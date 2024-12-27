::PEA_GLOBAL <-
{
	debug = ("debug" in PEA) ? PEA.debug : false
	
	sigmod = Convars.GetInt("sig_color_console") != null ? true : false
	
	countdown_skipped = false
	
	strip_romevision_items = false
	
	thinkertick = 1
	
	mission = NetProps.GetPropString(Entities.FindByClassname(null, "tf_objective_resource"), "m_iszMvMPopfileName")
	
	Wave = NetProps.GetPropInt(Entities.FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")
	
	moneydrop = Vector()
	
	customfuncs =
	[
		["CBaseCombatWeapon", ["GetOwner"]],
		["CBaseEntity", ["Enable", "Disable"]],
		["CTFBot", ["IsGrounded", "GetWeapon", "GetWearable", "GetWearableItem", "GetAllWearables", "RemoveWearable", "Zombify"]],
		["CTFPlayer", ["IsGrounded", "GetWeapon", "GetWearable", "GetWearableItem", "GetAllWearables", "RemoveWearable"]]
	]
	
	zombieitems = [5617, 5625, 5618, 5620, 5622, 5619, 5624, 5623, 5621]
	
	playerlog_limit = 16250
	
	tanks_in_wave = 0
	blimps_in_wave = 0
	
	class_integers = ["", "scout", "sniper", "soldier", "demo", "medic", "heavy", "pyro", "spy", "engineer", "civilian"]
	
	ignite_player = Entities.CreateByClassname("tf_weapon_flamethrower")

	GLOBAL_CALLBACKS =
	{
		OnGameEvent_recalculate_holidays = function(params) // do cleanup after mission switch
		{
			foreach (player in GetAllPlayers(false, false, false))
			{
				player.ValidateScriptScope()
				
				if (player.IsFakeClient())
				{
					if (!sigmod)
					{
						NetProps.SetPropBool(player, "m_bForcedSkin", false)
						NetProps.SetPropInt(player, "m_nForcedSkin", 0)
						NetProps.SetPropInt(player, "m_iPlayerSkinOverride", 0)
					}
					
					local scope = player.GetScriptScope()

					NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
					
					for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
					{ 
						if ("custom_wearable" in child.GetScriptScope()) { EntFireByHandle(child, "Kill", null, -1.0, null, null); continue }
						
						child.DisableDraw()
						
						continue
					}
					
					foreach (thing in player.GetScriptScope())
					{
						try { thing.GetClassname() }
						catch (e) { continue }
						
						if (!thing.IsPlayer()) thing.Kill()
					}
				
					player.TerminateScriptScope()
				}
			}
			
			if (GetRoundState() == 3 && NetProps.GetPropString(objective_resource_entity, "m_iszMvMPopfileName") != mission)
			{
				if ("MapCleanup" in PEA) ::MapCleanup()
				
				for (local ent; ent = Entities.FindByClassname(ent, "entity_sign"); ) ent.Kill()
				
				foreach (entgroup in customfuncs) { foreach (func in entgroup[1]) getroottable()[entgroup[0]][func] <- function() {} }

				foreach (thing, var in PEA) if (thing in getroottable()) delete getroottable()[thing]
				
				if ("PEA_ONETIME" in getroottable()) { foreach (thing, var in PEA_ONETIME) if (thing in getroottable()) delete getroottable()[thing] }
				
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
				delete ::PEA_GLOBAL_ONETIME
				
				if ("PEA_ONETIME" in getroottable()) delete ::PEA_ONETIME
				
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
		
		OnGameEvent_player_spawn = function(params)
		{
			local bot = GetPlayerFromUserID(params.userid)
			
			if (!bot.IsFakeClient()) return
			
			EntFireByHandle(bot, "CallScriptFunction", "GlobalBotTagCheck", -1.0, null, null)
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

				for (local child = dead_player.FirstMoveChild(); child != null; child = child.NextMovePeer())
				{
					if (child.GetClassname() == "tf_wearable" && child.GetScriptScope() != null) EntFireByHandle(child, "Kill", null, 0.1, null, null) // needs extra delay to allow wearables to remain on ragdolls
				}
			
				foreach (thing in dead_player.GetScriptScope())
				{
					try { thing.GetClassname() }
					catch (e) { continue }

					if (!thing.IsPlayer()) thing.Kill()
				}

				if (!projectiles_leftbehind) EntFireByHandle(dead_player, "RunScriptCode", "self.ForceChangeTeam(1, true)", 0.1, null, null)
				
				NetProps.SetPropString(dead_player, "m_iszScriptThinkFunction", "")
				dead_player.TerminateScriptScope()
			}
		}
		
		OnGameEvent_mvm_begin_wave = function(params)
		{
			if (firstload) NetProps.SetPropFloat(gamerules_entity, "m_flRestartRoundTime", Time())
			
			HideIcon("noicon")
			
			if (WaveHasIcon("blimp2_lite")) UnhideIcon("blimp2_lite", 8)
		}
		
		OnGameEvent_mvm_wave_complete = function(params) { wavewon = true }
	}

	EnableSpawn = function(...) { foreach (name in vargv) Entities.FindByName(null, "spawnbot_" + name).Enable() }
	DisableSpawn = function(...) { foreach (name in vargv) Entities.FindByName(null, "spawnbot_" + name).Disable() }

	ShovePlayer = function(player, radius)
	{
		local vradius = Vector(radius, radius, radius)
		
		local selfmins = self.GetBoundingMins() + self.GetOrigin() - vradius
		local selfmaxs = self.GetBoundingMaxs() + self.GetOrigin() + vradius

		local playermins = player.GetBoundingMins() + player.GetOrigin()
		local playermaxs = player.GetBoundingMaxs() + player.GetOrigin()

		if (playermins.x > selfmaxs.x || playermaxs.x < selfmins.x || playermins.y > selfmaxs.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermaxs.y < selfmins.y || playermins.z > selfmaxs.z || playermaxs.z < selfmins.z) return

		local pushforce = player.GetOrigin() - self.GetOrigin()
		pushforce.Norm()
		pushforce.z = 1.0
		pushforce = pushforce * 270

		if (player.IsGrounded()) player.SetOrigin(player.GetOrigin() + Vector(0, 0, 24))
		
		player.RemoveFlag(1)
		player.AddCond(115)

		player.ApplyAbsVelocityImpulse(pushforce)
	}
	
	PrecacheArray = function(array)
	{
		foreach (thing in array)
		{
			if (thing.find(".mdl") != null) PrecacheModel(thing)
			else PrecacheSound(thing)
		}
	}
	
	VectorAngles = function(forward)
	{
		local yaw, pitch;
		
		if (forward.y == 0.0 && forward.x == 0.0)
		{
			yaw = 0.0
			
			if (forward.z > 0.0) pitch = 270.0
			else				 pitch = 90.0
		}
		
		else
		{
			yaw = (atan2(forward.y, forward.x) * 180.0 / Constants.Math.Pi)
			if (yaw < 0.0) yaw += 360.0
	
			pitch = (atan2(-forward.z, forward.Length2D()) * 180.0 / Constants.Math.Pi)
			if (pitch < 0.0) pitch += 360.0
		}

		return QAngle(pitch, yaw, 0.0);
	}
	
	GetAllPlayers = function(team = false, radius = false, alive = true)
	{
		local resultarray = []
		
		if (!(!radius))
		{
			for (local player; player = Entities.FindByClassnameWithin(player, "player", radius[0], radius[1]); )
			{
				if (!(!team)) { if (player.GetTeam() != team) continue }
				if (alive) { if (!player.IsAlive()) continue }
				
				resultarray.append(player)
			}
		}
		
		else
		{
			local maxclients = MaxClients().tointeger()
			
			for (local i = 1; i <= maxclients; i++)
			{
				local player = PlayerInstanceFromIndex(i)
				
				if (player == null) continue
				
				if (!(!team)) { if (player.GetTeam() != team) continue }
				if (alive) { if (!player.IsAlive()) continue }
				
				resultarray.append(player)
			}
		}

		return resultarray
	}

	SpawnNavBrush = function(name, pos, xyz1, xyz2, tagname = false)
	{
		if (!tagname) tagname = name.slice(4)
		
		local navbrush = SpawnEntityFromTable("func_nav_avoid", { targetname = name, origin = pos, tags = tagname })

		navbrush.KeyValueFromInt("solid", 2)
		navbrush.KeyValueFromString("mins", xyz1)
		navbrush.KeyValueFromString("maxs", xyz2)
		
		local navbrush2 = SpawnEntityFromTable("func_nav_avoid", { targetname = name, origin = pos, tags = tagname }) // do it twice just to make sure

		navbrush2.KeyValueFromInt("solid", 2)
		navbrush2.KeyValueFromString("mins", xyz1)
		navbrush2.KeyValueFromString("maxs", xyz2)
	}
	
	SnapVectorToGround = function(pos, offset = false)
	{
		local tracetable =
		{
			start = pos
			end = pos - Vector(0, 0, 5000)
			mask = -1
		}
		
		TraceLineEx(tracetable)
		
		if (!offset) return tracetable.pos
		else		 return (tracetable.pos + Vector(0, 0, offset))
	}
	
	CreatePathHologram = function(where, angle)
	{
		local projector = SpawnEntityFromTable("prop_dynamic",
		{
			origin             = SnapVectorToGround(where)
			model 			   = "models/props_mvm/hologram_projector.mdl"
			shadowcastdist	   = 0
		})
		
		local hologram = SpawnEntityFromTable("prop_dynamic",
		{
			origin             = SnapVectorToGround(where, 5.0)
			angles			   = angle
			model 			   = "models/props_mvm/robot_hologram.mdl"
			rendercolor 	   = "138 187 247"
			disableshadows     = 1
		})
	}
	
	GiveNavAvoidToNavArea = function(name, area, tag = "", height = 500.0)
	{
		local mins = (0 - (area.GetSizeX() / 2.0)).tostring() + " " + (0 - (area.GetSizeY() / 2.0)).tostring() + " " + (0 - (height / 2.0)).tostring()
		local maxs = (area.GetSizeX() / 2.0).tostring() + " " + (area.GetSizeY() / 2.0).tostring() + " " + (height / 2.0).tostring()
		
		local avoid = SpawnEntityFromTable("func_nav_avoid",
		{
			origin           = area.GetCenter()
			tags             = tag
		})
		
		avoid.KeyValueFromInt("solid", 2)
		avoid.KeyValueFromString("mins", mins)
		avoid.KeyValueFromString("maxs", maxs)
	}
	
	ConnectNavAreas = function(navarray) { foreach (pair in navarray) NavMesh.GetNavAreaByID(pair[0]).ConnectTo(NavMesh.GetNavAreaByID(pair[1]), NavMesh.GetNavAreaByID(pair[0]).ComputeDirection(NavMesh.GetNavAreaByID(pair[1]).GetCenter())) }
	
	DisconnectNavAreas = function(navarray) { foreach (pair in navarray) NavMesh.GetNavAreaByID(pair[0]).Disconnect(NavMesh.GetNavAreaByID(pair[1])) }
	
	UnblockNavAreas = function(navarray) { foreach (nav in navarray) NavMesh.GetNavAreaByID(nav).UnblockArea() }
	
	EmitGlobalSound = function(sound)
	{
		SendGlobalGameEvent("teamplay_broadcast_audio", 
		{
			team             = -1,
			sound            = sound
			additional_flags = 0
			player           = -1
		})
	}
	
	StopGlobalSound = function(sound)
	{
		SendGlobalGameEvent("teamplay_broadcast_audio", 
		{
			team             = -1,
			sound            = sound,
			additional_flags = 4,
			player           = -1
		})	
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

	AttachGlow = function(color)
	{
		local scope = self.GetScriptScope()
		
		self.KeyValueFromString("targetname", "glow_target")

		scope.glow <- SpawnEntityFromTable("tf_glow",
		{
			origin				  = self.EyePosition()
			target           	  = "glow_target"
			GlowColor             = color
		})
		
		self.KeyValueFromString("targetname", "")
		
		glow.AcceptInput("SetParent", "!activator", self, null) // parenting a tf_glow fixes issues where it doesn't render if it's too far from you
	}
	
	Clamp = function(val, minVal, maxVal)
	{
		if (maxVal < minVal)   return maxVal
		else if (val < minVal) return minVal
		else if (val > maxVal) return maxVal
		else 				   return val
	}
	
	RemapValClamped = function(val, A, B, C, D)
	{
		if (A == B) return ((val >= B) ? D : C)
	
		local cVal = (val - A) / (B - A)
		
		cVal = Clamp(cVal, 0.0, 1.0)

		return (C + (D - C) * cVal)
	}
	
	SetDestroyCallback = function(entity, callback) // credit goes to ficool2 for function code
	{
		entity.ValidateScriptScope()
		local scope = entity.GetScriptScope()
		scope.setdelegate
		(
			{}.setdelegate
			(
				{
					parent   = scope.getdelegate()
					id       = entity.GetScriptId()
					index    = entity.entindex()
					callback = callback
					_get = function(keytofetch) { return parent[keytofetch] }
					_delslot = function(keytodelete)
					{
						if (keytodelete == id)
						{
							entity = EntIndexToHScript(index)
							local scope = entity.GetScriptScope()
							scope.self <- entity
							callback.pcall(scope)
						}
						
						delete parent[keytodelete]
					}
				}
			)
		)
	}
	
	CameraFix = function() // credit goes to ficool2 for function code
	{
		if (!("SetInputHook" in getroottable()))
		{
			::_PostInputScope <- null;
			::_PostInputFunc  <- null;

			::SetInputHook <- function(entity, input, pre_func, post_func)
			{
				entity.ValidateScriptScope();
				local scope = entity.GetScriptScope();
				if (post_func)
				{
					local wrapper_func = function() 
					{ 
						_PostInputScope = scope; 
						_PostInputFunc  = post_func;
						if (pre_func)
							return pre_func.call(scope);
						return true;
					};
					
					scope["Input" + input]           <- wrapper_func;
					scope["Input" + input.tolower()] <- wrapper_func;
				}
				else if (pre_func)
				{
					scope["Input" + input]           <- pre_func;
					scope["Input" + input.tolower()] <- pre_func;
				}
			}
			
			getroottable().setdelegate(
			{
				_delslot = function(k)
				{
					if (_PostInputScope && k == "activator" && "activator" in this)
					{
						_PostInputFunc.call(_PostInputScope);
						_PostInputFunc = null;
					}
					
					rawdelete(k);
				}
			});		
		}

		if (!("CameraFixer" in getroottable()))
		{
			::_CameraFixLifestate <- 0;

			::CameraFixPre <- function()
			{
				if (activator)
				{
					_CameraFixLifestate = NetProps.GetPropInt(activator, "m_lifeState");
					NetProps.SetPropInt(activator, "m_lifeState", 0);
					NetProps.SetPropEntity(self, "m_hPlayer", activator);
				}
				
				return true;
			}

			::CameraFixPost <- function()
			{
				if (activator)
				{
					NetProps.SetPropInt(activator, "m_lifeState", _CameraFixLifestate);
					NetProps.SetPropInt(activator, "m_takedamage", 2);
				}
			}
			
			::CameraDisableAll <- function()
			{
				for (local player; player = Entities.FindByClassname(player, "player");)
					EntFireByHandle(CameraFixer, "Disable", "", -1, player, player);
				EntFireByHandle(CameraFixer, "Kill", "", 1, null, null);
			}
			
			::CameraFixer <- Entities.CreateByClassname("point_viewcontrol");
			::CameraFixer.KeyValueFromString("classname", "camera_fixer");
			::CameraFixer.AddEFlags(1);
			SetInputHook(CameraFixer, "Disable", CameraFixPre, CameraFixPost);	

			SpawnEntityFromTable("logic_eventlistener", 
			{ 
				classname	 = "move_rope",
				eventname    = "teamplay_round_start",
				IsEnabled    = true,
				OnEventFired = "worldspawn,CallScriptFunction,CameraDisableAll,-1,-1",
			});

			SpawnEntityFromTable("logic_eventlistener", 
			{ 
				classname	 = "move_rope",
				eventname    = "recalculate_holidays",
				IsEnabled    = true,
				OnEventFired = "worldspawn,RunScriptCode,if (GetRoundState() == 8) CameraDisableAll(),0.1,-1",
			});
		}

		function Precache()
		{
			SetInputHook(self, "Disable", CameraFixPre, CameraFixPost);
		}
	}
	
	IsInside = function(vector, min, max) { return vector.x >= min.x && vector.x <= max.x && vector.y >= min.y && vector.y <= max.y && vector.z >= min.z && vector.z <= max.z }
	
	FreeUpRobotSlots = function(amount)
	{
		// collect all bots first to determine who deserves death
		
		local slotstoclear
		local botarray = []
		local deathpriority = []
		
		for (local i = 1; i <= MaxClients().tointeger(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			
			if (player == null) continue
			if (player.GetTeam() != 3) continue
			if (!player.IsAlive()) continue
			
			botarray.append(player)
			
			ClientPrint(null,3,"" + NetProps.GetPropString(player, "m_szNetname") + " " + player.GetPlayerClass())
		}

		slotstoclear = (botarray.len() + amount) - 22
		
		if (slotstoclear < 0) return // no need to free up slots when there is still room
		
		botarray = botarray.filter(function(index, bot) { return (!bot.IsMiniBoss() && bot != null) })

		ClientPrint(null,3,"origslotstoclear: " + slotstoclear)

		foreach (bot in botarray) { if (bot.IsOnAnyMission()) deathpriority.append(bot) } // prioritize mission support
		foreach (bot in botarray) { if (!bot.IsOnAnyMission()) deathpriority.append(bot) }

		for (local i = slotstoclear; i > 0; i--)
		{
			ClientPrint(null,3,"slotstoclear: " + i)
			
			if (i > 0) // destroy a random robot to make room for another
			{
				deathpriority[0].Teleport(true, Vector(0, 0, -3000), false, QAngle(), false, Vector())
				deathpriority[0].TakeDamage(10000.0, 64, null)
				deathpriority[0].ForceChangeTeam(1, true)
				
				ClientPrint(null,3,"destroyed: " + NetProps.GetPropString(deathpriority[0], "m_szNetname") + " to make room")
				
				deathpriority.remove(0)
			}
		}
	}
	
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
		if (!sigmod)
		{
			if (NetProps.GetPropBool(self, "m_bForcedSkin"))
			{
				NetProps.SetPropBool(self, "m_bForcedSkin", false)
				NetProps.SetPropInt(self, "m_nForcedSkin", 0)
				NetProps.SetPropInt(self, "m_iPlayerSkinOverride", 0)
			}
		}
		
		if (strip_romevision_items)
		{
			for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
			{
				if (child.GetClassname() == "tf_wearable" && child.GetModelName().find("tw_") != null) EntFireByHandle(child, "RunScriptCode", "self.DisableDraw()", -1.0, null, null)
			}
		} 
		
		if (self.HasBotTag("disband_squad")) self.DisbandCurrentSquad()
		if (self.HasBotTag("shuffle")) BotShuffler()
		
		if (self.HasBotTag("blimp")) AddThinkToEnt(self, "BlimpSetup_Think")
		
		if (self.HasBotTag("money"))
		{
			self.Teleport(true, moneydrop, false, QAngle(), false, Vector())
			self.TakeDamage(10000.0, 64, null)
			self.ForceChangeTeam(1, true)
		}
	}
	
	BombCarrierSpawnSpeedUp_Think = function()
	{
		if (thinkertick % 7 != 0) return
		
		if (NetProps.GetPropBool(objective_resource_entity, "m_bMannVsMachineBetweenWaves") == false)
		{
			for (local i = 1; i <= MaxClients().tointeger(); i++)
			{
				local player = PlayerInstanceFromIndex(i)
				if (player == null) continue
				if (player.GetTeam() != 3) continue
				if (player.HasItem())
				{
					if (player.InCond(51) && !player.HasBotAttribute(32768)) player.AddCustomAttribute("CARD: move speed bonus", 10, -1)
					else player.RemoveCustomAttribute("CARD: move speed bonus")
					
					if (GetMapName() == "mvm_powerplant_rc1")
					{
						if (!bomb_placement_adjusted)
						{
							if (current_bombpath == "right") player.Teleport(true, Vector(-1056, 3312, 96), false, QAngle(0, 0, 0), false, Vector(0, 0, 0)) // bots will disobey bomb path if they don't spawn from spawnbot_right
							
							bomb_placement_adjusted = true
						}
					}
				}
			}
		}
	}
	
	BotShuffler = function()
	{
		if (self.HasBotTag("shuffle"))
		{
			self.RemoveBotTag("shuffle")
			
			local maxchance = 0
			
			local order_array = []
			local name_array = []
			
			local wavespawn
			
			foreach (tag, entries in shuffle_wavespawn_table)
			{
				if (!self.HasBotTag(tag)) continue
				
				for (local i = 0; i <= entries.amounts.len() - 1; i++)
				{
					maxchance = maxchance + entries.amounts[i]
					order_array.append(entries.amounts[i])
				}
				
				for (local i = 0; i <= entries.names.len() - 1; i++) name_array.append(entries.names[i])
				
				wavespawn = tag
			}
			
			for (local i = 1; i <= order_array.len() - 1; i++) order_array[i] = order_array[i - 1] + order_array[i]

			local choice = RandomInt(1, maxchance)
			
			for (local i = 0; i <= order_array.len() - 1; i++)
			{
				if (choice <= order_array[i])
				{
					BotTransformer(name_array[i])
					
					foreach (tag, entries in shuffle_wavespawn_table)
					{
						if (tag != wavespawn) continue
						entries.amounts[i]--
					}

					break
				}
			}
		}
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
		
		// for (local blimp; blimp = Entities.FindByName(blimp, "blimpboss"); )
		// {
			// if (blimp.GetScriptScope() != null) continue
			// else SetUpBlimp(blimp)
		// }
	}
	
	CleanUpTank = function()
	{
		tanks_in_wave = tanks_in_wave - 1
		for (local cash; cash = Entities.FindByClassname(cash, "item_currencypack_custom"); ) AddThinkToEnt(cash, "ImprovedCashCollection_Think")
	}

	WaveHasIcon = function(name)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name) return true
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name) return true
		}
		
		return false
	}
	
	GetIconType = function(name)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name) return NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags.", i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name) return NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2.", i)
		}
	}
	
	GetIconCount = function(name)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name) return NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts.", i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name) return NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2.", i)
		}
	}
	
	GetTotalEnemyCount = function() { return NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount") }
	SetTotalEnemyCount = function(amount) { NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount", amount) }
	
	HideIcon = function(name) // IMPORTANT: adding the dot to netprop names here will fix issues where the third element in the array is inaccessible!
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name)
			{
				if (GetIconType(name) == 1) SetTotalEnemyCount(GetTotalEnemyCount() - GetIconCount(name))
				
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags.", 0, i)
			}
		
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name)
			{
				if (GetIconType(name) == 1) SetTotalEnemyCount(GetTotalEnemyCount() - GetIconCount(name))
				
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2.", 0, i)
			}
		}
	}
	
	UnhideIcon = function(name, flag)
	{
		for (local i = 0; i <= 11; i++)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags.", flag, i)
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name) NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2.", flag, i)
		}
	}
	
	AddIcon = function(name, flag, amount)
	{
		for (local i = 11; i >= 0; i--)
		{
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == "")
			{
				NetProps.SetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", name, i)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags2.", flag, i)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2.", amount, i)
				break
			}
			
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == "")
			{
				NetProps.SetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", name, i)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassFlags.", flag, i)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts.", amount, i)
				break
			}
		}
	}
	
	AddToIcon = function (name, amount)
	{
		for (local i = 0; i <= 11; i++)
		{
			local count = NetProps.GetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts.", i)
			
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames.", i) == name)
			{
				if (GetIconType(name) == 1) SetTotalEnemyCount(GetTotalEnemyCount() + amount)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts.", count + amount, i)
			}
			
			if (NetProps.GetPropStringArray(objective_resource_entity, "m_iszMannVsMachineWaveClassNames2.", i) == name)
			{
				if (GetIconType(name) == 1) SetTotalEnemyCount(GetTotalEnemyCount() + amount)
				NetProps.SetPropIntArray(objective_resource_entity, "m_nMannVsMachineWaveClassCounts2.", count + amount, i)
			}
		}
		
		// local totalcount = NetProps.GetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount")
		// NetProps.SetPropInt(objective_resource_entity, "m_nMannVsMachineWaveEnemyCount", totalcount + amount)
	}

	HideErrors = function()
	{
		ClientPrint(null,3,"\x07FF3F3FThe errors about missing spawn entities are harmless, please ignore them.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
		
		if ("MissionInitMessage" in PEA) MissionInitMessage()
		
		firstload = false
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
	
	BlimpSetup_Think = function()
	{
		local scope = self.GetScriptScope()
		
		if (!("train" in scope))
		{
			self.SetMoveType(0, 0)
			
			scope.train <- SpawnEntityFromTable("func_tracktrain",
			{
				targetname              = "blimp_train"
				target                  = "blimp_path1"
				startspeed              = 75
				speed                   = 75
				origin                  = Entities.FindByName(null, "blimp_path1").GetOrigin()
				orientationtype         = 1
				spawnflags              = 136
				volume					= 10
				model					= "*2"
				rendermode				= 1
				renderamt				= 0
				solid					= 0
			})
			
			scope.blimp <- SpawnEntityFromTable("base_boss",
			{
				targetname	  = "blimpboss"
				origin		  = train.GetOrigin()
				model         = "models/bots/boss_bot/boss_blimp.mdl"
				skin		  = 1
				teamnum		  = 3
				solid		  = 6
				health		  = 50000 + self.GetHealth()
			})

			blimp.ResetSequence(2)
			if (sigmod) blimp.SetPlaybackRate(0.015)
			
			NetProps.SetPropInt(blimp, "m_bloodColor", -1.0)
			
			train.ValidateScriptScope()
			train.GetScriptScope().parented_blimp <- blimp
			
			blimp.ValidateScriptScope()
			blimp.GetScriptScope().pathtrain <- train
			
			AttachGlow.call(blimp.GetScriptScope(), "125 168 196 255")
			
			EmitGlobalSound("MVM.TankStart")
			EmitGlobalSound("Announcer.MVM_Tank_Alert_Spawn")
			
			blimp.SetModelScale(("blimp_scale" in PEA) ? blimp_scale : 1, -1)
			
			AddThinkToEnt(blimp, "Blimp_Think")
			
			scope.blimpcallbacks <-
			{
				OnGameEvent_player_death = function(params)
				{
					local dead_player = GetPlayerFromUserID(params.userid)

					if (dead_player == self)
					{
						moneydrop = blimp.GetOrigin()
						
						DispatchParticleEffect("explosionTrail_seeds_mvm", blimp.GetOrigin(), Vector(0, 90, 0))
						DispatchParticleEffect("fluidSmokeExpl_ring_mvm", blimp.GetOrigin(), Vector(0, 90, 0))
						
						ScreenShake(blimp.GetOrigin(), 25.0, 5.0, 5.0, 1000.0, 0, true)

						EmitGlobalSound("MVM.TankExplodes")
						EmitGlobalSound("MVM.TankEnd")
						EmitGlobalSound("Announcer.MVM_General_Destruction")
						
						AddToIcon("blimp2_lite", -1)

						delete blimpcallbacks
					}
				}
			}
			
			foreach (name, callback in blimpcallbacks) blimpcallbacks[name] = callback.bindenv(scope)
			
			__CollectGameEventCallbacks(blimpcallbacks)
		}
		
		self.SetHealth(self.GetMaxHealth() - (blimp.GetMaxHealth() - blimp.GetHealth()))

		if (self.GetHealth() <= 0)
		{
			self.Teleport(true, blimp.GetOrigin(), false, QAngle(), false, Vector())
			self.TakeDamage(10000.0, 64, null)
		}
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
		
		if (!("DeployBomb" in scope))
		{
			PrecacheSound("npc/combine_gunship/ping_search.wav")
			
			scope.nextpingtime <- Time() + 5.0
			scope.deployed <- false
			
			scope.DeployBomb <- function()
			{	
				self.ResetSequence(1)
				if (sigmod) self.SetPlaybackRate(0.013)

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
		
		self.StudioFrameAdvance()
		self.DispatchAnimEvents(self)
		
		if (deployed) return -1
		
		if (Time() > nextpingtime)
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
			
			nextpingtime = Time() + 5.0
		}
		
		if (self.GetCycle() == 1.0)
		{
			if (self.GetSequence() == 2) self.SetCycle(0)
			else
			{
				deployed = true
				
				switch (GetMapName())
				{
					case "mvm_hanami_rc1":
					{
						EntFire("win_bots", "RoundWin")
						EntFire("hatch_destroy_relay", "Trigger")
						break
					}
					
					case "mvm_null_b9c":
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
				foreach (player in GetAllPlayers(3)) player.TakeDamageCustom(player, player, null, Vector(), Vector(), 9999999.9, 1024, 0)
				
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
		}
	}
}

CBaseEntity.Enable <- function() { this.AcceptInput("Enable", null, null, null) }
CBaseEntity.Disable <- function() { this.AcceptInput("Disable", null, null, null) }

CTFPlayer.IsGrounded <- function() { return NetProps.GetPropEntity(this, "m_hGroundEntity") != null }
CTFBot.IsGrounded <- function() { return NetProps.GetPropEntity(this, "m_hGroundEntity") != null }

CTFBot.Zombify <- function()
{
	if (!strip_romevision_items) // we want to remove romevision from zombies even if we normally accept it
	{
		for (local child = this.FirstMoveChild(); child != null; child = child.NextMovePeer())
		{
			if (child.GetClassname() == "tf_wearable" && child.GetModelName().find("tw_") != null) EntFireByHandle(child, "Kill", null, -1.0, null, null)
		}
	}

	NetProps.SetPropBool(this, "m_bForcedSkin", true)
	NetProps.SetPropInt(this, "m_nForcedSkin", 5)
	NetProps.SetPropInt(this, "m_iPlayerSkinOverride", 1)
	this.GetWearableItem(zombieitems[this.GetPlayerClass() - 1])
	// this.GetWearable(format("models/player/items/%s/%s_zombie.mdl", class_integers[this.GetPlayerClass()], class_integers[this.GetPlayerClass()]))
	this.SetCustomModelWithClassAnimations(format("models/player/%s.mdl", class_integers[this.GetPlayerClass()]))
	
	if (sigmod)
	{
		this.AddCustomAttribute("use human voice", 1, -1.0)
		this.AddCustomAttribute("voice pitch scale", 0.65, -1.0)
	}
	
	else this.AddCustomAttribute("voice pitch scale", 0, -1.0)
}

CTFPlayer.GetWeapon <- function(className, itemID)
{
	local weapon = Entities.CreateByClassname(className)

	NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)
	NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
	
	weapon.SetTeam(this.GetTeam())
	
	NetProps.SetPropInt(weapon, "m_iViewModelIndex", ::PrecacheModel("models/props_mvm/mann_hatch.mdl"))
	
	Entities.DispatchSpawn(weapon)

	for (local i = 0; i < 8; i++)
	{
		local heldWeapon = NetProps.GetPropEntityArray(this, "m_hMyWeapons", i)
		
		if (heldWeapon == null) continue
		if (heldWeapon.GetSlot() != weapon.GetSlot()) continue
		
		heldWeapon.Destroy()
		
		NetProps.SetPropEntityArray(this, "m_hMyWeapons", null, i)
		break
	}
	
	this.Weapon_Equip(weapon)   
	this.Weapon_Switch(weapon)

	return weapon
}

CTFBot.GetWeapon <- CTFPlayer.GetWeapon

CTFPlayer.GetWearable <- function(model, bonemerge = true, attachment = null, offsets = null)
{	
	for (local child = this.FirstMoveChild(); child != null; child = child.NextMovePeer())
	{ 
		if ("custom_wearable" in child.GetScriptScope())
		{
			if (typeof(model) == "string") { if (NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 3) == GetModelIndex(model)) return false }
			if (typeof(model) == "integer") { if (NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 3) == model) return false }
		}			
	}
	
	local modelIndex
	
	if (typeof(model) == "string")
	{
		modelIndex = GetModelIndex(model)
		if (modelIndex == -1) modelIndex = ::PrecacheModel(model)
	}

	if (typeof(model) == "integer") modelIndex = model

	local wearable = Entities.CreateByClassname("tf_wearable")
	
	NetProps.SetPropInt(wearable, "m_nModelIndex", modelIndex)
	
	wearable.SetAbsOrigin(this.GetLocalOrigin())
	wearable.SetAbsAngles(this.GetLocalAngles())
	
	wearable.SetSkin(this.GetTeam())
	wearable.SetTeam(this.GetTeam())
	wearable.SetSolidFlags(4)
	wearable.SetCollisionGroup(11)

	NetProps.SetPropEntity(wearable, "m_hOwnerEntity", this)
	wearable.SetOwner(this)
	Entities.DispatchSpawn(wearable)
	
	NetProps.SetPropInt(wearable, "m_fEffects", bonemerge ? 1 | 128 : 0)
	
	NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 65535)
	
	NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityLevel", 1)
	
	NetProps.SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
	NetProps.SetPropBool(wearable, "m_AttributeManager.m_Item.m_bInitialized", true)
	NetProps.SetPropBool(wearable, "m_AttributeManager.m_Item.m_bOnlyIterateItemViewAttributes", false)
	
	wearable.AcceptInput("SetParent", "!activator", this, this)
	
	if (attachment != null) wearable.AcceptInput("SetParentAttachment", attachment, null, null)
	
	if (offsets != null)
	{
		EntFireByHandle(wearable, "RunScriptCode", "self.SetLocalOrigin(Vector(" + offsets[0].x + ", " + offsets[0].y + ", " + offsets[0].z + "))", 0.1, null, null)
		EntFireByHandle(wearable, "RunScriptCode", "self.SetLocalAngles(QAngle(" + offsets[1].x + ", " + offsets[1].y + ", " + offsets[1].z + "))", 0.1, null, null)
	}
	
	NetProps.SetPropIntArray(wearable, "m_nModelIndexOverrides", modelIndex, 0)
	NetProps.SetPropIntArray(wearable, "m_nModelIndexOverrides", modelIndex, 1)
	NetProps.SetPropIntArray(wearable, "m_nModelIndexOverrides", modelIndex, 2)
	NetProps.SetPropIntArray(wearable, "m_nModelIndexOverrides", modelIndex, 3)
	
	wearable.ValidateScriptScope()
	wearable.GetScriptScope().custom_wearable <- true
	
	return wearable
}

CTFPlayer.GetWearableItem <- function(id)
{
	for (local child = this.FirstMoveChild(); child != null; child = child.NextMovePeer())
	{ 
		if ("custom_wearable" in child.GetScriptScope() && NetProps.GetPropInt(child, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == id) return
	}
	
	local dummy_Weapon = Entities.CreateByClassname("tf_weapon_parachute")
	NetProps.SetPropInt(dummy_Weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
	NetProps.SetPropBool(dummy_Weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	
	dummy_Weapon.SetTeam(this.GetTeam())
	dummy_Weapon.DispatchSpawn()
	
	this.Weapon_Equip(dummy_Weapon)
    
	local wearable = NetProps.GetPropEntity(dummy_Weapon, "m_hExtraWearable")

	dummy_Weapon.Kill()
	
	NetProps.SetPropInt(wearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", id)
	NetProps.SetPropBool(wearable, "m_AttributeManager.m_Item.m_bInitialized", true)
	NetProps.SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
	
	wearable.DispatchSpawn()

	wearable.ValidateScriptScope()
	wearable.GetScriptScope().custom_wearable <- true

	return wearable
}

CTFPlayer.RemoveWearable <- function(input)
{
	local killarray = []
	
	for (local child = this.FirstMoveChild(); child != null; child = child.NextMovePeer())
	{ 
		if ("custom_wearable" in child.GetScriptScope())
		{
			if (typeof(input) == "integer")
			{
				if (NetProps.GetPropInt(child, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == input) killarray.append(child)
				if (NetProps.GetPropInt(child, "m_nModelIndex") == input) killarray.append(child)
			}
			
			if (typeof(input) == "string") { if (NetProps.GetPropIntArray(child, "m_nModelIndexOverrides", 3) == GetModelIndex(input)) killarray.append(child) }
		}
	}

	foreach (ent in killarray) ent.Kill()
}

CTFPlayer.GetAllWearables <- function()
{
	local array = []
	
	for (local child = this.FirstMoveChild(); child != null; child = child.NextMovePeer())
	{ 
		if ("custom_wearable" in child.GetScriptScope()) array.append(child)
	}

	return array
}

CTFBot.RemoveWearable <- CTFPlayer.RemoveWearable
CTFBot.GetAllWearables <- CTFPlayer.GetAllWearables

CTFBot.GetWearable <- CTFPlayer.GetWearable
CTFBot.GetWearableItem <- CTFPlayer.GetWearableItem

CBaseCombatWeapon.GetOwner <- function() { return NetProps.GetPropEntity(this, "m_hOwner") }

if (!("PEA" in getroottable()))	::PEA <- {}
if (!("PLAYERLOG" in getroottable())) ::PLAYERLOG <- {}

foreach (thing, var in PEA_GLOBAL) getroottable()["PEA"][thing] <- getroottable()["PEA_GLOBAL"][thing]
foreach (thing, var in PLAYERLOG) getroottable()["PEA"][thing] <- getroottable()["PLAYERLOG"][thing]
foreach (thing, var in PEA) getroottable()[thing] <- getroottable()["PEA"][thing]

delete ::PLAYERLOG
delete ::PEA_GLOBAL

if (!("PEA_GLOBAL_ONETIME" in getroottable())) // declare these variables only once on initial load, don't update them on any future loads
{
	::PEA_GLOBAL_ONETIME <-
	{
		gamerules_entity = Entities.FindByClassname(null, "tf_gamerules")
		objective_resource_entity = Entities.FindByClassname(null, "tf_objective_resource")
		debugger = null
		wavewon = false
		
		dummywearableindex = ::PrecacheModel("models/weapons/w_models/w_shotgun.mdl")

		firstload = ("custom_spawns" in PEA) ? true : false
	}
	
	foreach (thing, var in PEA_GLOBAL_ONETIME) getroottable()[thing] <- getroottable()["PEA_GLOBAL_ONETIME"][thing]

	for (local i = 1; i <= Constants.Server.MAX_PLAYERS; i++) // run this for when the first player connects to the server and the callback hasn't loaded yet
	{
		local player = PlayerInstanceFromIndex(i)
		
		if (player == null) continue
		
		player.ValidateScriptScope()
		
		if (!player.IsFakeClient()) player.ForceRespawn()
	}
	
	if ("custom_spawns" in PEA)
	{
		foreach (spawn in custom_spawns)
		{
			local s = SpawnEntityFromTable("info_player_teamspawn",
			{
				origin 	   	  = spawn[0]
				targetname 	  = spawn[1]
				TeamNum	   	  = 3
				spawnflags 	  = 511
				StartDisabled = spawn[2]
			})
		}
		
		for (local ent; ent = Entities.FindByClassname(ent, "info_player_teamspawn"); ) { if (NetProps.GetPropInt(ent, "m_iHammerID") == 0) ent.KeyValueFromString("classname", "entity_sign") }
		
		NetProps.SetPropFloat(gamerules_entity, "m_flRestartRoundTime", Time())
		
		foreach (name, callback in PEA.GLOBAL_CALLBACKS) PEA.GLOBAL_CALLBACKS[name] = callback.bindenv(gamerules_entity.GetScriptScope())

		__CollectGameEventCallbacks(PEA.GLOBAL_CALLBACKS)
		
		return
	}
}

else if (firstload) EntFireByHandle(gamerules_entity, "CallScriptFunction", "HideErrors", 0.1, null, null)
	
HideIcon("noicon")

foreach (think in getroottable()["ThinksTable"]) delete getroottable()["ThinksTable"][think]

ignite_player.AddAttribute("Set DamageType Ignite", 1, -1.0)
Entities.DispatchSpawn(ignite_player)

for (local ent; ent = Entities.FindByName(ent, "blimp_path*"); ) if (NetProps.GetPropEntity(ent, "m_pnext") == null) EntityOutputs.AddOutput(ent, "OnPass", "!activator", "RunScriptCode", "self.GetScriptScope().parented_blimp.GetScriptScope().DeployBomb()", -1.0, -1.0)

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
	case "mvm_powerplant_rc1": DisableRomevision(); AssignThinkToThinksTable("BombCarrierSpawnSpeedUp_Think"); break
	
	case "mvm_underworld_rc2": DisableRomevision(); break
}

AssignThinkToThinksTable("TankFinder_Think")

if ("CALLBACKS" in PEA)
{
	foreach (name, callback in PEA.CALLBACKS) PEA.CALLBACKS[name] = callback.bindenv(gamerules_entity.GetScriptScope()) // this will let us use local functions inside callbacks
	
	__CollectGameEventCallbacks(PEA.CALLBACKS)
}

foreach (name, callback in PEA.GLOBAL_CALLBACKS) PEA.GLOBAL_CALLBACKS[name] = callback.bindenv(gamerules_entity.GetScriptScope())

__CollectGameEventCallbacks(PEA.GLOBAL_CALLBACKS)

for (local ent; ent = Entities.FindByClassname(ent, "script_wearable"); ) ent.Kill()
	
if (WaveHasIcon("blimp2_lite")) UnhideIcon("blimp2_lite", 8)
	
foreach (player in GetAllPlayers(false, false, false))
{
	player.ValidateScriptScope()
	
	if (player.IsFakeClient())
	{
		if (!sigmod)
		{
			NetProps.SetPropBool(player, "m_bForcedSkin", false)
			NetProps.SetPropInt(player, "m_nForcedSkin", 0)
			NetProps.SetPropInt(player, "m_iPlayerSkinOverride", 0)
		}
		
		local scope = player.GetScriptScope()

		NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
		
		for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
		{ 
			if ("custom_wearable" in child.GetScriptScope()) { EntFireByHandle(child, "Kill", null, -1.0, null, null); continue }
			
			child.DisableDraw()
			
			continue
		}
		
		foreach (thing in player.GetScriptScope())
		{
			try { thing.GetClassname() }
			catch (e) { continue }
			
			if (!thing.IsPlayer()) thing.Kill()
		}
	
		player.TerminateScriptScope()
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
	
	AssignThinkToThinksTable("InstantReady_Think")
	
	__CollectGameEventCallbacks(PEA.DEBUG_CALLBACKS)
}

AddThinkToEnt(gamerules_entity, "GlobalThinker")

seterrorhandler(function(e)
{
	for (local player; player = Entities.FindByClassname(player, "player");)
	{
		if (NetProps.GetPropString(player, "m_szNetworkIDString") == "[U:1:95064912]")
		{
			local Chat = @(m) (printl(m), ClientPrint(player, 2, m))
			ClientPrint(player, 3, format("\x07FF0000AN ERROR HAS OCCURRED [%s].\nCheck console for details", e))
			
			Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
			Chat("CALLSTACK")
			local s, l = 2
			while (s = getstackinfos(l++)) Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))

			Chat("LOCALS")
			
			if (s = getstackinfos(2))
			{
				foreach (n, v in s.locals) 
				{
					local t = type(v)
					t ==    "null" ? Chat(format("[%s] NULL"  , n))    :
					t == "integer" ? Chat(format("[%s] %d"    , n, v)) :
					t ==   "float" ? Chat(format("[%s] %.14g" , n, v)) :
					t ==  "string" ? Chat(format("[%s] \"%s\"", n, v)) :
									 Chat(format("[%s] %s %s" , n, t, v.tostring()))
				}
			}
			
			return
		}
	}
})

EntFireByHandle(gamerules_entity, "RunScriptCode", "wavewon = false", -1.0, null, null)