// Script for keeping a given bot at 1 health, for fancy purposes.
// Written by Seelpit
// Template & info provided by ficool2


//Simplifying references to constants and NetProps.
//Credit: VDC wiki, lite.
::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			if (v == null)
				ROOT[k] <- 0;
			else
				ROOT[k] <- v;
}

foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps);
	
const OVERLAY_BUDDHA_MODE = 0x02000000

for (local i = 1; i <= MaxClients().tointeger() ; i++)
{
	local player = PlayerInstanceFromIndex(i)
	SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
}

::BuddhaScript <-
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
		for (local i = 1; i <= MaxClients().tointeger() ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			AddThinkToEnt(player,null)
			SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
		}
        // keep this at the end
		printl("Cleaned up BuddhaScript.")
        delete ::BuddhaScript
    }
	// mandatory events
	OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
	OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
	
	CTFPlayer_EnableBuddha = function()
	{
		SetPropInt(this, "m_debugOverlays", GetPropInt(this, "m_debugOverlays") | OVERLAY_BUDDHA_MODE)
	}
	CTFPlayer_DisableBuddha = function()
	{
		SetPropInt(this, "m_debugOverlays", GetPropInt(this, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
	}
}

//Wrapper template by ficool2.
foreach (k,v in BuddhaScript)
{
	if (typeof(v) == "function" && startswith(k, "CTFPlayer_"))
	{
		local func_name = k.slice(10);
		CTFPlayer[func_name] <- v;
		CTFBot[func_name] <- v;
		delete BuddhaScript[k];
	}
}

__CollectGameEventCallbacks(BuddhaScript);