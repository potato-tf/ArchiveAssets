::PEA_GLOBAL <-
{
	debug = false
	
	strip_romevision_items = false
	
    gamerules_entity = Entities.FindByName(null, "gamerules")
	objective_resource_entity = Entities.FindByClassname(null, "tf_objective_resource")
	
	thinkertick = 1
	
	mission = NetProps.GetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName")
	
	Wave = NetProps.GetPropInt(Entities.FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")
	
	tanks_in_wave = 0
	blimps_in_wave = 0

	GLOBAL_CALLBACKS =
	{
		OnGameEvent_recalculate_holidays = function(params) // do cleanup after mission switch
		{
			if (GetRoundState() == 3 && NetProps.GetPropString(objective_resource_entity, "m_iszMvMPopfileName") != mission)
			{
				if ("MapCleanup" in PEA) ::MapCleanup()
				
				foreach (thing, var in PEA) if (thing in getroottable()) delete getroottable()[thing]
				
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (player.GetScriptScope() != null)
					{
						foreach (thing in player.GetScriptScope())
						{
							try { thing.GetClassname() }
							catch (e) { continue }
							
							if (!thing.IsPlayer()) thing.Kill()
						}
					}

					player.TerminateScriptScope()
				}
				
				delete ::PEA
				return
			}
			
			if (strip_romevision_items)
			{
				for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/carrier.mdl"); )
				{
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 0)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 1)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 2)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 3)
				}
				
				for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/carrier_parts.mdl"); )
				{
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 0)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 1)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 2)
					NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 3)
				}
			}
		}
		
		OnGameEvent_post_inventory_application = function(params) // player_spawn will not detect romevision items!
		{
			local bot = GetPlayerFromUserID(params.userid);
			
			if (bot.IsFakeClient())
			{
				if (strip_romevision_items) for (local child = bot.FirstMoveChild(); child != null; child = child.NextMovePeer()) if (child.GetClassname() == "tf_wearable" && child.GetModelName().find("tw_") != null) EntFireByHandle(child, "Kill", null, -1.0, null, null)
				
				EntFireByHandle(bot, "CallScriptFunction", "GlobalBotTagCheck", -1.0, null, null)
			}
		}
		
		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			
			if (dead_player.IsFakeClient())
			{	
				for (local cash; cash = Entities.FindByClassname(cash, "item_currencypack_custom"); ) AddThinkToEnt(cash, "ImprovedCashCollection_Think")
				
				local projectiles_leftbehind = false
				
				for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_*"); )
				{
					if (ent.GetOwner() == dead_player || NetProps.GetPropEntity(ent, "m_hThrower") == dead_player) { projectiles_leftbehind = true; break }
				}
				
				EntFireByHandle(dead_player, "RunScriptCode", "self.SetUseBossHealthBar(false)", -1.0, null, null)
				
				if (!projectiles_leftbehind) EntFireByHandle(dead_player, "RunScriptCode", "self.ForceChangeTeam(1, true)", 0.1, null, null)
			}
		}
	}

	ImprovedCashCollection_Think = function()
	{
		try // tends to throw harmless errors about collecting player becoming null
		{
			for (local player_to_collect; player_to_collect = Entities.FindByClassnameWithin(player_to_collect, "player", self.GetOrigin(), 288); )
			{
				if (player_to_collect != null && player_to_collect.GetTeam() == 2 && !player_to_collect.IsFakeClient() && NetProps.GetPropInt(player_to_collect, "m_lifeState") == 0 && NetProps.GetPropInt(player_to_collect, "m_PlayerClass") == Constants.ETFClass.TF_CLASS_SCOUT)
				{
					self.Teleport(true, player_to_collect.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
					self.DisableDraw()
					return 1 // stop reiterating after the teleport
				}
			}
		}
		
		catch (e) { return }

		return -1
	}
	
	IsInside = function(vector, min, max) { return vector.x >= min.x && vector.x <= max.x && vector.y >= min.y && vector.y <= max.y && vector.z >= min.z && vector.z <= max.z }
	
	DisableRomevision = function()
	{
		for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/carrier.mdl"); )
		{
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 0)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 1)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 2)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier.mdl"), 3)
		}
		
		for (local ent; ent = Entities.FindByModel(ent, "models/bots/boss_bot/carrier_parts.mdl"); )
		{
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 0)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 1)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 2)
			NetProps.SetPropIntArray(ent, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/carrier_parts.mdl"), 3)
		}
		
		strip_romevision_items = true
	}
	
	GlobalBotTagCheck = function()
	{
		if (self.HasBotTag("disband_squad")) self.DisbandCurrentSquad()
	}
	
	TankFinder_Think = function()
	{
		for (local tank; tank = Entities.FindByName(tank, "tankboss"); )
		{
			if (strip_romevision_items)
			{
				if (tank.GetModelName() == "models/bots/boss_bot/boss_tank.mdl") 		 NetProps.SetPropIntArray(tank, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank.mdl"), 3)
				if (tank.GetModelName() == "models/bots/boss_bot/boss_tank_damage1.mdl") NetProps.SetPropIntArray(tank, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage1.mdl"), 3)
				if (tank.GetModelName() == "models/bots/boss_bot/boss_tank_damage2.mdl") NetProps.SetPropIntArray(tank, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage2.mdl"), 3)
				if (tank.GetModelName() == "models/bots/boss_bot/boss_tank_damage3.mdl") NetProps.SetPropIntArray(tank, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage3.mdl"), 3)
			
				local child_array = []
				
				for (local child = tank.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)
				
				foreach (child in child_array) NetProps.SetPropIntArray(child, "m_nModelIndexOverrides", NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 0), 3)
			}
			
			if (EntityOutputs.HasAction(tank, "OnKilled")) continue
			else EntityOutputs.AddOutput(tank, "OnKilled", "gamerules", "CallScriptFunction", "CleanUpTank", -1.0, -1.0)
		}
		
		for (local blimp; blimp = Entities.FindByName(blimp, "blimpboss"); )
		{
			if (blimp.GetScriptScope() != null) continue
			else SetUpBlimp(blimp)
		}
	}
	
	CleanUpTank = function()
	{
		tanks_in_wave = tanks_in_wave - 1
		for (local cash; cash = Entities.FindByClassname(cash, "item_currencypack_custom"); ) AddThinkToEnt(cash, "ImprovedCashCollection_Think")
		
		if (debug) ClientPrint(null,3,"cleanup called")
	}
	
	HideIcon = function(name)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", 0, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2", 0, i)
		}
	}
	
	UnhideIcon = function(name, flag)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", flag, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2", flag, i)
		}
	}
	
	ConvertTankIconsToBlimp = function(convertall, amount = 1)
	{
		if (convertall)
		{
			for (local i = 0; i <= 11; i++)
			{
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == "tank")
				{
					NetProps.SetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", "blimp2_lite", i)
					blimps_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i)
				}
				
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == "tank")
				{
					NetProps.SetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", "blimp2_lite", i)
					blimps_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i)
				}
			}
		}
		
		else
		{
			for (local i = 0; i <= 11; i++)
			{
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == "blimp2_lite")
				{
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", 9, i)
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", amount, i)
					blimps_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i)
				}
				
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == "blimp2_lite")
				{
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2", 9, i)
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", amount, i)
					blimps_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i)
				}
				
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == "tank")
				{
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i) - amount, i)
					tanks_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i)
				}
				if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == "tank")
				{
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i) - amount, i)
					tanks_in_wave = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i)
				}
			}
		}
	}
	
	InstantReady_Think = function()
	{
		if (NetProps.GetPropBoolArray(gamerules_entity, "m_bPlayerReady", 1) && !countdown_skipped)
		{
			NetProps.SetPropFloat(gamerules_entity, "m_flRestartRoundTime", Time())
			countdown_skipped = true
		}
	}

	ThinksTable = {}
	
	GlobalThinker = function()
	{
		thinkertick = thinkertick + 1

		foreach (func in ThinksTable) func()

		return -1
	}
	
	AssignThinkToThinksTable = function(think) { if (!(think in getroottable()["ThinksTable"])) getroottable()["ThinksTable"][think] <- getroottable()[think] }

	RemoveThinkFromThinksTable = function(think) { delete getroottable()["ThinksTable"][think] }
	
	SetUpBlimp = function(blimp)
	{
		NetProps.SetPropIntArray(blimp, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 0)
		NetProps.SetPropIntArray(blimp, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 1)
		NetProps.SetPropIntArray(blimp, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 2)
		NetProps.SetPropIntArray(blimp, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 3)
		
		local blimp_speed = NetProps.GetPropFloat(blimp, "m_speed")
		
		local child_array = []
		
		for (local child = blimp.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)
		
		foreach (child in child_array) child.Kill()
		
		blimp.SetSkin(1)
		
		local train = SpawnEntityFromTable("func_tracktrain",
		{
			targetname              = "blimp_train"
			target                  = "blimp_path1"
			startspeed              = blimp_speed
			speed                   = blimp_speed
			origin                  = Entities.FindByName(null, "blimp_path1").GetOrigin()
			orientationtype         = 1
			spawnflags              = 136
			volume					= 10
			model					= "*2"
			rendermode				= 1
			renderamt				= 0
			solid					= 0
		})
		
		train.ValidateScriptScope()
		train.GetScriptScope().parented_blimp <- blimp
		
		blimp.ValidateScriptScope()
		blimp.GetScriptScope().pathtrain <- train
		
		blimp.SetModelScale(("blimp_scale" in PEA) ? blimp_scale : 1, -1)
		
		AddThinkToEnt(blimp, "Blimp_Think")
	}
	
	CleanUpBlimp = function()
	{
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == true) return // don't do cleanup if the blimp was the last enemy in the wave
		
		blimps_in_wave = blimps_in_wave - 1

		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == "blimp2_lite") NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", blimps_in_wave, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == "blimp2_lite") NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", blimps_in_wave, i)
			
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames", i) == "tank") NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", tanks_in_wave, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2", i) == "tank") NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", tanks_in_wave, i)
		}
		
		for (local train; train = Entities.FindByName(train, "blimp_train"); ) if (!train.GetScriptScope().parented_blimp.IsValid()) train.Kill()
		for (local cash; cash = Entities.FindByClassname(cash, "item_currencypack_custom"); ) AddThinkToEnt(cash, "ImprovedCashCollection_Think")
	}

	Blimp_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("Deploy_Bomb_1" in scope))
		{
			PrecacheSound("npc/combine_gunship/ping_search.wav")
			
			scope.nextpingtime <- Time() + 5
			
			scope.Deploy_Bomb_1 <- function()
			{	
				self.ResetSequence(1)
				self.SetCycle(0)
				
				EntFire("!self", "CallScriptFunction", "Deploy_Bomb_2", 8.0)
				
				EmitSoundEx(
				{
					sound_name = "MVM.TankDeploy",
					filter = 5,
					entity = self,
					volume = 1,
					soundlevel = 150,
					flags = 1,
					channel = 6
				})
			}
			
			scope.Deploy_Bomb_2 <- function()
			{
				if (self == null) return
				
				switch (GetMapName())
				{
					case "mvm_hanami_rc1":
					{
						EntFire("win_bots", "RoundWin")
						EntFire("hatch_destroy_relay", "Trigger")
						break
					}
					
					case "mvm_null_b9a":
					{
						soldier_statue.Kill()

						EntFire("bots_win", "RoundWin")
						EntFire("end_pit_destroy_particle", "Start")
						EntFire("pit_explosion_wav", "PlaySound")
						EntFire("hatch_explo_kill_players", "Enable")
						EntFire("hatch_explo_kill_players", "Disable", null, 0.5)
						EntFire("hatch_magnet_pit", "Enable")
						EntFire("trigger_hurt_hatch_fire", "Enable")
						break
					}
					
					case "mvm_quetzal_rc5": EntFire("boss_deploy_relay", "Trigger"); break
				}
			}
			
			EntityOutputs.AddOutput(self, "OnKilled", "gamerules", "CallScriptFunction", "CleanUpBlimp", -1.0, -1.0)
		}
		
		self.SetOrigin(scope.pathtrain.GetOrigin())
		self.SetAbsAngles(QAngle(0, scope.pathtrain.GetAbsAngles().y, 0))
		self.GetLocomotionInterface().Reset()
		
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank.mdl" 		|| self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank.mdl") 		NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 0)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage1.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage1.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage1.mdl"), 0)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage2.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage2.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage2.mdl"), 0)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage3.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage3.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage3.mdl"), 0)
		
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank.mdl" 		|| self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank.mdl") 		NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage1.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage1.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage1.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage2.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage2.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage2.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage3.mdl" || self.GetModelName() == "models/bots/tw2/boss_bot/boss_tank_damage3.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_blimp_damage3.mdl"), 3)
		
		EmitSoundEx(
		{
			sound_name = "MVM.TankPing",
			filter = 5,
			entity = self,
			volume = 1,
			soundlevel = 150,
			flags = 4,
			channel = 6
		})
		
		EmitSoundEx(
		{
			sound_name = "MVM.TankEngineLoop",
			filter = 5,
			entity = self,
			volume = 1,
			soundlevel = 150,
			flags = 4,
			channel = 6
		})
		
		if (Time() > scope.nextpingtime)
		{
			EmitSoundEx(
			{
				sound_name = "npc/combine_gunship/ping_search.wav",
				filter = 5,
				entity = self,
				volume = 1,
				soundlevel = 150,
				flags = 0,
				channel = 6
			})
			
			scope.nextpingtime = Time() + 5
		}
		
		return -1
	}
	
	DEBUG_CALLBACKS =
	{
		OnGameEvent_player_say = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)

			if (params.text == "1")
			{
				for (local ent; ent = Entities.FindByClassname(ent, "obj_sentrygun"); )
				{
					EntFireByHandle(ent, "RemoveHealth", "50", -1.0, null, null)
				}
				
				ClientPrint(null,3,"said 1")
				
				// PrecacheModel("models/player/pyro.mdl")
				// player.SetCustomModelWithClassAnimations("models/player/pyro.mdl")
				
			    // local wearable = SpawnEntityFromTable("tf_wearable",
				// {
					// origin = player.GetOrigin()
					// model = "models/bots/pyro/bot_pyro.mdl"
					// skin = 0
					// effects = 129
				// })
				
				// EntFireByHandle(wearable, "SetParent", "!activator", -1, player, null)
				// NetProps.SetPropInt(wearable, "m_fEffects", 129)
			}
			if (params.text == "2")
			{
				player.TakeDamage(200.0, 64, Entities.FindByName(null, "boss_plane*"))
			}
		}
	}
}

if (!("PEA" in getroottable()))	::PEA <- {}

foreach (thing, var in PEA_GLOBAL) getroottable()["PEA"][thing] <- getroottable()["PEA_GLOBAL"][thing]
foreach (thing, var in PEA) getroottable()[thing] <- getroottable()["PEA"][thing]

delete ::PEA_GLOBAL

foreach (think in getroottable()["ThinksTable"]) delete getroottable()["ThinksTable"][think]

for (local ent; ent = Entities.FindByName(ent, "blimp_path*"); ) if (NetProps.GetPropEntity(ent, "m_pnext") == null) EntityOutputs.AddOutput(ent, "OnPass", "!activator", "RunScriptCode", "self.GetScriptScope().parented_blimp.GetScriptScope().Deploy_Bomb_1()", -1.0, -1.0)

switch (GetMapName())
{
	case "mvm_sequoia_rc4": DisableRomevision(); break
	case "mvm_meltdown_rc5": break
	case "mvm_spacepost_rc1": break
	case "mvm_derelict_rc2": DisableRomevision(); break
	
	case "mvm_hanami_rc1": break
	case "mvm_hideout_b3": DisableRomevision(); break
	case "mvm_hoovydam_b10": DisableRomevision(); EntFire("initMain_roadside", "Trigger"); break
	
	case "mvm_null_b9a": DisableRomevision(); break
	case "mvm_decay_rc1": DisableRomevision(); break
	
	case "mvm_quetzal_rc5": DisableRomevision(); break
	case "mvm_powerplant_rc1": DisableRomevision(); break
}

AssignThinkToThinksTable("TankFinder_Think")

if ("CALLBACKS" in PEA) __CollectGameEventCallbacks(PEA.CALLBACKS)

__CollectGameEventCallbacks(PEA.GLOBAL_CALLBACKS)

for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++) // run this for when the first player connects to the server and the callback hasn't loaded yet
{
	local player = PlayerInstanceFromIndex(i)
	
	if (player == null) continue
	if (player.IsFakeClient()) for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) { EntFireByHandle(child, "Kill", null, -1.0, null, null); continue } 
	
	else if (!("first_spawn" in getroottable()))
	{
		player.ForceRespawn()
		PEA["first_spawn"] <- true; getroottable()["first_spawn"] <- PEA["first_spawn"]
	}
}

if (debug)
{
	for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
		{
			player.SetHealth(90000)
			player.SetMoveType(8, 0)
			player.AddCurrency(10000)
		}
	}
	
	PEA["countdown_skipped"] <- false
	getroottable()["countdown_skipped"] <- PEA["countdown_skipped"]
	
	AssignThinkToThinksTable("InstantReady_Think")
	
	__CollectGameEventCallbacks(PEA.DEBUG_CALLBACKS)
}

AddThinkToEnt(gamerules_entity, "GlobalThinker")