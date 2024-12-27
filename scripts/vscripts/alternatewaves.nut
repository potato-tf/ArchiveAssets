// lite

::ROOT <- getroottable()
::MAX_CLIENTS <- MaxClients().tointeger()

if (!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

::MVM_CLASS_FLAG_NONE            <- 0
::MVM_CLASS_FLAG_NORMAL          <- 1
::MVM_CLASS_FLAG_SUPPORT         <- 2
::MVM_CLASS_FLAG_MISSION         <- 4
::MVM_CLASS_FLAG_MINIBOSS        <- 8
::MVM_CLASS_FLAG_ALWAYSCRIT      <- 16
::MVM_CLASS_FLAG_SUPPORT_LIMITED <- 32
::MVM_CLASS_MAX                  <- 23

::AlternateWaves <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) { delete ::AlternateWaves } }
	function OnGameEvent_mvm_wave_complete(_) { CurrentWaveIcons = null }
	function OnGameEvent_mvm_begin_wave(_)
	{
		if(typeof CurrentWaveIcons == "array")
			AddWaveIcons(CurrentWaveIcons)
	}
	function OnGameEvent_player_death(params)
	{
		if(!bTrackIcons) return
		local hPlayer = GetPlayerFromUserID(params.userid)
		if(CurrentWaveIcons != null && hPlayer && hPlayer.IsBotOfType(TF_BOT_TYPE))
		{
			local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
			local iTotalBots = 0
			IterateIcons(function(iIcon, sNames, sCounts, sFlags)
			{
				local iFlags = GetPropIntArray(hObjectiveResource, sFlags, iIcon)
				if(iFlags & (MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_MINIBOSS) && !(iFlags & (MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_MISSION)))
					iTotalBots += GetPropIntArray(hObjectiveResource, sCounts, iIcon)
			})
			if(iTotalBots <= 0)
				EntFire("point_populator_interface", "$ResumeWavespawn", "endwave", -1)
		}
	}
	CurrentWaveIcons = null
	bTrackIcons = true

	function IterateIcons(func)
	{
		for(local iIcon = 0; iIcon <= MVM_CLASS_MAX; iIcon++)
		{
			local iIcon = iIcon

			local bTwo = iIcon > 11
			if(bTwo) iIcon -= 12
			local sTwo = bTwo ? "2." : "."

			local sNames = format("m_iszMannVsMachineWaveClassNames%s", sTwo)
			local sCounts = format("m_nMannVsMachineWaveClassCounts%s", sTwo)
			local sFlags = format("m_nMannVsMachineWaveClassFlags%s", sTwo)

			func(iIcon, sNames, sCounts, sFlags)
		}
	}
	function AddWaveIcons(array)
	{
		local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
		local IconList = []
		CurrentWaveIcons = array

		IterateIcons(function(iIcon, sNames, sCounts, sFlags) { IconList.append(GetPropStringArray(hObjectiveResource, sNames, iIcon)) })

		local iEnemyCount = 0
		foreach(Params in array)
		{
			local iIcon = IconList.find(Params[0])
			if(iIcon == null) iIcon = IconList.find("")
			if(iIcon == null) return
			IconList[iIcon] = Params[0]

			local bTwo = iIcon > 11
			if(bTwo) iIcon -= 12
			local sTwo = bTwo ? "2." : "."

			local sNames = format("m_iszMannVsMachineWaveClassNames%s", sTwo)
			local sCounts = format("m_nMannVsMachineWaveClassCounts%s", sTwo)
			local sFlags = format("m_nMannVsMachineWaveClassFlags%s", sTwo)

			SetPropStringArray(hObjectiveResource, sNames, Params[0], iIcon)
			SetPropIntArray(hObjectiveResource, sCounts, GetPropIntArray(hObjectiveResource, sCounts, iIcon) + Params[1], iIcon)
			SetPropIntArray(hObjectiveResource, sFlags, Params[2], iIcon)
			if(!(Params[2] & (MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_MISSION)))
				iEnemyCount += Params[1]
		}
		SetPropInt(hObjectiveResource, "m_nMannVsMachineWaveEnemyCount", GetPropInt(hObjectiveResource, "m_nMannVsMachineWaveEnemyCount") + iEnemyCount)
	}
	function ClearWaveIcons()
	{
		local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
		CurrentWaveIcons = null
		IterateIcons(function(iIcon, sNames, sCounts, sFlags)
		{
			SetPropStringArray(hObjectiveResource, sNames, "", iIcon)
			SetPropIntArray(hObjectiveResource, sCounts, 0, iIcon)
			SetPropIntArray(hObjectiveResource, sFlags, 0, iIcon)
		})
		SetPropInt(hObjectiveResource, "m_nMannVsMachineWaveEnemyCount", 0)
	}

	function SetWaveCount(iWave, iMaxWaves = null)
	{
		local hObjectiveResource = FindByClassname(null, "tf_objective_resource")
		if(iWave != null)
			SetPropInt(hObjectiveResource, "m_nMannVsMachineWaveCount", iWave)
		if(iMaxWaves != null)
			SetPropInt(hObjectiveResource, "m_nMannVsMachineMaxWaveCount", iMaxWaves)
	}
}
__CollectGameEventCallbacks(AlternateWaves)