// mvm_metro_rc3.bsp
const TFCOLLISION_GROUP_COMBATOBJECT = 23

function RunOnce() {
	PrecacheModel("models/props_trainyard/train_billboard001.mdl")
	PrecacheModel("models/props_debris/concrete_section128wall002a.mdl")
}

Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed forward dropdown stairs nullifying explosions.")
		function MakeRamp(origin, angles, scale, triangle) {
			//  I considered using training_prop_dynamic for these to avoid floating
			//   stickies, but pipes detonate instantly on contact + it might be annoying.
			local model = "models/props_trainyard/train_billboard001.mdl"
			if (triangle)
				model = "models/props_debris/concrete_section128wall002a.mdl"

			local prop = SpawnEntityFromTable("prop_dynamic", {
				origin = origin
				angles = angles
				model = model
				modelscale = scale
				solid = Constants.ESolidType.SOLID_VPHYSICS
				disableshadows = true
				disablereceiveshadows = true
				//rendermode = Constants.ERenderMode.kRenderNone
			})
			prop.SetCollisionGroup(TFCOLLISION_GROUP_COMBATOBJECT) // Projectile collide only.
			prop.DisableDraw()
		}

		// Rectangles.
		foreach (prop in [
			// Right forward bot dropdown.
			[Vector(-1500.0, 2500.0, 19.0), QAngle(57.0, 90.0, 0.0), 1.3],
			[Vector(-1768.0, 2578.0, 28.0), QAngle(57.0, 90.0, 0.0), 1.0],
			[Vector(-1788.0, 2626.0, 20.3), QAngle(227.0, 45.0, 0.0), 1.0],
			[Vector(-1998.0, 2808.0, 28.0), QAngle(57.0, 0.0, 0.0), 1.0],
			[Vector(-1957.0, 2619.0, 17.0), QAngle(48.0, 45.0, 90.0), 0.54],
			// Left forward bot dropdown.
			[Vector(-2583.0, 2298.0, -31.0), QAngle(57.0, 180.0, 0.0), 2.7],
			[Vector(-2716.0, 1888.0, -6.0), QAngle(57.0, 180.0, 90.0), 1.0],
			[Vector(-2702.0, 1827.0, -36.0), QAngle(227.0, 135.0, 90.0), 1.14],
			[Vector(-2976.0, 1629.0, -6.0), QAngle(57.0, 90.0, 90.0), 1.0],
			[Vector(-2802.0, 1714.0, -24.0), QAngle(227.0, 135.0, 90.0), 1.0],
		]) MakeRamp(prop[0], prop[1], prop[2], false)

		// Triangles.
		foreach (prop in [
			// Right forward bot dropdown.
			[Vector(-1721.0, 2537.0, 2.0), QAngle(311.0, 231.0, 33.0), 1.0],
			[Vector(-2022.0, 2694.0, 14.0), QAngle(311.0, 225.0, 0.0), 1.0],
			[Vector(-1886.0, 2558.0, 14.0), QAngle(132.0, 223.0, 180.0), 1.0],
			// Left forward bot dropdown.
			[Vector(-2649.0, 1969.0, 13.0), QAngle(47.0, 135.0, 0.0), 1.0],
			[Vector(-2747.0, 1840.0, 13.0), QAngle(47.0, 135.0, 0.0), 1.0],
			[Vector(-2927.0, 1659.0, 12.0),  QAngle(-47.0, -45.0, 0.0), 1.0],
		]) MakeRamp(prop[0], prop[1], prop[2], true)
	}
}
