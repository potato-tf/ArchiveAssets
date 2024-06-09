for (local ent; ent = Entities.FindByClassname(ent, "entity_soldier_statue"); ) ent.Kill() // entity_soldier_statue is a preserved entity!

::PEA <-
{	
	intel_entity = Entities.FindByName(null, "intel")

	/// WAVE 4
	blimp_scale = 0.5

	/// WAVE 5
	telesound_cooldown = 0.1
	w5_demoknight_support_active = true
	w5_pyro_support_active = true

	/// WAVE 6
	w6_current_stage = 1
	giftsound_array = ["01", "02", "04", 10, 11, 12, 13, 14, 15, 16, 21, 22, 23, 24, 25, 27]
	clutch_time = false
	p5_bosses_spawned = 0
	in_finale = false

	/// UTILITY
	IsInside = function(vector, min, max) { return vector.x >= min.x && vector.x <= max.x && vector.y >= min.y && vector.y <= max.y && vector.z >= min.z && vector.z <= max.z }

	ignite_player = Entities.CreateByClassname("tf_weapon_flamethrower")
	
	soldier_statue = SpawnEntityFromTable("entity_soldier_statue",
	{
		targetname	= "statue"
		model 		= "models/soldier_statue/soldier_statue.mdl"
		solid 		= 6
		origin 		= Vector(1900, 691, -115)
	})
	
	blimp_path = SpawnEntityGroupFromTable(
	{
		path1 = { path_track = {  origin = Vector(-3004, -4371, 184), targetname = "blimp_path1",  target = "blimp_path2",  } },
		path2 = { path_track = {  origin = Vector(-3004, -2903, 184), targetname = "blimp_path2",  target = "blimp_path3",  } },
		path3 = { path_track = {  origin = Vector(-2425, -2903, 184), targetname = "blimp_path3",  target = "blimp_path4",  } },
		path4 = { path_track = {  origin = Vector(-2425, -1141, 184), targetname = "blimp_path4",  target = "blimp_path5",  } },
		path5 = { path_track = {  origin = Vector(-1816, -437, -80),  targetname = "blimp_path5",  target = "blimp_path6",  } },
		path6 = { path_track = {  origin = Vector(-1392, -437, -80),  targetname = "blimp_path6",  target = "blimp_path7",  } },
		path7 = { path_track = {  origin = Vector(-1392, -1029, -80), targetname = "blimp_path7",  target = "blimp_path8",  } },
		path8 = { path_track = {  origin = Vector(-846, -1029, -80),  targetname = "blimp_path8",  target = "blimp_path9",  } },
		path9 = { path_track = {  origin = Vector(255, -1029, 184),   targetname = "blimp_path9",  target = "blimp_path10", } },
		path10 = { path_track = { origin = Vector(822, -419, 184),    targetname = "blimp_path10", target = "blimp_path11", } },
		path11 = { path_track = { origin = Vector(822, 404, 184),     targetname = "blimp_path11", target = "blimp_path12", } },
		path12 = { path_track = { origin = Vector(1815, 691, 184),    targetname = "blimp_path12",						    } }
	})
	
	MapCleanup = function() { for (local ent; ent = Entities.FindByClassname(ent, "entity_soldier_statue"); ) ent.Kill() } // entity_soldier_statue is a preserved entity!
	
	CALLBACKS =
	{
		OnGameEvent_player_spawn = function(params) // it takes an extra short while for the populator to fill in all of a bot's data when it spawns in, so "onspawn" callbacks need to be delayed
		{
			local bot = GetPlayerFromUserID(params.userid);
			
			if (!bot.IsFakeClient())
			{
				bot.ValidateScriptScope()
				local scope = bot.GetScriptScope()
				
				if (!("saw_mission_info" in scope)) 
				{
					scope.saw_mission_info <- true
					ClientPrint(bot, 4, "Prevent the robots from deploying their bomb underneath Soldier's statue!")
					ClientPrint(bot, 3, "\x07FF3F3FPrevent the robots from deploying their bomb underneath Soldier's statue!")
				}
				
				if (w6_current_stage == 5 && IsInside(bot.GetOrigin(), Vector(2500, -50, -250), Vector(3500, 1250, 500)))
				{
					EntFire("redtint", "Fade")
					bot.Teleport(true, Vector(-2550, -500, 30), true, QAngle(0, -90, 0), false, Vector(0, 0, 0))
				}
				
				return
			}
			
			else EntFireByHandle(bot, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
		}

		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			
			if (dead_player.IsFakeClient())
			{	
				EntFireByHandle(dead_player, "RunScriptCode", "self.SetIsMiniBoss(false); self.RemoveBotAttribute(32768); self.RemoveBotAttribute(65536)", -1.0, null, null)
				
				if (dead_player.HasBotTag("bouncealot"))
				{
					if (NetProps.GetPropString(dead_player, "m_szNetname").find("Revenge") == null)
					{
						PEA["bouncealot_revive_marker"] <- SpawnEntityFromTable("prop_dynamic",
						{
							model 		= "models/weapons/w_models/w_cannonball.mdl"
							origin 		= dead_player.GetOrigin()
							skin		= 1
						})
						
						getroottable()["bouncealot_revive_marker"] <- PEA["bouncealot_revive_marker"]
						
						for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
						{
							local player = PlayerInstanceFromIndex(i)
							
							if (player == null) continue
							
							player.RemoveCustomAttribute("cancel falling damage")
						}
					}
				}
				
				if (dead_player.HasBotTag("soldier_reborn"))
				{
					EntFire("bots_win", "RoundWin")
					dead_player.ForceChangeTeam(1, true)
					EmitSoundEx(
					{
						sound_name = "vo/soldier_sf12_badmagic07.mp3",
						filter = 5,
						volume = 1,
						soundlevel = 150,
						flags = 0,
						channel = 6
					})
				}
				
				if (dead_player.HasBotTag("zombiebot"))
				{
					SpawnEntityFromTable("prop_dynamic",
					{
						targetname	= "zombie_telemarker"
						model 		= "models/weapons/c_models/c_skullbat/c_skullbat.mdl"
						origin 		= dead_player.GetOrigin()
					})
				}
				
				NetProps.SetPropString(dead_player, "m_iszScriptThinkFunction", "")
				
				AddThinkToEnt(dead_player, null)
				
				if (dead_player.GetScriptScope() != null)
				{
					foreach (thing in dead_player.GetScriptScope())
					{
						try { thing.GetClassname() }
						catch (e) { continue }
						
						if (!thing.IsPlayer()) thing.Kill()
					}
				}

				dead_player.TerminateScriptScope()
			}
		}

		OnGameEvent_mvm_begin_wave = function(params)
		{
			if (Wave == 4) ConvertTankIconsToBlimp(true)
			
			if (Wave == 5) { HideIcon("demoknight"); HideIcon("pyro"); HideIcon("demoknight_samurai") }
			
			if (Wave == 6)
			{
				UnhideIcon("wheelofdoom_whammy", 9)
				::W6_IntroCutscene()
				EntFire("forwardupgrade", "Enable", null, 0.1)
			}
		}

		OnGameEvent_mvm_wave_complete = function(params) { if (NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveCount") == 6) w6_current_stage = 1 }

		OnScriptHook_OnTakeDamage = function(params)
		{
			if (!params.attacker.IsPlayer() || !params.const_entity.IsPlayer()) return
			if (!params.attacker.IsFakeClient()) return
			
			if (params.attacker.HasBotTag("balloonray"))
			{
				if (NetProps.GetPropEntity(params.const_entity, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn")) params.const_entity.SetOrigin(params.const_entity.GetOrigin() + Vector(0, 0, 24))
				
				if (!params.const_entity.IsFakeClient()) params.const_entity.SetGravity(-0.05)
				else									 params.const_entity.SetGravity(-0.02)
				
				params.const_entity.AddCustomAttribute("head scale", 5, -1.0)
				params.const_entity.AddCustomAttribute("voice pitch scale", 0.5, -1.0)
				
				EntFireByHandle(params.const_entity, "RunScriptCode", "self.SetGravity(1.0)", 5.0, null, null)
				EntFireByHandle(params.const_entity, "RunScriptCode", "self.RemoveCustomAttribute(`head scale`)", 5.0, null, null)
				EntFireByHandle(params.const_entity, "RunScriptCode", "self.RemoveCustomAttribute(`voice pitch scale`)", 5.0, null, null)
			}
			
			if (params.attacker.HasBotTag("santa_soldier"))
			{
				if (params.const_entity.IsFakeClient()) if (!params.const_entity.HasBotTag("soldier_reborn")) return

				local giftcond_array = [72, 82, 90, 91, 92, 93, 94, 95, 96, 97, 103, 109, 110, 111]
				
				params.const_entity.AddCondEx(giftcond_array[RandomInt(0, giftcond_array.len() - 1)], 5.0, params.attacker)
				
				if (!params.const_entity.IsFakeClient()) EmitSoundEx({sound_name = "misc/happy_birthday_tf_" + giftsound_array[RandomInt(0, giftsound_array.len() - 1)] + ".wav", filter_type = 4, entity = params.const_entity, volume = 1, soundlevel = 150, flags = 1, channel = 6})
			}
			
			if (params.attacker.HasBotTag("blast_perfect"))
			{
				if (params.const_entity.IsFakeClient()) if (!params.const_entity.HasBotTag("soldier_reborn")) return

				params.const_entity.SetOrigin(params.const_entity.GetOrigin() + Vector(0, 0, 48))
			}
			
			if (!("firefist_gun" in getroottable())) return
			if (firefist_gun == null) return
			
			if (params.weapon == firefist_gun && params.const_entity != NetProps.GetPropEntity(firefist_gun, "m_hOwner")) params.const_entity.TakeDamageEx(params.inflictor, params.attacker, ignite_player, Vector(0, 0, 0), params.const_entity.GetOrigin(), 0.01, 8)
		}
	}
	

	
	/////////////////////////////////// CALLBACKS ///////////////////////////////////
	
	/////////////////////////////////// CALLED FUNCTIONS ///////////////////////////////////
	
	BotTagCheck = function()
	{
		if (self.HasBotTag("p1") && (w6_current_stage != 1)) { self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.TakeDamage(10000.0, 64, null); self.ForceChangeTeam(1, true); return }  // doing this causes bots to never spawn and also not block other wavespawns
		if (self.HasBotTag("p2") && (w6_current_stage != 2)) { self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.TakeDamage(10000.0, 64, null); self.ForceChangeTeam(1, true); return }
		if (self.HasBotTag("p3") && (w6_current_stage != 3)) { self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.TakeDamage(10000.0, 64, null); self.ForceChangeTeam(1, true); return }
		if (self.HasBotTag("p4") && (w6_current_stage != 4)) { self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.TakeDamage(10000.0, 64, null); self.ForceChangeTeam(1, true); return }
		
		NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
		
		AddThinkToEnt(self, null)
		
		foreach (thing in self.GetScriptScope())
		{
			try { thing.GetClassname() }
			catch (e) { continue }
			
			if (!thing.IsPlayer()) thing.Kill()
		}
		
		self.TerminateScriptScope()

		if (self.HasBotTag("disband_squad")) 			self.DisbandCurrentSquad()
		if (self.HasBotTag("firefist")) 				AddThinkToEnt(self, "FireFist_Think")
		if (self.HasBotTag("rocketshotgun_hp_adjust"))	self.SetHealth(200)
		if (self.HasBotTag("bouncealot")) 				AddThinkToEnt(self, "Bouncealot_Think")
		if (self.HasBotTag("soldier_reborn")) 			AddThinkToEnt(self, "SoldierReborn_Think")
		if (self.HasBotTag("spellbook_fireball")) 		AddThinkToEnt(self, "SpellbookFireball_Think")
		if (self.HasBotTag("zombiebot")) 				EntFireByHandle(self, "CallScriptFunction", "ZombieTeleport", -1.0, null, null)
		if (self.HasBotTag("cleaver")) 					AddThinkToEnt(self, "CleaverBot_Think")
		if (self.HasBotTag("aoe_medic")) 				AddThinkToEnt(self, "AoEUber_Think")
		if (self.HasBotTag("nogravity_grenades")) 		AddThinkToEnt(self, "NoGravityGrenades_Think")
		if (self.HasBotTag("santa_soldier")) 			{ AddThinkToEnt(self, "SantaSoldier_Think"); self.SetCustomModelWithClassAnimations("models/player/soldier.mdl") }
		if (self.HasBotTag("victory"))			 		self.ForceChangeTeam(1, true)
		
		if (self.HasBotTag("w5_demoknight_support") || self.HasBotTag("w5_samurai_support"))			
		{
			if (self.HasBotTag("w5_demoknight_support") && !w5_demoknight_support_active) self.ForceChangeTeam(1, false) // does not drop currency so no need to kill
			else if (Entities.FindByName(null, "bouncetele") != null)
			{
				self.Teleport(true, Entities.FindByName(null, "bouncetele").GetOrigin(), false, QAngle(0, 0, 0), true, Vector(RandomInt(-500, 500), RandomInt(-500, 500), 600))

				if (telesound_cooldown < Time())
				{
					EmitSoundEx(
					{
						sound_name = "mvm/mvm_tele_deliver.wav",
						filter = 5,
						entity = self,
						volume = 1,
						soundlevel = 150,
						flags = 0,
						channel = 6
					})
					
					telesound_cooldown = Time() + 0.1
				}
				
				if (self.HasBotTag("w5_samurai_support")) self.SetCustomModelWithClassAnimations("models/player/demo.mdl") // necessary to make zombie skins work
			}
		}
		
		if (self.HasBotTag("w5_pyro_support") && !w5_pyro_support_active) { self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.TakeDamage(10000.0, 64, null); self.ForceChangeTeam(1, true) }
		
		if (self.HasBotTag("p5"))
		{
			switch (p5_bosses_spawned)
			{
				case 0: self.Teleport(true, Vector(-2501, -1711, -148), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); break
				case 1: self.Teleport(true, Vector(-3627, -1711, -148), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); break
				case 2: self.Teleport(true, Vector(-2501, -2874, -148), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)); break
			}
			
			EmitSoundEx({ sound_name = "ambient/medieval_thunder2.wav", filter = 5, entity = self, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
			EmitSoundEx({ sound_name = "misc/halloween/spell_lightning_ball_impact.wav", filter = 5, entity = self, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
			
			DispatchParticleEffect("wrenchmotron_teleport_beam", self.GetOrigin(), Vector(0, 90, 0))
			
			for (local player; player = Entities.FindByClassnameWithin(player, "player", self.EyePosition(), 75); )
			{
				if (player == null) continue
				
				if (player.GetTeam() == 2)
				{
					player.SetOrigin(player.GetOrigin() + Vector(0, 0, 48))
					player.SetAbsVelocity(Vector(500, 500, 250))
				}
			}
			
			p5_bosses_spawned = p5_bosses_spawned + 1
		}
	}

	ZombieTeleport = function()
	{
		if (w6_current_stage > 4)
		{
			self.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			self.TakeDamage(10000.0, 64, null)
			self.ForceChangeTeam(1, true)
		}
		
		switch (NetProps.GetPropInt(self, "m_PlayerClass"))
		{
			case Constants.ETFClass.TF_CLASS_SCOUT: self.SetCustomModelWithClassAnimations("models/player/scout.mdl"); break
			case Constants.ETFClass.TF_CLASS_SOLDIER: self.SetCustomModelWithClassAnimations("models/player/soldier.mdl"); break
			case Constants.ETFClass.TF_CLASS_PYRO: self.SetCustomModelWithClassAnimations("models/player/pyro.mdl"); break
			case Constants.ETFClass.TF_CLASS_DEMOMAN: self.SetCustomModelWithClassAnimations("models/player/demo.mdl"); break
			case Constants.ETFClass.TF_CLASS_HEAVYWEAPONS: self.SetCustomModelWithClassAnimations("models/player/heavy.mdl"); break
		}
		
		local zombie_telemarker = Entities.FindByName(null, "zombie_telemarker")
		
		if (zombie_telemarker == null) return
		else self.Teleport(true, zombie_telemarker.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		
		EmitSoundEx({ sound_name = "ambient/medieval_thunder2.wav", filter = 5, entity = zombie_telemarker, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
		EmitSoundEx({ sound_name = "misc/halloween/spell_lightning_ball_impact.wav", filter = 5, entity = zombie_telemarker, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
		
		DispatchParticleEffect("wrenchmotron_teleport_beam", Entities.FindByName(null, "zombie_telemarker").GetOrigin(), Vector(0, 90, 0))
		
		zombie_telemarker.Kill()
	}
	
	AnnounceBouncealotRevival = function()
	{	
		DispatchParticleEffect("wrenchmotron_teleport_beam", bouncealot_revive_marker.GetOrigin(), Vector(0, 90, 0))
		
		EmitSoundEx({ sound_name = "vo/demoman_laughshort05.mp3", filter = 5, entity = bouncealot_revive_marker, volume = 1, soundlevel = 150, flags = 1, pitch = 65, channel = 6 })
		
		EmitSoundEx({ sound_name = "ambient/medieval_thunder2.wav", filter = 5, entity = bouncealot_revive_marker, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
		EmitSoundEx({ sound_name = "misc/halloween/spell_lightning_ball_impact.wav", filter = 5, entity = bouncealot_revive_marker, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/demoman_mvm_resurrect01.mp3`, filter = 5, volume = 1, pitch = 65, soundlevel = 150, flags = 1, channel = 6 })", 2.0, null, null)
		
		SendGlobalGameEvent("show_annotation", 
		{
			id = 1
			text = "Bouncealot is being resurrected!"
			worldPosX = bouncealot_revive_marker.GetOrigin().x
			worldPosY = bouncealot_revive_marker.GetOrigin().y
			worldPosZ = bouncealot_revive_marker.GetOrigin().z
			play_sound = "misc/null.wav"
			show_distance = true
			show_effect = true
			lifetime = 3
		})
		
		for (local i = 1; i <= 9; i++)
		{
			EntFireByHandle(gamerules_entity, "RunScriptCode", "DispatchParticleEffect(`wrenchmotron_teleport_beam`, bouncealot_revive_marker.GetOrigin(), Vector(0, 90, 0))", 0.1 * i, null, null)

			EntFireByHandle(bouncealot_revive_marker, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder2.wav`, filter = 5, entity = self, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })", 0.1 * i, null, null)
			EntFireByHandle(bouncealot_revive_marker, "RunScriptCode", "EmitSoundEx({ sound_name = `misc/halloween/spell_lightning_ball_impact.wav`, filter = 5, entity = self, volume = 0.4, soundlevel = 150, flags = 0, channel = 6 })", 0.1 * i, null, null)
			
		}
	}

	W6_IntroCutscene = function()
	{
		SpawnEntityFromTable("info_particle_system",
		{
			origin		 = Vector(2885, -3125, -110)
			targetname	 = "green_steam_cap"
			start_active = 0
			effect_name	 = "green_steam_plume"
			angles		 = QAngle(-90, 0, 0)
		})
		
		SpawnEntityFromTable("info_particle_system",
		{
			origin		 = Vector(-3005, -3160, -198)
			targetname	 = "green_wof_sparks"
			start_active = 0
			effect_name	 = "green_wof_sparks"
			angles		 = QAngle(0, 247.5, 0)
		})
		
		PEA["wheel_plane"] <- SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "wheel_plane"
			origin        = Vector(-3000, -3144, 200)
			angles        = QAngle(0, 180, 0)
			modelscale	  = 0.5
			model         = "models/props_lakeside_event/buff_plane.mdl"
		})
		
		getroottable()["wheel_plane"] <- PEA["wheel_plane"]
		
		EntFire("green_steam_cap", "Start", null, -1.0); EntFire("green_steam_cap", "Stop", null, 3.0)
		EntFire("green_steam_cap", "Start", null, 3.25); EntFire("green_steam_cap", "Stop", null, 3.65)
		EntFire("green_steam_cap", "Start", null, 4.0);  EntFire("green_steam_cap", "Stop", null, 4.5)
		
		EntFire("green_wof_sparks", "Start", null, -1.0); EntFire("green_wof_sparks", "Stop", null, 6.7)
		EntFire("green_wof_sparks", "Start", null, 6.75); EntFire("green_wof_sparks", "Stop", null, 14.0)
		
		wheel_plane.SetModelScale(1.0, 6.75)
		
		for (local i = 0.1; i <= 1.0; i = i + 0.1) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 1.12; i <= 1.96; i = i + 0.12) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 2.1; i <= 2.94; i = i + 0.14) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 3.1; i <= 4.06; i = i + 0.16) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 4.24; i <= 4.96; i = i + 0.18) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 5.16; i <= 5.96; i = i + 0.2) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 6.18; i <= 6.62; i = i + 0.22) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		
		EntFire("wheel_plane", "Skin", 1, 6.75)
		
		EmitSoundEx( { sound_name = "vo/halloween_merasmus/sf12_appears09.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		EmitSoundEx( { sound_name = "Halloween.WheelofFate", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		
		function Delay_7Sec() { EmitSoundEx( { sound_name = "vo/halloween_merasmus/sf12_appears14.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } ) }
		
		function Delay_10Sec()
		{
			DispatchParticleEffect("explosionTrail_seeds_mvm", Vector(-3600, -2854, -170), Vector(0, 90, 0))
			DispatchParticleEffect("fluidSmokeExpl_ring_mvm", Vector(-3600, -2854, -170), Vector(0, 90, 0))
			
			local smoke_push = SpawnEntityFromTable("point_push",
			{
				origin        			= Vector(-3600, -2854, -170)
				radius                  = 250
				magnitude               = 500
				spawnflags              = 11
			})
			
			for (local player; player = Entities.FindInSphere(player, smoke_push.GetOrigin(), 250); ) if (player.IsPlayer()) player.SetOrigin(player.GetOrigin() + Vector(0, 0, 64))
			
			EntFireByHandle(smoke_push, "Enable", null, -1.0, null, null) // must be manually enabled
			EntFireByHandle(smoke_push, "Kill", null, 0.1, null, null)
			
			EmitSoundEx( { sound_name = "weapons/explode3.wav", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		}
		
		function Delay_11Sec() { soldier_statue.Teleport(true, Vector(-3600, -2854, -220), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)) }
		
		function Delay_12Sec() { EmitSoundEx( { sound_name = "merasmus_waitwhat.wav", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } ) }
		
		function Delay_14Sec()
		{
			for (local i = 1; i <= 3; i++)
			{
				EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/soldier_painsharp0" + i + ".mp3`, filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })", i - 1, null, null)
				
				if (i < 3) EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `weapons/wrench_hit_build_success" + i + ".wav`, filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })", i - 1, null, null)
				else	   EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `weapons/wrench_hit_build_success1.wav`, filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })", i - 1, null, null)
				
				EntFireByHandle(gamerules_entity, "RunScriptCode", "DispatchParticleEffect(`grenade_smoke`, Vector(-3600, -2854, -170), Vector(0, 0, 0))", i - 1, null, null)
				
				EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenShake(Vector(-3600, -2854, -220), 16, 200.0, 1.0, 1184.0, 0, true)", i - 1, null, null)
			}
			
			EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/soldier_battlecry05.mp3`, filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })", 3.0, null, null)
		}
		
		function Delay_17Sec()
		{
			DispatchParticleEffect("explosionTrail_seeds_mvm", Vector(-3600, -2854, -170), Vector(0, 90, 0))
			DispatchParticleEffect("fluidSmokeExpl_ring_mvm", Vector(-3600, -2854, -170), Vector(0, 90, 0))
			EmitSoundEx({ sound_name = "MVM.BombExplodes", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })
			
			soldier_statue.Kill()
		}
		
		function Delay_19Sec()
		{
			EmitSoundEx({ sound_name = "vo/soldier_mvm_resurrect05.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })
		}
		
		function Delay_22Sec()
		{
			EmitSoundEx({ sound_name = "vo/soldier_sf13_round_start02.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })
		}
		
		function Delay_23Sec()
		{
			EmitSoundEx({ sound_name = "vo/halloween_merasmus/sf12_appears15.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 })
		}
		
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_7Sec", 7.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_10Sec", 10.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_11Sec", 11.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_12Sec", 12.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_14Sec", 14.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_17Sec", 17.5, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_19Sec", 19.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_22Sec", 22.0, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay_23Sec", 23.5, null, null)
	}

	W6_FinalPhase = function()
	{
		ClientPrint(null,3,"\x0790EE90Final phase begins!"); ClientPrint(null,4,"Final phase begins!")
		
		SpawnEntityFromTable("env_fade", // ScreenFade function is imperfect, cannot be used to set permanent fades that can be turned off at will
		{
			targetname    = "redtint"
			spawnflags	  = 8
			rendercolor	  = "255 0 0"
			renderamt	  = 20
			holdtime	  = 60
			duration	  = 0.01
		})
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue
			if (player.GetTeam() == 3)
			{
				if (player.InCond(51)) player.Teleport(true, Vector(-1500, 2300, 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
				player.TakeDamage(10000.0, 64, null)
			}
		}
		
		EmitSoundEx( { sound_name = "ui/halloween_boss_chosen_it.wav", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		EmitSoundEx( { sound_name = "ambient/halloween/thunder_08.wav", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		EmitSoundEx( { sound_name = "gamestartup18_cut.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		EmitSoundEx( { sound_name = "merasmus_enough.wav", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		
		ScreenFade(null, 255, 255, 255, 255, 0.15, 1.0, 0)
		ScreenShake(Vector(0, 0, 0), 8.0, 200.0, 12.0, 9999.9, 0, true)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx( { sound_name = `vo/halloween_merasmus/sf12_leaving16.mp3`, filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )", 1.0, null, null)
		
		// EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenFade(null, 255, 0, 0, 20, -1.0, 66.3, 0)", 1.15, null, null)
		
		EntFire("redtint", "Fade", null, 1.15)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "clutch_time = true", 1.15, null, null)
		
	}

	W6_EndingCutscene = function()
	{
		EmitSoundEx( { sound_name = "vo/halloween_merasmus/sf12_headbomb_hit02.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		EmitSoundEx( { sound_name = "Halloween.WheelofFate", filter = 5, volume = 1, soundlevel = 150, flags = 1, channel = 6 } )
		
		wheel_plane.SetModelScale(0.5, -1.0)
		wheel_plane.SetModelScale(1.0, 6.75)
		
		for (local i = 0.1; i <= 1.0; i = i + 0.1) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 1.12; i <= 1.96; i = i + 0.12) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 2.1; i <= 2.94; i = i + 0.14) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 3.1; i <= 4.06; i = i + 0.16) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 4.24; i <= 4.96; i = i + 0.18) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 5.16; i <= 5.96; i = i + 0.2) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		for (local i = 6.18; i <= 6.62; i = i + 0.22) EntFire("wheel_plane", "Skin", RandomInt(2, 9), i)
		
		for (local i = 6.75; i <= 12; i = i + 1.75) { EntFire("wheel_plane", "Skin", RandomInt(2, 9), i); EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `hwn_wheel_of_fate_onlybell.wav`, filter = 5, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", i, null, null) }
		for (local i = 13.25; i <= 17; i = i + 1.25) { EntFire("wheel_plane", "Skin", RandomInt(2, 9), i); EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `hwn_wheel_of_fate_onlybell.wav`, filter = 5, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", i, null, null) }
		for (local i = 17.75; i <= 22.25; i = i + 0.75) { EntFire("wheel_plane", "Skin", RandomInt(2, 9), i); EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({ sound_name = `hwn_wheel_of_fate_onlybell.wav`, filter = 5, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", i, null, null) }
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-7168, -8192, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-7068, -8192, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-7168, -8292, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-6868, -8592, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-7668, -9000, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-5068, -5092, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		SpawnEntityFromTable("prop_dynamic",
		{
			targetname    = "skybox_engineers"
			origin        = Vector(-9000, -9292, 1568)
			modelscale	  = 5
			model         = "models/player/engineer.mdl"
			StartDisabled = 1
		})
		
		EntFire("skybox_engineers", "Enable", null, 11.75)
		EntFire("skybox_engineers", "Disable", null, 12.5)
		
		function Delay7Sec()
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				
				player.AddCondEx(32, 1.75, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`head scale`, 0.5, 1.75)", 1.75, null, null)
				EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`voice pitch scale`, 2.0, 1.75)", 1.75, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.SetGravity(-1)", 3.5, null, null)
				EntFireByHandle(player, "RunScriptCode", "self.SetGravity(1)", 5.25, null, null)
				
				EntFireByHandle(player, "SetCustomModel", "models/props_2fort/cow001_reference.mdl", 5.25, null, null)
				EntFireByHandle(player, "SetCustomModel", "", 6.5, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCondEx(54, 1.25, null)", 6.5, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCondEx(86, 1.25, null)", 7.75, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`head scale`, 100, 1.25)", 9.0, null, null)
				EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`voice pitch scale`, 0.25, 1.25)", 9.0, null, null)
				
				EntFireByHandle(player, "SetCustomModel", "models/empty.mdl", 10.25, null, null)
				EntFireByHandle(player, "SetHUDVisibility", "0", 10.25, null, null)
				EntFireByHandle(player, "SetCustomModel", "", 11.0, null, null)
				EntFireByHandle(player, "SetHUDVisibility", "1", 11.0, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCondEx(82, 0.75, null)", 11.0, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.SnapEyeAngles(QAngle(self.GetAbsAngles().x, self.GetAbsAngles().y, 180))", 12.5, null, null)
				EntFireByHandle(player, "RunScriptCode", "self.SnapEyeAngles(QAngle(self.GetAbsAngles().x, self.GetAbsAngles().y, 0))", 13.25, null, null)
				
				EntFireByHandle(player, "SetCustomModel", "models/props_foliage/tree_pine_huge.mdl", 13.25, null, null)
				EntFireByHandle(player, "SetCustomModel", "", 14.0, null, null)
				
				EntFireByHandle(player, "SetFogController", "silence_fog", 14.0, null, null)
				EntFireByHandle(player, "SetFogController", "fog", 14.75, null, null)
				
				EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`torso scale`, 100, 0.75)", 14.75, null, null)
				
				EntFireByHandle(player, "SpeakResponseConcept", "HalloweenLongFall", 15.5, null, null)
				
				if (player.IsFakeClient() && player.GetTeam() == 3) EntFireByHandle(player, "RunScriptCode", "self.TakeDamage(100000.0, 64, null)", 16.25, null, null)
			}
		}
		
		function Delay23Sec()
		{
			in_finale = true
			
			Convars.SetValue("tf_forced_holiday", 0)
			
			SpawnEntityFromTable("env_fade",
			{
				targetname    = "wheel_explosion_whiteout_start"
				spawnflags	  = 0
				rendercolor	  = "255 255 255"
				renderamt	  = 255
				holdtime	  = 1.5
				duration	  = 1.5
			})
			
			SpawnEntityFromTable("env_fade",
			{
				targetname    = "wheel_explosion_whiteout_end"
				spawnflags	  = 1
				rendercolor	  = "255 255 255"
				renderamt	  = 255
				holdtime	  = 1.5
				duration	  = 1.5
			})
			
			ScreenShake(Vector(0, 0, 0), 16, 200.0, 12.0, 9999.9, 0, true)
			
			EmitSoundEx({ sound_name = "MVM.BombExplodes", filter = 5, volume = 1, soundlevel = 150, flags = 0, channel = 6 })
			EmitSoundEx({ sound_name = "vo/halloween_merasmus/sf12_defeated12.mp3", filter = 5, volume = 1, soundlevel = 150, flags = 0, channel = 6 })
			
			DispatchParticleEffect("explosionTrail_seeds_mvm", wheel_plane.GetOrigin(), Vector(0, 90, 0))
			DispatchParticleEffect("fluidSmokeExpl_ring_mvm", wheel_plane.GetOrigin(), Vector(0, 90, 0))
			
			wheel_plane.Kill()
			
			EntFire("wheel_explosion_whiteout_start", "Fade")
			EntFireByHandle(gamerules_entity, "RunScriptCode", "EntFire(`wheel_explosion_whiteout_end`, `Fade`)", 3.0, null, null)
			
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				if (player.GetTeam() != 2) continue

				if (!player.IsFakeClient())
				{
					if (NetProps.GetPropInt(player, "m_lifeState") != 0) player.ForceRespawn()
					EntFireByHandle(player, "RunScriptCode", "self.Teleport(true, Vector(2196, 689, -60) + Vector(RandomInt(-150, 150), RandomInt(-150, 150), 0), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 2.5, null, null)
				}
				else
				{
					EntFireByHandle(player, "RunScriptCode", "self.Teleport(true, Vector(1900, 691, -110), true, QAngle(0, 0, 0), false, Vector(0, 0, 0))", 2.5, null, null)
					EntFireByHandle(player, "RunScriptCode", "self.SetMoveType(0, 0)", 2.5, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/soldier_hatoverhearttaunt06.mp3`, filter = 5, entity = self, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", 5.5, null, null)
					EntFireByHandle(player, "RunScriptCode", "self.Taunt(0, 0)", 9.0, null, null)
					
					EntFireByHandle(player, "RunScriptCode", "DispatchParticleEffect(`wrenchmotron_teleport_beam`, self.GetOrigin(), Vector(0, 90, 0))", 13.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder2.wav`, filter = 5, entity = self, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", 13.0, null, null)
					EntFireByHandle(player, "RunScriptCode", "EmitSoundEx({ sound_name = `misc/halloween/spell_lightning_ball_impact.wav`, filter = 5, entity = self, volume = 1, soundlevel = 150, flags = 0, channel = 6 })", 13.0, null, null)
					
					EntFireByHandle(player, "RunScriptCode", "self.GetScriptScope().gone = true", 12.5, null, null)
					EntFireByHandle(player, "RunScriptCode", "self.Teleport(true, Vector(-1500, 2300, 0), true, QAngle(0, 0, 0), false, Vector(0, 0, 0)); self.ForceChangeTeam(1, true); self.RemoveBotAttribute(65536)", 13.0, null, null)
					
					EntFireByHandle(player, "RunScriptCode", "SpawnEntityFromTable(`entity_soldier_statue`, { model = `models/soldier_statue/soldier_statue.mdl`, solid = 6, origin = Vector(1900, 691, -115) })", 13.0, null, null)
				}
			}
		}
		
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay7Sec", 6.75, null, null)
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "Delay23Sec", 23.0, null, null)
	}

	StunAllBots = function()
	{
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue
			if (player.GetTeam() == 2) continue
			
			if (IsPlayerABot(player)) player.AddCondEx(71, 20.0, null)
		}
	}

	/////////////////////////////////// CALLED FUNCTIONS ///////////////////////////////////
	/////////////////////////////////// THINKS ///////////////////////////////////

	SantaSoldier_Think = function()
	{
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_rocket"); )
		{
			if (ent.GetOwner() != self) continue
			if (ent.GetModelName() != "models/props_halloween/halloween_gift.mdl") ent.SetModel("models/props_halloween/halloween_gift.mdl")
		}
		
		return -1
	}

	NoGravityGrenades_Think = function()
	{
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_pipe"); )
		{
			if (NetProps.GetPropEntity(ent, "m_hThrower") != self) return
			
			ent.ValidateScriptScope()
			local scope = ent.GetScriptScope()
			
			if (!("starting_z" in scope)) scope.starting_z <- ent.GetOrigin().z - 50

			if (ent.GetOrigin().z != scope.starting_z)
			{
				ent.SetOrigin(Vector(ent.GetOrigin().x, ent.GetOrigin().y, scope.starting_z))
				ent.SetPhysVelocity(Vector(self.EyeAngles().Forward().x * 500, self.EyeAngles().Forward().y * 500, 0))
			}
			
			NetProps.SetPropBool(ent, "m_bTouched", false)
		}
		
		return -1
	}

	AoEUber_Think = function()
	{	
		local scope = self.GetScriptScope()
		
		if (!("spawned" in scope))
		{
			scope.spawned <- true
			scope.unique_id <- UniqueString()
			
			scope.uber_beam_1 <- SpawnEntityFromTable("dispenser_touch_trigger",
			{
				targetname    	   = "dispenser_trigger_" + scope.unique_id
				origin             = self.GetOrigin()
				spawnflags         = 1
			})
			
			scope.uber_beam_2 <- SpawnEntityFromTable("mapobj_cart_dispenser",
			{
				targetname    	   = "dispenser_mapobj_" + scope.unique_id
				origin             = self.GetOrigin()
				TeamNum            = 3,
				spawnflags         = 12
				touch_trigger      = "dispenser_trigger_" + scope.unique_id
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
		
		return 0.1
	}

	CleaverBot_Think = function()
	{
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_cleaver"); )
		{
			ent.ValidateScriptScope()
			local proj_scope = ent.GetScriptScope()
			
			if (!("multiplied" in proj_scope) && !("extra_cleaver" in proj_scope))
			{
				proj_scope.multiplied <- true
				
				SpawnEntityFromTable("tf_projectile_cleaver",
				{
					targetname = "extra_cleaver"
					teamnum    = 3
					origin     = ent.GetOrigin() + (self.EyeAngles().Left() * RandomInt(-175, 175))
				})
				
				SpawnEntityFromTable("tf_projectile_cleaver",
				{
					targetname = "extra_cleaver"
					teamnum    = 3
					origin     = ent.GetOrigin() + (self.EyeAngles().Left() * RandomInt(-175, 175))
				})
				
				SpawnEntityFromTable("tf_projectile_cleaver",
				{
					targetname = "extra_cleaver"
					teamnum    = 3
					origin     = ent.GetOrigin() + (self.EyeAngles().Left() * RandomInt(-175, 175))
				})
				
				for (local cleave; cleave = Entities.FindByName(cleave, "extra_cleaver"); )
				{
					cleave.ValidateScriptScope()
					cleave.GetScriptScope().extra_cleaver <- true
					
					cleave.SetOwner(self)
					
					cleave.SetPhysVelocity(ent.GetPhysVelocity())
				}
			}
		}
		
		return 0.1
	}

	SpellbookFireball_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("spawned" in scope))
		{
			scope.spawned <- true
			scope.spellbook <- NetProps.GetPropEntityArray(self, "m_hMyWeapons", 3)

			NetProps.SetPropInt(spellbook, "m_iSelectedSpellIndex", 0)
			NetProps.SetPropInt(spellbook, "m_iSpellCharges", 9999)
		}
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_flare"); ) if (ent.GetOwner() == self) ent.Kill()
		
		if (NetProps.GetPropInt(self, "m_afButtonLast") & Constants.FButtons.IN_ATTACK) spellbook.PrimaryAttack()
		
		return -1
	}

	SoldierReborn_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope))
		{
			scope.tick <- 1
			scope.taunted_in_intro <- false
			scope.moving <- false
			scope.gone <- false
			
			Convars.SetValue("tf_forced_holiday", 0)
			
			self.KeyValueFromString("targetname", "glow_target")
			
			scope.self_glow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				GlowColor             = "184 56 59 255"
			})
			
			EntFireByHandle(scope.self_glow, "SetParent", "!activator", -1.0, self, null)
			
			self.KeyValueFromString("targetname", "")
			
			self.ForceChangeTeam(2, true)
			self.Teleport(true, Vector(-3600, -2854, -210), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
			self.SetCustomModelWithClassAnimations("models/player/soldier.mdl")
			
			for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer()) if (child.GetClassname() == "tf_wearable" && child.GetModelName().find("tw_") != null) EntFireByHandle(child, "Kill", null, -1.0, null, null);

			scope.navdest1 <- Vector(-2501, -2874, -148)
			scope.navdest2 <- Vector(-2501, -1711, -148)
			scope.navdest3 <- Vector(-3627, -1711, -148)
			scope.navdest4 <- Vector(-3600, -2854, -220)
			
			return
		}
		
		if (scope.gone) return
		
		if (!taunted_in_intro && NetProps.GetPropEntity(self, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn"))
		{
			self.Taunt(0, 0)
			
			scope.taunted_in_intro = true
			
			Convars.SetValue("tf_forced_holiday", 2)
			
			local rpg = Entities.CreateByClassname("tf_weapon_rocketlauncher")

			NetProps.SetPropInt(rpg, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 18)
			NetProps.SetPropBool(rpg, "m_AttributeManager.m_Item.m_bInitialized", true)
			NetProps.SetPropBool(rpg, "m_bValidatedAttachedEntity", true)
			
			rpg.SetTeam(self.GetTeam())
			
			rpg.AddAttribute("fire rate bonus", 0.25, -1.0)
			rpg.AddAttribute("Projectile speed increased", 1.5, -1.0)
			
			Entities.DispatchSpawn(rpg) 
			self.Weapon_Equip(rpg)
			
			NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).Destroy()
			NetProps.SetPropEntityArray(self, "m_hMyWeapons", rpg, 0)
		}

		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue
			if (player.GetTeam() != 2 || NetProps.GetPropInt(player, "m_lifeState") != 0) continue
			
			if (NetProps.GetPropInt(player, "m_PlayerClass") != Constants.ETFClass.TF_CLASS_MEDIC) continue
			
			local medigun = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 1)
			
			if (NetProps.GetPropBool(medigun, "m_bChargeRelease") != true || NetProps.GetPropEntity(medigun, "m_hHealingTarget") != self) continue
			
			else NetProps.SetPropFloat(medigun, "m_flChargeLevel", NetProps.GetPropFloat(medigun, "m_flChargeLevel") - (0.001875 * 2)) // triple amount of uber lost per frame
		}
		
		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetCenter(), 250); ) // check if any of the blocker's bbox's angles intersect with our own bbox to push them
		{
			if (!in_finale && player.GetTeam() != 3) continue
			if (player == self) continue

			local player_peak_1 = player.GetOrigin() + player.GetBoundingMins()
			local player_peak_2 = player.GetOrigin() + Vector(player.GetBoundingMaxs().x, player.GetBoundingMins().y, player.GetBoundingMins().z)
			local player_peak_3 = player.GetOrigin() + Vector(player.GetBoundingMins().x, player.GetBoundingMaxs().y, player.GetBoundingMins().z)
			local player_peak_4 = player.GetOrigin() + Vector(player.GetBoundingMaxs().x, player.GetBoundingMaxs().y, player.GetBoundingMins().z)
			
			local player_peak_5 = player_peak_1 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_6 = player_peak_2 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_7 = player_peak_3 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_8 = player_peak_4 + Vector(0, 0, player.GetBoundingMaxs().z)
			
			local self_offset_min = self.GetOrigin() + self.GetBoundingMins() - Vector(20, 20, 20) // has to be extra huge to avoid getting force stopped
			local self_offset_max = self.GetOrigin() + self.GetBoundingMaxs() + Vector(20, 20, 20)
			
			if (IsInside(player_peak_1, self_offset_min, self_offset_max) || IsInside(player_peak_2, self_offset_min, self_offset_max) || IsInside(player_peak_3, self_offset_min, self_offset_max) || IsInside(player_peak_4, self_offset_min, self_offset_max) ||
				IsInside(player_peak_5, self_offset_min, self_offset_max) || IsInside(player_peak_6, self_offset_min, self_offset_max) || IsInside(player_peak_7, self_offset_min, self_offset_max) || IsInside(player_peak_8, self_offset_min, self_offset_max))
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
		
		if (scope.tick % 7 == 0)
		{
			NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).SetClip1(12)
			
			if (!in_finale)
			{
				for (local player; player = Entities.FindByClassnameWithin(player, "player", self.EyePosition(), 250); )
				{
					if (player == null) continue
					if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue
					
					if (player.GetTeam() == 2 && player != self)
					{
						self.AddCondEx(16, 0.5, self); self.AddCondEx(26, 0.5, self); self.AddCondEx(29, 0.5, self)
						player.AddCondEx(16, 0.5, self); player.AddCondEx(26, 0.5, self); player.AddCondEx(29, 0.5, self)
						
						if (clutch_time) { self.AddCondEx(91, 0.5, self); player.AddCondEx(91, 0.5, self) }
					}
				}
				
				if (clutch_time)
				{
					for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
					{
						local player = PlayerInstanceFromIndex(i)
						
						if (player == null) continue
						
						if (player != self && !player.InCond(107)) player.AddCondEx(107, 0.5, self)
					}
				}
			}
		}
		
		if (scope.tick % 67 == 0)
		{
			if (!in_finale)
			{
				EntFireByHandle(scope.self_glow, "SetGlowColor", "184 56 59 255", -1.0, null, null)
				EntFireByHandle(scope.self_glow, "SetGlowColor", "0 255 0 255", 0.5, null, null)
			}
			
			else if ("self_glow" in scope)
			{
				scope.self_glow.Kill()
				delete scope.self_glow
			}
			
		}
		
		if (scope.tick < 433) self.Weapon_Switch(NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0))
		
		if (scope.tick == 433 && !scope.moving)
		{
			scope.nextbot <- CustomBotNavigation(self)
			scope.moving <- true
		}
		
		intel_entity.Teleport(true, self.GetOrigin() - Vector(0, 0, 3000), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
		EntFireByHandle(intel_entity, "ForceDrop", null, -1.0, null, null)
		
		if (in_finale)
		{
			scope.moving = false
			self.SnapEyeAngles(QAngle(0, 0, 0))
			self.Weapon_Switch(NetProps.GetPropEntityArray(self, "m_hMyWeapons", 1))
		}
		
		if (scope.moving) scope.nextbot.Update()
		else 			  self.SnapEyeAngles(QAngle(0, 0, 0))
		
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue
			
			if (player.IsFakeClient() && player != self)
			{
				player.DelayedThreatNotice(self, -1.0)
				player.SetAttentionFocus(self)
			}
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}

	Bouncealot_Think = function()
	{	
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope))
		{
			scope.tick <- 0
			scope.teleported <- false
			scope.taunted <- false
			
			scope.bouncetele <- SpawnEntityFromTable("obj_teleporter", { targetname = "bouncetele", teamnum = 3, spawnflags = 2 } )
			scope.bouncetele.SetCollisionGroup(0)
			scope.bouncetele.SetSolid(0)
		}
		
		scope.bouncetele.SetOrigin(self.GetBoneOrigin(3))
		scope.bouncetele.SetAbsAngles(self.GetBoneAngles(3))
		
		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 250); ) // check if any of the blocker's bbox's angles intersect with our own bbox to push them
		{
			if (player.GetTeam() != 2) continue

			local player_peak_1 = player.GetOrigin() + player.GetBoundingMins()
			local player_peak_2 = player.GetOrigin() + Vector(player.GetBoundingMaxs().x, player.GetBoundingMins().y, player.GetBoundingMins().z)
			local player_peak_3 = player.GetOrigin() + Vector(player.GetBoundingMins().x, player.GetBoundingMaxs().y, player.GetBoundingMins().z)
			local player_peak_4 = player.GetOrigin() + Vector(player.GetBoundingMaxs().x, player.GetBoundingMaxs().y, player.GetBoundingMins().z)
			
			local player_peak_5 = player_peak_1 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_6 = player_peak_2 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_7 = player_peak_3 + Vector(0, 0, player.GetBoundingMaxs().z)
			local player_peak_8 = player_peak_4 + Vector(0, 0, player.GetBoundingMaxs().z)
			
			local self_offset_min = self.GetOrigin() + self.GetBoundingMins() - Vector(2.5, 2.5, 2.5)
			local self_offset_max = self.GetOrigin() + self.GetBoundingMaxs() + Vector(2.5, 2.5, 2.5)
			
			if (IsInside(player_peak_1, self_offset_min, self_offset_max) || IsInside(player_peak_2, self_offset_min, self_offset_max) || IsInside(player_peak_3, self_offset_min, self_offset_max) || IsInside(player_peak_4, self_offset_min, self_offset_max) ||
				IsInside(player_peak_5, self_offset_min, self_offset_max) || IsInside(player_peak_6, self_offset_min, self_offset_max) || IsInside(player_peak_7, self_offset_min, self_offset_max) || IsInside(player_peak_8, self_offset_min, self_offset_max))
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
		
		if (scope.tick % 7 == 0)
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				
				player.AddCustomAttribute("cancel falling damage", 1, -1)
			}
			
			local bouncealot_gun = NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0)
			
			if (NetProps.GetPropString(self, "m_szNetname").find("Revenge") == null) bouncealot_gun.SetClip1(12)
			else
			{
				bouncealot_gun.SetClip1(1)
				
				if (!scope.teleported)
				{
					self.Teleport(true, bouncealot_revive_marker.GetOrigin() + Vector(0, 0, 10), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
					
					bouncealot_revive_marker.Kill()
					
					self.SetCustomModelWithClassAnimations("models/player/demo.mdl") // necessary to make zombie skins work
					
					scope.teleported = true
				}
				
				if (!scope.taunted && NetProps.GetPropEntity(self, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn")) { self.Taunt(0, 0); scope.taunted = true }
			}
			
			for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_pipe"); )
			{
				if (ent.GetTeam() != 3) continue
				
				NetProps.SetPropBool(ent, "m_bTouched", false)
			
				ent.SetPhysVelocity(ent.GetPhysVelocity() + Vector(RandomInt(-500, 500), RandomInt(-500, 500), RandomInt(-500, 500)))
				
				if (NetProps.GetPropString(self, "m_szNetname").find("Revenge") != null)
				{
					ent.ValidateScriptScope()
					local scope = ent.GetScriptScope()
					
					if (!("trail" in scope))
					{
						ent.SetModelScale(2, -1)
						
						scope.trail <- SpawnEntityFromTable("trigger_particle",
						{
							attachment_type    = 1
							spawnflags 		   = 64
							particle_name      = "eyeboss_tp_vortex"
						})
						
						EntFireByHandle(scope.trail, "StartTouch", "!activator", -1, ent, ent)
						EntFireByHandle(scope.trail, "Kill", null, -1, null, null)
						
						AddThinkToEnt(ent, "PlayerMagnet_Think")
					}
				}
			}
		}
		
		scope.tick = scope.tick + 1
		
		return -1
	}

	PlayerMagnet_Think = function()
	{
		for (local player_to_attract; player_to_attract = Entities.FindByClassnameWithin(player_to_attract, "player", self.GetOrigin(), (RandomInt(1, 8) == 1) ? 500 : 50); )
		{
			if (player_to_attract != null && player_to_attract.GetTeam() == 2 && NetProps.GetPropInt(player_to_attract, "m_lifeState") == 0)
			{
				if (NetProps.GetPropEntity(player_to_attract, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn")) player_to_attract.SetOrigin(player_to_attract.GetOrigin() + Vector(0, 0, 24))
				player_to_attract.ApplyAbsVelocityImpulse((self.GetOrigin() - player_to_attract.GetOrigin()) * 0.5)
			}
		}
		
		return -1
	}

	FireFist_Think = function()
	{	
		local scope = self.GetScriptScope()
		
		if (!("init" in scope))
		{
			scope.init <- true
			
			PEA["firefist_gun"] <- Entities.CreateByClassname("tf_weapon_rocketlauncher"); getroottable()["firefist_gun"] <- PEA["firefist_gun"]

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
		}
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_rocket"); )
		{
			if (ent.GetOwner() == self)
			{
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
				
				ent.ValidateScriptScope()
				local scope = ent.GetScriptScope()
			
				if (!("fixed" in scope))
				{
					scope.fixed <- true
				
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
		
		return -1
	}
	
	/////////////////////////////////// CLASSES ///////////////////////////////////

	BotPathPoint = class
	{
		area = null
		pos = null
		how = null
		
		constructor(area, pos, how)
		{
			this.area = area
			this.pos = pos
			this.how = how
		}
	}

	CustomBotNavigation = class
	{
		me = null
		
		locomotion = null

		curtime = 0.0
		m_vecAbsOrigin = Vector()
		m_angAbsRotation = QAngle()
		m_vecEyePosition = Vector()
		
		path = []				
		path_index = 0

		path_target_pos = Vector()		
		path_update_time_next = 0.0
		path_update_force = false	
		path_areas = {}

		destination = null
		
		constructor(entity)
		{
			me = entity
			
			locomotion = me.GetLocomotionInterface()

			path_update_time_next = Time()
			path_update_force = true
		}
		
		function Update()
		{
			curtime = Time()
			m_vecAbsOrigin = me.GetOrigin()
			m_angAbsRotation = me.GetAbsAngles()
			m_vecEyePosition = m_vecAbsOrigin + Vector(0, 0, 72)

			if (destination == null) destination = me.GetScriptScope().navdest1
			
			Move()
			
			// local frame_time = FrameTime() * 2.0;

			// if (path.len() > 0)
			// {
				// local path_start_index = path_index
				
				// if (path_start_index == 0) path_start_index++
			
				// for (local i = path_start_index; i < path.len(); i++) DebugDrawLine(path[i - 1].pos, path[i].pos, 0, 255, 0, true, frame_time);
			// }
			
			// foreach (name, area in path_areas)
			// {
				// area.DebugDrawFilled(255, 0, 0, 30, frame_time, true, 0.0);
				// DebugDrawText(area.GetCenter(), name, false, frame_time);
			// }
		}
		
		function ResetPath()
		{
			path_areas.clear()
			path.clear()
			path_index = 0
			path_target_pos = null
		}

		function UpdatePath()
		{
			ResetPath()
			
			path_target_pos = destination

			local pos_start = m_vecAbsOrigin + Vector(0, 0, 1)
			local pos_end = path_target_pos + Vector(0, 0, 1)
			
			local area_start = NavMesh.GetNavArea(pos_start, 128.0)
			local area_end = NavMesh.GetNavArea(pos_end, 128.0)
			
			if (area_start == null) area_start = NavMesh.GetNearestNavArea(pos_start, 512.0, false, false)
			if (area_end == null) area_end = NavMesh.GetNearestNavArea(pos_end, 512.0, false, false)
			
			if (area_start == null || area_end == null) return false

			if (area_start == area_end)
			{
				path.append(BotPathPoint(area_end, pos_end, 9))
				return true
			}
			
			if (!NavMesh.GetNavAreasFromBuildPath(area_start, area_end, pos_end, 0.0, 2, false, path_areas)) return false

			if (path_areas.len() == 0) return false

			local area_target = path_areas["area0"]
			local area = area_target
			
			local area_count = path_areas.len()

			for (local i = 0; i < area_count && area != null; i++)
			{
				path.append(BotPathPoint(area, area.GetCenter(), area.GetParentHow()))
				area = area.GetParent()
			}
			
			path.append(BotPathPoint(area_start, m_vecAbsOrigin, 9))
			path.reverse()

			path.append(BotPathPoint(area_end, pos_end, 9))
		}

		function AdvancePath()
		{
			if (path.len() == 0) return false

			if ((path[path_index].pos - m_vecAbsOrigin).Length2D() < 32.0)
			{
				path_index++
				if (path_index >= path.len())
				{
					ResetPath()
					
					switch (destination)
					{
						case me.GetScriptScope().navdest1: destination = me.GetScriptScope().navdest2; break
						case me.GetScriptScope().navdest2: destination = me.GetScriptScope().navdest3; break
						case me.GetScriptScope().navdest3: destination = me.GetScriptScope().navdest4; break
						case me.GetScriptScope().navdest4: destination = me.GetScriptScope().navdest1; break
					}
					
					return false
				}
			}

			return true
		}

		function Move()
		{
			if (path_update_force)
			{
				UpdatePath()
				path_update_force = false
			}
			
			else if (path_update_time_next <= curtime)
			{
				UpdatePath()
				path_update_time_next = curtime + 0.5
			}

			if (AdvancePath())
			{
				local path_pos = path[path_index].pos

				locomotion.DriveTo(path_pos)
			}
		}
	}
}

try { IncludeScript("pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate or parse `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

ignite_player.AddAttribute("Set DamageType Ignite", 1, -1.0)
Entities.DispatchSpawn(ignite_player)

/////////////////////////////////// PARAMS ///////////////////////////////////
/////////////////////////////////// PRECACHING ///////////////////////////////////

PrecacheSound("vo/soldier_sf12_badmagic07.mp3")
PrecacheSound("mvm/mvm_tele_deliver.wav")
PrecacheSound("misc/rd_finale_beep01.wav")
PrecacheSound("ambient/explosions/explode_2.wav")
PrecacheSound("vo/mvm/mght/heavy_mvm_m_battlecry06.mp3")
PrecacheSound("misc/halloween/spell_fireball_impact.wav")
PrecacheSound("npc/combine_gunship/ping_search.wav")
PrecacheSound("ambient/medieval_thunder2.wav")
PrecacheSound("misc/halloween/spell_lightning_ball_impact.wav")
PrecacheSound("vo/demoman_laughshort05.mp3")
PrecacheSound("vo/demoman_mvm_resurrect01.mp3")
PrecacheSound("weapons/explode3.wav")
PrecacheSound("vo/halloween_merasmus/sf12_appears09.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_appears14.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_appears15.mp3")
PrecacheSound("merasmus_waitwhat.wav")
PrecacheSound("Halloween.WheelofFate")
PrecacheSound("weapons/wrench_hit_build_success1.wav")
PrecacheSound("weapons/wrench_hit_build_success2.wav")
PrecacheSound("vo/soldier_painsharp01.mp3")
PrecacheSound("vo/soldier_painsharp02.mp3")
PrecacheSound("vo/soldier_painsharp03.mp3")
PrecacheSound("vo/soldier_battlecry05.mp3")
PrecacheSound("vo/soldier_mvm_resurrect05.mp3")
PrecacheSound("vo/soldier_sf13_round_start02.mp3")
PrecacheSound("MVM.BombExplodes")
PrecacheSound("ui/halloween_boss_chosen_it.wav")
PrecacheSound("ambient/halloween/thunder_08.wav")
PrecacheSound("gamestartup18_cut.mp3")
PrecacheSound("merasmus_enough.wav")
PrecacheSound("vo/halloween_merasmus/sf12_leaving16.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_headbomb_hit02.mp3")
PrecacheSound("hwn_wheel_of_fate_onlybell.wav")
PrecacheSound("vo/halloween_merasmus/sf12_defeated12.mp3")
PrecacheSound("vo/soldier_hatoverhearttaunt06.mp3")

PrecacheModel("models/props_halloween/halloween_gift.mdl")
PrecacheModel("models/bots/boss_bot/boss_blimp.mdl")
PrecacheModel("models/empty.mdl")
PrecacheModel("models/bots/boss_bot/boss_blimp_damage1.mdl")
PrecacheModel("models/bots/boss_bot/boss_blimp_damage2.mdl")
PrecacheModel("models/bots/boss_bot/boss_blimp_damage3.mdl")

for (local i = 0; i <= giftsound_array.len() - 1; i++) PrecacheSound("misc/happy_birthday_tf_" + giftsound_array[i] + ".wav")

/////////////////////////////////// AUTOEXECUTE ///////////////////////////////////

Convars.SetValue("sv_turbophysics", 0)
ForceEscortPushLogic(2)

Convars.SetValue("tf_forced_holiday", 2)

EntFire("normal_gravity", "Kill")
EntFire("harvester_gravity", "Kill")
EntFire("cap_hatch_destroy_delete_prop", "Kill")
EntFire("cap_destroy_relay", "Kill")

for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++) // run this for when the first player connects to the server and the callback hasn't loaded yet
{
	local player = PlayerInstanceFromIndex(i)
	if (player == null) continue
	
	if (IsPlayerABot(player))
	{
		NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
		
		if (player.GetScriptScope() == null) continue
		
		foreach (thing in player.GetScriptScope())
		{
			try { thing.GetClassname() }
			catch (e) { continue }
			
			if (!thing.IsPlayer()) thing.Kill()
		}
		
		player.TerminateScriptScope()
	}
	
	else
	{
		player.ValidateScriptScope()
		local scope = player.GetScriptScope()
		
		if (!("saw_mission_info" in scope)) 
		{
			scope.saw_mission_info <- true
			ClientPrint(player, 4, "Prevent the robots from deploying their bomb underneath Soldier's statue!")
			ClientPrint(player, 3, "\x07FF3F3FPrevent the robots from deploying their bomb underneath Soldier's statue!")
		}
	}
}

EntityOutputs.RemoveOutput(Entities.FindByName(null, "capturezone_blue"), "OnCapture", "cap_hatch_glasswindow", "Break", null)
EntityOutputs.RemoveOutput(Entities.FindByName(null, "capturezone_blue"), "OnCapture", "cap_hatch_destroy_delete_prop", "Kill", null)
EntityOutputs.RemoveOutput(Entities.FindByName(null, "capturezone_blue"), "OnCapture", "cap_hatch_destroy_animated_prop", "Enable", null)

EntityOutputs.AddOutput(Entities.FindByName(null, "capturezone_blue"), "OnCapture", "statue", "Kill", null, -1.0, -1.0)

for (local ent; ent = Entities.FindByClassname(ent, "info_particle_system"); ) if (NetProps.GetPropString(ent, "m_iszEffectName") == "shingle_flyaway") ent.Kill()

if (Wave == 4) ConvertTankIconsToBlimp(true)

if (NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveCount") == 6)
{
	UnhideIcon("wheelofdoom_whammy", 9)
	
	for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		
		if (player == null) continue
		
		player.RemoveCustomAttribute("cancel falling damage")
	}
	
	ClientPrint(null,3,"\x0790EE90The forward Upgrade Station will always be open for the duration of this wave.")
	ClientPrint(null,4,"The forward Upgrade Station will always be open for the duration of this wave.")
}

/////////////////////////////////// AUTOEXECUTE ///////////////////////////////////

////////////////////////////////// DEBUGGING ///////////////////////////////////

if (debug)
{
	::PEA.OnGameEvent_player_say <- function(params)
	{
		local player = GetPlayerFromUserID(params.userid)

		if (params.text == "1")
		{
			ClientPrint(null,3,"" + NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount"))
		}
	}
	
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
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// DEBUGGING ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

__CollectGameEventCallbacks(PEA)