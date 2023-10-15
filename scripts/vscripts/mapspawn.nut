if (GetMapName() != "mvm_bronx_rc2") return

::GlobalFixes <- {}

::GlobalFixes.OnGameEvent_teamplay_round_start <- function(params)
{
    for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
        if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
            NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0) 
    
    for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt"); )
        if (deathpit.GetName() != "trigger_hurt_hatch_fire")
        {
            NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", Constants.FDmgType.DMG_ACID)
            EntFireByHandle(deathpit, "SetDamage", "10000", -1, null, null)
        }
        
}

__CollectGameEventCallbacks(::GlobalFixes)

// SpawnEntityFromTable("trigger_hurt", {
    
// })