::PEA <-
{
	debug_airraid = false
	debug_supplydrop_teles = false
	debug_supplydrop_crates = false
	debug_zeppelin = false
	
	intel_entity = Entities.FindByName(null, "Classic_Mode_Intel")
	
	airraid_dmg_multiplier = 1
	plane_count = 1
	nextplanetime = null

	teledestination_array =
	[
		Vector(-500, 200, -250), Vector(1100, 0, -400), Vector(500, 200, -250), // back
		Vector(-100, -1400, -150), Vector(500, -700, -150), // middle
		Vector(1000, -2000, -400), Vector(-600, -1700, -380) // front
	]

	teleport_status = "disabled"
	
	crate_dropsounds_array = [ "physics/wood/wood_box_break" + RandomInt(1, 2) + ".wav", "physics/wood/wood_crate_break" + RandomInt(1, 5) + ".wav" ]
	
	crateheli_count = 1

	zeppelin = null
	zeppelin_path_train = null
	zeppelin_bomb_deploy_point = null

	cur_zeppelin_tank = 1

	zeppelin_cage_tankprop1 = null
	zeppelin_cage_tankprop2 = null
	zeppelin_cage_tankprop3 = null

	zeppelin_engines_status = "alive, alive, alive"

	zeppelin_cage_tankprop1_teledest = null
	zeppelin_cage_tankprop2_teledest = null
	zeppelin_cage_tankprop3_teledest = null

	zeps_materializing_progress = 1
	zeppelin_crash_frame = 100

	zeppelin_tank_fall_accel_rate = 0
	zeppelin_is_deploying = false
	zeppelin_cur_speed = 40.0
	
	helium_crate_number = 1
	
	helium_locations =
	[
		Vector( 0,    -1000, -175),
		Vector(-500,   250,  -275),
		Vector( 500,   250,  -275),
		Vector(-600,  -1700, -360),
		Vector(-100,  -2600,  0  ),
		Vector( 1000, -2600,  0  ),
		Vector( 400,  -2600, -370),
		Vector( 1100,  0,    -410)
	]

	explosion_soundarray = [ "ambient/explosions/explode_" + RandomInt(1, 5) + ".wav", "ambient/explosions/explode_" + RandomInt(7, 9) + ".wav" ]
	
	tele_spot_back1 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_back1",
		origin        = Vector(-500, 200, -280)
		angles        = QAngle(0, 90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_back1 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_back1"
		origin        	   = Vector(-500, 200, -280)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_back2 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_back2"
		origin        = Vector(1100, 0, -413)
		angles        = QAngle(0, -90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_back2 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_back2"
		origin        	   = Vector(1100, 0, -413)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})
	
	tele_spot_back3 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_back3"
		origin        = Vector(500, 200, -284)
		angles        = QAngle(0, 90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_back3 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_back3"
		origin        	   = Vector(500, 200, -284)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_middle1 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_middle1"
		origin        = Vector(-100, -1400, -182)
		angles        = QAngle(0, 90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_middle1 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_middle1"
		origin        	   = Vector(-100, -1400, -182)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_middle2 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_middle2"
		origin        = Vector(500, -700, -184)
		angles        = QAngle(0, 90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_middle2 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_middle2"
		origin        	   = Vector(500, -700, -184)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_forward1 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_forward1"
		origin        = Vector(1000, -2000, -407)
		angles        = QAngle(0, 90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_forward1 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_forward1"
		origin        	   = Vector(1000, -2000, -407)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	tele_spot_forward2 = SpawnEntityFromTable("prop_dynamic",
	{
		targetname    = "tele_spot_forward2"
		origin        = Vector(-600, -1700, -381)
		angles        = QAngle(0, -90, 0)
		StartDisabled = 1
		model         = "models/props_mvm/robot_spawnpoint.mdl"
		skin          = 1
		DefaultAnim   = "idle"
	})
	
	skybeam_tele_spot_forward2 = SpawnEntityFromTable("info_particle_system",
	{
		targetname    	   = "tele_spot_skybeam_forward2"
		origin             = Vector(-600, -1700, -381)
		angles             = QAngle(0, 90, 0)
		start_active       = 0,
		effect_name        = "teleporter_mvm_bot_persist"
	})

	blimp_path = SpawnEntityGroupFromTable(
	{
		path1 = { path_track = {  origin = Vector(0, -5800, 150), 	targetname = "blimp_path1",  target = "blimp_path2" } },
		path2 = { path_track = {  origin = Vector(800, -5100, 150), targetname = "blimp_path2",  target = "blimp_path3" } },
		path3 = { path_track = {  origin = Vector(800, -2650, 150), targetname = "blimp_path3",  target = "blimp_path4" } },
		path4 = { path_track = {  origin = Vector(0, -2650, 150),   targetname = "blimp_path4",  target = "blimp_path5" } },
		path5 = { path_track = {  origin = Vector(0, 500, 150),   	targetname = "blimp_path5",  target = "blimp_path6" } },
		path6 = { path_track = {  origin = Vector(0, 1450, 450),    targetname = "blimp_path6",  target = "blimp_path7" } },
		path7 = { path_track = {  origin = Vector(0, 1700, 450),    targetname = "blimp_path7"  					    } }
	})
	
	CALLBACKS =
	{
		OnGameEvent_player_spawn = function(params) // VERY IMPORTANT: bot attributes get very fucked up within first moments of its spawn, make sure to delay them to end of frame with "RunScriptCode"
		{	
			local player = GetPlayerFromUserID(params.userid)
			
			if (!player.IsFakeClient())
			{
				if (Wave == 5 && NetProps.GetPropInt(player, "m_Local.m_audio.soundscapeIndex") != 34) NetProps.SetPropInt(player, "m_Local.m_audio.soundscapeIndex", 34)
				
				return
			}
			
			EntFireByHandle(player, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
		}
		
		OnGameEvent_mvm_begin_wave = function(params)
		{
			switch (Wave)
			{
				case 1: HideIcon("scout_jumping"); 	ConvertTankIconsToBlimp(true); 												 break	
				case 2: HideIcon("plane_lite_blu"); HideIcon("soldier"); 					  airraid_dmg_multiplier = 1.4; 	 break
				case 3: HideIcon("teleporter"); 	HideIcon("helicopter_blue_nys_nomiplod"); ConvertTankIconsToBlimp(false, 2); break
				case 4: HideIcon("teleporter"); 	HideIcon("plane_lite_blu"); 			  airraid_dmg_multiplier = 1;   	 break
				case 5:
				{
					HideIcon("demoknight"); HideIcon("pyro")
					NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", 0, 8)
				 	NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount", 73)
					break
				}
			}
		}
	}
	
	AirRaid_Start = function()
	{
		UnhideIcon("plane_lite_blu", 2)
		
		EntFireByHandle(gamerules_entity, "PlayVO", "mvm/ambient_mp3/mvm_siren.mp3", 3.0, null, null)
		
		AssignThinkToThinksTable("AirRaid_SpawnPlaneTemplate_Think")
		AssignThinkToThinksTable("AirRaid_BombControl")
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue;
			if (IsPlayerABot(player)) continue;
			
			EntFireByHandle(player, "SetScriptOverlayMaterial", "airraid_warning_overlay", 0.0, null, null);
			EntFireByHandle(player, "SetScriptOverlayMaterial", "", 8.0, null, null);
		}
	}

	AirRaid_SpawnPlaneTemplate_Think = function()
	{
		if (plane_count < 30 && (nextplanetime == null || thinkertick == nextplanetime))
		{
			local plane = SpawnEntityFromTable("prop_dynamic",
			{
				targetname	  = "plane_model_" + plane_count
				origin        = Vector(RandomInt(-800, 850), -7500, RandomInt(800, 1050))
				angles		  = QAngle(0, 90, 0)
				model         = "models/props_frontline/warhawk.mdl"
				playbackrate  = 1.0
				DefaultAnim	  = "Slow_Spin"
				body          = 1
				skin          = 3
				solid		  = 0
			})
			
			plane.ValidateScriptScope()
			AddThinkToEnt(plane, "AirRaid_Plane_Think")
			
			plane_count = plane_count + 1
			
			nextplanetime = thinkertick + RandomInt(67, 133)
		}
		
		if (plane_count >= 30) RemoveThinkFromThinksTable("AirRaid_SpawnPlaneTemplate_Think")
	}
	
	AirRaid_Plane_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope))
		{
			scope.tick <- 1
			
			scope.height <- self.GetOrigin().z
			
			scope.smoke <- SpawnEntityFromTable("info_particle_system",
			{
				origin             = self.GetOrigin() + Vector(0, 0, 25),
				angles             = self.GetAbsAngles(),
				start_active       = 1,
				effect_name        = "rockettrail"
			})
			
			EntFireByHandle(scope.smoke, "SetParent", "!activator", -1.0, self, null)
			
			scope.sound <- SpawnEntityFromTable("ambient_generic", 
			{
				health       	 = 10
				spawnflags   	 = 0
				radius       	 = 15000
				pitchstart   	 = 100
				pitch        	 = 100
				message      	 = "planesound.wav"
				SourceEntityName = self.GetName()
			})
			
			scope.weapon <- SpawnEntityFromTable("tf_point_weapon_mimic",
			{
				targetname              = "plane_gun"
				origin                  = self.GetOrigin()
				angles                  = self.GetAbsAngles()
				TeamNum                 = 3
				speedmin                = 525
				speedmax                = 525
				WeaponType              = 1
				SplashRadius            = 292
				Damage                  = 25 * airraid_dmg_multiplier
				crits                   = 0
				ModelOverride			= "models/weapons/w_models/w_cannonball.mdl"
				ModelScale				= 1
			})
			
			EntFireByHandle(scope.weapon, "SetParent", "!activator", -1.0, self, null)
			
			scope.weapon.SetOwner(self)
		}
		
		self.SetOrigin(Vector(self.GetOrigin().x, self.GetOrigin().y, scope.height) + Vector(0, 15, 0))
		
		if (scope.tick % 7 == 0)
		{
			for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 100.0); ) player.TakeDamage(1000.0, 64, self)
			ScreenShake(self.GetOrigin(), 16.0, 10.0, 0.5, 1500.0, 0, true)
		}

		if (scope.tick % 22 == 0) EntFireByHandle(scope.weapon, "FireOnce", null, -1.0, null, null)
		
		if (self.GetOrigin().y > 5250.0)
		{
			EntFireByHandle(scope.sound, "StopSound", null, -1.0, null, null)
			
			local other_planes = false
			
			for (local ent; ent = Entities.FindByModel(ent, self.GetModelName()); ) if (ent != self) other_planes = true
			
			if (!other_planes)
			{
				RemoveThinkFromThinksTable("AirRaid_BombControl")
				HideIcon("plane_lite_blu")
			}
			
			self.Kill()
			return 1
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}
	
	AirRaid_BombControl = function()
	{
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_pipe"); )
		{
			if (NetProps.GetPropEntity(ent, "m_hThrower") != null) continue
			
			if (NetProps.GetPropInt(ent, "m_iType") != 3) NetProps.SetPropInt(ent, "m_iType", 3)
		}
	}
	
	/////////////////////////////////// SUPPLY DROP (TELEPORTERS) ///////////////////////////////////

	SupplyDropTeles_Start = function()
	{
		if (debug_supplydrop_teles) ClientPrint(null,3,"supply drop tele initiated\n")
		
		UnhideIcon("teleporter", 2)
		
		EntFireByHandle(gamerules_entity, "PlayVO", "supplydrop_morse.wav", -1.0, null, null)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`back1`, -500, 200)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`back2`, 1100, 0)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`back3`, 500, 200)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`middle1`, -100, -1400)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`middle2`, 500, -700)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`forward1`, 1000, -2000)", RandomFloat(1.0, 5.0), null, null);
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_SpawnHeliTemplate(`forward2`, -600, -1700)", RandomFloat(1.0, 5.0), null, null);
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue;
			if (IsPlayerABot(player)) continue;
			
			AddThinkToEnt(player, "SupplyDropTeles_PlayerInteraction_Think")
			
			EntFireByHandle(player, "SetScriptOverlayMaterial", "supplydrop_tele_warning_overlay", 0.0, null, null);
			EntFireByHandle(player, "SetScriptOverlayMaterial", null, 8.0, null, null);
		}
		
		teleport_status = "inactive"
	}

	SupplyDropTeles_SpawnHeliTemplate = function(num, x, y)
	{
		local teleheli = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "heli_model_" + num
			origin                  = Vector(x, -7500, RandomInt(800, 1050))
			angles		 			= QAngle(0, 90, 0)
			model                   = "models/props_frontline/helicopter.mdl"
			DefaultAnim             = "Fly_idle"
			playbackrate            = 1
			skin                    = 1
		})
		
		teleheli.ValidateScriptScope()
		local teleheli_scope = teleheli.GetScriptScope()
		
		teleheli_scope.drop_point <- y
		teleheli_scope.telecrate_dropped <- false
		
		AddThinkToEnt(teleheli, "TeleHeli_Move_Think")
	}
	
	TeleHeli_Move_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("height" in scope))
		{
			scope.height <- self.GetOrigin().z
			
			scope.sound <- SpawnEntityFromTable("ambient_generic", 
			{
				health       = 10
				spawnflags   = 0
				radius       = 12500
				pitchstart   = 100
				pitch        = 100
				message      = "helisound.wav"
				SourceEntityName = self.GetName()
			})
		}
		
		self.SetOrigin(Vector(self.GetOrigin().x, self.GetOrigin().y, scope.height) + Vector(0, 15, 0))
		
		if (self.GetOrigin().y >= scope.drop_point && !scope.telecrate_dropped)
		{
			scope.telecrate_dropped = true
			
			local telecrate = SpawnEntityFromTable("prop_physics_multiplayer",
			{
				targetname				= "telecrate_" + self.GetName().slice(11)
				origin                  = self.GetOrigin()
				model                   = "models/props_hydro/barrel_crate_half.mdl"
				massscale               = 50
				spawnflags              = 0
			})
			
			telecrate.ValidateScriptScope()
			local cratescope = telecrate.GetScriptScope()
			
			AddThinkToEnt(telecrate, "TeleCrate_Think")
		}
		
		if (self.GetOrigin().y > 5250.0)
		{
			EntFireByHandle(scope.sound, "StopSound", null, -1.0, null, null)
			
			local other_helis = false
			
			for (local ent; ent = Entities.FindByModel(ent, self.GetModelName()); ) if (ent != self) other_helis = true

			if (!other_helis)
			{
				EntFireByHandle(gamerules_entity, "PlayVO", "mvm/mvm_tele_activate.wav", 0.0, null, null)
				
				teleport_status = "active"
			}
			
			self.Kill()
			return 1
		}
		
		return -1
	}
	
	TeleCrate_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope)) scope.tick <- 1
		
		for (local entity_to_crush; entity_to_crush = Entities.FindInSphere(entity_to_crush, self.GetOrigin(), 100); )
		{
			entity_to_crush.TakeDamage(1000.0, 64, self)
		}
		
		if (scope.tick > 133)
		{
			local telespot = Entities.FindByName(null, "tele_spot_" + self.GetName().slice(10))
			
			DispatchParticleEffect("fireSmoke_Collumn_mvmAcres", telespot.GetOrigin(), Vector(0, 90, 0))
			
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue;
				if (IsPlayerABot(player)) continue;
				
				local distvol = 1 - (telespot.GetOrigin() - player.GetOrigin()).Length() / 2500
				
				if (distvol < 0.2) distvol = 0.2
				if (distvol > 1) distvol = 1

				EmitSoundEx({ sound_name = crate_dropsounds_array[RandomInt(0, 1)], entity = player, volume = distvol, filter_type = 5, channel = 6 })
			}
			
			EntFireByHandle(telespot, "RunScriptCode", "self.EnableDraw()", 3.0, null, null)
			
			self.Kill()
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}

	SupplyDropTeles_End = function()
	{
		for (local telespot; telespot = Entities.FindByName(telespot, "tele_spot_*"); )
		{
			if (telespot.GetClassname() == "prop_dynamic") 		 { DispatchParticleEffect("fluidSmokeExpl_ring_mvm", telespot.GetOrigin(), Vector(0, 0, 0)); telespot.DisableDraw() }
			if (telespot.GetClassname() == "info_particle_system") EntFireByHandle(telespot, "Stop", null, -1.0, null, null)
		}
		
		EntFireByHandle(gamerules_entity, "PlayVO", "weapons/teleporter_explode.wav", -1.0, null, null)
		
		HideIcon("teleporter")
		
		teleport_status = "disabled"
	}

	BotTagCheck = function()
	{
		if (self.HasBotTag("blackbox")) self.SetHealth(200)
		
		if (self.HasBotTag("telebot_crate1") || self.HasBotTag("telebot_crate2") || self.HasBotTag("telebot_crate3")) self.SetMoveType(0, 0)
		
		if (self.HasBotTag("end_zep_sequence"))
		{
			self.Teleport(true, Vector(1000, -4000, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			self.TakeDamage(1000.0, 64, null)
		}
		
		if (!self.HasBotTag("telebot")) return
		
		if (!self.HasBotAttribute(32768)) EmitSoundEx({sound_name = "mvm/mvm_tele_deliver.wav", filter = 5, channel = 6, pitch = 100, volume = 0.2})
		
		else
		{
			NetProps.SetPropBool(self, "m_bGlowEnabled", true)
			EntFireByHandle(gamerules_entity, "PlayVO", "mvm/giant_heavy/giant_heavy_entrance.wav", -1.0, null, null)
		}
		
		if (intel_entity.GetOrigin().y <= -2500.0) 											self.Teleport(true, teledestination_array[RandomInt(0, 4)], false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		if (intel_entity.GetOrigin().y > -2500.0 && intel_entity.GetOrigin().y <= -1200.0)  self.Teleport(true, teledestination_array[RandomInt(0, 2)], false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		if (intel_entity.GetOrigin().y > -1200.0) 											self.Teleport(true, teledestination_array[RandomInt(5, 6)], false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		
		EntFireByHandle(self, "CallScriptFunction", "TeleFrag", 0.2, null, null) // smallest comfortable amount of time required by the populator to fill in all of the bot's identity without issues
	}

	/////////////////////////////////// SUPPLY DROP (TELEPORTERS) ///////////////////////////////////
	
	/////////////////////////////////// SUPPLY DROP (GIANT CRATES) ///////////////////////////////////

	SupplyDropCrates_Start = function()
	{
		if (debug_supplydrop_crates) ClientPrint(null,3,"supply drop crate initiated\n")
		
		EntFireByHandle(gamerules_entity, "PlayVO", "supplydrop_morse.wav", 0.0, null, null)
		
		UnhideIcon("helicopter_blue_nys_nomiplod", 2)
		
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "SupplyDropCrates_SpawnHeliTemplate", RandomFloat(1.0, 2.0), null, null);
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "SupplyDropCrates_SpawnHeliTemplate", RandomFloat(3.0, 4.0), null, null);
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "SupplyDropCrates_SpawnHeliTemplate", RandomFloat(5.0, 6.0), null, null);
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue;
			if (IsPlayerABot(player)) continue;

			EntFireByHandle(player, "SetScriptOverlayMaterial", "supplydrop_crate_warning_overlay", 0.0, null, null);
			EntFireByHandle(player, "SetScriptOverlayMaterial", "", 8.0, null, null);
		}
	}

	SupplyDropCrates_SpawnHeliTemplate = function()
	{
		if (debug_supplydrop_crates) ClientPrint(null,3,"tele heli spawned\n")
		
		local crateheli = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "crateheli_model_" + crateheli_count
			origin                  = Vector(0, -7500, RandomInt(800, 1050))
			angles		 			= QAngle(0, 90, 0)
			model                   = "models/props_frontline/helicopter.mdl"
			DefaultAnim             = "Fly_idle"
			playbackrate            = 1
			skin                    = 1
		})
		
		crateheli.ValidateScriptScope()
		local crateheli_scope = crateheli.GetScriptScope()
		
		switch (crateheli_count)
		{
			case 1: crateheli_scope.drop_point <- -3500; break
			case 2: crateheli_scope.drop_point <- -2000; break
			case 3: crateheli_scope.drop_point <- -1000; break
		}
		
		crateheli_scope.crate_dropped <- false
		
		AddThinkToEnt(crateheli, "CrateHeli_Move_Think")
		
		crateheli_count = crateheli_count + 1
	}
	
	CrateHeli_Move_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("height" in scope))
		{
			scope.height <- self.GetOrigin().z
			
			scope.sound <- SpawnEntityFromTable("ambient_generic", 
			{
				health       = 10
				spawnflags   = 0
				radius       = 12500
				pitchstart   = 100
				pitch        = 100
				message      = "helisound.wav"
				SourceEntityName = self.GetName()
			})
		}
		
		self.SetOrigin(Vector(self.GetOrigin().x, self.GetOrigin().y, scope.height) + Vector(0, 15, 0))
		
		if (self.GetOrigin().y >= scope.drop_point && !scope.crate_dropped)
		{
			scope.crate_dropped = true
			
			local crate = SpawnEntityFromTable("prop_physics_multiplayer",
			{
				targetname				= "giantcrate_" + self.GetName().slice(16)
				origin                  = self.GetOrigin()
				model                   = "models/props_hydro/barrel_crate.mdl"
				massscale               = 50
				modelscale				= 1.5
				spawnflags              = 4
			})
			
			AddThinkToEnt(crate, "GiantCrate_Think")
		}
		
		if (self.GetOrigin().y >= 5250.0)
		{
			EntFireByHandle(scope.sound, "StopSound", null, -1.0, null, null)
			
			self.Kill()
			return 1
		}
		
		return -1
	}
	
	GiantCrate_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope)) scope.tick <- 1
		
		for (local entity_to_crush; entity_to_crush = Entities.FindInSphere(entity_to_crush, self.GetOrigin(), 100); )
		{
			entity_to_crush.TakeDamage(1000.0, 64, self)
		}
		
		if (scope.tick >= 133)
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue;
				if (IsPlayerABot(player)) continue;
				
				local distvol = 1 - (self.GetOrigin() - player.GetOrigin()).Length() / 2500
				
				if (distvol < 0.2) distvol = 0.2
				if (distvol > 1) distvol = 1

				EmitSoundEx({ sound_name = crate_dropsounds_array[RandomInt(0, 1)], entity = player, volume = distvol, filter_type = 5, channel = 6 })
			}
			
			for (local giant_to_teleport; giant_to_teleport = Entities.FindByClassname(giant_to_teleport, "player"); )
			{
				if (giant_to_teleport == null) continue;
				if (!giant_to_teleport.IsFakeClient()) continue
				
				if (giant_to_teleport.HasBotTag("telebot_crate" + self.GetName().slice(11)))
				{
					giant_to_teleport.SetMoveType(2, 0)
					
					NetProps.SetPropBool(giant_to_teleport, "m_bGlowEnabled", true)
					giant_to_teleport.AddBotAttribute(8)
					EntFireByHandle(giant_to_teleport, "RunScriptCode", "self.RemoveBotAttribute(8)", 2.5, null, null)
					
					giant_to_teleport.Teleport(true, self.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
					
					EntFireByHandle(giant_to_teleport, "CallScriptFunction", "TeleFrag", 0.2, null, null) // smallest comfortable amount of time required by the populator to fill in all of the bot's identity without issues
				}
			}
			
			self.Kill()
			return 1
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}

	/////////////////////////////////// SUPPLY DROP (GIANT CRATES) ///////////////////////////////////
	
	Zeppelin_Start = function()
	{	
		if (debug_zeppelin) ClientPrint(null,3,"zeppelin spawned")
		
		AssignThinkToThinksTable("Zeppelin_SpawnHeliumCrates_Think")
		
		zeppelin_bomb_deploy_point = SpawnEntityFromTable("path_track", 
		{
			origin 		 = Vector(0, 1400, 1300),
			targetname   = "zeppelin_train_drop_point",
			speed        = zeppelin_cur_speed
		})
		
		local zeppelin_path_2 = SpawnEntityFromTable("path_track", 
		{
			origin 		 = Vector(0, -6000, 1300),
			targetname   = "zeppelin_train_spawn_point",
			target       = "zeppelin_train_drop_point",
			speed        = zeppelin_cur_speed
		})
		
		zeppelin_path_train = SpawnEntityFromTable("func_tracktrain", 
		{
			targetname   = "zeppelin_pathtrain"
			target       = "zeppelin_train_spawn_point",
			startspeed   = zeppelin_cur_speed,
			speed        = zeppelin_cur_speed,
			origin       = Vector(0, -6000, 1300)
		})
		
		zeppelin = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_model"
			origin       = Vector(0, -6000, 1300)
			model        = "models/props_frontline/zeppelin_skybox.mdl",
			DefaultAnim  = "idle",
			playbackrate = 1,
			modelscale   = 10,
			skin         = 1,
			rendermode   = 1,
			renderamt    = 0.0
		})
		
		local zeppelin_sound_source = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_sound_source"
			model        = "models/props_hydro/barrel_crate_half.mdl"
			modelscale   = 0.001
			origin       = Vector(-1000, -6000, 1100)
		})
		
		local zeppelin_sound = SpawnEntityFromTable("ambient_generic", 
		{
			targetname   = "zeppelin_sound"
			health       = 10
			spawnflags   = 0
			radius       = 12500
			pitchstart   = 100
			pitch        = 100
			message      = "zeppelinsound.wav"
			SourceEntityName = "zeppelin_cage_model_sound_source"
		})
		
		local zeppelin_rotor_smoke_s2 = SpawnEntityFromTable("info_particle_system",
		{
			targetname         = "zeppelin_cage_model_rotor_smoke_s2"
			origin             = Vector(-1000, -6000, 1250)
			angles             = QAngle(0, 180, 0)
			start_active       = 0,
			effect_name        = "rockettrail_vents_doomsday"
		})
		
		local zeppelin_rotor_smoke_s3 = SpawnEntityFromTable("info_particle_system",
		{
			targetname         = "zeppelin_cage_model_rotor_smoke_s3"
			origin             = Vector(-1100, -6000, 1200)
			angles             = QAngle(0, 180, 0)
			start_active       = 0,
			effect_name        = "lava_fireball"
		})
		
		EntityOutputs.AddOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "PlayVO", "vo/mvm_bomb_alerts0" + RandomInt(6,7) + ".mp3", 1.0, -1)
		EntityOutputs.AddOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "PlayVO", "mvm/mvm_tank_deploy.wav", 0.0, -1)
		
		EntityOutputs.AddOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "RunScriptCode", "zeppelin_is_deploying = true", 0.0, -1)
		EntityOutputs.AddOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "RunScriptCode", "zeppelin_is_deploying = false", 10.0, -1)
		
		EntityOutputs.AddOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "CallScriptFunction", "Zeppelin_BombDeployCheck", 5.5, -1)
		
		AddThinkToEnt(zeppelin, "Zeppelin_Materialize_Think")
		
		EntFireByHandle(gamerules_entity, "PlayVO", "zeppelinspawn.wav", 0.0, null, null)
		
		////////////////// (CAGE FLOOR)
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s1_floor"
			origin       = Vector(768, -6128, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 90),
			solid        = 6
		})
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s1_floor"
			origin       = Vector(768, -5872, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, -90),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s2_floor"
			origin       = Vector(256, -6128, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 90),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s2_floor"
			origin       = Vector(256, -5872, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, -90),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3_floor"
			origin       = Vector(-256, -6128, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 90),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3_floor"
			origin       = Vector(-256, -5872, 900)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, -90),
			solid        = 6
		})
		
		////////////////// (LEFT CAGE WALL)
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s1"
			origin       = Vector(256, -6293, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s1"
			origin       = Vector(256, -6293, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s2"
			origin       = Vector(-256, -6293, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s2"
			origin       = Vector(-256, -6293, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		////////////////// (RIGHT CAGE WALL)
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s1"
			origin       = Vector(256, -5713, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s1"
			origin       = Vector(256, -5713, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s2"
			origin       = Vector(-256, -5713, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_wall_s2"
			origin       = Vector(-256, -5713, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 0, 180),
			solid        = 6
		})
		
		////////////////// (FRONT, MIDDLE, AND BACK CAGE WALLS)
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s1"
			origin       = Vector(798, -5778, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s1"
			origin       = Vector(798, -5778, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s2"
			origin       = Vector(286, -5778, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s2"
			origin       = Vector(286, -5778, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3"
			origin       = Vector(-226, -5778, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3"
			origin       = Vector(-226, -5778, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3"
			origin       = Vector(-738, -5778, 1050)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		local zeppelin_cage_s3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3"
			origin       = Vector(-738, -5778, 1306)
			model        = "models/props_gameplay/security_fence512.mdl"
			angles       = QAngle(0, 90, 180),
			solid        = 6
		})
		
		////////////////// (CAGE TANK PROPS)
		
		zeppelin_cage_tankprop1 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s1_tankprop"
			origin       = Vector(536, -6008, 910)
			model        = "models/bots/boss_bot/boss_tank.mdl"
			angles       = QAngle(0, 0, 0)
		})
		
		zeppelin_cage_tankprop2 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s2_tankprop"
			origin       = Vector(24, -6008, 910)
			model        = "models/bots/boss_bot/boss_tank.mdl"
			angles       = QAngle(0, 0, 0)
		})
		
		zeppelin_cage_tankprop3 = SpawnEntityFromTable("prop_dynamic", 
		{
			targetname   = "zeppelin_cage_model_s3_tankprop"
			origin       = Vector(-488, -6008, 910)
			model        = "models/bots/boss_bot/boss_tank.mdl"
			angles       = QAngle(0, 0, 0)
			skin         = 1
		})
		
		zeppelin_cage_tankprop1_teledest = SpawnEntityFromTable("info_target", 
		{
			targetname   = "zeppelin_cage_model_s1_teledest"
			origin       = Vector(536, -6008, 920)
		})
		
		zeppelin_cage_tankprop2_teledest = SpawnEntityFromTable("info_target", 
		{
			targetname   = "zeppelin_cage_model_s2_teledest"
			origin       = Vector(24, -6008, 920)
		})
		
		zeppelin_cage_tankprop3_teledest = SpawnEntityFromTable("info_target", 
		{
			targetname   = "zeppelin_cage_model_s3_teledest"
			origin       = Vector(-488, -6008, 920)
		})
		
		EntFire("zeppelin_model", "SetParent", "zeppelin_pathtrain")
		EntFire("zeppelin_cage_model*", "SetParent", "zeppelin_model")
	}

	Zeppelin_Materialize_Think = function()
	{
		self.KeyValueFromFloat("renderamt", zeps_materializing_progress)
		
		zeps_materializing_progress = zeps_materializing_progress + 0.8
		
		if (zeps_materializing_progress > 254)
		{
			self.KeyValueFromInt("rendermode", 0)
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "");
		}
		
		return -1
	}

	Zeppelin_ParentTank = function()
	{
		local zeptank = Entities.FindByName(null, "zeppelin_engine_" + cur_zeppelin_tank + "_destructible")
		
		if (zeptank == null) // fix rare issue where tank fails to spawn if the BLU team limit is reached
		{
			for (local player; player = Entities.FindByClassname(player, "player"); )
			{
				if (player == null) continue
				if (player.IsFakeClient() && player.GetTeam() == 3)
				{
					player.TakeDamage(10000.0, 64, null)
					player.ForceChangeTeam(1, true)
					EntFireByHandle(gamerules_entity, "CallScriptFunction", "Zeppelin_ParentTank", 0.1, null, null)
					break
				}
			}
			
			return
		}
		
		if (cur_zeppelin_tank == 1) zeppelin_cage_tankprop1.DisableDraw()
		if (cur_zeppelin_tank == 2) { EntFire("zeppelin_cage_model_wall_s1", "Kill"); zeppelin_cage_tankprop2.DisableDraw() }
		if (cur_zeppelin_tank == 3) { EntFire("zeppelin_cage_model_wall_s2", "Kill"); zeppelin_cage_tankprop3.DisableDraw() }
		
		AddThinkToEnt(zeptank, "ZeppelinTank_Move_Think")
		
		EntityOutputs.AddOutput(zeptank, "OnKilled", "gamerules", "CallScriptFunction", "Zeppelin_DestroyCageStage", -1.0, -1.0)
	}
	
	ZeppelinTank_Move_Think = function()
	{
		switch (cur_zeppelin_tank)
		{
			case 1: self.SetOrigin(zeppelin_cage_tankprop1.GetOrigin()); break
			case 2: self.SetOrigin(zeppelin_cage_tankprop2.GetOrigin()); break
			case 3: self.SetOrigin(zeppelin_cage_tankprop3.GetOrigin()); break
		}
		
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank.mdl") 		 NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage1.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage1.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage2.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage2.mdl"), 3)
		if (self.GetModelName() == "models/bots/boss_bot/boss_tank_damage3.mdl") NetProps.SetPropIntArray(self, "m_nModelIndexOverrides", PrecacheModel("models/bots/boss_bot/boss_tank_damage3.mdl"), 3)
		
		local child_array = []
		
		for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer()) child_array.append(child)
		
		foreach (child in child_array) NetProps.SetPropIntArray(child, "m_nModelIndexOverrides", NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 0), 3)
		
		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 250.0); )
		{
			if (player == null) continue
			
			local selfmins = self.GetBoundingMins() + self.GetOrigin() - Vector(2, 2, 2)
			local selfmaxs = self.GetBoundingMaxs() + self.GetOrigin() + Vector(2, 2, 2)

			local playermins = player.GetBoundingMins() + player.GetOrigin()
			local playermaxs = player.GetBoundingMaxs() + player.GetOrigin()

			if (playermins.x > selfmaxs.x || playermaxs.x < selfmins.x || playermins.y > selfmaxs.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermins.z > selfmaxs.z || playermaxs.z < selfmins.z) break
			else
			{
				local pushforce = player.GetOrigin() - self.GetOrigin()
				pushforce.Norm()
				pushforce.z = 0.5
				pushforce = pushforce * 50

				player.RemoveFlag(1)
				player.AddCond(115)
				player.ApplyAbsVelocityImpulse(pushforce)
			}
		}
		
		self.SetAbsAngles(QAngle(0, 90, 0))
		self.GetLocomotionInterface().Reset()
		return -1
	}

	Zeppelin_DestroyCageStage = function()
	{
		if (debug_zeppelin) ClientPrint(null,3,"function ran")
		
		EntFire("zeppelin_cage_model_s" + cur_zeppelin_tank + "*", "Kill")
		
		switch (cur_zeppelin_tank)
		{
			case 1:
			{
				zeppelin_cage_tankprop1.Kill()
				
				zeppelin_engines_status = "dead, alive, alive"
				
				zeppelin_bomb_deploy_point.KeyValueFromVector("origin", zeppelin_bomb_deploy_point.GetOrigin() + Vector(0, 512, 0))
				
				AddThinkToEnt(zeppelin, "Zeppelin_DescendStage1_Think")
				
				EntFire("zeppelin_model", "SetPlaybackRate", 0.8)
				EntFire("zeppelin_pathtrain", "SetSpeedReal", 32.0)
				EntFire("zeppelin_cage_model_rotor_smoke_s2", "Start")
				EntFire("zeppelin_sound", "Pitch", 75)
				
				zeppelin_cur_speed = 32.0
				break
			}
			
			case 2:
			{
				zeppelin_cage_tankprop2.Kill()
				
				zeppelin_engines_status = "dead, dead, alive"
				
				zeppelin_bomb_deploy_point.KeyValueFromVector("origin", zeppelin_bomb_deploy_point.GetOrigin() + Vector(0, 512, 0))
				
				AddThinkToEnt(zeppelin, "Zeppelin_DescendStage2_Think")
				
				EntFire("zeppelin_model", "SetPlaybackRate", 0.6)
				EntFire("zeppelin_pathtrain", "SetSpeedReal", 24.0)
				EntFire("zeppelin_cage_model_rotor_smoke_s2", "Stop")
				EntFire("zeppelin_cage_model_rotor_smoke_s3", "Start")
				EntFire("zeppelin_sound", "Pitch", 50)
				
				zeppelin_cur_speed = 24.0
				break
			}
			
			case 3:
			{
				zeppelin_cage_tankprop3.Kill()
				
				zeppelin_engines_status = "dead, dead, dead"
				
				AddThinkToEnt(zeppelin, "Zeppelin_CrashingSequence_Think")
				
				EntityOutputs.RemoveOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "PlayVO", "vo/mvm_bomb_alerts06.mp3")
				EntityOutputs.RemoveOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "PlayVO", "vo/mvm_bomb_alerts07.mp3")
				EntityOutputs.RemoveOutput(zeppelin_bomb_deploy_point, "OnPass", "gamerules", "PlayVO", "mvm/mvm_tank_deploy.wav")
				
				for (local player_to_flash; player_to_flash = Entities.FindByClassnameWithin(player_to_flash, "player", zeppelin.GetOrigin(), 3000); )
				{
					if (player_to_flash == null) continue;
					if (IsPlayerABot(player_to_flash)) continue;
					
					ScreenFade(player_to_flash, 255, 140, 0, 50, 27.0, 0.0, 2)
				}
				
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 100, filter_type = 5})", 0.0, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 105, filter_type = 5})", 2.75, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 110, filter_type = 5})", 5.5, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 115, filter_type = 5})", 8.25, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 120, filter_type = 4})", 11.0, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 125, filter_type = 5})", 13.75, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 130, filter_type = 5})", 16.5, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 135, filter_type = 5})", 19.25, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 140, filter_type = 5})", 22.0, null, null)
				
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 100, volume = 0.5, filter_type = 5})", 0.0, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 105, volume = 0.5, filter_type = 5})", 2.75, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 110, volume = 0.5, filter_type = 5})", 5.5, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 115, volume = 0.5, filter_type = 5})", 8.25, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 120, volume = 0.5, filter_type = 5})", 11.0, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 125, volume = 0.5, filter_type = 5})", 13.75, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 130, volume = 0.5, filter_type = 5})", 16.5, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 135, volume = 0.5, filter_type = 5})", 19.25, null, null)
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `ambient/alarms/doomsday_lift_alarm.wav`, channel = 6, pitch = 140, volume = 0.5, filter_type = 5})", 22.0, null, null)
				
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					
					if (player == null) continue;
					if (IsPlayerABot(player))
					{
						player.AddCustomAttribute("cannot pick up intelligence", 1.0, -1.0)
						player.DropFlag(true)
						player.AddBotAttribute(8)
						continue
					}
					else
					{
						player.RemoveCondEx(107, true)
						player.RemoveCustomAttribute("voice pitch scale")
					}
				}
				
				EntFire("helium_crate*", "Kill")
				EntFire("crate_glow*", "Kill")
				break
			}
		}
		
		if (cur_zeppelin_tank < 3) cur_zeppelin_tank = cur_zeppelin_tank + 1
	}

	Zeppelin_DescendStage1_Think = function()
	{
		if (self.GetOrigin().z > 1250)
		{
			self.KeyValueFromVector("origin", self.GetOrigin() + Vector (0, 0, -0.1))
		}
		if (self.GetOrigin().z < 1250)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "");
		}
		return -1
	}

	Zeppelin_DescendStage2_Think = function()
	{
		if (self.GetOrigin().z > 1200)
		{
			self.KeyValueFromVector("origin", self.GetOrigin() + Vector (0, 0, -0.1))
		}
		if (self.GetOrigin().z < 1200)
		{
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "");
		}
		return -1
	}

	Zeppelin_CrashingSequence_Think = function()
	{
		local x = RandomInt(-500, 500)
		local y = RandomInt(-1500, 1500)
		
		if (debug_zeppelin) ClientPrint(null,3,"" + self.GetOrigin());
		
		zeppelin_crash_frame = zeppelin_crash_frame + 1
		
		if (self.GetOrigin().z >= 0.0)
		{
			zeppelin.KeyValueFromVector("origin", self.GetOrigin() + Vector (0, 0, -0.8))
			zeppelin.SetAbsAngles(self.GetAngles() + QAngle(0.01, 0, 0))
		}
		
		if (zeppelin_crash_frame % 25 == 0)
		{
			DispatchParticleEffect("fluidSmokeExpl_ring_mvm", self.GetOrigin() + Vector(x, y, x), Vector(0, 0, 0))
			EmitSoundEx({sound_name = explosion_soundarray[RandomInt(0, 1)], channel = 6, pitch = 100, filter_type = 5})
		}
		
		if (self.GetOrigin().z < 100.0)
		{
			for (local player_to_flash; player_to_flash = Entities.FindByClassname(player_to_flash, "player"); )
			{
				if (player_to_flash == null) continue;
				if (IsPlayerABot(player_to_flash)) continue;
				
				EntFireByHandle(player_to_flash, "RunScriptCode", "ScreenFade(self, 255, 140, 0, 255, 1.0, 0.0, 2)", 0.0, null, null)
				EntFireByHandle(player_to_flash, "RunScriptCode", "ScreenFade(self, 255, 140, 0, 255, 5.0, 0.0, 1)", 1.0, null, null)
			}
			
			EntFire("zeppelin_sound", "StopSound", null, 0.0)
		}
		
		if (self.GetOrigin().z < 0.0)
		{	
			EntFire("zeppelin_sound", "StopSound", null, 0.0)
			
			EmitSoundEx({sound_name = "ambient/explosions/explode_6.wav", channel = 6, pitch = 100, filter_type = 5})
			EmitSoundEx({sound_name = "ambient/explosions/explode_6.wav", channel = 6, pitch = 100, filter_type = 5})
			
			for (local player_to_hurt; player_to_hurt = Entities.FindInSphere(player_to_hurt, self.GetOrigin(), 3000.0); )
			{
				if (player_to_hurt == null) continue
				if (player_to_hurt.GetClassname() == "player" && NetProps.GetPropInt(player_to_hurt, "m_lifeState") != 0) continue
				
				player_to_hurt.TakeDamage(10000.0, 64, self)
			}
			
			SpawnEntityFromTable("info_particle_system",
			{
				origin             = zeppelin.GetOrigin() + Vector(0, 1500, -300)
				start_active       = 1,
				effect_name        = "base_destroyed_smoke_doomsday"
			})
			
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local bot_to_depacify = PlayerInstanceFromIndex(i)
				
				if (bot_to_depacify == null) continue;
				if (!IsPlayerABot(bot_to_depacify)) continue;
				
				bot_to_depacify.RemoveCustomAttribute("cannot pick up intelligence")
				bot_to_depacify.RemoveBotAttribute(8)
			}
			
			EntFire("spawnbot_invasion", "Enable")
			
			self.Kill()
		}
		
		return -1
	}

	Zeppelin_BombDeployCheck = function()
	{
		if (debug_zeppelin) ClientPrint(null,3,"" + zeppelin_path_train.GetVelocity())
		
		zeppelin_tank_fall_accel_rate = 0
		
		if (zeppelin_engines_status == "alive, alive, alive" && zeppelin_path_train.GetVelocity().y == 0.0)
		{
			EntFire("zeppelin_cage_model_s1_floor", "Kill")
			
			AddThinkToEnt(zeppelin_cage_tankprop1, "Zeppelin_DropTankIntoHatch_Think")
			EntFireByHandle(gamerules_entity, "PlayVO", "physics/metal/metal_chainlink_impact_hard" + RandomInt(1,3) + ".wav", 0.0, null, null)
		}
		if (zeppelin_engines_status == "dead, alive, alive" && zeppelin_path_train.GetVelocity().y == 0.0)
		{
			EntFire("zeppelin_cage_model_s2_floor", "Kill")
			
			AddThinkToEnt(zeppelin_cage_tankprop2, "Zeppelin_DropTankIntoHatch_Think")
			EntFireByHandle(gamerules_entity, "PlayVO", "physics/metal/metal_chainlink_impact_hard" + RandomInt(1,3) + ".wav", 0.0, null, null)
		}
		if (zeppelin_engines_status == "dead, dead, alive" && zeppelin_path_train.GetVelocity().y == 0.0)
		{
			EntFire("zeppelin_cage_model_s3_floor", "Kill")
			
			AddThinkToEnt(zeppelin_cage_tankprop3, "Zeppelin_DropTankIntoHatch_Think")
			EntFireByHandle(gamerules_entity, "PlayVO", "physics/metal/metal_chainlink_impact_hard" + RandomInt(1,3) + ".wav", 0.0, null, null)
		}
		
	}

	Zeppelin_DropTankIntoHatch_Think = function()
	{
		if (self.GetOrigin().z >= -400.0)
		{
			zeppelin_tank_fall_accel_rate = zeppelin_tank_fall_accel_rate - 0.15
			
			self.KeyValueFromVector("origin", self.GetOrigin() + Vector (0, 0, zeppelin_tank_fall_accel_rate))
		}
		if (self.GetOrigin().z < -400.0)
		{
			EntFire("boss_deploy_relay", "Trigger")
			self.Kill()
			EntFire("zeppelin_engine_" + cur_zeppelin_tank + "_destructible", "Kill")
		}
		
		return -1
	}

	Zeppelin_SpawnHeliumCrates_Think = function()
	{
		if (thinkertick % 533 != 0) return
		
		if (debug_zeppelin) ClientPrint(null,3,"spawn helium think active\n");
		
		if (zeppelin_engines_status == "dead, dead, dead" || helium_locations.len() == 0) return

		local number_pick = RandomInt(0, helium_locations.len() - 1)
		local origin_pick = helium_locations[number_pick]
		
		local helium_crate = SpawnEntityFromTable("prop_dynamic",
		{
			origin  = origin_pick
			model   = "models/props_hydro/barrel_crate_half.mdl"
		})
		
		AddThinkToEnt(helium_crate, "HeliumCrate_Think")
		
		if (helium_crate_number == 3)
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue;
				if (IsPlayerABot(player)) continue;
				
				EntFireByHandle(player, "SetScriptOverlayMaterial", "zeppelin_fight_tip_overlay", -1.0, null, null);
				EntFireByHandle(player, "SetScriptOverlayMaterial", "", 8.0, null, null);
			}
		}
		
		if (helium_crate_number >= 3 && helium_crate_number <= 5)
		{
			SendGlobalGameEvent("show_annotation", 
			{
				text = "Helium crate!"
				worldPosX = origin_pick.x
				worldPosY = origin_pick.y
				worldPosZ = origin_pick.z
				play_sound = "misc/null.wav"
				show_distance = true
				show_effect = true
				lifetime = 5
			})
		}
		
		helium_crate_number = helium_crate_number + 1
		
		helium_locations.remove(number_pick)
	}
	
	HeliumCrate_Think = function()
	{
		local scope = self.GetScriptScope()
		
		self.SetAbsAngles(self.GetAngles() + QAngle(0, 1, 0))
		
		if (!("glow" in scope))
		{
			self.KeyValueFromString("targetname", "heliumcrate")
			
			scope.glow <- SpawnEntityFromTable("tf_glow",
			{
				target    = "heliumcrate"
				GlowColor = "184 56 59 255"
			})
			
			self.KeyValueFromString("targetname", "")
		}
		
		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 64.0); )
		{
			if (player.GetTeam() != 2) return
			
			player.AddCustomAttribute("voice pitch scale", 2, -1.0)
			EntFireByHandle(player, "RunScriptCode", "self.RemoveCustomAttribute(`voice pitch scale`)", 12.0, null, null)
			
			player.ApplyAbsVelocityImpulse(Vector(0, 0, 800))
			player.AddCondEx(107, 12.0, self)
			
			player.ValidateScriptScope()
			local scope = player.GetScriptScope()
			
			if (!("saw_helium_tutorial" in scope)) 
			{
				scope.saw_helium_tutorial <- true
				ClientPrint(self, 4, "Hold the JUMP button to float upwards!")
			}
			
			helium_locations.append(self.GetOrigin())
			
			self.Kill()
			return 1
		}
		
		return -1
	}

	/////////////////////////////////// ZEPPELIN BOSS ///////////////////////////////////
	/////////////////////////////////// MISCELLANEOUS ///////////////////////////////////

	HaveDefendersBeenPushed_Think = function()
	{
		// ClientPrint(null,3,"" + teleport_status)
		
		if (thinkertick % 7 != 0) return
		
		if (teleport_status == "disabled") return
		if (teleport_status == "inactive")
		{
			for (local ent; ent = Entities.FindByName(ent, "tele_spot_*"); )
			{
				if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 2)
				if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 0.0)
				if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Stop", null, -1.0, null, null)
			}
			
			for (local ent; ent = Entities.FindByName(ent, "skybeam_*"); ) EntFireByHandle(ent, "Stop", null, -1.0, null, null)
		}
		
		if (teleport_status == "active")
		{
			for (local ent; ent = Entities.FindByName(ent, "tele_spot_*"); )
			{
				if (intel_entity.GetOrigin().y < -2500.0)
				{	
					if (ent.GetName().find("forward") != null)
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 2)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 0.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Stop", null, -1.0, null, null)
					}
					
					else
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 1)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 1.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Start", null, -1.0, null, null)
					}
					
					// ClientPrint(null,3,"not pushed/n");
				}
				
				else if (intel_entity.GetOrigin().y < -1200.0)
				{
					if (ent.GetName().find("back") != null)
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 1)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 1.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Start", null, -1.0, null, null)
					}
					
					else
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 2)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 0.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Stop", null, -1.0, null, null)
					}
					
					// ClientPrint(null,3,"pushed to tunnel/n");
				}
				
				else
				{
					if (ent.GetName().find("forward") != null)
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 1)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 1.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Start", null, -1.0, null, null)
					}
					
					else
					{
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropInt(ent, "m_nSkin", 2)
						if (ent.GetClassname() == "prop_dynamic") NetProps.SetPropFloat(ent, "m_flPlaybackRate", 0.0)
						if (ent.GetClassname() == "info_particle_system") EntFireByHandle(ent, "Stop", null, -1.0, null, null)
					}
					
					// ClientPrint(null,3,"pushed to incline/n");
				}
			}
		}
	}

	TeleFrag = function()
	{
		for (local entity_to_telefrag; entity_to_telefrag = Entities.FindInSphere(entity_to_telefrag, self.GetOrigin(), 100); )
		{
			if (entity_to_telefrag.GetTeam() == 2)
			{
				entity_to_telefrag.TakeDamage(1000.0, 64, self)
			}
		}
	}

	SetUpRain = function()
	{	
		for (local ent; ent = Entities.FindByClassname(ent, "env_soundscape"); ) EntFireByHandle(ent, "Disable", null, -1.0, null, null)
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			
			NetProps.SetPropInt(player, "m_Local.m_audio.soundscapeIndex", 34)
		}
		
		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, 2400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, 1900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, 1400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, 900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, 400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -1100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -1600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -2100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -2600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -3100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(-500, -3600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, 2400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, 1900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, 1400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, 900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, 400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -1100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -1600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -2100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -2600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -3100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(100, -3600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, 1900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, 1400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, 900, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, 400, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -1100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -1600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -2100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -2600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -3100, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("info_particle_system", 
		{
			origin       = Vector(700, -3600, 1000)
			start_active = 1
			effect_name  = "env_rain_001"
		})

		SpawnEntityFromTable("color_correction", 
		{
			StartDisabled    = 0
			maxfalloff       = -1
			minfalloff       = -1
			filename         = "download/darker_color_correction.raw"
		}) 
	}
}

try { IncludeScript("pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

if (!("onetimeactions_performed" in PEA))
{
	PEA["onetimeactions_performed"] <- true
	getroottable()["onetimeactions_performed"] <- PEA["onetimeactions_performed"]
	
	NavMesh.GetNavAreaByID(582).Disconnect(NavMesh.GetNavAreaByID(79))
	NavMesh.GetNavAreaByID(582).Disconnect(NavMesh.GetNavAreaByID(275))
	NavMesh.GetNavAreaByID(582).Disconnect(NavMesh.GetNavAreaByID(3131))
	
	NavMesh.GetNavAreaByID(3131).Disconnect(NavMesh.GetNavAreaByID(582))

	PrecacheSound("mvm/mvm_tele_deliver.wav")
	PrecacheSound("ambient/alarms/doomsday_lift_alarm.wav")
	
	PrecacheSound("physics/wood/wood_box_break1.wav")
	PrecacheSound("physics/wood/wood_box_break2.wav")
	
	PrecacheSound("physics/wood/wood_crate_break1.wav")
	PrecacheSound("physics/wood/wood_crate_break2.wav")
	PrecacheSound("physics/wood/wood_crate_break3.wav")
	PrecacheSound("physics/wood/wood_crate_break4.wav")
	PrecacheSound("physics/wood/wood_crate_break5.wav")
	
	PrecacheSound("ambient/explosions/explode_1.wav")
	PrecacheSound("ambient/explosions/explode_2.wav")
	PrecacheSound("ambient/explosions/explode_3.wav")
	PrecacheSound("ambient/explosions/explode_4.wav")
	PrecacheSound("ambient/explosions/explode_5.wav")
	PrecacheSound("ambient/explosions/explode_7.wav")
	PrecacheSound("ambient/explosions/explode_8.wav")
	PrecacheSound("ambient/explosions/explode_9.wav")
	
	PrecacheSound("planesound.wav")
	PrecacheSound("helisound.wav")
	PrecacheSound("supplydrop_morse.wav")
	PrecacheSound("zeppelinsound.wav")
	PrecacheSound("zeppelinspawn.wav")
	PrecacheSound("teleporter_spin3_fade.wav")
	PrecacheSound("teleporter_spin3_fade.wav")
}

for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/robot_spawnpoint.mdl"); ) ent.DisableDraw()

// NetProps.SetPropString(gamerules_entity, "m_iszScriptThinkFunction", "");

SetSkyboxTexture("sky_mayan")

for (local think_to_clear; think_to_clear = Entities.FindByName(think_to_clear, "defenderspushedcheck"); )
{
	think_to_clear.Kill()
}

for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
{
	local player = PlayerInstanceFromIndex(i)
	if (player == null) continue
	
	NetProps.SetPropInt(player, "m_Local.m_audio.soundscapeIndex", 1)
}

for (local ent; ent = Entities.FindByClassname(ent, "env_soundscape"); ) EntFireByHandle(ent, "Enable", null, -1.0, null, null)

switch (Wave)
{
	case 1: ConvertTankIconsToBlimp(true); 	  															  break
	case 3: ConvertTankIconsToBlimp(false, 2); AssignThinkToThinksTable("HaveDefendersBeenPushed_Think"); break
	case 4: 								   AssignThinkToThinksTable("HaveDefendersBeenPushed_Think"); break
	case 5:
	{
		EntFireByHandle(gamerules_entity, "PlayVO", "ambient/thunder3.wav", 5.0, null, null)
		EntFireByHandle(gamerules_entity, "PlayVO", "ambient/thunder4.wav", 10.0, null, null)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenFade(null, 175, 175, 175, 255, 0.25, 0.25, 2)", 10.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenFade(null, 175, 175, 175, 255, 0.25, 0.25, 1)", 10.25, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SetSkyboxTexture(`sky_alpinestorm_01`)", 10.5, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "SetUpRain()", 10.5, null, null)
		
		NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", 0, 8)
		NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount", 73)
		
		EntFire("spawnbot_invasion", "Disable")
	}
}

if (debug)
{	
	for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
		{
			// EmitSoundEx({ sound_name = "planesound.wav", filter = 5, entity = player, volume = 1, soundlevel = 150, flags = 0, channel = 6 })
			// player.EmitSound("MVM.TankExplodes")
			// EntFireByHandle(player, "SetScriptOverlayMaterial", "airraid_warning_overlay", 0.0, null, null);
			// EntFireByHandle(player, "SetScriptOverlayMaterial","supplydrop_tele_warning_overlay", 0.0, null, null);
			// EntFireByHandle(player, "SetScriptOverlayMaterial","supplydrop_crate_warning_overlay", 0.0, null, null);
			// DispatchParticleEffect("fireSmokeExplosion3", player.GetOrigin() + Vector(-700, 0, 150), Vector(0, 0, 0))
		}
		// ClientPrint(null,3,"current self y:" + player.GetOrigin().y);
		
		// EntFireByHandle(player, "SetScriptOverlayMaterial", "", 0.0, null, null);
	}
	
	// EntFireByHandle(gamerules_entity, "RunScriptCode", "AirRaid_Start(1)", 0.0, null, null)
	// EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropTeles_Start()", 0.0, null, null)
	// EntFireByHandle(gamerules_entity, "RunScriptCode", "SupplyDropCrates_Start()", 0.0, null, null)
	
}