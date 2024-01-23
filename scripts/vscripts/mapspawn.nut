
::__potato_hiderespawntext <- 0.0;

::GlobalFixes <- {
    function OnGameEvent_teamplay_round_start(params)
    {
        if (GetMapName() == "mvm_bronx_rc2")
        {
            for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
                if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
                    NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0)

            for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt");)
                if (deathpit.GetName() != "trigger_hurt_hatch_fire")
                {
                    NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", 1048576)  //DMG_ACID
                    EntFireByHandle(deathpit, "SetDamage", "10000", -1, null, null)
                }
        }
        local playermanager = Entities.FindByClassname(null, "tf_player_manager")
        if (playermanager.GetScriptThinkFunc() != "" || __potato_hiderespawntext > 0.0) return
        ::__potato_RespawnThink <- function()
        {
            for (local player, i = 1; i < MaxClients().tointeger(); i++)
            {
                try
                    if (player = PlayerInstanceFromIndex(i) && !IsPlayerABot(player) && NetProps.GetPropInt(player, "m_lifeState") != 0 && GetPropFloatArray(playermanager, "m_flNextRespawnTime", i) > 99.0)
                        SetPropFloatArray(playermanager, "m_flNextRespawnTime", __potato_hiderespawntext, player.entindex())
                catch(err) break
            }
            return -1
        }
        playermanager.ValidateScriptScope()
        playermanager.GetScriptScope().__RespawnThink <- __RespawnThink
        AddThinkToEnt(playermanager, "__RespawnThink")
    }
}

__CollectGameEventCallbacks(GlobalFixes)

// SpawnEntityFromTable("trigger_hurt", {

// })