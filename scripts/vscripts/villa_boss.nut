thinkTable <- {}

randomNames <- ["Unrecalled King of Ghost Robots", "Saturday", "King of Robot Ghosts", "Total Organ Failure", "R.E.G.R.E.T.", "Day 49"]

unusualParticle <- SpawnEntityFromTable("info_particle_system", {
	targetname = "boss_halo_particle"
	effect_name = "boss_halo"
})

unusualParticle.AcceptInput("SetParent", "!activator", self, null)
unusualParticle.AcceptInput("SetParentAttachment", "head", null, null)
EntFireByHandle(unusualParticle, "Start", null, 1, null, null)

sarcomaMimicParticle <- SpawnEntityFromTable("info_particle_system", {
	targetname = "boss_sarcoma_mimic_particle"
	effect_name = "sarcoma_chargeparticle"
	start_active = false
})

sarcomaMimicParticle.AcceptInput("SetParent", "!activator", self, self)
sarcomaMimicParticle.AcceptInput("SetParentAttachment", "flag", null, null)

local objRes = Entities.FindByClassname(null, "tf_objective_resource")

//==MIMIC ORDER==
//Hemorrhagic Fever
//Dyspnea
//Malignant Tumor
//Cardiomyopathy
//Tachycardia
//Sarcoma
//Pneumonia
//Cardiac Arrest

HEMORRHAGIC_FEVER <- 0
DYSPNEA <- 1
MALIGNANT_TUMOR <- 2
CARDIOMYOPATHY <- 3
TACHYCARDIA <- 4
SARCOMA <- 5
PNEUMONIA <- 6
CARDIAC_ARREST <- 7
FINAL_ATTACK <- 8

WAVEBAR_SLOT_NO <- 0

mainPhase <- 1
currentFinalePhase <- HEMORRHAGIC_FEVER
readyToChangePhase <- true
phaseTimer <- 0
pausePhaseTimerActions <- false
spinAngle <- 0
deadTumorCounter <- 0
lastPosition <- Vector(0, 0, 0)
damageTakenThisPhase <- 0
currentWeapon <- null
stickyList <- []
isExploding <- false

//Prep cardiac arrest particles
caParticle <- SpawnEntityFromTable("trigger_particle", {
	particle_name = "cardiac_arrest_buffed"
	attachment_type = 1
	spawnflags = 64
})

//Prep tachycardia particles
taParticle <- SpawnEntityFromTable("trigger_particle", {
	particle_name = "ukgr_tachycardia_intro"
	attachment_type = 1
	spawnflags = 64
})

teleportParticle <- SpawnEntityFromTable("info_particle_system", {
	effect_name = "ukgr_teleport_spellwheel"
	start_active = false
})

playerPush <- SpawnEntityFromTable("trigger_push", {
	origin = self.GetCenter()
	pushdir = QAngle(0, 0, 0)
	speed = 125
	startdisabled = true
	spawnflags = 1
	filtername = "team_red"
})
playerPush.SetSolid(2)
playerPush.SetSize(Vector(-100, -100, -104), Vector(100, 100, 104))
playerPush.AcceptInput("SetParent", "!activator", self, self)

hemorrhagicFeverAttrs <- {
	"damage penalty": 5,
	"move speed bonus": 1.25
}

dyspneaAttrs <- { //json syntax because string literals get weird
	"damage bonus": 0.3,
	"fire rate bonus": 0.1,
	"projectile spread angle penalty": 60,
	"faster reload rate": -1,
	"projectile speed increased": 0.6,
	"move speed bonus": 1.1,

	"mod projectile heat seek power": 360,
	"mod projectile heat aim error": 360,
	"mod projectile heat aim time": 0.6,
	"mod projectile heat no predict target speed": 1,

	"add cond on hit": 12,
	"add cond on hit duration": 4
}

cardiomyopathyAttrs <- {
	"damage bonus": 1,
	"fire rate bonus": 0.05,
	"projectile spread angle penalty": 10,
	"clip size upgrade atomic": 16,
	"move speed bonus": 1.1,
	"faster reload rate": 0.075
}

tachycardiaAttrs <- {
	"damage bonus": 4.5,
	"move speed bonus": 1.3,
	"fire rate bonus": 1.5
}

buffSarcomaAttrs <- {
	"damage bonus": 7,
	"projectile spread angle penalty": 50,
	"fire rate bonus": 0.06,
	"mult projectile count": 3,
	"faster reload rate": -0.8,
	"clip size bonus": 4
	"move speed bonus": 0.01
}

pneumoniaAttrs <- {
	"damage bonus": 1.5,
	"move speed bonus": 1.1,
	"projectile spread angle penalty": 45,
	"fire rate bonus": 0.01,
	"faster reload rate": 30,
	"stickybomb charge rate": 0.001,
	"projectile range increased": 2,
	"sticky arm time penalty": 0.7
}

cardiacAttrs <- {
	"fire rate bonus": 0.12,
	"faster reload rate": -0.8,
	"damage bonus": 4
}

finalAttackAttrs <- {
	"override projectile type": 2,
	"fire rate bonus": 0.1,
	"clip size bonus": 2.25,
	"damage bonus": 8,
	"faster reload rate": 0.2,
	"mult projectile scale": 3,
	"projectile speed increased": 0.6
}

//START OF PHASE 1 STUFF
::ukgr <- self
NetProps.SetPropString(self, "m_iName", "ukgr") //needed for particle nonsense
MAXSUPPORT <- 17
MOVESPEEDBASE <- 0.5
HEALTHBONUS <- 100
playersEaten <- 0
medigun <- null
amputator <- null
deadSupport <- 0
isBuffedFromEating <- false
support <- []
supportTimer <- Timer()
for(local i = 0; i < NetProps.GetPropArraySize(self, "m_hMyWeapons"); i++) {
	local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
	if(wep == null) continue

	if(wep.GetClassname() == "tf_weapon_medigun") {
		medigun = wep;
	}
	else if(wep.GetClassname() == "tf_weapon_bonesaw") {
		amputator = wep;
	}
}

startPhase1 <-  function() {
	for(local i = 1; i <= MaxPlayers; i++) {
		local player = PlayerInstanceFromIndex(i)
		if(player == null) continue
		if(!IsPlayerABot(player)) continue
		if(NetProps.GetPropInt(player, "m_lifeState") != LIFE_ALIVE) continue
		if(!player.HasBotTag("gmedsupport")) continue

		support.append(player)
	}
}

phase1skinBuffThink <- function() {
	if(self.InCond(TF_COND_HALLOWEEN_SPEED_BOOST) && !isBuffedFromEating) {
		isBuffedFromEating = true
		// self.SetSkin(0)
		self.UpdateSkin(4)
		playEmitSoundEx("vo/mvm/norm/medic_mvm_laughevil03.mp3")
	}
	else if(!(self.InCond(TF_COND_HALLOWEEN_SPEED_BOOST)) && isBuffedFromEating) {
		isBuffedFromEating = false
		// self.SetSkin(1)
		playEmitSoundEx("vo/mvm/norm/medic_mvm_negativevocalization05.mp3")
		self.UpdateSkin(3)
	}
}

offensiveThink <- function() {
	if(deadSupport >= MAXSUPPORT && supportTimer.Expired()) {
		local spawnbot = Entities.FindByName(null,  "spawnbot_arena2")
		foreach(supporter in support) {
			supporter.SetAbsOrigin(spawnbot.GetOrigin())
		}
		deadSupport = 0
	}

	if(self.GetHealth() < self.GetMaxHealth() && deadSupport < MAXSUPPORT) {
		EntFire("pop_interface", "ChangeBotAttributes", "EatBots", -1) //delay to let support walk out
		playEmitSoundEx("vo/mvm/norm/medic_mvm_negativevocalization06.mp3")
		delete thinkTable.offensiveThink
		thinkTable.defensiveThink <- defensiveThink
	}
}

defensiveThink <- function() {
	if(deadSupport >= MAXSUPPORT) {
		EntFire("pop_interface", "ChangeBotAttributes", "ShootPlayers", -1)
		supportTimer.Start(15)
		playEmitSoundEx("vo/mvm/norm/medic_mvm_battlecry01.mp3")
		delete thinkTable.defensiveThink
		thinkTable.offensiveThink <- offensiveThink
		return
	}

	local target = self.GetHealTarget()
	if(target != null) {
		target.TakeDamageCustom(self, self, null, Vector(0, 0, 1), target.GetCenter(),
			6, DMG_BLAST, TF_DMG_CUSTOM_MERASMUS_ZAP); //kills in approx half a second
	}
}

strengthen <- function() {
	playersEaten++
	self.SetHealth(self.GetHealth() + HEALTHBONUS)
	self.AddCustomAttribute("damage bonus", 1 + 0.25 * playersEaten, -1)
	self.AddCustomAttribute("move speed bonus", MOVESPEEDBASE + 0.1 * playersEaten, -1)
	self.AddCondEx(TF_COND_OFFENSEBUFF, 1 * playersEaten, null)
	self.AddCondEx(TF_COND_HALLOWEEN_SPEED_BOOST, 1 * playersEaten, null)
	local particle = SpawnEntityFromTable("info_particle_system", {
		origin = self.GetOrigin()
		effect_name = "soldierbuff_blue_buffed"
		start_active = true
	})
	particle.AcceptInput("SetParent", "ukgr", null, null)
	EntFireByHandle(particle, "Kill", null, 0.3, null, null)
}

::phase1Callbacks <- {
	OnGameEvent_player_death = function(params) {
		local victim = GetPlayerFromUserID(params.userid)
		local inflictor = EntIndexToHScript(params.inflictor_entindex)
		local isKillerUKGR = inflictor == ukgr ? true : false
		if(IsPlayerABot(victim)) {
			if(victim.HasBotTag("gmedsupport")) {
				ukgr.GetScriptScope().deadSupport++
				//printl("team " + victim.GetTeam())
				victim.ValidateScriptScope()
				EntFireByHandle(victim, "runscriptcode", "self.ForceChangeTeam(TF_TEAM_BLUE, true)", -1, null, null)
				EntFireByHandle(victim, "runscriptcode", "self.ForceRespawn()", -1, null, null)
				EntFireByHandle(victim, "runscriptcode", "self.AddBotTag(\"gmedsupport\")", -1, null, null)

				if(isKillerUKGR) {
					DispatchParticleEffect("rd_robot_explosion", victim.GetOrigin(), Vector())

					EmitSoundEx({
						sound_name = "ambient/grinder/grinderbot_03.wav",
						channel = 6,
						origin = victim.GetCenter(),
						filter_type = RECIPIENT_FILTER_PAS
					})
					ukgr.AcceptInput("CallScriptFunction", "strengthen", null, null)
				}

			}
		}
		else {
			if(isKillerUKGR) {
				ukgr.AcceptInput("CallScriptFunction", "strengthen", null, null)
			}
		}
	}
	OnScriptHook_OnTakeDamage = function(params) {
		local victim = params.const_entity
		local inflictor = params.inflictor
		if(!IsPlayerABot(victim)) return
		if(IsPlayerABot(victim) && !victim.HasBotTag("gmedsupport")) return
		if(inflictor == null || !IsPlayerABot(inflictor)) return
		params.force_friendly_fire = true
	}
}

setIcon <- function(icon) {
	NetProps.SetPropStringArray(objRes, "m_iszMannVsMachineWaveClassNames", icon, WAVEBAR_SLOT_NO)
	NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", icon)
}

//START OF PHASE 3 STUFF
changePhase <- function() {
	phaseTimer = 0
	pausePhaseTimerActions = false
	damageTakenThisPhase = 0
	DispatchParticleEffect("ukgr_phase_change_flames", self.GetCenter(), Vector())
	playEmitSoundEx("misc/halloween/spell_fireball_impact.wav")
	switch(currentFinalePhase) {
		case HEMORRHAGIC_FEVER:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_laughevil05.mp3")
			setIcon("ukgr_fever")
			self.AddWeaponRestriction(PRIMARY_ONLY)
			self.RemoveWeaponRestriction(MELEE_ONLY)
			self.AddBotAttribute(ALWAYS_FIRE_WEAPON) //Carries over to Dyspnea phase! Removed by the think later

			foreach(attr, val in cardiacAttrs) { //Reset stat changes from Cardiac Arrest mimic
				self.RemoveCustomAttribute(attr)
			}
			foreach(attr, val in hemorrhagicFeverAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			::CustomWeapons.GiveItem("Upgradeable TF_WEAPON_FLAMETHROWER", self)

			self.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
			caParticle.AcceptInput("EndTouch", "!self", self, self)
			break
		case DYSPNEA:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_negativevocalization01.mp3")
			setIcon("ukgr_dyspnea")
			foreach(attr, val in hemorrhagicFeverAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			foreach(attr, val in dyspneaAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			::CustomWeapons.GiveItem("Upgradeable TF_WEAPON_ROCKETLAUNCHER", self)
			break
		case MALIGNANT_TUMOR:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_specialcompleted05.mp3")
			setIcon("ukgr_tumor")
			::CustomWeapons.GiveItem("The Crusader's Crossbow", self)
			foreach(attr, val in dyspneaAttrs) {
				self.RemoveCustomAttribute(attr)
			}

			self.RemoveBotAttribute(SUPPRESS_FIRE)

			deadTumorCounter = 0
			//Teleports offscreen and then 20 mini versions spawn
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if(player == null) continue
				if(!IsPlayerABot(player)) continue
				if(!player.HasBotTag("UKGR_Tumor")) continue
				player.Teleport(true, lastPosition, false, QAngle(), false, Vector())
			}
			self.Teleport(true, Vector(-2600, -871, 1493), false, QAngle(), false, Vector()) //Teleports to spawnbot_altmode
			teleportParticle.SetOrigin(lastPosition)
			teleportParticle.AcceptInput("Start", null, null, null)
			break
		case CARDIOMYOPATHY:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_specialcompleted07.mp3")
			setIcon("ukgr_burstdemo")
			::CustomWeapons.GiveItem("The Iron Bomber", self)
			self.AddBotAttribute(HOLD_FIRE_UNTIL_FULL_RELOAD)
			foreach(attr, val in cardiomyopathyAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			break
		case TACHYCARDIA:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_laughhappy02.mp3")
			setIcon("ukgr_tachycardia")
			foreach(attr, val in cardiomyopathyAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			foreach(attr, val in tachycardiaAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			self.RemoveBotAttribute(HOLD_FIRE_UNTIL_FULL_RELOAD)
			self.AddWeaponRestriction(MELEE_ONLY)

			taParticle.AcceptInput("StartTouch", "!self", self, self)
			EntFireByHandle(taParticle, "EndTouch", "!self", 2, self, self)
			EntFireByHandle(self, "DispatchEffect", "ParticleEffectStop", 2, self, self)

			//Taunts to forcefully apply Tachycardia debuff on everyone
			//Debuff function below
			
			self.Weapon_Switch(amputator)
			EntFireByHandle(self, "RunScriptCode", "self.Taunt(TAUNT_BASE_WEAPON, 11)", 0.1, null, null)
			break
		case SARCOMA:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_negativevocalization04.mp3")
			setIcon("ukgr_sarcoma")
			foreach(attr, val in tachycardiaAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			//He's giving back your damn legs
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if(player == null) continue
				if(IsPlayerABot(player)) continue
				if(player.GetTeam() != 2) continue
				player.RemoveCustomAttribute("SET BONUS: move speed set bonus")
			}
			//Oh no I'm unarmed!
			self.ClearAllWeaponRestrictions()
			self.AddWeaponRestriction(SECONDARY_ONLY)
			self.SetScaleOverride(0.8)
			::CustomWeapons.GiveItem("The Quick-Fix", self)
			self.AddCustomAttribute("move speed bonus", 2, -1)
			break
		case PNEUMONIA:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_battlecry03.mp3")
			foreach(attr, val in buffSarcomaAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			setIcon("pneumonia_bp")
			self.SetScaleOverride(1.9)
			self.RemoveCond(33)
			self.RemoveWeaponRestriction(PRIMARY_ONLY)
			self.AddWeaponRestriction(SECONDARY_ONLY)
			self.AddBotAttribute(ALWAYS_FIRE_WEAPON)
			foreach(attr, val in pneumoniaAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			diseaseCallbacks.pneumoniaBot = self
			stickyList = [] //wipe the old list
			currentWeapon = ::CustomWeapons.GiveItem("Upgradeable TF_WEAPON_PIPEBOMBLAUNCHER", self)
			break
		case CARDIAC_ARREST:
			playEmitSoundEx("vo/mvm/norm/medic_mvm_jeers06.mp3")
			setIcon("ukgr_cardiac")
			self.AddWeaponRestriction(PRIMARY_ONLY)
			self.RemoveBotAttribute(SUPPRESS_FIRE)
			self.AddCondEx(71, 6, null)

			EntFire("heartbeat2", "PlaySound")

			foreach(attr, val in pneumoniaAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			foreach(attr, val in cardiacAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}

			self.AddCondEx(TF_COND_SODAPOPPER_HYPE, 11, null)
			::CustomWeapons.GiveItem("The Direct Hit", self)

			caParticle.AcceptInput("StartTouch", "!self", self, self)

			break
		case FINAL_ATTACK:
			setIcon("ukgr_base")
			//TODO: Remove all attributes here
			foreach(attr, val in allAttrs) {
				self.RemoveCustomAttribute(attr)
			}
			foreach(attr, val in finalAttackAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			self.SetScaleOverride(1.9)
			self.UpdateSkin(3)
			//TODO: Activate antistuck here
			//TODO: Also push players back anyways
			self.RemoveBotAttribute(ALWAYS_FIRE_WEAPON)
			self.AddBotAttribute(SUPPRESS_FIRE) //Removed after 2s to ensure Dyspnea rockets are all gone
			self.AddBotAttribute(HOLD_FIRE_UNTIL_FULL_RELOAD)
			//This one is temporary, so it's separated
			self.AddCustomAttribute("dmg taken increased", 0.1, 2.5)

			::CustomWeapons.GiveItem("The Crusader's Crossbow", self)
			break
		default:
			break;
	}
	readyToChangePhase = false
}

finaleThink <- function() {
	if(!isExploding) phaseTimer++

	if(readyToChangePhase) changePhase()

	if(currentFinalePhase == HEMORRHAGIC_FEVER) {
		local currentEyeAngles = self.EyeAngles()
		spinAngle = spinAngle + 12
		self.SnapEyeAngles(QAngle(currentEyeAngles.x, spinAngle, currentEyeAngles.z))
		if(phaseTimer > 530) {
			readyToChangePhase = true
			currentFinalePhase = DYSPNEA
		}
	}
	else if(currentFinalePhase == DYSPNEA) {
		if(phaseTimer > 275 && !pausePhaseTimerActions) {
			self.AddBotAttribute(SUPPRESS_FIRE)
			self.RemoveBotAttribute(ALWAYS_FIRE_WEAPON)
			pausePhaseTimerActions = true
		}

		else if (phaseTimer == 460) { //enables spawnbot_altmode for tumors
			local spawnbot = Entities.FindByName(null, "spawnbot_altmode")
			spawnbot.AcceptInput("enable", null, null, null)
			EntFireByHandle(spawnbot, "Disable", null, 0.5, null, null)
		}

		else if (phaseTimer == 539) {
			lastPosition = self.GetOrigin()
			//ClientPrint(null, 3, "Last position set! " + lastPosition.x + " " + lastPosition.y + " " + lastPosition.z)
		}

		else if(phaseTimer > 540) {
			readyToChangePhase = true
			currentFinalePhase = MALIGNANT_TUMOR
		}
	}
	else if(currentFinalePhase == MALIGNANT_TUMOR && (deadTumorCounter >= 15 || phaseTimer > 1000)) {
		readyToChangePhase = true
		self.Teleport(true, lastPosition, false, QAngle(), false, Vector())
		teleportParticle.AcceptInput("Stop", null, null, null)
		//It's set to 0 twice but yknow just to be safe
		deadTumorCounter = 0
		currentFinalePhase = CARDIOMYOPATHY
	}
	else if(currentFinalePhase == CARDIOMYOPATHY && phaseTimer > 666) {
		readyToChangePhase = true
		currentFinalePhase = TACHYCARDIA
	}
	else if(currentFinalePhase == TACHYCARDIA) {
		if(phaseTimer > 133 && !pausePhaseTimerActions) {
			for (local i = 1; i <= MaxPlayers ; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if(player == null) continue
				if(IsPlayerABot(player)) continue
				//He's taking your damn legs
				player.AddCustomAttribute("SET BONUS: move speed set bonus", 0.5, -1)
				player.AddCondEx(65, 18, null)
			}
			pausePhaseTimerActions = true
		}
		if(phaseTimer > 1333) {
			readyToChangePhase = true
			currentFinalePhase = SARCOMA
		}
	}
	else if(currentFinalePhase == SARCOMA) {
		if(phaseTimer == 200) {
			EntFireByHandle(sarcomaMimicParticle, "Start", null, -1, null, null)
			EmitSoundEx({
				sound_name = "ambient/levels/labs/teleport_mechanism_windup1.wav",
				channel = 6,
				origin = self.GetCenter(),
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
		}

		if(phaseTimer > 400 && !pausePhaseTimerActions) {
			EntFireByHandle(sarcomaMimicParticle, "Stop", null, -1, null, null)
			self.RemoveWeaponRestriction(SECONDARY_ONLY)
			self.AddWeaponRestriction(PRIMARY_ONLY)
			::CustomWeapons.GiveItem("Upgradeable TF_WEAPON_SYRINGEGUN_MEDIC", self)
			self.AddCondEx(33, 5, null)
			foreach(attr, val in buffSarcomaAttrs) {
				self.AddCustomAttribute(attr, val, -1)
			}
			self.SetScaleOverride(2.5)
			pausePhaseTimerActions = true
			EntFire("sarcoma_evolution_sound",  "PlaySound")
			EntFire("sarcoma_evolution_shake", "StartShake")
			DispatchParticleEffect("sarcoma_explode", self.GetOrigin(), Vector())
		}
		else if(phaseTimer > 733) {
			readyToChangePhase = true
			//ClientPrint(null, 3, "Switching to Pneumonia!")
			currentFinalePhase = PNEUMONIA
		}
	}
	else if(currentFinalePhase == PNEUMONIA) {
		if(!pausePhaseTimerActions) {
			if((Time() - NetProps.GetPropFloat(currentWeapon, "m_flNextPrimaryAttack")) <= 1) {
				local sticky = null;
				while(sticky = Entities.FindByClassname(sticky, "tf_projectile_pipe_remote")) {
					if(stickyList.find(sticky) == null) {
						stickyList.append(sticky)
						sticky.SetModelSimple("models/villa/stickybomb_pneumonia.mdl")
					}
				}
			}
		}

		if(phaseTimer == 67) { //1s
			foreach(sticky in stickyList) {
				if(sticky.IsValid()) {
					DispatchParticleEffect("pneumonia_stickybomb_aura", sticky.GetCenter(), Vector())
				}
			}
			self.RemoveBotAttribute(ALWAYS_FIRE_WEAPON)
			self.AddBotAttribute(SUPPRESS_FIRE)
			pausePhaseTimerActions = true //stop collecting stickies
		}

		if(phaseTimer == 167) { //approx 2.5s
			if(!pneumoniaSpawner.IsValid()) return //mostly for wave reset
			foreach(sticky in stickyList) {
				if(sticky.IsValid()) { //in case they get det
					pneumoniaSpawner.SpawnEntityAtLocation(sticky.GetOrigin() + Vector(0, 0, 0), Vector())
				}
			}
			self.RemoveBotAttribute(SUPPRESS_FIRE)
			self.PressAltFireButton(0.1)
		}

		if(phaseTimer > 367) {
			readyToChangePhase = true
			currentFinalePhase = CARDIAC_ARREST
		}
	}
	//It all loops back
	else if(currentFinalePhase == CARDIAC_ARREST) {

		if(phaseTimer == 400) {
			EntFire("wakeup_sound*", "PlaySound")
			EntFire("wakeup_shake*", "StartShake")
		}

		else if(phaseTimer > 734) {
			readyToChangePhase = true
			currentFinalePhase = HEMORRHAGIC_FEVER
		}
	}
	else if(currentFinalePhase == FINAL_ATTACK) {
		if(phaseTimer == 165) self.RemoveBotAttribute(SUPPRESS_FIRE)
		else if(phaseTimer > 165) {
			local finalRocket = null;
			while(finalRocket = Entities.FindByClassname(finalRocket, "tf_projectile_rocket")) {
				//TODO: Check for whether or not model is set and then add think
				//TODO: Change to crossbow model
				//TODO: Think creates a particle when explodes
				finalRocket.SetModelSimple("models/villa/stickybomb_pneumonia.mdl")
			}
		}
	}
}

cleanup <- function() {
	AddThinkToEnt(self, null)
	NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
	delete ::ukgr
	if("phase1Callbacks" in getroottable()) {
		delete ::phase1Callbacks
	}
	NetProps.SetPropString(self, "m_iName", null)
	local preserved = {
		"self" : null
		"__vname" : null
		"__vrefs" : null
	}
	local scope = self.GetScriptScope()
	foreach(key, val in scope) { //doesn't kill ents, but map reset gets them eventually
		if(!(key in preserved)) { //why can you delete self
			delete scope[key]
		}
	}
}

playEmitSoundEx <- function(soundName, dontRepeat=false) {
	EmitSoundEx({
		sound_name = soundName,
		channel = 6,
		origin = self.GetCenter(),
		filter_type = RECIPIENT_FILTER_GLOBAL
	})

	if(dontRepeat) return

	EmitSoundEx({
		sound_name = soundName,
		channel = 6,
		origin = self.GetCenter(),
		filter_type = RECIPIENT_FILTER_GLOBAL
	})
}

local randName = randomNames[RandomInt(0, randomNames.len() - 1)]
SetFakeClientConVarValue(self, "name", randName)
self.SetCustomModelWithClassAnimations("models/bots/forgotten/disease_bot_medic_ukgr.mdl")
self.AddCondEx((TF_COND_PREVENT_DEATH) , -1, null)
thinkTable.offensiveThink <- offensiveThink
thinkTable.phase1skinBuffThink <- phase1skinBuffThink
mainThink <- function() { //this is mostly to make the customweapons think works
	if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
		cleanup()
		return
	}

	if(self.GetLocomotionInterface().IsStuck()) {
		NetProps.SetPropVector(playerPush, "m_vecPushDir", Vector(0, self.EyeAngles().y, self.EyeAngles().z))
		EntFireByHandle(playerPush, "Enable", null, -1, null, null)
		EntFireByHandle(playerPush, "Disable", null, 0.5, null, null)
	}

	foreach(name, func in thinkTable) {
		func()
	}
	return -1
}
__CollectGameEventCallbacks(phase1Callbacks)
AddThinkToEnt(self, "mainThink")