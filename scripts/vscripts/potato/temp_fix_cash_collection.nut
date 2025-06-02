// Temporary fix for the bug introduced by the May 12, 2025 patch that causes cash to be
//  collected on some maps in perfectly accessible locations.
// This fix should be removed when https://github.com/ValveSoftware/source-sdk-2013/pull/1307
//  or similar is merged.

// Fix works by moving BLU spawnrooms after the round has started so their trigger bounds
//  don't intersect the playable space.
// Checks for rev involving RED spawns are not done since we haven't had any reports of this
//  issue on maps with rev missions on archive.

// Splat constants.
::ROOT <- getroottable()
if (!("ConstantNamingConvention" in ROOT))
{
	::CONST <- getconsttable()

	foreach (Enum in Constants)
	{
		foreach (name, value in Enum)
		{
			if (value == null)
				value = 0

			CONST[name] <- value
			ROOT[name] <- value
		}
	}
}

// Limit fix to maps with known major issues so that money is still collected where possible.
local maps =
{
	"mvm_hoovydam_b10": null
	"mvm_doppler_b12" : null
	"mvm_butcher_rc1b": null
}
if (!(GetMapName() in maps))
	return

::PotatoSpawnCash <-
{
	worldspawn = Entities.First()
	RECOMPUTE_DELAY = 2.1 // This is the game's 2.0s delay + MAXIMUM_TICK_INTERVAL.

	spawnbounds = {}
	queued_move_time = -1.0

	function RegisterSpawns()
	{
		spawnbounds.clear()

		for (local spawn; spawn = Entities.FindByClassname(spawn, "func_respawnroom");)
		{
			if (spawn.GetTeam() != TF_TEAM_BLUE) continue

			// Store spawn position so we can restore them whenever we RecomputeBlockers.
			spawnbounds[spawn] <- spawn.GetOrigin()

			// Create a nobuild in the same shape as the spawn so people can't enter.
			local nobuild = Entities.CreateByClassname("func_nobuild")
			nobuild.DispatchSpawn()
			nobuild.SetSolid(SOLID_BBOX)
			nobuild.SetAbsOrigin(spawn.GetOrigin())

			local bmodel = spawn.GetModelName()
			if (bmodel != "")
				nobuild.SetModel(bmodel)
			else
				nobuild.SetSize(spawn.GetBoundingMins(), spawn.GetBoundingMaxs())
		}
	}

	function QueueMoveSpawns()
	{
		// Queue spawns to be moved after CTFNavMesh::RecomputeInternalData() has concluded.
		queued_move_time = Time() + RECOMPUTE_DELAY

		EntFireByHandle(worldspawn, "RunScriptCode",
			"PotatoSpawnCash.MoveSpawns()",
		RECOMPUTE_DELAY, null, null)
	}

	function MoveSpawns()
	{
		// Only execute the latest MoveSpawns() as some maps spam RecomputeBlockers heavily.
		if (queued_move_time > Time())
			return

		// Move spawn away so it cannot collect cash that drops.
		foreach (spawn, _ in spawnbounds)
			spawn.SetAbsOrigin(Vector(999999.9, 999999.9, 999999.9))
	}

	function RestoreSpawns()
	{
		// Move spawn back so it registers for for RecomputeBlockers.
		foreach (spawn, origin in spawnbounds)
			spawn.SetAbsOrigin(origin)
	}

	function OnRecomputeBlockers()
	{
		// Restore spawn positions for RecomputeBlockers and then and queue moving them away.
		RestoreSpawns()
		QueueMoveSpawns()
	}

	function OnGameEvent_teamplay_round_start(_)
	{
		// Register new spawnroom entities and queue moving them.
		RegisterSpawns()
		QueueMoveSpawns()

		local nav_interface = Entities.FindByClassname(null, "tf_point_nav_interface")
		nav_interface.ValidateScriptScope()
		local scope = nav_interface.GetScriptScope()

		scope.InputRecomputeBlockers <- function()
		{
			PotatoSpawnCash.OnRecomputeBlockers()
			return true
		}
		scope.Inputrecomputeblockers <- scope.InputRecomputeBlockers
	}
}
__CollectGameEventCallbacks(PotatoSpawnCash)
