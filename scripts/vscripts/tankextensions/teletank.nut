local TELETANK_VALUES_TABLE = {
	TELETANK_MODEL              = "models/bots/boss_bot/boss_tank_building.mdl"
	TELETANK_MODEL_DAMAGE1      = "models/bots/boss_bot/boss_tank_building_damage1.mdl"
	TELETANK_MODEL_DAMAGE2      = "models/bots/boss_bot/boss_tank_building_damage2.mdl"
	TELETANK_MODEL_DAMAGE3      = "models/bots/boss_bot/boss_tank_building_damage3.mdl"
	TELETANK_MODEL_TRACK_L      = "models/bots/boss_bot/tank_track_L_building.mdl"
	TELETANK_MODEL_TRACK_R      = "models/bots/boss_bot/tank_track_R_building.mdl"
	TELETANK_MODEL_BOMB         = "models/bots/boss_bot/bomb_mechanism_building.mdl"
	TELETANK_UBER_DURATION_MULT = 0.2
}
foreach(k,v in TELETANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(TELETANK_MODEL)
PrecacheModel(TELETANK_MODEL_DAMAGE1)
PrecacheModel(TELETANK_MODEL_DAMAGE2)
PrecacheModel(TELETANK_MODEL_DAMAGE3)
PrecacheModel(TELETANK_MODEL_TRACK_L)
PrecacheModel(TELETANK_MODEL_TRACK_R)
PrecacheModel(TELETANK_MODEL_BOMB)

::TeleTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::TeleTankEvents }
	flLastTeleportTime = 0
	OnGameEvent_player_spawn = function(params)
	{
		local hPlayer = GetPlayerFromUserID(params.userid)
		EntFire("bignet", "RunScriptCode", "TeleTankEvents.Bot_TeleTank(activator)", -1, hPlayer)
	}
	Bot_TeleTank = function(hPlayer)
	{
		local iTeamNum = hPlayer.GetTeam()
		if(hPlayer.IsBotOfType(TF_BOT_TYPE) && hPlayer.HasBotTag("bot_teletank"))
			for(local hTank; hTank = FindByClassname(hTank, "tank_boss");)
			{
				if(iTeamNum != hTank.GetTeam()) continue
				local TeleScope = TankExt.GetMultiScopeTable(hTank.GetScriptScope(), "teletank")
				if(TeleScope && TeleScope.hTeleporter && TeleScope.hTeleporter.IsValid())
				{
					local vecTeleport = TeleScope.hTeleporter.GetOrigin() + TeleScope.hTeleporter.GetUpVector() * 16
					local Trace = {
						start   = vecTeleport
						end     = vecTeleport
						hullmin = hPlayer.GetPlayerMins()
						hullmax = hPlayer.GetPlayerMaxs()
						mask    = MASK_PLAYERSOLID_BRUSHONLY
						ignore  = hPlayer
					}
					TraceHull(Trace)
					if(!("startsolid" in Trace))
					{
						local flTime = Time()
						if(flTime - flLastTeleportTime > 0.1)
						{
							TeleScope.hTeleporter.EmitSound("MVM.Robot_Teleporter_Deliver")
							DispatchParticleEffect(iTeamNum == TF_TEAM_BLUE ? "teleportedin_blue" : "teleportedin_red", vecTeleport, Vector(1))
							flLastTeleportTime = flTime
						}

						hPlayer.SetAbsOrigin(vecTeleport)

						// if the bots last known nav area is their spawn they'll have spawn uber, this is the only entity that can reset their last known nav area purposely
						local hTriggerFix = CreateByClassnameSafe("trigger_remove_tf_player_condition")
						hTriggerFix.KeyValueFromInt("condition", TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
						hTriggerFix.KeyValueFromInt("spawnflags", 1)
						hTriggerFix.DispatchSpawn()
						hTriggerFix.AcceptInput("StartTouch", null, null, hPlayer)
						hTriggerFix.Kill()

						local flUberTime = Convars.GetFloat("tf_mvm_engineer_teleporter_uber_duration") * TELETANK_UBER_DURATION_MULT
						hPlayer.AddCondEx(TF_COND_INVULNERABLE, flUberTime, null)
						hPlayer.AddCondEx(TF_COND_TELEPORTED, 30, null)
						hPlayer.SetCollisionGroup(COLLISION_GROUP_DEBRIS)
						EntFire("bignet", "RunScriptCode", "activator.SetCollisionGroup(COLLISION_GROUP_PLAYER)", 0.5, hPlayer)

						for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecTeleport, 96);)
							if(hPlayer.IsAlive() && hPlayer.GetTeam() != iTeamNum)
							{
								local vecDirection = hPlayer.EyePosition() - vecTeleport
								vecDirection.z = 0.0
								vecDirection.Norm()
								vecDirection.z = 1.0
								vecDirection *= 400
								hPlayer.ApplyAbsVelocityImpulse(vecDirection)
								hPlayer.StunPlayer(0.5, 1, TF_STUN_MOVEMENT, null)
							}
						break
					}
				}
			}
	}
}
__CollectGameEventCallbacks(TeleTankEvents)

TankExt.NewTankType("teletank", {
	Model = {
		Default     = TELETANK_MODEL
		Damage1     = TELETANK_MODEL_DAMAGE1
		Damage2     = TELETANK_MODEL_DAMAGE2
		Damage3     = TELETANK_MODEL_DAMAGE3
		LeftTrack   = TELETANK_MODEL_TRACK_L
		RightTrack  = TELETANK_MODEL_TRACK_R
		Bomb        = TELETANK_MODEL_BOMB
	}
	function OnSpawn()
	{
		local bModelHasAttachment = self.LookupAttachment("building_attachment") != 0
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
		if(self.GetModelName() == TELETANK_MODEL) self.SetSkin(bBlueTeam ? 0 : 1)
		hTeleporter <- SpawnEntityFromTableSafe("prop_dynamic", {
			model          = "models/buildables/teleporter_light.mdl"
			defaultanim    = "running"
			body           = 1
			skin           = bBlueTeam ? 1 : 0
			origin         = bModelHasAttachment ? "0 0 0" : "-42 0 169"
			angles         = bModelHasAttachment ? "-90 0 -90" : "0 0 0"
			disableshadows = 1
		})
		EmitSoundOn("Building_Teleporter.SpinLevel3", hTeleporter)
		TankExt.SetDestroyCallback(hTeleporter, @() StopSoundOn("Building_Teleporter.SpinLevel3", self))
		TankExt.DispatchParticleEffectOn(hTeleporter, bBlueTeam ? "teleporter_arms_circle_blue" : "teleporter_arms_circle_red", "arm_attach_L")
		TankExt.DispatchParticleEffectOn(hTeleporter, bBlueTeam ? "teleporter_arms_circle_blue" : "teleporter_arms_circle_red", "arm_attach_R")
		TankExt.SetParentArray([hTeleporter], self, bModelHasAttachment ? "building_attachment" : null)

		local sUniqueName = UniqueString()
		local hTouch = SpawnEntityFromTableSafe("dispenser_touch_trigger", { targetname = sUniqueName, spawnflags = 1 })
		hTouch.SetSize(Vector(-512, -512, -128), Vector(512, 512, 384))
		hTouch.SetSolid(SOLID_BBOX)
		local hDisp = SpawnEntityFromTableSafe("mapobj_cart_dispenser", { touch_trigger = sUniqueName, origin = "0 8 0", angles = "0 90 0", defaultupgrade = 2, spawnflags = 4, teamnum = bBlueTeam ? TF_TEAM_BLUE : TF_TEAM_RED })
		EmitSoundEx({ entity = hDisp, sound_name = "misc/null.wav", filter_type = RECIPIENT_FILTER_GLOBAL, flags = SND_STOP | SND_IGNORE_NAME })
		TankExt.SetParentArray([hDisp], self, "smoke_attachment")

		local hTouchReal = SpawnEntityFromTableSafe("trigger_multiple", { spawnflags = 1 })
		TankExt.SetParentArray([hTouch, hTouchReal], self)
		SetPropEntity(hTouch, "m_pParent", null)
		SetPropEntity(hTouchReal, "m_pParent", null)
		hTouchReal.SetSize(Vector(-512, -512, -128), Vector(512, 512, 384))
		hTouchReal.SetSolid(SOLID_BBOX)
		local PlayersTouching = []
		hTouchReal.ValidateScriptScope()
		hTouchReal.ConnectOutput("OnStartTouch", "StartTouch")
		hTouchReal.ConnectOutput("OnEndTouch", "EndTouch")
		local hTouchReal_scope = hTouchReal.GetScriptScope()
		hTouchReal_scope.StartTouch <- function()
		{
			if(hDisp.GetTeam() == activator.GetTeam())
				PlayersTouching.append(activator)
		}
		hTouchReal_scope.EndTouch <- function()
		{
			local index = PlayersTouching.find(activator)
			if(index != null)
				PlayersTouching.remove(index)
		}
		hTouchReal_scope.Think <- function()
		{
			foreach(hPlayer in PlayersTouching)
				if(hPlayer.IsValid())
					hPlayer.AddCondEx(TF_COND_RADIUSHEAL, 0.2, null)
			return 0.1
		}
		AddThinkToEnt(hTouchReal, "Think")
	}
})