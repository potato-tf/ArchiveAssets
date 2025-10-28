AddEventCallback("player_hurt", function(eventTable)
    --PrintTable(eventTable)
    
        local attacker = ents.GetPlayerByUserId(eventTable.attacker)
        
        if not attacker then
            --print("gave up")
            return
        end
        
        local victim = ents.GetPlayerByUserId(eventTable.userid)
        
        local primary = attacker:GetPlayerItemBySlot(0)

    if not primary then
    return
    end
if eventTable.bonuseffect == 2.0 and primary:GetAttributeValue("tool needs giftwrap", true) == 1 then
        --print("That was a donk")
        
        --print(victim)
        --print(attacker)
        --print(primary)
        
        local sufferingDamage = 180 * primary:GetAttributeValueByClass("mult_dmg", 1)
        
        timer.Simple(0.05, function()
            if victim:IsAlive() == true then
            
                local sufferingTable = {
                    Attacker = attacker, -- Attacker
                    Inflictor = nil, -- Direct cause of damage, usually a projectile
                    Weapon = nil,
                    Damage = sufferingDamage,
                    DamageType = nil, -- Damage type, see DMG_* globals. Can be combined with | operator
                    DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
                    CritType = 0, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
                    DamagePosition = nil, -- Where the target was hit at
                    DamageForce = nil, -- Knockback force of the attack
                    ReportedPosition = nil -- Where the attacker attacked from
                }
                victim:TakeDamage(sufferingTable)
                
            end
        end)
        return
    end
end)