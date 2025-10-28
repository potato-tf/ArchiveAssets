local SCALETANK_VALUES_TABLE = {
	SCALETANK_SCALE_TIME = 0.4
}
foreach(k,v in SCALETANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.NewTankType("scaletank*", {
	function OnSpawn()
	{
		local hTracks = []
		for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().find("track_"))
				hTracks.append(hChild)

		local Params         = split(sTankName, "|")
		local flScaleInitial = self.GetModelScale()
		local flScaleGoal    = Params.len() < 2 ? flScaleInitial : Params[1].tofloat()
		local iHealthLast    = self.GetHealth()
		function Think()
		{
			local flHealthPercentage = iHealth / iMaxHealth.tofloat()
			if(iHealth != iHealthLast)
			{
				self.SetModelScale(flHealthPercentage * (flScaleInitial - flScaleGoal) + flScaleGoal, SCALETANK_SCALE_TIME)
				iHealthLast = iHealth
			}

			local flScale = self.GetModelScale()
			foreach(hTrack in hTracks)
				hTrack.SetPlaybackRate(GetPropFloat(self, "m_speed") / 80.0 / flScale)

			EmitSoundEx({
				sound_name  = "misc/null.wav"
				pitch       = 100 + (1 - flScale) * 15
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_CHANGE_PITCH | SND_IGNORE_NAME
			})
		}
	}
})