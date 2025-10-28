// Nut file for Runtime Optimization, Humbridge.
// by Seelpit

// Dependency:
//	seel_ins.nut	...also by Seelpit

printl("Seelpit's Runtime Optimization script loaded!")


//////////////////////////////////////////////////////////////////////////
//CHANGES TO FUNCTION REFERENCES
//////////////////////////////////////////////////////////////////////////

//Simplifying references to constants and NetProps.
//Credit: VDC wiki, lite.

::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			if (v == null)
				ROOT[k] <- 0;
			else
				ROOT[k] <- v;
}

foreach (k, v in NetProps.getclass())
    if (k != "IsValid")
        ROOT[k] <- NetProps[k].bindenv(NetProps);
	
foreach (k, v in Entities.getclass())
    if (k != "IsValid")
        ROOT[k] <- Entities[k].bindenv(Entities);

IncludeScript("seel_ins.nut",ROOT)
const OVERLAY_BUDDHA_MODE = 0x02000000

PrecacheSound("items/powerup_pickup_haste.wav")
PrecacheSound("items/powerup_pickup_crits.wav")
PrecacheSound("items/powerup_pickup_uber.wav")
PrecacheSound("weapons/medi_shield_deploy.wav")
	
// for (local i = 1; i <= MaxClients().tointeger() ; i++)
// {
	// local player = PlayerInstanceFromIndex(i)
	// AddThinkToEnt(player,null)
	// SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
// }

::SeelRuntime <-
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
        printl("Cleaning up SeelRuntime...")
		for (local i = 1; i <= ALL_PLAYERS ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			AddThinkToEnt(player,null)
			SetPropInt(player, "m_debugOverlays", GetPropInt(player, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
		}
        // keep this at the end
        delete ::SeelRuntime
    }
    
	ALL_PLAYERS = (MaxClients().tointeger())
	
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
	
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hAttacker = params.attacker;
		local hVictim = params.const_entity;
		if ( !( hAttacker.IsPlayer() ) ) return;
		
		if ( hVictim.GetClassname() == "obj_dispenser" && hVictim.GetTeam() == TF_TEAM_BLUE )
			params.damage = 0;
		
		if ( !( hVictim.IsPlayer() ) || !( hVictim.IsBotOfType(1337) ) ) return; 
		
		local iDmgTypeCustom = params.damage_stats
		
		//Makes backstabs deal 75 damage to IMPORTANT "player" bots. W7 players take dmg * 0.5 + 2(dmg * 0.5) = 0.5dmg + dmg = 1.5dmg -> 375 aka full kill.
		//Backstabs are always crits; resists total it to dmg * 0.25 + 2(dmg * 0.25) * 0.1 = 0.25dmg + 0.05dmg = 0.3dmg.
		//75 is a decent middle ground, might up it to ~80-90 if deemed not worth.
		if ( hVictim.HasBotTag("playerbot") && iDmgTypeCustom == TF_DMG_CUSTOM_BACKSTAB) //DMG_CUSTOM_BACKSTAB
			params.damage = 250
			
		//Chief Soda Scout takes less damage while drinking, since they're very vulnerable otherwise.
		//Reduction may seem a bit weird thanks to additional damage vulnerabilities, unfortunately!
		if ( hVictim.HasBotTag("chief_soda") && hVictim.GetActiveWeapon().GetSlot() == 1)
			params.damage *= 0.25
		
		//Makes Chief Soda Scout always deal blast damage.
		//This is a little more consistent than relying on rafmod's "add / remove damage type" attributes.
		if ( hAttacker.IsBotOfType(1337) )
			if ( hAttacker.HasBotTag("chief_soda") || hAttacker.HasBotTag("chief_mangler") )
				params.damage_type = DMG_BLAST | DMG_SLOWBURN //blast damage, use damage falloff formula
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local ent = GetPlayerFromUserID(params.userid);
		if (ent && ent.IsBotOfType(1337))
			EntFireByHandle(ent, "RunScriptCode", "SeelRuntime.BotCheck(self)", -1, null, null);
	}
	
	BotCheck = function(hBot)
	{
		// Prevent teleported bots from getting stuck in the terrain, prevent them from attacking for 1.5 seconds (== uber duration + 0.3),
		// and remove the teleported-in particles by removing the associated condition to reduce lag.
		// Remove the think after 3 seconds to prevent cases where the bot erroneously attempts to teleport anyway.
		if (hBot.HasBotTag("telebot"))
		{
			PreventBotStuck(hBot)
			
			hBot.RemoveCond(6)
			hBot.AddBotAttribute(SUPPRESS_FIRE)
			hBot.AddBotAttribute(IGNORE_FLAG)
			EntFireByHandle(hBot, "RunScriptCode", "self.RemoveBotAttribute(SUPPRESS_FIRE);self.RemoveBotAttribute(IGNORE_FLAG)", 1.5, null, null)
			
			EntFireByHandle(hBot, "RunScriptCode", "AddThinkToEnt(self,null)", 3, null, null)
		}
	}
	
	TestFunc = function()
	{
		printl("Test function fired succesfully!")
	}

	BallsToBombsThink = function()
	{
		for (local hBall; hBall = Entities.FindByClassname(hBall, "tf_projectile_stun_ball"); )
		{
			local hBot = hBall.GetOwner()
			// printl("Checking if owner "+hBot+" is valid...")
			if (hBot == null || !hBot.IsPlayer() || !hBot.IsAlive() || !hBot.IsBotOfType(TF_BOT_TYPE) || !hBot.HasBotTag("ballbomber"))
			{
				printl("[BallsToBombs] Owner is null, not alive, or doesn't have the right tag. Continuing...")
				continue;
			}
			
			EntFire("!activator","Kill","",0,hBall)
			
			for (local hWepMimic; hWepMimic = Entities.FindByClassname(hWepMimic, "tf_point_weapon_mimic"); )
				if (hWepMimic.GetOwner() == hBot)
					hWepMimic.AcceptInput("FireOnce","",hBot,hBot)
		}
		return -1
	}
	
	SetXZAnglesToZero = function(hEnt)
	{
		hEnt.SetAbsAngles(QAngle(0,hEnt.GetAbsAngles().y,0))
	}
	
	FindTouchTrigger = function(hDisp)
	{
		for (local hTouchTrig; hTouchTrig = Entities.FindByClassname(hTouchTrig, "dispenser_touch_trigger"); )
			if (hTouchTrig.GetOwner() == hDisp)
				hTouchTrig.AcceptInput("SetParent","!activator",hDisp,hDisp)
	}
	
	CheckSentryStuck = function(hSentry)
	{
		local vecOrigin = hSentry.GetOrigin()
		
		local arTraceLocs = [
		Vector(vecOrigin.x + hSentry.GetBoundingMaxs().x,	vecOrigin.y,								vecOrigin.z),
		Vector(vecOrigin.x,									vecOrigin.y + hSentry.GetBoundingMaxs().y,	vecOrigin.z),
		
		Vector(vecOrigin.x + hSentry.GetBoundingMins().x,	vecOrigin.y,								vecOrigin.z),
		Vector(vecOrigin.x,									vecOrigin.y + hSentry.GetBoundingMins().y,	vecOrigin.z),
		
		Vector(vecOrigin.x + hSentry.GetBoundingMaxs().x,	vecOrigin.y + hSentry.GetBoundingMaxs().y,	vecOrigin.z),
		Vector(vecOrigin.x + hSentry.GetBoundingMins().x,	vecOrigin.y + hSentry.GetBoundingMins().y,	vecOrigin.z),
		
		Vector(vecOrigin.x + hSentry.GetBoundingMaxs().x,	vecOrigin.y + hSentry.GetBoundingMins().y,	vecOrigin.z),
		Vector(vecOrigin.x + hSentry.GetBoundingMaxs().y,	vecOrigin.y + hSentry.GetBoundingMins().x,	vecOrigin.z)
		]
		
		
		local tbTrace = {
			start = vecOrigin
			end = vecOrigin
			hullmin = hSentry.GetBoundingMins()
			hullmax = hSentry.GetBoundingMaxs()
			mask = 81931 //MASK_PLAYERSOLID_BRUSHONLY
			ignore = hSentry
		}
		TraceHull(tbTrace)
		
		if (tbTrace.hit)
		{
			// printl("Hit something, investigating...")
			foreach(vec in arTraceLocs)
			{
				local tbTrace = {
					start = Vector(vec.x,vec.y,vec.z + 30)
					end = vec
					hullmin = hSentry.GetBoundingMins()*0.5
					hullmax = hSentry.GetBoundingMaxs()*0.5
					mask = 81931 //MASK_PLAYERSOLID_BRUSHONLY
					ignore = hSentry
				}
				TraceHull(tbTrace)
				
				if (tbTrace.hit)
				{
					// printl("Still hit something, trying next...")
					continue
				}
				else
				{
					// printl("A free spot! Get over here!")
					hSentry.SetAbsOrigin(tbTrace.pos)
				}
			}
		}
	}
	
	// Animates the sentry.
	NextAnimation = function(hProp)
	{
		// printl(hProp.GetModelName())
		if (hProp.GetModelName() == "models/buildables/sentry1_heavy.mdl")
			hProp.SetModel("models/buildables/sentry2_heavy.mdl")
			
		else if (hProp.GetModelName() == "models/buildables/sentry2_heavy.mdl")
			hProp.SetModel("models/buildables/sentry3_heavy.mdl")
			
		else if (hProp.GetModelName() == "models/buildables/sentry3_heavy.mdl")
		{
			// printl(hProp.GetScriptScope().hSentry)
			local hSentry = hProp.GetScriptScope().hSentry
			if (hSentry == null)
			{
				for (local hSentryB; hSentryB = Entities.FindByClassname(hSentryB, "obj_sentrygun"); )
				{
					if (hSentryB.GetTeam() != TF_TEAM_BLUE)
						continue;
					
					local iDist = Length(hSentryB.GetOrigin() - hProp.GetOrigin())
					
					if (iDist > 72) //approximation of "far enough". Sort of. Probably.
						continue;
					
					if ( !( GetPropBool(hSentryB,"m_bDisabled") ) )
						continue;
					
					hSentry = hSentryB
					break;
				}
			}
			
			hSentry.KeyValueFromInt("effects",0)
			
			EntFireByHandle(hSentry,"SetHealth","216",0,null,null) //the SetHealth function for sentries is a LIE. At least, on a rafmod server.
			SetPropBool(hSentry,"m_bDisabled",false)
			
			hSentry.KeyValueFromInt("$cannotbesapped",0)
			SetXZAnglesToZero(hSentry)
			
			EntFireByHandle(hSentry,"RemoveHealth","5000",6,null,null)
			
			EntFireByHandle(hProp,"Kill","",0.015,null,null)
		}
		
		if (hProp && hProp.IsValid())
		{
			EntFireByHandle(hProp,"SetAnimation","upgrade",0,null,null)
			EntFireByHandle(hProp,"SetPlaybackRate","3",0.015,null,null)
		}
	}
	
	// VScript rewrite of a lua function
	SpawnTele = function(hBot)
	{
		local traceStartPos = hBot.GetOrigin() + Vector(0, 0, 20)
		local traceEndPos = hBot.GetOrigin() + Vector(0, 0, -2000)
		printl("AbsOrigin: "+hBot.GetOrigin().tostring()+", edited to: "+traceStartPos.tostring())
		
		local tbTrace = {
			start = traceStartPos,
			end = traceEndPos,
			hullmin = hBot.GetBoundingMins()
			hullmax = hBot.GetBoundingMaxs()
			mask = 131083 //MASK_NPCWORLDSTATIC: SOLID, WINDOW, MONSTERCLIP, GRATE; aka only world.
		}
		TraceHull(tbTrace)
		printl("Trace finished!")
		
		if (tbTrace.hit)
		{
			printl("Trace hit at "+tbTrace.endpos.tostring())
			local hTele = SpawnEntityFromTable("obj_teleporter",
			{
				targetname = "tp"
				spawnflags = 2
				teamnum = 3
				origin = tbTrace.endpos
				teleportertype = 2
				"$TeleportWhere" : "spawnbot_chief"
			})
			hTele.SetSolid(0)
			local hBlock = SpawnEntityFromTable("func_forcefield",
			{
				targetname = "tp_block"
				teamnum = 3
				origin = tbTrace.endpos
			})
			hBlock.SetSolid(2)
			hBlock.SetSize(Vector(-40,-40,0),Vector(-40,-40,100))
			EntFireByHandle(hTele,"RemoveHealth","5000",5,null,null)
			EntFireByHandle(hBlock,"RunScriptCode","self.Destroy()",5,null,null)
		}
	}
	
	//Killer Bee Queen think function
	EnableQueenThink = function(hBot)
	{
		local hScope = hBot.GetScriptScope()
		printl("Declaring scope variables...")
		hScope.iHealthRoundedPrev <- 10
		
		printl("Constructing think...")
		hScope.QueenThink <- function()
		{
			if (!(self.IsAlive()))
			{
				printl("No longer alive, yeet the think.")
				SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self,null)
			}
			local iHealth = fabs(self.GetHealth()) / fabs(self.GetMaxHealth())
			local iHealthRoundedCur = ceil( (iHealth * 10) )
			
			// This part also handles cases where, if the boss' health "jumps" over a threshold, it will still spawn the bots.
			// NB: if the boss is somehow dealt enough damage to be killed prior to a WaveSpawn being spawned, that may cause problems with WaveSpawns not spawning at all.
			// If this ends up happening, I will fix it by keeping track of which WaveSpawns have spawned.
			if (iHealthRoundedCur < iHealthRoundedPrev)
			{
				iHealthRoundedPrev--;
				printl("Health mismatch! New threshold reached: "+iHealthRoundedPrev+"0% health!")
				EntFire("pop_interface","$ResumeWavespawn","Support"+iHealthRoundedPrev+"0")
			}
			
			if (Time() % 1 == 0)
				printl("Health: "+iHealth+", cur-%: "+iHealthRoundedCur+", prev-%: "+iHealthRoundedPrev)
			
			return -1
		}
		printl("Attempting to add think to the Queen...")
		AddThinkToEnt(hBot,"QueenThink")
	}
	PreventBotStuck = function(hBot)
	{
		local hScope = hBot.GetScriptScope()
		hScope.AntiStuckThink <- function()
		{
			if (!(self.IsAlive()))
			{
				SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self,null)
			}
			local origin = self.GetOrigin() //Thanks to Fellen for providing a quick solution for this!
			local trace = {
				start = origin
				end = origin
				hullmin = self.GetPlayerMins()
				hullmax = self.GetPlayerMaxs()
				mask = 81931 //MASK_PLAYERSOLID_BRUSHONLY
				ignore = self
			}
			TraceHull(trace)

			if (trace.hit)
			{
				printl("Bot is stuck! Attempting to un-stuck...")
				local hNavArea = NavMesh.GetNearestNavArea(self.GetOrigin(), 1024, false, true)
				local vecNavAreaCenter = hNavArea.GetCenter()
				vecNavAreaCenter.z += 16
				self.SetAbsOrigin(vecNavAreaCenter)
			}
		}
		printl("Attempting to add anti-stuck think to bot...")
		AddThinkToEnt(hBot,"AntiStuckThink")
	}
	
	PrintRandomBanter = function()
	{
		local iRandomText = RandomInt(0,3)
		
		//Switch statements are wack so I'm using if
		if (iRandomText == 0)
			PrintBanter(0)
		else if (iRandomText == 1)
			PrintBanter(1)
		else if (iRandomText == 2)
			PrintBanter(2)
		else if (iRandomText == 3)
			PrintBanter(3)
	}
	//Default delay: 2.5
	PrintBanter = function(iType,iLine = 0)
	{
		local iDelay = 2.5
		printl("Printing type "+iType.tostring()+", line "+iLine.tostring()+"...")
		if (iType == 0)
		{
			if (iLine == 0)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  mix, do you collect festivizers")
			if (iLine == 1)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFThe Festive Jeremix \x07FCECCB:  uhhh for use yeah, why?")
			if (iLine == 2)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  I can trade you some later")
				iDelay = 1
			}
			if (iLine == 3)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFYour Savior: Jeremessiah \x07FCECCB:  simp")
				iDelay = 0.75
			}
			if (iLine == 4)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  stfu")
				return;
			}
		}
		else if (iType == 1)
		{
			local iRareLine = RandomInt(0,9)
			if (iLine == 0)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFThe Festive Jeremix \x07FCECCB:  Are respawns bugged for blue, or")
			if (iLine == 1 && iRareLine == 9)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  you are a preplanned spawn in a wave of spawns. there is no respawn. you are a bot. all of us are.")
			else if (iLine == 1)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  Ya it's weird, really long or something")
				return;
			}
			if (iLine == 2)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJester Jerome \x07FCECCB:  Except me :)")
				return;
			}
		}
		else if (iType == 2)
		{
			if (iLine == 0)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFThe Festive Jeremix \x07FCECCB:  Did Jeremius actually ragequit???")
				iDelay = 1.5
			}
			if (iLine == 1)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFThe Festive Jeremix \x07FCECCB:  in this year???")
				iDelay = 0.5
			}
			if (iLine == 2)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFYour Savior: Jeremessiah \x07FCECCB:  skill issue")
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  lol they did")
			}
			if (iLine == 3)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  >dies once >instant disconnect >''man i'm so cool''")
				return;
			}
		}
		else if (iType == 3)
		{
			if (iLine == 0)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFThe Festive Jeremix \x07FCECCB:  Wait how the heck was Jeremiah's dc message different")
			if (iLine == 1)
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  true gamer moment")
			if (iLine == 2)
			{
				ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFJeremy, Arrogant Attacker \x07FCECCB:  For real tho no idea he just does that. Most Normal Dark Souls Player")
				return;
			}
		}
		iLine += 1
		local szFunction = "SeelRuntime.PrintBanter("+ iType.tostring() +","+ iLine.tostring()+")"
		printl("Sending function: "+szFunction)
		EntFire("bignet","RunScriptCode",szFunction,iDelay)
	}
	PrintBossBanter = function(iLine)
	{
		local iDelay = 2.5
		if (iLine == 0)
		{
			ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFYour Savior: Jeremessiah \x07FCECCB:  alright")
			iDelay = 0.5
		}
		if (iLine == 1)
			ClientPrint(null,3,"\x07FCECCB*DEAD* \x0799CCFFYour Savior: Jeremessiah \x07FCECCB:  thats it")
		if (iLine == 2)
			ClientPrint(null,3,"\x07FCECCB\x0799CCFFYour Savior: Jeremessiah \x07FCECCB:  im done carrying")
		iLine += 1
		local szFunction = "SeelRuntime.PrintBanter("+ iType.tostring() +","+ iLine.tostring()+")"
		printl("Sending function: "+szFunction)
		EntFire("bignet","RunScriptCode",szFunction,iDelay)
	}
	
	//Woe, ye who scour these files looking for wisdom!
	//SetModelScale(fl scale, fl change_duration) does the same thing as this.
	//I kept it cause it's functional and already useful for timing the flag change,
	//but if you're not doing anything once it reaches the apex, just...use SetModelScale().
	ChangeScaleToGiant = function(hBot, szIcon = "tf2_lite_crit")
	{
		local flScale = GetPropFloat(hBot,"m_flModelScale")
		if (flScale >= 1.75)
		{
			SINS.ChangeIconFlags(szIcon,9)
			
			return;
		}
		if (flScale < 1.75)
		{
			hBot.SetScaleOverride(flScale + 0.0375) //~20 times, 1.2sec
			EntFire("!activator","RunScriptCode","SeelRuntime.ChangeScaleToGiant(self)",0.06,hBot)
		}
	}
	
	// 95%: Crit-a-Cola (+DAMAGE)			Deals mini-crits.
	// 80%: Haste Fizz (+DAMAGE, +SPEED)	Shoots, reloads, and moves faster
	// 65%: Kritz-a-Cola (+DAMAGE)			Deals full crits.
	// 50%: Shield Shake (+DEFENSE, TEMP)	Gains a small shield. Can fade, can re-drink.
	// 25%: Uber-Pop (+DEFENSE, TEMP)		Gains invulnerability. Can fade, cannot re-drink.
	EnableBossThink = function(hBot)
	{
		local hScope = hBot.GetScriptScope()
		printl("Declaring scope variables...")
		hScope.bCola <- false
		hScope.bKritz <- false
		hScope.bHaste <- false
		hScope.bShield <- false
		hScope.bUber <- false
		hScope.bDying <- false
		hScope.flDrinkTime <- 0
		
		hScope.bMedicOnTeam <- false
		
		printl("Constructing think...")
		hScope.BossThink <- function()
		{
			if (!(self.IsAlive()))
			{
				printl("No longer alive, yeet the think.")
				SetPropString(self, "m_iszScriptThinkFunction", "")
				AddThinkToEnt(self,null)
			}
			local iHealth = fabs(self.GetHealth()) / fabs(self.GetMaxHealth())
			
			if (bCola && flDrinkTime <= Time() && !(self.InCond(16))) //Backup logic bc Etern-a-Cola is being weird.
				self.AddCond(16)
			
			//95%: Crit-a-Cola, 85%: Bonch, 75%: Multi-Pop, 65%: Haste Fizz, 50%: Shield Shake
			if (iHealth < 0.95 && !(bCola))
			{
				printl("Try to drink Crit-a-Cola!")
				
				EntFire("!activator","$GiveItem","Etern-a-Cola",0,self)
				
				bCola = true
				flDrinkTime = Time() + 5
				
				SINS.ChangeClassIcon(self,"scout_cola_nys")
				ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  actually useful scouts use cola")
				// ClientPrint(null,3,"Next drink time: "+flDrinkTime.tostring())
				return -1
			}
			else if (iHealth < 0.80 && !(bHaste) && flDrinkTime <= Time())
			{
				printl("Try to drink Haste Fizz!")
				
				EntFire("!activator","$GiveItem","Haste Fizz NOCHARGE",0,self)
				EntFire("!activator","$SetProp$m_iAmmo$5","1",0.1,self)
				EntFire("player","$PlaySoundToSelf","items/powerup_pickup_haste.wav",1.2)
				
				bHaste = true
				flDrinkTime = Time() + 5
				
				ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  dodge this")
				SINS.ChangeClassIcon(self,"scout_hastefizz_v1")
				// ClientPrint(null,3,"Next drink time: "+flDrinkTime.tostring())
				return -1
			}
			else if (iHealth < 0.65 && !(bKritz) && flDrinkTime <= Time())
			{
				printl("Try to drink Kritz-a-Cola!")
				
				EntFire("!activator","$GiveItem","Kritz-a-Cola",0,self)
				EntFire("!activator","$SetProp$m_iAmmo$5","1",0.1,self)
				EntFire("player","$PlaySoundToSelf","items/powerup_pickup_crits.wav",1.2)
				
				self.RemoveCond(16) //Redundant and confusing visuals: removed.
				
				bKritz = true
				flDrinkTime = Time() + 5
				
				ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  crit cans < crit in a can")
				SINS.ChangeClassIcon(self,"scout_kritzcola_v1")
				SINS.ChangeIconFlags("tf2_lite_crit",25)
				// ClientPrint(null,3,"Next drink time: "+flDrinkTime.tostring())
				return -1
			}
			else if (iHealth < 0.45 && !(bShield) && flDrinkTime <= Time())
			{
				printl("Try to drink Shield Shake!")
				
				EntFire("!activator","$GiveItem","Shield Shake",0,self)
				EntFire("!activator","$SetProp$m_iAmmo$5","1",0.1,self)
				EntFire("player","$PlaySoundToSelf","weapons/medi_shield_deploy.wav",1.2)
				
				bShield = true
				flDrinkTime = Time() + 5
				
				
				for (local i = 1; i <= MaxClients().tointeger() ; i++)
				{
					local player = PlayerInstanceFromIndex(i)
					if (player == null) continue
					if (player.IsBotOfType(TF_BOT_TYPE)) continue
					if (player.GetPlayerClass() != TF_CLASS_MEDIC) continue
					
					local hMedigun = GetItemInSlot(player,1) //Secondary
					if (hMedigun.GetAttribute("generate rage on heal",0) != 0)
					{
						bMedicOnTeam = true
						break
					}
				}
				if (bMedicOnTeam)
					ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  nice shield. gonna use it too")
				else
					ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  medic shield op? dont mind if i do")
				SINS.ChangeClassIcon(self,"scout_shieldshake_v1")
				// ClientPrint(null,3,"Next drink time: "+flDrinkTime.tostring())
				return -1
			}
			// else if (iHealth < 0.25 && !(bUber) && flDrinkTime <= Time())
			// {
				// printl("Try to drink Uber-Pop!")
				
				// EntFire("!activator","$GiveItem","Uber-Pop",0,self)
				// EntFire("!activator","$SetProp$m_iAmmo$5","1",0.1,self)
				// EntFire("player","$PlaySoundToSelf","items/powerup_pickup_uber.wav",1.2)
				
				// bUber = true
				// flDrinkTime = Time() + 5
				
				// ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  ")
				// SINS.ChangeClassIcon(self,"scout_bonk_uber_nys")
				// ClientPrint(null,3,"Next drink time: "+flDrinkTime.tostring())
				// return -1
			// }
			
			//Frame 108 of 194 = after 3.6 seconds
			if (self.GetHealth() <= 100 && self.InCond(7) && !(bDying))
			{
				printl("Try to drink water! (100% fail!)")
				EntFire("soda_relay","FireUser4","",3.5,self)
				bDying = true
				
				ClientPrint(null,3,"\x0799CCFFJeremessiah, Carbonated Doom \x07FCECCB:  water break, stop killing me")
			}
			
			return -1
		}
		printl("Attempting to add think to boss...")
		AddThinkToEnt(hBot,"BossThink")
		printl("Giving boss buddha...")
		SetPropInt(hBot, "m_debugOverlays", GetPropInt(hBot, "m_debugOverlays") | OVERLAY_BUDDHA_MODE)
	}
	
	RemoveBuddha = function(hBot)
	{
		printl("Removing buddha from"+hBot.GetName()+"...")
		SetPropInt(hBot, "m_debugOverlays", GetPropInt(hBot, "m_debugOverlays") & ~OVERLAY_BUDDHA_MODE)
	}
	
	iChiefPhase = 1
	SetChiefPhase = function(iPhase)
	{
		if (iChiefPhase < iPhase)
		{
			iChiefPhase = iPhase
			EntFire("pop_interface","ChangeBotAttributes","Phase"+iPhase.tostring())
			
			if (iPhase == 2)
			{
				EntFire("pop_interface","ChangeDefaultEventAttributes","Spellbook")
				ClientPrint(null,3,"\x0799CCFFFestive Fiend Jeremix \x07FCECCB:  fire time! burn em jeremy!")
				ClientPrint(null,3,"\x0799CCFFAustralium Assailant Jeremy \x07FCECCB:  I've got more than bullets now, bodyblockers")
			}
			if (iPhase == 3)
			{
				EntFire("pop_interface","ChangeDefaultEventAttributes","MilkMark")
				ClientPrint(null,3,"\x0799CCFFAustralium Assailant Jeremy \x07FCECCB:  Jeremix, get me some health")
				ClientPrint(null,3,"\x0799CCFFFestive Fiend Jeremix \x07FCECCB:  heal heal heal!! were so close!!")
			}
		}
	}
	
	PrintBonkBar = function(hBot)
	{
		hBot.GetScriptScope().hText <- SpawnEntityFromTable("point_worldtext",
		{
			textsize       = 40
			message        = 0
			font           = 1
			orientation    = 1
			textspacingx   = 1
			textspacingy   = 1
			spawnflags     = 0
			origin         = hBot.GetOrigin() + hBot.EyeAngles().Forward()*100 + Vector(0, 0, 65)
			rendermode     = 3
		})
		hBot.GetScriptScope().NetPropVal <- 0
		hBot.GetScriptScope().BonkThink <- function()
		{
			local flBarMeasure = GetPropFloatArray(self,"m_Shared.tfsharedlocaldata.m_flItemChargeMeter",NetPropVal)
			hText.KeyValueFromString("message",flBarMeasure.tostring())
		}
		AddThinkToEnt(hBot, "BonkThink")
	}
};

__CollectGameEventCallbacks(SeelRuntime);

//////////////////////////////////////////////////////////////////////////
//CONSTANTS
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
//FUNCTIONS
//////////////////////////////////////////////////////////////////////////

function ForEveryBotWithTag(tag,func)
{
	for (local i = 1; i <= ALL_PLAYERS ; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player == null) continue
		if (!player.IsBotOfType(TF_BOT_TYPE)) continue
		if (player == self) continue
		if (!player.IsAlive()) continue
		
		if (player.HasBotTag(tag)) func(player);
	}
}

//Stolen from PopExtUtil
function GetItemInSlot(player, slot)
{
	local item
	for (local i = 0; i < SLOT_COUNT; i++) {
		local wep = GetPropEntityArray(player, "m_hMyWeapons", i)
		if ( wep == null || wep.GetSlot() != slot) continue

		item = wep
		break
	}
	return item
}

local path1 = null
local path2 = null
local carrierdead = false
function SpawnCustomTankPaths()
{
	if (!self.IsValid()) return;
	
	printl("Creating paths...")
	
	path2 = SpawnEntityFromTable("path_track",{
		targetname = "carrier_path_2",
		origin = Vector(3810,-710,85) //Hatch coordinates.
	})
	path1 = SpawnEntityFromTable("path_track",{
		targetname = "carrier_path_1",
		origin = self.GetAttachmentOrigin(self.LookupAttachment("head")) + Vector(0,0,80)
		target = "carrier_path_2"
	})
	::PathMoveThink <- function()
	{
		if (!self.IsValid() || !self.IsAlive() && !self.HasBotTag("tank_carrier"))
		{
			printl("Removing think...")
			SetPropString(self, "m_iszScriptThinkFunction", "");
			AddThinkToEnt(self, "null")
		}
		
		if (path1 != null && path2 != null)
		{
			printl("Setting path 1 location...")
			path1.SetAbsOrigin(self.GetAttachmentOrigin(self.LookupAttachment("head")) + Vector(0,0,80))
			return -1
		}
		
		printl("Neither dead nor paths found.")
	}
	AddThinkToEnt(self,"PathMoveThink")
}
function TankToBeCarried(hTank)
{
	hTank.SetSolidFlags(FSOLID_NOT_SOLID)
	// ForEveryBotWithTag("tank_carrier", function(hBot)
	// {
		// hTank.AcceptInput("SetParent","!activator",hBot,hBot)
	// })
	
	::TankParentThink <- function()
	{
		if (!carrierdead)
			self.SetAbsOrigin(path1.GetOrigin())
	}
	AddThinkToEnt(hTank,"TankParentThink")
}
