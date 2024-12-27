PrecacheModel("models/props_breadspace_new/bread_mama_new.mdl")
PrecacheModel("models/bots/boss_bot/bread_boss/tentacle.mdl")

// Yes I know this file needs serious refactoring
// I would, but I'm too busy with my full-time job at the moment


local CurrentWaveNum = GetPropInt(FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount")
::dbug <- false
if(dbug) ClientPrint(null, 3, "cur wave " + CurrentWaveNum.tostring())

local EventsID = "breadeventslol"
if(!("breadeventslol" in getroottable())){
    getroottable()[EventsID] <-
    {
        // Cleanup events on round restart. Do not remove this event.

        OnGameEvent_recalculate_holidays = function(_) { if (GetRoundState() == 3) {
            delete getroottable()[EventsID]
            delete ::Bread
        } }

        // OnGameEvent_teamplay_round_start = function(_) {
        //     //PopExtUtil.PrintTable(PopExtUtil.BotArray)
        //     Cleanup()
        // }

        ////////// Add your events here //////////////
        OnGameEvent_player_spawn = function(params)
        {
            local player = GetPlayerFromUserID(params.userid);
            player.ValidateScriptScope()
            if (player != null && player.GetTeam() == 2)
            {
                // player.GetScriptScope().buttons_last <- 0
                // PopExtUtil.AddThinkToEnt(player, "BreadPlayerThink")
                Bread.PlayerSetup(player)
            }
        }
        OnGameEvent_post_inventory_application = function(params) {
            local player = GetPlayerFromUserID(params.userid);
            player.ValidateScriptScope()
            if (player != null && player.GetTeam() == 2)
            {
                // player.GetScriptScope().buttons_last <- 0
                // PopExtUtil.AddThinkToEnt(player, "BreadPlayerThink")
                Bread.PlayerSetup(player)
            }
        }
        OnGameEvent_npc_hurt = function(params) {
            if (!("Bread" in getroottable())) return
            //if(dbug) PopExtUtil.PrintTable(params)
            local ent = EntIndexToHScript(params.entindex)
            if (ent == Bread.breadboss)
            {
                // Check if a bot is about to die
                //if(dbug) ClientPrint(null, 3, "bosshealth " + ent.GetHealth().tostring() + params.damageamount.tostring())
                if ((ent.GetHealth() - params.damageamount) <= 0)
                {
                    Bread.ResetBoss()
                    EntFire("tf_gamerules", "$SetBossHealthPercentage", 0)
                    Bread.DoScript("killed")

                    // Change life state to "dying"
                    // The bot won't take any more damage, and sentries will stop targeting it
                    NetProps.SetPropInt(Bread.breadboss, "m_lifeState", 1)
                    // Reset health, preventing the default base_boss death behavior
                    Bread.breadboss.SetHealth(Bread.breadboss.GetMaxHealth() * 20)
                    EntFire("tf_gamerules", "$SetBossHealthPercentage", 0,0.1)
                    EntFire("tf_gamerules", "$SetBossHealthPercentage", 0,0.2)
                    EntFire("tf_gamerules", "$SetBossHealthPercentage", 0,0.3)


                    for (local t; t = Entities.FindByClassname(t, "base_boss"); )
                    {
                        if(t.GetName().find("tentacleboss")!= null) {
                            t.GetScriptScope().iHealth = 100000
                            NetProps.SetPropInt(ent, "m_lifeState", 1)
                            Bread.TentySetSeq(t, t.GetScriptScope().SEQ_DIE, 1, 0)
                            EntFireByHandle(t.GetScriptScope().coreParent, "kill", null, 5,null,null)
                        }
                    }
                }
                //if(dbug) ClientPrint(null, 3, "dmg " + params.damageamount.tostring())
            }
            //if(dbug) ClientPrint(null, 3, NetProps.GetPropInt(ent, "m_LastHitGroup").tostring())
        }
        OnScriptHook_OnTakeDamage = function(params)
        {
            if (!("Bread" in getroottable())) return
            //PopExtUtil.PrintTable(params)
            if(params.const_entity == null || params.attacker == null) return
            local ent = params.const_entity;
            try {
                if(params.inflictor.GetClassname() == "obj_sentrygun" && params.weapon.GetAttribute("projectile penetration",0) > 0){ // && params.attacker.GetTeam()==2
                    if(dbug) PopExtUtil.PrintTable(params)
                    local hits = Bread.GetSentryTrace(params.inflictor, params.damage_position)
                    local owner = params.attacker
                    if(ent.GetName().find("crate")!= null || ent == Bread.breadboss) {ent.TakeDamageEx(owner, owner, params.weapon, params.damage_force, params.damage_position, params.damage*0.55, 2)}

                    if(hits != null) {
                        //local dmgBonus = self.GetAttribute("damage bonus",1)

                        //if(dbug) ClientPrint(null,3,"dmgbonus " + dmgBonus.tostring() )
                        local bonus = 0.7
                        foreach (i, hit in hits)
                        {
                            hit.enthit.TakeDamageEx(owner, owner, params.weapon, params.damage_force, hit.pos, params.damage*bonus, 2)
                            bonus *=0.7
                            //TakeDamageEx(handle hInflictor, handle hAttacker, handle hWeapon, Vector vecDamageForce, Vector vecDamagePosition, float flDamage, int nDamageType)
                        }
                    }
                } else if (params.inflictor.GetClassname() == "obj_sentrygun" && params.attacker.GetTeam()==2){
                    if(ent.GetName().find("crate")!= null || ent == Bread.breadboss) params.damage = params.damage*1.4
                }
            } catch (exception){

            }

            if(ent.GetClassname() == "player") {

                try {
                    if(params.attacker.GetName().find("tentacle")!= null) {
                        if(dbug) PopExtUtil.PrintTable(params)
                        //if(dbug) ClientPrint(null, 3, params.weapon.GetName())
                        if(params.weapon.GetName().find("launcher")!= null)
                        {
                            // if(params.const_entity.GetHealth() > params.damage) {
                            //     if(dbug) ClientPrint(null, 3, params.const_entity.GetHealth().tostring())

                            //     params.damage_force = Vector(0,0,0)
                            //     params.damage_position.z = 1000
                            // }
                            EmitSoundEx({
                                sound_name = "Weapon_BoxingGloves.CritHit",
                                channel = 6,
                                filter = 5,
                                origin = params.const_entity.GetOrigin(),
                                entity = params.const_entity,
                                volume = 1,
                                sound_level = 0.5
                            })
                        }
                    }
                } catch (e){

                }

            }
            if(ent.GetClassname() == "tank_boss") {
                if(GetPropInt(FindByClassname(null, "tf_objective_resource"), "m_nMannVsMachineWaveCount") > 1){
                    params.early_out == true
                    params.damage = 0
                    ent.SetHealth(ent.GetMaxHealth())
                }

            }
            if(ent.GetClassname() == "base_boss") {
                //PopExtUtil.PrintTable(params)
                if(params.attacker.GetTeam()!=2) {
                    params.damage = 0
                    return
                } else if (Bread.desperation == true) {
                    params.damage = params.damage * 1.25
                }
                // if(params.attacker.GetClassname().find("sentrygun")!=null) {
                //     params.attacker = params.attacker.GetOwner()
                // }
                //Bread.GetPlayerTraceBoss(params.attacker)

                local armorPen = (params.weapon.GetAttribute("armor piercing", 0)/100) + 1.0
                // local bleedDur = params.weapon.GetAttribute("bleeding duration", 0)
                // local backfire = params.weapon.GetAttribute("mod flamethrower back crit", 0)

                //PopExtUtil.PrintTable(params)
                // if(dbug) ClientPrint(null, 3, "backfire " + backfire.tostring())
                if(dbug) ClientPrint(null, 3, "pene " + params.weapon.GetAttribute("projectile penetration",0).tostring())

                // non-tentacles
                if(ent.GetName().find("tentacleboss") == null) {
                    if( params.weapon.GetClassname().find("minigun")!=null ){
                        //ClientPrint(null, 3, "pls nerf")
                        //params.damage = params.damage * (0.9 + 0.1*params.weapon.GetAttribute("projectile penetration heavy",0))
                        params.damage = params.damage * 0.85

                    } else if (params.weapon.GetClassname().find("flamethrower")!=null || params.weapon.GetClassname().find("tf_weapon_rocketlauncher_fireball")!=null ) {
                        params.damage = params.damage * 0.69
                    }
                                    // bow with penetration is way too strong, need to nerf
                    else if((params.weapon.GetClassname().find("bow")!=null && params.weapon.GetAttribute("projectile penetration",0) > 0) || params.weapon.GetClassname().find("tf_weapon_raygun")!=null){
                        //ClientPrint(null, 3, "pls nerf")
                        params.damage = params.damage * 0.7
                    }
                    // Explosive damage needs to be nerfed slightly, because of the multiple hitbox mechanic
                    else if(params.attacker.GetClassname() == "player" && (params.damage_type & Constants.FDmgType.DMG_BLAST) && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_DEMOMAN){
                        //ClientPrint(null, 3, "pls nerf")
                        params.damage = params.damage * 0.70
                    }
                    else if(params.attacker.GetClassname() == "player" && (params.damage_type & Constants.FDmgType.DMG_BLAST) && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SOLDIER){
                        //ClientPrint(null, 3, "pls nerf")
                        if(params.weapon.GetAttribute("can overload", -1) > 0)
                            params.damage = params.damage * 0.70
                        else
                            params.damage = params.damage * 0.85
                    }
                    // For Cactus Overclocks
                    if(params.weapon.GetAttribute("mult dmg vs tanks", -99) > -99) {
                        params.damage = params.damage * params.weapon.GetAttribute("mult dmg vs tanks", 1)
                    }
                    if(params.attacker.GetPlayerClass() != Constants.ETFClass.TF_CLASS_SPY && (params.damage_type & Constants.FDmgType.DMG_CLUB)) {
                        params.damage = params.damage * 1.2
                    }
                }

                local dmg = params.damage
                local isCrit = false
                if ((params.damage_type & Constants.FDmgType.DMG_ACID) && params.crit_type != 1 || ClaudzUtil.IsPlayerCritBoosted(params.attacker)) {
                    if(params.weapon.GetClassname()!= "tf_weapon_pda_engineer_build"){
                        dmg *= 3
                        isCrit = true
                        if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                    }

                }
                else if (ClaudzUtil.IsPlayerMiniCritBoosted(params.attacker) || params.crit_type == 1) dmg *= 1.35

                if(ent.GetName().find("tentacleboss")!= null) {
                    if( params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
                        if(params.damage_type & Constants.FDmgType.DMG_BULLET) {
                            params.damage = params.damage * 1.5
                        } else {
                            params.damage = 110 * armorPen
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                            isCrit = true
                            params.crit_type = 0
                            //ClientPrint(params.attacker, 4, "Bonus Damage: " + (dmg*3).tostring())
                        }
                    } else if ( params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ){

                        if(params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                            dmg = params.damage * 1
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                            NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                            isCrit = true
                            params.crit_type = 0
                        } else if(params.weapon.GetClassname().find("bow")!=null){
                            params.damage = params.damage * 0.9
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                            NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                            //ClientPrint(null, 3, params.inflictor.GetClassname())
                            //if(params.inflictor.GetClassname() == "tf_projectile_arrow" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER) {
                                //EntFireByHandle(params.inflictor, "kill", null, -1, null, null)
                            //}
                            isCrit = true
                            params.crit_type = 0
                        }  else if (params.damage_type & Constants.FDmgType.DMG_CLUB) {
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                            isCrit = true
                            params.crit_type = 0
                        }
                    } else {
                        if(params.damage_type & Constants.FDmgType.DMG_CLUB) {
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                            isCrit = true
                            params.crit_type = 0
                        }
                    }
                    try {
                        if(ent.GetScriptScope().meleeOnly) {
                            params.damage = params.damage*0.75
                        }
                    } catch (exception){

                    }

                    if(isCrit) dmg = params.damage*3

                    try
                    {
                        ent.GetScriptScope().iHealth -= dmg
                        if(ent.GetScriptScope().iHealth < 0) {
                            DispatchParticleEffect("merasmus_blood", params.damage_position, Vector(0,0,0))
                            ent.GetScriptScope().iHealth = 100000
                            params.damage = 0
                            Bread.TentySetSeq(ent, ent.GetScriptScope().SEQ_DIE, 1, 0)
                            EntFireByHandle(ent.GetScriptScope().shooter, "kill", null, 0, null, null)
                            EntFireByHandle(ent.GetScriptScope().sweepShooter, "kill", null, 0, null, null)
                            EntFireByHandle(ent.GetScriptScope().lungeShooter, "kill", null, 0, null, null)

                            EntFireByHandle(ent.GetScriptScope().coreParent, "kill", null, 5,null,null)
                            EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 0, null)
                            EmitSoundEx({
                                sound_name = "Crocs.Hiss",
                                channel = 6,
                                filter = 5,
                                origin = ent.GetOrigin(),
                                entity = ent,
                                volume = 1,
                                sound_level = 0.5
                            })
                            if(ent.GetScriptScope().meleeOnly) {
                                Bread.ActiveMeleeTentacles -= 1
                            }
                            else if(ent.GetOrigin().z > -4000)
                            {
                                Bread.ActiveTentacles -= 1
                            }
                        }
                        DispatchParticleEffect("merasmus_blood_lowdamage", params.damage_position, Vector(0,0,0))

                        Bread.breadboss.TakeDamageEx(ent, params.attacker, params.weapon, Vector(0,0,0), Bread.breadboss.GetOrigin(), dmg, 1)
                    } catch(e) {
                        return
                    }


                    return
                }

                if(dbug) ClientPrint(null, 3, ent.GetName())
                local loc = Bread.breadboss.GetAttachmentOrigin(Bread.breadboss.LookupAttachment("MOUTHDEEP"))
                local dis = params.damage_position - loc
                local disOrigin = Bread.breadheadshot.GetOrigin()-params.damage_position

                // local bakloc = Bread.breadboss.GetAttachmentOrigin(Bread.breadboss.LookupAttachment("UPPERBACK"))
                // local bakdis = params.damage_position - bakloc
                if(dbug) ClientPrint(null, 3, "mouth dist" + dis.Length().tostring() + "disOrigin" + disOrigin.Length().tostring())

                if(Bread.IsPlayerBehind(Bread.breadinfo, params.attacker)) {
                    if( params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
                        if(params.damage_type & Constants.FDmgType.DMG_BULLET) {
                            params.damage = params.damage * 1.5
                        } else {
                            params.damage = 110 * armorPen
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                            params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                            isCrit = true
                            params.crit_type = 0
                            //ClientPrint(params.attacker, 4, "Bonus Damage: " + (dmg*3).tostring())
                        }
                    }
                    else if(params.weapon.GetAttribute("crit from behind", 0) || params.weapon.GetAttribute("mod flamethrower back crit", 0)) {
                        if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                        params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BACKSTAB
                        isCrit = true
                        params.crit_type = 0
                    } else if(params.weapon.GetAttribute("closerange backattack minicrits", 0) && ClaudzUtil.Dist(Bread.breadinfo, params.attacker) < 512) {

                        //if(dbug) ClientPrint(null,3,"old crit type " + params.crit_type.tostring())
                        params.crit_type = 1
                        if (ClaudzUtil.IsPlayerCritBoosted(params.attacker)) {
                            params.crit_type = 0
                            if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                        }
                        else {
                            params.damage *= 0.95
                        }
                        //if(dbug) ClientPrint(null,3,"new crit type " + params.crit_type.tostring())
                    }
                }



                dmg = params.damage
                if ((params.damage_type & Constants.FDmgType.DMG_ACID) || ClaudzUtil.IsPlayerCritBoosted(params.attacker)) {
                    isCrit = true
                    if(params.crit_type == 1) dmg *= 1.35
                    else if(params.weapon.GetClassname()!= "tf_weapon_pda_engineer_build") dmg *= 3
                }
                else if (ClaudzUtil.IsPlayerMiniCritBoosted(params.attacker) ||params.crit_type == 1) dmg *= 1.35

                // local arrow = Entities.FindByClassnameNearest("tf_projectile_arrow", loc, 300)
                // if(arrow!=null && arrow.GetOwner().GetTeam()== 2) {
                //     self.TakeDamage(60,2,arrow.GetOwner())
                //     EntFireByHandle(arrow, "kill", null, -1, null, null)
                // }
                if(dbug) PopExtUtil.PrintTable(params)
                //if(dbug) ClientPrint(null,3,params.attacker.GetOwner())


                if(ent.GetName().find("crate")!= null) {

                    if(dis.Length() < 50 || disOrigin.Length() < 70)
                    {

                        if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ) {
                            if((params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) || params.weapon.GetAttribute("revolver use hit locations", 0) == 1) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                                params.damage = params.damage * 0.5
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                params.crit_type = 0
                                dmg = params.damage*3
                            }
                            else if(params.weapon.GetClassname().find("bow")!=null){
                                params.inflictor.ValidateScriptScope()
                                params.inflictor.GetScriptScope().penetrations <- params.inflictor.GetScriptScope().rawin("penetrations") ? params.inflictor.GetScriptScope().penetrations + 1.0 : 1.0
                                if(dbug) ClientPrint(null, 3, "penetrations " + params.inflictor.GetScriptScope().penetrations.tostring())
                                params.damage = params.damage * 1.0 * (1.0/(params.inflictor.GetScriptScope().penetrations))

                                if(params.weapon.GetAttribute("cannot headshot", 0) != 1) {
                                    if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                    params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT

                                    NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                    params.crit_type = 0
                                    isCrit = true
                                    dmg = params.damage*3
                                }

                            }
                        }

                        else if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
                            if(params.damage_type & Constants.FDmgType.DMG_BULLET) {
                                params.damage = params.damage * 1.25
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                params.crit_type = 0
                                dmg = params.damage*3
                            }
                        }
                    } else if (dis.Length() < 100 || disOrigin.Length() < 100) {
                        if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ) {
                            if(params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                                params.damage = params.damage * 0.5
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                params.crit_type = 0
                                dmg = params.damage*3
                            }
                        }
                    }

                    Bread.HurtBoss(dmg)

                    DispatchParticleEffect("merasmus_blood_lowdamage", params.damage_position, Vector(0,0,0))
                    //Bread.breadboss.TakeDamageEx(params.inflictor, params.attacker, params.weapon, Vector(0,0,0), params.damage_position, dmg, 1)
                }
                else if(ent == Bread.breadboss) {
                    if(params.attacker.GetTeam()!=2) {
                        params.damage = 0
                        return
                    }

                    //PopExtUtil.PrintTable(params)

                    if(dis.Length() < 50 || disOrigin.Length() < 70)
                    {
                        if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ) {
                            if((params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) || params.weapon.GetAttribute("revolver use hit locations", 0) == 1) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                                params.damage = params.damage * 0.5
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                dmg = params.damage*3
                            }
                            else if(params.weapon.GetClassname().find("bow")!=null ){
                                params.inflictor.ValidateScriptScope()
                                params.inflictor.GetScriptScope().penetrations <- params.inflictor.GetScriptScope().rawin("penetrations") ? params.inflictor.GetScriptScope().penetrations +1 : 1
                                params.damage = params.damage * 1.0 * (1/(params.inflictor.GetScriptScope().penetrations))

                                if(params.weapon.GetAttribute("cannot headshot", 0) != 1) {
                                    if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                    params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                    EntFireByHandle(params.inflictor, "kill", null, -1, null, null)

                                    NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                    isCrit = true
                                    dmg = params.damage*3
                                }


                            }
                        }

                        else if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
                            if(params.damage_type & Constants.FDmgType.DMG_BULLET) {
                                params.damage = params.damage * 1.25
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                dmg = params.damage*3
                            }
                        }
                    } else if (dis.Length() < 100 || disOrigin.Length() < 100) {
                        if(params.attacker.GetClassname() == "player" && params.attacker.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER ) {
                            if(params.attacker.InCond(Constants.ETFCond.TF_COND_ZOOMED) && (params.damage_type & Constants.FDmgType.DMG_BULLET)) {
                                params.damage = params.damage * 0.5
                                if(!(params.damage_type & Constants.FDmgType.DMG_ACID)) params.damage_type += Constants.FDmgType.DMG_ACID
                                params.damage_stats = Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT
                                NetProps.SetPropInt(ent, "m_LastHitGroup",1)
                                isCrit = true
                                params.crit_type = 0
                                dmg = params.damage*3
                            }
                        }
                    }

                    local hpPercent = ((1.0*Bread.breadboss.GetHealth()) / (1.0*Bread.breadboss.GetMaxHealth()))
                    EntFire("tf_gamerules", "$SetBossHealthPercentage", hpPercent)
                    //if(dbug) ClientPrint(null, 3, "isbleed " + params.weapon.GetAttribute("bleeding duration", -1).tostring()) //this works yay
                    if(isCrit)
                        DispatchParticleEffect("merasmus_blood", params.damage_position, Vector(0,0,0))
                    else
                        DispatchParticleEffect("merasmus_blood_lowdamage", params.damage_position, Vector(0,0,0))
                    //if(dbug) ClientPrint(null, 4, "cur health " + Bread.breadboss.GetHealth().tostring() + "/" + Bread.breadboss.GetMaxHealth().tostring() + " percent: " + hpPercent.tostring())


                }


                if(dbug) ClientPrint(null, 3, "dmg " + dmg)

                if(params.damage_stats == Constants.ETFDmgCustom.TF_DMG_CUSTOM_HEADSHOT && params.weapon.GetAttribute("explosive sniper shot",-1) > -1) {
                    local flDmgRange = 125 + params.weapon.GetAttribute("explosive sniper shot",-1) * 25;
                    local flDmg = 100 + params.weapon.GetAttribute("explosive sniper shot",-1) * 20; //in game the dmg starts at 130, not 100
                    local expMult = params.weapon.GetAttribute("mult bleeding dmg",1);
                    flDmg *= expMult
                    local xEnt = null
                    while ( xEnt = Entities.FindByClassnameWithin(xEnt, "base_boss", params.damage_position, flDmgRange))
                    {
                        xEnt.TakeDamageEx(params.attacker, params.attacker, params.weapon, Vector(0,0,0), params.damage_position, flDmg*0.75, 64)
                        if(self.GetClassname().find("sniperrifle") != null) Bread.EmitFx(xEnt,"Weapon_Upgrade.ExplosiveHeadshot",0.6)
                    }
                    xEnt = null
                    while ( xEnt = Entities.FindByClassnameWithin(xEnt, "player", params.damage_position, flDmgRange))
                    {
                        if(xEnt.GetTeam()!=2) {
                            xEnt.TakeDamageEx(params.attacker, params.attacker, params.weapon, Vector(0,0,0), params.damage_position, flDmg, 64)
                            if(self.GetClassname().find("sniperrifle") != null) Bread.EmitFx(xEnt,"Weapon_Upgrade.ExplosiveHeadshot",0.6)
                        }
                    }
                }
            }

        }
    }
    local EventsTable = getroottable()[EventsID]
    foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
    __CollectGameEventCallbacks(EventsTable)
}


::Bread <- {
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()["Bread"] }
    OnGameEvent_recalculate_holiday = function(_) { if (GetRoundState() == 3) delete getroottable()["Bread"] }
    // Cleanup = function() {
    //     //EntFireByHandle(Bread.breadtank, "kill", "", 0, null, null)
    //     delete ::Bread
    // }

    // OnGameEvent_recalculate_holiday = function(_) { if (GetRoundState() == 3) Cleanup() }
    // OnGameEvent_mvm_wave_complete = function(_) {
    //     Cleanup()
    // }
    // OnGameEvent_teamplay_round_start = function(_) {
    //     //PopExtUtil.PrintTable(PopExtUtil.BotArray)
    //     Cleanup()
    // }


}
__CollectGameEventCallbacks(Bread)

Bread.PlayerSetup <- function(player) {
    if(dbug) ClientPrint(null,3,"player setup for " + player.tostring())
    for (local i = 0; i < 8; i++)
    {
        local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || weapon.IsMeleeWeapon())
            continue

        // need to exclude bow, crossbow, rescue ranger
        if(!(weapon.GetAttribute("projectile penetration",0) > 0 || weapon.GetAttribute("projectile penetration heavy",0) > 0 ) || weapon.GetClassname().find("bow")!=null || weapon.GetClassname().find("building_rescue")!=null) {
            continue
        }

        //ClientPrint(null,3,weapon.GetClassname())

        local bDmg = weapon.GetClassname().find("shotgun") != null ? 30 : 3
        if(weapon.GetClassname().find("pistol") != null || weapon.GetClassname().find("handgun_scout_secondary") != null) bDmg = 7
        if(weapon.GetClassname().find("scattergun") != null || weapon.GetClassname().find("soda_popper") != null || weapon.GetClassname().find("brawler_blaster") != null) bDmg = 30
        if(weapon.GetClassname().find("revolver") != null|| weapon.GetClassname().find("handgun_scout_primary") != null) bDmg = 15

        weapon.ValidateScriptScope()
        weapon.GetScriptScope().last_fire_time <- 0.0
        weapon.GetScriptScope().last_charge_amt <- 0.0
        weapon.GetScriptScope().charges <- [0]
        weapon.GetScriptScope().baseDmg <- bDmg

        weapon.GetScriptScope().BreadCheckWeaponFire <- BreadCheckWeaponFire
        EntFireByHandle(weapon, "RunScriptCode", "PopExtUtil.AddThinkToEnt(self, `BreadCheckWeaponFire`)", 1, null, null)
        //PopExtUtil.AddThinkToEnt(weapon, "BreadCheckWeaponFire")
    }
}
::BreadCheckWeaponFire <- function()
{
	local fire_time = NetProps.GetPropFloat(self, "m_flLastFireTime")
	if (fire_time > last_fire_time)
	{
        //if you need to do things here on weapon fire, now's the chance
		local owner = self.GetOwner()

        if(owner.GetActiveWeapon()!=self) return
        else if(dbug) ClientPrint(null,4,"thinktest" + Time().tostring())

        if(owner.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER && self.GetClassname().find("sniperrifle") != null){
            //if(dbug) ClientPrint(null,3,"im here " + self.GetClassname()+ " " + self.GetAttribute("projectile penetration",0).tostring())
            if(self.GetAttribute("projectile penetration",0) > 0){
                local hits = Bread.GetPlayerTraceBoss(self)
                if(hits != null) {
                    local dmgBonus = self.GetAttribute("damage bonus",1)
                    local charge = Bread.MaxArr(charges)
                    if(dbug) ClientPrint(null,3,"dmgbonus " + dmgBonus.tostring() + " charge " + charge.tostring())
                    foreach (i, hit in hits)
                    {
                        hit.enthit.TakeDamageEx(owner, owner, owner.GetActiveWeapon(), Vector(0,0,0), hit.pos, (25 + charge)*dmgBonus, 2) //25 instead of 50
                        //TakeDamageEx(handle hInflictor, handle hAttacker, handle hWeapon, Vector vecDamageForce, Vector vecDamagePosition, float flDamage, int nDamageType)
                    }
                }
            }
        }

        else if(self.GetAttribute("projectile penetration",0) > 0){
            local hits = Bread.GetPlayerTraceBoss(self)

            local bDmg = baseDmg
            if(hits != null) {
                local dmgBonus = self.GetAttribute("damage bonus",1)
                foreach (i, hit in hits)
                {
                    local falloff = 1.0 - ((ClaudzUtil.Min((owner.GetOrigin()-hit.enthit.GetOrigin()).Length(), 1500.0))/1500.0)
                    local rampup = bDmg * falloff
                    hit.enthit.TakeDamageEx(owner, owner, owner.GetActiveWeapon(), Vector(0,0,0), hit.pos, (bDmg + rampup)*dmgBonus, 2)
                    //TakeDamageEx(handle hInflictor, handle hAttacker, handle hWeapon, Vector vecDamageForce, Vector vecDamagePosition, float flDamage, int nDamageType)
                }
            }
        }

        else if (self.GetAttribute("projectile penetration heavy",0) > 0){
            local hits = Bread.GetPlayerTraceBoss(self)
            local max = self.GetAttribute("projectile penetration heavy",0)
            if(hits != null) {
                local dmgBonus = self.GetAttribute("damage bonus",1)
                local bDmg = baseDmg
                foreach (i, hit in hits)
                {
                    local falloff = 1.0 - ((ClaudzUtil.Min((owner.GetOrigin()-hit.enthit.GetOrigin()).Length(), 1500.0))/1500.0)
                    //ClientPrint(null,3,"falloff" + falloff.tostring() + " len " + (owner.GetOrigin()-hit.enthit.GetOrigin()).Length().tostring())
                    local rampup = bDmg * falloff
                    hit.enthit.TakeDamageEx(owner, owner, owner.GetActiveWeapon(), Vector(0,0,0), hit.pos, (baseDmg + rampup)*dmgBonus, 2)
                    if(i == max) break
                    //TakeDamageEx(handle hInflictor, handle hAttacker, handle hWeapon, Vector vecDamageForce, Vector vecDamagePosition, float flDamage, int nDamageType)
                }
            }
        }

		last_fire_time = fire_time
	}
    if(self.GetClassname().find("sniperrifle") != null ) {
        local charge = NetProps.GetPropFloat(self, "m_flChargedDamage")
        charges.push(charge)
        if(charges.len() > 5) charges.remove(0)
        if(dbug) ClientPrint(null,4, " charge " + charge.tostring())
    }
	return -1
}

for (local i = 1, player; i <= MaxClients().tointeger(); i++)
{
    if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2)
    {
        if(dbug) ClientPrint(null,3,"thinkinitadd " + player.tostring())
        Bread.PlayerSetup(player)
        // player.GetScriptScope().buttons_last <- 0
        // PopExtUtil.AddThinkToEnt(player, "BreadPlayerThink")
    }
}

::SwitchMedsOffMedigun <- function() {
    for (local i = 1, player; i <= MaxClients().tointeger(); i++)
    {
        if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2 && player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_MEDIC)
        {
            for (local i = 0; i < 8; i++)
            {
                local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
                if (weapon == null || !weapon.IsMeleeWeapon())
                    continue
                player.Weapon_Switch(weapon)
                break
            }
        }
    }
}
::BreadPlayerThink <- function() {
    //if(!ClaudzUtil.IsPlayerAlive(self)) return

    // ClientPrint(null,4,self.tostring())
    // local buttons = NetProps.GetPropInt(self, "m_nButtons");
	// local buttons_changed = buttons_last ^ buttons;
	// local buttons_pressed = buttons_changed & buttons;
	// local buttons_released = buttons_changed & (~buttons);

    // if(self.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER)
    // {
    //     if (buttons_pressed & Constants.FButtons.IN_ATTACK)
    //     {
    //         Bread.GetPlayerTraceBoss(self)
    //     }
    // }
    // buttons_last = buttons;
}
Bread.MaxArr <- function(arr) {
    local big = 0
    foreach(i in arr) {
        if(big < i) big = i
    }
    return big
}
Bread.GetPlayerTraceBoss <- function(player) {
    local trace =
	{
		start = player.EyePosition(),
		end = player.EyePosition() + player.EyeAngles().Forward() * 9999.0,
		ignore = player,
		mask = -1, //33570881,
		filter = function(entity)
		{
            //if(dbug) ClientPrint(null,3,"trace "+entity.tostring())
            if (entity.GetClassname() == "base_boss")
                return TRACE_OK_CONTINUE;
            else if(entity.GetClassname() == "player")
                return TRACE_OK_CONTINUE;

            else
                return TRACE_CONTINUE;

			//return TRACE_STOP;
		}
	};

	TraceLineGather(trace);

	if (trace.hits.len() > 0)
	{
        if(dbug) ClientPrint(null,3,"hits: ");
		foreach (i, hit in trace.hits)
		{
            if(dbug) ClientPrint(null,3,hit.enthit.tostring())
            //hit.enthit.TakeDamageEx(player, player, player.GetActiveWeapon(), Vector(0,0,0), hit.pos, 50, 2)

            //dont use printtable, it crashes
            // foreach (k, v in hit)
			// {
            //     ClientPrint(null,3,k.tostring() + " " + v.tostring())
			// }
		}
        return trace.hits;
	}
	else
	{
		if(dbug) ClientPrint(null,3,"no hits");
        return null
	}
}
Bread.GetSentryTrace <- function(sentry, targetpos) {
    local sentryPos = sentry.GetOrigin() + Vector(0,0,65)
    local target = targetpos //NetProps.GetPropEntity(sentry, "m_hEnemy").GetOrigin()
    //if(dbug) ClientPrint(null,3,"target pos" + targetpos.tostring())
    local aimThrough = target - sentryPos
    aimThrough.Norm()
    local trace =
	{
		start = sentryPos,
		end = sentryPos + aimThrough * 9999.0,
		ignore = sentry,
		mask = -1, //33570881,
		filter = function(entity)
		{
            //if(dbug) ClientPrint(null,3,"trace "+entity.tostring())
            if (entity.GetClassname() == "base_boss")
                return TRACE_OK_CONTINUE;
            else if (entity.GetClassname() == "player")
                return TRACE_OK_CONTINUE;
            else
                return TRACE_CONTINUE;

			//return TRACE_STOP;
		}
	};

	TraceLineGather(trace);

	if (trace.hits.len() > 0)
	{
        if(dbug) ClientPrint(null,3,"hits: ");
		foreach (i, hit in trace.hits)
		{
            if(dbug) ClientPrint(null,3,hit.enthit.tostring())
            //hit.enthit.TakeDamageEx(player, player, player.GetActiveWeapon(), Vector(0,0,0), hit.pos, 50, 2)

            //dont use printtable, it crashes
            // foreach (k, v in hit)
			// {
            //     ClientPrint(null,3,k.tostring() + " " + v.tostring())
			// }
		}
        trace.hits.remove(0)
        return trace.hits;
	}
	else
	{
		if(dbug) ClientPrint(null,3,"no hits");
        return null
	}
}

Bread.HurtBoss <- function(amt) {
    if(Bread.breadboss.GetHealth() < amt) {
        NetProps.SetPropInt(Bread.breadboss, "m_lifeState", 1)
        if(dbug) ClientPrint(null, 3, "killed")
        EntFire("tf_gamerules", "$SetBossHealthPercentage", 0)
        Bread.ResetBoss()
        Bread.DoScript("killed")

        // Change life state to "dying"
        // The bot won't take any more damage, and sentries will stop targeting it

        // Reset health, preventing the default base_boss death behavior
        Bread.breadboss.SetHealth(Bread.breadboss.GetMaxHealth() * 20)

        for (local t; t = Entities.FindByClassname(t, "base_boss"); )
        {
            if(t.GetName().find("tentacleboss")!= null) {
                t.GetScriptScope().iHealth = 100000
                NetProps.SetPropInt(t, "m_lifeState", 1)
                Bread.TentySetSeq(t, t.GetScriptScope().SEQ_DIE, 1, 0)
                EntFireByHandle(t.GetScriptScope().coreParent, "kill", null, 5,null,null)
            }
        }

        return
    }

    Bread.breadboss.SetHealth(Bread.breadboss.GetHealth()-amt)
    local hpPercent = ((1.0*Bread.breadboss.GetHealth()) / (1.0*Bread.breadboss.GetMaxHealth()))
    EntFire("tf_gamerules", "$SetBossHealthPercentage", hpPercent)
    DispatchParticleEffect("merasmus_blood", Bread.breadboss.GetOrigin() + Vector(0,0,100), Vector(0,0,0))
}

// Bread.breadtank <- null
// Bread.tanks <- {}
// Bread.tankModelFix <- function(tank) {
//     local model = "models/props_breadspace_new/bread_mama_new.mdl"
//     local hpPercent = ((1.0*tank.GetHealth()) / tank.GetMaxHealth())
//     local curThreshold = 1.0
//     if(Bread.tanks.rawin(tank.GetName())) curThreshold = Bread.tanks[tank.GetName()]
//     // if(debugzz) if(dbug) ClientPrint(null, 3 ,"hppercent" + hpPercent.tostring() + " wait threshold " + curThreshold)
//     if(hpPercent <= curThreshold || tank.GetModelName()!= model) {
//         tank.SetModelSimple(model)
//         Bread.tanks[tank.GetName()] <- curThreshold - 0.25
//     }
// }

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

Bread.IsPlayerBehind <- function(ent, player) {
    // ent should be Bread.breadinfo or bread_rotator for the boss
    local ent_angles = ent.GetAbsAngles()
    ent_angles.x = 0
    ent_angles.z = 0

    local a = ent.GetOrigin() + ent_angles.Forward()*70 // the "vertex"
    local b = ent.GetOrigin() + ent_angles.Forward()*200
    local c = player.GetOrigin()
    a.z = 0
    b.z = 0
    c.z = 0

    local v1 = a-b
    local v2 = a-c
    v1.Norm()
    v2.Norm()
    local ang =acos((v1).Dot(v2)) * (180.0 / PI);

    //ClientPrint(null, 4, "ang " + ang.tostring())
    return ang > 125
}

Bread.EmitFx <- function(ent,sound,vol = 1) {
    EmitSoundEx({
        sound_name = sound,
        channel = 6,
        filter = 5,
        origin = ent.GetOrigin(),
        entity = ent,
        volume = vol,
        sound_level = 0.5
    })
}
Bread.PrintCollisionInfo <- function() {
    // {
    //     movetype = 4
    //     m_CollisionGroup = 5
    //     m_nSurroundType = -1
    //     solidflags = -1
    //     movecollide = 0
    //     solidtype = -1
    //   }

    local collision = {
        solidtype = NetProps.GetPropInt(breadboss, "m_nSolidType")
        solidflags = NetProps.GetPropInt(breadboss, "m_usSolidFlags")
        m_nSurroundType  = NetProps.GetPropInt(breadboss, "m_nSurroundType")
        movetype   = NetProps.GetPropInt(breadboss, "movetype")
        movecollide   = NetProps.GetPropInt(breadboss, "movecollide")
        m_CollisionGroup    = NetProps.GetPropInt(breadboss, "m_CollisionGroup")
    }
    if(dbug) PopExtUtil.PrintTable(collision)

}

Bread.breadboss <- null
Bread.BreadBossSetup <- function(breadboss) {
    EntFire("breadboss", "SetMaxHealth", "220000")
    breadboss.SetResolvePlayerCollisions(true)
    // NetProps.SetPropInt(breadboss, "m_CollisionGroup",9)
    // NetProps.SetPropInt(breadboss, "m_nSolidType",2)
    // NetProps.SetPropInt(breadboss, "m_usSolidFlags",0)
    //NetProps.SetPropInt(breadboss, "m_nSurroundType",0)

    Bread.PrintCollisionInfo()

    Bread.breadinfo <- Entities.FindByName(null, "bread_rotator")
    Bread.breadheadshot <- Entities.FindByName(null, "cratetop1")

    Bread.breadorigin <- Entities.FindByName(null, "breadorigin")

    //EntFire("breadtank", "SetSpeed", "200", 2, null)
    EntFire("tf_gamerules", "RunScriptCode", "Bread.SetBreadTankSpeed(`200`)", 2, null)

    Bread.breadboss <- breadboss
    Bread.SEQ_IDLE <- Bread.breadboss.LookupSequence("idle")
    Bread.SEQ_BITE <- Bread.breadboss.LookupSequence("bite")
    Bread.SEQ_INTRO <- Bread.breadboss.LookupSequence("intro")
    Bread.SEQ_SLEEP <- Bread.breadboss.LookupSequence("sleep")
    Bread.SEQ_DEATH <- Bread.breadboss.LookupSequence("death")


    Bread.AimLevel <- 0 // 0 is low, 1 is mid, 2 is high
    Bread.OldAimLevel <- 0

    Bread.curSeq <- Bread.SEQ_SLEEP
    if(dbug) ClientPrint(null,2,"bread boss setup")

    // NetProps.SetPropInt(breadboss, "movetype",0)
    // NetProps.SetPropInt(breadboss, "movecollide",0)
    Bread.Hints()

}
Bread.desperation <- false
Bread.DesperateTimes <- function() {
    Bread.desperation = true
}

Bread.Hints <- function() {
    for (local i = 1, player; i <= MaxClients().tointeger(); i++)
    {
        if (player = PlayerInstanceFromIndex(i), player && player.GetTeam() == 2)
        {
            if(player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SNIPER)
                ClientPrint(player, 3, "\x078ff347 Hint: While zoomed, try aiming for the tentacles or the center of the boss' forehead")
            if(player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY)
                ClientPrint(player, 3, "\x078ff347 Hint: You can backstab the boss, just watch out for the tentacles")
        }
    }
}

Bread.curTarget <- null
Bread.noRotate <- true
Bread.lookFront <- true
Bread.nextUpdate <- Time() + 1.5
Bread.UpdateTarget <- function(){
    Bread.curTarget = ClaudzUtil.GetClosestTargetLOS(Bread.breadinfo, 2000, 2, Bread.breadboss,true)
    //if(dbug) ClientPrint(null, 3, "new target " + Bread.curTarget.tostring())
    Bread.nextUpdate <- Time() + 1.5
    return Bread.curTarget
}


Bread.overrideTarget <- null
Bread.SetTargetOverride <- function(ent) {
    Bread.overrideTarget = ent
}
Bread.ClearTargetOverride <- function() {
    Bread.overrideTarget = null
    Bread.curTarget = null
    Bread.Rotate()
}
Bread.Rotate <- function(){
    if(!ClaudzUtil.IsPlayerAlive(Bread.breadboss)) return
    //Bread.PrintCollisionInfo()
    // NetProps.SetPropInt(Bread.breadboss, "m_CollisionGroup",9)
    // NetProps.SetPropInt(Bread.breadboss, "m_nSolidType",2)
    // NetProps.SetPropInt(Bread.breadboss, "m_usSolidFlags",0)

    if(Bread.noRotate == true) {
        if(Bread.lookFront == true)
            EntFire("bread_rotator*", "$RotateTowards", "breadabove", 0)
        else
            EntFire("bread_rotator*", "$StopRotateTowards", "", 0)
        return
    }

    if(Bread.overrideTarget != null) {
        Bread.curTarget = Bread.overrideTarget
    }

    else if(Bread.curTarget == null || !ClaudzUtil.IsPlayerAlive(Bread.curTarget) ||
            !ClaudzUtil.IsPlayerLOSofMe(Bread.breadboss,Bread.curTarget,Bread.breadboss,true) ||
            ClaudzUtil.Dist(Bread.breadboss, Bread.curTarget) > 800 ||
            ClaudzUtil.IsPlayerDisguisedSpy(Bread.curTarget)||
            Time() > Bread.nextUpdate) {

        if(Bread.UpdateTarget() == null){
            EntFire("bread_rotator*", "$StopRotateTowards", "", 0)
            return
        }

    }
    EntFire("bread_rotator*", "$RotateTowards", "!activator", 0, Bread.curTarget)
    //if(Bread.curTarget!= null) if(dbug) ClientPrint(null, 4, Bread.curTarget.tostring())
}


Bread.ToggleRotate <- function() {
    if(Bread.noRotate) {
        Bread.noRotate = false
    } else { Bread.noRotate = true }
    Bread.Rotate()
}


Bread.PlaybackRate <- 1
Bread.DigDown <- function() {
    Bread.curSeq = Bread.SEQ_SLEEP
    Bread.PlaybackRate = 0.1
    Bread.breadboss.ResetSequence(Bread.SEQ_SLEEP)
    Bread.breadboss.SetCycle(0.0)
    Bread.noRotate = true
}
Bread.BiteAttack <- function() {
    Bread.PlaybackRate = 1
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(0.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("BreadSoundBite", "ForceSpawnAtEntityOrigin", "bread_rotator", 0)
    EntFire("bitehurt", "Enable", null, 0.3, null)
    EntFire("bitehurt", "Disable", null, 0.8, null)

}
Bread.BiteReverse <- function() {
    Bread.PlaybackRate = -1
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.35, null)
    EntFire("breadGoopMortar", "FireOnce", 8, 0.4, null)
}
Bread.BiteReverseBig <- function() {
    Bread.PlaybackRate = -1
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.35, null)
    EntFire("breadGoopMortarBig", "FireOnce", 8, 0.4, null)
}
Bread.BiteReverseShotty <- function() {
    Bread.PlaybackRate = -1.0
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.6, null)
    EntFire("breadGoopShotgun", "FireOnce", 8, 0.7, null)
}
Bread.BiteReverseAcid <- function() {
    Bread.PlaybackRate = -1.0
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.6, null)
    EntFire("breadGoopAcid", "FireMultiple", 4, 0.7, null)
}
Bread.BiteReverseGas <- function() {
    Bread.PlaybackRate = -0.8
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.5, null)
    EntFire("breadGasMortar", "FireOnce", 8, 0.6, null)
    EntFire("breadGasMortar", "FireOnce", 8, 0.75, null)
}
Bread.BiteReverseSlow <- function() {
    Bread.PlaybackRate = -0.8
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.5, null)
    //EntFire("breadGoopMortar", "FireOnce", 8, 0.5, null)
    //EntFire("breadGoopMortar", "FireOnce", 8, 0.65, null)
    EntFire("breadGoopMortar", "FireOnce", 8, 0.6, null)
    EntFire("breadGoopMortar", "FireOnce", 8, 0.75, null)
    EntFire("breadGoopMortar", "FireOnce", 8, 0.9, null)
    EntFire("breadGasMortar", "FireOnce", 8, 0.6, null)
}
Bread.BiteReverseRocket <- function() {
    // Bread.PlaybackRate = -1.4
    // Bread.curSeq = Bread.SEQ_BITE
    // Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    // Bread.breadboss.SetCycle(1.0)
    // Bread.noRotate = false
    // Bread.Rotate()
    // EntFire("toggleCrate", "trigger", 8, 0.25, null)
    // EntFire("breadGoopShooter", "FireOnce", 8, 0.3, null)
    // //EntFire("breadGoopShooter", "FireOnce", 8, 0.6, null)
    // EntFire("breadGoopShooter", "FireOnce", 8, 0.5, null)
    Bread.PlaybackRate = -1
    Bread.curSeq = Bread.SEQ_BITE
    Bread.breadboss.ResetSequence(Bread.SEQ_BITE)
    Bread.breadboss.SetCycle(1.0)
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("toggleCrate", "trigger", 8, 0.4, null)
    EntFire("breadGoopShooter", "FireOnce", 8, 0.5, null)
    EntFire("breadGoopShooter", "FireOnce", 8, 0.6, null)
    EntFire("breadGoopShooter", "FireOnce", 8, 0.7, null)
}
Bread.EruptAttack <- function() {
    Bread.PlaybackRate = 1
    Bread.curSeq = Bread.SEQ_INTRO
    //Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_INTRO)
    Bread.breadboss.SetCycle(0.15) //21
    Bread.noRotate = true
    Bread.Rotate()
}
Bread.PillSpit <- function() {
    Bread.PlaybackRate = 0.6
    Bread.curSeq = Bread.SEQ_INTRO
    //Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_INTRO)
    Bread.breadboss.SetCycle(0.35) //21
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 0, null)
    EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_03.mp3", 2, null)
    //Crocs.Growl
    EmitSoundEx({
        sound_name = "Crocs.Growl",
        channel = 6,
        filter = 5,
        origin = Bread.breadboss.GetOrigin(),
        entity = Bread.breadboss,
        volume = 1,
        sound_level = 0.5
    })
    //EntFire("toggleCrate", "trigger", 8, 0.35, null)
    EntFire("breadGoopPills", "$StartFiring", 8, 1.5, null)

    EntFire("breadGoopPills", "FireMultiple", 4, 1.5, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 2, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 2.5, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 3, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 3.5, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 4, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 4.5, null)
    EntFire("breadGoopPills", "FireMultiple", 4, 5, null)

    EntFire("breadGoopPills", "$StopFiring", 8, 5.5, null)
}
Bread.Roar <- function() {
    Bread.PlaybackRate = 2
    Bread.curSeq = Bread.SEQ_INTRO
    //Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_INTRO)
    Bread.breadboss.SetCycle(0.4) //21
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 0, null)
    //Crocs.Growl
    EmitSoundEx({
        sound_name = "Crocs.Growl",
        channel = 6,
        filter = 5,
        origin = Bread.breadboss.GetOrigin(),
        entity = Bread.breadboss,
        volume = 1,
        sound_level = 0.5
    })
}
Bread.RoarSlow <- function() {
    Bread.PlaybackRate = 1.0
    Bread.curSeq = Bread.SEQ_INTRO
    //Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_INTRO)
    Bread.breadboss.SetCycle(0.4) //21
    Bread.noRotate = false
    Bread.Rotate()
    EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 0, null)
    //Crocs.Growl
    EmitSoundEx({
        sound_name = "Crocs.Growl",
        channel = 6,
        filter = 5,
        origin = Bread.breadboss.GetOrigin(),
        entity = Bread.breadboss,
        volume = 1,
        sound_level = 0.5
    })
}
Bread.EruptReverse <- function() {
    Bread.PlaybackRate = -1
    Bread.curSeq = Bread.SEQ_INTRO
    Bread.breadboss.ResetSequence(Bread.SEQ_INTRO)
    Bread.breadboss.SetCycle(0.30)
    Bread.noRotate = true
    Bread.Rotate()
    //if(dbug) ClientPrint(null, 3, "EruptReverse")
}
Bread.DoIdle <- function() {
    Bread.PlaybackRate = 1
    Bread.curSeq = Bread.SEQ_IDLE
    Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_IDLE)
    Bread.noRotate = false
    Bread.Rotate()
    if(Bread.AimLevel < 1) Bread.AimLevel = 1
}
Bread.DoStunned <- function() {
    Bread.PlaybackRate = 0.8
    Bread.curSeq = Bread.SEQ_IDLE
    Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_IDLE)
    Bread.noRotate = true
    Bread.Rotate()
}
Bread.BreadDie <- function() {
    Bread.lookFront = true
    Bread.PlaybackRate = 1.0
    Bread.curSeq = Bread.SEQ_DEATH
    //Bread.breadboss.SetCycle(0.0)
    Bread.breadboss.ResetSequence(Bread.SEQ_DEATH)
    Bread.breadboss.SetCycle(0.0) //21
    Bread.noRotate = true
    Bread.Rotate()
    //EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 0, null)
    EntFire("tf_gamerules", "PlayVO", "breadspace/breadboss_wakeup.mp3", 0, null)

    //Crocs.Growl
    EmitSoundEx({
        sound_name = "Crocs.Growl",
        channel = 6,
        filter = 5,
        origin = Bread.breadboss.GetOrigin(),
        entity = Bread.breadboss,
        volume = 1,
        sound_level = 0.5
    })
    EntFire("deathrattle", "StartShake", null, 0)
    TextualTimer.Pause()
}
Bread.BreadKillCue <- function() {
    //Bread.lookFront = true
    Bread.noRotate = true
    //Bread.Rotate()
    EntFire("bread_rotator*", "$RotateTowards", "breadabove", 0)
    EntFire("kill_bread_relay", "trigger", null, 0)
    EntFire("deathrattle", "StopShake", null, 0)
    Bread.PlaybackRate = 0
    NetProps.SetPropString(Bread.breadboss, "m_iszScriptThinkFunction", "")
    EntFire("bread_rotate_relay", "disable")
    EntFire("tf_gamerules", "$SetBossHealthPercentage", 0)
}

Bread.BreadSetSeq <- function(seq, rate = 1, cycle = 0.0, norotate = false) {
    local scope = Bread.breadboss.GetScriptScope()
    Bread.PlaybackRate = rate
    Bread.curSeq = seq
    Bread.breadboss.SetCycle(cycle)
    Bread.breadboss.ResetSequence(seq)
    Bread.noRotate = norotate
    Bread.Rotate()
}
Bread.BreadSetSeqTable <- function(tab) {
    local scope = Bread.breadboss.GetScriptScope()
    Bread.PlaybackRate = table.rawin("rate") ? tab.rate : 1
    Bread.curSeq = tab.seq
    Bread.breadboss.SetCycle(table.rawin("cycle") ? tab.cycle : 0.0)
    Bread.breadboss.ResetSequence(tab.seq)
    Bread.noRotate = table.rawin("noRotate") ? tab.noRotate : false
    Bread.Rotate()
}
Bread.AnimQueue <- []
Bread.AnimScripts<- {
    mortar = ["Roar","BiteReverseSlow","BiteReverseSlow","BiteReverseSlow","BiteReverseGas","BiteReverseBig","DoIdle"], //,"BiteReverse"
    biteComplex = ["Roar","BiteAttack"],
    summon = ["Roar","DoIdle"],
    payloadHit = ["RoarSlow","DoStunned"],
    rapid = ["Roar","BiteReverseRocket","BiteReverseRocket","BiteReverseRocket","BiteReverseRocket","BiteReverseRocket","BiteReverseRocket","DoIdle"],
    shotgun = ["BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","BiteReverseShotty","DoIdle"]
    acid = ["BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","BiteReverseAcid","DoIdle"]
    pills = ["PillSpit","DoIdle"]
    killed = ["BreadDie","BreadKillCue"]
}
Bread.DoScript <- function(scriptname) {
    if(dbug) ClientPrint(null, 3, "doscript " + scriptname)
    local scrpt = Bread.AnimScripts[scriptname]
    local first = scrpt[0]
    Bread[first]()
    Bread.AnimQueue <- clone(scrpt)
    Bread.AnimQueue.remove(0)
}
Bread.DoChase <- 0
::AnimThinkTest <- function() {
    if(!(NetProps.GetPropInt(self, "m_lifeState") == 0)) EntFire("tf_gamerules", "$SetBossHealthPercentage", 0)
    if (!("Bread" in getroottable())) return
    local bot = self
    //if(dbug) ClientPrint(null, 4, Bread.AnimQueue.len().tostring())

    if(Bread.AnimQueue.len() > 0) {
        if (bot.GetCycle() > 0.98 && Bread.PlaybackRate > 0) {
            local nextAnim = Bread.AnimQueue.remove(0)
            //if(dbug) ClientPrint(null, 3, nextAnim)
            Bread[nextAnim]()
        }
        else if (bot.GetCycle() < 0.02 && Bread.PlaybackRate < 0) {
            local nextAnim = Bread.AnimQueue.remove(0)
            //if(dbug) ClientPrint(null, 3, nextAnim)
            Bread[nextAnim]()
        }
    }

    //intro for popping out
    else if(Bread.curSeq == Bread.SEQ_INTRO && bot.GetCycle() > 0.95) {
        Bread.DoIdle()
    }

    else if (bot.GetCycle() > 0.99 && Bread.PlaybackRate > 0){
        bot.SetCycle(0.0)
        if(Bread.curSeq == Bread.SEQ_BITE){
            EntFire("BreadSoundBite", "ForceSpawnAtEntityOrigin", "bread_rotator", 0)
        }
    }

    // reversed intro for going down anim
    else if (Bread.curSeq == Bread.SEQ_INTRO && bot.GetCycle() < 0.08 && Bread.PlaybackRate < 0){
        Bread.DigDown()
        //EntFire("breadboss", "$SetKey$renderfx", "6", 0)
        //EntFire("breadboss", "$SetKey$renderamt", "0", 0)

    }
    else if (bot.GetCycle() < 0.01 && Bread.PlaybackRate < 0){
        bot.SetCycle(0.99)
        if(Bread.curSeq == Bread.SEQ_BITE){
            //EntFire("BreadSoundBite", "ForceSpawnAtEntityOrigin", "bread_rotator", 0)
            EntFire("toggleCrate", "trigger", 8, 0.35, null)
            EntFire("breadGoopMortar", "FireOnce", null, 0.4, null)
        }
    }



    bot.SetSequence(Bread.curSeq)
    bot.StudioFrameAdvance()
    bot.DispatchAnimEvents(bot)
    bot.SetPlaybackRate(Bread.PlaybackRate)

    //handle rotation
    local angles = Bread.breadinfo.GetAbsAngles()

    //z value shouldnt get lower than -20
    if(Bread.OldAimLevel != Bread.AimLevel) {
        if(Bread.OldAimLevel < Bread.AimLevel) Bread.OldAimLevel += 0.05
        else Bread.OldAimLevel -= 0.05
    }
    local z = ClaudzUtil.Max(angles.x + 60 + (Bread.OldAimLevel*(-10)), -20) //ClaudzUtil.Max(angles.x + 50, -20)
    local breadangles = QAngle(180, angles.y - 90, z)
    if(Bread.noRotate) {
        breadangles = QAngle(180, angles.y - 90, 0)
    }
    if(Bread.curSeq == Bread.SEQ_BITE && Bread.PlaybackRate < 0) {
        breadangles.z -= 15
    }
    Bread.breadboss.SetAbsAngles(breadangles)
    //if(dbug) ClientPrint(null, 4, Bread.breadboss.GetAbsAngles().tostring())

    if(Bread.DoChase != 0) {
        if(Bread.curTarget == null) return -1
        if(dbug) ClientPrint(null, 4, Bread.DoChase.tostring())
        //local dir = Bread.curTarget.GetOrigin() - Bread.breadboss.GetOrigin()
        local dir = angles.Forward()
        dir.z = 0
        dir.Norm()
        local new_pos = Bread.breadorigin.GetOrigin() + dir*(Bread.DoChase*FrameTime())

        if( !(new_pos.x > 4100 || new_pos.x < 3000 || new_pos.y > 300 || new_pos.y < -1800) )
            Bread.breadorigin.SetAbsOrigin(Bread.breadorigin.GetOrigin() + dir*(Bread.DoChase*FrameTime()))
        //Bread.breadorigin.SetAbsVelocity(dir*Bread.DoChase)
        Bread.breadboss.SetResolvePlayerCollisions(true)
    }

    return -1
}

::Breggbusterthink <- function() {
    if(self.IsTaunting()) {
        local scope = self.GetScriptScope()
        delete scope.PlayerThinkTable.Breggbusterthink
        EntFireByHandle(scope.bregg, "kill", "", 2, null, null)
    }
}

Bread.AttackIndex <- -1
Bread.Phase1AttackScripts <- [
    "bite_relay",
    "digdown_relay",
    "erupt_relay",
    "shotgun_relay"
]
Bread.Phase2AttackScripts <- [
    "acid_relay",
    "pill_relay",
    "biterevrocket_relay",
    "tentacleburst_relay", //tent
    "mortar_relay",
    "shotgun_relay",
    "summonRelay", //tent
]

Bread.Phase3AttackScripts <- [
    "bite_relay_chase", //tent
    "pill_relay",
    "biterevrocket_relay",
    "bite_relay_chase", //tent
    "moreTentacleBurstRelay",
    "mortar_relay",
    "shotgun_relay",
    "summonRelay", //tent
    "acid_relay"
]
Bread.Phase <- 0
Bread.TriggerNextAttack <- function() {
    if(!(NetProps.GetPropInt(Bread.breadboss, "m_lifeState") == 0)) return

    Bread.AttackIndex += 1
    local nextAttack = ""

    // // start phase 3 if fall under 50% health
    // if(Bread.Phase == 2 && ((1.0*Bread.breadboss.GetHealth()) / (1.0*Bread.breadboss.GetMaxHealth())) < 0.5) {
    //     Bread.AttackIndex = -1
    //     Bread.Phase = 3
    // }

    if(Bread.Phase == 2) {
        if(Bread.AttackIndex >= Bread.Phase2AttackScripts.len()) Bread.AttackIndex = 0
        nextAttack = Bread.Phase2AttackScripts[Bread.AttackIndex]
    } else if (Bread.Phase == 3) {
        if(Bread.AttackIndex >= Bread.Phase3AttackScripts.len()) Bread.AttackIndex = 0
        nextAttack = Bread.Phase3AttackScripts[Bread.AttackIndex]
        if(nextAttack == "bite_relay_chase" || nextAttack == "mortar_relay" || nextAttack == "tentacleburst_relay" || nextAttack == "pill_relay"|| nextAttack == "acid_relay" || nextAttack == "moreTentacleBurstRelay") {
            Bread.DoChase = 0
        } else {
            Bread.DoChase = 100
        }
    } else if (Bread.Phase == 0) {
        // if phase is set to 0, it is a transitional phase
    }
    EntFire(nextAttack, "trigger")
}

Bread.ResetBoss <- function() {
    Bread.Phase = 0
    Bread.ClearTargetOverride()
    Bread.lookFront = true
    Bread.AttackIndex = -1
    Bread.StopAllRelays()
    Bread.AimLevel = 1
}
Bread.TriggerPhase2 <- function() {
    Bread.Phase = 2
    Bread.TriggerNextAttack()
}
Bread.TriggerPhase3 <- function() {
    Bread.Phase = 3
    Bread.TriggerNextAttack()
}
Bread.StopAllRelays <- function() {
    local relays = [
        "digdown_relay",
        "bite_relay_chase",
        "pill_relay",
        "mortar_relay",
        "shotgun_relay",
        "biterevrocket_relay",
        "summonRelay",
        "tentacleburst_relay",
        "bite_relay",
        "acid_relay",
        "moreTentacleBurstRelay"
    ]
    foreach (r in relays) {
        EntFire(r, "CancelPending")
    }
    Bread.ClearTargetOverride()
}
Bread.PayloadHitFunc <- function() {
    if(dbug) ClientPrint(null, 3, "payloadhit called")
    //If boss has not died from payload damage
    if((NetProps.GetPropInt(Bread.breadboss, "m_lifeState") == 0)) {
        if(dbug) ClientPrint(null, 3, "trigger phase 3")
        Bread.ResetBoss()
        EntFire("tf_gamerules", "RunScriptCode", "Bread.TriggerPhase3()", 0.2)
    } else {
        if(dbug) ClientPrint(null, 3, "we shouldnt do anything here")
        //Bread.DoScript("killed")
    }
}



Bread.ActiveTentacles <- 0
Bread.ActiveMeleeTentacles <- 0

Bread.SummonTentacles <- function() {
    local left = ["tent_spot_2","tent_spot_5","tent_spot_6"]
    local right = ["tent_spot_1","tent_spot_3","tent_spot_4"]

    if(Bread.ActiveTentacles < 3) {
        local i = RandomInt(0,2)
        local lspot = FindByName(null, left[i])
        if(FindByNameNearest("tentacleboss*", lspot.GetOrigin(), 100) == null) {
            EntFire("TentaclebossPT", "ForceSpawnAtEntityOrigin", left[i])
        }
        i = RandomInt(0,2)
        local rspot = FindByName(null, right[i])
        if(FindByNameNearest("tentacleboss*", rspot.GetOrigin(), 100) == null) {
            EntFire("TentaclebossPT", "ForceSpawnAtEntityOrigin", right[i])
        }
    }

}
Bread.SummonMeleeTentacles <- function() {
    if(Bread.ActiveMeleeTentacles < 1) {
        EntFire("breadtentrelay", "trigger")
    }
}

Bread.TentyDie <- function(ent) {
    //ClientPrint(null,3,"tentydie " + ent.tostring())
    ent.GetScriptScope().iHealth = 100000
    Bread.TentySetSeq(ent, ent.GetScriptScope().SEQ_DIE, 1, 0)
    EntFireByHandle(ent.GetScriptScope().shooter, "kill", null, 0, null, null)
    EntFireByHandle(ent.GetScriptScope().sweepShooter, "kill", null, 0, null, null)
    EntFireByHandle(ent.GetScriptScope().lungeShooter, "kill", null, 0, null, null)

    EntFireByHandle(ent.GetScriptScope().coreParent, "kill", null, 5,null,null)
    EmitSoundEx({
        sound_name = "Crocs.Hiss",
        channel = 6,
        filter = 5,
        origin = ent.GetOrigin(),
        entity = ent,
        volume = 1,
        sound_level = 0.5
    })
    if(ent.GetScriptScope().meleeOnly) {
        Bread.ActiveMeleeTentacles -= 1
    }
    else if(ent.GetOrigin().z > -4000)
    {
        Bread.ActiveTentacles -= 1
    }
}

Bread.TentySetSeq <- function(tenty, seq, rate = 1, cycle = 0.0) {

    local scope = tenty.GetScriptScope()
    scope.PlaybackRate = rate
    scope.curSeq = seq
    tenty.SetCycle(cycle)
    tenty.ResetSequence(seq)
    if(seq == scope.SEQ_LUNGE) {
        EntFireByHandle(scope.lungeShooter, "FireOnce", null, 1.2, null,null)
        if(dbug) ClientPrint(null, 3, "tent lunge")
    } else if (seq == scope.SEQ_SWEEP) {
        EntFireByHandle(scope.sweepShooter, "$StartFiring", null, 1, null,null)
        EntFireByHandle(scope.sweepShooter, "$StopFiring", null, 1.5, null,null)
        //EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.0, null,null)
        // EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.1, null,null)
        // EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.2, null,null)
        // EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.3, null,null)
        // EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.4, null,null)
        // EntFireByHandle(scope.sweepShooter, "FireOnce", null, 1.5, null,null)


        EntFireByHandle(scope.sweeprotate, "StartForward",null, 1, null,null)
        EntFireByHandle(scope.sweeprotate, "SnapToStartPos",null, 1.6, null,null)
        //frames 30-46
        //30 fps
        if(dbug) ClientPrint(null, 3, "tent sweep")
    } else if (seq == scope.SEQ_SHOOT) {
        //EntFire("tentWepShoot", "FireOnce", null, 0.3, null)
        EntFireByHandle(scope.shooter, "FireOnce", null, 0.3, null, null)
        if(dbug) ClientPrint(null, 3, "tent shoot")
    } else if (seq == scope.SEQ_DIE) {
        if(dbug) ClientPrint(null, 3, "kill tent")
        EntFireByHandle(scope.glow, "disable", "", 0.1, null, null)
        EntFireByHandle(tenty, "disable", "", 0, null, null)
        EntFireByHandle(tenty, "$SetSolidFlags", "4", 0, null, null)
    } else if (seq == scope.SEQ_IDLE) {
        tenty.SetCycle(0.5*RandomInt(0,3)/10.0)
    }
}
Bread.TentyUpdateTarget <- function(tenty) {
    local ent = ClaudzUtil.GetClosestTargetLOS(tenty, 1200, 2, tenty)
    tenty.GetScriptScope().curTarget <- ent
    tenty.GetScriptScope().nextUpdate <- Time() + 4
}
Bread.TentyRotate <- function(tenty) {
    local scope = tenty.GetScriptScope()

    if(Time() > scope.nextUpdate) Bread.TentyUpdateTarget(tenty)

    else if(scope.curTarget == null || !ClaudzUtil.IsPlayerAlive(scope.curTarget) || !ClaudzUtil.IsPlayerLOSofMe(tenty,scope.curTarget,tenty) || ClaudzUtil.Dist(tenty, scope.curTarget) > 460)
        Bread.TentyUpdateTarget(tenty)

    if(scope.curTarget != null)
        {
            EntFireByHandle(tenty.GetScriptScope().rotator, "$RotateTowards", "!activator", 0, scope.curTarget, null)
            EntFireByHandle(tenty.GetScriptScope().shootrotator, "$RotateTowards", "!activator", 0, scope.curTarget, null)
        }
    else
        EntFireByHandle(tenty.GetScriptScope().rotator, "$StopRotateTowards", "", 0, null, null)
}
::TentacleSetup <- function(tenty, meleeOnly = false) {
    if(!meleeOnly)
        Bread.ActiveTentacles += 1
    else
        Bread.ActiveMeleeTentacles += 1
    // local arr = split(tenty.GetName() , "_")
    // local FixupId = arr[arr.len()-1]
    // local rotator = Entities.FindByNameNearest("tentacleorigin_" + FixupId, tenty.GetOrigin(), 50)
    // if(rotator == null) {
    //     rotator = Entities.FindByNameNearest("tentacleorigin", tenty.GetOrigin(), 50)
    //     FixupId = ""
    // }
    EntFire("tf_gamerules", "PlayVO", "ambient_mp3/hell/hell_rumbles_02.mp3", 1, null)
    if(dbug) ClientPrint(null,3,tenty.GetName())

    tenty.ValidateScriptScope()
    local scope = tenty.GetScriptScope()
    scope.nextUpdate <- Time() + 2

    scope.SEQ_INTRO <- tenty.LookupSequence("extend")
    scope.SEQ_LUNGE <- tenty.LookupSequence("attack_lunge")
    scope.SEQ_SWEEP <- tenty.LookupSequence("attack_sweep")
    scope.SEQ_SHOOT <- tenty.LookupSequence("attack_shoot")
    scope.SEQ_DIE   <- tenty.LookupSequence("die")
    scope.SEQ_IDLE  <- tenty.LookupSequence("wiggle_idle")
    //scope.fixupId <- FixupId
    scope.TENTY <- tenty
    scope.curTarget <- null
    //scope.rotator <- rotator
    scope.rotator <- Entities.FindByNameNearest("tentacleorigin*", tenty.GetOrigin(), 200) //rotator
    scope.shootrotator <- Entities.FindByNameNearest("tentacleshootrotate*", tenty.GetOrigin(), 200)
    scope.shooter <- Entities.FindByNameNearest("tentWepShoot*", tenty.GetOrigin(), 200)
    scope.sweeprotate <- Entities.FindByNameNearest("sweep_rotate*", tenty.GetOrigin(), 200)
    scope.sweepShooter <- Entities.FindByNameNearest("tentWepMortarSweep*", tenty.GetOrigin(), 200)
    scope.lungeShooter <- Entities.FindByNameNearest("tentWepMortar*", tenty.GetOrigin(), 200)
    scope.glow <- Entities.FindByNameNearest("tent_glow*", tenty.GetOrigin(), 100)
    scope.blood <- Entities.FindByNameNearest("tentblood*", tenty.GetOrigin(), 200)

    scope.coreParent <- Entities.FindByNameNearest("tentaclecore*", tenty.GetOrigin(), 200)
    scope.meleeOnly <- meleeOnly

    scope.iHealth <- 800
    if(meleeOnly)
        scope.iHealth <- 1000

    if(dbug) PopExtUtil.PrintTable(scope)

    scope.PlaybackRate <- 0
    scope.curSeq <- scope.SEQ_INTRO

    EntFireByHandle(tenty, "$SetKey$renderamt", "255", 1.1, null, null)
    EntFireByHandle(tenty, "RunScriptCode", "Bread.TentySetSeq(self,self.GetScriptScope().SEQ_INTRO,0.3)", 1, null, null)
    EmitSoundEx({
        sound_name = "breadspace/newlocknew_rockrumble_short.mp3",
        channel = 6,
        filter = 5,
        origin = tenty.GetOrigin(),
        entity = tenty,
        volume = 1,
        sound_level = 0.5
    })
    EntFireByHandle(tenty, "RunScriptCode", "self.StopSound(`breadspace/newlocknew_rockrumble_short.mp3`)", 3, null, null)

    if(tenty.GetOrigin().z < -4000)
    {
        EntFireByHandle(scope.glow, "kill", "", 0.1, null, null)
        Bread.ActiveTentacles -= 1
        scope.iHealth <- 1500
    }

    //tenty.SetAbsOrigin(Entities.FindByName(null, "tentacleorigin").GetOrigin())

    AddThinkToEnt(self, "TentacleThink")
    //Bread.TentyUpdateTarget(tenty)
}

// tentacle AI is like a flowchart
//  checks for closest target on a cycle of 0.5 secs
//  if there's no closest target, go idle
//  if idling, immediatly switch modes when there's a new target
//  if closest target is far, shoot
//  if closest target is near (300), lunge then sweep
::TentacleThink <- function() {
    //if(!(NetProps.GetPropInt(self, "m_lifeState") == 0)) return
    //ClientPrint(null, 4,self.GetCycle().tostring())

    local scope = self.GetScriptScope()
    local targetDist = 5000
    self.SetPlaybackRate(scope.PlaybackRate)

    if(scope.curTarget != null && ClaudzUtil.IsPlayerAlive(scope.curTarget)) {
        targetDist = ClaudzUtil.Dist(self, scope.curTarget)
    }

    if (scope.curSeq == scope.SEQ_DIE ){
        if(self.GetCycle() > 0.98)
        scope.PlaybackRate = 0
    }

    else if((scope.curTarget == null|| scope.curSeq == scope.SEQ_INTRO ) && self.GetCycle() > 0.98) {
        Bread.TentySetSeq(self,scope.SEQ_IDLE)
    }

    else if(scope.curSeq == scope.SEQ_IDLE && scope.curTarget != null && !scope.meleeOnly) {
        if(targetDist > 300)
            Bread.TentySetSeq(self,scope.SEQ_SHOOT)
        else
            Bread.TentySetSeq(self,scope.SEQ_LUNGE,1.5)
    } else if(scope.curSeq == scope.SEQ_IDLE && scope.curTarget != null && scope.meleeOnly) {
        if(targetDist < 300 )
            Bread.TentySetSeq(self,scope.SEQ_LUNGE,1.5)
    }

    else if(scope.curSeq == scope.SEQ_LUNGE && self.GetCycle() > 0.98) {
        if(targetDist > 300 && !scope.meleeOnly)
            Bread.TentySetSeq(self,scope.SEQ_SHOOT)
        else if(targetDist > 300 && scope.meleeOnly)
            Bread.TentySetSeq(self,scope.SEQ_IDLE)
        else
            {
                Bread.TentySetSeq(self,scope.SEQ_SWEEP)
                self.SetCycle(0)
                return -1
            }
    }
    else if(scope.curSeq == scope.SEQ_SWEEP && self.GetCycle() > 0.98 ) {
        if(targetDist > 300 && !scope.meleeOnly)
            Bread.TentySetSeq(self,scope.SEQ_SHOOT)
        else if(targetDist > 300 && scope.meleeOnly)
            Bread.TentySetSeq(self,scope.SEQ_IDLE)
        else
        {
            Bread.TentySetSeq(self,scope.SEQ_IDLE)
            //Bread.TentySetSeq(self,scope.SEQ_LUNGE,1.5)
            self.SetCycle(0)
            return -1
        }
    }

    else if(scope.curSeq == scope.SEQ_SHOOT && targetDist < 300 && self.GetCycle() > 0.98) {
        Bread.TentySetSeq(self,scope.SEQ_LUNGE,1.5)
    }

    else if(scope.curSeq == scope.SEQ_SHOOT && targetDist >= 300 && self.GetCycle() > 0.98) {
        //EntFire("tentWepShoot", "FireOnce", null, 0.3, null)
        EntFireByHandle(scope.shooter, "FireOnce", null, 0.3, null, null)

        self.SetCycle(0.0)
    }


    else if (self.GetCycle() > 0.98 && scope.PlaybackRate > 0){
        self.SetCycle(0.0)
    }
    else if (self.GetCycle() < 0.01 && Bread.PlaybackRate < 0){
        self.SetCycle(0.99)
    }
    self.SetSequence(scope.curSeq)
    self.StudioFrameAdvance()
    self.DispatchAnimEvents(self)
    self.SetPlaybackRate(scope.PlaybackRate)

    return -1
}

Bread.NoMove <- function(prop) {
    //AddThinkToEnt(prop, "NoMove")
    local props = {
        owner = NetProps.GetPropEntity(self, "m_hOwnerEntity"),
        moveparent = NetProps.GetPropEntity(self, "moveparent"),
        movetype = NetProps.GetPropInt(self, "movetype")
        movecollide = NetProps.GetPropInt(self, "movecollide")
    }
    if(dbug) ClientPrint(null, 3, self.GetPropEntity(handle entity, string propertyName))
}
::NoMove <- function() {
    self.SetGravity(0.0001)
    if(dbug) ClientPrint(null, 4, "base " + self.GetBaseVelocity().tostring() + " phys " + self.GetPhysVelocity().tostring() + " abs " + self.GetAbsVelocity().tostring() + " grav " + self.GetGravity().tostring())
}

Bread.WeakSetup <- function(prop) {
    prop.ValidateScriptScope()
    local scope = prop.GetScriptScope()
    scope.locTarget <- Entities.FindByNameNearest("breadbossmouth", prop.GetOrigin(), 1000)
    AddThinkToEnt(prop, "WeakThink")
}
::WeakThink <- function() {
    local scope = self.GetScriptScope()
    self.SetAbsOrigin(scope.locTarget.GetOrigin())
    self.SetAbsAngles(scope.locTarget.GetAbsAngles())
    local loc = Bread.breadboss.GetAttachmentOrigin(Bread.breadboss.LookupAttachment("MOUTHDEEP"))
    //if(dbug) ClientPrint(null, 4, "box loc " + self.GetOrigin().tostring() + " point loc " + scope.locTarget.GetOrigin().tostring() + " attach loc " + loc.tostring())
    //if(dbug) ClientPrint(null, 4, "boss loc " + Bread.breadboss.GetOrigin().tostring() + " origin loc " + Bread.breadorigin.GetOrigin().tostring() )
}

::StrikeMarkerThink <- function() {
    local scope = self.GetScriptScope()
    local parent = scope.parent
    if(parent == null || !ClaudzUtil.IsPlayerAlive(parent) || !parent.GetAbsVelocity) return -1;
    local newpos = self.GetOrigin()

    local ground = GetLocationBelow(parent)
    //local diff = ground - self.GetOrigin()
    scope.sparker.SetAbsOrigin(ground + Vector(0,0,1))
    // self.SetAbsAngles(QAngle(0,0,0))
    // newpos = ground + Vector(0,0,1)


    // local diff = (newpos - scope.oldpos)
    // self.SetAbsOrigin(scope.oldpos + diff*FrameTime())
    // scope.oldpos <- scope.oldpos + diff*FrameTime()
    return -1;
    // return -1 for 0.015; return 0 for next frame
}

Bread.CreateStrikeMarker <- function(projectile) {
    projectile.ValidateScriptScope()
    local scope = projectile.GetScriptScope()
    scope.sparker <- projectile
    scope.parent <- projectile.GetMoveParent()
    scope.oldpos <- GetLocationBelow(projectile)
    AddThinkToEnt(projectile, "StrikeMarkerThink")
}

Bread.breadtank <- null
Bread.SetBreadTank <- function(tank) {
    Bread.breadtank <- tank
}
Bread.SetBreadTankSpeed <- function(spd) {
    if(Bread.breadtank == null) {if(dbug)ClientPrint(null,3,"something fucked up")}
    EntFireByHandle(Bread.breadtank, "SetSpeed", spd, 0, null, null)
}
Bread.KillBreadTank <- function() {
    EntFireByHandle(Bread.breadtank, "kill", null, 0, null, null)
}

// ///////////////////// Debug ///////////////////
// Setting a error handler allows us to view vscript error messages, even if we are not testing locally i.e. on potato testing server
// Bread.DebugSteamIds <- {}
// Bread.DebugSteamIds["[U:1:66915592]"] <- 1
// seterrorhandler(function(e)
// {
// 	for (local player; player = Entities.FindByClassname(player, "player");)
// 	{
// 		if (Bread.DebugSteamIds.rawin(NetProps.GetPropString(player, "m_szNetworkIDString")))
// 		{
// 			local Chat = @(m) (printl(m), ClientPrint(player, 2, m))
// 			ClientPrint(player, 3, format("\x07FF0000AN ERROR HAS OCCURRED [%s].\nCheck console for details", e))

// 			Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
// 			Chat("CALLSTACK")
// 			local s, l = 2
// 			while (s = getstackinfos(l++))
// 				Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))
// 			Chat("LOCALS")
// 			if (s = getstackinfos(2))
// 			{
// 				foreach (n, v in s.locals)
// 				{
// 					local t = type(v)
// 					t ==    "null" ? Chat(format("[%s] NULL"  , n))    :
// 					t == "integer" ? Chat(format("[%s] %d"    , n, v)) :
// 					t ==   "float" ? Chat(format("[%s] %.14g" , n, v)) :
// 					t ==  "string" ? Chat(format("[%s] \"%s\"", n, v)) :
// 									 Chat(format("[%s] %s %s" , n, t, v.tostring()))
// 				}
// 			}
// 			return
// 		}
// 	}
// })
