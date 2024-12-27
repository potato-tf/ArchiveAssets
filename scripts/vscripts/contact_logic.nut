local CurrentWaveNum = GetPropInt(FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")
::Contact <- {}
::debugzz <- false

::Contact <-
{
    Cleanup = function()
    {
        if(debugzz) ClientPrint(null, 3 , CurrentWaveNum.tostring())
        for (local i = 1, player; i <= MaxClients().tointeger(); i++)
            if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2)
                player.SetGravity(1.0)

        local badeggs = []
        //PopExtUtil.PrintTable(PopExtUtil.BotArray)
        for (local index = 0; index < PopExtUtil.BotArray.len(); index += 1) {
            local player = PopExtUtil.BotArray[index]
            try {
                player.ValidateScriptScope()
            } catch(e) {
                if(debugzz) ClientPrint(null, 3, "exception caught during cleanup: " + e.tostring())
                badeggs.append(index)
                continue
            }
            if(debugzz) ClientPrint(null, 3 , "cleaning up " + player.tostring())
            local scope = player.GetScriptScope()

            local alive = PopExtUtil.IsAlive(player)
            if (alive && !("botCreated" in scope)) {
                scope.botCreated <- true

                foreach(tag, table in robotTags)
                    if (player.HasBotTag(tag)) {
                        scope.popFiredDeathHook <- false
                        PopExtHooks.AddHooksToScope(tag, table, scope)

                        if ("OnSpawn" in table)
                            table.OnSpawn(player, tag)
                    }
            }
            // Make sure that ondeath hook is fired always
            if (!alive && "popFiredDeathHook" in scope) {
                if (!scope.popFiredDeathHook)
                    PopExtHooks.FireHooksParam(player, scope, "OnDeath", null)

                delete scope.popFiredDeathHook
            }
        }

        while(badeggs.len() > 0) {
            local i = badeggs.pop()
            PopExtUtil.BotArray.remove(i)
        }

        delete ::Contact
    }

    OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_) {
        Cleanup()
    }
    OnGameEvent_teamplay_round_start = function(_) {
        //PopExtUtil.PrintTable(PopExtUtil.BotArray)
        Cleanup()
    }

    OnScriptHook_OnTakeDamage = function(params)
    {
        if(params.const_entity == null || params.attacker == null) return

        local ent = params.const_entity;

        if( params.attacker.GetTeam()!= 2 && ent.GetClassname() != "base_boss") return

        local dmg = params.damage
        local isCrit = false
        if ((params.damage_type & Constants.FDmgType.DMG_ACID) || IsPlayerCritBoosted(params.attacker)) {
            dmg *= 3
            isCrit = true
        }
        else if (IsPlayerMiniCritBoosted(params.attacker)) dmg *= 1.35

        if(params.attacker.GetTeam()== 3 && ent.GetClassname() == "base_boss" && ent.GetName().find("controlpanel")!=null && Contact.rawin("cannonPuppet") && IsPlayerAlive(Contact.cannonPuppet))
        {
            local h = Contact.cannonPuppet.GetHealth()
            if(CurrentWaveNum == 6 ) dmg = dmg*0.80 //&& params.attacker != Contact.engiBoss
            if(CurrentWaveNum == 7 && h < 5000) dmg = dmg*0.65 // i will be a bit kind to the players

            if(dmg > 500) dmg = 500
            if(h < dmg) {
                EntFireByHandle(Contact.cannonPuppet, "$Suicide", null, 0, null, null)
            }
            else Contact.cannonPuppet.SetHealth(Contact.cannonPuppet.GetHealth()-dmg)

            local curThreshold = Contact.cannonPuppet.GetScriptScope().curThreshold
            local ratio = (1.0 * Contact.cannonPuppet.GetHealth()) / Contact.cannonPuppet.GetMaxHealth()
            if(ratio < curThreshold && curThreshold > 0) {
                CreateGameTextSuperFast("////WARNING: LASER CONTROLS AT "+ (curThreshold*100).tostring() +"% HEALTH////", 2, "255 255 0", "255 255 0")
                ClientPrint(null, 3, "\x07FF3F3FWARNING: LASER CONTROLS AT "+ (curThreshold*100).tostring() +"% HEALTH")
                Contact.cannonPuppet.GetScriptScope().curThreshold <- curThreshold - 0.2
            }


        }

        else if ( ent.GetClassname() == "prop_dynamic" && ent.GetName().find("drone")!=null)
        {
            local bot = Entities.FindByNameNearest("dronebot", ent.GetOrigin()-Vector(0,0,90), 100)
            if(!IsPlayerAlive(bot)) return

            if(params.attacker.rawin("InCond") && params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) && !isCrit && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                dmg *= 2
                params.damage_type += Constants.FDmgType.DMG_ACID
                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
            }
            bot.TakeDamageEx(params.inflictor, params.attacker, params.weapon, params.damage_force, params.damage_position, dmg, params.damage_type)
            //Entities.FindByNameNearest("drone_hitbox", ent.GetOrigin(), 150).TakeDamageEx(params.inflictor, params.attacker, params.weapon, params.damage_force, params.damage_position, dmg, params.damage_type)
        }

        else if ( ent.GetClassname() == "obj_teleporter" && ent.GetTeam()== 3) //I stuck a teleporter onto the lil ufo model so that sentries can target it
        {
            if(ent.GetName().find("drone_hitbox")!=null) {
                local bot = Entities.FindByNameNearest("dronebot", ent.GetOrigin()-Vector(0,0,90), 110)
                if(IsPlayerAlive(bot)) bot.TakeDamageEx(params.inflictor, params.attacker, params.weapon, params.damage_force, params.damage_position, dmg, params.damage_type)
            }
        }

        else if(ent.GetClassname() == "tank_boss" && CurrentWaveNum > 4) {
            EntFireByHandle(ent,"RunScriptCode","Contact.tankModelFix(self)", 0.1, ent, ent)
        }

        // this block is for engi ufo weakspot
        else if ( ent.GetClassname() == "obj_dispenser" && ent.GetTeam()== 3 && params.attacker.GetTeam()== 2)
        {
            if(ent.GetName().find("ufo_weakspot")!=null || ent.GetName().find("ufo_headspot")!=null) {
                dmg = 0
                if( params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ) {
                    if(params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                        dmg = params.damage * 1.25
                        params.damage_type += Constants.FDmgType.DMG_ACID
                        params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                    }
                    else if(params.weapon.GetClassname().find("bow")!=null){
                        dmg = params.damage * 1.0
                        params.damage_type += Constants.FDmgType.DMG_ACID
                        params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                    }
                }

                else if( params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
                    if(params.damage_type & Constants.FDmgType.DMG_BULLET) {
                        dmg = params.damage * 2.5
                        params.damage_type += Constants.FDmgType.DMG_ACID
                        params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                    } else {
                        dmg = params.damage * 7
                        params.damage_type += Constants.FDmgType.DMG_ACID
                        params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                        ClientPrint(params.attacker, 4, "Bonus Damage: " + (dmg*3).tostring())
                    }
                }
                if(dmg!= 0){
                    Contact.engiTank.TakeDamageEx(params.inflictor, params.attacker, params.weapon, params.damage_force, params.damage_position, dmg, params.damage_type)
                    //ClientPrint(params.attacker, 4, "Bonus Damage: " + dmg.tostring())
                    if(debugzz) ClientPrint(params.attacker, 3, "bonus damage " + dmg.tostring())
                } else { params.damage = 0 }
            }
        }
    }

    OnGameEvent_player_death = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        player.SetGravity(1.0)
        if(player.GetTeam() == 3) NetProps.SetPropString(player, "m_iName", "")
    }

    Players = {}
    PlayerSpawn = function(player)
    {
        player.ValidateScriptScope()
        local userid = NetProps.GetPropString(player, "m_szNetworkIDString")
        Contact.Players[userid] <- player
        player.GetScriptScope().lastBeamDmg <- Time()
        if(CurrentWaveNum == 7) player.SetGravity(0.7)
    }
    OnGameEvent_player_spawn = function(params)
    {
        local player = GetPlayerFromUserID(params.userid);
        //if(debugzz) ClientPrint(null, 3, "player spawned " + player.tostring() + player.GetName())
        player.ValidateScriptScope()
        if (player != null && player.GetTeam() == 2)
        {
            PlayerSpawn(player)
        }
    }

    Objects ={}
    OnGameEvent_player_builtobject = function(params)
    {
        if(!params.rawin("userid")) return
        local player = GetPlayerFromUserID(params.userid);
        if (player==null || player.GetTeam() != 2) return
        Contact.Objects[params.index] <- EntIndexToHScript(params.index)
    }
    OnGameEvent_object_destroyed = function(params)
    {
        if(!params.rawin("userid")) return
        local player = GetPlayerFromUserID(params.userid);
        if (player==null || player.GetTeam() != 2) return
        Contact.Objects[params.index] <- null
    }
    OnGameEvent_object_detonated = function(params)
    {
        if(!params.rawin("userid")) return
        local player = GetPlayerFromUserID(params.userid);
        if (player==null || player.GetTeam() != 2) return
        Contact.Objects[params.index] <- null
    }

}

__CollectGameEventCallbacks(Contact)

//::MaxPlayers <- MaxClients().tointeger()
// spoof a player spawn when the wave initializes
for (local i = 1, player; i <= MaxClients().tointeger(); i++)
    if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2)
        Contact.PlayerSpawn(player)

//if(debugzz) ClientPrint(null, 3, "max players " + MaxPlayers)

///////////////////// Utility ///////////////////

::IsPlayerAlive <- function(player)
{
    // lifeState corresponds to the following values:
    // 0 - alive
    // 1 - dying (probably unused)
    // 2 - dead
    // 3 - respawnable (spectating)
    return player!= null && player.IsValid() && NetProps.GetPropInt(player, "m_lifeState") == 0;
}

::MASK_VISIBLE_AND_NPCS <-  33579137
::GetPlayerTarget <- function(player)
{
	local startPt = player.EyePosition();
	local endPt = startPt + player.EyeAngles().Forward().Scale(800);

	local m_trace = { start = startPt, end = endPt, ignore = player , mask = MASK_VISIBLE_AND_NPCS};
	TraceLineEx(m_trace);

	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)
		return null;

	if (m_trace.enthit.GetClassname() == "worldspawn")
		return null;

	return m_trace.enthit;
}

// probably doesn't count random crits
::IsPlayerCritBoosted <- function(player)
{ // excludes conds that wont happen during the mission like mannpower and wheel of fate
    if(player.GetClassname()!= "player" || !player.InCond) return false
    return player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_USER_BUFF) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_ON_KILL) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_RAGE_BUFF)
}

::IsPlayerMiniCritBoosted <- function(player)
{
    if(player.GetClassname()!= "player" || !player.InCond) return false
    return player.InCond(Constants.ETFCond.TF_COND_ENERGY_BUFF) || player.InCond(Constants.ETFCond.TF_COND_NOHEALINGDAMAGEBUFF) || player.InCond(Constants.ETFCond.TF_COND_OFFENSEBUFF)
}

::IsPlayerDisguisedSpy <- function(player)
{
    if(player.GetClassname()!= "player" || !IsPlayerAlive(player) || !(player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY)) return false
    if(player.InCond(Constants.ETFCond.TF_COND_STEALTHED) || player.InCond(Constants.ETFCond.TF_COND_FEIGN_DEATH)) return true
    if(player.GetDisguiseTeam() != 3) return false
    return player.InCond(Constants.ETFCond.TF_COND_DISGUISING) || player.InCond(Constants.ETFCond.TF_COND_DISGUISED)
}

::IsPlayerLOSForUFO <- function(me, player)
{
    local startPt = me.GetOrigin() + Vector(0,0,-150)
    local endPt = player.GetOrigin() + Vector(0,0,20)
    // run a trace from the gun to the position of the player
    // if the trace hits something that blocks los, that means the player is not los
    // only if the trace doesnt hit anything or it hits the player, return true

	local m_trace = { start = startPt, end = endPt, ignore = me , mask = 33570945};
	TraceLineEx(m_trace);
    //ClientPrint(null, 3, me.GetClassname() + " " + player.GetClassname() + " " + (m_trace.hit).tostring() + (m_trace.rawin("enthit")).tostring() )
    //if(m_trace.rawin("enthit")) ClientPrint(null, 3, "ent hit "+ m_trace.enthit.GetClassname() )

    if (!m_trace.hit || !m_trace.rawin("enthit") || m_trace.enthit == player ) //|| m_trace.enthit.GetClassname() == "worldspawn"
    {
        //ClientPrint(null, 3, "in LOS true" )
        return true;
    }
    //ClientPrint(null, 3, "in LOS false" )
    return false;
}
::IsPlayerLOSForbot <- function(me, player)
{
    local startPt = me.GetOrigin() + Vector(0,0,20)
    local endPt = player.GetOrigin() + Vector(0,0,20)
    // run a trace from the bot to the position of the player
    // if the trace hits something that blocks los, that means the player is not los
    // only if the trace doesnt hit anything or it hits the player, return true

	local m_trace = { start = startPt, end = endPt, ignore = me , mask = 33570945};
	TraceLineEx(m_trace);

    if (!m_trace.hit || !m_trace.rawin("enthit") || m_trace.enthit == player ) //|| m_trace.enthit.GetClassname() == "worldspawn"
    {
        return true;
    }
    return false;
}

::IsPlayerInOpenAir <- function(player)
{
    local startPt = player.GetOrigin()
    local endPt = player.GetOrigin() + Vector(0,0,1000)
    // run a trace from the gun to the position of the player
    // if the trace hits something that blocks los, that means the player is not los
    // only if the trace doesnt hit anything or it hits the player, return true

	local m_trace = { start = startPt, end = endPt, ignore = player , mask = 33570945};
	TraceLineEx(m_trace);

    if (!m_trace.hit || !m_trace.rawin("enthit") || m_trace.enthit == player )
    {
        return true;
    }
    return false;
}

/**
 * Returns the position on ground below from the entity's origin.
 * Modified from:
 * https://github.com/L4D2Scripters/vslib
 */
::GetLocationBelow <- function(player)
{
	local startPt = player.GetOrigin();
	local endPt = startPt + Vector(0, 0, -99999);
	//MASK_PLAYERSOLID_BRUSHONLY 81931
    //(CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE)
    //everything normally solid for player movement, except monsters (world+brush only)
	local m_trace = { start = startPt, end = endPt, ignore = player, mask = 81931 };
	TraceLineEx(m_trace);

	if (!m_trace.hit)
		return;

	return m_trace.pos;
}

::CreateGameTextUpper <- function(msg, hold, color, color2) {
    local textent = SpawnEntityFromTable("game_text", {
        "origin": "1984 1984 99999"
        "targetname": "upper_text"
        "message": msg
        "x": "-1"
        "y": "0.4"
        "spawnflags": "1"
        "effect": "2"
        "channel": "2"
        "color": color
        "color2": color2
        "fadein": "0.2"
        "fxtime": "0.3"
        "fadeout": "1"
        "holdtime": hold
    })
    EntFireByHandle(textent,"Display", null, 0.1, null, null)
    EntFireByHandle(textent,"kill", null, 6, null, null)
}
::CreateGameTextUpperFast <- function(msg, hold, color, color2) {
    local textent = SpawnEntityFromTable("game_text", {
        "origin": "1984 1984 99999"
        "targetname": "upper_text"
        "message": msg
        "x": "-1"
        "y": "0.4"
        "spawnflags": "1"
        "effect": "2"
        "channel": "2"
        "color": color
        "color2": color2
        "fadein": "0.1"
        "fxtime": "0.01"
        "fadeout": "1"
        "holdtime": hold
    })
    EntFireByHandle(textent,"Display", null, 0.1, null, null)
    EntFireByHandle(textent,"kill", null, 6, null, null)
}
::CreateGameTextSuperFast <- function(msg, hold, color, color2) {
    local textent = SpawnEntityFromTable("game_text", {
        "origin": "1984 1984 99999"
        "targetname": "upper_text"
        "message": msg
        "x": "-1"
        "y": "0.4"
        "spawnflags": "1"
        "effect": "2"
        "channel": "2"
        "color": color
        "color2": color2
        "fadein": "0.01"
        "fxtime": "0"
        "fadeout": "1"
        "holdtime": hold
    })
    EntFireByHandle(textent,"Display", null, 0.1, null, null)
    EntFireByHandle(textent,"kill", null, 6, null, null)
}
::CreateGameTextLower <- function(msg, hold, color) {
    local textent = SpawnEntityFromTable("game_text", {
        "origin": "1984 1984 99999"
        "targetname": "text_lower"
        "message": msg
        "x": "-1"
        "y": "0.45"
        "channel": "1"
        "spawnflags": "1"
        "color": color
        "fadein": "0.25"
        "fadeout": "1"
        "holdtime": hold
    })
    EntFireByHandle(textent,"Display", null, 0.1, null, null)
    EntFireByHandle(textent,"kill", null, 6, null, null)
}

Contact.ppInterface <- SpawnEntityFromTable("point_populator_interface" , {})
Contact.ChangeAttributes <- function(name) {
    EntFireByHandle(Contact.ppInterface,"ChangeBotAttributes",name,-1,null,null)
}

///////////////////// Drone Bot ///////////////////

Contact.takeDamageIfNearbyFix <- function() {
    local ent = Entities.FindByClassnameNearest("tf_projectile_arrow", self.GetOrigin() + Vector(0,0,110), 40)
    if(ent!=null && ent.GetOwner().GetTeam()== 2) {
        self.TakeDamage(60,2,ent.GetOwner())
        EntFireByHandle(ent, "kill", null, 0.1, null, null)
    }
    local ent = Entities.FindByClassnameNearest("tf_projectile_healing_bolt", self.GetOrigin() + Vector(0,0,110), 40)
    if(ent!=null && ent.GetOwner().GetTeam()== 2) {
        self.TakeDamage(20,2,ent.GetOwner())
        EntFireByHandle(ent, "kill", null, 0.1, null, null)
    }
    local ent = Entities.FindByClassnameNearest("tf_projectile_energy_ring", self.GetOrigin() + Vector(0,0,110), 50)
    if(ent!=null && ent.GetOwner().GetTeam()== 2) {
        self.TakeDamage(20,2,ent.GetOwner())
        EntFireByHandle(ent, "kill", null, 0.1, null, null)
    }
    local ent = Entities.FindByClassnameNearest("tf_weapon_flamethrower", self.GetOrigin() + Vector(0,0,110), 500)
    if(ent!=null && ent.GetOwner() && ent.GetOwner().GetTeam()== 2 && ent.GetOwner().GetActiveWeapon() == ent) {
        local buttons = NetProps.GetPropInt(ent.GetOwner(), "m_nButtons");
        if (buttons & Constants.FButtons.IN_ATTACK) {
            local hitEnt = GetPlayerTarget(ent.GetOwner())
            if(hitEnt != null && hitEnt.GetName().find("drone")!=null) {
                local dist = (hitEnt.GetOrigin() - ent.GetOwner().GetOrigin()).Length()
                local dmg = 2 + 5*((500-dist)/500)
                hitEnt.TakeDamage(dmg,2,ent.GetOwner())
            }
        }
    }
    local ent = Entities.FindByClassnameNearest("tf_weapon_rocketlauncher_fireball", self.GetOrigin() + Vector(0,0,110), 500)
    if(ent!=null && ent.GetOwner().GetTeam()== 2 && ent.GetOwner().GetActiveWeapon() == ent) {
        local buttons = NetProps.GetPropInt(ent.GetOwner(), "m_nButtons");
        if (buttons & Constants.FButtons.IN_ATTACK) {
            local hitEnt = GetPlayerTarget(ent.GetOwner())
            if(hitEnt != null && hitEnt.GetName().find("drone")!=null) {
                local dist = (hitEnt.GetOrigin() - ent.GetOwner().GetOrigin()).Length()
                local dmg = 5 + 5*((500-dist)/500)
                hitEnt.TakeDamage(dmg,2,ent.GetOwner())
            }
        }
    }
    return 0.8
}

PopExt.AddRobotTag("drone", {
    OnSpawn = function(bot, tag) {
        EntFireByHandle(bot,"$HideToAll",null,0,bot,bot)
        EntFireByHandle(bot,"$HideToAll",null,0.2,bot,bot)
        EntFireByHandle(bot,"$HideToAll",null,0.5,bot,bot)
        NetProps.SetPropString(bot, "m_iName", "dronebot")
        bot.KeyValueFromString("rendermode", "10")
        bot.SetGravity(0.6)

        bot.ValidateScriptScope()
        bot.GetScriptScope().PlayerThinkTable.takeDamageIfNearbyFix <- Contact.takeDamageIfNearbyFix
    },

    OnDeath = function(bot, params) {
        EntFireByHandle(bot,"$ShowToAll",null,0,bot,bot)
       NetProps.SetPropString(bot, "m_iName", "")
       delete bot.GetScriptScope().PlayerThinkTable.takeDamageIfNearbyFix
       bot.KeyValueFromString("rendermode", "1")
       bot.SetGravity(1.0)
    },
})

// PrintNuke = function(obj) {
//     ClientPrint(null, 3, "fucking kill me") //debuging
//     ClientPrint(null, 4, "Nuke HP: " + obj.GetHealth().tostring())
// }


///////////////////// UFO Blimp Tank ///////////////////
Contact.SetUfoTrigger <- function(parentTank, UFOrange) {
    parentTank.ValidateScriptScope()
    parentTank.GetScriptScope().TankThinkTable.UfoTriggerThink <- Contact.UfoTriggerThink
    parentTank.GetScriptScope().triggerdelay <- Time() + 1
    parentTank.GetScriptScope().laserRange <- UFOrange
}

Contact.UfoTriggerThink <- function() {

    if(self.GetScriptScope().triggerdelay > Time()) return -1

    local closestEnt = null
    local closestDist = 99999
    local UFOrange = self.GetScriptScope().laserRange

    //TODO: ignore entities that are above a certain point

    for (local entity; entity = Entities.FindByClassnameWithin(entity, "obj_sentrygun", self.GetOrigin()+Vector(0,0,-100), UFOrange);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity) && IsPlayerLOSForUFO(self,entity)) {
            local dist = (entity.GetOrigin()-self.GetOrigin()).Length()
            if(dist < closestDist) {
                closestDist = dist
                closestEnt = entity
            }
        }
    }
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "player", self.GetOrigin()+Vector(0,0,-100), UFOrange);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity) && !IsPlayerDisguisedSpy(entity) && IsPlayerLOSForUFO(self,entity) && entity.GetOrigin().z < self.GetOrigin().z  - 40) {

            local dist = (entity.GetOrigin()-self.GetOrigin()).Length()
            if(dist < closestDist) {
                closestDist = dist
                closestEnt = entity
            }
        }
    }
    if(closestEnt != null) {
        EntFireByHandle(self, "$FireUser5", null, 0, closestEnt, closestEnt)
    }
    else {
        local cannon = Entities.FindByNameNearest("cannon_model", Vector(901, -1505, 1100), 1000)
        EntFireByHandle(self, "$FireUser5", null, 0, cannon, cannon)
    }

    self.GetScriptScope().triggerdelay = Time() + 0.4
    return 0.4
}

PopExt.AddRobotTag("tutorial", {

    OnSpawn = function(bot, tag) {
        bot.ValidateScriptScope()
        local scope = bot.GetScriptScope()
        bot.SetGravity(1.0)
        local ent = FindByName(null, "ufo_phys_a*")
        local location = ent.GetOrigin() + Vector(0, 0, 50)
        location.z = Min(location.z,200)
        if(debugzz) ClientPrint(null,3,"moving tutorial bot to ufo " + ent.tostring())


        bot.Teleport(true, location, false, QAngle(0,0,0), false, Vector(0,0,0))
    },

    OnDeath = function(bot, params) {
       bot.SetGravity(1.0)
    },
})

///////////////////// Engi Lasers ///////////////////
Contact.BaseBoss <- null //"controlpanel_baseboss"

Contact.SetEngiUfoTrigger <- function(dummy) {
    if(debugzz) ClientPrint(null,3,"SetEngiUfoTrigger registered " + dummy.tostring())
    dummy.ValidateScriptScope()
    dummy.GetScriptScope().triggerdelay <- Time() + 1
    //dummy.GetScriptScope().PlayerThinkTable.EngiUfoTriggerThink <- Contact.EngiUfoTriggerThink
    dummy.GetScriptScope().TankThinkTable.EngiUfoTriggerThink <- Contact.EngiUfoTriggerThink
    EntFire("laser_firer1_engi", "$setowner", "!activator", 0, Contact.engiDrone)
    EntFire("laser_firer2_engi", "$setowner", "!activator", 0, Contact.engiDrone)
    EntFire("laser_firer3_engi", "$setowner", "!activator", 0, Contact.engiDrone)
    EntFire("laser_firer4_engi", "$setowner", "!activator", 0, Contact.engiDrone)

}

Contact.EngiUfoTriggerThink <- function() {
    local engiufo = self //Contact.engiDrone
    if(engiufo == null) return
    if(self.GetScriptScope().triggerdelay > Time()) return -1

    local closestEnt = null
    local closestDist = 99999

    //for (local entity; entity = Entities.FindByClassnameWithin(entity, "player", self.GetOrigin()+Vector(0,0,50), 3000);)
    foreach (k, entity in Contact.Players)
    {
        if(entity!= null && IsPlayerAlive(entity) && entity.GetTeam() == 2 && !IsPlayerDisguisedSpy(entity) ) { // && IsPlayerLOSForUFO(self,entity)
            local shipO = engiufo.GetOrigin()
            local playerO = entity.GetOrigin()
            local higher = engiufo.GetOrigin().z > entity.GetOrigin().z + 80
            shipO.z = 0
            playerO.z = 0
            local dist = (shipO-playerO).Length()
            //if(debugzz) ClientPrint(null, 3, entity.GetName() + " ishigher " + higher + " dist " + dist)
            if((higher || (dist < 2000 && dist > 300)) && dist < closestDist) {
                closestDist = dist
                closestEnt = entity
            }
        }
    }
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "obj_sentrygun", self.GetOrigin(), 2000);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity)) {
            local dist = (entity.GetOrigin()-self.GetOrigin()).Length()
            if(dist < closestDist) {
                closestDist = dist
                closestEnt = entity
            }
        }
    }
    if(closestEnt != null) {
        EntFireByHandle(engiufo, "$FireUser5", null, 0, closestEnt, closestEnt)
        EntFireByHandle(engiufo, "$FireUser6", null, 0, closestEnt, closestEnt)
    }
    else {
        EntFireByHandle(engiufo, "$FireUser5", null, 0, Contact.BaseBoss, Contact.BaseBoss)
        EntFireByHandle(engiufo, "$FireUser6", null, 0, Contact.BaseBoss, Contact.BaseBoss)
    }

    self.GetScriptScope().triggerdelay = Time() + 0.4
    return 0.1
}

///////////////////// Penultimate Wave ///////////////////

Contact.teletrooperThink <- function() {
    local scope = self.GetScriptScope()
    if(!scope.rawin("setupTime")) scope.setupTime <- Time() + 5
    if(Time() > scope.setupTime) {
        if(scope.rawin("newgrav"))
            self.SetGravity(scope.newGrav)
        else
            self.SetGravity(1.0)
        EntFireByHandle(self, "EnableDamageForces", null, 0.0, null, null)
        delete scope.PlayerThinkTable.teletrooperThink
        return
    }
    return -1
}

//should be the origin of the tanks -250 z
Contact.spawnLocs <- {
    "a": Vector(1178, 1239, 950),
    "b": Vector(-2224 1688 950),
    "c": Vector(-651, 938, 1050)
}
Contact.dedUfos <- {}
Contact.ufoModelHandles <- {}

Contact.wave7WinCondition <- null
PopExt.AddRobotTag("w7wincondition", {
    // Called when the robot is spawned
    OnSpawn = function(bot, tag) {
        if(debugzz) {ClientPrint(null, 3, "win condtion spawned")}
        Contact.wave7WinCondition <- bot
        bot.ValidateScriptScope()
        bot.GetScriptScope().teleTimer <- Time() + 0.3
        bot.GetScriptScope().PlayerThinkTable.TelePuppetThink <- Contact.TelePuppetThink
    }
    OnDeath = function(bot, params) {
        if(debugzz) {ClientPrint(null, 3, "win condtion has somehow died")}
        if(debugzz) {ClientPrint(null, 4, "win condtion has somehow died")}
    }
})
Contact.LoseWave7 <- function() {
    if(debugzz) ClientPrint(null,3,"wave " + CurrentWaveNum.tostring() + " cores: " + Contact.numCores.tostring() + " win " + IsPlayerAlive(Contact.wave7WinCondition).tostring())
    if(CurrentWaveNum == 7 && Contact.numCores == 5)
    {
        return;
    } else if(Contact.numCores == 3) {
        return;
    }
    if(CurrentWaveNum == 7 && Contact.numCores != 5 && IsPlayerAlive(Contact.wave7WinCondition)) {
        //EntFire("boss_deploy_relay", "Trigger")
        if(debugzz) ClientPrint(null,3,"wave " + CurrentWaveNum.tostring() + " cores: " + Contact.numCores.tostring())
        EntFire("boss_deploy_relay", "Trigger", null, 0.3, null)
    }
    else if(CurrentWaveNum == 6 && Contact.numCores != 3 && IsPlayerAlive(Contact.wave7WinCondition)) {
        //EntFire("boss_deploy_relay", "Trigger")
        if(debugzz) ClientPrint(null,3,"wave " + CurrentWaveNum.tostring() + " cores: " + Contact.numCores.tostring())
        EntFire("boss_deploy_relay", "Trigger", null, 0.3, null)

    } else {
        return
    }
    if(debugzz) ClientPrint(null,3,"Triggering bomb deploy. loser")
    EntFire("panel_splode", "Start", null, 0.1, null)
    EntFire("tf_gamerules", "PlayVO", "misc\rd_robot_explosion01.wav", 0.1, null)

    // if(debugzz && IsPlayerAlive(Contact.wave7WinCondition)) ClientPrint(null,3,"Triggering bomb deploy. loser")
    // if(IsPlayerAlive(Contact.wave7WinCondition)) EntFire("boss_deploy_relay", "Trigger", null, 0.3, null)
}
Contact.WinWave7 <- function() {
    if(debugzz) ClientPrint(null,3,"Killing wave7WinCondition")
    EntFireByHandle(Contact.wave7WinCondition, "$Suicide", null, 0, null, null)
}
PopExt.AddRobotTag("ufo_a", {
    // Called when the robot is spawned
    OnSpawn = function(bot, tag) {
        local ufoId = "a"
        bot.ValidateScriptScope()
        bot.GetScriptScope().setupTime <- (Time() + 2)
        bot.AddCondEx(Constants.ETFCond.TF_COND_TELEPORTED, 0.1, bot)
        if(!(ufoId in Contact.dedUfos)) {
            if(bot.IsMiniBoss()) bot.Teleport(true, Contact.spawnLocs[ufoId]+Vector(0,0,-50), false, QAngle(0,0,0), false, Vector(0,0,0))
            else bot.Teleport(true, Contact.spawnLocs[ufoId], false, QAngle(0,0,0), false, Vector(0,0,0))
            bot.GetScriptScope().PlayerThinkTable.teletrooperThink <- Contact.teletrooperThink
            bot.SetGravity(0.3)
            EntFireByHandle(bot, "DisableDamageForces", null, 0.0, null, null)
        } else {
            EntFireByHandle(bot, "$AddCond", "71 2", 0, null, null)
        }
    },
    OnDeath= function(bot, tag) {
        bot.SetGravity(1.0)
    }
})
PopExt.AddRobotTag("ufo_b", {
    OnSpawn = function(bot, tag) {
        local ufoId = "b"
        bot.ValidateScriptScope()
        bot.GetScriptScope().setupTime <- (Time() + 2)
        bot.AddCondEx(Constants.ETFCond.TF_COND_TELEPORTED, 0.1, bot)
        if(!(ufoId in Contact.dedUfos)) {
            if(bot.IsMiniBoss()) bot.Teleport(true, Contact.spawnLocs[ufoId]+Vector(0,0,-50), false, QAngle(0,0,0), false, Vector(0,0,0))
            else bot.Teleport(true, Contact.spawnLocs[ufoId], false, QAngle(0,0,0), false, Vector(0,0,0))
            bot.GetScriptScope().PlayerThinkTable.teletrooperThink <- Contact.teletrooperThink
            bot.SetGravity(0.3)
            EntFireByHandle(bot, "DisableDamageForces", null, 0.0, null, null)
        } else {
            EntFireByHandle(bot, "$AddCond", "71 2", 0, null, null)
        }
    },
    OnDeath= function(bot, tag) {
        bot.SetGravity(1.0)
    }
})
PopExt.AddRobotTag("ufo_c", {
    OnSpawn = function(bot, tag) {
        local ufoId = "c"
        bot.ValidateScriptScope()
        bot.GetScriptScope().setupTime <- (Time() + 2)
        bot.AddCondEx(Constants.ETFCond.TF_COND_TELEPORTED, 0.1, bot)
        if(!(ufoId in Contact.dedUfos)) {
            if(bot.IsMiniBoss()) bot.Teleport(true, Contact.spawnLocs[ufoId]+Vector(0,0,-50), false, QAngle(0,0,0), false, Vector(0,0,0))
            else bot.Teleport(true, Contact.spawnLocs[ufoId], false, QAngle(0,0,0), false, Vector(0,0,0))
            bot.GetScriptScope().PlayerThinkTable.teletrooperThink <- Contact.teletrooperThink
            bot.SetGravity(0.3)
            EntFireByHandle(bot, "DisableDamageForces", null, 0.0, null, null)
        } else {
            EntFireByHandle(bot, "$AddCond", "71 2", 0, null, null)
        }
    },
    OnDeath= function(bot, tag) {
        bot.SetGravity(1.0)
    }
})

Contact.TelePuppetThink <- function() {
    if(self.GetScriptScope().teleTimer > Time()) return
    self.GetLocomotionInterface().ClearStuckStatus("")
    self.Teleport(true, Vector(1982, 3108, 700), false, QAngle(0,0,0), false, Vector(0,0,0))
}

// OnSpawn, OnDeath, OnTakeDamage, OnTakeDamagePost, OnDealDamage, OnDealDamagePost
Contact.cannonPuppet <- null
PopExt.AddRobotTag("cannon_puppet", {
    OnSpawn = function(bot, tag) {
        Contact.cannonPuppet <- bot
        bot.ValidateScriptScope()
        bot.GetScriptScope().teleTimer <- Time() + 0.3
        bot.GetScriptScope().PlayerThinkTable.TelePuppetThink <- Contact.TelePuppetThink
        bot.GetScriptScope().curThreshold <- 0.5
    },
    OnDeath = function(bot, params) {
        delete bot.GetScriptScope().PlayerThinkTable.TelePuppetThink
        delete Contact.cannonPuppet
    },
})

Contact.numCores <- 0
// 25 50 75 99
Contact.ChargeCannon <- function() {
    Contact.numCores += 1
    if(Contact.numCores == 0) {
        CreateGameTextSuperFast("////CANNON CHARGE AT 10%////", 2, "255 255 0", "255 0 0")
        ClientPrint(null, 3, "\x07FF3F3F POWERCORE DEPOSITED >>> RED LASER CANNON CHARGING" )
        Contact.WinWave7()
        return
    }
    //Contact.cannonPuppet.SetHealth(Min(20000,Contact.cannonPuppet.GetHealth()+8000))
    if(Contact.numCores > 3) { //set this to 3 when engi is done
        Contact.cannonPuppet.SetHealth(Min(20000,Contact.cannonPuppet.GetHealth()+8000))
        EntFire("unlock_button", "trigger", null, 0.4)
        //ClientPrint(null, 4, "CANNON OVERCHARGED. FIRE AT WILL")
        CreateGameTextUpperFast("////CANNON OVERCHARGED. FIRE AT WILL////", 2, "255 255 0", "255 0 0")
        ClientPrint(null, 3, "\x07FF3F3F CANNON OVERCHARGED. PREPARE TO FIRE. HIT PANEL TO TRIGGER")
    } else {
        Contact.cannonPuppet.SetHealth(Min(20000,Contact.cannonPuppet.GetHealth()+2500))
        //ClientPrint(null, 4, "CORE DEPOSITED. CANNON CHARGE AT " + (Contact.numCores*33).tostring() + "%" )
        CreateGameTextSuperFast("////CANNON CHARGE AT " + (Contact.numCores*33).tostring() + "%////", 2, "255 255 0", "255 0 0")
        ClientPrint(null, 3, "\x07FF3F3F CANNON CHARGE AT " + (Contact.numCores*33).tostring() + "%" )
        //if(Contact.numCores == 3) EntFireByHandle(Contact.wave7WinCondition, "kill", null, 1, null, null)
    }
    if(Contact.numCores == 3) Contact.WinWave7()
}

Contact.spyBoss <- null
Contact.spyGoinUpCheck <- function() {
    if(IsPlayerInOpenAir(Contact.spyBoss)) {
        Contact.ChangeAttributes("goinUp")
    } else {
        Contact.ChangeAttributes("spymelee")
    }
}
Contact.playerGoinUp <- function(bot) {
    if(debugzz) ClientPrint(null, 3, "going up")
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "player", bot.GetOrigin()+Vector(0,0,20), 300);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity) && IsPlayerLOSForbot(bot,entity)) { //&& IsPlayerLOSForUFO(self,entity)
            entity.ApplyAbsVelocityImpulse(Vector(0,0,2000))
        }
    }
}
Contact.playerFlashBang <- function(bot) {
    if(debugzz) ClientPrint(null, 3, "flash bang")
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "player", bot.GetOrigin()+Vector(0,0,20), 700);)
    {
        if(!IsPlayerLOSForbot(bot,entity) || entity.GetTeam() != 2 || !IsPlayerAlive(entity)) continue

        local playerBack = entity.EyePosition() + (entity.EyeAngles().Forward() * -10)
        local playerFront = entity.EyePosition() + (entity.EyeAngles().Forward() * 10)

        //if playerback is closer to spy than player front, that means player is relatively rotated facing spy
        local towardsBack = playerBack - bot.GetOrigin()
        local towardsFront = playerFront - bot.GetOrigin()

        if(towardsBack.Length() < towardsFront.Length()) continue

        EntFire("spywhiteout", "fade", null, 0, entity)
        entity.AddCondEx(Constants.ETFCond.TF_COND_MARKEDFORDEATH_SILENT, 8, bot)
    }
}

PopExt.AddRobotTag("spyboss", {
    OnSpawn = function(bot, tag) {
        Contact.spyBoss = bot
        bot.ValidateScriptScope()
        local scope = bot.GetScriptScope()
        for (local wearable = bot.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
        {
            if (wearable.GetClassname() != "tf_wearable"||wearable.GetModelName().find("chicago_overcoat.mdl")==null)
                continue;
            EntFireByHandle(wearable, "SetLightingOrigin", "manninblacklightingref", 0, null, null)
            //EntFireByHandle(wearable, "$SetKey$renderfx", "15", 0, null, null)
            EntFireByHandle(wearable, "$SetKey$renderamt", "245", 0, null, null)
            EntFireByHandle(wearable, "$SetKey$rendermode", "1", 0, null, null)
        }
    }
})

Contact.medBoss <- null
PopExt.AddRobotTag("medicboss", {
    // Called when the robot is spawned
    OnSpawn = function(bot, tag) {
        Contact.medBoss = bot
        bot.ValidateScriptScope()
        local scope = bot.GetScriptScope()
    }
})
Contact.HealMedBoss <- function() {
    Contact.medBoss.SetHealth(Min(22000,Contact.medBoss.GetHealth()+40))
}

redRespawn <- Entities.FindByName(null,"rs_red")
EntityOutputs.AddOutput(redRespawn, "OnStartTouch", "!activator", "RunScriptCode", "self.AddCond(130)", 0.1, -1)
EntityOutputs.AddOutput(redRespawn, "OnEndTouch", "!activator", "RunScriptCode", "self.RemoveCond(130)", 0.1, -1)

Contact.AttachSuccParticle <- function(player)
{
    // if(debugzz) ClientPrint(null, 3, "AttachSuccParticle " + player.tostring())
    local particle = SpawnEntityFromTable("info_particle_system", {
        "targetname":   "succ_beam",
        "effect_name":  "medicgun_beam_blue",
        "origin":       player.GetOrigin() + Vector(0,0,50),
        "cpoint1":      "succ_particle",
        "start_active": "1"
    })
    EntFireByHandle(particle, "SetParent", "!activator", 0, player, player)
    EntFireByHandle(particle, "kill",null,1, null, null)
}

Contact.NavTest <- function() {
    for (local ent; ent = Entities.FindByClassname(ent, "func_nav_blocker"); )
    {
        EntFireByHandle(ent, "disable", null, 0, null, null)
    }
    for (local ent; ent = Entities.FindByClassname(ent, "func_nav_avoid"); )
    {
        EntFireByHandle(ent, "disable", null, 0, null, null)
    }
    for (local ent; ent = Entities.FindByClassname(ent, "func_nav_prefer"); )
    {
        EntFireByHandle(ent, "disable", null, 0, null, null)
    }
    //EntFire("route_r_prefer", "Enable", null, 0.3)
    EntFire("nav_reset", "recomputeblockers", null, 1, null)
    if(debugzz) ClientPrint(null, 4, "reset and clear nav")
}

::shootThink <- function() {
    local vel = self.GetForwardVector()*200
    vel.z = 0
    local lilVel = self.GetForwardVector()
    lilVel.z = 0
    lilVel.Norm()
    self.SetAbsOrigin(self.GetOrigin() + (vel*FrameTime()) + lilVel)
    return -1
}


///////////////////// Final Wave ///////////////////

// for ringmarker1, which is the parent for the env_beam
::ringRegister <- function(beam) {
    if(debugzz) ClientPrint(null,3,"ringregister " + beam.GetName())
    local arr = split(beam.GetName() , "t")
    local beamId = arr[arr.len()-1]

    local marker = null

    for (local entity; entity = Entities.FindByNameWithin(entity,"ringmarkerone*", beam.GetOrigin(), 30);)
    {
        //if(debugzz) ClientPrint(null, 3, entity.GetName().tostring() )
        local ringArr = split(entity.GetName() , "e")
        local ringId = ringArr[ringArr.len()-1]

        if(beamId == ringId) {
            marker = entity
            break
        }
    }

    if(marker == null) {
        if(debugzz) ClientPrint(null, 3, "something has gone wrong. no marker found")
        return
    }
    beam.ValidateScriptScope()
    beam.GetScriptScope().marker <- marker
    AddThinkToEnt(beam, "ringThink")
}
::tauntBeam <- function(player) {
    local i = RandomInt(0,6)
    switch(i){
        case 0:
            ClientPrint(player, 3, "Ironstar: How'd the power of math and hot plasma taste?")
            break
        case 1:
            ClientPrint(player, 3, "Ironstar: Y'all ever heard of jumping and ducking?")
            break
        case 2:
            ClientPrint(player, 3, "Ironstar: Sorry about that pardner.")
            break
        case 3:
            ClientPrint(player, 3, "Ironstar: How's about you try dodging next time.")
            break
        case 4:
            ClientPrint(player, 3, "Ironstar: Hm, something smells like burnt bacon.")
            break
        // case 5:
        //     ClientPrint(player, 3, "Ironstar: Tougher than riding a mechanical bull, aint it?")
        //     break
        default:
            break
    }
}


::DoesPlayerIntersectBeam <- function(player, beam1, beam2) {
    local o = player.GetOrigin()
    local b1 = beam1.GetOrigin()
    local b2 = beam2.GetOrigin()
    //lets do the z check first, because it is cheaper
    local eye_z = player.EyePosition().z

    if(!(b1.z > (o.z-15) && b1.z < (o.z+110))) {
        //if(debugzz) ClientPrint(null,3,"player o " + o.tostring() + " b1 " + b1.tostring() + " b2 " + b2.tostring())
        return false
    }

    local r = 25 // size of box to check is 2r. fyi player hull is 32 wide
    //for simplicity, i will set all the z to be 0
    //points are starting from bottom left, counter-clockwise
    local p1 = Vector(o.x-r, o.y-r, 0)
    local p2 = Vector(o.x+r, o.y-r, 0)
    local p3 = Vector(o.x+r, o.y+r, 0)
    local p4 = Vector(o.x-r, o.y+r, 0)
    // if one algorithm doesn't work...
    if(altintersect(b1, b2, p1, p2)|| altintersect(b1, b2, p2, p3) || altintersect(b1, b2, p3, p4)|| altintersect(b1, b2, p4, p1)){
        //if(debugzz) ClientPrint(null,3,"true")
        return true
    }
    // use more algorithm
    if(doIntersect(b1, b2, p1, p2) || doIntersect(b1, b2, p2, p3) || doIntersect(b1, b2, p3, p4)|| doIntersect(b1, b2, p4, p1)) {
        //if(debugzz) ClientPrint(null,3,"true")
        return true
    }
    //if(debugzz) ClientPrint(null,3,"false")

    return false
}

::ccw <- function(A,B,C){
    return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)
}

// Return true if line segments AB and CD intersect
::altintersect <- function(A,B,C,D){
    return ccw(A,C,D) != ccw(B,C,D) && ccw(A,B,C) != ccw(A,B,D)
}

// https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
// Given three collinear points p, q, r, the function checks if point q lies on line segment 'pr'
::onSegment <- function( p,  q,  r)
{
    if (q.x <= Max(p.x, r.x) && q.x >= Min(p.x, r.x) && q.y <= Max(p.y, r.y) && q.y >= Min(p.y, r.y))
        return true;
    return false;
}
::Max <- function(x, y) {
    if (x > y) {return x}
    else {return y}
}
::Min <- function(x, y) {
    if (y > x) {return x}
    else {return y}
}
// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are collinear
// 1 --> Clockwise
// 2 --> Counterclockwise
::orientation <- function( p, q, r)
{
    // See https://www.geeksforgeeks.org/orientation-3-ordered-points/
    // for details of below formula.
    local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

    if (val == 0) {return 0} // collinear

    return (val > 0)? 1: 2; // clock or counterclock wise
}
// The main function that returns true if line segment 'p1q1' and 'p2q2' intersect.
::doIntersect <- function( p1, q1, p2, q2)
{
    // Find the four orientations needed for general and
    // special cases
    local o1 = orientation(p1, q1, p2);
    local o2 = orientation(p1, q1, q2);
    local o3 = orientation(p2, q2, p1);
    local o4 = orientation(p2, q2, q1);

    // General case
    if (o1 != o2 && o3 != o4)
        return true;

    // Special Cases
    // p1, q1 and p2 are collinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;
    // p1, q1 and q2 are collinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;
    // p2, q2 and p1 are collinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;
    // p2, q2 and q1 are collinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false; // Doesn't fall in any of the above cases
}

::beamRegister <- function(beam1, nameOfBeamPoint2) {
    beam1.ValidateScriptScope()
    local beampoint = Entities.FindByName(null, nameOfBeamPoint2)

    if(beampoint == null) {
        if(debugzz) ClientPrint(null, 3, "something has gone wrong. no 2nd beam point found")
        return
    }
    if(debugzz) ClientPrint(null, 3, beam1.GetName() + " registering " + beampoint.GetName())
    beam1.GetScriptScope().marker <- beampoint
    AddThinkToEnt(self, "beamThink")
}
::beamThink <- function() {
    /*
        Ideally, i would look for an intersection between a circle and a line segment, where the beam is the
        line segment, and the circle is a circle around the player.
        This however is kinda complicated, math-wise

        Instead I will draw a square box around the player and check if any of the 4 lines that make up the box
        intersect with the beam line segment. Slightly less accurate but much simpler.
    */
   local beam1 = self
   local beam2 = self.GetScriptScope().marker
   foreach (k, entity in Contact.Players) {
        if (entity != null && IsPlayerAlive(entity) && entity.GetTeam() == 2 ) { // && IsPlayerLOSForbot(self,entity)
            if(!(entity.GetScriptScope().rawin("lastBeamDmg")) || Time() > entity.GetScriptScope().lastBeamDmg + 0.1) {
                if(DoesPlayerIntersectBeam(entity, beam1, beam2)) {
                    entity.ApplyAbsVelocityImpulse(Vector(0,0,120))
                    entity.TakeDamageCustom(entity, Contact.engiDrone,null, Vector(0,0,0), Vector(0,0,0), 100, 8, Constants.ETFDmgCustom.TF_DMG_CUSTOM_BURNING)
                    if(entity.GetHealth() < 50) tauntBeam(entity)
                    entity.GetScriptScope().lastBeamDmg <- Time()
                }
            }
        }
    }
    return -1
}
::ringThink <- function() {
    local marker = self.GetScriptScope().marker
    local radius = (marker.GetOrigin()-self.GetOrigin()).Length()
    local ring_z = self.GetOrigin().z
    foreach (k, entity in Contact.Players) {
        if (entity != null && IsPlayerAlive(entity) && entity.GetTeam() == 2  ) { //&& IsPlayerLOSForbot(self,entity)
            local ent_z = entity.GetOrigin().z
            local eye_z = entity.EyePosition().z
            local dist = ((entity.GetOrigin() + Vector(0,0,30)) - self.GetOrigin()).Length()
            if(ring_z > (ent_z-5) && ring_z < eye_z + 40) {
                if(fabs(dist - radius) < 3){

                    if(!(entity.GetScriptScope().rawin("lastBeamDmg")) || Time() > entity.GetScriptScope().lastBeamDmg + 0.05)
                    {
                        entity.TakeDamageCustom(entity, Contact.engiDrone,null, Vector(0,0,0), Vector(0,0,0), 85, 8, Constants.ETFDmgCustom.TF_DMG_CUSTOM_BURNING)
                        entity.ApplyAbsVelocityImpulse(Vector(0,0,70))
                        if(entity.GetHealth() < 50 && CurrentWaveNum==7) tauntBeam(entity)
                        entity.GetScriptScope().lastBeamDmg <- Time()
                    }
                }
            }
        }
    }
    foreach (k,entity in Contact.Objects) {
        if (IsPlayerAlive(entity) && entity.GetTeam() == 2 &&  IsPlayerLOSForbot(self,entity)) {
            entity.ValidateScriptScope()
            local ent_z = entity.GetOrigin().z
            local eye_z = entity.GetOrigin().z + 50
            local dist = ((entity.GetOrigin() + Vector(0,0,30)) - self.GetOrigin()).Length()
            if(ring_z > ent_z && ring_z < eye_z + 2) {
                if(fabs(dist - radius) < 4) {
                    if(!(entity.GetScriptScope().rawin("lastBeamDmg")) ||Time() > entity.GetScriptScope().lastBeamDmg + 0.2)
                    {
                        entity.TakeDamageEx(entity, Contact.engiDrone, Contact.engiDrone.GetActiveWeapon(), Vector(0,0,0), Vector(0,0,0), 100, 1024)
                        entity.GetScriptScope().lastBeamDmg <- Time()
                    }
                }
            }
        }
    }
    return -1
}

Contact.engiTank <- null
// Contact.SetupEngiTank <- function(tank)
// {
//     Contact.engiTank = tank
//     //tank.SetSolid(2)
//     Contact.BaseBoss = Entities.FindByName(null, "controlpanel_baseboss")
//     EntFireByHandle(tank, "RunScriptCode", "Contact.SetupEngiTank2(Contact.engiTank)",6, tank,tank)
// }
// Contact.SetupEngiTank2 <- function(tank)
// {
//     if(debugzz) ClientPrint(null,3,"setup tank")
//     // tank.SetAbsOrigin(Contact.engiDrone.GetOrigin() + Vector(0, 0, 70))
//     // tank.SetAbsAngles(QAngle(0,0,0))

//     local ufo = Entities.FindByName(null, "engi_ufo")
//     // local child = tank
//     // local parent = ufo //Contact.engiDrone

//     // SetPropEntity(child, "m_hMovePeer", parent.FirstMoveChild())
// 	// SetPropEntity(parent, "m_hMoveChild", child)
// 	// SetPropEntity(child, "m_hMoveParent", parent)

//     // EntFireByHandle(tank, "SetParent", "!activator", 0.0, parent, parent)

//     EntFireByHandle(tank, "$TeleportToEntity", "!activator", 0, ufo, ufo)
//     EntFireByHandle(tank, "SetParent", "!activator", 0.1, ufo, ufo)
// }

Contact.tanks <- {}
Contact.tankModelFix <- function(tank) {
    local model = ""
    if(CurrentWaveNum == 7){
        model = "models/mvm_ufo/ufo_core.mdl"
    } else {
        model = "models/props_invasion/props_alien/saucer.mdl"
    }
    local hpPercent = ((1.0*tank.GetHealth()) / tank.GetMaxHealth())
    local curThreshold = 1.0
    if(Contact.tanks.rawin(tank.GetName())) curThreshold = Contact.tanks[tank.GetName()]
    // if(debugzz) ClientPrint(null, 3 ,"hppercent" + hpPercent.tostring() + " wait threshold " + curThreshold)
    if(hpPercent <= curThreshold || tank.GetModelName()!= model) {
        if(debugzz) ClientPrint(null, 3 ,"settingtankmodel for wave" + CurrentWaveNum.tostring())
        tank.SetModelSimple(model)
        Contact.tanks[tank.GetName()] <- curThreshold - 0.25
    }
}

PopExt.AddTankName("engiufotank*", {
    // Called when the tank is spawned
    OnSpawn = function(tank, name) {
        Contact.engiTank = tank
        if(debugzz) ClientPrint(null,3,"setup tank")
        local ufo = Entities.FindByName(null, "engi_ufo")
        if(debugzz) ClientPrint(null,3,"engi_ufo" + ufo.tostring())

        local angles = ufo.GetAbsAngles()
        local anglestring = angles.x + " " + angles.y + " " + angles.z

        EntFireByHandle(tank, "$SetKey$rendermode", "10", 1, tank, tank)
        EntFireByHandle(tank, "$SetKey$renderamt", "0", 1, tank, tank)
        EntFireByHandle(tank,"$SetCollisionFilter", "filter_is_red", 1, tank,tank)
        EntFireByHandle(tank, "$SetLocalAngles", anglestring, 1, tank, tank)
        EntFireByHandle(tank, "$TeleportToEntity", "!activator", 1, ufo, ufo)
        EntFireByHandle(tank, "SetParent", "!activator", 1.01, ufo, ufo)
        EntFireByHandle(tank, "RunScriptCode", "Contact.SetEngiUfoTrigger(self)", 1,null,null)
    },

    OnDeath = function(tank, params) {
        Contact.KillEngiDrone()
    }
})

Contact.EngiDroneThink <- function() {
    local loco = Contact.engiDrone.GetLocomotionInterface()
    if(loco.IsStuck()) {
        loco.DriveTo(Contact.engiDrone.GetOrigin() + Vector(0,0,100))
        Contact.engiDrone.ApplyAbsVelocityImpulse(Vector(0,0,400))
        loco.ClearStuckStatus("")
        if(debugzz) ClientPrint(null,3,"getting unstuck")
    }
}

Contact.engiDrone <- null
PopExt.AddRobotTag("engidrone", {
    OnSpawn = function(bot, tag) {
        if(debugzz) ClientPrint(null, 3,"engidrone spawned")
        Contact.BaseBoss = Entities.FindByName(null, "controlpanel_baseboss")

        bot.ValidateScriptScope()
        local scope = bot.GetScriptScope()

        //scope.PlayerThinkTable.EngiDroneThink <- Contact.EngiDroneThink
        //EntFireByHandle(bot, "RunScriptCode", "Contact.SetEngiUfoTrigger(self)", 1,null,null)
        //Contact.SetEngiUfoTrigger(bot)

        if(Contact.engiDrone != null) return

        bot.Teleport(true, Vector(-242, -1617, 1854), false, QAngle(0,0,0), false, Vector(0,0,0))

        EntFireByHandle(bot, "EnableDamageForces", null, 5, null, null)

        bot.SetGravity(0.05)
        EntFireByHandle(bot, "DisableDamageForces", null, 0.0, null, null)
        Contact.engiDrone = bot
    },

    OnDeath = function(bot, params) {
       NetProps.SetPropString(bot, "m_iName", "")
       EntFireByHandle(bot, "EnableDamageForces", null, 0.0, null, null)
       bot.SetGravity(1.0)
       //try delete bot.GetScriptScope().PlayerThinkTable.EngiDroneThink catch(e) return
       try delete bot.GetScriptScope().PlayerThinkTable.EngiUfoTriggerThink catch(e) return
    },
})
Contact.KillEngiDrone <- function()
{
    Contact.engiDroneLastLoc <- Contact.engiDrone.GetOrigin()
    EntFireByHandle(Contact.engiDrone, "$Suicide", null, 0, null, null)
    //Contact.engiDrone.TakeDamage(9999999, 1, Contact.engiDrone)
}

Contact.engiDroneLastLoc <- null
Contact.engiBoss <- null

Contact.LaserIndicator <- function(duration){

    local wep = Contact.engiBoss.GetActiveWeapon()

    local wep_marker = SpawnEntityFromTable("prop_dynamic", {
        "targetname": "wep_marker"
        "model": "models/empty.mdl"
    })
    PopExtUtil.SetParentLocalOrigin(wep_marker, wep, "muzzle")

    local aim_marker = SpawnEntityFromTable("prop_dynamic", {
        "origin": (Contact.engiBoss.EyePosition() + Contact.engiBoss.EyeAngles().Forward()*2000).ToKVString()
        "targetname": "aim_marker"
        "model": "models/empty.mdl"
    })
    AddThinkToEnt(aim_marker, "MoveLaserAimMarker")

    local beam_ent = SpawnEntityFromTable("env_beam", {
        "origin": wep.GetOrigin().ToKVString()
        "targetname": "wep_marker"
        "model": "models/empty.mdl"
        "ClipStyle": "1"
        "targetname": "aim_beam"
        "BoltWidth": "6"
        "LightningEnd": "aim_marker"
        "LightningStart": "wep_marker"
        "origin": wep.GetOrigin().ToKVString()
        "renderamt": "200"
        "rendercolor": "0 0 255"
        "damage": "0"
        "NoiseAmplitude": "0"
        "dissolvetype": "1"
        "texture": "sprites/laserbeam.spr"
        "life": "0" //duration.tostring()
        "spawnflags": "769" //8 512
    })

    EntFireByHandle(wep_marker, "kill", "", duration, null, null)
    EntFireByHandle(aim_marker, "kill", "", duration, null, null)
    EntFireByHandle(beam_ent, "kill", "", duration, null, null)

}
::MoveLaserAimMarker <- function() {
    self.SetAbsOrigin(Contact.engiBoss.EyePosition() + Contact.engiBoss.EyeAngles().Forward()*2000)
    return -1
}

PopExt.AddRobotTag("engiboss", {

    OnSpawn = function(bot, tag) {
        bot.ValidateScriptScope()
        local scope = bot.GetScriptScope()
        bot.SetGravity(1.0)

        if(Contact.engiBoss != null) return
        bot.AddCondEx(Constants.ETFCond.TF_COND_STEALTHED_USER_BUFF, 0.1, bot)
        bot.AddCondEx(Constants.ETFCond.TF_COND_TELEPORTED, 0.5, bot)
        local location = Contact.engiDroneLastLoc + Vector(0, 0, 500)
        location.z = Min(location.z,1000)
        Contact.engiBoss = bot
        PopExtUtil.CreatePlayerWearable(bot, "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_engineer.mdl", true)
        PopExtUtil.CreatePlayerWearable(bot, "models/player/items/scout/scout_henchboy_hat.mdl", true)
        //PopExtUtil.CreatePlayerWearable(bot, "models/player/items/engineer/hwn_engineer_misc1.mdl", true)
        //PopExtUtil.CreatePlayerWearable(bot, "models/workshop/player/items/engineer/hwn2022_dustbowl_devil/hwn2022_dustbowl_devil.mdl", true)
        bot.Teleport(true, location, false, QAngle(0,0,0), false, Vector(0,0,0))
    },

    OnDeath = function(bot, params) {
       bot.SetGravity(1.0)
    },
})

Contact.DamageNearbyBuildings <- function() {
    local bot = Contact.engiBoss
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "obj_sentrygun", bot.GetOrigin(), 400);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity)) {
            entity.TakeDamage(120, 1, Contact.engiBoss)
        }
    }
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "obj_dispenser", bot.GetOrigin(), 400);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity)) {
            entity.TakeDamage(120, 1, Contact.engiBoss)
        }
    }
    for (local entity; entity = Entities.FindByClassnameWithin(entity, "obj_teleporter", bot.GetOrigin(), 400);)
    {
        if(entity.GetTeam() == 2 && IsPlayerAlive(entity)) {
            entity.TakeDamage(120, 1, Contact.engiBoss)
        }
    }
}

Contact.HurtCannonOrbital <- function() {
    if(Contact.cannonPuppet == null || !IsPlayerAlive(Contact.cannonPuppet)) return

    local h = Contact.cannonPuppet.GetHealth()
    local dmg = 55

    if(Contact.cannonPuppet.GetHealth() > 5500 && Contact.numCores != 4){
        dmg = 110
    }

    if(h < dmg) {
        EntFireByHandle(Contact.cannonPuppet, "$Suicide", null, 0, null, null)
    }
    else { Contact.cannonPuppet.SetHealth(Contact.cannonPuppet.GetHealth() - dmg) }
}


::StrikeMarkerThink <- function() {
    local scope = self.GetScriptScope()
    local parent = scope.parent
    if(parent == null || !parent.GetAbsVelocity) return -1;
    local vel = parent.GetAbsVelocity()
    local newpos = self.GetOrigin()
    if(vel.Length() < 50) {
        local ground = GetLocationBelow(parent)
        //local diff = ground - self.GetOrigin()
        scope.sparker.SetAbsOrigin(ground + Vector(0,0,10))
        scope.sparker.SetAbsAngles(QAngle(0,0,0))
        newpos = ground + Vector(0,0,10)
    } else {
        local startPt = parent.GetOrigin();
        local endPt = startPt + vel*9999;
        //MASK_PLAYERSOLID_BRUSHONLY 81931
        //(CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE)
        //everything normally solid for player movement, except monsters (world+brush only)
        local m_trace = { start = startPt, end = endPt, ignore = parent, mask = 81931 };
        TraceLineEx(m_trace);

        if (!m_trace.hit)
            return -1;

        local ground = m_trace.pos;

        //scope.sparker.SetAbsOrigin(ground + Vector(0,0,10))
        scope.sparker.SetAbsAngles(QAngle(0,0,0))
        newpos = ground + Vector(0,0,10)
    }

    local diff = (newpos - scope.oldpos)
    self.SetAbsOrigin(scope.oldpos + diff*FrameTime())
    scope.oldpos <- scope.oldpos + diff*FrameTime()
    return -1;
    // return -1 for 0.015; return 0 for next frame
}

Contact.CreateStrikeMarker <- function(projectile) {
    // create a env_spark on the ground below the projectile
    // create a env_beam that points from the mothership to the env_spark
    // pt weapon mimic that is below the projectile that points downwards
    // local arr = split(projectile.GetName() , "_")
    // local beamId = arr[arr.len()-1]
    // ClientPrint(null, 3, projectile.GetName())
    // local marker = Entities.FindByNameNearest("sparker_" + beamId, projectile.GetOrigin()-Vector(0,0,100), 1000)

    // if(marker == null) {
    //     if(debugzz) ClientPrint(null, 3, "something has gone wrong. no marker found")
    //     EntFireByHandle(projectile, "kill", null, 0, null, null)
    //     return
    // }

    projectile.ValidateScriptScope()
    local scope = projectile.GetScriptScope()
    scope.sparker <- projectile
    scope.parent <- projectile.GetMoveParent()
    scope.oldpos <- GetLocationBelow(projectile)
    AddThinkToEnt(projectile, "StrikeMarkerThink")
}


::OrbitalThink <- function() {
    local ground = GetLocationBelow(self)
    //local diff = ground - self.GetOrigin()
    local scope = self.GetScriptScope()
    scope.sparker.SetAbsOrigin(ground + Vector(0,0,5))
    //scope.sparker.SetLocalOrigin(diff)
    return -1
}

Contact.CreateLaser <- function(projectile) {
    // create a env_spark on the ground below the projectile
    // create a env_beam that points from the mothership to the env_spark
    // pt weapon mimic that is below the projectile that points downwards
    local arr = split(projectile.GetName() , "_")
    local beamId = arr[arr.len()-1]

    local marker = Entities.FindByNameNearest("sparker_" + beamId, projectile.GetOrigin()-Vector(0,0,100), 50)

    if(marker == null) {
        if(debugzz) ClientPrint(null, 3, "something has gone wrong. no marker found")
        EntFireByHandle(projectile, "kill", null, 0, null, null)
        return
    }

    projectile.ValidateScriptScope()
    local scope = projectile.GetScriptScope()
    scope.sparker <- marker
    AddThinkToEnt(projectile, "OrbitalThink")
}



// ///////////////////// Debug ///////////////////
// Setting a error handler allows us to view vscript error messages, even if we are not testing locally i.e. on potato testing server
Contact.DebugSteamIds <- {}
Contact.DebugSteamIds["[U:1:1086491858]"] <- 1 //Table
Contact.DebugSteamIds["[U:1:66915592]"] <- 1 //Claudz
seterrorhandler(function(e)
{
	for (local player; player = Entities.FindByClassname(player, "player");)
	{
		if (Contact.DebugSteamIds.rawin(NetProps.GetPropString(player, "m_szNetworkIDString")))
		{
			local Chat = @(m) (printl(m), ClientPrint(player, 2, m))
			ClientPrint(player, 3, format("\x07FF0000AN ERROR HAS OCCURRED [%s].\nCheck console for details", e))

			Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
			Chat("CALLSTACK")
			local s, l = 2
			while (s = getstackinfos(l++))
				Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))
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
