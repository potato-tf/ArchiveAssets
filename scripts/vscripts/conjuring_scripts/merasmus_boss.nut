///////////////////////////////////////////////////////////SETUP
/////////////////////////////////////////////////////////////////

//yes this popfile is a gigantic mess
//yes navigating the pop is a complete nightmare 
//yes this is neccesary dont ask why
// all by stardustspy with some help
//Night Fight Arena - Clash Royale OST Soundtrack Theme (Season 63)

::MASK_SOLID <- 33570827

PrecacheModel("models/props_mvm/robot_spawnpoint_warning.mdl")
PrecacheModel("models/empty.mdl")
PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper_fixed.mdl")
PrecacheModel("models/bots/merasmus/merasmus.mdl")
PrecacheModel("models/bots/pyro/bot_pyro.mdl")
PrecacheModel("models/weapons/c_models/c_bow/c_bow.mdl")
PrecacheModel("models/items/tf_gift.mdl")
PrecacheModel("models/bots/spy/bot_spy.mdl")
PrecacheSound("weapons/pipe_bomb1.wav")
PrecacheSound("weapons/jar_explode.wav")
PrecacheSound("weapons/gas_can_explode.wav")
PrecacheSound("weapons/bombinomicon_explode1.wav")
PrecacheSound("ui/halloween_boss_summoned_monoculus.wav")
PrecacheSound("ui/halloween_boss_summoned.wav")
PrecacheSound("vo/halloween_merasmus/sf12_appears01.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_staff_magic03.mp3")
PrecacheSound("misc/halloween/spell_lightning_ball_impact.wav")
PrecacheSound("items/powerup_pickup_crits.wav")
PrecacheSound("vo/halloween_merasmus/sf12_magic_backfire06.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_defeated01.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_grenades05.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_hide_idles08.mp3")
PrecacheSound("misc/halloween/merasmus_appear.wav")
PrecacheSound("vo/halloween_merasmus/sf12_found01.mp3")
PrecacheSound("misc/halloween/merasmus_disappear.wav")
PrecacheSound("vo/halloween_merasmus/sf12_defeated12.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_appears09.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_found02.mp3")
PrecacheSound("ambient/energy/electric_loop.wav")
PrecacheSound("vo/halloween_merasmus/sf12_ranged_attack04.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_ranged_attack07.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_magicwords03.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_magicwords06.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_appears10.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_magicwords10.mp3")
PrecacheSound("ambient/machines/electric_machine.wav")
PrecacheSound("misc/halloween/hwn_plumes_capture.wav")
PrecacheSound("misc/halloween/merasmus_death.wav")
PrecacheSound("ambient/medieval_thunder2.wav")
PrecacheSound("ambient/medieval_thunder3.wav")
PrecacheSound("ambient/medieval_thunder4.wav")
PrecacheSound("vo/halloween_merasmus/sf12_ranged_attack08.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_wheel_speed01.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_wheel_bloody02.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_found04.mp3")
PrecacheSound("weapons/explode2.wav")
PrecacheSound("vo/halloween_merasmus/sf12_staff_magic04.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_ranged_attack06.mp3")
PrecacheSound("misc/hologram_move.wav")
PrecacheSound("ambient/atmosphere/terrain_rumble1.wav")
PrecacheSound("vo/halloween_merasmus/sf12_found08.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_staff_magic13.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_magicwords09.mp3")
PrecacheSound("misc/halloween/spell_lightning_ball_cast.wav")
PrecacheSound("vo/halloween_merasmus/sf12_ranged_attack04.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_wheel_gravity02.mp3")
PrecacheModel("models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl")
PrecacheSound("vo/halloween_merasmus/sf12_leaving08.mp3")
PrecacheSound("merasmus_theme.mp3")
PrecacheSound("vo/halloween_merasmus/sf12_wheel_ghosts03.mp3")
PrecacheSound("misc/halloween/spell_athletic.wav")
PrecacheSound("misc/halloween/spell_skeleton_horde_cast.wav")
PrecacheModel("models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl")

PrecacheSound("ambient/explosions/explode_8.wav")

PrecacheSound("misc/halloween/skeleton_break.wav")

PopExtUtil.PrecacheParticle("merasmus_zap")

local boss_defeat = false

function PlayBossMusic()
{
    local gamerules = FindByClassname(null, "tf_gamerules")
    EntFireByHandle(gamerules, "RunScriptCode", "ClientPrint(null,3,`\x072dbe13Now Playing: \x07a11ae8Night Fight Arena - Clash Royale`);", 6, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 6, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 6, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 6, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 246, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 246, null, null)
    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `merasmus_theme.mp3`});", 246, null, null)
}

function TimerTag()
{
    ::TimerThink <- function()
    {
        self.RemoveCondEx(24, true)
        self.RemoveCondEx(27, true)
    }
    PopExt.AddRobotTag("bot_timer", 
    {
        OnSpawn = function(bot, tag)
        {
            local origin = bot.GetOrigin()
            local nav_delete = {}

            bot.Teleport(true, Vector(-1139, 3988, 544), false, QAngle(), false, Vector())
            bot.DisableDraw()
            bot.SetMoveType(MOVETYPE_NOCLIP + MOVETYPE_FLY, MOVECOLLIDE_DEFAULT) // completely stops a player in place
            bot.SetCollisionGroup(13)
            bot.SetSolid(0) // cannot be affected by trace but bot cannot be hit    
            bot.SetModelSimple("models/player/heavy.mdl")
            bot.AddCondEx(64, -1, null)
            PopExtUtil.AddThinkToEnt(bot, "TimerThink")

            local bot_win_temp = SpawnEntityFromTable("game_round_win", 
            {
                TeamNum = 3
                origin = Vector(480, 768, 752)
                force_map_reset = 1
                switch_teams = 0
                targetname = "win_temp"
            })

            if (boss_defeat == false)
            {
                EntFireByHandle(bot_win_temp, "RoundWin", "", 300, null, null)
                EntFireByHandle(MerasmusNamespace.gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `vo/halloween_merasmus/sf12_leaving08.mp3`});", 300, null, null)
            }
        }
	})
}
TimerTag()


function SummonRain()
{
    // Rain particles fix - replaces missing rain particles with sawmill rain
    // Kill old broken rain particles

    // for (local rain; rain = Entities.FindByClassname(rain, "info_particle_system");) {
    //     if (rain.GetName() == "end_pit_destroy_particle") continue
    //     EntFireByHandle(rain, "Kill", "", -1, null, null)
    // }


    // Spawn hand-placed sawmill rain particles
    local rain001 = [ Vector(1188, 7162, 1385) 
        Vector(1406, 3900, 2065) Vector(285, 4022, 1866) Vector(383, 4575, 1784) Vector(1419, 4788, 1775) 
        Vector(1618, 5618, 1629) Vector(928, 5895, 1522) Vector(663, 6615, 1440) Vector(1223, 8556, 1836)
        Vector(-337, 2734, 1703) Vector(1417, 2845, 1498) Vector(-952, 1165, 1450) Vector(672, 1081, 1466)
        Vector(665, 216, 1388) Vector(-707, 346, 1412) Vector(824 1835 1962) Vector(-207, 1705, 1824)
        Vector(2153, 5193, 1886) Vector(744, 3255, 1930)
    ]
    local rain002 = [Vector(-508, -2608, 1800), Vector(789, -2290, 1800), Vector(-324, -2694, 1800), Vector(-320, -3360, 1800)]
    foreach(vec in rain001) {
        SpawnEntityFromTable("info_particle_system", {
            origin = vec
            effect_name = "env_rain_001"
            start_active = 1
            flag_as_weather = 1
            targetname = "rain_summoned"
        })
    }
    foreach(vec in rain002) {
        SpawnEntityFromTable("info_particle_system", {
            origin = vec
            effect_name = "env_rain_002_256"
            start_active = 1
            flag_as_weather = 1
            targetname = "rain_summoned"
        })
    }
    EntFireByHandle(MerasmusNamespace.gamerules, "CallScriptFunction", "StopRain", 22, null, null)
}

function StopRain() 
{
    for(local rain; rain = FindByName(rain, "rain_summoned");)
    {
        rain.Kill()
    }
}

function StopEarthquake() 
{
    for(local earthquake; earthquake = FindByName(earthquake, "particle_quake");)
    {
        earthquake.Kill()
    }
    EmitSoundEx
    ({
        sound_name = "ambient/atmosphere/terrain_rumble1.wav",
        flags = SND_STOP
    });

    try delete ::EarthquakeThink catch(e) return
}

function BossSpawnAnimation()
{
    local anim = SpawnEntityFromTable("prop_dynamic",
    {
        model = "models/bots/merasmus/merasmus.mdl"
        origin = Vector(1147, 7468, 480)
        angles = Vector(0, 270, 0)
        DefaultAnim = "primary_death_burning"
        targetname = "merasmus_animation"
    })

    anim.SetPlaybackRate(-1);

    // AddThinkToEnt(anim, "OnAnimThink");
}

function RespawnBombCarrier()
{
    local intel = FindByName(null, "intel_ironman")
    local runner = null
    local spawn = FindByName(null, "spawnbot_giant")

    intel.AcceptInput("ForceReset", "", null, null)
    for (local player; player = FindByClassname(player, "player");)
    {
        if (player.IsBotOfType(TF_BOT_TYPE))
        {
            if (player.HasBotTag("bot_runner"))
            {
                local intel_origin = intel.GetOrigin()
                local spawn_origin = spawn.GetOrigin()

                player.Teleport(true, spawn_origin, false, QAngle(), false, Vector(0, 0, 0))
                intel.SetOrigin(player.GetOrigin())
            }
        }
    }
}
/////////////BOSS

::MerasmusThink <- function () 
{
    local origin = self.GetOrigin()
    local melee = PopExtUtil.GetItemInSlot(self, 2)
    local primary = PopExtUtil.GetItemInSlot(self, 0)
    local merasmus_buttons = NetProps.GetPropInt(self, "m_nButtons");
    local merasmus_buttons_changed = merasmus_buttons_last ^ merasmus_buttons;
    local merasmus_buttons_pressed = merasmus_buttons_changed & merasmus_buttons;
    local merasmus_buttons_released = merasmus_buttons_changed & (~merasmus_buttons);

    local eyepos_start = self.EyePosition()+self.EyeAngles().Forward() *100
    local eyepos_end = null
    if (laser_mode == 1)
    {
        eyepos_end = self.EyePosition()+self.EyeAngles().Forward()*925
    }
    else 
    {
        eyepos_end = self.EyePosition()+self.EyeAngles().Forward()*1850
    }
    local eyelook = self.EyeAngles()
    local wep_active_merasmus = self.GetActiveWeapon()
    local sound_range = (40 + (20 * log10(300 / 36.0))).tointeger();

    local maxhealth = self.GetMaxHealth()
    local health = self.GetHealth()

    if (health > 1000)
    {
        self.AddCondEx(70, -1, null)
    }

    local mins = self.GetPlayerMins()
    local maxs = self.GetPlayerMaxs()

    local classnames = 
    {
        "player" : 1
        "obj_sentrygun" : 1
        "obj_dispenser": 1
        "obj_teleporter" : 1
        "entity_medigun_shield" : 1
    }

    SetPropBool(self, "m_bForcedSkin", true)
    SetPropInt(self, "m_nForcedSkin", 1)

    //anti-stuck

    //how it works: first we insert 2 unchanging variables: a null variable and a number
    //then we tick up the number constantly, just below
    //if the number reaches 10, document the current origins in the null variable (Vector_Compare)
    //if the number reaches 50, compare that variable to the current origin
    //if the x value of the current origin is the exact same as the stored variable, assume boss is stuck
    //then force a teleport, and reset the counter

    //the only reason we have the cond checks is to ensure Merasmus isn't classified as "stuck" when casting a spell
    //avoid this from happening by ensuring that the stuck check never goes off if merasmus is casting a spell

    if (!self.InCond(87))
    {
        stuckTime++
    }

    if (stuckTime == 10 && (self.InCond(87))) // cant teleport if casting a spell)
    {
        Vector_Compare = origin
    }

    if (stuckTime == 50 && (self.InCond(87))) // cant teleport if casting a spell)
    {
        if (Vector_Compare.x == origin.x)
        {
            //printl("we stuck :(")
            //MerasmusNamespace.UnstuckEntity(self)

            //rather then using lites stuck fix, we will just force a standard teleport since that will likely put merasmus
            //in a better position if he is bodyblocked into a corner, for example
            local tele_spots = {}
            GetNavAreasInRadius(origin, 1000, tele_spots)

            FindRandomSpot(tele_spots)

            NoAction = true
            MerasmusNamespace.UnstuckEntity(self)
        }
        stuckTime = 0
    }

    for (local player; player = FindByClassname(player, "player");)
    {
        if (player.IsBotOfType(TF_BOT_TYPE))
        {
            if (player.HasBotTag("bot_hitbox"))
            {
                local primary = PopExtUtil.GetItemInSlot(player, 0)
                player.SetMoveType(MOVETYPE_NOCLIP + MOVETYPE_FLY, MOVECOLLIDE_DEFAULT) // completely stops a player in place
                player.SetAbsOrigin(self.GetOrigin() + Vector(0, 0, 47))
                //player.AddCondEx(64, -1, null)
                player.DisableDraw()
                if (primary != null)
                {
                    primary.DisableDraw()
                }
                //player.SetCollisionGroup(13)
               // player.SetSolid(0) // cannot be affected by trace but bot cannot be hit

            }
        }
    }

    function SummonSkeletons()
    {
        local spawn_skele_spots = {}
        GetNavAreasInRadius(self.GetOrigin(), 300, spawn_skele_spots)

        local minareasize = 1500;
        local spots = []

        foreach(id, nav in spawn_skele_spots)
        {
            if (nav.GetSizeX() * nav.GetSizeY() > minareasize)
            {
                spots.append(nav)
                //PopExtUtil.PrintTable(spots)
                nav_area_num++
            }
        }

        for (local player; player = FindByClassname(player, "player");)
        {
            if (player.IsBotOfType(TF_BOT_TYPE) && player.GetTeam() != TEAM_SPECTATOR)
            {
                if (player.HasBotTag("bot_skeleton"))
                {
                    if (!player.InCond(64)) continue
                    local nav = spots[RandomInt(0, nav_area_num - 1)]
                    local spot = nav.FindRandomSpot()
                    local wep = player.GetActiveWeapon()
                    player.AddCustomAttribute("no_jump", 1, 3)
                    player.AddCustomAttribute("no_duck", 1, 3)
                    player.AddCustomAttribute("no_attack", 1, 3)
                    player.AddCustomAttribute("clip size penalty", 0.15, 3.2)
                    player.AddCustomAttribute("move speed penalty", 0.0001, 3)
                    player.Teleport(true, spot + Vector(0, 0, 50), false, QAngle(), false, Vector(0, 0, 0))
                    EntFireByHandle(player, "RunScriptCode", "self.RemoveCondEx(64, true)", 3, null, null)
                    MerasmusNamespace.UnstuckEntity(player)

                    wep.SetClip1(1)
                    
                    player.AddCondEx(5, 3, null)

                    local skele_anim = SpawnEntityFromTable("prop_dynamic",
                    {
                        model = "models/bots/skeleton_sniper/skeleton_sniper_fixed.mdl"
                        origin = player.GetOrigin() + Vector(0, 0, -60)
                        angles = player.GetAbsAngles()
                        targetname = "skele_anim"
                        skin = 1
                    })
                    skele_anim.ResetSequence(RandomInt(4, 10))
                    EntFireByHandle(skele_anim, "Kill", "", 3, null, null)
                }
            }
        }
    }

    function DoAnimation(boss, anim_sequence_name, duration, model)
    {
        self.SetMoveType(MOVETYPE_NOCLIP + MOVETYPE_FLY, MOVECOLLIDE_DEFAULT) // completely stops a player in place
        self.SetCustomModelWithClassAnimations("models/empty.mdl")

        EntFireByHandle(self, "RunScriptCode", "self.SetMoveType(2, MOVECOLLIDE_DEFAULT)", duration, self, null)
        self.AddCondEx(87, duration, null) // prevent from doing anything such as turning
        self.AddCondEx(65, duration + 1.75, null) // check for if animation is in progress
        self.AddCustomAttribute("no_attack", 1, duration)
        EntFireByHandle(self, "SetCustomModelWithClassAnimations", model, duration, null, null)
        anim = SpawnEntityFromTable("prop_dynamic",
        {
            model = "models/bots/merasmus/merasmus.mdl"
            origin = origin
            angles = self.GetAbsAngles() // use absangles since eyeposition can cause merasmus to turn up or down weirdly
            targetname = "merasmus_animation"
        })
        anim.ResetSequence(anim.LookupSequence(anim_sequence_name))
        EntFireByHandle(anim, "Kill", "", duration, null, null)
        if (NUM_MAX_SPELL_TIER == 0)
        {
            NUM_MAX_SPELL_TIER = 3
        }
    }

    ///////////main attack: laser

    function GetAllEnemyTargets(enemy)
    {
        // Check if the enemy is already in the target array, or if it's dead
        if (targetArray.find(enemy) != null) return
        if (NetProps.GetPropInt(enemy, "m_lifeState") != 0) return

        // Add the enemy to the target array
        targetArray.append(enemy)

        local best_distance = null

        // Get the origin of the entity we're comparing distances to
        local origin = enemy.GetOrigin()

        foreach (target in targetArray)
        {
            local target_origin = target.GetOrigin()
            local vec = origin - target_origin

            // Compute the length of the vector (distance between points)
            local distance = vec.Length()

            // If this is the first target or a closer target, update the best distance and targeted enemy
            if (best_distance == null || distance < best_distance)
            {
                best_distance = distance
                targeted = target
            }
        }
    }

    //# ENABLE THIS
    
    //Special AI used to allow Merasmus to attack with ranged melee

    //i had some code here b4 but i cant do math so i had chatgpt write the code :trollskull:

    // Function to calculate the distance between two vectors (origin and ent origin)
    function CalculateDistance(ent) 
    {
        local ent_origin = ent.GetOrigin();
        local vec = origin - ent_origin;
        return vec.Length();
    }

    // Main loop to find all entities in range and select the closest one
    function FindClosestEntity() 
    {
        targetArray.clear(); // Clear the target array before starting

        local closest_distance = null; // To track the shortest distance
        targeted = null;               // Reset targeted

        local ent = null; // Initialize ent to null for the loop
        for (ent = FindInSphere(ent, origin, 2000); ent != null; ent = FindInSphere(ent, origin, 2000)) 
        {
            // Check if the entity is valid and from a different team
            if (ent.GetClassname() in classnames && ent.GetTeam() != TEAM_SPECTATOR && ent.GetTeam() != self.GetTeam()) 
            {
                //is ent invisible or disguised

                if (ent.GetClassname() == "player" && ent.GetDisguiseTeam() == self.GetTeam() || ent.GetClassname() == "player" && ent.InCond(4)) continue

                // Check if the entity is not already in the target array
                if (targetArray.find(ent) == null) 
                {
                    local distance = CalculateDistance(ent);  // Calculate the distance
                    targetArray.append({"entity": ent, "distance": distance});  // Add entity and its distance to the array
                }

                // Print the updated targetArray with entities and their distances
               // PopExtUtil.PrintTable(targetArray);

                // Now compare distances to find the closest entity
                foreach (target in targetArray) 
                {
                    local dist = target.distance;
                    if (closest_distance == null || dist < closest_distance) 
                    {
                        closest_distance = dist;
                        targeted = target.entity;  // Set the closest entity as the targeted one
                    }
                }
            }
        }

        // After the loop, print the targeted entity (the one with the shortest distance)
        if (targeted != null) 
        {
            //printl("Targeted entity: " + targeted);
            aibot.LookAt(targeted.GetOrigin(), 1950, 1950)
            self.PressFireButton(0.1)
        }
    }

    // Call the function to find the closest entity
    FindClosestEntity();

    local eyetrace = 
    {
        start  = eyepos_start,
        end    = eyepos_end
        hullmin = Vector(-10, -10, -10)
        hullmax = Vector(10, 10, 10)
        mask = 33636363
        ignore = self
    }
    TraceHull(eyetrace)

    function SpawnLaser(ent, rand_intmin, rand_intmax) 
    {
        local sound_range = (40 + (20 * log10(300 / 36.0))).tointeger();
        
        local target = SpawnEntityFromTable("info_target", 
        {
            effect_name = "merasmus_targ", 
            spawnflags = 1
            origin = Vector(0, 0, 0) //self.EyeAngles().Forward()*300
            angles = Vector(0, 0, 0)
        })
        laser = SpawnEntityFromTable("info_particle_system", 
        {
            effect_name = "merasmus_zap_beam_bits", 
            targetname = "laser"
            origin = self.GetOrigin()
            angles = Vector(0, 0, 0)
        })
        
        if (target == null) return
        
        if (ent == null && target != null)
        {
            if (laser_mode == 1)
            {
                target.SetAbsOrigin(eyetrace.end + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0))
            }
            else 
            {
                target.SetAbsOrigin(eyetrace.end + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0))
            }
        }
        else if (ent != null && target != null)
        {
            if (laser_mode == 1)
            {
                target.SetAbsOrigin(ent.GetOrigin() + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0)) // problem
            }
            else 
            {
                target.SetAbsOrigin(ent.GetOrigin() + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0))
            }
            
        }

        SetPropEntityArray(laser, "m_hControlPointEnts", target, 0)
        laser.SetAbsOrigin(origin + Vector(0, RandomInt(rand_intmin, rand_intmax), 80))
        laser.SetAbsAngles(eyelook)

        for (local enemy; enemy = FindInSphere(enemy, target.GetOrigin(), 25);)
        {
            if (ent == null) continue
            if (enemy != ent) continue

            local damage = 40

            if (ent.GetClassname() != "player")
            {
                ent.TakeDamageEx(null, self, null, Vector(0, 0, 0), ent.GetOrigin(), damage * 2, 2)
            }
            else if (ent.GetClassname() == "player")
            {
                if (ent.GetDisguiseTeam() == 2 || ent.GetDisguiseTeam() == 3 || ent.InCond(4))
                {
                    damage = damage * 0.2
                }
                ent.TakeDamageEx(null, self, null, Vector(0, 0, 0), ent.GetOrigin(), damage, 2)
            }
        }
        
        EmitSoundEx({
            sound_name = "misc/halloween/spell_lightning_ball_impact.wav",
            origin = target.GetOrigin(),
            sound_level = sound_range 
        });
        EntFireByHandle(laser, "Start", "", 0.1, null, null)
        target.AcceptInput("SetParent", "!activator", laser, target) // causes weird particle placement if placed before firing particle
        EntFireByHandle(laser, "Stop", "", 0.2, null, null)
        EntFireByHandle(laser, "Kill", "", 0.3, null, null)
        EntFireByHandle(target, "Kill", "", 0.3, null, null)
        //DebugDrawBox(target.GetOrigin(), Vector(-10, -10, -10), Vector(10, 10, 10), 132, 55, 75, 0, 2)
        // DebugDrawBox(laser.GetOrigin(), Vector(-10, -10, -10), Vector(10, 10, 10), 132, 55, 75, 0, 2)
    }
    
    if (!self.InCond(51) && !self.HasBotTag("bot_transform"))
    {
        switch_spell_mode()
    }

	if (NetProps.GetPropInt(self, "m_Shared.m_iNextMeleeCrit") == 0)
	{
		if (self.GetActiveWeapon() == melee)
		{
            if (eyetrace.hit && eyetrace.enthit.GetClassname() in classnames)
            {
                local enemy = eyetrace.enthit

                if (enemy.GetClassname() == "entity_medigun_shield")
                {
                    printl(enemy)
                    local shield_owner = enemy.GetOwner()
                    printl(shield_owner)
                    local rage = shield_owner.GetRageMeter()

                    if (laser_mode == 1)
                    {
                        shield_owner.AddCustomAttribute("increase buff duration HIDDEN", 0.17, 0.09)
                    }
                    else 
                    { 
                        shield_owner.AddCustomAttribute("increase buff duration HIDDEN", 0.39, 0.3)
                    }

                    // NetProps.SetPropBool(shield_owner, "m_bRageDraining", false)
                    // shield_owner.SetRageMeter(33)
                    // NetProps.SetPropFloat(shield_owner, "m_flRageMeter", 0)
                }
                
                if (enemy.GetTeam() != self.GetTeam() && enemy.GetTeam() != TEAM_SPECTATOR)
                {
                    if (laser_mode == 0)
                    {
                        SpawnLaser(enemy, 0, 0)
                    }
                    else 
                    {

                        for(local L = 0; L <= 4; L++)
                        {
                            if (enemy == null) continue
                           // printl("multi attack")
                            SpawnLaser(enemy, -40, 40) 
                        }
                    }
                }
                else 
                {
                    if (laser_mode == 0)
                    {
                        SpawnLaser(null, 0, 0)
                    }
                    else 
                    {

                        for(local L = 0; L <= 4; L++)
                        {
                            if (enemy == null) continue
                           // printl("multi attack")
                            SpawnLaser(null, -40, 40) 
                        }
                    }
                }
            }
            else 
            {
                //something was hit but isn't relavent (i.e. worldspawn)
                if (laser_mode == 0)
                {
                    SpawnLaser(null, 0, 0)
                }
                else 
                {
                    for(local L = 0; L <= 4; L++)
                    {
                       // printl("multi attack")
                        SpawnLaser(null, -40, 40)
                    }
                }
            }
            
		}
		
		// continue smack detection
		NetProps.SetPropInt(self, "m_Shared.m_iNextMeleeCrit", -2)
	}

    //////////////TELEPORTING

    function FindRandomSpot(table)
    {
        //my dumbass spent too long figuring out how a table/arrays works, this is for reference

        //navs cannot be inserted into tables, only arrays (or the "{}")
        //however these cannot be appended, and as such GetAllAreas is used to collect all the areas
        //then an empty table is made
        //the foreach gets every nav in the array, places it into the "spot" table, then appends it, giving it a number
        local minareasize = 1500;
        local spots = []
        local num = RandomInt(1, 2)
        //TF_NAV_SPAWN_ROOM_BLUE
        //TF_NAV_SPAWN_ROOM_RED
        foreach(id, nav in table)
        {
            if (nav.GetSizeX() * nav.GetSizeY() > minareasize && !nav.HasAttributeTF(TF_NAV_SPAWN_ROOM_RED) && !nav.HasAttributeTF(TF_NAV_SPAWN_ROOM_BLUE) && nav.IsReachableByTeam(3))
            {
                spots.append(nav)
            }
        }
        
        local nav = spots[RandomInt(0, spots.len() - 1)]
        local spot = nav.FindRandomSpot()

        local pos = self.GetOrigin()

        self.Teleport(true, spot + Vector(0, 0, 50), false, QAngle(), false, Vector(0, 0, 0))
        Vector_Compare = origin

        NetProps.SetPropBool(self, "m_bGlowEnabled", true)
        EntFireByHandle(self, "RunScriptCode", "NetProps.SetPropBool(self, `m_bGlowEnabled`, false)", 5, self, self)

        local num = RandomInt(1, 5)

        if (num == 1)
        {
            EmitSoundEx({
                sound_name = "vo/halloween_merasmus/sf12_found01.mp3", // huzzah
                origin = origin,
            });
        }
        else if (num == 2)
        {
            EmitSoundEx({
                sound_name = "vo/halloween_merasmus/sf12_appears09.mp3", // maniacal laugh
                origin = origin,
            });
        }
        else if (num == 3)
        {
            EmitSoundEx({
                sound_name = "vo/halloween_merasmus/sf12_found04.mp3", // 
                origin = origin,
            });
        }
        else if (num == 4)
        {
            EmitSoundEx({
                sound_name = "vo/halloween_merasmus/sf12_appears10.mp3", // 
                origin = origin,
            });
        }
        else if (num == 5)
        {
            EmitSoundEx({
                sound_name = "vo/halloween_merasmus/sf12_found02.mp3", // 
                origin = origin,
            });
        }


        EmitSoundEx({
            sound_name = "misc/halloween/merasmus_appear.wav",
            origin = origin,
        });

        local teleport = SpawnEntityFromTable("info_particle_system", 
        {
            effect_name = "merasmus_tp", 
            targetname = "telep"
            origin = origin
            angles = Vector(0, 0, 0)
        })

        EntFireByHandle(teleport, "Start", "", 0, null, null)
        EntFireByHandle(teleport, "Stop", "", 0.1, null, null)
        EntFireByHandle(teleport, "Kill", "", 0.2, null, null)
        teleport = null 
    }

    // # 1, 300
    local TeleportRand = RandomInt(1, 300)
    
    if (TeleportRand == 1 && NoAction == false && !self.HasBotTag("bot_transform") && !self.InCond(51) && !self.InCond(87))
    {
        local tele_spots = {}
        GetNavAreasInRadius(origin, 1000, tele_spots)

        FindRandomSpot(tele_spots)

        NoAction = true
        TimerNoAction = 0
        MerasmusNamespace.UnstuckEntity(self)
    }
    //printl(TimerNoAction)
    if (TimerNoAction >= 600)
    {
        NoAction = false
        TimerNoAction = 0
    }
    if (NoAction == true)
    {
        TimerNoAction++
    }


    ///////////////////////////PHASES

    //TRANSFORM

    if (health <= maxhealth / 1.5 && phase == 0 && !self.InCond(65) && !self.InCond(87))
    {
        if (!self.HasBotTag("bot_transform") && anim == null && is_disguising == 0)
        {
            self.RemoveWeaponRestriction(3)
            self.AddBotTag("bot_transform")
            phase = 1

            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_ranged_attack06.mp3",
                origin = self.GetOrigin(),
            });
            self.AddCustomAttribute("dmg taken increased", 0, 2) 

            MerasmusNamespace.disguise_boss_health = 15000
            DoAnimation(self, "leave", 2, "models/bots/soldier/bot_soldier.mdl")
            //self.SetModelScale(2, 2)
            local weapon = PopExtUtil.GiveWeapon(self, "tf_weapon_rocketlauncher", 205)
            weapon.AddAttribute("damage bonus", 2, -1)
            weapon.AddAttribute("faster reload rate", 0.4, -1)
            weapon.AddAttribute("fire rate bonus", 0.45, -1)
            weapon.AddAttribute("clip size upgrade atomic", 2, -1)
           // weapon.AddAttribute("health regen", 5, -1)
            weapon.AddAttribute("disable weapon switch", 1, -1)
            weapon.AddAttribute("provide on active", 1, -1)
            weapon.AddAttribute("move speed penalty", 0.78, -1)
            self.AddCondEx(56, -1, self)
            self.Weapon_Switch(primary)
            self.AddWeaponRestriction(0)
            attackTime = 4
            MerasmusNamespace.UnstuckEntity(self)
            NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", "boss_merasmus");
            EntFireByHandle(self, "RunScriptCode", "NetProps.SetPropString(self, `m_PlayerClass.m_iszClassIcon`, `boss_merasmus`);", 1, self, self)
        }
    }
    else if (health <= maxhealth / 2 && phase == 1 && !self.InCond(65) && !self.InCond(87))
    {
        if (!self.HasBotTag("bot_transform") && anim == null && is_disguising == 0)
        {
            phase = 2

            NUM_MAX_SPELL_TIER = 6

            self.SetPlayerClass(4);
            SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 4);
            self.RemoveWeaponRestriction(3)
            self.AddCustomAttribute("dmg taken increased", 0, 2) 
            self.AddBotTag("bot_transform")
            MerasmusNamespace.disguise_boss_health = 17500

            DoAnimation(self, "leave", 2, "models/bots/demo/bot_demo.mdl")

            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_ranged_attack07.mp3",
                origin = self.GetOrigin(),
            });

            local weapon = PopExtUtil.GiveWeapon(self, "TF_WEAPON_GRENADELAUNCHER", 206)
            weapon.AddAttribute("fire rate bonus", 0.25, -1)
            weapon.AddAttribute("faster reload rate", 0.45, -1)
            weapon.AddAttribute("damage bonus", 1.5, -1)
           // weapon.AddAttribute("health regen", 10, -1)
            weapon.AddAttribute("move speed penalty", 0.78, -1)
            weapon.AddAttribute("clip size upgrade atomic", 2, -1)
            weapon.AddAttribute("disable weapon switch", 1, -1)
            weapon.AddAttribute("provide on active", 1, -1)
            self.AddCondEx(56, -1, self)
            self.Weapon_Switch(primary)
            self.AddWeaponRestriction(0)
            attackTime = 4
            MerasmusNamespace.UnstuckEntity(self)
            NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", "boss_merasmus");
            EntFireByHandle(self, "RunScriptCode", "NetProps.SetPropString(self, `m_PlayerClass.m_iszClassIcon`, `boss_merasmus`);", 1, self, self)
        }
    }
    else if (health <= maxhealth / 3 && phase == 2 && !self.InCond(65) && !self.InCond(87))
    {
        phase = 3
        NUM_MAX_SPELL_TIER = 9
        self.SetPlayerClass(7);
        SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", 7);
        self.RemoveWeaponRestriction(3)
        self.AddBotTag("bot_transform")
        self.AddCustomAttribute("dmg taken increased", 0, 2) 
        MerasmusNamespace.disguise_boss_health = 17500
        //self.SetCustomModelWithClassAnimations("models/bots/pyro/bot_pyro.mdl")
        DoAnimation(self, "leave", 2, "models/bots/pyro/bot_pyro.mdl")

        EmitSoundEx
        ({
            sound_name = "vo/halloween_merasmus/sf12_ranged_attack04.mp3",
            origin = self.GetOrigin(),
        });
        //self.SetModelScale(2, 2)
        local weapon = PopExtUtil.GiveWeapon(self, "tf_weapon_rocketlauncher_fireball", 1178)
        weapon.AddAttribute("mult_item_meter_charge_rate", 0.8, -1)
        //weapon.AddAttribute("health regen", 10, -1)
        weapon.AddAttribute("move speed penalty", 0.78, -1)
        weapon.AddAttribute("disable weapon switch", 1, -1)
        weapon.AddAttribute("provide on active", 1, -1)
        self.AddCondEx(56, -1, self)
        self.Weapon_Switch(primary)
        self.AddWeaponRestriction(0)
        attackTime = 4
        MerasmusNamespace.UnstuckEntity(self)
        NetProps.SetPropString(self, "m_PlayerClass.m_iszClassIcon", "boss_merasmus");
        EntFireByHandle(self, "RunScriptCode", "NetProps.SetPropString(self, `m_PlayerClass.m_iszClassIcon`, `boss_merasmus`);", 1, self, self)
    }

    //SPELLS

    //# ENABLE THIS
    if (phase >= 1 && !self.HasBotTag("bot_transform") && anim == null && NoCastSpell == false)
    {
        local use_spell = RandomInt(1, 500)
        check_spell_cast()
        if (use_spell == 1 || force_cast_Timer == 0)
        {
            self.PressAltFireButton(0.1)
        }
    }

    //printl(force_cast_Timer)
    if (anim != null && !self.InCond(87))
    {
        anim = null
    }


    if (NoCastSpell = true)
    {
        TimerNoCastSpell++
    }
    if (TimerNoCastSpell >= 235)
    {
        NoCastSpell = false
    }
    
   // printl(force_cast_Timer)
   //printl(force_cast_Timer)
    if (merasmus_buttons_pressed & Constants.FButtons.IN_ATTACK2 && tickspell == false && NUM_MAX_SPELL_TIER > 0)
	{
        // # DISABLE THIS
       // NUM_MAX_SPELL_TIER = 9

        spell_number = RandomInt(1, NUM_MAX_SPELL_TIER)
        
        tickspell = true
        NoCastSpell = true
        attackTime = 3
        NoAction = true
        //self.AddCondEx(64, 3, null)
        DoAnimation(self, "zap_attack", 3, "models/bots/merasmus/merasmus.mdl")
        force_cast_Timer = 8
        TimerNoCastSpell = 0

        //incase merasmus moves further then intended
        // self.AddCustomAttribute("no_jump", 1, 3)
		// self.AddCustomAttribute("no_duck", 1, 3)
		// self.AddCustomAttribute("no_attack", 1, 3)
		// self.AddCustomAttribute("disable weapon switch", 1, 3)
        // self.AddCustomAttribute("move speed penalty", 0.0001, 3)

        if (spell_number == 1)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_staff_magic03.mp3",
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 2)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_ranged_attack08.mp3",
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 3)
        {
            local max_particles = 0
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_wheel_bloody02.mp3", // BLOOD LETTING!!!!!!!!!!!!!!!!!
                origin = self.GetOrigin(),
            });
            local burn_indicator = {}
            GetNavAreasInRadius(origin, 500, burn_indicator)
            
            foreach(nav in burn_indicator)
            {
                if (max_particles <= 10)
                local area = nav.GetCenter()
                local particle = SpawnEntityFromTable("info_particle_system", 
                {
                    effect_name = "eb_aura_angry01", 
                    targetname = "particle_blood"
                    origin = area
                    angles = Vector(0, 0, 0)
                })
                EntFireByHandle(particle, "Start", "", 0.1, null, null)
                EntFireByHandle(particle, "Kill", "", 3, null, null)
                max_particles++
            }
        }
        else if (spell_number == 4)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_magicwords06.mp3",
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 5)
        {
            SummonSkeletons()
            EmitSoundEx
            ({
                sound_name = "misc/halloween/spell_skeleton_horde_cast.wav",
                origin = self.GetOrigin(),
            });
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_wheel_ghosts03.mp3",
                origin = self.GetOrigin(),
            });
            DispatchParticleEffect("halloween_ghost_smoke", self.GetOrigin(), Vector(0, 0, 0))
            //EntFireByHandle(gamerules, "CallScriptFunction", "SummonSkeletons", 3, null, null)
        }
        else if (spell_number == 6)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_magicwords10.mp3",
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 7)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_grenades05.mp3"
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 8)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_magicwords09.mp3"
                origin = self.GetOrigin(),
            });
        }
        else if (spell_number == 9)
        {
            EmitSoundEx
            ({
                sound_name = "vo/halloween_merasmus/sf12_magicwords03.mp3"
                origin = self.GetOrigin(),
            });
        }
	}

    if (self.GetMoveType() == 2)
    {
        tickspell = false
        nav_area_num = 0
    }

    if (tickspell == true)
    {
        cast_spell(spell_number)
    }

    // # ENABLE THIS
    if (self.HasBotTag("bot_transform") && !self.InCond(87))
    {
        ClientPrint(null, 4, "DISGUISE HEALTH: "+floor(MerasmusNamespace.disguise_boss_health))
        self.SetModelScale(2, 0)
    }
    else 
    {
        self.AddWeaponRestriction(3)
        self.SetModelScale(1, 0)
    }

    merasmus_buttons_last = merasmus_buttons;
}

::ChainThink <- function () 
{
    self.SetAbsOrigin(merasmus.GetOrigin() + Vector(0,0 , 50))

    return -1 // not supported by popextutil, needed here
}

::TornadoThink <- function () 
{
    self.SetModelSimple("models/empty.mdl")
    if (particle == null || particle.IsValid() == false)
    {
        local sound_range = (40 + (20 * log10(300 / 36.0))).tointeger();
        particle = SpawnEntityFromTable("info_particle_system", 
        {
            effect_name = "set_taunt_saharan_spy", 
            targetname = "particle_tornado"
            origin = self.GetOrigin()
            angles = Vector(0, 0, 0)
        })

        EmitSoundEx
        ({
            sound_name = "misc/halloween/hwn_plumes_capture.wav",

            origin = self.GetOrigin(),
            sound_level = sound_range 
        });
        EntFireByHandle(particle, "SetParent", "!activator", 0, self, null)
        //self.SetAbsOrigin(self.GetOrigin())
        EntFireByHandle(particle, "Start", "", -1, null, null)
        EntFireByHandle(particle, "Kill", "", 3, null, null)
    }

    for (local player; player = FindByClassnameWithin(player, "player", self.GetOrigin(), 150);)
    {
        if (player.GetTeam() != merasmus.GetTeam() && player.GetTeam() != TEAM_SPECTATOR)
        {
            player.TakeDamageEx(null, merasmus, null, Vector(0, 0, Vector(0, 0, 0)), self.GetOrigin(), 1, 128)
            player.SetVelocity(Vector(RandomInt(-425, 425), RandomInt(-125, 125), 700))
        }
    }
}

::GravWellThink <- function() 
{
    local touched = NetProps.GetPropBool(self, "m_bTouched")
    local sound_range = (40 + (20 * log10(3000 / 36.0))).tointeger();
    local gamerules = FindByClassname(null, "tf_gamerules")
    local origin = self.GetOrigin()
    local classnames = 
    {
        "player" : 1
        "obj_sentrygun" : 1
        "obj_dispenser": 1
        "obj_teleporter" : 1
        "entity_medigun_shield" : 1
    }
    for (local ent; ent = FindInSphere(ent, origin, 150);)
    {
        //i would use a basic for loop, but i cant be bothered. 
        if (ent.GetClassname() in classnames && ent.GetTeam() != TEAM_SPECTATOR && ent.GetTeam() != merasmus.GetTeam())
        {
            //no buildings
            if (ent.GetClassname() != "player") return

            local player_origin = ent.GetOrigin()
            local vec = origin - player_origin;

            if (PopExtUtil.IsOnGround(ent)) 
            {
                player_origin.z = player_origin.z + 32;
                ent.SetAbsOrigin(player_origin);
            }
            local speed, vel = (speed = vec.Norm(), vec * pow(speed, 1.25))

            ent.SetAbsVelocity(vel);
        }
    }
    vortex_particle.SetAbsOrigin(origin)
    if (touched == true && has_touch == false)
    {
        local origin = self.GetOrigin()
        EmitSoundEx
        ({
            sound_name = "misc/hologram_move.wav",
            origin = self.GetOrigin(),
            sound_level = sound_range 
            //filter_type = RECIPIENT_FILTER_GLOBAL
        });
        // DispatchParticleEffect("merasmus_dazed_explosion", origin, Vector(-90, 0, 0))
        //vortex.SetAbsOrigin(origin + Vector(0, 0, 50))
        vortex_particle.SetAbsOrigin(origin + Vector(0, 0, 50))
        vortex_particle.AcceptInput("Start", "", null, null)

        //EntFireByHandle(vortex, "Kill", "", 10, null, null)
        EntFireByHandle(vortex_particle, "Kill", "", 7, null, null)
        EntFireByHandle(self, "Kill", "", 7, null, null)
        EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `misc/hologram_move.wav`, filter_type = RECIPIENT_FILTER_GLOBAL, flags = 4});", 10, null, null)
        has_touch = true
        //self.Kill()
    }
}

::BookBombThink <- function() 
{
    local touched = NetProps.GetPropBool(self, "m_bTouched")
    local sound_range = (40 + (20 * log10(1000 / 36.0))).tointeger();

    local classnames = 
    {
        "player" : 1
        "obj_sentrygun" : 1
        "obj_dispenser": 1
        "obj_teleporter" : 1
        "entity_medigun_shield" : 1
    }

    if (touched == true)
    {
        local origin = self.GetOrigin()

        EmitSoundEx
        ({
            sound_name = "weapons/bombinomicon_explode1.wav",
            origin = self.GetOrigin(),
            sound_level = sound_range 
        });
        DispatchParticleEffect("merasmus_dazed_explosion", origin, Vector(-90, 0, 0))
        for (local ent; ent = FindInSphere(ent, origin, 150);)
        {
            if (ent.GetClassname() in classnames && ent.GetTeam() != TEAM_SPECTATOR && ent.GetTeam() != merasmus.GetTeam())
            {
                ent.TakeDamageEx(null, merasmus, null, Vector(0, 0, 0), ent.GetOrigin(), 400, 8192 + 1024)
            }
        }
        self.Kill()
    }
}

function MakeEarthquake(ent)
{
    ::EarthquakeThink <- function()
    {
        local sound_range = (40 + (20 * log10(3000 / 36.0))).tointeger();

        for (local player; player = FindByClassnameWithin(player, "player", self.GetOrigin(), 750);)
        {
            if (player.GetTeam() != merasmus.GetTeam() && player.GetTeam() != TEAM_SPECTATOR)
            {
                ScreenShake(player.GetOrigin(), 60, 0.5, 0.5, 750, 0, true)
                if (player.GetFlags() & FL_ONGROUND)
                {
                    player.TakeDamageEx(null, merasmus, null, Vector(0, 0, 0), self.GetOrigin(), 100, 64)
                }
            }
        }
        for (local building; building = FindByClassnameWithin(building, "obj*", self.GetOrigin(), 750);)
        {
            if (building.GetTeam() != merasmus.GetTeam() && building.GetTeam() != TEAM_SPECTATOR)
            {
                building.TakeDamageEx(null, merasmus, null, Vector(0, 0, 0), self.GetOrigin(), 250, 64)
            }
            else 
            {
                continue
            }
        }
        
        EmitSoundEx
        ({
            sound_name = "ambient/atmosphere/terrain_rumble1.wav",
            origin = self.GetOrigin(),
            sound_level = sound_range 
        });
        
        return 1
    }

    AddThinkToEnt(ent, "EarthquakeThink")
}

function ApplyThunderThink(player, caster)
{
    player.ValidateScriptScope()
    local scope = player.GetScriptScope()
    //scope.vortex <- vortex
    scope.merasmus <- caster
    scope.fire_rate <- 0
    scope.ambience <- false
    scope.thunder_storm_timer <- 22
    scope.thunder_time_server <- 0
    scope.thunder_duration <- function() 
    {
        if (thunder_storm_timer == null) return
        local time = floor(Time())
        if (time != thunder_time_server) { // Once every second
            thunder_time_server = time
            local origin = self.GetOrigin()
            if (thunder_storm_timer > 0)
            {
                thunder_storm_timer--
                //printl(thunder_storm_timer)
            }
            if (thunder_storm_timer == 0)
            {
                local names = 
                {
                    "swave" : 1
                    "thunder_struck" : 1
                    "shock_targ" : 1
                    "thunder_cloud" : 1
                }

                function GetTargetname(entity)
                {
                    return GetPropString(entity, "m_iName")
                }

                for(local ent; ent = FindInSphere(ent, origin, INT_MAX);)
                {
                    if (GetTargetname(ent) in names)
                    {
                        ent.Kill()
                    }
                }

                delete self.GetScriptScope().PlayerThinkTable.ThunderThink 
            }
        }
    }

    scope.thunder_bolt <- null
    scope.thunder_cloud <- SpawnEntityFromTable("info_particle_system", 
    {
        effect_name = "utaunt_electricity_cloud_parent_WY", 
        targetname = "thunder_cloud"
        origin = player.GetOrigin()
        angles = Vector(0, 0, 0)
    })
    scope.thunder_targ <- SpawnEntityFromTable("info_target", 
    {
        effect_name = "shock_targ", 
        spawnflags = 1
        origin = player.GetOrigin()
        angles = Vector(0, 0, 0)
    })
    scope.thunder_cloud.AcceptInput("start", "", scope.thunder_cloud, scope.thunder_cloud)

    scope.ThunderThink <- function()
    {
        local origin = self.GetOrigin()
        local strike_prepare = 90
        local classnames = 
        {
            "player" : 1
            "obj_sentrygun" : 1
            "obj_dispenser": 1
            "obj_teleporter" : 1
            "entity_medigun_shield" : 1
        }
        //ambient\energy\electric_loop.wav
        local sound_range = (40 + (20 * log10(3000 / 36.0))).tointeger();

        if (NetProps.GetPropInt(self, "m_lifeState") != 0 || self == null)
        {
            thunder_storm_timer = 0
            delete self.GetScriptScope().PlayerThinkTable.ThunderThink 
        }

        local thund_trace = 
        {
            start  = thunder_cloud.GetOrigin(),
            end    = thunder_cloud.GetOrigin() + Vector(0, 0, -380)
            hullmin = Vector(-10, -10, -10)
            hullmax = Vector(10, 10, 10)
            mask = -1 
            ignore = self
        }

        TraceHull(thund_trace)
        //DebugDrawLine(thunder_cloud.GetOrigin(), thunder_targ.GetOrigin(), 34, 55, 113, true, 0.1)
        //printl(thund_trace.pos)

        fire_rate++
        thunder_duration()

        if (thunder_bolt == null)
        {
            thunder_bolt = SpawnEntityFromTable("info_particle_system", 
            {
                effect_name = "underworld_skull_zap", 
                targetname = "thunder_struck"
                origin = player.GetOrigin()
                angles = Vector(90, 0, 0)
            })
        }

        if (fire_rate > strike_prepare && thunder_targ != null)
        {
            thunder_cloud.SetAbsOrigin(thunder_targ.GetOrigin() + Vector(0, 0, 380))
        }
        else if (fire_rate < strike_prepare && thunder_targ != null)
        {
            thunder_targ.SetAbsOrigin(origin)
            thunder_cloud.SetAbsOrigin(thunder_targ.GetOrigin() + Vector(0, 0, 380))
            //thunder_cloud.AcceptInput("SetParent", "!activator", self, thunder_cloud)
        }

        if (fire_rate == strike_prepare && thunder_targ != null)
        {
            thunder_targ.SetAbsOrigin(thund_trace.pos + Vector(0, 0, 30))
        }

        if (fire_rate == 140 && thunder_targ != null)
        {
            EmitSoundEx
            ({
                sound_name = "items/powerup_pickup_crits.wav",
                origin = thunder_targ.GetOrigin(),
                sound_level = sound_range 
            });
            local shockwave = SpawnEntityFromTable("info_particle_system", 
            {
                effect_name = "taunt_yeti_fistslam_shockwave", 
                targetname = "swave"
                origin = thunder_targ.GetOrigin()
                angles = Vector(90, 0, 0)
            })
            thunder_targ.AcceptInput("SetParent", "!activator", thunder_bolt, thunder_targ)
            thunder_bolt.SetAbsOrigin(thunder_targ.GetOrigin() + Vector(0, 0, 380))
            thunder_targ.SetAbsOrigin(thund_trace.pos)
            SetPropEntityArray(thunder_bolt, "m_hControlPointEnts", thunder_targ, 0)
            EntFireByHandle(thunder_bolt, "Start", "", 0.1, null, null)
            EntFireByHandle(thunder_bolt, "Stop", "", 0.2, null, null)

            EntFireByHandle(shockwave, "Start", "", 0.1, null, null)
            EntFireByHandle(shockwave, "Stop", "", 0.2, null, null)
            EntFireByHandle(shockwave, "kill", "", 0.3, null, null)

            for (local ent; ent = FindInSphere(ent, thunder_targ.GetOrigin(), 100);)
            {
                if (ent.GetClassname() in classnames && ent.GetTeam() != TEAM_SPECTATOR && ent.GetTeam() != merasmus.GetTeam())
                {
                    ent.TakeDamageEx(null, merasmus, null, Vector(0, 0, 0), ent.GetOrigin(), 100, 256 + 67108864)
                }
            }
        }
        if (fire_rate == 200)
        {
            fire_rate = 0
        }
    }

    PopExtUtil.AddThinkToEnt(player, "ThunderThink")
}


::SpawnMerasmus <- function () 
{
    self.ValidateScriptScope()
    PlayBossMusic()
    local melee = PopExtUtil.GetItemInSlot(self, 2)
    local sniperscope = self.GetScriptScope()
    local intel = FindByName(null, "intel_ironman")

    intel.AcceptInput("AddOutput" "OnReturn !activator:CallScriptFunction:RespawnBombCarrier:0:-1", null, null)

    //sniperscope.target <- null
    sniperscope.laser <- null
    //laser.AcceptInput("SetParent", "!activator", self, laser)
    //target.AcceptInput("SetParent", "!activator", laser, target)
    sniperscope.phase <- 0
    sniperscope.nav_area_num <- -1
    sniperscope.NoAction <- false
    sniperscope.TimerNoAction <- 0

    sniperscope.NoCastSpell <- false
    sniperscope.TimerNoCastSpell <- 0
    sniperscope.NUM_MAX_SPELL_TIER <- 0
    sniperscope.tickspell <- false
    sniperscope.stuckTime <- 0
    sniperscope.targetArray <- []
    sniperscope.laser_mode <- 0
    sniperscope.targeted <- null
    sniperscope.merasmus_buttons_last <- 0

    sniperscope.force_cast_Timer <- 8
    sniperscope.time_cast_server <- 0
    sniperscope.check_spell_cast <- function() 
    {
        if (force_cast_Timer == null) return
        local time = floor(Time())
        if (time != time_cast_server) { // Once every second
            time_cast_server = time
            local origin = self.GetOrigin()
            if (force_cast_Timer > 0)
            {
                force_cast_Timer--
            }
            if (force_cast_Timer == 0)
            {
                force_cast_Timer = 8 
                self.PressAltFireButton(0.1)
            }
        }
    }
    sniperscope.switch_attackmode_time <- 6
    sniperscope.attack_time_server<- 0
    sniperscope.switch_spell_mode <- function() 
    {
        if (switch_attackmode_time == null) return
        local time = floor(Time())
        if (time != attack_time_server) { // Once every second
            attack_time_server = time
            local origin = self.GetOrigin()
            if (switch_attackmode_time > 0)
            {
                switch_attackmode_time--
            }
            if (switch_attackmode_time == 0)
            {
                if (laser_mode == 0)
                {
                    melee.AddAttribute("fire rate penalty", 7.2, -1)
                    laser_mode = 1
                    //printl(laser_mode)
                }
                else 
                {
                    melee.RemoveAttribute("fire rate penalty")
                    laser_mode = 0
                    //printl(laser_mode)
                }
                switch_attackmode_time = 6
            }
        }
    }
    sniperscope.attackTime <- 0
    sniperscope.serverTime <- 0
    sniperscope.spell_number <- null
    sniperscope.anim <- null
    sniperscope.is_disguising <- 0
    sniperscope.cast_spell <- function(spell_type) 
    {
        if (attackTime == null) return
        local time = floor(Time())
        if (time != serverTime) { // Once every second
            serverTime = time
            local origin = self.GetOrigin()
            if (attackTime > 0)
            {
                attackTime--
                //printl(attackTime)
            }
            if (attackTime == 0)
            {
                if (spell_type == 1) // SPELL: WEAK. SUMMON FIREBALL: Spawns fireballs in 4 directions
                {
                    local fireball = SpawnEntityFromTable("tf_projectile_spellfireball", 
                    {
                        basevelocity = Vector(-900, 0, 0),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(-50, 0, 80)
                        angles       = self.EyeAngles()
                    })
                    local fireball2 = SpawnEntityFromTable("tf_projectile_spellfireball", 
                    {
                        basevelocity = Vector(900, 0, 0),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(75, 0, 80)
                        angles       = self.EyeAngles()
                    })
                    local fireball3 = SpawnEntityFromTable("tf_projectile_spellfireball", 
                    {
                        basevelocity = Vector(0, 900, 0),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(0, 75, 80)
                        angles       = self.EyeAngles()
                    })
                    local fireball4 = SpawnEntityFromTable("tf_projectile_spellfireball", 
                    {
                        basevelocity = Vector(0, -900, 0),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(20, 75, 80)
                        angles       = self.EyeAngles()
                    })
                    fireball.SetOwner(self) 
                    fireball2.SetOwner(self) 
                    fireball3.SetOwner(self) 
                    fireball4.SetOwner(self) 
                }
                if (spell_type == 2) // SPELL: WEAL. SUMMON MONOCULUS: Summon monoculus spell.
                {
                    local eye_spell = SpawnEntityFromTable("tf_projectile_spellmeteorshower", 
                    {
                        basevelocity = Vector(0, 0, 0),
                        teamnum      = self.GetTeam(),
                        origin       = self.EyePosition()
                        angles       = self.EyeAngles()
                    })
                    eye_spell.SetOwner(self) 
                    eye_spell.SetCollisionGroup(27)
                    local velocity = PopExtUtil.AnglesToVector(self.EyeAngles())
                    eye_spell.SetPhysVelocity(Vector(velocity.x * 500, velocity.y * 500, 500))
                }
                if (spell_type == 3) // SPELL: WEAK. BLOCK HEAL: Blocks ability to heal, and forces players to bleed
                {
                    for (local player; player = FindByClassnameWithin(player, "player", self.GetOrigin(), 500);)
                    {
                        if (player.GetTeam() != self.GetTeam() && player.GetTeam() != TEAM_SPECTATOR)
                        {
                            player.AddCustomAttribute("mod weapon blocks healing", 1, 10)
                            player.BleedPlayerEx(10, 2, false, 64)
                            local chain = SpawnEntityFromTable("info_particle_system", 
                            {
                                effect_name = "passtime_beam", 
                                targetname = "cursed_chain"
                                origin = self.GetOrigin()
                                angles = Vector(0, 0, 0)
                            })
                            //EntFireByHandle(target, "SetParent", "!activator", 0, chain, null)
                            SetPropEntityArray(chain, "m_hControlPointEnts", player, 0)
                            SetPropEntityArray(chain, "m_hControlPointEnts", player, 1)
                            SetPropEntityArray(chain, "m_hControlPointEnts", player, 2)
                            EntFireByHandle(chain, "Start", "", 0.1, null, null)
                            EntFireByHandle(chain, "Stop", "", 10, null, null)
                            EntFireByHandle(chain, "Kill", "", 10.1, null, null)

                            chain.ValidateScriptScope()
                            local chainscope = chain.GetScriptScope()
                            chainscope.merasmus <- self
                            AddThinkToEnt(chain, "ChainThink")
                        }
                    }
                }
                if (spell_type == 4) // MEDIUM SPELL: SPAWN TORNADO. Create 3 sand tornados that launch players
                {
                    EmitSoundEx
                    ({
                        sound_name = "misc/halloween/merasmus_disappear.wav",
            
                        origin = self.GetOrigin(),

                    });
                    local tornado_particle = SpawnEntityFromTable("info_particle_system", 
                    {
                        effect_name = "set_taunt_saharan_spy", 
                        targetname = "particle_tornado"
                        origin = self.GetOrigin()
                        angles = Vector(0, 0, 0)
                    })
                    local tornado_particle2 = SpawnEntityFromTable("info_particle_system", 
                    {
                        effect_name = "set_taunt_saharan_spy", 
                        targetname = "particle_tornado"
                        origin = self.GetOrigin()
                        angles = Vector(0, 0, 0)
                    })
                    local tornado_particle3 = SpawnEntityFromTable("info_particle_system", 
                    {
                        effect_name = "set_taunt_saharan_spy", 
                        targetname = "particle_tornado"
                        origin = self.GetOrigin()
                        angles = Vector(0, 0, 0)
                    })
                    
                    local projectile_tornado = SpawnEntityFromTable("tf_projectile_energy_ring", 
                    {
                        basevelocity = self.EyeAngles().Forward()*250 + QAngle(80, -80),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(0, 0, 20)
                        angles       = self.EyeAngles()
                    })
                    projectile_tornado.SetOwner(self) 
                    local projectile_tornado2 = SpawnEntityFromTable("tf_projectile_energy_ring", 
                    {
                        basevelocity = self.EyeAngles().Forward()*250 + QAngle(-80, 80),
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(0, 0, 20.1)
                        angles       = self.EyeAngles()
                    })
                    projectile_tornado2.SetOwner(self) 
                    local projectile_tornado3 = SpawnEntityFromTable("tf_projectile_energy_ring", 
                    {
                        basevelocity = self.EyeAngles().Forward()*250,
                        teamnum      = self.GetTeam(),
                        origin       = origin + Vector(0, 0, 20.2)
                        angles       = self.EyeAngles()
                    })
                    projectile_tornado3.SetOwner(self) 

                    projectile_tornado3.ValidateScriptScope()
                    local scope3 = projectile_tornado3.GetScriptScope()
                    scope3.particle <- null
                    scope3.merasmus <- self
                    PopExtUtil.AddThinkToEnt(projectile_tornado3, "TornadoThink")
                    
                    projectile_tornado.ValidateScriptScope()
                    local scope1 = projectile_tornado.GetScriptScope()
                    scope1.particle <- null
                    scope1.merasmus <- self
                    PopExtUtil.AddThinkToEnt(projectile_tornado, "TornadoThink")
                    
                    projectile_tornado2.ValidateScriptScope()
                    local scope2 = projectile_tornado2.GetScriptScope()
                    scope2.particle <- null
                    scope2.merasmus <- self
                    PopExtUtil.AddThinkToEnt(projectile_tornado2, "TornadoThink")
                }
                if (spell_type == 5)
                {
                    //SummonSkeletons() have to do it somewhere else
                }
                if (spell_type == 6)
                {
                    local sound_range_spell_6 = (40 + (20 * log10(3000 / 36.0))).tointeger();
                    local max_particles = 0
                    EmitSoundEx
                    ({
                        sound_name = "ambient/explosions/explode_8.wav",
                        origin = self.GetOrigin(),
                        sound_level = sound_range_spell_6 
                    });
                    local earthquake = SpawnEntityFromTable("info_target", 
                    {
                        targetname = "earthquake", 
                        spawnflags = 1
                        origin = self.GetOrigin()
                        angles = Vector(0, 0, 0)
                    })
                    earthquake.ValidateScriptScope()
                    local eqscope = earthquake.GetScriptScope()
                    eqscope.merasmus <- self
                    MakeEarthquake(earthquake)
                    EntFireByHandle(earthquake, "Kill", "", 10, null, null)

                    local earthquake_location = {}
                    GetNavAreasInRadius(self.GetOrigin(), 750, earthquake_location)
                    
                    foreach(nav in earthquake_location)
                    {
                        if (max_particles <= 10)
                        local area = nav.GetCenter()
                        local particle = SpawnEntityFromTable("info_particle_system", 
                        {
                            effect_name = "utaunt_god_lava_crack3", 
                            //moon_drill_rock_debris
                            targetname = "particle_quake"
                            origin = area
                            angles = Vector(0, 0, 0)
                        })
                        EntFireByHandle(particle, "Start", "", 0.1, null, null)
                        EntFireByHandle(particle, "Kill", "", 10, null, null)
                        max_particles++
                    }
                    EntFireByHandle(MerasmusNamespace.gamerules, "CallScriptFunction", "StopEarthquake", 10, null, null)
                }
                if (spell_type == 7)
                {
                    function SpawnBomb() 
                    {
                        local book_bomb = SpawnEntityFromTable("tf_projectile_stun_ball", 
                        {
                            targetname = "bomb"
                        })
                        book_bomb.SetModelSimple("models/props_lakeside_event/bomb_temp.mdl")
                        book_bomb.SetOrigin(self.GetOrigin())
                        book_bomb.SetPhysVelocity(Vector(RandomInt(-200 * 1.5, 200 * 1.5), RandomInt(-200 * 1.5, 200 * 1.5), 1250))
                        book_bomb.SetPhysAngularVelocity(Vector(RandomInt(-700, 700), RandomInt(-700, 700), RandomInt(-700, 700)))
                        book_bomb.ValidateScriptScope()
                        local scope = book_bomb.GetScriptScope()
                        scope.merasmus <- self
                        PopExtUtil.AddThinkToEnt(book_bomb, "BookBombThink")
                    }

                    for(local i = 0; i <= 10; i++){
                        SpawnBomb() 
                    }
                }
                if (spell_type == 8)
                {
                    local sound_range_spell = (40 + (20 * log10(3000 / 36.0))).tointeger();
                    EmitSoundEx
                    ({
                        sound_name = "misc/halloween/spell_lightning_ball_cast.wav",
                        origin = self.GetOrigin(),
                        sound_level = sound_range_spell
                    });
                    local grav_well = SpawnEntityFromTable("tf_projectile_stun_ball", 
                    {
                        targetname = "gravity_vortex"
                    })
                    grav_well.SetModelSimple("models/passtime/ball/passtime_ball.mdl")
                    grav_well.SetOrigin(self.GetOrigin() + Vector(0, 0, 100))

                    // local vortex = SpawnEntityFromTable("point_push", 
                    // {
                    //     targetname = "big_succ"
                    //     magnitude = -900
                    //     radius = 200
                    //     inner_radius = 120
                    //     enabled = 1
                    //     spawnflags = 9
                    // })
                    
                    local vortex_particle = SpawnEntityFromTable("info_particle_system", 
                    {
                        effect_name = "eyeboss_tp_vortex", 
                        targetname = "fx_vortex"
                        origin = self.GetOrigin()
                        angles = Vector(0, 0, 0)
                    })

                    local velocity = PopExtUtil.AnglesToVector(self.EyeAngles())
                    grav_well.SetPhysVelocity(Vector(velocity.x * 500, velocity.y * 500, 500))
                    grav_well.ValidateScriptScope()
                    local scope = grav_well.GetScriptScope()
                    //scope.vortex <- vortex
                    scope.vortex_particle <- vortex_particle
                    scope.has_touch <- false
                    scope.merasmus <- self
                    PopExtUtil.AddThinkToEnt(grav_well, "GravWellThink")
                }
                if (spell_type == 9)
                {
                    local gamerules = FindByClassname(null, "tf_gamerules")
                    SummonRain()
                    EmitSoundEx
                    ({
                        sound_name = "ambient/medieval_thunder2.wav",
                        origin = self.GetOrigin(),
                    });
                    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder3.wav`});", 5, null, null)
                    EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder4.wav`});", 10, null, null)
                    local rand = RandomInt(1, 2)
                    if (rand == 1)
                    {
                        EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder2.wav`});", 15, null, null)
                    }
                    else if (rand == 2)
                    {
                        EntFireByHandle(gamerules, "RunScriptCode", "EmitSoundEx({ sound_name = `ambient/medieval_thunder3.wav`});", 15, null, null)
                    }

                    for (local ent; ent = FindInSphere(ent, origin, INT_MAX);)
                    {
                        local classnames = 
                        {
                            "player" : 1
                        }

                        if (ent.GetClassname() in classnames && ent.GetTeam() != TEAM_SPECTATOR && ent.GetTeam() != self.GetTeam())
                        {
                            ApplyThunderThink(ent, self)
                        }
                    }
                }
                anim = null
                attackTime = 6 // set this here because we check for movetype on self, if this isnt here spells fire twice
            }
        }
    }
    //self.SetForcedTauntCam(1)

    sniperscope.Vector_Compare <- null

    
    self.Weapon_Switch(melee)
    NetProps.SetPropInt(self, "m_Shared.m_iNextMeleeCrit", -2)
    self.SetCustomModelWithClassAnimations("models/bots/merasmus/merasmus.mdl")
    //bot.SetCustomModelOffset(Vector(0, 0, -80))
    // bot.SetModelScale(1, 0)
    melee.AddAttribute("fire rate bonus", 0.25, -1)
    melee.AddAttribute("damage bonus", 2, -1)
    melee.AddAttribute("damage causes airblast", 1, -1)
    PopExtUtil.AddThinkToEnt(self, "MerasmusThink")
}

::MerasmusNamespace <- 
{
    Cleanup = function()
    {
        // cleanup any persistent changes here
        
        // keep this at the end
        delete ::MerasmusNamespace            
    }
    
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) Cleanup() }
    OnGameEvent_mvm_wave_complete = function(_) { Cleanup() }
    
    // add stored variables or your own events here
    //
    // e.g.
    // myvar = 123
    //
    // OnGameEvent_player_death = function(params)
    // { ... }

    gamerules = FindByClassname(null, "tf_gamerules")
    areas = {}
    disguise_boss_health = 0

    classnames = 
    {
        "player" : 1
        "obj_sentrygun" : 1
        "obj_dispenser": 1
        "obj_teleporter" : 1
        "entity_medigun_shield" : 1
    }

    function BossSetup() 
    {
        PopExt.AddRobotTag("bot_merasmus", 
        {
            OnSpawn = function(bot, tag) 
            {
                bot.ValidateScriptScope()

                bot.AcceptInput("CallScriptFunction", "SpawnMerasmus", bot, bot)
            }
        })
        PopExt.AddRobotTag("bot_skeleton", 
        {
            OnSpawn = function(bot, tag) 
            {
                local class_string = PopExtUtil.Classes[bot.GetPlayerClass()]
                local wep = bot.GetActiveWeapon()
                EntFireByHandle(bot, "SetCustomModelWithClassAnimations", format("models/player/%s.mdl", class_string), SINGLE_TICK, null, null)
                EntFireByHandle(bot, "RunScriptCode", "MerasmusNamespace.SkeletonSetup(self, `models/bots/skeleton_sniper/skeleton_sniper_fixed.mdl`)", 0.5, null, null)
                bot.GetScriptScope().usingcustommodel <- true
                bot.AddCustomAttribute("no_jump", 1, -1)
                bot.AddCustomAttribute("no_duck", 1, -1)
                bot.AddCustomAttribute("no_attack", 1, -1)
                bot.AddCustomAttribute("move speed penalty", 0.0001, -1)
                bot.AddCondEx(64, -1, null)
            }
            OnDeath = function(bot, tag) 
            {
                local sound_range = (40 + (20 * log10(1500 / 36.0))).tointeger();
                EmitSoundEx({
                    sound_name = "misc/halloween/skeleton_break.wav",
                    origin = bot.GetOrigin(),
                    sound_level = sound_range 
                });
            }
        })

        PopExt.AddRobotTag("bot_runner", 
        {
            OnSpawn = function(bot, tag) 
            {
                local gamerules = FindByClassname(null, "tf_gamerules")
                gamerules.AcceptInput("RunScriptCode", "EmitSoundEx({ sound_name = `misc/halloween/spell_athletic.wav`});", null, null)
            }
        })
    }

    function SkeletonSetup(player, model) 
    {
        player.ValidateScriptScope()
        local scope = player.GetScriptScope()

        local wearable = CreateByClassname("tf_wearable")
        SetPropString(wearable, "m_iName", "__bot_bonemerge_model")
        SetPropInt(wearable, "m_nModelIndex", PrecacheModel(model))
        SetPropBool(wearable, "m_bValidatedAttachedEntity", true)
        SetPropBool(wearable, STRING_NETPROP_ITEMDEF, true)
        SetPropEntity(wearable, "m_hOwnerEntity", player)
        wearable.SetTeam(player.GetTeam())
        wearable.SetOwner(player)
        DispatchSpawn(wearable)
        EntFireByHandle(wearable, "SetParent", "!activator", -1, player, player)
        SetPropInt(wearable, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL)
        scope.wearable <- wearable

        SetPropInt(player, "m_nRenderMode", kRenderTransColor)
        SetPropInt(player, "m_clrRender", 0)

        scope.PlayerThinkTable.BotModelThink <- function() {
            if (wearable.IsValid() && (player.IsTaunting() || wearable.GetMoveParent() != player))
                EntFireByHandle(wearable, "SetParent", "!activator", -1, player, player)
            return -1
        }
    }

    function IsMiniCritAttacker(entity) 
    {
        local CritArray = [16, 19, 31]
        foreach(crit in CritArray)
        {
            if (entity.InCond(crit))
            {
                return true
            }
        }
        return false
    }

    function IsMiniCritVictim(entity) 
    {
        local CritArray = [24, 30]
        foreach(crit in CritArray)
        {
            if (entity.InCond(crit))
            {
                return true
            }
        }
        return false
    }

    function IsCritAttacker(entity) 
    {
        local CritArray = [11, 34, 37, 39, 40, 44, 56]
        foreach(crit in CritArray)
        {
            if (entity.InCond(crit))
            {
                return true
            }
        }
        return false
    }

    OnScriptHook_OnTakeDamage = function(params) 
    {
        local victim = params.const_entity
        local weapon = params.weapon
        local attacker = params.attacker
        local entity = params.inflictor
        local damage = params.damage
        local dmgtype = params.damage_type
        local dmg_special = params.damage_stats

        local scope = victim.GetScriptScope()

        if (victim.GetClassname() == "player")
        {
            if (victim.IsBotOfType(TF_BOT_TYPE))
            {
                if (victim.HasBotTag("bot_merasmus") && !victim.HasBotTag("bot_transform"))
                {
                    //reduce effectiveness of spy knife and minigun
                    local origin = victim.GetOrigin()

                    if (weapon != null && weapon.GetClassname() == "tf_weapon_minigun")
                    {
                        damage *= 0.67
                    }

                    if (weapon != null && dmgtype != null && weapon.GetClassname() == "tf_weapon_knife")
                    {
                        damage *= 0.75
                    }

                    if (victim.GetHealth() == 1)
                    {
                        if (scope.anim == null)
                        {   
                            boss_defeat = true
                            local bot_win = FindByName(null, "bots_win")
                            local bomb = FindByName(null, "intel_ironman")
                            scope.DoAnimation(victim, "death", 7, "models/empty.mdl")
                            bomb.AcceptInput("ForceDrop" "", bomb, bomb)
                            bomb.AcceptInput("Disable" "", bomb, bomb)
                            victim.AddCustomAttribute("dmg taken increased", 0, 5)
                            EntFireByHandle(bot_win, "Kill", "", 0, null, null)
                            victim.RemoveCondEx(70, true)
                            EntFireByHandle(scope.anim, "Kill", "", 5, null, null)
                            local die_effect = SpawnEntityFromTable("info_particle_system", 
                            {
                                effect_name = "moon_miasma_purple01", 
                                targetname = "die"
                                origin = victim.GetOrigin()
                                angles = Vector(0, 0, 0)
                            })
                            die_effect.AcceptInput("Start", "", null, null)
                            EntFireByHandle(die_effect, "Kill", "", 5, null, null)
                            EntFireByHandle(victim, "RunScriptCode", "DispatchParticleEffect(`merasmus_dazed_explosion`, self.GetOrigin(), Vector(0, 0, 0))", 5, null, null)
                            EmitSoundEx
                            ({
                                sound_name = "vo/halloween_merasmus/sf12_defeated12.mp3"
                                origin = victim.GetOrigin(),
                            });
                            EmitSoundEx
                            ({
                                sound_name = "misc/halloween/merasmus_death.wav"
                                origin = victim.GetOrigin(),
                            });

                            EntFireByHandle(victim, "RunScriptCode", "self.TakeDamage(999, 1024, null)", 5.1, victim, victim)
                        }
                    }
                }
                if (victim.HasBotTag("bot_transform"))
                {
                    if (attacker.GetTeam() != 2) return
                    local factor = 1.0
                    local primary = PopExtUtil.GetItemInSlot(victim, 0)
                    // victim.Weapon_Switch(primary)
                    // victim.AddWeaponRestriction(0)
                    // primary.AddAttribute("disable weapon switch", 1, -1)
                    // primary.AddAttribute("provide on active", 1, -1)
                    if (dmgtype != DMG_ACID)
                    {
                        if (MerasmusNamespace.IsMiniCritAttacker(attacker) || MerasmusNamespace.IsMiniCritVictim(victim))
                        {
                            //if the attacker is critboosted and the victim is minicritted, use crit dmg calcs
                            if (MerasmusNamespace.IsCritAttacker(attacker) && MerasmusNamespace.IsMiniCritVictim(victim))
                            {
                                factor = 3.0
                            }
                            else 
                            {
                                factor = 1.35
                            }
                        }
                        else
                        {
                            factor = 3.0
                        }
                    }
                    
                    if (victim.InCond(87))
                    {
                        factor = 0
                    }
                    else 
                    {
                        NetProps.SetPropInt(victim, "m_iHealth", victim.GetHealth() + damage * factor)
                        disguise_boss_health = disguise_boss_health - damage * factor
                    }

                    if (disguise_boss_health <= 0)
                    {
                        local melee = PopExtUtil.GetItemInSlot(victim, 2)
                        local primary = PopExtUtil.GetItemInSlot(victim, 0)
                        local vo_disguise_destroy = RandomInt(1, 4)

                        if (vo_disguise_destroy == 1)
                        {
                            EmitSoundEx
                            ({
                                sound_name = "vo/halloween_merasmus/sf12_magic_backfire06.mp3"
                                origin = victim.GetOrigin(),
                            });
                        }
                        else if (vo_disguise_destroy == 2)
                        {
                            EmitSoundEx
                            ({
                                sound_name = "vo/halloween_merasmus/sf12_defeated01.mp3"
                                origin = victim.GetOrigin(),
                            });
                        }
                        else if (vo_disguise_destroy == 3)
                        {
                            EmitSoundEx
                            ({
                                sound_name = "vo/halloween_merasmus/sf12_found08.mp3"
                                origin = victim.GetOrigin(),
                            });
                        }
                        else if (vo_disguise_destroy == 4)
                        {
                            EmitSoundEx
                            ({
                                sound_name = "vo/halloween_merasmus/sf12_staff_magic13.mp3"
                                origin = victim.GetOrigin(),
                            });
                        }
                        
                        victim.ValidateScriptScope()
                        local scope = victim.GetScriptScope()
                        scope.is_disguising = 0
                        victim.SetPlayerClass(2);
                        SetPropInt(victim, "m_Shared.m_iDesiredPlayerClass", 2);
                        victim.RemoveWeaponRestriction(0)
                        ClientPrint(null, 4, "MERASMUS REVEALED!")
                        victim.RemoveBotTag("bot_transform")
                        PopExtUtil.StripWeapon(victim, 0)
                        victim.SetCustomModelWithClassAnimations("models/bots/merasmus/merasmus.mdl")
                        //victim.SetModelScale(1, 0)
                        victim.RemoveCondEx(56, true)
                        //victim.SetCustomModelOffset(Vector(0, 0, -80))
                        victim.Weapon_Switch(melee)
                        victim.AddWeaponRestriction(3)
                        NetProps.SetPropString(victim, "m_PlayerClass.m_iszClassIcon", "boss_merasmus");
                        EntFireByHandle(victim, "RunScriptCode", "NetProps.SetPropString(self, `m_PlayerClass.m_iszClassIcon`, `boss_merasmus`);", 1, victim, victim)
                    }
                }

                if (victim.HasBotTag("bot_hitbox"))
                {
                    local origin = victim.GetOrigin()
                    local head_hitbox_min = Vector(-22, -22, -22);  
                    local head_hitbox_max = Vector(22, 22, 22);     
                    local origin_head = origin + Vector(0, 0, 100)

                    local hitbox_trace = 
                    {
                        start  = origin_head,
                        end    = origin_head, 
                        hullmin = head_hitbox_min
                        hullmax = head_hitbox_max
                        //mask = -1 
                        ignore = victim
                    }
                    TraceHull(hitbox_trace)
                    //DebugDrawBox(origin_head, head_hitbox_min, head_hitbox_max, 5, 33, 123, 0, 0.1)

                    if (hitbox_trace.hit && hitbox_trace.enthit.GetClassname() == "tf_projectile_arrow" && weapon.GetClassname() == "tf_weapon_compound_bow") 
                    {
                        //printl("arrow is headshot")

                        params.damage_type = params.damage_type | DMG_CRITICAL
                        params.damage_stats = TF_DMG_CUSTOM_HEADSHOT
                    }

                    victim.AddCustomAttribute("dmg taken increased", 0, 0.1) // victim here is merasmuses extended hitbox. 
                    //use delay here so the params.damage is updated but the attribute is applied before damage is actually taken
                    for (local player; player = FindByClassname(player, "player");)
                    {
                        if (player.IsBotOfType(TF_BOT_TYPE) && player.HasBotTag("bot_merasmus") && !player.HasBotTag("bot_transform"))
                        {
                            player.TakeDamageEx(null, attacker, weapon, Vector(0, 0, 0), player.GetOrigin(), damage, dmgtype)
                        }
                    }
                }
            }
        }
    }

    //ty lite
    function UnstuckEntity(entity)
    {
        ::MASK_PLAYERSOLID <- 33636363
        local origin = entity.GetOrigin();
        local trace = {
            start = origin,
            end = origin,
            hullmin = entity.GetBoundingMins(),
            hullmax = entity.GetBoundingMaxs(),
            mask = MASK_PLAYERSOLID,
            ignore = entity
        }
        TraceHull(trace);
        if ("startsolid" in trace)
        {
            local dirs = [Vector(1, 0, 0), Vector(-1, 0, 0), Vector(0, 1, 0), Vector(0, -1, 0), Vector(0, 0, 1), Vector(0, 0, -1)];
            for (local i = 16; i <= 96; i += 16)
            {
                foreach (dir in dirs)
                {
                    trace.start = origin + dir * i;
                    trace.end = trace.start;
                    delete trace.startsolid;
                    TraceHull(trace);
                    if (!("startsolid" in trace))
                    {
                        entity.SetAbsOrigin(trace.end);
                        return true;
                    }
                }
            }
            return false;
        }
        return true;
    }


    function OnGameEvent_player_spawn(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        local secondary = PopExtUtil.GetItemInSlot(player, 1)
        //printl(secondary)
        player.ValidateScriptScope()
        local playerscope = player.GetScriptScope()
        
    }

    function OnGameEvent_mvm_wave_failed(params)
    {
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });

        StopEarthquake() 
        StopRain()
    }

    function OnGameEvent_mvm_wave_complete(params)
    {
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });
        EmitSoundEx
        ({
            sound_name = "merasmus_theme.mp3",
            flags = SND_STOP
        });

        StopEarthquake() 
        StopRain()
    }

};

__CollectGameEventCallbacks(MerasmusNamespace)
GetAllAreas(MerasmusNamespace.areas) 
MerasmusNamespace.BossSetup()