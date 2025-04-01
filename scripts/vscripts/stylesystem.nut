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

if("StyleSystem" in ROOT)
	StyleSystem.Cleanup()

if(!("StyleSystemHideRankPlayerSteamIDs" in ROOT))
	::StyleSystemHideRankPlayerSteamIDs <- []

::StyleSystem <- {
	function Cleanup()
	{
		if(hText && hText.IsValid())
			hText.Kill()
		
		ShowRankImage(null)
		
		delete ::StyleSystem
	}
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) Cleanup() }

	hText = SpawnEntityFromTable("game_text", {
		holdtime = 1
		spawnflags = 1
	})
	iRank = 0
	iScore = 0
	bActive = false
	bHideText = false

	CallbackTable = {}
	function SetCallbacks(Table)
	{
		local ValidKeyvalues = [ "All", "DRank", "CRank", "BRank", "ARank", "SRank", "PRank" ]
		foreach(k,v in Table)
			if(ValidKeyvalues.find(k) != null)
				CallbackTable[k] <- v
			else ClientPrint(null, 3, format("\x07ffff00[StyleSystem] ERROR: StyleSystem.SetCallbacks found invalid keyvalue: \x07ff7700\"%s\"\x07ffff00", k))
	}

	ParamsTable = {
		Tank              = 200
		Tank_TextColor    = "80 220 80"
		Tank_TextSize     = 35
		Tank_TextDuration = 5

		Boss              = 200
		Boss_MinHealth    = 10000
		Boss_TextColor    = "80 220 80"
		Boss_TextSize     = 35
		Boss_TextDuration = 5

		Giant              = 100
		Giant_TextColor    = "80 220 80"
		Giant_TextSize     = 25
		Giant_TextDuration = 2.5

		MiniGiant              = 50
		MiniGiant_MinHealth    = 450
		MiniGiant_TextColor    = "80 220 80"
		MiniGiant_TextSize     = 15
		MiniGiant_TextDuration = 1.5

		Common              = 25
		Common_TextColor    = "80 220 80"
		Common_TextSize     = 10
		Common_TextDuration = 1

		Player              = -200
		Player_TextColor    = "220 80 80"
		Player_TextSize     = 20
		Player_TextDuration = 5

		PRank = 20000
		SRank = 17600
		ARank = 8800
		BRank = 4400
		CRank = 2200
	}
	function SetParams(Table)
	{
		foreach(k,v in Table)
			if(k in ParamsTable)
			{
				if(typeof ParamsTable[k] == typeof v)
					ParamsTable[k] = v
				else ClientPrint(null, 3, format("\x07ffff00[StyleSystem] ERROR: StyleSystem.SetParams keyvalue \x07ff7700\"%s\"\x07ffff00 is type \x07ff7700%s\x07ffff00, expected type \x07ff7700%s", k, typeof v, typeof ParamsTable[k]))
			}
			else ClientPrint(null, 3, format("\x07ffff00[StyleSystem] ERROR: StyleSystem.SetParams found invalid keyvalue: \x07ff7700\"%s\"\x07ffff00", k))
	}

	function AddPoints(Value, vecOrigin = null)
	{
		if(Value == null) return
		if(vecOrigin != null)
		{
			local sValue     = Value.tostring()
			local sColor     = "80 220 80"
			local flTextSize = 25
			local flDuration = 2
			if(Value in ParamsTable)
			{
				sValue     = ParamsTable[Value].tostring()
				sColor     = ParamsTable[format("%s_TextColor", Value)]
				flTextSize = ParamsTable[format("%s_TextSize", Value)]
				flDuration = ParamsTable[format("%s_TextDuration", Value)]
			}

			local hText = SpawnEntityFromTable("point_worldtext", {
				origin      = vecOrigin
				color       = sColor
				textsize    = flTextSize
				message     = sValue
				font        = 1
				orientation = 1
			})
			SetPropBool(hText, "m_bForcePurgeFixedupStrings", true)

			local flTime = Time()
			local flTimeEndFade = flTime + flDuration
			local flTimeStartFade = flTimeEndFade - 1
			if(flTimeEndFade < flTime)
				flTimeEndFade = flTime
			local flTimeFadeDist = flTimeEndFade - flTimeStartFade
			
			hText.ValidateScriptScope()
			local hText_scope = hText.GetScriptScope()
			hText_scope.Think <- function()
			{
				local flTime = Time()
				if(flTime >= flTimeStartFade)
				{
					local flAlpha = ((flTimeEndFade - flTime.tofloat()) / flTimeFadeDist) * 255
					self.AcceptInput("SetColor", format("%s %i", sColor, flAlpha), null, null)
				}
				self.SetAbsOrigin(self.GetOrigin() + Vector(0, 0, 0.25))
				if(flTime >= flTimeEndFade) self.Kill()
				return -1
			}
			AddThinkToEnt(hText, "Think")
		}

		if(typeof Value == "string")
			Value = ParamsTable[Value]
		iScore += Value
		if(iScore < 0) iScore = 0
	}
	function OnGameEvent_player_death(params)
	{
		if(bActive && !(params.death_flags & 32))
		{
			local sScoreType
			local hVictim = GetPlayerFromUserID(params.userid)
			local hAttacker = GetPlayerFromUserID(params.attacker)
			local iTeamNumVictim = hVictim ? hVictim.GetTeam() : -1
			local iTeamNumAttacker = hAttacker ? hAttacker.GetTeam() : -1
			if(hVictim.IsBotOfType(TF_BOT_TYPE))
			{
				if(hVictim.HasBotTag("bot_nopoints")) return
				if(iTeamNumVictim != 2 && iTeamNumVictim != iTeamNumAttacker)
				{
					local iMaxHealth = hVictim.GetMaxHealth()
					if(iMaxHealth >= ParamsTable.Boss_MinHealth)
						sScoreType = "Boss"
					else if(hVictim.IsMiniBoss())
						sScoreType = "Giant"
					else if(iMaxHealth >= ParamsTable.MiniGiant_MinHealth)
						sScoreType = "MiniGiant"
					else
						sScoreType = "Common"
				}
			}
			else
				sScoreType = "Player"

			if(sScoreType != null)
				AddPoints(sScoreType, hVictim.GetOrigin() + Vector(0, 0, hVictim.GetBoundingMaxs().z))
		}
	}
	function OnGameEvent_mvm_tank_destroyed_by_players(_)
	{
		if(bActive)
		{
			local bTank = false
			for(local hTank; hTank = FindByClassname(hTank, "tank_boss");)
			{
				if(hTank.GetHealth() <= 0)
				{
					bTank = true
					AddPoints("Tank", hTank.GetCenter())
					break
				}
			}
			if(!bTank)
				AddPoints("Tank")
		}
	}
	
	function SetActive(bool)
	{
		if(bool)
		{
			if(!bActive)
			{
				bActive = bool
				iScore = 0
				SetPropBool(hText, "m_bForcePurgeFixedupStrings", true)
				hText.ValidateScriptScope()
				local hText_scope = hText.GetScriptScope()
				hText_scope.Think <- function()
				{
					StyleSystem.Think()
					return -1
				}
				AddThinkToEnt(hText, "Think")
			}
		}
		else if(bActive)
		{
			bActive = bool
			AddThinkToEnt(hText, null)
			hText.TerminateScriptScope()
			ShowRankImage(null)
			SetPropString(hText, "m_iszMessage", "")
			hText.KeyValueFromInt("channel", 4)
			hText.AcceptInput("Display", null, null, null)
			hText.KeyValueFromInt("channel", 5)
			hText.AcceptInput("Display", null, null, null)
		}
	}

	function ShowRankImage(Index)
	{
		local sRankImage
		switch(Index)
		{
			case 0:
				sRankImage = "hud/scorerank_d"
				break
			case 1:
				sRankImage = "hud/scorerank_c"
				break
			case 2:
				sRankImage = "hud/scorerank_b"
				break
			case 3:
				sRankImage = "hud/scorerank_a"
				break
			case 4:
				sRankImage = "hud/scorerank_s"
				break
			case 5:
				sRankImage = "hud/scorerank_p"
				break
		}
		for(local i = 1; i <= MAX_CLIENTS; i++)
		{
			local hPlayer = PlayerInstanceFromIndex(i)
			if(hPlayer && !hPlayer.IsFakeClient() && (StyleSystemHideRankPlayerSteamIDs.find(GetPropString(hPlayer, "m_szNetworkIDString")) == null || sRankImage == null))
				hPlayer.SetScriptOverlayMaterial(sRankImage)
		}
	}

	function OnGameEvent_player_say(params)
	{
		if(params.text.tolower().find("!hiderank") == 0)
		{
			local hPlayer = GetPlayerFromUserID(params.userid)
			local sPlayerID = GetPropString(hPlayer, "m_szNetworkIDString")
			local iPlayerIDIndex = StyleSystemHideRankPlayerSteamIDs.find(sPlayerID)
			if(iPlayerIDIndex == null)
			{
				StyleSystemHideRankPlayerSteamIDs.append(sPlayerID)
				hPlayer.SetScriptOverlayMaterial(null)
			}
			else
				StyleSystemHideRankPlayerSteamIDs.remove(iPlayerIDIndex)
		}
	}

	function Think()
	{
		local sRankImage, iCurrentRank

		if(iScore < ParamsTable.CRank) iCurrentRank = 0
		else if(iScore < ParamsTable.BRank)	iCurrentRank = 1
		else if(iScore < ParamsTable.ARank)	iCurrentRank = 2
		else if(iScore < ParamsTable.SRank)	iCurrentRank = 3
		else if(iScore < ParamsTable.PRank)	iCurrentRank = 4
		else iCurrentRank = 5
		
		if(iRank != iCurrentRank)
		{
			iLastRank <- iRank
			iRank = iCurrentRank
			if("All" in CallbackTable) CallbackTable.All()
			switch(iCurrentRank)
			{
				case 0:
					if("DRank" in CallbackTable) CallbackTable.DRank()
					break
				case 1:
					if("CRank" in CallbackTable) CallbackTable.CRank()
					break
				case 2:
					if("BRank" in CallbackTable) CallbackTable.BRank()
					break
				case 3:
					if("ARank" in CallbackTable) CallbackTable.ARank()
					break
				case 4:
					if("SRank" in CallbackTable) CallbackTable.SRank()
					break
				case 5:
					if("PRank" in CallbackTable) CallbackTable.PRank()
					break
			}
			delete iLastRank
		}

		ShowRankImage(iRank)

		if(!bHideText)
		{
			local DisplayText = function(message, color, channel, x, y)
			{
				if(message) SetPropString(hText, "m_iszMessage", message)
				if(color)   hText.KeyValueFromString("color", color)
				if(channel) hText.KeyValueFromInt("channel", channel)
				if(x)       hText.KeyValueFromFloat("x", x)
				if(y)       hText.KeyValueFromFloat("y", y)
				hText.AcceptInput("Display", null, null, null)
			}
			
			local iScoreLength = iScore.tostring().len()
			DisplayText("00000".slice(iScoreLength > 5 ? 5 : iScoreLength) + iScore, "255 255 255", 5, 0.375, 0.78)
			if(iRank != 5)
			{
				local iScoreNext = [ ParamsTable.CRank, ParamsTable.BRank, ParamsTable.ARank, ParamsTable.SRank, ParamsTable.PRank ][iRank]
				local iScoreNextLength = iScoreNext.tostring().len()
				DisplayText("00000".slice(iScoreNextLength > 5 ? 5 : iScoreNextLength) + iScoreNext, "255 255 0", 4, 0.375, 0.75)
			}
		}
		return -1
	}
}
__CollectGameEventCallbacks(StyleSystem)