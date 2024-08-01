//	example path
//	InitWaveOutput
//	{
//		Target wave_start_relay
//		Action runscriptcode
//		Param "if(!(`CreateBlimpPath` in this)) IncludeScript(`blimp_lite`)
//
//		if(!(Entities.FindByName(null,`blimp_1`))) {
//			CreateBlimpPath([
//				`964 0 512|blimp_1`,
//				`137 0 384|blimp_2`,
//				`-1372 0 256|blimp_3`
//			])
//		}"
//	}

::blimpmodel <- PrecacheModel("models/bots/boss_bot/boss_blimp_pure.mdl") // pure is the more recent version
function CreateBlimpPath(array) {
	local arraylen = array.len()-1
	for(local i=arraylen;i>=0;i--) {
		local info = split(array[i],"|")
		local pos = info[0]
		local name = info[1]
		local nextname = ""
		if(i<arraylen) {
			local nextinfo = split(array[i+1],"|")
			nextname = nextinfo[1]
		}
		local path = SpawnEntityFromTable("path_track",{
			origin = pos
			targetname = name
			target = nextname
			orientationtype = 1
		})
		if(i==0)
			path.KeyValueFromString("OnPass","wave_start_relay,CallScriptFunction,SetBlimp,-1,-1")
	}
}
function SetBlimp() {
	// activator is tank_boss
	// caller is path_track
	if(activator.GetClassname()!="tank_boss") return

	for(local child=activator.FirstMoveChild();child!=null;child=child.NextMovePeer())
		child.DisableDraw()

	activator.ValidateScriptScope()
	local gss = activator.GetScriptScope()

	activator.SetAbsAngles(QAngle(0,activator.GetAbsAngles().y,0))
	local tankspeed = NetProps.GetPropFloat(activator,"m_speed")
	gss.blimptrain <- SpawnEntityFromTable("func_tracktrain",{
		origin = caller.GetOrigin()
		speed = tankspeed
		startspeed = tankspeed
		target = caller.GetName()
	})
	activator.KeyValueFromString("OnKilled","!self,RunScriptCode,blimptrain.Kill(),-1,-1")
	AddThinkToEnt(activator,"BlimpThink")
}

::BlimpThink <- function() {
	for(local i=0;i<=3;i++)NetProps.SetPropIntArray(self,"m_nModelIndexOverrides",blimpmodel,i)
	self.SetAbsOrigin(blimptrain.GetOrigin())
	self.GetLocomotionInterface().Reset()
	return -1
}