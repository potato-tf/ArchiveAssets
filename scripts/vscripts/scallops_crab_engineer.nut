::CrabEngineer <-
{
	currentSide = "b"

	function CleanUp()
    {
        local ent = null;
        while (ent = Entities.FindByClassname(ent, "bot_hint*"))
        {
            EntFireByHandle(ent, "Enable", "", 0, null, null);
        }

        Convars.SetValue("tf_bot_engineer_mvm_sentry_hint_bomb_backward_range", 3000);
        Convars.SetValue("tf_bot_engineer_mvm_hint_min_distance_from_bomb", 1300);
        delete ::CrabEngineer;
    }

    function DetermineBestHint()
    {
        local bomb = Entities.FindByName(null, CrabEngineer.currentSide == "a" ? "intel_a" : "intel_b");
        local hints = [];
        local ent = null;
        local closestHint = null;
        local closestDist = -1.0;
        local bombArea = NavMesh.GetNearestNavArea(bomb.GetOrigin(), 0.0, false, false);
        while (ent = Entities.FindByName(ent, CrabEngineer.currentSide == "a" ? "enginest_a*" : "enginest_b*"))
        {
            if (ent.GetClassname() != "bot_hint_engineer_nest")
                continue;

            // find closest hint to the bomb
            hints.append(ent);
            local area = NavMesh.GetNearestNavArea(ent.GetOrigin(), 0.0, false, false);
            local dist = NavMesh.NavAreaTravelDistance(bombArea, area, 0.0);
            if (closestDist == -1.0 || dist < closestDist)
            {
                closestHint = ent;
                closestDist = dist;
            }
        }

        closestHint.AcceptInput("Enable", "", null, null);
        foreach (i, hint in hints)
        {
            if (hint.GetName() == closestHint.GetName())
                continue;

            // disable all other hints to force usage of the closest
            hint.AcceptInput("Disable", "", null, null);
        }

        if (developer() > 0)
        {
            printl(format("Teleporting Engineer to hint: '%s' from bomb '%s'", closestHint.GetName(), bomb.GetName()));
        }

        return closestHint;
    }

    Events =
    {
        OnGameEvent_recalculate_holidays = function(params) { CrabEngineer.CleanUp() }
        OnGameEvent_mvm_wave_complete = function(params) { CrabEngineer.CleanUp() }

        function OnGameEvent_mvm_begin_wave(params)
        {
            local ent = null;
            while (ent = Entities.FindByClassname(ent, "bot_hint*"))
            {
                ent.ValidateScriptScope();
                local scope = ent.GetScriptScope();
                local isB = startswith(ent.GetName(), "enginest_b");
                scope.enabled <- isB;
                ent.AcceptInput(isB ? "Enable" : "Disable", "", null, null);
            }

            Convars.SetValue("tf_bot_engineer_mvm_sentry_hint_bomb_backward_range", 9999999);
            Convars.SetValue("tf_bot_engineer_mvm_hint_min_distance_from_bomb", 0);
        }

        function OnGameEvent_player_builtobject(params)
        {
            local obj = EntIndexToHScript(params.index);
            if (obj.GetTeam() != 3)
                return;

            local player = GetPlayerFromUserID(params.userid);
            if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE) && player.HasBotTag("crab_engineer"))
            {
                // if the engineer built something, he's teleported in, so swap hint states
                player.RemoveBotTag("crab_engineer");
                local ent = null;
                while (ent = Entities.FindByClassname(ent, "bot_hint*"))
                {
                    ent.ValidateScriptScope();
                    local scope = ent.GetScriptScope();
                    if (("enabled" in scope))
                    {
                        scope.enabled = !scope.enabled;
                        ent.AcceptInput(scope.enabled ? "Enable" : "Disable", "", null, null);
                        if (scope.enabled)
                        {
                            CrabEngineer.currentSide = startswith(ent.GetName(), "enginest_b") ? "b" : "a";
                        }
                    }
                }
            }
        }

        function OnGameEvent_player_spawn(params)
        {
            // checking for tags here doesn't work for some reason
            local player = GetPlayerFromUserID(params.userid);
            if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)
                && player.GetTeam() == 3
                && player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER)
            {
                CrabEngineer.DetermineBestHint();
            }
        }
    }
}

__CollectGameEventCallbacks(CrabEngineer.Events)
