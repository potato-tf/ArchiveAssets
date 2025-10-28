// Base structure for setting up script that can be easily compatible with other scripts
// Structure by StardustSpy, and borrowed some stuff from lite, popextensions (braindawg) and ficool2
// Assumes basic VScript abilities, Source knowledge, and how MvM works 

// Useful links:
// TF2's VScript functions: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions
// Script Examples: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/VScript_Examples
// Game Event hooks: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Game_Events
// List of NetProps: https://invalidvertex.com/tf2dump/netprops.txt
// Organised list of names TF2 uses to refer to hats, weapons and other items: https://csrd.science/misc/econ-tf/items.html
// Potato.TF Sigmod/Rafmod wiki. Very useful for looking up NetProps specific to entities. https://sigwiki.potato.tf/index.php/Main_Page

// You can search for specific infomation marked by [#1-6] by pressing CTRL + F on your keyboard (or whatever it is to access searching for text)
// Intended to be for VERY new VScripters


// Fold things into root so the script can access them anywhere
::ROOT <- getroottable()
::MAX_CLIENTS <- MaxClients().tointeger() // get all players that can spawn in a server

// This is useful to automatically fold constants, as they are always accessible 
// Especially helpful for trace masks, also runs x2 faster according to wiki
// Credit to Lite for folds
if (!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0

// When using NetProps.GetProp[example], you always need to prefix it with "NetProps,"
// This streamlines the process, and you dont have to do this anymore

// see "CNetPropManager" for applicable functions
foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

// Same as above, but with Entities.FindBy[example] and anything else prefixed with entities

// see "CEntities" for applicable functions
foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

// The next 2 are useful for other functions such as GetAllAreas, but you might not use them as readily.

// see "CScriptEntityOutputs" for applicable functions
foreach(k, v in ::EntityOutputs.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs)

// see "CNavMesh" for applicable functions
foreach(k, v in ::NavMesh.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NavMesh[k].bindenv(::NavMesh)

        
// This will store things like variables into the root table, allowing us to refer to these anywhere in the script
// Keep these in mind for later when you reach the Game Hooks section

// Ents that are useful to refer to in the script
// Gamerules will likely be used far more, since it is often used for EntFireByHandle and AcceptInput
// Also, FindByClassname would usually require "Entities.", but we folded that already so we dont need to use it 
::gamerules <- FindByClassname(null, "tf_gamerules")
::player_manager <- FindByClassname(null, "tf_player_manager")
::WORLD_SPAWN <- FindByClassname(null, "worldspawn")

//Teams
::TEAM_SPECTATOR <- 1
::TEAM_RED <- 2
::TEAM_BLU <- 3

// If you are trying to do something with the Nav Mesh, it will always be useful to check for if the nav square is in Red or Blu spawn
::TF_NAV_SPAWN_ROOM_RED <- 2
::TF_NAV_SPAWN_ROOM_BLUE <- 4

// Source sets up some "puppet bots" used for SourceTV spectating. As a result, we shouldnt check for IsPlayerABot since that wont get actual MvM Bots. 
// Instead we use IsBotOfType
// Use this when using IsBotOfType
::TF_BOT_FAKE_CLIENT <- 1337

const SINGLE_TICK = 0.015

// get into the habit of putting everything in namespaces if you want to have better compatibility with other scripts
// You dont need to precache things within the namespace unless it may conflict with the map or other missions
::myNamespace <- 
{
    Player_Cleanup_Table = []

    // Borrowed from PopExtensions. Useful utility functions that can print tables and their contents
    // PrintTable should be used, as DoPrintTable appears to be a "wrapper" (i.e. this function simplifies DoPrintTable)
    PrintTable = function(table) 
    {
        if (table == null) return;

        this.DoPrintTable(table, 0)
    }

    DoPrintTable = function(table, indent) 
    {
        local line = ""
        for (local i = 0; i < indent; i++) {
            line += " "
        }
        line += typeof table == "array" ? "[" : "{";

        ClientPrint(null, 2, line)

        indent += 2
        foreach(k, v in table) {
            line = ""
            for (local i = 0; i < indent; i++) {
                line += " "
            }
            line += k.tostring()
            line += " = "

            if (typeof v == "table" || typeof v == "array") {
                ClientPrint(null, 2, line)
                this.DoPrintTable(v, indent)
            }
            else {
                try {
                    line += v.tostring()
                }
                catch (e) {
                    line += typeof v
                }

                ClientPrint(null, 2, line)
            }
        }
        indent -= 2

        line = ""
        for (local i = 0; i < indent; i++) {
            line += " "
        }
        line += typeof table == "array" ? "]" : "}";

        ClientPrint(null, 2, line)
    }

    DispatchParticleEffectEx = function(name, origin, angles, delay_start, delay_end, ent_attachment, debug, will_parent, entity)
    {
        PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = name })

        if (delay_start < delay_end && debug == true)
        {
            //printl("WARNING: Start delay is slower then end delay! Particle may not spawn!")
        }

        local particle = SpawnEntityFromTable("info_particle_system", 
        {
            effect_name = name, 
            targetname = "temporary"
            origin = origin
            angles = angles
        })  

        if (will_parent == true)
        {
            EntFireByHandle(particle, "SetParent", "!activator", -1, entity, entity)
        }

        if (ent_attachment != null)
        {   
            SetPropEntityArray(particle, "m_hControlPointEnts", ent_attachment, 0);
        }

        if (delay_start == -1)
        {
            particle.AcceptInput("Start", "", null, null)
        }
        else 
        {
            EntFireByHandle(particle, "Start", "", delay_start, null, null);
        }

        if (delay_end != -1)
        {
            EntFireByHandle(particle, "Stop", "", delay_end, null, null);
            EntFireByHandle(particle, "Kill", "", delay_end + SINGLE_TICK, null, null);
        }

        return particle
    }

    // This function is called when the mission reloads, and when a player dies
    // It cleans the player of all their thinks, including PlayerThinks
    // Those thinks are then re-added upon spawning (PlayerSpawn)
    PlayerCleanup = function(player)
    {
        foreach (key, ent in Player_Cleanup_Table)
        {
            // ensure that when we call the func, we are cleaning the correct player
            if (ent != player)
            {
                continue;
            }
            
            ////printl("Cleaning: " + ent)
            player.ValidateScriptScope()
            local scope = player.GetScriptScope()
            
            // Keep this here since this function may break certain things without it.
            if (scope.len() <= 5) return

            // These are contained within the script scope and are used by the game, not us.
            // Deleting these may cause problems, so they should be ignored.
            local ignore_table = 
            {
                "self"      : null,
                "__vname"   : null,
                "__vrefs"   : null
            };

            foreach (think, v in scope)
            {
                // v is a variable used for ignore_table. You can ignore it, but dont remove it
                // This deletes everything we store in our scope, including our thinks, tables and variables such as server_time_check
                if (!(think in ignore_table))
                {
                    ////printl("Deleted Think: " + scope[think])
                    delete scope[think]
                }
            }

            // Remove player entry by key
            Player_Cleanup_Table.remove(key)
            //PrintTable(Player_Cleanup_Table)
            break; // Exit loop once the player is found and removed
        }
    }

    Cleanup = function()
    {
        for (local player; player = FindByClassname(player, "player");)
        {
            PlayerCleanup(player)
        }
        
        // keep this at the end of this function
        delete ::myNamespace
    }
    
    // mandatory events
    OnGameEvent_recalculate_holidays = function(_) 
    { 
        if (GetRoundState() == 3) 
        {
            Cleanup()
        } 
    }
    OnGameEvent_mvm_wave_complete = function(_) 
    {
        Cleanup() 
    }

    //Thinks

    // [#4] Example think function  within a namespace
    // Usually, you would do something like ::myThink1, which stores the think in the root table so that it can be accessed anywhere
    // However, we live in a namespace, which is already stored in the root, so everything (including thinks, locals, etc) is formatted like:
    // myVariableName = myDesiredTask 
,
    // We also put return -1 at the end of our thinks to tell the game to run this think after that many seconds in the server (-1 = end of every frame)
    // Don't do this for these function and any functions you want to add, since our PlayerThinks already do this

    myThink1 = function()
    {
        // self is whoever or whatever has the think
        ////printl(self)

        ////printl("Running Think 1!")

        // Grabs the current servers time (i.e. how long has the server existed)
        // We want to define it as a local here since we want this to always update
        // Also useful for: getting player origin, eye angles, active weapon, etc
        local cur_time = Time()

        // This is only for the example, but its also here for something important 
        // Defining this variable here as a local means that, every time this function is ran, the variable is overriden
        // This means that if we define something like a float here, it will always be updated to 2, even if the script updates the number later
        // If we are trying to preserve infomation, this will cause trouble 
        local run_after_time = 2

        // This will initilise our variable and also ensure that if it is null, it means its 0
        // Don't worry about this resetting the value of server_time_check, since this will only run if server_time_check is null
        if (typeof(server_time_check) == "null")
        {
            // You may wonder why ";" is used at the end of some lines. 
            // Here is why, according to ficool2:

            // `it separates a statement, its for people used to other languages where ; are mandatory
            // they (the ";") are optional in squirrel as new lines also count as separate statements`

            // -ficool2, Potato.TF discord, #scripting, 4/11/2024

            server_time_check = 0;
        }

        // [#5] This can seem quite intimidating in "complexity", which could result in -1 attack stat, but will usually confuse newer scripters
        // We want to define our variable (server_time_check) in the scope so that the script doesnt automatically update it until we tell it to do so

        // Now how it works: We save the server time as server_time_check, which is called a "timestamp" (like stamping a note to remember it)
        // Then, we check if cur_time is above server_time_check + run_after_time. run_after_time serves as a "delay", in that we check this 2 seconds after the current timestamp

        // Once cur_time is equal to server_time_check, we save the current time again, and then "check it" 2 seconds later
        if ((server_time_check + run_after_time) <= cur_time)
        {
            ////printl("Ran this after the time we are told to run it")

            server_time_check = cur_time // Document our time once cur_time is equal or above server_time_check. This needs to be here for it to work!
        }
    }

    PsychicPunchieThink = function()
    {
        // self is whoever or whatever has the think

        local trace_start = self.EyePosition() + self.EyeAngles().Forward()
        local range_for_extension = 999999
        local trace_end = trace_start + self.EyeAngles().Forward() * range_for_extension
        local cur_origin = self.GetOrigin()
        local cur_eye_angle = self.EyeAngles().Forward()
        local cur_eye_pos = self.EyePosition()
        local cur_eye_look = self.EyeAngles()
        local active_wep = self.GetActiveWeapon()
        local weapon_last_fire_time = GetPropFloat(active_wep, "m_flNextPrimaryAttack")
        local cur_time = Time()

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

                target.SetAbsOrigin(eyetrace.end + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0))
                
            }
            else if (ent != null && target != null)
            {

                target.SetAbsOrigin(ent.GetOrigin() + Vector(RandomInt(rand_intmin, rand_intmax), RandomInt(rand_intmin, rand_intmax), 0))
                
                
            }

            SetPropEntityArray(laser, "m_hControlPointEnts", target, 0)
            laser.SetAbsOrigin(cur_origin + Vector(0, RandomInt(rand_intmin, rand_intmax), 80))
            laser.SetAbsAngles(cur_eye_look)
            
            // EmitSoundEx({
            //     sound_name = "misc/halloween/spell_lightning_ball_impact.wav",
            //     origin = target.GetOrigin(),
            //     sound_level = sound_range 
            // });
            EntFireByHandle(laser, "Start", "", 0.1, null, null)
            target.AcceptInput("SetParent", "!activator", laser, target) // causes weird particle placement if placed before firing particle
            EntFireByHandle(laser, "Stop", "", 0.2, null, null)
            EntFireByHandle(laser, "Kill", "", 0.3, null, null)
            EntFireByHandle(target, "Kill", "", 0.3, null, null)
            //DebugDrawBox(target.GetOrigin(), Vector(-10, -10, -10), Vector(10, 10, 10), 132, 55, 75, 0, 2)
            // DebugDrawBox(laser.GetOrigin(), Vector(-10, -10, -10), Vector(10, 10, 10), 132, 55, 75, 0, 2)
        }


        // Begin a trace for brushes
        local trace_params =
        {
            start  = trace_start,
            end    = trace_end,
            mask   = (CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_WINDOW | CONTENTS_GRATE),
            ignore = self
        }
        TraceLineEx(trace_params)


        if (GetPropInt(self, "m_Shared.m_iNextMeleeCrit") == 0)
        {
            //printl("fire!")

            //printl("hit!")

            local pos_hit = trace_params.pos
            local target = SpawnEntityFromTable("info_target", 
            {
                targetname = "zap_targ", 
                spawnflags = 1
                origin = pos_hit 
                angles = cur_eye_angle
            })
            local particle = SpawnEntityFromTable("info_particle_system", 
            {
                effect_name = "merasmus_zap_beam_bits", 
                targetname = "temporary"
                origin = cur_eye_pos
                angles = cur_eye_angle
            })  
            particle.SetAbsAngles(cur_eye_look)

            SetPropEntityArray(particle, "m_hControlPointEnts", target, 0);
        
            EntFireByHandle(particle, "Start", "", -1, null, null);
        

            EntFireByHandle(particle, "Stop", "", 0.001, null, null);
            EntFireByHandle(particle, "Kill", "", 0.001 + SINGLE_TICK, null, null);
            EntFireByHandle(target, "Kill", "", 0.002 + SINGLE_TICK, null, null);

            SpawnLaser(target, 0, 0) 
            
            
            // continue smack detection
            SetPropInt(self, "m_Shared.m_iNextMeleeCrit", -2)
        }
    }

    PlayerSpawn = function(player)
    {
        // Store whoever called this function for when we need to clean it up
        // Mostly to help clean up any player ents that may have thinks already on them
        if (Player_Cleanup_Table.find(player) == null)
        {
            ////printl("putting "+player+" in table")
            Player_Cleanup_Table.append(player)
        }

        // "validating" the scope not only checks if the player has a script scope, but if not, creates it
        // If you find that your scripts arent working, check if they are being validated first
        player.ValidateScriptScope()
        local scope = player.GetScriptScope() // [#3]

        //PrintTable(Player_Cleanup_Table)

        // example of how to add multiple thinks to an ent
        // Think Tables are mostly used for players, but also useful for projectiles and tanks which can be copied to make their own tables. Just change its name to something relavent 
        // This also checks if the table exists in player scope, as to not override existing tables
        if (!("myThinkTable" in scope)) 
        {
            ////printl("Created think table")
            // [#1] This is important, as we run our thinks from here 
            scope.myThinkTable <- {} 
        }

        scope.PlayerThinks <- function() 
        { 
            ////printl("Running multiple Player Thinks!")
            foreach (name, func in scope.myThinkTable) 
            {
                func.call(scope); 
            }
            // [#2] This has the think run on every server tick (or "at the end of every frame"). This ensures the script runs consistently, as anything else may cause inconsistencies, including return 0 or return 0.015
            // If you want to know how to run something after a certain amount of time, see [#5]
            return -1 
        }

		AddThinkToEnt(player, "PlayerThinks")
        
        // Remember, we store all our functions within a player's scope, which contains a table
        // This means that ALL functions will share this variable
        // If this creates undesirable effects, make another variable and change the name
        // This is for [#5]

        scope.server_time_check <- 0
        scope.flPunchTime <- 0
        scope.laser <- null
        scope.DispatchParticleEffectEx <- DispatchParticleEffectEx

        // This is how you add your own think function to the think table
        // How it works: VScript only allows one think per entity. Because Valve sucks at coding.
        // Technically, players still have one think, which is called PlayerThinks (you can replace this with your own name fyi)
        // However, all that think does is run functions found within myThinkTable (see [#1])
        // Because thinks are actually functions ran on a timer, we can execute multiple thinks within that table using .call (which calls the function as if you ran it via RunScriptCode)

        // Format: scope (which we refer to as a local, see [#3]), table (see [#1]), name of function that "represents" our think, name of our think

        // Or simply: scope, table, func in scope, think func

        // So the last 2 often confuse newer scripters (or those who have used PopExtensions by Braindawg in the past). I will now (attempt to) explain here
        // This essentially acts like AddThinkToEnt
        // The first part is what is being called within myThinkTable, aka this is how we name our function within the table
        // Think of it as "The function sends a representitive into the table. After being called, the representitive comes back to the think with infomation that is ran on the server"
        // The second part is the name of our think that is stored within the namespace (see [#4]). It is how the main think (PlayerThinks) accesses the function from within the table and calls it
        // In other words, this is how we insert multiple thinks onto a player
        // Also its best to insert the thinks after inserting our variables so that our script doesnt spit out something not existing
        // scope.myThinkTable.myThink1 <- myThink1
        scope.myThinkTable.PsychicPunchieThink <- PsychicPunchieThink
    }   
    
    SpawnMagic = function(player)
    {
        if ( player && player.GetTeam() == TEAM_BLU)
        {
            if (player.IsBotOfType(TF_BOT_FAKE_CLIENT))
            {
                if ( player.HasBotTag("bot_psychic") )
                {
                    printl("found psychic")
                    player.ValidateScriptScope()
                    //printl("found punch")
                    SetPropInt(player, "m_Shared.m_iNextMeleeCrit", -2)
                    PlayerSpawn(player)
                }

            }
        }
    }
    // Event Hooks

    OnGameEvent_player_death = function(params) 
    {
        local player = GetPlayerFromUserID(params.userid)
        
        PlayerCleanup(player)
    }

    // This event runs 1 frame after player_spawn. It also runs when a player upgrades or when firing Regenerate()
    // Its better to use this because player_spawn wont run when a wave initilises
    // Because we check for if the script already exists, we dont have to worry about loading the script after respawning (i.e. upgrading)
    OnGameEvent_post_inventory_application = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        player.ValidateScriptScope()
        local playerscope = player.GetScriptScope()
        
        // // Remember our variables at the top of the script? We use one here. TEAM_RED is the same as 2, only in text form
        // if (player && player.GetTeam() == TEAM_RED)
        // {
        //     PlayerSpawn(player)
        // }
        
        EntFireByHandle(player, "RunScriptCode", "myNamespace.SpawnMagic(self)", 0.1, player, player)

        // if ( player && player.GetTeam() == TEAM_BLU)
        // {
        //     if (player.IsBotOfType(TF_BOT_FAKE_CLIENT))
        //     {
        //         if ( player.HasBotTag("bot_psychic") )
        //         {
        //             printl("found psychic")
        //             player.ValidateScriptScope()
        //             //printl("found punch")
        //             SetPropInt(player, "m_Shared.m_iNextMeleeCrit", -2)
        //             PlayerSpawn(player)
        //         }

        //     }
        // }
        
        
    }

    OnGameEvent_player_spawn = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        player.ValidateScriptScope()
        local playerscope = player.GetScriptScope()

        // If for some reason you cant use post_inventory_application but you need to load something when a player spawns, you can call a function here
        // Because of the quirk with wave initilising, this wont usually run, however we can "late load" this event, which causes it to run. See [#6]
        
        // if (player && player.GetTeam() == TEAM_RED)
        // {
        //     PlayerSpawn(player)
        // }
        
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
    }
};

// [#6] credit to ficool2
// spoof a player spawn for OnGameEvent_player_spawn hook
// !!! may cause issues if used on BLU! !!!
// for (local i = 1, player; i <= MaxClients(); i++)
// {
//     if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == TEAM_RED)
//     {
//         myNamespace.PlayerSpawn(player)
//     }
// }

__CollectGameEventCallbacks(myNamespace) // the OnGameEvent/OnScriptHook outputs need this