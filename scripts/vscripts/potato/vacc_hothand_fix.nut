::__potato.StretchFix <- {

    backpack_model = "models/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl"
    itemdef_netprop = "m_AttributeManager.m_Item.m_iItemDefinitionIndex"
    class_strings = ["", "scout", "sniper", "soldier", "demo", "medic", "heavy", "pyro", "spy", "engineer", "civilian"]

    function KillStretch(player) {

        //some missions (trespasser, mobo, bigrock revs) use civilian for players
        if (player.GetPlayerClass() > 9) return

        local class_string = this.class_strings[player.GetPlayerClass()]

        local model_name =  format("models/bots/%s/bot_%s.mdl", class_string, class_string)
        local giant_model_name = format("models/bots/%s_boss/bot_%s_boss.mdl", class_string, class_string)

        if (player.GetModelName() != model_name && player.GetModelName() != giant_model_name)
            return

        for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
            if (child.GetModelName() == this.backpack_model)
            {
                EntFireByHandle(child, "Kill", "", -1, null, null)
                break
            }
            else if (NetProps.GetPropInt(child, this.itemdef_netprop) == 998) //vaccinator id
            {
                EntFireByHandle(NetProps.GetPropEntity(child, "m_hExtraWearable"), "Kill", "", -1, null, null)
                break
            }
            else if (child.GetClassname() == "tf_weapon_slap") //hothand id
            {
                NetProps.SetPropInt(child, "m_nRenderMode", 1) //kRenderTransColor
                NetProps.SetPropInt(child,  "m_clrRender", 0)
                break
            }

    }

    Events = {
        function OnGameEvent_post_inventory_application(params) {
            EntFireByHandle(GetPlayerFromUserID(params.userid), "RunScriptCode", "__potato.StretchFix.KillStretch(self)", 0.015, null, null)
        }
    }
}

::__potato.StretchFix.setdelegate(::__potato)
::__potato.StretchFix.Events.setdelegate(::__potato.StretchFix)

__CollectGameEventCallbacks(::__potato.StretchFix.Events)