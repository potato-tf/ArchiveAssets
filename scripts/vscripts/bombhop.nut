// V2

// rafmod servers use this convar to turn certain entity classes into networked-only entities, including nav_func brushes
// networked-only brush entities cannot be interacted with, meaning the essential trace checks cannot be done
// for this script to function correctly, the convar has to be set to 0

if (Convars.GetInt("sig_etc_entity_limit_manager_convert_server_entity") == 1)
{
	if (!Convars.IsConVarOnAllowList("sig_etc_entity_limit_manager_convert_server_entity"))
	{
		ClientPrint(null, 3, "WARNING: `sig_etc_entity_limit_manager_convert_server_entity` convar is not on the VScript convar allowlist! BombHop pathing will be very inaccurate!")
	}

	else
	{
		ClientPrint(null, 2, "Convar `sig_etc_entity_limit_manager_convert_server_entity` is set to 1. In order for this script to function correctly, it will now be set to 0 and force a wave reload.")

		Convars.SetValue("sig_etc_entity_limit_manager_convert_server_entity", 0)

		local pop = SpawnEntityFromTable("point_populator_interface", {})
		pop.AcceptInput("$JumpToWave", "" + NetProps.GetPropInt(Entities.FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount"), null, null)

		return
	}
}

if (!("hoprange" in self.GetScriptScope()))	// check for a unique variable that no other script uses to avoid compatibility problems
{
	// you are free to change up the variables below in any way you want via the "SetParams" function, or by editing this file directly

	debug <- false								// enable debugging, this will grant you noclip, godmode, access to debug commands, instant wave start, display messages about what the bomb is doing currently, and display error descriptions in chat and console
	debugger_id <- false						// the steamid of the user that the error handler should only display messages to (set to false to have it display errors to all players instead)
	debug_nodraw <- false						// if on a listen server, should debug draw functions execute?

	pref_spawnnavarea <- false					// personally defined ID of the nav area that should represent the robots' spawn room (set to "false" boolean to have this variable determined automatically)
	pref_hatchnavarea <- false					// personally defined ID of the nav area that should represent the hatch (set to "false" boolean to have this variable determined automatically)
	hoprange <- 500.0							// the roughly maximum distance in HUs that the bomb will aim to travel on each hop (set to 0 for the bomb to hop in place)
	hoptime_min <- 10.0 						// shortest possible cooldown between bomb hops
	hoptime_max <- 30.0 						// longest possible cooldown between bomb hops
	spawndistance_multiplier_min <- 0.9			// how far does the bomb have to be from the spawn for its hopping cooldown to be set to the minimum possible (in percentage of the total distance from spawn to hatch)
	spawndistance_multiplier_max <- 0.1 		// how close does the bomb have to be to the spawn for its hopping cooldown to be set to the maximum possible (in percentage of the total distance from spawn to hatch)
	hopduration <- 100							// how many ticks should a hopping sequence last (1 tick = 0.015s, 100 ticks = 1.5s)
	hopheight <- 100.0							// how tall in HUs should a hop be?
	checkforbadhops <- true						// should the bomb hop timer be accordingly adjusted based on hops that are too short or long?
	nohopping_when_hoptime_is_max <- true 		// should bomb hopping be disabled when hopping cooldown is set to the highest possible
	smoothhopcurve <- true						// should the bomb's hopping curve be smooth?
	allowpickupduringhop <- false				// are robots allowed to pick up the bomb in the middle of its hopping sequence?
	allowbadrouteonfailure <- false				// if no proper route can be made, should the script try to establish any possible one that doesn't care about following the bomb carrier's path?
	hoptimerdisplayclock <- true				// should the hopping timer be represented by a clock icon?
	hoptimerdisplaytext <- false				// should the hopping timer be represented by text? (can use both clock and text at the same time)
	hoptimerdisplaygracetimer <- false			// should the grace period time display under the hopping timer text?

	recovery_hatchdist <- 0.15					// when determining the best place for the bomb to rejoin with the bomb carrier's route, how far does each area have to be from the hatch to be considered? (can be a percentage of the full path's length...
	// recovery_hatchdist <- 1200				// ...or an amount in HUs)

	graceperiod_enabled <- true					// should the bomb have its hopping cooldown fully reset only a certain time after it has been picked up?
	restoredhoptime_penaltyticks <- 30			// how many ticks should it take for the hopping cooldown to fully reset after pickup (the logic runs every 0.1s, so 30 ticks equals 3 seconds)
	restoredhoptime_penaltyspread <- true		// should the hopping cooldown reset gradually over the course of the above variable or should it only fully reset after that time has expired?

	overlay_material <- false					// the directory path of the material that the overlay will display when the bomb hops (set to false to not display overlays)
	// overlay_material <- ["ovrl1", "ovrl2"]	// optionally the variable can be an array, in which case the logic will cycle through its material items periodically
	overlay_refreshtime <- 25					// how long in ticks should be the interval between checking the overlay status?
	overlay_duration <- 300						// for how many ticks should the overlay display (1 tick = 0.015s, 300 ticks = 4.5s)

	hopsound <- "misc/ks_tier_02_kill_02.wav"	// the sound that the bomb will make when hopping ("false" bool will set it to no sound)
	hopsound_level <- 75						// sound_level parameter of the emitsoundex function that emits the hopsound
	variable_hopsound_pitch <- false			// should the pitch of the hop sound vary depending on hop distance?

	prehop_funcs <- []							// an array containing all functions that will be run when the bomb starts hopping (you can append your own functions from outside this script here)
	posthop_funcs <- []							// an array containing all functions that will be run when the bomb stops hopping (you can append your own functions from outside this script here)

	hop_responses_enabled <- true				// should the mercs react to hopping bombs with voicelines?
	hop_response_radius <- 450.0				// the radius in HUs that defines how close a player has to be to a hopping bomb to be able to respond to it
	hop_response_chance <- 4					// odds of a player responding to a hopping bomb (odds in % are 100 divided by this variable, values below 1 are set to 1)

	hop_responses <- 							// the voicelines that the mercs will use when reacting to a hopping bomb (all of these were repurposed from the payload game mode)
	{
		scout = [2512, 2513, 2514, 2515, 2516, 2517],
		soldier = [],
		pyro = [],
		demoman = [7719, 7720],
		heavy = [1990, 2070, 2268],
		engineer = [],
		sniper = [2335, 2444, 2445],
		medic = [],
		spy = []
	}

	hop_response_conditions <-					// array containing functions that will be run when determining whether to play a hop response cue
	[
		[										// each item in the array must be another array containing two items:
			SniperZoom <- function(ply)			// 1. the function that checks whether a cue should run (should always demand a player input that is provided by the think function)
			{
				if (ply.InCond(1) && ply.GetPlayerClass() == 2) return true	// the function must return a "true" bool if its check passes

				return false
			},

			[2519, 2542, 2543]					// 2. and another array containing the list of voice cues to randomly select from if successful
		]
	]

	hopcurve_func <- function() { return ((hopend + hopstart) * 0.5) + Vector(0, 0, hopheight) }	// the function that determines the apex of the bomb's hop (and overall curve if smoothhopcurve is set to true)

	// if bomb hopping isn't working properly on a certain map, experimenting with toggling the variables below might help address any issues

	fixpoornavconnections <- true			// certain maps tend to have nav areas that are wrongly connected to other unreachable areas that are far above them, setting this to true will adjust these connections to be one-directional (up -> down) (reload the map to undo this)
	evaluatedisabledprefers <- true			// should path calculation take disabled func_nav_prefer entities into consideration for better path determination? (this may produce path failures on sequoia-styled gate maps that use prefers for guiding bots through shortcuts)
	considerburiedareas <- false			// when looking for areas affected by nav cost brushes, should those that are clipping with the world receive extra height calculations? (recommended for maps that use lots of ramps or curbs)
	ignoreelevatedareas <- false			// should the pathing ignore nav areas that are a specified amount of HUs above the ground? (recommended for maps that tend to make bots go airborne like hoovydam and radar)
	areaheightlimit <- 100.0				// how far from the ground does a nav area have to be for the pathing to discard it?

	// if bomb hopping isn't working properly on a certain map, experimenting with toggling the variables above might help address any issues

	mapspecfic_improvements <- true		// should the script automatically set certain variables based on the current map? (recommended)

	// you are free to change up the variables above in any way you want via the "SetParams" function, or by editing this file directly

	lifetick <- 0							// amount of ticks that passed since script creation
	terminate <- false						// is the script meant to end its run asap?
	defaultreset_cooldown <- NetProps.GetPropInt(self, "m_nReturnTime")	// how long does it take for the bomb to reset in vanilla gameplay

	allareas <- []							// array representing ALL nav areas on the map
	spawnareas <- []						// array representing all nav areas inside robots' spawn room(s)

	alwaysallownav_array <- []				// an array holding all nav areas will never be put into the "blocknav_array" variable
	neverallownav_array <- []				// an array holding all nav areas will always be put into the "blocknav_array" variable

	if (!(!hopsound)) PrecacheSound(hopsound)

	local allareas_table = {}
	NavMesh.GetAllAreas(allareas_table)
	for (local i = 0; i < allareas_table.len(); i++) allareas.append(allareas_table["area" + i])
	navconnectionsfixed_check <- allareas[0]
	foreach (nav in allareas) { if (nav.HasAttributeTF(4)) spawnareas.append(nav) }

	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	// SETUP FUNCTIONS
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////

	SetUp <- function() // the variables in this function are dynamically adjusted by the think logic, so don't modify them yourself
	{
		nav_interface <- Entities.FindByClassname(null, "tf_point_nav_interface")	// some maps tend to use this entity to dynamically block and unblock certain nav areas midwave, requiring recomputation of the bomb's main route

		hoptime <- hoptime_max				// current cooldown between bomb hops

		blocknav_array <- [] 				// an array holding all nav areas that the bomb's pathing functions should avoid using

		spawnnavarea <- false				// the area that is currently being used to represent the robots' spawn room
		hatchnavarea <- false				// the area that is currently being used to represent the hatch
		nohopping <- true					// is the bomb allowed to hop
		justhopped <- false					// has the bomb hopped just now?
		moving <- false 					// is the bomb currently hopping?
		toapex <- true 						// if the bomb is hopping, is it currently on its way towards the apex of the hop?
		moveamount <- Vector() 				// how much should the bomb change its origin while hopping on every tick
		hopstart <- Vector() 				// where the hopping sequence began its course
		hopapex <- Vector() 				// where the apex of the hopping sequence is
		hopend <- Vector() 					// where the hopping sequence ends its course
		endmovetick <- 0					// tick at which a hop should conclude
		hoplength <- 0						// how far did the bomb go on its last hop?
		hopduration_midjump <- 0			// what is the bomb's hop duration for the hop it's currently doing?
		hopcurve_array <- []				// an array containing all vectors the bomb will teleport to while performing a smooth curve hop
		disttospawn <- null 				// the bomb's distance in HUs from its current position to the robot spawn
		fullroute_navarray <- []			// an array containing the nav areas that the bomb will hop over on its way from the spawn to the hatch
		fullroute_length <- 0 				// the total distance in HUs that the bomb has to travel from the robot spawn to the hatch
		routerecovery <- false				// did the bomb get lost and is recovering back to the main route?
		botcarrier <- false					// which bot is carrying me right now?
		evaluatingnavbrushes <- false		// have we evaluated nav brushes on this tick?

		restoredhoptime <- 0.0				// the amount of time to deduct from the bomb's hopping cooldown after it has been dropped
		restoredhoptime_remainder <- 0.0	// the amount of time recorded from the previous grace period
		restoredhoptime_penalty <- 0.0		// the amount of time to deduct from the grace period each tick while the bomb is being carried
		restoredhoptime_penaltytick <- 0.0	// the tick at which the grace period should expire

		overlay_on <- false					// is the overlay meant to be displayed right now
		overlay_off_tick <- 0				// the tick at which the overlay should stop being displayed

		debug_pathtest <- false				// are we in the middle of testing bombhop pathing?
		debug_recoverytest <- false			// are we in the middle of testing bombhop recovery pathing?

		text_timer <- false					// the entity responsible for displaying the timer in text form
		text_gracetimer <- false			// the entity responsible for displaying the grace timer

		if (hoptimerdisplaytext)
		{
			text_timer = Entities.FindByName(null, self.GetName() + "_bombhop_texttimer")

			if (text_timer == null)
			{
				text_timer = SpawnEntityFromTable("point_worldtext",
				{
					targetname		= self.GetName() + "_bombhop_texttimer"
					textsize       	= 36
					message        	= ""
					color		   	= "255 255 255"
					font           	= 1
					orientation    	= 1
					textspacingx   	= 1
					textspacingy   	= 1
					rendermode     	= 3
				})

				text_timer.AcceptInput("SetParent", "!activator", self, self)
				text_timer.SetLocalOrigin(Vector(0, 0, 70))
			}
		}

		if (hoptimerdisplaygracetimer)
		{
			text_gracetimer = Entities.FindByName(null, self.GetName() + "_bombhop_texttgracetimer")

			if (text_gracetimer == null)
			{
				text_gracetimer = SpawnEntityFromTable("point_worldtext",
				{
					targetname		= self.GetName() + "_bombhop_textgracetimer"
					textsize       	= 18
					message        	= ""
					color		   	= "255 255 0"
					font           	= 1
					orientation    	= 1
					textspacingx   	= 1
					textspacingy   	= 1
					rendermode     	= 3
				})

				text_gracetimer.AcceptInput("SetParent", "!activator", self, self)
				text_gracetimer.SetLocalOrigin(Vector(0, 0, 50))
			}
		}

		EntFireByHandle(self, "CallScriptFunction", "EvaluateNavBrushes", 0.4, null, null) 	// the nav mesh updates itself only every 0.2s, so let's give it time to acknowledge the brush entities to later scan through

		SetTouchable(true) // this may sometimes run in the middle of a bomb's hop, so let's ensure its solidity is restored
	}

	NextFrameActions <- function() // functions that will be run a frame after the script has loaded, to give outside scripts a way to intercept any undesirable actions through SetParams
	{
		if (mapspecfic_improvements)
		{
			local mapname = GetMapName()

			if (mapname.find("area_52") != null) evaluatedisabledprefers = false
			if (mapname.find("autumnull") != null) AlwaysAllowNavAreas(10, 15, 18, 33, 100, 231, 2617, 2618, 2619, 3075) // nav_avoids right outside of the spawns cause the logic to completely break
			if (mapname.find("casino_city") != null)
			{
				considerburiedareas = true

				AlwaysAllowNavAreas(5321) // one nav_avoid stretches far enough to block all ways for the bomb to pass through without touching a blocked area
			}
			if (mapname.find("derelict") != null) fixpoornavconnections = true
			if (mapname.find("downtown") != null) { fixpoornavconnections = true; considerburiedareas = true }
			if (mapname.find("giza") != null)
			{
				considerburiedareas = true
				fixpoornavconnections = true

				NavMesh.GetNavAreaByID(6387).Disconnect(NavMesh.GetNavAreaByID(6405)) // one-directional down -> up connection???
			}
			if (mapname.find("hideout") != null) fixpoornavconnections = true
			if (mapname.find("hoovydam") != null)
			{
				NavMesh.GetNavAreaByID(1475).Disconnect(NavMesh.GetNavAreaByID(38))
				NavMesh.GetNavAreaByID(289).ConnectTo(NavMesh.GetNavAreaByID(293), 1)	// remove bad connection from one of the launch fans and replace it with a better one

				ignoreelevatedareas = true
			}
			if (mapname.find("isolation") != null) fixpoornavconnections = true
			if (mapname.find("lotus") != null) fixpoornavconnections = true
			if (mapname.find("meltdown") != null)
			{
				fixpoornavconnections = true

				NeverAllowNavAreas(92) // flank route near bomb has no nav_avoid to discourage bombhop pathing through it (bomb carriers have a nav_prefer at the main entry point so they aren't affected)
			}
			if (mapname.find("metro") != null) fixpoornavconnections = true
			if (mapname.find("_null_") != null) AlwaysAllowNavAreas(15, 18, 33, 100, 231, 2626, 2627, 3102, 3118, 3120, 3127, 3129) // nav_avoids right outside of the spawns cause the logic to completely break
			if (mapname.find("powerplant") != null) fixpoornavconnections = true
			if (mapname.find("radar") != null)
			{
				fixpoornavconnections = true

				NavMesh.GetNavAreaByID(16025).Disconnect(NavMesh.GetNavAreaByID(16970)) // one-directional down -> up connection???
			}
			if (mapname.find("seabed") != null) considerburiedareas = true
			if (mapname.find("sequoia") != null) evaluatedisabledprefers = false
			if (mapname.find("spacepost") != null) evaluatedisabledprefers = true
			if (mapname.find("underworld") != null)
			{
				fixpoornavconnections = true

				NeverAllowNavAreas(73) // right flank route has no nav_avoid whatsoever
			}
		}

		if (debug) SetUpDebug()

		if (GetListenServerHost() == null) debug_nodraw = true	// debug draw commands don't work on non-listen servers

		if (fixpoornavconnections) FixPoorNavConnections()

		if (hoptimerdisplayclock) self.KeyValueFromFloat("ReturnTime", 599.0)	// this netprop doesn't actually control the return time, but it decides whether to draw the clock icon above the bomb (< 600 = draw, >= 600 = don't draw)
		else					  self.KeyValueFromFloat("ReturnTime", 600.0)
	}

	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	// INTERACTIVE FUNCTIONS (can be called from your own script)
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////

	/* SetParams example usage:

	local bombscope = Entities.FindByName(null, "bombnamehere").GetScriptScope()

	bombscope.SetParams(
	["hoprange", 800.0],
	["hopduration", 25],
	)

	*/

	SetParams <- function(...)
	{
		local endresult = []
		local scope = self.GetScriptScope()

		foreach (arg in vargv)
		{
			if (!(arg[0] in scope))
			{
				DebugMsg("SetParams: Parameter " + arg[0] + " doesn't exist, aborting.")
				continue
			}

			if (scope[arg[0]] == arg[1])
			{
				DebugMsg("SetParams: Parameter " + arg[0] + " is already set to value " + arg[1] + ", aborting.")
				continue
			}

			scope[arg[0]] = arg[1]

			local process = []

			process.append(arg[0])
			process.append(arg[1])

			endresult.append(process)

			DebugMsg("SetParams: Successfully set " + arg[0] + " to " + arg[1] + ".")
		}

		DebugMsg("SetParams: Function has successfully executed.", true)

		PostSetParams(endresult)
	}

	// AlwaysAllowNavAreas / NeverAllowNavAreas example usage:
	// bombscope.AlwaysAllowNavAreas(51, 5, 100, 3214, 999)
	// bombscope.NeverAllowNavAreas(24, 48, 2, 75, 1815, 2041)


	AlwaysAllowNavAreas <- function(...)	// these areas will never be considered as undesirable for path determination
	{
		foreach (navid in vargv) { alwaysallownav_array.append(NavMesh.GetNavAreaByID(navid)) }
	}

	NeverAllowNavAreas <- function(...) // these areas will always be considered as undesirable for path determination
	{
		foreach (navid in vargv) { neverallownav_array.append(NavMesh.GetNavAreaByID(navid)) }
	}

	SetTouchable <- function(boolinput) // set whether the robots can pick up the bomb or not, accepts false or true
	{
		if (boolinput)
		{
			NetProps.SetPropInt(self, "m_Collision.m_nSolidType", 2)
			NetProps.SetPropInt(self, "m_Collision.m_usSolidFlags", 140)
		}

		else
		{
			NetProps.SetPropInt(self, "m_Collision.m_nSolidType", 0) 	// we need to make sure the hop is not interrupted by a robot, these netprops make the bomb completely untouchable by robots
			NetProps.SetPropInt(self, "m_Collision.m_usSolidFlags", 0)	// there are SetSolidType and SetSolidFlags VScript functions, but you shouldn't use those, since they permanently alter the bomb's hitbox and cause complications
		}
	}

	TerminateHopScript <- function()
	{
		terminate = true

		if (moving)	// wait until hopping is done
		{
			DebugMsg("Can't terminate in mid-hop, waiting until resolution.", true)
			return
		}

		self.AcceptInput("SetReturnTime", "" + defaultreset_cooldown, null, null)

		if (defaultreset_cooldown > 600.0) NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)

		if (hoptimerdisplaytext) text_timer.Kill()
		if (hoptimerdisplaygracetimer) text_gracetimer.Kill()

		AddThinkToEnt(self, null)
		NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")

		self.TerminateScriptScope()
	}

	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	// MAIN FUNCTIONS
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////

	DetermineFullRoute <- function(redo = false)		// this function will run once as soon as the wave starts and attempt to build a "spawn -> hatch" route that imitates the bomb carrier's path, it's crucial for all the other bombhop logic to function properly
	{
		if (NetProps.GetPropBool(self, "m_bDisabled")) return

		DebugMsg("DetermineFullRoute has been called")

		if (!redo)	// the wave has just started, let's determine initial spawn and hatch areas
		{
			DebugMsg("DetermineFullRoute: Initial run detected.")

			if (!(!pref_spawnnavarea) || !(!pref_hatchnavarea))	// if starting and/or ending areas were manually provided, use those instead of automatically determining them
			{
				DebugMsg("DetermineFullRoute: Determining spawn or hatch nav areas based off manual input...")

				if (!(!pref_spawnnavarea)) spawnnavarea = NavMesh.GetNavAreaByID(pref_spawnnavarea)
				if (!(!pref_hatchnavarea)) hatchnavarea = NavMesh.GetNavAreaByID(pref_hatchnavarea)
			}

			if (!spawnnavarea)
			{
				DebugMsg("DetermineFullRoute: spawnnavarea variable not provided, attempting to determine it...")

				if (NetProps.GetPropInt(self, "m_nFlagStatus") == 0)	// depending on the map, bombs with "at home" flags may stay in inaccessible and isolated areas that are far from the map proper
				{
					DebugMsg("DetermineFullRoute: Flag is at home, aborting.", true)
					return
				}

				local bestarea = false

				if (self.GetOwner() != null) bestarea = self.GetOwner().GetSpawnArea()	// if we're being carried, assume the start area is where the current carrier spawned

				else	// otherwise collect all spawn areas of currently alive bots, and select one that was used the most
				{
					local maxclients = MaxClients().tointeger()

					local spawns = {}
					local highestamount = 0

					for (local i = 1; i <= maxclients; i++)
					{
						local player = PlayerInstanceFromIndex(i)

						if (player == null) continue
						if (player.GetTeam() != 3) continue
						if (!player.IsAlive()) continue
						if (player.IsOnAnyMission()) continue

						local spawnarea = player.GetSpawnArea()

						if (spawnarea == null) continue

						if (!(spawnarea in spawns)) spawns[spawnarea] <- 0
						spawns[spawnarea]++
					}

					foreach (spawnarea, amount in spawns)
					{
						if (amount > highestamount)
						{
							highestamount = amount
							bestarea = spawnarea
						}
					}
				}

				spawnnavarea = bestarea
			}

			if (!hatchnavarea)
			{
				DebugMsg("DetermineFullRoute: hatchnavarea variable not provided, attempting to determine it...")

				hatchnavarea = FindBestNearestNavMesh(Entities.FindByClassname(null, "func_capturezone").GetCenter())	// any nav mesh that sits as close to where the bomb carrier could start doing its deploying animation
			}
		}

		else DebugMsg("DetermineFullRoute: Redetermining route...") // we're calling this mid-wave, no need to redefine starting and ending points that we already know

		if (!spawnnavarea) DebugMsg("DetermineFullRoute: Failed, couldn't find a NavMesh that's inside the robot spawn", true)
		if (!hatchnavarea) DebugMsg("DetermineFullRoute: Failed, couldn't find a NavMesh that's close to the hatch", true)

		if (!spawnnavarea || !hatchnavarea) return

		DebugMsg("DetermineFullRoute: Successfully determined spawnnavarea (" + spawnnavarea + ") and hatchnavarea (" + hatchnavarea + ") variables")

		if (blocknav_array.find(spawnnavarea) != null) blocknav_array.remove(blocknav_array.find(spawnnavarea))	// sometimes there might be nav brushes very close to the robot spawn and/or hatch, let's make sure they don't effect the starting and ending areas
		if (blocknav_array.find(hatchnavarea) != null) blocknav_array.remove(blocknav_array.find(hatchnavarea))

		fullroute_navarray = BombHop_BuildPath(spawnnavarea, hatchnavarea)	// build a path that should completely imitate the path a bomb carrier would take

		// some maps tend to have spawn rooms that are gated off from the rest of the map during setup, like bigrock or underworld
		// in that case let's retry and temporarily unblock all meshes that are considered blocked because of these gates

		if (!fullroute_navarray)
		{
			DebugMsg("DetermineFullRoute: Failed to establish path, retrying with unblocked map-placed nav meshes")

			fullroute_navarray = BombHop_BuildPath(spawnnavarea, hatchnavarea, true)
		}

		if (!fullroute_navarray && allowbadrouteonfailure)	// if we really want to, make any possible path, ignoring the bomb carrier's path altogether
		{
			DebugMsg("DetermineFullRoute: Failed to establish path, retrying with no blocked areas.", true)
			fullroute_navarray = BombHop_BuildPath(spawnnavarea, hatchnavarea, true, true)
		}

		if (!fullroute_navarray)	// couldn't make path anyway, keep retrying until something changes
		{
			DebugMsg("DetermineFullRoute: Failed to establish any path, aborting.", true)
			return
		}

		local new_fullroute_navarray = []	// we ideally don't want the hopping pathing to take spawn rooms into consideration, especially if they're large ones like on decoy

		foreach (nav in fullroute_navarray)	// let's go through all the collected areas and toss out those that have "blu spawnroom" area attribute
		{
			if (GetAreaHeight(nav) > areaheightlimit) continue	// some maps like hoovy dam may place nav areas in mid air, let's not let the bomb stay on such areas (`ignoreelevatedareas` variable has to be set to true)
			if (nav.HasAttributeTF(4)) break					// as soon as we hit an area that's in the spawn room, discard it and all the next ones

			new_fullroute_navarray.append(nav)
		}

		fullroute_navarray = new_fullroute_navarray

		spawnnavarea = fullroute_navarray[fullroute_navarray.len() - 1]	// update the "spawnnavarea" variable that still defines an area in the spawn room, replace it with first one encountered after leaving it
		hatchnavarea = fullroute_navarray[0]

		fullroute_length = DeterminePathLength(fullroute_navarray, [0, 255, 0, 255])

		DebugMsg("DetermineFullRoute ran successfully. fullroute_length = " + fullroute_length + " | fullroute_navarray.len() = " + fullroute_navarray.len(), true)

		if (!redo && NetProps.GetPropInt(self, "m_nFlagStatus") == 2)
		{
			if (hoptimerdisplayclock) self.AcceptInput("ShowTimer", "0.0", null, null)	// display clock if it was hidden
			DetermineReturnTime()	// start the hop timer if the script got called while the bomb was idle
		}

		if (debug && !debug_nodraw)
		{
			DebugDrawText(spawnnavarea.GetCenter(), "SPAWN_NAV", false, 5.0)
			DebugDrawText(hatchnavarea.GetCenter(), "HATCH_NAV", false, 5.0)

			local i = 1

			foreach (nav in fullroute_navarray)
			{
				DebugDrawText(nav.GetCenter(), "" + i, false, 5.0)
				i++
			}
		}
	}

	DetermineReturnTime <- function()
	{
		if (terminate) { TerminateHopScript(); return }

		if (!InWave()) return										// no point
		if (fullroute_length <= 0) return							// we need a full spawn -> hatch route before we can do anything
		if (NetProps.GetPropInt(self, "m_nFlagStatus") < 2) return	// don't hop if we're not idle
		if (moving)	return											// failsafe

		DebugMsg("DetermineReturnTime has been called")

		if (debug_recoverytest && !routerecovery)
		{
			local recoveryareas = []

			foreach (nav in allareas)
			{
				if (fullroute_navarray.find(nav) != null) continue
				if (nav.HasAttributeTF(2)) continue
				if (nav.HasAttributeTF(4)) continue
				if (nav == hatchnavarea) continue
				if (nav == spawnnavarea) continue

				recoveryareas.append(nav)
			}

			self.SetAbsOrigin(recoveryareas[RandomInt(0, recoveryareas.len() - 1)].GetCenter())
		}

		local calcresult = CalculateDistance()		// we'll need to calculate the distance to tell when and how often the bomb should hop, let's call the function and let it know us what the verdict is

		if (calcresult.atspawn)						// the bomb is sitting nearby the spawn room, so there is nowhere for it to really hop towards
		{
			DebugMsg("DetermineReturnTime: Bomb is sitting in spawn, disabling hopping.", true)

			nohopping = true

			restoredhoptime = 0.0					// reset everything related to the grace period
			restoredhoptime_remainder = 0.0
			restoredhoptime_penalty = 0.0

			NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0)	// this will hide the timer floating above the bomb
			NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)

			return -1
		}

		if (!calcresult.success)												// something went wrong, and we don't know why
		{
			DebugMsg("DetermineReturnTime: Distance calculation failed, aborting.", true)

			NetProps.SetPropFloat(self, "m_flResetTime", Time() + hoptime)	// don't hop, try again next time
			NetProps.SetPropFloat(self, "m_flMaxResetTime", hoptime)

			return -1
		}

		// we have determined how far the bomb is from the spawn, let's adjust the hopping timer based on that distance

		hoptime = RemapValClamped(disttospawn, fullroute_length * spawndistance_multiplier_min, fullroute_length * spawndistance_multiplier_max, hoptime_min, hoptime_max)

		if (nohopping_when_hoptime_is_max && hoptime >= hoptime_max && hoptime_min != hoptime_max) 	// the timer can't be any higher than this, meaning the bomb hasn't made any real progress yet
		{
			DebugMsg("DetermineReturnTime: Hopping timer is set to highest possible, disabling hopping.", true)	// let's not beat the dead horse that is the robot team and disable hopping for now

			nohopping = true

			restoredhoptime = 0.0
			restoredhoptime_remainder = 0.0
			restoredhoptime_penalty = 0.0

			NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0)
			NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)

			return -1
		}

		else nohopping = false	// the bomb did make progress, so let's allow it to hop

		local restoredhoptimepercent = 1.0

		if (graceperiod_enabled)
		{
			restoredhoptime_penalty = 0

			restoredhoptimepercent = 1.0 + (restoredhoptime / hoptime)

			hoptime -= restoredhoptime					// deduct the grace period from the determined hop timer

			restoredhoptime_remainder = restoredhoptime	// retain any grace periods that persisted while the bomb was being carried
		}

		if (justhopped && checkforbadhops)				// adjust hop timer based on whether the bomb hopped too little or too far
		{
			DebugMsg("DetermineReturnTime: Last distance travelled was " + hoplength)

			local mult

			if (hoplength <= hoprange) 	mult = RemapValClamped(hoplength, 0, hoprange, 3.0, 1.0)
			else						mult = RemapValClamped(hoplength, hoprange, (hoprange * 2.0), 1.0, 0.5)

			hoptime /= mult

			DebugMsg("DetermineReturnTime: Dividing hop timer by " + mult)
		}

		justhopped = false

		if (hoptime > (hoptime_max * 2.0)) hoptime = hoptime_max	// failsafe

		if (hoptime < 0.05) { Hop(); return }	// no need to set timer, just hop immediately

		NetProps.SetPropFloat(self, "m_flResetTime", Time() + hoptime)					 	// also refresh the timer icon
		NetProps.SetPropFloat(self, "m_flMaxResetTime", hoptime * restoredhoptimepercent)	// this will make the icon somewhat more accurately represent the grace period

		// 1.5x reset = 1/4, 2x reset = 1/2, 4x reset = 3/4

		DebugMsg("DetermineReturnTime: Successfully set hopping timer to " + hoptime, true)
	}

	CalculateDistance <- function()				// this function is run whenever the bomb is dropped or when the bomb is about to perform a hop
	{
		DebugMsg("CalculateDistance has been called")

		local resulttable = 							// the function will return this table whenever it's called
		{
			success = false								// have we successfully determined the bomb's path?
			atspawn = false								// have we determined that the bomb is inside or close to a robot spawn room?
		}

		disttospawn = 0

		local bestclosestarea = false

		local recovery_path = {}
		local bestrecoveryarea = false

		DebugMsg("CalculateDistance: Searching for nearest nav area to bomb's origin...")

		local homenav = FindBestNearestNavMesh(self.GetOrigin())

		if (!homenav)
		{
			DebugMsg("CalculateDistance: Failed to find any nearest nav area to bomb's origin, aborting.", true)
			return resulttable
		}

		DebugMsg("CalculateDistance: Successfully found nearest nav arae to bomb's origin: " + homenav)

		if (homenav.HasAttributeTF(4))
		{
			DebugMsg("CalculateDistance: Bomb is sitting in spawn, aborting.", true)
			resulttable.success = true
			resulttable.atspawn = true
			return resulttable
		}

		local fullroute_slot = null
		local distance = 0
		local lastdistance = 0
		local fullroute_end = fullroute_navarray[fullroute_navarray.len() - 1]

		if (fullroute_navarray.find(homenav) != null)				// if bomb sits on an area that's a part of the route, use that area as a springboard
		{
			DebugMsg("CalculateDistance: Bomb's area sits on the main route.")
			fullroute_slot = fullroute_navarray.find(homenav)
		}

		else														// otherwise check if the bomb's area is adjacent to the route, or the areas adjacent to the bomb's area
		{
			DebugMsg("CalculateDistance: Bomb's area does not sit on the main route, checking for adjacent areas.")
			local checkednavs = []

			foreach (nav in GetAllAdjacentAreas(homenav))
			{
				local found = false

				if (checkednavs.find(nav) != null) continue

				checkednavs.append(nav)

				if (fullroute_navarray.find(nav) != null) { fullroute_slot = fullroute_navarray.find(nav); break }

				foreach (nav2 in GetAllAdjacentAreas(nav))
				{
					if (checkednavs.find(nav2) != null) continue

					checkednavs.append(nav2)

					if (fullroute_navarray.find(nav2) != null)
					{
						fullroute_slot = fullroute_navarray.find(nav2)
						found = true
						break
					}
				}
			}

			if (fullroute_slot != null) distance += (fullroute_navarray[fullroute_slot].GetCenter() - homenav.GetCenter()).Length()	// the bomb is rather close to the path, but let's still ensure it doesn't hop too far
		}

		if (fullroute_slot != null)	// runs if bomb finds itself either directly on the path or pretty close to it
		{
			routerecovery = false

			DebugMsg("CalculateDistance: Found main route close to the bomb, calculating best place to hop onto.")

			bestclosestarea = fullroute_navarray[fullroute_slot]

			for (local i = fullroute_slot; i < fullroute_navarray.len() - 1; i++)	// look through all next areas on the route and determine which one makes the bomb hop the best length
			{
				local nextarea = fullroute_navarray[i + 1]
				local area = fullroute_navarray[i]

				distance += (nextarea.GetCenter() - area.GetCenter()).Length()	// add distances between next few areas and...

				if (distance < hoprange) bestclosestarea = nextarea 			// ...hop onto one that falls just barely under the hop distance limit
				else
				{
					if (nextarea.IsConnected(homenav, -1)) bestclosestarea = nextarea					// if areas are too far apart but still connected with each other, make an exception and ignore distance limit
					if ((distance - hoprange) < (hoprange - lastdistance)) bestclosestarea = nextarea 	// if we overexceed less than we underexceed, allow it
					break
				}

				lastdistance = distance
			}

			if (bestclosestarea == homenav && homenav != fullroute_end) bestclosestarea = fullroute_navarray[fullroute_slot + 1] // if we failed to find any good next area, just hop one square forward
		}

		if (!bestclosestarea)	// none of the meshes on the route are close to the bomb, meaning it got lost and has to find its way back to the route
		{
			DebugMsg("CalculateDistance: Bomb is not close to the full route, calculating recovery route.")

			routerecovery = true

			local weight = 1.0
			local weight_decrement = (0.4 / fullroute_navarray.len().tofloat())
			local bestdistance = 99999.9
			local hatchdistance = 0
			local prev_area = hatchnavarea

			DebugMsg("CalculateDistance: Weight decrement = " + weight_decrement)

			foreach (area in fullroute_navarray)												// cycle again, look for the best area to rejoin with the route
			{
				weight -= weight_decrement														// manipulate the results a little to encourage the bomb to think more about recovering back to the spawn and not the hatch

				hatchdistance += (area.GetCenter() - prev_area.GetCenter()).Length()

				prev_area = area

				if (recovery_hatchdist <= 1.0 && hatchdistance < (fullroute_length * recovery_hatchdist)) continue	// skip the first areas around the hatch to make the bomb not hop back towards it
				if (recovery_hatchdist > 1.0 && hatchdistance < recovery_hatchdist) continue

				local distance = ((area.GetCenter() - homenav.GetCenter()).Length()) * weight	// determine distance between every area on the route and the area occupied by the bomb (by order from hatch area to spawn area)

				if (distance < bestdistance)
				{
					bestdistance = distance
					bestclosestarea = area
				}
			}

			DebugMsg("CalculateDistance: Determined best area to recover to: " + bestclosestarea)

			if (debug && !debug_nodraw)
			{
				bestclosestarea.DebugDrawFilled(0, 0, 255, 255, 5.0, true, 0.0)
				DebugDrawText(bestclosestarea.GetCenter(), "-                  RECOVERYCLOSESTAREA", false, 5.0)
			}

			// the bomb is certainly further from the route than the hop limit allows, meaning we have to build an extra route back to the full route

			local recoveryblock = []

			foreach (nav in GetAllAdjacentAreas(hatchnavarea)) // ensure recovery path doesn't go near hatch
			{
				recoveryblock.append(nav)

				foreach (nav2 in GetAllAdjacentAreas(nav)) recoveryblock.append(nav2)
			}

			foreach (nav in recoveryblock) nav.MarkAsBlocked(3)

			NavMesh.GetNavAreasFromBuildPath(homenav, bestclosestarea, Vector(), 0.0, 3, false, recovery_path) // otherwise ignore any other nav brush

			foreach (nav in recoveryblock) nav.UnblockArea()

			if (recovery_path.len() <= 0) NavMesh.GetNavAreasFromBuildPath(homenav, bestclosestarea, Vector(), 0.0, 3, false, recovery_path) // ignore everything and go through hatch if unsuccessful

			DebugMsg("recovery_path.len(): " + recovery_path.len())

			if (recovery_path.len() > 0) // run the same hop distance calculation
			{
				local recoveryjumpdist = 0
				local cur_recoveryarea = recovery_path["area" + (recovery_path.len() - 1)]

				for (local i = recovery_path.len() - 1; i >= 1; i--) // ensure we hop as best as we can
				{
					local next_recoveryarea = recovery_path["area" + (i - 1)]

					recoveryjumpdist += (next_recoveryarea.GetCenter() - cur_recoveryarea.GetCenter()).Length()

					if (recoveryjumpdist < hoprange) cur_recoveryarea = next_recoveryarea
				}

				bestrecoveryarea = cur_recoveryarea
			}
		}

		if (!bestclosestarea)
		{
			DebugMsg("CalculateDistance: Failed to find a good area to hop onto, aborting.", true)
			return resulttable
		}

		disttospawn = DeterminePathLength(fullroute_navarray, [0, 255, 0, 255], bestclosestarea) // calculate the distance from the closest point on the route to the robot spawn
		disttospawn += DeterminePathLength(recovery_path, [255, 255, 0, 255])					 // then add to it the length of the recovery route, if we are on one

		DebugMsg("CalculateDistance: Successfully determined distance to spawn: " + disttospawn)

		if (debug && !debug_nodraw) DebugDrawText(bestclosestarea.GetCenter(), "-\nBESTCLOSESTAREA", false, 5.0)

		hopend = (!(!bestrecoveryarea)) ? bestrecoveryarea : bestclosestarea

		resulttable.success = true
		resulttable.atspawn = (homenav == fullroute_end) ? ((hoprange > 0.0) ? true : false) : false

		DebugMsg("CalculateDistance: Successfully determined area to hop onto: " + hopend)

		DebugMsg("CalculateDistance has resolved", true)

		return resulttable
	}

	Hop <- function()
	{
		NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0) // hide the timer icon until we're done hopping
		NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)

		local calcresult = CalculateDistance()	// start the calculations to know whether to hop and where

		if (calcresult.atspawn) return -1	// we're in spawn, no need to hop

		if (!calcresult.success)	// failed, try again next time
		{
			NetProps.SetPropFloat(self, "m_flResetTime", Time() + hoptime)

			NetProps.SetPropFloat(self, "m_flMaxResetTime", hoptime)

			return -1
		}

		hopstart = self.GetOrigin()	// the hop begins where the bomb currently is

		if (hoprange > 0.0) hopend = hopend.GetCenter()
		else				hopend = hopstart

		hoplength = (hopend - hopstart).Length()	// record hop distance for adjusting next hop cooldown
		EmitSoundEx({sound_name = hopsound, channel = 6, entity = self, sound_level = hopsound_level, pitch = (variable_hopsound_pitch) ? (100.0 * (hoprange / hoplength)) : 100.0 })
		moving = true

		hopduration_midjump = hopduration // preserve latest hopduration variable, don't let it get changed during the hop

		restoredhoptime = 0	// reset grace period
		restoredhoptime_remainder = 0

		endmovetick = lifetick + hopduration_midjump + 33	// ensure the bomb eventually ends up at its destination if something goes wrong

		if (hop_responses_enabled)
		{
			for (local i = 1; i <= MaxClients().tointeger(); i++)
			{
				local player = PlayerInstanceFromIndex(i)

				if (player == null) continue
				if (player.GetTeam() != 2) continue

				if (RandomInt(1, hop_response_chance) == 1)
				{
					if ((player.GetOrigin() - self.GetOrigin()).Length() < hop_response_radius)
					{
						local class_array = [null, "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer"]
						local pick = class_array[player.GetPlayerClass()]
						local special = false

						foreach (cond in hop_response_conditions)
						{
							if (cond[0](player))
							{
								player.PlayScene(format("scenes/Player/%s/low/%i.vcd", pick, cond[1][RandomInt(0, cond[1].len() - 1)]), -1.0)
								special = true
							}
						}

						if (!special && hop_responses[pick].len() > 0) player.PlayScene(format("scenes/Player/%s/low/%i.vcd", pick, hop_responses[pick][RandomInt(0, hop_responses[pick].len() - 1)]), -1.0)
					}
				}
			}
		}

		if (!(!overlay_material))
		{
			overlay_on = true
			overlay_off_tick = lifetick + overlay_duration
		}

		if (!allowpickupduringhop) SetTouchable(false)

		hopapex = hopcurve_func()	// determine where the hop's apex should be

		foreach (func in prehop_funcs) func()	// now's a good time to run any extra custom functions from outside scripts

		if (smoothhopcurve)
		{
			hopapex += Vector(0, 0, hopheight)	// bezier curves fall short of the apex so let's compensate
			BombHop_BuildCurve(hopstart, hopend, hopapex, hopduration_midjump)
		}
	}

	EvaluateNavBrushes <- function() 	// building a path that imitates the bomb carrier's path requires us to know and block all undesirable nav areas that we don't want pathing to go through
	{
		if (evaluatingnavbrushes) return	// ensure this runs only once each tick

		DebugMsg("EvaluateNavBrushes has been called.")

		evaluatingnavbrushes = true

		local bombtag = (NetProps.GetPropString(self, "m_iszTags").len() > 0) ? NetProps.GetPropString(self, "m_iszTags") : "bomb_carrier" // if the map has multiple bombs, ensure only the nav brushes related to this bomb are involved

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array before wipe: " + blocknav_array.len())

		blocknav_array.clear()	// reset the list of undesirable areas for recollection

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array after wipe: " + blocknav_array.len())

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array before prefer collection: " + blocknav_array.len())

		if (evaluatedisabledprefers) // if a prefer is supposed to guide the bomb, but is disabled, it probably means the bomb isn't supposed to go through it this wave, making it a useful "pseudo-avoid"
		{
			for (local ent; ent = Entities.FindByClassname(ent, "func_nav_prefer"); ) // scan through all disabled nav_prefers
			{
				if (NetProps.GetPropBool(ent, "m_isDisabled"))
				{
					local tags = split(NetProps.GetPropString(ent, "m_iszTags"), " ")

					if (tags.find("bomb_carrier") != null || tags.find(bombtag) != null)
					{
						foreach (nav in GetAreasObscuredByBrush(ent)) { if (blocknav_array.find(nav) == null) blocknav_array.append(nav) }
					}
				}
			}
		}

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array after prefer collection: " + blocknav_array.len())

		DebugMsg("EvaluateNavBrushes: Bomb tag: " + bombtag)

		for (local ent; ent = Entities.FindByClassname(ent, "func_nav_avoid"); )	// scan through all enabled nav_avoids
		{
			if (NetProps.GetPropBool(ent, "m_isDisabled")) continue

			local tags = split(NetProps.GetPropString(ent, "m_iszTags"), " ")

			if (tags.find("bomb_carrier") != null || tags.find(bombtag) != null)
			{
				foreach (nav in GetAreasObscuredByBrush(ent)) { if (blocknav_array.find(nav) == null) blocknav_array.append(nav) }
			}
		}

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array after avoid collection: " + blocknav_array.len())

		// apply map-specific fixes to the nav mesh

		foreach (nav in alwaysallownav_array) { if (blocknav_array.find(nav) != null) blocknav_array.remove(blocknav_array.find(nav)) }
		foreach (nav in neverallownav_array) { if (blocknav_array.find(nav) == null) blocknav_array.append(nav) }

		DebugMsg("EvaluateNavBrushes: Size of blocknav_array after avoid collection: " + blocknav_array.len())

		if (InWave()) DetermineFullRoute(true)		// if we're calling this in-wave, it's probably because the mesh changed and we need to redefine the route

		EntFireByHandle(self, "RunScriptCode", "evaluatingnavbrushes = false", -1.0, null, null) // make sure this func gets run only once each tick
	}

	BombHop_Think <- function() // runs every tick
	{
		lifetick++

		if (debug)	// skip wave start countdown if we're debugging
		{
			if (NetProps.GetPropBoolArray(Entities.FindByClassname(null, "tf_gamerules"), "m_bPlayerReady", 1) && !InWave())
			{
				NetProps.SetPropFloat(Entities.FindByClassname(null, "tf_gamerules"), "m_flRestartRoundTime", Time())
			}

			local maxclients = MaxClients().tointeger()

			for (local i = 1; i <= maxclients; i++)
			{
				local player = PlayerInstanceFromIndex(i)	// allow the bomb to teleport to listen server host with MOUSE3 or wipe debugdraw displays with RELOAD

				if (player == null) continue
				if (player.GetTeam() != 2) continue

				if (NetProps.GetPropInt(player, "m_afButtonLast") & 8192) DebugDrawClear()

				if (!InWave()) continue

				if (NetProps.GetPropInt(player, "m_afButtonLast") & 33554432)
				{
					if (!moving)
					{
						self.SetAbsOrigin(player.GetOrigin())
						DetermineReturnTime()
					}

					else ClientPrint(null, 3, "Can't teleport the bomb while it's hopping.")
				}
			}
		}

		if (NetProps.GetPropBool(self, "m_bDisabled")) return -1 // bomb is not in use by the mission, no need to use its hopping logic

		if (!InWave()) return -1 // no need to run this when not in a wave

		botcarrier = self.GetOwner()								// useful for recording who the carrier was when the bomb got dropped

		UpdateTextTimer()

		if (fullroute_length <= 0) DetermineFullRoute()				// for the purposes of determining the hop cooldown, we'll need to know the full length of the bomb's path from spawn to hatch

		if (fullroute_length <= 0) return -1						// if we failed, pause the logic and try again next tick

		if (!moving && !nohopping && graceperiod_enabled)			// if we are not currently hopping (but we could be able to)
		{
			if (NetProps.GetPropInt(self, "m_nFlagStatus") == 1 && lifetick % 7 == 0) 							// if a robot is currently carrying us, do this every 7 ticks (~0.1s)
			{
				if (restoredhoptime_penaltyspread) 					restoredhoptime -= restoredhoptime_penalty	// keep reducing the grace period until it drops down to 0
				else if (lifetick >= restoredhoptime_penaltytick)	restoredhoptime = 0							// or reduce it all after it's expired if set this way

				if (restoredhoptime < 0) restoredhoptime = 0
			}

			if (NetProps.GetPropInt(self, "m_nFlagStatus") == 2 && lifetick % 7 == 0) 									    	// if we're currently idle, do this every 7 ticks (~0.1s)
			{
				restoredhoptime = hoptime - (NetProps.GetPropFloat(self, "m_flResetTime") - Time()) + restoredhoptime_remainder	// this is essentially the amount of time the bomb is away from its hopping cooldown + any remaining grace periods
			}
		}

		if (!(!overlay_material))
		{
			if (lifetick % overlay_refreshtime == 0)	// check every X ticks for when the overlay is supposed to stop displaying
			{
				if (lifetick >= overlay_off_tick) overlay_on = false

				local maxclients = MaxClients().tointeger()

				for (local i = 1; i <= maxclients; i++)
				{
					local player = PlayerInstanceFromIndex(i)

					if (player == null) continue
					if (player.GetTeam() != 2) continue

					if (!overlay_on) player.SetScriptOverlayMaterial(null)
					else
					{
						if (typeof(overlay_material) == "string") player.SetScriptOverlayMaterial(overlay_material)
						if (typeof(overlay_material) == "array")
						{
							local curoverlay = overlay_material.find(player.GetScriptOverlayMaterial())
							if (curoverlay == null) player.SetScriptOverlayMaterial(overlay_material[0])
							else { player.SetScriptOverlayMaterial(((curoverlay + 1) > (overlay_material.len() - 1)) ? overlay_material[0] : overlay_material[curoverlay + 1]) }
						}
					}
				}
			}
		}

		if (NetProps.GetPropInt(self, "m_nFlagStatus") < 2) return -1

		if (NetProps.GetPropFloat(self, "m_flResetTime") - Time() <= 0.05) Hop() // make sure to perform a hop just a few ticks before the actual reset, otherwise the bomb will actually reset back to spawn

		if (moving)	// time to hop
		{
			local hopover = (hopduration_midjump <= 0) ? true : false

			if (!hopover)
			{
				if (smoothhopcurve)
				{
					if (hopcurve_array.len() <= 0) hopover = true
					else self.SetAbsOrigin(hopcurve_array.pop())
				}

				else
				{
					local range = (100.0 / hopduration_midjump.tofloat()) * 12.0	// the smaller the hopduration variable is, the larger the detection radius has to be

					if ((hopapex - self.GetOrigin()).Length() <= range) toapex = false // we have reached the apex
					if (((hopend - self.GetOrigin()).Length() <= range && !toapex) || lifetick >= endmovetick) hopover = true	// we have reached the hop's end, time to wrap things up

					if (!hopover)
					{
						if (toapex) moveamount = (hopapex - hopstart) * (1.0 / (hopduration_midjump.tofloat() / 2.0))	// divide the amount moved per tick across an amount of ticks equal to hopduration variable so that it looks smooth
						else		moveamount = (hopend - hopapex) * (1.0 / (hopduration_midjump.tofloat() / 2.0))

						self.SetAbsOrigin(self.GetOrigin() + moveamount)	// move this much every tick
					}
				}
			}

			if (hopover)
			{
				self.SetAbsOrigin(hopend)	// just in case something goes horribly wrong

				moving = false	// reset all movement-related variables
				toapex = true	// might aswell prematurely switch this back on for next time
				moveamount = Vector()
				hopstart = Vector()
				hopapex = Vector()
				hopend = Vector()

				SetTouchable(true)	// set the bomb's solidity flags back to default

				justhopped = true
				DetermineReturnTime()	// update the hop timer now that the bomb's position has changed

				foreach (func in posthop_funcs) func()	// run any functions from outside scripts
			}
		}

		return -1
	}

	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	// UTILITY FUNCTIONS
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////

	DebugMsg <- function(txt, separate = false) { if (debug) ClientPrint(null, 2, "(" + self.GetName() + ") | " + txt + (separate ? "\n---------------------------------------" : "")) }

	InWave <- function() { return (!NetProps.GetPropBool(Entities.FindByClassname(null, "tf_objective_resource"), "m_bMannVsMachineBetweenWaves")) }

	ResetPath <- function() { EntFireByHandle(self, "CallScriptFunction", "SetUp", 0.1, null, null); return true }	// if a bomb has been force-reset after a gate cap, reset most of its variables

	Clamp <- function(val, minVal, maxVal)
	{
		if (maxVal < minVal)   return maxVal
		else if (val < minVal) return minVal
		else if (val > maxVal) return maxVal
		else 				   return val
	}

	RemapValClamped <- function(val, A, B, C, D)
	{
		if (A == B) return ((val >= B) ? D : C)

		local cVal = (val - A) / (B - A)

		cVal = Clamp(cVal, 0.0, 1.0)

		return (C + (D - C) * cVal)
	}

	AddRouteReDeterminationTriggers <- function()
	{
		local scope = self.GetScriptScope()

		ReDetermineFullRoute <- function()	// some maps may dynamically enable or disable nav brushes (such as when the bomb carrier touches the hatch zone), so we need to recalculate full path when that happens
		{
			for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); ) EntFireByHandle(ent, "CallScriptFunction", "EvaluateNavBrushes", 1.0, null, null)

			return true
		}

		InputEnable <- ReDetermineFullRoute
		Inputenable <- ReDetermineFullRoute

		InputDisable <- ReDetermineFullRoute
		Inputdisable <- ReDetermineFullRoute
	}


	// the "GetNavAreasFromBuildPath" function has a quirk that allows us to build a nav path that reliably imitates the path a bomb carrier would take
	// the function's second-to-last argument (IgnoreNavBlockers) allows us to pick any number of nav meshes that we don't want the path to go through
	// by storing all the nav areas that are obscured by func_nav entities in a table and blocking them for one frame, we can have the function pretend to be the bomb carrier and avoid undesirable paths

	BombHop_BuildPath <- function(start, end, remove_mapplaced_blocked_navs = false, ignore_bombpath = false)
	{
		local table = {}
		local blockednavs = []

		if (remove_mapplaced_blocked_navs)	// this is used in bigrock and underworld when robot spawn is cut off from the nav mesh by gates
		{
			foreach (nav in allareas) { if (nav.IsBlocked(3, true)) blockednavs.append(nav) }

			foreach (nav in blockednavs) nav.UnblockArea()	// temporarily unblock all map-placed blocked meshes and try building a path again
		}

		if (!ignore_bombpath) foreach (nav in blocknav_array) nav.MarkAsBlocked(3)			// block all undesirable areas that we don't want to path through...

		NavMesh.GetNavAreasFromBuildPath(start, end, Vector(), 0.0, 3, false, table)		// ...build a path...

		if (!ignore_bombpath)  foreach (nav in blocknav_array) nav.UnblockArea()			// ...then unblock the undesirables (this has no real effect on bot pathing, since this runs over the course of 1 frame)

		if (remove_mapplaced_blocked_navs) 	{ foreach (nav in blockednavs) nav.MarkAsBlocked(3) }

		if (table.len() > 0)	// convert the returned table to an array for ease of use
		{
			local arr = []

			for (local i = 0; i < table.len() - 1; i++) arr.append(table["area" + i])

			arr.append(start)

			return arr
		}

		else return false
	}

	BombHop_BuildCurve <- function(start, end, apex, length)	// create a quadratic bezier curve using the start, apex, and end points as parameters
	{
		local percentage = (1.0 / length.tofloat())

		function Interpolate(from, to, percent)
		{
			local difference = to - from

			return (from + (difference * percent))
		}

		for (local i = 0.0; i < 1.0; i += percentage)
		{
			local a = Interpolate(start, apex, i)
			local b = Interpolate(apex, end, i)
			local c = Interpolate(a, b, i)

			hopcurve_array.append(c)
		}

		hopcurve_array.append(end)

		hopcurve_array.reverse()	// this will make movement code much simpler thanks to the pop() array function
	}

	DeterminePathLength <- function(input, dc, startarea = false)
	{
		if (input.len() == 0) return 0

		local arr = []

		if (typeof(input) == "table") { for (local i = 0; i < input.len(); i++) arr.append(input["area" + i]) }
		else arr = input

		local dist = 0
		local foundstartarea = false

		for (local i = 0; i < arr.len(); i++)	// if we've determined a start area, skip along the path until we reach it, then start calculating the distance
		{
			if (!(!startarea))
			{
				if (arr[i] == startarea) foundstartarea = true
				if (!foundstartarea) continue
			}

			if (debug && !debug_nodraw) arr[i].DebugDrawFilled(dc[0], dc[1], dc[2], dc[3], 5.0, true, 0.0)

			if (i + 1 > arr.len() - 1) continue

			local curarea1 = arr[i].GetCenter()
			local curarea2 = arr[i + 1].GetCenter()

			dist += (curarea2 - curarea1).Length()
		}

		return dist
	}

	FindBestNearestNavMesh <- function(vec)
	{
		local homenav = false

		for (local i = 16; i <= 512; i += 16) 									// try to determine the closest nav mesh to the bomb, keep increasing search radius with each unsuccessful try
		{
			local validarea = NavMesh.GetNearestNavArea(vec, i, true, false)	// let's first look for nav meshes that are in the bomb's line of sight

			if (validarea == null) continue

			homenav = validarea
			break
		}

		if (!homenav)																// failed to find any nav mesh, let's try again
		{
			DebugMsg("FindBestNearestNavMesh: Failed to find nearest nav mesh to bomb's origin, retrying with different method...")

			for (local i = 16; i <= 512; i += 16)
			{
				local validarea = NavMesh.GetNearestNavArea(vec, i, false, false)	// this time let's accept meshes that are not in the bomb's line of sight

				if (!validarea) continue

				homenav = validarea
				break
			}
		}

		return homenav
	}


	// some maps (ex. derelict, powerplant) tend to have lots of areas that are bi-directionally linked with other areas that are far above them, even though jumping up to those areas is impossible, these connections should be made one-directional

	FixPoorNavConnections <- function(check = false)
	{
		local amount = 0

		if (!check && navconnectionsfixed_check.IsTFMarked())
		{
			DebugMsg("FixPoorNavConnections: This func has already run, aborting.", true)
			return
		}

		foreach (nav in allareas)
		{

			foreach (adj_nav in GetAllAdjacentAreas(nav))
			{
				if (!adj_nav.IsConnected(nav, -1)) continue

				local found = false

				for (local i = 0; i <= 3; i++)	// compare vertical distance between each of the areas' corners
				{
					local curnav = nav.GetZ(nav.GetCorner(i))

					for (local j = 0; j <= 3; j++)
					{
						local curadj = adj_nav.GetZ(adj_nav.GetCorner(j))

						local dist = curadj - curnav

						if (dist < 0) dist *= -1.0

						if (dist < 50.0)	// as soon as we find one that's less than 50 HUs, continue to the next pair
						{
							found = true
							break
						}
					}

					if (found) break
				}

				if (!found)	// if the corners are more than 50 HUs apart vertically (roughly jumping height), disconnect
				{
					if (check) amount++
					else
					{
						if (nav.GetCenter().z > adj_nav.GetCenter().z) 	adj_nav.Disconnect(nav)
						else							 				nav.Disconnect(adj_nav)
					}
				}
			}
		}

		amount /= 2	// we're only checking and not actually fixing, meaning every connection gets checked twice from the perspective of two different areas

		if (check) 	ClientPrint(null,3,"Found " + amount + " poor connections between areas." + ((amount > 30) ? " It is highly recommended that the 'FixPoorNavConnections' function is run." : ""))
		else		navconnectionsfixed_check.TFMark()	// this will make vscript permanently remember that this expensive function got run
	}

	GetAllAdjacentAreas <- function(area)
	{
		local alldir_array = []

		for (local i = 0; i <= 3; i++)
		{
			local table = {}
			area.GetAdjacentAreas(i, table)

			for (local i = 0; i < table.len(); i++) alldir_array.append(table["area" + i])
		}

		return alldir_array
	}

	GetAreaHeight <- function(area)
	{
		if (!ignoreelevatedareas) return 0

		local tracetable =
		{
			start = area.GetCenter() + Vector(0, 0, 24)	// in case some areas are buried in the world
			end = area.GetCenter() - Vector(0, 0, 5000)
			mask = -1
		}

		TraceLineEx(tracetable)

		if ("startsolid" in tracetable) return 0

		return ((tracetable.pos - tracetable.start).Length())
	}

	GetAreasObscuredByBrush <- function(brush)	// credit goes to ficool2 for the initial code for checking if a point is within a trigger's bounds
	{
		// collect all nav areas that are touching a particular nav brush in any way
		// a nav area is affected by a nav brush entity only when its center is obscured by it, so let's trace and filter out those areas that don't meet this criterion
		// append all matching nav areas to the output array

		// WARNING: this function won't return any areas if the sigmod "sig_etc_entity_limit_manager_convert_server_entity" convar is set to 1! nav_func entities cannot be traced against in any imaginable way while this convar is active!

		local output = []
		local masksearch = 1

		local thisnavtable = {}
		NavMesh.GetNavAreasOverlappingEntityExtent(brush, thisnavtable)

		if (NetProps.GetPropInt(brush, "m_iHammerID") == 0) masksearch = 33554432 // apparently this mask flag can allow traces to collide with custom nav brushes

		brush.RemoveSolidFlags(4)

		for (local i = 0; i < thisnavtable.len(); i++)
		{
			local area = thisnavtable["area" + i]

			local trace =
			{
				start = area.GetCenter()
				end   = area.GetCenter()
				mask  = masksearch
			}

			TraceLineEx(trace)

			if (trace.hit)
			{
				if (trace.enthit == brush) output.append(area)

				else if (considerburiedareas)	// determine where the area is the most elevated, and add that height to its center
				{
					local area_ceil = -9999

					for (local i = 0; i <= 3; i++)
					{
						local height = area.GetZ(area.GetCorner(i))

						if (height > area_ceil) area_ceil = height
					}

					local trace2 =
					{
						start = area.GetCenter() + Vector(0, 0, (area_ceil - area.GetCenter().z))
						end   = area.GetCenter() + Vector(0, 0, (area_ceil - area.GetCenter().z))
						mask  = masksearch
					}

					TraceLineEx(trace2)

					if (trace2.hit && trace2.enthit == brush) output.append(area)
				}
			}
		}

		brush.AddSolidFlags(4)

		return output
	}

	PostSetParams <- function(arr)
	{
		local reroute = false
		local regrace = false

		foreach (param in arr)
		{
			switch (param[0])
			{
				case "debug":
				{
					if (!param[1]) 	debug = false
					else 			SetUpDebug()

					break
				}

				case "pref_spawnnavarea": { reroute = true; break }
				case "pref_hatchnavarea": { reroute = true; break }

				case "allowpickupduringhop": { if (moving) SetTouchable(param[1]); break }

				case "hopsound": { if (!(!hopsound)) PrecacheSound(hopsound); break }

				case "hoptimerdisplayclock":
				{
					self.KeyValueFromFloat("ReturnTime", param[1] ? 599.0 : 600.0)

					if (param[1])
					{
						local old1 = NetProps.GetPropFloat(self, "m_flResetTime")
						local old2 = NetProps.GetPropFloat(self, "m_flMaxResetTime")

						if (NetProps.GetPropInt(self, "m_nFlagStatus") == 2)
						{
							self.AcceptInput("ShowTimer", "0.0", null, null)

							NetProps.SetPropFloat(self, "m_flResetTime", old1)
							NetProps.SetPropFloat(self, "m_flMaxResetTime", old2)
						}
					}

					else
					{
						for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag_return_icon"); )
						{
							if (ent.GetRootMoveParent() == self) ent.Kill()
						}
					}

					break
				}

				case "hoptimerdisplaytext":
				{
					if (!param[1])
					{
						text_timer.Kill()
						text_timer = null
					}

					else
					{
						text_timer = SpawnEntityFromTable("point_worldtext",
						{
							targetname		= self.GetName() + "_bombhop_texttimer"
							textsize       	= 36
							message        	= ""
							color		   	= "255 255 255"
							font           	= 1
							orientation    	= 1
							textspacingx   	= 1
							textspacingy   	= 1
							rendermode     	= 3
						})

						text_timer.AcceptInput("SetParent", "!activator", self, self)
						text_timer.SetLocalOrigin(Vector(0, 0, 70))
					}

					break
				}

				case "hoptimerdisplaygracetimer":
				{
					if (!param[1])
					{
						text_gracetimer.Kill()
						text_gracetimer = null
					}

					else
					{
						text_gracetimer = SpawnEntityFromTable("point_worldtext",
						{
							targetname		= self.GetName() + "_bombhop_textgracetimer"
							textsize       	= 18
							message        	= ""
							color		   	= "255 255 255"
							font           	= 1
							orientation    	= 1
							textspacingx   	= 1
							textspacingy   	= 1
							rendermode     	= 3
						})

						text_gracetimer.AcceptInput("SetParent", "!activator", self, self)
						text_gracetimer.SetLocalOrigin(Vector(0, 0, 50))
					}

					break
				}

				case "graceperiod_enabled": { regrace = true; break }
				case "restoredhoptime_penaltyticks": { regrace = true; break }
				case "restoredhoptime_penaltyspread": { regrace = true; break }

				case "fixpoornavconnections": { FixPoorNavConnections(); break }
			}
		}

		if (reroute) fullroute_length = 0

		if (regrace)
		{
			restoredhoptime = 0.0
			restoredhoptime_remainder = 0.0
			restoredhoptime_penalty = 0.0
			restoredhoptime_penaltytick = 0.0
		}

	}

	SetUpDebug <- function()
	{
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)

			if (player == null) continue

			if (!player.IsFakeClient())
			{
				player.SetHealth(90000)
				player.SetMoveType(8, 0)
				player.SetCurrency(10000)
			}
		}

		seterrorhandler(function(e)
		{
			local filter = false

			for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); )	// seterrorhandler function is not called by the bomb so we have no access to any of its variables here
			{
				if (ent.GetScriptScope() == null) continue
				if (!ent.GetScriptScope().debugger_id && !(!filter)) break

				filter = ent.GetScriptScope().debugger_id

				break
			}

			for (local player; player = Entities.FindByClassname(player, "player");)
			{
				if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:" + filter + "]" || !filter)
				{
					local Chat = @(m) (printl(m), ClientPrint(player, 2, m))
					ClientPrint(player, 3, format("\x07FF0000AN ERROR HAS OCCURRED [%s].\nCheck console for details", e))

					Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
					Chat("CALLSTACK")
					local s, l = 2
					while (s = getstackinfos(l++)) Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))

					Chat("LOCALS")

					if (s = getstackinfos(2))
					{
						foreach (n, v in s.locals)
						{
							local t = type(v)
							t ==    "null" ? Chat(format("[%s] NULL"  , n))    :
							t == "integer" ? Chat(format("[%s] %d"    , n, v)) :
							t ==   "float" ? Chat(format("[%s] %.14g" , n, v)) :
							t ==  "string" ? Chat(format("[%s] \"%s\"", n, v)) :
											 Chat(format("[%s] %s %s" , n, t, v.tostring()))
						}
					}

					return
				}
			}
		})
	}

	Unload <- function()
	{
		local maxclients = MaxClients().tointeger()

		for (local i = 1; i <= maxclients; i++)
		{
			local player = PlayerInstanceFromIndex(i)

			if (player == null) continue
			if (player.GetTeam() != 2) continue

			player.SetScriptOverlayMaterial(null)
		}

		delete BOMBHOP_CALLBACKS
	}

	UpdateTextTimer <- function()
	{
		if (!(!text_timer))
		{
			if (!moving && !nohopping && NetProps.GetPropInt(self, "m_nFlagStatus") == 2)
			{
				text_timer.EnableDraw()
				text_timer.KeyValueFromString("message", format("%.1f", NetProps.GetPropFloat(self, "m_flResetTime") - Time()).tostring())
			}

			else text_timer.DisableDraw()
		}

		if (!(!text_gracetimer))
		{
			if (restoredhoptime > 0.0)
			{
				text_gracetimer.EnableDraw()
				text_gracetimer.KeyValueFromString("message", format("%.1f", restoredhoptime).tostring())
			}

			else text_gracetimer.DisableDraw()
		}
	}

	InputForceReset <- ResetPath 	// this will only be called on mannhattan-styled gate maps that force reset the bombs when a gate is capped
	Inputforcereset <- ResetPath

	InputForceResetSilent <- ResetPath
	Inputforceresetsilent <- ResetPath

	for (local ent; ent = Entities.FindByClassname(ent, "func_nav_*"); )	// recalculate route when any nav brush becomes enabled or disabled...
	{
		if (ent.GetClassname() != "func_nav_prefer" && ent.GetClassname() != "func_nav_avoid") continue

		ent.ValidateScriptScope()

		AddRouteReDeterminationTriggers.call(ent.GetScriptScope())
	}

	for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/robot_hologram.mdl"); )	// ...or when any bomb path hologram receives those inputs (the called function will always run only once per tick)
	{
		ent.ValidateScriptScope()

		AddRouteReDeterminationTriggers.call(ent.GetScriptScope())
	}

	local id = 0

	for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); )
	{
		if (ent == self) continue
		if (ent.GetScriptScope() == null) continue

		if ("debug_id" in ent.GetScriptScope()) id++
	}

	debug_id <- id	// the ID of the bomb that debug commands will need for verifying which bomb they should be run under

	DebugMsg("DebugID: " + debug_id)

	SetUp()

	EntFireByHandle(self, "CallScriptFunction", "NextFrameActions", -1.0, null, null)

	if (nav_interface != null)
	{
		DebugMsg("Map contains a nav_interface entity, setting up route redetermination function")

		nav_interface.ValidateScriptScope()
		local interface_scope = nav_interface.GetScriptScope()

		interface_scope.ReDetermineFullRoute <- function()
		{
			if (NetProps.GetPropBool(Entities.FindByClassname(null, "tf_objective_resource"), "m_bMannVsMachineBetweenWaves")) return true

			for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); )
			{
				if (ent.GetScriptScope() == null) continue

				EntFireByHandle(ent, "RunScriptCode", "DetermineFullRoute(true)", 3.0, null, null)	// it takes a few seconds for recomputation to take place
			}

			return true
		}

		interface_scope.InputRecomputeBlockers <- interface_scope.ReDetermineFullRoute
		interface_scope.Inputrecomputeblockers <- interface_scope.ReDetermineFullRoute
	}

	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	// CALLBACKS
	////////////////////////////////////////////////
	////////////////////////////////////////////////
	////////////////////////////////////////////////

	BOMBHOP_CALLBACKS <-
	{
		OnGameEvent_teamplay_flag_event = function(params)
		{
			local found = false																					// ensure that the callback applies only to this particular bomb

			if ("carrier" in params) { if (EntIndexToHScript(params.carrier) == self.GetOwner()) found = true }	// by the time the bomb is picked up, vscript already knows who its carrier is
			if ("player" in params) { if (EntIndexToHScript(params.player) == self.GetOwner()) found = true }

			if ("carrier" in params) { if (EntIndexToHScript(params.carrier) == botcarrier) found = true }		// by the time the bomb is dropped, we can tell who its carrier was via the saved "botcarrier" variable
			if ("player" in params) { if (EntIndexToHScript(params.player) == botcarrier) found = true }

			if (found)
			{
				if (params.eventtype == 1) // bomb has been picked up
				{
					DebugMsg("I've been picked up, saving grace period.", true)

					moving = false				// reset all movement-related variables for in case the bomb got picked up in mid-hop
					toapex = true
					moveamount = Vector()
					hopstart = Vector()
					hopapex = Vector()
					hopend = Vector()
					justhopped = false
					hopcurve_array.clear()

					if (debug_pathtest || debug_recoverytest)
					{
						local maxclients = MaxClients().tointeger()

						for (local i = 1; i <= maxclients; i++)
						{
							local player = PlayerInstanceFromIndex(i)

							if (player == null) continue
							if (player.GetTeam() != 3) continue
							if (player == EntIndexToHScript(params.player)) continue

							player.SetHealth(0)
							player.TakeDamage(10000.0, 64, null)
						}

						EntFireByHandle(EntIndexToHScript(params.player), "RunScriptCode", "self.SetHealth(0); self.TakeDamage(10000.0, 64, null)", 0.5, null, null)

						local pop = SpawnEntityFromTable("point_populator_interface", {})

						pop.AcceptInput("PauseBotSpawning", null, null, null)
					}

					if (graceperiod_enabled)
					{
						if (restoredhoptime_penaltyspread) 	restoredhoptime_penalty = (restoredhoptime / restoredhoptime_penaltyticks.tofloat()) 	// determine how much the grace period percentage should be deducted every grace period depletion tick
						else								restoredhoptime_penaltytick = lifetick + (restoredhoptime_penaltyticks * 6.66)			// or determine time after pickup at which it should all go away
					}
				}

				if (params.eventtype == 4)	// the bomb has been dropped and changed its position, recalculate hop timer
				{
					DebugMsg("I've been dropped, calling DetermineReturnTime.", true)

					DetermineReturnTime()
				}
			}
		}

		OnGameEvent_player_say = function(params)
		{
			if (debug)
			{
				if (params.text == "d")
				{
					TerminateHopScript()

					// for (local i = 0; i <= 10; i++)
					// {
					// 	SpawnEntityFromTable("obj_sentrygun",
					// 	{
					// 		origin	= Entities.FindByClassname(null, "func_capturezone").GetCenter() + Vector(RandomFloat(-250, 250), RandomFloat(-250, 250), 0)
					// 		teamnum	= 2
					// 		defaultupgrade = 2
					// 		spawnflags = 10
					// 	})
					// }
				}

				if (params.text.find("!visavoid") != null)	// mark red all the nav meshes that are affected by nav_avoid entities in guiding the bomb carrier
				{
					if (!endswith(params.text, "avoid")) { if (!endswith(params.text, debug_id.tostring())) return } // appending an ID (starting from the number 0) to the command will filter the command to run only under the bomb of that ID

					foreach (nav in blocknav_array) nav.DebugDrawFilled(255, 0, 0, 255, 20.0, true, 0.0)

					DebugMsg("Size of blocknav_array : " + blocknav_array.len())
				}

				if (params.text.find("!vispath") != null)	// this will basically call DetermineFullRoute and visualize the calculated path
				{
					if (!endswith(params.text, "path")) { if (!endswith(params.text, debug_id.tostring())) return }

					local spawnareas = []

					foreach (nav in allareas) { if (nav.HasAttributeTF(4)) spawnareas.append(nav) }

					local test_spawnnavarea
					local test_hatchnavarea

					if (!(!pref_spawnnavarea)) 	test_spawnnavarea = NavMesh.GetNavAreaByID(pref_spawnnavarea)
					else						test_spawnnavarea = spawnareas[RandomInt(0, spawnareas.len() - 1)]	// select random nav mesh inside robots' spawn room, can help visualize path flow from different spawn points

					if (!(!pref_hatchnavarea))	test_hatchnavarea = NavMesh.GetNavAreaByID(pref_hatchnavarea)
					else 						test_hatchnavarea = FindBestNearestNavMesh(Entities.FindByClassname(null, "func_capturezone").GetCenter())

					if (test_spawnnavarea == null) DebugMsg("Failed, couldn't find a NavMesh that's close to robot spawn")
					if (test_hatchnavarea == null) DebugMsg("Failed, couldn't find a NavMesh that's close to the hatch")

					if (test_spawnnavarea == null || test_hatchnavarea == null) return

					if (blocknav_array.find(test_spawnnavarea) != null) blocknav_array.remove(blocknav_array.find(test_spawnnavarea))
					if (blocknav_array.find(test_hatchnavarea) != null) blocknav_array.remove(blocknav_array.find(test_hatchnavarea))

					local test_fullroute_navarray = BombHop_BuildPath(test_spawnnavarea, test_hatchnavarea)

					if (!test_fullroute_navarray)																				// failed to create path, maybe the map has pre-placed blocked nav meshes around maps with initially blocked off spawns like bigrock?
					{
						DebugMsg("Failed to establish any path, retrying with unblocked map-placed nav meshes")

						test_fullroute_navarray = BombHop_BuildPath(test_spawnnavarea, test_hatchnavarea, true)
					}

					if (!test_fullroute_navarray)																				// still didn't work? give up
					{
						DebugMsg("Failed to establish any path, aborting")
						return
					}

					local test_new_fullroute_navarray = []

					foreach (nav in test_fullroute_navarray)							// cut blu spawn room meshes out of the equation
					{
						if (GetAreaHeight(nav) >= areaheightlimit) continue							// maps like hoovydam put certain nav areas in complete midair, don't let the bomb sit on those
						if (nav.HasAttributeTF(4)) break
						test_new_fullroute_navarray.append(nav)
					}

					test_fullroute_navarray = test_new_fullroute_navarray

					local first = test_fullroute_navarray[test_fullroute_navarray.len() - 1] 		// let's try building a proper path one more time, now that we've taken spawn room meshes out of the calculation
					local last = test_fullroute_navarray[0]

					DebugMsg("First point: " + first.GetCenter())
					DebugMsg("Last point: " + last.GetCenter())

					local i = 1

					foreach (nav in test_fullroute_navarray)
					{
						nav.DebugDrawFilled(255, 0, 0, 255, 20.0, true, 0.0)
						DebugDrawText(nav.GetCenter(), "" + i, false, 5.0)
						i++
					}

					first.DebugDrawFilled(255, 0, 0, 255, 20.0, true, 0.0)
					last.DebugDrawFilled(255, 0, 0, 255, 20.0, true, 0.0)
				}

				if (params.text == "!pathtest" || params.text == "!recoverytest")
				{
					hoptime_min = 0.5
					hoptime_max = 0.5

					nohopping_when_hoptime_is_max = false

					if (params.text == "!pathtest") debug_pathtest = true
					if (params.text == "!recoverytest") debug_recoverytest = true

					NetProps.SetPropFloat(Entities.FindByClassname(null, "tf_gamerules"), "m_flRestartRoundTime", Time())
				}

				if (params.text == "!heighttest")
				{
					if (debug_id > 0) return		// no need to have this run multiple times per bomb
					if (!ignoreelevatedareas) ClientPrint(null, 3, "ignorelevatedareas is set to false, no areas will be detected")
					foreach (nav in allareas)
					{
						if (GetAreaHeight(nav) >= areaheightlimit)
						{
							nav.DebugDrawFilled(255, 0, 0, 255, 30.0, true, 0.0)
							DebugDrawText(nav.GetCenter(), "" + GetAreaHeight(nav), false, 30.0)
						}
					}
				}

				if (params.text == "!navmeshtest")
				{
					if (debug_id > 0) return		// no need to have this run multiple times per bomb
					FixPoorNavConnections(true)		// this will only run a check and not actually fix the connections
				}
			}
		}

		OnGameEvent_player_spawn = function(params)
		{
			local player = GetPlayerFromUserID(params.userid);

			if (player.IsFakeClient() && (debug_pathtest || debug_recoverytest))
			{
				EntFireByHandle(player, "RunScriptCode", "self.SetOrigin(Entities.FindByClassname(null, `func_capturezone`).GetCenter())", 0.1, null, null)
			}
		}

		OnGameEvent_mvm_wave_complete = function(params) { SetUp() } // winning a wave will not remove the bomb, so we need to manually reset its variables
	}
}

else
{
	ClientPrint(null, 2, "BombHop script is already active, aborting.")
	return
}

foreach (name, callback in BOMBHOP_CALLBACKS) BOMBHOP_CALLBACKS[name] = callback.bindenv(this)

__CollectGameEventCallbacks(BOMBHOP_CALLBACKS)

AddThinkToEnt(self, "BombHop_Think")

local selfent = self

setdelegate // credit goes to ficool2 for the code, this is done to ensure that callbacks belonging to the bomb get deleted when the bomb gets despawned
(
	{}.setdelegate
	(
		{
			parent   = getdelegate()
			id       = selfent.GetScriptId()
			index    = selfent.entindex()
			callback = function() { Unload() }
			_get = function(keytofetch) { return parent[keytofetch] }
			_delslot = function(keytodelete)
			{
				if (keytodelete == id)
				{
					selfent = EntIndexToHScript(index)
					local scope = selfent.GetScriptScope()
					self <- selfent
					callback.pcall(scope)
				}

				delete parent[keytodelete]
			}
		}
	)
)

ClientPrint(null, 2, "BombHop script has successfully loaded for " + self.GetName() + ".")