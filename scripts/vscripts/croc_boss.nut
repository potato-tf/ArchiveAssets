//vscript by stardustspy
//do not use without my credit PLEASE!!!!!!!!!

::ROOT <- getroottable()

if (!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0

// see "CNetPropManager" for applicable functions
foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

// see "CEntities" for applicable functions
foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

foreach(k, v in ::EntityOutputs.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs)

foreach(k, v in ::NavMesh.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NavMesh[k].bindenv(::NavMesh)

::TEAM_RED <- 2
::TEAM_BLU <- 3
::TF_NAV_SPAWN_ROOM_RED <- 2
::TF_NAV_SPAWN_ROOM_BLUE <- 4
::TF_BOT_FAKE_CLIENT <- 1337
::MAX_COUNT_WEAPON_EQUPPED <- 8
::TEAM_SPECTATOR <- 1
::SOLID_NONE <- 0
::CONTENTS_SOLID <- 1
::CONTENTS_WINDOW <- 2
::CONTENTS_GRATE <- 8
::CONTENTS_MOVEABLE <- 16384
::CONTENTS_PLAYERCLIP <- 65536
::MASK_NPCWORLDSTATIC <- 131083
::MASK_PLAYERSOLID <- 33636363
::MASK_NPCSOLID <- 33701899
::MASK_SOLID <- 33570827
::MASK_SHOT <- 1174421507
::MASK_SHOT_HULL <- 100679691
::IN_ATTACK2 <- 2048
::PI <- 3.14159265359
::PRIMARY_FIRE <- Constants.FButtons.IN_ATTACK
::SECONDARY_FIRE <- Constants.FButtons.IN_ATTACK2
::gamerules <- Entities.FindByClassname(null, "tf_gamerules")
::player_manager <- Entities.FindByClassname(null, "tf_player_manager")
::WORLD_SPAWN <- Entities.FindByClassname(null, "worldspawn")
::MAX_COUNT_PLAYERS <- MaxClients().tointeger()
::MASK_VISIBLE_AND_NPCS <- 33579137
::TF_DMG_CUSTOM_HEADSHOT <- 1
::TF_DMG_CUSTOM_BACKSTAB <- 2

// Define the damage types you want to check for
::DMG_MELEE  <- 134217728  // Melee
::DMG_BURN   <- 8          // Fire
::DMG_BLAST  <- 64         // Blast
::DMG_BULLET <- 2          // Bullet
::TF_DMG_CRITICAL <- 1048576

::SND_NOFLAGS <- 0
::SND_CHANGE_VOL <- 1
::SND_CHANGE_PITCH <- 2
::SND_STOP <- 4
::SND_SPAWNING <- 8
::SND_DELAY <- 16
::SND_STOP_LOOPING <- 32
::SND_SPEAKER <- 64
::SND_SHOULDPAUSE <- 128
::SND_IGNORE_PHONEMES <- 256
::SND_IGNORE_NAME <- 512
::SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL <- 1024

const STRING_NETPROP_ITEMDEF = "m_AttributeManager.m_Item.m_iItemDefinitionIndex"
const SLOT_COUNT = 7
const EFL_USER = 1048576 // EFL_IS_BEING_LIFTED_BY_BARNACLE
const EFL_USER2 = 1073741824 //EFL_NO_PHYSCANNON_INTERACTION
const SINGLE_TICK = 0.015
const DMG_NO_BULLET_FALLOFF = 2097152

PrecacheSound("ambient/energy/weld1.wav")
PrecacheSound("ambient/energy/weld2.wav")
PrecacheSound("player/recharged.wav")
PrecacheSound("npc/assassin/ball_zap1.wav")
PrecacheSound("weapons/drg_wrench_teleport.wav")
PrecacheSound("misc/halloween/spell_lightning_ball_cast.wav")
PrecacheSound("misc/halloween/spell_meteor_impact.wav")
PrecacheSound("misc/halloween/spell_spawn_boss.wav")
PrecacheSound("ambient/lair/crocs_swim_burst.wav")
PrecacheModel("models/props_mvm/robot_spawnpoint_warning.mdl")
PrecacheModel("models/props_island/crocodile/crocodile.mdl")
PrecacheSound("ambient/lair/crocs_jump_bite.wav")
PrecacheSound("ambient_mp3/lair/crocs_growl5.mp3")
PrecacheSound("ambient_mp3/lair/crocs_hiss3.mp3")
PrecacheSound("physics/flesh/flesh_bloody_break.wav")

local nav_area_table = {}
NavMesh.GetAllAreas(nav_area_table)

//fold
::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			ROOT[k] <- v != null ? v : 0;
}

// we love shitscripting

::crocBossScript <-
{
    IsWaveStarted = false

    IsAlive = function(player)
    {
		return GetPropInt(player, "m_lifeState") == 0
	}

    Cleanup = function()
    {
        for (local player; player = Entities.FindByClassname(player, "player");)
        {
            NetProps.SetPropString(player, "m_iszScriptThinkFunction", "")
            AddThinkToEnt(player, null)
            player.SetScriptOverlayMaterial("")
        }

        // keep this at the end
        delete ::crocBossScript
    }

    CleanTargets = function()
    {
        for (local ent; ent = FindByClassname(ent, "info_target");)
        {
            if (ent.GetName() == "crocodile_event")
            {
                ////printl("killing: "+ent)
                ent.Kill()
            }
            if (ent.GetName() == "crocodile_virus")
            {
                ////printl("killing: "+ent)
                ent.Kill()
            }
            // else
            // {
            //     //printl("we found "+ent+" but it doesnt match our stuff")
            // }
        }
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
        CleanTargets()
        Cleanup()
    }

    OnGameEvent_mvm_wave_failed = function(params)
    {
        CleanTargets()
    }

    OnGameEvent_mvm_reset_stats = function(params)
    {
        CleanTargets()
    }

    OnGameEvent_player_death = function(params)
    {
        local player = GetPlayerFromUserID(params.userid);
        local attacker = GetPlayerFromUserID(params.attacker);
        local true_death = params.death_flags;
        local victim_entindex = params.victim_entindex;
        local inflictor_entindex = params.inflictor_entindex;
        local weapon = params.weapon;
        local weaponid = params.weaponid;
        local damagebits = params.damagebits;
        local customkill = params.customkill;
        local assister = params.assister;
        local weapon_logclassname = params.weapon_logclassname;
        local stun_flags = params.stun_flags;
        local silent_kill = params.silent_kill;
        local rocket_jump = params.rocket_jump;
        local weapon_def_index = params.weapon_def_index;
        local crit_type = params.crit_type;

        if (player && player.GetTeam() == TEAM_RED && !(true_death & 32))
        {
            CureVirus(player, true)
        }
    }

    OnGameEvent_mvm_pickup_currency = function(params)
    {
        local player = params.player
        local currency = params.currency

        local player_entity = EntIndexToHScript(player)

        if (player_entity.GetPlayerClass() == 1)
        {
            crocBossScript.CureVirus(player_entity, false)
        }
    }

    OnGameEvent_player_used_powerup_bottle = function(params)
    {
        local player = params.player
        local canteen = params.type

        local player_ent = EntIndexToHScript(player)

        //printl("Player: "+player_ent)
        //printl("Canteen: "+canteen)

        if (canteen == 3) // recall
        {
            crocBossScript.CureVirus(player_ent, false)
        }
    }

    OnGameEvent_player_healed = function(params)
    {
        local patient = params.patient
        local healer = params.healer
        // local amount = params.amount

        local entity = GetPlayerFromUserID(params.patient)
        local healer_entity = GetPlayerFromUserID(params.healer)

        ////printl(entity)

        if (healer == 0)
        {
            ////printl("healer is healthkit")
            CureVirus(entity, false)
        }

        // no mad milk/conch healing
        if (healer_entity != null && healer_entity.GetPlayerClass() != 3 && healer_entity.GetPlayerClass() != 1)
        {
            ////printl("healer is player: "+healer_entity)
            CureVirus(entity, false)
        }
    }

    OnGameEvent_player_spawn = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        player.ValidateScriptScope()
        local playerscope = player.GetScriptScope()

        if (player && player.GetTeam() == 3 && player.IsBotOfType(1337))
        {
            EntFireByHandle(gamerules, "RunScriptCode", "crocBossScript.CheckForBot(activator)", 0.1, player, player)
        }
    }

    OnGameEvent_post_inventory_application = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        player.ValidateScriptScope()
        local playerscope = player.GetScriptScope()

        // if (player && player.GetTeam() == 2)
        // {
        //     EntFireByHandle(player, "RunScriptCode", "caller.SetHealth(5000)", 0.5, player, player)
        // }

        ////printl(primary)
    }

    BeginCrocodileEvent = function(iCrocCount, flAttackInterval)
    {
        for (local player; player = FindByClassname(player, "player");)
        {
            if (player == null)
            {
                continue
            }
            if (player.GetTeam() != TEAM_RED)
            {
                continue
            }
            ClientPrint(player, 4, "The Crocodiles have SNAPPED! Watch your step!")
            // player.EmitSound("ambient_mp3/lair/crocs_hiss3.mp3")
            // player.EmitSound("ambient_mp3/lair/crocs_growl5.mp3")
        }

        function InitiateCrocodileAttack(origin)
        {
            local enemy_classnames = ["player", "obj_*", "tank_boss"];

            ////printl(origin)

            foreach (entry in enemy_classnames)
            {
                for (local enemy; enemy = FindByClassnameWithin(enemy, entry, origin, 50);)
                {
                    ////printl("found ent: "+enemy)
                    if (enemy.GetClassname() != "tank_boss")
                    {
                        ////printl("damaging ent: "+enemy)
                        enemy.TakeDamageCustom(null, WORLD_SPAWN, null, Vector(0, 0, 0), enemy.GetOrigin(), 99999, 8192, 81)
                    }
                    else if (enemy.GetClassname() == "player" && enemy.IsMiniBoss())
                    {
                        enemy.TakeDamageCustom(null, WORLD_SPAWN, null, Vector(0, 0, 0), enemy.GetOrigin(), 750, 8192, 81)
                    }
                    else
                    {
                        enemy.TakeDamageCustom(null, WORLD_SPAWN, null, Vector(0, 0, 0), enemy.GetOrigin(), 99999, 8192, 81)
                    }
                }
            }

            local crocodile_prop = SpawnEntityFromTable("prop_dynamic",
            {
                model = "models/props_island/crocodile/crocodile.mdl"
                origin = origin
                angles = Vector(0, 0, 0)
                disableshadows = 1
                DefaultAnim = "attack"
                targetname = "croco"
            })
            EntFireByHandle(crocodile_prop, "Kill", "", 1.3, null, null)
        }

        ::CrocodileEventThink <- function()
        {

            ////printl(self)

            local cur_time = Time()

            if ((flServerTime + flCrocTriggerTime) <= cur_time && iSuccessAttackCount <= iAttackCount)
            {
                local minareasize = 1500;
                local spots = []
                local total_origin = Vector(0, 0, 0)
                local player_count = 0

                for (local player; player = FindByClassname(player, "player");)
                {
                    if (player.GetTeam() != TEAM_SPECTATOR)
                    {
                        total_origin += player.GetOrigin()
                        player_count += 1
                    }
                }

                local average_origin_x = null
                local average_origin_y = null
                local average_origin_z = null
                if (player_count > 0)
                {
                    average_origin_x = total_origin.x / player_count
                    average_origin_y = total_origin.y / player_count
                    average_origin_z = total_origin.z / player_count
                }

                local average = Vector(average_origin_x, average_origin_y, average_origin_z)

                local nav_table_average = {}
                NavMesh.GetNavAreasInRadius(average, 2000, nav_table_average)

                foreach(id, nav in nav_table_average)
                {
                    if (nav.GetSizeX() * nav.GetSizeY() > minareasize && !nav.HasAttributeTF(TF_NAV_SPAWN_ROOM_RED) && !nav.HasAttributeTF(TF_NAV_SPAWN_ROOM_BLUE) && nav.IsReachableByTeam(3))
                    {
                        spots.append(nav)
                    }
                }

                local nav = spots[RandomInt(0, spots.len() - 1)]
                local spot = nav.FindRandomSpot()

                local soundlevel = (40 + (20 * log10(1200 / 36.0))).tointeger()

                local warning = SpawnEntityFromTable("prop_dynamic",
                {
                    model = "models/props_mvm/robot_spawnpoint_warning.mdl"
                    origin = spot
                    angles = Vector(0, 0, 0)
                    disableshadows = 1
                    targetname = "warning"
                })
                EmitSoundEx
                ({
                    sound_name = "ambient/lair/crocs_swim_burst.wav",
                    origin = spot,
                    sound_level = soundlevel
                });
                EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 0, warning, warning)
                EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 0.5, warning, warning)
                EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 1, warning, warning)

                EntFireByHandle(self, "RunScriptCode", "InitiateCrocodileAttack(activator.GetOrigin())", 2, warning, warning)
                EntFireByHandle(warning, "Kill", "", 2, warning, warning)

                // //printl("attack at: "+spot)
                // //printl("attacks: "+iSuccessAttackCount)

                iSuccessAttackCount++

                flServerTime = cur_time
            }

            return -1
        }

        local CrocodileEventDummy = SpawnEntityFromTable("info_target",
        {
            targetname = "crocodile_event"
            origin = "0 0 0"
        })

        CrocodileEventDummy.ValidateScriptScope()
        local DummyScope = CrocodileEventDummy.GetScriptScope()

        DummyScope.iAttackCount <- iCrocCount
        DummyScope.flCrocTriggerTime <- flAttackInterval
        DummyScope.flServerTime <- 0
        DummyScope.iSuccessAttackCount <- 0
        DummyScope.InitiateCrocodileAttack <- InitiateCrocodileAttack
        DummyScope.DispatchParticleEffectEx <- DispatchParticleEffectEx

        AddThinkToEnt(CrocodileEventDummy, "CrocodileEventThink")

        EntFireByHandle(CrocodileEventDummy, "Kill", "", iCrocCount + 2, CrocodileEventDummy, CrocodileEventDummy)
    }

    SetDestroyCallback = function(entity, callback)
    {
        entity.ValidateScriptScope()
        local scope = entity.GetScriptScope()
        scope.setdelegate({}.setdelegate({
                parent   = scope.getdelegate()
                id       = entity.GetScriptId()
                index    = entity.entindex()
                callback = callback
                _get = function(k)
                {
                    return parent[k]
                }
                _delslot = function(k)
                {
                    if (k == id)
                    {
                        entity = EntIndexToHScript(index)
                        local scope = entity.GetScriptScope()
                        scope.self <- entity
                        callback.pcall(scope)
                    }
                    delete parent[k]
                }
            })
        )
    }

    HealthKitThink = function()
    {
        local origin = self.GetOrigin()

        if (GetPropBool(self, "m_bDisabled") == false)
        {
            for (local player; player = FindByClassnameWithin(player, "player", origin, 40);)
            {
                if (player.GetTeam() == TEAM_RED)
                {
                    //printl("attempting cure player in think")
                    // Damaging the player is the most seemless way to implement this but this might result in unexpected deaths
                    // player.TakeDamageCustom(null, WORLD_SPAWN, null, Vector(0, 0, 0), player.GetOrigin(), 1, 4096 + 131072, 16)

                    crocBossScript.CureVirus(player, false)
                    EntFireByHandle(self, "Disable", "", -1, player, player);
                    EntFireByHandle(self, "Enable", "", 3, player, player);
                }
            }
        }

        return -1
    }

    BeginVirusEvent = function()
    {
        ////printl("Calling new virus event")
        ::VirusThink <- function()
        {
            local cur_time = Time()

            for (local hp_pack; hp_pack = FindByClassname(hp_pack, "item_healthkit_*");)
            {
                local pack_origin = hp_pack.GetOrigin()
                hp_pack.ValidateScriptScope()

                if (NetProps.GetPropString(hp_pack, "m_iszScriptThinkFunction") != "HealthKitThink")
                {
                    //printl("added think to pack")

                    AddThinkToEnt(hp_pack, "HealthKitThink")
                }

                if (GetPropBool(hp_pack, "m_bDisabled") == false)
                {
                    for (local player; player = FindByClassnameWithin(player, "player", pack_origin, 40);)
                    {
                        if (player.GetTeam() == TEAM_RED)
                        {
                            // Damaging the player is the most seemless way to implement this but this might result in unexpected deaths
                            // player.TakeDamageCustom(null, WORLD_SPAWN, null, Vector(0, 0, 0), player.GetOrigin(), 1, 4096 + 131072, 16)

                            crocBossScript.CureVirus(player, false)
                            EntFireByHandle(hp_pack, "Disable", "", -1, player, player);
                            EntFireByHandle(hp_pack, "Enable", "", 3, player, player);
                        }
                    }
                }
            }

            foreach (key, entry in tPlayersToRegenerate)
            {
                local victim = entry.victim
                local attacker = entry.attacker
                local sick_time = entry.flTimeUntilCure
                local victim_origin = victim.GetOrigin()

                if (cur_time >= sick_time)
                {
                    crocBossScript.CureVirus(victim, false)
                    // ClientPrint(victim, 4, "The virus dissapates...")
                }
            }

            if ((flVirusTime + 0.75) <= cur_time)
            {
                foreach (key, entry in tPlayersToRegenerate)
                {
                    local victim = entry.victim
                    local attacker = entry.attacker
                    local sick_time = entry.flTimeUntilCure

                    ////printl("Player in array: "+victim)
                    ////printl("Player as attacker: "+attacker)

                    if (entry.bCured == true || cur_time >= sick_time)
                    {
                        tPlayersToRegenerate.remove(key)
                        continue
                    }

                    if (victim == null || !crocBossScript.IsAlive(victim))
                    {
                        ////printl("removing "+victim)
                        tPlayersToRegenerate.remove(key)
                    }

                    if (crocBossScript.IsAlive(victim) && victim != null)
                    {
                        ////printl("entity "+victim+" is missing health, the virus infects...")
                        local dmg_penalty = victim.GetCustomAttribute("damage penalty", 1)
                        local sniper_dmg_penalty = victim.GetCustomAttribute("dmg penalty vs players", 1)
                        local switch_speed_penalty = victim.GetCustomAttribute("deploy time increased", 1)
                        local heal_penalty = victim.GetCustomAttribute("heal rate penalty", 1)
                        local sentry_dmg_penalty = victim.GetCustomAttribute("engy sentry damage bonus", 1)
                        local uber_rate_penalty = victim.GetCustomAttribute("ubercharge rate penalty", 1)

                        if (heal_penalty > 0.25)
                        {
                            victim.AddCustomAttribute("heal rate penalty", heal_penalty - 0.05, -1)
                            victim.AddCustomAttribute("deploy time increased", switch_speed_penalty + 0.05, -1)
                            victim.AddCustomAttribute("engy sentry damage bonus", sentry_dmg_penalty - 0.05, -1)
                            victim.AddCustomAttribute("ubercharge rate penalty", uber_rate_penalty - 0.05, -1)

                            // sniper can have his EH nerfed, tank busting doesnt matter as much to him

                            // 2 = sniper
                            if (victim.GetPlayerClass() == 2)
                            {
                                victim.AddCustomAttribute("dmg penalty vs players", sniper_dmg_penalty - 0.05, -1)
                            }
                            else
                            {
                                victim.AddCustomAttribute("damage penalty", dmg_penalty - 0.05, -1)
                            }
                        }

                        local sound_range = (40 + (20 * log10(3000 / 36.0))).tointeger();

                        EmitSoundEx
                        ({
                            sound_name = "physics/flesh/flesh_bloody_break.wav",
                            origin = victim.GetOrigin(),
                            volume = 1
                            sound_level = sound_range
                            entity = victim
                            filter = RECIPIENT_FILTER_SINGLE_PLAYER
                        });

                        SendGlobalGameEvent("player_healonhit",
                        {
                            entindex = victim.entindex(),
                            amount = -3,
                            weapon_def_index = 65535 // INVALID_ITEM_DEF_INDEX
                        });

                        // for some reason if sethealth goes below 0, the player lives
                        local cur_health = victim.GetHealth() - 3
                        if (cur_health > 0)
                        {
                            victim.SetHealth(victim.GetHealth() - 3)
                        }
                        else
                        {
                            victim.SetScriptOverlayMaterial("")
                            victim.TakeDamageCustom(null, attacker, attacker.GetActiveWeapon(), Vector(0, 0, 0), victim.GetOrigin(), 99999, 4096 + 131072, 16)
                        }
                    }
                    // else if (crocBossScript.IsAlive(victim) && victim != null && victim.GetHealth() >= victim.GetMaxHealth())
                    // {
                    //     //printl("entity "+victim+" is max health! The virus corrupts!")
                    //     victim.SetScriptOverlayMaterial("")

                    //     for (local child = victim.FirstMoveChild(); child != null; child = child.NextMovePeer())
                    //     {
                    //         if (child.GetName() == "skulls_sickness")
                    //         {
                    //             child.Destroy()
                    //         }
                    //     }

                    //     victim.TakeDamageCustom(null, attacker, attacker.GetActiveWeapon(), Vector(0, 0, 0), victim.GetOrigin(), 99999, 4096 + 131072, 16)
                    // }
                }


                flVirusTime = cur_time
            }

            return -1
        }

        local bFindVirus = null

        for (local ent; ent = FindByClassname(ent, "info_target");)
        {
            local found_ent = false

            if (ent.GetName() == "crocodile_virus")
            {
                found_ent = true
            }

            if (found_ent == true)
            {
                bFindVirus = true
            }
        }

        if (bFindVirus == true)
        {
            ////printl("Virus entity already exists!")
            return
        }

        local VirusDummy = SpawnEntityFromTable("info_target",
        {
            targetname = "crocodile_virus"
            origin = "0 0 0"
        })

        VirusDummy.ValidateScriptScope()
        local DummyScope = VirusDummy.GetScriptScope()

        DummyScope.tPlayersToRegenerate <- []
        DummyScope.flVirusTime <- 0

        AddThinkToEnt(VirusDummy, "VirusThink")
    }

    CureVirus = function(player, death_boolean)
    {
        ////printl("Curing player: "+player)
        //printl("cured: "+player)

        for (local ent; ent = FindByClassname(ent, "info_target");)
        {
            if (ent == null)
            {
                continue
            }
            if (ent.GetName() == "crocodile_virus")
            {
                ////printl("Found virus event")
                ent.ValidateScriptScope()
                local VirusScope = ent.GetScriptScope()

                local VirusArray = VirusScope.tPlayersToRegenerate
                //PrintTable(VirusArray)

                for (local i = VirusArray.len() - 1; i >= 0; i--)
                {
                    local victim = VirusArray[i].victim
                    local boolean = VirusArray[i].bCured
                    ////printl("curing victim in array: "+victim)

                    if (victim == player)
                    {
                        ////printl("curing: "+victim)
                        VirusArray.remove(i)
                        //printl(boolean)
                        boolean = true
                        //printl(boolean)
                        player.SetScriptOverlayMaterial("")
                        player.AddCondEx(121, 5, null)

                        victim.RemoveCustomAttribute("heal rate penalty")
                        victim.RemoveCustomAttribute("deploy time increased")
                        victim.RemoveCustomAttribute("engy sentry damage bonus")
                        victim.RemoveCustomAttribute("ubercharge rate penalty")

                        // 2 = sniper
                        if (victim.GetPlayerClass() == 2)
                        {
                            victim.RemoveCustomAttribute("dmg penalty vs players")
                        }
                        else
                        {
                            victim.RemoveCustomAttribute("damage penalty")
                        }

                        if (death_boolean == false)
                        {
                            ClientPrint(player, 4, "You're cured! You cannot be infected for 5 seconds!")
                        }

                        for (local next, child = player.FirstMoveChild(); child; child = next)
                        {
                            next = child.NextMovePeer()
                            if (child.GetName() == "skulls_sickness")
                            {
                                child.Kill()
                            }
                        }
                    }
                    else
                    {
                        continue
                    }
                }
            }
        }
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

    InitiateCrocodileAttack = function(origin, ent)
    {
        local enemy_classnames =
        {
            "player" : 1
            "obj_teleporter" : 1
            "obj_sentrygun" : 1
            "obj_dispenser" : 1
        }
        ////printl("Dealt damage at: " + origin)
        for (local enemy; enemy = FindInSphere(enemy, origin, 50);)
        {
            if (enemy.GetClassname() in enemy_classnames && enemy.GetTeam() != ent.GetTeam() && enemy.GetTeam() != TEAM_SPECTATOR)
            {
                enemy.TakeDamageCustom(null, ent, ent.GetActiveWeapon(), Vector(0, 0, 0), enemy.GetOrigin(), 99999, 8192, 81)
            }
        }
        local crocodile_prop = SpawnEntityFromTable("prop_dynamic",
        {
            model = "models/props_island/crocodile/crocodile.mdl"
            origin = origin
            angles = Vector(0, 0, 0)
            disableshadows = 1
            DefaultAnim = "attack"
            targetname = "warning"
        })
        EntFireByHandle(crocodile_prop, "Kill", "", 1.3, null, null)
    }


    CrocBossSetup = function(ent)
    {
        ent.ValidateScriptScope()
        local scope = ent.GetScriptScope()

        ::CrocThink <- function()
        {
            //self.SetForcedTauntCam(1);

            // Loop through all rockets of class "tf_projectile_rocket"
            for (local rocket; rocket = Entities.FindByClassname(rocket, "tf_projectile_rocket");)
            {
                local wep_owner = NetProps.GetPropEntity(rocket, "m_hLauncher") // Get the launcher
                if (wep_owner.GetOwner() == self) // Check if the rocket belongs to this entity
                {
                    // Check if the rocket is already in the list
                    local found = false
                    foreach (entry in rocket_list)
                    {
                        if (entry.rocket == rocket)
                        {
                            found = true
                            break
                        }
                    }

                    if (!found)
                    {
                        local origin = rocket.GetOrigin() // Get the rocket's origin
                        // Add rocket and its origin to the list as a table entry
                        rocket_list.append({rocket = rocket, origin = origin})
                    }
                }
            }

            // Iterate through the rocket list and update the origin or remove invalid rockets
            for (local i = 0; i < rocket_list.len();)
            {
                local entry = rocket_list[i]
                local rocket = entry.rocket

               // //printl(rocket)

                // If the rocket is invalid or null, remove it from the list
                if (!rocket.IsValid() || rocket == null)
                {
                    // //printl("Rocket no longer valid!")
                    // //printl(entry.origin)
                    local found_origin = entry.origin
                    local area_to_use = null
                    local check_croc = NavMesh.FindNavAreaAlongRay(found_origin, found_origin + Vector(0, 0, -35), null)

                    //the point of checking if croc is null is to ensure that if we get a direct hit/do not hit the ground, we can initiate our attack
                    //and have it not look ugly
                    if (check_croc == null)
                    {
                        //use trace so we can find the exact spot rather then doing weird ass .length shit that hurts my brain
                        local trace =
                        {
                            start = found_origin,  // Starting point of the line
                            end = found_origin + Vector(0, 0, -125),  // Ending point of the line
                            hullmin = Vector(-1, -1, -1),  // Min hull extents
                            hullmax = Vector(1, 1, 1)  // Max hull extents
                            mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_GRATE),
                            ignore = self
                        }

                        TraceHull(trace)

                        if (trace.hit)
                        {
                           // //printl("Hit at: " + trace.pos)  // This will be the closest point on the line that was hit
                            area_to_use = trace.pos
                        }
                    }
                    else
                    {
                        area_to_use = found_origin
                    }

                    if (area_to_use == null)
                    {
                        rocket_list.remove(i) // Remove invalid rocket
                        continue // Skip incrementing 'i', since the list shrunk
                    }

                    // Store the last known origin and the time to execute the command
                    local execution_time = Time() + 1.75
                    local warning = SpawnEntityFromTable("prop_dynamic",
                    {
                        model = "models/props_mvm/robot_spawnpoint_warning.mdl"
                        origin = area_to_use
                        angles = Vector(0, 0, 0)
                        disableshadows = 1
                        targetname = "warning"
                    })
                    local soundlevel = (40 + (20 * log10(1200 / 36.0))).tointeger()

                    EmitSoundEx
                    ({
                        sound_name = "ambient/lair/crocs_swim_burst.wav",
                        origin = area_to_use,
                        sound_level = soundlevel
                    });
                    EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 0, warning, warning)
                    EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 0.5, warning, warning)
                    EntFireByHandle(self, "RunScriptCode", "DispatchParticleEffect(`target_break_initial_dust`, activator.GetOrigin(), Vector(-90, 0, 0))", 1, warning, warning)
                    execute_command_list.append({origin = area_to_use, time = execution_time, warn_prop = warning})

                    rocket_list.remove(i) // Remove invalid rocket
                    continue // Skip incrementing 'i', since the list shrunk
                }
                else
                {
                    // Update the origin for valid rockets
                    entry.origin = rocket.GetOrigin()
                    i++ // Increment only if the rocket is still valid
                }
            }

            // Check the execute_command_list for any commands to execute
            for (local j = 0; j < execute_command_list.len();)
            {
                local command_entry = execute_command_list[j]
                local command_time = command_entry.time

                // If the command time matches the current time, execute the function
                if (command_time <= Time())
                {
                    InitiateCrocodileAttack(command_entry.origin, self) // Call the attack function
                    execute_command_list.remove(j) // Remove the executed command
                   // //printl("executed!")

                    if (command_entry.warn_prop.IsValid() || command_entry.warn_prop != null)
                    {
                        command_entry.warn_prop.Kill()
                    }
                    continue
                }
                j++ // Increment if not executed
            }

            return -1
        }

        scope.rocket_list <- []
        scope.execute_command_list <- []
        scope.InitiateCrocodileAttack <- InitiateCrocodileAttack
        AddThinkToEnt(ent, "CrocThink")
    }

    SwarmerSetup = function(ent)
    {
        ent.ValidateScriptScope()
        local scope = ent.GetScriptScope()

        ::SwarmerThink <- function()
        {
            local cur_time = Time()
            local origin = self.GetOrigin()

            if (GetPropInt(self, "m_lifeState") != 0)
            {
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
                AddThinkToEnt(self, null)
                return -1
            }

            for (local player; player = FindByClassnameWithin(player, "player", origin, 250);)
            {
                if (player.GetTeam() == TEAM_BLU && player.IsBotOfType(TF_BOT_FAKE_CLIENT) && player.HasBotTag("bot_swarmer"))
                {
                    if ((flTimeUntilNextParticle + 0.8) <= cur_time)
                    {
                        DispatchParticleEffectEx("soldierbuff_mvm", origin, Vector(0, 0, 0), -1, 0.35, self, false, true, self);
                        flTimeUntilNextParticle = cur_time
                    }
                }
            }

            return -1
        }

        scope.flTimeUntilNextParticle <- 0
        scope.DispatchParticleEffectEx <- DispatchParticleEffectEx
        AddThinkToEnt(ent, "SwarmerThink")
    }

    function PrintTable(table)
    {
        if (table == null) return;

        this.DoPrintTable(table, 0)
    }

    function DoPrintTable(table, indent) {
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

    function CheckForBot(ent)
    {
        if (ent.HasBotTag("bot_crocodile_boss"))
        {
            EntFireByHandle(gamerules, "RunScriptCode", "crocBossScript.CrocBossSetup(activator)", 0.1, ent, ent)
        }

        if (ent.HasBotTag("bot_swarmer"))
        {
            EntFireByHandle(gamerules, "RunScriptCode", "crocBossScript.SwarmerSetup(activator)", 0.1, ent, ent)
        }
    }

    PlayerSpawn = function(player)
    {
        // do stuff when player "spawns" here
        CheckForBot(player)
    }

    OnScriptHook_OnTakeDamage = function(params)
    {
        local victim = params.const_entity
        local attacker = params.attacker
        local dmgtype = params.damage_type
        local weapon = params.weapon
        local special_dmgtype = params.damage_stats

        local enemy_classnames =
        {
            "player" : 1
            "obj_teleporter" : 1
            "obj_sentrygun" : 1
            "obj_dispenser" : 1
        }

        // REGULAR CROCODILES
        local damage_type_list =
        [
            DMG_BLAST,
            DMG_MELEE,
            DMG_BULLET,
            DMG_BURN
        ]

        // Check if attacker is a valid player bot with the right tag
        if (attacker != null && attacker.GetClassname() == "player" && attacker.IsBotOfType(TF_BOT_FAKE_CLIENT) && attacker.HasBotTag("bot_crocodile"))
        {
            // Check if the damage type is in the list
            local is_valid_damage = false

            foreach (type_dmg in damage_type_list)
            {
                // Check if the current type matches the damage type
                if (dmgtype & type_dmg)
                {
                    is_valid_damage = true
                    break
                }
            }

            // Check if it's a critical hit and if the damage type is valid
            if (victim.GetClassname() in enemy_classnames && attacker.GetClassname() in enemy_classnames && attacker.GetTeam() != victim.GetTeam() && is_valid_damage && (dmgtype & TF_DMG_CRITICAL) != TF_DMG_CRITICAL && !victim.InCond(65))
            {
                ////printl("We found a viable type!")

                // Apply effects to the victim
                victim.AddCustomAttribute("CARD: move speed bonus", 0.5, 3)
                victim.AddCondEx(15, 3, null)
                victim.SetScriptOverlayMaterial("effects/water_warp")
                victim.AddCondEx(65, 10, null)
                // if (victim.GetClassname() == "player" && victim.GetTeam() != attacker.GetTeam())
                // {
                //     victim.EmitSound("ambient/lair/crocs_jump_bite.wav")
                // }

                // Clear overlay after 3 seconds
                EntFireByHandle(gamerules, "RunScriptCode", "activator.SetScriptOverlayMaterial(``)", 3, victim, victim)
            }
        }

        // CROCODILE SWARMER

        // DEALING DAMAGE
        if (attacker != null && attacker.GetClassname() == "player" && attacker.IsBotOfType(TF_BOT_FAKE_CLIENT) && attacker.HasBotTag("bot_swarmer"))
        {
            local dmg_dealt_mult = 1

            ////printl("normal damage: "+params.damage)

            for (local player; player = FindByClassnameWithin(player, "player", attacker.GetOrigin(), 250);)
            {
                if (player.GetTeam() == TEAM_BLU && player.IsBotOfType(TF_BOT_FAKE_CLIENT) && player != attacker && player.HasBotTag("bot_swarmer"))
                {
                    dmg_dealt_mult += 0.05
                }
            }

            ////printl("dmg mult: "+dmg_dealt_mult)

            params.damage = params.damage * dmg_dealt_mult

            ////printl("new damage: "+params.damage)
        }

        // TAKING DAMAGE
        if (attacker != null && victim.GetClassname() == "player" && victim.IsBotOfType(TF_BOT_FAKE_CLIENT) && victim.HasBotTag("bot_swarmer"))
        {
            local dmg_dealt_mult = 1

            ////printl("normal damage taken: "+params.damage)

            for (local player; player = FindByClassnameWithin(player, "player", attacker.GetOrigin(), 250);)
            {
                if (player.GetTeam() == TEAM_BLU && player.IsBotOfType(TF_BOT_FAKE_CLIENT) && player != attacker && player.HasBotTag("bot_swarmer"))
                {
                    dmg_dealt_mult -= 0.05
                }
            }

            ////printl("resist mult: "+dmg_dealt_mult)

            params.damage = params.damage * dmg_dealt_mult

            ////printl("new damage taken: "+params.damage)
        }

        // CROCODILE SPITTER

        if (weapon != null)
        {
            local spitter = weapon.GetAttribute("cannot giftwrap", 0)

            if (spitter != 0 && params.damage > 0 && special_dmgtype != 16)
            {
                ////printl("spit on")

                crocBossScript.BeginVirusEvent()

                for (local ent; ent = FindByClassname(ent, "info_target");)
                {
                    if (ent.GetName() == "crocodile_virus")
                    {
                        ////printl("Beginning new virus event")
                        ent.ValidateScriptScope()
                        local VirusScope = ent.GetScriptScope()

                        if (victim.GetClassname() == "player" && victim.GetTeam() != attacker.GetTeam() && VirusScope.tPlayersToRegenerate.find(victim) == null && !victim.InCond(121))
                        {
                            foreach (entry in VirusScope.tPlayersToRegenerate)
                            {
                                if (entry.victim == victim)
                                {
                                    ////printl("we found our player already")
                                    return
                                }
                            }

                            local sick_duration = 10

                            ////printl("added "+victim+"to virus array")
                            ClientPrint(victim, 4, "You're sick! Find a source of direct healing!")
                            victim.SetScriptOverlayMaterial("models/props_combine/portalball001_sheet")
                            //utaunt_poison_fadingskulls_g

                            local particle = SpawnEntityFromTable("info_particle_system",
                            {
                                effect_name = "utaunt_poison_fadingskulls_g",
                                targetname = "skulls_sickness"
                                origin = victim.GetOrigin()
                                angles = Vector(0, 0, 0)
                            })
                            EntFireByHandle(particle, "SetParent", "!activator", -1, victim, victim)
                            particle.AcceptInput("Start", "", null, null)

                            VirusScope.tPlayersToRegenerate.append({victim = victim, attacker = attacker, bCured = false, flTimeUntilCure = Time() + sick_duration})
                        }
                    }
                }

                return
            }
        }
    }
};

for (local i = 1, player; i <= MaxClients(); i++)
{
    if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 3)
    {
        crocBossScript.PlayerSpawn(player)
        crocBossScript.CureVirus(player, true)
    }
}


__CollectGameEventCallbacks(crocBossScript)
