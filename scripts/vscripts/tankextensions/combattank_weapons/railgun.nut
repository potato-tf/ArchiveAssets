////////////////////////////////////////////////////////////////////////////////////////////
// includes:
//     railgun
////////////////////////////////////////////////////////////////////////////////////////////

local COMBATTANK_VALUES_TABLE = {
	COMBATTANK_RAILGUN_SND_CHARGE           = ")misc/doomsday_cap_close_quick.wav"
	COMBATTANK_RAILGUN_SND_FIRE1            = ")weapons/shooting_star_shoot_charged.wav"
	COMBATTANK_RAILGUN_SND_FIRE2            = ")weapons/sniper_railgun_charged_shot_01.wav"
	COMBATTANK_RAILGUN_MODEL                = "models/bots/boss_bot/combat_tank/combat_tank_railgun.mdl"
	COMBATTANK_RAILGUN_MODEL_CASING         = "models/bots/boss_bot/combat_tank/railgun_case.mdl"
	COMBATTANK_MINIGUN_PARTICLE_TRACER_RED  = "dxhr_sniper_rail_red"
	COMBATTANK_MINIGUN_PARTICLE_TRACER_BLUE = "dxhr_sniper_rail_blue"
	COMBATTANK_RAILGUN_FIRE_DELAY           = 8
	COMBATTANK_RAILGUN_CONE_RADIUS          = 20
	COMBATTANK_RAILGUN_BULLET_DAMAGE        = 75 // 225
}
foreach(k,v in COMBATTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_CHARGE)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_FIRE1)
TankExt.PrecacheSound(COMBATTANK_RAILGUN_SND_FIRE2)

CombatTankWeapons.railgun <- {
	Spawn = function(hTank)
	{
		local hRailgun = SpawnEntityFromTable("prop_dynamic", { model = COMBATTANK_RAILGUN_MODEL })
		hRailgun.ValidateScriptScope()
		local hRailgun_scope = hRailgun.GetScriptScope()
		hRailgun_scope.hTank <- hTank
		hRailgun_scope.hTank_scope <- hTank.GetScriptScope()
		hRailgun_scope.flNextAttack <- 0.0
		hRailgun_scope.bCharging <- false
		
		hRailgun_scope.hCasingShooter <- SpawnEntityFromTable("env_shooter", {
			origin = Vector(-66, -38, 0)
			angles = QAngle(0, -90, 0)
			shootmodel = COMBATTANK_RAILGUN_MODEL_CASING
			m_flGibLife = 5
			m_flVariance = 0.15
			m_flVelocity = 200
			m_iGibs = 1
			nogibshadows = 1
			shootsounds = -1
			spawnflags = 5
			gibanglevelocity = 10
		})
		TankExt.SetParentArray([hRailgun_scope.hCasingShooter], hRailgun)

		hRailgun_scope.Shoot <- function()
		{
			flNextAttack = Time() + COMBATTANK_RAILGUN_FIRE_DELAY
			bCharging = false
			TankExt.CombatTankPlaySound({
				sound_name = COMBATTANK_RAILGUN_SND_FIRE1
				sound_level = 90
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			TankExt.CombatTankPlaySound({
				sound_name = COMBATTANK_RAILGUN_SND_FIRE2
				sound_level = 90
				entity = hTank
				filter_type = RECIPIENT_FILTER_GLOBAL
			})

			local iTeamNum = hTank.GetTeam()
			if("enthit" in hTank_scope.LaserTrace)
			{
				local hHit = hTank_scope.LaserTrace.enthit
				if(hHit.IsValid() && "GetTeam" in hHit && hHit.GetTeam() != iTeamNum)
				{
					local sClassname = hHit.GetClassname()
					if(sClassname == "player")
						if(!hHit.InCond(TF_COND_DISGUISED))
							hHit.EmitSound("Flesh.BulletImpact")
					if(startswith(sClassname, "obj_"))
						hHit.EmitSound("SolidMetal.BulletImpact")
					hHit.TakeDamageCustom(hTank, hTank, null, Vector(), Vector(), COMBATTANK_RAILGUN_BULLET_DAMAGE, DMG_BULLET | DMG_ACID, TF_DMG_CUSTOM_HEADSHOT)
				}
			}

			local sEffectName = iTeamNum == 3 ? COMBATTANK_MINIGUN_PARTICLE_TRACER_BLUE : COMBATTANK_MINIGUN_PARTICLE_TRACER_RED
			local hParticleTracers = [
				SpawnEntityFromTable("info_particle_system", {
					origin = Vector(0, 1, 1)
					effect_name = sEffectName
					start_active = 1
				})
				SpawnEntityFromTable("info_particle_system", {
					origin = Vector(0, -1, 1)
					effect_name = sEffectName
					start_active = 1
				})
				SpawnEntityFromTable("info_particle_system", {
					origin = Vector(0, -1, -1)
					effect_name = sEffectName
					start_active = 1
				})
				SpawnEntityFromTable("info_particle_system", {
					origin = Vector(0, 1, -1)
					effect_name = sEffectName
					start_active = 1
				})
			]
			TankExt.SetParentArray(hParticleTracers, self, "barrel")

			local hTracerTarget = SpawnEntityFromTable("info_target", { origin = hTank_scope.LaserTrace.endpos, spawnflags = 0x01 })
			SetPropBool(hTracerTarget, "m_bForcePurgeFixedupStrings", true)
			EntFireByHandle(hTracerTarget, "Kill", null, 0.066, null, null)

			foreach(hParticleTracer in hParticleTracers)
			{
				SetPropBool(hParticleTracer, "m_bForcePurgeFixedupStrings", true)
				SetPropEntityArray(hParticleTracer, "m_hControlPointEnts", hTracerTarget, 0)
				EntFireByHandle(hParticleTracer, "Kill", null, 0.066, null, null)
			}

			EntFireByHandle(hCasingShooter, "Shoot", null, 0.1, null, null)
		}
		hRailgun_scope.Think <- function()
		{
			if(!(self && self.IsValid())) return
			if(hTank_scope.hEnemy)
			{				
				local bEnemyInCone = hTank_scope.flAngleDist != null && hTank_scope.flAngleDist < COMBATTANK_RAILGUN_CONE_RADIUS
				if(!bCharging && bEnemyInCone && Time() >= flNextAttack)
				{
					bCharging = true
					TankExt.CombatTankPlaySound({
						sound_name = COMBATTANK_RAILGUN_SND_CHARGE
						sound_level = 90
						entity = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					self.AcceptInput("SetAnimation", "fire", null, null)
					EntFireByHandle(self, "CallScriptFunction", "Shoot", 1.7, null, null)
				}
			}
			return -1
		}
		TankExt.AddThinkToEnt(hRailgun, "Think")
		return hRailgun
	}
}
