::__potato.NameFormatter <- {
    // Format name delays (in seconds)
    InitialFormatDelay = 1.0    // Before checking if the mission has a custom name
    PluginReloadDelay = 10.0    // Before the mission is reloaded on completion
    WinPanelDelay = 1.0         // Until the mission complete screen is shown
    HumiliationTime = 5.0       // Length of humiliation period, hardcoded to 5s in MvM

    popscript = null    // Sigmod $script_manager handle.
    CustomMissionName = null  // Stores the mission maker's custom mission name.

    // EntFire checks so we don't format at the wrong time.
    InVictory = false   // Has the mission been completed?
    //InHumiliation = false  // Is the mission in the humiliation period?

    // Mapping for difficulty phrases to their respective display names.
    DifficultyMap = {
        "nor": "(NOR) ",
        "int": "(INT) ",
        "adv": "(ADV) ",
        "exp": "(EXP) "
    }
    // Phrases to not include in the formatted mission display name.
    IgnorePhrases = [
        "rev",
        "reverse",
        "666"
    ]
    // Valve popfile names; we don't want to format these at all as they
    //  are already properly localised.
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
     * Tests if a mission name appears to be a population file path.
     *
     * @return bool         True if appears to be a popfile path.
     */
    function IsPopPath(name)
        return !(startswith(name, "scripts/population/mvm_") && endswith(name, ".pop"))

    /**
     * Tests if the mission maker has attempted to change the mission display name
     * with $SetClientProp or SetPropString.
     *
     * Sets CustomMissionName if the mission maker has changed their mission name.
     *
     * @return bool         True if the mission name has been modified.
     */

    _FakeMissionName = null  // Mission name fake prop, internal use for this function.
    function IsNameModified() {
        if (IsSigmod) {
            // $SetClientProp test
            //  Store mission name ClientProp to _FakeMissionName.
            //  Note that there is no $GetClientProp input in sigmod.
            popscript.AcceptInput("$ExecuteScript", @"
                local objres = ents.FindByClass(""tf_objective_resource"")
                objres:AcceptInput(""RunScriptCode"",
                    string.format(""::__potato.NameFormatter._FakeMissionName = `%s`"",
                     objres:GetFakeSendProp(""m_iszMvMPopfileName"")))
            ", null, null)

            // Raflua CEntity:GetFakeSendProp() returns nil if a client prop is
            //  not set.
            if (_FakeMissionName != "nil") {
                CustomMissionName = _FakeMissionName
                return true
            }
        }

        if (IsPopPath(NetProps.GetPropString(hObjRes, "m_iszMvMPopfileName"))) {
            CustomMissionName = NetProps.GetPropString(hObjRes, "m_iszMvMPopfileName")
            return true
        }

        CustomMissionName = null
        return false
    }

    /**
     * Detects the best mission name setting method and sets the mission display name
     * using that method ($SetClientProp if sigmod, otherwise SetPropString).
     *
     * @param str|null newname   Mission name to set; return early if null.
     */
    function SetMissionName(name) {
        if (name == null) return
        if (IsSigmod == true) {
            hObjRes.AcceptInput("$SetClientProp$m_iszMvMPopfileName", name, null, null)
            return
        }
        NetProps.SetPropString(hObjRes, "m_iszMvMPopfileName", name)
    }

    /**
     * Formats the current mission display name according to Potato.tf standard formatting.
     * Standard format is "(Difficulty) Mission Name".
     *
     * @param str popname   Mission name to format.
     * @param bool end?     Set to true to remove "(Difficulty)" from the formatted name.
     * @return str|null     Formatted mission name if successful, otherwise null.
     */
    function FormatMissionName(popname, end = false) {
        // Return null if we're on a 'normal' pop ("mvm_bigrock.pop"), as there
        //  is no mission name to format.
        if (popname.slice(19 + MapName_len, 20 + MapName_len) != "_") return null

        // From filepath:
        //  "scripts/population/mvm_condemned_b3_adv_unholy_undead.pop"
        // Get phrases:
        //  ["adv", "unholy", "undead"]
        local strings = split(popname.slice(20 + MapName_len, -4), "_")

        // Return null if we're probably on a Valve mission.
        if (strings.len() == 1 && ValvePops.find(strings[0]) != null) return null

        local name = ""  // Formatted mission name
        local difficulty = ""   // Formatted mission difficulty

        for(local i = 0; i <= strings.len() - 2; ++i) {
            // Skip phrases in IgnorePhrases.
            if (IgnorePhrases.find(strings[i]) != null) continue
            // Set formatted difficulty if phrase is recognised in DifficultyMap.
            if (strings[i] in DifficultyMap) {
                difficulty = DifficultyMap[strings[i]]
                continue
            }
            // Join strings to make the formatted mission name.
            name += strings[i] + " "
        }

        // Append the last phrase of the mission name outside the loop to avoid
        //  a trailing space.
        if (!end) {
            // Add mission difficulty to the start (if it exists) by default.
            return difficulty + name + strings.top()
        } else {
            // If specified when called, don't add the "(Difficulty)" tag.
            return name + strings.top()
        }
    }

    Events = {
        // Fired every mission change, wave jump or (post) wave fail.
        function OnGameEvent_teamplay_round_start(_) {
            InVictory = false
            //InHumiliation = false

            if (IsSigmod) {
                // The mission itself will make this entity if it has any raflua features.
                popscript = Entities.FindByClassname(null, "$script_manager")
                if (!popscript)
                    popscript = SpawnEntityFromTable("$script_manager", {targetname = "popscript"})
            }

            // We delay checking the mission display name so that mission makers may set their
            //  own as desired within this window.
            EntFireByHandle(hObjRes, "RunScriptCode", format(@"
                if (!::__potato.NameFormatter.IsNameModified())
                    ::__potato.NameFormatter.SetMissionName(
                        ::__potato.NameFormatter.FormatMissionName(`%s`))",
              NetProps.GetPropString(hObjRes, "m_iszMvMPopfileName")),
            InitialFormatDelay, null, null)
        }

        // Fired every wave loss (or on reverse mode win). Triggers 5s humiliation period.
        /* function OnGameEvent_teamplay_round_win(_) {
            InHumiliation = true

            // Set the mission name without "(Difficulty)" before the loss summary panel shows.
            // We don't do this if the mission maker has used SetPropString since we will have
            //  no guaranteed way of knowing the original popfile name.
            if (!IsPopPath(NetProps.GetPropString(hObjRes, "m_iszMvMPopfileName"))) {
                EntFireByHandle(hObjRes, "RunScriptCode", format(@"
                if (::__potato.NameFormatter.InHumiliation)
                    ::__potato.NameFormatter.SetMissionName(
                        ::__potato.NameFormatter.FormatMissionName(`%s`, true))",
                    NetProps.GetPropString(hObjRes, "m_iszMvMPopfileName"), true),
                // Advance fire by 1s to account for client latency.
                HumiliationTime - 1.0, null, null)
            }
        } */

        // Event is fired when the mission is complete.
        // Note that debug methods may not always fire this event, but regular play will.
        function OnGameEvent_mvm_mission_complete(params) {
            InVictory = true

            // The order of code here may be confusing, because we must run this code first;
            //  the below block this one sets m_iszMvMPopfileName to formatted params.mission
            //  which makes the IsNameModified() test useless if it is ran after that block.
            if (IsNameModified())
                // Set name back to mission maker's name once panel has been displayed
                EntFireByHandle(hObjRes, "RunScriptCode", format(@"
                    if (::__potato.NameFormatter.InVictory)
                        ::__potato.NameFormatter.SetMissionName(`%s`)", CustomMissionName),
                WinPanelDelay + 2.0, null, null)
            else
                // Set name back to regular formatted name once victory panel has been displayed
                EntFireByHandle(hObjRes, "RunScriptCode", format(@"
                    if (::__potato.NameFormatter.InVictory)
                        ::__potato.NameFormatter.SetMissionName(
                            ::__potato.NameFormatter.FormatMissionName(`%s`))", params.mission),
                WinPanelDelay + 2.0, null, null)
            // Give a 2s delay because if the client holds the scoreboard open, this may
            //  not apply for them; I'm tempted to not reset it at all for this reason.

            // Set mission name without difficulty before victory panel shows
            hObjRes.AcceptInput("RunScriptCode", format(@"
                if (::__potato.NameFormatter.InVictory)
                    ::__potato.NameFormatter.SetMissionName(
                        ::__potato.NameFormatter.FormatMissionName(`%s`, true))", params.mission),
            null, null)
            // Set name immediately to account for client latency.

            // Reset mission name before the popfile is reloaded by plugin
            EntFireByHandle(hObjRes, "RunScriptCode", format(@"
                if (::__potato.NameFormatter.InVictory)
                    NetProps.SetPropString(::__potato.hObjRes, `m_iszMvMPopfileName`, `%s`)
                ", params.mission),
            PluginReloadDelay - 0.015, null, null)
            // Only need to advance by SINGLE_TICK as this is for the server's benefit.
        }
    }
}

::__potato.NameFormatter.setdelegate(::__potato)
::__potato.NameFormatter.Events.setdelegate(::__potato.NameFormatter)

__CollectGameEventCallbacks(::__potato.NameFormatter.Events)
