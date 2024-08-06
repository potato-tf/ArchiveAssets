// "scripts/vscripts/mapspawn.nut" is executed by the game once every map spawn.
// Potato uses it to apply various global fixes for every map and mission.
// You can use this pattern to test if your mission is running on a Potato event server:
//   IsPotato = "__potato" in getroottable()
::__potato <- {
    // Miscellaneous variables
    //  Is the server using sigsegv-mvm? https://github.com/rafradek/sigsegv-mvm/
    //  Should always return true on Potato for the foreseeable future.
    IsSigmod = Convars.GetInt("sig_color_console") != null ? true : false
    //  Length of the current map name.
    len_mapname = GetMapName().len()

    // Preserved entity handles; we only need to grab them once.
    gamerules = null    // tf_gamerules
    objres = null   // tf_objective_resource
    plyrmgr = null  // tf_player_manager

    // mapspawn.nut executes too early to grab entities immediately.
    function PopulatePreservedEnts() {
        gamerules = Entities.FindByClassname(null, "tf_gamerules")
        objres = Entities.FindByClassname(null, "tf_objective_resource")
        plyrmgr = Entities.FindByClassname(null, "tf_player_manager")
        plyrmgr.ValidateScriptScope()
    }
}

EntFire("worldspawn", "RunScriptCode", "__potato.PopulatePreservedEnts()")

IncludeScript("potato/mapfixes.nut")    // Fixes for the base versions of some maps on Potato.
IncludeScript("potato/nameformatter.nut")   // Automatically formats the mission display name.
IncludeScript("potato/hiderespawntext.nut") // Hides "Respawn in: ..." text while dead for missions with no respawns.
