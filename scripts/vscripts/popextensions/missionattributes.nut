IncludeScript("popextensions/customattributes")

PrecacheScriptSound("Announcer.MVM_Get_To_Upgrade")

const EFL_USER 					= 1048576
const HUNTSMAN_DAMAGE_FIX_MOD 	= 1.263157
const SCOUT_MONEY_COLLECTION_RADIUS = 288

if (!("ScriptLoadTable" in ROOT)) ::ScriptLoadTable   <- {}
if (!("ScriptUnloadTable" in ROOT)) ::ScriptUnloadTable <- {}

::MissionAttributes <- {

	noromecarrier = false //the rome tank removing stuff loops through every prop_dynamic if it can't find the carrier by name, skip the prop_dynamic loop if we already did it

	Attrs = {

		// =========================================
			// Replicates sigsegv-mvm: ForceHoliday.
			// Forces a tf_holiday for the mission.
			// Supported Holidays are:
			//	0 - None
			//	1 - Birthday
			//	2 - Halloween
			//	3 - Christmas
		// =========================================
		ForceHoliday = function(value) {

			// @param Holiday		Holiday number to force.
			// @error TypeError		If type is not an integer.
			// @error IndexError	If invalid holiday number is passed.
				// Error Handling
			try (value.tointeger()) catch(_) {RaiseTypeError(attr, "int"); success = false; return}
			if (type(value) != "integer") {RaiseTypeError(attr, "int"); success = false; return}
			if (value < kHoliday_None || value >= kHolidayCount) {RaiseIndexError(attr, [kHoliday_None, kHolidayCount - 1]); success = false; return}

			// Set Holiday logic
			MissionAttributes.SetConvar("tf_forced_holiday", value)
			if (value == kHoliday_None) return

			local ent = FindByName(null, "_popext_missionattr_holiday");
			if (ent != null) ent.Kill();

			SpawnEntityFromTable("tf_logic_holiday", {
				targetname   = "_popext_missionattr_holiday",
				holiday_type = value
			});

		}

		// =========================================
		// Restore original YER disguise behavior
		// =========================================
		YERDisguiseFix = function(params) {

			MissionAttributes.TakeDamageTable.YERDisguiseFix <- function(params) {
				local victim   = params.const_entity
				local attacker = params.inflictor

				if ( victim.IsPlayer() && params.damage_custom == TF_DMG_CUSTOM_BACKSTAB &&
					attacker != null && !attacker.IsBotOfType(TF_BOT_TYPE) &&
					(PopExtUtil.GetItemIndex(params.weapon) == ID_YOUR_ETERNAL_REWARD || PopExtUtil.GetItemIndex(params.weapon) == ID_WANGA_PRICK)
				) {
					attacker.GetScriptScope().stabvictim <- victim
					EntFireByHandle(attacker, "RunScriptCode", "PopExtUtil.SilentDisguise(self, stabvictim)", -1, null, null)
				}
			}
			MissionAttributes.SpawnHookTable.RemoveYERAttribute <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				local wep   = PopExtUtil.GetItemInSlot(player, SLOT_MELEE)
				local index = PopExtUtil.GetItemIndex(wep)

				if (index == ID_YOUR_ETERNAL_REWARD || index == ID_WANGA_PRICK)
					wep.RemoveAttribute("disguise on backstab")
			}
		}


		LooseCannonFix = function(params) {

			MissionAttributes.TakeDamageTable.LooseCannonFix <- function(params) {
				local wep = params.weapon

				if (PopExtUtil.GetItemIndex(wep) != ID_LOOSE_CANNON || params.damage_custom != TF_DMG_CUSTOM_CANNONBALL_PUSH) return

				params.damage *= wep.GetAttribute("damage bonus", 1.0)
			}
		}


		BotGibFix = function(params) {

			MissionAttributes.TakeDamageTable.BotGibFix <- function(params) {
				local victim = params.const_entity
				if (victim.IsPlayer() && !victim.IsMiniBoss() && victim.GetModelScale() <= 1.0 && params.damage >= victim.GetHealth() && (params.damage_type & DMG_CRITICAL || params.damage_type & DMG_BLAST))
				victim.SetModelScale(1.0000001, 0.0)
			}
		}

		HolidayPunchFix = function(params) {

			MissionAttributes.TakeDamageTable.HolidayPunchFix <- function(params) {
				local wep   = params.weapon
				local index = PopExtUtil.GetItemIndex(wep)
				if (index != ID_HOLIDAY_PUNCH || !(params.damage_type & DMG_CRITICAL)) return

				local victim = params.const_entity
				if (victim != null && victim.IsPlayer() && victim.IsBotOfType(TF_BOT_TYPE)) {
					victim.Taunt(TAUNT_MISC_ITEM, MP_CONCEPT_TAUNT_LAUGH)

					local tfclass = victim.GetPlayerClass()
					local class_string = PopExtUtil.Classes[tfclass]

					if (victim.GetModelName() == format("models/player/%s.mdl", class_string)) return

					local botmodel = format("models/bots/%s/bot_%s.mdl", class_string, class_string)

					victim.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", class_string))

					PopExtUtil.PlayerRobotModel(victim, botmodel)

					//overwrite the existing bot model think to remove it after taunt
					victim.GetScriptScope().PlayerThinkTable.BotModelThink <- function() {

						if (Time() > victim.GetTauntRemoveTime()) {
							if (wearable != null) wearable.Destroy()

							SetPropInt(self, "m_clrRender", 0xFFFFFF)
							SetPropInt(self, "m_nRenderMode", kRenderNormal)
							self.SetCustomModelWithClassAnimations(botmodel)

							SetPropString(self, "m_iszScriptThinkFunction", "")
						}
					}
				}
			}
		}

		EnableGlobalFixes = function() {
			local fixes = ["DragonsFuryFix", "FastNPCUpdate", "NoCreditVelocity", "ScoutBetterMoneyCollection", "HoldFireUntilFullReloadFix", "EngineerBuildingPushbackFix"]
			foreach (fix in fixes) {
				MissionAttributes[fix]()
			}
		}

		DragonsFuryFix = function() {
			MissionAttributes.ThinkTable.DragonsFuryFix <- function() {
				for (local fireball; fireball = FindByClassname(fireball, "tf_projectile_balloffire");)
					fireball.RemoveFlag(FL_GRENADE)
			}
		}

		FastNPCUpdate = function() {

			MissionAttributes.ThinkTable.FastNPCUpdate <- function() {
				local validnpcs = ["headless_hatman", "eyeball_boss", "merasmus", "tf_zombie"]

				foreach (npc in validnpcs)
					for (local n; n = FindByClassname(n, npc);)
						n.FlagForUpdate(true)
			}
		}


		NoCreditVelocity = function(params) {

			MissionAttributes.DeathHookTable.NoCreditVelocity <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (!player.IsBotOfType(TF_BOT_TYPE)) return

				for (local money; money = FindByClassname(money, "item_currencypack*");)
					money.SetAbsVelocity(Vector(1, 1, 1)) //0 velocity breaks our reverse mvm money pickup methods.  set to 1hu instead
			}
		}
		ScoutBetterMoneyCollection = function(params) {

			MissionAttributes.SpawnHookTable.ScoutBetterMoneyCollection <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE) || player.GetPlayerClass() != TF_CLASS_SCOUT) return

				player.GetScriptScope().PlayerThinkTable.MoneyThink <- function() {

					if (player.GetPlayerClass() != TF_CLASS_SCOUT || "ReverseMVMCurrencyThink" in player.GetScriptScope().PlayerThinkTable) {
						delete player.GetScriptScope().PlayerThinkTable.MoneyThink
						return
					}

					local origin = player.GetOrigin()
					for (local money; money = FindByClassnameWithin(money, "item_currencypack*", player.GetOrigin(), SCOUT_MONEY_COLLECTION_RADIUS);)
						money.SetOrigin(origin)
				}
			}
		}

		HoldFireUntilFullReloadFix = function(params) {

			MissionAttributes.SpawnHookTable.HoldFireUntilFullReloadFix <- function(params) {
				local player = GetPlayerFromUserID(params.userid)

				if (!player.IsBotOfType(TF_BOT_TYPE)) return

				local scope = player.GetScriptScope()
				scope.holdingfire <- false
				scope.lastfiretime <- 0.0

				scope.PlayerThinkTable.HoldFireThink <- function() {

					if (!player.HasBotAttribute(HOLD_FIRE_UNTIL_FULL_RELOAD)) return

					local activegun = player.GetActiveWeapon()
					if (activegun == null) return
					local clip = activegun.Clip1()
					if (clip == 0)
					{
						player.AddBotAttribute(SUPPRESS_FIRE)
						scope.holdingfire = true
					}
					else if (clip == activegun.GetMaxClip1() && scope.holdingfire)
					{
						player.RemoveBotAttribute(SUPPRESS_FIRE)
						scope.holdingfire = false
					}
				}
			}
		}
		// Doesn't fully work correctly, need to investigate
		EngineerBuildingPushbackFix = function(params) {

			MissionAttributes.SpawnHookTable.EngineerBuildingPushbackFix <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				// if (player.IsBotOfType(TF_BOT_TYPE)) return

				player.ValidateScriptScope()
				local scope = player.GetScriptScope()

				// 400, 500 (range, force)
				local epsilon = 20.0

				local blastjump_weapons = {
					tf_weapon_rocketlauncher = null
					tf_weapon_rocketlauncher_directhit = null
					tf_weapon_rocketlauncher_airstrike = null
				}

				scope.lastvelocity <- player.GetAbsVelocity()
				scope.nextthink <- -1
				scope.PlayerThinkTable.EngineerBuildingPushbackFix <- function() {
					if (scope.nextthink > -1 && Time() < scope.nextthink) return

					if (!PopExtUtil.IsAlive(self)) return

					local velocity = self.GetAbsVelocity()

					local wep       = self.GetActiveWeapon()
					local classname = (wep != null) ? wep.GetClassname() : ""
					local lastfire  = GetPropFloat(wep, "m_flLastFireTime")

					// We might have been pushed by an engineer building something, lets double check
					if( fabs((scope.lastvelocity - velocity).Length() - 700) < epsilon) {
						// Blast jumping can generate this type of velocity change in a frame, lets check for that
						if (self.InCond(TF_COND_BLASTJUMPING) && classname in blastjump_weapons && (Time() - lastfire < 0.1))
							return

						// Even with the above check, some things still sneak through so lets continue filtering

						// Look around us to see if there's a building hint and bot engineer within range
						local origin   = self.GetOrigin()
						local engie    = null
						local hint     = null

						for (local player; player = Entities.FindByClassnameWithin(player, "player", origin, 650);) {
							if (!player.IsBotOfType(TF_BOT_TYPE) || player.GetPlayerClass() != TF_CLASS_ENGINEER) continue

							engie = player
							break
						}

						if (engie != null)
							hint = Entities.FindByClassnameWithin(null, "bot_hint_*", engie.GetOrigin(), 200)

						// Counteract impulse velocity
						if (hint != null && engie != null) {
							// ClientPrint(null, 3, "COUNTERACTING VELOCITY")
							local dir =  self.EyePosition() - hint.GetOrigin()

							dir.z = 0
							dir.Norm()
							dir.z = 1

							local push = dir * 500
							self.SetAbsVelocity(velocity - push)

							nextthink = Time() + 1
						}
					}

					lastvelocity = velocity
				}
			}
		}
		// =================================
		// disable random crits for red bots
		// =================================

		RedBotsNoRandomCrit = function(value) {

			MissionAttributes.SpawnHookTable.RedBotsNoRandomCrit <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (!player.IsBotOfType(TF_BOT_TYPE) && player.GetTeam() != TF_TEAM_PVE_DEFENDERS) return

				PopExtUtil.AddAttributeToLoadout(player, "crit mod disabled hidden", 0)
			}

		}

		// =====================
		// disable crit pumpkins
		// =====================

		NoCrumpkins = function(value) {

			local pumpkinIndex = PrecacheModel("models/props_halloween/pumpkin_loot.mdl")

			MissionAttributes.ThinkTable.NoCrumpkins <- function() {
				switch(value)
				{
				case 1:
					for (local pumpkin; pumpkin = FindByClassname(pumpkin, "tf_ammo_pack");)
						if (GetPropInt(pumpkin, "m_nModelIndex") == pumpkinIndex)
							EntFireByHandle(pumpkin, "Kill", "", -1, null, null) //should't do .Kill() in the loop, entfire kill is delayed to the end of the frame.
				}

				foreach (player in PopExtUtil.PlayerArray)
					if (player.InCond(TF_COND_CRITBOOSTED_PUMPKIN)) //TF_COND_CRITBOOSTED_PUMPKIN
						EntFireByHandle(player, "RunScriptCode", "self.RemoveCond(TF_COND_CRITBOOSTED_PUMPKIN)", -1, null, null)

			}

		}

		// ===================
		// disable reanimators
		// ===================

		NoReanimators = function(value) {

			if (value < 1) return

			MissionAttributes.DeathHookTable.NoReanimators <- function(params) {
				for (local revivemarker; revivemarker = FindByClassname(revivemarker, "entity_revive_marker");)
					EntFireByHandle(revivemarker, "Kill", "", -1, null, null)
			}

		}


		// ====================
		// set all mobber cvars
		// ====================

		AllMobber = function(value) {

			if (value < 1) return

			MissionAttributes.SetConvar("tf_bot_escort_range", INT_MAX)
			MissionAttributes.SetConvar("tf_bot_flag_escort_range", INT_MAX)
			MissionAttributes.SetConvar("tf_bot_flag_escort_max_count", 0)

		}


		// ===========================
		// allow standing on bot heads
		// ===========================

		StandableHeads = function(value) {

			local movekeys = IN_FORWARD | IN_BACK | IN_LEFT | IN_RIGHT
			MissionAttributes.SpawnHookTable.StandableHeads <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				player.GetScriptScope().PlayerThinkTable.StandableHeads <- function() {
					local groundent = GetPropEntity(player, "m_hGroundEntity")

					if (!groundent || !groundent.IsPlayer() || PopExtUtil.InButton(player, movekeys)) return
					player.SetAbsVelocity(Vector())
				}
			}
		}

		// =================================================
		// doesn't work until wave switches, won't work on W1
		// =================================================

		"666Wavebar": function(value) { //need quotes for this guy.
			MissionAttributes.StartWaveTable.EventWavebar <- function(params) { SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount", value) }
			MissionAttributes.StartWaveTable.EventWavebar(null)
		}

		// ===================================
		// sets the wave number on the wavebar
		// ===================================

		WaveNum = function(value) {
			MissionAttributes.StartWaveTable.SetWaveNum <- function(params) { SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount", value) }
			MissionAttributes.StartWaveTable.SetWaveNum(null)
		}

		// =======================================
		// sets the max wave number on the wavebar
		// =======================================

		MaxWaveNum = function(value) {
			MissionAttributes.StartWaveTable.SetMaxWaveNum <- function(params) { SetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineMaxWaveCount", value) }
			MissionAttributes.StartWaveTable.SetMaxWaveNum(null)
		}

		// =============================================================================
		// Enable this to fix huntsman damage bonus not scaling correctly
		// WARNING: Rafmod already does this, enabling this on potato servers will stack
		// =============================================================================

		HuntsmanDamageFix = function(value) {
			MissionAttributes.TakeDamageTable.HuntsmanDamageFix <- function(params) {
				local wep = params.weapon

				if (GetPropString(wep, "m_iClassname") != "tf_weapon_compound_bow") return

				if (wep.GetAttribute("damage bonus", 1.0) != 1.0) params.damage *= HUNTSMAN_DAMAGE_FIX_MOD
			}
		}

		// =========================================================
		// UNFINISHED
		// =========================================================

		NegativeDmgHeals = function(value) {
			// function NegativeDmgHeals(params) {
			// 	local player = params.const_entity

			// 	local damage = params.damage
			// 	if (!player.IsPlayer() || damage > 0) return

			// 	if ((value == 2 && player.GetHealth() - damage > player.GetMaxHealth()) || //don't overheal is value is 2
			// 	(value == 1 && player.GetHealth() - damage > player.GetMaxHealth() * 1.5)) return //don't go past max overheal if value is 1

			// 	player.SetHealth(player.GetHealth() - damage)

			// }
			// MissionAttributes.TakeDamageTable.NegativeDmgHeals <- MissionAttributes.NegativeDmgHeals
		}
		// ==============================================================
		// Allows spies to place multiple sappers when item meter is full
		// ==============================================================

		MultiSapper = function(value) {

			MissionAttributes.SpawnHookTable.MultiSapper <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE) || player.GetPlayerClass() < TF_CLASS_SPY) return

				player.GetScriptScope().BuiltObjectTable.MultiSapper <- function(params) {
					if (params.object != OBJ_ATTACHMENT_SAPPER) return
					local sapper = EntIndexToHScript(params.index)
					SetPropBool(sapper, "m_bDisposableBuilding", true)
				}
			}
		}

		// =======================================================================================
		// Fix "Set DamageType Ignite" not actually making most weapons ignite on hit
		// WARNING: Rafmod already does this, enabling this on potato servers will ALWAYS stack,
		// 			since there does not seem to be a way to turn off the rafmod fix
		// =======================================================================================

		SetDamageTypeIgniteFix = function(value) {

			// Afterburn damage and duration varies from weapon to weapon, we don't want to override those
			// This list leaves out only the volcano fragment and the heater
			local ignitingWeaponsClassname = [
				"tf_weapon_particle_cannon",
				"tf_weapon_flamethrower",
				"tf_weapon_rocketlauncher_fireball",
				"tf_weapon_flaregun",
				"tf_weapon_flaregun_revenge",
				"tf_weapon_compound_bow"
			]

			MissionAttributes.TakeDamageTable.SetDamageTypeIgniteFix <- function(params) {

				local wep = params.weapon
				local victim = params.const_entity
				local attacker = params.inflictor

				if ( wep == null || attacker == null || attacker == victim
					|| wep.GetClassname() in ignitingWeaponsClassname
					|| PopExtUtil.GetItemIndex(wep) == ID_HUO_LONG_HEATMAKER
					|| PopExtUtil.GetItemIndex(wep) == ID_SHARPENED_VOLCANO_FRAGMENT
					|| wep.GetAttribute("Set DamageType Ignite", 10) == 10
				) return

				PopExtUtil.Ignite(victim)
			}
		}

		// =========================================================

		//all of these could just be set directly in the pop easily, however popfile's have a 4096 character limit for vscript so might as well save space

		NoRefunds = function(value) {
			MissionAttributes.SetConvar("tf_mvm_respec_enabled", 0);
		}

		// =========================================================

		RefundLimit = function(value) {
			MissionAttributes.SetConvar("tf_mvm_respec_enabled", 1)
			MissionAttributes.SetConvar("tf_mvm_respec_limit", value)
		}

		// =========================================================

		RefundGoal = function(value) {
			MissionAttributes.SetConvar("tf_mvm_respec_enabled", 1)
			MissionAttributes.SetConvar("tf_mvm_respec_credit_goal", value)
		}

		// =========================================================

		FixedBuybacks = function(value) {
			MissionAttributes.SetConvar("tf_mvm_buybacks_method", 1)
		}

		// =========================================================

		BuybacksPerWave = function(value) {
			MissionAttributes.SetConvar("tf_mvm_buybacks_per_wave", value)
		}

		// =========================================================

		NoBuybacks = function(value) {
			MissionAttributes.SetConvar("tf_mvm_buybacks_method", value)
			MissionAttributes.SetConvar("tf_mvm_buybacks_per_wave", 0)
		}

		// =========================================================

		DeathPenalty = function(value) {
			MissionAttributes.SetConvar("tf_mvm_death_penalty", value)
		}

		// =========================================================

		BonusRatioHalf = function(value) {
			MissionAttributes.SetConvar("tf_mvm_currency_bonus_ratio_min", value)
		}

		// =========================================================

		BonusRatioFull = function(value) {
			MissionAttributes.SetConvar("tf_mvm_currency_bonus_ratio_max", value)
		}

		// =========================================================

		UpgradeFile = function(value) {
			EntFire("tf_gamerules", "SetCustomUpgradesFile", value)
		}

		// =========================================================

		FlagEscortCount = function(value) {
			MissionAttributes.SetConvar("tf_bot_flag_escort_max_count", value)
		}

		// =========================================================

		BombMovementPenalty = function(value) {
			MissionAttributes.SetConvar("tf_mvm_bot_flag_carrier_movement_penalty", value)
		}

		// =========================================================

		MaxSkeletons = function(value) {
			MissionAttributes.SetConvar("tf_max_active_zombie", value)
		}

		// =========================================================

		TurboPhysics = function(value) {
			MissionAttributes.SetConvar("sv_turbophysics", value)
		}

		// =========================================================

		Accelerate = function(value) {
			MissionAttributes.SetConvar("sv_accelerate", value)
		}

		// =========================================================

		AirAccelerate = function(value) {
			MissionAttributes.SetConvar("sv_airaccelerate", value)
		}

		// =========================================================

		BotPushaway = function(value) {
			MissionAttributes.SetConvar("tf_avoidteammates_pushaway", value)
		}

		// =========================================================

		TeleUberDuration = function(value) {
			MissionAttributes.SetConvar("tf_mvm_engineer_teleporter_uber_duration", value)
		}

		// =========================================================

		RedMaxPlayers = function(value) {
			MissionAttributes.SetConvar("tf_mvm_defenders_team_size", value)
		}

		// =========================================================

		MaxVelocity = function(value) {
			MissionAttributes.SetConvar("sv_maxvelocity", value)
		}

		// =========================================================

		ConchHealthOnHitRegen = function(value) {
			MissionAttributes.SetConvar("tf_dev_health_on_damage_recover_percentage", value)
		}

		// =========================================================

		MarkForDeathLifetime = function(value) {
			MissionAttributes.SetConvar("tf_dev_marked_for_death_lifetime", value)
		}

		// =========================================================

		GrapplingHookEnable = function(value) {
			MissionAttributes.SetConvar("tf_grapplinghook_enable", value)
		}

		// =========================================================

		GiantScale = function(value) {
			MissionAttributes.SetConvar("tf_mvm_miniboss_scale", value)
		}

		// =========================================================

		VacNumCharges = function(value) {
			MissionAttributes.SetConvar("weapon_medigun_resist_num_chunks", value)
		}

		// =========================================================

		DoubleDonkWindow = function(value) {
			MissionAttributes.SetConvar("tf_double_donk_window", value)
		}

		// =========================================================

		ConchSpeedBoost = function(value) {
			MissionAttributes.SetConvar("tf_whip_speed_increase", value)
		}

		// =========================================================

		StealthDmgReduction = function(value) {
			MissionAttributes.SetConvar("tf_stealth_damage_reduction", value)
		}

		// =========================================================

		FlagCarrierCanFight = function(value) {
			MissionAttributes.SetConvar("tf_mvm_bot_allow_flag_carrier_to_fight", value)
		}

		// =========================================================

		HHHChaseRange = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_chase_range", value)
		}

		// =========================================================

		HHHAttackRange = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_attack_range", value)
		}

		// =========================================================

		HHHQuitRange = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_quit_range", value)
		}

		// =========================================================

		HHHTerrifyRange = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_terrify_radius", value)
		}

		// =========================================================

		HHHHealthBase = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_health_base", value)
		}

		// =========================================================

		HHHHealthPerPlayer = function(value) {
			MissionAttributes.SetConvar("tf_halloween_bot_health_per_player", value)
		}

		// =========================================================

		HalloweenBossNotSolidToPlayers = function(value) {
			MissionAttributes.HalloweenBossNotSolidToPlayers <- true
		}

		// =========================================================

		SentryHintBombForwardRange = function(value) {
			MissionAttributes.SetConvar("tf_bot_engineer_mvm_sentry_hint_bomb_forward_range", value)
		}

		// =========================================================

		SentryHintBombBackwardRange = function(value) {
			MissionAttributes.SetConvar("tf_bot_engineer_mvm_sentry_hint_bomb_backward_range", value)
		}

		// =========================================================

		SentryHintMinDistanceFromBomb = function(value) {
			MissionAttributes.SetConvar("tf_bot_engineer_mvm_hint_min_distance_from_bomb", value)
		}

		// =========================================================

		NoBusterFF = function(value) {
			if (value != 1 || value != 0 ) RaiseIndexError(attr)
			MissionAttributes.SetConvar("tf_bot_suicide_bomb_friendly_fire", value = 1 ? 0 : 1)
		}

		// =========================================================

		HalloweenBossNotSolidToPlayers = function(value) {
			for (local hatman; hatman = FindByClassname(hatman, "headless_hatman");)
				hatman.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		}

		// =========================================================

		// =====================
		// Disable sniper lasers
		// =====================

		SniperHideLasers = function(value) {

			if (value < 1) return

			MissionAttributes.ThinkTable.SniperHideLasers <- function() {
				for (local dot; dot = FindByClassname(dot, "env_sniperdot");)
					if (dot.GetOwner().GetTeam() == TF_TEAM_PVE_INVADERS)
						EntFireByHandle(dot, "Kill", "", -1, null, null)

				return -1;
			}
		}

		// ===================================
		// lose wave when all players are dead
		// ===================================

		TeamWipeWaveLoss = function(value) {

			MissionAttributes.DeathHookTable.TeamWipeWaveLoss <- function(params) {
				if (!PopExtUtil.IsWaveStarted) return
				EntFire("tf_gamerules", "RunScriptCode", "if (PopExtUtil.CountAlivePlayers() == 0) EntFire(`__utilroundwin`, `RoundWin`)")
			}
		}

		// =================================================================================
		// change sentry kill count per mini-boss kill.  -4 will make giants count as 1 kill
		// =================================================================================

		GiantSentryKillCountOffset = function(value) {

			MissionAttributes.DeathHookTable.GiantSentryKillCount <- function(params) {

				local sentry = EntIndexToHScript(params.inflictor_entindex)
				local victim = GetPlayerFromUserID(params.userid)

				if (sentry == null) return

				if (sentry.GetClassname() != "obj_sentrygun" || !victim.IsMiniBoss()) return
				local kills = GetPropInt(sentry, "m_iKills")
				SetPropInt(sentry, "m_iKills", kills + value)
			}
		}

		// ========================================================================
		// set reset time for flags (bombs).
		// accepts a key/value table of flag targetnames and their new return times
		// can also just accept a float value to apply to all flags
		// ========================================================================

		FlagResetTime = function(value) {

			MissionAttributes.FlagResetTime <- function() {
				for (local flag; flag = FindByClassname(flag, "item_teamflag");)
				{
					if (typeof value == "table")
						foreach (k, v in value)
							EntFire(k, "SetReturnTime", v.tostring())

					else if (typeof value == "integer" || typeof value == "float")
						EntFire("item_teamflag", "SetReturnTime", value.tostring())
				}
			}
			MissionAttributes.FlagResetTime()
		}

		// =============================
		// enable bot/blu team headshots
		// =============================

		BotHeadshots = function(value) {

			if (value < 1) return

			MissionAttributes.TakeDamageTable.BotHeadshots <- function(params) {

				local player = params.attacker, victim = params.const_entity
				local wep = params.weapon

				if (!player.IsPlayer() || !victim.IsPlayer()) return

				function CanHeadshot()
				{
					//check for head hitgroup, or for headshot dmg type but no crit dmg type (huntsman quirk)
					if (GetPropInt(victim, "m_LastHitGroup") == HITGROUP_HEAD || (params.damage_stats == TF_DMG_CUSTOM_HEADSHOT && !(params.damage_type & DMG_CRITICAL)))
					{
						//are we sniper and do we have a non-sleeper primary?
						if (player.GetPlayerClass() == TF_CLASS_SNIPER && wep && wep.GetSlot() != SLOT_SECONDARY && PopExtUtil.GetItemIndex(wep) != ID_SYDNEY_SLEEPER)
							return true

						//are we using classic and is charge meter > 150?  This isn't correct but no GetAttributeValue
						if (GetPropFloat(wep, "m_flChargedDamage") >= 150.0 && PopExtUtil.GetItemIndex(wep) == ID_CLASSIC)
							return true

						//are we using the ambassador?
						if (PopExtUtil.GetItemIndex(wep) == ID_AMBASSADOR || PopExtUtil.GetItemIndex(wep) == ID_FESTIVE_AMBASSADOR)
							return true

						//did the victim just get explosive headshot? only checks for bleed cond + stun effect so can be edge cases where this returns false erroneously.
						if (!victim.InCond(TF_COND_BLEEDING) && !(GetPropInt(victim, "m_iStunFlags") & TF_STUN_MOVEMENT)) //check for explosive headshot victim.
							return true
					}
					return false
				}

				if (!CanHeadshot()) return

				params.damage_type = params.damage_type | DMG_CRITICAL //DMG_USE_HITLOCATIONS doesn't actually work here, no headshot icon.
				params.damage_stats = TF_DMG_CUSTOM_HEADSHOT
			}
		}

		// ==============================================================
		// Uses bitflags to enable certain behavior
		// 1  = Robot animations (excluding sticky demo and jetpack pyro)
		// 2  = Human animations
		// 4  = Enable footstep sfx
		// 8  = Enable voicelines (WIP)
		// 16 = Enable viewmodels (WIP)
		// ==============================================================

		PlayersAreRobots = function(value) {

			// TODO: Make PlayersAreRobots 16 and HandModelOverride incompatible
			// Doesn't work
			/*
			ScriptLoadTable.PlayersAreRobotsReset <- function() {
				DoEntFire("__bot_bonemerge_model", "Kill", "", -1, null, null)
				printl("TEST TEST TEST")
				foreach (player in PopExtUtil.HumanArray) {
					player.ValidateScriptScope()
					local scope = player.GetScriptScope()

					EntFireByHandle(player, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", PopExtUtil.Classes[player.GetPlayerClass()]), -1, null, null)
					SetPropInt(player, "m_clrRender", 0xFFFFFF)
					SetPropInt(player, "m_nRenderMode", kRenderNormal)
				}
				delete ScriptLoadTable.PlayersAreRobotsReset
			}
			*/

			MissionAttributes.SpawnHookTable.PlayersAreRobots <- function(params) {
				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				player.ValidateScriptScope()
				local scope = player.GetScriptScope()

				if ("wearable" in scope && scope.wearable != null) {
					scope.wearable.Destroy()
					scope.wearable <- null
				}

				local playerclass  = player.GetPlayerClass()
				local class_string = PopExtUtil.Classes[playerclass]
				local model = format("models/bots/%s/bot_%s.mdl", class_string, class_string)

				if (value & 1) {
					//sticky anims and thruster anims are particularly problematic
					if (PopExtUtil.HasItemInLoadout(player, "tf_weapon_pipebomblauncher") || PopExtUtil.HasItemInLoadout(player, ID_THERMAL_THRUSTER)) {
						PopExtUtil.PlayerRobotModel(player, model)
						return
					}

					EntFireByHandle(player, "SetCustomModelWithClassAnimations", model, 1, null, null)
					PopExtUtil.SetEntityColor(player, 255, 255, 255, 255)
					SetPropInt(player, "m_nRenderMode", kRenderFxNone) //dangerous constant name lol
				}

				if (value & 2) {
					if (value & 1) value = value & 1 //incompatible flags
					PopExtUtil.PlayerRobotModel(player, model)
				}

				if (value & 4) {
					scope.stepside <- GetPropInt(player, "m_Local.m_nStepside")

					function StepThink() {
						if (self.GetPlayerClass() == TF_CLASS_MEDIC) return

						if (GetPropInt(self,"m_Local.m_nStepside") != scope.stepside)
							EmitSoundOn("MVM.BotStep", self)

						scope.stepside = GetPropInt(self,"m_Local.m_nStepside")
						return -1
					}
					if (!("StepThink" in scope.PlayerThinkTable))
						scope.PlayerThinkTable.StepThink <- StepThink


				} else if ("StepThink" in scope.PlayerThinkTable) delete scope.PlayerThinkTable.StepThink

				if (value & 8) {
					MissionAttributes.ThinkTable.RobotVOThink <- function() {

						for (local ent; ent = FindByClassname(ent, "instanced_scripted_scene"); ) {
							if (ent.IsEFlagSet(EFL_USER)) continue
							ent.AddEFlags(EFL_USER)
							local owner = GetPropEntity(ent, "m_hOwner")
							if (owner != null && !owner.IsBotOfType(TF_BOT_TYPE)) {

								local vcdpath = GetPropString(ent, "m_szInstanceFilename");
								if (!vcdpath || vcdpath == "") return -1

								local dotindex	 = vcdpath.find(".")
								local slashindex = null;
								for (local i = dotindex; i >= 0; --i) {
									if (vcdpath[i] == '/' || vcdpath[i] == '\\') {
										slashindex = i
										break
									}
								}

								owner.ValidateScriptScope()
								local scope = owner.GetScriptScope()
								scope.soundtable <- VCD_SOUNDSCRIPT_MAP[owner.GetPlayerClass()]
								scope.vcdname	 <- vcdpath.slice(slashindex+1, dotindex)

								if (scope.vcdname in scope.soundtable) {
									local soundscript = scope.soundtable[scope.vcdname];
									if (typeof soundscript == "string")
										PopExtUtil.StopAndPlayMVMSound(owner, soundscript, 0);
									else if (typeof soundscript == "array")
										foreach (sound in soundscript)
											PopExtUtil.StopAndPlayMVMSound(owner, sound[1], sound[0]);
								}
							}
						}
						return -1;
					}

				} else if ("RobotVOThink" in scope.PlayerThinkTable) delete scope.PlayerThinkTable.RobotVOThink

				if (value & 16) {

					//run this with a delay for LoadoutControl

					EntFireByHandle(player, "RunScriptCode", @"

						if (`HandModelOverride` in MissionAttributes.SpawnHookTable) return

						local vmodel   = PopExtUtil.ROBOT_ARM_PATHS[self.GetPlayerClass()]
						local playervm = GetPropEntity(self, `m_hViewModel`)
						if (playervm == null) return
						playervm.GetOrigin()

						if (playervm == null) return

						if (playervm.GetModelName() != vmodel) playervm.SetModelSimple(vmodel)

						for (local i = 0; i < SLOT_COUNT; i++) {

							local wep = GetPropEntityArray(self, `m_hMyWeapons`, i)
							if (wep == null || wep.GetModelName() == vmodel) continue

							wep.SetModelSimple(vmodel)
							wep.SetCustomViewModel(vmodel)
						}

					", SINGLE_TICK, null, null)

				}
			}
		}

		// =======================================================
		// Uses bitflags to change behavior:
		// 1   =	 Blu bots use human models.
		// 2   = 	 Blu bots use zombie models. Overrides human models.
		// 4   =	 Red bots use human models.
		// 4   =	 Red bots use zombie models. Overrides human models.
		// 128 = 	 Include buster
		// =======================================================

		BotsAreHumans = function(value) {

			MissionAttributes.SpawnHookTable.BotsAreHumans <- function(params) {

				local player = GetPlayerFromUserID(params.userid)

				if (!player.IsBotOfType(TF_BOT_TYPE)) return

				MissionAttributes.HumanModel <- function(player)
				{

					if ("usingcustommodel" in player.GetScriptScope() || (!(value & 128) && player.GetModelName() ==  "models/bots/demo/bot_sentry_buster.mdl")) return

					local classname = PopExtUtil.Classes[player.GetPlayerClass()]
					if (player.GetTeam() == TF_TEAM_PVE_INVADERS && value > 0)
					{
						player.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", classname))
						if (value & 2)
						{
							// CTFBot.GenerateAndWearItem() works here, but causes a big perf warning spike on bot spawn
							// faking it doesn't do this
							PopExtUtil.CreatePlayerWearable(player, format("models/player/items/%s/%s_zombie.mdl", classname, classname))
							SetPropBool(player, "m_bForcedSkin", true)
							SetPropInt(player, "m_nForcedSkin", player.GetSkin() + 4)
							SetPropInt(player, "m_iPlayerSkinOverride", 1)
						}
					}

					if (player.GetTeam() == TF_TEAM_PVE_INVADERS && value & 4)
					{

						player.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", classname))
						if (value & 8)
						{
							format(PopExtUtil.CreatePlayerWearable(player, "models/player/items/%s/%s_zombie.mdl"), classname, classname)
							SetPropBool(player, "m_bForcedSkin", true)
							SetPropInt(player, "m_nForcedSkin", player.GetSkin() + 4)
							SetPropInt(player, "m_iPlayerSkinOverride", 1)
						}
					}
				}

				EntFireByHandle(player, "RunScriptCode", "try MissionAttributes.HumanModel(self) catch(_) return", 0.033, null, null)
			}
		}

		// ==============================================================
		// 1 = disables romevision on bots 2 = disables rome carrier tank
		// ==============================================================

		NoRome = function(value) {

			local carrierPartsIndex = GetModelIndex("models/bots/boss_bot/carrier_parts.mdl")

			MissionAttributes.SpawnHookTable.NoRome <- function(params) {

				local bot = GetPlayerFromUserID(params.userid)

				EntFireByHandle(bot, "RunScriptCode", @"
					if (self.IsBotOfType(TF_BOT_TYPE))
						// if (!self.HasBotTag(`popext_forceromevision`)) //handle these elsewhere
							for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
								if (child.GetClassname() == `tf_wearable` && startswith(child.GetModelName(), format(`models/workshop/player/items/%s/tw`, PopExtUtil.Classes[self.GetPlayerClass()])))
									EntFireByHandle(child, `Kill`, ``, -1, null, null)
				", -1, null, null)

				if (value < 2 || MissionAttributes.noromecarrier) return

				local carrier = FindByName(null, "botship_dynamic") //some maps have a targetname for it

				if (carrier == null) {
					for (local props; props = FindByClassname(props, "prop_dynamic");) {
						if (GetPropInt(props, "m_nModelIndex") != carrierPartsIndex) continue

						carrier = props
						break
					}

				}
				SetPropIntArray(carrier, "m_nModelIndexOverrides", carrierPartsIndex, VISION_MODE_ROME)
				MissionAttributes.noromecarrier = true
			}
		}

		// =========================================================

		SpellRateCommon = function(value) {

			MissionAttributes.SetConvar("tf_spells_enabled", 1)
			MissionAttributes.DeathHookTable.SpellRateCommon <- function(params) {
				if (RandomFloat(0, 1) > value) return

				local bot = GetPlayerFromUserID(params.userid)
				if (!bot.IsBotOfType(TF_BOT_TYPE) || bot.IsMiniBoss()) return

				local spell = SpawnEntityFromTable("tf_spell_pickup", {targetname = "_commonspell" origin = bot.GetLocalOrigin() TeamNum = TF_TEAM_PVE_DEFENDERS tier = 0 "OnPlayerTouch": "!self,Kill,,0,-1" })
			}

		}

		// =========================================================

		SpellRateGiant = function(value) {

			MissionAttributes.SetConvar("tf_spells_enabled", 1)
			MissionAttributes.DeathHookTable.SpellRateGiant <- function(params) {
				if (RandomFloat(0, 1) > value) return

				local bot = GetPlayerFromUserID(params.userid)
				if (!bot.IsBotOfType(TF_BOT_TYPE) || !bot.IsMiniBoss()) return

				local spell = SpawnEntityFromTable("tf_spell_pickup", {targetname = "_giantspell" origin = bot.GetLocalOrigin() TeamNum = TF_TEAM_PVE_DEFENDERS tier = 0 "OnPlayerTouch": "!self,Kill,,0,-1" })
			}

		}

		// =========================================================

		RareSpellRateCommon = function(value) {

			MissionAttributes.SetConvar("tf_spells_enabled", 1)
			MissionAttributes.DeathHookTable.RareSpellRateCommon <- function(params) {
				if (RandomFloat(0, 1) > value) return

				local bot = GetPlayerFromUserID(params.userid)
				if (!bot.IsBotOfType(TF_BOT_TYPE) || bot.IsMiniBoss()) return

				local spell = SpawnEntityFromTable("tf_spell_pickup", {targetname = "_commonspell" origin = bot.GetLocalOrigin() TeamNum = TF_TEAM_PVE_DEFENDERS tier = 1 "OnPlayerTouch": "!self,Kill,,0,-1" })
			}

		}

		// =========================================================

		RareSpellRateGiant = function(value) {

			MissionAttributes.SetConvar("tf_spells_enabled", 1)
			MissionAttributes.DeathHookTable.RareSpellRateGiant <- function(params) {
				if (RandomFloat(0, 1) > value) return

				local bot = GetPlayerFromUserID(params.userid)
				if (!bot.IsBotOfType(TF_BOT_TYPE) || !bot.IsMiniBoss()) return

				local spell = SpawnEntityFromTable("tf_spell_pickup", {targetname = "_giantspell" origin = bot.GetLocalOrigin() TeamNum = TF_TEAM_PVE_DEFENDERS tier = 1 "OnPlayerTouch": "!self,Kill,,0,-1" })
			}

		}

		// ===========================================================================================
		//skeleton's spawned by bots or tf_zombie entities will no longer split into smaller skeletons
		// ===========================================================================================

		NoSkeleSplit = function(value) {

			MissionAttributes.ThinkTable.NoSkeleSplit <- function() {

				//kill skele spawners before they split from tf_zombie_spawner
				for (local skelespell; skelespell = FindByClassname(skelespell, "tf_projectile_spellspawnzombie"); )
					if (GetPropEntity(skelespell, "m_hThrower") == null)
						EntFireByHandle(skelespell, "Kill", "", -1, null, null)

				// m_hThrower does not change when the skeletons split for spell-casted skeles, just need to kill them after spawning
				for (local skeles; skeles = FindByClassname(skeles, "tf_zombie");  ) {
					//kill blu split skeles
					if (skeles.GetModelScale() == 0.5 && (skeles.GetOwner() == null || skeles.GetOwner().IsBotOfType(TF_BOT_TYPE))) {
						EntFireByHandle(skeles, "Kill", "", -1, null, null)
						return
					}
					// if (skeles.GetTeam() == 5) {
					// 	skeles.SetTeam(TF_TEAM_PVE_INVADERS)
					// 	skeles.SetSkin(1)
					// }
				}
			}

		}

		// ====================================================================
		// ready-up countdown time.  Values below 9 will disable starting music
		// ====================================================================

		WaveStartCountdown = function(value) {

			MissionAttributes.ThinkTable.WaveStartCountdown <- function() {
				if (PopExtUtil.IsWaveStarted) return

				local roundtime = GetPropFloat(PopExtUtil.GameRules, "m_flRestartRoundTime")
				if (roundtime > Time() + value) {
					local ready = PopExtUtil.GetPlayerReadyCount()
					if (ready >= PopExtUtil.HumanArray.len() || (roundtime <= 12.0))
						SetPropFloat(PopExtUtil.GameRules, "m_flRestartRoundTime", Time() + value)
				}
			}
		}

		// =======================================================================================================================
		// array of arrays with xyz values to spawn path_tracks at
		// path_track names are ordered based on where they are listed in the array

		// example:

		//`ExtraTankPath`: [
		//	[`686 4000 392`, `667 4358 390`, `378 4515 366`, `-193 4250 289`], // starting node: extratankpath1_1
		//	[`640 5404 350`, `640 4810 350`, `640 4400 550`, `1100 4100 650`, `1636 3900 770`] //starting node: extratankpath2_1
		//]
		// the last track in the list will have _lastnode appended to the targetname
		// ======================================================================================================================

		ExtraTankPath = function(value) {

			if (typeof value != "array") {
				PopExtMain.Error.RaiseValueError("ExtraTankPath", value, "Value must be array")
				success = false
				return
			}
			if (!("ExtraTankPathTracks" in MissionAttributes)) MissionAttributes.ExtraTankPathTracks <- []
			foreach (path in value) {

				local tracks = []

				MissionAttributes.PathNum++

				foreach (i, pos in path) {
					local org = split(pos, " ")

					local track = SpawnEntityFromTable("path_track", {
						targetname = format("extratankpath%d_%d", MissionAttributes.PathNum, i+1)
						origin = Vector(org[0].tointeger(), org[1].tointeger(), org[2].tointeger())
					})
					tracks.append(track)
				}

			local lastnode = tracks[tracks.len() - 1]
			PopExtUtil.SetTargetname(lastnode, format("%s_lastnode", GetPropString(lastnode, "m_iName")))

			tracks.append(null) //dummy value to put at the end

			for (local i = 0; i < tracks.len() - 1; i++)
				if (tracks[i] != null)
					SetPropEntity(tracks[i], "m_pnext", tracks[i+1])
			}
		}


		// =======================================
		// replace viewmodel arms with custom ones
		// =======================================

		HandModelOverride = function(value) {

			MissionAttributes.SpawnHookTable.HandModelOverride <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				player.ValidateScriptScope()
				local scope = player.GetScriptScope()

				scope.PlayerThinkTable.ArmThink <- function() {
					local tfclass	   = player.GetPlayerClass()
					local class_string = PopExtUtil.Classes[tfclass]

					local vmodel   = null
					local playervm = GetPropEntity(player, "m_hViewModel")

					if (typeof value == "string")
						vmodel = PopExtUtil.StringReplace(value, "%class", class_string);
					else if (typeof value == "array") {
						if (value.len() == 0) return

						if (tfclass >= value.len())
							vmodel = PopExtUtil.StringReplace(value[0], "%class", class_string);
						else
							vmodel = value[tfclass]
					}
					else {
						// do we need to do anything special for thinks??
						PopExtMain.Error.RaiseValueError("HandModelOverride", value, "Value must be string or array of strings")
						return
					}

					if (vmodel == null) return

					if (playervm.GetModelName() != vmodel) playervm.SetModelSimple(vmodel)

					for (local i = 0; i < SLOT_COUNT; i++) {
						local wep = GetPropEntityArray(player, "m_hMyWeapons", i)
						if (wep == null || (wep.GetModelName() == vmodel)) continue

						wep.SetModelSimple(vmodel)
						wep.SetCustomViewModel(vmodel)
					}
				}
			}
		}

		// ===========================================================
		// add cond to every player on spawn with an optional duration
		// ===========================================================

		AddCond = function(value) {

			MissionAttributes.SpawnHookTable.AddCond <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				if (typeof value == "array") {

					player.RemoveCondEx(value[0], true)
					EntFireByHandle(player, "RunScriptCode", format("self.AddCondEx(%d, %f, null)", value[0], value[1]), -1, null, null)
				}
				else if (typeof value == "integer") {

					player.RemoveCond(value)
					EntFireByHandle(player, "RunScriptCode", format("self.AddCond(%d)", value), -1, null, null)
				}
			}
		}

		// ======================================================
		// add/modify player attributes, can be filtered by class
		// ======================================================

		PlayerAttributes = function(value) {

			MissionAttributes.SpawnHookTable.PlayerAttributes <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return
				if (typeof value != "table") {
					PopExtMain.Error.RaiseValueError("PlayerAttributes", value, "Value must be table")
					success = false
					return
				}

				local tfclass = player.GetPlayerClass()
				foreach (k, v in value)
				{
					if (typeof v != "table")
					PopExtUtil.SetPlayerAttributes(player, k, v)
					else if (tfclass in value)
					{
						local table = value[tfclass]
						foreach (k, v in table) {
							PopExtUtil.SetPlayerAttributes(player, k, v)
						}
					}
				}
			}
		}

		// ======================================================================
		// add/modify item attributes, can be filtered by item index or classname
		// ======================================================================

		ItemAttributes = function(value) {

			MissionAttributes.SpawnHookTable.ItemAttributes <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				if (typeof value != "table") {
					PopExtMain.Error.RaiseValueError("ItemAttributes", value, "Value must be table")
					success = false
					return
				}

				function ApplyAttributes(item, attr)
				{

					local wep = PopExtUtil.HasItemInLoadout(player, item)
					if (wep == null) return

					foreach (attrib, value in attr)
					{
						PopExtUtil.SetPlayerAttributes(player, attrib, value, wep)
					}
				}

				foreach(k, v in value)
				{
					if (typeof k == "string" && k.find(","))
					{
						local idarray = split(k, ",")

						if (idarray.len() > 1)
							idarray.apply(function (val) {return val.tofloat()})
						k = idarray
					}
					if (typeof k == "array")
						foreach (item in k)
							ApplyAttributes(item, v)
					else
						ApplyAttributes(k, v)
				}

			}

		}

		// ============================================================
		// TODO: once we have our own giveweapon functions, finish this
		// ============================================================

		LoadoutControl = function(value) {

			MissionAttributes.SpawnHookTable.LoadoutControl <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return

				player.ValidateScriptScope()
				local scope = player.GetScriptScope()


				function LoadoutControl(item, replacement)
				{
					local wep = PopExtUtil.HasItemInLoadout(player, item)
					if (wep == null) return

					if (GetPropEntity(wep, "m_hExtraWearable") != null)
					{
						GetPropEntity(wep, "m_hExtraWearableViewModel").Kill()
						GetPropEntity(wep, "m_hExtraWearable").Kill()
					}

					wep.Kill()

					if (replacement == null) return

					try
						PopExtUtil.GiveWeapon(player, PopExtItems[replacement].item_class, PopExtItems[replacement].id)
					catch(_)
						if (typeof replacement == "table")
							foreach (classname, itemid in replacement)
								PopExtUtil.GiveWeapon(player, classname, itemid)
						else
							PopExtMain.Error.RaiseValueError("LoadoutControl", value, "Item replacement must be a table")
				}

				foreach (item, replacement in value)
				{
					if (typeof item == "string" && item.find(","))
					{
						local idarray = split(item, ",")

						if (idarray.len() > 1)
							idarray.apply(function (val) {return val.tointeger()})
						item = idarray
					}
					if (typeof item == "array")
						foreach (i in item)
							LoadoutControl(i, replacement)
					else
						LoadoutControl(item, replacement)
				}

				EntFireByHandle(player, "RunScriptCode", "PopExtUtil.SwitchToFirstValidWeapon(self)", SINGLE_TICK, null, null)

				//old mince code, needlessly complicated
				// function HasVal(arr, val) foreach (v in arr) if (v == val) return true

				// function IsInMultiList(arr, val) {
				// 	if (arr.len() <= 0) return false

				// 	local in_list = false
				// 	foreach (a in arr) {
				// 		if (HasVal(a, val)) {
				// 			in_list = true
				// 			break
				// 		}
				// 	}
				// 	return in_list
				// }

				// for (local i = 0; i < SLOT_COUNT; ++i) {
				// 	local wep = GetPropEntityArray(player, "m_hMyWeapons", i)
				// 	if (wep == null) continue

				// 	local tfclass = PopExtUtil.Classes[player.GetPlayerClass()]

				// 	local slot  = PopExtUtil.Slots[i]
				// 	local index = PopExtUtil.GetItemIndex(wep)
				// 	local cls	= wep.GetClassname()

				// 	local whitelists = []
				// 	local tables     = []

				// 	tables.insert(0, value)
				// 	if ("Whitelist" in value) whitelists.insert(0, value.Whitelist)

				// 	if (tfclass in value) {
				// 		tables.insert(0, value[tfclass])
				// 		if ("Whitelist" in value[tfclass])
				// 			whitelists.insert(0, value[tfclass].Whitelist)
				// 	}

				// 	if (tfclass in value && slot in value[tfclass]) {
				// 		tables.insert(0, value[tfclass][slot])
				// 		if ("Whitelist" in value[tfclass][slot])
				// 			whitelists.insert(0, value[tfclass][slot].Whitelist)
				// 	}


				// 	if (whitelists.len() > 0) {
				// 		local in_whitelist = IsInMultiList(whitelists, index) || IsInMultiList(whitelists, cls)

				// 		if (!in_whitelist) {
				// 			wep.Kill()
				// 			continue
				// 		}
				// 	}

				// 	foreach (table in tables) {
				// 		local identifiers = [index, cls]
				// 		local full_break  = false

				// 		foreach (id in identifiers) {
				// 			if (id in table) {
				// 				local value = table[id]

				// 				if (value == null) {
				// 					wep.Kill()
				// 					full_break = true
				// 					break
				// 				}
				// 				else if (value == "") {
				// 					printl("GIVE STOCK ITEM, check with IsInMultiList")
				// 				}
				// 				else if (typeof value == "string" && value.len() > 0) {
				// 					printl("INVALID VALUE "+value+ "FOR k: "+id)
				// 					continue
				// 				}
				// 				else {
				// 					try {
				// 						local value = value.tointeger()
				// 						printl("REPLACE ITEM WITH ITEMINDEX "+value)
				// 					}
				// 					catch (e) {}
				// 				}
				// 			}
				// 		}

				// 		if (full_break) break
				// 	}
				// }
			}
		}

		// DisableSound = function(value) {

		// 	if (typeof value != "array") PopExtMain.Error.RaiseValueError("DisableSound", value, "value must be an array")

		// 	MissionAttributes.ThinkTable.DisableSounds <- function() {

		// 		foreach (sound in value)
		// 		{

		// 			foreach (player in PopExtUtil.HumanArray)
		// 			{
		// 				StopSoundOn(sound, player)
		// 				player.StopSound(sound)
		// 			}

		// 			StopSoundOn(sound, PopExtUtil.Worldspawn)
		// 			PopExtUtil.Worldspawn.StopSound(sound)
		// 		}
		// 	}
		// break

		// =================================================================================
		// hardcoded to only be able to replace specific sounds
		// spamming stopsound in a think function is very laggy, gotta be smarter than that
		// see `replace weapon fire sound` and more in customattributes.nut for wep sounds
		// see the tank sound overrides in hooks.nut for disabling tank explosions
		// =================================================================================

		SoundOverrides = function(value) {

			if (typeof value != "table") PopExtMain.Error.RaiseValueError("SoundOverrides", value, "value must be a table")

			local DeathSounds = {

				"MVM.GiantCommonExplodes": null
				"MVM.SentryBusterExplode": null
				"MVM.PlayerDied": null
			}

			local TankSounds = {

				"MVM.TankStart" : null
				// "MVM.TankEnd" : null
				"MVM.TankPing" : null
				"MVM.TankEngineLoop" : null
				// "MVM.TankSmash" : null
				"MVM.TankDeploy" : null
				"MVM.TankExplodes" : null
			}
			local names = []

			// local BroadcastAudioSounds = {

			// 	"Game.YourTeamWon": null
			// 	"MVM.Warning": null
			// 	"music.mvm_end_last_wave": null
			// 	"music.mvm_end_tank_wave": null
			// 	"Announcer.MVM_Final_Wave_End": null
			// 	"Announcer.MVM_Get_To_Upgrade": null
			// 	"Announcer.MVM_Robots_Planted": null
			// 	"Announcer.MVM_Final_Wave_End": null
			// 	"Announcer.MVM_Tank_Alert_Spawn": null
			// 	"Announcer.MVM_Tank_Alert_Another": null
			// 	"Announcer.MVM_An_Engineer_Bot_Is_Dead": null
			// 	"Announcer.MVM_An_Engineer_Bot_Is_Dead_But_Not_Teleporter": null
			// }

			//teamplay_broadcast_audio overrides
			foreach (sound, override in value)
			{
				PrecacheSound(sound)
				PrecacheScriptSound(sound)

				if (override != null)
				{
					PrecacheSound(override)
					PrecacheScriptSound(override)
				}

				if (sound in DeathSounds)
				{
					DeathSounds[sound] <- []
					if (override != null) DeathSounds[sound].append(override)
				}
				// sound.split(sound, "k")[1]
				if (sound in TankSounds)
				{
					TankSounds[sound] <- []
					if (override != null) TankSounds[sound].append(override)
				}

				{
					MissionAttributes.ThinkTable.SetTankSounds <- function()
					{
						for (local tank; tank = FindByClassname(tank, "tank_boss");)
						{
							local scope = tank.GetScriptScope()

							if (!("popProperty" in scope)) scope.popProperty <- {}
							if (!("SoundOverrides" in scope)) scope.popProperty.SoundOverrides <- {}
							foreach (tanksound, tankoverride in TankSounds) if (!(split(tanksound, "k")[1] in scope.popProperty.SoundOverrides)) scope.popProperty.SoundOverrides[split(tanksound, "k")[1]] <- tankoverride
							if ("created" in scope) delete scope.created
						}
					}

				}

				MissionAttributes.SoundsToReplace[sound] <- override
			}

			//sounds played on death (giant/buster explosions)
			MissionAttributes.DeathHookTable.SoundOverrides <- function(params) {

				local victim = GetPlayerFromUserID(params.userid)

				foreach (sound, override in DeathSounds)
				{
					if (override)
					{
						// StopSoundOn(sound, victim)
						MissionAttributes.EmitSoundFunc <- function() { if (override && override.len()) EmitSoundEx({sound_name = override[0], entity = victim}) }
						EntFireByHandle(victim, "RunScriptCode", format("StopSoundOn(`%s`, self)", sound), -1, null, null)
						EntFireByHandle(victim, "RunScriptCode", "MissionAttributes.EmitSoundFunc()", -1, null, null)
					}
				}
			}

			MissionAttributes.TakeDamageTablePost.SoundOverrides <- function(params) {

			}

			//catch-all for disabling non teamplay_broadcast_audio sfx
			//nukes perf, don't do this.

			// MissionAttributes.ThinkTable.DisableSounds <- function() {

			// 	foreach (sound, override in value)
			// 	{
			// 		if (override == null && !(sound in DeathSounds) && !(sound in BroadcastAudioSounds))
			// 		{
			// 			foreach (player in PopExtUtil.PlayerArray)
			// 			{
			// 				StopSoundOn(sound, player)
			// 				player.StopSound(sound)
			// 			}

			// 			StopSoundOn(sound, PopExtUtil.Worldspawn)
			// 			PopExtUtil.Worldspawn.StopSound(sound)
			// 		}
			// 	}
			// }

		}

		NoThrillerTaunt = function(value) {

			MissionAttributes.SpawnHookTable.NoThrillerTaunt <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				player.ValidateScriptScope()

				player.GetScriptScope().PlayerThinkTable.NoThrillerTaunt <- function() {
					if (self.IsTaunting())
					{
						for (local scene; scene = FindByClassname(scene, "instanced_scripted_scene");)
						{
							local owner = GetPropEntity(scene, "m_hOwner");
							if (owner == self)
							{
								local name = GetPropString(scene, "m_szInstanceFilename");
								local thriller_name = self.GetPlayerClass() == TF_CLASS_MEDIC ? "taunt07" : "taunt06";
								if (name.find(thriller_name) != null)
								{
									scene.Kill();
									self.RemoveCond(TF_COND_TAUNTING);
									self.Taunt(TAUNT_BASE_WEAPON, 0);
									break;
								}
							}
						}
					}
				}
			}
		}
		// =====================================
		// uses bitflags to enable random crits:
		// 1 - Blue humans
		// 2 - Blue robots
		// 4 - Red  robots
		// =====================================

		EnableRandomCrits = function(value) {

			if (value == 0.0) return

			local user_chance = (args.len() > 2) ? args[2] : null

			// Simplified rare high moments
			local base_ranged_crit_chance = 0.0005
			local max_ranged_crit_chance  = 0.0020
			local base_melee_crit_chance  = 0.15
			local max_melee_crit_chance   = 0.60
			// 4 kills to reach max chance

			local timed_crit_weapons = {
				"tf_weapon_handgun_scout_secondary" : null,
				"tf_weapon_pistol_scout" : null,
				"tf_weapon_flamethrower" : null,
				"tf_weapon_minigun" : null,
				"tf_weapon_pistol" : null,
				"tf_weapon_syringegun_medic" : null,
				"tf_weapon_smg" : null,
				"tf_weapon_charged_smg" : null,
			}

			local no_crit_weapons = {
				"tf_weapon_laser_pointer" : null,
				"tf_weapon_medigun"	: null,
				"tf_weapon_sniperrifle" : null,
			}

			MissionAttributes.ThinkTable.EnableRandomCritsThink <- function() {

				if (!PopExtUtil.IsWaveStarted) return -1

				foreach (player in PopExtUtil.PlayerArray)
				{
					if (!( (value & 1 && player.GetTeam() == TF_TEAM_PVE_INVADERS && !player.IsBotOfType(TF_BOT_TYPE)) ||
						(value & 2 && player.GetTeam() == TF_TEAM_PVE_INVADERS && player.IsBotOfType(TF_BOT_TYPE))  ||
						(value & 4 && player.GetTeam() == TF_TEAM_PVE_DEFENDERS && player.IsBotOfType(TF_BOT_TYPE)) ))
						continue

					player.ValidateScriptScope()
					local scope = player.GetScriptScope()
					if (!("crit_weapon" in scope))
						scope.crit_weapon <- null

					if (!("ranged_crit_chance" in scope) || !("melee_crit_chance" in scope))
					{
						scope.ranged_crit_chance <- base_ranged_crit_chance
						scope.melee_crit_chance <- base_melee_crit_chance
					}

					if (!PopExtUtil.IsAlive(player) || player.GetTeam() == TEAM_SPECTATOR) continue

					local wep       = player.GetActiveWeapon()
					local index     = PopExtUtil.GetItemIndex(wep)
					local classname = wep.GetClassname()

					// Lose the crits if we switch weapons
					if (scope.crit_weapon != null && scope.crit_weapon != wep)
						player.RemoveCond(TF_COND_CRITBOOSTED_CTF_CAPTURE)

					// Wait for bot to use its crits
					if (scope.crit_weapon != null && player.InCond(TF_COND_CRITBOOSTED_CTF_CAPTURE)) continue

					// We handle melee weapons elsewhere in OnTakeDamage
					if (wep == null || wep.IsMeleeWeapon()) continue
					// Certain weapon types never receive random crits
					if (classname in no_crit_weapons || wep.GetSlot() > 2) continue
					// Ignore weapons with certain attributes
					// if (wep.GetAttribute("crit mod disabled", 1) == 0 || wep.GetAttribute("crit mod disabled hidden", 1) == 0) continue

					local crit_chance_override = (user_chance > 0) ? user_chance : null
					local chance_to_use        = (crit_chance_override != null) ? crit_chance_override : scope.ranged_crit_chance

					// Roll for random crits
					if (RandomFloat(0, 1) < chance_to_use)
					{
						player.AddCond(TF_COND_CRITBOOSTED_CTF_CAPTURE)
						scope.crit_weapon <- wep

						// Detect weapon fire to remove our crits
						wep.ValidateScriptScope()
						wep.GetScriptScope().last_fire_time <- Time()
						wep.GetScriptScope().Think <- function()
						{
							local fire_time = GetPropFloat(self, "m_flLastFireTime");
							if (fire_time > last_fire_time)
							{
								local owner = self.GetOwner()
								owner.RemoveCond(TF_COND_CRITBOOSTED_CTF_CAPTURE)

								owner.ValidateScriptScope()
								local scope = owner.GetScriptScope()

								// Continuous fire weapons get 2 seconds of crits once they fire
								if (classname in timed_crit_weapons)
								{
									owner.AddCondEx(TF_COND_CRITBOOSTED_CTF_CAPTURE, 2, null)
									EntFireByHandle(owner, "RunScriptCode", format("crit_weapon <- null; ranged_crit_chance <- %f", base_ranged_crit_chance), 2, null, null)
								}
								else
								{
									scope.crit_weapon <- null
									scope.ranged_crit_chance <- base_ranged_crit_chance
								}

								SetPropString(self, "m_iszScriptThinkFunction", "")
							}
							return -1
						}
						AddThinkToEnt(wep, "Think")
					}
				}
			}

			MissionAttributes.DeathHookTable.EnableRandomCritsKill <- function(params) {

				local attacker = GetPlayerFromUserID(params.attacker)
				if (attacker == null || !attacker.IsBotOfType(TF_BOT_TYPE)) return

				attacker.ValidateScriptScope()
				local scope = attacker.GetScriptScope()
				if (!("ranged_crit_chance" in scope) || !("melee_crit_chance" in scope)) return

				if (scope.ranged_crit_chance + base_ranged_crit_chance > max_ranged_crit_chance)
					scope.ranged_crit_chance <- max_ranged_crit_chance
				else
					scope.ranged_crit_chance <- scope.ranged_crit_chance + base_ranged_crit_chance

				if (scope.melee_crit_chance + base_melee_crit_chance > max_melee_crit_chance)
					scope.melee_crit_chance <- max_melee_crit_chance
				else
					scope.melee_crit_chance <- scope.melee_crit_chance + base_melee_crit_chance
			}

			MissionAttributes.TakeDamageTable.EnableRandomCritsTakeDamage <- function(params) {
				if (!("inflictor" in params)) return

				local attacker = params.inflictor
				if (attacker == null || !attacker.IsPlayer() || !attacker.IsBotOfType(TF_BOT_TYPE)) return

				attacker.ValidateScriptScope()
				local scope = attacker.GetScriptScope()
				if (!("melee_crit_chance" in scope)) return

				// Already a crit
				if (params.damage_type & DMG_CRITICAL) return

				// Only Melee weapons
				local wep = attacker.GetActiveWeapon()
				if (!wep.IsMeleeWeapon()) return

				// Certain weapon types never receive random crits
				if (attacker.GetPlayerClass() == TF_CLASS_SPY) return
				// Ignore weapons with certain attributes
				// if (wep.GetAttribute("crit mod disabled", 1) == 0 || wep.GetAttribute("crit mod disabled hidden", 1) == 0) return

				// Roll our crit chance
				if (RandomFloat(0, 1) < scope.melee_crit_chance) {
					params.damage_type = params.damage_type | DMG_CRITICAL
					// We delay here to allow death code to run so the reset doesn't get overriden
					EntFireByHandle(attacker, "RunScriptCode", format("melee_crit_chance <- %f", base_melee_crit_chance), SINGLE_TICK, null, null)
				}
			}
		}

		ForceRedMoney = function(value) {
			MissionAttributes.RedMoneyValue = value
		}

		// =======================================
		// 1 = enables basic Reverse MvM behavior
		// 2 = blu players cannot pick up bombs
		// 4 = blu players have infinite ammo
		// 8 = blu spies have infinite cloak
		// 16 = blu players have spawn protection
		// 32 = blu players cannot attack in spawn
		// 64 = remove blu footsteps
		// =======================================

		ReverseMVM = function(value) {

			// Prevent bots on red team from hogging slots so players can always join and get switched to blue
			// TODO: Needs testing
			// also need to reset it
			//MissionAttributes.SetConvar("tf_mvm_defenders_team_size", 999)
			MissionAttributes.DeployBombStart <- function(player) {

				//do this so we can do CancelPending
				local deployrelay = SpawnEntityFromTable("logic_relay" {
					targetname = "__bombdeploy"
					"OnTrigger#1": "bignetRunScriptCodePopExtUtil.EndWaveReverse()2-1"
					"OnTrigger#2": "boss_deploy_relay,Trigger,,2,-1"
				})
				if (GetPropEntity(player, "m_hItem") == null) return

				player.DisableDraw()

				for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
					child.DisableDraw()

				player.AddCustomAttribute("move speed bonus", 0.00001, -1)
				player.AddCustomAttribute("no_jump", 1, -1)

				local dummy = CreateByClassname("prop_dynamic")

				PopExtUtil.SetTargetname(dummy, format("__deployanim%d", player.entindex()))
				dummy.SetOrigin(player.GetOrigin())
				dummy.SetAbsAngles(player.GetAbsAngles())
				dummy.SetModel(player.GetModelName())
				dummy.SetSkin(player.GetSkin())

				DispatchSpawn(dummy)
				dummy.ResetSequence(dummy.LookupSequence("primary_deploybomb"))

				player.IsMiniBoss() ? EmitSoundEx({sound_name = "MVM.DeployBombGiant", entity = player, flags = SND_CHANGE_VOL, volume = 0.5}) : EmitSoundEx({sound_name = "MVM.DeployBombSmall", entity = player, flags = SND_CHANGE_VOL, volume = 0.5})

				EntFireByHandle(player, "SetForcedTauntCam", "1", -1, null, null)
				EntFireByHandle(player, "SetHudVisibility", "0", -1, null, null)
				EntFire("__bombdeploy", "Trigger")
			}

			MissionAttributes.DeployBombStop <- function(player) {

				if (GetPropEntity(player, "m_hItem") == null) return

				player.EnableDraw()

				for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
					child.EnableDraw()

				player.RemoveCustomAttribute("move speed bonus")
				player.RemoveCustomAttribute("no_jump")

				FindByName(null, format("__deployanim%d", player.entindex())).Kill()

				player.IsMiniBoss() ? StopSoundOn("MVM.DeployBombGiant", player) : StopSoundOn("MVM.DeployBombSmall", player)

				EntFireByHandle(player, "SetForcedTauntCam", "0", -1, null, null)
				EntFireByHandle(player, "SetHudVisibility", "1", -1, null, null)
				EntFire("__bombdeploy", "CancelPending")
				EntFire("__bombdeploy", "Kill")
			}

			MissionAttributes.ThinkTable.ReverseMVMThink <- function() {
				// Enforce max team size
				local player_count  = 0
				local max_team_size = 6
				foreach (player in PopExtUtil.HumanArray) {

					if (player_count + 1 > max_team_size && player.GetTeam() != TEAM_SPECTATOR && !player.IsBotOfType(TF_BOT_TYPE)) {
						player.ForceChangeTeam(TEAM_SPECTATOR, false)
						continue
					}
					player_count++
				}

				// Readying up starts the round
				if (!PopExtUtil.IsWaveStarted) {
					local ready = PopExtUtil.GetPlayerReadyCount()
					if (ready > 0 && ready >= PopExtUtil.HumanArray.len() && !("WaveStartCountdown" in MissionAttributes) && GetPropFloat(PopExtUtil.GameRules, "m_flRestartRoundTime") >= Time() + 12.0)
							SetPropFloat(PopExtUtil.GameRules, "m_flRestartRoundTime", Time() + 10.0)
				}
			}

			MissionAttributes.SpawnHookTable.ReverseMVMSpawn <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return
				player.ValidateScriptScope()
				local scope = player.GetScriptScope()

				if ("ReverseMVMCurrencyThink" in scope.PlayerThinkTable) delete scope.PlayerThinkTable.ReverseMVMCurrencyThink
				if ("ReverseMVMPackThink" in scope.PlayerThinkTable)  delete scope.PlayerThinkTable.ReverseMVMPackThink
				if ("ReverseMVMLaserThink" in scope.PlayerThinkTable)  delete scope.PlayerThinkTable.ReverseMVMLaserThink
				if ("ReverseMVMDrainAmmoThink" in scope.PlayerThinkTable)  delete scope.PlayerThinkTable.ReverseMVMDrainAmmoThink

				// Switch to blue team
				if (player.GetTeam() != TF_TEAM_PVE_INVADERS) {
					EntFireByHandle(player, "RunScriptCode", "PopExtUtil.ChangePlayerTeamMvM(self, TF_TEAM_PVE_INVADERS)", SINGLE_TICK, null, null)
					EntFireByHandle(player, "RunScriptCode", "self.ForceRespawn()", SINGLE_TICK, null, null)
				}

				// Kill any phantom lasers from respawning as engie (yes this is real)
				EntFireByHandle(player, "RunScriptCode", @"
					for (local ent; ent = FindByClassname(ent, `env_laserdot`);)
						if (ent.GetOwner() == self)
							ent.Destroy()
				", 0.5, null, null)

				// Temporary solution for engie wrangler laser
				scope.handled_laser   <- false
				scope.PlayerThinkTable.ReverseMVMLaserThink <- function() {

					if (!("laser_spawntime" in scope)) scope.laser_spawntime <- -1

					if (!PopExtUtil.IsAlive(player) || player.GetTeam() == TEAM_SPECTATOR) return

					local wep = self.GetActiveWeapon()

					if (wep && wep.GetClassname() == "tf_weapon_laser_pointer") {
						if (laser_spawntime == -1)
							laser_spawntime = Time() + 0.55
					}
					else {
						if (laser_spawntime > -1) {
							laser_spawntime = -1
							handled_laser   = false
						}
						return
					}

					if (handled_laser) return
					if (Time() < laser_spawntime) return

					local laser = null
					for (local ent; ent = FindByClassname(ent, "env_laserdot");) {
						if (ent.GetOwner() == self) {
							laser = ent
							break
						}
					}

					for (local ent; ent = FindByClassname(ent, "obj_sentrygun");) {
						local builder = GetPropEntity(ent, "m_hBuilder")
						if (builder != self) continue

						if (!GetPropBool(ent, "m_bPlayerControlled") || laser == null) continue

						originalposition <- self.GetOrigin()
						originalvelocity <- self.GetAbsVelocity()
						originalmovetype <- self.GetMoveType()
						self.SetAbsOrigin(ent.GetOrigin() + Vector(0, 0, -32))
						self.SetAbsVelocity(Vector())
						self.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT)
						EntFireByHandle(laser, "RunScriptCode", "self.SetTeam(TF_TEAM_PVE_DEFENDERS)", SINGLE_TICK, null, null)
						EntFireByHandle(self, "RunScriptCode", "self.SetAbsOrigin(originalposition); self.SetAbsVelocity(originalvelocity); self.SetMoveType(originalmovetype, MOVECOLLIDE_DEFAULT)", SINGLE_TICK, null, null)

						handled_laser = true
						return
					}

					if (!handled_laser && laser != null)
						laser.Destroy()
				}

				// Allow money collection
				local collectionradius = 0
				scope.PlayerThinkTable.ReverseMVMCurrencyThink <- function() {

					// Save money netprops because we fuck it in the loop below
					// local money              = GetPropInt(PopExtUtil.ObjectiveResource, "m_nMvMWorldMoney")
					// local prev_wave_money    = GetPropInt(PopExtUtil.MvMStatsEnt, "m_previousWaveStats.nCreditsDropped")
					// local current_wave_money = GetPropInt(PopExtUtil.MvMStatsEnt, "m_currentWaveStats.nCreditsDropped")

					// Find currency near us
					local origin = self.GetOrigin()
					self.GetPlayerClass() != TF_CLASS_SCOUT ? collectionradius = 72 : collectionradius = 288

					for ( local moneypile; moneypile = FindByClassnameWithin(moneypile, "item_currencypack_*", origin, collectionradius); )
					{
						// NEW COLLECTION METHOD (royal)
						local moneyOwner = GetPropEntity(moneypile, "m_hOwnerEntity")

						local objectiveResource = PopExtUtil.ObjectiveResource
						local moneyBefore = GetPropInt(PopExtUtil.ObjectiveResource, "m_nMvMWorldMoney")

						moneypile.SetAbsOrigin(Vector(-1000000, -1000000, -1000000))
						moneypile.Kill()

						local moneyAfter = GetPropInt(PopExtUtil.ObjectiveResource, "m_nMvMWorldMoney")

						local moneyValue = moneyBefore - moneyAfter

						local CREDITS_ACQUIRED_PROP = "m_currentWaveStats.nCreditsAcquired"
						local mvmStatsEnt = PopExtUtil.MvMStatsEnt
						SetPropInt(mvmStatsEnt, CREDITS_ACQUIRED_PROP, GetPropInt(mvmStatsEnt, CREDITS_ACQUIRED_PROP) + moneyValue)

						for (local i = 1, player; i <= MAX_CLIENTS; i++)
							if (player = PlayerInstanceFromIndex(i), player && !IsPlayerABot(player))
								player.AddCurrency(moneyValue)

						EmitSoundOn("MVM.MoneyPickup", player)

						// scout money healing
						if (self.GetPlayerClass() == TF_CLASS_SCOUT)
						{
							local curHealth = self.GetHealth()
							local maxHealth = self.GetMaxHealth()
							local healthAddition = curHealth < maxHealth ? 50 : 25

							// If we cross the border into insanity, scale the reward
							local healthCap = maxHealth * 4
							if ( curHealth > healthCap )
							{
								healthAddition = PopExtUtil.RemapValClamped( curHealth, healthCap, (healthCap * 1.5), 20, 5 )
							}

							self.SetHealth(curHealth + healthAddition)
						}

						// OLD COLLECTION METHOD
						// // Move the money to the origin and respawn it to allow us to collect it after it touches the ground
						// for (local hurt; hurt = FindByClassname(hurt, "trigger_hurt");)
						// {
						// 	// moneypile.ValidateScriptScope()
						// 	// moneypile.GetScriptScope().CollectThink <- function() {
						// 		// printl(self.GetVelocity().Length())
						// 		if (moneypile.GetVelocity().Length() == 0)
						// 		{
						// 			// moneypile.SetOrigin(Vector(0, 0, FLT_MIN))

						// 			moneypile.SetOrigin(hurt.GetOrigin())
						// 			DispatchSpawn(moneypile)
						// 			EmitSoundOn("MVM.MoneyPickup", player)
						// 		}
						// 	// }
						// 	AddThinkToEnt(moneypile, "CollectThink")
						// }
						// 	// EntFireByHandle(moneypile, "RunScriptCode", format(@"
						// 	// 		printl(self.GetVelocity())
						// 	// 		for (local hurt; hurt = FindByClassname(hurt, `trigger_hurt`);)
						// 	// 		{
						// 	// 			EmitSoundOn(`MVM.MoneyPickup`, self)
						// 	// 			self.SetOrigin(hurt.GetOrigin())
						// 	// 			DispatchSpawn(self)
						// 	// 		}
						// 	// 		// The money counters are fucked from what we did in the above loop, fix it here
						// 	// 		SetPropInt(PopExtUtil.ObjectiveResource, `m_nMvMWorldMoney`, %d)
						// 	// 		SetPropInt(PopExtUtil.MvMStatsEnt, `m_previousWaveStats.nCreditsDropped`, %d)
						// 	// 		SetPropInt(PopExtUtil.MvMStatsEnt, `m_currentWaveStats.nCreditsDropped`, %d)
						// 	// ", money, prev_wave_money, current_wave_money), -1, null, null)
					}


					// The money counters are fucked from what we did in the above loop, fix it here
					// SetPropInt(PopExtUtil.ObjectiveResource, "m_nMvMWorldMoney", money)
					// SetPropInt(PopExtUtil.MvMStatsEnt, "m_previousWaveStats.nCreditsDropped", prev_wave_money)
					// SetPropInt(PopExtUtil.MvMStatsEnt, "m_currentWaveStats.nCreditsDropped", current_wave_money)
				}

				// Allow pack collection
				scope.PlayerThinkTable.ReverseMVMPackThink <- function() {
					local origin = self.GetOrigin()
					for ( local ent; ent = FindByClassnameWithin(ent, "item_*", origin, 40); ) {
						if (ent.IsEFlagSet(EFL_USER)) continue
						if (GetPropInt(ent, "m_fEffects") & EF_NODRAW) continue

						local classname = ent.GetClassname()
						if (startswith(classname, "item_currencypack_")) continue

						local refill    = false
						local is_health = false

						local multiplier = 0.0
						if (endswith(classname, "_small"))       multiplier = 0.2
						else if (endswith(classname, "_medium")) multiplier = 0.5
						else if (endswith(classname, "_full"))   multiplier = 1.0

						if (startswith(classname, "item_ammopack_")) {
							local metal    = GetPropIntArray(self, "m_iAmmo", TF_AMMO_METAL)
							local maxmetal = 200

							if (metal < maxmetal) {
								local maxmult  = PopExtUtil.Round(maxmetal * multiplier)
								local setvalue = (metal + maxmult > maxmetal) ? maxmetal : metal + maxmult

								SetPropIntArray(self, "m_iAmmo", setvalue, TF_AMMO_METAL)
								refill = true
							}

							for (local i = 0; i < SLOT_MELEE; ++i) {
								local wep     = PopExtUtil.GetItemInSlot(self, i)
								local ammo    = GetPropIntArray(self, "m_iAmmo", i+1)
								local maxammo = PopExtUtil.GetWeaponMaxAmmo(self, wep)

								if (ammo >= maxammo)
									continue
								else {
									local maxmult  = PopExtUtil.Round(maxammo * multiplier)
									local setvalue = (ammo + maxmult > maxammo) ? maxammo : ammo + maxmult

									SetPropIntArray(self, "m_iAmmo", setvalue, i+1)
									refill = true
								}
							}

						}
						else if (startswith(classname, "item_healthkit_")) {
							is_health = true

							local hp    = self.GetHealth()
							local maxhp = self.GetMaxHealth()
							if (hp >= maxhp) continue

							refill = true

							local maxmult  = PopExtUtil.Round(maxhp * multiplier)
							local setvalue = (hp + maxmult > maxhp) ? maxhp : hp + maxmult
							self.ExtinguishPlayerBurning()

							SendGlobalGameEvent("player_healed", {
								patient = PopExtUtil.GetPlayerUserID(self)
								healer  = 0
								amount  = setvalue - hp
							})
							SendGlobalGameEvent("player_healonhit", {
								entindex         = self.entindex()
								weapon_def_index = 65535
								amount           = setvalue - hp
							})

							self.SetHealth(setvalue)
						}

						if (refill) {
							if (is_health)
								EmitSoundOnClient("HealthKit.Touch", self)
							else
								EmitSoundOnClient("AmmoPack.Touch", self)

							ent.AddEFlags(EFL_USER)
							EntFireByHandle(ent, "Disable", "", -1, null, null)

							EntFireByHandle(ent, "Enable", "", 10, null, null)
							EntFireByHandle(ent, "RunScriptCode", "self.RemoveEFlags(EFL_USER)", 10, null, null)
						}
					}
				}

				// Drain player ammo on weapon usage
				scope.PlayerThinkTable.ReverseMVMDrainAmmoThink <- function() {

					if (value & 4) return
					local buttons = GetPropInt(self, "m_nButtons");

					local wep = player.GetActiveWeapon()
					if (wep == null || wep.IsMeleeWeapon()) return

					wep.ValidateScriptScope()
					local scope = wep.GetScriptScope()
					if (!("nextattack" in scope)) {
						scope.nextattack <- -1
						scope.lastattack <- -1
					}


					local classname = wep.GetClassname()
					local itemid    = PopExtUtil.GetItemIndex(wep)
					local sequence  = wep.GetSequence()

					// These weapons have clips but either function fine or don't need to be handled
					if (classname == "tf_weapon_particle_cannon"  || classname == "tf_weapon_raygun"     ||
						classname == "tf_weapon_flaregun_revenge" || classname == "tf_weapon_drg_pomson" ||
						classname == "tf_weapon_medigun") return

					local clip = wep.Clip1()

					if (clip > -1) {
						if (!("lastclip" in scope))
							scope.lastclip <- clip

						// We reloaded
						if (clip > scope.lastclip) {
							local difference = clip - scope.lastclip
							if (self.GetPlayerClass() == TF_CLASS_SPY && classname == "tf_weapon_revolver") {
								local maxammo = GetPropIntArray(self, "m_iAmmo", SLOT_SECONDARY + 1)
								SetPropIntArray(self, "m_iAmmo", maxammo - difference, SLOT_SECONDARY + 1)
							}
							else {
								local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)
								SetPropIntArray(self, "m_iAmmo", maxammo - difference, wep.GetSlot() + 1)
							}
						}

						scope.lastclip <- clip
					}
					else {
						if (classname == "tf_weapon_rocketlauncher_fireball") {
							local recharge = GetPropFloat(player, "m_Shared.m_flItemChargeMeter")
							if (recharge == 0) {
								local cost = (sequence == 13) ? 2 : 1
								local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)

								if (maxammo - cost > -1)
									SetPropIntArray(self, "m_iAmmo", maxammo - cost, wep.GetSlot() + 1)
							}
						}
						else if (classname == "tf_weapon_flamethrower") {
							if (sequence == 12) return // Weapon deploy
							if (Time() < scope.nextattack) return

							local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)

							// The airblast sequence lasts 0.25s too long so we check against it here
							if (buttons & IN_ATTACK && sequence != 13) {
								if (maxammo - 1 > -1) {
									SetPropIntArray(self, "m_iAmmo", maxammo - 1, wep.GetSlot() + 1)
									scope.nextattack <- Time() + 0.105
								}
							}
							else if (buttons & IN_ATTACK2) {
								local cost = 20
								if (itemid == ID_BACKBURNER || itemid == ID_FESTIVE_BACKBURNER_2014) // Backburner
									cost = 50
								else if (itemid == ID_DEGREASER) // Degreaser
									cost = 25

								if (maxammo - cost > -1) {
									SetPropIntArray(self, "m_iAmmo", maxammo - cost, wep.GetSlot() + 1)
									scope.nextattack <- Time() + 0.75
								}
							}
						}
						else if (classname == "tf_weapon_flaregun") {
							local nextattack = GetPropFloat(wep, "m_flNextPrimaryAttack")
							if (Time() < nextattack) return

							local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)
							if (buttons & IN_ATTACK) {
								if (maxammo - 1 > -1)
									SetPropIntArray(self, "m_iAmmo", maxammo - 1, wep.GetSlot() + 1)
							}
						}
						else if (classname == "tf_weapon_minigun") {
							local nextattack = GetPropFloat(wep, "m_flNextPrimaryAttack")
							if (Time() < nextattack) return

							local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)
							if (sequence == 21) {
								if (maxammo - 1 > -1)
									SetPropIntArray(self, "m_iAmmo", maxammo - 1, wep.GetSlot() + 1)
							}
							else if (sequence == 25) {
								if (Time() < scope.nextattack) return
								if (itemid != ID_HUO_LONG_HEATMAKER && itemid != ID_GENUINE_HUO_LONG_HEATMAKER) return

								if (maxammo - 1 > -1) {
									SetPropIntArray(self, "m_iAmmo", maxammo - 1, wep.GetSlot() + 1)
									scope.nextattack <- Time() + 0.25
								}
							}
						}
						else if (classname == "tf_weapon_mechanical_arm") {
							// Reset hack
							SetPropIntArray(self, "m_iAmmo", 0, TF_AMMO_GRENADES1)
							SetPropInt(wep, "m_iPrimaryAmmoType", TF_AMMO_METAL)

							local nextattack1 = GetPropFloat(wep, "m_flNextPrimaryAttack")
							local nextattack2 = GetPropFloat(wep, "m_flNextSecondaryAttack")

							local maxmetal = GetPropIntArray(self, "m_iAmmo", TF_AMMO_METAL)

							if (buttons & IN_ATTACK) {
								if (Time() < nextattack1) return
								if (maxmetal - 5 > -1) {
									SetPropIntArray(self, "m_iAmmo", maxmetal - 5, TF_AMMO_METAL)
									// This prevents an exploit where you M1 and M2 in rapid succession to evade the 65 orb cost
									SetPropFloat(wep, "m_flNextSecondaryAttack", Time() + 0.25)
								}
							}
							else if (buttons & IN_ATTACK2) {
								if (Time() < nextattack2) return

								if (maxmetal - 65 > -1) {
									// Hack to get around the game blocking SecondaryAttack below 65 metal
									SetPropIntArray(self, "m_iAmmo", INT_MAX, TF_AMMO_GRENADES1)
									SetPropInt(wep, "m_iPrimaryAmmoType", TF_AMMO_GRENADES1)

									SetPropIntArray(self, "m_iAmmo", maxmetal - 65, TF_AMMO_METAL)
								}
							}
						}
						else if (itemid == ID_WIDOWMAKER) { // Widowmaker
							local nextattack = GetPropFloat(wep, "m_flNextPrimaryAttack")
							if (Time() < nextattack) return

							local maxmetal = GetPropIntArray(self, "m_iAmmo", TF_AMMO_METAL)

							if (buttons & IN_ATTACK) {
								if (maxmetal - 30 > -1)
									SetPropIntArray(self, "m_iAmmo", maxmetal - 30, TF_AMMO_METAL)
							}
						}
						else if (classname == "tf_weapon_sniperrifle" || itemid == ID_BAZAAR_BARGAIN || itemid == ID_CLASSIC) {
							local lastfire = GetPropFloat(wep, "m_flLastFireTime")
							if (scope.lastattack == lastfire) return

							scope.lastattack <- lastfire
							local maxammo = GetPropIntArray(self, "m_iAmmo", wep.GetSlot() + 1)
							if (scope.lastattack > 0 && scope.lastattack < Time()) {
								if (maxammo - 1 > -1)
									SetPropIntArray(self, "m_iAmmo", maxammo - 1, wep.GetSlot() + 1)
							}
						}
					}
				}
				if (player.GetPlayerClass() == TF_CLASS_ENGINEER)
				{
					scope.BuiltObjectTable.DrainMetal <- function(params) {
						if (value & 4) return
						local player = GetPlayerFromUserID(params.userid)
						local scope = player.GetScriptScope()
						local curmetal = GetPropIntArray(player, "m_iAmmo", TF_AMMO_METAL)
						if (!("buildings" in scope)) scope.buildings <- [-1, array(2), -1]
						// don't drain metal if this buildings entindex exists in the players scope
						if (scope.buildings.find(params.index) != null || scope.buildings[1].find(params.index) != null) return

						// add entindexes to player scope
						if (params.object == OBJ_TELEPORTER)
							if (GetPropInt(EntIndexToHScript(params.index), "m_iTeleportType") == TTYPE_ENTRANCE)
								scope.buildings[1][0] = params.index
							else
								scope.buildings[1][1] = params.index
						else
							scope.buildings[params.object] = params.index

						switch(params.object)
						{
							case OBJ_DISPENSER:
								SetPropIntArray(player, "m_iAmmo", curmetal - 100, TF_AMMO_METAL)
							break

							case OBJ_TELEPORTER:
								if (PopExtUtil.HasItemInLoadout(player, ID_EUREKA_EFFECT))
									SetPropIntArray(player, "m_iAmmo", curmetal - 25, TF_AMMO_METAL)
								else
									SetPropIntArray(player, "m_iAmmo", curmetal - 50, TF_AMMO_METAL)
							break

							case OBJ_SENTRYGUN:
								if (PopExtUtil.HasItemInLoadout(player, ID_GUNSLINGER))
									SetPropIntArray(player, "m_iAmmo", curmetal - 100, TF_AMMO_METAL)
								else
									SetPropIntArray(player, "m_iAmmo", curmetal - 130, TF_AMMO_METAL)
							break
						}
						if (GetPropIntArray(player, "m_iAmmo", TF_AMMO_METAL) < 0) EntFireByHandle(player, "RunScriptCode", "SetPropIntArray(player, `m_iAmmo`, 0, TF_AMMO_METAL)", -1, null, null)
					}

				}

				//bitflags
				//cannot pick up intel
				if (value & 2 && !IsPlayerABot(player))
					player.AddCustomAttribute("cannot pick up intelligence", 1, -1)

				//infinite cloak
				if (value & 8 && player.GetPlayerClass() == TF_CLASS_SPY)
					//setting it to -FLT_MAX makes it display as +inf%
					player.AddCustomAttribute("cloak consume rate decreased", -FLT_MAX, -1)

				//spawnroom behavior.  16 = spawn protection 32 = can't attack
				if (value & 16 || value & 32)
				{
					scope.PlayerThinkTable.InRespawnThink <- function()
					{
						if (!PopExtUtil.IsPointInRespawnRoom(player.EyePosition())) return

						if (value & 16 && !player.InCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED))
							player.AddCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, 2.0, null)

						if (value & 32)
							player.AddCustomAttribute("no_attack", 1, 0.033)
					}
				}

				// disable footsteps
				if (value & 64) {
					// player.AddCond(TF_COND_DISGUISED)
					// scope.PlayerThinkTable.RemoveFootsteps <- function() {
					// 	if (!player.IsMiniBoss()) player.SetIsMiniBoss(true)
					// }

					//stop explosion sound
					MissionAttributes.DeathHookTable.RemoveFootsteps <- function(params) {
						foreach (player in PopExtUtil.HumanArray)
							StopSoundOn("MVM.GiantCommonExplodes", player)
					}
				}
				//disable bomb deploy
				if (!(value & 128)) {

					for (local roundwin; roundwin = FindByClassname(roundwin, "game_round_win");)
						if (roundwin.GetTeam() == TF_TEAM_PVE_INVADERS)
							EntFireByHandle(roundwin, "Kill", "", -1, null, null)

					for (local capturezone; capturezone = FindByClassname(capturezone, "func_capturezone");)
					{
						AddOutput(capturezone, "OnStartTouch", "!activator", "RunScriptCode", "MissionAttributes.DeployBombStart(self)", -1, -1)
						AddOutput(capturezone, "OnEndTouch", "!activator", "RunScriptCode", "MissionAttributes.DeployBombStop(self)", -1, -1)
					}
				}
			}
		}

		// =========================================================
		ClassLimits = function(value) {

			MissionAttributes.ChangeClassTable.ClassLimits <- function(params) {

				local player = GetPlayerFromUserID(params.userid)
				if (player.IsBotOfType(TF_BOT_TYPE)) return
				// Note that player_changeclass fires before a class swap actually occurs.
				// This means that player.GetPlayerClass() can be used to get the previous class,
				//  and that PopExtUtil::PlayerClassCount() will return the current class array.
				local classcount = PopExtUtil.PlayerClassCount()[params["class"]] + 1
				if (params["class"] in value && classcount > value[params["class"]]) {
					PopExtUtil.ForceChangeClass(player, player.GetPlayerClass())
					if (value[params["class"]] == 0)
						PopExtUtil.ShowMessage(format("%s is not allowed on this mission.", PopExtUtil.ClassesCaps[params["class"]]))
					else
						PopExtUtil.ShowMessage(format("%s is limited to %i for this mission.", PopExtUtil.ClassesCaps[params["class"]], value[params["class"]]))
					switch(params["class"]) {
						case TF_CLASS_SCOUT: EmitSoundOn("Scout.No03", player); break
						case TF_CLASS_SOLDIER: EmitSoundOn("Soldier.No01", player); break
						case TF_CLASS_PYRO: EmitSoundOn("Pyro.No01", player); break
						case TF_CLASS_DEMOMAN: EmitSoundOn("Demoman.No03", player); break
						case TF_CLASS_HEAVYWEAPONS: EmitSoundOn("Heavy.No02", player); break
						case TF_CLASS_ENGINEER: EmitSoundOn("Engineer.No03", player); break
						case TF_CLASS_MEDIC: EmitSoundOn("Medic.No03", player); break
						case TF_CLASS_SNIPER: EmitSoundOn("Sniper.No04", player); break
						case TF_CLASS_SPY: EmitSoundOn("Spy.No02", player); break
						case TF_CLASS_CIVILIAN: EmitSoundOn("Scout.No03", player); break
					}
				}
			}

			// Accept string identifiers for classes to limit.
			foreach (k, v in value) {
				if (typeof k != "string") continue
				switch (k.tolower()) {
					case "scout": value[TF_CLASS_SCOUT] <- v; delete value[k]; break
					case "soldier": value[TF_CLASS_SOLDIER] <- v; delete value[k]; break
					case "pyro": value[TF_CLASS_PYRO] <- v; delete value[k]; break
					case "demo": value[TF_CLASS_DEMOMAN] <- v; delete value[k]; break
					case "demoman": value[TF_CLASS_DEMOMAN] <- v; delete value[k]; break
					case "heavy": value[TF_CLASS_HEAVYWEAPONS] <- v; delete value[k]; break
					case "heavyweapons": value[TF_CLASS_HEAVYWEAPONS] <- v; delete value[k]; break
					case "engineer": value[TF_CLASS_ENGINEER] <- v; delete value[k]; break
					case "medic": value[TF_CLASS_MEDIC] <- v; delete value[k]; break
					case "sniper": value[TF_CLASS_SNIPER] <- v; delete value[k]; break
					case "spy": value[TF_CLASS_SPY] <- v; delete value[k]; break
					case "civilian": value[TF_CLASS_CIVILIAN] <- v; delete value[k]; break
				}
			}

			MissionAttributes.ClassLimits <- value
			// Dump overflow players to free classes on wave init.
			EntFireByHandle(PopExtUtil.GameRules, "RunScriptCode", @"
				local initcounts = PopExtUtil.PlayerClassCount()
				local classes = array(TF_CLASS_COUNT_ALL, 0)
				foreach (player in PopExtUtil.HumanArray) {
					local pclass = player.GetPlayerClass()
					++classes[pclass]
					if (pclass in MissionAttributes.ClassLimits && classes[pclass] > MissionAttributes.ClassLimits[pclass]) {
						local nobreak = 1
						foreach (i, targetcount in MissionAttributes.ClassLimits) {
							if (targetcount > initcounts[i]) {
								++initcounts[i]
								PopExtUtil.ForceChangeClass(player, i)
								nobreak = 0
								break
							}
						}
						if (nobreak) {
							PopExtUtil.ForceChangeClass(player, RandomInt(1, 9))
							MissionAttributes.ParseError(`ClassLimits could not find a free class slot.`)
							break
						}
					}
				}", SINGLE_TICK, null, null)

		}

		// =========================================================

		ShowHiddenAttributes = function(value) {
			MissionAttributes.CurAttrs[value] <- true
		}

		// =========================================================
		// Hides the "Respawn in: # seconds" text
		// 0 = Default behaviour (countdown)
		// 1 = Hide completely
		// 2 = Show only 'Prepare to Respawn'
		// =========================================================

		HideRespawnText = function(value) {
			local rtime = 0.0
			switch (value) {
				case 1: break
				case 2: rtime = 1.0; break
				default:
					if ("RespawnTextThink" in PopExtUtil.PlayerManager.GetScriptScope()) {
						AddThinkToEnt(PopExtUtil.PlayerManager, null)
						delete PopExtUtil.PlayerManager.GetScriptScope().RespawnTextThink
					}
					return
			}

			PopExtUtil.PlayerManager.ValidateScriptScope()
			PopExtUtil.PlayerManager.GetScriptScope().RespawnTextThink <- function() {
				foreach (player in PopExtUtil.HumanArray) {
					if (player.IsAlive() == true) continue
					SetPropFloatArray(PopExtUtil.PlayerManager, "m_flNextRespawnTime", rtime, player.entindex())
				}
				return -1
			}
			AddThinkToEnt(PopExtUtil.PlayerManager, "RespawnTextThink")
		}

		// DefaultGiantFoosteps = function(value) {
		// 	foreach(bot in PopExtUtil.BotArray) {
		// 		if ("RestoreGiantFootsteps" in bot.GetScriptScope().PlayerThinkTable)
		// 			delete bot.GetScriptScope().PlayerThinkTable.RestoreGiantFootsteps

		// 		bot.AddCustomAttribute("override footstep sound set", 2.0, -1)
		// 	}
	}
	CurAttrs			= {} // Array storing currently modified attributes.
	ConVars  			= {} //table storing original convar values
	SoundsToReplace 	= {}

	ThinkTable     		= {}
	TakeDamageTable 	= {}
	TakeDamageTablePost = {}
	SpawnHookTable   	= {}
	DeathHookTable  	= {}
	//InitWaveTable 	= {}
	DisconnectTable 	= {}
	StartWaveTable  	= {}
	ChangeClassTable 	= {}
	DebugText        	= false

	PathNum 			= 0

	RedMoneyValue = 0

	// function InitWave() {
	// 	foreach (_, func in MissionAttributes.InitWaveTable) func()

	// 	// foreach (attr, value in MissionAttributes.CurAttrs) printl(attr+" = "+value)
	// 	// PopExtMain.Error.RaisedParseError = false
	// }

	function Cleanup()
	{
		MissionAttributes.ResetConvars()
		this.PathNum = 0
		foreach (bot in PopExtUtil.BotArray)
			if (bot.GetTeam() == TF_TEAM_PVE_DEFENDERS)
				bot.ForceChangeTeam(TEAM_SPECTATOR, true)

		for (local wearable; wearable = FindByClassname(wearable, "tf_wearable");)
			if (wearable.GetOwner() == null || IsPlayerABot(wearable.GetOwner()))
				EntFireByHandle(wearable, "Kill", "", -1, null, null)

		PopExtMain.Error.DebugLog(format("Cleaned up mission attributes"))
	}

	// Mission Attribute Functions
	// =========================================================
	// Function is called in popfile by mission maker to modify mission attributes.

	function SetConvar(convar, value, duration = 0, hideChatMessage = true) {

		local commentaryNode = FindByClassname(null, "point_commentary_node")
		if (commentaryNode == null && hideChatMessage) commentaryNode = SpawnEntityFromTable("point_commentary_node", {targetname = "  IGNORE THIS ERROR \r"})

		//save original values to restore later
		if (!(convar in MissionAttributes.ConVars)) MissionAttributes.ConVars[convar] <- Convars.GetStr(convar);

		if (Convars.GetStr(convar) != value) Convars.SetValue(convar, value)

		if (duration > 0) EntFire("tf_gamerules", "RunScriptCode", "MissionAttributes.SetConvar("+convar+","+MissionAttributes.ConVars[convar]+")", duration)

		if (commentaryNode != null) EntFireByHandle(commentaryNode, "Kill", "", -1, null, null)
	}

	function ResetConvars(hideChatMessage = true)
	{
		local commentaryNode = FindByClassname(null, "point_commentary_node")
		if (commentaryNode == null && hideChatMessage) commentaryNode = SpawnEntityFromTable("point_commentary_node", {targetname = "  IGNORE THIS ERROR \r"})

		foreach (convar, value in MissionAttributes.ConVars) Convars.SetValue(convar, value)
		MissionAttributes.ConVars.clear()

		if (commentaryNode != null) EntFireByHandle(commentaryNode, "Kill", "", -1, null, null)
	}

	function MissionAttr(...) {

		local args = vargv
		local attr
		local value

		if (args.len() == 0)
			return
		else if (args.len() == 1) {
			attr  = args[0]
			value = null
		}
		else {
			attr  = args[0]
			value = args[1]
		}

		local success = true

		if (attr in this.Attrs)
		{
			this.Attrs[attr](value) //ugly ass
			PopExtMain.Error.DebugLog(format("Added mission attribute %s", attr))
			this.CurAttrs[attr] <- value
		}
		else {

			ParseError(format("Could not find mission attribute '%s'", attr))
			success = false
		}
	}
	// Logging Functions
	// =========================================================
	// Generic debug message that is visible if PrintDebugText is true.
	// Example: Print a message that the script is working as expected.
	Events = {

		function OnScriptHook_OnTakeDamage(params) { foreach (_, func in MissionAttributes.TakeDamageTable) func(params) }
		function OnGameEvent_player_hurt(params) { foreach (_, func in MissionAttributes.TakeDamageTablePost) func(params) }
		function OnGameEvent_player_disconnect(params) { foreach (_, func in MissionAttributes.DisconnectTable) func(params) }
		function OnGameEvent_mvm_begin_wave(params) { foreach (_, func in MissionAttributes.StartWaveTable) func(params) }
		function OnGameEvent_player_changeclass(params) { foreach (_, func in MissionAttributes.ChangeClassTable) func(params) }
		function OnGameEvent_player_team(params) {
			local player = GetPlayerFromUserID(params.userid)
			if (!player.IsBotOfType(TF_BOT_TYPE) && params.team == TEAM_SPECTATOR && params.oldteam == TF_TEAM_PVE_INVADERS)
			{
				EntFireByHandle(player, "RunScriptCode", "PopExtUtil.ChangePlayerTeamMvM(self, TF_TEAM_PVE_INVADERS)", -1, null, null)
				EntFireByHandle(player, "RunScriptCode", "self.ForceRespawn()", SINGLE_TICK, null, null)
			}
		}

		function OnGameEvent_pumpkin_lord_summoned(params) {

			if ("HalloweenBossNotSolidToPlayers" in MissionAttributes && MissionAttributes.HalloweenBossNotSolidToPlayers)
				for (local boss; boss = FindByClassname(boss, "headless_hatman");)
					boss.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		}

		function OnGameEvent_eyeball_boss_summoned(params) {

			if ("HalloweenBossNotSolidToPlayers" in MissionAttributes && MissionAttributes.HalloweenBossNotSolidToPlayers)
				for (local boss; boss = FindByClassname(boss, "eyeball_boss");)
					boss.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		}

		function OnGameEvent_merasmus_summoned(params) {

			if ("HalloweenBossNotSolidToPlayers" in MissionAttributes && MissionAttributes.HalloweenBossNotSolidToPlayers)
				for (local boss; boss = FindByClassname(boss, "merasmus");)
					boss.SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		}

		function OnGameEvent_player_death(params) {
			if (MissionAttributes.SoundsToReplace.len() != 0)
			{
				foreach (sound, override in MissionAttributes.SoundsToReplace)
					foreach (player in PopExtUtil.HumanArray)
					{
						StopSoundOn(sound, player)
						if (override == null) continue
						EmitSoundEx({sound_name = MissionAttributes.SoundsToReplace[sound], entity = player})
					}
			}

			foreach (_, func in MissionAttributes.DeathHookTable) func(params)
		}
		function OnGameEvent_recalculate_holidays(params)
		{

			if (GetRoundState() != GR_STATE_PREROUND) return


            foreach (player in PopExtUtil.PlayerArray)
                PopExtMain.PlayerCleanup(player)

			MissionAttributes.Cleanup()
		}

		function OnGameEvent_mvm_wave_complete(params)
		{
			MissionAttributes.Cleanup()
		}

		function OnGameEvent_mvm_mission_complete(params)
		{
			foreach (_, func in ScriptUnloadTable) func()
		}
		function OnGameEvent_teamplay_broadcast_audio(params)
		{
			if (!MissionAttributes.SoundsToReplace.len()) return

			if (params.sound in MissionAttributes.SoundsToReplace)
			{
				foreach (player in PopExtUtil.HumanArray)
					StopSoundOn(params.sound, player)

				if (MissionAttributes.SoundsToReplace[params.sound] == null) return

				EmitSoundEx({sound_name = MissionAttributes.SoundsToReplace[params.sound]})
			}
		}
	}
};

foreach (_, func in ScriptLoadTable) func()

__CollectGameEventCallbacks(MissionAttributes.Events);

MissionAttributes.DeathHookTable.ForceRedMoneyKill <- function(params) {

	local shouldCollect = false

	if (MissionAttributes.RedMoneyValue >= 1)
		shouldCollect = true
	else
	{
		local attacker = GetPlayerFromUserID(params.attacker)

		if (attacker)
		{
			local weaponDefIndex = params.weapon_def_index

			for (local i = 0; i < SLOT_COUNT; i++)
			{
				local weapon = GetPropEntityArray(attacker, "m_hMyWeapons", i)
				if (weapon == null)
					continue

				if (PopExtUtil.GetItemIndex(weapon)!= weaponDefIndex)
					continue

				weapon.ValidateScriptScope()
				if ("collectCurrencyOnKill" in weapon.GetScriptScope())
					shouldCollect = true
			}
		}
	}

	if (!shouldCollect)
		return

	local player = GetPlayerFromUserID(params.userid)

	// bots only drop item_currencypack_custom, but all other pack classes are supported just in case
	for (local entity; entity = FindByClassnameWithin(entity, "item_currencypack_*", player.GetOrigin(), 100);) {
		entity.ValidateScriptScope()
		local scriptScope = entity.GetScriptScope()
		scriptScope.RealOrigin <- entity.GetOrigin()

		scriptScope.CollectPack <- function() {
			local pack = self

			if (!pack.IsValid())
				return

			if (GetPropBool(pack, "m_bDistributed"))
				return

			local packClassName = pack.GetClassname()
			local origin = pack.GetScriptScope().RealOrigin
			local owner = GetPropEntity(pack, "m_hOwnerEntity")
			local modelPath = pack.GetModelName()

			local objectiveResource = FindByClassname(null, "tf_objective_resource")

			local moneyBefore = GetPropInt(objectiveResource, "m_nMvMWorldMoney")
			pack.Kill()
			local moneyAfter = GetPropInt(objectiveResource, "m_nMvMWorldMoney")

			local packPrice = moneyBefore - moneyAfter

			local mvmStats = FindByClassname(null, "tf_mann_vs_machine_stats")

			SetPropInt(mvmStats, "m_currentWaveStats.nCreditsAcquired", GetPropInt(mvmStats, "m_currentWaveStats.nCreditsAcquired") + packPrice)

			for (local i = 1, player; i <= MaxClients(); i++)
				if (player = PlayerInstanceFromIndex(i), player && !IsPlayerABot(player))
					player.AddCurrency(packPrice)

			// spawn a worthless currencypack which can be collected by a scout for overheal
			local fakePack = CreateByClassname("item_currencypack_custom")
			SetPropBool(fakePack, "m_bDistributed", true)
			SetPropEntity(fakePack, "m_hOwnerEntity", owner)
			DispatchSpawn(fakePack)
			fakePack.SetModel(modelPath)

			// position to ground, as fake pack won't have any velocity
			traceWorld <- {
				start = origin,
				end = origin - Vector(0, 0, 50000)
				mask = MASK_SOLID_BRUSHONLY
			}

			TraceLineEx(traceWorld)

			if (traceWorld.hit)
			{
				fakePack.SetAbsOrigin(traceWorld.pos + Vector(0, 0, 5))
			}
			else
				fakePack.SetAbsOrigin(origin)


			fakePack.ValidateScriptScope()
			fakePack.GetScriptScope().despawnTime <- Time() + TF_POWERUP_LIFETIME
			fakePack.GetScriptScope().DespawnThink <- function () {
				if (Time() < despawnTime)
					return

				fakePack.Kill()
			}

			AddThinkToEnt(fakePack, "DespawnThink")
		}

		entity.SetAbsOrigin(Vector(-1000000, -1000000, -1000000))
		EntFireByHandle(entity, "CallScriptFunction", "CollectPack", 0, null, null)
	}
}

local MissionAttrEntity = FindByName(null, "_popext_missionattr_ent")
if (MissionAttrEntity == null) MissionAttrEntity = SpawnEntityFromTable("info_teleport_destination", {targetname = "_popext_missionattr_ent"});

function MissionAttrThink() {
	if (!MissionAttrEntity || !("MissionAttributes" in ROOT)) return -1; // Prevent error on mission complete
	foreach (_, func in MissionAttributes.ThinkTable) func()
	return -1
}

MissionAttrEntity.ValidateScriptScope();
MissionAttrEntity.GetScriptScope().MissionAttrThink <- MissionAttrThink
AddThinkToEnt(MissionAttrEntity, "MissionAttrThink")

// This only supports key : value pairs, if you want var args call MissionAttr directly
function MissionAttrs(attrs = {}) {
	foreach (attr, value in attrs)
		MissionAttributes.MissionAttr(attr, value)
}

//super truncated version incase the pop character limit becomes an issue.
function MAtrs(attrs = {}) {
	foreach (attr, value in attrs)
		MissionAttributes.MissionAttr(attr, value)
}

// Allow calling MissionAttr() directly with MissionAttr().
function MissionAttr(...) {
	MissionAttr.acall(vargv.insert(0, MissionAttributes))
}

//super truncated version incase the pop character limit becomes an issue.
function MAtr(...) {
	MissionAttr.acall(vargv.insert(0, MissionAttributes))
}
