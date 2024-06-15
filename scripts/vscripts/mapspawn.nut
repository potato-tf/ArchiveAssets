// Globals
::__potato_hiderespawntext <- 1;
local objRes = Entities.FindByClassname(null, "tf_objective_resource");
local delay = 1; //delay the popfile name switch.  If the mission maker changes the pop name themself before this delay then we won't override it.

::__potato_GlobalFixes <- {
    // Callback runs on first wave init
    function OnGameEvent_teamplay_round_start(params)
    {
        // Fixes for Bronx
        if (GetMapName() == "mvm_bronx_rc2")
        {
            // Fix poor performance caused by Bone Followers being enabled on animated Engiebot models
            for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
            {
                if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
                {
                    NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0);
                }
            }
            // Fix death pit not killing ubered players
            for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt");)
            {
                if (deathpit.GetName() != "trigger_hurt_hatch_fire")
                {
                    NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", 1048576);  // DMG_CRITICAL
                    EntFireByHandle(deathpit, "SetDamage", "10000", -1, null, null);
                }
            }
        }

        local tf_player_manager = Entities.FindByClassname(null, "tf_player_manager");
        if (tf_player_manager.GetScriptThinkFunc() != "") return;   // Do not reapply think if already applied
        local tf_gamerules =  Entities.FindByClassname(null, "tf_gamerules");

        // Hide respawn times if they are arbitrarily high
        // ====================================================================
        // FOR MISSION MAKERS: You can disable this behaviour for your mission!
        // Simply fire this output to do so:
		//  Target worldspawn
		//  Action RunScriptCode
		//  Param  "__potato_hiderespawntext = 0"
        function __potato_RespawnThink()
        {
            for (local i = 1; i <= MaxClients().tointeger(); i++)
            {
                local player = PlayerInstanceFromIndex(i);
                if (__potato_hiderespawntext == 1 &&                    // Is fix is enabled?
                    player != null && !IsPlayerABot(player) &&          // Is player is valid?
                    NetProps.GetPropInt(player, "m_lifeState") == 2 &&  // Is player is dead?
                    NetProps.GetPropFloatArray(tf_gamerules, "m_TeamRespawnWaveTimes", player.GetTeam()) > 99.0)    // Does respawn wave time exceed 99s?
                {
                    // This can be set to 1.0s to instead show 'Respawn in: Prepare to Respawn'
                    NetProps.SetPropFloatArray(tf_player_manager, "m_flNextRespawnTime", 0.0, i);  
                }
            }
            return -1;
        }

        // Add think function to tf_player_manager
        // Note: If a mission clears the thinks on tf_player_manager this script will fail
        tf_player_manager.ValidateScriptScope();
        tf_player_manager.GetScriptScope().__potato_RespawnThink <- __potato_RespawnThink;
        AddThinkToEnt(tf_player_manager, "__potato_RespawnThink");

        // Format mission name into a new string

        function __potato__GlobalFixes::Format()
        {
            local popname = NetProps.GetPropString(objRes, "m_iszMvMPopfileName")
            local str = ""
            local s = []
            local pivot = -1

            if (startswith(popname, "scripts/population/") && endswith(popname, ".pop")) //probably an unmodified name
                s = split(split(popname, "/")[2], "_")

            local len = s.len() - 1

            //first clean up the array
            for (local i = len; i >= 0; i--)
            {
                local name = s[i]

                //remove "mvm" and remove rev if there's already a difficulty keyword
                if (name == "mvm" || (name == "rev" && (s[i - 1] in diffKeywords || s[i + 1] in diffKeywords)))
                {
                    s.remove(i)
                    continue
                }

                //remove .pop suffix
                if (i == len)
                {
                    s[i] = split(name, ".")[0]
                    continue
                }
            }

            //find a pivot keyword to separate map and mission name.
            foreach(i, name in s)
            {
                local namelen = name.len()
                if (name in diffKeywords || name in pivotKeywords || (startswith(name, "rc") && namelen < 5) || (startswith(name, "b") && namelen < 4) || (startswith(name, "a") && namelen < 4))
                    pivot = i+1
            }

            if (pivot == -1) return

            str += format("(%s) ", s[pivot - 1])

            for (local i = pivot; i < s.len(); i++)
                str += format("%s ", s[i])

            //setting this netprop directly will break the map rotation for rafmod/sigmod servers, use ClientProp instead to fake it
            this.IsSigmod() ? EntFireByHandle(objRes, "$SetClientProp$m_iszMvMPopfileName", format("%s", str), -1, null, null) : EntFireByHandle(objRes, "RunScriptCode", format("NetProps.SetPropString(self, `m_iszMvMPopfileName`, `%s`)", str), -1, null, null)
        }
        EntFire("bignet", "RunScriptCode", "__potato_GlobalFixes.Format()", delay)
    }
}

// Register callbacks
__CollectGameEventCallbacks(__potato_GlobalFixes);
