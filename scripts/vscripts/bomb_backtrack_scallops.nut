::BombBacktrack <-
{
    CleanUp = function()
    {
        BombBacktrack.dev_printl("[BombBacktrack] Cleaning up");
        local bomb = null;
        while (bomb = Entities.FindByClassname(bomb, "item_teamflag"))
        {
            BombBacktrack.ClearBombScope(bomb);
        }

        delete ::BombBacktrack;
    }

    OnGameEvent_recalculate_holidays = function(params) { CleanUp(); }
    OnGameEvent_mvm_wave_complete = function(params) { CleanUp(); }

    // these can be changed on a per-map basis
    SecondsBetweenHops = 15
    MinSecondsBetweenHops = 5 // only matters if ResetTimerOnPickup is false
    ResetTimerOnPickup = true
    HopDistMin = 600
    HopDistMax = 1200
    HomeAreaID = 5039

    max = function(x, y)
    {
        return x > y ? x : y;
    }

    dev_printl = function(msg)
    {
        if (developer() > 0)
        {
            printl(msg);
        }
    }

    ClearBombScope = function(bomb)
    {
        local scope = bomb.GetScriptScope();
        if (scope != null)
        {
            if (scope.textEnt != null)
            {
                scope.textEnt.Destroy();
            }

            bomb.TerminateScriptScope();
            NetProps.SetPropString(bomb, "m_iszScriptThinkFunction", "");
            AddThinkToEnt(bomb, null);
        }
    }

    CreateBombScope = function(bomb)
    {
        bomb.ValidateScriptScope();
        local scope = bomb.GetScriptScope();
        if (("nextHopTime" in scope))
            return;

        scope.nextHopTime <- 0;
        scope.pickedUpOnce <- false;
        scope.dropped <- false;
        scope.textEnt <- null;
        scope.nextTextUpdate <- 0;
        scope.lastBombOwner <- null;
        scope.remainingTime <- BombBacktrack.SecondsBetweenHops;
        //scope.homeArea <- NavMesh.GetNavAreaByID(BombBacktrack.HomeAreaID);
        // Scallops has two bombs, so we need a separate home area for each
        scope.homeArea <- bomb.GetName() == "intel_b" ? NavMesh.GetNavAreaByID(3962) : NavMesh.GetNavAreaByID(4014);

        scope.GetTimeToNextHop <- function()
        {
            return BombBacktrack.max(scope.nextHopTime-Time(), 0);
        }

        scope.CreateTextEnt <- function()
        {
            if (scope.textEnt != null)
                return;

            scope.textEnt = Entities.CreateByClassname("point_worldtext");
            scope.textEnt.KeyValueFromString("message", format("%d", BombBacktrack.SecondsBetweenHops));
            scope.textEnt.KeyValueFromFloat("textsize", 35.0);
            scope.textEnt.KeyValueFromInt("orientation", 1);
            scope.textEnt.KeyValueFromInt("font", 0);
            scope.textEnt.KeyValueFromString("color", "255 255 255 255");
            scope.textEnt.SetAbsOrigin(bomb.GetOrigin());
            scope.textEnt.DisableDraw();
            Entities.DispatchSpawn(scope.textEnt);
        }

        scope.UpdateTextPos <- function()
        {
            if (scope.textEnt == null)
                return;

            local origin = bomb.GetOrigin();
            origin.z += 30.0;
            scope.textEnt.SetAbsOrigin(origin);
        }

        scope.DoBombHop <- function()
        {
            local currentArea = NavMesh.GetNearestNavArea(bomb.GetCenter(), 999999.0, false, false);
            local areaTable = {};
            local endOrigin = scope.homeArea.GetCenter();
            endOrigin.z += 15.0;
            NavMesh.GetNavAreasFromBuildPath(currentArea, scope.homeArea, endOrigin, 0.0, Constants.ETFTeam.TEAM_ANY, false, areaTable);
            if (areaTable.len() <= 0)
            {
                BombBacktrack.dev_printl("[BombBacktrack] Bomb hop failed (path build failed)");
                return false;
            }

            foreach (area in areaTable)
            {
                if (NavMesh.NavAreaTravelDistance(currentArea, area, BombBacktrack.HopDistMax) >= BombBacktrack.HopDistMin)
                {
                    DispatchParticleEffect("eyeboss_tp_player", bomb.GetOrigin(), Vector(0, 0, -90));
                    local origin = area.GetCenter();
                    origin.z += 15.0;
                    bomb.SetAbsOrigin(origin);
                    scope.UpdateTextPos();
                    DispatchParticleEffect("eyeboss_tp_player", origin, Vector(0, 0, -90));
                    BombBacktrack.dev_printl("[BombBacktrack] Bomb hop successful");
                    return true;
                }
            }

            BombBacktrack.dev_printl("[BombBacktrack] Bomb hop failed (couldn't find a valid area to teleport to)");
            return false;
        }

        scope.BombHop_Think <- function()
        {
            local curTime = Time();
            if (scope.textEnt == null)
            {
                scope.CreateTextEnt();
            }

            if (scope.dropped && bomb.GetOwner() == null)
            {
                if (curTime >= scope.nextTextUpdate)
                {
                    scope.textEnt.KeyValueFromString("message", format("%d", ceil(scope.GetTimeToNextHop())));
                    scope.nextTextUpdate = curTime + 0.2;
                }

                if (scope.GetTimeToNextHop() <= 0)
                {
                    scope.DoBombHop();
                    scope.nextHopTime = curTime + BombBacktrack.SecondsBetweenHops;
                }
            }

            return -1;
        }

        AddThinkToEnt(bomb, "BombHop_Think");
    }

    OnGameEvent_mvm_begin_wave = function(params)
    {
        BombBacktrack.dev_printl("[BombBacktrack] Wave begin");
        local bomb = null;
        while (bomb = Entities.FindByClassname(bomb, "item_teamflag"))
        {
            BombBacktrack.ClearBombScope(bomb);
            BombBacktrack.CreateBombScope(bomb);
            //AddThinkToEnt(bomb, "BombHop_Think");
            //NetProps.SetPropInt(bomb, "m_Collision.m_nSolidType", 2);
            //NetProps.SetPropInt(bomb, "m_Collision.m_usSolidFlags", 140);
        }
    }

    OnGameEvent_teamplay_flag_event = function(params)
    {
        local bomb = null;
        while (bomb = Entities.FindByClassname(bomb, "item_teamflag"))
        {
            local scope = bomb.GetScriptScope();
            if (!("nextHopTime" in scope))
                continue;

            local owner = bomb.GetOwner();
            if (params.eventtype == 1) // picked up
            {
                if (owner == null || owner.entindex() != params.player)
                    continue;

                BombBacktrack.dev_printl("[BombBacktrack] Bomb was picked up");
                scope.dropped = false;
                scope.lastBombOwner = owner;
                if (scope.pickedUpOnce)
                {
                    scope.remainingTime = scope.GetTimeToNextHop();
                }

                if (scope.textEnt != null)
                {
                    scope.textEnt.DisableDraw();
                }

                scope.pickedUpOnce = true;
            }
            else if (params.eventtype == 4 && owner == null && scope.lastBombOwner != null
                && scope.lastBombOwner.entindex() == params.player) // dropped
            {
                BombBacktrack.dev_printl("[BombBacktrack] Bomb was dropped");
                scope.dropped = true;
                if (BombBacktrack.ResetTimerOnPickup)
                {
                    scope.nextHopTime = Time() + BombBacktrack.SecondsBetweenHops;
                }
                else
                {
                    scope.nextHopTime = Time() + BombBacktrack.max(scope.remainingTime, BombBacktrack.MinSecondsBetweenHops);
                }

                scope.UpdateTextPos();
                if (scope.textEnt != null)
                {
                    scope.textEnt.EnableDraw();
                }
            }
        }
    }
}

__CollectGameEventCallbacks(BombBacktrack);