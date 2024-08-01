// vscript coding done by pealover

::SkinKing <-
{
    gamerules_entity = Entities.FindByName(null, "gamerules")

	mission = NetProps.GetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName")
	
	GetWave = function() { return NetProps.GetPropInt(Entities.FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount") }
	
	warmonger_died = false
	warmonger_death_origin = Vector()

	CALLBACKS =
	{
		OnGameEvent_recalculate_holidays = function(params) // do cleanup after mission switch
		{
			if (GetRoundState() == 3)
			{
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					
					if (player == null) continue
					if (player.IsFakeClient()) continue
					
					EmitSoundEx({ sound_name = "pizza_tower_war.mp3", filter_type = 4, entity = player, channel = 6, flags = 4 }) // stop playing boss theme on round restart
				}

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
					
					NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")

					player.TerminateScriptScope()
				}

				if (NetProps.GetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName") != mission || GetWave() != 6)
				{
					
					foreach (thing, var in SkinKing) if (thing in getroottable()) delete getroottable()[thing]

					delete ::SkinKing
					return
				}
			}
		}
		
		OnGameEvent_post_inventory_application = function(params)
		{
			local bot = GetPlayerFromUserID(params.userid);
			
			if (bot.IsFakeClient()) EntFireByHandle(bot, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
		}
	
		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			
			if (!dead_player.IsFakeClient()) return
			
			if (dead_player.HasBotTag("warmonger"))
			{
				warmonger_death_origin = dead_player.GetOrigin()
				
				EntFireByHandle(gamerules_entity, "CallScriptFunction", "WarMonger_Death", -1.0, null, null)
				
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/mvm/mght/soldier_mvm_m_painsharp02.mp3`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", -1.0, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/mvm/mght/soldier_mvm_m_autodejectedtie01.mp3`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 1.75, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/physics/robo_impact_soft_05.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 3.5, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/physics/robo_impact_soft_06.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.0, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `weapons/gunslinger_draw.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.6, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `physics/metal/metal_box_impact_bullet2.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.8, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `npc/attack_helicopter/aheli_damaged_alarm1.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.9, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/giant_soldier/giant_soldier_step02.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 5.75, null, null)
				
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/mvm/mght/soldier_mvm_m_painsharp02.mp3`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", -1.0, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/mvm/mght/soldier_mvm_m_autodejectedtie01.mp3`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 1.75, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/physics/robo_impact_soft_05.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 3.5, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/physics/robo_impact_soft_06.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.0, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `weapons/gunslinger_draw.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.6, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `physics/metal/metal_box_impact_bullet2.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.8, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `npc/attack_helicopter/aheli_damaged_alarm1.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 4.9, null, null)
				EntFireByHandle(dead_player, "RunScriptCode", "EmitSoundEx({ sound_name = `mvm/giant_soldier/giant_soldier_step02.wav`, filter_type = 5, sound_level = 75, entity = self, channel = 6})", 5.75, null, null)
			}
		}

		OnGameEvent_mvm_begin_wave = function(params)
		{
			if (GetWave() == 6)
			{
				ClientPrint(null, 3, "\x079AFF9ASong Name: Thousand March by Mr Sauceman")
				
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					
					if (player == null) continue
					if (player.IsFakeClient()) continue
					
					EmitSoundEx({ sound_name = "pizza_tower_war.mp3", filter_type = 4, entity = player, channel = 6, flags = 1 })
				}
			}
		}
	}
	
	WarMonger_Death = function()
	{
		warmonger_died = true

		SpawnEntityFromTable("prop_dynamic",
		{
			targetname     		 = "thebody_1"
			origin         		 = warmonger_death_origin
			skin 		   		 = 1
			modelscale	   		 = 1.75
			model          		 = "models/player/soldier.mdl"
			defaultanim    		 = "stand_melee"
			disablebonefollowers = 1
			renderamt			 = 0
			rendermode			 = 1
		})
		
		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			targetname     			= "thesoul_1"
			origin					= warmonger_death_origin
			model                   = "models/bots/soldier_boss/bot_soldier_boss.mdl"
			modelscale				= 1.75
			skin 					= 1
			disablebonefollowers	= 1
			initialowner			= "thebody_1"
		})
		
		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			targetname     			= "thesoul_1"
			model                   = "models/player/items/soldier/luckyshot.mdl"
			skin 					= 1
			disablebonefollowers	= 1
			initialowner			= "thebody_1"
		})
		
		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			targetname     			= "thesoul_1"
			model                   = "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl"
			skin 					= 1
			disablebonefollowers	= 1
			initialowner			= "thebody_1"
		})
		
		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			targetname     			= "thesoul_1"
			model                   = "models/weapons/c_models/c_pickaxe/c_pickaxe_s2.mdl"
			skin 					= 1
			disablebonefollowers	= 1
			initialowner			= "thebody_1"
		})

		function MongerDeathSequence_2()
		{
			EntFire("thebody_1", "Kill")
			EntFire("thesoul_1", "Kill")
			
			SpawnEntityFromTable("prop_dynamic",
			{
				targetname     		 = "thebody_2"
				origin         		 = warmonger_death_origin
				skin 		   		 = 1
				modelscale	   		 = 1.75
				model          		 = "models/player/soldier.mdl"
				defaultanim    		 = "taunt05"
				disablebonefollowers = 1
				renderamt			 = 0
				rendermode			 = 1
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				targetname     			= "thesoul_2"
				origin					= warmonger_death_origin
				model                   = "models/bots/soldier_boss/bot_soldier_boss.mdl"
				modelscale				= 1.75
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "thebody_2"
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				targetname     			= "thesoul_2"
				model                   = "models/player/items/soldier/luckyshot.mdl"
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "thebody_2"
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				targetname     			= "thesoul_2"
				model                   = "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl"
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "thebody_2"
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				targetname     			= "thesoul_2"
				model                   = "models/weapons/c_models/c_pickaxe/c_pickaxe_s2.mdl"
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "thebody_2"
			})
		}
		
		SpawnEntityFromTable("tf_generic_bomb",
		{
			targetname 		 = "lebomb"
			origin			 = warmonger_death_origin
			model 			 = "models/weapons/w_models/w_stickybomb2.mdl"
			health 			 = 10000000
			damage 			 = 8000
			radius 			 = 800 
			explode_particle = "fluidSmokeExpl_ring_mvm" 
			sound 		 	 = "ambient/explosions/explode_2.wav"
			modelscale   	 = 0
			friendlyfire 	 = 1
		})
		
		EntFireByHandle(gamerules_entity, "CallScriptFunction", "MongerDeathSequence_2", 2.5, null, null)
		
		EntFire("lebomb", "Detonate", null, 5.9)
		EntFire("thebody_2", "Kill", null, 6.15)
		EntFire("thesoul_2", "Kill", null, 6.15)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenShake(warmonger_death_origin, 16, 40.0, 3.0, 2500.0, 0, true)", 5.9, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "ScreenFade(null, 255, 255, 255, 255, 1.0, 0.5, 1)", 5.9, null, null)
	}

	BotTagCheck = function() { if (self.HasBotTag("warmonger")) AddThinkToEnt(self, "Warmonger_Think") }

	Warmonger_Think = function()
	{
		if (self.GetHealth() > 30000.0) self.AddWeaponRestriction(4)
		else							self.AddWeaponRestriction(2)

		if (warmonger_died)
		{
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				if (!player.IsFakeClient()) continue
				if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue
				
				player.TakeDamage(10000.0, 64, null)
			}
		}
	
		return -1
	}
}

foreach (thing, var in SkinKing) getroottable()[thing] <- getroottable()["SkinKing"][thing]

PrecacheSound("pizza_tower_war.mp3")
PrecacheSound("vo/mvm/mght/soldier_mvm_m_painsharp02.mp3")
PrecacheSound("vo/mvm/mght/soldier_mvm_m_autodejectedtie01.mp3")
PrecacheSound("mvm/physics/robo_impact_soft_05.wav")
PrecacheSound("mvm/physics/robo_impact_soft_06.wav")
PrecacheSound("weapons/gunslinger_draw.wav")
PrecacheSound("physics/metal/metal_box_impact_bullet2.wav")
PrecacheSound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
PrecacheSound("mvm/giant_soldier/giant_soldier_step02.wav")

PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl")
PrecacheModel("models/player/items/soldier/luckyshot.mdl")
PrecacheModel("models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl")
PrecacheModel("models/weapons/c_models/c_pickaxe/c_pickaxe_s2.mdl")
PrecacheModel("models/weapons/w_models/w_stickybomb2.mdl")

__CollectGameEventCallbacks(CALLBACKS)
