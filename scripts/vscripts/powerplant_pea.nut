for (local ent; ent = Entities.FindByName(ent, "tele_*"); ) ent.Kill()

::PEA <-
{
	debug = true

	intel_entity = Entities.FindByName(null, "intel")
	
	teledestination_array = []
	teledestination_array_giant = []

	tele_spot_b1 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_b1"
		origin        = Vector(-630, -430, 255)
		angles        = QAngle(0, -90, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_b2 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_b2"
		origin        = Vector(-1150, -1120, 255)
		angles        = QAngle(0, 90, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_b3 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_b3"
		origin        = Vector(-1850, -700, 255)
		angles        = QAngle(0, 0, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_b4 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_b4"
		origin        = Vector(450, -450, 205)
		angles        = QAngle(0, 180, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_b5 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_b5"
		origin        = Vector(180, -1120, 320)
		angles        = QAngle(0, 180, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_f1 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_f1"
		origin        = Vector(-1500, 1600, 180)
		angles        = QAngle(0, -90, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_f2 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_f2"
		origin        = Vector(-450, 1500, 40)
		angles        = QAngle(0, -90, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_f3 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_f3"
		origin        = Vector(450, 600, 80)
		angles        = QAngle(0, 180, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_f4 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_f4"
		origin        = Vector(-1950, -100, 255)
		angles        = QAngle(0, 0, 0)
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		DefaultAnim   = "idle"
	})

	tele_spot_b1_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_b1"
		origin        	   = Vector(-630, -430, 255)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_b2_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_b2"
		origin             = Vector(-1150, -1120, 255)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_b3_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_b3"
		origin             = Vector(-1850, -700, 255)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_b4_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_b4"
		origin             = Vector(450, -450, 205)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_b5_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_b5"
		origin        	   = Vector(180, -1120, 320)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_f1_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_f1"
		origin             = Vector(-1500, 1600, 180)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_f2_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_f2"
		origin             = Vector(-450, 1500, 40)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_f3_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_f3"
		origin             = Vector(450, 600, 80)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_f4_skyparticle = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "skyparticle_tele_spot_f4"
		origin             = Vector(-1950, -100, 285)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	teleports_active = false

	current_squad_leader = null
	bomb_placement_adjusted = false

	current_bombpath = null
	
	nav_avoid_giant = null
	nav_avoid_giant2 = null
	nav_avoid_bossbot = null
	
	SetUpNavFuncs = function()
	{
		nav_avoid_giant = SpawnEntityFromTable("func_nav_avoid",
		{
			targetname       = "nav_avoid_giant"
			origin           = Vector(-700, -350, 0)
			tags             = "bot_giant"
		})

		nav_avoid_giant.KeyValueFromInt("solid", 2)
		nav_avoid_giant.KeyValueFromString("mins", "-300 -300 -1000")
		nav_avoid_giant.KeyValueFromString("maxs", "300 300 1000")
		
		nav_avoid_giant2 = SpawnEntityFromTable("func_nav_avoid",
		{
			targetname       = "nav_avoid_giant"
			origin           = Vector(-800, 200, 200)
			tags             = "bot_giant"
		})

		nav_avoid_giant2.KeyValueFromInt("solid", 2)
		nav_avoid_giant2.KeyValueFromString("mins", "-200 -200 -1000")
		nav_avoid_giant2.KeyValueFromString("maxs", "200 200 1000")
		
		function PreventBadPathing()
		{
			local nav_avoid_telebot = SpawnEntityFromTable("func_nav_avoid",
			{
				targetname       = "nav_avoid_telebot"
				origin           = Vector(-500, -1500, 0)
				tags             = "telebot"
			})

			nav_avoid_telebot.KeyValueFromInt("solid", 2)
			nav_avoid_telebot.KeyValueFromString("mins", "-2000 -1500 -1000")
			nav_avoid_telebot.KeyValueFromString("maxs", "2000 250 1000")
		}
		
		PreventBadPathing(); PreventBadPathing(); PreventBadPathing(); PreventBadPathing() // needs to be run this many times to ensure the telebot nav paths win the attention of telebots over all the default nav funcs
		
		nav_avoid_bossbot = SpawnEntityFromTable("func_nav_avoid",
		{
			targetname       = "nav_avoid_bossbot"
			origin           = Vector(-100, 650, 0)
			tags             = "boss_bot"
		})
	
		nav_avoid_bossbot.KeyValueFromInt("solid", 2)
		nav_avoid_bossbot.KeyValueFromString("mins", "-300 -300 -1000")
		nav_avoid_bossbot.KeyValueFromString("maxs", "300 250 1000")

	}
	
	ignite_player = Entities.CreateByClassname("tf_weapon_flamethrower")
	
	CALLBACKS =
	{
		OnGameEvent_post_inventory_application = function(params)
		{
			local spawned_player = GetPlayerFromUserID(params.userid);
			
			if (spawned_player.IsFakeClient()) return
			
			spawned_player.ValidateScriptScope()
			local scope = spawned_player.GetScriptScope()
			
			if (!("saw_mission_info" in scope)) 
			{
				scope.saw_mission_info <- true
				ClientPrint(spawned_player, 4, "For the duration of this mission, certain robots will be spawning from several different locations marked on this map.")
				ClientPrint(spawned_player, 3, "\x07FFD700For the duration of this mission, certain robots will be spawning from several different locations marked on this map.")
			}
		}

		OnGameEvent_player_spawn = function(params) // it takes an extra short while for the populator to fill in all of a bot's data when it spawns in, so "onspawn" callbacks need to be delayed
		{
			local bot = GetPlayerFromUserID(params.userid);
			
			if (!bot.IsFakeClient()) return
			
			EntFireByHandle(bot, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
		}

		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			
			if (dead_player.IsFakeClient())
			{
				if (dead_player.GetScriptScope() != null)
				{
					foreach (thing in dead_player.GetScriptScope())
					{
						try { thing.GetClassname() }
						catch (e) { continue }
						
						if (!thing.IsPlayer()) thing.Kill()
					}
				}
				
				AddThinkToEnt(dead_player, null)
				NetProps.SetPropString(dead_player, "m_iszScriptThinkFunction", "")

				dead_player.TerminateScriptScope()
			}
		}
		
		OnGameEvent_mvm_begin_wave = function(params)
		{
			if (Wave == 5) { HideIcon("scout_giant"); HideIcon("pyro_flare"); HideIcon("heavy_heater_giant") }
		}
	}
	
	Teles_Start = function()
	{
		EntFireByHandle(gamerules_entity, "PlayVO", "mvm/mvm_tele_activate.wav", 0.0, null, null)
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (IsPlayerABot(player)) continue
			
			player.ValidateScriptScope()
			local scope = player.GetScriptScope()
			
			if (!("saw_teleport_overlay" in scope)) 
			{
				scope.saw_teleport_overlay <- true
				EntFireByHandle(player, "SetScriptOverlayMaterial", "teleport_warning_overlay", 0.0, null, null);
				EntFireByHandle(player, "SetScriptOverlayMaterial", "", 8.0, null, null);
			}
		}
		
		teleports_active = true
	}

	BotTagCheck = function()
	{
		if (self.HasBotTag("aoe_medic")) AddThinkToEnt(self, "AoEUber_Think")
		if (self.HasBotTag("boss_bot")) AddThinkToEnt(self, "FireFist_Think")
		
		if (!(self.HasBotTag("telebot")) && !(self.HasBotTag("telebot_ignorenavfunc"))) return
		
		if (!(self.HasBotTag("telebot_squadmember")) || !(self.HasBotTag("telebot_w3d")) || !(self.HasBotTag("telebot_w5a")) || !(self.HasBotTag("telebot_bosshelper")))
		{
			try
			{
				if (!(self.HasBotAttribute(32768))) self.Teleport(true, teledestination_array[RandomInt(0, teledestination_array.len() - 1)] + Vector(0, 0, 10), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
				else                                self.Teleport(true, teledestination_array_giant[RandomInt(0, teledestination_array_giant.len() - 1)] + Vector(0, 0, 10), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			}
			catch (e) {} // vscript complains about not finding any tele locations even when the "if" condition is not met
		}
		
		if (self.HasBotTag("telebot_w3d")) self.Teleport(true, Vector(-800, -2050, 235), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		if (self.HasBotTag("telebot_w5a")) self.Teleport(true, Vector(-1850, -700, 285), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		
		if (self.HasBotTag("telebot_squadleader"))
		{
			current_squad_leader = self
			EntFireByHandle(gamerules_entity, "RunScriptCode", "current_squad_leader = null", 0.5, null, null)
		}
		
		if (self.HasBotTag("telebot_squadmember")) self.Teleport(true, current_squad_leader.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		
		if (!(self.HasBotAttribute(32768)))
		{
			self.AddCustomAttribute("force distribute currency on death", 1, -1)
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player_to_alert = PlayerInstanceFromIndex(i)
				
				if (player_to_alert == null || IsPlayerABot(player_to_alert)) continue
				
				if (!(self.HasBotTag("telebot_squadmember"))) EmitSoundEx({sound_name = "mvm/mvm_tele_deliver.wav", channel = 6, entity = player_to_alert, pitch = 100, filter_type = 4, volume = 0.2})
			}
		}
		
		if (self.HasBotAttribute(32768))
		{
			NetProps.SetPropBool(self, "m_bGlowEnabled", true)
			if (!(self.HasBotTag("telebot_squadmember"))) EntFireByHandle(gamerules_entity, "PlayVO", "mvm/giant_heavy/giant_heavy_entrance.wav", -1.0, null, null)
		}
		
		EntFireByHandle(self, "CallScriptFunction", "Telefrag", 0.2, null, null) // smallest comfortable amount of time required by the populator to fill in all of the bot's identity without issues
	}

	Telefrag = function()
	{
		if (!self.HasBotTag("telebot") && !(self.HasBotTag("telebot_ignorenavfunc"))) return
		
		local teletext = NetProps.GetPropString(self, "m_szNetname") + "\nhas teleported in!"
		
		if (self.HasBotTag("telebot_w3d")) teletext = "Surprise attack!"
		if (self.HasBotTag("telebot_w5a")) teletext = "Giant Pyro and Giant Medic\nhave teleported in!"
		
		if (self.HasBotAttribute(32768) && !self.HasBotTag("telebot_squadmember"))
		{
			SendGlobalGameEvent("show_annotation", 
			{
				text = teletext
				worldPosX = self.GetOrigin().x
				worldPosY = self.GetOrigin().y
				worldPosZ = self.GetOrigin().z
				play_sound = "misc/null.wav"
				show_distance = false
				show_effect = true
				lifetime = 5
			})
		}
		
		if (!self.HasBotTag("telebot_bosshelper"))
		{
			for (local entity_to_telefrag; entity_to_telefrag = Entities.FindInSphere(entity_to_telefrag, self.GetOrigin(), 100); )
			{
				if (entity_to_telefrag.GetTeam() == 2)
				{
					entity_to_telefrag.TakeDamage(1000.0, 64, self)
				}
			}
		}
	}

	ControlTeleSpot = function(action, ent_to_effect)
	{
		ent_to_effect.KeyValueFromInt("rendermode", 0)
		
		if (action == "enable")
		{
			NetProps.SetPropInt(ent_to_effect, "m_nSkin", 1)
			NetProps.SetPropFloat(ent_to_effect, "m_flPlaybackRate", 1.0)
			
			EntFire("skyparticle_" + ent_to_effect.GetName(), "Start")
		}
		
		if (action == "disable")
		{
			NetProps.SetPropInt(ent_to_effect, "m_nSkin", 2)
			NetProps.SetPropFloat(ent_to_effect, "m_flPlaybackRate", 0.0)
			
			EntFire("skyparticle_" + ent_to_effect.GetName(), "Stop")
		}
		
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == true)
		{
			ent_to_effect.KeyValueFromInt("rendermode", 1)
			ent_to_effect.KeyValueFromInt("renderamt", 90)
			
			EntFire("skyparticle_" + ent_to_effect.GetName(), "Stop")
		}
	}

	HaveDefendersBeenPushed_Think = function()
	{	
		if (thinkertick % 7 != 0) return
		
		if (!teleports_active)
		{
			if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == true)
			{
				for (local telespot; telespot = Entities.FindByName(telespot, "tele_spot_b*"); ) ::ControlTeleSpot("enable", telespot)
				for (local telespot; telespot = Entities.FindByName(telespot, "tele_spot_f*"); ) ::ControlTeleSpot("disable", telespot)
			}
			else for (local telespot; telespot = Entities.FindByName(telespot, "tele_spot_*"); ) ::ControlTeleSpot("disable", telespot)
		}
		
		if (teleports_active)
		{
			if (intel_entity.GetOrigin().y < -300.0) EntFire("nav_avoid_telebot", "Disable")
			else EntFire("nav_avoid_telebot", "Enable")
			
			if (current_bombpath == "left")
			{
				if (intel_entity.GetOrigin().y <= 850.0) {::ControlTeleSpot("disable", tele_spot_b4); ::ControlTeleSpot("disable", tele_spot_b5)}
				else 									 {::ControlTeleSpot("enable", tele_spot_b4); ::ControlTeleSpot("enable", tele_spot_b5)}
				
				if (intel_entity.GetOrigin().y <= 100.0) {::ControlTeleSpot("disable", tele_spot_b1); ::ControlTeleSpot("disable", tele_spot_b2); ::ControlTeleSpot("disable", tele_spot_b3); ::ControlTeleSpot("enable", tele_spot_f1); ::ControlTeleSpot("enable", tele_spot_f2); ::ControlTeleSpot("enable", tele_spot_f3)}
				else									 {::ControlTeleSpot("enable", tele_spot_b1); ::ControlTeleSpot("enable", tele_spot_b2); ::ControlTeleSpot("enable", tele_spot_b3); ::ControlTeleSpot("disable", tele_spot_f1); ::ControlTeleSpot("disable", tele_spot_f2); ::ControlTeleSpot("disable", tele_spot_f3)}
				
				if (intel_entity.GetOrigin().y <= -600.0) ::ControlTeleSpot("enable", tele_spot_f4)
				else 									  ::ControlTeleSpot("disable", tele_spot_f4)
			}
			
			if (current_bombpath == "right")
			{
				if (intel_entity.GetOrigin().y <= 700.0) {::ControlTeleSpot("disable", tele_spot_b1); ::ControlTeleSpot("disable", tele_spot_b2); ::ControlTeleSpot("disable", tele_spot_b3)}
				else									 {::ControlTeleSpot("enable", tele_spot_b1); ::ControlTeleSpot("enable", tele_spot_b2); ::ControlTeleSpot("enable", tele_spot_b3)}
				
				if (intel_entity.GetOrigin().y <= 0.0) {::ControlTeleSpot("disable", tele_spot_b4); ::ControlTeleSpot("disable", tele_spot_b5); ::ControlTeleSpot("enable", tele_spot_f1); ::ControlTeleSpot("enable", tele_spot_f2); ::ControlTeleSpot("enable", tele_spot_f3)}
				else								   {::ControlTeleSpot("enable", tele_spot_b4); ::ControlTeleSpot("enable", tele_spot_b5); ::ControlTeleSpot("disable", tele_spot_f1); ::ControlTeleSpot("disable", tele_spot_f2); ::ControlTeleSpot("disable", tele_spot_f3)}
				
				if (intel_entity.GetOrigin().y <= -650.0) ::ControlTeleSpot("enable", tele_spot_f4)
				else 									  ::ControlTeleSpot("disable", tele_spot_f4)
			}
		}
		
		teledestination_array.clear()
		teledestination_array_giant.clear()
		
		for (local telespot; telespot = Entities.FindByName(telespot, "tele_spot_*"); )
		{
			if (NetProps.GetPropInt(telespot, "m_nSkin") == 2) continue
			
			teledestination_array.append(telespot.GetOrigin())
			
			if (telespot.GetName() == "tele_spot_b1" || telespot.GetName() == "tele_spot_b2" || telespot.GetName() == "tele_spot_b5") continue
			
			teledestination_array_giant.append(telespot.GetOrigin())
		}
	}

	BombCarrierSpawnSpeedUp_Think = function()
	{
		if (thinkertick % 7 != 0) return
		
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == false)
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue
				if (player.GetTeam() != 3) continue
				if (player.HasItem())
				{
					if (player.InCond(130) && !player.HasBotAttribute(32768)) player.AddCustomAttribute("CARD: move speed bonus", 10, -1)
					else player.RemoveCustomAttribute("CARD: move speed bonus")
					
					if (!bomb_placement_adjusted)
					{
						if (current_bombpath == "right") player.Teleport(true, Vector(-1056, 3312, 96), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)) // bots will disobey bomb path if they don't spawn from spawnbot_right
						
						bomb_placement_adjusted = true
					}
				}
			}
		}
	}
	
	AoEUber_Think = function()
	{	
		local scope = self.GetScriptScope()
		
		if (!("init" in scope))
		{
			scope.init <- true

			scope.uber_beam_1 <- SpawnEntityFromTable("dispenser_touch_trigger",
			{
				origin             = self.GetOrigin()
				spawnflags         = 1
			})
			
			scope.uber_beam_2 <- SpawnEntityFromTable("mapobj_cart_dispenser",
			{
				origin             = self.GetOrigin()
				TeamNum            = 3,
				spawnflags         = 12
				touch_trigger      = "dispenser_trigger"
			})
			
			scope.uber_beam_1.KeyValueFromInt("solid", 2)
			scope.uber_beam_1.KeyValueFromString("mins", "-250 -250 -250")
			scope.uber_beam_1.KeyValueFromString("maxs", "250 250 250")
			
			EntFireByHandle(scope.uber_beam_1, "SetParent", "!activator", -1.0, self, null)
			EntFireByHandle(scope.uber_beam_2, "SetParent", "!activator", -1.0, self, null)
			
			self.AddCond(55)
		}
		
		for (local player_to_shield; player_to_shield = Entities.FindByClassnameWithin(player_to_shield, "player", self.GetOrigin(), 250); )
		{
			if (player_to_shield == null) continue
			if (player_to_shield.GetTeam() == 3 && !player_to_shield.HasBotTag("aoe_medic")) player_to_shield.AddCondEx(52, 0.5, self)
		}
		
		return
	}
	
	FireFist_Think = function()
	{	
		local scope = self.GetScriptScope()
		
		if (!("init" in scope))
		{
			scope.init <- true
			
			scope.tick <- 1
			
			scope.boss_stage_threshold_reached <- false
			scope.after_boss_phase_transition <- false
			
			local firefist_gun = Entities.CreateByClassname("tf_weapon_rocketlauncher")

			NetProps.SetPropInt(firefist_gun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 18)
			NetProps.SetPropBool(firefist_gun, "m_AttributeManager.m_Item.m_bInitialized", true)
			NetProps.SetPropBool(firefist_gun, "m_bValidatedAttachedEntity", true)
			NetProps.SetPropInt(firefist_gun, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_boxing_gloves/c_boxing_gloves_xmas.mdl"))
			
			firefist_gun.SetTeam(self.GetTeam())
			firefist_gun.AddAttribute("clip size bonus", 9999, -1.0)
			
			Entities.DispatchSpawn(firefist_gun) 
			self.Weapon_Equip(firefist_gun)
			
			NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).Destroy()
			NetProps.SetPropEntityArray(self, "m_hMyWeapons", firefist_gun, 0)
			
			self.Weapon_Switch(firefist_gun)
			
			self.AddCond(30)
			
			scope.skybeam <- SpawnEntityFromTable("info_particle_system",
			{
				targetname    	   = "phase2_skybeam"
				origin             = self.GetOrigin()
				angles             = QAngle(0, 90, 0)
				start_active       = 0,
				effect_name        = "teleporter_mvm_bot_persist"
			})
			
			EntFire("phase2_skybeam", "SetParent", "!activator", -1.0, self)
			
			SpawnEntityFromTable("point_populator_interface", {targetname = "behavior_control"})

			function OnScriptHook_OnTakeDamage(params)
			{
				if (params.attacker == self || params.attacker == Entities.FindByName(null, "phase2_rockets"))
				{
					if ((params.damage_type == 2359360 || params.damage_type == 3407936) && params.const_entity != self) params.const_entity.TakeDamageEx(params.inflictor, params.attacker, ignite_player, Vector(0, 0, 0), params.const_entity.GetOrigin(), 0.01, 8)
				}
			}
			
			function OnGameEvent_player_spawn(params)
			{
				local bot = GetPlayerFromUserID(params.userid);
				
				if (!bot.IsFakeClient()) return
				
				bot.Teleport(true, self.GetOrigin() + Vector(0, 0, 50), false, QAngle(0, 0, 0), true, Vector(RandomInt(-500, 500), RandomInt(-500, 500), 600))
			}
			
			__CollectGameEventCallbacks(scope)
		}
		
		if (!scope.boss_stage_threshold_reached)
		{
			for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 250.0); )
			{
				if (player.GetTeam() != 2) continue
				
				local selfmins = self.GetBoundingMins() + self.GetOrigin() - Vector(3, 3, 3)
				local selfmaxs = self.GetBoundingMaxs() + self.GetOrigin() + Vector(3, 3, 3)

				local playermins = player.GetBoundingMins() + player.GetOrigin()
				local playermaxs = player.GetBoundingMaxs() + player.GetOrigin()

				if (playermins.x > selfmaxs.x || playermaxs.x < selfmins.x || playermins.y > selfmaxs.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermins.z > selfmaxs.z || playermaxs.z < selfmins.z) continue
				else
				{
					local pushforce = player.GetOrigin() - self.GetOrigin()
					pushforce.Norm()
					pushforce.z = 1.0
					pushforce = pushforce * 270
					
					player.RemoveFlag(1)
					player.AddCond(115)
					
					player.ApplyAbsVelocityImpulse(pushforce)
				}
			}
		
			if (self.GetHealth() < 40000.0)
			{
				scope.boss_stage_threshold_reached = true
				
				self.AddCondEx(71, 5.0, self)
				self.AddCustomAttribute("dmg taken increased", 0.1, -1)
				
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue;
					if (IsPlayerABot(player)) continue;
					
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 100, self)", 0.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 125, self)", 1.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 150, self)", 2.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 175, self)", 3.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 200, self)", 4.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`misc/rd_finale_beep01.wav`, 300.0, 0, 225, self)", 5.0, null, null)
					
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`ambient/explosions/explode_2.wav`, 300.0, 0, 100, self)", 5.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitAmbientSoundOn(`vo/mvm/mght/heavy_mvm_m_battlecry06.mp3`, 300.0, 0, 100, self)", 5.0, null, null)
				}
				
				function ExplosionPush()
				{
					self.RemoveCustomAttribute("dmg taken increased")
					
					DispatchParticleEffect("fireSmoke_Collumn_mvmAcres", self.GetOrigin(), Vector(0, 90, 0))
					
					for (local player_to_push; player_to_push = Entities.FindByClassnameWithin(player_to_push, "player", self.GetOrigin(), 500); )
					{
						if (player_to_push.GetTeam() == 2)
						{
							local pushforce = player_to_push.GetOrigin() - self.GetOrigin()
							pushforce.Norm()
							pushforce.z = 1.0
							pushforce = pushforce * 800
							
							player_to_push.TakeDamage(100.0, 64, self)
							
							player_to_push.RemoveFlag(1)
							player_to_push.AddCond(115)
							
							player_to_push.ApplyAbsVelocityImpulse(pushforce)
						}
					}
					
					EntFire("behavior_control", "ChangeBotAttributes", "Phase2")
				}
				
				EntFireByHandle(self, "CallScriptFunction", "ExplosionPush", 5.0, null, null)
				
				EntFireByHandle(gamerules_entity, "PlayVO", "mvm/mvm_tele_activate.wav", 7.5, null, null)
				EntFireByHandle(self, "RunScriptCode", "self.GetScriptScope().after_boss_phase_transition = true", 9.0, null, null)
				
				EntFire("spawnbot_single_flag", "Enable", null, 9.0)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "UnhideIcon(`scout_giant`, 2); UnhideIcon(`pyro_flare`, 2); UnhideIcon(`heavy_heater_giant`, 2); UnhideIcon(`pyro_dragon_fury_swordstone`, 25)", 9.0, null, null)
				
				EntFire("phase2_skybeam", "Start", null, 9.0)
			}
		}
		
		if (scope.after_boss_phase_transition && scope.tick % 40 == 0)
		{
			if (Entities.FindByName(null, "phase2_rockets") == null)
			{
				scope.phase2_rocket <- SpawnEntityFromTable("tf_point_weapon_mimic",
				{
					targetname              = "phase2_rockets"
					origin                  = self.GetOrigin() + Vector(0, 0, 150)
					angles                  = QAngle(-90, 0, 0)
					TeamNum                 = 3
					speedmin                = 2000
					speedmax                = 2000
					WeaponType              = 0
					SplashRadius            = 146
					SpreadAngle				= 45
					Damage                  = 90
					crits                   = 1
				})
				
				EntFireByHandle(scope.phase2_rocket, "SetParent", "!activator", -1.0, self, null)
				
				scope.phase2_rocket.SetOwner(self)
			}
			
			else EntFireByHandle(Entities.FindByName(null, "phase2_rockets"), "FireOnce", null, -1.0, self, self)
		}
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_rocket"); )
		{
			if (ent.GetTeam() == 3)
			{	
				ent.ValidateScriptScope()
				local scope = ent.GetScriptScope()
			
				if (!("fixed" in scope))
				{
					scope.fixed <- true
					
					EmitSoundEx(
					{
						sound_name = "MVM.GiantSoldierRocketShoot",
						filter = 5,
						entity = self,
						volume = 1,
						soundlevel = 150,
						flags = 4,
						channel = 6
					})
					
					if (ent.GetOwner().GetClassname() == "tf_point_weapon_mimic") { ent.SetMoveType(5, 0); ent.SetGravity(4) }
				
					EmitSoundEx(
					{
						sound_name = "misc/halloween/spell_fireball_impact.wav",
						filter = 5,
						entity = self,
						volume = 1,
						soundlevel = 150,
						flags = 0,
						channel = 6
					})
					
					ent.SetModelSimple("models/weapons/w_models/w_drg_ball.mdl")

					local fireparticle = SpawnEntityFromTable("trigger_particle",
					{
						attachment_type    = 1
						spawnflags 		   = 64
						particle_name      = "lava_fireball"
					})
					
					EntFireByHandle(fireparticle, "StartTouch", "!activator", -1, ent, ent)
					EntFireByHandle(fireparticle, "Kill", null, -1, null, null)
				}
			}
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}
}

if (!("onetimeactions_performed" in PEA))
{
	PEA.onetimeactions_performed <- true

	PrecacheSound("mvm/mvm_tele_deliver.wav")
	PrecacheSound("misc/halloween/spell_fireball_impact.wav")
	PrecacheSound("misc/rd_finale_beep01.wav")
	
	// NavMesh.GetNavAreaByID(39).Disconnect(NavMesh.GetNavAreaByID(1867))
	// NavMesh.GetNavAreaByID(143).Disconnect(NavMesh.GetNavAreaByID(292))
	// NavMesh.GetNavAreaByID(352).Disconnect(NavMesh.GetNavAreaByID(663))
	// NavMesh.GetNavAreaByID(446).Disconnect(NavMesh.GetNavAreaByID(39))
	// NavMesh.GetNavAreaByID(1018).Disconnect(NavMesh.GetNavAreaByID(682))
	// NavMesh.GetNavAreaByID(1022).Disconnect(NavMesh.GetNavAreaByID(687))
	// NavMesh.GetNavAreaByID(1867).Disconnect(NavMesh.GetNavAreaByID(39))
	// NavMesh.GetNavAreaByID(2358).Disconnect(NavMesh.GetNavAreaByID(292))
	// NavMesh.GetNavAreaByID(2385).Disconnect(NavMesh.GetNavAreaByID(354))
	// NavMesh.GetNavAreaByID(2918).Disconnect(NavMesh.GetNavAreaByID(39))
	// NavMesh.GetNavAreaByID(2937).Disconnect(NavMesh.GetNavAreaByID(1573))
	// NavMesh.GetNavAreaByID(2938).Disconnect(NavMesh.GetNavAreaByID(203))
	// NavMesh.GetNavAreaByID(2939).Disconnect(NavMesh.GetNavAreaByID(203))
	// NavMesh.GetNavAreaByID(2939).Disconnect(NavMesh.GetNavAreaByID(83))
	// NavMesh.GetNavAreaByID(2940).Disconnect(NavMesh.GetNavAreaByID(83))
}

try { IncludeScript("pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

if (Entities.FindByName(null, "nav_avoid_giant") == null) ::SetUpNavFuncs()

ignite_player.AddAttribute("Set DamageType Ignite", 1, -1.0)
Entities.DispatchSpawn(ignite_player)

AssignThinkToThinksTable("HaveDefendersBeenPushed_Think")
AssignThinkToThinksTable("BombCarrierSpawnSpeedUp_Think")
	
for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++) // run this for when the first player connects to the server and the callback hasn't loaded yet
{
	local player = PlayerInstanceFromIndex(i)
	if (player == null) continue
	if (IsPlayerABot(player))
	{
		if (player.GetScriptScope() != null)
		{
			foreach (thing in player.GetScriptScope())
			{
				try { thing.GetClassname() }
				catch (e) { continue }
				
				if (!thing.IsPlayer()) thing.Kill()
			}
		}
		
		AddThinkToEnt(player, null)
		NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")

		player.TerminateScriptScope()
		
		continue
	}
	
	player.ValidateScriptScope()
	local scope = player.GetScriptScope()
	
	if (!("saw_mission_info" in scope)) 
	{
		scope.saw_mission_info <- true
		ClientPrint(player, 4, "For the duration of this mission, certain robots will be spawning from several different locations marked on this map.")
		ClientPrint(player, 3, "\x07FFD700For the duration of this mission, certain robots will be spawning from several different locations marked on this map.")
	}
}

if (Wave == 5) { EntFire("spawnbot_invasion", "Disable"); HideIcon("scout_giant"); HideIcon("pyro_flare"); HideIcon("heavy_heater_giant") }

EntFire("spawnbot_single_flag", "Disable")

for (local ent; ent = Entities.FindByName(ent, "bombpath_left_*"); )
{
	EntityOutputs.RemoveOutput(ent, "OnTrigger", "gamerules", "RunScriptCode", "current_bombpath = `left`")
	EntityOutputs.AddOutput(ent, "OnTrigger", "gamerules", "RunScriptCode", "current_bombpath = `left`", -1.0, -1)
}

for (local ent; ent = Entities.FindByName(ent, "bombpath_right_*"); )
{
	EntityOutputs.RemoveOutput(ent, "OnTrigger", "gamerules", "RunScriptCode", "current_bombpath = `right`")
	EntityOutputs.AddOutput(ent, "OnTrigger", "gamerules", "RunScriptCode", "current_bombpath = `right`", -1.0, -1)
}

if (debug)
{
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "B1"
		font           = 1
		orientation    = 1
		origin         = tele_spot_b1.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "B2"
		font           = 1
		orientation    = 1
		origin         = tele_spot_b2.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "B3"
		font           = 1
		orientation    = 1
		origin         = tele_spot_b3.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "B4"
		font           = 1
		orientation    = 1
		origin         = tele_spot_b4.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "B5"
		font           = 1
		orientation    = 1
		origin         = tele_spot_b5.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "F1"
		font           = 1
		orientation    = 1
		origin         = tele_spot_f1.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "F2"
		font           = 1
		orientation    = 1
		origin         = tele_spot_f2.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "F3"
		font           = 1
		orientation    = 1
		origin         = tele_spot_f3.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
	
	SpawnEntityFromTable("point_worldtext",
	{
		textsize       = 40
		message        = "F4"
		font           = 1
		orientation    = 1
		origin         = tele_spot_f4.GetOrigin() + Vector(0, 0, 100)
		rendermode     = 3
	})
}