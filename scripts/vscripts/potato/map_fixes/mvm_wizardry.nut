// mvm_wizardry.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed laggy NPC animations.")

		// Fix laggy Skeleton animations.
		EntityOutputs.AddOutput(Entities.FindByName(null, "relay_wheel_go_ghosts"),
			"OnTrigger", "relay_wheel_go_ghosts", "RunScriptCode",
			@"ApplyFastUpdate <- function() {
				for (local skele; skele = Entities.FindByClassname(skele, ""tf_zombie"");) {
					if (skele.GetScriptScope()) continue
					skele.ValidateScriptScope()
					skele.GetScriptScope().FastUpdate <- function() {
						self.FlagForUpdate(true)
						return -1.0
					}
					AddThinkToEnt(skele, ""FastUpdate"")
				}
				return 0.1
			}
			AddThinkToEnt(self, ""ApplyFastUpdate"")",
		0.5, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "relay_wheel_clear"),
			"OnTrigger", "relay_wheel_go_ghosts", "RunScriptCode",
			"AddThinkToEnt(self, null)",
		-1, -1)

		// Fix laggy Ghost animations.
		EntityOutputs.AddOutput(Entities.FindByName(null, "ghost_timer"),
			"OnTimer", "ghost", "RunScriptCode",
			@"FastUpdate <- function() {
				self.FlagForUpdate(true)
				return -1.0
			}
			AddThinkToEnt(self, ""FastUpdate"")",
		0.5, -1)
	}

	// Fix laggy HHH animations.
	function OnGameEvent_pumpkin_lord_summoned(_) {
		local hhh = Entities.FindByClassname(null, "headless_hatman")
		hhh.ValidateScriptScope()
		hhh.GetScriptScope().FastUpdate <- function() {
			self.FlagForUpdate(true)
			return -1.0
		}
		AddThinkToEnt(hhh, "FastUpdate")
	}
}
