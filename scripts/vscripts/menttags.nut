::CONST <- getconsttable()
::ROOT <- getroottable()
const INT_MAX = 2147483647

if (!("ConstantNamingConvention" in ROOT))
{
	foreach(a, b in Constants)
	{
		foreach(k, v in b)
		{
			CONST[k] <- v != null ? v : 0
			ROOT[k] <- v != null ? v : 0
		}
	}
}

if(!("MentMissionName" in ROOT))
{
	::MentMissionName <- ""
	local ent = Entities.FindByClassname(null, "tf_objective_resource");
	MentMissionName = NetProps.GetPropString(ent, "m_iszMvMPopfileName");
}

::SpawnHook <-
{
	function OnGameEvent_recalculate_holidays(params)
	{
		local ent = Entities.FindByClassname(null, "tf_objective_resource");
		if (ent)
		{
			if (MentMissionName != NetProps.GetPropString(ent, "m_iszMvMPopfileName")) // BAIL
			{
				delete ::MentMissionName;
				delete ::SpawnHook;
				return;
			}
		}
	}

	function OnGameEvent_player_spawn(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (!IsPlayerABot(player) && params.team != 3)
		{
			return
		}
		player.TerminateScriptScope();
		NetProps.SetPropString(player, "m_iszScriptThinkFunction", "");
		AddThinkToEnt(player, null);
		EntFireByHandle(player, "RunScriptCode", "TagCheck(self)", -1, null, null)
	}
}

function TagCheck(player)
{
	local tags = {}
	player.GetAllBotTags(tags)
	foreach (tag in tags)
	{
		if (tag.find("extra_spawn_point") != null)
		{
			local params = split(tag, "|")
			if (params.len() == 1)
			{
				ClientPrint(null, 3, format("\x04[MentTags] \x07FF0000ERROR:\x01 \"extra_spawn_point\" tag must have at least 1 parameter!", params.len()))
				continue;
			}
			if (params.len() == 2)
			{
				params.append("0 0 0")
			}
			local tempVector = split(params[1], " ")
			local tempAngles = split(params[2], " ")
			local vector = Vector(tempVector[0].tofloat(), tempVector[1].tofloat(), tempVector[2].tofloat())
			local angle = QAngle(tempAngles[0].tofloat(), tempAngles[1].tofloat(), tempAngles[2].tofloat())
			player.Teleport(true, vector, true, angle, true, player.GetAbsVelocity())
			player.RemoveCondEx(TF_COND_INVULNERABLE, true)
			player.RemoveCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, true)
			player.RemoveCondEx(TF_COND_INVULNERABLE_CARD_EFFECT, true)
			player.RemoveCondEx(TF_COND_INVULNERABLE_USER_BUFF, true)
			player.RemoveCondEx(TF_COND_PHASE, true)
		}

		if (tag.find("alt_fire") != null)
		{
			player.ValidateScriptScope()
			AddThinkToEnt(player, "AltFireThink")
		}

		if (tag.find("custom_model") != null)
		{
			local params = split(tag, "|")
			if (params.len() == 1)
			{
				ClientPrint(null, 3, format("\x04[MentTags] \x07FF0000ERROR:\x01 \"custom_model\" tag must have at least 1 parameter!", params.len()))
				continue;
			}

			local model = params[1];
			PrecacheModel(model);
			player.SetCustomModelWithClassAnimations(model);
		}
	}
}

::AltFireThink <- function()
{
	self.PressAltFireButton(0.0)
}
__CollectGameEventCallbacks(SpawnHook)