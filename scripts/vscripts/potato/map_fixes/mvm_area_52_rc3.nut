// mvm_area_52_rc3.bsp
const CHAN_STATIC = 6
const SND_STOP = 0x4
const SF_AMBIENT_SOUND_START_SILENT = 0x10
const SF_TRIGGER_ALLOW_CLIENTS = 0x1
const SF_TRIGGER_DISALLOW_BOTS = 0x1000

Events <- {
	// main_gate_door_trigger script scope.
	capscope = null
	// Array of all environmental ambient_generic entities.
	ambients = []

	function OnGameEvent_player_death(params) {
		local p = GetPlayerFromUserID(params.userid)
		if (!p.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) return
		// Check if the dead bot was touching main_gate_door_trigger.
		// Our gatebot filtering is done automatically by OnStartTouch.
		capscope.RemoveTouch(p)
	}

	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Killed a stray steam particle at \"-1272 -780 -40\".")
		for (local p; p = Entities.FindByClassname(p, "info_particle_system");) {
			if (NetProps.GetPropInt(p, "m_iHammerID") != 625971) continue
			p.Kill()
			break
		}

		RegisterFix("Fixed main_gate sometimes opening without capture.")
		// Triggers filtered by bot tag seem to have a bug in stock TF2 where they will not always
		//  fire OnEndTouch(All).
		// At a guess I'd say this might be caused by the OnEndTouch test occurring after a
		//  dead bot's tags are removed.
		// This isn't a problem with, say, Mannhattan, as only cosmetic logic in handled
		//  through the trigger_timer_door and game logic is instead handled through OnCapTeam2
		//  on team_control_point.
		// In any case, we fix this for Area 52 by emulating the map outputs associated with
		//  OnEndTouchAll using player_death.

		local capzone = Entities.FindByName(null, "main_gate_door_trigger")
		capzone.ValidateScriptScope()
		capscope = capzone.GetScriptScope()

		local end = EntityOutputs.GetNumElements(capzone, "OnEndTouchAll")
		capscope.OnEndTouchAll <- array(end)
		for (local i = 0; i < end; ++i) {
			local t = {}
			EntityOutputs.GetOutputTable(capzone, "OnEndTouchAll", t, i)
			capscope.OnEndTouchAll[i] = t
		}

		// Remove original OnEndTouchAll so we don't get double fires.
		foreach (output in capscope.OnEndTouchAll) {
			EntityOutputs.RemoveOutput(capzone, "OnEndTouchAll",
				output.target, output.input, output.parameter)
		}

		capscope.Touching <- []
		capscope.AddTouch <- function() {
			Touching.push(activator)
		}
		capscope.RemoveTouch <- function(bot) {
			local i = Touching.find(bot)
			if (i == null) return
			Touching.remove(i)
			if (Touching.len() != 0) return

			// Fire OnEndTouchAll if none are left touching the trigger.
			foreach (output in OnEndTouchAll) {
				if (output.times_to_fire == 0) continue
				DoEntFire(
					output.target,
					output.input,
					output.parameter,
					output.delay,
					bot,
					self
				)
				--output.times_to_fire
			}
		}

		EntityOutputs.AddOutput(capzone,
			"OnStartTouch", "!self",
			"CallScriptFunction", "AddTouch",
		-1, -1)
		// We need this to account for when bots step off the point without dying.
		// RemoveTouch() is set up so that it won't fire OnEndTouchAll outputs twice for one bot.
		EntityOutputs.AddOutput(capzone,
			"OnEndTouch", "!self",
			"RunScriptCode", "RemoveTouch(activator)",
		-1, -1)

		// TODO: Given the nature of this fix, this claim may not be accurate. Requires testing,
		//  as in theory if enough players are distributed through the map this could once again
		//  become a problem.
		// TODO: Roll this in to map_fixes.nut for reuse if it proves successful.
		RegisterFix("Fixed environmental ambient_generics causing sound corruption.")

		// Clear out list of ambient_generics, as the contained ones will have been killed on
		//  wave reset.
		ambients.clear()

		// Disable ambient_generics by including their HammerID here.
		local skip = {
			[627633] = null, // No apparent source for this sound.
			[626169] = null  // Source is a stray steam particle, which is also killed above.
		}

		for (local a = null; a = Entities.FindByClassname(a, "ambient_generic");) {
			// Only target ambient_generics that are used for environmental sound.
			if (NetProps.GetPropInt(a, "m_spawnflags") & SF_AMBIENT_SOUND_START_SILENT) continue

			// Stop sound and start tracking ambient_generic activity state.
			a.AcceptInput("StopSound", "", null, null)
			ambients.push(a)
			a.ValidateScriptScope()
			local ascope = a.GetScriptScope()
			ascope.active <- false
			ascope.msg <- NetProps.GetPropString(a, "m_iszSound")

			// Do nothing more if the ambient_generic is marked to skip.
			// We can't kill these ambient_generics as they will magically keep playing for
			//  any latejoining players, so they need to still exist so we can StopSound on them
			//  in player_spawn.
			if (NetProps.GetPropInt(a, "m_iHammerID") in skip) continue

			// Setup a trigger for each ambient_generic.
			local soundtrigger = Entities.CreateByClassname("trigger_multiple")
			soundtrigger.KeyValueFromInt("spawnflags",
				SF_TRIGGER_ALLOW_CLIENTS|SF_TRIGGER_DISALLOW_BOTS
			)
			soundtrigger.SetAbsOrigin(a.GetOrigin())
			soundtrigger.DispatchSpawn()

			// Trigger bounds are defined by ambient_generic radius flag.
			local radius = NetProps.GetPropFloat(a, "m_radius")
			if (!radius) radius = 1250.0 // Use default radius if not provided.
			soundtrigger.SetSize(
				Vector(-radius, -radius, -radius),
				Vector(radius, radius, radius)
			)
			soundtrigger.SetSolid(Constants.ESolidType.SOLID_BBOX)

			soundtrigger.ValidateScriptScope()
			local tscope = soundtrigger.GetScriptScope()
			tscope.ambient <- a // Store corresponding ambient_generic in script scope.

			// Function starts playing an ambient_generic and marks it as playing.
			tscope.PlayAmbientSound <- function() {
				ambient.AcceptInput("PlaySound", "", null, null)
				ambient.GetScriptScope().active = true
			}
			// Function stops playing an ambient_generic and marks it as stopped.
			tscope.StopAmbientSound <- function() {
				ambient.AcceptInput("StopSound", "", null, null)
				ambient.GetScriptScope().active = false
			}

			// Call respective functions above when players enter/leave the corresponding
			//  sound triggers.
			EntityOutputs.AddOutput(soundtrigger,
				"OnStartTouchAll", "!self",
				"CallScriptFunction", "PlayAmbientSound",
			-1, -1)
			EntityOutputs.AddOutput(soundtrigger,
				"OnEndTouchAll", "!self",
				"CallScriptFunction", "StopAmbientSound",
			-1, -1)
		}
	}

	function OnGameEvent_player_spawn(params){
		local p = GetPlayerFromUserID(params.userid)
		if (params.team != 0 || p.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) return
		// Work around a bug where late joining players will hear map spawned ambient_generics
		//  that are not playing by force stopping all environmental ambient_generics here.

		foreach (a in ambients) {
			// If an ambient_generic is activated by a player in its sound trigger, we don't need
			//  to stop it here.
			local ascope = a.GetScriptScope()
			if (ascope.active) continue

			// StopSound is inconsistent for this workaround and requires multiple inputs to work.
			StopAmbientSoundOn(ascope.msg, a)
		}
	}
}
