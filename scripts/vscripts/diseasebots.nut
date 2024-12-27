::pneumoniaSpawner <- Entities.FindByName(null, "pneumonia_spawn_maker")
::uberFlaskNormalSpawner <- Entities.FindByName(null, "uber_flask_normal_maker")
::uberFlaskShortSpawner <- Entities.FindByName(null, "uber_flask_short_maker")

PrecacheSound("vo/halloween_haunted1.mp3")
PrecacheSound("misc/halloween/spell_mirv_explode_secondary.wav")
PrecacheSound("ambient/grinder/grinderbot_03.wav")
PrecacheSound("player/pl_burnpain3.wav")
PrecacheSound("player/flame_out.wav")
PrecacheSound("player/drown3.wav")
PrecacheSound("ambient/levels/labs/teleport_mechanism_windup1.wav")
PrecacheSound("misc/halloween/spell_spawn_boss.wav")
PrecacheScriptSound("Weapon_DragonsFury.BonusDamageHit")
PrecacheScriptSound("Halloween.spell_overheal")
PrecacheScriptSound("Halloween.spell_lightning_cast")
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "hemorrhagic_fever_flamethrower"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "rd_robot_explosion"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "soldierbuff_blue_buffed"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "sarcoma_chargeparticle"})

::diseaseCallbacks <- {
	pneumoniaBot = null

	Cleanup = function() {
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if(player == null) continue
			local scope = player.GetScriptScope()
			
			if("onContainmentBreach" in scope) {
				delete scope.onContainmentBreach
			}

			if(IsPlayerABot(player)) continue
			if(player.GetTeam() != TF_TEAM_RED) continue
			player.SetScriptOverlayMaterial(null)
			player.RemoveCustomAttribute("move speed penalty")
			player.RemoveCustomAttribute("halloween increased jump height")
			player.RemoveCustomAttribute("damage force increase")
			player.RemoveCondEx(TF_COND_SPEED_BOOST, true)
			if("playerDebuffThink" in scope.thinkTable) {
				delete scope.thinkTable.playerDebuffThink
			}
			if("feverThink" in scope.thinkTable) {
				delete scope.thinkTable.feverThink
			}
			if("feverTicks" in scope) {
				delete scope.feverTicks
			}
			if("feverThink" in scope) {
				delete scope.feverThink
			}
		}
		EntFire("uber_flask_normal_prop*", "Kill", -1)
		EntFire("uber_flask_normal_trigger*", "Kill", -1)
		EntFire("uber_flask_short_prop*", "Kill", -1)
		EntFire("uber_flask_short_trigger*", "Kill", -1)

		delete ::diseaseCallbacks
    }

	OnGameEvent_recalculate_holidays = function(_) {
		if(GetRoundState() == 3) {
			Cleanup()
		}
	}

	OnGameEvent_mvm_wave_complete = function(_) {
		Cleanup()
	}

	playSound = function(soundName, player) { //scope moment
		EmitSoundEx({
			sound_name = soundName
			origin = player.GetOrigin()
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			entity = player
			channel = 6
		})
	}

	OnGameEvent_player_death = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		if(player == null) return
		
		if(!IsPlayerABot(player)) {
			local scope = player.GetScriptScope()
			if("feverThink" in scope.thinkTable) {
				delete scope.thinkTable.feverThink
			}
			return
		}

		if(player.HasBotTag("special_disease") && !player.HasBotTag("Malignant_Tumor") && !player.HasBotTag("UKGR_Tumor")) {
			local center = player.GetCenter() //spawnentityatlocation is dumb
			uberFlaskNormalSpawner.SpawnEntityAtLocation(center, Vector())
			EntFire("uber_flask_normal_prop*", "RunScriptCode", "diseaseCallbacks.killInTime(self, 3, 12)", -1)
			EntFire("uber_flask_normal_trigger*", "RunScriptCode", "diseaseCallbacks.killInTime(self, 3, 12)", -1)
			return
		}

		if(player.HasBotTag("Hemorrhagic_Fever")) {
			local scope = player.GetScriptScope()
			EntFire("hemorrhagic_fever_trigger", "Disable")
			EntFire("hemorrhagic_fever_fire_particles", "Stop")
			EntFire("hemorrhagic_fever_weapon_particles", "Stop")
			if("rageParticle" in scope && scope.rageParticle.IsValid()) {
				scope.rageParticle.Kill()
				delete scope.rageParticle
			}
			if("ornament" in scope && scope.ornament.IsValid()) {
				scope.ornament.Kill()
				delete scope.ornament
			}
		}
		if(!player.HasBotTag("Malignant_Tumor") && !player.HasBotTag("UKGR_Tumor")) return

		local victim = null

		DispatchParticleEffect("malignant_tumor_explode", player.GetCenter(), Vector())

		//check if this channel is correct
		EmitSoundEx({
			sound_name = "misc/halloween/spell_mirv_explode_secondary.wav",
			channel = 6,
			origin = player.GetCenter(),
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		while(victim = Entities.FindByClassnameWithin(victim, "player", player.GetCenter(), 180)) {
			if(victim.GetTeam() == TF_TEAM_RED) {
				local distance = (victim.GetCenter() - player.GetCenter()).Length()

				local shouldDamage = true
				//printl("distance " + distance)
				//DebugDrawCircle(player.GetCenter(), Vector(255, 0, 0), 127, 146, true, 1)

				local traceTable = {
					start = player.GetCenter()
					end = victim.GetCenter()
				}
				TraceLineEx(traceTable)

				if(traceTable.hit && traceTable.enthit != victim) {
					//not los, don't damage them
					shouldDamage = false
				}

				if(shouldDamage) {
					local splash = distance / 2.88
					local damage = 125 * (1 - splash / 125)
					//printl("damage " + damage)

					victim.TakeDamageEx(player, player, null, Vector(1, 0, 0), player.GetCenter(), damage, DMG_BLAST)
					diseaseCallbacks.playSound("Weapon_DragonsFury.BonusDamageHit", victim)
				}
			}
		}

		//WE LOVE MIXING GUARD CLAUSES
		if(player.HasBotTag("UKGR_Tumor")) return

		local center = player.GetCenter() + Vector(0, 0, 20)
		uberFlaskShortSpawner.SpawnEntityAtLocation(center, Vector())
		EntFire("uber_flask_short_prop*", "RunScriptCode", "diseaseCallbacks.killInTime(self, 2, 1.5)", -1)
		EntFire("uber_flask_short_trigger*", "RunScriptCode", "diseaseCallbacks.killInTime(self, 2, 1.5)", -1)
	}

	OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid)

		if(player == null) return
		if(player.GetTeam() != TF_TEAM_RED && player.GetTeam() != TF_TEAM_BLUE) return

		if(!IsPlayerABot(player)) {
			EntFireByHandle(player, "RunScriptCode", "diseaseCallbacks.addPlayerDebuffThink()", -1, player, null)
		}
		else {
			player.ValidateScriptScope()
			player.GetScriptScope().onContainmentBreach <- function() {
				self.AddCondEx(TF_COND_SPEED_BOOST, -1, null)
			}
			EntFireByHandle(player, "RunScriptCode", "diseaseCallbacks.specialDiseaseCheck()", -1, player, null)
		}
	}

	setupPneumoniaSpawner = function() {
		local template = Entities.FindByName(null, "pneumonia_spawn_template")
		template.ValidateScriptScope()
		local scope = template.GetScriptScope()

		scope.PreSpawnInstance <- function(classname, targetname) { //this needs to be present

		}

		scope.PostSpawn <- function(entities) {
			foreach(targetname, handle in entities) {
				if(targetname == "pneumonia_spawn_e_hurt") {
					handle.ValidateScriptScope()
					if(!("diseaseCallbacks" in getroottable())) {
						return
					}
					handle.GetScriptScope().owner <- diseaseCallbacks.pneumoniaBot
					handle.GetScriptScope().takePneumoniaDamage <- function() {
						if(!("diseaseCallbacks" in getroottable())) return
						diseaseCallbacks.playSound("player/drown3.wav", activator)
						activator.ViewPunch(QAngle(-6, 0, 0))
						activator.TakeDamage(40, DMG_POISON, owner)
					}
				}
				EntFireByHandle(handle, "Kill", null, 2, null, null)
			}
		}
	}

	specialDiseaseCheck = function() {
		local tags = {}
		activator.GetAllBotTags(tags)

		foreach(i, tag in tags) {
			switch(tag) {
				case "Pneumonia":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_medic.mdl")
					diseaseCallbacks.addPneumoniaThink(activator)
					break
				case "Sarcoma_w6":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_heavy_boss.mdl")
					break
				case "Sarcoma":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_heavy_boss.mdl")
					activator.AcceptInput("RunScriptCode", "diseaseCallbacks.addSarcomaThink()", activator, null)
					break
				case "Dyspnea":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_soldier_boss.mdl")
					break
				case "Tachycardia":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_scout_boss.mdl")
					break
				case "UKGR_Tumor":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_medic_ukgr.mdl")
					break
				case "Malignant_Tumor":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_heavy.mdl")
					break
				case "Cardiomyopathy":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_demo_boss.mdl")
					break
				case "Hemorrhagic_Fever":
					activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_pyro_boss.mdl")
					break
				default:
					break
			}
		}
	}

	addPneumoniaThink = function(bot) {
		pneumoniaBot = bot
		bot.GetScriptScope().pneumoniaThink <- function() {
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				AddThinkToEnt(self, null)
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			}

			if(!pneumoniaSpawner.IsValid()) return //mostly for wave reset
			pneumoniaSpawner.SpawnEntityAtEntityOrigin(self)

			return 1
		}
		AddThinkToEnt(bot, "pneumoniaThink")
	}

	addSarcomaThink = function() {
		//Stage 0 = Unarmed bot (Has SuppressFire) 0.8 scale 1.5 speed
		//Stage 1 = Melee bot 1.25 scale 1 speed
		//Stage 2 = Stock shotgun bot 1.5 scale 0.75 speed
		//Stage 3 = Strong shotgun bot 1.75 scale 0.66 speed
		//Stage 4 = Minigun bot 2.15 scale 0.5 speed
		//Stage 5 = Crit minigun 2.5 scale 0 speed

		local scope = activator.GetScriptScope()
		scope.sarcomaProgress <- 0
		scope.sarcomaStage <- 0
		scope.sarcomaThresholds <- [12, 24, 36, 48, 70, 999999] //Time to reach each stage, in seconds
		scope.sarcomaNextStage <- scope.sarcomaThresholds[0]
		scope.containmentBreachActive <- false

		scope.chargeupParticle <- SpawnEntityFromTable("info_particle_system", {
			effect_name = "sarcoma_chargeparticle"
			start_active = false
		})

		scope.chargeupParticle.AcceptInput("SetParent", "!activator", activator, activator)
		scope.chargeupParticle.AcceptInput("SetParentAttachment", "center_attachment", null, null)

		EmitSoundEx({
			sound_name = "misc/halloween/spell_spawn_boss.wav",
			channel = 6,
			origin = activator.GetCenter(),
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		EmitSoundEx({
			sound_name = "misc/halloween/spell_spawn_boss.wav",
			channel = 6,
			origin = activator.GetCenter(),
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		activator.SetUseBossHealthBar(true)

		SpawnEntityFromTable("filter_tf_bot_has_tag", {
			targetname = "sarcomafilter"
			tags = "sarcoma sarcoma_w6"
		})
		scope.sarcomaPush <- SpawnEntityFromTable("trigger_push", {
			origin = activator.GetCenter()
			pushdir = QAngle(0, 0, 0)
			speed = 125
			startdisabled = true
			spawnflags = 1
			filtername = "team_red"
		})
		scope.selfPush <- SpawnEntityFromTable("trigger_push", {
			origin = activator.GetCenter()
			pushdir = QAngle(0, 0, 0)
			speed = 500
			startdisabled = true
			spawnflags = 1
			filtername = "sarcomafilter"
		})
		scope.sarcomaPush.SetSolid(2)
		scope.sarcomaPush.SetSize(Vector(-100, -100, -104), Vector(100, 100, 104))
		scope.sarcomaPush.AcceptInput("SetParent", "!activator", activator, activator)
		scope.selfPush.SetSolid(2)
		scope.selfPush.SetSize(Vector(-100, -100, -104), Vector(100, 100, 104))
		scope.selfPush.AcceptInput("SetParent", "!activator", activator, activator)

		scope.onContainmentBreach <- function() {
			self.AddCondEx(TF_COND_SPEED_BOOST, -1, null)
			if(sarcomaStage == 5) {
				self.AddCustomAttribute("move speed bonus", 0.6, -1)
			}
			containmentBreachActive = true
			self.AddCustomAttribute("health drain", -2, -1)
		}

		scope.sarcomaThink <- function() {
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				AddThinkToEnt(self, null)
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
				if(chargeupParticle.IsValid()) {
					chargeupParticle.Kill()
				}
				if(sarcomaPush.IsValid()) {
					sarcomaPush.Kill()
				}
				if(selfPush.IsValid()) {
					selfPush.Kill()
				}
				delete sarcomaPush
				delete selfPush
				delete chargeupParticle
				return
			}

			if(self.GetLocomotionInterface().IsStuck()) { //safety for altmode, since he tends to hump walls and get stuck
				//printl("sarcoma triggered antistuck")
				local angles = self.EyeAngles()
				local newYaw = (ceil(angles.y) + 180) % 360

				NetProps.SetPropVector(selfPush, "m_vecPushDir", Vector(0, newYaw, angles.z))
				EntFireByHandle(selfPush, "Enable", null, -1, null, null)
				EntFireByHandle(selfPush, "Disable", null, 0.5, null, null)
			}

			sarcomaProgress++
			if(sarcomaProgress == sarcomaNextStage - 2) {
				EntFireByHandle(chargeupParticle, "Start", null, -1, null, null)
				EmitSoundEx({
					sound_name = "ambient/levels/labs/teleport_mechanism_windup1.wav",
					channel = 6,
					origin = self.GetCenter(),
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
			if(sarcomaProgress < sarcomaNextStage) return 1

			sarcomaStage++
			sarcomaNextStage = sarcomaThresholds[sarcomaStage]
			NetProps.SetPropVector(sarcomaPush, "m_vecPushDir", self.EyeAngles() + Vector())
			EntFireByHandle(sarcomaPush, "Enable", null, -1, null, null)

			EntFireByHandle(chargeupParticle, "Stop", null, -1, null, null)

			switch(sarcomaStage) {
				case 1:
					self.RemoveBotAttribute(SUPPRESS_FIRE)
					self.ClearAllWeaponRestrictions()
					self.AddWeaponRestriction(1)
					self.GenerateAndWearItem("The Killing Gloves of Boxing")
					self.AddCustomAttribute("move speed bonus", 1, -1)
					self.SetScaleOverride(1.25)
					break
				case 2:
					self.ClearAllWeaponRestrictions()
					self.AddWeaponRestriction(4)
					self.AddCustomAttribute("move speed bonus", 0.75, -1)
					self.SetScaleOverride(1.5)
					break
				case 3:
					self.AddCond(TF_COND_OFFENSEBUFF)
					self.AddCustomAttribute("move speed bonus", 0.66, -1)
					self.SetScaleOverride(1.75)
					break
				case 4:
					self.ClearAllWeaponRestrictions()
					self.AddWeaponRestriction(2)
					self.RemoveCond(TF_COND_OFFENSEBUFF)
					self.AddCustomAttribute("move speed bonus", containmentBreachActive ? 0.6 : 0.5, -1)
					self.AddCustomAttribute("dmg taken increased", 1.5, -1)
					self.SetScaleOverride(2.15)
					break
				case 5:
					self.AddCond(TF_COND_CRITBOOSTED_USER_BUFF)
					self.AddCustomAttribute("move speed bonus", containmentBreachActive ? 0.6 : 0.0001, -1)
					self.AddCustomAttribute("health drain", -50, -1)
					self.AddCustomAttribute("dmg taken increased", 4, -1)
					self.SetScaleOverride(2.5)
					break
				default:
					break
			}
			EntFire("sarcoma_evolution_sound", "PlaySound")
			EntFire("sarcoma_evolution_shake", "StartShake")
			DispatchParticleEffect("sarcoma_explode", self.GetOrigin(), Vector())
			EntFireByHandle(sarcomaPush, "Disable", null, 0.5, null, null)
			return 1
		}
		AddThinkToEnt(activator, "sarcomaThink")
	}

	addPlayerDebuffThink = function() {
		//printl("Player Debuff Check is thonking...")
		local scope = activator.GetScriptScope()

		if(!("medigun" in scope) || !scope.medigun.IsValid()) {
			scope.medigun <- null
			for(local i = 0; i < NetProps.GetPropArraySize(activator, "m_hMyWeapons"); i++) {
				local wep = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)

				if(wep && wep.GetClassname() == "tf_weapon_medigun") {
					scope.medigun = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i);
					break;
				}
			}
		}

		scope.dyspneaDebuffed <- false
		scope.tachycardiaDebuffed <- false
		scope.playerDebuffThink <- function() {
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				delete thinkTable.playerDebuffThink
				return
			}
			if(timeCounter < DEFAULTTIME) {
				return
			}

			//Check for Dyspnea's debuff cond, apply screen overlay
			if(self.InCond(12) && !dyspneaDebuffed) {
				dyspneaDebuffed = true
				self.SetScriptOverlayMaterial("effects/forgotten_dyspnea_debuff")
				diseaseCallbacks.playSound(::pomsonSound, self)
			}
			else if(!self.InCond(12) && dyspneaDebuffed) {
				dyspneaDebuffed = false
				self.SetScriptOverlayMaterial(null)
			}

			//Check for Dyspnea's debuff cond
			if(self.InCond(12)) {
				local rageMeter = NetProps.GetPropFloat(self, "m_Shared.m_flRageMeter")
				local newRageMeter = rageMeter - 1.2 > 0 ? rageMeter - 1.2 : 0
				//printl("Rage: " + rageMeter)
				NetProps.SetPropFloat(self, "m_Shared.m_flRageMeter", newRageMeter)

				local uberMeter = NetProps.GetPropFloat(medigun, "m_flChargeLevel")
				local newUberMeter = uberMeter - 0.01 > 0 ? uberMeter - 0.01 : 0
				//printl("uber: " + uberMeter + " " + Time())
				NetProps.SetPropFloat(medigun, "m_flChargeLevel", newUberMeter)
			}

			//Check for tachycardia's debuff cond, apply screen overlay and attributes
			//65 because recall cans apply 32
			if(self.InCond(65) && !tachycardiaDebuffed) {
				tachycardiaDebuffed = true
				self.SetScriptOverlayMaterial("effects/forgotten_tachycardia_debuff")
				diseaseCallbacks.playSound("Halloween.spell_lightning_cast", self)
				self.AddCustomAttribute("move speed penalty", 2, -1)
				self.AddCustomAttribute("halloween increased jump height", 15, -1)
				self.AddCustomAttribute("damage force increase", 1.5, -1)
				self.AddCondEx(TF_COND_SPEED_BOOST, -1, null)
			}
			else if(!self.InCond(65) && tachycardiaDebuffed) {
				tachycardiaDebuffed = false
				self.SetScriptOverlayMaterial(null)
				self.RemoveCustomAttribute("move speed penalty")
				self.RemoveCustomAttribute("halloween increased jump height")
				self.RemoveCustomAttribute("damage force increase")
				self.RemoveCondEx(TF_COND_SPEED_BOOST, true)
			}
		}
		scope.thinkTable.playerDebuffThink <- scope.playerDebuffThink
	}

	killInTime = function(ent, seconds, flashSeconds) {
		if(ent.GetScriptThinkFunc() == "killThink") {
			return
		}
		ent.ValidateScriptScope()
		ent.GetScriptScope().shouldFlash <- false
		ent.GetScriptScope().shouldKill <- false
		ent.GetScriptScope().seconds <- seconds
		ent.GetScriptScope().flashSeconds <- flashSeconds
		ent.GetScriptScope().killThink <- function() {
			if(!shouldFlash) {
				shouldFlash = true
				return flashSeconds
			}
			if(!shouldKill) {
				self.AcceptInput("AddOutput", "renderfx 10", null, null)
				shouldKill = true
				return seconds
			}
			else {
				self.Kill()
			}
		}
		AddThinkToEnt(ent, "killThink")
	}

	activateHemorrhagicFever = function() {
		activator.SetUseBossHealthBar(true)
		local scope = activator.GetScriptScope()
		scope.flamethrower <- null

		for(local i = 0; i < NetProps.GetPropArraySize(activator, "m_hMyWeapons"); i++) {
			local wep = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i)

            if(wep && wep.GetClassname() == "tf_weapon_flamethrower") {
                scope.flamethrower = NetProps.GetPropEntityArray(activator, "m_hMyWeapons", i);
                break;
            }
        }
		
		scope.flamethrowerParticle <- SpawnEntityFromTable("trigger_particle", {
			particle_name = "hemorrhagic_fever_flamethrower"
			attachment_type = 4
			attachment_name = "muzzle"
			spawnflags = 64
		})
		
		scope.rageParticle <- SpawnEntityFromTable("trigger_particle", {
			particle_name = "cardiac_arrest_buffed"
			attachment_type = 1
			spawnflags = 64
		})

		local hemorrhagicFeverTrigger = Entities.FindByName(null, "hemorrhagic_fever_trigger")
		hemorrhagicFeverTrigger.AcceptInput("Enable", null, null, null)
		hemorrhagicFeverTrigger.ValidateScriptScope()
		hemorrhagicFeverTrigger.GetScriptScope().owner <- activator
		hemorrhagicFeverTrigger.GetScriptScope().tickHemorrhagicFever <- function() {
			local scope = activator.GetScriptScope()
			if(!("feverTicks" in scope)) {
				scope.feverTicks <- 0
			}
			
			scope.feverThink <- function() {
				if(timeCounter < DEFAULTTIME) {
					return
				}
				
				diseaseCallbacks.playSound("player/pl_burnpain3.wav", self)
				feverTicks = feverTicks + 1 > 40 ? 40 : feverTicks + 1
				
				if(feverTicks >= 10) {
					//ClientPrint(null, 3, "Ouch! Doing " + (5 + (feverTicks * 0.5)) + " damage")
					self.ViewPunch(QAngle(-5, 0, 0))
					self.IgnitePlayer() //Doesn't burn player but plays on fire voicelines pog
					self.TakeDamage(5 + (feverTicks * 0.5), DMG_BURN, null)
					diseaseCallbacks.playSound("Fire.Engulf", self)
				}
			}
			scope.thinkTable.feverThink <- scope.feverThink
		}

		hemorrhagicFeverTrigger.GetScriptScope().stopHemorrhagicFever <- function() {
			local scope = activator.GetScriptScope()
			local newTicks = scope.feverTicks
			newTicks = newTicks - 3 < 0 ? 0 : newTicks - 3
			
			diseaseCallbacks.playSound("player/flame_out.wav", activator)
			if(newTicks >= 7) {
				newTicks = 7
				// ClientPrint(null, 3, "New ticks above 10, setting to 9...")
			}
			activator.ExtinguishPlayerBurning()
			scope.feverTicks = newTicks
			if("feverThink" in scope.thinkTable) { //dying can delete it first
				delete scope.thinkTable.feverThink
			}
		}

		EntFire("hemorrhagic_fever_fire_particles", "Start")

		scope.onContainmentBreach <- function() {
			self.ClearAllWeaponRestrictions()
			self.AddWeaponRestriction(PRIMARY_ONLY)
			self.AddCondEx(TF_COND_SPEED_BOOST, -1, null)
			self.AddCustomAttribute("move speed bonus", 0.6, -1)
			self.AddCustomAttribute("damage bonus", 1.5, -1)
			self.AddCustomAttribute("bleeding duration", 5, -1)
			self.AddCustomAttribute("dmg taken increased", 2, -1)
			
			EntFire("hemorrhagic_fever_trigger", "Disable", null, -1)
			EntFire("hemorrhagic_fever_fire_particles", "Stop")
			
			NetProps.SetPropString(self, "m_iName", "fever")
			scope.ornament <- SpawnEntityFromTable("prop_dynamic_ornament", {
				InitialOwner = "fever"
				updatechildren = true
				DisableBoneFollowers = true
				model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"
			})
			NetProps.SetPropString(self, "m_iName", null)
			
			flamethrowerParticle.AcceptInput("StartTouch", "!activator", ornament, ornament)
			rageParticle.AcceptInput("StartTouch", "!activator", self, self)
		}
	}
}
__CollectGameEventCallbacks(diseaseCallbacks)
diseaseCallbacks.setupPneumoniaSpawner()
for (local i = 1; i <= MaxPlayers ; i++)
{
	local player = PlayerInstanceFromIndex(i)
	if(player == null) continue
	if(player.GetTeam() != TF_TEAM_RED) continue
	if(!IsPlayerABot(player)) {
		player.AcceptInput("RunScriptCode", "diseaseCallbacks.addPlayerDebuffThink()", player, null)
	}
}

::applyFlaskBoost <- function(flaskLevel) {
	local selfHealth = self.GetHealth()
	//Level 2 = tumor potions
	local hpBoost = (flaskLevel == 2) ? 60 : 200
	self.SetHealth(selfHealth + hpBoost)

	local condBoostDuration = (flaskLevel == 2) ? 4 : 8
	self.AddCondEx(16, condBoostDuration, null)
	self.AddCondEx(26, condBoostDuration, null)

	local scope = self.GetScriptScope()
	if(!("medigun" in scope) || !medigun.IsValid()) {
		scope.medigun <- null
		for(local i = 0; i < NetProps.GetPropArraySize(self, "m_hMyWeapons"); i++) {
			local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)

			if(wep && wep.GetClassname() == "tf_weapon_medigun") {
				scope.medigun = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i);
				break;
			}
		}
	}

	if(medigun == null) {
		return
	}

	local uberBoost = (flaskLevel == 2) ? 0.15 : 0.5
	local rageBoost = uberBoost * 100

	local uberMeter = NetProps.GetPropFloat(medigun, "m_flChargeLevel")
	local newUberMeter = uberMeter + uberBoost < 1 ? uberMeter + uberBoost : 1
	NetProps.SetPropFloat(medigun, "m_flChargeLevel", newUberMeter)

	if(medigun.GetAttribute("generate rage on heal", 0) > 0) {
		local rageMeter = NetProps.GetPropFloat(self, "m_Shared.m_flRageMeter")
		local newRageMeter = rageMeter + rageBoost < 100 ? rageMeter + rageBoost : 100
		NetProps.SetPropFloat(self, "m_Shared.m_flRageMeter", newRageMeter)
	}
	diseaseCallbacks.playSound("Halloween.spell_overheal", self)
}