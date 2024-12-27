//Nut file used for Accursed Aggrievocation!
//Dependencies:
//- popextensions_main.nut - By Braindawg, washy, Mince, and the rest of the Potato.tf team. Me included!

IncludeScript("popextensions_main.nut",getroottable())

::SeelTerror <-
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
        Convars.SetValue("tf_eyeball_boss_lifetime_spell",8) //Reset to default
        // keep this at the end
        delete ::SeelTerror
    }
    
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }

};

__CollectGameEventCallbacks(SeelTerror)

const iGIANT_EYE_LEVEL = 149 //approx
const OVERLAY_BUDDHA_MODE = 0x02000000
::ALL_PLAYERS <- MaxClients().tointeger();

for (local i = 1; i <= ALL_PLAYERS ; i++)
{
	local player = PlayerInstanceFromIndex(i)
	if (player == null) continue
	if (!player.IsBotOfType(TF_BOT_TYPE)) continue
	SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
}
//For wave 2: set duration of eyeball_boss to 3 minutes / 180 seconds.
Convars.SetValue("tf_eyeball_boss_lifetime_spell",180)


//Cult chief logic: spawns a tf_projectile_spellspawnboss when the bot performs the Second Rate Sorcery taunt.
//Special thanks to lite for the script that slows down its rockets.
PopExt.AddRobotTag("cultchief", {
	OnSpawn = function(bot,tag)
	{
		bot.GetScriptScope().bCasting <- false
		bot.GetScriptScope().bCastingDone <- false
		::hEyeBoss <- null
		
        PrecacheModel("models/props_halloween/halloween_demoeye.mdl")
        bot.GetScriptScope().iEyeRocketModelIndex <- PrecacheModel("models/props_halloween/eyeball_projectile.mdl")
        bot.GetScriptScope().flEyeRocketSpeed <- 550.0
		
		bot.GetScriptScope().PlayerThinkTable.bossThink <- function()
		{
			if (self.InCond(7) && !bCasting)
			{
				bCasting = true
				EntFire("!activator","RunScriptCode","bCastingDone = true",2.43,self)
			}
			if (bCastingDone)
			{
				bCastingDone = false
				local eyeboss_proj = CreateByClassname("tf_projectile_spellspawnboss");
				eyeboss_proj.KeyValueFromInt("teamnum",3);
				eyeboss_proj.KeyValueFromVector("origin",self.GetOrigin() + Vector(0,0,2));
				SetPropEntity(eyeboss_proj,"m_hThrower",self);
				DispatchSpawn(eyeboss_proj)
				
				self.RemoveCond(7)
			}
			if (hEyeBoss == null)
			{
				hEyeBoss = FindByClassname(hEyeBoss,"eyeball_boss")
			}
			else
			{
				hEyeBoss.KeyValueFromInt("solid",0)
				hEyeBoss.SetAbsOrigin(self.GetOrigin() + Vector(0,0,(60 + 85 * 1.75)))
				
				//Snippet by lite. Slows down rockets.
				for(local hRocket; hRocket = FindByClassname(hRocket, "tf_projectile_rocket");)
					if(GetPropInt(hRocket, "m_nModelIndex") == iEyeRocketModelIndex && hRocket.GetOwner() == hEyeBoss)
					{
						local vecVelocity = hRocket.GetAbsVelocity()
						if(vecVelocity.Length() > flEyeRocketSpeed)
						{
							vecVelocity.Norm()
							hRocket.SetAbsVelocity(vecVelocity * flEyeRocketSpeed)
						}
					}
			}
		}
	}
	OnDeath = function(bot,tag)
	{
		if (hEyeBoss != null)
		{
			hEyeBoss.AddFlag(FL_FROZEN)
			hEyeBoss.AcceptInput("AddOutput","rendermode 10",null,null)
			local hEyeBossProp = SpawnEntityFromTable("prop_dynamic",
			{
				targetname = "eyeball_boss_prop"
				model = "models/props_halloween/halloween_demoeye.mdl"
				skin = 3
				defaultanim = "escape"
				origin = hEyeBoss.GetOrigin()
				angles = hEyeBoss.GetAbsAngles()
			})
			EmitSoundEx({
				sound_name = "vo/halloween_eyeball/eyeball_laugh01.mp3",
				entity = hEyeBoss
				sound_level = 67 //~800 HU
			})
			EntFire("!activator","CallScriptFunction","DisappearEyeball",3.94,hEyeBoss)
			EntFire("!activator","Kill","",4,hEyeBoss)
			EntFire("eyeball_boss_prop","Kill","",4)
		}
	}
})

PopExt.AddRobotTag("leave_squad", {
	OnSpawn = function(bot,tag)
	{
		EntFire("!activator", "RunScriptCode","self.LeaveSquad()",0,bot)
	}
})
PopExt.AddRobotTag("leave_squad_delay", {
	OnSpawn = function(bot,tag)
	{
		EntFire("!activator", "RunScriptCode","self.LeaveSquad()",10,bot)
	}
})
PopExt.AddRobotTag("leave_squad_delay_short", {
	OnSpawn = function(bot,tag)
	{
		EntFire("!activator", "RunScriptCode","self.LeaveSquad()",5,bot)
	}
})

PopExt.AddRobotTag("unichief", {
	OnDeath = function(bot,tag)
	{
		local vecTarget = bot.GetOrigin()+Vector(0,0,65)
		printl("Attempting to dispatch particle effect at"+vecTarget.tostring())
		
		// EmitSoundEx({
			// sound_name = "Halloween.PlayerEscapedUnderworld",
			// entity = bot
			// sound_level = 67 //~800 HU
		// })
		DispatchParticleEffect("eyeboss_tp_escape",vecTarget,bot.GetAbsAngles().Forward())
		local hDest = SpawnEntityFromTable("info_teleport_destination",
		{
			targetname = "chief_teledest"
			origin = vecTarget
		})
		local hSpawnParticle = SpawnEntityFromTable("info_particle_system",
		{
			targetname = "chief_teleparticle"
			origin = vecTarget
			effect_name = "eyeboss_tp_vortex"
			start_active = 0
		})
		
		EntFire("!activator","Start","",1.7,hSpawnParticle)
		EntFire("!activator","RunScriptCode","BossSound(`Halloween.spell_teleport`)",1.7,hSpawnParticle)
		EntFire("!activator","Stop","",5,hSpawnParticle)
		EntFire("!activator","Kill","",6,hSpawnParticle)
		EntFire("!activator","Kill","",4.2,hDest)
	}
})
PopExt.AddRobotTag("unichief_final", {
	OnSpawn = function(bot,tag)
	{
		SetPropInt(bot, "m_debugOverlays", GetPropInt(bot, "m_debugOverlays") | OVERLAY_BUDDHA_MODE);
		bot.GetScriptScope().PlayerThinkTable.finalBossThink <- function()
		{
		}
	}
})

::DisappearEyeball <- function()
{
	EmitSoundEx({
		sound_name = "Halloween.spell_spawn_boss_disappear",
		entity = self
		sound_level = 67 //~800 HU
	})
	DispatchParticleEffect("eyeboss_tp_escape",self.GetOrigin(),self.GetAbsAngles().Forward())
}

//Jarate/Bowman Sniper logic.
//That's right, I'm using rafmod to check when a bot gets a target and using that to fire some VScript 8)
::ShouldTossJarate <- function()
{
	local hSecondaryWep = PopExtUtil.GetItemInSlot(self,1)
	if (self.GetActiveWeapon() == hSecondaryWep && GetPropFloat(hSecondaryWep,"m_flNextPrimaryAttack") <= Time())
		hSecondaryWep.PrimaryAttack()
}

// Boss logic

::BossSound <- function(szSoundname)
{
	EmitSoundEx({
		sound_name = szSoundname,
		entity = self
		sound_level = 67 //~800 HU
	})
}
::BossAttack_JumpLaser <- function(bot)
{
	local hLaserMimic_1 = SpawnEntityFromTable("tf_point_weapon_mimic",
	{
		targetname = "laser_mimic"
		origin = Vector(0,0,0)
		teamnum = 3 //blue
		"$weaponname":"Light of Miquella"
		"$weaponnosound":1
	})
	local hLaserMimic_2 = SpawnEntityFromTable("tf_point_weapon_mimic",
	{
		targetname = "laser_mimic"
		origin = Vector(0,0,0)
		angles = QAngle(0,180,0)
		teamnum = 3
		"$weaponname":"Light of Miquella"
		"$weaponnosound":1
	})
	
	EntFire("laser_mimic*","$SetOwner","!activator",0,bot)
	hLaserMimic_1.ValidateScriptScope()
	hLaserMimic_1.GetScriptScope().hBot <- bot
	hLaserMimic_1.GetScriptScope().tick <- 1
	hLaserMimic_2.ValidateScriptScope()
	hLaserMimic_2.GetScriptScope().hBot <- bot
	hLaserMimic_2.GetScriptScope().tick <- 1
	::Laser_Think <- function()
	{
		local scope = self.GetScriptScope()
		if (hBot == null || !PopExtUtil.IsAlive(hBot))
		{
			self.Destroy()
			return
		}
		self.SetAbsOrigin(hBot.GetOrigin() + Vector(0,0,40))
		
		//Cooldown: 1 second
		if (scope.tick > 210)
			scope.tick = 1
		
		//11 times per second, trigger 24 times for 120 degrees covered
		if (scope.tick % 6 == 0 && scope.tick <= 144)
		{
			self.AcceptInput("FireOnce","",null,null)
			self.SetAbsAngles(self.GetAbsAngles() + QAngle(0,5,0))
		}
		
		scope.tick = scope.tick + 1
		return -1
	}
	AddThinkToEnt(hLaserMimic_1,"Laser_Think")
	AddThinkToEnt(hLaserMimic_2,"Laser_Think")
}
::BossModelThink <- function()
{
	if (!self.IsValid()) 
	{
		printl("Debug: ERROR: NO SELF FOUND.")
		return -1
	}
	if (self.GetCycle() >= 0.7)
	{
		self.Destroy()
		return -1
	}
}
::RemoveBuddha <- function()
{
	SetPropInt(self, "m_debugOverlays", GetPropInt(self, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
}

::BossAttack_RelativeKnockback <- function()
{
	local vecBotOrigin = self.GetOrigin()
	for (local i = 1; i <= ALL_PLAYERS ; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player == null) continue
		if (player.IsBotOfType(TF_BOT_TYPE)) continue
		if (!player.IsAlive()) continue
		
		local vecPlayerOrigin = player.GetOrigin()
		local flDist = (vecPlayerOrigin - vecBotOrigin).Length()
		if (flDist > 400) continue;

		local flDiffx = vecPlayerOrigin.x - vecBotOrigin.x
		local flDiffy = vecPlayerOrigin.y - vecBotOrigin.y
		local vecDiff = Vector(flDiffx, flDiffy, 0)
		
		vecDiff = vecDiff * (0.15*pow(1+1000/flDist,2))
		vecDiff.z = 330
		player.SetAbsVelocity(vecDiff)
	}
}

::BossAttack_SkyLaser <- function()
{
	//Fire a trace from the bot's Y rotation straight ahead.
	//Along this trace, fire a bunch of lasers from the sky.
	
	//Stop the trace prematurely if it hits a wall.
}

::BossAttack_Microcosm <- function()
{
	//Initial Test
	//Create a particle on the ground underneath the nearest player within a certain distance.
	//Don't do this if the player is above our eye level.
	
	// DispatchParticleEffect("eyeboss_tp_escape",self.GetOrigin(),self.GetAbsAngles().Forward())
	//SpawnEntityFromTable?
	local hBombTest = CreateByClassname("tf_generic_bomb");
	hBombTest.KeyValueFromFloat("damage",1)
	hBombTest.KeyValueFromFloat("radius",146) //rocket explosion radius
	hBombTest.KeyValueFromInt("health",9999) //failsafe
	hBombTest.KeyValueFromString("explode_particle","utaunt_lightning_impact_electric")
	hBombTest.KeyValueFromString("sound","")
	hBombTest.KeyValueFromString("model","models/weapons/w_models/w_stickybomb3.mdl")
	hBombTest.KeyValueFromInt("skin",1)
	hBombTest.KeyValueFromInt("friendlyfire",0)
	hBombTest.KeyValueFromVector("origin",self.GetOrigin() + Vector(0,0,125));
	// hBombTest.SetMoveType(11,0); //CUSTOM and DEFAULT
	// hBombTest.SetGravity(-50);
	// hBombTest.AddSolidFlags(FSOLID_NOT_SOLID) //not_solid
	DispatchSpawn(hBombTest)
	
	local Microcosm_Think = function()
	{
		
	}
}