
--Dear god... this is gonna be whack.
--//////////////////////////////////////////////////////////////////////////////////////////////
--===========CosCo The Rocket Drone========= Rest In Peace...s
--///////////////VARIABLES//////////////////
PT_list = 0
--=============Heavy Reinforcement===============
--//////
function self_destruct(_, activator)
    local ent = ents.FindByName("hitdetection")

    activator:AddCallback(ON_DEATH, function()

    end)
end
--=============[THE POWER-PLAYER]===============
--//////
function disableCanteens(_, activator)
    activator:AcceptInput("$AddPlayerAttribute", "fire input on hit|popscript^$powerAttack")
    activator:AcceptInput("$AddPlayerAttribute", "gesture speed increase|2.5")
    activator:AcceptInput("$AddPlayerAttribute", "fire input on taunt|popscript^$tauntPowerUp")
    --///////////////////
    activator:AcceptInput("$AddItemAttribute", "Construction rate increased|2|2")
    activator:AcceptInput("$AddItemAttribute", "powerup max charges|0|9")
end

function pointsChecker(_, activator)
        if activator.poweringScale < 5 then
            activator.powerState = 5

            activator.powerID:AddOutput("message [No Power] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            activator.powerID:AcceptInput("Display",_, activator)

        elseif activator.poweringScale < 10 then
            activator.powerState = 10

            activator.powerID:AddOutput("message [Minicrits + Sentry Burst Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            activator.powerID:AddOutput("color 0 128 0")
            activator.powerID:AcceptInput("Display",_, activator)
            activator.power = 1

        elseif activator.poweringScale < 30 then
            activator.powerState = 30

            activator.powerID:AddOutput("message [+Crits +Speed Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            activator.powerID:AddOutput("color 255 255 0")
            activator.powerID:AcceptInput("Display",_, activator)
            activator.power = 2

        elseif activator.poweringScale >= 30 then

            activator.powerID:AddOutput("message [POWER-PLAY Ready] 30/30")
            activator.powerID:AddOutput("color 255 0 0")
            activator.powerID:AcceptInput("Display",_, activator)
            activator.power = 3
        end
end

function sentry_Detection(_, activator) 
    if not activator.alreadyLvl2 then
        --or "obj_dispenser" or "obj_telepoter" <== buggy.

        if activator:GetClassname() == "obj_sentrygun" then
            activator:AddOutput("$OnShootBullet popscript:$sentryPowerAttack::0:-1")
            activator:AddOutput("$OnShootRocket popscript:$sentryRocketAttack::0:-1")
        end

        if activator:GetClassname() == "obj_sentrygun" or activator:GetClassname() == "obj_dispenser" or activator:GetClassname() == "obj_teleporter" then
            if activator.m_iHighestUpgradeLevel < 3 then

                activator.m_iHighestUpgradeLevel = 2
                activator.alreadyLvl2 = 1

                -- activator.m_hBuilder:AcceptInput("$DisplayTextChat", "{green}Synchronized!")
                -- if activator:GetClassname() == "obj_dispenser" then

                --     timer.Simple(0.05, function()
                --         activator:Activate()
                --     end)
                -- end
            elseif activator.m_iHighestUpgradeLevel == 3 then
                activator.m_iHighestUpgradeLevel = 3
                activator.alreadyLvl2 = 1
                -- activator.m_hBuilder:AcceptInput("$DisplayTextChat", "{green}Synchronized!")
            end
        end
    else
        activator.alreadyLvl2 = 1
    end
end

function powerhouseAction(_, activator)
    activator.poweringScale = 0
    activator.power = 0
    activator.powerState = 5
    activator.empowered = 0
    local powerID = "power"..(PT_list)
    PT_list = PT_list + 1

    ents.CreateWithKeys("game_text", {
        targetname = powerID,
        -- spawnflags = 1,
        holdtime = 99999,
        color = "255 0 0",
        message = "[No Power] 0/5",
        channel = 1,
        y = 0.65,
        x = -1,
    })
    local powerAction = ents.FindByName(tostring(powerID))
    activator.powerID = powerAction

    activator.IsDead = 0
    -- util.PrintToChatAll(activator.powerID)
    activator.powerID:AcceptInput("Display",_, activator)

    --Remove
    activator:AddCallback(ON_DEATH, function()
        activator.powerID:Remove()
        activator.poweringScale = 0
        activator.IsDead = 1
    end)
    activator:AddCallback(ON_REMOVE, function()
        activator.powerID:Remove()
        activator.poweringScale = 0
    end)
    --
end
function powerAttack(_, activator, caller)
    -- print(caller:GetPlayerName())
    -- print(activator:GetPlayerName())

    if not caller:IsAlive() then
        activator.poweringScale = activator.poweringScale + 1

        pointsChecker(_, activator)

        -- timer.Create(0.02, function()
        --     if activator.IsDead == 1 then
        --         return false
        --     end

        --     if activator.poweringScale < 5 then
        --         activator.powerState = 5

        --         activator.powerID:AddOutput("message [No Power] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AcceptInput("Display",_, activator)

        --     elseif activator.poweringScale < 10 then
        --         activator.powerState = 10

        --         activator.powerID:AddOutput("message [Minicrits + Sentry Burst Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AddOutput("color 0 128 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 1

        --     elseif activator.poweringScale < 30 then
        --         activator.powerState = 30

        --         activator.powerID:AddOutput("message [+Crits +Speed Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AddOutput("color 255 255 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 2

        --     elseif activator.poweringScale >= 30 then

        --         activator.powerID:AddOutput("message [POWER-PLAY Ready] 30/30")
        --         activator.powerID:AddOutput("color 255 0 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 3
        --     end

        -- end, 0) 
    end
end
function sentryPowerAttack(_, activator)
    local owner = activator.m_hBuilder

    if not activator.m_hEnemy:IsAlive() then
        owner.poweringScale = owner.poweringScale + 1

        pointsChecker(_, owner)

        -- timer.Create(0.02, function()
        --     if activator.IsDead == 1 then
        --         return false
        --     end

        --     if activator.poweringScale < 5 then
        --         activator.powerState = 5

        --         activator.powerID:AddOutput("message [No Power] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AcceptInput("Display",_, activator)

        --     elseif activator.poweringScale < 10 then
        --         activator.powerState = 10

        --         activator.powerID:AddOutput("message [Minicrits + Sentry Burst Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AddOutput("color 0 128 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 1

        --     elseif activator.poweringScale < 30 then
        --         activator.powerState = 30

        --         activator.powerID:AddOutput("message [+Crits +Speed Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
        --         activator.powerID:AddOutput("color 255 255 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 2

        --     elseif activator.poweringScale >= 30 then

        --         activator.powerID:AddOutput("message [POWER-PLAY Ready] 30/30")
        --         activator.powerID:AddOutput("color 255 0 0")
        --         activator.powerID:AcceptInput("Display",_, activator)
        --         activator.power = 3
        --     end

        -- end, 0)
    end
end
function sentryRocketAttack(_, activator) --<This Stinks but i have to do this.
    local owner = activator.m_hOwnerEntity.m_hBuilder

    activator:AddCallback(ON_REMOVE, function()
        if not activator.m_hOwnerEntity.m_hEnemy:IsAlive() then

            owner.poweringScale = owner.poweringScale + 1
            -- timer.Create(0.02, function()
            --     if activator.IsDead == 1 then
            --         return false
            --     end
    
            --     if activator.poweringScale < 5 then
            --         activator.powerState = 5
    
            --         activator.powerID:AddOutput("message [No Power] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            --         activator.powerID:AcceptInput("Display",_, activator)
    
            --     elseif activator.poweringScale < 10 then
            --         activator.powerState = 10
    
            --         activator.powerID:AddOutput("message [Minicrits + Sentry Burst Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            --         activator.powerID:AddOutput("color 0 128 0")
            --         activator.powerID:AcceptInput("Display",_, activator)
            --         activator.power = 1
    
            --     elseif activator.poweringScale < 30 then
            --         activator.powerState = 30
    
            --         activator.powerID:AddOutput("message [+Crits +Speed Ready] "..tostring(activator.poweringScale).."/"..tostring(activator.powerState))
            --         activator.powerID:AddOutput("color 255 255 0")
            --         activator.powerID:AcceptInput("Display",_, activator)
            --         activator.power = 2
    
            --     elseif activator.poweringScale >= 30 then
    
            --         activator.powerID:AddOutput("message [POWER-PLAY Ready] 30/30")
            --         activator.powerID:AddOutput("color 255 0 0")
            --         activator.powerID:AcceptInput("Display",_, activator)
            --         activator.power = 3
            --     end
    
            -- end, 0)
        end
    end)
end
--/////////
function tauntPowerUp(_, activator)
--Time To Be Strong
    if activator.empowered == 0 then
        if activator.power == 0 then
            -- print("not enough power")
            
        elseif activator.power == 1 then --<== Tier 1
            -- activator:AcceptInput("$PlaySoundToSelf", "weapons/vaccinator_heal.wav")
            activator:AcceptInput("$PlaySoundToSelf","vo/engineer_autocappedintelligence01.mp3")
            activator:AcceptInput("$DisplayTextChat","{yellow}SENTRY OVER-DRIVE")

            activator:AddCond(52, 3.2)
            --///////////////////////
            activator:AddCond(19, 8)

            activator:SetAttributeValue("engy sentry fire rate increased", 0.70)

            activator.powerID:AddOutput("color 255 0 0")
            activator.poweringScale = activator.poweringScale - 5
            activator.power = 0
            activator.empowered = 1
            activator.powerState = 5

            pointsChecker(_, activator)

            timer.Simple(8, function()
                activator.empowered = 0
                activator:AcceptInput("$PlaySoundToSelf", "weapons/sentry_damage2.wav")
                activator:SetAttributeValue("engy sentry fire rate increased", 3.60)
                activator:AcceptInput("$DisplayTextChat","{red}SENTRY OVERHEATING - COOLING DOWN")
                timer.Simple(4, function()
                    activator:SetAttributeValue("engy sentry fire rate increased", nil)
                end)
            end)

        elseif activator.power == 2 then --<== Tier 2
            activator:AcceptInput("$PlaySoundToSelf", "misc/halloween/spell_lightning_ball_impact.wav")
            activator:AcceptInput("$PlaySoundToSelf","vo/engineer_battlecry07.mp3")
            activator:AcceptInput("$DisplayTextChat","{yellow}SENTRY OVER-DRIVE")
            
            activator:AddCond(52, 3.2)
            --///////////////////////
            activator:AddCond(56, 11) 
            activator:AddCond(32, 11)

            activator.powerID:AddOutput("color 255 0 0")
            activator.poweringScale = activator.poweringScale - 10
            activator.power = 0
            activator.empowered = 1
            activator.powerState = 5

            pointsChecker(_, activator)

            activator:SetAttributeValue("engy sentry fire rate increased", 0.70)

            timer.Simple(10, function()
                activator.empowered = 0
                activator:AcceptInput("$PlaySoundToSelf", "weapons/sentry_damage2.wav")
                activator:SetAttributeValue("engy sentry fire rate increased", 3.60)
                activator:AcceptInput("$DisplayTextChat","{red}SENTRY OVERHEATING - COOLING DOWN")
                timer.Simple(4, function()
                    activator:SetAttributeValue("engy sentry fire rate increased", nil)
                end)
            end)
        elseif activator.power == 3 then --<== Tier 3
            activator:AcceptInput("$PlaySoundToSelf", "misc/halloween/spell_overheal.wav")
            activator:AcceptInput("$PlaySoundToSelf", "vo/engineer_sf13_influx_big01.mp3")

            activator:AcceptInput("$DisplayTextChat","{YELLOW}SUPER SENTRY MODE")

            activator:AddCond(57, 9)
            activator:AddCond(109, 23)
            activator:AddCond(55, 5.2)
            --///////////////////////
            activator:AddCond(26, 23)
            activator:AddCond(16, 23)
            activator:AddCond(32, 23)

            activator.powerID:AddOutput("color 255 0 0")
            activator.poweringScale = 0
            activator.power = 0
            activator.empowered = 1
            activator.powerState = 5

            pointsChecker(_, activator)

            activator:SetAttributeValue("engy sentry fire rate increased", 0.45)
            
            timer.Simple(23, function()
                activator.empowered = 0
                activator:SetAttributeValue("engy sentry fire rate increased", nil)
            end)
        end
    end
end
--////////////////////////////////////////////////
--=============[THE BROKEN OATH]===============
--//////
function setVariablesMedic(_, activator)

    gaugeID = "guage"..tostring(PT_list)
    infoID = "info"..tostring(PT_list)
    activator.damageMeter = 0
    activator.powerTier = 0
    activator.powerDescription = 0
    activator.Uber = 0

    ents.CreateWithKeys("game_text", {
        targetname = gaugeID,
        -- spawnflags = 1,
        holdtime = 99999,
        color = "255 0 0",
        message = "▱▱▱",
        channel = 1,
        y = 0.55,
        x = -1,
    })
    ents.CreateWithKeys("game_text", {
        targetname = infoID,
        -- spawnflags = 1,
        holdtime = 99999,
        color = "255 0 0",
        message = "0/200 [No Passives]",
        channel = 2,
        y = 0.58,
        x = -1,
    })

    local gaugetxt = ents.FindByName(tostring(gaugeID))
    local info = ents.FindByName(tostring(infoID))

    activator.gauge = gaugetxt
    activator.textDescriptor = info

    activator.gauge:AcceptInput("Display",_, activator)
    activator.textDescriptor:AcceptInput("Display",_, activator)

    activator:AddCallback(ON_DEATH, function()

        activator.gauge:Remove()
        activator.textDescriptor:Remove()
    end)
    activator:AddCallback(ON_REMOVE, function()

        activator.gauge:Remove()
        activator.textDescriptor:Remove()
    end)

    PT_list = PT_list + 1
end

function brokenAttack(damage, activator)
	local medigun = activator:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY)
    activator.damageMeter = activator.damageMeter + damage

    function OnGameTick()
        if activator:InCond(57) and activator:GetConditionProvider(57) == activator then
            -- print("ubered. Not Getting Points")
            activator.damageMeter = 0
        end
    end

    if activator.damageMeter < 200 then

        activator.gauge:AddOutput("message ▱▱▱")
        activator.gauge:AddOutput("color 255 0 0")
        activator.gauge:AcceptInput("Display", _,activator)
        activator.textDescriptor:AddOutput("message "..tostring(activator.damageMeter).."/200 [No Passives]")
        activator.textDescriptor:AcceptInput("Display", _,activator)


        medigun:SetAttributeValue("hidden maxhealth non buffed", nil)
        medigun:SetAttributeValue("mark for death", nil)
        medigun:SetAttributeValue("effect cond override", nil)
        medigun:SetAttributeValue("Set DamageType Ignite", nil)
        activator:RemoveCond(32)
        activator:RemoveCond(46)

        activator.powerTier = 0
        activator.Uber = 1

        -- RemoveEventCallback(UberEvent)
        
    elseif activator.damageMeter < 1000 then

        activator.gauge:AddOutput("message ▰▱▱")
        activator.gauge:AddOutput("color 0 128 0")
        activator.gauge:AcceptInput("Display", _,activator)
        activator.textDescriptor:AddOutput("message "..tostring(activator.damageMeter).."/1000 [+25 HP +Speed]")
        activator.textDescriptor:AddOutput("color 0 128 0")
        activator.textDescriptor:AcceptInput("Display", _,activator)

        medigun:SetAttributeValue("hidden maxhealth non buffed", 25)
        activator:AddCond(32, -1)

        activator.powerTier = 1
    elseif activator.damageMeter < 2000 then

        activator.gauge:AddOutput("message ▰▰▱")
        activator.gauge:AddOutput("color 255 255 0")
        activator.gauge:AcceptInput("Display", _,activator)
        activator.textDescriptor:AddOutput("message "..tostring(activator.damageMeter).."/2000 [+50 HP +Mark]")
        activator.textDescriptor:AddOutput("color 255 255 0")
        activator.textDescriptor:AcceptInput("Display", _,activator)

        medigun:SetAttributeValue("hidden maxhealth non buffed", 50)
        activator:AddCond(32, -1)
        activator:AddCond(46, -1)
        medigun:SetAttributeValue("mark for death", 1)

        activator.powerTier = 2
    elseif activator.damageMeter >= 2000 then

        activator.gauge:AddOutput("message ▰▰▰")
        activator.gauge:AddOutput("color 255 0 0")
        activator.gauge:AcceptInput("Display", _,activator)
        activator.textDescriptor:AddOutput("message 2000/2000 [Uber| Break The Oath]")
        activator.textDescriptor:AddOutput("color 255 0 0")
        activator.textDescriptor:AcceptInput("Display", _,activator)
        activator.Uber = 0
        medigun:SetAttributeValue("effect cond override", 8505)
        medigun:SetAttributeValue("Set DamageType Ignite", 3)

        -- local UberEvent = AddEventCallback("player_chargedeployed", function(eventTable)
        --     -- PrintTable(eventTable)
        --     local uber = ents.GetPlayerByUserId(eventTable.userid)
        --     -- util.PrintToChatAll(uber)
        --     if uber.Uber == 0 then
        --         -- uber:AcceptInput("$PlaySoundToSelf", "vo/medic_sf13_influx_big02.mp3")
        --         -- uber:AcceptInput("$PlaySoundToSelf", "misc/halloween/spell_overheal.wav")
        --         uber.damageMeter = 0
        --         uber.gauge:AddOutput("message ▱▱▱") 
        --         uber.gauge:AddOutput("color 255 0 0")
        --         uber.gauge:AcceptInput("Display", _,uber)
        --         uber.textDescriptor:AddOutput("message "..tostring(uber.damageMeter).."/200 [No Passives]")
        --         uber.textDescriptor:AcceptInput("Display", _,uber)

        --         uber.Uber = 1
        --     else
        --         print("already ubered")
        --     end
        --     return ACTION_MODIFIED 
        -- end)

        -- function OnGameTick()
        --     if activator.m_bChargeRelease == 1 then
        --         print("pernis")

        --         -- activator.damageMeter = 0
        --         -- activator.gauge:AddOutput("message ▱▱▱") 
        --         -- activator.gauge:AddOutput("color 255 0 0")
        --         -- activator.gauge:AcceptInput("Display", _,activator)
        --         -- activator.textDescriptor:AddOutput("message "..tostring(activator.damageMeter).."/200 [No Passives]")
        --         -- activator.textDescriptor:AcceptInput("Display", _,activator)

        --         -- activator.Uber = 1                
        --     end
        -- end
    end
end

--////////////////////////////////////////////////
--=============[THE BLAST-BASH DASH-BACK]===============
--//////
function demoShieldVariables(_, activator)
    activator.dashCount = 3
    activator.revertCount = 0


    -- activator:AcceptInput("$AddItemAttribute", "passive reload|1|0")
    -- activator.revertCountMelee = 0
    
    if activator.req ~= 1 then
        activator:AcceptInput("$DisplayTextChat", "{red}If you dont see UI of 3 green bars. Please re-equip the weapon")

        local blastDamage = "bashDamage"..tostring(PT_list)
        local blastParticle = "bashFX"..tostring(PT_list)
        local flingBack = "fling"..tostring(PT_list)
        local targetinfo = "targetFling"..tostring(PT_list)
        local meter = "meter"..tostring(PT_list)

        activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeter|0")
        activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeterMelee|2")
  
        ents.CreateWithKeys("trigger_hurt", {
            targetname = blastDamage,
            spawnflags = 1,

            damagetype = 64,
            damage = 300,
            filtername = "blurobots",
            startdisabled = 1,
        })
        ents.CreateWithKeys("info_particle_system", {
            targetname = blastParticle,

            effect_name = "ExplosionCore_MidAir",
            startdisabled = 1,
        })
        --////////////////////////////////////////
        ents.CreateWithKeys("info_target", {
            targetname = targetinfo, 
            ["$fakeparentoffset"] = "-60 0 65",
        })
        ents.CreateWithKeys("trigger_catapult", {
            targetname = flingBack,

            LaunchTarget = targetinfo,
            spawnflags = 1,
            playerSpeed = 600,
            startdisabled = 1,

        })
        ents.CreateWithKeys("game_text", {
            targetname = meter,
            -- spawnflags = 1,
            holdtime = 99999,
            color = "0 255 0",
            message = "▰▰▰",
            channel = 1,
            y = 0.52,
            x = -1,
        })

        activator.bd = ents.FindByName(blastDamage)
        activator.bp = ents.FindByName(blastParticle)
        activator.fb = ents.FindByName(flingBack)
        activator.targetinfo = ents.FindByName(targetinfo)
        activator.meter = ents.FindByName(meter)

        activator.bd:SetSolid(2)
        activator.bd:AddOutput("mins -100 -100 -100")
        activator.bd:AddOutput("maxs 100 100 100")
        activator.bd:AcceptInput("SetOwner", activator)

        activator.fb:SetSolid(2)
        activator.fb:AddOutput("mins -10 -10 -10")
        activator.fb:AddOutput("maxs 10 10 10")
        -- activator.fb:AddOutput("LaunchTarget "..tostring(activator.targetinfo:GetName()))

        activator.bd:SetFakeParent(activator)
        activator.bp:SetFakeParent(activator)
        activator.fb:SetFakeParent(activator)
        activator.targetinfo:SetFakeParent(activator)

        activator.meter:AcceptInput("Display", _, activator)

        timer.Create(30, function()
            if activator.dashCount < 1 then
                activator.dashCount = 1

                if activator.dashCount == 1 then
                    activator.meter:AddOutput("message  ▰▱▱")
                    activator.meter:AddOutput("color 0 255 0")
                    activator.meter:AcceptInput("Display", _, activator)
                end
            end
        end, 0)

        activator:AddCallback(ON_DEATH, function()
            activator.bd:Remove()
            activator.bp:Remove()
            activator.fb:Remove()
            activator.meter:Remove()
            activator.targetinfo:Remove()

            activator.req = 0
            activator:RemoveAllCallbacks(ON_DEATH)
            -- util.PrintToChatAll("penis")
        end)
        -- activator:AddCallback(ON_SPAWN, function()
        --     activator.bd:Remove()
        --     activator.bp:Remove()
        --     activator.fb:Remove()
        --     activator.meter:Remove()
        --     activator.targetinfo:Remove()

        --     activator.req = 0
        --     -- util.PrintToChatAll(activator.req)
        -- end)

        PT_list = PT_list + 1
        activator.req = 1
    else
        activator.req = 0
    end
end

function blastBash(_, activator)
    -- util.PrintToChatAll(activator.bd)
    -- util.PrintToChatAll(activator.fb)
    -- util.PrintToChatAll(activator.dashCount)
    -- util.PrintToChatAll(activator.bd:GetAbsOrigin())
    -- util.PrintToChatAll(activator.fb:GetAbsOrigin())
    -- util.PrintToChatAll(activator.dashCount)

    local checkNetProps = activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)
    
    if checkNetProps:GetItemName() == "TF_WEAPON_GRENADELAUNCHER" or "The Iron Bomber" or "The Loose Cannon" or "The Loch-n-Load"  then
        if checkNetProps:GetAttributeValue("clip size upgrade atomic", true) ~= nil then
        activator.refillClip = (4 + (checkNetProps:GetAttributeValue("clip size upgrade atomic", true)))
        else
            activator.refillClip = 4
        end
    end

    activator.bd:AcceptInput("Enable")
        activator.bp:AcceptInput("Start")
        activator.fb:AcceptInput("Enable")

        timer.Simple(0.2, function()
            activator.bd:AcceptInput("Disable")
            activator.bp:AcceptInput("Stop") 
            activator.fb:AcceptInput("Disable")
        end)

    if activator.dashCount == 3 then
        activator.meter:AddOutput("message  ▰▰▱")
        activator.meter:AcceptInput("Display", _, activator)

        activator:SetAttributeValue("charge recharge rate increased", 999)
        activator:SetAttributeValue("faster reload rate", 0.05)
        checkNetProps.m_iClip1 = activator.refillClip
        
        activator:AddCond(32, 2)
        activator:AddCond(57, 1.5)
        activator:AddHealth(50, true)
        -- activator:AcceptInput("$RemoveItemAttribute", "Fire Input On Kill|0")
        -- activator:AcceptInput("$RemoveItemAttribute", "Fire Input On Kill|2")
        timer.Simple(1.2, function()
            activator:SetAttributeValue("charge recharge rate increased", nil)
            activator:SetAttributeValue("faster reload rate", nil)
        end)
    elseif activator.dashCount == 2 then
        activator.meter:AddOutput("message  ▰▱▱")
        activator.meter:AcceptInput("Display", _, activator)

        activator:SetAttributeValue("charge recharge rate increased", 999)
        activator:SetAttributeValue("faster reload rate", 0.05)
        checkNetProps.m_iClip1 = activator.refillClip
        
        activator:AddCond(32, 2)
        activator:AddCond(57, 1.5)
        activator:AddHealth(50, true)
        timer.Simple(1.2, function()
            activator:SetAttributeValue("charge recharge rate increased", nil)
            activator:SetAttributeValue("faster reload rate", nil) 
        end)

    elseif activator.dashCount == 1 then
        activator.meter:AddOutput("message  ▱▱▱")
        activator.meter:AddOutput("color 255 0 0")
        activator.meter:AcceptInput("Display", _, activator)

        activator:SetAttributeValue("charge recharge rate increased", 999)
        activator:SetAttributeValue("faster reload rate", 0.05) 
        checkNetProps.m_iClip1 = activator.refillClip
        
        activator:AddCond(32, 2)
        activator:AddCond(57, 1.5)
        timer.Simple(1.2, function()
            activator:SetAttributeValue("charge recharge rate increased", nil)
            activator:SetAttributeValue("faster reload rate", nil)
        end)
        activator.dashCount = 0
        
    elseif activator.dashCount == 0 then
        activator:SetAttributeValue("charge recharge rate increased", nil)
        -- activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeter|0")
        -- activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeterMelee|2")
    else
        activator:SetAttributeValue("charge recharge rate increased", nil)
        -- activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeter|0")
        -- activator:AcceptInput("$AddItemAttribute", "Fire Input On Kill|popscript^$fillUpMeterMelee|2")
    end

    if activator.dashCount ~= 0 then
        activator.dashCount = activator.dashCount - 1
    else
        activator.dashCount = 0
    end
end

function fillUpMeter(_, activator, caller)

    if activator.dashCount ~= 3 then

        if not caller:IsAlive() then
            activator.revertCount = activator.revertCount + 1
        end

        if activator.revertCount >= 6 then
            activator.dashCount = activator.dashCount + 1

            if activator.dashCount == 1 then
                activator.meter:AddOutput("message  ▰▱▱")
                activator.meter:AddOutput("color 0 255 0")
                activator.meter:AcceptInput("Display", _, activator)

            elseif activator.dashCount == 2 then
                activator.meter:AddOutput("message  ▰▰▱")
                activator.meter:AcceptInput("Display", _, activator)

            elseif activator.dashCount == 3 then
                activator.meter:AddOutput("message  ▰▰▰")
                activator.meter:AcceptInput("Display", _, activator)    
            end

            activator.revertCount = 0
        end
    end
end
function fillUpMeterMelee(_, activator, caller)
    -- util.PrintToChatAll("shing")

    if activator.dashCount ~= 3 then

        if not caller:IsAlive() then
            activator.revertCount = activator.revertCount + 2
            -- util.PrintToChatAll(activator.revertCountMelee)
        end

        if activator.revertCount >= 6 then
            activator.dashCount = activator.dashCount + 1

            if activator.dashCount == 1 then
                activator.meter:AddOutput("message  ▰▱▱")
                activator.meter:AddOutput("color 0 255 0")
                activator.meter:AcceptInput("Display", _, activator)

            elseif activator.dashCount == 2 then
                activator.meter:AddOutput("message  ▰▰▱")
                activator.meter:AcceptInput("Display", _, activator)

            elseif activator.dashCount == 3 then
                activator.meter:AddOutput("message  ▰▰▰")
                activator.meter:AcceptInput("Display", _, activator)    
            end

            activator.revertCount = 0
        end
    end
end
--////////////////////////////////////////////////
--=============[THE DOPPELSAPPER]===============
--//////
function spyVariables(_, activator)
    activator.alreadytriggered = 0
    activator.killConfirmed = 0
    activator.copyTarget = nil
    activator.hasDied = 0
    activator.copyItems = {}
end
function sapperCopy(_, activator, caller)

    local classCheck = caller.m_iClass
    local targetHealth = caller.m_iHealth
    local isCrit = 0
    activator.hasDied = 0

    if caller:InCond(34) then
        isCrit = 1
    end
    if classCheck ~= 8 then
        if classCheck ~= 9 then

            if activator.alreadytriggered ~= 1 then
                activator.alreadytriggered = 1

                activator.copyItems = caller:GetAllItems()
                activator.copyTarget = caller

                activator:AcceptInput("$DisplayTextChat", "{yellow}Marked!")
                activator:AddCallback(ON_DEATH, function()
            
                    activator:RemoveAllCallbacks(ON_DEATH)
                    caller:RemoveAllCallbacks(ON_DEATH)
                end)

        -------------------------------------------------------------------------------------
                caller:AddCallback(ON_DEATH, function()
                    activator:RemoveAllCallbacks(ON_DEATH)

                    timer.Simple(0.22, function()
                        activator:AddCallback(ON_DEATH, function()
                            -- activator:AcceptInput("$DisplayTextChat", "{red}Dead. Returning Back To Spy")
                            activator.hasDied = 1
                            -- util.PrintToChatAll(activator.hasDied)
                            activator:SwitchClass(8)
    
                            -- activator:AcceptInput("$DisplayTextChat", "{Red} Target Was Not Killed")
                            activator.alreadytriggered = 0
                            activator.copyItems = nil
                            activator.copyTarget = nil
                            isCrit = 0

                            timer.Stop(activator.id1)
                            timer.Stop(activator.id2)
    
                            activator:RemoveAllCallbacks(ON_DEATH)
                        end)
                    end)
        ---------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------

                    -- caller:RemoveAllCallbacks(ON_DEATH)

                    activator:AcceptInput("$DisplayTextChat", "{yellow}You Are Now {blue}"..tostring(caller:GetPlayerName()))
                    activator.killConfirmed = 1
                    activator.alreadytriggered = 0
                    activator:SwitchClassInPlace(caller.m_iClass)

                    timer.Simple(0.22, function()
                        for i, items in pairs(activator.copyItems) do
                        activator:GiveItem(activator.copyItems[i]:GetItemName(), activator.copyItems[i]:GetAllAttributeValues())
                        end
                    end)

                    activator:AcceptInput("SetCustomModelWithClassAnimations", tostring(caller.m_ModelName))

                    timer.Simple(0.1, function()
                        if caller.m_bIsMiniBoss == 1 then
                            activator.m_flModelScale = 1.4

                            activator:AddHealth(1750, true)

                            activator:SetAttributeValue("SET BONUS: move speed set bonus", 1)
                            activator:SetAttributeValue("dmg from ranged reduced", 0.70)
                            activator:SetAttributeValue("hidden primary max ammo bonus", 1.80) 
                            activator:SetAttributeValue("override footstep sound set", 6)
                            activator:SetAttributeValue("heal rate bonus", 5)
                            activator.m_bIsMiniBoss = 1
                        else
                            activator:AddHealth(200, true)
                            activator:SetAttributeValue("dmg from ranged reduced", 0.70)
                            activator:SetAttributeValue("heal rate bonus", 2.5)
                            activator:SetAttributeValue("ubercharge rate bonus", 1.50)
                            -- activator.m_flModelScale = caller.activator.m_flModelScale 
                        end

                        if isCrit == 1 then
                            activator:AddCond(16, 99)
                        end
                    end)

        warn = timer.Simple(10, function()
                        activator:AcceptInput("$DisplayTextChat", "{yellow}Reverting Back To Spy In 5 Seconds...")
                        -- activator:AcceptInput("$PlaySoundToSelf", "ui/cyoa_node_activate.wav")
                    end)

        revert = timer.Simple(20, function()

                        activator:SetAttributeValue("SET BONUS: move speed set bonus", nil)
                        activator:SetAttributeValue("hidden primary max ammo bonus", nil)
                        activator:SetAttributeValue("dmg from ranged reduced", nil)
                        activator:SetAttributeValue("override footstep sound set", nil)
                        activator.m_bIsMiniBoss = 0
                        if isCrit == 1 then
                            activator:RemoveCond(34)
                        end

                        activator.m_flModelScale = 1
                        activator.killConfirmed = 0
                        classCheck = nil
                        targetHealth = 0
                        isCrit = 0

                        activator:SwitchClassInPlace(8)
                        activator:AcceptInput("SetCustomModelWithClassAnimations", "")

                        timer.Simple(0.22, function()
                            activator:AddCallback(ON_DEATH, function()
                                -- activator:AcceptInput("$DisplayTextChat", "{red}Dead. Returning Back To Spy")
                                activator.hasDied = 1
                                activator:SwitchClass(8)
        
                                -- activator:AcceptInput("$DisplayTextChat", "{Red} Target Was Not Killed")
                                activator.alreadytriggered = 0
                                activator.copyItems = nil
                                activator.copyTarget = nil
                                isCrit = 0

                                timer.Stop(activator.id1)
                                timer.Stop(activator.id2)
        
                                activator:RemoveAllCallbacks(ON_DEATH)
                            end)
                        end)
                    end)
                    activator.id1 = revert
                    activator.id2 = warn

                    caller:RemoveAllCallbacks(ON_DEATH)
                end)
        --------------------------------------------------------------------------------------
                timer.Simple(5, function()

                    if activator.killConfirmed == 1 then
                        return false
                    end
                    caller:RemoveAllCallbacks(ON_DEATH)
                    activator:AcceptInput("$DisplayTextChat", "{Red} Target Was Not Killed")
                    activator.alreadytriggered = 0
                    activator.copyItems = nil
                    activator.copyTarget = nil
                    isCrit = 0
                    classCheck = nil
                    targetHealth = 0
                end)

            end
        else
            activator:AcceptInput("$DisplayTextChat", "{Red}Spies and Engineers are invalid. Denied.")
        end
    else
        activator:AcceptInput("$DisplayTextChat", "{Red}Spies and Engineers are invalid. Denied.")
    end
end

---------------------PRIMAL PROTECTOR ----------------------------

function strongestMannVariables(_, activator)

    local count = "count"..PT_list
    activator.killReq = 0

    -- activator:AcceptInput("$AddItemAttribute", "add cond when active|16|2")
    activator:AcceptInput("$AddItemAttribute", "drop health pack on kill|1|2")
    activator:AcceptInput("$AddItemAttribute", "damage bonus|1.65|1")
    activator:AcceptInput("$AddPlayerAttribute", "CARD: move speed bonus|1.20")
    activator:AcceptInput("$AddPlayerAttribute", "crit on cond|19")


    -- activator:AcceptInput("$AddItemAttribute", "minicritboost on kill|5.0|1")
    -- activator:AcceptInput("$AddPlayerAttribute", "fire input on taunt|popscript^$summonShield")
    -- activator:AcceptInput("$AddPlayerAttribute", "dmg taken from crit reduced|0.40")
    -- activator:AcceptInput("$AddPlayerAttribute", "gesture speed increase|2.5") 

    -- activator:AcceptInput("$AddItemAttribute", "fire input on kill|popscript^$killMechanic|1")
    -- activator:AcceptInput("$AddItemAttribute", "fire input on kill|popscript^$killMechanic|2")

    -- ents.CreateWithKeys("game_text", {
    --     targetname = count,
    --     -- spawnflags = 1,
    --     holdtime = 99999,
    --     color = "255 0 0",
    --     message = "[Primal Protection] 0/10", 
    --     channel = 1,
    --     y = 0.55,
    --     x = -1,
    -- })
    -- activator.countID = ents.FindByName(count)

    -- timer.Simple(0.25, function()
    --     activator.countID:AcceptInput("Display",_, activator)
    -- end)
    activator:AddCallback(ON_SPAWN, function()
        -- util.PrintToChatAll("bye bye")

        activator:AcceptInput("$RemoveItemAttribute", "add cond when active|2")
        activator:AcceptInput("$RemoveItemAttribute", "drop health pack on kill|2")
        activator:AcceptInput("$RemoveItemAttribute", "damage bonus|1")
        activator:AcceptInput("$RemovePlayerAttribute", "CARD: move speed bonus")
        activator:AcceptInput("$RemovePlayerAttribute", "crit on cond")

        -- activator:AcceptInput("$RemoveItemAttribute", "minicritboost on kill|1")
        -- activator:AcceptInput("$RemovePlayerAttribute", "gesture speed increase")
        -- activator:AcceptInput("$RemovePlayerAttribute", "dmg taken from crit reduced")

        -- activator:AcceptInput("$RemoveItemAttribute", "fire input on kill|popscript^$killMechanic|1")
        -- activator:AcceptInput("$RemoveItemAttribute", "fire input on kill|popscript^$killMechanic|2")

        -- activator.countID:Remove()
        activator:RemoveCond(32)

        activator:RemoveAllCallbacks()
    end)
    activator:AddCallback(ON_DEATH, function()
        -- util.PrintToChatAll("bye bye")

        activator:AcceptInput("$RemoveItemAttribute", "always crit|2")
        -- activator:AcceptInput("$RemoveItemAttribute", "drop health pack on kill|2")
        activator:AcceptInput("$RemoveItemAttribute", "damage bonus|1")
        -- activator:AcceptInput("$RemoveItemAttribute", "minicritboost on kill|1")
        -- activator:AcceptInput("$RemovePlayerAttribute", "gesture speed increase")
        -- activator:AcceptInput("$RemovePlayerAttribute", "dmg taken from crit reduced")

        -- activator:AcceptInput("$RemoveItemAttribute", "fire input on kill|popscript^$killMechanic|1")
        -- activator:AcceptInput("$RemoveItemAttribute", "fire input on kill|popscript^$killMechanic|2")
        -- activator.countID:Remove()

        activator:RemoveAllCallbacks()
        activator:RemoveCond(32)

    end)

    -- PT_list = PT_list + 1
end

-- function killMechanic(_, activator)

--     if activator.killReq < 10 then
--         activator.killReq = activator.killReq + 1
--         activator.countID:AddOutput("message [Primal Protection] "..activator.killReq.."/10")
--         activator.countID:AcceptInput("Display",_, activator)
--     else
--         print("full bar")
--         activator.killReq = 10
--         activator.countID:AddOutput("message [Primal Protection] "..activator.killReq.."/10")
--         activator.countID:AcceptInput("Display",_, activator)
--     end
-- end

function summonShield(_, activator)

    local position = {
        translation = activator:GetAbsOrigin(),
        -- rotation = activator:GetAbsAngles(),
        -- parent = activator
    }

    if activator.killReq == 10 then
            -- util.PrintToChatAll("Spawned")
        ents.SpawnTemplate("PP_Template", position)

        activator.killReq = 0

        activator.countID:AddOutput("message [Primal Protection] 0/10")
        activator.countID:AcceptInput("Display",_, activator)
    end
end