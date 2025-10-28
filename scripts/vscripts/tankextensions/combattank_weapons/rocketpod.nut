local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_ROCKETPOD_SND_FIRE              = "MVM.GiantSoldierRocketShoot"
	COMBATTANK_ROCKETPOD_ROCKET_SPLASH         = 146
	COMBATTANK_ROCKETPOD_ROCKET_SPEED          = 900
	COMBATTANK_ROCKETPOD_ROCKET_DAMAGE         = 90
	COMBATTANK_ROCKETPOD_ROCKET                = "models/bots/boss_bot/combat_tank_mk2/mk2_rocket_dumbfire.mdl"
	COMBATTANK_ROCKETPOD_ROCKET_HOMING         = "models/bots/boss_bot/combat_tank_mk2/mk2_rocket_seeker.mdl"
	COMBATTANK_ROCKETPOD_RELOAD_DELAY          = 0.3
	COMBATTANK_ROCKETPOD_PARTICLE_TRAIL        = "rockettrail"
	COMBATTANK_ROCKETPOD_PARTICLE_TRAIL_HOMING = "eyeboss_projectile"
	COMBATTANK_ROCKETPOD_MODEL                 = "models/bots/boss_bot/combat_tank_mk2/mk2_rocket_pod.mdl"
	COMBATTANK_ROCKETPOD_HOMING_POWER          = 0.05
	COMBATTANK_ROCKETPOD_HOMING_SPEED_MULT     = 0.75
	COMBATTANK_ROCKETPOD_HOMING_DURATION       = 1.5
	COMBATTANK_ROCKETPOD_FIRE_DELAY            = 0.1
	COMBATTANK_ROCKETPOD_CONE_RADIUS           = 90
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_ROCKETPOD_MODEL)
PrecacheModel(COMBATTANK_ROCKETPOD_ROCKET)
PrecacheModel(COMBATTANK_ROCKETPOD_ROCKET_HOMING)
TankExt.PrecacheSound(COMBATTANK_ROCKETPOD_SND_FIRE)

TankExt.CombatTankWeapons["rocketpod"] <- {
	Model = COMBATTANK_ROCKETPOD_MODEL
	function OnSpawn()
	{
		local hWeapon = SpawnEntityFromTableSafe("tf_point_weapon_mimic", {
			angles        = QAngle(0, -2, 0)
			damage        = COMBATTANK_ROCKETPOD_ROCKET_DAMAGE
			modeloverride = COMBATTANK_ROCKETPOD_ROCKET
			modelscale    = 1
			speedmax      = COMBATTANK_ROCKETPOD_ROCKET_SPEED
			speedmin      = COMBATTANK_ROCKETPOD_ROCKET_SPEED
			splashradius  = COMBATTANK_ROCKETPOD_ROCKET_SPLASH
			weapontype    = 0
		})
		TankExt.SetParentArray([hWeapon], self, "barrel_1")
		local flTimeNext = 0.0
		local iSlots     = [1, 2, 3, 4, 5, 6, 7, 8, 9]
		local bReloading = false
		local bClosed    = true
		bHoming <- false

		function Think()
		{
			if(!(self && self.IsValid())) return
			local flTime       = Time()
			local bEnemyInCone = hTank_scope.flAngleDot >= cos(COMBATTANK_ROCKETPOD_CONE_RADIUS * DEG2RAD)
			local bNext        = flTime >= flTimeNext
			if(bNext && bEnemyInCone && !bReloading && iSlots.len() > 0)
			{
				if(bClosed)
				{
					bClosed = false
					self.AcceptInput("SetAnimation", "open", null, null)
					flTimeNext = flTime + 0.33
					return
				}

				flTimeNext = flTime + COMBATTANK_ROCKETPOD_FIRE_DELAY
				local iRNG = RandomInt(0, iSlots.len() - 1)
				local iBarrel = iSlots[iRNG]
				iSlots.remove(iRNG)

				// SetPropInt(hWeapon, "m_iParentAttachment", iBarrel) // this is slower
				hWeapon.SetAbsOrigin(self.GetAttachmentOrigin(iBarrel))
				hWeapon.AcceptInput("FireOnce", null, null, null)

				DispatchParticleEffect("rocketbackblast", self.GetAttachmentOrigin(iBarrel + 9), self.GetAttachmentAngles(iBarrel + 9).Forward())
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_ROCKETPOD_SND_FIRE
					sound_level = 90
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})

				for(local hRocket; hRocket = FindByClassnameWithin(hRocket, "tf_projectile_rocket", hWeapon.GetOrigin(), 64);)
				{
					if(hRocket.GetOwner() != hWeapon || hRocket.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL) continue
					MarkForPurge(hRocket)

					local iTeamNum = hTank.GetTeam()
					hRocket.SetSize(Vector(), Vector())
					hRocket.SetSolid(SOLID_BSP)
					hRocket.SetSequence(1)
					hRocket.SetSkin(iTeamNum == TF_TEAM_BLUE ? 1 : 0)
					hRocket.SetTeam(iTeamNum)
					hRocket.SetOwner(hTank)

					hRocket.ValidateScriptScope()
					hRocket.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
					local bSolid = false
					local hRocket_scope = hRocket.GetScriptScope()
					hRocket_scope.hTank <- hTank
					hRocket_scope.RocketThink <- function()
					{
						if(!self.IsValid()) return
						local vecOrigin = self.GetOrigin()
						if(!bSolid && (!hTank.IsValid() || !TankExt.IntersectionBoxBox(vecOrigin, self.GetBoundingMins(), self.GetBoundingMaxs(), hTank.GetOrigin(), hTank.GetBoundingMins(), hTank.GetBoundingMaxs())))
							{ bSolid = true; self.SetSolid(SOLID_BBOX) }
						if("HomingThink" in this) HomingThink()
						return -1
					}
					if(bHoming)
					{
						hRocket.SetModel(COMBATTANK_ROCKETPOD_ROCKET_HOMING)
						hRocket.SetSize(Vector(), Vector())
						hRocket_scope.HomingParams <- {
							Target      = hTank_scope.hTarget
							TurnPower   = COMBATTANK_ROCKETPOD_HOMING_POWER
							RocketSpeed = COMBATTANK_ROCKETPOD_HOMING_SPEED_MULT
							AimTime     = COMBATTANK_ROCKETPOD_HOMING_DURATION
						}
						IncludeScript("tankextensions/misc/homingrocket", hRocket_scope)
					}
					TankExt.AddThinkToEnt(hRocket, "RocketThink")

					local sTrail = bHoming ? COMBATTANK_ROCKETPOD_PARTICLE_TRAIL_HOMING : COMBATTANK_ROCKETPOD_PARTICLE_TRAIL
					if(sTrail != "rockettrail")
					{
						hRocket.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
						local hTrail = CreateByClassnameSafe("trigger_particle")
						hTrail.KeyValueFromString("particle_name", sTrail)
						hTrail.KeyValueFromString("attachment_name", "trail")
						hTrail.KeyValueFromInt("attachment_type", 4)
						hTrail.KeyValueFromInt("spawnflags", 64)
						DispatchSpawn(hTrail)
						hTrail.AcceptInput("StartTouch", null, hRocket, hRocket)
						hTrail.Kill()
					}
				}
			}

			if(bNext && bReloading)
			{
				flTimeNext = flTime + COMBATTANK_ROCKETPOD_RELOAD_DELAY
				for(local i = 1; i <= 9; i++)
					if(iSlots.find(i) == null)
					{
						iSlots.append(i)
						break
					}
				if(iSlots.len() >= 9) bReloading = false
			}

			if(bNext && !bEnemyInCone || iSlots.len() == 0)
			{
				if(!bClosed)
				{
					bClosed = true
					self.AcceptInput("SetAnimation", "close", null, null)
					flTimeNext = flTime + 0.66
				}
				if(iSlots.len() < 9)
					bReloading = true
			}
			return -1
		}
		TankExt.AddThinkToEnt(self, "Think")
	}
}

TankExt.CombatTankWeapons["rocketpod_homing"] <- {
	Model = COMBATTANK_ROCKETPOD_MODEL
	function OnSpawn()
	{
		TankExt.CombatTankWeapons["rocketpod"].OnSpawn.call(this)
		bHoming = true
	}
}