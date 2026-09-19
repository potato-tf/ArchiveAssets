// This script can be used to disable some announcer voicelines that cannot otherwise
//  be modified without a soundscript override.
// It can be included in your popfile in Wave 1 and will apply for the rest of the mission.

// Example inclusion:
//  InitWaveOutput
//  {
//      Target BigNet
//      Action RunScriptCode
//      Param "IncludeScript(`wave_alerts.nut`, getroottable())"
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

const FLT_MIN = 1.175494e-38
const TF_DEATH_FEIGN_DEATH = 0x20

::WaveAlerts <-
{
	AllowAllDead = true
	AllowSpyUpdates = true

	CountdownWatchdog = null
	GamerulesProxy = Entities.FindByClassname(null, "tf_gamerules")
	ForceStartTime = -1.0

	function GetWaveIndex()
	{
		local mvm_stats = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")
		return NetProps.GetPropInt(mvm_stats, "m_iCurrentWaveIdx")
	}

	function CheckCountdownStartedWatchdog()
	{
		local restart_time = NetProps.GetPropFloat(GamerulesProxy, "m_flRestartRoundTime")
		if (restart_time < 0.0)
			return -1.0

		if (restart_time - Time() > 10.0)
			return -1.0

		ForceStartTime = restart_time

		AddThinkToEnt(CountdownWatchdog, "CountdownThink")
		CountdownThink()

		return -1.0
	}

	function CountdownThink()
	{
		// Don't allow the countdown to tick down naturally, so we can control the triggering of voicelines.
		NetProps.SetPropFloat(GamerulesProxy, "m_flRestartRoundTime", 0.0)

		if (ForceStartTime <= Time())
		{
			NetProps.SetPropFloat(GamerulesProxy, "m_flRestartRoundTime", FLT_MIN)
			ForceStartTime = -1.0

			CountdownWatchdog.Destroy()
			CountdownWatchdog = null
		}

		return -1.0
	}

	function OnGameEvent_player_death(params)
	{
		if (AllowAllDead)
			return

		if (params.death_flags & TF_DEATH_FEIGN_DEATH)
			return

		if (GetRoundState() != GR_STATE_RND_RUNNING)
			return

		local red_humans = []

		for (local i = MaxClients().tointeger(); i > 0; --i)
		{
			local player = PlayerInstanceFromIndex(i)
			if (!player)
				continue

			if (player.GetTeam() != TF_TEAM_RED)
				continue

			if (player.IsAlive() && params.victim_entindex != i)
				// If there is an alive RED player, then this voiceline won't play.
				// Note that the victim is still considered alive at this time.
				return

			if (player.IsBotOfType(TF_BOT_TYPE))
				continue

			red_humans.push(player)
		}

		foreach (human in red_humans)
			human.StopSound("Announcer.MVM_All_Dead")
	}

	function OnGameEvent_mvm_mission_update(params)
	{
		if (AllowSpyUpdates)
			return

		if (params["class"] != TF_CLASS_SPY)
			return

		local sound_string = params.count > 0 ? "Announcer.MVM_Spy_Alert" : "Announcer.mvm_spybot_death_all"

		for (local i = MaxClients().tointeger(); i > 0; --i)
		{
			local player = PlayerInstanceFromIndex(i)
			if (!player)
				continue

			if (player.IsBotOfType(TF_BOT_TYPE))
				continue

			player.StopSound(sound_string)
		}
	}

	function OnGameEvent_mvm_reset_stats(_)
	{
		CountdownWatchdog = null

		if (GetWaveIndex() != 0)
			return

		delete ::WaveAlerts
	}
}
__CollectGameEventCallbacks(WaveAlerts)

/**
 * Sets whether the announcer should speak an alert play whenever spy bots spawn.
 * Behaviour is allowed by default.
 * Note that other cosmetic effects related to spy spawns (such as the swoop animation) cannot be disabled.
 * @type {function}
 * @param {bool} allowed
 */
function WaveAlerts::SetAllowSpyUpdates(allowed)
{
	AllowSpyUpdates = allowed

	if (!allowed)
	{
		PrecacheScriptSound("Announcer.MVM_Spy_Alert")
		PrecacheScriptSound("Announcer.mvm_spybot_death_all")
	}
}

/**
 * Sets whether the announcer should speak a countdown when there are 10 seconds or less on the readymode timer.
 * Behaviour is allowed by default.
 * Note that the countdown timer on the HUD will also be disabled.
 * @type {function}
 * @param {bool} allowed
 */
function WaveAlerts::SetAllowWaveCountdown(allowed)
{
	if (CountdownWatchdog)
	{
		if (CountdownWatchdog.IsValid())
			CountdownWatchdog.Destroy()

		CountdownWatchdog = null
	}

	if (!allowed)
	{
		CountdownWatchdog = Entities.CreateByClassname("handle_dummy")
		NetProps.SetPropBool(CountdownWatchdog, "m_bForcePurgeFixedupStrings", true)

		CountdownWatchdog.ValidateScriptScope()
		local scope = CountdownWatchdog.GetScriptScope()

		scope.CheckCountdownStartedWatchdog <- CheckCountdownStartedWatchdog.bindenv(this)
		scope.CountdownThink <- CountdownThink.bindenv(this)

		AddThinkToEnt(CountdownWatchdog, "CheckCountdownStartedWatchdog")
	}
}

/**
 * Sets whether the announcer should announce when all players on RED team have died.
 * Behaviour is allowed by default.
 * @type {function}
 * @param {bool} allowed
 */
function WaveAlerts::SetAllowAllDead(allowed)
{
	AllowAllDead = allowed

	if (!allowed)
		PrecacheScriptSound("Announcer.MVM_All_Dead")
}
