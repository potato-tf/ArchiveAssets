local ROOT = getroottable()

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

if("TextualTimer" in ROOT && TextualTimer.hText && TextualTimer.hText.IsValid()) return

local DefaultCallbacks = {
	[0] = function()
	{
		local hRelay = FindByName(null, sRelay)
		if(hRelay && hRelay.GetClassname() == "logic_relay")
			hRelay.AcceptInput("Trigger", null, null, null)
		else
		{
			local MAX_CLIENTS = MaxClients().tointeger()
			for(local i = 1; i <= MAX_CLIENTS; i++)
			{
				local hPlayer = PlayerInstanceFromIndex(i)
				if(hPlayer && !hPlayer.IsFakeClient())
				{
					SpawnEntityFromTable("game_round_win", { teamnum = hPlayer.GetTeam() == 2 ? 3 : 2, force_map_reset = 1 }).AcceptInput("RoundWin", null, null, null)
					ClientPrint(null, 4, "Wave Failed...")
					break
				}
			}
		}
	}
}

::TextualTimer <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) delete ::TextualTimer }

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
		if(bPaused)
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
		foreach(key, value in Table)
		{
			switch(key)
			{
				case "minutes":
					flNewTime += value.tofloat() * 60
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
		if(flNewTime > 0) flTimeDuration = flNewTime
	}
	function AddCallbacks(Table)
	{
		foreach(Keyvalue, Callback in Table)
			TimerCallbacks[Keyvalue == "all" ? Keyvalue : Keyvalue.tointeger()] <- Callback
	}
	function RemoveCallbacks(Array)
	{
		foreach(Keyvalue in Array)
		{
			if(Keyvalue != "all") Keyvalue = Keyvalue.tointeger()
			if(Keyvalue in TimerCallbacks)
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

	hText = SpawnEntityFromTable("game_text", {
		targetname = "textualtimer"
		channel    = 5
		holdtime   = 1
		spawnflags = 1
		x          = -1
		y          = 0.77
	})

	function Think()
	{
		if(bActive)
		{
			local flTime = Time()
			local GetTimeRemaining = @() ceil(flTimeEnd - (bPaused ? flTimePauseStart : flTime)).tointeger()
			local iTimeRemaining = GetTimeRemaining()
			if(iTimeRemaining < 0) iTimeRemaining = 0
			local iMinutes = iTimeRemaining / 60
			local iSeconds = iTimeRemaining % 60
			local sZero = iSeconds < 10 ? "0" : ""
			SetPropString(hText, "m_iszMessage", format("%s%i:%s%i%s", sTextPrefix, iMinutes, sZero, iSeconds, sTextSuffix))
			if(!bHideText)
				hText.AcceptInput("Display", null, null, null)

			if(flTimeTarget == -1)
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
				if(hText.KeyValueFromString("color", iDir == 1 ? sColorNegative : sColorPositive))
				flTimeEnd += iDir
				iTimeRemaining = GetTimeRemaining()
				if(iDir == 1 ? iTimeRemaining > flTimeTarget : iTimeRemaining < flTimeTarget)
				{
					hText.KeyValueFromString("color", sColor)
					flTimeEnd = flTime + flTimeTarget
					flTimePauseStart = flTime
					flTimeTarget = -1
				}
			}
			iTimeRemainingLast = iTimeRemaining
		}
	}
}
__CollectGameEventCallbacks(TextualTimer)

TextualTimer.hText.KeyValueFromString("color", TextualTimer.sColor)
TextualTimer.hText.ValidateScriptScope()
TextualTimer.hText.GetScriptScope().Think <- function()
{
	if("TextualTimer" in ROOT)
		TextualTimer.Think()
	return -1
}
AddThinkToEnt(TextualTimer.hText, "Think")