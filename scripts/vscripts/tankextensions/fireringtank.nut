local FIRERINGTANK_VALUES_TABLE = {
	FIRERINGTANK_BURN_DURATION = 8
	FIRERINGTANK_DAMAGE_PERCENT = 72
	FIRERINGTANK_SND_SPIN = "weapons/dragon_gun_motor_loop_dry.wav"
	FIRERINGTANK_PARTICLE = "heavy_ring_of_fire"
	FIRERINGTANK_FIRE_RATE = 0.5
	FIRERINGTANK_PARTICLE_FORWARD = Vector(1, 0, 0)
}
foreach(k,v in FIRERINGTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(FIRERINGTANK_SND_SPIN)

TankExt.NewTankScript("fireringtank", {
	OnSpawn = function(hTank, sName, hPath)
	{
		EmitSoundEx({
			sound_name = FIRERINGTANK_SND_SPIN
			entity = hTank
			filter_type = RECIPIENT_FILTER_GLOBAL
			sound_level = 82
		})

		local hTank_scope = hTank.GetScriptScope()
		hTank_scope.hIgniter <- SpawnEntityFromTable("trigger_ignite", { spawnflags = 1, startdisabled = 1, damage_percent_per_second = FIRERINGTANK_DAMAGE_PERCENT, burn_duration = FIRERINGTANK_BURN_DURATION })
		hTank_scope.hIgniter.SetSize(Vector(-160, -160, -32), Vector(160, 160, 48))
		hTank_scope.hIgniter.SetSolid(SOLID_BBOX)

		hTank_scope.hFilter <- SpawnEntityFromTable("filter_activator_tfteam", { teamnum = hTank.GetTeam(), negated = 1 })
		SetPropEntity(hTank_scope.hIgniter, "m_hFilter", hTank_scope.hFilter)
		
		hTank_scope.flNextAttack <- 0
		hTank_scope.FireRingThink <- function()
		{
			local flTime = Time()
			if(flTime >= flNextAttack)
			{
				flNextAttack = flTime + FIRERINGTANK_FIRE_RATE
				local vecTank = self.GetOrigin()
				local angTank = self.GetAbsAngles()
				local Rotate = @(vec) RotatePosition(Vector(), angTank, vec)
				DispatchParticleEffect(FIRERINGTANK_PARTICLE, vecTank + Rotate(Vector(64, 48, 0)), FIRERINGTANK_PARTICLE_FORWARD)
				DispatchParticleEffect(FIRERINGTANK_PARTICLE, vecTank + Rotate(Vector(-64, 48, 0)), FIRERINGTANK_PARTICLE_FORWARD)
				DispatchParticleEffect(FIRERINGTANK_PARTICLE, vecTank + Rotate(Vector(64, -48, 0)), FIRERINGTANK_PARTICLE_FORWARD)
				DispatchParticleEffect(FIRERINGTANK_PARTICLE, vecTank + Rotate(Vector(-64, -48, 0)), FIRERINGTANK_PARTICLE_FORWARD)
				hIgniter.AcceptInput("Enable", null, null, null)
				EntFireByHandle(hIgniter, "Disable", null, 0.2, null, null)
			}
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "FireRingThink")
		TankExt.SetParentArray([hTank_scope.hIgniter], hTank)
	}
	OnDeath = function()
	{
		if(hFilter && hFilter.IsValid()) hFilter.Destroy()
		EmitSoundEx({
			sound_name = FIRERINGTANK_SND_SPIN
			entity = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags = 4
		})
	}
})