IncludeScript("alternatewaves", getroottable())

function AlternateWavebars(wave_num) {

// AlternateWaves.ClearWaveIcons()
EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", wave_num == 0 ? "1" : "0", -1)
EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", wave_num.tostring(), -1)
EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "0", -1)

switch (wave_num)
    {
        case 0:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", "0", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "1", -1)
            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["scout", 60, MVM_CLASS_FLAG_NORMAL],
                ["soldier_crit", 24, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier_buff", 4, MVM_CLASS_FLAG_NORMAL],

                ["soldier_burstfire", 4, MVM_CLASS_FLAG_MINIBOSS],
                ["heavy_deflector", 2, MVM_CLASS_FLAG_MINIBOSS],
                ["medic_giant", 2, MVM_CLASS_FLAG_MINIBOSS],
                ["scout_fan_giant", 10, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],

                ["tf2_lite", 9, MVM_CLASS_FLAG_NORMAL],

                ["scout_stun", 1, MVM_CLASS_FLAG_SUPPORT],
                ["heavy_gru", 1, MVM_CLASS_FLAG_SUPPORT]
            ])
            break
        case -1:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", "0", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "6", -1)
            AlternateWaves.ClearWaveIcons()

            break
        case 1:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "2", -1)
            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["heavy", 24, MVM_CLASS_FLAG_NORMAL],
                ["soldier_barrage", 2, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["demo_spammer", 3, MVM_CLASS_FLAG_MINIBOSS],
                ["pyro_reflect", 20, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["scout_milk", 20, MVM_CLASS_FLAG_NORMAL],

                ["heavy_armored", 9, MVM_CLASS_FLAG_NORMAL],
                ["medic_uber", 9, MVM_CLASS_FLAG_NORMAL],
                ["heavy_heater_giant", 1, MVM_CLASS_FLAG_MINIBOSS],	
                ["pyro_dragon_fury_swordstone", 3, MVM_CLASS_FLAG_MINIBOSS],
                ["pyro_dragon_crown", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier_commander", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["medic_giant", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["medic_kritz_giant", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["scout_milk_giant", 2, MVM_CLASS_FLAG_MINIBOSS],

                ["pyro", 1, MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["demoknight", 1, MVM_CLASS_FLAG_SUPPORT]
            ])
            break
        case 2:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "3", -1)
            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["tank_uber_lite", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["soldier_charged_mangler_v2", 4, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["pyro_dragon_fury_swordstone" 23, MVM_CLASS_FLAG_NORMAL],
                ["scout_stun", 40, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["demo_burst_giant", 3, MVM_CLASS_FLAG_MINIBOSS],
                ["medic_uber", 3, MVM_CLASS_FLAG_NORMAL],
                ["medic_kritz", 3, MVM_CLASS_FLAG_NORMAL],
                ["medic_quickfix_seel2", 15, MVM_CLASS_FLAG_NORMAL],
                ["heavy_robot_nys", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["heavy", 3, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier_conch_giant", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["medic_giant", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["heavy_deflector", 1, MVM_CLASS_FLAG_MINIBOSS],


                ["soldier_directhit_lite", 1 MVM_CLASS_FLAG_SUPPORT],
                ["demo", 1 MVM_CLASS_FLAG_SUPPORT],
            ])
        break
        case 3:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "4", -1)
            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                
                ["blueside_indicator", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],

                ["tank_combine_harvester", 2, MVM_CLASS_FLAG_MINIBOSS],
                ["tank_combat_minigun", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["heavy_shotgun", 6, MVM_CLASS_FLAG_MINIBOSS],
                ["scout_stun_giant_armored", 6, MVM_CLASS_FLAG_MINIBOSS],
                ["soldier_spammer", 8,  MVM_CLASS_FLAG_MINIBOSS],
                ["medic_giant", 1, MVM_CLASS_FLAG_MINIBOSS],
                ["heavy_deflector_healonkill", 3, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier_hyper_lite", 3, MVM_CLASS_FLAG_MINIBOSS],
                ["medic_uber", 10, MVM_CLASS_FLAG_NORMAL],
                ["sniper_bow", 10, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["pyro", 10, MVM_CLASS_FLAG_NORMAL],

                ["soldier", 75, MVM_CLASS_FLAG_SUPPORT],
                ["demo_loch", 75, MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT]
            ])
        break
        //BOSS TIME SHENANIGANS YIPPE DAPPY DO
        //--This is scrapped lol

        case 4:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", "1", -1)

            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS],
            ])
        break

        //Inital boss wave
        case 5:
            EntFire("tf_objective_resource", "$SetClientProp$m_nMvMEventPopfileType", "0", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "5", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "5", -1)

            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS],

                ["random_lite", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_SUPPORT],
                ["heavy", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["pyro", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["banner_trio", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT]

            ])
        break
        case 6:
             //-------BLAST SUPPORT-------------

            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS],
                //--Supports
                ["demo_giant", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_SUPPORT],
                ["scout_conch_yoovy", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["soldier", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["shotgun_lite", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["scout_stun", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT]

            ])
        break
        case 7:
            //-------SUPPORT FIRE-------------
            
            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([
                ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS],
                //--Supports
                ["pyro_dragon_fury_swordstone", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_SUPPORT],
                ["pyro_flare_spammer", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["pyro", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["demo_burst", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["heavy_heater", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT]

            ])
        break
        case 8:
            //-----SUPPORT BULLETS----------


            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([

                ["monoculus_nys", 1, MVM_CLASS_FLAG_MINIBOSS],
                //--Supports
                ["heavy_giant", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_SUPPORT],
                ["scout_fan_giant", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_SUPPORT],
                ["scout", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["scout_pistol_nys", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["demoknight", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT],
                ["spy_revolver_lite", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT]
            ])
        break
        case 9:
            //-----IMPASSE INTERMISSION 1----------
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", -1)
            EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "6", -1)

            AlternateWaves.ClearWaveIcons()
            AlternateWaves.AddWaveIcons([

                ["demo_spammer_hyper_lite", 4, MVM_CLASS_FLAG_MINIBOSS],
                ["soldier_crit_giant", 2, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["heavy_giant", 1, MVM_CLASS_FLAG_MINIBOSS | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["medic_giant", 5, MVM_CLASS_FLAG_MINIBOSS],
                ["pyro_hyper_lite", 4, MVM_CLASS_FLAG_MINIBOSS],
                ["tank", 1, MVM_CLASS_FLAG_MINIBOSS],

                ["medic_uber", 8, MVM_CLASS_FLAG_NORMAL],
                ["scout", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
                ["soldier_crit", 1, MVM_CLASS_FLAG_NORMAL | MVM_CLASS_FLAG_SUPPORT | MVM_CLASS_FLAG_ALWAYSCRIT],
            ])
        break
    }
}

EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineWaveCount", "6", 1)
EntFire("tf_objective_resource", "$SetClientProp$m_nMannVsMachineMaxWaveCount", "5", 1)

AlternateWaves.ClearWaveIcons()

EntFire("bomb_endurance", "RunScriptFile", "snurper_bombhop.nut", 0.22)
EntFire("wave_init_relay_route_r", "Trigger", null, 0.24)