::playerMaxMoveSpeed <- 1
::bossIsBuffed <- false
//Flag to apply debuffs when players respawn

PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "cardiac_arrest_buffed"})
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "cardiac_arrest_dh_warning"})
PrecacheSound("vo/mvm/mght/soldier_mvm_m_laughlong01.mp3")
PrecacheSound("ui/heartbeat1.mp3")
PrecacheSound("ui/heartbeat2.mp3")
PrecacheSound("ui/heartbeat3.mp3")
PrecacheSound("ui/heartbeat4.mp3")
PrecacheSound("ui/heartbeat5.mp3")

::heartbeaterCallbacks <- {
	Cleanup = function() {
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if(player == null) continue
			if(IsPlayerABot(player)) continue
			if(player.GetTeam() != TF_TEAM_RED) continue
			
			player.RemoveCustomAttribute("move speed penalty")
			player.RemoveCustomAttribute("halloween increased jump height")
			player.RemoveCustomAttribute("uber duration bonus")
			if("thinkTable" in player.GetScriptScope() && "drainShieldThink" in player.GetScriptScope().thinkTable) {
				delete player.GetScriptScope().thinkTable.drainShieldThink
			}
		}
		//delete ::playerMaxMoveSpeed
		delete ::heartbeaterCallbacks
    }
	
	OnGameEvent_mvm_wave_complete = function(_) {
		Cleanup()
	}
	
	OnGameEvent_recalculate_holidays = function(_) {
		if(GetRoundState() == 3) {
			Cleanup()
		} 
	}
	
	OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		if(player == null) return
		
		if(!IsPlayerABot(player) && player.GetTeam() == TF_TEAM_RED) {
			player.AcceptInput("SetFogController", "heartbeater_fog", null, null)
			EntFireByHandle(player, "RunScriptCode", "heartbeaterCallbacks.NerfPlayerUberShield()", -1, player, null)
			return
		}

		if(player.GetTeam() != TF_TEAM_BLUE) return
		EntFireByHandle(player, "RunScriptCode", "heartbeaterCallbacks.addHeartbeaterThink()", -1, player, null)
	}
	
	addHeartbeaterThink = function() {
		if(!activator.HasBotTag("heartbeater")) {
			return
		}
		
		local stunDurationList = [40, 40, 40, 40, 60, 60, 60, 60, 60, 100, 100, 100, 100, 100, 100, 120, 120, 160, 160, 200]
		// Raw sound names, new version calls ambient_generic entities instead
		local stunDurationAudioList = ["heartbeat1", "heartbeat1", "heartbeat1", "heartbeat1", "heartbeat2", "heartbeat2", "heartbeat2", "heartbeat2", "heartbeat2", "heartbeat3", "heartbeat3", "heartbeat3", "heartbeat3", "heartbeat3", "heartbeat3", "heartbeat4", "heartbeat4", "heartbeat5", "heartbeat6", "heartbeat7"]
		local stunDurationChoice = 2
		local activeDuration = 0
		local eligibleForStatChange = false
		local eligibleForStun = true
		const PRIMARYMODE = 1
		const MELEEMODE = 0

		local patternPreference = RandomInt(0,2)
		local patternList = [0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1]
		local patternNumber = 0
		local modeToUse = 0

		activator.GetScriptScope().dhParticle <- SpawnEntityFromTable("trigger_particle", {
			particle_name = "cardiac_arrest_dh_warning"
			attachment_type = 1
			spawnflags = 64
		})
		activator.GetScriptScope().rageParticle <- SpawnEntityFromTable("trigger_particle", {
			particle_name = "cardiac_arrest_buffed"
			attachment_type = 1
			spawnflags = 64
		})

		activator.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_soldier_boss.mdl")
		activator.GetScriptScope().heartbeaterThink <- function() {
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				AddThinkToEnt(self, null)
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			
				if(rageParticle.IsValid()) {
					rageParticle.Kill()
				}
				if(dhParticle.IsValid()) {
					dhParticle.Kill()
				}
				delete rageParticle
				delete dhParticle
				return
			}
			
			if(activeDuration == 0 && eligibleForStun) { //if not stunned and eligible for stun
				stunDurationChoice = bossIsBuffed ? RandomInt(0,8) : RandomInt(0,16) //Yes it maxes out at 19 but I don't like the ultra long delays
				//printl("Stun Audio: " + stunDurationAudioList[stunDurationChoice])
				//printl("Stun Duration: " + stunDurationList[stunDurationChoice])
				
				local soundname = "ui/" + stunDurationAudioList[stunDurationChoice] + ".mp3"
				EmitSoundEx({
					sound_name = soundname,
					channel = 6,
					origin = self.GetCenter(),
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

				EmitSoundEx({
					sound_name = soundname,
					channel = 6,
					origin = self.GetCenter(),
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

				EmitSoundEx({
					sound_name = soundname,
					channel = 6,
					origin = self.GetCenter(),
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

				EmitSoundEx({
					sound_name = soundname,
					channel = 6,
					origin = self.GetCenter(),
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				
				self.AddCondEx(TF_COND_MVM_BOT_STUN_RADIOWAVE, stunDurationList[stunDurationChoice] / 10, null)
				activeDuration = RandomInt(20,160)
				eligibleForStatChange = true
				eligibleForStun = false

				modeToUse = patternList[patternPreference * 5 + patternNumber]
				patternNumber = (patternNumber + 1) > 4 ? 0 : (patternNumber + 1)
				if(modeToUse == PRIMARYMODE && self.GetHealth() <= self.GetMaxHealth() * 0.65) {
					dhParticle.AcceptInput("StartTouch", "!activator", self, self)
                }
				else {
					modeToUse = MELEEMODE
				}
			}
			
			if(self.GetCondDuration(TF_COND_MVM_BOT_STUN_RADIOWAVE) != 0) return //if actively stunned, return
			//printl("Active Duration: " + activeDuration)
			eligibleForStun = true
			activeDuration--

			if(!eligibleForStatChange) return

			self.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
			if(bossIsBuffed) {
				rageParticle.AcceptInput("StartTouch", "!activator", self, self)
			}				

			EntFire("wakeup_sound*", "PlaySound")
			EntFire("wakeup_shake*", "StartShake")

			eligibleForStatChange = false

			if(self.GetHealth() > self.GetMaxHealth() * 0.9) {
				//printl("This triggered")
				self.AddCustomAttribute("move speed bonus", 1.75, -1)
			}
			else {
				self.AddCustomAttribute("move speed bonus", 1.75 * playerMaxMoveSpeed, -1)
			}

			// if(self.GetHealth() > self.GetMaxHealth() * 0.5) return

			self.ClearAllWeaponRestrictions()
			if(modeToUse == PRIMARYMODE) {
				self.AddWeaponRestriction(PRIMARY_ONLY)
				self.AddCustomAttribute("move speed bonus", 0.4, -1)
				dhParticle.AcceptInput("StartTouch", "!activator", self, self)
			}
			else {
				self.AddWeaponRestriction(MELEE_ONLY)
				self.AddCustomAttribute("move speed bonus", 1.75 * playerMaxMoveSpeed, -1)
			}

		}
		AddThinkToEnt(activator, "heartbeaterThink")
	}
	
	NerfPlayerUberShield = function() {
		// local currentUberDuration = self.GetCustomAttribute("uber duration bonus", 0)
		activator.AddCustomAttribute("uber duration bonus", -6, -1)
		EntFireByHandle(activator, "RunScriptCode", "heartbeaterCallbacks.drainShieldIfActive()", -1, activator, null)
		if(!bossIsBuffed) return
		activator.AddCustomAttribute("move speed penalty", 0.7, -1)
		activator.AddCustomAttribute("halloween increased jump height", 0.5, -1)
	}

	drainShieldIfActive = function() {
		activator.GetScriptScope().drainShieldThink <- function() {
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				delete thinkTable.drainShieldThink
				return
			}
			if(timeCounter < DEFAULTTIME) {
				return
			}

			if(self.IsRageDraining()) {
				local rageMeter = NetProps.GetPropFloat(self, "m_Shared.m_flRageMeter")
				//printl("Rage: " + rageMeter)
				local newRageMeter = rageMeter - 2 > 0 ? rageMeter - 2 : 0;
				NetProps.SetPropFloat(self, "m_Shared.m_flRageMeter", newRageMeter)
			}
		}
		activator.GetScriptScope().thinkTable.drainShieldThink <- activator.GetScriptScope().drainShieldThink
	}

	buffBoss = function() {
		//Flag to apply debuffs when players respawn
		bossIsBuffed = true
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if(player == null) continue
			if(!IsPlayerABot(player)) {
				//Boss rage debuffs are applied here too
				if(player.GetTeam() == TF_TEAM_RED) {
					EntFireByHandle(player, "RunScriptCode", "heartbeaterCallbacks.NerfPlayerUberShield()", -1, player, null)
				}
				continue
			}
			if(!player.HasBotTag("heartbeater")) continue

			EmitSoundEx({
				sound_name = "vo/mvm/mght/soldier_mvm_m_laughlong01.mp3"
				speaker_entity = player
			})

			DispatchParticleEffect("cardiac_arrest_timer", player.GetCenter() + Vector(0,0,128), Vector())
			
			//player.AddCondEx(TF_COND_CRITBOOSTED_USER_BUFF, -1, null)
			player.AddCondEx(TF_COND_SODAPOPPER_HYPE, -1, null)
			player.AddCustomAttribute("fire rate penalty", 0.4, -1)
			player.AddCustomAttribute("move speed penalty", 3, -1)
			player.AddCustomAttribute("damage penalty", 10, -1)
			player.AddCustomAttribute("dmg taken increased", 1.75, -1)
			player.GetScriptScope().rageParticle.AcceptInput("StartTouch", "!activator", player, player)
			EntFire("wakeup_shake*", "StartShake")
			break
		}
	}
}
__CollectGameEventCallbacks(heartbeaterCallbacks)
for (local i = 1; i <= MaxPlayers ; i++) {
	local player = PlayerInstanceFromIndex(i)
	if(player == null) continue
	if(IsPlayerABot(player)) continue
	if(player.GetTeam() != TF_TEAM_RED) continue
	
	local maxMoveSpeed = player.GetCustomAttribute("move speed bonus", 1)
	if(maxMoveSpeed > playerMaxMoveSpeed) playerMaxMoveSpeed = maxMoveSpeed
	player.AcceptInput("RunScriptCode", "heartbeaterCallbacks.NerfPlayerUberShield()", player, null)
	player.AcceptInput("SetFogController", "heartbeater_fog", null, null)
}