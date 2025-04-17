// This is a special VScript file that will run before mapspawn.nut when using sigsegv-mvm
//  (https://github.com/rafradek/sigsegv-mvm/) with sig_util_vscript_load_init_scripts "1"
//  set.
// We use this file on Potato to apply both global and map-specific fixes and utility.
// We do not use mapspawn.nut for this, as it is a vanilla file that maps can include their
//  own version of which would overwrite this file.

::ROOT <- getroottable()
// Potato server namespace.
::__potato <- {

	MapName = GetMapName()
	MapName_len = GetMapName().len()

	ServerTags = null
	ScriptsBuffer = {}
	TestingServer = false

	// True if the sigsegv-mvm extension is active on the server.
	IsSigmod = Convars.GetInt("sig_etc_misc") != null

	// Preserved entity handles; we only need to grab them once as they are not reset
	//  between rounds.
	// Entities besides worldspawn need to be grabbed on a delay as they do not exist
	//  when this file is executed.
	hGamerules = null // tf_gamerules
	hObjRes    = null // tf_objective_resource
	hPlyrMgr   = null // tf_player_manager
	hWorldspawn = Entities.FindByClassname(null, "worldspawn") // worldspawn

	Events = {
		// Update ServerTags whenever sv_tags changes.
		function OnGameEvent_server_cvar(params) {
			if (params.cvarname != "sv_tags") return
			UpdateServerTags(params.cvarvalue)
		}

		function OnGameEvent_recalculate_holidays(_) {
			if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND)

			// TODO: This script should be modified to be integrated better with this file.
			EntFireByHandle(hWorldspawn,
				"RunScriptFile", "fb",
			-1, null, null)
		}
	}
}
::__potato.Events.setdelegate(::__potato)
__CollectGameEventCallbacks(::__potato.Events)

/**
 * Utility function which is called after map entities are spawned.
 */
function __potato::OnEntitiesSpawned() {

	// == GET PRESERVED HANDLES ==
	// Platform entities.
	//hBigNet     = Entities.FindByClassname(null, "ai_network")
	// TF2 entities.
	hGamerules = Entities.FindByClassname(null, "tf_gamerules")
	hPlyrMgr   = Entities.FindByClassname(null, "tf_player_manager")
	// MvM Entities.
	hObjRes    = Entities.FindByClassname(null, "tf_objective_resource")
	//hMVMStats  = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")
	//hPopulator = Entities.FindByClassname(null, "info_populator")
	// == END PRESERVED HANDLES ==

	// Validate scopes for preserved entities here as it only needs to be done once.
	hPlyrMgr.ValidateScriptScope()

	// Set TestingServer to true if this is a Potato testing server.
	UpdateServerTags()

	// Enable HL2 20th anniversary radial fog.
	Include("force_radial_fog")

	if (!TestingServer)
		// Scoreboard mission name formatter.
		// TODO: Include() needs negation ability to avoid including it separately here.
		Include("name_format", "potato")

	// Include any buffered tag-dependent scripts now.
	foreach (fp, include in ScriptsBuffer) {
		local nobreak = true
		foreach (tag in include[0]) {
			if (ServerTags.find(tag) == null) {
				nobreak = false
				break
			}
		}
		if (nobreak) {
			try {
				IncludeScript("potato/" + fp, include[1])
			} catch (e) {
				if (startswith(e, "Failed to include script \"potato/" + fp))
					continue
				throw e
			}
		}
	}
	delete ScriptsBuffer

	// MvM-only settings.
	if (NetProps.GetPropBool(hGamerules, "m_bPlayingMannVsMachine")) {
		// Suppress CVar change notifications for these which are always set by the game for MvM.
		Convars.SetValue("mp_tournament", 1)
		Convars.SetValue("mp_tournament_stopwatch", 0)

		// Spy bots are sometimes incredibly passive because once they finish lurking in a
		//  hiding spot, they will find a new hiding spot closer to the enemy's spawn.
		// In MvM, this is a problem because spies will not sap teleporters for the most part
		//  and will thus never get the chance to intercept players once they end up here.
		// This behaviour can probably be remedied by making spies to ChangeTo a new
		//  SpyAttack action once they lose patience with lurking instead of having them seek
		//  a new hiding spot.
		// For now, to see if we can make them more aggressive without detouring:
		//  Spy bots will keep retreating until they find cover; allow them to see all cover.
		Convars.SetValue("tf_bot_retreat_to_cover_range", 99999.0)
		//  Make spies to immediately exit cover once they find it.
		Convars.SetValue("tf_bot_wait_in_cover_max_time", 0.0)
		Convars.SetValue("tf_bot_wait_in_cover_min_time", 0.0)
	}
}

/**
 * Updates the ServerTags array, an array of strings containing tags from sv_tags.
 * Also updates variables dependent on ServerTags.
 *
 * @param string tags?          Tag string override (Default: Refers to sv_tags value).
 */
function __potato::UpdateServerTags(tags = null) {
	if (!tags)
		tags = Convars.GetStr("sv_tags")
	ServerTags = split(tags, ",")

	// Set TestingServer to true if this is a Potato testing server.
	TestingServer = ServerTags.find("testing") != null
}

/**
 * Includes a script file relative to "scripts/vscripts/potato/".
 * Does not throw an error if the inclusion failed.
 * Allows testing against sv_tags to conditionally include scripts.
 *
 * @param string fp             File to include, ".nut" extension is optional.
 * @param string|array tags?    Tag(s) to test against; all must be satisfied for inclusion to occur (Default: None).
 * @param table scope?          Scope to include the script in (Default: ROOT).
 */
function __potato::Include(fp, tags = null, scope = ROOT) {
	if (typeof tags == "string")
		tags = [tags]

	if (fp.find(".nut") == null)
		fp += ".nut"

	// If server tags cannot be checked yet, store scripts to include later.
	if (ServerTags == null && tags != null) {
		ScriptsBuffer[fp] <- [tags, scope]
		return
	}

	// Don't include scripts that we don't match the sv_tags for.
	if (tags != null)
		foreach (tag in tags)
			if (ServerTags.find(tag) == null)
				return

	// Catch script include errors so that other scripts can execute.
	try {
		IncludeScript("potato/" + fp, scope)
		return
	} catch (e) {
		// Must use startswith() here, sometimes an extra closing quote is added by the game.
		if (startswith(e, "Failed to include script \"potato/" + fp))
			return
		// If any other error is thrown (how?), re-throw it.
		throw e
	}
}

/**
 * Deletes the ::__potato namespace.
 * Can be used to reload the script.
 */
function __potato::Delete() {
	function keys_recurse(container) {
		foreach (v in container)
			if (typeof v == "table" || typeof v == "array") {
				keys_recurse(v)
				if (typeof v == "table") v.setdelegate(null)
			}
	}
	keys_recurse(::__potato)
	delete ::__potato
}

// You can run script code after entities first spawn with this pattern.
EntFireByHandle(::__potato.hWorldspawn, "RunScriptCode",
	"::__potato.OnEntitiesSpawned()",
-1, null, null)

if (::__potato.IsSigmod) {
	// Extended ugrades refund cash exploit fix.
	::__potato.Include("temp_refund_exploit_fix")
}

// Disables respawn text on missions with no respawns.
::__potato.Include("hide_respawntext")
// Map-specific bug fixes.
::__potato.Include("map_fixes")
// Cosmetic stretching fixes.
::__potato.Include("vacc_hothand_fix")
// Gas nerf.
::__potato.Include("gas_nerf")
// All Chat
::__potato.Include("allchat")

// Testing server VScript debug tools.
::__potato.Include("debug_tools", "testing")
// Judging Restrictions.
::__potato.Include("judging", "judging")

// These scripts are not included in ArchiveAssets.
// TODO: These scripts should be modified to be integrated better with this file.
// Contract progress tracker.
try IncludeScript("contracts.nut") catch (_) {}
// StringToFile() server syncing.
try IncludeScript("stringtofile.nut") catch (_) {}
// VScript-Python interface.
try IncludeScript("vpi/vpi.nut") catch (_) {}
