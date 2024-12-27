::TeleTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::TeleTankEvents }
	flLastTeleportTime = 0
	OnGameEvent_player_spawn = function(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		EntFireByHandle(hPlayer, "RunScriptCode", "TeleTankEvents.Bot_TeleTank(self)", -1, null, null)
	}
	Bot_TeleTank = function(hPlayer)
	{
		if(hPlayer.getclass() == CTFBot && hPlayer.HasBotTag("bot_teletank"))
			for(local hTank; hTank = FindByClassname(hTank, "tank_boss");)
			{
				local hTank_scope = hTank.GetScriptScope()
				if("hTeleporter" in hTank_scope)
				{
					local vecTeleport = hTank_scope.hTeleporter.GetOrigin() + hTank_scope.hTeleporter.GetUpVector() * 16
					local Trace = {
						start = vecTeleport
						end = vecTeleport
						hullmin = hPlayer.GetBoundingMins()
						hullmax = hPlayer.GetBoundingMaxs()
						mask = MASK_PLAYERSOLID_BRUSHONLY
						ignore = hPlayer
					}
					TraceHull(Trace)
					if(!("startsolid" in Trace))
					{
						local flTime = Time()
						if(flTime - flLastTeleportTime > 0.1)
						{
							hTank_scope.hTeleporter.EmitSound("MVM.Robot_Teleporter_Deliver")
							DispatchParticleEffect(hTank.GetTeam() == 3 ? "teleportedin_blue" : "teleportedin_red", vecTeleport, Vector(1))
							flLastTeleportTime = flTime
						}

						hPlayer.SetAbsOrigin(vecTeleport)
						local flUberTime = Convars.GetFloat("tf_mvm_engineer_teleporter_uber_duration")
						hPlayer.AddCondEx(TF_COND_INVULNERABLE, flUberTime, null)
						hPlayer.AddCondEx(TF_COND_INVULNERABLE_WEARINGOFF, flUberTime, null)
						hPlayer.AddCondEx(TF_COND_TELEPORTED, 30, null)
						break
					}
				}
			}
	}
}
__CollectGameEventCallbacks(TeleTankEvents)

TankExt.NewTankScript("teletank", {
	OnSpawn = function(hTank, sName, hPath)
	{
		local hTank_scope = hTank.GetScriptScope()
		local bBlueTeam = hTank.GetTeam() == 3
		hTank_scope.hTeleporter <- SpawnEntityFromTable("prop_dynamic", {
			model          = "models/buildables/teleporter_light.mdl"
			defaultanim    = "running"
			body           = 1
			skin           = bBlueTeam ? 1 : 0
			origin         = "-42 0 169"
			disableshadows = 1
		})
		local hParticle = SpawnEntityFromTable("info_particle_system", {
			effect_name  = bBlueTeam ? "teleporter_blue_wisps_level3" : "teleporter_red_wisps_level3"
			start_active = 1
			origin       = "-42 0 169"
		})
		TankExt.SetParentArray([hTank_scope.hTeleporter, hParticle], hTank)
	}
})