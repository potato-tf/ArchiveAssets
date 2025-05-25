local maps =
{
	"mvm_hoovydam_b10": null
	"mvm_doppler_b12" : null
	"mvm_butcher_rc1b": null
}

// Limit fix to maps with known issues so we don't run in to possible issues with incursion.
//  calculations.
if (!(GetMapName() in maps))
	return

// Move BLU spawnrooms after the round has started to fix overzealous cash collection.
//  We don't kill these in case they are targeted by popfile I/O.
// Not bothering with checks for rev since we haven't had any reports about maps with rev missions.

::PotatoSpawnCash <-
{
	worldspawn = Entities.First()
	spawnbounds = {}
	RECOMPUTE_DELAY = 2.1 // This is the game's 2.0s delay + MAXIMUM_TICK_INTERVAL.
	queued_move_time = -1.0

	function RegisterSpawns()
	{
		spawnbounds.clear()
		for (local spawn; spawn = Entities.FindByClassname(spawn, "func_respawnroom");)
			if (spawn.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE)
				spawnbounds[spawn] <- spawn.GetOrigin()
	}

	function MoveSpawns()
	{
		// Only execute the latest MoveSpawns()
		if (queued_move_time > Time())
			return

		printl("move")
		foreach (spawn, _ in spawnbounds)
			spawn.SetAbsOrigin(Vector(999999.9, 999999.9, 999999.9))
	}

	function RestoreSpawns()
	{
		printl("restore")
		foreach (spawn, origin in spawnbounds)
			spawn.SetAbsOrigin(origin)
	}

	function OnGameEvent_teamplay_round_start(_)
	{
		local nav_interface = Entities.FindByClassname(null, "tf_point_nav_interface")
		nav_interface.ValidateScriptScope()
		local scope = nav_interface.GetScriptScope()
		scope.InputRecomputeBlockers <- function()
		{
			printl("InputRecomputeBlockers")
			PotatoSpawnCash.RestoreSpawns()

			PotatoSpawnCash.queued_move_time = Time() + PotatoSpawnCash.RECOMPUTE_DELAY
			EntFireByHandle(self, "RunScriptCode",
				"PotatoSpawnCash.MoveSpawns()",
			PotatoSpawnCash.RECOMPUTE_DELAY, null, null)

			return true
		}
		scope.Inputrecomputeblockers <- scope.InputRecomputeBlockers

		RegisterSpawns()

		// Function is delayed to ensure that it runs after spawn nav squares have been
		//  marked.
		queued_move_time = Time() + RECOMPUTE_DELAY
		EntFireByHandle(worldspawn, "RunScriptCode",
			"PotatoSpawnCash.MoveSpawns()",
		RECOMPUTE_DELAY, null, null)
	}
}
__CollectGameEventCallbacks(PotatoSpawnCash)
