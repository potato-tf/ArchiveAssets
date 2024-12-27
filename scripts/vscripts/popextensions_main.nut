::popExtensionsVersion <- "12.27.2024.1"
local _root = getroottable()

local o = Entities.FindByClassname(null, "tf_objective_resource")

//save popfile name in global scope when we first initialize
//if the popfile name changed, a new pop has loaded, clean everything up.
::__popname <- NetProps.GetPropString(o, "m_iszMvMPopfileName")

// ::commentaryNode <- SpawnEntityFromTable("point_commentary_node", {targetname = "  IGNORE THIS ERROR \r"})

//overwrite AddThinkToEnt
//certain entity types use think tables, meaning any external scripts will conflict with this and break everything
//we could replace this behavior entirely, but this would be misleading to newer scripters
//don't want to lead them astray by allowing adding multiple thinks with AddThinkToEnt in our library and our library only.

local banned_think_classnames = {
	player = "PlayerThinkTable"
	tank_boss = "TankThinkTable"
	tf_projectile_ = "ProjectileThinkTable"
	tf_weapon_ = "ItemThinkTable"
	tf_wearable = "ItemThinkTable"
}

if (!("_AddThinkToEnt" in _root))
{
	//rename so we can still use it elsewhere
	//this also allows people to override the think restriction by using _AddThinkToEnt(ent, "FuncNameHere") instead
	//I'm not including this in the warning, only the people that know what they're doing already and can find it here should know about it.
	::_AddThinkToEnt <- AddThinkToEnt

	::AddThinkToEnt <- function(ent, func)
	{
		//mission unloaded, revert back to vanilla AddThinkToEnt
		if (!("__popname" in _root))
		{
			_AddThinkToEnt(ent, func)
			AddThinkToEnt <- _AddThinkToEnt
			return
		}

		foreach (k, v in banned_think_classnames)
			if (startswith(ent.GetClassname(), k))
			{
				error(format("ERROR: **POPEXTENSIONS WARNING: AddThinkToEnt on '%s' entity overwritten!**\n", k))
				// ClientPrint(null, HUD_PRINTTALK, format("\x08FFB4B4FF**WARNING: AddThinkToEnt on '%s' entities is forbidden!**\n\n Use PopExtUtil.AddThinkToEnt instead.\n\nExample: AddThinkToEnt(ent, \"%s\") -> PopExtUtil.AddThinkToEnt(ent, \"%s\")", k, func, func))

				local entstring = ""+ent
				//we use printl instead of printf because it's redirected to player console on potato servers
				printl(format("\n\n**POPEXTENSIONS WARNING: AddThinkToEnt on '%s' overwritten!**\n\nAddThinkToEnt(ent, \"%s\") -> PopExtUtil.AddThinkToEnt(ent, \"%s\")\n\n", entstring, func, func))
				PopExtUtil.AddThinkToEnt(ent, func)
				return
			}

		_AddThinkToEnt(ent, func)
	}
}
::PopExtMain <- {

	//manual cleanup flag, set to true for missions that are created for a specific map.
	//automated unloading is meant for multiple missions on one map, purpose-built map/mission combos (like zm_redridge) don't need this.
	ManualCleanup = false

	function PlayerCleanup(player) {

		NetProps.SetPropInt(player, "m_nRenderMode", kRenderNormal)
		NetProps.SetPropInt(player, "m_clrRender", 0xFFFFFF)

		player.ValidateScriptScope()
		local scope = player.GetScriptScope()

		if (scope.len() <= 5) return

		//ignore these variables when cleaning up
		local ignore_table = {
			"self"      : null
			"__vname"   : null
			"__vrefs"   : null
			"Preserved" : null
			"popWearablesToDestroy" : null
			"ExtraLoadout" : null
		}
		foreach (k, v in scope)
			if (!(k in ignore_table))
				delete scope[k]
	}
	Error = {

		RaisedParseError = false

		function DebugLog(LogMsg) {
			if (MissionAttributes.DebugText) {
				ClientPrint(null, HUD_PRINTCONSOLE, format("MissionAttr: %s.", LogMsg))
			}
		}
		// TODO: implement a try catch raise system instead of this

		// Raises an error if the user passes an index that is out of range.
		// Example: Allowed values are 1-2, but user passed 3.
		function RaiseIndexError(attr, max = [0, 1])
			ParseError(format("Index out of range for %s, value range: %d - %d", attr, max[0], max[1]))

		// Raises an error if the user passes an argument of the wrong type.
		// Example: Allowed values are strings, but user passed a float.
		function RaiseTypeError(attr, type)
			ParseError(format("Bad type for %s (should be %s)", attr, type))

		// Raises an error if the user passes an invalid argument
		// Example: Attribute expects a bitwise operator but value cannot be evenly split into a power of 2
		function RaiseValueError(attr, value, extra = "")
			ParseError(format("Bad value %s	passed to %s. %s", value.tostring(), attr, extra))

		// Raises a template parsing error, if nothing else fits.
		function ParseError(ErrorMsg) {

			if (!this.RaisedParseError) {

				this.RaisedParseError = true
				ClientPrint(null, HUD_PRINTTALK, "\x08FFB4B4FFIt is possible that a parsing error has occured. Check console for details.")
			}
			ClientPrint(null, HUD_PRINTCONSOLE, format("%s %s.\n", POPEXT_ERROR, ErrorMsg))

			foreach (player in PopExtUtil.HumanArray) {

				if (player == null) continue

				EntFireByHandle(PopExtUtil.ClientCommand, "Command", format("echo %s %s.\n", POPEXT_ERROR, ErrorMsg), -1, player, player)
			}
			printf("%s %s.\n", POPEXT_ERROR, ErrorMsg)
		}

		// Raises an exception.
		// Example: Script modification has not been performed correctly. User should never see one of these.
		function RaiseException(ExceptionMsg) {
			Assert(false, format("POPEXT EXCEPTION: %s.", ExceptionMsg))
		}
	}
	Events = {
		function OnGameEvent_post_inventory_application(params) {
			if (GetRoundState() == GR_STATE_PREROUND) return

			local player = GetPlayerFromUserID(params.userid)

			PopExtMain.PlayerCleanup(player)

			player.ValidateScriptScope()
			local scope = player.GetScriptScope()

			scope.userid <- params.userid

			if (!("PlayerThinkTable" in scope)) scope.PlayerThinkTable <- {}
			if (!("Preserved" in scope)) scope.Preserved <- {}

			if (player.IsBotOfType(TF_BOT_TYPE))
			{
				EntFireByHandle(player, "RunScriptCode", @"
					PopExtTags.EvaluateTags(self)
					aibot <- AI_Bot(self)

					PlayerThinkTable.BotThink <- function() {
						try
							aibot.OnUpdate()
						catch(e)
							if (e == `the index 'bot' does not exist`) return
					}
				", -1, player, player);

			}

			scope.PlayerThinks <- function() { foreach (name, func in scope.PlayerThinkTable) func.call(scope); return -1 }

			_AddThinkToEnt(player, "PlayerThinks")

			if (player.GetPlayerClass() > TF_CLASS_PYRO && !("BuiltObjectTable" in scope))
			{
				scope.BuiltObjectTable <- {}
				scope.buildings <- []
			}

			if ("MissionAttributes" in _root) foreach (_, func in MissionAttributes.SpawnHookTable) func(params)
			// if ("GlobalFixes" in _root) foreach (_, func in GlobalFixes.SpawnHookTable) func(params)
			if ("CustomAttributes" in _root) foreach (_, func in CustomAttributes.SpawnHookTable) func(params)
			if ("PopExtPopulator" in _root) foreach (_, func in PopExtPopulator.SpawnHookTable) func(params)
			if ("CustomWeapons" in _root) foreach (_, func in CustomWeapons.SpawnHookTable) func(params)
		}
		function OnGameEvent_player_changeclass(params) {
			local player = GetPlayerFromUserID(params.userid)

			for (local model; model = FindByName(model, "__bot_bonemerge_model");)
				if (model.GetMoveParent() == player)
					EntFireByHandle(model, "Kill", "", -1, null, null)
		}

		//clean up bot scope on death
		function OnGameEvent_player_death(params) {

			local player = GetPlayerFromUserID(params.userid)

			if (!player.IsBotOfType(TF_BOT_TYPE)) return

			PopExtMain.PlayerCleanup(player)
		}

		function OnGameEvent_teamplay_round_start(_) {

			//clean up all wearables that are not owned by a player or a bot
			for (local wearable; wearable = FindByClassname(wearable, "tf_wearable*");)
				if (wearable.GetOwner() == null || IsPlayerABot(wearable.GetOwner()))
					EntFireByHandle(wearable, "Kill", "", -1, null, null)

			//same pop or manual cleanup flag set, don't run
			if (__popname == GetPropString(o, "m_iszMvMPopfileName") || PopExtMain.ManualCleanup) return

			//clean up all players
			local maxclients = MaxClients().tointeger()
			for (local i = 1; i <= maxclients; i++) {

				local player = PlayerInstanceFromIndex(i)

				if (player == null) continue

				PopExtMain.PlayerCleanup(player)
			}

			//clean up missionattributes
			MissionAttributes.Cleanup()

			//nuke it all
			local cleanup = [

				"MissionAttributes"
				"CustomAttributes"
				"PopExt"
				"PopExtTags"
				"PopExtHooks"
				"GlobalFixes"
				"SpawnTemplate"
				"SpawnTemplateWaveSchedule"
				"SpawnTemplates"
				"VCD_SOUNDSCRIPT_MAP"
				"PopExtUtil"
				"PointTemplates"
				"CustomWeapons"
				"__popname"
				"AI_Bot"
				"CustomWeapons"
				"ExtraItems"
				"Homing"
				"Include"
				"MAtr"
				"MAtrs"
				"MissionAttr"
				"MissionAttrs"
				"MissionAttrThink"
				"PathPoint"
				"popExtensionsVersion"
				"popExtEntity"
				"PopExtItems"
				"PopExtMain"
				"popExtThinkFuncSet"
				"PopExtTutorial"
				"PopulatorThink"
				"RespawnEndTouch"
				"RespawnStartTouch"
				"ScriptLoadTable"
				"ScriptUnloadTable"
			]

			foreach(c in cleanup) if (c in _root) delete _root[c]

			EntFire("_popext*", "Kill")
			EntFire("__util*", "Kill")
			EntFire("__bot*", "Kill")
		}
	}
}
__CollectGameEventCallbacks(PopExtMain.Events)

//HACK: forces post_inventory_application to fire on pop load
local maxclients = MaxClients().tointeger()
for (local i = 1; i <= maxclients; i++)
	if (PlayerInstanceFromIndex(i) != null)
		EntFireByHandle(PlayerInstanceFromIndex(i), "RunScriptCode", "self.Regenerate(true)", 0.015, null, null)

function Include(path) {
	try IncludeScript(format("popextensions/%s", path), _root) catch(e) printl(e)
}

Include("constants") //constants must include first
Include("itemdef_constants") //constants must include first
Include("item_map") //must include second
Include("attribute_map") //must include third (after item_map)
Include("util") //must include fourth

Include("hooks") //must include before popextensions
Include("popextensions")

Include("robotvoicelines") //must include before missionattributes
Include("customattributes") //must include before missionattributes
Include("missionattributes")
Include("customweapons")

Include("botbehavior") //must include before tags
Include("tags")

Include("globalfixes")
Include("spawntemplate")

// Include("tutorialtools")
// Include("populator")
