::ClaudzUtil <- {}
::ClaudzUtil <- {

    Players = {}
    PlayerSpawn = function(player)
    {
        player.ValidateScriptScope()
        local userid = NetProps.GetPropString(player, "m_szNetworkIDString")
        Players[userid] <- player
        player.GetScriptScope().lastBeamDmg <- Time()
    }
    OnGameEvent_player_spawn = function(params)
    {
        local player = GetPlayerFromUserID(params.userid);
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
        Objects[params.index] <- EntIndexToHScript(params.index)
    }
    OnGameEvent_object_destroyed = function(params)
    {
        if(!params.rawin("userid")) return
        local player = GetPlayerFromUserID(params.userid);
        if (player==null || player.GetTeam() != 2) return
        Objects[params.index] <- null
    }
    OnGameEvent_object_detonated = function(params)
    {
        if(!params.rawin("userid")) return
        local player = GetPlayerFromUserID(params.userid);
        if (player==null || player.GetTeam() != 2) return
        Objects[params.index] <- null
    }

    ///////////////////// Utility ///////////////////

    IsPlayerAlive = function(player)
    {
        // lifeState corresponds to the following values:
        // 0 - alive
        // 1 - dying (probably unused)
        // 2 - dead
        // 3 - respawnable (spectating)
        return player != null && player.IsValid() && NetProps.GetPropInt(player, "m_lifeState") == 0;
    }

    IsPlayerLOSofMe = function(me, player)
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

    // MASK_VISIBLE_AND_NPCS =  33579137
    // GetPlayerTarget = function(player)
    // {
    //     local startPt = player.EyePosition();
    //     local endPt = startPt + player.EyeAngles().Forward().Scale(800);

    //     local m_trace = { start = startPt, end = endPt, ignore = player , mask = MASK_VISIBLE_AND_NPCS};
    //     TraceLineEx(m_trace);

    //     if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)
    //         return null;

    //     if (m_trace.enthit.GetClassname() == "worldspawn")
    //         return null;

    //     return m_trace.enthit;
    // }

    // IsPlayerCritBoosted = function(player)
    // { // excludes conds that wont happen during the mission like mannpower and wheel of fate
    //     if(player.GetClassname()!= "player" || !player.InCond) return false
    //     return player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_USER_BUFF) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_ON_KILL) || player.InCond(Constants.ETFCond.TF_COND_CRITBOOSTED_RAGE_BUFF)
    // }

    // IsPlayerMiniCritBoosted = function(player)
    // {
    //     if(player.GetClassname()!= "player" || !player.InCond) return false
    //     return player.InCond(Constants.ETFCond.TF_COND_ENERGY_BUFF) || player.InCond(Constants.ETFCond.TF_COND_NOHEALINGDAMAGEBUFF) || player.InCond(Constants.ETFCond.TF_COND_OFFENSEBUFF)
    // }

    // IsPlayerDisguisedSpy = function(player)
    // {
    //     if(player.GetClassname()!= "player" || !ClaudzUtil.IsPlayerAlive(player) || !(player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY)) return false
    //     if(player.InCond(Constants.ETFCond.TF_COND_STEALTHED) || player.InCond(Constants.ETFCond.TF_COND_FEIGN_DEATH)) return true
    //     if(player.GetDisguiseTeam() != 3) return false
    //     return player.InCond(Constants.ETFCond.TF_COND_DISGUISING) || player.InCond(Constants.ETFCond.TF_COND_DISGUISED)
    // }

    // IsPlayerUbered = function(player)
    // {
    //     if(player.GetClassname()!= "player" || !ClaudzUtil.IsPlayerAlive(player)) return false
    //     if(player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE) || player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) || player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)|| player.InCond(Constants.ETFCond.TF_COND_INVULNERABLE_CARD_EFFECT))
    //         return true
    //     else
    //         return false
    // }

    Tracking = {}
    AddTracking = function(name, handle)
    {
        Tracking[name] <- handle
    }
    RemoveTracking = function(name)
    {
        if(name in Tracking) {
            delete Tracking.name
        }
    }
    GetTracking = function(name)
    {
        if(Tracking.rawin(name)) {
            return Tracking[name]
        } else {
            return null
        }
    }

        /**
     * Returns the position on ground below from the entity's origin.
     * Modified from:
     * https://github.com/L4D2Scripters/vslib
     */
    GetLocationBelow = function(player)
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

    // CreateGameTextUpper = function(msg, hold, color, color2) {
    //     local textent = SpawnEntityFromTable("game_text", {
    //         "origin": "1984 1984 99999"
    //         "targetname": "upper_text"
    //         "message": msg
    //         "x": "-1"
    //         "y": "0.4"
    //         "spawnflags": "1"
    //         "effect": "2"
    //         "channel": "2"
    //         "color": color
    //         "color2": color2
    //         "fadein": "0.2"
    //         "fxtime": "0.3"
    //         "fadeout": "1"
    //         "holdtime": hold
    //     })
    //     EntFireByHandle(textent,"Display", null, 0.1, null, null)
    //     EntFireByHandle(textent,"kill", null, 6, null, null)
    // }
    // CreateGameTextUpperFast = function(msg, hold, color, color2) {
    //     local textent = SpawnEntityFromTable("game_text", {
    //         "origin": "1984 1984 99999"
    //         "targetname": "upper_text"
    //         "message": msg
    //         "x": "-1"
    //         "y": "0.4"
    //         "spawnflags": "1"
    //         "effect": "2"
    //         "channel": "2"
    //         "color": color
    //         "color2": color2
    //         "fadein": "0.1"
    //         "fxtime": "0.01"
    //         "fadeout": "1"
    //         "holdtime": hold
    //     })
    //     EntFireByHandle(textent,"Display", null, 0.1, null, null)
    //     EntFireByHandle(textent,"kill", null, 6, null, null)
    // }
    // CreateGameTextSuperFast = function(msg, hold, color, color2) {
    //     local textent = SpawnEntityFromTable("game_text", {
    //         "origin": "1984 1984 99999"
    //         "targetname": "upper_text"
    //         "message": msg
    //         "x": "-1"
    //         "y": "0.4"
    //         "spawnflags": "1"
    //         "effect": "2"
    //         "channel": "2"
    //         "color": color
    //         "color2": color2
    //         "fadein": "0.01"
    //         "fxtime": "0"
    //         "fadeout": "1"
    //         "holdtime": hold
    //     })
    //     EntFireByHandle(textent,"Display", null, 0.1, null, null)
    //     EntFireByHandle(textent,"kill", null, 6, null, null)
    // }
    // CreateGameTextLower = function(msg, hold, color) {
    //     local textent = SpawnEntityFromTable("game_text", {
    //         "origin": "1984 1984 99999"
    //         "targetname": "text_lower"
    //         "message": msg
    //         "x": "-1"
    //         "y": "0.45"
    //         "channel": "1"
    //         "spawnflags": "1"
    //         "color": color
    //         "fadein": "0.25"
    //         "fadeout": "1"
    //         "holdtime": hold
    //     })
    //     EntFireByHandle(textent,"Display", null, 0.1, null, null)
    //     EntFireByHandle(textent,"kill", null, 6, null, null)
    // }
}

__CollectGameEventCallbacks(ClaudzUtil)

// spoof a player spawn when the wave initializes
for (local i = 1, player; i <= MaxClients().tointeger(); i++)
{
    if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2)
        ClaudzUtil.PlayerSpawn(player)
}

// for ringmarker1, which is the parent for the env_beam
::RingRegister <- function(beam, damage, attker) {
    local arr = split(beam.GetName() , "t")
    local beamId = arr[arr.len()-1]

    local marker = null

    for (local entity; entity = Entities.FindByNameWithin(entity,"ringmarkerone*", beam.GetOrigin(), 30);)
    {
        local ringArr = split(entity.GetName() , "e")
        local ringId = ringArr[ringArr.len()-1]

        if(beamId == ringId) {
            marker = entity
            break
        }
    }

    if(marker == null) {
        return
    }
    beam.ValidateScriptScope()
    beam.GetScriptScope().marker <- marker
    beam.GetScriptScope().dmgValue <- damage
    beam.GetScriptScope().attacker <- attker
    AddThinkToEnt(beam, "RingThink")
}
::RingThink <- function() {
    local marker = self.GetScriptScope().marker
    local damage = self.GetScriptScope().dmgValue
    local radius = (marker.GetOrigin()-self.GetOrigin()).Length()
    local ring_z = self.GetOrigin().z
    foreach (k, entity in ClaudzUtil.Players) {
        if (entity != null && ClaudzUtil.IsPlayerAlive(entity) && entity.GetTeam() == 2  ) {
            local ent_z = entity.GetOrigin().z
            local eye_z = entity.EyePosition().z
            local dist = ((entity.GetOrigin() + Vector(0,0,30)) - self.GetOrigin()).Length()
            if(ring_z > (ent_z-5) && ring_z < eye_z + 40) {
                if(fabs(dist - radius) < 3){

                    if(!(entity.GetScriptScope().rawin("lastBeamDmg")) || Time() > entity.GetScriptScope().lastBeamDmg + 0.1)
                    {
                        entity.TakeDamageCustom(entity, self.GetScriptScope().attacker,null, Vector(0,0,0), Vector(0,0,0), damage, 8, Constants.ETFDmgCustom.TF_DMG_CUSTOM_BURNING)
                        entity.ApplyAbsVelocityImpulse(Vector(0,0,70))
                        entity.GetScriptScope().lastBeamDmg <- Time()
                    }
                }
            }
        }
    }
    foreach (k,entity in ClaudzUtil.Objects) {
        if (ClaudzUtil.IsPlayerAlive(entity) && entity.GetTeam() == 2 &&  ClaudzUtil.IsPlayerLOSofMe(self,entity)) {
            entity.ValidateScriptScope()
            local ent_z = entity.GetOrigin().z
            local eye_z = entity.GetOrigin().z + 50
            local dist = ((entity.GetOrigin() + Vector(0,0,30)) - self.GetOrigin()).Length()
            if(ring_z > ent_z && ring_z < eye_z + 2) {
                if(fabs(dist - radius) < 4) {
                    if(!(entity.GetScriptScope().rawin("lastBeamDmg")) ||Time() > entity.GetScriptScope().lastBeamDmg + 0.2)
                    {
                        entity.TakeDamageEx(entity,self.GetScriptScope().attacker, null, Vector(0,0,0), Vector(0,0,0), 100, 1024)
                        entity.GetScriptScope().lastBeamDmg <- Time()
                    }
                }
            }
        }
    }
    return -1
}
::SetMoveIgnoreSolid <- function(ent, speed) {
    ent.ValidateScriptScope()
    ent.GetScriptScope().shootSpeed <- speed
    AddThinkToEnt(self, "ShootThink")
}
::ShootThink <- function() {
    local vel = self.GetForwardVector() * self.GetScriptScope().shootSpeed
    vel.z = 0
    local lilVel = self.GetForwardVector()
    lilVel.z = 0
    lilVel.Norm()
    self.SetAbsOrigin(self.GetOrigin() + (vel*FrameTime()) + lilVel)
    return -1
}
// ///////////////////// Debug ///////////////////
// Setting a error handler allows us to view vscript error messages, even if we are not testing locally i.e. on potato testing server
ClaudzUtil.DebugSteamIds <- {}
ClaudzUtil.DebugSteamIds["[U:1:66915592]"] <- 1