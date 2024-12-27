////////////////////////////////////////////////////////////////////////////////////////////
// includes:
//     rocketpod
//     rocketpod_homing
////////////////////////////////////////////////////////////////////////////////////////////
// extra weapons get added to the list by appending to the CombatTankWeapons table
// then the weapon script will need to have an IncludeScript in the main popfile
// CombatTankWeapons.rocketpod <- {
//     Spawn = function(hTank)
//     {
//     
//     }
//     OnDeath = function()
//     {
//
//     }
////////////////////////////////////////////////////////////////////////////////////////////

local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_ROCKETPOD_SND_FIRE              = "MVM.GiantSoldierRocketShoot"
	COMBATTANK_ROCKETPOD_ROCKET_SPLASH         = 146
	COMBATTANK_ROCKETPOD_ROCKET_SPEED          = 900
	COMBATTANK_ROCKETPOD_ROCKET_DAMAGE         = 90
	COMBATTANK_ROCKETPOD_ROCKET                = "models/bots/boss_bot/combat_tank/combat_tank_rocket.mdl"
	COMBATTANK_ROCKETPOD_RELOAD_DELAY          = 0.3
	COMBATTANK_ROCKETPOD_PARTICLE_TRAIL        = "rockettrail"
	COMBATTANK_ROCKETPOD_PARTICLE_TRAIL_HOMING = "eyeboss_projectile"
	COMBATTANK_ROCKETPOD_MODEL                 = "models/bots/boss_bot/combat_tank/combat_tank_rocketpod.mdl"
	COMBATTANK_ROCKETPOD_HOMING_POWER          = 0.05
	COMBATTANK_ROCKETPOD_HOMING_SPEED          = 500
	COMBATTANK_ROCKETPOD_HOMING_DURATION       = 1
	COMBATTANK_ROCKETPOD_FIRE_DELAY            = 0.1
	COMBATTANK_ROCKETPOD_CONE_RADIUS           = 90
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_ROCKETPOD_ROCKET)
TankExt.PrecacheSound(COMBATTANK_ROCKETPOD_SND_FIRE)

CombatTankWeapons.rocketpod <- {
	Spawn = function(hTank)
	{
		local hRocketPod = SpawnEntityFromTable("prop_dynamic", { model = COMBATTANK_ROCKETPOD_MODEL })
		hRocketPod.ValidateScriptScope()
		local hRocketPod_scope = hRocketPod.GetScriptScope()
		hRocketPod_scope.hTank <- hTank
		hRocketPod_scope.hTank_scope <- hTank.GetScriptScope()
		hRocketPod_scope.hWeapon <- SpawnEntityFromTable("tf_point_weapon_mimic", {
			angles = QAngle(0, 2, 0)
			damage = COMBATTANK_ROCKETPOD_ROCKET_DAMAGE
			modeloverride = COMBATTANK_ROCKETPOD_ROCKET
			modelscale = 1
			speedmax = COMBATTANK_ROCKETPOD_ROCKET_SPEED
			speedmin = COMBATTANK_ROCKETPOD_ROCKET_SPEED
			splashradius = COMBATTANK_ROCKETPOD_ROCKET_SPLASH
			weapontype = 0
		})
		TankExt.SetParentArray([hRocketPod_scope.hWeapon], hRocketPod, "barrel_1")
		hRocketPod_scope.flNext <- 0.0
		hRocketPod_scope.iSlots <- [1, 2, 3, 4, 5, 6, 7, 8, 9]
		hRocketPod_scope.bReloading <- false
		hRocketPod_scope.bHoming <- "Homing" in this
		
		hRocketPod_scope.Think <- function()
		{
			if(!(self && self.IsValid())) return
			local flTime = Time()
			local bEnemyInCone = hTank_scope.flAngleDist != null && hTank_scope.flAngleDist < COMBATTANK_ROCKETPOD_CONE_RADIUS
			if(flTime >= flNext && bEnemyInCone && !bReloading && iSlots.len() > 0)
			{
				flNext = flTime + COMBATTANK_ROCKETPOD_FIRE_DELAY
				local iRNG = RandomInt(0, iSlots.len() - 1)
				local iBarrel = iSlots[iRNG]
				iSlots.remove(iRNG)
				
				SetPropInt(hWeapon, "m_iParentAttachment", iBarrel)
				hWeapon.AcceptInput("FireOnce", null, null, null)
		
				DispatchParticleEffect("rocketbackblast", self.GetAttachmentOrigin(iBarrel + 9), self.GetAttachmentAngles(iBarrel + 9).Forward())
				TankExt.CombatTankPlaySound({
					sound_name = COMBATTANK_ROCKETPOD_SND_FIRE
					sound_level = 90
					entity = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
			
			if(hWeapon.IsValid())
			{
				for(local hRocket; hRocket = FindByClassnameWithin(hRocket, "tf_projectile_rocket", hWeapon.GetOrigin(), 64);)
				{
					if(hRocket.GetOwner() != hWeapon || hRocket.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL) continue
					SetPropBool(hRocket, "m_bForcePurgeFixedupStrings", true)
					hRocket.ValidateScriptScope()
					hRocket.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
					local hRocket_scope = hRocket.GetScriptScope()
					hRocket_scope.bSolid <- false
					hRocket_scope.RocketThink <- function()
					{
						// apparently if the rocket hits a reanimator then it becomes a null instance for a tick
						if(!self.IsValid()) return
						local vecOrigin = self.GetOrigin()
						if(!bSolid)
						{
							local Trace = {
								start = vecOrigin
								end = vecOrigin
								hullmin = self.GetBoundingMins()
								hullmax = self.GetBoundingMaxs()
								mask = MASK_PLAYERSOLID
								ignore = self
							}
							TraceHull(Trace)
							if (!("startsolid" in Trace && Trace.enthit.GetClassname() == "tank_boss"))
							{
								bSolid = true
								self.SetSolid(2)
							}
						}
						if("HomingThink" in this)
							HomingThink.call(this)
						return -1
					}
					TankExt.AddThinkToEnt(hRocket, "RocketThink")

					if(bHoming)
					{
						hRocket_scope.hEnemy <- hTank_scope.hEnemy
						hRocket_scope.iDeflected <- 0
						hRocket_scope.flSpeed <- hRocket.GetAbsVelocity().Length()
						hRocket_scope.flHomingTime <- Time() + COMBATTANK_ROCKETPOD_HOMING_DURATION
						hRocket_scope.HomingThink <- function()
						{
							local iCurrentDeflected = GetPropInt(self, "m_iDeflected")
							if(iDeflected < iCurrentDeflected)
							{
								flHomingTime = Time() + COMBATTANK_ROCKETPOD_HOMING_DURATION
								iDeflected = iCurrentDeflected
								hEnemy = null
								local hLauncherOwner = GetPropEntity(self, "m_hLauncher").GetOwner()
								local flEnemyDist = COMBATTANK_MAX_RANGE
								for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, COMBATTANK_MAX_RANGE);)
								{
									local flPlayerDist = (hPlayer.GetCenter() - vecOrigin).Length()
									if(
										hPlayer.GetTeam() != self.GetTeam()	&&
										GetPropInt(hPlayer, "m_lifeState") == 0 &&
										flEnemyDist > flPlayerDist &&
										!TankExt.IsPlayerStealthedOrDisguised(hPlayer) &&
										hPlayer != hLauncherOwner
									)
									{
										hEnemy = hPlayer
										flEnemyDist = flPlayerDist
									}
								}
							}
							if(Time() <= flHomingTime && hEnemy && GetPropInt(hEnemy, "m_lifeState") == LIFE_ALIVE)
							{
								local vecTarget = hEnemy.GetCenter() - self.GetOrigin()
								vecTarget.Norm()
								local vecForward = self.GetForwardVector()
								local vecDirection = vecForward + (vecTarget - vecForward) * COMBATTANK_ROCKETPOD_HOMING_POWER
								vecDirection.Norm()
								local vecVelocity = vecDirection * flSpeed
								self.SetAbsVelocity(vecVelocity)
								self.SetForwardVector(vecDirection)
							}
						}
					}
			
					local sTrail = bHoming ? COMBATTANK_ROCKETPOD_PARTICLE_TRAIL_HOMING : COMBATTANK_ROCKETPOD_PARTICLE_TRAIL
					if(sTrail != "rockettrail")
					{
						hRocket.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)
						local hTrail = CreateByClassname("trigger_particle")
						SetPropBool(hTrail, "m_bForcePurgeFixedupStrings", true)
						hTrail.KeyValueFromString("particle_name", sTrail)
						hTrail.KeyValueFromInt("attachment_type", 1)
						hTrail.KeyValueFromInt("spawnflags", 64)
						DispatchSpawn(hTrail)
						hTrail.AcceptInput("StartTouch", null, hRocket, hRocket)
						hTrail.Kill()
					}

					local iTeamNum = hTank.GetTeam()
					hRocket.SetSolid(0)
					hRocket.SetSequence(bHoming ? 2 : 1)
					hRocket.SetSkin(iTeamNum == 3 ? bHoming ? 3 : 1 : bHoming ? 2 : 0)
					hRocket.SetTeam(iTeamNum)
					hRocket.SetOwner(hTank)
				}
			}
		
			if(flTime >= flNext && !bEnemyInCone && iSlots.len() < 9 || iSlots.len() == 0) bReloading = true
		
			if(flTime >= flNext && bReloading)
			{
				flNext = flTime + COMBATTANK_ROCKETPOD_RELOAD_DELAY
				for(local i = 1; i <= 9; i++)
					if(iSlots.find(i) == null)
					{
						iSlots.append(i)
						break
					}
				if(iSlots.len() >= 9) bReloading = false
			}
			return -1
		}
		TankExt.AddThinkToEnt(hRocketPod, "Think")
		return hRocketPod
	}
}

CombatTankWeapons.rocketpod_homing <- clone CombatTankWeapons.rocketpod
CombatTankWeapons.rocketpod_homing.Homing <- null