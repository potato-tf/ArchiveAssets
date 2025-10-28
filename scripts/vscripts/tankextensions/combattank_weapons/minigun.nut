local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_MINIGUN_SPREAD_MULTIPLIER = 1
	COMBATTANK_MINIGUN_SND_SPINUP        = ")mvm/giant_heavy/giant_heavy_gunwindup.wav"
	COMBATTANK_MINIGUN_SND_SPINNING      = ")mvm/giant_heavy/giant_heavy_gunspin.wav"
	COMBATTANK_MINIGUN_SND_SPINDOWN      = ")mvm/giant_heavy/giant_heavy_gunwinddown.wav"
	COMBATTANK_MINIGUN_SND_FIRE          = ")mvm/giant_heavy/giant_heavy_gunfire.wav"
	COMBATTANK_MINIGUN_PARTICLE_TRACER   = "bullet_tracer01"
	COMBATTANK_MINIGUN_PARTICLE_MUZZLE   = "muzzle_minigun_constant"
	COMBATTANK_MINIGUN_PARTICLE_CASING   = "eject_minigunbrass"
	COMBATTANK_MINIGUN_MODEL             = "models/bots/boss_bot/combat_tank_mk2/mk2_minigun.mdl"
	COMBATTANK_MINIGUN_FIRE_DELAY        = 0.066
	COMBATTANK_MINIGUN_CONE_RADIUS       = 25
	COMBATTANK_MINIGUN_BULLET_DAMAGE     = 22
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(COMBATTANK_MINIGUN_MODEL)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINUP)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINNING)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_FIRE)
TankExt.PrecacheSound(COMBATTANK_MINIGUN_SND_SPINDOWN)

TankExt.CombatTankWeapons["minigun"] <- {
	Model = COMBATTANK_MINIGUN_MODEL
	DefaultAnim = "idle"
	function OnSpawn()
	{
		local SpawnParticleSystem = @(sParticle) SpawnEntityFromTableSafe("info_particle_system", { effect_name = sParticle })
		local hParticleMuzzle1 = SpawnParticleSystem(COMBATTANK_MINIGUN_PARTICLE_MUZZLE)
		local hParticleMuzzle2 = SpawnParticleSystem(COMBATTANK_MINIGUN_PARTICLE_MUZZLE)
		local hParticleCasing1 = SpawnParticleSystem(COMBATTANK_MINIGUN_PARTICLE_CASING)
		local hParticleCasing2 = SpawnParticleSystem(COMBATTANK_MINIGUN_PARTICLE_CASING)
		TankExt.SetParentArray([hParticleMuzzle1], self, "barrel_1")
		TankExt.SetParentArray([hParticleMuzzle2], self, "barrel_2")
		TankExt.SetParentArray([hParticleCasing1], self, "case_eject_1")
		TankExt.SetParentArray([hParticleCasing2], self, "case_eject_2")
		local flNextAttack = 0.0
		local flTimeIdle   = 0.0
		local iStateLast   = 0
		local iState       = 0
		local iBarrel      = 0

		function Think()
		{
			if(!(self && self.IsValid())) return
			local flTime = Time()
			if(hTank_scope.hTarget)
			{
				if(iState == 0)
				{
					iState = 1
					hTank_scope.AddToSoundQueue({
						sound_name  = COMBATTANK_MINIGUN_SND_SPINUP
						volume      = 0.9
						sound_level = 120
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					self.AcceptInput("SetAnimation", "spin_up", null, null)
					flTimeIdle = flTime + 1
				}
				if(flTime >= flTimeIdle || iState > 1)
				{
					local bEnemyInCone = hTank_scope.flAngleDot >= cos(COMBATTANK_MINIGUN_CONE_RADIUS * DEG2RAD)
					if(iState == 1) self.AcceptInput("SetAnimation", "spining", null, null)
					if(!bEnemyInCone && iState != 2)
					{
						iState = 2
						self.SetBodygroup(1, 0)
						hTank_scope.AddToSoundQueue({
							sound_name  = COMBATTANK_MINIGUN_SND_SPINNING
							volume      = 0.8
							sound_level = 120
							entity      = hTank
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
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
							hTank_scope.AddToSoundQueue({
								sound_name  = COMBATTANK_MINIGUN_SND_FIRE
								sound_level = 120
								entity      = hTank
								filter_type = RECIPIENT_FILTER_GLOBAL
							})
						}
						if(flTime >= flNextAttack)
						{
							flNextAttack = flTime + COMBATTANK_MINIGUN_FIRE_DELAY
							iBarrel = iBarrel ? 0 : 1
							local vecTowardsEnemy = RotatePosition(Vector(), QAngle(RandomFloat(-5, 5), RandomFloat(-5, 5)) * COMBATTANK_MINIGUN_SPREAD_MULTIPLIER, hTank_scope.vecTarget - hTank_scope.vecMount)
							vecTowardsEnemy.Norm()

							local Trace = {
								start  = hTank_scope.vecMount
								end    = hTank_scope.vecMount + vecTowardsEnemy * 8192
								ignore = hTank
								mask   = MASK_SHOT
							}
							TraceLineEx(Trace)
							if("enthit" in Trace)
							{
								local hHit = Trace.enthit
								if("GetTeam" in hHit && hHit.GetTeam() != hTank.GetTeam())
								{
									local sClassname = hHit.GetClassname()
									if(sClassname == "player")
										if(!hHit.InCond(TF_COND_DISGUISED))
											hHit.EmitSound(
												hHit.InCond( TF_COND_INVULNERABLE ) ||
												hHit.InCond( TF_COND_INVULNERABLE_USER_BUFF ) ||
												hHit.InCond( TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED ) ||
												hHit.InCond( TF_COND_INVULNERABLE_CARD_EFFECT ) ?
												"FX_RicochetSound.Ricochet" : "Flesh.BulletImpact"
											)
									if(startswith(sClassname, "obj_"))
										hHit.EmitSound("SolidMetal.BulletImpact")
									hHit.TakeDamageCustom(hTank, hTank, null, Vector(), Vector(), COMBATTANK_MINIGUN_BULLET_DAMAGE, DMG_BULLET, TF_DMG_CUSTOM_MINIGUN)
								}
							}

							local hParticleTracer = SpawnEntityFromTableSafe("info_particle_system", {
								effect_name = COMBATTANK_MINIGUN_PARTICLE_TRACER
								start_active = 1
							})
							TankExt.SetParentArray([hParticleTracer], self, iBarrel ? "barrel_1" : "barrel_2")
							local hTracerTarget = SpawnEntityFromTableSafe("info_target", { origin = Trace.endpos, spawnflags = 0x01 })
							hTracerTarget.AddEFlags(EFL_IN_SKYBOX | EFL_FORCE_CHECK_TRANSMIT)
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
					hTank_scope.AddToSoundQueue({
						sound_name  = COMBATTANK_MINIGUN_SND_SPINNING
						volume      = 0.8
						sound_level = 120
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					hParticleMuzzle1.AcceptInput("Stop", null, null, null)
					hParticleMuzzle2.AcceptInput("Stop", null, null, null)
					hParticleCasing1.AcceptInput("Stop", null, null, null)
					hParticleCasing2.AcceptInput("Stop", null, null, null)
					self.SetBodygroup(1, 0)
				}
			}
			else if(iState != 0)
			{
				iState = 0
				hTank_scope.AddToSoundQueue({
					sound_name  = COMBATTANK_MINIGUN_SND_SPINDOWN
					volume      = 0.9
					sound_level = 120
					entity      = hTank
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				self.AcceptInput("SetAnimation", "spin_down", null, null)
			}

			local SoundStop = @(sSound) EmitSoundEx({
				sound_name  = sSound
				entity      = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_STOP
			})
			if(iState != 0) SoundStop(COMBATTANK_MINIGUN_SND_SPINDOWN)
			if(iState != 1) SoundStop(COMBATTANK_MINIGUN_SND_SPINUP)
			if(iState != 2) SoundStop(COMBATTANK_MINIGUN_SND_SPINNING)
			if(iState != 3) SoundStop(COMBATTANK_MINIGUN_SND_FIRE)
			return -1
		}
		TankExt.AddThinkToEnt(self, "Think")
	}
}
