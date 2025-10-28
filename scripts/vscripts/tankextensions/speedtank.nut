local SPEEDTANK_VALUES_TABLE = {
	SPEEDTANK_MODEL              = "models/bots/boss_bot/boss_tank_blitz.mdl"
	SPEEDTANK_MODEL_DAMAGE1      = "models/bots/boss_bot/boss_tank_blitz_damage1.mdl"
	SPEEDTANK_MODEL_DAMAGE2      = "models/bots/boss_bot/boss_tank_blitz_damage2.mdl"
	SPEEDTANK_MODEL_DAMAGE3      = "models/bots/boss_bot/boss_tank_blitz_damage3.mdl"
}
foreach(k,v in SPEEDTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(SPEEDTANK_MODEL)
PrecacheModel(SPEEDTANK_MODEL_DAMAGE1)
PrecacheModel(SPEEDTANK_MODEL_DAMAGE2)
PrecacheModel(SPEEDTANK_MODEL_DAMAGE3)

TankExt.NewTankType("speedtank*", {
	// DisableSmokestack = 1
	Model = {
		Default = SPEEDTANK_MODEL
		Damage1 = SPEEDTANK_MODEL_DAMAGE1
		Damage2 = SPEEDTANK_MODEL_DAMAGE2
		Damage3 = SPEEDTANK_MODEL_DAMAGE3
	}
	function OnSpawn()
	{
		local hTracks = []
		for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().find("track_"))
				hTracks.append(hChild)

		local bUsingCustomModel = self.GetModelName() == SPEEDTANK_MODEL
		local hParticle1, hParticle2, hParticle3
		if(bUsingCustomModel)
		{
			hParticle1 = SpawnEntityFromTableSafe("info_particle_system", { effect_name = "blitz_jet_parent" })
			hParticle2 = SpawnEntityFromTableSafe("info_particle_system", { effect_name = "blitz_jet_parent" })
			hParticle3 = SpawnEntityFromTableSafe("info_particle_system", { effect_name = "blitz_jet_parent" })
			TankExt.SetParentArray([hParticle1], self, "jet_attachment_1")
			TankExt.SetParentArray([hParticle2], self, "jet_attachment_2")
			TankExt.SetParentArray([hParticle3], self, "jet_attachment_3")
		}

		local Params         = split(sTankName, "|")
		local flSpeedInitial = GetPropFloat(self, "m_speed")
		local flSpeedGoal    = Params.len() < 2 ? flSpeedInitial : Params[1].tofloat()
		local iHealthLast    = self.GetHealth()
		local bDeploying     = false
		function Think()
		{
			if(bDeploying) return

			// DisableSmokestack = 1
			if(bUsingCustomModel) self.AcceptInput("DispatchEffect", "ParticleEffectStop", null, null)

			if(iHealth != iHealthLast)
			{
				local flHealthPercentage = iHealth / iMaxHealth.tofloat()
				SetPropFloat(self, "m_speed", flHealthPercentage * (flSpeedInitial - flSpeedGoal) + flSpeedGoal)
				iHealthLast = iHealth

				if(bUsingCustomModel)
				{
					local PlayIgnitionSound = function(flPitch)
					{
						PrecacheSound(")weapons/bumper_car_speed_boost_start.wav")
						PrecacheSound(")ambient/fire/ignite.wav")
						EmitSoundEx({
							sound_name  = ")weapons/bumper_car_speed_boost_start.wav"
							sound_level = 90
							pitch       = flPitch
							entity      = self
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
						EmitSoundEx({
							sound_name  = ")ambient/fire/ignite.wav"
							sound_level = 90
							pitch       = flPitch
							entity      = self
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
					}

					if(!GetPropBool(hParticle3, "m_bActive") && flHealthPercentage < 0.25)
					{
						PlayIgnitionSound(120)
						hParticle1.AcceptInput("Start", null, null, null)
						hParticle2.AcceptInput("Start", null, null, null)
						hParticle3.AcceptInput("Start", null, null, null)
					}
					else if(!GetPropBool(hParticle2, "m_bActive") && flHealthPercentage < 0.5)
					{
						PlayIgnitionSound(110)
						hParticle1.AcceptInput("Start", null, null, null)
						hParticle2.AcceptInput("Start", null, null, null)
					}
					else if(!GetPropBool(hParticle1, "m_bActive") && flHealthPercentage < 0.75)
					{
						PlayIgnitionSound(100)
						hParticle1.AcceptInput("Start", null, null, null)
					}
				}
			}

			foreach(hTrack in hTracks)
				hTrack.SetPlaybackRate(GetPropFloat(self, "m_speed") / 80.0)
		}
		function OnStartDeploy()
		{
			bDeploying = true
			hParticle1.AcceptInput("Stop", null, null, null)
			hParticle2.AcceptInput("Stop", null, null, null)
			hParticle3.AcceptInput("Stop", null, null, null)
		}
	}
})