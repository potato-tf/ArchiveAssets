///////////////////////////////////////////////////////////SETUP
/////////////////////////////////////////////////////////////////

//yes this popfile is a gigantic mess
//yes navigating the pop is a complete nightmare 
//yes this is neccesary dont ask why
// all by stardustspy with some help
PrecacheModel("models/props_mvm/robot_spawnpoint_warning.mdl")
PrecacheModel("models/empty.mdl")
PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper_fixed.mdl")
PrecacheModel("models/bots/spy/bot_spy.mdl")
PrecacheSound("weapons/pipe_bomb1.wav")
PrecacheSound("weapons/jar_explode.wav")
PrecacheSound("weapons/gas_can_explode.wav")
PrecacheSound("ui/halloween_boss_summoned_monoculus.wav")
PrecacheSound("misc/halloween/spell_lightning_ball_impact.wav")

local gamerules = FindByClassname(null, "tf_gamerules")
local spawn_text_player_list = []
local isTrickRoomUp = false
local areas = {}
local cauldron = null
local PlayerManager = FindByClassname(null, "tf_player_manager")

GetAllAreas(areas)

function PlayerInArray(ent)
{
    if (spawn_text_player_list.find(ent) != null) return

    local team = ent.GetTeam()
    local ClassType = ent.GetPlayerClass()
    local CurrentWaveNum = GetPropInt(FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")
    
    spawn_text_player_list.append(ent)

    if (ent != null && team == 2)
    {
        if (CurrentWaveNum == 1)
        {
            ClientPrintSafe(ent, "^0bf90bMerasmus: ^a600ffWelcome, mortal! I have taken it upon myself to use this area to test my new ^ffd800CONJURING CAULDRON! ^")
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffThis cauldron will cast ^ffd800random effects during robot waves every 45 seconds! ^a600ffIt's effects could go ^ffd800 both ways or either ways! ^a600ffBah-ahahahahaha! ^`)", 5, null, null)
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffBecause im so nice, i'll let you experience some of its effects against ^99CCFFmostly familiar robot types!^`)", 10, null, null)
            //this is probably something Merasmus would say
            if (ClassType != 3)
            {
                EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffAnd DO NOT let ^FF3F3FSoldier ^a600ffdrink it!^`)", 15, null, null)
            }
            else 
            {
                EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ff^FF3F3FSoldier, ^a600ffDO NOT drink this! Or else you'll turn into a European RACOON!^`)", 15, null, null)
            }
        }
        if (CurrentWaveNum == 2)
        {
            ClientPrintSafe(ent, "^0bf90bMerasmus: ^a600ffI'm sure you lot are already so SCARED of my ^d80e0epowerful new concoction! ^")
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffInfact it was so scary, i forgot to explain what ^e50255Weapon Tiers ^a600ffare! ^`)", 5, null, null)
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^ffd800Weapon tiers are certain changes a weapon gets during one of the cauldrons effects! ^a600ffThe better the weapon, the harsher the nerf! ^`)", 10, null, null)
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^ffd800And weaker weapons obtain buffs! ^e50255To view your weapon's tier, press X+9 on your keyboard! ^`)", 15, null, null)
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffMost weapons gain the same buffs, but some weapons get ^e50255special treatment!^`)", 20, null, null)
            EntFireByHandle(ent, "RunScriptCode", "ClientPrintSafe(self, `^0bf90bMerasmus: ^a600ffNow hurry up and get steamrolled, im BORED here! Eu-Haha!^`)", 25, null, null)
        }
    }
}

::PlayerManager <- Entities.FindByClassname(null, "tf_player_manager")

::GetPlayerUserID <- function(player)
{
    return NetProps.GetPropIntArray(PlayerManager, "m_iUserID", player.entindex())
}


function SetUp() 
{
    Convars.SetValue("tf_spells_enabled", 0)
}
SetUp()

::ClientPrintSafe <- function(player, text)
{
    //replace ^ with /x07 at run-time
    local escape = "^"

    //just use the normal print function if there's no escape character
    if (!startswith(text, escape)) 
    {
        ClientPrint(player, 3, text)
        return;
    }
    
    //split text at the escape character
    local splittext = split(text, escape)

    //remove 0-length strings
    for (local i = splittext.len() - 1; i >= 0; i--)
        if (splittext[i].len() < 1) 
            splittext.remove(i);
    
    //format into new string
    local formatted = ""
    foreach (i, t in splittext)
        formatted += format("/x07%s", t)
    
    //print formatted string
    ClientPrint(player, 3, formatted)
}

///////////////////////////////////////////////////////////CAULDRON EFFECTS
/////////////////////////////////////////////////////////////////


//////////EFFECT 1: Reverse the speed tiers of every class.
////////////////////////
function TrickRoomThink(ent)
{
    local playerscope = ent.GetScriptScope()
    local maxspeed = NetProps.GetPropFloat(ent, "m_flMaxspeed")
    ::SetClassSpeed <- function() 
    {
        local maxspeed = NetProps.GetPropFloat(self, "m_flMaxspeed")

        local wep = self.GetActiveWeapon()
        local switchtime = NetProps.GetPropFloat(self, "m_flNextAttack")

        //do the calcs in a function so the think doesnt keep recalcing speed
        function CalculateSpeedTier(speed)
        {
            //do the calc in the script earlier
            if (self.InCond(0))
            {
                return
            }
            if (class_speed >= 300)
            {
                NetProps.SetPropFloat(self, "m_flMaxspeed", maxspeed / 2)
            }
            else if (class_speed <= 300)
            {
                NetProps.SetPropFloat(self, "m_flMaxspeed", maxspeed * 2)
            }
        }

        if (set_speed == false)
        {
            //only call when the game needs to (it detected a change in speed for any reason)
            CalculateSpeedTier(maxspeed)
            savedtime = switchtime
            set_speed = true
        }
        //tf2 recalcs m_flMaxspeed every time a player switches weapons
        //fix players being able to dodge the new speed here
        if (switchtime > savedtime)
        {
            set_speed = false
        }

        //heavy and sniper have weird shit when it comes to changing their speed, fix those instances here
        //although revved heavy/scoped sniper is just as fast as non-scoped or revved but whatever

        //this needs to be here to calculate speed after unscope/unrev
        if (self.InCond(0))
        {
            if (maxspeed <= 300)
            {
                NetProps.SetPropFloat(self, "m_flMaxspeed", maxspeed * 2)
            }
            set_speed = false
        }
        else 
        {
            return
        }
    }
    ent.ValidateScriptScope();
    playerscope.CurSpeed <- maxspeed
    playerscope.savedtime <- 0
    playerscope.speedtier <- 0
    playerscope.set_speed <- false
    playerscope.class_speed <- NetProps.GetPropFloat(ent, "m_flMaxspeed")
    PopExtUtil.AddThinkToEnt(ent, "SetClassSpeed")
}

function CallTrickRoom()
{
    isTrickRoomUp = true
    for (local player; player = FindByClassname(player, "player");)
    {
        ClientPrint(player, 4, "The dimensions have been twisted!")
        SetSkyboxTexture("sky_harvest_night_01")
        EmitSoundOnClient("Halloween.hellride", player)
        TrickRoomThink(player)
    }
}

///////////////EFFECT 2: Summon metoers to scatter the area. These can be RED or BLU
////////////////////////

function SummonMeteors() 
{

    for (local player; player = FindByClassname(player, "player");)
    {
        if (player.IsBotOfType(TF_BOT_TYPE))
        {
            if (player.HasBotTag("bot_fireball"))
            {
                // player.ForceChangeTeam(5, false)
                //player.SetAbsOrigin(Vector(217, -415, 1038))
                player.SetAbsOrigin(cauldron.GetOrigin())
                player.SetCustomModel("models/empty.mdl")
                //player.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT)
                player.ValidateScriptScope()
                local playerscope = player.GetScriptScope()
                playerscope.meteor_timer <- 0
                playerscope.meteorScatter <- 0
                playerscope.meteorNumber <- 0
                playerscope.meteorBeginTime <- 0
                playerscope.meteorInitTimer <- 0
                playerscope.activateMetoer <- true
                playerscope.meteorBegins <- true
                PopExtUtil.AddThinkToEnt(player, "MetoerThink")
            }
        }
    }
    ::MetoerThink <- function()
    {
        if (meteorNumber <= 50)
        {
            meteorBeginTime++
        }
        if (meteorBeginTime <= 100 && meteorBegins == true)
        {
            meteorInitTimer++
            if (meteorInitTimer == 5)
            {
                for (local meteor = 0; meteor <= 1; meteor++)
                {
                    local fireball = SpawnEntityFromTable("tf_projectile_spellfireball", 
                    {
                        basevelocity = Vector(0, 0, 600),
                        teamnum      = 5,
                        origin       = self.GetOrigin() + Vector(0, 0, 75) + Vector(RandomInt(-60, 130), RandomInt(-60, 130), 0),
                        angles       = Vector(-90, 0, 0)
                    })
                    fireball.SetOwner(self)
                    meteorInitTimer = 0
                    fireball = null
                }
            }
        }
        if (meteorBeginTime >= 500)
        {
            activateMetoer = true
            if (activateMetoer == true && meteorNumber <= 50) 
            {
                meteorScatter++
                if (meteorScatter == 10)
                {
                    local minareasize = 1200;
                    local spots = [];

                    foreach(id, nav in areas)
                    {
                        if (nav.GetSizeX() * nav.GetSizeY() > minareasize)
                        spots.append(nav.GetCenter() + Vector(0, 0, 50));
                    }
                    for (local meteor = 0; meteor <= 1; meteor++)
                    {
                        local spot = spots[RandomInt(0, spots.len() - 1)]
                        ////printl(spot)
                        local speed = RandomInt(-350, -650)
                        local fireball = SpawnEntityFromTable("tf_projectile_spellfireball", 
                        {
                            basevelocity = Vector(0, 0, speed),
                            teamnum      = 5,
                            origin       = spot + Vector(0, 0, 900),
                            angles       = Vector(90, 0, 0)
                        })
                        local warning = SpawnEntityFromTable("prop_dynamic",
                        {
                            model = "models/props_mvm/robot_spawnpoint_warning.mdl"
                            origin = spot - Vector(0, 0, 50)
                            angles = Vector(0, 0, 0)
                            targetname = "indicator_warn"
                        })
                        fireball.SetOwner(self)
                        EntFireByHandle(warning, "Kill", "", 3, null, null)
                    }
                    meteorScatter = 0
                    meteorNumber++
                    //return spots; // causes script to iterate over spots again
                }
            }
            if (meteorScatter >= 30)
            {
                meteorBegins = false
                meteorBeginTime = 0
                activateMetoer = false
            }
        }

        return -1
    }
}

///////////////EFFECT 3: Stop time. All projectiles stay in place. All Players stay in place. No one can do jack shit.
////////////////////////

function CreateTimeThink(ent)
{
    local entscope = ent.GetScriptScope()
    ent.ValidateScriptScope()

    ::TimeIsStopped <- function() 
    {
        countTimeStuck()

        //SetSkyboxTexture("blacksky")

        if (self.InCond(34))
        {
            EntFireByHandle(self, "RunScriptCode", "self.AddCondEx(34, 5, self)", 5, self, self)
            self.AddCondEx(34, 5, self)
        }
        else if (self.InCond(52))
        {
            EntFireByHandle(self, "RunScriptCode", "self.AddCondEx(52, 5, self)", 5, self, self)
            //self.AddCondEx(52, 5, self)
        }

        
        if (timeStop >= 1)
        {   
            self.SetMoveType(MOVETYPE_NOCLIP + MOVETYPE_FLY, MOVECOLLIDE_DEFAULT) // completely stops a player in place
            //bots can defy cond rules and as such must be corrected here
            if (self.IsBotOfType(TF_BOT_TYPE))
            {
                self.SnapEyeAngles(look)
                self.AddCustomAttribute("no_attack", 1, 0.07)
                //set reload time so bots cant just immediately attack when free'd
                self.AddCustomAttribute("reload time increased", 999, 0.07)
            }
            else 
            {
                if (self.GetPlayerClass() == 5)
                {
                    self.AddCustomAttribute("uber duration bonus", 99999, 0.07)
                }
                self.AddCustomAttribute("powerup duration", 999, 0.07)
                self.AddCustomAttribute("increase buff duration", 999, 0.07)
            }
        }
        else
        {
            self.SetMoveType(MOVETYPE_WALK, MOVECOLLIDE_DEFAULT) // allows player to move
        }
        // self.AddFlag(FL_FROZEN)
        self.AddCondEx(87, 0.07, null) // no wep switching, moving camera or attacking
        if (self.IsTaunting())
        {
            self.CancelTaunt()
        }
    }

    if (ent.GetTeam() == 2)
    {
        entscope.timeStop <- 5
    }
    else if (ent.GetTeam() == 3)
    {
        entscope.timeStop <- 9
    }
    entscope.serverTime <- 0
    entscope.countTimeStuck <- function() 
    {
        //caberCountTime acts as time
        if (timeStop == null) return
        local time = floor(Time())
        if (time != serverTime) { // Once every second
            serverTime = time
            if (timeStop > 0)
            {
                timeStop--
            }
            if (timeStop == 0)
            {
                self.SetMoveType(MOVETYPE_WALK, MOVECOLLIDE_DEFAULT) // completely stops a player in place
                self.RemoveCondEx(87, true)
                // self.RemoveFlag(FL_FROZEN)
                self.RemoveCustomAttribute("no_attack")
                self.RemoveCustomAttribute("reload time increased")
                if (self.GetPlayerClass() == 5)
                {
                    //this does mean medic gets a free buff duration increase, with or without shield
                    //but what medic isnt buying shield lmao
                    //also this doesnt affect other classes 
                    self.AddCustomAttribute("increase buff duration", 1.2, -1)
                }
                try delete self.GetScriptScope().PlayerThinkTable.TimeIsStopped catch(e) return
            }
        }
    }
    PopExtUtil.AddThinkToEnt(ent, "TimeIsStopped")
}


/////////////////////////PROJECTILEs
function CreateTimeThinkProj(ent)
{
    if (ent == null || !ent.IsValid()) return
    local entscope = ent.GetScriptScope()
    ent.ValidateScriptScope()

    ::TimeIsStopped <- function() 
    {
        local getphys = GetPhysVelocity(self)
        local touched = NetProps.GetPropBool(self, "m_bTouched")
        local origin = self.GetOrigin()
        local forwardvelo = self.GetAbsAngles()
        local sound_range = (40 + (20 * log10(1900 / 36.0))).tointeger();

        //for some reason the game likes to spawn a second ball without velocity
        //kill it here
        if (phys.x == 0)
        {
            self.Kill()
            return
        }

        countTimeStuckProj()

        if (self.GetClassname() == "tf_projectile_stun_ball" && weapon != "tf_weapon_bat_wood")
        {   
            if (team != null)
            {
                if (team == 2)
                {
                    self.SetSkin(0)
                }
                else if (team == 3)
                {
                    self.SetSkin(1)
                }
            }

            if (timeStopProj > 1)
            {   
                self.SetVelocity(Vector(0, 0, 0))
                self.SetPhysVelocity(Vector(0, 0, 0 + floor(11))) // sometimes the projectile has less then 0 z velocity, fix it here
            }
            else if (timeStopProj >= 1)
            {
                // due to the original projectile that this replaced being deleted, "phys" only refers to one vector, causing projectiles 
                // to fly away like rockets. ensure that phys is set here, but only set phys once

                // this doesnt work?
                if (releaseProjectile == false)
                {
                    self.SetVelocity(velocity)
                    self.SetPhysVelocity(phys)
                    self.SetPhysAngularVelocity(rotation)
                    releaseProjectile = true
                }
            }

            if (timeStopProj < 1)
            {
                detonateTimer++
            }

            if (grenade == true)
            {
                if (detonateTimer >= 132)
                {
                    DispatchParticleEffect("ExplosionCore_MidAir", self.GetOrigin(), Vector(-15, 90, 90))
                    EmitSoundEx({
                        sound_name = "weapons/pipe_bomb1.wav",
                        origin = origin,
                        sound_level = sound_range 
                    });
                    for (local player; player = FindByClassnameWithin(player, "player", origin, radius);)
                    {
                        if (player == null) continue
                        if (player.GetTeam() != team && crit == true)
                        {
                            player.TakeDamageEx(null, owner, weapon, Vector(0, 0, 0), origin, damage * 3, 64 + 1048576)
                        }
                        else if (player.GetTeam() != team)
                        {
                            if (player.InCond(24) || player.InCond(30)) //jarate, marked for death
                            {
                                player.TakeDamageEx(null, owner, weapon, Vector(0, 0, 0), origin, damage * 1.35, 64 + 1048576)
                            }
                            else 
                            {
                                player.TakeDamageEx(null, owner, weapon, Vector(0, 0, 0), origin, damage, 64)
                            }
                        }
                    }
                    for (local building; building = FindByClassnameWithin(building, "obj_*", origin, radius);)
                    {
                        if (building == null) continue
                        if (building.GetTeam() != team)
                        {
                            building.TakeDamageEx(null, owner, weapon, Vector(0, 0, 0), origin, damage, 64)
                        }
                    }
                    self.Kill()
                }
            }
            else if (jarate == true)
            {
                if (touched == true || detonateTimer >= 132)
                {
                    DispatchParticleEffect("peejar_impact", self.GetOrigin(), Vector(-15, 90, 90))
                    EmitSoundEx({
                        sound_name = "weapons/jar_explode.wav",
                        origin = origin,
                        sound_level = sound_range 
                    });
                    for (local player; player = FindByClassnameWithin(player, "player", origin, 512);)
                    {
                        if (player == null) continue
                        if (player.GetTeam() != team)
                        {
                            player.AddCondEx(24, 14, owner)
                        }
                    }
                    self.Kill()
                }
            }
            else if (milk == true)
            {
                if (touched == true || detonateTimer >= 132)
                {
                    DispatchParticleEffect("peejar_impact_milk", self.GetOrigin(), Vector(-15, 90, 90))
                    EmitSoundEx({
                        sound_name = "weapons/jar_explode.wav",
                        origin = origin,
                        sound_level = sound_range 
                    });
                    for (local player; player = FindByClassnameWithin(player, "player", origin, 512);)
                    {
                        if (player == null) continue
                        if (player.GetTeam() != team)
                        {
                            player.AddCondEx(27, 14, owner) // 15 seconds because theres still 4 seconds left on the timestop
                        }
                    }
                    self.Kill()
                }
            }
            //i dont think gas is good enough to bother implementing the "linger" mechanic
            else if (gas == true)
            {
                if (touched == true || detonateTimer >= 132)
                {
                    if (team == 2)
                    {
                        DispatchParticleEffect("gas_can_impact_red", origin, Vector(-90, 180, 0))
                    }
                    else if (team == 3)
                    {
                        DispatchParticleEffect("gas_can_impact_blue", origin, Vector(-90, 180, 0))
                    }
                    EmitSoundEx({
                        sound_name = "weapons/gas_can_explode.wav",
                        origin = origin,
                        sound_level = sound_range 
                    });
                    for (local player; player = FindByClassnameWithin(player, "player", origin, 512);)
                    {
                        if (player == null) continue
                        if (player.GetTeam() != team)
                        {
                            player.AddCondEx(123, 14, owner) // 15 seconds because theres still 4 seconds left on the timestop
                        }
                    }
                    self.Kill()
                }
            }
            return
        }
        else 
        {
            if (timeStopProj >= 1)
            {   
                self.SetVelocity(Vector(0, 0, 0))
                self.SetPhysVelocity(Vector(0, 0, 0))
            }
            else
            {
                self.SetVelocity(velocity)
                self.SetPhysVelocity(phys)
            }
        }
    }

    if (ent.GetTeam() == 2 && ent.IsValid())
    {
        entscope.timeStopProj <- 5
    }
    else if (ent.GetTeam() == 3 && ent.IsValid())
    {
        entscope.timeStopProj <- 10
    }
    //entscope.timeStopProj <- 5
    entscope.serverTime <- 0
    entscope.countTimeStuckProj <- function() 
    {
        //caberCountTime acts as time
        if (timeStopProj == null) return
        local time = floor(Time())
        if (time != serverTime) { // Once every second
            serverTime = time
            //printl(timeStopProj)
            if (timeStopProj > 0)
            {
                timeStopProj--
            }
            //dont delete if the projectile was replaced
            if (timeStopProj == 0 && self.GetClassname() != "tf_projectile_stun_ball")
            {
                try delete self.GetScriptScope().ProjectileThinkTable.TimeIsStopped catch(e) return
            }

            // due to the original projectile that this replaced being deleted, "phys" only refers to one vector, causing projectiles 
            // to fly away like rockets. ensure that phys is set here, but only set phys once

            //think is weird, set "phys" here
            else if (timeStopProj == 1 && self.GetClassname() == "tf_projectile_stun_ball")
            {
                self.SetPhysVelocity(phys)
            }
        }
    }
    PopExtUtil.AddThinkToEnt(ent, "TimeIsStopped")
}

function CreateTimeThinkBuild(ent) 
{
    if (ent == null || !ent.IsValid()) return
    local entscope = ent.GetScriptScope()
    ent.ValidateScriptScope()
    local angles = ent.GetAbsAngles()

    ::BuildingTimeStop <- function() 
    {
        countTimeStuckBuild()

        if (timeStopBuild < 1)
        {
            NetProps.SetPropInt(self, "m_iState", 1) // stop sentry from turning and searching
            return
        }
        NetProps.SetPropInt(self, "m_iState", 2)
        return -1
    }  

    if (ent.GetTeam() == 2 && ent.IsValid())
    {
        entscope.timeStopBuild <- 5
    }
    else if (ent.GetTeam() == 3 && ent.IsValid())
    {
        entscope.timeStopBuild <- 9
    }
    entscope.serverTime <- 0
    entscope.countTimeStuckBuild <- function() 
    {
        //caberCountTime acts as time
        if (timeStopBuild == null) return
        local time = floor(Time())
        if (time != serverTime) { // Once every second
            serverTime = time
            printl(timeStopBuild)
            if (timeStopBuild > 0)
            {
                timeStopBuild--
            }
            if (timeStopBuild == 0)
            {
                for (local building; building = FindByClassname(building, "obj_*");)
                {
                    
                    try delete building.GetScriptScope().BuildingTimeStop catch(e) return
                }
            }
        }
    }

    AddThinkToEnt(ent, "BuildingTimeStop")
}


function StopTime()
{
    for (local spawn; spawn = FindByClassname(spawn, "info_player_teamspawn");)
    {
        if (spawn == null) continue
        EntFireByHandle(spawn, "Disable", "", 0, null, null)
        EntFireByHandle(spawn, "Enable", "", 9, null, null)
    }
    for (local building; building = FindByClassname(building, "obj_*");)
    {
        if (building == null) continue
        local nextatk = NetProps.GetPropFloat(building, "m_flNextAttack")
        local owner = NetProps.GetPropEntity(building, "m_hBuilder")
        local recharge = NetProps.GetPropFloat(building, "m_flCurrentRechargeDuration")

        EntFireByHandle(building, "RunScriptCode", "self.SetPlaybackRate(1)", 4.1, building, building)

        if (building.GetClassname() == "obj_sentrygun")
        {
            building.ValidateScriptScope()
            local buildscope = building.GetScriptScope()
            local angles = building.GetAbsAngles()

            buildscope.angles <- angles
            buildscope.buildingtimer <- 0
            if (NetProps.GetPropEntity(building, "m_hEnemy") == null || NetProps.GetPropInt(self, "m_iState") == 1)
            {
                CreateTimeThinkBuild(building)
            }
            //CreateTimeThinkBuild(building)
        }
        if (building.GetClassname() == "obj_teleporter")
        {
            //building.SetSequence(0)
            building.SetPlaybackRate(0)
            NetProps.SetPropBool(building, "m_bDisabled", true)
            EntFireByHandle(building, "RunScriptCode", "self.SetPlaybackRate(1)", 4.1, building, building)
            EntFireByHandle(building, "RunScriptCode", "NetProps.SetPropBool(self, `m_bDisabled`, false)", 4.1, building, building)
        }   
    }
    for (local player; player = FindByClassname(player, "player");)
    {
        if (player.IsBotOfType(TF_BOT_TYPE) || player.GetTeam() == 2)
        {
            local location = player.GetOrigin()
            local eyes = player.EyeAngles()
            local moving = self.GetMoveType()

            player.ValidateScriptScope()
            local playerscope = player.GetScriptScope()
            if (player.GetPlayerClass() == 9)
            {
                player.AddCustomAttribute("engy sentry fire rate increased", 38, 1) // stop sentry firing speed
                player.AddCustomAttribute("engy dispenser radius increased", 0, 3.05) // no dispensers
            }
            if (player.InCond(34))
            {
                EntFireByHandle(player, "RunScriptCode", "self.AddCondEx(34, 5, self)", 5, player, player)
                player.RemoveCondEx(34, true)
                player.AddCondEx(34, -1, player)
            }
            else if (player.InCond(52))
            {
                EntFireByHandle(player, "RunScriptCode", "self.AddCondEx(52, 5, self)", 5, player, player)
                player.RemoveCondEx(52, true)
                player.AddCondEx(52, -1, player)
            }

            //insert things here before calling script func
            playerscope.location <- location
            playerscope.look <- eyes
            playerscope.movetype <- moving

            CreateTimeThink(player)
        }
    }
    for (local projectile; projectile = FindByClassname(projectile, "tf_projectile_*");)
    {
        local velocity = projectile.GetVelocity()
        local phys = GetPhysVelocity(projectile)
        local weapon = NetProps.GetPropEntity(projectile, "m_hLauncher")
        //local fuse = NetProps.GetPropFloat(projectile, "m_flDetonateTime")

        projectile.ValidateScriptScope()
        local projscope = projectile.GetScriptScope()

        projscope.velocity <- velocity
        projscope.phys <- phys
        projscope.weapon <- weapon
        //projscope.fuse <- fuse
        //add the think first, then check if the projectile is actually a pipe
        CreateTimeThinkProj(projectile)
        if (projectile.GetClassname() == "tf_projectile_pipe")
        {
            //get all the projectile info again
            if (projectile == null || !projectile.IsValid()) continue
            local proj_origin = projectile.GetOrigin()
            local velocity = projectile.GetVelocity()
            local phys = GetPhysVelocity(projectile)
            local rotation = GetPhysAngularVelocity(projectile)

            local weapon = NetProps.GetPropEntity(projectile, "m_hLauncher")
            local owner = weapon.GetOwner()
            local team = owner.GetTeam()
            local radius = NetProps.GetPropFloat(projectile, "m_DmgRadius")
            local damage = NetProps.GetPropFloat(projectile, "m_flDamage")
            local crit = NetProps.GetPropBool(projectile, "m_bCritical")
            local model = projectile.GetModelName()
            projectile.Kill()
            local pipe = SpawnEntityFromTable("tf_projectile_stun_ball", 
            {
            	targetname = "bomb"
            })
            
            DispatchSpawn(pipe)
            pipe.SetOrigin(proj_origin)
            pipe.SetPhysVelocity(phys)
            pipe.SetTeam(team)
            pipe.SetModelSimple(model)
            
            pipe.ValidateScriptScope()
            NetProps.SetPropVector(pipe, "m_angRotation", rotation)
            local projscope = pipe.GetScriptScope()

            if (crit == true)
            {
                projscope.crit <- true
            }
            else 
            {
                projscope.crit <- false
            }
            projscope.velocity <- velocity
            projscope.phys <- phys
            projscope.rotation <- rotation
            projscope.team <- NetProps.GetPropInt(owner, "m_iTeamNum")
            projscope.owner <- owner
            projscope.weapon <- weapon
            projscope.radius <- radius
            projscope.damage <- damage
            projscope.detonateTimer <- 0
            projscope.timeStopProj <- 5
            projscope.serverTime <- 0
            projscope.grenade <- true
            projscope.jarate <- false
            projscope.milk <- false
            projscope.gas <- false
            projscope.releaseProjectile <- false
            projscope.countTimeStuckProj <- function() 
            {
                //caberCountTime acts as time
                if (timeStopProj == null) return
                local time = floor(Time())
                if (time != serverTime) { // Once every second
                    serverTime = time
                    //printl(timeStopProj)
                    if (timeStopProj > 0)
                    {
                        timeStopProj--
                    }
                    if (timeStopProj == 0)
                    {
                        try delete self.GetScriptScope().ProjectileThinkTable.TimeIsStopped catch(e) return
                    }
                }
            }
            EntFireByHandle(pipe, "RunScriptCode", "CreateTimeThinkProj(self)", 0.1, pipe, null)
            continue
        }
        //all these blocks are copied so that every projectile is consistent
        else if (projectile.GetClassname() == "tf_projectile_jar")
        {
            //get all the projectile info again
            if (projectile == null || !projectile.IsValid()) continue
            local proj_origin = projectile.GetOrigin()
            local velocity = projectile.GetVelocity()
            local phys = GetPhysVelocity(projectile)
            local rotation = GetPhysAngularVelocity(projectile)

            local weapon = NetProps.GetPropEntity(projectile, "m_hLauncher")
            local owner = weapon.GetOwner()
            local team = owner.GetTeam()
            local radius = NetProps.GetPropFloat(projectile, "m_DmgRadius")
            local damage = NetProps.GetPropFloat(projectile, "m_flDamage")
            local crit = NetProps.GetPropBool(projectile, "m_bCritical")
            local model = projectile.GetModelName()

            projectile.Kill()
            local jar = SpawnEntityFromTable("tf_projectile_stun_ball", 
            {
            	targetname = "jar"
            })
            
            DispatchSpawn(jar)
            jar.SetOrigin(proj_origin)
            jar.SetPhysVelocity(phys)
            jar.SetTeam(team)
            jar.SetModelSimple(model)
            jar.SetModelScale(1.5, 0)
            
            jar.ValidateScriptScope()
            NetProps.SetPropVector(jar, "m_angRotation", rotation)
            local projscope = jar.GetScriptScope()

            if (crit == true)
            {
                projscope.crit <- true
            }
            else 
            {
                projscope.crit <- false
            }
            projscope.velocity <- velocity
            projscope.phys <- phys
            projscope.rotation <- rotation
            projscope.team <- NetProps.GetPropInt(owner, "m_iTeamNum")
            projscope.owner <- owner
            projscope.weapon <- weapon
            projscope.radius <- radius
            projscope.damage <- damage
            projscope.grenade <- false
            projscope.jarate <- true
            projscope.milk <- false
            projscope.gas <- false
            projscope.detonateTimer <- 0
            projscope.timeStopProj <- 5
            projscope.serverTime <- 0
            projscope.releaseProjectile <- false
            projscope.countTimeStuckProj <- function() 
            {
                //caberCountTime acts as time
                if (timeStopProj == null) return
                local time = floor(Time())
                if (time != serverTime) { // Once every second
                    serverTime = time
                    //printl(timeStopProj)
                    if (timeStopProj > 0)
                    {
                        timeStopProj--
                    }
                    if (timeStopProj == 0)
                    {
                        try delete self.GetScriptScope().ProjectileThinkTable.TimeIsStopped catch(e) return
                    }
                }
            }
            EntFireByHandle(jar, "RunScriptCode", "CreateTimeThinkProj(self)", 0.1, jar, null)
            continue
        }
        else if (projectile.GetClassname() == "tf_projectile_jar_milk")
        {
            //get all the projectile info again
            if (projectile == null || !projectile.IsValid()) continue
            local proj_origin = projectile.GetOrigin()
            local velocity = projectile.GetVelocity()
            local phys = GetPhysVelocity(projectile)
            local rotation = GetPhysAngularVelocity(projectile)

            local weapon = NetProps.GetPropEntity(projectile, "m_hLauncher")
            local owner = weapon.GetOwner()
            local team = owner.GetTeam()
            local radius = NetProps.GetPropFloat(projectile, "m_DmgRadius")
            local damage = NetProps.GetPropFloat(projectile, "m_flDamage")
            local crit = NetProps.GetPropBool(projectile, "m_bCritical")
            local model = projectile.GetModelName()

            projectile.Kill()
            local jar = SpawnEntityFromTable("tf_projectile_stun_ball", 
            {
            	targetname = "jar"
            })
            
            DispatchSpawn(jar)
            jar.SetOrigin(proj_origin)
            jar.SetPhysVelocity(phys)
            jar.SetTeam(team)
            jar.SetModelSimple(model)
            jar.SetModelScale(1.5, 0)
            
            jar.ValidateScriptScope()
            NetProps.SetPropVector(jar, "m_angRotation", rotation)
            local projscope = jar.GetScriptScope()

            if (crit == true)
            {
                projscope.crit <- true
            }
            else 
            {
                projscope.crit <- false
            }
            projscope.velocity <- velocity
            projscope.phys <- phys
            projscope.rotation <- rotation
            projscope.team <- NetProps.GetPropInt(owner, "m_iTeamNum")
            projscope.owner <- owner
            projscope.weapon <- weapon
            projscope.radius <- radius
            projscope.damage <- damage
            projscope.grenade <- false
            projscope.jarate <- false
            projscope.milk <- true
            projscope.gas <- false
            projscope.detonateTimer <- 0
            projscope.timeStopProj <- 5
            projscope.serverTime <- 0
            projscope.releaseProjectile <- false
            projscope.countTimeStuckProj <- function() 
            {
                //caberCountTime acts as time
                if (timeStopProj == null) return
                local time = floor(Time())
                if (time != serverTime) { // Once every second
                    serverTime = time
                    //printl(timeStopProj)
                    if (timeStopProj > 0)
                    {
                        timeStopProj--
                    }
                    if (timeStopProj == 0)
                    {
                        try delete self.GetScriptScope().ProjectileThinkTable.TimeIsStopped catch(e) return
                    }
                }
            }
            EntFireByHandle(jar, "RunScriptCode", "CreateTimeThinkProj(self)", 0.1, jar, null)
            continue
        }
        else if (projectile.GetClassname() == "tf_projectile_jar_gas")
        {
            //get all the projectile info again
            if (projectile == null || !projectile.IsValid()) continue
            local proj_origin = projectile.GetOrigin()
            local velocity = projectile.GetVelocity()
            local phys = GetPhysVelocity(projectile)
            local rotation = GetPhysAngularVelocity(projectile)

            local weapon = NetProps.GetPropEntity(projectile, "m_hLauncher")
            local owner = weapon.GetOwner()
            local team = owner.GetTeam()
            local radius = NetProps.GetPropFloat(projectile, "m_DmgRadius")
            local damage = NetProps.GetPropFloat(projectile, "m_flDamage")
            local crit = NetProps.GetPropBool(projectile, "m_bCritical")
            local model = projectile.GetModelName()

            projectile.Kill()
            local jar = SpawnEntityFromTable("tf_projectile_stun_ball", 
            {
            	targetname = "jar"
            })
            
            DispatchSpawn(jar)
            jar.SetOrigin(proj_origin)
            jar.SetPhysVelocity(phys)
            jar.SetTeam(team)
            jar.SetModelSimple(model)
            jar.SetModelScale(1.5, 0)
            
            jar.ValidateScriptScope()
            NetProps.SetPropVector(jar, "m_angRotation", rotation)
            local projscope = jar.GetScriptScope()

            if (crit == true)
            {
                projscope.crit <- true
            }
            else 
            {
                projscope.crit <- false
            }
            projscope.velocity <- velocity
            projscope.phys <- phys
            projscope.rotation <- rotation
            projscope.team <- NetProps.GetPropInt(owner, "m_iTeamNum")
            projscope.owner <- owner
            projscope.weapon <- weapon
            projscope.radius <- radius
            projscope.damage <- damage
            projscope.grenade <- false
            projscope.jarate <- false
            projscope.milk <- false
            projscope.gas <- true
            projscope.detonateTimer <- 0
            projscope.timeStopProj <- 5
            projscope.serverTime <- 0
            projscope.releaseProjectile <- false
            projscope.countTimeStuckProj <- function() 
            {
                //caberCountTime acts as time
                if (timeStopProj == null) return
                local time = floor(Time())
                if (time != serverTime) { // Once every second
                    serverTime = time
                    //printl(timeStopProj)
                    if (timeStopProj > 0)
                    {
                        timeStopProj--
                    }
                    if (timeStopProj == 0)
                    {
                        try delete self.GetScriptScope().ProjectileThinkTable.TimeIsStopped catch(e) return
                    }
                }
            }
            EntFireByHandle(jar, "RunScriptCode", "CreateTimeThinkProj(self)", 0.1, jar, null)
            continue
        }
        else 
        {
            continue
        }
    }
}

//CAULDRON STUFF

::CauldronThink <- function()
{
    tickSpell()
    return -1
}


function CastRandomSpell() 
{
    local spell = RandomInt(4, 4)

    //AFFECTS ALL 
    if (spell == 1)
    {
        CallTrickRoom()
    }
    else if (spell == 2)
    {
        SummonMeteors()
    }
    else if (spell == 3)
    {
        StopTime()
        //call again incase any projectiles arent caught
        EntFireByHandle(gamerules, "CallScriptFunction", "StopTime", -1, null, null)
    }
}
function SetUpCauldron() 
{
    cauldron = SpawnEntityFromTable("prop_dynamic",
    {
        model = "models/props_harbor/foundry_cauldron_harbor.mdl"
        origin = Vector(224.33, -832, 960)
        angles = Vector(0, 90, 0)
        targetname = "indicator_warn"
    })
    cauldron.ValidateScriptScope()
    local cauldronscope = cauldron.GetScriptScope()
    cauldronscope.castTime <- 5
    cauldronscope.serverTime <- 0
    cauldronscope.tickSpell <- function() 
    {
        //caberCountTime acts as time
        if (castTime == null) return
        local time = floor(Time())
        if (time != serverTime) { // Once every second
            serverTime = time
            printl(castTime)
            if (castTime > 0)
            {
                castTime--
            }
            if (castTime == 35)
            {
                if (isTrickRoomUp == true)
                {
                    for(local player; player = FindByClassname(player, "player");)
                    {
                        local maxspeed = NetProps.GetPropFloat(player, "m_flMaxspeed")
                        ClientPrint(player, 4, "The twisted dimensions have returned to normal!")
                        SetSkyboxTexture("blacksky")
                        try delete ::SetClassSpeed catch(e) return
                        if (maxspeed >= 300)
                        {
                            NetProps.SetPropFloat(player, "m_flMaxspeed", maxspeed / 2)
                        }
                        else if (maxspeed <= 300)
                        {
                            NetProps.SetPropFloat(player, "m_flMaxspeed", maxspeed * 2)
                        }
                    }
                    isTrickRoomUp = false
                }
            }
            if (castTime == 0)
            {
                CastRandomSpell()
                castTime = 45
            }
        }
    }
    AddThinkToEnt(cauldron, "CauldronThink")
}
//SetUpCauldron()






///////////////////////////////////////////////////////////SETUP HOOKS
/////////////////////////////////////////////////////////////////

//Set up detection for fake projectiles due to Time Stop

::HitboxDetect <- function () 
{
    function IntersectBoxBox(a_mins, a_maxs, b_mins, b_maxs) 
    {
        return (a_mins.x <= b_maxs.x && a_maxs.x >= b_mins.x) &&
            (a_mins.y <= b_maxs.y && a_maxs.y >= b_mins.y) &&
            (a_mins.z <= b_maxs.z && a_maxs.z >= b_mins.z)
    }
    local origin = self.GetOrigin()
    local player_mins = self.GetPlayerMins()
    local player_maxs = self.GetPlayerMaxs()
    local box_mins = self.GetBoundingMins()
    local box_maxs = self.GetBoundingMaxs()
    
    if (IntersectBoxBox(origin + player_mins, origin + player_maxs, box_mins, box_maxs))
    {
        printl("something")
    }


    self.SetForcedTauntCam(1)
    DebugDrawCircle(origin + Vector(0, 0, 55), Vector(34, 123, 34), 0, radius, true, 0.1)
    DebugDrawBox(origin, mins, maxs, 64, 123, 64, 0, 0.1)
}


/////////////MISC

::PumpkinHopper <- function () 
{
    local forwardvelo = self.EyeAngles().Forward()*250
    local velocity = self.GetVelocity()

    if (nojump == false)
    {
        self.AddCustomAttribute("no_jump", 1, 12)
        self.AddCustomAttribute("move speed bonus", 0.01, 12)
        self.AddCondEx(64, 12, null)
        //self.SetCustomModelWithClassAnimations("models/empty.mdl")
        nojump = true
    }
    if (!(self.GetFlags() & FL_ONGROUND))
    {
        self.SetVelocity(Vector(forwardvelo.x, forwardvelo.y, velocity.z))
    }
}

::TitanPyro <- function () 
{
    local eyepos_start = self.EyePosition()+self.EyeAngles().Forward()
    local eyepos_end = self.EyePosition()+self.EyeAngles().Forward()*1250

    local eyetrace = {
        start  = eyepos_start,
        end    = eyepos_end
        ignore = self
    }
    TraceLineEx(eyetrace)

    if (self.InCond(51))
    {
        self.SetScaleOverride(1.9)
        //self.SetModelScale(2.5, 10)
    }
    else 
    {
        growTime++
    }

    if (growTime == 10)
    {
        self.SetModelScale(2.5, 2)
    }

    if (eyetrace.hit && "enthit" in eyetrace && eyetrace.enthit.GetClassname() == "player")     
    {
        local hitPlayer = eyetrace.enthit
        if (hitPlayer == null) return
        if (hitPlayer.GetTeam() == self.GetTeam()) return
        if (hitPlayer.GetDisguiseTeam() == self.GetTeam()) return
        
        self.PressFireButton(0.1)
    } 
    else if(eyetrace.hit && "enthit" in eyetrace && eyetrace.enthit.GetClassname() == "obj_*")     
    {
        local hitObj = eyetrace.enthit
        if (hitObj == null) return
        if (hitObj.GetTeam() == self.GetTeam()) return
        
        self.PressFireButton(0.1)
    }
}
::TitanSniper <- function () 
{
    local origin = self.GetOrigin()

    local eyepos_start = self.EyePosition()+self.EyeAngles().Forward()
    local eyepos_end = self.EyePosition()+self.EyeAngles().Forward()*1750
    local sound_range = (40 + (20 * log10(300 / 36.0))).tointeger();

    local eyetrace = {
        start  = eyepos_start,
        end    = eyepos_end
        ignore = self
    }
    TraceLineEx(eyetrace)

    if (self.InCond(51))
    {
        self.SetScaleOverride(1.9)
        //self.SetModelScale(2.5, 10)
    }
    else 
    {
        growTime++
    }

    if (growTime == 10)
    {
        self.SetModelScale(2.5, 2)
    }

    if (eyetrace.hit && "enthit" in eyetrace && eyetrace.enthit.GetClassname() == "player")     
    {
        local hitPlayer = eyetrace.enthit
        if (hitPlayer == null) return
        if (hitPlayer.GetTeam() == self.GetTeam()) return
        if (hitPlayer.GetDisguiseTeam() == self.GetTeam()) return
        shoottime++

        if (laser == null)
        {
            laser = SpawnEntityFromTable("info_particle_system", 
            {
                effect_name = "merasmus_zap", 
                targetname = "laser"
                origin = origin
                angles = Vector(0, 0, 0)
            })
            laser.SetOrigin(origin + Vector(0, 0, 100))
            laser.SetAngles(RandomInt(-180, 180), 0, 0)
        }
        
        if (laser != null)
        {
            SetPropEntityArray(laser, "m_hControlPointEnts", hitPlayer, 0)
            EntFireByHandle(laser, "Start", "", 0.38, null, null)
            EntFireByHandle(laser, "Stop", "", 0.39, null, null)
            EntFireByHandle(laser, "Kill", "", 0.40, null, null)
            if (GetPropEntityArray(laser, "m_hControlPointEnts", 0) == hitPlayer && shoottime >= 40)
            {
                hitPlayer.TakeDamageEx(null, self, null, Vector(0, 0, 0), hitPlayer.GetOrigin(), 1, 1024)
                EmitSoundEx({
                    sound_name = "misc/halloween/spell_lightning_ball_impact.wav",
                    origin = hitPlayer.GetOrigin(),
                    sound_level = sound_range 
                });
                //EntFireByHandle(hitPlayer, "RunScriptCode", "self.TakeDamageEx(null, caller, null, Vector(0, 0, 0), self.GetOrigin(), 1, 1024)", 0.39, hitPlayer, self)
            }
            if (shoottime == 45)
            {
                shoottime = 0
            }
        }
        //laser.Kill()
        laser = null
    } 
    else 
    {
        EntFireByHandle(laser, "stop", "", -1, null, null)
        EntFireByHandle(laser, "Kill", "", 0.03, null, null)
        laser = null
    }
}

function MiscSetup() 
{
    PopExt.AddRobotTag("bot_revolver_spy", 
    {
		OnSpawn = function(bot, tag) {
			local gun = PopExtUtil.GiveWeapon(bot, "tf_weapon_revolver", 210)
            bot.SetCustomModelWithClassAnimations("models/bots/spy/bot_spy.mdl")
		}
	})
    PopExt.AddRobotTag("bot_titan", 
    {
		OnSpawn = function(bot, tag) {
			local fist = PopExtUtil.GiveWeapon(bot, "TF_WEAPON_FISTS", 195)
            if (bot.GetPlayerClass() == 7)
            {
                bot.ValidateScriptScope()
                local pyroscope = bot.GetScriptScope()
                fist.AddAttribute("fire rate bonus", 0.5, -1)
                pyroscope.growTime <- 0
                PopExtUtil.AddThinkToEnt(bot, "TitanPyro")
            }
            if (bot.GetPlayerClass() == 2)
            {
                bot.ValidateScriptScope()
                local sniperscope = bot.GetScriptScope()
                sniperscope.laser <- null
                sniperscope.shoottime <- 0
                sniperscope.growTime <- 0
                PopExtUtil.AddThinkToEnt(bot, "TitanSniper")
            }
		}
	})
    PopExt.AddRobotTag("bot_pumpkin", 
    {
		OnSpawn = function(bot, tag) 
        {
            bot.ValidateScriptScope()
            local tagscope = bot.GetScriptScope()
            tagscope.nojump <- false
			PopExtUtil.AddThinkToEnt(bot, "PumpkinHopper")
		}
	})
}
MiscSetup() 

function WarningAllPlayers() 
{
    SendGlobalGameEvent("show_annotation", {
        text = "Watch the tombs! Something might arise from them..."
        lifetime = 5
        worldPosX = 1686
        worldPosY = 2351
        worldPosZ = 896
        id = 4
        play_sound = "misc/null.wav"
        show_distance = false
        show_effect = false
        follow_entindex = 0
    })
}
function WarningTitans() 
{
    SendGlobalGameEvent("show_annotation", {
        text = "The TITANS are coming! Grab upgrades IMMEDIATELY!"
        lifetime = 5
        worldPosX = 1737
        worldPosY = 6219
        worldPosZ = 839
        id = 4
        play_sound = "misc/null.wav"
        show_distance = false
        show_effect = false
        follow_entindex = 0
    })
}

function OnScriptHook_OnTakeDamage(params) 
{
    local victim = params.const_entity
    local weapon = params.weapon
    local attacker = params.attacker
    local entity = params.inflictor
    local damage = params.damage

    if (victim.GetClassname() == "player")
    {
        if (victim.IsBotOfType(TF_BOT_TYPE))
        {
            if (victim.HasBotTag("bot_pumpkin"))
            {
                if (weapon != null && weapon.GetClassname() == "tf_weapon_minigun")
                {
                    damage *= 0.6
                }
                
                if (entity != null && entity.GetClassname() == "obj_sentrygun")
                {
                    damage *= 0.5
                }
            }
        }
    }
}


//player_spawn is too slow and can cause text to appear twice, this is faster
function OnGameEvent_post_inventory_application(params)
{
	local player = GetPlayerFromUserID(params.userid)
    local secondary = PopExtUtil.GetItemInSlot(player, 1)
    //printl(secondary)
    player.ValidateScriptScope()
    local playerscope = player.GetScriptScope()
    SetSkyboxTexture("blacksky")

    try delete self.GetScriptScope().PlayerThinkTable.TimeIsStopped catch(e) return

    //PlayerInArray(player)
}

//reset text on wave complete/fail

// commented out, i dont think players want something explained to them twice
// also causes text to play twice

// function OnGameEvent_mvm_wave_failed(params)
// {
//     local player = FindByClassname(null, "player")
//     if (spawn_text_player_list.find(player) != null)
//     {
//         spawn_text_player_list = []
//         return
//     }
// }

function OnGameEvent_mvm_wave_complete(params)
{
    local player = FindByClassname(null, "player")

    // NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", false)
    // player.ForceChangeTeam(5, false)
    // NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", true)
	if (spawn_text_player_list.find(player) != null)
    {
        spawn_text_player_list = []
        return
    }
}


__CollectGameEventCallbacks(this)