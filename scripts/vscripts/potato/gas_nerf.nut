// Gas Passer nerf for Potato.TF servers.

// TODO: Unnecessary folding of the entire thing. Redefine the few constants/functions we use as locals instead.
// locals would avoid rare conflicts with other scripts (not that people should be redefining non-null constants anyway...)
local CONST = getconsttable()
local ROOT = getroottable()

if (!("HasProp" in ROOT))
    foreach(k, v in ::NetProps.getclass())
        if (k != "IsValid" && !(k in ROOT))
            ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

if (!("ConstantNamingConvention" in ROOT))
{
    foreach(a, b in Constants)
        foreach(k, v in b)
        {
            CONST[k] <- v != null ? v : 0
            ROOT[k]  <- v != null ? v : 0
        }
}
local itemdef_netprop = "m_AttributeManager.m_Item.m_iItemDefinitionIndex"

// TODO: Use consistent formatting with the rest of the mapfixes (extend __potato table and setdelegate for cleaner variable access).
// Classes instantiate faster (not super important) and are the "correct" way to do inheritance.  Unsure if class delegation is different.
// This was designed to be standalone, should the rest of the mapfixes be converted to classes? Any benefits besides init time?
// class GasNerf extends __Potato
class __Potato_GasNerf
{
    __gas_damage_recharge_rate  = 4000.0
    __gas_passive_recharge_rate = 180.0
    // __gas_damage_mult        = ( 90 / 350 ) //used for dmg penalty vs players
    __gas_damage_amount         = 125.0
    __gas_reignite_immune_time  = 5.0
    __damage_range              = Convars.GetFloat("tf_damage_range")

    Events = {

        function OnGameEvent_post_inventory_application(params)
        {
            local player = GetPlayerFromUserID(params.userid)

            if (player.IsFakeClient())
                return

            local scope = player.GetScriptScope()

            if (!scope)
            {
                player.ValidateScriptScope()
                scope = player.GetScriptScope()
            }

            // only check pyro
            if (player.GetPlayerClass() == 7)
            {
                // find gas and phlog in our loadout
                for (local i = 0; i < 7; i++)
                {
                    local wep = GetPropEntityArray(player, "m_hMyWeapons", i)

                    if (wep == null)
                        continue

                    if (GetPropInt(wep, itemdef_netprop) == 1180)
                        scope.gaswep <- wep
                    else if (GetPropInt(wep, itemdef_netprop) == 594)
                        scope.phlogwep <- wep
                }

                // no gas equipped
                if (!("gaswep" in scope))
                    return

                local passive_rate = __Potato_GasNerf.__gas_passive_recharge_rate
                local damage_rate = __Potato_GasNerf.__gas_damage_recharge_rate
                local attrib_damagerate = "item_meter_damage_for_full_charge"
                local attrib_chargerate = "item_meter_charge_rate"

                local gas = scope.gaswep

                //apply rebalance attribs
                if (gas.GetAttribute("explode_on_ignite", 0.0))
                {
                    if (gas.GetAttribute(attrib_damagerate, 0.0) != damage_rate)
                        gas.AddAttribute(attrib_damagerate, damage_rate, -1)

                    if (gas.GetAttribute(attrib_chargerate, 0.0) != passive_rate)
                        gas.AddAttribute(attrib_chargerate, passive_rate, -1)

                    gas.AddAttribute("ragdolls become ash", 1.0, -1)

                    gas.ReapplyProvision()

                    // Start empty on spawn
                    // m_bRegenerating is true when switching loadouts with tf_respawn_on_loadoutchange 1 and touching a resupply cabinet
                    if (!GetPropBool(player, "m_Shared.m_bInUpgradeZone") && !GetPropBool(player, "m_bRegenerating"))
                    {
                        SetPropIntArray(player, "m_iAmmo", 0, 4)
                        SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 0.0, 1)
                    }
                }
                // refunded explode on ignite
                else
                {
                    gas.AddAttribute(attrib_damagerate, 750.0, -1)
                    gas.AddAttribute(attrib_chargerate, 60.0, -1)
                    gas.ReapplyProvision()
                }
            }
        }

        function OnGameEvent_player_team( params )
        {
            local player = GetPlayerFromUserID(params.userid)

            // remove takedamage flag from bots on respawn
            // validity checks are due to rafmod deleting the player reference in player_team or something

            if (player && player.IsValid() && player.IsFakeClient() && player.IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE))
                player.RemoveEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE)
        }

        function OnGameEvent_player_say(params)
        {
            local player = GetPlayerFromUserID(params.userid)

			local valid_chars = {
				[33] = "!",
				[46] = ".",
				[47] = "/",
				[63] = "?",
				[92] = "\\",
			}
            local text = params.text.tolower()

            if (text[0] in valid_chars && text.slice(1) == "gas")
            {
                ClientPrint(player, HUD_PRINTTALK, "\x07F5B111GAS REBALANCE:")
                ClientPrint(player, HUD_PRINTTALK, format("\x01- Damage reduced:\x07F5B111 350\x01 → \x07F5B111%d", __Potato_GasNerf.__gas_damage_amount))
                ClientPrint(player, HUD_PRINTTALK, format("\x01- Damage for full charge:\x07F5B111 750\x01 → \x07F5B111%d", __Potato_GasNerf.__gas_damage_recharge_rate))
                ClientPrint(player, HUD_PRINTTALK, format("\x01- Passive recharge:\x07F5B111 60\x01 → \x07F5B111%d", __Potato_GasNerf.__gas_passive_recharge_rate))
                ClientPrint(player, HUD_PRINTTALK, "\x01- Gas meter\x07F5B111 does not save between lives\x01")
                ClientPrint(player, HUD_PRINTTALK, "\x01- Crit damage\x07F5B111 does not contribute to charge\x01")
                ClientPrint(player, HUD_PRINTTALK, "\x01- Can now be resisted by\x07F5B111 fire resistance")
                ClientPrint(player, HUD_PRINTTALK, "\x01- Explosions\x07F5B111 can not stack\x01")
            }
        }

        // override gas damage completely
        // was originally just going to use "dmg penalty vs players" but it's easier to fix stacking explosions this way and set absolute damage amounts instead of multipliers
        function OnScriptHook_OnTakeDamage( params )
        {
            local weapon = params.weapon
            local attacker = params.attacker
            local victim = params.const_entity

            local attacker_scope = attacker.GetScriptScope()

            // ignore bots and null ents
            if (!attacker || !weapon || !attacker.IsPlayer() || attacker.IsFakeClient()) return

            local gaswep   = "gaswep" in attacker_scope ? attacker_scope.gaswep : null
            local phlogwep = "phlogwep" in attacker_scope ? attacker_scope.phlogwep : null

            if (!gaswep || !gaswep.IsValid() || !gaswep.GetAttribute("explode_on_ignite", 0.0))
                return

            local chargemeter_netprop = "m_Shared.m_flItemChargeMeter"
            local gasmeter = GetPropFloatArray(attacker, chargemeter_netprop, 1)

            if ( attacker_scope && weapon != gaswep )
            {
                // sometimes the meter is full but gas doesn't replenish
                if (gasmeter >= 100.0 && GetPropIntArray(attacker, "m_iAmmo", 4) < 1)
                {
                    SetPropIntArray(attacker, "m_iAmmo", 1, 4)
                    return
                }
                local damage_type = params.damage_type

                // local charge_per_tick = ((Time() + passive_rate) / Time()) / passive_rate

                // bad hack for crit charging, works but we should modify the meter directly instead
                // was skill issuing before by ignoring the charge rate upgrade value I think
                // according to the code, formula is: current meter + ( (damage / ( damage to charge * charge rate upgrade value ) ) * 100.0 )
                local damage_rate = __Potato_GasNerf.__gas_damage_recharge_rate
                if (damage_type & DMG_ACID)
                {
                    local damage_mult = 1.0
                    local attacker_weapon = attacker.GetActiveWeapon()

                    // handle damage range calculations for the dragons fury so crit build time is consistent with non-crits
                    if (attacker_weapon && attacker_weapon.GetClassname() == "tf_weapon_rocketlauncher_fireball")
                    {
                        local damage_range = __Potato_GasNerf.__damage_range
                        local distance = (victim.GetCenter() - attacker.GetCenter()).Length()
                        local optimal_distance = 512
                        local center = distance / optimal_distance

                        center = center > 2.5 ? 2.5 : center < 0.5 ? 0.5 : center

                        damage_mult = (1.0 - (center * damage_range)) + damage_range
                        damage_mult = damage_mult < 0.5 ? 0.5 : damage_mult > 1.2 ? 1.2 : damage_mult
                    }
                    gaswep.RemoveAttribute("item_meter_damage_for_full_charge")
                    gaswep.AddAttribute("item_meter_damage_for_full_charge", (damage_rate * (3 / damage_mult)), -1)
                    gaswep.ReapplyProvision()
                }
                else if (!(damage_type & DMG_ACID) && gaswep.GetAttribute("item_meter_damage_for_full_charge", 0.0) != damage_rate)
                {
                    gaswep.RemoveAttribute("item_meter_damage_for_full_charge")
                    gaswep.AddAttribute("item_meter_damage_for_full_charge", damage_rate, -1)
                    gaswep.ReapplyProvision()
                }
            }

            // ignore flagged victims to avoid infinite loops, check for gas index, check if TF_DMG_CUSTOM_BURN and check dmg amount
            else if (params.damage_stats == TF_DMG_CUSTOM_BURNING && params.damage == 350 && GetPropInt(weapon, itemdef_netprop) == 1180)
            {
                params.damage = 0
                params.early_out = true
                if (!victim.IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE))
                {
                    // investigate DMG_PLASMA (16777216), damage type when first igniting enemies, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE is afterburn

                    // NOTE: TF_DMG_CUSTOM_BURNING is what controls the flamethrower killicon, we remove it to set a custom one
                    // unfortunately it is also used to stop the gas from recharging on itself
                    // setting lifestate to dead right before damage will cause pGenericMeterUser->ShouldUpdateMeter to return false
                    // victim.TakeDamageCustom(__Potato_GasNerf.__gas_inflictor_dummy, attacker, gaswep, Vector(), victim.GetOrigin(), damage_amount, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_BURNING)

                    local gas_killicon = __Potato_GasNerf.__gas_inflictor_dummy

                    gas_killicon.KeyValueFromString("classname", "firedeath")

                    // don't charge phlog
                    if (phlogwep && phlogwep.IsValid())
                        phlogwep.AddAttribute("mod soldier buff type", 4.0, -1)

                    // non-alive lifestate fixes self-recharging when not using TF_DMG_CUSTOM_BURNING
                    SetPropInt(attacker, "m_lifeState", 1)
                    victim.TakeDamageEx(gas_killicon, attacker, gaswep, Vector(), victim.GetOrigin(), __Potato_GasNerf.__gas_damage_amount, DMG_BURN|DMG_PREVENT_PHYSICS_FORCE)
                    SetPropInt(attacker, "m_lifeState", 0)
                    // set it back or else it'll get cleaned up, preserved ents use classname checks
                    gas_killicon.KeyValueFromString("classname", "move_rope")

                    if (phlogwep && phlogwep.IsValid())
                        phlogwep.AddAttribute("mod soldier buff type", 5.0, -1)

                    // flag to avoid infinite TakeDamage loops
                    victim.AddEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE)

                    // allow for re-ignite after a delay
                    EntFireByHandle(victim, "runscriptcode", "self.RemoveEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE)", __Potato_GasNerf.__gas_reignite_immune_time, null, null)
                }
            }
            return false
        }
    }
}

__CollectGameEventCallbacks(__Potato_GasNerf.Events)

//ents must be created and inserted after the class is initialized
for (local dummy; dummy = Entities.FindByName(dummy, "__gas_killicon");)
    EntFireByHandle(dummy, "Kill", "", -1, null, null)

__Potato_GasNerf.__gas_inflictor_dummy <- SpawnEntityFromTable("move_rope", {targetname = "__gas_killicon"})
