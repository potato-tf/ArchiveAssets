if (!("CONST" in getroottable()))
{
    ::CONST <- getconsttable()
    ::ROOT <- getroottable()

    foreach(k, v in ::NetProps.getclass())
        if (k != "IsValid" && !(k in ROOT))
            ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

    if (!("ConstantNamingConvention" in ROOT))
    {
        foreach(a, b in Constants)
            foreach(k, v in b)
            {
                CONST[k] <- v != null ? v : 0
                ROOT[k] <- v != null ? v : 0
            }
    }
}

class __Potato_GasNerf {

    __gas_damage_recharge_rate  = 5000.0
    __gas_passive_recharge_rate = 180.0
    // __gas_damage_mult        = ( 90 / 350 ) //used for dmg penalty vs players
    __gas_damage_amount         = 90.0
    __gas_reignite_immune_time  = 5.0
    __damage_range              = Convars.GetFloat("tf_damage_range")

    Events = {

        function OnGameEvent_post_inventory_application(params)
        {
            local player = GetPlayerFromUserID(params.userid)

            if (player.IsFakeClient())
                return

            player.ValidateScriptScope()
            local scope = player.GetScriptScope()

            //only check pyro
            if (player.GetPlayerClass() == 7) {

                //find gas in our loadout
                local gas = null
                for (local i = 0; i < 7; i++) {

                    local wep = GetPropEntityArray(player, "m_hMyWeapons", i)

                    if (wep == null || wep.GetSlot() != 1 || GetPropInt(wep, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 1180)
                        continue

                    gas = wep
                    scope.gaswep <- gas
                    break
                }

                // no gas equipped
                if (!gas)
                {
                    if ("gaswep" in scope)
                        delete scope.gaswep

                    return
                }

                local passive_rate = __Potato_GasNerf.__gas_passive_recharge_rate
                local damage_rate = __Potato_GasNerf.__gas_damage_recharge_rate
                local attrib_damagerate = "item_meter_damage_for_full_charge"
                local attrib_chargerate = "item_meter_charge_rate"
                //apply rebalance attribs
                if (
                    gas.GetAttribute("explode_on_ignite", 0.0) &&
                    gas.GetAttribute(attrib_damagerate, 0.0) != damage_rate &&
                    gas.GetAttribute(attrib_chargerate, 0.0) != passive_rate
                ) {
                    // gas.RemoveAttribute(attrib_damagerate)
                    // gas.RemoveAttribute(attrib_chargerate)
                    gas.AddAttribute(attrib_damagerate, damage_rate, -1)
                    gas.AddAttribute(attrib_chargerate, passive_rate, -1)
                    // gas.AddAttribute("dmg penalty vs players", __Potato_GasNerf.__gas_damage_mult) //handle this in OnTakeDamage instead
                    // gas.AddAttribute("mult_item_meter_charge_rate", 0.01, -1)
                    gas.ReapplyProvision()
                }
                // else if (!gas.GetAttribute("explode_on_ignite", 0.0)) {
                    // gas.RemoveAttribute(attrib_damagerate)
                    // gas.RemoveAttribute(attrib_chargerate)
                    // gas.ReapplyProvision()
                // }
                // Start empty on spawn
                // m_bRegenerating is true when switching loadouts with tf_respawn_on_loadoutchange 1 and touching a resupply cabinet
                if (!GetPropBool(player, "m_Shared.m_bInUpgradeZone") && !GetPropBool(player, "m_bRegenerating"))
                {
                    SetPropIntArray(player, "m_iAmmo", 0, 4)
                    SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 0.0, 1)
                }

                //TESTING REMOVE ME
                //TESTING REMOVE ME
                //TESTING REMOVE ME
                //TESTING REMOVE ME
                //TESTING REMOVE ME
                EntFireByHandle(player, "RunScriptCode", "SetPropIntArray(self, `m_iAmmo`, 1, 4); SetPropFloatArray(self, `m_Shared.m_flItemChargeMeter`, 100.0, 1)", 0.1, null, null)

                // not necessary just read m_flItemChargeMeter
                // local next_charge_timestamp = Time() + passive_rate
                // gas.ValidateScriptScope()
                // local gas_scope = gas.GetScriptScope()
                // gas_scope.passive_charge_progress <- 0.0
                // gas_scope.total_charge_progress <- 0.0
                // gas_scope.ChargeBarThink <- function()
                // {
                    // if ( GetPropFloat(self, "m_flEffectBarRegenTime") == Time() )
                    // {
                        // local passive_charge_progress = ( ( next_charge_timestamp - Time() ) - passive_rate ) / -passive_rate
                        // gas_scope.total_charge_progress += passive_charge_progress
                        // return -1
                    // }
                    // next_charge_timestamp = Time() + passive_rate
                    // return -1
                // }
                // AddThinkToEnt(gas, "ChargeBarThink")
            }
        }

        function OnGameEvent_player_team( params )
        {
            local player = GetPlayerFromUserID(params.userid)

            //remove takedamage flag from bots on respawn
            if (player.IsFakeClient())
                player.RemoveEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE)
        }

        // override gas damage completely
        // was originally just going to use "dmg penalty vs players" but it's easier to fix stacking explosions this way and set absolute damage amounts instead of multipliers
        function OnScriptHook_OnTakeDamage( params )
        {
            local weapon = params.weapon
            local attacker = params.attacker
            local victim = params.const_entity

            local attacker_scope = attacker.GetScriptScope()

            //ignore bots and null ents
            if (!attacker || !weapon || attacker.IsFakeClient()) return

            local gaswep = "gaswep" in attacker_scope ? attacker_scope.gaswep : null

            local chargemeter_netprop = "m_Shared.m_flItemChargeMeter"
            local gasmeter = GetPropFloatArray(attacker, chargemeter_netprop, 1)

            if ( attacker_scope && gaswep && gaswep.IsValid() && weapon != attacker_scope.gaswep )
            {
                // sometimes the meter is full but gas doesn't replenish
                if (gasmeter >= 100.0 && GetPropIntArray(attacker, "m_iAmmo", 4) < 1)
                {
                    SetPropIntArray(attacker, "m_iAmmo", 1, 4)
                    return
                }
                local damage_type = params.damage_type

                // TESTING REMOVE ME
                // TESTING REMOVE ME
                // TESTING REMOVE ME
                // TESTING REMOVE ME
                // if (damage_type & DMG_BURN && !(damage_type & DMG_PLASMA))
                // {
                //     params.early_out = true
                //     return false
                // }

                // handle damage range calculations for the dragons fury so crit build time is consistent with non-crits
                local damage_mult = 1.0
                if (attacker.GetActiveWeapon().GetClassname() == "tf_weapon_rocketlauncher_fireball" && damage_type & DMG_ACID) //DMG_IGNITE
                {
                    local distance = (victim.GetCenter() - attacker.GetCenter()).Length()
                    local optimal_distance = 512
                    local center = distance / optimal_distance

                    center = center > 2.5 ? 2.5 : center < 0.5 ? 0.5 : center

                    damage_mult = (1.0 - (center * damage_range)) + damage_range
                    damage_mult = damage_mult < 0.5 ? 0.5 : damage_mult > 1.2 ? 1.2 : damage_mult
                }
                // local charge_per_tick = ((Time() + passive_rate) / Time()) / passive_rate

                // bad hack for crit charging, works but we should modify the meter directly instead
                // was skill issuing before by ignoring the charge rate upgrade value I think
                // according to the code, formula is current meter + ( (damage / ( damage to charge * charge rate upgrade value ) ) * 100.0 )
                local damage_rate = __Potato_GasNerf.__gas_damage_recharge_rate
                if ( damage_type & DMG_ACID)
                {
                    gaswep.RemoveAttribute("item_meter_damage_for_full_charge")
                    gaswep.AddAttribute("item_meter_damage_for_full_charge", (damage_rate * (3 / damage_mult)), -1)
                    gaswep.ReapplyProvision()
                    // SetPropFloatArray(attacker, chargemeter_netprop, gasmeter - (gas_dmg * 3), 1)
                }
                else if (!(damage_type & DMG_ACID) && gaswep.GetAttribute("item_meter_damage_for_full_charge", 0.0) != damage_rate)
                {
                    gaswep.RemoveAttribute("item_meter_damage_for_full_charge")
                    gaswep.AddAttribute("item_meter_damage_for_full_charge", damage_rate, -1)
                    gaswep.ReapplyProvision()
                }
            }

            //ignore flagged victims to avoid infinite loops, check for gas index, check if TF_DMG_CUSTOM_BURN and check dmg amount
            else if (GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 1180 && params.damage_stats == 3 && params.damage == 350)
            {
                params.damage = 0
                params.early_out = true
                if (!victim.IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE))
                {
                    // investigate DMG_PLASMA (16777216), damage type when first igniting enemies, 2056 is afterburn

                    // NOTE: TF_DMG_CUSTOM_BURNING is what controls the flamethrower killicon, we remove it to set a custom one
                    // unfortunately it is also used to stop the gas from recharging on itself
                    // setting lifestate to dead right before damage will cause pGenericMeterUser->ShouldUpdateMeter to return false
                    // victim.TakeDamageCustom(__Potato_GasNerf.__gas_inflictor_dummy, attacker, gaswep, Vector(), victim.GetOrigin(), damage_amount, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_BURNING)

                    SetPropInt(attacker, "m_lifeState", 1)
                    victim.TakeDamageEx(__Potato_GasNerf.__gas_inflictor_dummy, attacker, gaswep, Vector(), victim.GetOrigin(), __Potato_GasNerf.__gas_damage_amount, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE)
                    SetPropInt(attacker, "m_lifeState", 0)

                    // flag to avoid infinite TakeDamage loops
                    victim.AddEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE) //EFL_IS_BEING_LIFTED_BY_BARNACLE, dummy EFlag

                    // allow for re-ignite after a delay
                    EntFireByHandle(victim, "runscriptcode", "self.RemoveEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE)", __Potato_GasNerf.__gas_reignite_immune_time, null, null)
                }
            }
            return false
        }
    }
}

//ents must be created and inserted after the class is initialized
for (local dummy; dummy = Entities.FindByName(dummy, "__gas_killicon");)
    EntFireByHandle(dummy, "Kill", "", -1, null, null)

__Potato_GasNerf.__gas_inflictor_dummy <- SpawnEntityFromTable("move_rope", {targetname = "__gas_killicon", classname = "firedeath"})
__CollectGameEventCallbacks(__Potato_GasNerf.Events)