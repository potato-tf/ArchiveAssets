// mapspawn.nut is executed by the game once every map spawn.
::__potato <- {
    // Seconds to delay before formatting the mission display name
    //  If the mission name is changed in this window, no automatic formatting occurs.
    FormatNameDelay = 1.0
    // Time before SM plugin reloads the current mission
    PluginReloadDelay = 10.0

    // Entity handles
    objres = null
    popscript = null

    len_mapname = GetMapName().len()
    IsSigmod = Convars.GetInt("sig_color_console") != null ? true : false

    FakeMissionName = null  // Store for mission name fake prop
    CustomMissionName = null  // Store for mission maker's name
    InVictory = false   // True if the mission has been completed
    InLoss = false  // True if in humilation period

    // Mapping for difficulty phrases to respective display names
    DifficultyMap = {
        "nor": "(NOR) ",
        "int": "(INT) ",
        "adv": "(ADV) ",
        "exp": "(EXP) "
    }
    // Phrases to ignore when formatting mission display name
    IgnorePhrases = [
        "rev",
        "reverse",
        "666"
    ]
    // Valve popfile names
    ValvePops = [
        "intermediate",
        "intermediate2",
        "advanced",
        "advanced1",
        "advanced2",
        "advanced3",
        "ironman",
        "expert1",
        "666"
    ]

    /**
     * Tests if the current popname is likely to be unmodified.
     *
     * Sets FakeMissionName when applicable if sigmod, otherwise sets it to null.
     * Sets CustomMissionName if the mission maker has changed their mission name.
     *
     * @return bool         True if the mission name is unmodified.
     */
    function IsNameUnmodified() {
        local changed = @(name) !(startswith(name, "scripts/population/mvm_") && endswith(name, ".pop"))

        if (IsSigmod == true) {
            // Store mission name ClientProp to __potato.FakeMissionName
            //  This is... the way that it is (calls in to raflua) because
            //   there's no $GetClientProp input
            popscript.AcceptInput("$ExecuteScript", @"
                local objres = ents.FindByClass(""tf_objective_resource"")
                objres:AcceptInput(""RunScriptCode"", string.format(""__potato.FakeMissionName = `%s`"", objres:GetFakeSendProp(""m_iszMvMPopfileName"")))
            ", null, null)

            if (FakeMissionName != "nil") {
                CustomMissionName = FakeMissionName
                return false
            }
        } else FakeMissionName = null

        local changed = @(name) !(startswith(name, "scripts/population/mvm_") && endswith(name, ".pop"))
        if (changed(NetProps.GetPropString(objres, "m_iszMvMPopfileName"))) {
            CustomMissionName = NetProps.GetPropString(objres, "m_iszMvMPopfileName")
            return false
        }

        CustomMissionName = null
        return true
    }

    /**
     * Detects the recommended mission name setting method and sets the mission display name
     * using that method.
     *
     * @param str newname   Mission name to set.
     */
    function SetMissionName(newname) {
        if (newname == null) return
        if (IsSigmod == true) {
            objres.AcceptInput("$SetClientProp$m_iszMvMPopfileName", newname, null, null)
            return
        }
        NetProps.SetPropString(objres, "m_iszMvMPopfileName", newname)
    }

    /**
     * Formats the current mission display name according to Potato.tf standard formatting,
     * if the mission name is otherwise unchanged.
     * Standard format is "(Difficulty) Mission Name".
     *
     * @param str popname   Mission name to format.
     * @param bool end      Set to true to use end card formatting (no difficulty).
     * @return str|null     Formatted mission name if successful, otherwise null.
     */
    function FormatMissionName(popname, end = false) {
        // Don't format mission name if we're on a 'normal' pop ("mvm_bigrock.pop"), as there
        //  is no mission name to format.
        if (popname.slice(19 + len_mapname, 20 + len_mapname) != "_") return null

        // Split:
        //  "scripts/population/mvm_condemned_b3_adv_unholy_undead.pop"
        // To:
        //  ["adv", "unholy", "undead"]
        local strings = split(popname.slice(20 + len_mapname, -4), "_")

        // Don't format mission name if we're probably on a Valve mission
        if (strings.len() == 1 && ValvePops.find(strings[0]) != null) return null

        local name = ""  // Mission display name
        local difficulty = ""   // Mission display difficulty tag
        for(local i = 0; i <= strings.len() - 2; ++i) {
            // Don't include "rev" or "reverse" in formatted version
            if (IgnorePhrases.find(strings[i]) != null) continue
            // Test for mission difficulty tag
            if (strings[i] in DifficultyMap) {
                difficulty = DifficultyMap[strings[i]]
                continue
            }
            // Join strings to form mission name with space separator
            name += strings[i] + " "
        }
        // Add mission difficulty to the start if it exists.
        //  Don't add if on the victory screen since map name will also be squashed in.
        // Also append the last word of the mission name, done outside the loop to avoid
        //  a trailing space.
        if (end == false) {
            return difficulty + name + strings.top()
        } else {
            return name + strings.top()
        }
    }

    /**
     * Applies the map fixes specified for the current map.
     */
    function ApplyMapFixes() {
        switch (GetMapName()) {
            // Bronx
            case "mvm_bronx_rc2":
                // Fix performance issues and large demos caused by bone followers on map engibots
                for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
                    if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
                        NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0)

                // Fix death pit not killing ubered players
                for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt");) {
                    if (deathpit.GetName() != "trigger_hurt_hatch_fire") {
                        NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", Constants.FDmgType.DMG_ACID)   // DMG_CRITICAL
                        deathpit.AcceptInput("SetDamage", "10000", null, null)
                    }
                }
                break

            // Oilrig
            case "mvm_oilrig_rc5a":
                // Rain particles fix - replaces missing rain particles with sawmill rain
                // Kill old broken rain particles
                for (local rain; rain = Entities.FindByClassname(rain, "info_particle_system");) {
                    if (rain.GetName() == "end_pit_destroy_particle") continue
                    EntFireByHandle(rain, "Kill", "", -1, null, null)
                }

                // Spawn hand-placed sawmill rain particles
                local rain001 = [Vector(-2848, 384, 8810), Vector(-1200, 1924, 3620),
                    Vector(282, 1924, 3620), Vector(882, 1924, 3620), Vector(-366, -608, 3620), Vector(528, -608, 4100),
                    Vector(1849, -291, 3420), Vector(0, -1000, 1600), Vector(1024, -1632, 4100), Vector(-1024, -1632, 4100),
                    Vector(1562, -2210, 3620), Vector(-864, -3936, 3620), Vector(160, -4096, 4200), Vector(320, -4960, 4300),
                    Vector(-704, -4960, 4300), Vector(1242, -4256, 3620), Vector(-1146, -4702, 3620)]
                local rain002 = [Vector(-508, -2608, 1800), Vector(789, -2290, 1800), Vector(-324, -2694, 1800), Vector(-320, -3360, 1800)]
                foreach(vec in rain001) {
                    SpawnEntityFromTable("info_particle_system", {
                        origin = vec
                        effect_name = "env_rain_001"
                        start_active = 1
                        flag_as_weather = 1
                    })
                }
                foreach(vec in rain002) {
                    SpawnEntityFromTable("info_particle_system", {
                        origin = vec
                        effect_name = "env_rain_002_256"
                        start_active = 1
                        flag_as_weather = 1
                    })
                }

                // Middle spawn fixes
                // Add missing BLU func_respawnroom
                local tankspawn = SpawnEntityFromTable("func_respawnroom", {
                    origin = Vector(-520, -5450, 1063)
                    TeamNum = Constants.ETFTeam.TF_TEAM_BLUE
                })
                tankspawn.SetSize(Vector(), Vector(400, 410, 200))
                tankspawn.SetSolid(Constants.ESolidType.SOLID_BBOX)

                // Properly mark the middle spawn nav square as an invaders spawn room
                local tanknav = NavMesh.GetNavAreaByID(27)
                tanknav.SetAttributeTF(Constants.FTFNavAttributeType.TF_NAV_SPAWN_ROOM_BLUE)
                tanknav.ClearAttributeTF(Constants.FTFNavAttributeType.TF_NAV_BOMB_CAN_DROP_HERE)

                // Auto-collect cash dropped in tank spawn
                local tankcollect = SpawnEntityFromTable("trigger_hurt", {
                    origin = Vector(-520, -5450, 1063)
                })
                tankcollect.SetSize(Vector(), Vector(400, 410, 200))
                tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
                break

            // Rottenburg
            case "mvm_rottenburg":
                // Fix the tank barricade turning invisible after breaking once
                EntFire("Barricade", "SetParent", "Tank_Barricade_Particle")
                // Fix prediction errors on the tank barricade
                EntFire("Barricade", "DisableCollision")
                break

            // Lotus
            case "mvm_lotus_b6":
                // Fix spawnroom blockers incorrectly rendering behind props
                for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                    NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
                break

            // Mansion
            case "mvm_mansion_rc1d":
                // Fix spawnroom blockers incorrectly rendering behind props
                for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                    NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
                break
        }
    }

    Events = {
        // Event is fired every mission change, wave jump or (post) wave fail
        function OnGameEvent_teamplay_round_start(_) {
            __potato.InVictory = false
            __potato.InLoss = false
            __potato.FakeMissionName = null
            __potato.CustomMissionName = null
            __potato.ApplyMapFixes()

            // These ents are created after map init, so we can't fetch them on map spawn
            __potato.objres = Entities.FindByClassname(null, "tf_objective_resource")
            if (__potato.IsSigmod) {
                __potato.popscript = Entities.FindByClassname(null, "$script_manager")
                if (__potato.popscript == null)
                    __potato.popscript = SpawnEntityFromTable("$script_manager", {targetname = "popscript"})
            }

            // We delay setting the mission display name so that mission makers may set their
            //  own as desired
            EntFireByHandle(__potato.objres, "RunScriptCode", format(@"
                if (__potato.IsNameUnmodified())
                    __potato.SetMissionName(__potato.FormatMissionName(`%s`))",
              NetProps.GetPropString(__potato.objres, "m_iszMvMPopfileName")),
            __potato.FormatNameDelay, null, null)
        }

        // Event is fired when the mission is complete
        function OnGameEvent_mvm_mission_complete(params) {
            __potato.InVictory = true
            if (__potato.IsNameUnmodified() == true)
                // Set name back to regular formatted name once victory panel has been displayed
                EntFireByHandle(__potato.objres, "RunScriptCode", format(@"
                    if (__potato.InVictory)
                        __potato.SetMissionName(__potato.FormatMissionName(`%s`))", params.mission),
                3.0, null, null)
            else
                // Set name back to mission maker's name once panel has been displayed
                EntFireByHandle(__potato.objres, "RunScriptCode", format(@"
                    if (__potato.InVictory)
                        __potato.SetMissionName(`%s`)", __potato.CustomMissionName),
                3.0, null, null)

            // Set mission name without difficulty before victory panel shows
            __potato.objres.AcceptInput("RunScriptCode", format(@"
                if (__potato.InVictory)
                    __potato.SetMissionName(__potato.FormatMissionName(`%s`, true))", params.mission),
            null, null)

            // Reset mission name before the popfile is reloaded by plugin
            EntFireByHandle(__potato.objres, "RunScriptCode", format(@"
                if (__potato.InVictory) {
                    NetProps.SetPropString(__potato.objres, `m_iszMvMPopfileName`, `%s`)
                    if (__potato.IsSigmod)
                        self.AcceptInput(`$ResetClientProp$m_iszMvMPopfileName`, ``, null, null)
                }
                ", params.mission),
            __potato.PluginReloadDelay - 0.5, null, null)
        }

        // Event is fired when a game_round_win receives RoundWin input
        //  i.e Any loss or rev win
        // Note: has not been tested properly locally as I cannot get the loss summary panel to appear on sigmod
        function OnGameEvent_teamplay_round_win(_) {
            __potato.InLoss = true
            local changed = @(name) !(startswith(name, "scripts/population/mvm_") && endswith(name, ".pop"))

            // Set mission name without difficulty before the loss summary panel shows
            //  Can't do anything here if the mission maker has changed the prop since we have no
            //   guaranteed way of knowing the popfile name
            if (!changed(NetProps.GetPropString(__potato.objres, "m_iszMvMPopfileName"))) {
                EntFireByHandle(__potato.objres, "RunScriptCode", format("if (__potato.InLoss) __potato.SetMissionName(__potato.FormatMissionName(`%s`))",
                    NetProps.GetPropString(__potato.objres, "m_iszMvMPopfileName"), true),
                3.0, null, null)
            }
        }
    }
    // Addendum: Mission name-changing logic is (in part) complex because the Potato plugin that
    //   serves the mission name to the Potato website retrieves the popfile name directly from
    //   the NetProp, causing the website to track progress incorrectly if it is modified.
    //  Mission reloading also breaks on Potato for the same reason.
    //  Aspiring plugin authors should consider instead using a method like this instead in a
    //   static function to reduce overhead,
    //    https://github.com/mtxfellen/tf2-plugins/blob/3a83742/addons/sourcemod/scripting/include/tfmvm_stocks.inc#L21
    //   or set up the appropriate SDKCall to CPopulationManager::GetPopulationFilename().
    //  The rest of the complexity is just over-engineering for aesthetic purposes.
}

__CollectGameEventCallbacks(__potato.Events)
