::ROOT <- getroottable()
::MAX_CLIENTS <- MaxClients().tointeger()

if (!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

IncludeScript("tankextensions_main", getroottable())
IncludeScript("tankextensions/combattank", getroottable())
IncludeScript("tankextensions/combattank_weapons/minigun", getroottable())
IncludeScript("tankextensions/combattank_weapons/rocketpod", getroottable())
IncludeScript("alternatewaves", getroottable())
IncludeScript("stylesystem", getroottable())

local hNoBuild = SpawnEntityFromTable("func_nobuild", {
	origin = "-1328 -535 132"
	allowdispenser = 1
	allowteleporters = 1
	spawnflags = 64
})
hNoBuild.KeyValueFromInt("solid", 2)
hNoBuild.SetSize(Vector(-40, -41, -28), Vector(40, 41, 28))

// // METH_HEAD_SOLUTION_TO_A_CRACK_HEAD_PROBLEM_NUMBER_1843194914901
// local hFilter = SpawnEntityFromTable("filter_tf_bot_has_tag", { targetname = "filter_cliff_exclude", require_all_tags = 1, Negated = 1, tags = "bot_cliff" })
// local VectorMatch = @(vec1, vec2) vec1.x == vec2.x && vec1.y == vec2.y && vec1.z == vec2.z
// for(local hTrigger; hTrigger = FindByClassname(hTrigger, "trigger_*");)
// {
// 	local vecOrigin = hTrigger.GetOrigin()
// 	if(VectorMatch(vecOrigin, Vector(-320, 1888, -832)) || VectorMatch(vecOrigin, Vector(-320, 1888, -472)))
// 		SetPropEntity(hTrigger, "m_hFilter", hFilter)
// }
// // nvm fuck this game it gets teleported into spawn and is so big that it produces a duplicate in the skybox

if(!("bPerfectRank" in ROOT))
	::bPerfectRank <- false

PrecacheSound(")ui/itemcrate_smash_ultrarare_short.wav")
PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_loop.wav")
::LightUpTheNight <- {
	OnGameEvent_recalculate_holidays = function(_)
	{
		if(GetRoundState() == 3)
		{
			local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
			if(GetPropInt(hObjectiveResource, "m_nMannVsMachineWaveCount") == GetPropInt(hObjectiveResource, "m_nMannVsMachineMaxWaveCount") && bPerfectRank)
			{
				FindByName(null, "w7_begin_normal_relay").AcceptInput("Disable", null, null, null)
				FindByName(null, "w7_begin_secret_relay").AcceptInput("Enable", null, null, null)
			}
			else
				bPerfectRank = false
			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(hPlayer && !hPlayer.IsFakeClient())
					hPlayer.SetScriptOverlayMaterial(null)
			}
			delete ::LightUpTheNight 
		}
	}

	OnScriptHook_OnTakeDamage = function(params) // Stalkers
	{
		local hAttacker = params.attacker
		if(hAttacker && hAttacker.getclass() == CTFBot && hAttacker.HasBotTag("bot_goldbuster"))
		{
			params.force_friendly_fire = false

			local hVictim = params.const_entity
			if(hVictim != hAttacker)
				params.weapon = hAttacker.GetActiveWeapon()

			if(hVictim.getclass() != CTFBot) return

			local bGaveWeapon = false
			local BotTags = {}
			hVictim.GetAllBotTags(BotTags)

			local sParams
			foreach(k, tag in BotTags)
				if(startswith(tag, "bot_goldweapon"))
					{ sParams = split(tag, "|"); sParams.remove(0); hVictim.RemoveBotTag(tag); bGaveWeapon = true; break }
			
			if(sParams)
				foreach(sItem in sParams)
					hVictim.AcceptInput("$GiveItem", sItem, null, null)
				
			if(bGaveWeapon)
			{
				ClientPrint(null, 3, format("\x0799CCFF%s \x07FBECCBhas turned \x07FFAF00Gold\x07FBECCB!", GetPropString(hVictim, "m_szNetname")))
				DispatchParticleEffect("mvm_loot_explosion", hVictim.GetCenter(), Vector())
				EmitSoundEx({
					sound_name = ")ui/itemcrate_smash_ultrarare_short.wav"
					sound_level = 150
					filter_type = RECIPIENT_FILTER_GLOBAL
					entity = hAttacker
				})
			}
		}
	}

	CrimsonGlowChangeTarget = function()
	{
		local flTargetDist
		local hPlayerTarget
		for(local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(!hPlayer || hPlayer.GetTeam() != 2 || !hPlayer.IsAlive()) continue
			local flPlayerDist = (hPlayer.GetOrigin() - self.GetOrigin()).Length()
			if(!flTargetDist || flPlayerDist < flTargetDist)
				flTargetDist = flPlayerDist, hPlayerTarget = hPlayer
		}
		if(hPlayerTarget)
		{
			local vecPlayer = hPlayerTarget.GetOrigin()
			local Trace = {
				start = vecPlayer
				end = vecPlayer + Vector(0, 0, -8192)
				mask = 81931
			}
			TraceLineEx(Trace)
			FindByName(null, "crimsonglow_rotato").SetAbsOrigin(Trace.endpos + Vector(0, 0, 8))
		}
	}

	SetGutterman = function()
	{
		for(local i = 0; i <= 6; i++)
		{
			local hWeapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 0)
			{
				hWeapon.ValidateScriptScope()
				local hWeapon_scope = hWeapon.GetScriptScope()
				hWeapon_scope.clamp <- function(value, low, high)
				{
					if (value < low)
						return low
					if (value > high)
						return high
					return value
				}
				hWeapon_scope.Think <- function()
				{
					if(self && self.IsValid()) self.AddAttribute("spread penalty", clamp(2 - NetProps.GetPropFloat(self, "m_fFireDuration") * 0.2, 0, 2), -1)
					return -1
				}
				AddThinkToEnt(hWeapon, "Think")
				break
			}
		}
	}
	
	SetStalker = function()
	{
		local sName = "stalkerent_" + self.entindex()
		local hThinkEnt = SpawnEntityFromTable("info_target", { targetname = sName, spawnflags = 0x01 })
		SetPropBool(hThinkEnt, "m_bForcePurgeFixedupStrings", true)
		
		local sParam = format("interrupt_action -posent %s -lookposent %s -waituntildone", sName, sName)
		EntFireByHandle(self, "$BotCommand", sParam, 0.1, null, null)
		EntFireByHandle(self, "$BotCommand", sParam, 1, null, null)

		hThinkEnt.ValidateScriptScope()
		local hThinkEnt_scope = hThinkEnt.GetScriptScope()
		hThinkEnt_scope.hStalker <- self
		hThinkEnt_scope.hAnimProp <- null
		hThinkEnt_scope.bDetonating <- false
		hThinkEnt_scope.flTimeNext <- Time()

		local hGlow = SpawnEntityFromTable("tf_glow", { target = sName, GlowColor = "194 180 0 255" })
		SetPropEntity(hGlow, "m_hTarget", self)

		local hGiants = {}
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && hPlayer.GetTeam() == self.GetTeam() && hPlayer.IsAlive() && hPlayer.IsMiniBoss() && hPlayer != self)
				hGiants[hPlayer] <- (hPlayer.GetOrigin() - self.GetOrigin()).Length()
		}
		local hGiantsOrdered = []
		while(hGiants.len() != 0) // sorting algorithms are cool but i doubt i did it right
		{
			local hGiantSelected
			local flDistSelected = 0
			foreach(hGiant, flDist in hGiants)
				if(flDist > flDistSelected)
					hGiantSelected = hGiant,
					flDistSelected = flDist
			hGiantsOrdered.append(hGiantSelected)
			delete hGiants[hGiantSelected]
		}

		EmitSoundEx({
			sound_name = "mvm/sentrybuster/mvm_sentrybuster_loop.wav"
			sound_level = 90
			entity = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			pitch = 85
		})
		hThinkEnt_scope.Cleanup <- function()
		{
			if(hStalker && hStalker.IsValid())
			{
				printl(hStalker)
				hStalker.EnableDraw()
				EmitSoundEx({
					sound_name = "mvm/sentrybuster/mvm_sentrybuster_loop.wav"
					entity = hStalker
					filter_type = RECIPIENT_FILTER_GLOBAL
					flags = 4
				})
			}
			if(hAnimProp && hAnimProp.IsValid())
				hAnimProp.Destroy()
			if(hGlow && hGlow.IsValid())
				hGlow.Destroy()
			self.Destroy()
		}
		hThinkEnt_scope.Think <- function()
		{
			local vecStalker = hStalker.GetOrigin()
			local iRange = Convars.GetInt("tf_bot_suicide_bomb_range")

			if(!(hStalker && hStalker.IsValid() && hStalker.IsAlive()))
				{ Cleanup(); return }
			if(hAnimProp && hAnimProp.IsValid())
				hAnimProp.SetAbsOrigin(vecStalker), hAnimProp.SetAbsAngles(hStalker.GetAbsAngles())
			if(!bDetonating)
			{
				if(hStalker.InCond(7))
				{
					bDetonating = true
					hStalker.DisableDraw()
					local iRNG = RandomInt(1, 50)
					hAnimProp = SpawnEntityFromTable("prop_dynamic", { origin = vecStalker, angles = hStalker.GetAbsAngles(), modelscale = hStalker.GetModelScale(), model = iRNG == 1 ? "models/player/taunts/greetingstyle.mdl" : "models/bots/sniper/bot_sniper.mdl", rendermode = 10, disableshadows = 1, disablebonefollowers = 1, "OnAnimationBegun" : "!self,SetPlaybackRate,0.84,0,-1" })
					local hAnimPropOrnament = SpawnEntityFromTable("prop_dynamic_ornament", { model = "models/bots/skeleton_sniper/skeleton_sniper_stalker.mdl" })
					hAnimPropOrnament.AcceptInput("SetAttached", "!activator", hAnimProp, null)
					hAnimProp.AcceptInput("SetAnimation", iRNG == 1 ? "taunt01" : "melee_deploybomb", null, null)
					SetPropEntity(hGlow, "m_hTarget", hAnimPropOrnament)
					self.KeyValueFromString("targetname", "")
					
					EmitSoundEx({
						sound_name = "mvm/sentrybuster/mvm_sentrybuster_loop.wav"
						entity = hStalker
						filter_type = RECIPIENT_FILTER_GLOBAL
						flags = 4
					})

					for(local hBot; hBot = FindByClassnameWithin(hBot, "player", vecStalker, iRange);)
						if(hBot.IsBotOfType(TF_BOT_TYPE) && hBot.GetTeam() == hStalker.GetTeam())
						{
							hBot.AddCustomAttribute("mult_player_movespeed_active", 0.01, 2)
						}
				}
				if(hStalker.GetHealth() > 1 && hGiantsOrdered.len() > 0)
				{
					local hGiant
					while(!(hGiant = hGiantsOrdered[0]).IsValid() || !hGiant.IsAlive())
						{ hGiantsOrdered.remove(0); if(hGiantsOrdered.len() == 0) break }
					
					if(hGiant)
					{
						local vecGiant = hGiant.GetOrigin()
						self.SetAbsOrigin(vecGiant + Vector(0, 0, 150))
						if((vecGiant - vecStalker).Length() < iRange / 3.0)
						{
							SetPropInt(hStalker, "m_takedamage", 0)
							hStalker.SetHealth(1)
						}
					}
				}
				else self.SetAbsOrigin(vecStalker), flTimeNext += 9999

				local flTime = Time()
				if(flTime >= flTimeNext)
				{
					flTimeNext += 4
					hStalker.EmitSound("MVM.SentryBusterIntro")
				}
			}
			return -1
		}
		AddThinkToEnt(hThinkEnt, "Think")
	}

	FixProjectileGravity = function()
	{
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(self, "m_hMyWeapons", i)
			if(!hWeapon) continue
			local flGravity = hWeapon.GetAttribute("projectile gravity", 0)
			if(flGravity != 0)
			{
				hWeapon.RemoveAttribute("projectile gravity")
				hWeapon.ValidateScriptScope()
				local hWeapon_scope = hWeapon.GetScriptScope()
				hWeapon_scope.hPlayer <- self
				hWeapon_scope.flGravity <- flGravity
				hWeapon_scope.flLastFireTime <- GetPropFloat(hWeapon, "m_flLastFireTime")
				hWeapon_scope.Think <- function()
				{
					if(!self.IsValid()) return
					local flNewGravity = self.GetAttribute("projectile gravity", 0.8192)
					if(flNewGravity != 0.8192)
					{
						flGravity = flNewGravity
						hWeapon.RemoveAttribute("projectile gravity")
					}
					local flFireTime = GetPropFloat(self, "m_flLastFireTime")
					if(flFireTime != flLastFireTime && flGravity != 0)
						for(local hProjectile; hProjectile = FindByClassnameWithin(hProjectile, "tf_projectile_*", hPlayer.EyePosition(), 32);)
							if(hProjectile.GetOwner() == hPlayer || GetPropEntity(hProjectile, "m_hThrower"))
							{
								SetPropBool(hProjectile, "m_bForcePurgeFixedupStrings", true)
								hProjectile.SetMoveType(MOVETYPE_FLY, MOVECOLLIDE_FLY_CUSTOM)
								hProjectile.ApplyAbsVelocityImpulse(hProjectile.GetPhysVelocity())
								hProjectile.ValidateScriptScope()
								local hProjectile_scope = hProjectile.GetScriptScope()
								hProjectile_scope.flProjectileGravity <- flGravity
								hProjectile_scope.Think <- function()
								{
									if(!self.IsValid()) return
									self.ApplyAbsVelocityImpulse(Vector(0, 0, -(flProjectileGravity / 66.0)))
									local vecVelocity = self.GetAbsVelocity()
									vecVelocity.Norm()
									self.SetForwardVector(vecVelocity)
									return -1
								}
								AddThinkToEnt(hProjectile, "Think")
							}
					flLastFireTime = flFireTime
					return -1
				}
				AddThinkToEnt(hWeapon, "Think")
			}
		}
	}
	OnGameEvent_post_inventory_application = function(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(hPlayer)
			hPlayer.AcceptInput("RunScriptCode", "LightUpTheNight.FixProjectileGravity.call(this)", null, null)
	}

	DecideWave7 = function()
	{
		local hRelay = FindByName(null, "w7_begin_secret_relay")
		if(hRelay && GetPropBool(hRelay, "m_bDisabled") == false)
		{
			AlternateWaves.AddWaveIcons([
				[ "heavy_head_nys", 1, MVM_CLASS_FLAG_MINIBOSS ]
			])
		}
		else
		{
			AlternateWaves.AddWaveIcons([
				[ "hyper_giant",                1,  MVM_CLASS_FLAG_MINIBOSS                             ],
				[ "scout_fan_supportgiant",     0,  MVM_CLASS_FLAG_SUPPORT                              ],
				[ "scout",                      0,  MVM_CLASS_FLAG_SUPPORT                              ],
				[ "heavy_armored_fist",         4,  MVM_CLASS_FLAG_NORMAL   | MVM_CLASS_FLAG_ALWAYSCRIT ],
				[ "medic",                      4,  MVM_CLASS_FLAG_NORMAL                               ],
				[ "tank_combat_minigun_rocket", 1,  MVM_CLASS_FLAG_MINIBOSS                             ],
				[ "soldier",                    12, MVM_CLASS_FLAG_NORMAL   | MVM_CLASS_FLAG_ALWAYSCRIT ],
				[ "soldier_sergeant_crits",     0,  MVM_CLASS_FLAG_SUPPORT  | MVM_CLASS_FLAG_ALWAYSCRIT ],
				[ "demo_bomber",                0,  MVM_CLASS_FLAG_SUPPORT                              ],
				[ "heavy_chief",                0,  MVM_CLASS_FLAG_SUPPORT                              ]
			])
		}
	}
	
	function SetDestroyCallback(entity, callback)
	{
		entity.ValidateScriptScope();
		local scope = entity.GetScriptScope();
		scope.setdelegate({}.setdelegate({
				parent   = scope.getdelegate()
				id       = entity.GetScriptId()
				index    = entity.entindex()
				callback = callback
				_get = function(k)
				{
					return parent[k];
				}
				_delslot = function(k)
				{
					if (k == id)
					{
						entity = EntIndexToHScript(index);
						local scope = entity.GetScriptScope();
						scope.self <- entity;
						callback.pcall(scope);
					}
					delete parent[k];
				}
			})
		);
	}

	TimeStopRevertInfo = {}
	TimeStopInfo = {}
	bTimeStop = false
	hTimeStopThink = null
	function TimeStop(bool = null, hIgnore = null)
	{
		if(bool == null)
			bool = !bTimeStop
		local flTime = Time()
		if(bool && !bTimeStop)
		{
			EntFire("tf_gamerules", "PlayVO", "replay/enterperformancemode.wav")
			EntFire("tf_gamerules", "PlayVO", "replay/enterperformancemode.wav")
			ScreenFade(null, 255, 255, 255, 50, 1.2, 0, 1)
			PrecacheSound("ambient/levels/citadel/citadel_drone_loop4.wav")
			EmitSoundEx({
				sound_name = "ambient/levels/citadel/citadel_drone_loop4.wav"
				entity = First()
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			bTimeStop = true

			for(local hEnt = Next(First()); hEnt = Next(hEnt);)
			{
				local sClassname = hEnt.GetClassname()
				if(hIgnore != null)
				{
					if(sClassname == "player" && hEnt == hIgnore) continue
					
					if(startswith(sClassname, "obj_") && GetPropEntity(hEnt, "m_hBuilder") == hIgnore) continue

					local hOwner = hEnt.GetOwner()
					if(hOwner == hIgnore) continue
					if(startswith(sClassname, "tf_projectile_") && (
						GetPropEntity(hEnt, "m_hThrower") == hIgnore ||
						GetPropEntity(hOwner, "m_hBuilder") == hIgnore
					)) continue

					if(hEnt.GetRootMoveParent() == hIgnore) continue
				}

				local RevertInfo = {}
				local Info = {}

				if("SetPlaybackRate" in hEnt)
				{
					RevertInfo.playbackrate <- hEnt.GetPlaybackRate()
					hEnt.SetPlaybackRate(0)
				}

				if("GetMoveType" in hEnt && hEnt.GetMoveType() != 0)
				{
					RevertInfo.velocity <- hEnt.GetAbsVelocity()
					RevertInfo.physvelocity <- hEnt.GetPhysVelocity()
					RevertInfo.movetype <- hEnt.GetMoveType()
					Info.physvelocity <- Vector(0, 0, 12)
					Info.movetype <- MOVETYPE_NONE
					hEnt.SetAbsVelocity(Vector())
					hEnt.SetPhysVelocity(Vector())
					hEnt.SetMoveType(MOVETYPE_NONE, GetPropInt(hEnt, "movecollide"))
				}

				if(sClassname == "player")
				{
					RevertInfo.clientsideanimation <- GetPropBool(hEnt, "m_bClientSideAnimation")
					RevertInfo.flags <- FL_FROZEN
					RevertInfo.overlay <- null
					Info.noswitch <- 1
					Info.cloakmeter <- GetPropFloat(hEnt, "m_Shared.m_flCloakMeter")
					Info.ragemeter <- GetPropFloat(hEnt, "m_Shared.m_flRageMeter")
					Info.energydrinkmeter <- GetPropFloat(hEnt, "m_Shared.m_flEnergyDrinkMeter")
					Info.hypemeter <- GetPropFloat(hEnt, "m_Shared.m_flHypeMeter")
					Info.chargemeter <- GetPropFloat(hEnt, "m_Shared.m_flChargeMeter")
					Info.itemchargemeter <- GetPropFloat(hEnt, "m_Shared.m_flItemChargeMeter")
					if(!hEnt.IsAlive()) RevertInfo.movetype <- MOVETYPE_WALK
					Info.flags <- FL_FROZEN
					SetPropBool(hEnt, "m_bClientSideAnimation", false)
					hEnt.AddFlag(FL_FROZEN)
					hEnt.SetScriptOverlayMaterial("debug/hsv")
				}
				else if(startswith(sClassname, "tf_weapon_"))
				{
					RevertInfo.nextprimaryattack <- GetPropFloat(hEnt, "m_flNextPrimaryAttack") - flTime
					RevertInfo.nextsecondaryattack <- GetPropFloat(hEnt, "m_flNextSecondaryAttack") - flTime
					RevertInfo.timeweaponidle <- GetPropFloat(hEnt, "m_flTimeWeaponIdle") - flTime
					Info.nextprimaryattack <- 1
					Info.nextsecondaryattack <- 1
					Info.timeweaponidle <- 1
					Info.chargelevel <- GetPropFloat(hEnt, "m_flChargeLevel")
					
					local flEffectBarRegenTime = GetPropFloat(hEnt, "m_flEffectBarRegenTime")
					if(flEffectBarRegenTime > 0) Info.effectbarregentime <- flEffectBarRegenTime - flTime
				}
				else if(sClassname == "tf_powerup_bottle")
				{
					RevertInfo.active <- false
					Info.active <- true
				}
				else if(startswith(sClassname, "tf_projectile_"))
				{
					RevertInfo.solid <- hEnt.GetSolid()
					RevertInfo.eflags <- EFL_NO_THINK_FUNCTION
					hEnt.SetSolid(SOLID_BSP)
					hEnt.AddEFlags(EFL_NO_THINK_FUNCTION)
				}
				else if(startswith(sClassname, "obj_"))
				{
					RevertInfo.eflags <- EFL_NO_THINK_FUNCTION
					hEnt.AddEFlags(EFL_NO_THINK_FUNCTION)
				}
				
				if(RevertInfo.len() > 0) TimeStopRevertInfo[hEnt] <- RevertInfo
				if(Info.len() > 0) TimeStopInfo[hEnt] <- Info
			}
			hTimeStopThink = CreateByClassname("func_brush")
			hTimeStopThink.ValidateScriptScope()
			hTimeStopThink.GetScriptScope().Think <- function()
			{
				LightUpTheNight.TimeStopThink()
				return -1
			}
			AddThinkToEnt(hTimeStopThink, "Think")
			SetDestroyCallback(hTimeStopThink, function() { LightUpTheNight.TimeStopDestroy() })
		}
		else if(!bool && bTimeStop)
		{
			EntFire("tf_gamerules", "PlayVO", "replay/exitperformancemode.wav")
			EntFire("tf_gamerules", "PlayVO", "replay/exitperformancemode.wav")
			ScreenFade(null, 255, 255, 255, 50, 0.815, 0, 1)
			bTimeStop = false

			if(hTimeStopThink && hTimeStopThink.IsValid())
				hTimeStopThink.Kill()
		}
	}
	function TimeStopKeyvalues(hEnt, Table, flTime, bAdd)
	{
		if("playbackrate" in Table)
			hEnt.SetPlaybackRate(Table.playbackrate)

		if("origin" in Table)
			hEnt.SetAbsOrigin(Table.origin)
		if("velocity" in Table)
			hEnt.SetAbsVelocity(Table.velocity)
		if("physvelocity" in Table)
			hEnt.SetPhysVelocity(Table.physvelocity)
		if("movetype" in Table)
			hEnt.SetMoveType(Table.movetype, GetPropInt(hEnt, "movecollide"))
		if("clientsideanimation" in Table)
			SetPropBool(hEnt, "m_bClientSideAnimation", Table.clientsideanimation)
		if("noswitch" in Table)
			Table.noswitch == 0 ? hEnt.RemoveCustomAttribute("disable weapon switch") : hEnt.AddCustomAttribute("disable weapon switch", Table.noswitch, 0.1)
		if("flags" in Table)
			bAdd ? hEnt.AddFlag(Table.flags) : hEnt.RemoveFlag(Table.flags)
		if("condition" in Table)
			bAdd ? hEnt.AddCond(Table.condition) : hEnt.RemoveCond(Table.condition)
		if("solid" in Table)
			hEnt.SetSolid(Table.solid)
		if("eflags" in Table)
			bAdd ? hEnt.AddEFlags(Table.eflags) : hEnt.RemoveEFlags(Table.eflags)
		if("overlay" in Table)
			hEnt.SetScriptOverlayMaterial(Table.overlay)
		if("cloakmeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flCloakMeter", Table.cloakmeter)
		if("ragemeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flRageMeter", Table.ragemeter)
		if("energydrinkmeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flEnergyDrinkMeter", Table.energydrinkmeter)
		if("hypemeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flHypeMeter", Table.hypemeter)
		if("chargemeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flChargeMeter", Table.chargemeter)
		if("itemchargemeter" in Table)
			SetPropFloat(hEnt, "m_Shared.m_flItemChargeMeter", Table.itemchargemeter)

		if("active" in Table)
			SetPropBool(hEnt, "m_bActive", Table.active)

		if("nextprimaryattack" in Table)
			SetPropFloat(hEnt, "m_flNextPrimaryAttack", flTime + Table.nextprimaryattack)
		if("nextsecondaryattack" in Table)
			SetPropFloat(hEnt, "m_flNextSecondaryAttack", flTime + Table.nextprimaryattack)
		if("timeweaponidle" in Table)
			SetPropFloat(hEnt, "m_flTimeWeaponIdle", flTime + Table.nextprimaryattack)
		if("effectbarregentime" in Table)
			SetPropFloat(hEnt, "m_flEffectBarRegenTime", flTime + Table.effectbarregentime)
		if("chargelevel" in Table)
			SetPropFloat(hEnt, "m_flChargeLevel", Table.chargelevel)
	}
	function TimeStopThink()
	{
		local flTime = Time()
		foreach(hEnt, Info in TimeStopInfo)
		{
			if(!hEnt || !hEnt.IsValid()) { continue }
			TimeStopKeyvalues(hEnt, Info, flTime, true)
		}
		EntFire("tf_ragdoll", "Kill")
	}
	function TimeStopDestroy()
	{
		local flTime = Time()
		TimeStopInfo.clear()
		foreach(hEnt, RevertInfo in TimeStopRevertInfo)
		{
			if(!hEnt || !hEnt.IsValid()) { continue }
			TimeStopKeyvalues(hEnt, RevertInfo, flTime, false)
		}
		TimeStopRevertInfo.clear()
		EmitSoundEx({
			sound_name = "ambient/levels/citadel/citadel_drone_loop4.wav"
			entity = First()
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags = 4
		})
	}
}
__CollectGameEventCallbacks(LightUpTheNight)

StyleSystem.SetParams({
	PRank = 19000
	SRank = 16500
	ARank = 8800
	BRank = 4400
	CRank = 2200
})
StyleSystem.SetCallbacks({
	PRank = function()
	{
		EntFire("perfectrank_achieved_relay", "Trigger")
	}
	All = function()
	{
		if(StyleSystem.iRank > StyleSystem.iLastRank && StyleSystem.iRank != 5)
			EntFire("player", "$PlaySoundToSelf", "ui/quest_status_tick_novice.wav")
		if(StyleSystem.iLastRank == 5)
			EntFire("perfectrank_lost_relay", "Trigger")
	}
})