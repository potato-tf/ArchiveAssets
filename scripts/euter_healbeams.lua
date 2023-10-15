local medicboss = nil
local boss_healparticle_target = nil

function OnWaveReset(wave)
    medicboss = nil
    boss_healparticle_target = nil
end

function OnGameTick()
    if boss_healparticle_target == nil then
        return
    end
    if medicboss == nil then
        return
    end

    local bossMedigun = medicboss:GetPlayerItemBySlot(1)
    local bossPatient = bossMedigun.m_hHealingTarget
    if bossPatient == nil or not bossPatient:IsPlayer() then
        boss_healparticle_target:SetAbsOrigin(medicboss:GetAbsOrigin() + Vector(0,0,128))
        return
    end

    local patientOrigin = bossPatient:GetAbsOrigin()
    boss_healparticle_target:SetAbsOrigin(patientOrigin + Vector(0,0,60))
end

function OnWaveSpawnBot(bot, wave, tags)
    for _, tag in pairs(tags) do
        if tag == "euterboss" then
            medicboss = bot
            timer.Simple(0.5, function()
                boss_healparticle_target = ents.FindByName("boss_healbeam_target")
            end)
        end
    end
end