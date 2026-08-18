if ("TextualTimer" in getroottable() && TextualTimer.hText && TextualTimer.hText.IsValid())
	TextualTimer.Destroy()

const SF_ENVTEXT_ALLPLAYERS = 0x1

local DefaultCallbacks = {
	[0] = function()
	{
		local hRelay = Entities.FindByName(null, sRelay)
		if (hRelay && hRelay.GetClassname() == "logic_relay")
			hRelay.AcceptInput("Trigger", "", null, null)
		else
		{
			for(local i = MaxClients().tointeger(); i > 0; i--)
			{
				local hPlayer = PlayerInstanceFromIndex(i)

				if (!hPlayer || hPlayer.IsFakeClient())
					continue

				local win = SpawnEntityFromTable("game_round_win",
				{
					teamnum = hPlayer.GetTeam() == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED,
					force_map_reset = true
				})
				NetProps.SetPropBool(win, "m_bForcePurgeFixedupStrings", true)
				win.AcceptInput("RoundWin", "", null, null)

				ClientPrint(null, HUD_PRINTCENTER, "Wave Failed...")
				break
			}
		}
	}
}

::TextualTimer <- {
	function OnGameEvent_mvm_reset_stats(_)
	{
		delete ::TextualTimer
	}
	function OnGameEvent_mvm_begin_wave(_)
	{
		if(bAuto) Start()
	}
	function OnGameEvent_mvm_wave_complete(_)
	{
		if(bAuto) End()
	}

	function Start()
	{
		local flTime = Time()
		flTimeEnd = flTime + flTimeDuration
		flTimePauseStart = flTime
		bActive = true
	}

	function Pause()
	{
		if (bPaused)
		{
			flTimeEnd += Time() - flTimePauseStart
			bPaused = false
		}
		else
		{
			bPaused = true
			flTimePauseStart = Time()
		}
	}
	function End()
	{
		bActive = false
	}
	function Set(iTime)
	{
		flTimeTarget = iTime
	}
	function Add(iTime, iSecondsCap = 0)
	{
		iTime += iTimeRemainingLast
		if(iSecondsCap > 0 && iTime > iSecondsCap)
			iTime = iSecondsCap
		Set(iTime)
	}
	function SetParams(Table)
	{
		local flNewTime = 0
		foreach (key, value in Table)
		{
			switch (key)
			{
				case "minutes":
					flNewTime += value.tofloat() * 60.0
					break
				case "seconds":
					flNewTime += value.tofloat()
					break
				case "x":
					hText.KeyValueFromFloat("x", value.tofloat())
					break
				case "y":
					hText.KeyValueFromFloat("y", value.tofloat())
					break
				case "color":
					hText.KeyValueFromString("color", value)
					sColor = value
					break
				case "color_positive":
					sColorPositive = value
					break
				case "color_negative":
					sColorNegative = value
					break
				case "relayname":
					sRelay = value
					break
				case "automatic":
					bAuto = value
					break
				case "text_prepend":
					sTextPrefix = value
					break
				case "text_append":
					sTextSuffix = value
					break
			}
		}
		if (flNewTime > 0) flTimeDuration = flNewTime
	}
	function AddCallbacks(Table)
	{
		foreach (Keyvalue, Callback in Table)
			TimerCallbacks[Keyvalue == "all" ? Keyvalue : Keyvalue.tointeger()] <- Callback
	}
	function RemoveCallbacks(Array)
	{
		foreach (Keyvalue in Array)
		{
			if (Keyvalue != "all") Keyvalue = Keyvalue.tointeger()
			if (Keyvalue in TimerCallbacks)
				delete TimerCallbacks[Keyvalue]
		}
	}
	function ClearCallbacks()
	{
		TimerCallbacks.clear()
		TimerCallbacks = clone DefaultCallbacks
	}

	sRelay             = ""
	sTextPrefix        = ""
	sTextSuffix        = ""
	sColor             = "0 255 255"
	sColorPositive     = "255 0 0"
	sColorNegative     = "0 255 0"
	flTimeDuration     = 900
	flTimePauseStart   = 0
	flTimeEnd          = 0
	flTimeTarget       = -1
	iTimeRemainingLast = 0
	bActive            = false
	bPaused            = false
	bHideText          = false
	bAuto              = true
	TimerCallbacks     = clone DefaultCallbacks

	hText = null

	function Think()
	{
		if (bActive)
		{
			local flTime = Time()
			local GetTimeRemaining = @() ceil(flTimeEnd - (bPaused ? flTimePauseStart : flTime)).tointeger()
			local iTimeRemaining = GetTimeRemaining()
			if (iTimeRemaining < 0) iTimeRemaining = 0
			local iMinutes = iTimeRemaining / 60
			local iSeconds = iTimeRemaining % 60
			hText.KeyValueFromString("message", format("%s%i:%02i%s", sTextPrefix, iMinutes, iSeconds, sTextSuffix))

			if (!bHideText)
				hText.AcceptInput("Display", "", null, null)

			if (flTimeTarget == -1.0)
			{
				if(iTimeRemainingLast != iTimeRemaining)
				{
					if("all" in TimerCallbacks)
						TimerCallbacks.all.call(this)
					if(iTimeRemaining in TimerCallbacks)
						TimerCallbacks[iTimeRemaining].call(this)
				}
			}
			else
			{
				local iDir = iTimeRemaining < flTimeTarget ? 1 : -1
				hText.KeyValueFromString("color", iDir == 1 ? sColorNegative : sColorPositive)
				flTimeEnd += iDir
				iTimeRemaining = GetTimeRemaining()
				if (iDir == 1 ? iTimeRemaining > flTimeTarget : iTimeRemaining < flTimeTarget)
				{
					hText.KeyValueFromString("color", sColor)
					flTimeEnd = flTime + flTimeTarget
					flTimePauseStart = flTime
					flTimeTarget = -1.0
				}
			}
			iTimeRemainingLast = iTimeRemaining
		}
		return -1.0
	}
}
__CollectGameEventCallbacks(TextualTimer)

TextualTimer.hText = SpawnEntityFromTable("game_text",
{
	targetname = "textualtimer",
	channel    = 5,
	holdtime   = 1.0,
	spawnflags = SF_ENVTEXT_ALLPLAYERS,
	x          = -1.0,
	y          = 0.77
})
NetProps.SetPropBool(TextualTimer.hText, "m_bForcePurgeFixedupStrings", true)

TextualTimer.hText.KeyValueFromString("color", TextualTimer.sColor)

TextualTimer.hText.ValidateScriptScope()
TextualTimer.hText.GetScriptScope().Think <- TextualTimer.Think.bindenv(TextualTimer)
AddThinkToEnt(TextualTimer.hText, "Think")
