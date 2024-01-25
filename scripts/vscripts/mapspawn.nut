// Globals
::__potato_hiderespawntext <- 1;

::GlobalFixes <- {
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
    }
}

// Register callbacks
__CollectGameEventCallbacks(GlobalFixes);
