::PEA <-
{	
	wavecount = 6
	logname = "undead_dread/player.log"

	debug = false
	
	intel_entity = Entities.FindByName(null, "intel")
	
	custom_spawns = 
	[
		[ Vector(-576, -2464, -96), "spawnbot_support", 0 ],
		[ Vector(-576, -2464, -96), "spawnbot_support_2", 0 ],
		[ Vector(2296, -2832, 228), "spawnbot_side_support", 0 ],
		[ Vector(2296, -2832, 228), "spawnbot_side_support_2", 0 ],
		[ Vector(1000, -2800, -150), "spawnbot_tunnel", 0 ],
		[ Vector(1000, -2800, -150), "spawnbot_tunnel_support", 0 ],
		
		[ Vector(1330, -600, 250), "spawnbot_coffin_front", 0 ],
		[ Vector(1950, -1100, 300), "spawnbot_coffin_front", 0 ],
		[ Vector(100, -550, 300), "spawnbot_coffin_front", 0 ],
		
		[ Vector(-850, 450, -100), "spawnbot_coffin_middle", 0 ],
		[ Vector(1100, 600, 50), "spawnbot_coffin_middle", 0 ],
		[ Vector(1700, 1700, 250), "spawnbot_coffin_middle", 0 ],
		[ Vector(-1200, 1800, 300), "spawnbot_coffin_middle", 0 ],
		[ Vector(600, 1050, 300), "spawnbot_coffin_middle", 0 ],
		
		[ Vector(-50, 2400, -350), "spawnbot_coffin_back", 0 ],
		[ Vector(900, 2500, -100), "spawnbot_coffin_back", 0 ],
		[ Vector(1150, 3950, 100), "spawnbot_coffin_back", 0 ],
		[ Vector(-300, 3500, 100), "spawnbot_coffin_back", 0 ],
		
		[ Vector(-576, -2464, -96), "spawnbot_samurai", 1 ],
		[ Vector(-576, -2464, -96), "spawnbot_samurai_2", 1 ],
		[ Vector(-50, 2400, -350), "spawnbot_secretwave", 1 ]
	]

	finalpath = []

	medicshotgun_soundarray = ["autodejectedtie02", "jeers05", "specialcompleted02", "specialcompleted12"]
	
	bombhop_responses =
	{
		scout = [2512, 2513, 2514, 2515, 2516, 2517],
		demoman = [7719, 7720],
		heavy = [1990, 2070, 2268],
		sniper = [2335, 2444, 2445],
		sniper_scope = [2519, 2542, 2543]
	}
	
	next_zombiespawnsound_time = 0
	
	duckyspawn_time = 0
	duckyspawn_amount = 0
	duckyspawn_pickups = 0
	duckyspawn_locations =
	[
		Vector(-1100, 1800, 300)
		Vector(-900, 300, 0),
		Vector(-400, 150, 500),
		Vector(375, 2650, -200),
		Vector(600, 1250, 300),
		Vector(2100, 450, 100),
	]
	
	in_snatcher_cutscene = false
	hatchsnatcher_cutsceneover = false
	endshaking = false
	secretwave = 5
	secretwave_startmusic_suppressed = false
	
	bombhoptime = 10.0
	bombhoptime_base = 10.0
	
	time = 1
	minutes = 0
	
	blocknav_array = []
	
	bombnearhatch = false
	nextconchsoundtime = 0.0
	
	coffinoverlaytime = 0.0
	
	megatonicon = Entities.CreateByClassname("info_particle_system")
	
	shuffle_wavespawn_table =
	{
		w2b =
		{
			names 	= ["demo_fire_2", "pyro_flare"],
			amounts = [8, 16]
		}
		
		w3e =
		{
			names 	= ["easyheavy", "normalheavy"],
			amounts = [8, 7]
		}
	}
	
	cross_connections =
	[
		[],        // dummy
		[2, 3],    // 1
		[4, 7],    // 2
		[5, 7],    // 3
		[7],       // 4
		[6, 8],    // 5
		[8],   	   // 6
		[6, 8],    // 7
		[] 		   // 8 (hatch)
	]
	
	coffin_sounds =
	[
		"ui/item_contract_tracker_pickup.wav"
		"ui/item_contract_tracker_drop.wav"
		"ui/item_boxing_gloves_pickup.wav"
		"ui/item_cardboard_pickup.wav"
		"ui/item_crate_drop.wav"
		"ui/item_default_drop.wav"
	]
	
	coffin_locations =
	[
		Vector(1330, -600, 250) // front
		Vector(1950, -1100, 300) // front
		Vector(100, -550, 300) // front
		Vector(-850, 450, -100) // middle
		Vector(1100, 600, 50) // middle
		Vector(1700, 1700, 250) // middle
		Vector(-1200, 1800, 300) // middle
		Vector(600, 1050, 300) // middle
		Vector(-50, 2400, -350) // back
		Vector(900, 2500, -100) // back
		Vector(1150, 3950, 100) // back
		Vector(-300, 3500, 100) // back
	]
	
	BotTagCheck = function()
	{
		if (!self.IsOnAnyMission()) self.AddBotTag("nonzombie")
		
		if (NetProps.GetPropInt(self, "m_nRenderMode") != 0) self.KeyValueFromInt("rendermode", 0)
		
		if (self.IsMiniBoss()) self.AddBotTag("bot_giant")

		for (local ent; ent = Entities.FindByNameWithin(ent, "coffin_prop", self.GetOrigin(), 250.0); )
		{
			self.RemoveBotTag("nonzombie")
			
			self.Zombify()

			if (sigmod) self.AddCustomAttribute("force distribute currency on death", 1, -1.0)
		
			if (self.IsMiniBoss())
			{
				AttachGlow("125 168 196 255")
				
				function DelayedAnnotation()
				{
					SendGlobalGameEvent("show_annotation", 
					{
						id = self.entindex()
						text = "Danger!"
						follow_entindex = self.GetScriptScope().glow.entindex()
						play_sound = "misc/null.wav"
						show_distance = true
						show_effect = false
						lifetime = 7.5
					})
				}
				
				EntFireByHandle(self, "CallScriptFunction", "DelayedAnnotation", 0.2, null, null) // calling this earlier will make the annotation spawn at world origin

				EmitGlobalSound("MVM.GiantHeavyEntrance")
			}

			ent.ResetSequence(ent.LookupSequence("taunt_the_crypt_creeper_A2"))

			if (Time() >= next_zombiespawnsound_time) 
			{
				EmitGlobalSound("Player.IsNowIT")
				
				next_zombiespawnsound_time = Time() + 1.0
			}
			
			break
		}
		
		if (self.HasBotTag("test"))
		{
			// for (local ent; ent = Entities.FindInSphere(ent, self.GetOrigin(), 250.0); )
			// {
				// ClientPrint(null,3,"" + ent.GetModelName())
			// }
			
			// GetWearable.call(self.GetActiveWeapon().GetScriptScope(), "models/weapons/w_models/w_baseball.mdl", false, "weapon_bone")
			
			// self.SetCustomModelWithClassAnimations("models/bots/demo/bot_sentry_buster.mdl")
			// self.Teleport(true, Vector(642.364, 3544.41, -206), false, QAngle(), false, Vector())
			// self.Teleport(true, intel_entity.GetOrigin(), false, QAngle(), false, Vector())
			// EntFireByHandle(self, "RunScriptCode", "self.TakeDamage(10000.0, 64, self)", 2.0, null, null)
			
			self.Teleport(true, Vector(550, 4600, 0), false, QAngle(), false, Vector())
			
			EntFireByHandle(self, "RunScriptCode", "GetShotgunVM.call(self.GetScriptScope())", 3.0, null, null)
			EntFireByHandle(self, "RunScriptCode", "self.Weapon_Switch(NetProps.GetPropEntityArray(self, `m_hMyWeapons`, 1))", 6.0, null, null)
			EntFireByHandle(self, "RunScriptCode", "self.Weapon_Switch(NetProps.GetPropEntityArray(self, `m_hMyWeapons`, 2))", 9.0, null, null)
			EntFireByHandle(self, "RunScriptCode", "self.Weapon_Switch(NetProps.GetPropEntityArray(self, `m_hMyWeapons`, 0))", 12.0, null, null)
			EntFireByHandle(self, "RunScriptCode", "self.Weapon_Switch(NetProps.GetPropEntityArray(self, `m_hMyWeapons`, 1))", 15.0, null, null)
			EntFireByHandle(self, "RunScriptCode", "self.Weapon_Switch(NetProps.GetPropEntityArray(self, `m_hMyWeapons`, 2))", 18.0, null, null)
			
			// self.Zombify()
		}
		
		if (self.HasBotTag("conch"))
		{
			self.AddCustomAttribute("health regen", 4.0, -1.0)
			
			self.GetWearable("models/workshop_partner/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl")
			self.GetWearable("models/workshop_partner/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl")
			
			if (thinkertick >= nextconchsoundtime)
			{
				self.EmitSound("Samurai.Conch")
				nextconchsoundtime = thinkertick + 66
			}
			
			AddThinkToEnt(self, "Conch_Think")
		}
		
		if (self.HasBotTag("ballman"))
		{
			self.AddCustomAttribute("head scale", 0.1, -1.0)
			self.GetWearable("models/weapons/w_models/w_baseball.mdl", false, "head")
			AddThinkToEnt(self.GetActiveWeapon(), "Ballman_Think")
		}
		
		if (self.HasBotTag("firedemo"))
		{
			self.GetWearableItem(105)
			AddThinkToEnt(self.GetActiveWeapon(), "FireDemo_Think")
		}
		
		if (self.HasBotTag("medic_shotgun"))
		{
			self.GetWearable("models/weapons/w_models/w_shotgun.mdl", false, "head", [Vector(0, -15, -10), QAngle(0, 90, 0)])
			
			AddThinkToEnt(self, "MedicShotgun_Think")
		}
		
		if (self.HasBotTag("samurai_soldier"))
		{
			self.AddCustomAttribute("health regen", 4.0, -1.0)
			
			self.GetWearable("models/workshop_partner/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl")
			self.GetWearable("models/workshop_partner/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl")
			
			AddThinkToEnt(self, "SamuraiSoldier_Think")
		}
		
		if (self.HasBotTag("secretwave_skip")) self.TakeDamage(10000.0, 64, self)
		
		if (self.HasBotTag("hatch_snatcher")) AddThinkToEnt(self, "HatchSnatcher_Think")

		if (Wave == 5 && secretwave_unlocked)
		{
			if (!self.HasBotTag("hatch_snatcher"))
			{
				SpawnEntityFromTable("item_teamflag",
				{
					targetname			= "fakeintel"
					origin	 			= self.GetOrigin()
					trail_effect 		= 1
					TeamNum				= 3
					ScoringType			= 0
					ReturnTime			= 60000
					ReturnBetweenWaves	= 1
					NeutralType			= 1
					GameType			= 1
					flag_trail			= "flagtrail"
					flag_paper			= "player_intel_papertrail"
					flag_model			= "models/props_td/atom_bomb.mdl"
					flag_icon			= "../hud/objectives_flagpanel_carried"
					OnDrop 				= "!self,Kill,,0,-1"
					OnReturn 			= "!self,Kill,,0,-1"
				})
			}
		}
	}
	
	CALLBACKS =
	{
		OnGameEvent_player_spawn = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)
			
			if (player.IsFakeClient()) { EntFireByHandle(player, "CallScriptFunction", "BotTagCheck", -1.0, null, null); return }

			if (player.GetScriptScope() == null) player.ValidateScriptScope()
			
			player.AddCustomAttribute("vision opt in flags", 2, -1)
		
			local scope = player.GetScriptScope()
			
			if (!("lastfetchresults" in scope)) EntFireByHandle(player, "RunScriptCode", "IsInLog.call(self.GetScriptScope())", -1.0, null, null) // needs to be delayed because steamid isn't available yet

			if ("hashatchwep" in scope)
			{
				if (scope.hashatchwep)
				{
					local classname
					
					if (player.GetPlayerClass() == 1) classname = "tf_weapon_bat"
					else if (player.GetPlayerClass() == 8) classname = "tf_weapon_knife"
					else if (player.GetPlayerClass() == 9) classname = "tf_weapon_wrench"
					else classname = "tf_weapon_club"
					
					local hatchwep = player.GetWeapon(classname, 30758)
					
					local vm = NetProps.GetPropEntity(player, "m_hViewModel")
					
					NetProps.SetPropInt(hatchwep, "m_nRenderMode", 1)
					NetProps.SetPropInt(hatchwep, "m_clrRender", 0)

					AddThinkToEnt(hatchwep, "HatchVM_Think")
				}
			}
			
			if ("hasshotgunwep" in scope)
			{
				local killarray = []
				
				for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
				{ 
					if ("custom_wearable" in child.GetScriptScope() && NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 3) != GetModelIndex("models/props_mvm/mann_hatch.mdl")) killarray.append(child)
				}
				
				foreach (ent in killarray) ent.Kill()
				
				if (scope.hasshotgunwep) GetShotgunVM.call(scope)
				else NetProps.SetPropInt(player, "m_nRenderMode", 0)
			}
		}
		
		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			local attacker = GetPlayerFromUserID(params.attacker)
			
			if (dead_player.GetPlayerClass() == 5 && dead_player.GetTeam() == 2) dead_player.SetCustomModelWithClassAnimations("")
		}

		OnGameEvent_player_say = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)
			
			if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
			{
				if (params.text == "!s")
				{
					secretwave_unlocked = true
					ClientPrint(null, 4, "You've unlocked the secret bonus wave!")
					EmitGlobalSound("ui/mm_level_four_achieved.wav")

					NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineMaxWaveCount", 6)
				}
				
				if (params.text == "!f")
				{
					if (sigmod)
					{
						suppress_waveend_music = true
						
						local pop = SpawnEntityFromTable("point_populator_interface", {})
						pop.AcceptInput("$FinishWave", null, null, null)
					}
				}
				
				if (params.text == "t")
				{
					// Entities.FindByName(null, "spawnbot_tunnel").AcceptInput("Enable", null, null, null)
					// EntFire("spawnbot_tunnel", "Disable", null, 0.1, null)
					// intel_entity.SetAbsOrigin(player.GetOrigin())
					
					foreach (player in GetAllPlayers()) ClientPrint(null,3,"" + player)
					
					// ClientPrint(null,3,"" + NetProps.GetPropInt(intel_entity, "m_Collision.m_usSolidFlags"))
				}
			}
		}
		
		OnGameEvent_mvm_begin_wave = function(params)
		{
			if (intel_entity.GetScriptScope() != null)
			{
				intel_entity.TerminateScriptScope()
				NetProps.SetPropString(intel_entity, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(intel_entity, null)
			}

			intel_entity.ValidateScriptScope()
			AddThinkToEnt(intel_entity, "BombHop_Think")

			NetProps.SetPropInt(intel_entity, "m_Collision.m_nSolidType", 2)
			NetProps.SetPropInt(intel_entity, "m_Collision.m_usSolidFlags", 140)
			
			for (local ent; ent = Entities.FindByName(ent, "gallery_*"); ) ent.Kill()
			if ("WeaponGallery_Think" in getroottable()["ThinksTable"]) RemoveThinkFromThinksTable("WeaponGallery_Think")

			HideIcon("dead_blu_lite") // hiding a non-wavespawn represented icon removes it outright
			
			if (!secretwave_unlocked)
			{
				NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineMaxWaveCount", 5)
				
				if (Wave == 6) NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveCount", 5)
			}
			
			for (local ent; ent = Entities.FindByModel(ent, "models/props_mvm/robot_hologram.mdl"); ) ent.Kill()
			
			ModifyWaveBar()
			
			foreach (player in GetAllPlayers(2)) ProgressLog.call(player.GetScriptScope())
		}
		
		OnGameEvent_mvm_wave_complete = function(params)
		{
			if (Wave == 4)
			{
				for (local ent; ent = Entities.FindByModel(ent, "models/items/target_duck.mdl"); )
				{
					AddThinkToEnt(ent, null)
					NetProps.SetPropString(ent, "m_iszScriptThinkFunction", "")
					ent.Kill()
				}
			}

			if (Wave == 5)
			{
				if (!secretwave_unlocked)
				{
					suppress_waveend_music = true
					EntFireByHandle(gamerules_entity, "RunScriptCode", "suppress_waveend_music = false", 0.03, null, null)
					EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`music.mvm_end_tank_wave`)", 0.06, null, null)
				}
				
				else
				{
					Entities.FindByName(null, "fakehatch").Kill()
					Entities.FindByName(null, "hatch").SetOrigin(Vector(642.364, 3544.41, -206))
					Entities.FindByName(null, "capturezone_red").SetOrigin(Vector(642.364, 3544.41, -206))
					
					for (local ent; ent = Entities.FindByName(ent, "fakeintel"); ) ent.Kill()
				}
			}
			
			if (Wave == 6) secretwave_unlocked = false
			
			foreach (player in GetAllPlayers(2)) ProgressLog.call(player.GetScriptScope())
		}
		
		OnGameEvent_teamplay_flag_event = function(params)
		{
			if (params.eventtype == 1)
			{
				local intelscope = intel_entity.GetScriptScope()
				
				intelscope.restoredhoptimepenalty = (intelscope.restoredhoptime / 30.0)
			}
			
			if (params.eventtype == 4)
			{
				if (thinkertick < intel_entity.GetScriptScope().activationtime) return
				intel_entity.GetScriptScope().DetermineReturnTime()
			}
		}
		
		OnGameEvent_player_changeclass = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)
			
			if (player.IsFakeClient()) return
			
			if ("modsactive" in player.GetScriptScope())
			{
				player.GetScriptScope().modsactive.loch = false
				player.GetScriptScope().modsactive.bow = false
			}
			
			if ("hashatchwep" in player.GetScriptScope()) player.GetScriptScope().hashatchwep = false
			if ("hasshotgunwep" in player.GetScriptScope()) player.GetScriptScope().hasshotgunwep = false
		}
		
		OnScriptHook_OnTakeDamage = function(params)
		{
			local inflictor = params.inflictor
			local victim = params.const_entity
			local attacker = params.attacker
			local weapon = params.weapon
			
			if (inflictor.GetClassname() == "obj_sentrygun")
			{
				local scope = inflictor.GetScriptScope()
				
				if (scope == null) return
				if (!("balled" in scope)) return
				else
				{
					if (scope.balled == 0 && NetProps.GetPropInt(inflictor, "m_iUpgradeLevel") > 1)
					{
						if (scope.blocknextshot)
						{
							params.early_out = true
							scope.blocknextshot = false
						}
						
						else scope.blocknextshot = true
					}
				}
			}
			
			if (!attacker.IsPlayer() || !victim.IsPlayer()) return
			
			if (NetProps.GetPropString(weapon, "m_iszScriptThinkFunction") == "FireDemo_Think")
			{
				if (params.damage_type & 64) victim.TakeDamageEx(inflictor, attacker, ignite_player, Vector(), victim.GetOrigin(), 0.01, 8)
			}
			
			if (attacker.GetPlayerClass() == 2 && params.damage_custom == 22)
			{
				params.weapon = params.weapon.GetScriptScope().weapon // the stunball projectile is the weapon by default, changing it to the bow that fired it
				weapon = params.weapon
				
				params.damage = inflictor.GetScriptScope().weapon.GetScriptScope().damage
				params.damage_type = 2
				
				local attach = "head"
				local offsets = [Vector(0, 0, 1), QAngle()]
				local scale = 1.25
				local duration = 7.5

				if (victim.IsFakeClient())
				{
					if (victim.HasBotTag("sentrybuster"))
					{
						attach = "flag"
						offsets = [Vector(0, 0, -10), QAngle()]
						scale = 3.0
						duration = 3600.0
						
						SetFakeClientConVarValue(victim, "name", "Ball Buster")
					}
				}
				
				if ("ballent" in victim.GetScriptScope())
				{
					victim.GetScriptScope().ballent.GetScriptScope().endtime = Time() + duration
					return
				}

				local ballhat = victim.GetWearable("models/weapons/w_models/w_baseball.mdl", false, attach, offsets)
				ballhat.SetModelScale(scale, -1.0)
				
				victim.GetScriptScope().ballent <- ballhat
				
				ballhat.ValidateScriptScope()
				ballhat.GetScriptScope().ignite <- false

				if (inflictor.GetScriptScope().ignite)
				{
					local particle = SpawnEntityFromTable("trigger_particle",
					{
						particle_name = "m_brazier_flame"
						attachment_type = 1
						spawnflags = 64
					})
					
					NetProps.SetPropBool(particle, "m_bForcePurgeFixedupStrings", true)
					
					particle.AcceptInput("StartTouch", "!activator", ballhat, ballhat)
					particle.Kill()
					
					ballhat.GetScriptScope().owner <- attacker
					ballhat.GetScriptScope().ignite = true
				}
				
				if (victim.IsFakeClient()) { if (inflictor.GetScriptScope().fullstun && !victim.IsMiniBoss()) victim.StunPlayer(5.0, 0.5, 320, inflictor) }

				if (NetProps.GetPropBool(inflictor, "m_bCritical")) params.damage_type += 1048576

				victim.AddCustomAttribute("head scale", 0.1, -1.0)

				AddThinkToEnt(ballhat, "BallHead_Think")
			}
			
			if (victim.IsFakeClient())
			{
				if (!victim.IsAlive()) return
				
				if (victim.HasBotTag("hatch_snatcher"))
				{
					if (attacker.GetPlayerClass() == 3 || attacker.GetPlayerClass() == 6)
					{
						if (weapon.GetAttribute("rocket specialist", -1.0) != -1.0)
						{
							weapon.AddAttribute("rocket specialist", attacker.GetScriptScope().rocketspecialist, -1.0)
							EntFireByHandle(weapon, "RunScriptCode", "self.AddAttribute(`rocket specialist`, 0.0 , -1.0)", -1.0, null, null)
						}
						
						if (weapon.GetAttribute("slow enemy on hit", -1.0) != -1.0)
						{
							weapon.AddAttribute("slow enemy on hit", 0.2, -1.0)
							EntFireByHandle(weapon, "RunScriptCode", "self.AddAttribute(`slow enemy on hit`, 1.0 , -1.0)", -1.0, null, null)
						}
					}
				}
				
				if (victim.HasItem() && weapon != null)
				{
					if (attacker.GetTeam() == 2 && weapon.GetScriptScope() != null)
					{
						if ("hatchwepprop" in weapon.GetScriptScope() && params.damage_type != 1048640)
						{
							victim.EmitSound("MVM.BombExplodes")
							
							params.inflictor = megatonicon
							inflictor = megatonicon

							foreach (player in GetAllPlayers(false, [victim.GetOrigin(), 300.0]))
							{
								if (player.GetTeam() == 2 && attacker != player) continue
								
								player.TakeDamageEx(megatonicon, attacker, weapon, Vector(0, 0, 0), victim.GetOrigin(), params.damage, 1048576 + 64)
								
								DispatchParticleEffect("explosionTrail_seeds_mvm", victim.GetOrigin(), Vector(0, 90, 0))
								DispatchParticleEffect("fluidSmokeExpl_ring_mvm", victim.GetOrigin(), Vector(0, 90, 0))
								
								ScreenShake(victim.GetOrigin(), 25.0, 5.0, 5.0, 1000.0, 0, true)
								ScreenFade(player, 255, 255, 255, 255, 1.0, 0.1, 1)
							}
						}
					}
				}
				
				if (victim.HasBotTag("bonk"))
				{
					if (victim.HasBotAttribute(8))
					{
						victim.RemoveBotAttribute(8)
						victim.ClearAllWeaponRestrictions()
						victim.AddWeaponRestriction(1)
						
						foreach (player in GetAllPlayers(3, [victim.GetOrigin(), 450.0]))
						{
							if (player == victim) continue
							if (player.HasBotTag("bonk"))
							{
								if (player.HasBotAttribute(8))
								{
									player.RemoveBotAttribute(8)
									player.ClearAllWeaponRestrictions()
									player.AddWeaponRestriction(1)
								}
							}
						}
					}
				}
			}
		}
	}
	
	DisplayWeaponGallery = function()
	{
		if ("WeaponGallery_Think" in getroottable()["ThinksTable"]) return
		
		local lochmodprop = SpawnEntityFromTable("prop_dynamic",
		{
			targetname 			 = "gallery_loch"
			origin             	 = Vector(435, 5150, 0)
			disablebonefollowers = 1
			solid				 = 6
			model 			   	 = "models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl"
		})
		
		local color = (150) | (69 << 8) | (0 << 16) | (0 << 24)
		NetProps.SetPropInt(lochmodprop, "m_clrRender", color)
		
		local lochmodpropflame = SpawnEntityFromTable("trigger_particle",
		{
			particle_name = "m_brazier_flame"
			attachment_type = 4
			attachment_name = "muzzle"
			spawnflags = 64
		})

		lochmodpropflame.AcceptInput("StartTouch", "!activator", lochmodprop, lochmodprop)
		lochmodpropflame.Kill()

		local bowmodprop = SpawnEntityFromTable("prop_dynamic",
		{
			targetname 			 = "gallery_bow"
			origin             	 = Vector(500, 5150, 0)
			disablebonefollowers = 1
			solid				 = 6
			model 			   	 = "models/weapons/c_models/c_bow/c_bow.mdl"
		})
		
		local bowmodpropball = SpawnEntityFromTable("prop_dynamic",
		{
			origin             	 = bowmodprop.GetOrigin()
			disablebonefollowers = 1
			model 			   	 = "models/weapons/w_models/w_baseball.mdl"
		})
		
		bowmodpropball.AcceptInput("SetParent", "!activator", bowmodprop, null)
		EntFireByHandle(bowmodpropball, "SetParentAttachment", "muzzle", 0.1, null, null)
		
		local shotgunmodprop = SpawnEntityFromTable("prop_dynamic",
		{
			targetname 			 = "gallery_shotgun"
			origin             	 = Vector(565, 5150, 0)
			disablebonefollowers = 1
			solid				 = 6
			model 			   	 = "models/weapons/w_models/w_shotgun.mdl"
		})

		local hatchwepprop = SpawnEntityFromTable("prop_dynamic", // scaled models retain old collision so it's impossible to trace accurately on the small hatch
		{
			targetname 			 = "gallery_hatch"
			origin             	 = Vector(635, 5150, 0)
			angles				 = QAngle(60, -90, 0)
			modelscale			 = 0.1
			disablebonefollowers = 1
			solid				 = 6
			model 			   	 = "models/props_mvm/mann_hatch.mdl"
		})

		local hatchwepprop2 = SpawnEntityFromTable("prop_dynamic",
		{
			targetname 			 = "gallery_hatch"
			origin             	 = Vector(635, 5150, 0)
			disablebonefollowers = 1
			solid				 = 6
			rendermode			 = 1
			renderamt			 = 0
			model 			   	 = "models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl"
		})
		
		AssignThinkToThinksTable("WeaponGallery_Think")
	}
	
	EquipWeaponMod = function(weapon, refresh = false)
	{
		local scope = self.GetScriptScope()
		
		local validweaponclasses = []
		local success = false
		
		switch (weapon)
		{
			case "loch":
			{
				validweaponclasses = ["grenadelauncher", "cannon"]
				break
			}
			
			case "bow":
			{
				validweaponclasses = ["compound_bow"]
				break
			}
		}
		
		for (local i = 0; i <= 2; i++)
		{
			local myweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			
			if (myweapon == null) continue
			
			for (local j = 0; j <= validweaponclasses.len() - 1; j++)
			{
				if (myweapon.GetClassname().slice(10) == validweaponclasses[j])
				{
					success = true

					switch (weapon)
					{
						case "bow":
						{
							if (refresh && scope.modsactive.bow)
							{
								AddThinkToEnt(myweapon, "Ballman_Think")
								break
							}
							
							EmitSoundEx({ sound_name = "Weapon_BaseballBat.HitBall", filter_type = 4, entity = self, channel = 6 })
							
							if (!scope.modsactive.bow)
							{
								scope.modsactive.bow = true
								
								AddThinkToEnt(myweapon, "Ballman_Think")
							}
							
							else
							{
								scope.modsactive.bow = false
								
								NetProps.SetPropString(myweapon, "m_iszScriptThinkFunction", "")
								AddThinkToEnt(myweapon, null)
							}

							break
						}
						
						case "loch":
						{
							if (refresh && scope.modsactive.loch)
							{
								myweapon.SetClip1(2)
								
								myweapon.AddAttribute("sticky air burst mode", 2.0, -1.0)
								myweapon.AddAttribute("clip size penalty", 0.5, -1.0)
								myweapon.AddAttribute("fire rate penalty HIDDEN", 1.4, -1.0)
								
								AddThinkToEnt(myweapon, "FireDemo_Think")
								break
							}
							
							EmitSoundEx({ sound_name = "Taunt.Pyro02Fire", filter_type = 4, entity = self, channel = 6 })
							
							if (!scope.modsactive.loch)
							{
								scope.modsactive.loch = true

								myweapon.SetClip1(2)
								
								myweapon.AddAttribute("sticky air burst mode", 2.0, -1.0)
								myweapon.AddAttribute("clip size penalty", 0.5, -1.0)
								myweapon.AddAttribute("fire rate penalty HIDDEN", 1.4, -1.0)
								
								AddThinkToEnt(myweapon, "FireDemo_Think")
							}
							
							else
							{
								scope.modsactive.loch = false

								myweapon.RemoveAttribute("sticky air burst mode")
								myweapon.RemoveAttribute("clip size penalty")
								myweapon.RemoveAttribute("fire rate penalty HIDDEN")
								
								NetProps.SetPropString(myweapon, "m_iszScriptThinkFunction", "")
								AddThinkToEnt(myweapon, null)
							}

							break
						}
					}
				}
			}
		}
		
		if (!refresh && !success) ClientPrint(self, 4, "You don't have a valid weapon to apply this mod to")
	}

	ModifyWaveBar = function(init = false)
	{
		switch (Wave)
		{
			case 1:
			{
				if (!init) HideIcon("scout")
				
				break
			}
			case 2:
			{
				if (init) AddIcon("dead_blu_lite", 2, 0)
				
				AddToIcon("demo_fire_2", 8)
				AddToIcon("pyro_flare", 16)
				
				break
			}
			case 3:
			{
				if (init) AddIcon("dead_blu_lite", 2, 0)
				else
				{
					HideIcon("soldier")
					HideIcon("pyro")
					HideIcon("scout_stun")
				}
				
				break
			}
			case 4:
			{
				if (init) AddIcon("dead_blu_lite", 2, 0)
				else
				{
					HideIcon("medic")
					HideIcon("scout_shortstop")
					
					duckyspawn_time = thinkertick + 4000
					AssignThinkToThinksTable("DuckySpawn_Think")
				}
				
				break
			}
			case 5:
			{
				UnhideIcon("hatch_nys", 9)
				UnhideIcon("pyro_giant", 25)
				UnhideIcon("medic_giant", 9)
				UnhideIcon("scout_giant_fast", 9)
				
				if (init)
				{
					if (secretwave_unlocked) DisableSpawn("secretwave")
					
					else
					{
						NetProps.SetPropFloat(gamerules_entity, "m_flRestartRoundTime", Time())
						EnableSpawn("secretwave")
					}
				}
				
				else if (secretwave_unlocked) HatchSnatcherIntroCutscene()
				
				break
			}
			case 6:
			{
				UnhideIcon("soldier_crit", 17)
				
				SetTotalEnemyCount(GetTotalEnemyCount() + 27)
				
				break
			}
		}
	}

	DetermineBombPath = function(num)
	{	
		local choice = cross_connections[num][RandomInt(0, cross_connections[num].len() - 1)]
		
		finalpath.append(choice)
		
		switch (num)
		{
			case 1:
			{
				CreatePathHologram(Vector(13, -1831, -50), QAngle(0, 0, 0))
				CreatePathHologram(Vector(532, -1832, -50), QAngle(0, 0, 0))
				
				EntFire("sentrynest_right6", "Enable")
				EntFire("sentrynest_left4", "Enable")
				EntFire("sentrynest_left6", "Enable")
				
				switch (choice)
				{
					case 2:
					{
						guaranteedbranch = 2
						
						SpawnNavBrush("nav_avoid_middle_front", Vector(1000, -900, 0), "-200 -100 -150", "200 100 150", "bomb_carrier")
						
						CreatePathHologram(Vector(1010, -1546, -50), QAngle(0, 120, 0))
						CreatePathHologram(Vector(752, -1232, 50), QAngle(0, 180, 0))
						CreatePathHologram(Vector(241, -1236, 50), QAngle(0, 180, 0))
						
						EntFire("sentrynest_right5", "Enable")
						
						break
					}
					case 3:
					{
						guaranteedbranch = 3
						
						CreatePathHologram(Vector(1010, -1546, -50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(999, -817, 50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(987, -313, 50), QAngle(0, 90, 0))
						
						break
					}
					// case 5: scrapped for being too chokeholdy
					// {
						// SpawnNavBrush("nav_avoid_left_front", Vector(500, -1200, 0), "-200 -250 -250", "200 250 250", "bomb_carrier common")
						// SpawnNavBrush("nav_avoid_middle_front", Vector(1000, -900, 0), "-200 -100 -150", "200 100 150", "bomb_carrier")
						
						// SpawnNavBrush("nav_avoid_right_flank_front_2", Vector(1150, -300, 250), "-150 -100 -100", "150 100 100", "bomb_carrier common")
						// SpawnNavBrush("nav_avoid_right_rightmiddle_2", Vector(1700, -100, 100), "-250 -50 -250", "250 50 250", "bomb_carrier")
						// SpawnNavBrush("nav_avoid_left_rightmiddle", Vector(400, 100, 50), "-150 -250 -250", "150 250 250", "bomb_carrier common")
						
						// CreatePathHologram(Vector(1010, -1546, -50), QAngle(0, 90, 0))
						// CreatePathHologram(Vector(1010, -1100, -50), QAngle(0, 0, 0))
						// CreatePathHologram(Vector(1525, -1100, 150), QAngle(0, 90, 0))
						// CreatePathHologram(Vector(1525, -300, 300), QAngle(0, 0, 0))
						// CreatePathHologram(Vector(2050, -300, 300), QAngle(0, 90, 0))
						// CreatePathHologram(Vector(2050, 400, 300), QAngle(0, 120, 0))
						
						// break
					// }
				}
				
				break
			}
			case 2:
			{	
				switch (choice)
				{
					case 4:
					{	
						CreatePathHologram(Vector(-242, -1100, 150), QAngle(0, 110, 0))
						CreatePathHologram(Vector(-444, -349, 100), QAngle(0, 90, 0))
						CreatePathHologram(Vector(-436, 108, 150), QAngle(0, 0, 0))
						
						break
					}
					case 7:
					{
						SpawnNavBrush("nav_avoid_right_flank_front", Vector(1550, -700, 150), "-150 -200 -250", "150 200 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_right_leftfront", Vector(-300, -900, 100), "-125 -250 -100", "150 250 100", "bomb_carrier nonzombie")
						
						SpawnNavBrush("nav_avoid_right_rightmiddle", Vector(1400, 100, 0), "-200 -250 -250", "200 250 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_left_rightmiddle", Vector(400, 100, 50), "-150 -250 -250", "150 250 250", "bomb_carrier nonzombie")
						
						SpawnNavBrush("nav_avoid_left_leftmiddle", Vector(150, 500, 100), "-200 -175 -250", "200 175 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_left_leftmiddle_2", Vector(-100, 1300, 100), "-250 -200 -250", "250 150 250", "bomb_carrier nonzombie")

						CreatePathHologram(Vector(-490, -1350, 250), QAngle(0, 100, 0))
						CreatePathHologram(Vector(-750, -800, 350), QAngle(0, 90, 0))
						CreatePathHologram(Vector(-750, 150, 450), QAngle(0, 90, 0))
						CreatePathHologram(Vector(-450, 900, 350), QAngle(0, 70, 0))
						
						break
					}
				}
				
				break
			}
			case 3:
			{
				switch (choice)
				{
					case 5:
					{
						SpawnNavBrush("nav_avoid_left_front", Vector(500, -1200, 0), "-200 -250 -250", "200 250 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_right_flank_front", Vector(1550, -700, 150), "-150 -200 -250", "150 200 250", "bomb_carrier")
						SpawnNavBrush("nav_avoid_left_rightmiddle", Vector(400, 100, 50), "-150 -250 -250", "150 250 250", "bomb_carrier nonzombie")
						
						SpawnNavBrush("nav_avoid_right_rightmiddle_2", Vector(1700, -100, 100), "-250 -50 -250", "250 50 250", "bomb_carrier")
						
						CreatePathHologram(Vector(993, 100, 50), QAngle(0, 0, 0))
						CreatePathHologram(Vector(1672, 171, 50), QAngle(0, 90, 0))
						
						// cross_connections[5].remove(cross_connections[5].find(8))
						
						break
					}
					case 7:
					{
						SpawnNavBrush("nav_avoid_left_front", Vector(500, -1200, 0), "-200 -250 -250", "200 250 250", "bomb_carrier")
						SpawnNavBrush("nav_avoid_right_flank_front", Vector(1550, -700, 150), "-150 -200 -250", "150 200 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_right_rightmiddle", Vector(1400, 100, 0), "-200 -250 -250", "200 250 250", "bomb_carrier nonzombie")

						CreatePathHologram(Vector(993, 100, 50), QAngle(0, 180, 0))
						CreatePathHologram(Vector(139, 231, 150), QAngle(0, 90, 0))
						CreatePathHologram(Vector(145, 875, 150), QAngle(0, 135, 0))
						
						break
					}
				}
				
				break
			}
			case 4:
			{
				switch (choice)
				{
					// case 5: scrapped, made the path look unnatural
					// {
						// SpawnNavBrush("nav_avoid_right_flank_front", Vector(1550, -700, 150), "-150 -200 -250", "150 200 250", "bomb_carrier")
						
						// SpawnNavBrush("nav_avoid_left_leftfront", Vector(-400, -1350, 200), "-125 -250 -100", "150 250 100", "bomb_carrier nonzombie")
						// SpawnNavBrush("nav_avoid_left_leftfront_2", Vector(-800, 150, 450), "-250 -250 -250", "250 250 250", "bomb_carrier nonzombie")
						
						// SpawnNavBrush("nav_avoid_left_leftmiddle", Vector(150, 500, 100), "-200 -175 -250", "200 175 250", "bomb_carrier nonzombie")
						// SpawnNavBrush("nav_avoid_left_leftmiddle_2", Vector(-100, 1300, 100), "-250 -200 -250", "250 150 250", "bomb_carrier nonzombie")
						
						// SpawnNavBrush("nav_avoid_right_rightmiddle_2", Vector(1700, -100, 100), "-250 -50 -250", "250 50 250", "bomb_carrier")
						
						// CreatePathHologram(Vector(139, 231, 150), QAngle(0, 0, 0))
						// CreatePathHologram(Vector(993, 100, 50), QAngle(0, 0, 0))
						// CreatePathHologram(Vector(1672, 171, 50), QAngle(0, 90, 0))
						
						// cross_connections[5].remove(cross_connections[5].find(6))
						
						// break
					// }
					case 7:
					{
						SpawnNavBrush("nav_avoid_right_flank_front", Vector(1550, -700, 150), "-150 -200 -250", "150 200 250", "bomb_carrier nonzombie")
						SpawnNavBrush("nav_avoid_left_rightmiddle", Vector(400, 100, 50), "-150 -250 -250", "150 250 250", "bomb_carrier")
						SpawnNavBrush("nav_avoid_right_rightmiddle", Vector(1400, 100, 0), "-200 -250 -250", "200 250 250", "bomb_carrier nonzombie")
						
						CreatePathHologram(Vector(139, 231, 150), QAngle(0, 90, 0))
						CreatePathHologram(Vector(145, 875, 150), QAngle(0, 120, 0))
						
						EntFire("sentrynest_right3", "Enable")
						EntFire("sentrynest_right4", "Enable")
						
						break
					}
				}
				
				break
			}
			case 5:
			{
				EntFire("sentrynest_left2", "Enable")
				EntFire("sentrynest_left3", "Enable")
				EntFire("sentrynest_left5", "Enable")
				
				switch (choice)
				{
					case 6:
					{
						SpawnNavBrush("nav_avoid_right_rightback", Vector(1250, 2250, 200), "-250 -250 -250", "250 250 250", "bomb_carrier")
						
						CreatePathHologram(Vector(1686, 1263, 150), QAngle(0, 135, 0))
						CreatePathHologram(Vector(1176, 1817, 150), QAngle(0, 180, 0))
						
						break
					}
					case 8:
					{
						SpawnNavBrush("nav_avoid_left_rightback", Vector(1400, 1400, 100), "-200 -250 -250", "200 250 250", "bomb_carrier")
						
						CreatePathHologram(Vector(1686, 1150, 150), QAngle(0, 70, 0))
						CreatePathHologram(Vector(1900, 1700, 300), QAngle(0, 135, 0))
						CreatePathHologram(Vector(1300, 2150, 300), QAngle(0, 90, 0))
						CreatePathHologram(Vector(1200, 3100, 150), QAngle(0, 90, 0))
						CreatePathHologram(Vector(1200, 3500, 50), QAngle(0, 180, 0))
						
						break
					}
				}
				
				break
			}
			case 6:
			{
				switch (choice)
				{
					// case 7: scrapped, the bomb detour is noticeable
					// {
						// SpawnNavBrush("nav_avoid_right_middleback", Vector(600, 2000, 0), "-250 -50 -250", "250 50 250", "bomb_carrier nonzombie")
						// choice = 8
						
						// CreatePathHologram(Vector(600, 1813, 50), QAngle(0, 180, 0))
						// CreatePathHologram(Vector(-197, 1823, 100), QAngle(0, 135, 0))
						// CreatePathHologram(Vector(-550, 2250, 100), QAngle(0, 50, 0))
						// CreatePathHologram(Vector(-100, 3050, -50), QAngle(0, 30, 0))
						
						// break
					// }
					case 8:
					{
						SpawnNavBrush("nav_avoid_straight_middleback", Vector(300, 1800, 0), "-150 -250 -250", "150 250 250", "bomb_carrier")
						SpawnNavBrush("nav_avoid_straight_leftback", Vector(-550, 2100, 50), "-250 -150 -150", "250 150 150", "bomb_carrier nonzombie")
						
						CreatePathHologram(Vector(600, 1813, 50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(582, 2266, 50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(577, 2860, -50), QAngle(0, 180, 0))
						CreatePathHologram(Vector(105, 2871, -50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(105, 3541, -50), QAngle(0, 0, 0))
						
						break
					}
				}
				
				break
			}
			case 7:
			{
				switch (choice)
				{
					case 6:
					{
						SpawnNavBrush("nav_avoid_straight_leftback", Vector(-550, 2100, 50), "-250 -150 -150", "250 150 150", "bomb_carrier")
						
						choice = 8
						
						CreatePathHologram(Vector(-200, 1600, 100), QAngle(0, 20, 0))
						CreatePathHologram(Vector(600, 1813, 50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(582, 2266, 50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(577, 2860, -50), QAngle(0, 180, 0))
						CreatePathHologram(Vector(105, 2871, -50), QAngle(0, 90, 0))
						CreatePathHologram(Vector(105, 3541, -50), QAngle(0, 0, 0))
						
						break
					}
					case 8:
					{
						CreatePathHologram(Vector(-200, 1600, 100), QAngle(0, 120, 0))
						CreatePathHologram(Vector(-550, 2250, 100), QAngle(0, 50, 0))
						CreatePathHologram(Vector(-100, 3050, -50), QAngle(0, 30, 0))
						
						SpawnNavBrush("nav_avoid_right_leftback", Vector(250, 1800, 50), "-150 -250 -250", "150 250 250", "bomb_carrier")
						break
					}
				}
				
				SpawnNavBrush("nav_avoid_right_rightback", Vector(1250, 2250, 200), "-250 -250 -250", "250 250 250", "bomb_carrier nonzombie")
				
				break
			}
		}
		
		if (choice != 8) DetermineBombPath(choice)
		
		else
		{
			GiveNavAvoidToNavArea("nav_avoid_area261_dontdisable", NavMesh.GetNavAreaByID(261), "bomb_carrier nonzombie")
			GiveNavAvoidToNavArea("nav_avoid_area404_dontdisable", NavMesh.GetNavAreaByID(404), "bomb_carrier nonzombie")
			
			EntFireByHandle(gamerules_entity, "CallScriptFunction", "RecognizeAvoids", 0.4, null, null)
		}
	}
	
	RecognizeAvoids = function() // needs to be delayed because of navmesh updating only every 0.2s
	{
		for (local ent; ent = Entities.FindByClassname(ent, "func_nav_avoid"); )
		{
			if (NetProps.GetPropInt(ent, "m_iHammerID") != 0) continue
			else
			{
				local thisnavtable = {}
				NavMesh.GetNavAreasOverlappingEntityExtent(ent, thisnavtable)
				foreach (nav in thisnavtable) { if (nav.GetAttributes() == 536870912) blocknav_array.append(nav) }
			}
		}
		
		blocknav_array.append(NavMesh.GetNavAreaByID(24))
		blocknav_array.append(NavMesh.GetNavAreaByID(48))
		blocknav_array.append(NavMesh.GetNavAreaByID(59))
		blocknav_array.append(NavMesh.GetNavAreaByID(74))
		blocknav_array.append(NavMesh.GetNavAreaByID(147))
		blocknav_array.append(NavMesh.GetNavAreaByID(377))
	}
	
	BotTransformer = function(target)
	{
		local iconname = target
		
		switch (target)
		{
			case "scout_bonk":
			{
				self.SetPlayerClass(1)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 1)
				self.Regenerate(true)

				self.GetWearableItem(106)
				SetFakeClientConVarValue(self, "name", "Bonk Scout")
				self.AddWeaponRestriction(1)
				
				self.SetDifficulty(2)
				self.AddBotTag("bonk")
				
				break
			}
			
			case "soldier_crit":
			{
				self.SetPlayerClass(3)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 3)
				self.Regenerate(true)
				
				SetFakeClientConVarValue(self, "name", "Charged Soldier")
				self.AddBotAttribute(512)
				
				local wep = self.GetWeapon("tf_weapon_rocketlauncher", 513)
				
				wep.AddAttribute("faster reload rate", 0.2, -1.0)
				wep.AddAttribute("fire rate bonus", 2.0, -1.0)
				wep.AddAttribute("Projectile speed increased", 0.5, -1.0)
				
				self.SetDifficulty(1)
				
				break
			}
			
			case "soldier_conch":
			{
				self.SetPlayerClass(3)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 3)
				self.Regenerate(true)
				
				SetFakeClientConVarValue(self, "name", "Extended Conch Soldier")
				
				self.GetWeapon("tf_weapon_rocketlauncher", 18)
				
				self.SetDifficulty(1)
				
				self.AddBotTag("conch")

				break
			}
			
			case "pyro_flare":
			{
				self.SetPlayerClass(7)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 7)
				self.Regenerate(true)
				
				self.GetWeapon("tf_weapon_flaregun", 39)
				SetFakeClientConVarValue(self, "name", "Flare Pyro")
				self.AddWeaponRestriction(4)
				
				self.SetDifficulty(1)

				break
			}
			
			case "demo_fire_2":
			{
				self.SetPlayerClass(4)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 4)
				self.Regenerate(true)
				
				self.GetWeapon("tf_weapon_grenadelauncher", 308)
				SetFakeClientConVarValue(self, "name", "Pyroman")
				
				self.SetDifficulty(0)
				
				self.AddBotTag("firedemo")

				break
			}
			
			case "easyheavy":
			{
				iconname = "heavy"
				self.SetPlayerClass(6)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 6)
				self.Regenerate(true)
				
				SetFakeClientConVarValue(self, "name", "Heavyweapons")
				
				self.GetWeapon("tf_weapon_minigun", 15)
				self.GetWearableItem(940)
				
				self.SetDifficulty(0)

				break
			}
			
			case "normalheavy":
			{
				iconname = "heavy"
				self.SetPlayerClass(6)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 6)
				self.Regenerate(true)
				
				SetFakeClientConVarValue(self, "name", "Heavyweapons")
				
				self.GetWeapon("tf_weapon_minigun", 15)
				
				self.SetDifficulty(1)

				break
			}
			
			case "sniper_bow_stun":
			{
				self.SetPlayerClass(2)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 2)
				self.Regenerate(true)
				
				self.GetWeapon("tf_weapon_compound_bow", 56)
				SetFakeClientConVarValue(self, "name", "Ballman")
				
				self.SetDifficulty(2)

				self.AddBotTag("ballman")

				break
			}
		}
		
		local tf_class = class_integers[self.GetPlayerClass()]

		if (!self.IsMiniBoss()) self.SetCustomModelWithClassAnimations(format("models/bots/%s/bot_%s.mdl", tf_class, tf_class))
		else
		{
			self.SetCustomModelWithClassAnimations(format("models/bots/%s_boss/bot_%s_boss.mdl", tf_class, tf_class))
			self.SetScaleOverride(1.75)
			
			for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				if (player.IsFakeClient()) continue
				if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue
				
				player.AcceptInput("SpeakResponseConcept", "TLK_MVM_GIANT_CALLOUT", null, null)
			}
		}
		
		NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", iconname)
	}
	
	ToggleCoffins = function()
	{
		switch (coffins_active)
		{
			case false:
			{
				coffins_active = true

				AddIcon("dead_blu_lite", 2, 0)
				
				EmitGlobalSound("Halloween.TeleportVortex.EyeballMovedVortex")

				coffintime_cc.Enable()
				
				for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (IsPlayerABot(player)) continue
					
					player.ValidateScriptScope()
					local scope = player.GetScriptScope()
					
					if (!("saw_teleport_overlay" in scope)) 
					{
						coffinoverlaytime = Time() + 8.0
						scope.saw_teleport_overlay <- true
						player.SetScriptOverlayMaterial("undead_dread_overlays/coffin_warning_overlay")
						EntFireByHandle(player, "SetScriptOverlayMaterial", "", 8.0, null, null);
					}
				}
				
				break
			}
			
			case true:
			{
				coffins_active = false
				
				if (!NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves")) HideIcon("dead_blu_lite")
				
				EmitGlobalSound("ui/halloween_loot_found.wav")
				
				for (local ent; ent = Entities.FindByName(ent, "spawnbot_coffin*"); ) ent.Disable()
				
				coffintime_cc.Disable()
				
				break
			}
		}
		
		for (local ent; ent = Entities.FindByName(ent, "coffin_prop"); ) EntFireByHandle(ent, "RunScriptCode", "self.ResetSequence(self.LookupSequence(self.GetScriptScope().active_anim))", 0.1, null, null)
	}
	
	CreateFirePit = function(where, creator, crits)
	{
		PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "cauldron_flamethrower" })
	
		local tracetable =
		{
			start = where
			end = where - Vector(0, 0, 50)
			mask = -1
		}
		
		TraceLineEx(tracetable)
		
		if (tracetable.hit)
		{
			local firepit = SpawnEntityFromTable("info_particle_system",
			{
				origin             = where
				angles             = QAngle(-90, 0, 0)
				start_active       = 1,
				effect_name        = "cauldron_flamethrower"
			})
			
			firepit.KeyValueFromString("classname", "firedeath")
			
			firepit.ValidateScriptScope()
			firepit.GetScriptScope().owner <- creator
			firepit.GetScriptScope().team <- creator.GetTeam()
			firepit.GetScriptScope().crit <- crits
			
			AddThinkToEnt(firepit, "FirePit_Think")
			
			EntFireByHandle(firepit, "Kill", null, 3.0, null, null)
			
			if (!creator.IsFakeClient()) return
			
			foreach (player in GetAllPlayers(2))
			{
				if (TraceLine(where, player.EyePosition(), player) == 1.0)
				{
					if (!("vistip_firepit" in player.GetScriptScope()))
					{
						player.GetScriptScope().vistip_firepit <- true
						SendGlobalGameEvent("show_annotation", 
						{
							id = player.entindex()
							text = "Pyroman's grenades leave columns\nof fire where they land!"
							worldPosX = where.x
							worldPosY = where.y
							worldPosZ = where.z + 150
							visibilityBitfield = (1 << player.entindex())
							play_sound = "misc/null.wav"
							show_distance = false
							show_effect = false
							lifetime = 7.5
						})
					}
				}
			}
		}
	}
	
	HatchSnatcherIntroCutscene = function()
	{
		in_snatcher_cutscene = true
		
		PrecacheSound("ui/cyoa_musicintruderalert.mp3")
		PrecacheSound("player/taunt_jackhammer_loop.wav")
		
		foreach (player in GetAllPlayers(2))
		{
			local playercam = SpawnEntityFromTable("point_viewcontrol",
			{
				origin	 = Vector(1010, 3310, -60)
				angles	 = QAngle(10, 140, 0)
			})

			playercam.AcceptInput("CallScriptFunction", "CameraFix", null, null)

			EntFireByHandle(playercam, "Enable", null, 1.0, player, player)

			EntFireByHandle(playercam, "RunScriptCode", "AddThinkToEnt(self, `CameraRumble_Think`)", 2.5, null, null)
			
			player.SetMoveType(0, 0)
			player.AddHudHideFlags(4)
			
			player.AddCustomAttribute("no_attack", 1, -1)
			player.AddCustomAttribute("voice pitch scale", 0, -1)
			
			ScreenFade(player, 0, 0, 0, 255, 1.0, -1.0, 2)
			
			EntFireByHandle(player, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 1.0, null, null)

			EntFireByHandle(player, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 2)", 9.0, null, null)
			EntFireByHandle(player, "RunScriptCode", "ScreenFade(self, 0, 0, 0, 255, 1.0, -1.0, 1)", 10.0, null, null)
		
			EntFireByHandle(player, "RunScriptCode", "self.RemoveHudHideFlags(4)", 10.0, null, null)
			
			EntFireByHandle(player, "RunScriptCode", "self.SetMoveType(2, 0)", 10.0, null, null)
			
			EntFireByHandle(player, "RunScriptCode", "self.RemoveCustomAttribute(`no_attack`)", 10.0, null, null)
			EntFireByHandle(player, "RunScriptCode", "self.RemoveCustomAttribute(`voice pitch scale`)", 10.0, null, null)
			
			EntFireByHandle(playercam, "Disable", null, 10.0, player, player)
		}

		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/cyoa_musicintruderalert.mp3`)", 1.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/cyoa_musicintruderalert.mp3`)", 1.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/cyoa_musicintruderalert.mp3`)", 1.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/cyoa_musicintruderalert.mp3`)", 1.0, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitGlobalSound(`ui/cyoa_musicintruderalert.mp3`)", 1.0, null, null)
		
		EntFireByHandle(gamerules_entity, "RunScriptCode", "EmitSoundEx({sound_name = `player/taunt_jackhammer_loop.wav`, channel = 6, filter_type = 5})", 2.5, null, null)
		EntFireByHandle(gamerules_entity, "RunScriptCode", "hatchsnatcher_cutsceneover = true; in_snatcher_cutscene = false", 10.0, null, null)

		local hatchsnatcher_dummy = SpawnEntityFromTable("prop_dynamic",
		{
			targetname			 = "snatcher_dummymodel"
			origin         		 = Vector(642.364, 3544.41, -500)
			angles				 = QAngle(0, -65, 0)
			skin 		   		 = 1
			modelscale	   		 = 1.9
			model                = "models/bots/pyro_boss/bot_pyro_boss.mdl"
			defaultanim    		 = "taunt01"
			disablebonefollowers = 1
		})
		
		SpawnEntityFromTable("prop_dynamic_ornament",
		{
			model                   = "models/player/items/all_class/trn_wiz_hat_pyro.mdl"
			skin 					= 1
			disablebonefollowers	= 1
			initialowner			= "snatcher_dummymodel"
		})

		NetProps.SetPropBool(hatchsnatcher_dummy, "m_bClientSideAnimation", false)

		AddThinkToEnt(hatchsnatcher_dummy, "HatchSnatcherDummy_Think")
	}
	
	CameraRumble_Think = function()
	{
		if (endshaking) return
		
		local choice = RandomInt(0, 1)
		
		if (choice == 0) self.SetAbsAngles(self.GetAbsAngles() + QAngle(RandomInt(0, 1) == 0 ? 0.33 : -0.33, 0, 0))
		if (choice == 1) self.SetAbsAngles(self.GetAbsAngles() + QAngle(0, RandomInt(0, 1) == 0 ? 0.33 : -0.33, 0))

		return -1
	}
	
	Coffin_Think = function()
	{
		if (thinkertick % 7 != 0) return
		if (!intel_entity.IsValid()) return
		
		local intel_y = intel_entity.GetOrigin().y
		
		if (!coffins_active) return

		for (local ent; ent = Entities.FindByName(ent, "spawnbot_coffin_front"); )
		{
			if (intel_y < -1000.0) 						ent.Disable()
			if (intel_y >= -1000.0 && intel_y < 1500.0) ent.Disable()
			if (intel_y >= 1500.0)						ent.Enable()
		}
		
		for (local ent; ent = Entities.FindByName(ent, "spawnbot_coffin_middle"); )
		{
			if (intel_y < -1000.0) 						ent.Enable()
			if (intel_y >= -1000.0 && intel_y < 1500.0) ent.Disable()
			if (intel_y >= 1500.0)						ent.Disable()
		}
		
		for (local ent; ent = Entities.FindByName(ent, "spawnbot_coffin_back"); )
		{
			if (intel_y < -1000.0) 						ent.Enable()
			if (intel_y >= -1000.0 && intel_y < 1500.0) ent.Enable()
			if (intel_y >= 1500.0)						ent.Disable()
		}
	}
	
	CoffinProp_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("beam" in scope))
		{
			scope.active_anim <- null
			
			local unique = UniqueString()
			
			scope.beam_apex <- SpawnEntityFromTable("info_teleport_destination", { targetname = unique, origin = self.GetOrigin() + Vector(0, 0, 1500) })
			
			scope.beam <- SpawnEntityFromTable("env_beam",
			{
				targetname				= self.GetName() + "_beam_" + unique
				origin					= self.GetOrigin()
				life                    = 0
				boltwidth               = 25
				LightningStart			= self.GetName() + "_beam_" + unique
				LightningEnd			= unique
				NoiseAmplitude          = 1
				rendercolor				= "56 243 171"
				texture					= "sprites/laserbeam.spr"
				spawnflags				= 0
			})
		}
		
		if (!NetProps.GetPropBool(associated_spawn_ent, "m_bDisabled"))
		{
			scope.active_anim = "taunt_the_crypt_creeper_A1"
			if (NetProps.GetPropInt(scope.beam, "m_active") == 0) scope.beam.AcceptInput("TurnOn", null, null, null)
		}
		else
		{
			scope.active_anim = "ref"
			if (NetProps.GetPropInt(scope.beam, "m_active") == 1) scope.beam.AcceptInput("TurnOff", null, null, null)
		}			

		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		
		if (self.GetSequenceName(self.GetSequence()).find("A1") != null)
		{
			if (self.GetCycle() > 0.7) self.ResetSequence(self.LookupSequence(scope.active_anim))
			if (self.GetCycle() == 0.0 || (self.GetCycle() > 0.27 && self.GetCycle() < 0.275)) EmitSoundEx({sound_name = coffin_sounds[RandomInt(0, coffin_sounds.len() - 1)], channel = 6, entity = self, sound_level = 75, pitch = 100 + RandomInt(-20, 20)})
		}

		if (self.GetSequenceName(self.GetSequence()).find("A2") != null)
		{
			if (self.GetCycle() > 0.2 && self.GetCycle() < 0.6) self.SetCycle(0.6)
			if (self.GetCycle() > 0.8) self.ResetSequence(self.LookupSequence(scope.active_anim))
		}

		return -1
	}
	
	Conch_Think = function()
	{
		foreach (player in GetAllPlayers(3, [self.GetOrigin(), 450.0]))
		{
			player.AddCondEx(29, 0.25, self)
			
			local foundaura = false

			for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) { if (child.GetName() == "conchbuffaura") foundaura = true }
			
			if (foundaura) continue

			local buffaura = SpawnEntityFromTable("info_particle_system",
			{
				targetname = "conchbuffaura"
				origin = player.GetOrigin()
				effect_name = "soldierbuff_mvm"
				start_active = 1
				flag_as_weather = 0
			})

			buffaura.AcceptInput("SetParent", "!activator", player, player)
			
			EntFireByHandle(buffaura, "Kill", null, 1.0, null, null)
		}

		return 0.1
	}
	
	Ballman_Think = function()
	{
		try { self.GetScriptScope() }
		catch (e) { return -1 }
		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		local scope = self.GetScriptScope()

		if (!("chargetime" in scope))
		{
			scope.chargetime <- 0
			scope.damage <- 0
			scope.ballspeed <- 0
			scope.ballgravity <- 0
			scope.fullstun <- false
		}

		if (owner.InCond(0))
		{
			local reloadattr = self.GetAttribute("faster reload rate", 1.0)
			local dmgattr = self.GetAttribute("damage bonus", 1.0)

			chargetime = (Time() - NetProps.GetPropFloat(self, "m_flChargeBeginTime")) * (1.0 + (0.5 * ((1.0 - reloadattr) / 0.2)))

			if (chargetime >= 1.0) chargetime = 1.0

			damage = (50.0 + (70.0 * chargetime)) * dmgattr
			ballspeed = RemapValClamped(chargetime, 0.0, 1.0, 1200, 2000)
			ballgravity = RemapValClamped(chargetime, 0.0, 1.0, 0.5, 0.2)

			if (chargetime >= 1.0) fullstun = true
		}

		else chargetime = 0.0
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_arrow"); )
		{
			if (ent.GetOwner() != owner) continue

			local ball = SpawnEntityFromTable("tf_projectile_stun_ball", 
			{
				teamnum      = ent.GetTeam()
				origin       = ent.GetOrigin()
				angles       = ent.GetAbsAngles()
			})

			ball.SetMoveType(5, 2)
			ball.SetGravity(ballgravity)
			
			local vecVelocity = Vector(0, 0, 0)
			vecVelocity += owner.EyeAngles().Forward() * 15
			vecVelocity += owner.EyeAngles().Up() * 0.5
			vecVelocity.Norm()
			vecVelocity *= ballspeed

			ball.ApplyAbsVelocityImpulse(vecVelocity)

			ball.SetOwner(owner)
			NetProps.SetPropEntity(ball, "m_hLauncher", ball) // this will let us access the ball in ontakedamage hook
			
			ball.ValidateScriptScope()
			ball.GetScriptScope().ignite <- false
			ball.GetScriptScope().weapon <- self
			ball.GetScriptScope().fullstun <- fullstun
			
			fullstun = false
			
			AddThinkToEnt(ball, "Ball_Think")
			
			if (NetProps.GetPropBool(ent, "m_bArrowAlight"))
			{
				ball.GetScriptScope().ignite = true
				
				local particle = SpawnEntityFromTable("trigger_particle",
				{
					particle_name = "m_brazier_flame"
					attachment_type = 1
					spawnflags = 64
				})
				
				NetProps.SetPropBool(particle, "m_bForcePurgeFixedupStrings", true)
				
				particle.AcceptInput("StartTouch", "!activator", ball, ball)
				particle.Kill()
			}
			
			if (NetProps.GetPropBool(ent, "m_bCritical")) NetProps.SetPropBool(ball, "m_bCritical", true)

			ent.Kill()
		}
		
		return -1
	}
	
	FireDemo_Think = function()
	{
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_pipe"); )
		{
			if (NetProps.GetPropEntity(ent, "m_hThrower") != owner) continue
			
			ent.ValidateScriptScope()
			local proj_scope = ent.GetScriptScope()
			
			if (!("flameparticle" in proj_scope))
			{
				proj_scope.flameparticle <- SpawnEntityFromTable("trigger_particle",
				{
					particle_name = "m_brazier_flame"
					attachment_type = 1
					spawnflags = 64
				})
				
				proj_scope.flameparticle.AcceptInput("StartTouch", "!activator", ent, ent)
				proj_scope.flameparticle.Kill()
				
				proj_scope.owner <- owner
				proj_scope.crit <- (NetProps.GetPropBool(ent, "m_bCritical")) ? 1048576 : 0
		
				proj_scope.OnGameEvent_object_deflected <- function(params)
				{
					if (params.object_entindex == owner.entindex()) owner = GetPlayerFromUserID(params.userid)
				}
				
				SetDestroyCallback(ent, function() { CreateFirePit(self.GetOrigin(), self.GetScriptScope().owner, self.GetScriptScope().crit) })
				
				__CollectGameEventCallbacks(proj_scope)
			}
		}
		
		return -1
	}
	
	MedicShotgun_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("patient_alive" in scope))
		{
			if (self.HasBotTag("no_patient"))
			{
				scope.patient_alive <- false
				
				if (sigmod) self.AcceptInput("$BotCommand", "switch_action FetchFlag", null, null)

				local origmodel = self.GetModelName()
				
				self.SetCustomModelWithClassAnimations("models/bots/heavy_boss/bot_heavy_boss.mdl")
				self.KeyValueFromInt("rendermode", 1)
				self.KeyValueFromInt("renderamt", 0)
				
				local newmodel = self.GetWearable(origmodel)
				
				newmodel.KeyValueFromString("targetname", "glow_target")
				
				scope.glow <- SpawnEntityFromTable("tf_glow",
				{
					target           	  = "glow_target"
					origin				  = self.EyePosition()
					GlowColor			  = "125 168 196 255"
					StartDisabled		  = 1
				})
				
				scope.glow.AcceptInput("SetParent", "!activator", newmodel, newmodel)
				
				newmodel.KeyValueFromString("targetname", "")

				local shotgun = self.GetWeapon("tf_weapon_shotgun_hwg", 11)
				
				shotgun.AddAttribute("fire rate bonus", 2.5, -1.0)
				shotgun.AddAttribute("bullets per shot bonus", 10.0, -1.0)
				shotgun.AddAttribute("damage penalty", 0.5, -1.0)
				shotgun.AddAttribute("faster reload rate", 0.1, -1.0)
			}
			
			if (self.GetHealTarget() == null) return -1
			
			self.AddBotAttribute(8)

			scope.patient_alive <- true
			
			scope.medigun <- NetProps.GetPropEntityArray(self, "m_hMyWeapons", 1)
			scope.patient <- self.GetHealTarget()
			
			scope.connected <- false
			scope.distlimit <- 450
			
			// scope.lifetime <- 1.0
			// scope.drain_amount <- 24.0
			
			// scope.drain_amount <- format("%.1f", (scope.patient.GetMaxHealth().tofloat() / 1750.0)).tofloat()
			scope.drain_amount <- 7.0
			scope.drainbank_amount <- 0

			scope.drain_interval <- 10

			// local attempts = 1
			
			// the more you add a number to itself, the less accurate the result! adding 0.7 to itself ten times in this loop below won't return 7!
			// the only way is to multiply it by a number, reset it if it doesn't match, and then increase the multiplier

			// for (local i = scope.drain_amount; i <= (scope.drain_amount * 10.0); i *= attempts) // rise the drained amount to a non-floating number
			// {
				// scope.drain_interval++
				// attempts++

				// if (i == (scope.drain_amount * 10.0)) { scope.drain_amount = i; break }
				// if (i.tointeger() != i) { i = scope.drain_amount; continue }

				// scope.drain_amount = i
				// break
			// }

			scope.nextdraintime <- thinkertick + scope.drain_interval

			if (scope.patient.GetPlayerClass() == 1) self.AddCustomAttribute("CARD: move speed bonus", 10, -1.0)
			
			local patient_beamend = UniqueString()
			local healer_beamstart = UniqueString()

			scope.medigun.KeyValueFromString("targetname", healer_beamstart)
			scope.patient.KeyValueFromString("targetname", patient_beamend)
			
			scope.beam_start <- SpawnEntityFromTable("env_beam",
			{
				targetname				= healer_beamstart
				origin					= scope.medigun.GetCenter()
				life                    = 0
				boltwidth               = 15
				LightningStart			= healer_beamstart
				LightningEnd			= patient_beamend
				NoiseAmplitude          = 1
				rendercolor				= "110 0 0"
				texture					= "sprites/laserbeam.spr"
				spawnflags				= 0
			})
			
			scope.medigun.KeyValueFromString("targetname", "")
			scope.patient.KeyValueFromString("targetname", "")
			
			scope.dist <- 0
			
			shotguncallbacks <-
			{
				OnGameEvent_player_death = function(params)
				{
					local dead_player = GetPlayerFromUserID(params.userid)
					
					if (dead_player == self)
					{
						self.KeyValueFromInt("rendermode", 0)
						
						self.SetCustomModelWithClassAnimations("models/bots/medic/bot_medic.mdl")
						
						intel_entity.AcceptInput("ForceGlowDisabled", "0", null, null)
						
						delete shotguncallbacks

						return
					}

					if (dead_player.IsFakeClient())
					{
						if (dead_player == scope.patient)
						{
							if (sigmod) self.AcceptInput("$BotCommand", "switch_action FetchFlag", null, null)
							
							self.RemoveCustomAttribute("CARD: move speed bonus")
							
							local origmodel = self.GetModelName()
							
							self.SetCustomModelWithClassAnimations("models/bots/heavy_boss/bot_heavy_boss.mdl")
							self.KeyValueFromInt("rendermode", 1)
							self.KeyValueFromInt("renderamt", 0)
							
							local newmodel = self.GetWearable(origmodel)
							
							newmodel.KeyValueFromString("targetname", "glow_target")
							
							scope.glow <- SpawnEntityFromTable("tf_glow",
							{
								target           	  = "glow_target"
								origin				  = self.EyePosition()
								GlowColor			  = "125 168 196 255"
								StartDisabled		  = 1
							})
							
							scope.glow.AcceptInput("SetParent", "!activator", newmodel, newmodel)
							
							newmodel.KeyValueFromString("targetname", "")
							
							try { scope.beam_start.Kill() }
							catch (e) {}
							
							local shotgun = self.GetWeapon("tf_weapon_shotgun_hwg", 11)
							
							shotgun.AddAttribute("fire rate bonus", 2.5, -1.0)
							shotgun.AddAttribute("bullets per shot bonus", 10.0, -1.0)
							shotgun.AddAttribute("damage penalty", 0.5, -1.0)
							shotgun.AddAttribute("faster reload rate", 0.1, -1.0)
							
							EntFireByHandle(self, "RunScriptCode", "self.RemoveBotAttribute(8)", 2.5, null, null)
							
							self.EmitSound("vo/mvm/norm/medic_mvm_" + medicshotgun_soundarray[RandomInt(0, medicshotgun_soundarray.len() - 1)] + ".mp3")

							scope.patient_alive = false
						}
					}
				}
			}
			
			foreach (name, callback in shotguncallbacks) shotguncallbacks[name] = callback.bindenv(scope)

			__CollectGameEventCallbacks(shotguncallbacks)
		}

		if (scope.patient_alive)
		{
			if (thinkertick % 7 == 0)
			{
				foreach (player in GetAllPlayers(2))
				{
					if (TraceLine(self.EyePosition(), player.EyePosition(), self) == 1.0)
					{
						if (!("vistip_medicshotgun" in player.GetScriptScope()))
						{
							player.GetScriptScope().vistip_medicshotgun <- true
							SendGlobalGameEvent("show_annotation", 
							{
								id = player.entindex()
								text = "Giant Shotgun Medics leech\nhealth from their patients!"
								follow_entindex = self.entindex()
								visibilityBitfield = (1 << player.entindex())
								play_sound = "misc/null.wav"
								show_distance = false
								show_effect = false
								lifetime = 7.5
							})
						}
					}
				}
				
				if (!scope.connected)
				{
					scope.distlimit = 450
					scope.patient.AddCustomAttribute("CARD: move speed bonus", 0.01, -1.0)
				}
				
				else
				{
					scope.patient.RemoveCustomAttribute("CARD: move speed bonus")
					scope.distlimit = 540
				}
				
				// scope.lifetime += 0.015
				
				// local drain_rate = (self.GetMaxHealth().tofloat() / self.GetHealth().tofloat()) * scope.lifetime

				// scope.drain_amount = 24.0 * drain_rate
				
				// if (scope.drain_amount > 432.0) scope.drain_amount = 432.0
				
				// NetProps.SetPropFloat(scope.beam_start, "m_boltWidth", (drain_rate < 6.0) ? drain_rate * 4.0 : 25.0)
				
				scope.dist = (scope.patient.GetCenter() - scope.medigun.GetOrigin()).Length()
				
				if (scope.dist > scope.distlimit) { { if (NetProps.GetPropInt(scope.beam_start, "m_active") == 1) scope.beam_start.AcceptInput("TurnOff", null, null, null) } ; scope.connected = false }
				else							  { { if (NetProps.GetPropInt(scope.beam_start, "m_active") == 0) scope.beam_start.AcceptInput("TurnOn", null, null, null) } ; scope.connected = true }
			}
			
			if (scope.connected && scope.nextdraintime <= thinkertick)
			{
				// local drainperframe = scope.drain_amount
				// local origdrainperframe = drainperframe
				
				// local interval = 1
				
				// for (local i = drainperframe; i < 1.0; i *= 2.0)
				// for (local i = drainperframe; i < 1.0; i *= 2.0)
				// {
					// drainperframe += origdrainperframe
					// interval++
				// }
				
				scope.nextdraintime = thinkertick + scope.drain_interval
				
				if (scope.patient.GetHealth().tofloat() < 35.0) scope.patient.TakeDamage(195.0, 64, scope.patient)
				
				// else scope.patient.SetHealth(scope.patient.GetHealth().tofloat() - drainperframe)
				else scope.patient.SetHealth(scope.patient.GetHealth().tofloat() - scope.drain_amount)
				
				// if (self.GetHealth() < self.GetMaxHealth()) self.SetHealth(self.GetHealth().tofloat() + drainperframe)
				if (self.GetHealth() < self.GetMaxHealth())
				{
					// self.SetHealth(self.GetHealth().tofloat() + drainperframe)
					self.SetHealth(self.GetHealth().tofloat() + scope.drain_amount)
					
					if (scope.drainbank_amount > 0)
					{
						// self.SetHealth(self.GetHealth().tofloat() + drainperframe)
						// scope.drainbank_amount -= drainperframe
						self.SetHealth(self.GetHealth().tofloat() + scope.drain_amount)
						scope.drainbank_amount -= scope.drain_amount
					}
				}
				
				// else scope.drainbank_amount += drainperframe
				else scope.drainbank_amount += scope.drain_amount
			}
		}
		
		else
		{
			foreach (player in GetAllPlayers(2))
			{
				if (!("vistip_medicshotgun2" in player.GetScriptScope()))
				{
					if (TraceLine(self.EyePosition(), player.EyePosition(), self) == 1.0)
					{
						player.GetScriptScope().vistip_medicshotgun2 <- true
						SendGlobalGameEvent("show_annotation", 
						{
							id = player.entindex()
							text = "When their patient dies,\nthey bring out their shotguns!"
							follow_entindex = self.entindex()
							visibilityBitfield = (1 << player.entindex())
							play_sound = "misc/null.wav"
							show_distance = false
							show_effect = false
							lifetime = 7.5
						})
					}
				}
			}
			
			if (self.HasItem())
			{
				intel_entity.AcceptInput("ForceGlowDisabled", "1", null, null)
				glow.Enable()
			}
		}

		return -1
	}
	
	SamuraiSoldier_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("jumping" in scope))
		{
			scope.origmodel <- self.GetModelName()
			scope.jumping <- false
			scope.dummymodel <- null
			scope.in_cooldown <- true
			scope.cooldown_exittime <- thinkertick + ((!self.HasBotTag("samurai_minion") ? 250 : 1000) * RandomFloat(0.75, 1.25))
			scope.activated <- false
			// scope.leader <- null
			scope.hat <- (!self.HasBotTag("samurai_minion")) ? "models/player/items/soldier/soldier_samurai.mdl" : "models/workshop/player/items/sniper/robo_sniper_soldered_sensei/robo_sniper_soldered_sensei.mdl"
			
			if (self.HasBotTag("samurai_minion"))
			{
				local hat = self.GetWearable(hat, false, "head", [Vector(5, 0, -128), QAngle()])
				hat.SetModelScale(1.45, -1.0)
				
				foreach (player in GetAllPlayers(3))
				{
					if (player.HasBotTag("valid_samurai"))
					{
						self.Teleport(true, player.GetOrigin(), false, QAngle(), true, Vector(RandomInt(-500, 500), RandomInt(-500, 500), 0))
						break
					}
				}
			}
		}
		
		if (dummymodel != null)
		{
			if (dummymodel.GetCycle() >= 0.8)
			{
				local dummykill = dummymodel
				
				dummymodel = null
				dummykill.Kill()
				
				self.SetMoveType(2, 0)
				
				self.SetCustomModelOffset(Vector())
			}
		}
		
		if (thinkertick % 6 != 0) return -1
		
		if (jumping && self.IsGrounded()) jumping = false
		
		if (jumping && self.GetAbsVelocity().z <= 0 && !in_cooldown)
		{
			foreach (player in GetAllPlayers(2))
			{
				if (TraceLine(self.EyePosition(), player.EyePosition(), self) == 1.0)
				{
					if (!("vistip_samuraisoldier" in player.GetScriptScope()))
					{
						player.GetScriptScope().vistip_samuraisoldier <- true
						SendGlobalGameEvent("show_annotation", 
						{
							id = player.entindex()
							text = "Samurai Soldiers duplicate\nthemselves when they jump!"
							follow_entindex = self.entindex()
							// worldPosX = where.x
							// worldPosY = where.y
							// worldPosZ = where.z + 225
							visibilityBitfield = (1 << player.entindex())
							play_sound = "misc/null.wav"
							show_distance = false
							show_effect = false
							lifetime = 7.5
						})
					}
				}
			}
			
			self.SetMoveType(0, 0)

			self.SetCustomModelOffset(Vector(0, 0, -5000))
			
			dummymodel = SpawnEntityFromTable("prop_dynamic",
			{
				targetname			 = "dummymodel_" + self.entindex()
				origin         		 = self.GetOrigin()
				skin 		   		 = 1
				modelscale	   		 = 1.3
				model          		 = "models/player/soldier.mdl"
				defaultanim    		 = "taunt07"
				disablebonefollowers = 1
				rendermode			 = 1
				renderamt			 = 0
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				model                   = origmodel
				skin 					= 1
				modelscale				= 1.3
				disablebonefollowers	= 1
				initialowner			= "dummymodel_" + self.entindex()
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				model                   = hat
				modelscale				= 1.45
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "dummymodel_" + self.entindex()
			})
			
			if (!self.HasBotTag("samurai_minion"))
			{
				EnableSpawn("samurai")
				EntFireByHandle(samurai_spawn, "Disable", null, 0.1, null, null)
			}
			
			else
			{
				EnableSpawn("samurai_2")
				EntFireByHandle(samurai_spawn_minion, "Disable", null, 0.1, null, null)
			}

			self.AddBotTag("valid_samurai")
			EntFireByHandle(self, "RunScriptCode", "self.RemoveBotTag(`valid_samurai`)", 0.1, null, null)
			
			PrecacheSound("items/samurai/TF_samurai_noisemaker_setA_01.wav")
			PrecacheSound("items/samurai/TF_samurai_noisemaker_setA_02.wav")
			PrecacheSound("items/samurai/TF_samurai_noisemaker_setA_03.wav")
			PrecacheSound("items/samurai/TF_conch.wav")
			PrecacheSound("sfx_supermove.wav")
			
			if (!activated)
			{
				if (thinkertick >= nextconchsoundtime)
				{
					self.EmitSound("Samurai.Conch")
					nextconchsoundtime = thinkertick + 66
				}
			}
			
			EmitSoundEx({sound_name = "items/samurai/TF_samurai_noisemaker_setA_0" + RandomInt(1, 3) + ".wav", channel = 6, entity = self, sound_level = 150})
			EmitSoundEx({sound_name = "sfx_supermove.wav", channel = 6, entity = self, sound_level = 150})
			
			for (local i = 0; i <= 5; i++)
			{
				local sfx = SpawnEntityFromTable("info_particle_system", { origin = self.EyePosition() + Vector(RandomInt(-150, 150), RandomInt(-150, 150), RandomInt(-150, 150)), effect_name = "eyeboss_team_blue", start_active = 1, flag_as_weather = 0 } )
				EntFireByHandle(sfx, "Kill", null, 3.0, null, null)
			}

			activated = true
			in_cooldown = true
			
			cooldown_exittime = thinkertick + (1000 * RandomFloat(0.75, 1.25))
		}
		
		if (self.IsGrounded() && !in_cooldown)
		{
			local alivesamurais = 0
			
			foreach (player in GetAllPlayers(3))
			{
				if (!player.HasBotTag("samurai_soldier")) continue
				
				alivesamurais++
			}
			
			if (alivesamurais < 10)
			{
				local trace =
				{
					start = self.EyePosition() + Vector(0, 0, 150),
					end = self.EyePosition() + Vector(0, 0, 150),
					hullmin = self.GetBoundingMins() + Vector(0, 0, 150),
					hullmax = self.GetBoundingMaxs() + Vector(0, 0, 150),
					mask = 33636363,
					ignore = self
				}
				
				TraceHull(trace)
				
				if (!("startsolid" in trace))
				{
					self.GetLocomotionInterface().Jump()
					jumping = true
				}
			}
		}
		
		if (in_cooldown && (thinkertick >= cooldown_exittime)) in_cooldown = false
		
		if (activated)
		{
			foreach (player in GetAllPlayers(3, [self.GetOrigin(), 450.0]))
			{
				player.AddCondEx(29, 0.25, self)
				
				local foundaura = false

				for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) { if (child.GetName() == "conchbuffaura") foundaura = true }

				local buffaura = SpawnEntityFromTable("info_particle_system",
				{
					targetname = "conchbuffaura"
					effect_name = "soldierbuff_mvm"
					origin = player.GetOrigin()
					start_active = 1
					flag_as_weather = 0
				})

				buffaura.AcceptInput("SetParent", "!activator", player, player)
				
				EntFireByHandle(buffaura, "Kill", null, 1.0, null, null)
			}
		}
	}
	
	FirePit_Think = function()
	{
		for (local entity_to_burn; entity_to_burn = Entities.FindInSphere(entity_to_burn, self.GetOrigin(), 90.0); )
		{
			if (entity_to_burn.GetClassname() == "tf_weapon_compound_bow") NetProps.SetPropBool(entity_to_burn, "m_bArrowAlight", true)
			if (entity_to_burn.GetClassname() == "tf_projectile_arrow") NetProps.SetPropBool(entity_to_burn, "m_bArrowAlight", true)

			if (entity_to_burn.GetTeam() == team) continue
			
			local dmg = (entity_to_burn.GetClassname() == "obj_sentrygun") ? 3.25 : 6.5

			entity_to_burn.TakeDamageEx(self, owner, ignite_player, Vector(0, 0, 0), entity_to_burn.GetOrigin(), dmg, 8 + crit)
		}
		
		return 0.075
	}

	TunnelSpawnFix_Think = function()
	{
		for (local pumpkin; pumpkin = Entities.FindByClassname(pumpkin, "tf_ammo_pack"); )
		{
			if (NetProps.GetPropInt(pumpkin, "m_nModelIndex") == PrecacheModel("models/props_halloween/pumpkin_loot.mdl")) EntFireByHandle(pumpkin, "Kill", null, -1.0, null, null)
		}

		if (Wave == 5)
		{
			if (NetProps.GetPropFloat(gamerules_entity, "m_flRestartRoundTime") > Time() + 5.1 && NetProps.GetPropFloat(gamerules_entity, "m_flRestartRoundTime") < Time() + 10.1) NetProps.SetPropFloat(gamerules_entity, "m_flRestartRoundTime", Time() + 5.0)
		}
		
		if (thinkertick % 6 != 0) return
		
		NavMesh.GetNavAreaByID(126).SetAttributeTF(4) // those occassionally have their flags reset
		NavMesh.GetNavAreaByID(155).SetAttributeTF(4)
		NavMesh.GetNavAreaByID(1997).SetAttributeTF(4)
		
		foreach (player in GetAllPlayers(3))
		{
			local bounds = (player.HasBotAttribute(32768)) ? Vector(154, 66, 136) : Vector(128, 44, 136)
			
			if (IsInside(player.GetOrigin(), Vector(1016, -2336, -16) - bounds, Vector(1016, -2336, -16) + bounds))
			{
				player.Teleport(true, player.GetOrigin() + Vector(0, 72, 8), false, QAngle(), false, Vector())
			}
		}
	}
	
	SuppressWaveEndMusic_Think = function()
	{
		if (suppress_waveend_music)
		{
			StopGlobalSound("music.mvm_end_wave")
			StopGlobalSound("music.mvm_end_mid_wave")
			StopGlobalSound("music.mvm_end_last_wave")
			StopGlobalSound("music.mvm_end_tank_wave")
		}
	}
	
	DuckySpawn_Think = function()
	{
		if (thinkertick < duckyspawn_time) return
		
		local choice = duckyspawn_locations[RandomInt(0, duckyspawn_locations.len() - 1)]
		
		local ducky = SpawnEntityFromTable("prop_dynamic",
		{
			model	   = "models/items/target_duck.mdl"
			origin 	   = SnapVectorToGround(choice, 24.0)
		})

		AddThinkToEnt(ducky, "DuckyPickup_Think")
		
		duckyspawn_locations.remove(duckyspawn_locations.find(choice))
		
		duckyspawn_amount++
		
		if (duckyspawn_amount >= 3) RemoveThinkFromThinksTable("DuckySpawn_Think")
		
		duckyspawn_time = thinkertick + 4000
	}
	
	DuckyPickup_Think = function()
	{
		self.SetAbsAngles(self.GetAngles() + QAngle(0, 1, 0))
		
		foreach (player in GetAllPlayers(2, [self.GetOrigin(), 72.0]))
		{
			if (player.IsFakeClient()) continue
			
			local scope = player.GetScriptScope()
			
			if (!("hasducky" in scope))
			{
				scope.hasducky <- true
				
				EmitSoundEx({ sound_name = "Halloween.Quack", filter_type = 4, flags = 0, entity = player, channel = 6 })
				
				DispatchParticleEffect("halloween_explosion", self.GetOrigin(), Vector(0, 90, 0))
				
				duckyspawn_pickups++
				
				if (duckyspawn_pickups >= 3)
				{
					secretwave_unlocked = true
					ClientPrint(null, 4, "You've unlocked the secret bonus wave!")
					EmitGlobalSound("ui/mm_level_four_achieved.wav")

					NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineMaxWaveCount", 6)
				}
				
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self, null)
				self.Kill()
				return 1
			}
			
			else ClientPrint(player, 4, "Someone else has to pick this up")
		}
		
		return -1
	}
	
	HatchSnatcherDummy_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("hatch" in scope))
		{
			scope.orighatch <- Entities.FindByName(null, "hatch")
			scope.hatch <- SpawnEntityFromTable("prop_dynamic",
			{
				origin         		 = self.GetOrigin()
				model                = "models/props_mvm/mann_hatch.mdl"
				disablebonefollowers = 1
			})
			
			scope.finished1 <- false
			scope.finished2 <- false
			
			hatch.AcceptInput("SetParent", "!activator", self, self)
			
			EntFireByHandle(hatch, "SetParentAttachment", "weapon_bone", 0.1, null, null) // 20 57 out of 67
			
			EntFireByHandle(hatch, "RunScriptCode", "self.SetLocalOrigin(Vector(0, 0, 30))", 0.5, null, null)
			EntFireByHandle(hatch, "RunScriptCode", "self.SetLocalAngles(QAngle(0, -20, 85))", 0.5, null, null)
			
			PrecacheSound("player/taunt_jackhammer_down_strike.wav")
			PrecacheSound("player/taunt_jackhammer_loop.wav")
			PrecacheSound("player/taunt_jackhammer_loop_end.wav")

			PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "hammer_impact_button_dust2" })
		}
		
		if (self.GetCycle() < 0.3 || self.GetCycle() > 0.75) self.SetCycle(0.3)
		
		if (self.GetOrigin().z > -365 && self.GetOrigin().z < -325) DispatchParticleEffect("hammer_impact_button_dust2", self.EyePosition() + Vector(0, 0, 200), Vector(0, 90, 0))
		
		if (self.GetOrigin().z > -365)
		{
			if (!finished1)
			{
				EmitGlobalSound("vo/taunts/pyro/pyro_taunt_flip_exert_02.mp3")
				finished1 = true
				orighatch.SetOrigin(Vector(0, 0, -5000))
				EmitSoundEx({sound_name = "player/taunt_jackhammer_down_strike.wav", channel = 6, filter_type = 5})
			}
		}
		
		if (self.GetOrigin().z < -206) self.SetOrigin(self.GetOrigin() + Vector(0, 0, 0.5))
		
		else if (!finished2)
		{
			finished2 = true
			endshaking = true
			EmitSoundEx({sound_name = "player/taunt_jackhammer_loop.wav", channel = 6, filter_type = 5, flags = 4})
			EmitSoundEx({sound_name = "player/taunt_jackhammer_loop_end.wav", channel = 6, filter_type = 5})
			EmitGlobalSound("vo/taunts/pyro/pyro_taunt_flip_exert_06.mp3")
		}
		
		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		
		if (hatchsnatcher_cutsceneover) self.Kill()
		
		return -1
	}
	
	HatchSnatcher_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("hatchprop" in scope))
		{
			scope.holeblock_deco <- SpawnEntityFromTable("prop_dynamic",
			{
				origin 					= Vector(2220, 186, 360)
				angles                  = QAngle(0, 90, 180)
				modelscale				= 1.3
				solid					= 0
				model					= "models/props_gameplay/security_fence256.mdl"
			})

			scope.holeblock_brush <- SpawnEntityFromTable("func_button",
			{
				origin 					= Vector(2215, 186, 330)
				angles                  = QAngle(0, 90, 180)
			})

			holeblock_brush.KeyValueFromInt("solid", 2)
			holeblock_brush.KeyValueFromString("mins", "-1 -300 -200")
			holeblock_brush.KeyValueFromString("maxs", "1 0 500")
			
			scope.aggrodestinations <-
			[
				Vector(900, -1800, 0), // initial
				Vector(1330, -600, 250), // front
				Vector(1950, -1100, 300), // front
				// Vector(100, -550, 300), // front
				Vector(-850, 450, -100),// middle
				// Vector(1100, 600, 50), // middle
				Vector(1700, 1700, 250), // middle
				Vector(-1200, 1800, 300), // middle
				Vector(600, 1050, 300), // middle
				Vector(-50, 2400, -350), // back
				Vector(900, 2500, -100), // back
				Vector(1150, 3950, 100), // back
				Vector(-300, 3500, 100) // back
			]
			
			scope.voicecooldown <- thinkertick + RandomInt(350, 650)
			scope.tauntcooldown <- thinkertick + RandomInt(2000, 3000)
			
			scope.aggrotarget <- SpawnEntityFromTable("prop_dynamic",
			{
				targetname    = "aggrotarget"
				origin		  = Vector(900, -1800, 0)
				model         = "models/props_hydro/barrel_crate_half.mdl"
				modelscale    = 0.01
				rendermode	  = 1
				renderamt 	  = 0
			})
			
			SpawnEntityFromTable("filter_tf_bot_has_tag",
			{
				targetname 		 = "filter_hatchsnatcher"
				tags       		 = "hatch_snatcher"
			})
			
			local snatcher_logic = SpawnEntityFromTable("func_nav_prerequisite",
			{
				filtername = "filter_hatchsnatcher"
				Task       = 2
				Entity	   = "aggrotarget"
				spawnflags = 3
			})
			
			snatcher_logic.KeyValueFromInt("solid", 2)
			snatcher_logic.KeyValueFromString("mins", "-9999 -9999 -9999")
			snatcher_logic.KeyValueFromString("maxs", "9999 9999 9999")
			
			RegisterScriptGameEventListener("round_start")
			SendGlobalGameEvent("round_start", {})
			
			scope.origmodel <- self.GetModelName()
			
			self.SetCustomModelWithClassAnimations("models/player/soldier.mdl")
			self.KeyValueFromInt("rendermode", 1)
			self.KeyValueFromInt("renderamt", 0)
			
			local fakemodel = self.GetWearable(origmodel)
			self.GetWearableItem(634)
			
			fakemodel.KeyValueFromString("targetname", "glow_target")
			
			scope.glow <- SpawnEntityFromTable("tf_glow",
			{
				target           	  = "glow_target"
				GlowColor			  = "125 168 196 255"
			})
			
			glow.AcceptInput("SetParent", "!activator", fakemodel, fakemodel)
			
			fakemodel.KeyValueFromString("targetname", "")
			
			scope.hatchprop <- self.GetWearable("models/props_mvm/mann_hatch.mdl", false, "head", [Vector(50, 10, 0), QAngle(40, 0, 0)])
			
			hatchprop.SetModelScale(0.75, -1.0)
			
			scope.tauntmodel <- null
			
			self.Teleport(true, Vector(642.364, 3544.41, -206), false, QAngle(), false, Vector())
			self.StunPlayer(3600.0, 0.0, 64, self)
			
			foreach (player in GetAllPlayers(2))
			{
				local dir = RandomInt(0, 1)
				if (dir == 0) dir = -1

				player.Teleport(true, SnapVectorToGround(self.GetOrigin() + Vector((RandomInt(250, 500) * dir), (RandomInt(250, 250) * dir), 250), 24.0), false, QAngle(), false, Vector())
				player.SnapEyeAngles(VectorAngles(self.GetCenter() - player.EyePosition()))
			}
			
			scope.AntiStun_Start <- function()
			{
				for (local ent; ent = Entities.FindByClassname(ent, "func_upgradestation"); ) ent.Disable()
				
				foreach (player in GetAllPlayers(2))
				{
					if (player.GetPlayerClass() == 3)
					{
						local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0)
						if (weapon.GetAttribute("rocket specialist", -1.0) != -1.0)
						{
							player.GetScriptScope().rocketspecialist <- weapon.GetAttribute("rocket specialist", -1.0)
							local projspeed = player.GetScriptScope().rocketspecialist * 0.15
							
							weapon.AddAttribute("rocket specialist", 0.0, -1.0)
							weapon.AddAttribute("projectile speed increased", 1.0 + projspeed, -1.0)
						}
					}
				}
			}
			
			scope.AntiStun_End <- function()
			{
				for (local ent; ent = Entities.FindByClassname(ent, "func_upgradestation"); ) ent.Enable()
				
				foreach (player in GetAllPlayers(2))
				{
					if (player.GetPlayerClass() == 3)
					{
						local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0)

						if (weapon.GetAttribute("rocket specialist", -1.0) != -1.0)
						{
							if (!("rocketspecialist" in player.GetScriptScope())) continue // this should never happen really
							
							weapon.AddAttribute("rocket specialist", player.GetScriptScope().rocketspecialist, -1.0)
							weapon.RemoveAttribute("projectile speed increased")
							
							delete player.GetScriptScope().rocketspecialist
						}
					}
				}
			}
			
			AntiStun_Start()

			scope.snatchercallbacks <-
			{
				OnGameEvent_recalculate_holidays = function(params)
				{
					AntiStun_End()
					
					delete snatchercallbacks
				}

				OnGameEvent_post_inventory_application = function(params)
				{
					local player = GetPlayerFromUserID(params.userid)

					if (player.GetTeam() != 2) return
					
					AntiStun_Start()
				}
				
				OnGameEvent_player_death = function(params)
				{
					local dead_player = GetPlayerFromUserID(params.userid)

					if (dead_player == self)
					{
						self.KeyValueFromInt("rendermode", 0)
						
						local newhatch = SpawnEntityFromTable("prop_dynamic",
						{
							targetname			 = "fakehatch"
							origin         		 = self.EyePosition()
							model                = "models/props_mvm/mann_hatch.mdl"
							disablebonefollowers = 1
						})
						
						AddThinkToEnt(newhatch, "HatchLand_Think")
						
						AntiStun_End()
						
						delete snatchercallbacks
					}
				}
			}
			
			foreach (name, callback in snatchercallbacks) snatchercallbacks[name] = callback.bindenv(scope)
			
			__CollectGameEventCallbacks(snatchercallbacks)
		}
		
		if (thinkertick % 666 == 0) aggrotarget.SetOrigin(aggrodestinations[RandomInt(0, aggrodestinations.len() - 1)])
		
		if ((aggrotarget.GetOrigin() - self.GetOrigin()).Length() < 100.0)
		{
			local oldtarget = aggrotarget.GetOrigin()
			
			local ord = 0
			
			foreach (vec in aggrodestinations)
			{
				if (vec.ToKVString() == oldtarget.ToKVString())
				{
					aggrodestinations.remove(ord)
					break
				}
				
				ord++
			}
			
			aggrotarget.SetOrigin(coffin_locations[RandomInt(0, aggrodestinations.len() - 1)])
			
			aggrodestinations.append(oldtarget)
		}

		if (thinkertick > voicecooldown)
		{
			self.EmitSound("pyro_sf13_spell_generic0" + RandomInt(1, 9))
			voicecooldown = thinkertick + RandomInt(350, 650)
		}
		
		if (thinkertick > tauntcooldown)
		{
			self.SetMoveType(0, 0)
			self.SetCustomModelOffset(Vector(0, 0, -5000))
			
			tauntmodel = SpawnEntityFromTable("prop_dynamic",
			{
				targetname			 = "dummymodel_" + self.entindex()
				origin         		 = self.GetOrigin()
				skin 		   		 = 1
				modelscale	   		 = 1.9
				model          		 = "models/player/scout.mdl"
				defaultanim    		 = "taunt_spintowin"
				disablebonefollowers = 1
				rendermode			 = 1
				renderamt			 = 0
			})
			
			local fakemodelglow = SpawnEntityFromTable("tf_glow",
			{
				target           	  = "dummymodel_" + self.entindex()
				GlowColor			  = "125 168 196 255"
			})
			
			fakemodelglow.AcceptInput("SetParent", "!activator", tauntmodel, tauntmodel)
			
			tauntmodel.SetCycle(0.36)
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				model                   = origmodel
				skin 					= 1
				modelscale				= 1.9
				disablebonefollowers	= 1
				initialowner			= "dummymodel_" + self.entindex()
			})
			
			SpawnEntityFromTable("prop_dynamic_ornament",
			{
				model                   = "models/player/items/all_class/trn_wiz_hat_scout.mdl"
				skin 					= 1
				disablebonefollowers	= 1
				initialowner			= "dummymodel_" + self.entindex()
			})
			
			local tauntprop = SpawnEntityFromTable("prop_dynamic",
			{
				targetname			 = "dummytauntprop_" + self.entindex()
				origin         		 = self.GetOrigin()
				skin 		   		 = 1
				modelscale	   		 = 0.75
				model          		 = "models/props_mvm/mann_hatch.mdl"
				disablebonefollowers = 1
			})
			
			tauntprop.AcceptInput("SetParent", "!activator", tauntmodel, null)
			
			EntFireByHandle(tauntprop, "SetParentAttachment", "hand_R", 0.1, null, null)
			EntFireByHandle(tauntprop, "RunScriptCode", "self.SetLocalOrigin(Vector(50, 10, 0))", 0.2, null, null)
			EntFireByHandle(tauntprop, "RunScriptCode", "self.SetLocalAngles(QAngle(40, 0, 0))", 0.2, null, null)
			
			local choice = [2, 5, 7]
			
			PrecacheSound("vo/taunts/pyro/pyro_taunt_flip_int_02.mp3")
			PrecacheSound("vo/taunts/pyro/pyro_taunt_flip_int_05.mp3")
			PrecacheSound("vo/taunts/pyro/pyro_taunt_flip_int_07.mp3")
			
			self.EmitSound("vo/taunts/pyro/pyro_taunt_flip_int_0" + choice[RandomInt(0, 2)] + ".mp3")

			tauntcooldown = thinkertick + RandomInt(2000, 3000)
		}
		
		if (tauntmodel != null)
		{
			if (tauntmodel.GetCycle() >= 1.0)
			{
				local t = tauntmodel
				tauntmodel = null
				t.Kill()
				
				self.SetMoveType(2, 0)
				self.SetCustomModelOffset(Vector())
			}
		}
		
		foreach (player in GetAllPlayers(2, [self.GetOrigin(), 250.0]))
		{
			local selfmins = self.GetBoundingMins() + self.GetOrigin() - Vector(5.0, 5.0, 5.0)
			local selfmaxs = self.GetBoundingMaxs() + self.GetOrigin() + Vector(5.0, 5.0, 5.0)

			local playermins = player.GetBoundingMins() + player.GetOrigin()
			local playermaxs = player.GetBoundingMaxs() + player.GetOrigin()

			if (playermins.x > selfmaxs.x || playermaxs.x < selfmins.x || playermins.y > selfmaxs.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermins.z > selfmaxs.z || playermaxs.z < selfmins.z) continue
			else
			{
				local pushforce = player.GetOrigin() - self.GetOrigin()
				pushforce.Norm()
				pushforce.z = 1.0
				pushforce = pushforce * 270
				
				if (NetProps.GetPropEntity(player, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn")) player.SetOrigin(player.GetOrigin() + Vector(0, 0, 24))
				
				player.RemoveFlag(1)
				player.AddCond(115)

				player.ApplyAbsVelocityImpulse(pushforce)
			}
		}

		return -1
	}

	HatchLand_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("lifetick" in scope))
		{
			scope.lifetick <- 0
			scope.curvel <- 0
			
			PrecacheSound("weapons/slap_swing.wav")
		}
		
		if (lifetick < 100) curvel = 0.75
		if (lifetick > 100) curvel -= 0.027
		if (curvel < -0.5) curvel = -5.0
		
		self.SetOrigin(self.GetOrigin() + Vector(0, 0, curvel))
		self.SetAbsAngles(self.GetAbsAngles() + QAngle(0, 12, 0))
		
		if (thinkertick % 7 == 0)
		{
			if (TraceLine(self.GetOrigin(), self.GetOrigin() - Vector(0, 0, 500), self) <= 0.1)
			{
				self.SetOrigin(SnapVectorToGround(self.GetOrigin()))
				
				Entities.FindByName(null, "capturezone_red").Kill()
				
				local newcapzone = SpawnEntityFromTable("func_capturezone",
				{
					origin         		 	= SnapVectorToGround(self.GetOrigin())
					TeamNum 				= 3
					targetname 				= "capturezone_red"
					shouldBlock 			= 1
					capturepoint 			= 1
					capture_delay_offset 	= 0.025
					capture_delay			= 1.1
					OnCapture				= "round_win,RoundWin,,0,-1"
					OnCapture 				= "boss_deploy_relay,Trigger,,0,-1"
				})
				
				newcapzone.KeyValueFromInt("solid", 2)
				newcapzone.KeyValueFromString("mins", "-48 -48 -16")
				newcapzone.KeyValueFromString("maxs", "48 48 16")
				
				EmitSoundEx({sound_name = "player/taunt_jackhammer_loop_end.wav", channel = 6, sound_level = 150, entity = self})
				
				DispatchParticleEffect("hammer_impact_button_dust2", self.GetOrigin(), Vector(0, 90, 0))
				
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self, null)
				
				return 1
			}
		}
		
		if (thinkertick % 50 == 0) self.EmitSound("weapons/slap_swing.wav")
		
		lifetick++
		
		return -1
	}
	
	BombHop_Think = function()
	{
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves")) return -1
		
		local scope = self.GetScriptScope()
		
		if (!("moving" in scope))
		{
			scope.moving <- false
			scope.toapex <- true
			scope.moveamount <- Vector()
			scope.v1 <- Vector()
			scope.hopapex <- Vector()
			scope.v2 <- Vector()
			scope.maxdist <- false
			scope.disttospawn <- null
			scope.patharray <- []
			scope.maxdistarray <- []
			scope.activationtime <- thinkertick + 481 // always takes exactly this amount of frames for the game to start accepting path calculations since wave start
			
			scope.disttohatch_before <- 0
			scope.disttohatch_after <- 0
			
			scope.restoredhoptime <- 0.0
			scope.restoredhoptimeremainder <- 0.0
			scope.restoredhoptimepenalty <- 0.0
			
			scope.nohopping <- true
			
			scope.fullroute <- null
			
			scope.overlay_time <- -1
			scope.hidehopoverlay <- false
			
			scope.CalculateDistance <- function()
			{
				local resulttable =
				{
					success = true
					atspawn = false
					recovery = false
				}
				
				local table = {}
				patharray = []
				
				local nearestnav = false
				local dir = 0
				
				for (local i = 16; i <= 512; i += 16)
				{
					local validarea = NavMesh.GetNearestNavArea(self.GetOrigin(), i, true, false)
					
					if (!validarea) continue

					nearestnav = validarea
					break
				}
				
				if (!nearestnav)
				{
					for (local i = 16; i <= 512; i += 16)
					{
						local validarea = NavMesh.GetNearestNavArea(self.GetOrigin(), i, false, false)
						
						if (!validarea) continue

						nearestnav = validarea
						break
					}
				}

				foreach (nav in blocknav_array) { if (nearestnav != nav) nav.MarkAsBlocked(3) }

				if (!NavMesh.GetNavAreasFromBuildPath(nearestnav, NavMesh.GetNavAreaByID(355), Vector(), 0.0, 3, false, table)) // nav area 355 is cave entrance spawn
				{  
					// try to find the fastest way back to our intended route

					local bestlength = 10000
					local bestreturnarea
					
					foreach (area in maxdistarray)
					{
						local distance = (area.GetCenter() - self.GetOrigin()).Length()

						if (distance < bestlength)
						{
							bestlength = distance
							bestreturnarea = area
						}
						
						else continue
					}
					
					local radiustable = {}
					
					NavMesh.GetNavAreasInRadius(self.GetOrigin(), 500.0, radiustable)

					local bestarea
					
					foreach (area in radiustable)
					{
						local distance = (bestreturnarea.GetCenter() - area.GetCenter()).Length()

						if (distance < bestlength)
						{
							bestlength = distance
							bestarea = area
						}
						
						else continue
					}

					patharray.append(bestarea)
					foreach (nav in blocknav_array) nav.UnblockArea()
					resulttable.recovery = true
					disttospawn = 10000
					return resulttable
				}

				foreach (nav in blocknav_array) nav.UnblockArea()
				
				if (table.len() == 0) { resulttable.success = false; return resulttable }
				
				for (local i = 0; i < table.len() - 1; i++) patharray.append(table["area" + i])
				
				patharray.reverse()
				
				if (patharray.len() < 2) { resulttable.atspawn = true; return resulttable }

				local curarea1
				local curarea2
				
				disttospawn = 0

				for (local i = 0; i <= patharray.len() - 2; i++)
				{
					curarea1 = patharray[i].GetCenter()
					curarea2 = patharray[i + 1].GetCenter()
					
					disttospawn += (curarea2 - curarea1).Length()
				}

				return resulttable
			}
			
			scope.DetermineReturnTime <- function()
			{
				if (thinkertick < activationtime) return

				local calcresult = CalculateDistance()
				
				if (calcresult.atspawn)
				{
					nohopping = true
					
					restoredhoptime = 0.0
					restoredhoptimeremainder = 0.0
					restoredhoptimepenalty = 0.0
					
					NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0)
					NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)

					return -1
				}
				
				if (!calcresult.success)
				{
					NetProps.SetPropFloat(self, "m_flResetTime", Time() + bombhoptime)
					NetProps.SetPropFloat(self, "m_flMaxResetTime", bombhoptime)
					
					return -1
				}

				bombhoptime = RemapValClamped(disttospawn, maxdist - 1750.0, 2750.0, bombhoptime_base, bombhoptime_base * 3.0)
				
				if (bombhoptime == (bombhoptime_base * 3.0))
				{
					nohopping = true
					
					restoredhoptime = 0.0
					restoredhoptimeremainder = 0.0
					restoredhoptimepenalty = 0.0
					
					NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0)
					NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)
					
					return -1
				}
				
				else nohopping = false
				
				restoredhoptimepenalty = 0
				
				// bombhoptime = RemapValClamped(dist, maxdist - 2000.0, 2000.0, bombhoptime_base, bombhoptime_base)

				local restoredhoptimepercent = 1.0 + (restoredhoptime / bombhoptime)
				
				bombhoptime -= restoredhoptime
				
				if (bombhoptime <= 0.0) bombhoptime = 0.1

				if (disttohatch_before < 4000.0) // let's not do this is we are far from hatch
				{
					if (disttohatch_after < disttohatch_before) bombhoptime /= 3.0 // nav clunkyness made the bomb hop towards the hatch, let's compensate by reducing hop time
				}
				
				disttohatch_before = disttohatch_after

				NetProps.SetPropFloat(self, "m_flResetTime", Time() + bombhoptime)
				NetProps.SetPropFloat(self, "m_flMaxResetTime", bombhoptime * restoredhoptimepercent)
				
				// 1.5x reset = 1/4, 2x reset = 1/2, 4x reset = 3/4 
				
				// self.KeyValueFromFloat("ReturnTime", bombhoptime)
				
				restoredhoptimeremainder = restoredhoptime
			}
			
			scope.DetermineFullPath <- function()
			{
				self.KeyValueFromFloat("ReturnTime", bombhoptime)
				
				local maxdisttable = {}
				maxdistarray = []
				
				foreach (nav in blocknav_array) nav.MarkAsBlocked(3)
				
				NavMesh.GetNavAreasFromBuildPath(NavMesh.GetNavAreaByID(34), NavMesh.GetNavAreaByID(355), Vector(), 0.0, 3, false, maxdisttable)
				
				foreach (nav in blocknav_array) nav.UnblockArea()
				
				if (maxdisttable.len() == 0) return

				for (local i = 0; i < maxdisttable.len() - 1; i++) maxdistarray.append(maxdisttable["area" + i])
				
				maxdistarray.reverse()
				
				local curarea1
				local curarea2
				
				maxdist = 0
				
				for (local i = 0; i <= maxdistarray.len() - 2; i++)
				{
					curarea1 = maxdistarray[i].GetCenter()
					curarea2 = maxdistarray[i + 1].GetCenter()
					
					maxdist += (curarea2 - curarea1).Length()
				}
			}
		}
		
		if (thinkertick < activationtime) return -1 // let's not do anything until we have all necessary variables
		
		if (!maxdist) DetermineFullPath()

		if (!moving && !nohopping)
		{
			if (NetProps.GetPropInt(self, "m_nFlagStatus") == 1 && thinkertick % 7 == 0) // carried
			{
				restoredhoptime -= restoredhoptimepenalty
				if (restoredhoptime < 0) restoredhoptime = 0
			}
			
			if (NetProps.GetPropInt(self, "m_nFlagStatus") == 2 && thinkertick % 7 == 0) // dropped
			{
				restoredhoptime =  bombhoptime - (NetProps.GetPropFloat(self, "m_flResetTime") - Time()) + restoredhoptimeremainder
			}
		}

		// if (thinkertick % 7 == 0)
		// {
			// ClientPrint(null,3,"time until hop: " + (NetProps.GetPropFloat(self, "m_flResetTime") - Time()))
		// }
		
		if (Time() > coffinoverlaytime)
		{
			if (Time() < overlay_time)
			{
				if (thinkertick % 25 == 0)
				{
					foreach (player in GetAllPlayers(2))
					{
						if (!("hopalert_tutorial" in player.GetScriptScope())) continue

						if (player.GetScriptScope().hopalert_tutorial > 2)
						{
							if (player.GetScriptOverlayMaterial().find("2") != null) player.SetScriptOverlayMaterial("undead_dread_overlays/bombhopalert1")
							else													 player.SetScriptOverlayMaterial("undead_dread_overlays/bombhopalert2")
						}
						
						else
						{
							if (player.GetScriptOverlayMaterial().find("2") != null) player.SetScriptOverlayMaterial("undead_dread_overlays/bombhopalert_tut1")
							else													 player.SetScriptOverlayMaterial("undead_dread_overlays/bombhopalert_tut2")
						}
					}
					
					hidehopoverlay = true
				}
			}
			
			else if (hidehopoverlay)
			{
				local overlayspresent = false
				
				foreach (player in GetAllPlayers(2))
				{
					if (player.GetScriptOverlayMaterial() == null) continue
					
					overlayspresent = true
					
					player.SetScriptOverlayMaterial(null)												 
				}
				
				if (!overlayspresent) hidehopoverlay = false
			}
		}

		if (NetProps.GetPropInt(self, "m_nFlagStatus") < 2)
		{
			moving = false
			toapex = true
			moveamount = Vector()
			v1 = Vector()
			hopapex = Vector()
			v2 = Vector()
			
			return -1
		}

		if (Time() - NetProps.GetPropFloat(self, "m_flResetTime") > -0.1)
		{
			NetProps.SetPropFloat(self, "m_flResetTime", Time() + 60000.0)
			NetProps.SetPropFloat(self, "m_flMaxResetTime", 0.0)
			
			local calcresult = CalculateDistance()
			
			if (calcresult.atspawn) return -1
			
			if (!calcresult.success)
			{
				NetProps.SetPropFloat(self, "m_flResetTime", Time() + bombhoptime)
				NetProps.SetPropFloat(self, "m_flMaxResetTime", bombhoptime)
				
				return -1
			}
			
			if (patharray.len() == 0)
			{
				NetProps.SetPropFloat(self, "m_flResetTime", Time() + bombhoptime)
				NetProps.SetPropFloat(self, "m_flMaxResetTime", bombhoptime)
				
				return -1
			}

			v1 = self.GetOrigin()
			v2 = patharray[0]
			
			if (calcresult.recovery)
			{
				EmitSoundEx({sound_name = "misc/ks_tier_02_kill_02.wav", channel = 6, entity = self, sound_level = 75})
				disttohatch_before = (NavMesh.GetNavAreaByID(34).GetCenter() - v1).Length()
				moving = true
			}
			
			else
			{
				foreach (nav in patharray)
				{
					if (nav == v2) continue

					if ((v2.GetCenter() - v1).Length() < 400.0) v2 = nav

					else
					{
						EmitSoundEx({sound_name = "misc/ks_tier_02_kill_02.wav", channel = 6, entity = self, sound_level = 75})
						disttohatch_before = (NavMesh.GetNavAreaByID(34).GetCenter() - v1).Length()
						moving = true

						break
					}
				}
			}
			
			foreach (player in GetAllPlayers(2))
			{
				if (!("hopalert_tutorial" in player.GetScriptScope())) player.GetScriptScope().hopalert_tutorial <- 0
				
				if (player.GetPlayerClass() == 1 || player.GetPlayerClass() == 2 || player.GetPlayerClass() == 4 || player.GetPlayerClass() == 6)
				{
					if (RandomInt(1, 3) == 1)
					{
						if ((player.GetOrigin() - self.GetOrigin()).Length() < 450.0)
						{
							local tfclassname = class_integers[player.GetPlayerClass()] + ((player.GetPlayerClass() == 4) ? "man" : "")
							local responseindex = tfclassname + ((player.GetPlayerClass() == 2 && player.InCond(1)) ? "_scope" : "")
							
							player.PlayScene(format("scenes/Player/%s/low/%i.vcd", tfclassname, bombhop_responses["" + responseindex][RandomInt(0, bombhop_responses["" + responseindex].len() - 1)]), -1.0)
						}
					}
				}
				
				if (player.GetScriptScope().hopalert_tutorial < 3) player.GetScriptScope().hopalert_tutorial++
			}
			
			overlay_time = Time() + 5.0

			NetProps.SetPropInt(self, "m_Collision.m_nSolidType", 0) // using SetSolid and SetSolidFlags messes with the bomb's default collision
			NetProps.SetPropInt(self, "m_Collision.m_usSolidFlags", 0)
			
			hopapex = ((v2.GetCenter() + v1) * 0.5) + Vector(0, 0, 100)
		}

		if (moving)
		{	
			if ((hopapex - self.GetOrigin()).Length() <= 12.0) toapex = false
			if ((v2.GetCenter() - self.GetOrigin()).Length() <= 12.0)
			{
				restoredhoptime = 0
				disttohatch_after = (NavMesh.GetNavAreaByID(34).GetCenter() - self.GetOrigin()).Length()
				DetermineReturnTime()
				
				moving = false
				toapex = true
				moveamount = Vector()
				v1 = Vector()
				hopapex = Vector()
				v2 = Vector()
				
				NetProps.SetPropInt(self, "m_Collision.m_nSolidType", 2)
				NetProps.SetPropInt(self, "m_Collision.m_usSolidFlags", 140)
				
				return -1
			}
			
			if (toapex) moveamount = (hopapex - v1) * (1.0 / 50.0)
			else		moveamount = (v2.GetCenter() - hopapex) * (1.0 / 50.0)

			self.SetAbsOrigin(self.GetOrigin() + moveamount)
		}
		
		return -1
	}
	
	BallHead_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("victim" in scope))
		{
			scope.victim <- self.GetRootMoveParent()
			scope.jumped <- false
			scope.endtime <- Time() + 7.5
			
			PrecacheSound("Engineer.PainCrticialDeath01")
			
			if (victim.GetPlayerClass() == 4) EntFireByHandle(victim, "RunScriptCode", "EmitSoundEx({sound_name = `Demoman.PainCrticialDeath0` + RandomInt(1, 3), origin = self.GetOrigin(), special_dsp = 14})", RandomFloat(1.0, 3.0), null, null)
			
			else EntFireByHandle(victim, "RunScriptCode", "EmitSoundEx({sound_name = class_integers[self.GetPlayerClass()] + `.PainCrticialDeath0` + RandomInt(1, 3), origin = self.GetOrigin(), special_dsp = 14})", RandomFloat(1.0, 3.0), null, null)

			if (!("vistip_ballhead" in victim.GetScriptScope()))
			{
				victim.GetScriptScope().vistip_ballhead <- true
				SendGlobalGameEvent("show_annotation", 
				{
					id = self.entindex()
					text = "Ballman's balls put\nyou into Ballvision!"
					follow_entindex = self.entindex()
					visibilityBitfield = (1 << victim.entindex())
					play_sound = "misc/null.wav"
					show_distance = false
					show_effect = false
					lifetime = 7.5
				})
			}
			
			scope.End <- function()
			{
				SendGlobalGameEvent("hide_annotation", { id = self.entindex() })

				victim.SetForcedTauntCam(0)
				victim.RemoveCustomAttribute("voice pitch scale")
				victim.RemoveCustomAttribute("head scale")
				
				delete victim.GetScriptScope().ballent
				
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self, null)
				self.Kill()
			}
			
			victim.SetForcedTauntCam(1)
			victim.AddCustomAttribute("voice pitch scale", 0, -1.0)
			
			scope.OnGameEvent_player_death <- function(params)
			{
				local dead_player = GetPlayerFromUserID(params.userid)
				
				if (dead_player == victim) End()
			}
			
			scope.OnGameEvent_recalculate_holidays <- function(params) { End() }

			__CollectGameEventCallbacks(scope)
		}

		if (ignite && !victim.InCond(22)) victim.TakeDamageEx(owner, owner, ignite_player, Vector(0, 0, 0), victim.GetOrigin(), 6.5, 8)
		
		if (!jumped)
		{
			if (victim.IsJumping()) endtime -= 3.75
			jumped = true
		}
		
		if (NetProps.GetPropEntity(victim, "m_hGroundEntity") != null) jumped = false

		if (Time() >= endtime) End()
		
		return -1
	}
	
	Ball_Think = function()
	{
		try { self.GetScriptScope() }
		catch (e) { return }
		
		if (NetProps.GetPropBool(self, "m_bTouched"))
		{
			self.SetGravity(1.0)
			
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			AddThinkToEnt(self, null)
			return
		}
		
		for (local ent; ent = Entities.FindByClassnameWithin(ent, "obj_sentrygun", self.GetOrigin(), 50.0); )
		{
			if (ent.GetTeam() == self.GetTeam()) continue
			if (NetProps.GetPropBool(ent, "m_bBuilding")) continue
			
			ent.ValidateScriptScope()
			local sentryscope = ent.GetScriptScope()
			
			if ("balled" in sentryscope)
			{
				if (NetProps.GetPropInt(ent, "m_iUpgradeLevel") == 1) continue
				
				if (sentryscope.balled == 0) sentryscope.AttachBall()
				else continue
			}
			
			else AddThinkToEnt(ent, "SentryBall_Think")
			
			ent.TakeDamage(1.0, 64, self)

			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			self.Kill()
			
			break
		}
		
		return -1
	}
	
	SentryBall_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("balled" in scope))
		{
			scope.balled <- 0
			scope.lasthealth <- self.GetHealth()
			scope.endtime <- thinkertick + 150
			scope.blocknextshot <- false
			scope.AttachBall <- function()
			{
				local sentryball
				
				if (!("sentryball1" in scope))
				{
					if (NetProps.GetPropInt(self, "m_iUpgradeLevel") > 1) blocknextshot = true
					
					scope.sentryball1 <- SpawnEntityFromTable("prop_dynamic",
					{
						origin             	 = self.GetOrigin()
						disablebonefollowers = 1
						model 			   	 = "models/weapons/w_models/w_baseball.mdl"
					})
					
					sentryball = sentryball1
				}
				
				else if (!("sentryball2" in scope))
				{
					balled = 1
					scope.sentryball2 <- SpawnEntityFromTable("prop_dynamic",
					{
						origin             	 = self.GetOrigin()
						disablebonefollowers = 1
						model 			   	 = "models/weapons/w_models/w_baseball.mdl"
					})
					
					sentryball = sentryball2
				}
				
				else return
				
				local sound = "weapons/sentry_damage" + RandomInt(1, 4) + ".wav"
				
				EmitSoundEx({sound_name = sound, entity = self, channel = 6, sound_level = 150})
				EmitSoundEx({sound_name = sound, entity = self, channel = 6, sound_level = 150})
				EmitSoundEx({sound_name = sound, entity = self, channel = 6, sound_level = 150})

				sentryball.AcceptInput("SetParent", "!activator", self, null)
				
				local attach
				
				if (NetProps.GetPropInt(self, "m_iUpgradeLevel") == 1) attach = "muzzle"
				else
				{
					if ("sentryball1" in scope) attach = "muzzle_r"
					if ("sentryball2" in scope)	attach = "muzzle_l"
				}
				
				EntFireByHandle(sentryball, "SetParentAttachment", attach, 0.1, null, null)
			}
			
			AttachBall()
		}
		
		if ((balled == 0 && NetProps.GetPropInt(self, "m_iUpgradeLevel") == 1) || balled == 1) NetProps.SetPropInt(self, "m_iState", 1)

		if (self.GetHealth() > lasthealth || thinkertick >= endtime)
		{
			sentryball1.Kill()
			if ("sentryball2" in scope) sentryball2.Kill()
			
			NetProps.SetPropInt(self, "m_iState", 2)
			
			self.TerminateScriptScope()
			NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			AddThinkToEnt(self, null)
			return
		}
	
		lasthealth = self.GetHealth()

		return -1
	}
	
	WeaponGallery_Think = function()
	{
		for (local ent; ent = Entities.FindByName(ent, "gallery_*"); )
		{
			ent.SetAbsAngles(ent.GetAngles() + QAngle(0, 1, 0))
			
			if (thinkertick % 50 == 0 && ent.GetName().find("shotgun"))
			{
				local shotgunparticle = SpawnEntityFromTable("trigger_particle",
				{
					particle_name = "healthgained_red"
					attachment_type = 0
					spawnflags = 64
				})

				shotgunparticle.AcceptInput("StartTouch", "!activator", ent, ent)
				shotgunparticle.Kill()
			}
		}
		
		foreach (player in GetAllPlayers(2, [Vector(525, 5150, 0), 450.0]))
		{
			if (player.IsFakeClient()) continue
			
			local scope = player.GetScriptScope()	
			
			local invalid = false
			
			if (!("inmodmenu" in scope))
			{
				scope.inmodmenu <- false
				scope.modmenucooldown <- 0
				scope.lookingat <- null
				scope.modsactive <-
				{
					loch = false
					bow = false
				}
				
				scope.hashatchwep <- false
				scope.hasshotgunwep <- false
			}
			
			if (scope.modmenucooldown > Time())
			{
				player.RemoveHudHideFlags(4)
				player.SetScriptOverlayMaterial(null)
				continue
			}

			if (thinkertick % 7 == 0)
			{
				local tracetable =
				{
					start = player.EyePosition()
					end = player.EyePosition() + (player.EyeAngles().Forward() * 1300)
					mask = 33570827
					ignore = player
				}
				
				TraceLineEx(tracetable)
				
				scope.lookingat = tracetable.enthit.GetName()
				
				if (startswith(scope.lookingat, "gallery"))
				{
					scope.inmodmenu = true
					player.AddCustomAttribute("no_attack", 1, 0.5)
					player.AddHudHideFlags(4)
					
					if (!scope.lastfetchresults.beatmission)
					{
						ClientPrint(player, 4, "Complete the mission to earn access to these items")
						scope.lookingat = null
						scope.inmodmenu = false
						player.RemoveHudHideFlags(4)
						continue
					}
					
					switch (scope.lookingat.slice(8))
					{
						case "loch":
						{
							if (player.GetPlayerClass() != 4)
							{
								ClientPrint(player, 4, "Only Demoman can equip this")
								invalid = true
							}
							
							else player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_loch")

							break
						}
						
						case "bow":
						{
							if (player.GetPlayerClass() != 2)
							{
								ClientPrint(player, 4, "Only Sniper can equip this")
								invalid = true
							}
							
							else player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_bow")
							
							break
						}
						
						case "hatch":
						{
							if (!scope.lastfetchresults.beatsecretwave)
							{
								ClientPrint(player, 4, "Complete all six waves to earn access to this item")
								invalid = true
							}
							
							else player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_hatch")
							
							// player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_hatch")
							
							break
						}
						
						case "shotgun":
						{
							if (player.GetPlayerClass() != 5)
							{
								ClientPrint(player, 4, "Only Medic can equip this")
								invalid = true
							}
							
							else player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_shotgun")
							
							break
						}
					}
					
					if (invalid)
					{
						scope.lookingat = null
						scope.inmodmenu = false
						player.RemoveHudHideFlags(4)
						continue
					}
				}
				
				else
				{
					scope.lookingat = null
					scope.inmodmenu = false
					player.RemoveHudHideFlags(4)
				}
			}
			
			if (scope.inmodmenu)
			{
				if (NetProps.GetPropInt(player, "m_afButtonPressed") & 1)
				{
					switch (scope.lookingat.slice(8))
					{
						case "hatch":
						{
							if (!scope.hashatchwep)
							{
								scope.hashatchwep = true
								
								local classname
								
								if (player.GetPlayerClass() == 1) classname = "tf_weapon_bat"
								else if (player.GetPlayerClass() == 8) classname = "tf_weapon_knife"
								else if (player.GetPlayerClass() == 9) classname = "tf_weapon_wrench"
								else classname = "tf_weapon_club"
								
								local hatchwep = player.GetWeapon(classname, 30758)
								
								local vm = NetProps.GetPropEntity(player, "m_hViewModel")

								NetProps.SetPropInt(hatchwep, "m_nRenderMode", 1)
								NetProps.SetPropInt(hatchwep, "m_clrRender", 0)
								
								AddThinkToEnt(hatchwep, "HatchVM_Think")
							}
							
							else
							{
								scope.hashatchwep = false
								player.ForceRespawn()
							}
							
							break
						}
						
						case "shotgun":
						{
							if (!scope.hasshotgunwep)
							{
								scope.hasshotgunwep = true
								GetShotgunVM.call(scope)
							}
							
							else
							{
								player.SetCustomModelWithClassAnimations("")

								scope.hasshotgunwep = false
								player.ForceRespawn()
							}
							
							break
						}
						
						default:
						{
							EquipWeaponMod.call(scope, scope.lookingat.slice(8))

							break
						}
					}
					
					player.SetScriptOverlayMaterial(null)
					
					scope.inmodmenu = false
					scope.modmenucooldown = Time() + 3.0
				}
			}
			
			else player.SetScriptOverlayMaterial(null)
		}
	}
	
	GetShotgunVM = function()
	{
		local weapon = Entities.CreateByClassname("tf_weapon_shotgun_primary")

		NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 9)
		NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
		NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
		
		weapon.SetTeam(self.GetTeam())
		
		Entities.DispatchSpawn(weapon)
		
		self.Weapon_Equip(weapon)   
		
		NetProps.SetPropInt(weapon, "m_nRenderMode", 1)
		NetProps.SetPropInt(weapon, "m_clrRender", 0)
		
		weapon.SetCustomViewModelModelIndex(PrecacheModel("models/weapons/c_models/c_engineer_arms.mdl"))
		weapon.SetModelSimple("models/weapons/c_models/c_engineer_arms.mdl")
		NetProps.SetPropInt(weapon, "m_iViewModelIndex", GetModelIndex("models/weapons/c_models/c_engineer_arms.mdl"))
		NetProps.SetPropInt(weapon, "m_iWorldModelIndex", GetModelIndex("models/weapons/c_models/c_engineer_arms.mdl"))

		local hands = SpawnEntityFromTable("tf_wearable_vm", { modelindex = PrecacheModel("models/weapons/c_models/c_medic_arms.mdl") } )
		local hands2 = SpawnEntityFromTable("tf_wearable_vm", { modelindex = PrecacheModel("models/weapons/w_models/w_shotgun.mdl") } )
		
		NetProps.SetPropBool(hands, "m_bForcePurgeFixedupStrings", true)
		NetProps.SetPropBool(hands2, "m_bForcePurgeFixedupStrings", true)
		
		self.EquipWearableViewModel(hands)
		self.EquipWearableViewModel(hands2)

		NetProps.SetPropEntity(hands, "m_hWeaponAssociatedWith", weapon)
		NetProps.SetPropEntity(hands2, "m_hWeaponAssociatedWith", weapon)
		NetProps.SetPropEntity(weapon, "m_hExtraWearableViewModel", hands2)
		
		NetProps.SetPropIntArray(self, "m_iAmmo", 32 * NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).GetAttribute("maxammo primary increased", 1.0), 1)
		weapon.SetClip1(-1)
		
		weapon.AddAttribute("mod max primary clip override", -1.0, -1.0) // hides reserve ammo
		
		weapon.AddAttribute("fire rate penalty", 2.5, -1.0)
		weapon.AddAttribute("bullets per shot bonus", 10, -1.0)
		weapon.AddAttribute("damage penalty", 0.5, -1.0)
		
		NetProps.SetPropEntity(self, "m_hActiveWeapon", null)	
		self.Weapon_Switch(weapon)
		
		AddThinkToEnt(weapon, "ShotgunVM_Think")
	}
	
	HatchVM_Think = function()
	{
		try { self.GetScriptScope() }
		catch (e) { return }
		
		local scope = self.GetScriptScope()
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		local mainvm = NetProps.GetPropEntity(owner, "m_hViewModel")
		
		if (!("vm" in scope))
		{
			self.AddAttribute("crit mod disabled", 0.0, -1.0)
			
			scope.vm <- Entities.CreateByClassname("obj_teleporter")
			vm.SetAbsOrigin(self.GetOrigin())
			vm.DispatchSpawn()
			vm.SetModel(self.GetModelName())
			vm.SetAbsAngles(self.GetAbsAngles())
			vm.AddEFlags(4194304)
			vm.SetSolid(0)
			NetProps.SetPropBool(vm, "m_bPlacing", true)
			NetProps.SetPropInt(vm, "m_fObjectFlags", 2)
			NetProps.SetPropEntity(vm, "m_hBuilder", owner)
			
			scope.hatchwepprop <- SpawnEntityFromTable("prop_dynamic",
			{
				origin             	 = self.GetOrigin()
				modelscale			 = 0.06
				angles				 = QAngle(0, 0, 120)
				disablebonefollowers = 1
				disableshadows		 = 1
				solid				 = 0
				model 			   	 = "models/props_mvm/mann_hatch.mdl"
			})
			
			NetProps.SetPropBool(vm, "m_bClientSideAnimation", false)
			
			vm.AcceptInput("SetParent", "!activator", mainvm, null)
			
			hatchwepprop.AcceptInput("SetParent", "!activator", vm, null)
			
			EntFireByHandle(hatchwepprop, "SetParentAttachmentMaintainOffset", "weapon_bone", 0.1, null, null)
			EntFireByHandle(hatchwepprop, "RunScriptCode", "self.SetLocalOrigin(Vector())", 0.2, null, null)
			EntFireByHandle(hatchwepprop, "RunScriptCode", "self.SetLocalAngles(QAngle(0, 0, 180))", 0.2, null, null)
			
			scope.wm <- owner.GetWearable("models/props_mvm/mann_hatch.mdl", false, "effect_hand_R", null)

			NetProps.SetPropInt(self, "m_fEffects", 48)
			NetProps.SetPropInt(wm, "m_fEffects", 48)
			NetProps.SetPropInt(vm, "m_fEffects", 48)
			NetProps.SetPropInt(hatchwepprop, "m_fEffects", 48)
			
			wm.SetModelScale(0.06, -1.0)
			
			vm.SetPlaybackRate(1.0)

			SetDestroyCallback(self, function()
			{
				try
				{
					local scope = self.GetScriptScope()
					scope.wm.Kill()
					scope.vm.Kill()
				}
				
				catch (e) {}
			})
		}
		
		if (!vm.IsValid()) return -1
		
		vm.StudioFrameAdvance()
		vm.DispatchAnimEvents(vm)
		
		if (owner.GetActiveWeapon() != self || owner.IsTaunting() || in_snatcher_cutscene)
		{
			vm.DisableDraw()
			wm.DisableDraw()
			hatchwepprop.DisableDraw()
			return -1
		}
		
		vm.EnableDraw()
		wm.EnableDraw()
		hatchwepprop.EnableDraw()
		
		if (vm.GetSequence() != self.GetSequence())
		{
			vm.SetSequence(self.GetSequence())
			vm.SetCycle(0.0)
			vm.SetPlaybackRate(1.0)
		}

		if (vm.GetCycle() >= 1.0) vm.SetCycle(0.0)
		
		return -1
	}
	
	ShotgunVM_Think = function()
	{
		try { self.GetScriptScope() }
		catch (e) { return }
		
		local scope = self.GetScriptScope()
		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		local syringe = NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 0)
		local medigun = NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 1)
		local melee = NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 2)
		
		if (!("curwep" in scope)) scope.curwep <- owner.GetActiveWeapon()
		
		if (owner.GetActiveWeapon() == syringe)
		{	
			if (NetProps.GetPropIntArray(owner, "m_iAmmo", 1) <= 0) owner.Weapon_Switch(medigun)
			else
			{
				NetProps.SetPropEntity(owner, "m_hActiveWeapon", null)
				owner.Weapon_Switch(self)
			}
		}
		
		if (thinkertick % 7 != 0) return -1
		
		NetProps.SetPropInt(owner, "m_nRenderMode", 10)
		
		owner.GetWearable("models/player/medic.mdl")

		if (owner.GetActiveWeapon() == self)
		{	
			if (owner.GetModelName() != "models/player/engineer.mdl") owner.SetCustomModelWithClassAnimations("models/player/engineer.mdl")
			
			if (NetProps.GetPropIntArray(owner, "m_iAmmo", 1) <= 0) owner.Weapon_Switch(medigun)

			if (owner.IsTaunting())
			{
				owner.RemoveWearable(9)
				
				for (local scene; scene = Entities.FindByClassname(scene, "instanced_scripted_scene"); )
				{
					if (NetProps.GetPropEntity(scene, "m_hOwner") != owner) continue

					if (NetProps.GetPropString(scene, "m_iszSceneFile").find("taunt01") != null)
					{
						scene.Kill()
						
						EntFireByHandle(owner, "RunScriptCode", "self.PlayScene(`scenes/Player/Medic/low/` + RandomInt(607, 608) + `.vcd`, -1.0)", 0.1, null, null)
						
						break
					}
					
				}
			}
			
			else owner.GetWearableItem(9)
		}
		
		else
		{
			if (owner.GetModelName() != "models/player/medic.mdl") owner.SetCustomModelWithClassAnimations("models/player/medic.mdl")
		
			owner.RemoveWearable(9)
		}
		
		if (owner.GetActiveWeapon() == medigun)
		{
			if (owner.IsTaunting())
			{
				if (NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 35) owner.RemoveWearable(NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
			}
		
			else owner.GetWearableItem(NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
		}
		
		else owner.RemoveWearable(NetProps.GetPropInt(medigun, "m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
	
		if (owner.GetActiveWeapon() == melee)
		{
			if (NetProps.GetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 30758) owner.GetWearableItem(NetProps.GetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
		}
	
		else owner.RemoveWearable(NetProps.GetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex"))

		if (curwep != owner.GetActiveWeapon() || owner.IsTaunting())
		{
			owner.SetModelScale(owner.GetModelScale(), 0)
			
			for (local child = owner.FirstMoveChild(); child != null; child = child.NextMovePeer())
			{ 
				child.SetModelScale(child.GetModelScale(), 0.0)
				
				NetProps.SetPropBool(child, "m_AttributeManager.m_Item.m_bInitialized", false)
				
				EntFireByHandle(child, "RunScriptCode", "NetProps.SetPropBool(self, \x22m_AttributeManager.m_Item.m_bInitialized\x22, true)", 0.10, child, child)
			}
		}

		curwep = owner.GetActiveWeapon()

		self.AddAttribute("projectile penetration", syringe.GetAttribute("projectile penetration", 0.0), -1.0)
		self.AddAttribute("fire rate bonus", syringe.GetAttribute("fire rate bonus", 1.0), -1.0)
		self.AddAttribute("heal on kill", syringe.GetAttribute("heal on kill", 0.0), -1.0)
		
		return -1
	}
	
	DisplayLog_Think = function()
	{
		for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
			{
				if (NetProps.GetPropInt(player, "m_afButtonPressed") & 8192)
				{
					foreach (playor in GetAllPlayers(2, false, false)) ClientPrint(player,3,NetProps.GetPropString(playor, "m_szNetname") + "'s wavedata: " + playor.GetScriptScope().lastfetchresults.wavedata)
				}
			}
		}
	}
	
	MapCleanup = function()
	{
		foreach (player in GetAllPlayers(false, false, false))
		{
			player.SetCustomModelWithClassAnimations("")
			NetProps.SetPropInt(player, "m_nRenderMode", 0)
			
			local killarray = []
			
			for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) { if ("custom_wearable" in child.GetScriptScope()) killarray.append(child)	}

			foreach (ent in killarray) ent.Kill()
		}
	}
}

PrecacheScriptSound("MVM.BotStep")
PrecacheScriptSound("Samurai.Conch")
PrecacheScriptSound("Player.IsNowIT")

try { IncludeScript("playerlog_pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate or parse player logging file. Access to certain features in this mission may be unavailable.") }

try { IncludeScript("pea2.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate or parse `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

if (!("PEA_ONETIME" in getroottable()))
{
	::PEA_ONETIME <- // declare these variables only once on initial load, don't update them on any future loads
	{	
		coffins_active = false
		suppress_waveend_music = false
		secretwave_unlocked = false
		samurai_spawn = null
		samurai_spawn_minion = null
		guaranteedbranch = false
		
		coffintime_cc = SpawnEntityFromTable("color_correction", 
		{
			StartDisabled    = 1
			maxfalloff       = -1
			minfalloff       = -1
			fadeInDuration   = 5.0
			fadeOutDuration  = 5.0
			filename         = "materials/colorcorrection/zombie_cc25.raw"
		})
	}
	
	foreach (thing, var in PEA_ONETIME) getroottable()[thing] <- getroottable()["PEA_ONETIME"][thing]

	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "m_brazier_flame" })

	samurai_spawn = Entities.FindByName(null, "spawnbot_samurai")
	samurai_spawn_minion = Entities.FindByName(null, "spawnbot_samurai_2")
	
	coffintime_cc.KeyValueFromString("classname", "entity_sign") // this makes the entity preserve itself on mission reloads
	
	PrecacheSound("misc/ks_tier_02_kill_02.wav")
	
	DisconnectNavAreas(
	[
		[180, 414], [189, 39], [189, 2077], [274, 581], [318, 1134], [3264, 1786], [406, 332], [406, 404], [406, 4017], [485, 169], [579, 39], [736, 5381], [736, 5382], [979, 5381], [982, 581], [1134, 44], [1178, 303], [1278, 140], [1278, 902], [2417, 457], [3160, 1763], [3177, 3188], [3178, 3188],
		[3179, 1763], [3324, 1076], [3379, 5365], [4400, 5381], [4406, 5381], [5725, 140], [5726, 140], [5727, 140], [5728, 140], [5307, 204], [5365, 3379], [910, 5827], [910, 5828], [145, 5683], [145, 5684], [234, 5684], [360, 368], [481, 2693], [481, 5684], [481, 5684]
	])
	
	ConnectNavAreas([[116, 123]])
	
	UnblockNavAreas([85, 200, 297, 298, 354, 356, 454, 623, 792, 795, 1075, 1078, 1533, 1540, 1545, 1546, 1547, 2342, 2343, 2371, 2388, 2389])
	
	foreach (player in GetAllPlayers(2))
	{
		if (player.IsFakeClient()) continue
		
		player.ValidateScriptScope()
		
		IsInLog.call(player.GetScriptScope())
	}
}

samurai_spawn.Disable()
samurai_spawn_minion.Disable()

foreach (sound in coffin_sounds) PrecacheSound(sound)

if (!secretwave_unlocked)
{
	NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineMaxWaveCount", 5)
	
	if (Wave == 6)
	{
		NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveCount", 5)
		
		EntFire("FrontUpgradeStation", "Enable")
		EntFire("FrontUpgradeGate", "Open")
	}
}

for (local ent; ent = Entities.FindByClassname(ent, "func_nav_prefer"); ) ent.Kill()

for (local ent; ent = Entities.FindByClassname(ent, "func_nav_avoid"); )
{
	local id = NetProps.GetPropInt(ent, "m_iHammerID")
	
	if (id == 1920728 || id == 1941647 || id == 1395198 || id == 1396096)
	{
		ent.KeyValueFromString("targetname", "nav_avoid_dontdisable")
		continue
	}

	ent.Kill()
}

for (local ent; ent = Entities.FindByName(ent, "bombpath_choose_relay"); ) ent.Disable()
for (local ent; ent = Entities.FindByName(ent, "bombpath_holograms_clear_relay"); ) ent.Disable()
	
SpawnNavBrush("nav_avoid_giant_upgradestation_dontdisable", Vector(-100, -550, 300), "-250 -250 -250", "250 250 250", "bot_giant")

for (local i = 3; i <= 6; i++) EntFire("sentrynest_right" + i, "Disable")
for (local i = 2; i <= 6; i++) EntFire("sentrynest_left" + i, "Disable")
	
if (!(!guaranteedbranch)) cross_connections[1].remove(cross_connections[1].find(guaranteedbranch))

megatonicon.KeyValueFromString("classname", "megaton")

if (!wavewon)
{
	local cashcollect = SpawnEntityFromTable("trigger_hurt",
	{
		origin		= Vector(1000, -2300, -100)
		targetname  = "tunnelspawncashcollector"
		damage 		= 0.001
		damagecap   = 9999
		damagetype  = 1
		damagemodel = 0
		spawnflags  = 0
	})
	
	cashcollect.KeyValueFromInt("solid", 2)
	cashcollect.KeyValueFromString("mins", "-150 -1000 -500")
	cashcollect.KeyValueFromString("maxs", "150 0 500")
}
	
if (Wave != 5)
{
	if (!wavewon) DetermineBombPath(1)
	else		  EntFireByHandle(gamerules_entity, "RunScriptCode", "DetermineBombPath(1)", 5.0, null, null)
}

else
{
	CreatePathHologram(Vector(13, -1831, -50), QAngle(0, 0, 0))
	CreatePathHologram(Vector(532, -1832, -50), QAngle(0, 0, 0))
	CreatePathHologram(Vector(1010, -1546, -50), QAngle(0, 120, 0))
	CreatePathHologram(Vector(752, -1232, 50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(241, -1236, 50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(1010, -1546, -50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(999, -817, 50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(987, -313, 50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(1010, -1100, -50), QAngle(0, 0, 0))
	CreatePathHologram(Vector(1525, -1100, 150), QAngle(0, 90, 0))
	CreatePathHologram(Vector(1525, -300, 300), QAngle(0, 0, 0))
	CreatePathHologram(Vector(2050, -300, 300), QAngle(0, 90, 0))
	CreatePathHologram(Vector(2050, 400, 300), QAngle(0, 120, 0))
	CreatePathHologram(Vector(-242, -1100, 150), QAngle(0, 110, 0))
	CreatePathHologram(Vector(-444, -349, 100), QAngle(0, 90, 0))
	CreatePathHologram(Vector(-436, 108, 150), QAngle(0, 0, 0))
	CreatePathHologram(Vector(-490, -1350, 250), QAngle(0, 100, 0))
	CreatePathHologram(Vector(-750, -800, 350), QAngle(0, 90, 0))
	CreatePathHologram(Vector(-750, 150, 450), QAngle(0, 90, 0))
	CreatePathHologram(Vector(-450, 900, 350), QAngle(0, 70, 0))
	CreatePathHologram(Vector(993, 100, 50), QAngle(0, 0, 0))
	CreatePathHologram(Vector(1672, 171, 50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(993, 100, 50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(139, 231, 150), QAngle(0, 90, 0))
	CreatePathHologram(Vector(145, 875, 150), QAngle(0, 135, 0))
	CreatePathHologram(Vector(139, 231, 150), QAngle(0, 0, 0))
	CreatePathHologram(Vector(145, 875, 150), QAngle(0, 120, 0))
	CreatePathHologram(Vector(1686, 1263, 150), QAngle(0, 135, 0))
	CreatePathHologram(Vector(1176, 1817, 150), QAngle(0, 180, 0))
	CreatePathHologram(Vector(1686, 1150, 150), QAngle(0, 70, 0))
	CreatePathHologram(Vector(1900, 1700, 300), QAngle(0, 135, 0))
	CreatePathHologram(Vector(1300, 2150, 300), QAngle(0, 90, 0))
	CreatePathHologram(Vector(1200, 3100, 150), QAngle(0, 90, 0))
	CreatePathHologram(Vector(1200, 3500, 50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(600, 1813, 50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(-197, 1823, 100), QAngle(0, 135, 0))
	CreatePathHologram(Vector(-550, 2250, 100), QAngle(0, 50, 0))
	CreatePathHologram(Vector(-100, 3050, -50), QAngle(0, 30, 0))
	CreatePathHologram(Vector(600, 1813, 50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(582, 2266, 50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(577, 2860, -50), QAngle(0, 180, 0))
	CreatePathHologram(Vector(105, 2871, -50), QAngle(0, 90, 0))
	CreatePathHologram(Vector(105, 3541, -50), QAngle(0, 0, 0))
	CreatePathHologram(Vector(-200, 1600, 100), QAngle(0, 20, 0))
	CreatePathHologram(Vector(-200, 1600, 100), QAngle(0, 120, 0))
}

ModifyWaveBar(true)

if (WaveHasIcon("dead_blu_lite"))
{
	if (Entities.FindByModel(null, "models/workshop/player/items/spy/taunt_the_crypt_creeper/taunt_the_crypt_creeper.mdl") == null)
	{
		for (local ent; ent = Entities.FindByName(ent, "spawnbot_coffin*"); )
		{
			ent.Disable()
			
			ent.ValidateScriptScope()
			
			local coffinprop = SpawnEntityFromTable("prop_dynamic",
			{
				targetname		   	 = "coffin_prop"
				origin             	 = SnapVectorToGround(ent.GetOrigin())
				angles             	 = ent.GetAbsAngles()
				disablebonefollowers = 1
				model 			   	 = "models/workshop/player/items/spy/taunt_the_crypt_creeper/taunt_the_crypt_creeper.mdl"
			})
			
			coffinprop.ValidateScriptScope()
			coffinprop.GetScriptScope().associated_spawn_ent <- ent
			
			NetProps.SetPropBool(coffinprop, "m_bClientSideAnimation", false)
			
			AddThinkToEnt(coffinprop, "CoffinProp_Think")
		}
	}
}

else { for (local ent; ent = Entities.FindByModel(ent, "models/workshop/player/items/spy/taunt_the_crypt_creeper/taunt_the_crypt_creeper.mdl"); ) ent.Kill() }

if (coffins_active) ToggleCoffins()
	
for (local ent; ent = Entities.FindByClassname(ent, "point_viewcontrol"); ) ent.Kill()

for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
{
	local player = PlayerInstanceFromIndex(i)
	
	if (player == null) continue
	if (player.IsFakeClient()) continue
	if (player.GetTeam() != 2) continue
	
	player.ValidateScriptScope()
	player.SetScriptOverlayMaterial(null)
	
	local scope = player.GetScriptScope()

	if (!wavewon) { if ("modsactive" in scope) { foreach (name, status in scope.modsactive) { if (status) EquipWeaponMod.call(scope, name, true) } } }
	
	IsInLog.call(player.GetScriptScope())

	if ("hasducky" in scope) delete scope.hasducky
	
	player.AddCustomAttribute("vision opt in flags", 2, -1)
}

AssignThinkToThinksTable("TunnelSpawnFix_Think")
AssignThinkToThinksTable("SuppressWaveEndMusic_Think")
AssignThinkToThinksTable("Coffin_Think")

AssignThinkToThinksTable("DisplayLog_Think")

AssignThinkToThinksTable("FetchCheck_Think")

for (local ent; ent = Entities.FindByClassname(ent, "entity_sign"); ) { if (ent.GetName().find("support") != null) ent.Enable() }
for (local ent; ent = Entities.FindByClassname(ent, "entity_sign"); ) { if (ent.GetName().find("coffin") != null) ent.Disable() }

if (debug)
{
	for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
		{			
			// player.Teleport(true, Vector(1000, -1200, 0), false, QAngle(), false, Vector())

			// player.SetScriptOverlayMaterial("coffin_warning_overlay")
			// player.SetScriptOverlayMaterial("undead_dread_overlays/weaponmod_loch")
			// player.AddHudHideFlags(4)
			
			// EntFireByHandle(player, "SetScriptOverlayMaterial", "", 0.0, null, null)
			// EntFireByHandle(player, "RunScriptCode", "self.RemoveHudHideFlags(4)", 3.0, null, null)
		}
	}
}