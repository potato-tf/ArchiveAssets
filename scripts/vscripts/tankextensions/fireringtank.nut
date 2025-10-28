local FIRERINGTANK_VALUES_TABLE = {
	FIRERINGTANK_BURN_DURATION    = 8
	FIRERINGTANK_DAMAGE_PERCENT   = 72
	FIRERINGTANK_SND_SPIN         = ")weapons/dragon_gun_motor_loop_dry.wav"
	FIRERINGTANK_PARTICLE         = "heavy_ring_of_fire"
	FIRERINGTANK_FIRE_RATE        = 0.5
	FIRERINGTANK_PARTICLE_FORWARD = Vector(1, 0, 0)
}
foreach(k,v in FIRERINGTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(FIRERINGTANK_SND_SPIN)

TankExt.NewTankType("fireringtank", {
	function OnSpawn()
	{
		EmitSoundEx({
			sound_name  = FIRERINGTANK_SND_SPIN
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			sound_level = 82
		})

		local hIgniter = SpawnEntityFromTableSafe("trigger_ignite", { spawnflags = 1, startdisabled = 1, damage_percent_per_second = FIRERINGTANK_DAMAGE_PERCENT, burn_duration = FIRERINGTANK_BURN_DURATION })
		hIgniter.SetSize(Vector(-160, -160, -32), Vector(160, 160, 48))
		hIgniter.SetSolid(SOLID_OBB)

		hFilter <- SpawnEntityFromTableSafe("filter_activator_tfteam", { teamnum = self.GetTeam(), negated = 1 })
		SetPropEntity(hIgniter, "m_hFilter", hFilter)

		TankExt.SetParentArray([hIgniter], self)
		SetPropEntity(hIgniter, "m_pParent", null)

		local flNextAttack = 0
		function Think()
		{
			if(flTime >= flNextAttack)
			{
				flNextAttack = flTime + FIRERINGTANK_FIRE_RATE
				local vecTank  = self.GetOrigin()
				local angTank  = self.GetAbsAngles()
				local Particle = @(vec) DispatchParticleEffect(FIRERINGTANK_PARTICLE, vecTank + RotatePosition(Vector(), angTank, vec), FIRERINGTANK_PARTICLE_FORWARD)
				Particle(Vector(64, 48, 0))
				Particle(Vector(-64, 48, 0))
				Particle(Vector(64, -48, 0))
				Particle(Vector(-64, -48, 0))
				hIgniter.AcceptInput("Enable", null, null, null)
				EntFireByHandle(hIgniter, "Disable", null, 0.2, null, null)
			}
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
		if(hFilter && hFilter.IsValid()) hFilter.Kill()
	}
})