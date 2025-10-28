::ScallopsPyroBoss <-
{
	OnGameEvent_recalculate_holidays = function(params) { delete ::ScallopsPyroBoss }
    OnGameEvent_mvm_wave_complete = function(params) { delete ::ScallopsPyroBoss }

	function OnGameEvent_player_death(params)
    {
        local player = GetPlayerFromUserID(params.userid);
        if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE) && player.HasBotTag("boss_pocket_medic"))
        {
            for (local i = 1; i <= MaxClients().tointeger(); i++)
            {
                local boss = PlayerInstanceFromIndex(i);
                if (boss != null && boss.IsBotOfType(Constants.EBotType.TF_BOT_TYPE) && boss.HasBotTag("pyro_boss"))
                {
                    // Switch to secondary after our medic dies
                    boss.ClearAllWeaponRestrictions();
                    boss.AddWeaponRestriction(4);
                    if (RandomInt(1, 2) == 1)
                    {
                        boss.PlayScene("scenes/player/pyro/low/1517.vcd", 0);
                    }
                    else
                    {
                        boss.PlayScene("scenes/player/pyro/low/1485.vcd", 0);
                    }

                    break;
                }
            }
        }
    }

    function OnGameEvent_player_spawn(params)
    {
        local player = GetPlayerFromUserID(params.userid);
        if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE))
        {
            EntFireByHandle(player, "RunScriptCode",
                "if(self.HasBotTag(`pyro_boss`)){self.PressAltFireButton(99999);}", 0.5, null, null);
        }
    }
}
__CollectGameEventCallbacks(ScallopsPyroBoss)
