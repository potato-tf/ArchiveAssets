////////////////////////////////////////////////////////////////////////////////////////////
// includes:
//     minigun
////////////////////////////////////////////////////////////////////////////////////////////
// extra weapons get added to the list by appending to the CombatTankWeapons table
// then the weapon script will need to have an IncludeScript in the main popfile
// CombatTankWeapons.minigun <- {
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
	COMBATTANK_MINIGUN_SPREAD_MULTIPLIER = 1
	COMBATTANK_MINIGUN_SND_SPINUP        = "MVM.GiantHeavyGunWindUp"
	COMBATTANK_MINIGUN_SND_SPINNING      = "MVM.GiantHeavyGunSpin"
	COMBATTANK_MINIGUN_SND_SPINDOWN      = "MVM.GiantHeavyGunWindDown"
	COMBATTANK_MINIGUN_SND_FIRE          = "MVM.GiantHeavyGunFire"
	COMBATTANK_MINIGUN_PARTICLE_TRACER   = "bullet_tracer01"
	COMBATTANK_MINIGUN_PARTICLE_MUZZLE   = "muzzle_minigun_constant"
	COMBATTANK_MINIGUN_PARTICLE_CASING   = "eject_minigunbrass"
	COMBATTANK_MINIGUN_MODEL             = "models/bots/boss_bot/combat_tank/combat_tank_minigun.mdl"
	COMBATTANK_MINIGUN_FIRE_DELAY        = 0.066
	COMBATTANK_MINIGUN_CONE_RADIUS       = 25
	COMBATTANK_MINIGUN_BULLET_DAMAGE     = 22
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINUP)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINNING)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_FIRE)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINDOWN)

CombatTankWeapons.minigun <- {
	Spawn = function(hTank)
	{
		local hMinigun = SpawnEntityFromTable("prop_dynamic", { model = COMBATTANK_MINIGUN_MODEL, defaultanim = "idle" })
		hMinigun.ValidateScriptScope()
		local hMinigun_scope = hMinigun.GetScriptScope()
		hMinigun_scope.hTank <- hTank
		hMinigun_scope.hTank_scope <- hTank.GetScriptScope()
		hMinigun_scope.hParticleMuzzle1 <- SpawnEntityFromTable("info_particle_system", { effect_name = COMBATTANK_MINIGUN_PARTICLE_MUZZLE })
		hMinigun_scope.hParticleMuzzle2 <- SpawnEntityFromTable("info_particle_system", { effect_name = COMBATTANK_MINIGUN_PARTICLE_MUZZLE })
		hMinigun_scope.hParticleCasing1 <- SpawnEntityFromTable("info_particle_system", { effect_name = COMBATTANK_MINIGUN_PARTICLE_CASING })
		hMinigun_scope.hParticleCasing2 <- SpawnEntityFromTable("info_particle_system", { effect_name = COMBATTANK_MINIGUN_PARTICLE_CASING })
		TankExt.SetParentArray([hMinigun_scope.hParticleMuzzle1], hMinigun, "barrel_1")
		TankExt.SetParentArray([hMinigun_scope.hParticleMuzzle2], hMinigun, "barrel_2")
		TankExt.SetParentArray([hMinigun_scope.hParticleCasing1], hMinigun, "case_eject_1")
		TankExt.SetParentArray([hMinigun_scope.hParticleCasing2], hMinigun, "case_eject_2")
		hMinigun_scope.flNextAttack <- 0.0
		hMinigun_scope.flTimeIdle <- 0.0
		hMinigun_scope.iState <- 0
		hMinigun_scope.iBarrel <- 0

		hMinigun_scope.Think <- function()
		{
			if(!(self && self.IsValid())) return
			local flTime = Time()
			if(hTank_scope.hEnemy)
			{
				if(iState == 0)
				{
					iState = 1
					TankExt.CombatTankPlaySound({
						sound_name = COMBATTANK_MINIGUN_SND_SPINUP
						sound_level = 90
						entity = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					self.AcceptInput("SetAnimation", "spin_up", null, null)
					flTimeIdle = flTime + 1
				}
				if(flTime >= flTimeIdle || iState > 1)
				{
					local bEnemyInCone = hTank_scope.flAngleDist != null && hTank_scope.flAngleDist < COMBATTANK_MINIGUN_CONE_RADIUS
					if(iState == 1) self.AcceptInput("SetAnimation", "spining", null, null)
					if(!bEnemyInCone && iState != 2)
					{
						iState = 2
						self.SetBodygroup(1, 0)
						TankExt.CombatTankPlaySound({
							sound_name = COMBATTANK_MINIGUN_SND_SPINNING
							sound_level = 90
							entity = hTank
							filter_type = RECIPIENT_FILTER_GLOBAL
						}, true)
						hParticleMuzzle1.AcceptInput("Stop", null, null, null)
						hParticleMuzzle2.AcceptInput("Stop", null, null, null)
						hParticleCasing1.AcceptInput("Stop", null, null, null)
						hParticleCasing2.AcceptInput("Stop", null, null, null)
					}
					if(bEnemyInCone)
					{
						if(iState != 3)
						{
							iState = 3
							self.SetBodygroup(1, 1)
							TankExt.CombatTankPlaySound({
								sound_name = COMBATTANK_MINIGUN_SND_FIRE
								sound_level = 90
								entity = hTank
								filter_type = RECIPIENT_FILTER_GLOBAL
							}, true)
						}
	
						if(flTime >= flNextAttack)
						{
							flNextAttack = flTime + COMBATTANK_MINIGUN_FIRE_DELAY
							iBarrel = iBarrel ? 0 : 1
							local vecTowardsEnemy = RotatePosition(Vector(), QAngle(RandomFloat(-5, 5), RandomFloat(-5, 5)) * COMBATTANK_MINIGUN_SPREAD_MULTIPLIER, hTank_scope.vecEnemyTarget - hTank_scope.vecMount)
							vecTowardsEnemy.Norm()
	
							local Trace = {
								start = hTank_scope.vecMount
								end = hTank_scope.vecMount + vecTowardsEnemy * 8192
								ignore = hTank
								mask = MASK_SHOT
							}
							TraceLineEx(Trace)
							if("enthit" in Trace)
							{
								local hHit = Trace.enthit
								if(hHit.IsValid() && "GetTeam" in hHit && hHit.GetTeam() != hTank.GetTeam())
								{
									local sClassname = hHit.GetClassname()
									if(sClassname == "player")
										if(!hHit.InCond(TF_COND_DISGUISED))
											hHit.EmitSound("Flesh.BulletImpact")
									if(startswith(sClassname, "obj_"))
										hHit.EmitSound("SolidMetal.BulletImpact")
									hHit.TakeDamageCustom(hTank, hTank, null, Vector(), Vector(), COMBATTANK_MINIGUN_BULLET_DAMAGE, DMG_BULLET, TF_DMG_CUSTOM_MINIGUN)
								}
							}
	
							local hParticleTracer = SpawnEntityFromTable("info_particle_system", {
								effect_name = COMBATTANK_MINIGUN_PARTICLE_TRACER
								start_active = 1
							})
							SetPropBool(hParticleTracer, "m_bForcePurgeFixedupStrings", true)
							TankExt.SetParentArray([hParticleTracer], self, iBarrel ? "barrel_1" : "barrel_2")
							local hTracerTarget = SpawnEntityFromTable("info_target", { origin = Trace.endpos, spawnflags = 0x01 })
							hTracerTarget.AddEFlags(EFL_IN_SKYBOX | EFL_FORCE_CHECK_TRANSMIT)
							SetPropBool(hTracerTarget, "m_bForcePurgeFixedupStrings", true)
							SetPropEntityArray(hParticleTracer, "m_hControlPointEnts", hTracerTarget, 0)
							EntFireByHandle(hParticleTracer, "Kill", null, 0.066, null, null)
							EntFireByHandle(hTracerTarget, "Kill", null, 0.066, null, null)
							hParticleMuzzle1.AcceptInput("Start", null, null, null)
							hParticleMuzzle2.AcceptInput("Start", null, null, null)
							hParticleCasing1.AcceptInput("Start", null, null, null)
							hParticleCasing2.AcceptInput("Start", null, null, null)
						}
					}
					flTimeIdle = flTime + 1
				}
			}
			else if(flTime <= flTimeIdle)
			{
				if(iState > 2)
				{
					iState = 2
					TankExt.CombatTankPlaySound({
						sound_name = COMBATTANK_MINIGUN_SND_SPINNING
						sound_level = 90
						entity = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					}, true)
					hParticleMuzzle1.AcceptInput("Stop", null, null, null)
					hParticleMuzzle2.AcceptInput("Stop", null, null, null)
					hParticleCasing1.AcceptInput("Stop", null, null, null)
					hParticleCasing2.AcceptInput("Stop", null, null, null)
				}
			}
			else if(iState != 0)
			{
				iState = 0
				TankExt.CombatTankPlaySound({
					sound_name = COMBATTANK_MINIGUN_SND_SPINDOWN
					sound_level = 90
					entity = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				self.AcceptInput("SetAnimation", "spin_down", null, null)
			}
			
			iState != 0 ? TankExt.CombatTankStopSound({
				sound_name = COMBATTANK_MINIGUN_SND_SPINDOWN
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = SND_STOP
			}) : null
			iState != 1 ? TankExt.CombatTankStopSound({
				sound_name = COMBATTANK_MINIGUN_SND_SPINUP
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = SND_STOP
			}) : null
			iState != 2 ? TankExt.CombatTankStopSound({
				sound_name = COMBATTANK_MINIGUN_SND_SPINNING
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = SND_STOP
			}) : null
			iState != 3 ? TankExt.CombatTankStopSound({
				sound_name = COMBATTANK_MINIGUN_SND_FIRE
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = SND_STOP
			}) : null
			return -1
		}
		TankExt.AddThinkToEnt(hMinigun, "Think")
		return hMinigun
	}
}
