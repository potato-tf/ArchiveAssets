__potato.MapFixes <- {}
__potato.MapFixes.Events <- {
    // Apply map fixes whenever entities are recreated.
    //  Fired every wave fail, wave jump or mission change.
    function OnGameEvent_teamplay_round_start(_) { switch (GetMapName()) {
        // Bronx RC2
        // - Fixes performance issues and large demos caused by bone followers on map engibots.
        // - Fixes death pit not killing ubered players.
        case "mvm_bronx_rc2":
            // 
            for (local props; props = Entities.FindByClassname(props, "prop_dynamic");)
                if (props.GetModelName() == "models/bots/engineer/bot_engineer.mdl")
                    NetProps.SetPropInt(props, "m_BoneFollowerManager.m_iNumBones", 0)

            // Fix the death pit not killing ubered players
            for (local deathpit; deathpit = Entities.FindByClassname(deathpit, "trigger_hurt");) {
                if (deathpit.GetName() != "trigger_hurt_hatch_fire") {
                    NetProps.SetPropInt(deathpit, "m_bitsDamageInflict", Constants.FDmgType.DMG_ACID)   // DMG_CRITICAL
                    deathpit.AcceptInput("SetDamage", "10000", null, null)
                }
            }
            break

        // Lotus B6
        // - Fixes the spawn holograms rendering behind props that are behind them.
        case "mvm_lotus_b6":
            for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
            break

        // Mansion RC1D
        // - Fixes the spawn holograms rendering behind props that are behind them.
        case "mvm_mansion_rc1d":
            for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");)
                NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
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

        // Rottenburg
        // - Fixes the tank barricade turning invisible after breaking once.
        // - Fixes client prediction errors on the tank barricade.
        case "mvm_rottenburg":
            EntFire("Barricade", "SetParent", "Tank_Barricade_Particle")
            EntFire("Barricade", "DisableCollision")
            break
    }}
}
__CollectGameEventCallbacks(__potato.MapFixes.Events)
