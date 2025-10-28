::Metropolis <-
{
	function OnGameEvent_recalculate_holidays(params)
	{
		CleanUp();
	}

	function OnGameEvent_mvm_begin_wave(params)
	{
		local rules = null;
		while ((rules = Entities.FindByClassname(rules, "tf_gamerules")) != null)
		{
			RemoveScope(rules);
			AddScope(rules);
		}
	}

	function OnGameEvent_mvm_wave_complete(params)
	{
		CleanUp();
	}

	function HasScope(rules)
	{
		local scope = rules.GetScriptScope();
		return ("IsFading" in scope);
	}

	function RemoveScope(rules)
	{
		local scope = rules.GetScriptScope();
		if (scope != null)
		{
			rules.TerminateScriptScope();
			NetProps.SetPropString(rules, "m_iszScriptThinkFunction", "");
			AddThinkToEnt(rules, null);
		}
	}

	function CleanUp()
	{
		local rules = null;
		while ((rules = Entities.FindByClassname(rules, "tf_gamerules")) != null)
		{
			RemoveScope(rules);
		}
		delete ::Metropolis;
	}

	function StartFadeOutTrack(track)
	{
		local rules = null;
		while ((rules = Entities.FindByClassname(rules, "tf_gamerules")) != null)
		{
			if (HasScope(rules))
			{
				local scope = rules.GetScriptScope();
				scope.StartFade(track);
				return;
			}
		}
	}

	AddScope = function(rules)
	{
		rules.ValidateScriptScope();
		if (HasScope(rules))
		{
			return;
		}

		local scope = rules.GetScriptScope();

		scope.Volume <- 1.0;
		scope.IsFading <- false;
		scope.Track <- "";

		scope.StartFade <- function(track)
		{
			scope.IsFading = true;
			scope.Volume = 1.0;
			scope.Track = track;
		}

		scope.MusicThink <- function()
		{
			if (!scope.IsFading)
			{
				return 0;
			}

			scope.Volume -= FrameTime();
			if (scope.Volume <= 0.0)
			{
				scope.Volume = 0.0;
				scope.IsFading = false;
			}

			for (local i = 1, player; i <= MaxClients().tointeger(); i++)
			{
				if ((player = PlayerInstanceFromIndex(i)) != null && !IsPlayerABot(player))
				{
					EmitSoundEx({
							sound_name = scope.Track
							entity = player
							filter_type = 4
							flags = 1
							volume = scope.Volume
						})
				}
			}

			return 0;
		}

		AddThinkToEnt(rules, "MusicThink");
	}
}
__CollectGameEventCallbacks(Metropolis);