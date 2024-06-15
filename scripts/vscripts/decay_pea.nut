::PEA <-
{	
	zombies_active = 0

	BFB_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		owner.SetScoutHypeMeter(owner.GetScoutHypeMeter() - self.GetScriptScope().boost_drainrate)
		
		owner.AddCustomAttribute("CARD: move speed bonus", 1, -1.0) // having this attribute means the game will use its own routines for calculating boost speed
		
		return -1
	}
	
	CowMangler_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		if (owner.GetActiveWeapon() == self && owner.InCond(0))
		{
			owner.RemoveCondEx(0, true)
			owner.AddCondEx(32, 0.1, self)
			owner.AddCustomAttribute("disable weapon switch", 1, 2.25)
		}
		
		for (local ent; ent = Entities.FindByClassname(ent, "tf_projectile_energy_ball"); )
		{
			if (NetProps.GetPropBool(ent, "m_bChargedShot") && ent.GetOwner() == owner)
			{
				NetProps.SetPropFloat(self, "m_flEnergy", self.GetMaxClip1())
				
				local orb = SpawnEntityFromTable("tf_projectile_mechanicalarmorb", 
				{
					basevelocity = ent.GetAbsVelocity()
					teamnum      = ent.GetTeam()
					origin       = ent.GetOrigin()
					angles       = ent.GetAbsAngles()
				})
				
				local orb_explosion_pos = owner.EyePosition() + (owner.EyeAngles().Forward() * 1300)
				
				local tracetable =
				{
					start = owner.EyePosition()
					end = owner.EyePosition() + (owner.EyeAngles().Forward() * 1300)
					mask = Constants.FContents.CONTENTS_SOLID
				}
				
				TraceLineEx(tracetable)
				
				orb.ValidateScriptScope()
				orb.GetScriptScope().hitpos <- tracetable.pos - (owner.EyeAngles().Forward() * 32)

				orb.SetOwner(owner)
				
				AddThinkToEnt(orb, "OrbExplosion_Think")
				
				ent.Kill()
			}
		}
		
		return -1
	}
	
	OrbExplosion_Think = function()
	{
		if ((self.GetScriptScope().hitpos - self.GetOrigin()).Length2D() < 64.0)
		{
			PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "nucleus_core_steady" })
			
			local explosion = SpawnEntityFromTable("info_particle_system", 
			{
				origin       = self.GetOrigin()
				start_active = 1
				effect_name  = "nucleus_core_steady"
			})
			
			PrecacheSound("npc/scanner/scanner_electric2.wav")
			
			EmitSoundEx(
			{
				sound_name = "npc/scanner/scanner_electric2.wav",
				filter = 5,
				volume = 1,
				soundlevel = 150,
				entity = self
				flags = 1,
				channel = 6
			})
			
			EntFireByHandle(explosion, "Kill", null, 1.5, null, null)
			
			for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 250.0); )
			{
				if (player == null) return
				if (player.GetTeam() != 3) return
				
				player.AddCondEx(71, 1.0, self)
				player.AddCondEx(30, 8.0, self)
				player.TakeDamageEx(self, self.GetOwner(), fire, Vector(0, 0, 0), player.GetOrigin(), 0.01, 8)
			}
		}
	}
	
	AirStrike_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		if (owner.GetActiveWeapon() == self)
		{
			if (owner.InCond(81))
			{
				owner.AddCondEx(30, 0.1, self)
				self.AddAttribute("Blast radius increased", 1.25, -1.0) // account for hardcoded radius reduction 
			}
			
			else self.RemoveAttribute("Blast radius increased") // the duration argument for addattribute does not work
		}

		return -1
	}
	
	PainTrain_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		for (local ent; ent = Entities.FindByClassnameWithin(ent, "item_teamflag", owner.GetOrigin(), 250.0); ) if (owner.GetActiveWeapon() == self) owner.AddCondEx(34, 0.1, self)

		return -1
	}
	
	ThermalThruster_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		if (owner.InCond(125))
		{
			owner.AddCondEx(107, 0.1, self)
			owner.AddCustomAttribute("CARD: move speed bonus", 10, 0.1)
			owner.AddCustomAttribute("disable weapon switch", 1, 0.1)
		}

		return -1
	}
	
	SplendidScreen_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwnerEntity")
		
		if (owner.InCond(17))
		{	
			owner.AddCondEx(28, 0.1, self)
			owner.AddCondEx(51, 0.1, self)
			owner.SetSolid(0)
			
			for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 250.0); )
			{
				if (player == null) continue
				if (player.GetTeam() != 3) continue
				
				local selfmins = owner.GetBoundingMins() + owner.GetOrigin() - Vector(200, 200, 200)
				local selfmaxs = owner.GetBoundingMaxs() + owner.GetOrigin() + Vector(200, 200, 200)

				local playermins = player.GetBoundingMins() + player.GetOrigin()
				local playermaxs = player.GetBoundingMaxs() + player.GetOrigin()

				if (playermins.x > selfmaxs.x || playermaxs.x < selfmins.x || playermins.y > selfmaxs.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermins.z > selfmaxs.z || playermaxs.z < selfmins.z) return
				else
				{
					local pushforce = player.GetOrigin() - self.GetOrigin()
					pushforce.Norm()
					pushforce.z = 0.5
					pushforce = pushforce * 50
					
					if (NetProps.GetPropEntity(player, "m_hGroundEntity") == Entities.FindByClassname(null, "worldspawn")) player.SetOrigin(player.GetOrigin() + Vector(0, 0, 24))
					
					player.RemoveFlag(1)
					player.AddCond(115)
					player.ApplyAbsVelocityImpulse(pushforce)
				}
			}
		}
		
		else owner.SetSolid(1)
		
		return -1
	}
	
	Tomislav_Think = function()
	{		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		if (NetProps.GetPropInt(self, "m_iWeaponState") > 0 && NetProps.GetPropInt(owner, "m_afButtonLast") & 8192)
		{
			NetProps.SetPropInt(self, "m_iWeaponState", 0)
			owner.RemoveCond(0)
			owner.Weapon_Switch(NetProps.GetPropEntityArray(owner, "m_hMyWeapons", 2))
		}

		return -1
	}
	
	EurekaEffect_Think = function()
	{		
		local scope = self.GetScriptScope()
		
		if (!("tick" in scope)) scope.tick <- 1
		
		local owner = NetProps.GetPropEntity(self, "m_hOwner")
		
		if (NetProps.GetPropInt(owner, "m_Local.m_audio.soundscapeIndex") == 107 || NetProps.GetPropInt(owner, "m_Local.m_audio.soundscapeIndex") == 108)
		{
			if (scope.tick % 33 == 0) owner.Regenerate(true)
			owner.AddCondEx(16, 0.1, self)
		}
		
		scope.tick = scope.tick + 1

		return -1
	}
	
	weapontweak_ids = [41, 142, 154, 173, 308, 310, 356, 424, 426, 441, 589, 772, 1104, 1179]
	
	WeaponTweakCheck = function()
	{	
		for (local i = 0; i <= weapontweak_ids.len() - 1; i++)
		{
			for (local j = 0; j < 7; j++)
			{
				local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", j)

				if (weapon == null) continue
				
				local weaponid = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				
				if (weaponid == weapontweak_ids[i])
				{
					switch (weaponid)
					{
						case 41: // natascha
						{
							weapon.AddAttribute("slow enemy on hit", 0, -1.0)
							weapon.AddAttribute("damage penalty", 1, -1.0)
							weapon.AddAttribute("spunup_damage_resistance", 1, -1.0)
							weapon.AddAttribute("weapon spread bonus", 1.25, -1.0)

							break
						}
						case 142: // gunslinger
						{
							weapon.AddAttribute("Construction rate increased", 2.5, -1.0)
							
							NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).AddAttribute("single wep deploy time decreased", 0.2, -1.0)
							NetProps.GetPropEntityArray(self, "m_hMyWeapons", 1).AddAttribute("single wep deploy time decreased", 0.2, -1.0)
							NetProps.GetPropEntityArray(self, "m_hMyWeapons", 2).AddAttribute("single wep deploy time decreased", 0.2, -1.0)
							
							break
						}
						case 154: // pain train
						{
							weapon.AddAttribute("dmg taken from bullets increased", 1, -1.0)
							weapon.AddAttribute("crit mod disabled", 0, -1.0)
							
							AddThinkToEnt(weapon, "PainTrain_Think")
							break
						}
						case 173: // vita-saw
						{
							local scope = self.GetScriptScope()
							
							if ("uber_retained" in scope) NetProps.SetPropFloat(NetProps.GetPropEntityArray(self, "m_hMyWeapons", 1), "m_flChargeLevel", scope.uber_retained)

							scope.uber_retained <- 0
							
							self.SetHealth(150)
				
							weapon.AddAttribute("ubercharge_preserved_on_spawn_max", 0.01, -1.0)
							weapon.AddAttribute("max health additive penalty", 0, -1.0)
							
							weapon.ValidateScriptScope()
							
							weapon.GetScriptScope().organs <- 0
							weapon.GetScriptScope().giant_organs <- 0

							break
						}
						case 308: // loch-n-load
						{
							weapon.AddAttribute("CARD: damage bonus", 1.2, -1.0)
							weapon.AddAttribute("dmg bonus vs buildings", 1, -1.0)
							weapon.AddAttribute("clip size penalty", 0.5, -1.0)
							weapon.AddAttribute("Blast radius decreased", 1, -1.0)
							
							weapon.SetClip1(weapon.GetMaxClip1())
							break
						}
						case 310: // warrior's spirit
						{
							weapon.AddAttribute("dmg taken increased", 1, -1.0)
							weapon.AddAttribute("damage bonus", 1, -1.0)
							weapon.AddAttribute("heal on kill", 0, -1.0)
							weapon.AddAttribute("minicrits become crits", 1, -1.0)
							weapon.AddAttribute("crit mod disabled", 0, -1.0)
							
							NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).AddAttribute("no primary ammo from dispensers while active", 1, -1.0)

							break
						}
						case 356: // conniver's kunai
						{
							self.SetScriptOverlayMaterial("skull_scamper_overlays/kunai/kunai_tier_0")
							self.SetHealth(75)
							
							weapon.AddAttribute("sanguisuge", 0, -1.0)
							weapon.AddAttribute("max health additive penalty", -50, -1.0)
							
							weapon.ValidateScriptScope()
							local weaponscope = weapon.GetScriptScope()
							
							weaponscope.tier <- 0
							weaponscope.killsuntilnexttier <- 4

							break
						}
						case 424: // tomislav
						{
							weapon.AddAttribute("minigun spinup time decreased", 0.6, -1.0)
							weapon.AddAttribute("single wep deploy time decreased", 0.6, -1.0)
							
							AddThinkToEnt(weapon, "Tomislav_Think")
							break
						}
						case 426: // eviction notice
						{
							weapon.AddAttribute("mult_player_movespeed_active", 1, -1.0)
							weapon.AddAttribute("mod_maxhealth_drain_rate", 0, -1.0)
							weapon.AddAttribute("damage penalty", 0.65, -1.0)
							weapon.AddAttribute("speed_boost_on_hit", 0, -1.0)
							weapon.AddAttribute("heal on hit for slowfire", 25, -1.0)

							break
						}
						case 441: // cow mangler
						{
							weapon.AddAttribute("fire rate penalty", 1.15, -1.0)
							
							AddThinkToEnt(weapon, "CowMangler_Think")
							break
						}
						case 589: // eureka effect
						{
							weapon.AddAttribute("Construction rate decreased", 1, -1.0)
							weapon.AddAttribute("metal_pickup_decreased", 0.5, -1.0)
							weapon.AddAttribute("mod teleporter cost", 1, -1.0)
							weapon.AddAttribute("fire rate penalty", 1.15, -1.0)
							
							AddThinkToEnt(weapon, "EurekaEffect_Think")
							break
						}
						case 772: // bfb
						{
							weapon.AddAttribute("boost on damage", 0, -1.0)
							weapon.AddAttribute("hype resets on jump", 0, -1.0)
							weapon.AddAttribute("lose hype on take damage", 0, -1.0)
							
							weapon.ValidateScriptScope()
							weapon.GetScriptScope().boost_drainrate <- 0.3
							
							AddThinkToEnt(weapon, "BFB_Think")
							break
						}
						case 1104: // air strike
						{
							weapon.AddAttribute("Blast radius decreased", 1, -1.0)
							weapon.AddAttribute("damage penalty", 1, -1.0)
							weapon.AddAttribute("rocket jump damage reduction", 1, -1.0)
							weapon.AddAttribute("Projectile speed decreased", 0.6, -1.0)
							
							AddThinkToEnt(weapon, "AirStrike_Think")
							break
						}
						case 1179: // thermal thruster
						{
							weapon.AddAttribute("holster_anim_time", 0, -1.0)
							weapon.AddAttribute("item_meter_charge_rate", 1, -1.0)
							weapon.AddAttribute("falling_impact_radius_stun", 1, -1.0)
							weapon.AddAttribute("thermal_thruster_air_launch", 1, -1.0)
							weapon.AddAttribute("mult_item_meter_charge_rate", 0.4, -1.0) // prevent players from wasting credits on the upgrade

							AddThinkToEnt(weapon, "ThermalThruster_Think")
							break
						}
					}

					break
				}
			}
		}
		
		if (self.GetPlayerClass() == Constants.ETFClass.TF_CLASS_DEMOMAN) // demo shields are not assigned to "myweapons" tables so this has to be done
		{
			for (local ent; ent = Entities.FindByClassname(ent, "tf_wearable_demoshield"); )
			{
				if (NetProps.GetPropInt(ent, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 406 && NetProps.GetPropEntity(ent, "m_hOwnerEntity") == self)
				{
					ent.AddAttribute("charge recharge rate increased", 1, -1.0)
					ent.AddAttribute("charge impact damage increased", 1, -1.0)
					ent.AddAttribute("dmg taken from fire reduced", 1, -1.0)
					ent.AddAttribute("dmg taken from blast reduced", 1, -1.0)
					
					AddThinkToEnt(ent, "SplendidScreen_Think")
					break
				}
			}
		}
		
		if (self.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER) // weapons keep custom attributes on respawns, so engie's weapons need cleanup when gunslinger is unequipped
		{
			if (NetProps.GetPropInt(NetProps.GetPropEntityArray(self, "m_hMyWeapons", 2), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 142)
			{
				NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0).RemoveAttribute("single wep deploy time decreased")
				NetProps.GetPropEntityArray(self, "m_hMyWeapons", 1).RemoveAttribute("single wep deploy time decreased")
				NetProps.GetPropEntityArray(self, "m_hMyWeapons", 2).RemoveAttribute("single wep deploy time decreased")
			}
		}
	}
	
	BotTagCheck = function()
	{
		if (self.HasBotTag("zombie"))
		{	
			for (local player; player = Entities.FindByClassname(player, "player"); )
			{
				if (player == null) continue
				
				if (NetProps.GetPropInt(NetProps.GetPropEntityArray(player, "m_hMyWeapons", 2), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 173) continue
				
				player.ValidateScriptScope()
				local scope = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 2).GetScriptScope()
				
				if ("organs" in scope)
				{
					if (scope.organs != 6) continue
					
					self.Teleport(true, player.GetOrigin(), false, QAngle(0, 0, 0), false, Vector(0, 0, 0))
					self.ForceChangeTeam(2, true)
					self.AddCondEx(51, 3.0, self)
					
					switch (self.GetPlayerClass())
					{
						case Constants.ETFClass.TF_CLASS_SOLDIER: self.SetCustomModelWithClassAnimations("models/player/soldier.mdl"); break
						case Constants.ETFClass.TF_CLASS_PYRO: self.SetCustomModelWithClassAnimations("models/player/pyro.mdl"); break
						case Constants.ETFClass.TF_CLASS_DEMOMAN: self.SetCustomModelWithClassAnimations("models/player/demo.mdl"); break
						case Constants.ETFClass.TF_CLASS_HEAVYWEAPONS: self.SetCustomModelWithClassAnimations("models/player/heavy.mdl"); break
					}
					
					for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer()) if (child.GetClassname() == "tf_wearable") child.SetTeam(2)
					
					NetProps.SetPropIntArray(self, "m_iAmmo", NetProps.GetPropIntArray(self, "m_iAmmo", 1) * 100, 1)

					EntFire("spawnbot_single_flag", "Disable", null, -1.0)
					EntFire("spawnbot_mission_spy", "Disable", null, -1.0)
					
					scope.organs = 0
					
					if (self.IsMiniBoss()) scope.giant_organs = 0
					
					break
				}
			}
			
			if (self.GetTeam() == 3) self.ForceChangeTeam(1, true)
		}
		
		if (self.HasBotTag("flashuber")) AddThinkToEnt(self, "FlashUber_Think")
	}
	
	FlashUber_Think = function()
	{
		if (self.InCond(51)) return -1
		
		self.AddCondEx(52, 2.0, self)
		if (self.GetHealTarget() != null) self.GetHealTarget().AddCondEx(52, 2.0, self)
		
		return 5
	}
	
	CALLBACKS =
	{
		OnGameEvent_player_spawn = function(params)
		{
			local player = GetPlayerFromUserID(params.userid);
			
			if (player.IsFakeClient())
			{
				EntFireByHandle(player, "CallScriptFunction", "BotTagCheck", -1.0, null, null)
				return
			}
			
			player.SetScriptOverlayMaterial(null)
			
			EntFireByHandle(player, "CallScriptFunction", "WeaponTweakCheck", -1.0, null, null)
		}
		
		OnGameEvent_player_death = function(params)
		{
			local dead_player = GetPlayerFromUserID(params.userid)
			local attacker = GetPlayerFromUserID(params.attacker)
			
			dead_player.SetScriptOverlayMaterial(null)
			
			if (dead_player.IsFakeClient())
			{
				if (params.weapon == "pep_brawlerblaster") // BFB
				{
					local bfb = NetProps.GetPropEntityArray(attacker, "m_hMyWeapons", 0).GetScriptScope()

					if (bfb.boost_drainrate > 0.1) bfb.boost_drainrate = bfb.boost_drainrate - 0.01
					else						   bfb.boost_drainrate = 0.1
				}
				
				if (params.weapon == "warrior_spirit") attacker.AddCondEx(26, 5.0, attacker)
				if (params.weapon == "eviction_notice") attacker.AddCondEx(29, 5.0, attacker)
				
				if (params.weapon == "kunai" && params.customkill == 2)
				{
					local kunai = NetProps.GetPropEntityArray(attacker, "m_hMyWeapons", 1).GetScriptScope()
					
					if (kunai.tier == 5) return
					
					kunai.killsuntilnexttier = kunai.killsuntilnexttier - 1
					
					if (kunai.killsuntilnexttier == 0)
					{
						kunai.tier = kunai.tier + 1
						kunai.killsuntilnexttier = 4
						
						attacker.SetScriptOverlayMaterial("skull_scamper_overlays/kunai/kunai_tier_" + kunai.tier)
						attacker.AddCustomAttribute("max health additive bonus", 25 * kunai.tier, -1.0)
					}
				}
				
				AddThinkToEnt(dead_player, null)
				NetProps.SetPropString(dead_player, "m_iszScriptThinkFunction", "")
				dead_player.TerminateScriptScope()
			}
			
			else
			{
				if (NetProps.GetPropInt(NetProps.GetPropEntityArray(dead_player, "m_hMyWeapons", 2), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 589) EntFireByHandle(dead_player, "RunScriptCode", "self.ForceRespawn()", -1.0, null, null)
				if (NetProps.GetPropInt(NetProps.GetPropEntityArray(dead_player, "m_hMyWeapons", 2), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 173) dead_player.GetScriptScope().uber_retained = NetProps.GetPropFloat(NetProps.GetPropEntityArray(dead_player, "m_hMyWeapons", 1), "m_flChargeLevel")
			}
		}
		
		OnGameEvent_player_hurt = function(params)
		{
			if (params.attacker == 0) return // worldspawn
			
			local attacker = GetPlayerFromUserID(params.attacker)
			local victim = GetPlayerFromUserID(params.userid)
			
			if (!attacker.IsPlayer()) return
			
			if (attacker == victim) return
			
			if (attacker.IsFakeClient()) return
			
			if (NetProps.GetPropInt(NetProps.GetPropEntityArray(attacker, "m_hMyWeapons", 0), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 772 && params.weaponid == 85) // only BFB has this weaponid
			{
				attacker.SetScoutHypeMeter(attacker.GetScoutHypeMeter() + (params.damageamount / 6))
			}
		}
		
		OnScriptHook_OnTakeDamage = function(params)
		{
			if (!params.attacker.IsPlayer() || !params.const_entity.IsPlayer() || !params.const_entity.IsFakeClient() || params.attacker.IsFakeClient() || params.weapon == null) return

			local weaponscope = params.weapon.GetScriptScope()
			
			if (weaponscope != null)
			{
				if ("tier" in weaponscope)
				{
					if (weaponscope.tier == 5 && params.const_entity.IsMiniBoss() && params.damage_custom == 2) params.damage = params.damage * 2
				}
			}
			
			if (NetProps.GetPropInt(params.weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 41) // natascha
			{
				params.const_entity.ValidateScriptScope()
				local scope = params.const_entity.GetScriptScope()
				
				if (!("natascha_bullets" in scope)) scope.natascha_bullets <- 0
				
				scope.natascha_bullets = scope.natascha_bullets + 1
				
				if (!params.const_entity.IsMiniBoss() && scope.natascha_bullets < 10) params.const_entity.AddCustomAttribute("CARD: move speed bonus", 1 - (scope.natascha_bullets * 0.04), -1.0)
				
				if (params.const_entity.IsMiniBoss() && scope.natascha_bullets < 40) params.const_entity.AddCustomAttribute("CARD: move speed bonus", 1 - (scope.natascha_bullets * 0.01), -1.0)
			}
			
			if (NetProps.GetPropInt(params.weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 173) // vitasaw
			{
				weaponscope.organs = weaponscope.organs + 1
				
				if (weaponscope.organs == 6)
				{
					weaponscope.giant_organs = weaponscope.giant_organs + 1
					
					if (zombies_active >= 4) // destroy a random zombie to make room for another
					{
						for (local player; player = Entities.FindByClassname(player, "player"); )
						{
							if (player == null) continue
							if (player.IsFakeClient() && player.GetTeam() == 2) { player.TakeDamage(10000.0, 64, null); player.ForceChangeTeam(1, true); break }
						}
					}
					
					if (weaponscope.giant_organs != 6) EntFire("spawnbot_single_flag", "Enable", null, -1.0)
					else							   EntFire("spawnbot_mission_spy", "Enable", null, -1.0)
				}
			}
		}
		
		OnGameEvent_player_builtobject = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)
			local building = EntIndexToHScript(params.index)
			
			if (params.object == 2 && NetProps.GetPropInt(NetProps.GetPropEntityArray(player, "m_hMyWeapons", 2), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 142)
			{		
				NetProps.SetPropFloat(building, "m_flPercentageConstructed", 1.0)
				NetProps.SetPropInt(building, "m_iState", 1)
				NetProps.SetPropBool(building, "m_bBuilding", false)
				NetProps.SetPropInt(building, "m_iAmmoShells", 150)
				NetProps.SetPropInt(building, "m_iHealth", 100)
			}
		}
		
		OnGameEvent_player_say = function(params)
		{
			local player = GetPlayerFromUserID(params.userid)
		}
	}

	Booth_Think = function()
	{
		for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); )
		{
			if (NetProps.GetPropInt(ent, "m_nFlagStatus") != 2) continue // not active or carried
			if (IsInside(ent.GetOrigin(), self.GetOrigin() + Vector(-125, -100, -25), self.GetOrigin() + Vector(100, 75, 300)))
			{
				EntFireByHandle(ent, "ForceResetSilent", null, -1.0, null, null) // required for stubborn bombs that like to teleport out of bounds
				EntFireByHandle(ent, "RunScriptCode", "self.SetOrigin(Vector(-100, -2250, 485)); NetProps.SetPropInt(self, `m_nFlagStatus`, 2)", -1.0, null, null)
			}
		}
		
		for (local player; player = Entities.FindByClassname(player, "player"); )
		{
			if (player == null) continue
			if (player.IsFakeClient()) continue
			if (NetProps.GetPropInt(player, "m_lifeState") != 0) continue
			
			player.ValidateScriptScope()
			local scope = player.GetScriptScope()
			
			if (!("booth_page" in scope)) scope.booth_page <- 1
			
			if ((player.GetOrigin() - self.GetOrigin()).Length2D() <= 100.0 && NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == true)
			{
				player.AddCustomAttribute("no_attack", 1, 0.1)
				
				if (NetProps.GetPropInt(player, "m_afButtonPressed") & 1) scope.booth_page = (scope.booth_page == 4) ? 1 : scope.booth_page + 1
				
				player.SetScriptOverlayMaterial("skull_scamper_overlays/weapontweaks/tweaks_p" + scope.booth_page)
				
				player.AddHudHideFlags(4)
			}
			
			else
			{
				player.SetScriptOverlayMaterial(null)
				
				player.RemoveHudHideFlags(4)
				
				if (NetProps.GetPropInt(NetProps.GetPropEntityArray(player, "m_hMyWeapons", 1), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 356)
				{
					local kunai = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 1).GetScriptScope()
					if (!("tier" in kunai)) continue // always throws errors on first frame of life as a kunai spy
					player.SetScriptOverlayMaterial("skull_scamper_overlays/kunai/kunai_tier_" + kunai.tier)
				}
				
				scope.booth_page = 1
			}
		}
		
		return -1
	}
	
	blu_spawn_booth_keeper_voicelines_array =
	[
		"vo/heavy_award08.mp3", 		   "vo/heavy_fairyprincess12.mp3", 			 "vo/heavy_specialcompleted01.mp3", 	"vo/heavy_scram2012_falling01.mp3", "vo/heavy_scram2012_falling01.mp3", "vo/heavy_sf12_seeking03.mp3",
		"vo/heavy_mvm_loot_godlike03.mp3", "vo/compmode/cm_heavy_gamewon_6s_01.mp3", "vo/heavy_cartstaycloseoffense06.mp3", "vo/heavy_sandwichtaunt13.mp3", 	"vo/heavy_activatecharge03.mp3", 	"vo/heavy_sf12_seeking02.mp3"
	]
	
	SetUpInfoBooth = function()
	{
		if (Entities.FindByName(null, "infobooth") != null) return
		
		local blu_spawn_booth = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "infobooth"
			origin                  = Vector(-100, -2345, 480)
			model                   = "models/props_medieval/ticket_booth/ticket_booth.mdl"
			modelscale				= 0.8
		})
		
		local blu_spawn_booth_bbox = SpawnEntityFromTable("func_button", { origin = Vector(-100, -2335, 480) })

		local blu_spawn_booth_keeper = SpawnEntityFromTable("prop_dynamic",
		{
			targetname              = "infobooth_keeper"
			origin                  = Vector(-110, -2345, 480)
			model                   = "models/player/heavy.mdl"
			angles                  = QAngle(0, 90, 0)
			DefaultAnim             = "stand_melee"
			modelscale				= 0.8
		})

		local blu_spawn_booth_board = SpawnEntityFromTable("prop_dynamic",
		{
			origin                  = Vector(-107, -2315, 590)
			model                   = "models/props_gameplay/sign_wood_cap001.mdl"
			angles                  = QAngle(0, -90, 0)
			modelscale				= 0.4
			disableshadows			= 1
		})

		local blu_spawn_booth_text = SpawnEntityFromTable("point_worldtext",
		{
			textsize       = 12
			message        = "INFO\nBOOTH"
			font           = 1
			orientation    = 0
			textspacingx   = 1
			textspacingy   = 10
			spawnflags     = 0
			origin         = Vector(-85, -2310, 595)
			angles         = QAngle(0, -90, 0)
			rendermode     = 3
			targetname	   = "infobooth_text"
		})

		blu_spawn_booth_bbox.KeyValueFromInt("solid", 2)
		blu_spawn_booth_bbox.KeyValueFromString("mins", "-45 -25 -50")
		blu_spawn_booth_bbox.KeyValueFromString("maxs", "45 25 150")
		
		AddThinkToEnt(blu_spawn_booth, "Booth_Think")
		AddThinkToEnt(blu_spawn_booth_keeper, "KeeperVoicelines_Think")
	}

	KeeperVoicelines_Think = function()
	{
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == false) return RandomInt(15, 45)
		
		local cue = blu_spawn_booth_keeper_voicelines_array[RandomInt(0, blu_spawn_booth_keeper_voicelines_array.len() - 1)]
		for (local player; player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 500.0); )
		{
			if (player.GetTeam() != 2) continue
			PrecacheSound(cue)
			EmitSoundEx({ sound_name = cue, filter = 5, entity = self, volume = 1, pitch = 150, soundlevel = 150, flags = 0, channel = 6 })
			break
		}
		
		return RandomInt(15, 45)
	}
	
	RemoveCrumpkins_Think = function() { for (local ent; ent = Entities.FindByModel(ent, "models/props_halloween/pumpkin_loot.mdl"); ) ent.Kill() }
	
	CleanUpZombies_Think = function()
	{
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves")) return -1
		
		zombies_active = 0
		
		for (local player; player = Entities.FindByClassname(player, "player"); )
		{
			if (player == null) continue
			if (player.IsFakeClient() && player.GetTeam() == 2) zombies_active = zombies_active + 1
		}
		
		// skipping slot 0 since it's always occupied by the zombies
		
		for (local i = 1; i <= 11; i++)
		{
			local flags = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags", i)
			local amounts = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts", i)
			
			if ((flags == 1 || flags == 9) && amounts != 0) return -1
		}
		
		for (local i = 1; i <= 11; i++)
		{
			local flags = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2", i)
			local amounts = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2", i)
			
			if ((flags == 1 || flags == 9) && amounts != 0) return -1
		}
		
		// if we make it this far, kill all zombies
		
		for (local player; player = Entities.FindByClassname(player, "player"); )
		{
			if (player == null) continue
			if (!player.IsFakeClient()) continue
			if (player.HasBotTag("zombie")) { player.TakeDamage(10000.0, 64, null), player.ForceChangeTeam(1, true) }
		}
	}
	
	fire = Entities.CreateByClassname("tf_weapon_flamethrower")
}

try { IncludeScript("pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

::SetUpInfoBooth()

EntFire("spawnbot_single_flag", "Disable")
EntFire("spawnbot_mission_spy", "Disable")

Entities.FindByName(null, "pumpkinmagic").KeyValueFromFloat("respawn_time", 7200.0)

for (local ent; ent = Entities.FindByClassname(ent, "tf_pumpkin_bomb"); ) ent.Kill()

fire.AddAttribute("Set DamageType Ignite", 1, -1.0)
Entities.DispatchSpawn(fire)

for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++) // run this for when the first player connects to the server and the callback hasn't loaded yet
{
	local player = PlayerInstanceFromIndex(i)
	
	if (player == null) continue
	if (player.IsFakeClient())
	{
		if (player.GetTeam() != 1) player.ForceChangeTeam(1, true)
		
		AddThinkToEnt(player, null)
		NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
		player.TerminateScriptScope()
		
		continue
	}
	
	else if (!("first_spawn" in getroottable()))
	{
		player.ForceRespawn()
		PEA["first_spawn"] <- true; getroottable()["first_spawn"] <- PEA["first_spawn"]
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
	}
}

AssignThinkToThinksTable("RemoveCrumpkins_Think")
AssignThinkToThinksTable("CleanUpZombies_Think")

for (local ent; ent = Entities.FindByClassname(ent, "item_teamflag"); )
{
	EntFireByHandle(ent, "ForceReset", null, -1.0, null, null)
	ent.SetModelSimple("models/props_td/atom_bomb.mdl")
}

if (NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveCount") == 4)
{	
	SpawnEntityFromTable("prop_dynamic",
	{
		targetname     = "bombpath_arrows_flank"
		origin         = Vector(532, 1827, 642)
		model 		   = "models/props_mvm/robot_hologram.mdl"
		angles 		   = QAngle(0, 225, 0)
		rendercolor    = "140 0 140"
		disableshadows = 1
	})
	
	SpawnEntityFromTable("prop_dynamic",
	{
		origin 		   = Vector(532, 1827, 642)
		model  		   = "models/props_mvm/hologram_projector.mdl"
		angles 		   = QAngle(0, 225, 0)
		disableshadows = 1
	})
	
	SpawnEntityFromTable("prop_dynamic",
	{
		targetname     = "bombpath_arrows_flank"
		origin         = Vector(370, 1435, 642)
		model 		   = "models/props_mvm/robot_hologram.mdl"
		angles 		   = QAngle(0, 270, 0)
		rendercolor    = "140 0 140"
		disableshadows = 1
	})
	
	SpawnEntityFromTable("prop_dynamic",
	{
		origin  	   = Vector(370, 1435, 642)
		model  		   = "models/props_mvm/hologram_projector.mdl"
		angles 		   = QAngle(0, 270, 0)
		disableshadows = 1
	})
	
	SpawnEntityFromTable("prop_dynamic",
	{
		targetname     = "bombpath_arrows_flank"
		origin         = Vector(370, 831, 542)
		model 	   	   = "models/props_mvm/robot_hologram.mdl"
		angles 	       = QAngle(0, 225, 0)
		rendercolor    = "140 0 140"
		disableshadows = 1
	})
	
	SpawnEntityFromTable("prop_dynamic",
	{
		origin 		   = Vector(370, 831, 542)
		model 		   = "models/props_mvm/hologram_projector.mdl"
		angles 		   = QAngle(0, 225, 0)
		disableshadows = 1
	})
	
	for (local i = 1; i <= 3; i++) SpawnEntityFromTable("func_nav_avoid", { targetname = "bomb_avoid_upper_flank", origin = Vector(-300, 1350, 700), tags = "bomb_carrier" })
	
	for (local ent; ent = Entities.FindByName(ent, "bomb_avoid_upper_flank"); )
	{
		ent.KeyValueFromInt("solid", 2)
		ent.KeyValueFromString("mins", "-200 -100 -100")
		ent.KeyValueFromString("maxs", "200 100 100")
	}
	
	EntityOutputs.AddOutput(Entities.FindByName(null, "wave_start_relay"), "OnTrigger", "bombpath_arrows_flank", "Disable", null, -1.0, -1.0)
}