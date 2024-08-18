__potato.MapFixes <- {}
__potato.MapFixes.Events <- {
    // Apply map fixes whenever entities are recreated.
    //  Fired every wave fail, wave jump or mission change.
    function OnGameEvent_teamplay_round_start(_) { switch (GetMapName()) {
        // Bronx RC2
        // - Fixes performance issues and large demos caused by bone followers on map engibots.
        // - Fixes death pit not killing ubered players.
        case "mvm_bronx_rc2":
            // Disable bone followers.
            for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
                if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
                    NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0)

            // Fix the death pit not killing ubered players.
            for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt");) {
                if (deathpit.GetName() != "trigger_hurt_hatch_fire") {
                    NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", Constants.FDmgType.DMG_ACID)   // DMG_CRITICAL
                    deathpit.AcceptInput("SetDamage", "10000", null, null)
                }
            }
            break

        // Decompose RC6B
        // - Adds a trigger_teleport to fix bots getting stuck in the wrong spawn door.
        // - Fixes the respawn room visualizers rendering behind props that are behind them.
        // - Hides the front vis as it has a black alpha layer on first map load.
        case "mvm_decompose_rc6b":
            for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
            local frontvis = Entities.FindByClassnameNearest("func_respawnroomvisualizer",
                                Vector(172, -2506.02, 355.5), 10.0)
            NetProps.SetPropInt(frontvis, "m_nRenderMode", Constants.ERenderMode.kRenderNone)

            // Setup gate teleport entities.
            SpawnEntityFromTable("info_teleport_destination", {
                targetname = "unstuck_dest"
                origin = Vector(164, -3048, 247)
            })
            local door_unstuck = SpawnEntityFromTable("trigger_teleport", {
                targetname = "unstuck_trigger"
                target = "unstuck_dest"
                origin = Vector(-3336, -3416, 295)
                spawnflags = 1  // Clients only
            })
            door_unstuck.SetSize(Vector(-808, -344, -295), Vector(808, 344, 295))
            door_unstuck.SetSolid(Constants.ESolidType.SOLID_BBOX)

            // Enable/disable based on gate capture status.
            EntityOutputs.AddOutput(Entities.FindByName(null, "wave_reset_relay"),
                "OnTrigger", "unstuck_trigger", "Enable", "", -1, -1)
            EntityOutputs.AddOutput(Entities.FindByName(null, "gate01_relay"),
                "OnTrigger", "unstuck_trigger", "Disable", "", -1, -1)
            break

        // Giza B7
        // - Fix an out-of-bounds access spot.
        case "mvm_giza_b7":
            local f = Entities.CreateByClassname("func_forcefield")
            f.SetModel("models/empty.mdl")
            f.SetAbsOrigin(Vector(-1024, -1980, 2016))
            NetProps.SetPropVector(f, "m_Collision.m_vecMinsPreScaled", Vector(-256, -68, -1056))
            NetProps.SetPropVector(f, "m_Collision.m_vecMaxsPreScaled", Vector(256, 68, 1056))
            f.SetSize(Vector(-256, -68, -1056), Vector(256, 68, 1056))
            f.SetSolid(Constants.ESolidType.SOLID_BBOX)
            f.SetTeam(Constants.ETFTeam.TEAM_SPECTATOR)
            NetProps.SetPropInt(f, "m_nRenderMode", Constants.ERenderMode.kRenderNone)
            break

        // Autumnull RC2, Lotus B6, Mansion RC1D, Null B9A, Watermine RC11
        // Autumnull RC2, Lotus B6, Mansion RC1D, Null B9A, Watermine RC11
        // - Fixes the respawn room visualizers rendering behind props that are behind them.
        case "mvm_autumnull_rc2":
        case "mvm_coaltown":
        case "mvm_lotus_b6":
        case "mvm_mansion_rc1d":
        case "mvm_null_b9a":
        case "mvm_null_b9a":
        case "mvm_watermine_rc11":
            for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
            break

        // Madhattan RC5A
        // - Fix the forward upgrade station breaking on wave fail/mission swap.
        case "mvm_madhattan_rc5a":
            EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
                "OnMapSpawn", "open_upgrade_relay", "Trigger", "", -1, 1)
            break

        // Oilrig RC5A
        // - Replaces missing rain particles that were not packed with the map.
        // - Fixes the tank spawn not being setup as a bot spawn.
        case "mvm_oilrig_rc5a":
            // Kill old broken rain particles.
            for (local rain; rain = Entities.FindByClassname(rain, "info_particle_system");) {
                if (rain.GetName() == "end_pit_destroy_particle") continue
                EntFireByHandle(rain, "Kill", "", -1, null, null)
            }

            // Spawn hand-placed Sawmill rain particles.
            local rain001 = [Vector(-2848, 384, 8810), Vector(-1200, 1924, 3620),
                Vector(282, 1924, 3620), Vector(882, 1924, 3620), Vector(-366, -608, 3620), Vector(528, -608, 4100),
                Vector(1849, -291, 3420), Vector(0, -1000, 1600), Vector(1024, -1632, 4100), Vector(-1024, -1632, 4100),
                Vector(1562, -2210, 3620), Vector(-864, -3936, 3620), Vector(160, -4096, 4200), Vector(320, -4960, 4300),
                Vector(-704, -4960, 4300), Vector(1242, -4256, 3620), Vector(-1146, -4702, 3620)]
            local rain002 = [Vector(-508, -2608, 1800), Vector(789, -2290, 1800), Vector(-324, -2694, 1800), Vector(-320, -3360, 1800)]
            foreach(vec in rain001) {
                SpawnEntityFromTable("info_particle_system", {
                    origin = vec
                    effect_name = "env_rain_001"
                    start_active = 1
                    flag_as_weather = 1
                })
            }
            foreach(vec in rain002) {
                SpawnEntityFromTable("info_particle_system", {
                    origin = vec
                    effect_name = "env_rain_002_256"
                    start_active = 1
                    flag_as_weather = 1
                })
            }

            // Properly mark the tank spawn nav square as an invaders' spawn room.
            local tanknav = NavMesh.GetNavAreaByID(27)
            tanknav.SetAttributeTF(Constants.FTFNavAttributeType.TF_NAV_SPAWN_ROOM_BLUE)
            tanknav.ClearAttributeTF(Constants.FTFNavAttributeType.TF_NAV_BOMB_CAN_DROP_HERE)
            // Add missing BLU func_respawnroom.
            local tankspawn = SpawnEntityFromTable("func_respawnroom", {
                origin = Vector(-520, -5450, 1063)
                TeamNum = Constants.ETFTeam.TF_TEAM_BLUE
            })
            tankspawn.SetSize(Vector(), Vector(400, 410, 200))
            tankspawn.SetSolid(Constants.ESolidType.SOLID_BBOX)
            // Auto-collect cash dropped in the tank spawn.
            local tankcollect = SpawnEntityFromTable("trigger_hurt", {
                origin = Vector(-520, -5450, 1063)
            })
            tankcollect.SetSize(Vector(), Vector(400, 410, 200))
            tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
            break

        // Outlands RC2
        // - Fixes cash getting stuck in hatch.
        // - Fixes cash getting stuck in tank spawn.
        case "mvm_outlands_rc2":
            local hatchcollect = SpawnEntityFromTable("trigger_hurt", {
                origin = Vector(-192, -2560, -500)
            })
            hatchcollect.SetSize(Vector(), Vector(384, 385, 150))
            hatchcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)

            local tankcollect = SpawnEntityFromTable("trigger_hurt", {
                origin = Vector(-1627, 2937, -274)
            })
            tankcollect.SetSize(Vector(), Vector(862, 626, 491))
            tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
            break

        // Hanami RC1
        // - Fixes the tank barricade turning invisible after breaking once.
        // - Fixes client prediction errors on the tank barricade.
        case "mvm_hanami_rc1":
            local barricade = Entities.FindByName(null, "prop_barricade")
            barricade.AddEFlags(Constants.FEntityEFlags.EFL_IN_SKYBOX)
            barricade.SetSolidFlags(Constants.ESolidType.SOLID_NONE)
            break
        // Rottenburg
        // - Fixes the tank barricade turning invisible after breaking once.
        // - Fixes client prediction errors on the tank barricade.
        case "mvm_rottenburg":
            local barricade = Entities.FindByName(null, "Barricade")
            barricade.AddEFlags(Constants.FEntityEFlags.EFL_IN_SKYBOX)
            barricade.SetSolidFlags(Constants.ESolidType.SOLID_NONE)
            break
        // Whitecliff Event RC2
        // - Fix the forward upgrade station breaking on mission swap.
        case "mvm_whitecliff_event_rc2":
            EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
                "OnMapSpawn", "FowardUpgradeStationTrigger", "Enable", "", -1, 1)
            break
    }}
}
__CollectGameEventCallbacks(__potato.MapFixes.Events)
