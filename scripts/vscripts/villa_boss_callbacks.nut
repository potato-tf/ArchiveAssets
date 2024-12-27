IncludeScript("customweaponsvillaedit.nut", getroottable())

PrecacheSound("misc/halloween/spell_fireball_impact.wav")
PrecacheSound("ambient/explosions/explode_1.wav")
PrecacheSound("ambient/explosions/explode_4.wav")
PrecacheSound("ambient/explosions/explode_5.wav")
PrecacheSound("ambient/explosions/explode_7.wav")
PrecacheSound("ambient/explosions/explode_8.wav")
PrecacheSound("ambient/levels/labs/electric_explosion1.wav")
PrecacheSound("ambient/levels/labs/electric_explosion2.wav")
PrecacheSound("ambient/levels/labs/electric_explosion3.wav")
PrecacheSound("ambient/levels/labs/electric_explosion4.wav")
PrecacheSound("ambient/levels/labs/electric_explosion5.wav")
PrecacheSound("misc/doomsday_missile_explosion.wav")
PrecacheSound("mvm/mvm_tank_explode.wav")
PrecacheSound("vo/mvm/norm/medic_mvm_specialcompleted05.mp3") //Transitioning to Tumor mimic
PrecacheSound("vo/mvm/norm/medic_mvm_specialcompleted07.mp3") //Transitioning to Cardiomyopathy mimic

PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "ukgr_tachycardia_intro"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "ukgr_teleport_spellwheel"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "boss_halo"})
PrecacheEntityFromTable({classname = "ukgr_death_explosion", effect_name = "boss_halo"})

::bossCallbacks <- {
	ukgr = null

	Cleanup = function() {
		delete ::bossCallbacks
    }

	OnGameEvent_recalculate_holidays = function(_) {
		if(GetRoundState() == 3) {
			Cleanup()
		}
	}

	OnGameEvent_mvm_wave_complete = function(_) {
		Cleanup()
	}

    OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		if(player == null) return
		if(!IsPlayerABot(player)) return

        EntFireByHandle(player, "RunScriptCode", "bossCallbacks.checkTags()", -1, player, null)
	}

	checkTags = function() {
		if(!activator.HasBotTag("UKGR")) return
		ukgr = activator
		activator.ValidateScriptScope()
		IncludeScript("villa_boss.nut", activator.GetScriptScope())
	}

	cleanupPhase1Support = function() { //if some of the phase 1 soldiers are still floating around
		local support = ukgr.GetScriptScope().support
		foreach(bot in support) {
			if(NetProps.GetPropInt(bot, "m_lifeState") == 0) {
				bot.TakeDamage(1000, 0, bot)
			}
			EntFireByHandle(bot, "runscriptcode", "self.ForceChangeTeam(TEAM_SPECTATOR, true)", -1, null, null)
		}
	}

	OnScriptHook_OnTakeDamage = function(params) { //may just put this in a separate namespace to throw out early
		if(params.const_entity != ukgr) return
		local scope = ukgr.GetScriptScope()
		if(scope.mainPhase == 3) return
		if(ukgr.GetHealth() <= params.damage) {
			scope.mainPhase++

			switch(scope.mainPhase) {
				case 2:
					foreach(player, datatable in losecond.players) {
						if(player.InCond(TF_COND_HALLOWEEN_GHOST_MODE)) {
							player.ForceRespawn()
							if(datatable.reanimEntity && datatable.reanimEntity.IsValid()) {
								datatable.reanimEntity.Kill();		
								datatable.reanimCount++;
							}
						}
						player.AcceptInput("SetFogController", "outside_fog", null, null)
					}
					delete ::phase1Callbacks
					if("offensiveThink" in scope.thinkTable) {
						delete scope.thinkTable.offensiveThink
					}
					else {
						delete scope.thinkTable.defensiveThink
					}
					if("phase1skinBuffThink" in scope.thinkTable) delete scope.thinkTable.phase1skinBuffThink
					Entities.FindByName(null, "pop_interface").AcceptInput("ChangeBotAttributes", "ShootPlayers", null, null)
					EntFire("gamerules", "runscriptcode", "bossCallbacks.cleanupPhase1Support()",  2)
					ukgr.RemoveWeaponRestriction(SECONDARY_ONLY)
					ukgr.RemoveCustomAttribute("damage bonus")
					ukgr.RemoveCustomAttribute("move speed bonus")
					ukgr.RemoveCondEx(TF_COND_CRITBOOSTED_USER_BUFF, true)
					ukgr.RemoveCondEx(TF_COND_HALLOWEEN_SPEED_BOOST, true)
					ukgr.RemoveBotAttribute(HOLD_FIRE_UNTIL_FULL_RELOAD)
				// case 3:
					local spawnbotOrigin = Entities.FindByName(null, "spawnbot_boss").GetOrigin()
					//local playerTeleportLocation = Vector(-2252, 2209, 579)

					EntFire("teleport_relay", "CancelPending")
					EntFire("teleport_player_to_arena" "AddOutput", "target roof_player_destination")

					ukgr.AddBotAttribute(SUPPRESS_FIRE)
					ukgr.AddCondEx((TF_COND_PREVENT_DEATH), -1, null)
					ukgr.GenerateAndWearItem("TF_WEAPON_SYRINGE_GUN_MEDIC")
					ukgr.AddCustomAttribute("max health additive bonus", 40000,  -1)
					ukgr.SetHealth(ukgr.GetMaxHealth())
					ukgr.Teleport(true, spawnbotOrigin, false, QAngle(), false, Vector())
					scope.thinkTable.finaleThink <- scope.finaleThink
					ukgr.RemoveBotAttribute(SUPPRESS_FIRE)
					//Disable altmode spawns to block tumors
					EntFire("spawnbot_altmode", "Disable", null, 5)
					EntFire("spawnbot_roof", "Enable", null, 10)

					ScreenFade(null, 0, 0, 0, 255, 0.75, 1.5, 2) //fix timing
					for(local i = 1; i <= MaxPlayers ; i++) {
						local player = PlayerInstanceFromIndex(i)
						if(player == null) continue
						if(IsPlayerABot(player)) continue

						EntFireByHandle(player, "runscriptcode", "self.Teleport(true, Vector(-2909, 3766, 2251), true, QAngle(2, -42.31, 0), false, Vector())",
							1, null, null)
					}
					break
				case 3:
					DispatchParticleEffect("ukgr_death_explosion", ukgr.GetCenter(), Vector())
					ukgr.AddCustomAttribute("dmg taken increased", 0.00001, -1)
					ukgr.AddCustomAttribute("move speed penalty", 0.000001, -1)
					ukgr.AddCustomAttribute("increased jump height", 0.000001, -1)
					ukgr.AddBotAttribute(SUPPRESS_FIRE)
					//prevent phase from advancing or smth
					for(local i = 1; i <= MaxPlayers ; i++) {
						local player = PlayerInstanceFromIndex(i)
						if(player == null) continue
						if(IsPlayerABot(player)) continue

						player.AddCustomAttribute("dmg taken increased", -0.01, -1)
					}
					scope.isExploding = true
					ukgr.RemoveCond(TF_COND_PREVENT_DEATH)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3`)", 0, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/explosions/explode_1.wav`)", 0, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/levels/labs/electric_explosion1.wav`)", 0.4, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/explosions/explode_4.wav`)", 0.8, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/levels/labs/electric_explosion2.wav`)", 1.2, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/explosions/explode_5.wav`)", 1.6, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/levels/labs/electric_explosion3.wav`)", 2.0, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/explosions/explode_7.wav`)", 2.4, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/levels/labs/electric_explosion4.wav`)", 2.8, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/explosions/explode_8.wav`)", 3.2, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`ambient/levels/labs/electric_explosion5.wav`)", 3.6, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`misc/doomsday_missile_explosion.wav`, true)", 4.0, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "playEmitSoundEx(`mvm/mvm_tank_explode.wav`, true)", 4.0, ukgr, null)
					EntFireByHandle(ukgr, "RunScriptCode", "ScreenFade(null, 230, 230, 230, 255, 1, 4.5, 2)", 4, null, null)
					EntFireByHandle(ukgr, "RunScriptCode", "self.SetAbsOrigin(Vector(-2600, -871, 1493))", 5.0, null, null)
					EntFireByHandle(ukgr, "RunScriptCode", "self.AddCustomAttribute(`health drain`, -9999, -1)", 5.1, null, null)
					EntFireByHandle(ukgr, "RunScriptCode", "self.AddCustomAttribute(`dmg taken increased`, 10, -1)", 5.1, null, null)
					EntFireByHandle(ukgr, "RunScriptCode", "self.TakeDamage(990000,0,self)", 5.1, null, null)
					break
			}
			params.early_out = true
		}
	}

	OnGameEvent_player_death = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		if(!IsPlayerABot(player)) {
			local randomVoice = RandomInt(0,2)
			switch(randomVoice) {
				case 0:
					ukgr.AcceptInput("RunScriptCode", "playEmitSoundEx(\"vo/mvm/norm/medic_mvm_laughevil01.mp3\", true)", null, null)
					break
				case 1:
					ukgr.AcceptInput("RunScriptCode", "playEmitSoundEx(\"vo/mvm/norm/medic_mvm_laughshort01.mp3\", true)", null, null)
					break
				case 2:
					ukgr.AcceptInput("RunScriptCode", "playEmitSoundEx(\"vo/mvm/norm/medic_mvm_laughshort02.mp3\", true)", null, null)
					break
				default:
					break
			}
			return
		}
        if(!player.HasBotTag("UKGR_Tumor")) return
		ukgr.GetScriptScope().deadTumorCounter++
		if(ukgr.GetHealth() >= 500) ukgr.TakeDamage(150, DMG_BLAST, ukgr)
    }
}
__CollectGameEventCallbacks(bossCallbacks)

::reduceToOneHP <- function() {
	if(ukgr == null) return
	if(IsPlayerABot(self)) return
	if(self.GetHealth() <= 5) return
	self.SetHealth(1)
}