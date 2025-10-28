// Original script by CookieCat
// Modified by Mentrillum

::BombBacktracker <-
{
	// The bomb's max backtrack time. When expired the bomb jumps back in position.
	BacktrackTime = 15

	// The bomb's travel distance once it backtracks.
	// Note this is dictated by the path length of the navmesh, not a radius in hammer units.
	BacktrackDistanceMin = 400.0
	BacktrackDistanceMax = 1200.0

	// The bomb's resting position once it has fully backtracked
	HomePosition = Vector(0.0, 0.0, 0.0)

	// When set will make the bomb keep it's timer even if picked up.
	PersistentTimer = true

	// If the persistent timer is enabled and the bomb is picked up while the timer is below the minimum timer, then the timer is set to the minimum timer.
	MinimumTimer = 5

	// The color of the countdown timer in RGBA string format.
	TimerColor = "0 0 255 255"

	// The timer's height offset relative to the bomb's position.
	// Note this does not affect the circle timer.
	TimerZOffset = 70.0

	// Determines if the bomb timer should use the timer icon rather than text.
	UseCircleTimer = false

	// If set will make the bomb backtracking pathing algorithm block off areas the bomb should not go.
	// This is an array that takes nav area IDs. To get a nav area ID, make sure nav_edit is set to 1.
	// Whenever you hover your cursor over a nav area, it should display "Area #X  X Connections". Area #X is your nav area ID, simply input the integer in the array
	// and whenever the bomb backtracks it will temporarily block that area and then immediately unblock it once the bomb backtracks.
	BlacklistedAreaIDs = []

	function CleanUp()
	{
		local bomb = null;
		while ((bomb = Entities.FindByClassname(bomb, "item_teamflag")) != null)
		{
			RemoveScope(bomb);
		}
		delete ::BombBacktracker;
	}

	function OnGameEvent_recalculate_holidays(params)
	{
		CleanUp();
	}

	function OnGameEvent_mvm_begin_wave(params)
	{
		local bomb = null;
		while ((bomb = Entities.FindByClassname(bomb, "item_teamflag")) != null)
		{
			RemoveScope(bomb);
			AddScope(bomb);
		}
	}

	function OnGameEvent_mvm_wave_complete(params)
	{
		CleanUp();
	}

	function OnGameEvent_teamplay_flag_event(params)
	{
		local time = Time();
		local bomb = null;
		while ((bomb = Entities.FindByClassname(bomb, "item_teamflag")) != null)
		{
			if (!HasScope(bomb))
			{
				continue;
			}

			local scope = bomb.GetScriptScope();
			local owner = bomb.GetOwner();
			if (params.eventtype == 1) // Picked up
			{
				if (owner == null || owner.entindex() != params.player)
				{
					continue;
				}

				scope.IsDropped = false;
				scope.LastOwner = owner;
				scope.PersistentTime = scope.NextJumpTime - time;
				if (scope.ReturnTimer != null && !UseCircleTimer)
				{
					scope.ReturnTimer.DisableDraw();
				}
			}
			else if (params.eventtype == 4 && owner == null && scope.LastOwner != null && scope.LastOwner.entindex() == params.player) // Dropped
			{
				if (!PersistentTimer)
				{
					scope.NextJumpTime = time + BacktrackTime;
				}
				else
				{
					scope.NextJumpTime = scope.PersistentTime + time;
					if (scope.NextJumpTime - time <= MinimumTimer)
					{
						scope.NextJumpTime = MinimumTimer + time;
					}
				}

				scope.UpdateTimerPosition();
				if (scope.ReturnTimer != null && !UseCircleTimer)
				{
					scope.ReturnTimer.EnableDraw();
				}

				if (UseCircleTimer)
				{
					bomb.AcceptInput("ShowTimer", format("%d", BacktrackTime), null, null);
					NetProps.SetPropFloat(bomb, "m_flResetTime", scope.NextJumpTime);
					NetProps.SetPropFloat(bomb, "m_flMaxResetTime", BacktrackTime);
				}
				scope.IsDropped = true;
			}
		}
	}

	function RemoveScope(bomb)
	{
		local scope = bomb.GetScriptScope();
		if (scope != null)
		{
			if (scope.ReturnTimer != null)
			{
				scope.ReturnTimer.Destroy();
			}

			bomb.TerminateScriptScope();
			NetProps.SetPropString(bomb, "m_iszScriptThinkFunction", "");
			AddThinkToEnt(bomb, null);
		}
	}

	function HasScope(bomb)
	{
		local scope = bomb.GetScriptScope();
		return ("NextJumpTime" in scope);
	}

	AddScope = function(bomb)
	{
		bomb.ValidateScriptScope();
		if (HasScope(bomb))
		{
			return;
		}
		local scope = bomb.GetScriptScope();

		scope.NextJumpTime <- 0.0;
		scope.PersistentTime <- -1.0;
		scope.IsDropped <- false;
		scope.LastOwner <- null; // We need this cause bombs start off dropped, we don't want these to move unless there is an owner
		scope.ReturnTimer <- null;
		scope.ReturnTimerUpdate <- 0.0;

		scope.CreateTimer <- function()
		{
			if (scope.ReturnTimer != null)
			{
				return;
			}

			scope.ReturnTimer = Entities.CreateByClassname("point_worldtext");
			scope.ReturnTimer.KeyValueFromString("message", format("%d", BombBacktracker.BacktrackTime));
			scope.ReturnTimer.KeyValueFromFloat("textsize", 35.0);
			scope.ReturnTimer.KeyValueFromInt("orientation", 1);
			scope.ReturnTimer.KeyValueFromInt("font", 1);
			scope.ReturnTimer.KeyValueFromString("color", BombBacktracker.TimerColor);
			scope.ReturnTimer.SetAbsOrigin(bomb.GetOrigin());
			scope.ReturnTimer.DisableDraw();
			Entities.DispatchSpawn(scope.ReturnTimer);
		}

		scope.UpdateTimerPosition <- function()
		{
			if (scope.ReturnTimer == null)
			{
				return;
			}

			scope.ReturnTimer.SetAbsOrigin(bomb.GetOrigin() + Vector(0.0, 0.0, BombBacktracker.TimerZOffset));
		}

		scope.Backtrack <- function()
		{
			local lastKnownArea = NavMesh.GetNearestNavArea(bomb.GetOrigin(), 10000.0, false, false);
			local endArea = NavMesh.GetNearestNavArea(BombBacktracker.HomePosition, 10000.0, false, false);
			if (BombBacktracker.BlacklistedAreaIDs.len() > 0)
			{
				foreach (id in BombBacktracker.BlacklistedAreaIDs)
				{
					local area = NavMesh.GetNavAreaByID(id);
					area.MarkAsBlocked(Constants.ETFTeam.TF_TEAM_BLUE);
				}
			}
			local areas = {};
			NavMesh.GetNavAreasFromBuildPath(lastKnownArea, endArea, BombBacktracker.HomePosition, 0.0, Constants.ETFTeam.TF_TEAM_BLUE, false, areas);

			if (BombBacktracker.BlacklistedAreaIDs.len() > 0)
			{
				foreach (id in BombBacktracker.BlacklistedAreaIDs)
				{
					local area = NavMesh.GetNavAreaByID(id);
					area.UnblockArea();
				}
			}

			if (areas.len() == 0)
			{
				return;
			}

			foreach (area in areas)
			{
				if (NavMesh.NavAreaTravelDistance(lastKnownArea, area, BombBacktracker.BacktrackDistanceMax) >= BombBacktracker.BacktrackDistanceMin)
				{
					DispatchParticleEffect("eyeboss_tp_player", bomb.GetOrigin(), Vector(0, 0, -90));
					EmitSoundEx({
						sound_name = "ui/mm_queue.wav"
						sound_level = 85
						entity = bomb
						filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
					})
					bomb.SetAbsOrigin(area.GetCenter() + Vector(0.0, 0.0, 10.0));
					scope.UpdateTimerPosition();
					return;
				}
			}
		}

		scope.Think <- function()
		{
			local time = Time();
			if (scope.ReturnTimer == null)
			{
				scope.CreateTimer();
			}

			if (scope.PersistentTime <= 0.0)
			{
				scope.PersistentTime = BombBacktracker.BacktrackTime;
			}

			if (!scope.IsDropped || bomb.GetOwner() != null)
			{
				return 0;
			}

			if ((NetProps.GetPropFloat(self, "m_flResetTime") - time) <= 0.025)
			{
				NetProps.SetPropFloat(self, "m_flResetTime", time + 0.025);
			}

			if (scope.NextJumpTime <= time)
			{
				scope.Backtrack();
				scope.NextJumpTime = time + BombBacktracker.BacktrackTime;
				if (BombBacktracker.UseCircleTimer)
				{
					NetProps.SetPropFloat(self, "m_flResetTime", scope.NextJumpTime);
					NetProps.SetPropFloat(self, "m_flMaxResetTime", BombBacktracker.BacktrackTime);
				}
			}

			if (scope.ReturnTimerUpdate <= time)
			{
				local display = ceil(scope.NextJumpTime - time);
				if (display <= 0.0)
				{
					display = 0.0;
				}
				scope.ReturnTimer.KeyValueFromString("message", format("%d", display));
				scope.ReturnTimerUpdate = time + 0.2;
			}

			return 0;
		}

		AddThinkToEnt(bomb, "Think");
	}
}
__CollectGameEventCallbacks(BombBacktracker);
PrecacheSound("ui/mm_queue.wav");