local hTank          = null
local vecPathCurrent = null
local iLoopCurrent   = 1
local bInitalized    = false

function PathThink()
{
	if(hTank && hTank.IsValid())
	{
		bInitalized = true
		local vecTank    = hTank.GetOrigin()
		local vecPathDir = vecPathCurrent - vecTank
		local flDist     = vecPathDir.Length2DSqr()
		vecPathDir.z = 0
		vecPathDir.Norm()
		vecPathDir *= 32
		local vecPath = vecPathCurrent + vecPathDir
		self.SetAbsOrigin(vecPath)
		if(flDist <= 576) // sqr(24)
		{
			iLoopCurrent++
			if(iLoopCurrent == iArrayLength)
				iLoopCurrent = iLoopStart
			vecPathCurrent = OriginArray[iLoopCurrent]
		}
	}
	else if(bInitalized)
		self.Kill()
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
	local hPath = SpawnEntityFromTableSafe("path_track", {
		origin     = OriginArray[1]
		targetname = format("%s_2", sPathName)
	})
	hPath.ValidateScriptScope()
	local hPath_scope = hPath.GetScriptScope()
	IncludeScript("tankextensions/misc/loopingpath_think", hPath_scope)
	hPath_scope.OriginArray  <- OriginArray
	hPath_scope.sPathName    <- sPathName
	hPath_scope.iArrayLength <- iArrayLength
	hPath_scope.iLoopStart   <- iLoopStart
	TankExt.AddThinkToEnt(hPath, "PathThink")

	TankExt.SetPathConnection(FindByName(null, format("%s_1", sPathName)), hPath)
	TankExt.SetPathConnection(hPath, FindByName(null, format("%s_3", sPathName)))
}