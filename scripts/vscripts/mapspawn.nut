// This is a special VScript file that will run before mapspawn.nut when using sigsegv-mvm
//  (https://github.com/rafradek/sigsegv-mvm/) with sig_util_vscript_load_init_scripts "1"
//  set.
// We use this file on Potato to apply both global and map-specific fixes and utility.
// We do not use mapspawn.nut for this, as it is a vanilla file that maps can include their
//  own version of which would overwrite this file.

// Potato server namespace.
::__potato <- {
	//ROOT = getroottable()

	MapName = GetMapName()
	MapName_len = GetMapName().len()

	ServerTags = null
	TestingServer = false

	// True if the sigsegv-mvm extension is active on the server.
	IsSigmod = Convars.GetInt("sig_etc_misc") != null ? true : false

	// Preserved entity handles; we only need to grab them once as they are not reset
	//  between rounds.
	// Entities besides worldspawn need to be grabbed on a delay as they do not exist
	//  when this file is executed.
	hGamerules = null // tf_gamerules
	hObjRes    = null // tf_objective_resource
	hPlyrMgr   = null // tf_player_manager
	hWorldspawn = Entities.FindByClassname(null, "worldspawn") // worldspawn
}

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

	// Set these variables after servercfgfile is executed.
	ServerTags = split(Convars.GetStr("sv_tags"), ",")
	if (ServerTags.find("testing") != null)
		TestingServer = true
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

// These scripts are in the game-servers repo, not ArchiveAssets.
IncludeScript("stringtofile.nut")
IncludeScript("contracts.nut")

// The modules here can be found in the "vscripts/potato" folder.
// They are not dependent on each other.

// Map-specific bug fixes.
IncludeScript("potato/map_fixes.nut")
// Auto-formats the scoreboard mission name.
IncludeScript("potato/name_format.nut")
// Disables respawn text on missions with no respawns.
IncludeScript("potato/hide_respawntext.nut")

// Stricter VScript rules used on the testing servers.
//IncludeScript("potato/script_rules.nut")
// Judging feedback tools used on the testing servers.
//IncludeScript("potato/judge_feedback.nut")
