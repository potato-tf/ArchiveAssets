::BuffRemoveShield <-
{
	OnGameEvent_recalculate_holidays = function(params) { delete ::BuffRemoveShield }

    function OnGameEvent_deploy_buff_banner(params)
    {
        local player = GetPlayerFromUserID(params.buff_owner);
        if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE) && player.HasBotTag("medic_buff_remove_shield"))
        {
            EntFireByHandle(player, "RunScriptCode",
                "local entity=null;while(entity=Entities.FindByClassname(entity,`entity_medigun_shield`)){if(entity.GetOwner()==self){entity.Destroy();break;}}", 0.1, player, player);
        }
    }
}
__CollectGameEventCallbacks(BuffRemoveShield)
