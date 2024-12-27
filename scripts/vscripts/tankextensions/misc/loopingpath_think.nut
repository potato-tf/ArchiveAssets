hTank <- null
vecPathCurrent <- null
iLoopCurrent <- 1
bInitalized <- false

function PathThink()
{
	if(hTank && hTank.IsValid())
	{
		bInitalized = true
		local vecTank = hTank.GetOrigin()
		local vecTankXY = Vector(vecTank.x, vecTank.y, 0)
		local vecPathXY = Vector(vecPathCurrent.x, vecPathCurrent.y, 0)

		local vecPathDir = vecPathXY - vecTankXY
		vecPathDir.Norm()
		vecPathDir *= 32
		local vecPath = vecPathCurrent + vecPathDir
		self.SetAbsOrigin(vecPath)

		local flDistXY = (vecPathXY - vecTankXY).Length()

		if(flDistXY <= 24)
		{
			iLoopCurrent++
			if(iLoopCurrent == iArrayLength)
				iLoopCurrent = iLoopStart
			vecPathCurrent = OriginArray[iLoopCurrent]
		}
	}
	else if(bInitalized)
		self.Destroy()
	return -1
}
function LoopInitialize()
{
	hTank = activator
	vecPathCurrent = OriginArray[iLoopCurrent]

	TankExt.SetPathConnection(self, null)
	self.KeyValueFromString("targetname", "active_loop_path")

	// merging the two functions causes a no free edicts error and i dont know why
	EntFireByHandle(self, "CallScriptFunction", "Respawn", -1, null, null)
}
function Respawn()
{
	local hPath = SpawnEntityFromTable("path_track", {
		origin = OriginArray[1]
		targetname = format("%s_2", sPathName)
		vscripts = "tankextensions/misc/loopingpath_think"
	})
	SetPropBool(hPath, "m_bForcePurgeFixedupStrings", true)

	local hPath_scope = hPath.GetScriptScope()
	hPath_scope.OriginArray <- OriginArray
	hPath_scope.sPathName <- sPathName
	hPath_scope.iArrayLength <- iArrayLength
	hPath_scope.iLoopStart <- iLoopStart
	TankExt.AddThinkToEnt(hPath, "PathThink")

	TankExt.SetPathConnection(FindByName(null, format("%s_1", sPathName)), hPath)
	TankExt.SetPathConnection(hPath, FindByName(null, format("%s_3", sPathName)))
}