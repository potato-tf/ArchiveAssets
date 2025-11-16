local GATETANK_VALUES_TABLE = {
	GATETANK_MODEL             = "models/bots/boss_bot/boss_tank_gatebot.mdl"
	GATETANK_MODEL_DAMAGE1     = "models/bots/boss_bot/boss_tank_gatebot_damage1.mdl"
	GATETANK_MODEL_DAMAGE2     = "models/bots/boss_bot/boss_tank_gatebot_damage2.mdl"
	GATETANK_MODEL_DAMAGE3     = "models/bots/boss_bot/boss_tank_gatebot_damage3.mdl"
}
foreach(k,v in GATETANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(GATETANK_MODEL)
PrecacheModel(GATETANK_MODEL_DAMAGE1)
PrecacheModel(GATETANK_MODEL_DAMAGE2)
PrecacheModel(GATETANK_MODEL_DAMAGE3)

local MAX_CONTROL_POINTS  = 8
local MAX_PREVIOUS_POINTS = 3
local hObjectiveResource  = FindByClassname(null, "tf_objective_resource")

TankExt.NewTankType("gatetank*", {
	Model = {
		Default     = GATETANK_MODEL
		Damage1     = GATETANK_MODEL_DAMAGE1
		Damage2     = GATETANK_MODEL_DAMAGE2
		Damage3     = GATETANK_MODEL_DAMAGE3
	}
	function OnSpawn()
	{
		local CapturePoints     = []
		local TriggerTimerDoors = {}
		for(local hTrigger; hTrigger = FindByClassname(hTrigger, "trigger_timer_door");)
			TriggerTimerDoors[hTrigger] <- hTrigger.GetCenter()

		local hGatebotFilter
		for(local hFilter; hFilter = FindByClassname(hFilter, "filter_tf_bot_has_tag");)
			if(GetPropString(hFilter, "m_iszTags").find("bot_gatebot") != null)
				{ hGatebotFilter = hFilter; break }

		local GatebotTriggers = []
		for(local hTrigger; hTrigger = FindByClassname(hTrigger, "trigger_multiple");)
			if(GetPropEntity(hTrigger, "m_hFilter") == hGatebotFilter)
				GatebotTriggers.append(hTrigger)

		local sParams = split(sTankName, "|")
		sParams.remove(0) // removing the tanks name
		foreach(sPathName in sParams)
		{
			local hPath = FindByName(null, sPathName)
			if(!hPath) return ClientPrint(null, HUD_PRINTTALK, format("\x07FFFF00GateTank parameter cannot find specified path %s!", sPathName))

			// find closest trigger
			local vecOrigin = hPath.GetOrigin()
			local hTriggerCapture, flDist = FLT_MAX
			foreach(hTrigger, vecTrigger in TriggerTimerDoors)
			{
				local flDiff = (vecOrigin - vecTrigger).Length()
				if(flDiff < flDist)
				{
					hTriggerCapture = hTrigger
					flDist          = flDiff
				}
			}
			delete TriggerTimerDoors[hTriggerCapture]

			local hPoint = FindByName(null, GetPropString(hTriggerCapture, "m_iszCapPointName"))
			if(hPoint.GetTeam() != TF_TEAM_BLUE)
				CapturePoints.append([hPath, hTriggerCapture, hPoint])
		}

		local bComplete = false
		if(CapturePoints.len() == 0)
		{
			bComplete = true
			self.SetSkin(1)
		}

		local function TouchTrigger(hTrigger, bTouch)
		{
			local hFilter     = GetPropEntity(hTrigger, "m_hFilter")
			local iSpawnFlags = GetPropInt(hTrigger, "m_spawnflags")
			SetPropEntity(hTrigger, "m_hFilter", null)
			SetPropInt(hTrigger, "m_spawnflags", SF_TRIGGER_ALLOW_ALL)
			hTrigger.AcceptInput(bTouch ? "StartTouch" : "EndTouch", null, null, self)
			SetPropEntity(hTrigger, "m_hFilter", hFilter)
			SetPropInt(hTrigger, "m_spawnflags", iSpawnFlags)
		}

		local Touching = {}

		flCapturePercent <- 1.0
		iPointIndex      <- 0
		bCapturing       <- false
		local flTimeCapturing  = 0.0
		local flTimeOffset     = 0.0
		local flCurrentCapTime = 0.0
		local flSpeedLast      = 0.0
		local bWaiting         = false
		function Think()
		{
			local NotTouching = clone Touching
			foreach(hTrigger in GatebotTriggers)
			{
				if(GetPropBool(hTrigger, "m_bDisabled")) continue

				hTrigger.RemoveSolidFlags(FSOLID_NOT_SOLID)
				local Trace = {
					start = vecOrigin + Vector(0, 0, 1)
					end   = vecOrigin + Vector(0, 0, 1)
					mask  = CONTENTS_SOLID
				}
				TraceLineEx(Trace)
				hTrigger.AddSolidFlags(FSOLID_NOT_SOLID)
				if(Trace.hit && Trace.enthit == hTrigger)
				{
					if(hTrigger in Touching)
						delete NotTouching[hTrigger]
					else
					{
						Touching[hTrigger] <- null
						TouchTrigger(hTrigger, true)
					}
				}
			}
			foreach(hTrigger, _ in NotTouching)
			{
				delete Touching[hTrigger]
				TouchTrigger(hTrigger, false)
			}

			if(bComplete) return

			local hPath    = CapturePoints[0][0]
			local hTrigger = CapturePoints[0][1]
			local hPoint   = CapturePoints[0][2]
			while(hPoint.GetTeam() == TF_TEAM_BLUE)
			{
				CapturePoints.remove(0)
				if(CapturePoints.len() == 0)
				{
					bComplete = true
					self.SetSkin(1)
					return
				}
				else
				{
					hPath    = CapturePoints[0][0]
					hTrigger = CapturePoints[0][1]
					hPoint   = CapturePoints[0][2]
				}

				if(bWaiting || bCapturing)
				{
					bCapturing = false
					bWaiting   = false
					SetPropFloat(self, "m_speed", flSpeedLast)
				}
			}

			if(!bWaiting && (vecOrigin - hPath.GetOrigin()).Length2D() < 20.0)
				bWaiting = true

			if(bWaiting)
			{
				local flSpeed = GetPropFloat(self, "m_speed")
				if(flSpeed != 0.0)
				{
					flSpeedLast = flSpeed
					SetPropFloat(self, "m_speed", 0.0)
				}

				iPointIndex = GetPropInt(hPoint, "m_iPointIndex")
				local bCanCap = true
				for(local iPrevIndex = 0; iPrevIndex < MAX_PREVIOUS_POINTS; iPrevIndex++)
				{
					local iPrevPointIndex = GetPropIntArray(hObjectiveResource, "m_iPreviousPoints", iPrevIndex + iPointIndex * MAX_PREVIOUS_POINTS + TF_TEAM_BLUE * MAX_CONTROL_POINTS * MAX_PREVIOUS_POINTS)
					if(iPrevPointIndex != -1 && iPrevPointIndex != iPointIndex && GetPropIntArray(hObjectiveResource, "m_iOwner", iPrevPointIndex) != TF_TEAM_BLUE)
					{
						bCanCap = false
						break
					}
				}

				if(!bCapturing && bCanCap && !GetPropBool(hTrigger, "m_bDisabled"))
				{
					bCapturing = true
					TouchTrigger(hTrigger, true)
					flTimeCapturing = flTime

					flTimeOffset = 0
					if(GetPropIntArray(hObjectiveResource, "m_iCappingTeam", iPointIndex) == TF_TEAM_BLUE)
					{
						local flCapturePercent = 1 - GetPropFloatArray(hObjectiveResource, "m_flCapPercentages", iPointIndex)
						if(flCapturePercent == 1.0)
							flCapturePercent = 0.0

						local iPointArray = iPointIndex + TF_TEAM_BLUE * MAX_CONTROL_POINTS
						flTimeOffset = flCapturePercent * GetPropFloatArray(hObjectiveResource, "m_flTeamCapTime", iPointArray)
					}
				}
			}

			if(bCapturing)
			{
				local iPointArray = iPointIndex + TF_TEAM_BLUE * MAX_CONTROL_POINTS
				SetPropIntArray(hObjectiveResource, "m_iTeamInZone", TF_TEAM_BLUE, iPointIndex)
				SetPropIntArray(hObjectiveResource, "m_iCappingTeam", TF_TEAM_BLUE, iPointIndex)

				flCapturePercent = 1 - (flTime + flTimeOffset - flTimeCapturing) / GetPropFloatArray(hObjectiveResource, "m_flTeamCapTime", iPointArray)
				SetPropFloatArray(hObjectiveResource, "m_flCapPercentages", flCapturePercent, iPointIndex)
				SetPropFloatArray(hObjectiveResource, "m_flLazyCapPerc", flCapturePercent, iPointIndex)
				if(flCapturePercent <= 0.0)
				{
					bCapturing = false
					bWaiting   = false

					hPoint.AcceptInput("SetOwner", format("%i", TF_TEAM_BLUE), null, self)
					for(local i = GetNumElements(hTrigger, "OnCapTeam2") - 1; i >= 0; i--)
					{
						local OutputTable = {}
						GetOutputTable(hTrigger, "OnCapTeam2", OutputTable, i)
						if(OutputTable.target == "!self") OutputTable.target = hTrigger.GetName()
						DoEntFire(OutputTable.target, OutputTable.input, OutputTable.parameter, OutputTable.delay, self, self)
					}

					SetPropIntArray(hObjectiveResource, "m_iTeamInZone", 0, iPointIndex)
					SetPropIntArray(hObjectiveResource, "m_iCappingTeam", 0, iPointIndex)

					SetPropFloat(self, "m_speed", flSpeedLast)
					CapturePoints.remove(0)
					if(CapturePoints.len() == 0)
					{
						bComplete = true
						self.SetSkin(1)
					}
				}
			}
		}
	}
	function OnDeath()
	{
		local iPointArray = iPointIndex + TF_TEAM_BLUE * MAX_CONTROL_POINTS
		if(bCapturing && hObjectiveResource.IsValid() && GetPropIntArray(hObjectiveResource, "m_iNumTeamMembers", iPointArray) == 0)
		{
			local iPointIndex         = iPointIndex
			local flCapPercentageLast = GetPropFloatArray(hObjectiveResource, "m_flCapPercentages", iPointIndex)
			SetPropIntArray(hObjectiveResource, "m_iTeamInZone", 0, iPointIndex)
			TankExt.DelayFunction(hObjectiveResource, null, (1 - flCapturePercent) * GetPropFloatArray(hObjectiveResource, "m_flTeamCapTime", iPointArray), function()
			{
				if(GetPropFloatArray(hObjectiveResource, "m_flCapPercentages", iPointIndex) == flCapPercentageLast)
					SetPropIntArray(hObjectiveResource, "m_iCappingTeam", 0, iPointIndex)
			})
		}
	}
})