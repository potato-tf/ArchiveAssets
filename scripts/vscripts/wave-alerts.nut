// This script can be used to disable some announcer voicelines that cannot otherwise
//  be modified without a soundscript override.
// It can be included in your popfile in Wave 1 and will apply for the rest of the mission.

// Example inclusion:
//  InitWaveOutput
//  {
//      Target BigNet
//      Action RunScriptCode
//      Param "IncludeScript(`wave-alerts.nut`, getroottable())"
//  }

// Feel free to report any bugs or feature requests regarding this script to fellen.

local CONST = getconsttable()
local ROOT = getroottable()
if (!("ConstantNamingConvention" in ROOT))
{
	foreach (enum_table in Constants)
	{
		foreach (name, value in enum_table)
		{
			if (value == null)
				value = 0

			CONST[name] <- value
			ROOT[name] <- value
		}
	}
}

::WaveAlerts <-
{
	mvm_stats = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")

	AllowSpyUpdates = true

	function SetAllowSpyUpdates(/* bool */ allowed) /* -> null */
	{
		AllowSpyUpdates = allowed

		if (!allowed)
		{
			PrecacheScriptSound("Announcer.MVM_Spy_Alert")
			PrecacheScriptSound("Announcer.mvm_spybot_death_all")
		}
	}

	function OnGameEvent_mvm_mission_update(params)
	{
		if (AllowSpyUpdates)
			return
		
		if (params["class"] != TF_CLASS_SPY)
			return

		local sound_string = params.count > 0 ? "Announcer.MVM_Spy_Alert" : "Announcer.mvm_spybot_death_all"

		for (local i = MaxClients().tointeger(); --i;)
		{
			local player = PlayerInstanceFromIndex(i)
			if (!player || player.IsBotOfType(TF_BOT_TYPE))
				continue

			player.StopSound(sound_string)
		}
	}
	
	function OnGameEvent_stats_resetround(_)
	{
		if (GetRoundState() != GR_STATE_PREROUND)
			return

		if (NetProps.GetPropInt(mvm_stats, "m_iCurrentWaveIdx") != 0)
			return

		delete ::WaveAlerts
	}
}
__CollectGameEventCallbacks(WaveAlerts)
