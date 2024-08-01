::PointTemplates <- {
        Bringonthethunda = {
                NoFixup = 1,
                [0] = {
                        info_particle_system = {
                                targetname = "lightning"
                                origin = "-539 32 0"
                                angles = "0 0 0"
                                effect_name = "wrenchmotron_teleport_beam"
                        }
                },
                [1] = {
                        info_particle_system = {
                                targetname = "groundshake"
                                origin = "-539 32 138"
                                angles = "0 0 0"
                                effect_name = "hammer_impact_button"
                        }
                },
                [2] = {
                        env_shake = {
                                targetname = "bigshake"
                                origin = "-539 32 138"
                                angles = "0 0 0"
                                amplitude = "16"
                                duration = "2"
                                frequency = "9"
                                spawnflags = "1" 
                        }
                },
                [3] = {
                        logic_relay = {
                                targetname = "start_the_sequence"
                                "ontrigger#1": "lightning,start,,0,-1"
                                "ontrigger#2": "lightning,stop,,1,-1"
                                "ontrigger#3": "statue,setanimation,taunt04,0.5,-1"
                                "ontrigger#4": "statue,setplaybackrate,0,0.8,-1"
                                "ontrigger#5": "statue,setplaybackrate,1.25,4.5,-1"
                                "ontrigger#6": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_battlecry06.mp3,5.3,-1"
                                "ontrigger#7": "tf_gamerules,PlayVO,ambient_mp3/halloween/thunder_01.mp3,0,-1"
                                "ontrigger#8": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_award08.mp3,7.4,-1"
                                "ontrigger#9": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_award04.mp3,1.6,-1"
                                "ontrigger#10": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_award04.mp3,1.6,-1"
                                "ontrigger#11": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_award08.mp3,7.4,-1"
                                "ontrigger#12": "tf_gamerules,PlayVO,vo/mvm/mght/heavy_mvm_m_battlecry06.mp3,5.3,-1"
                                "ontrigger#13": "groundshake,start,,7.1,-1"
                                "ontrigger#14": "groundshake,stop,,8,-1"
                                "ontrigger#15": "tf_gamerules,PlayVO,ambient/explosions/explode_1.wav,7.1,-1"
                                "ontrigger#16": "groundshake,start,,0,-1"
                                "ontrigger#17": "groundshake,stop,,1,-1"
                                "ontrigger#18": "bigshake,StartShake,,0,-1"
                                "ontrigger#19": "bigshake,StartShake,,7.1,-1"
                        }
                }
        }
        Dispensomat_boss = {
                NoFixup = 1,
                [0] = {
                    dispenser_touch_trigger = {
                            targetname = "dispensomat_bounds"
                            origin = "0 0 64"
                            maxs = "650 650 650"
                            mins = "-650 -650 -650"
                            spawnflags = "1"
                    }
                },
                [1] = {
                    mapobj_cart_dispenser = {
                            targetname = "dispensomat_healbeam"
                            origin = "0 0 98"
                            teamnum = "3"
                            touch_trigger = "dispensomat_bounds"
                            spawnflags = "6"
                    }
                },
                [2] = {
                    mapobj_cart_dispenser = {
                            targetname = "dispensomat_healbeam"
                            origin = "0 0 98"
                            teamnum = "3"
                            touch_trigger = "dispensomat_bounds"
                            spawnflags = "6"
                    }
                }
        }
        Grimmemorial_Boss = {
                NoFixup = 1,
                [0] = {
                    logic_timer = {
                            targetname = "stomp_timer"
                            refiretime = "12"
                            "OnTimer#1": "stomp_attack,trigger,,0,-1"
                    }
                },
                [1] = {
                        logic_relay = {
                                targetname = "stomp_attack"
                                spawnflags = "2"
                                "OnTrigger#1": "tf_gamerules,playvo,weapons/rocket_pack_boosters_charge.wav,6,-1"
                                "OnTrigger#2": "CRUSH,enable,,6.8,-1"
                                "OnTrigger#3": "CRUSH,disable,,6.9,-1"
                                "OnTrigger#4": "dusty_ass_bitch,start,,6.8,-1"
                                "OnTrigger#5": "dusty_ass_bitch,stop,,7.5,-1"
                                "OnTrigger#6": "tf_gamerules,playvo,ambient/explosions/explode_1.wav,6.8,-1"
                                "OnTrigger#7": "warningman,pitch,100,0,-1"
                                "OnTrigger#8": "warningman,pitch,110,1,-1"
                                "OnTrigger#9": "warningman,pitch,120,2,-1"
                                "OnTrigger#10": "warningman,pitch,130,3,-1"
                                "OnTrigger#11": "warningman,pitch,140,4,-1"
                                "OnTrigger#12": "warningman,pitch,150,5,-1"
                                "OnTrigger#13": "warningman,pitch,160,6,-1"
                                "OnTrigger#14": "statue_stop,enable,,4.5,-1"
                                "OnTrigger#15": "statue_stop,disable,,4.6,-1"
                                "OnTrigger#16": "bigshake,startshake,,6.8,-1"
                                "OnTrigger#17": "statue_jump_for_joy,ApplyImpulse,,6.8,-1"
                        }
                },
                [2] = {
                    trigger_hurt = {
                            targetname = "CRUSH"
                            maxs = "256 256 48"
                            mins = "-256 -256 -24"
                            damage = "400"
                            damagetype = "128"
                            filtername = "filter_red"
                            spawnflags = "65"
                            startdisabled = "1"
                    }
                },
                [3] = {
                        info_particle_system = {
                                targetname = "dusty_ass_bitch"
                                origin = "0 0 0"
                                angles = "0 0 0"
                                effect_name = "hammer_impact_button"
                        }
                },
                [4] = {
                        ambient_generic = {
                                targetname = "warningman"
                                health = "10"
                                message = "misc/rd_finale_beep01.wav"
                                pitch = "100"
                                pitchstart = "100"
                                radius = "5000"
                                spawnflags = "17"
                                sourceentityname = "CRUSH"
                       }
                }
        }
        Grimmemorial_Stunner = {
                NoFixup = 1,
                [0] = {
                        trigger_add_tf_player_condition = {
                                targetname = "statue_stop"
                                origin = "0 0 0"
                                maxs = "9999 9999 9999"
                                mins = "-9999 -9999 -9999"
                                spawnflags = "1"
                                duration = "2"
                                condition = "71"
                                filtername = "filter_statue"
                                startdisabled = "1"
                        }
                },
                [1] = {
                        trigger_apply_impulse = {
                                targetname = "statue_jump_for_joy"
                                origin = "0 0 0"
                                maxs = "9999 9999 9999"
                                mins = "-9999 -9999 -9999"
                                spawnflags = "1"
                                filtername = "filter_statue"
                                force = "375"
                                impulse_dir = "262 10 0"
                        }
                },
                [2] = {
                        trigger_once = {
                                targetname = "disable_fart"
                                origin = "-4939 -185 -86"
                                maxs = "512 512 512"
                                mins = "-512 -512 -512"
                                filtername = "filter_statue"
                                "OnTrigger#1": "stomp_attack,CancelPending,,0,-1"
                                "OnTrigger#2": "stomp_timer,disable,,0,-1"
                                "OnTrigger#3": "stomp_attack,CancelPending,,1,-1"
                                "OnTrigger#4": "stomp_attack,CancelPending,,2,-1"
                                "OnTrigger#5": "stomp_attack,CancelPending,,3,-1"
                                "OnTrigger#6": "tf_gamerules,playvo,vo/mvm/mght/heavy_mvm_m_domination15.mp3,0,-1"
                                spawnflags = "1"
                        }
                },
                [3] = {
                        filter_tf_bot_has_tag = {
                                targetname = "filter_statue"
                                tags = "bot_statue"
                                require_all_tags = "1"
                        }
                }
        } 
        Dipshit_Alarm = {
                NoFixup = 1,
                [0] = {
                        trigger_multiple = {
                                targetname = "dipshit_alarm"
                                spawnflags = "1"
                                maxs = "9999 9999 9999"
                                mins = "-9999 -9999 -9999"
                                filtername = "dipshit_filter"
                                "OnStartTouchAll#1": "tf_gamerules,playvo,mvm/mvm_tele_deliver.wav,0,-1"
                                "OnStartTouchAll#2": "annotations_for_dipshits,show,,0,-1"
                                "OnStartTouchAll#3": "annotations_for_dipshits,kill,,6,-1"
                        }
                },
                [1] = {
                        filter_tf_bot_has_tag = {
                                targetname = "dipshit_filter"
                                tags = "bot_dipshit"
                                require_all_tags = "1"
                        }
                },
                [2] = {
                        training_annotation = {
                                targetname = "annotations_for_dipshits"
                                lifetime = "5"
                                origin = "-2195 36 -93"
                                display_text = "Robots inbound from behind!"
                        }
                }
        }
}