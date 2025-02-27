// Radial fog must be enabled by the mapmaker for non-official maps, but most of our maps will
//  not be receiving updates any time soon, so we force allow it by default here.
// Note that clients can still opt out with r_radialfog_force 0.
class EnableRadialFog {
	constructor() {
		for (local e; e = Entities.FindByClassname(e, "env_fog_controller");)
			NetProps.SetPropBool(e, "m_fog.radial", true)
		for (local e; e = Entities.FindByClassname(e, "sky_camera");)
			NetProps.SetPropBool(e, "m_skyboxData.fog.radial", true)
	}

	Events = {
		function OnGameEvent_recalculate_holidays(_) {
			if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

			for (local e; e = Entities.FindByClassname(e, "point_camera");)
				NetProps.SetPropBool(e, "m_bFogRadial", true)
		}
	}
}

::EnableRadialFog <- EnableRadialFog()
__CollectGameEventCallbacks(::EnableRadialFog.Events)
