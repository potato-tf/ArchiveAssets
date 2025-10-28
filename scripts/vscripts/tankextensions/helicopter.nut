local HELICOPTER_VALUES_TABLE = {
	HELICOPTER_MODEL        = "models/bots/boss_helicopter/boss_helicopter.mdl"
	HELICOPTER_SOUND_ENGINE = "^npc/attack_helicopter/aheli_rotor_loop1.wav"
	HELICOPTER_MAX_RANGE    = 2000

	HELICOPTER_ROCKET_SND_FIRE        = "MVM.GiantSoldierRocketShoot"
	HELICOPTER_ROCKET_SND_FIRE_CRIT   = "MVM.GiantSoldierRocketShootCrit"
	HELICOPTER_ROCKET_SPLASH          = 146
	HELICOPTER_ROCKET_SPEED           = 600
	HELICOPTER_ROCKET_DAMAGE          = 75
	HELICOPTER_ROCKET_MODEL           = "models/weapons/w_models/w_rocket.mdl"
	HELICOPTER_ROCKET_HOMING_POWER    = 0.06
	HELICOPTER_ROCKET_HOMING_DURATION = 0.75
	HELICOPTER_ROCKET_COOLDOWN        = 0.8
	HELICOPTER_ROCKET_PARTICLE_TRAIL  = "rockettrail"

	HELICOPTER_STICKY_SND_FIRE       = ")weapons/stickybomblauncher_shoot.wav"
	HELICOPTER_STICKY_SND_FIRE_CRIT  = ")weapons/stickybomblauncher_shoot_crit.wav"
	HELICOPTER_STICKY_MODEL          = "models/weapons/w_models/w_stickybomb_d.mdl"
	HELICOPTER_STICKY_SPREAD         = 35
	HELICOPTER_STICKY_SPLASH_RADIUS  = 189
	HELICOPTER_STICKY_SPEED_MIN      = 100
	HELICOPTER_STICKY_SPEED_MAX      = 1000
	HELICOPTER_STICKY_DAMAGE         = 100
	HELICOPTER_STICKY_COOLDOWN       = 15
	HELICOPTER_STICKY_SHOT_AMOUNT    = 12
	HELICOPTER_STICKY_DETONATE_DELAY = 5
}
foreach(k,v in HELICOPTER_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(HELICOPTER_MODEL)
PrecacheModel(HELICOPTER_ROCKET_MODEL)
PrecacheModel(HELICOPTER_STICKY_MODEL)
TankExt.PrecacheSound(HELICOPTER_SOUND_ENGINE)
TankExt.PrecacheSound(HELICOPTER_ROCKET_SND_FIRE)
TankExt.PrecacheSound(HELICOPTER_ROCKET_SND_FIRE_CRIT)
TankExt.PrecacheSound(HELICOPTER_STICKY_SND_FIRE)
TankExt.PrecacheSound(HELICOPTER_STICKY_SND_FIRE_CRIT)

PrecacheScriptSound("SawMill.BladeImpact")
PrecacheSound("weapons/dumpster_rocket_reload.wav")
PrecacheSound("doors/door_metal_large_open1.wav")
PrecacheSound("physics/metal/metal_solid_strain4.wav")
PrecacheSound("physics/metal/metal_box_strain2.wav")
PrecacheSound("physics/metal/metal_box_impact_soft3.wav")
PrecacheSound("physics/metal/metal_grate_impact_soft3.wav")
PrecacheSound("doors/door_squeek1.wav")
PrecacheSound("items/ammocrate_close.wav")

TankExt.NewTankType("helicopter*", {
	DisableChildModels = 1
	DisableSmokestack  = 1
	NoScreenShake      = 1
	EngineLoopSound    = "misc/null.wav"
	PingSound          = "misc/null.wav"
	NoDestructionModel = 1
	NoGravity          = 1
	Model              = {
		Visual = "models/empty.mdl"
	}
	function OnSpawn()
	{
		EmitSoundEx({
			sound_name  = HELICOPTER_SOUND_ENGINE
			channel     = CHAN_STATIC
			sound_level = 150
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		local bParticles = sTankName.find("_customparticles") ? true : false
		local bCrit      = sTankName.find("_crit") ? true : false
		local bBlueTeam  = self.GetTeam() == TF_TEAM_BLUE
		local bFinalSkin = self.GetSkin() == 1

		local hModel = CreateByClassnameSafe("funCBaseFlex")
		hModel.SetModel(HELICOPTER_MODEL)
		hModel.SetPlaybackRate(1.0)
		hModel.SetTeam(bBlueTeam ? TF_TEAM_BLUE : TF_TEAM_RED)
		hModel.DispatchSpawn()
		hModel.SetSkin(bFinalSkin ? 4 : 0)
		hModel.SetSequence(hModel.LookupSequence("takeoff"))
		TankExt.SetParentArray([hModel], self)

		local sParams = split(sTankName, "|")
		if(sParams.len() >= 2)
		{
			SetPropInt(hModel, "m_iTextureFrameIndex", 2)
			hModel.AcceptInput("Color", sParams[1], null, null)
		}

		local hMimicRocket = SpawnEntityFromTableSafe("tf_point_weapon_mimic", {
			damage        = HELICOPTER_ROCKET_DAMAGE
			modeloverride = HELICOPTER_ROCKET_MODEL
			modelscale    = 1
			speedmin      = HELICOPTER_ROCKET_SPEED
			speedmax      = HELICOPTER_ROCKET_SPEED
			splashradius  = HELICOPTER_ROCKET_SPLASH
			weapontype    = 0
		})
		local StickyKeyValues = {
			damage        = HELICOPTER_STICKY_DAMAGE
			modeloverride = HELICOPTER_STICKY_MODEL
			modelscale    = 1
			speedmin      = HELICOPTER_STICKY_SPEED_MIN
			speedmax      = HELICOPTER_STICKY_SPEED_MAX
			splashradius  = HELICOPTER_STICKY_SPLASH_RADIUS
			spreadangle   = HELICOPTER_STICKY_SPREAD
			weapontype    = 3
		}
		local hMimicSticky1 = SpawnEntityFromTableSafe("tf_point_weapon_mimic", StickyKeyValues)
		local hMimicSticky2 = SpawnEntityFromTableSafe("tf_point_weapon_mimic", StickyKeyValues)

		local hHurt = SpawnEntityFromTableSafe("trigger_multiple", {
			origin        = "-16 0 184"
			startdisabled = 1
			spawnflags    = 1
		})
		hHurt.SetSize(Vector(-224, -224, -8), Vector(224, 224, 8))
		hHurt.SetSolid(SOLID_BBOX)
		hHurt.KeyValueFromString("classname", "helicopter")
		TankExt.SetParentArray([hMimicSticky1], hModel, "muzzle_l")
		TankExt.SetParentArray([hMimicSticky2], hModel, "muzzle_r")
		TankExt.SetParentArray([hMimicRocket], hModel, "muzzle_mid")
		TankExt.SetParentArray([hHurt], hModel)

		hHurt.ValidateScriptScope()
		local hTank = self
		hHurt.GetScriptScope().StartTouch <- function()
		{
			local hGameRules = FindByClassname(null, "tf_gamerules")
			SetPropBool(hGameRules, "m_bPlayingMannVsMachine", false)
			activator.TakeDamageEx(self, hTank, null, Vector(), Vector(), 1000, DMG_CRUSH | DMG_BLAST)
			SetPropBool(hGameRules, "m_bPlayingMannVsMachine", true)
			self.EmitSound("SawMill.BladeImpact")
		}
		hHurt.ConnectOutput("OnStartTouch", "StartTouch")

		local flSpeed = GetPropFloat(self, "m_speed")
		SetPropFloat(self, "m_speed", 0.0)

		local hTank_scope = self.GetScriptScope()
		hTank_scope.bNoGravity = false

		local vecOrigin = self.GetOrigin()
		local Trace = {
			start  = vecOrigin
			end    = vecOrigin + Vector(0, 0, -8192)
			mask   = CONTENTS_SOLID
			ignore = self
		}
		TraceLineEx(Trace)
		self.SetAbsOrigin(Trace.endpos)

		local flTimeToLaunch = Time() + 4.23
		local flTimeToActive = Time() + 5.83
		local bLaunched      = false
		local bActive        = false

		local vecOriginLast = self.GetOrigin()
		local angCurrent    = QAngle()
		local angGoal       = QAngle()
		local flYawCurrent  = 0.0

		local flTimeRocket = 0
		local flTimeSticky = 0
		hStickies <- []

		local hParticle
		if(bParticles)
		{
			TankExt.DelayFunction(self, this, 1, function()
			{
				hParticle = SpawnEntityFromTableSafe("info_particle_system", {
					origin       = Trace.endpos
					effect_name  = "mvm_helicopter_floor_wind_dust_parent"
					start_active = 1
				})
			})
			TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_exhaust_parent", "exhaust_l")
			TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_exhaust_parent", "exhaust_r")
		}

		local vecBombLast     = Vector()
		local iBombAttachment = hModel.LookupAttachment("bomb_pos")
		local bFoundWorld     = false

		local sModelLast     = "models/bots/boss_bot/boss_tank.mdl"
		local iDamageBody    = hModel.FindBodygroupByName("damage")
		local iRotorMainPose = hModel.LookupPoseParameter("rotor_spin_main")
		local iRotorTailPose = hModel.LookupPoseParameter("rotor_spin_tail")
		local iRotorMainDeg  = 0
		local iRotorTailDeg  = 0
		function Think()
		{
			hModel.StudioFrameAdvance()

			local sModel = self.GetModelName()
			if(sModel != sModelLast)
			{
				sModelLast = sModel
				if(sModel == "models/bots/boss_bot/boss_tank.mdl")
				{
					hModel.SetBodygroup(iDamageBody, 0)
					hModel.SetSkin(bFinalSkin ? 4 : 0)
				}
				else if(sModel == "models/bots/boss_bot/boss_tank_damage1.mdl")
				{
					hModel.SetBodygroup(iDamageBody, 1)
					hModel.SetSkin(bFinalSkin ? 5 : 1)
				}
				else if(sModel == "models/bots/boss_bot/boss_tank_damage2.mdl")
				{
					hModel.SetBodygroup(iDamageBody, 2)
					hModel.SetSkin(bFinalSkin ? 6 : 2)
				}
				else if(sModel == "models/bots/boss_bot/boss_tank_damage3.mdl")
				{
					hModel.SetBodygroup(iDamageBody, 3)
					hModel.SetSkin(bFinalSkin ? 7 : 3)
				}
			}

			if(!bActive)
			{
				local flLaunchPercent = (5.83 - flTimeToActive + flTime) / 5.83
				EmitSoundEx({
					sound_name  = HELICOPTER_SOUND_ENGINE
					sound_level = 150
					pitch       = 100 * flLaunchPercent
					channel     = CHAN_STATIC
					entity      = self
					filter_type = RECIPIENT_FILTER_GLOBAL
					flags       = SND_CHANGE_PITCH
				})

				if(!bLaunched && flTime >= flTimeToLaunch)
				{
					bLaunched = true
					hHurt.AcceptInput("Enable", null, null, null)
					SetPropFloat(self, "m_speed", flSpeed)
					hTank_scope.bNoGravity = true

					local angRotation = self.GetAbsAngles()
					angCurrent   = angRotation
					flYawCurrent = angRotation.y

					if(bParticles)
					{
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_wind_rings_parent", "rotor_main")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_wind_rings_back_parent", "rotor_tail")

						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_parent", "rotor_main_tip_0")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_parent", "rotor_main_tip_1")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_parent", "rotor_main_tip_2")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_parent", "rotor_main_tip_3")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_back_parent", "rotor_tail_tip_0")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_back_parent", "rotor_tail_tip_1")
						TankExt.DispatchParticleEffectOn(hModel, "mvm_helicopter_propeller_tips_back_parent", "rotor_tail_tip_2")
					}
				}
				if(flTime >= flTimeToActive)
				{
					bActive = true
					hModel.ResetSequence(hModel.LookupSequence("idle"))
					if(bParticles)
						hParticle.Kill()

					flTimeRocket = flTime + HELICOPTER_ROCKET_COOLDOWN
					flTimeSticky = flTime + HELICOPTER_STICKY_COOLDOWN
				}
			}

			if(bLaunched)
			{
				local vecOrigin     = self.GetOrigin()
				local vecVelocity   = (vecOrigin - vecOriginLast) * (1 / FrameTime())
				local flVelocitySqr = vecVelocity.Length2DSqr()
				if(flVelocitySqr != 0)
				{
					angGoal   = TankExt.VectorAngles(vecVelocity)
					angGoal.x = sqrt(flVelocitySqr) * 0.1
				}
				else angGoal.x = 0
				vecOriginLast = vecOrigin

				local flRotateSpeed = 0.6
				if(angCurrent.x != angGoal.x)
				{
					local iDir = angCurrent.x < angGoal.x ? 0.5 : -0.5
					angCurrent.x += flRotateSpeed * iDir

					if(iDir == 0.5 ? angCurrent.x > angGoal.x : angCurrent.x < angGoal.x)
						angCurrent.x = angGoal.x
				}
				local RotateYaw = function(YawCurrent, YawGoal)
				{
					local iDir = YawCurrent < YawGoal ? 1 : -1
					local bReversed = false
					if(fabs(YawGoal - YawCurrent) > 180)
					{
						iDir = -iDir
						bReversed = true
					}

					YawCurrent += flRotateSpeed * iDir

					if(iDir == 1 ? bReversed ? YawCurrent < YawGoal : YawCurrent > YawGoal : bReversed ? YawCurrent > YawGoal : YawCurrent < YawGoal)
						YawCurrent = YawGoal

					if(YawCurrent < 0)
						YawCurrent += 360
					else if(YawCurrent >= 360)
						YawCurrent -= 360

					return YawCurrent
				}

				if(angCurrent.y != angGoal.y) angCurrent.y = RotateYaw(angCurrent.y, angGoal.y)
				self.SetAbsAngles(angCurrent)

				local hTarget
				local vecTarget
				foreach(sClassname in [ "player", "obj_sentrygun", "obj_dispenser", "obj_teleporter", "tank_boss", "merasmus", "headless_hatman", "eyeball_boss", "tf_zombie" ])
				{
					for(local hEnt, flDist = HELICOPTER_MAX_RANGE; hEnt = FindByClassnameWithin(hEnt, sClassname, vecOrigin, flDist);)
					{
						local vecEntCenter = hEnt.GetCenter()
						local vecEntTrace  = "EyePosition" in hEnt ? hEnt.EyePosition() : vecEntCenter
						local bTrace       = TraceLine(vecEntTrace, vecOrigin, self) == 1
						if
						(
							bTrace &&
							hEnt.IsAlive() &&
							hEnt.GetTeam() != iTeamNum &&
							!(hEnt.GetFlags() & FL_NOTARGET) &&
							!TankExt.IsPlayerStealthedOrDisguised(hEnt)
						)
						{
							hTarget   = hEnt
							vecTarget = vecEntCenter
							flDist    = (vecEntCenter - vecOrigin).Length()
						}
					}
					if(hTarget) break
				}

				local flYawGoal = hTarget && (!bDeploying && bActive) ? TankExt.VectorAngles(vecTarget - vecOrigin).y : angCurrent.y
				if(flYawCurrent != flYawGoal) flYawCurrent = RotateYaw(flYawCurrent, flYawGoal)
				hModel.SetLocalAngles(QAngle(0, flYawCurrent - angCurrent.y, 0))

				if(bActive)
				{
					hModel.SetPoseParameter(iRotorMainPose, iRotorMainDeg += 15.75)
					hModel.SetPoseParameter(iRotorTailPose, iRotorTailDeg += 20.25)
					if(!bDeploying && hTarget)
					{
						if(flTime >= flTimeRocket)
						{
							flTimeRocket = flTime + HELICOPTER_ROCKET_COOLDOWN
							hMimicRocket.AcceptInput("FireOnce", null, null, null)
							EmitSoundEx({
								sound_name  = bCrit ? HELICOPTER_ROCKET_SND_FIRE_CRIT : HELICOPTER_ROCKET_SND_FIRE
								sound_level = 90
								entity      = self
								filter_type = RECIPIENT_FILTER_GLOBAL
							})

							for(local hRocket; hRocket = FindByClassnameWithin(hRocket, "tf_projectile_rocket", hMimicRocket.GetOrigin(), 1);)
								if(hRocket.GetOwner() == hMimicRocket)
								{
									MarkForPurge(hRocket)
									hRocket.SetSize(Vector(), Vector())
									hRocket.SetSolid(SOLID_BSP)
									hRocket.SetSequence(1)
									hRocket.SetSkin(iTeamNum == TF_TEAM_BLUE ? 1 : 0)
									hRocket.SetTeam(iTeamNum)
									hRocket.SetOwner(self)
									if(bCrit) SetPropBool(hRocket, "m_bCritical", true)

									hRocket.ValidateScriptScope()
									local hRocket_scope = hRocket.GetScriptScope()
									local bSolid = false
									local hTank = self
									hRocket_scope.RocketThink <- function()
									{
										if(!self.IsValid()) return
										local vecOrigin = self.GetOrigin()
										if(!bSolid && (!hTank.IsValid() || !TankExt.IntersectionBoxBox(vecOrigin, self.GetBoundingMins(), self.GetBoundingMaxs(), hTank.GetOrigin(), hTank.GetBoundingMins(), hTank.GetBoundingMaxs())))
											{ bSolid = true; self.SetSolid(SOLID_BBOX) }
										HomingThink()
										return -1
									}
									hRocket_scope.HomingParams <- {
										Target      = hTarget
										TurnPower   = HELICOPTER_ROCKET_HOMING_POWER
										AimTime     = HELICOPTER_ROCKET_HOMING_DURATION
										MaxAimError = -1
									}
									IncludeScript("tankextensions/misc/homingrocket", hRocket_scope)
									TankExt.AddThinkToEnt(hRocket, "RocketThink")

									if(HELICOPTER_ROCKET_PARTICLE_TRAIL != "rockettrail")
									{
										hRocket.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
										local hTrail = CreateByClassnameSafe("trigger_particle")
										hTrail.KeyValueFromString("particle_name", HELICOPTER_ROCKET_PARTICLE_TRAIL)
										hTrail.KeyValueFromString("attachment_name", "trail")
										hTrail.KeyValueFromInt("attachment_type", 4)
										hTrail.KeyValueFromInt("spawnflags", 64)
										hTrail.DispatchSpawn()
										hTrail.AcceptInput("StartTouch", null, hRocket, hRocket)
										if(bCrit)
										{
											hTrail.KeyValueFromString("particle_name", iTeamNum == TF_TEAM_BLUE ? "critical_rocket_blue" : "critical_rocket_red")
											hTrail.AcceptInput("StartTouch", null, hRocket, hRocket)
										}
										hTrail.Kill()
									}
								}
						}
						if(flTime >= flTimeSticky)
						{
							flTimeSticky = flTime + HELICOPTER_STICKY_COOLDOWN
							EmitSoundEx({
								sound_name  = bCrit ? HELICOPTER_STICKY_SND_FIRE_CRIT : HELICOPTER_STICKY_SND_FIRE
								sound_level = 110
								pitch       = 97
								entity      = self
								filter_type = RECIPIENT_FILTER_GLOBAL
							})
							foreach(hMimicSticky in [hMimicSticky1, hMimicSticky2])
							{
								hMimicSticky.AcceptInput("FireMultiple", format("%i", HELICOPTER_STICKY_SHOT_AMOUNT), null, null)
								EntFireByHandle(hMimicSticky, "DetonateStickies", null, HELICOPTER_STICKY_DETONATE_DELAY, null, null)
								for(local hSticky; hSticky = FindByClassnameWithin(hSticky, "tf_projectile_pipe", hMimicSticky.GetOrigin(), 1);)
									if(!GetPropEntity(hSticky, "m_hThrower"))
									{
										SetPropEntity(hSticky, "m_hThrower", self)
										hSticky.SetOwner(self)
										hSticky.SetTeam(iTeamNum)
										hSticky.SetSkin(iTeamNum == TF_TEAM_BLUE ? 1 : 0)
										if(bCrit) SetPropBool(hSticky, "m_bCritical", true)
										hStickies.append(hSticky)
									}
							}
						}
					}
				}
			}

			if(bDeploying && !bFoundWorld)
			{
				self.SetCycle(0.0)

				local vecBomb = hModel.GetAttachmentOrigin(iBombAttachment)
				local Trace = {
					start = vecBombLast
					end   = vecBomb
					mask  = CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_MOVEABLE
				}
				TraceLineEx(Trace)
				if(Trace.hit)
				{
					bFoundWorld = true
					self.EmitSound("weapons/dumpster_rocket_reload.wav")
					TankExt.DelayFunction(self, this, 0.5, function()
					{
						self.SetCycle(1.0) // ends deploy sequence
						hModel.SetCycle(1.0)
					})
				}
				vecBombLast = vecBomb
			}
		}
		function OnStartDeploy()
		{
			self.StopSound("MVM.TankDeploy")
			hModel.ResetSequence(hModel.LookupSequence("deploy"))
			hModel.SetCycle(0.0)
			vecBombLast = hModel.GetAttachmentOrigin(iBombAttachment)

			self.EmitSound("doors/door_metal_large_open1.wav")
			TankExt.DelayFunction(self, this, 1.1, function()
			{
				self.EmitSound("physics/metal/metal_solid_strain4.wav")
			})
			TankExt.DelayFunction(self, this, 2.4, function()
			{
				self.EmitSound("physics/metal/metal_box_strain2.wav")
			})
			TankExt.DelayFunction(self, this, 3.93, function()
			{
				self.EmitSound("physics/metal/metal_box_impact_soft3.wav")
			})
			TankExt.DelayFunction(self, this, 4.3, function()
			{
				self.EmitSound("physics/metal/metal_grate_impact_soft3.wav")
			})
			TankExt.DelayFunction(self, this, 5.7, function()
			{
				self.EmitSound("doors/door_squeek1.wav")
			})
			TankExt.DelayFunction(self, this, 6.6, function()
			{
				self.EmitSound("items/ammocrate_close.wav")
			})
		}
	}
	function OnDeath()
	{
		EmitSoundEx({
			sound_name  = "misc/null.wav"
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags       = SND_STOP | SND_IGNORE_NAME
		})
		foreach(hSticky in hStickies)
			if(hSticky.IsValid())
				hSticky.Kill()
	}
})