local PARATANK_VALUES_TABLE = {
	PARATANK_PARACHUTE_MODEL     = "models/props_aircrap/tank_chute.mdl"
	PARATANK_SND_PARACHUTE_OPEN  = ")items/para_open.wav"
	PARATANK_SND_PARACHUTE_CLOSE = ")items/para_close.wav"
	PARATANK_GROUND_DISTANCE     = -100
}
foreach(k,v in PARATANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(PARATANK_PARACHUTE_MODEL)
TankExt.PrecacheSound(PARATANK_SND_PARACHUTE_OPEN)
TankExt.PrecacheSound(PARATANK_SND_PARACHUTE_CLOSE)

TankExt.NewTankType("paratank", {
	NoGravity = 1
	function OnSpawn()
	{
		local hParachute = SpawnEntityFromTableSafe("prop_dynamic", { model = PARATANK_PARACHUTE_MODEL })
		hParachute.DisableDraw()
		TankExt.SetParentArray([hParachute], self)

		local hTracks = []
		for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().find("track_"))
				hTracks.append(hChild)

		local bParachuteActive = false
		local hTank_scope      = self.GetScriptScope()
		local iSeqRetract      = hParachute.LookupSequence("retract")
		hTank_scope.bNoGravity = false
		function Think()
		{
			if(bParachuteActive)
				foreach(hTrack in hTracks)
					hTrack.SetPlaybackRate(0)

			local Trace = {
				start  = vecOrigin
				end    = vecOrigin + Vector(0, 0, PARATANK_GROUND_DISTANCE)
				ignore = self
				mask   = MASK_NPCSOLID_BRUSHONLY
			}
			TraceLineEx(Trace)
			if(!Trace.hit && !bParachuteActive)
			{
				hTank_scope.bNoGravity = true
				bParachuteActive       = true
				hParachute.EnableDraw()
				hParachute.AcceptInput("SetAnimation", "deploy", null, null)
				self.SetAbsAngles(QAngle(0, self.GetAbsAngles().y, 0))
				EmitSoundEx({
					sound_name  = "EngineLoopSound" in hTank_scope ? hTank_scope.EngineLoopSound : "MVM.TankEngineLoop"
					channel     = CHAN_STATIC
					entity      = self
					filter_type = RECIPIENT_FILTER_GLOBAL
					flags       = SND_STOP
				})
				EmitSoundEx({
					sound_name  = PARATANK_SND_PARACHUTE_OPEN
					filter_type = RECIPIENT_FILTER_GLOBAL
					pitch       = 85
				})
			}
			else if(Trace.hit && bParachuteActive)
			{
				hTank_scope.bNoGravity = false
				bParachuteActive       = false
				hParachute.AcceptInput("SetAnimation", "retract", null, null)
				EmitSoundEx({
					sound_name  = "EngineLoopSound" in hTank_scope ? hTank_scope.EngineLoopSound : "MVM.TankEngineLoop"
					channel     = CHAN_STATIC
					sound_level = 85
					entity      = self
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				EmitSoundEx({
					sound_name  = PARATANK_SND_PARACHUTE_CLOSE
					filter_type = RECIPIENT_FILTER_GLOBAL
					pitch       = 85
				})
			}
			if(hParachute.GetSequence() == iSeqRetract && hParachute.GetCycle() == 1) hParachute.DisableDraw()
		}
	}
})