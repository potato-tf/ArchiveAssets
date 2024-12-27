local RAGE_DURATION = 10
local UPDATE_INTERVAL = 0.015

local knockbackHandles = {}

local RAGE_OVERRIDES_APPLY = {
    ["throwable fire speed"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("Set DamageType Ignite", 5)
    end,
    ["throwable damage"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("dmg from ranged reduced", 0.75)
    end,
    ["tool needs giftwrap"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("weapon spread bonus", 0.5)
    end,
    ["allow_halloween_offering"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("add cond when active", 7450)
    end
}
local RAGE_OVERRIDES_REMOVE = {
    ["throwable fire speed"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("Set DamageType Ignite", nil)
    end,
    ["throwable damage"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("dmg from ranged reduced", nil)
    end,
    ["tool needs giftwrap"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("weapon spread bonus", nil)
    end,
    ["allow_halloween_offering"] = function(activator)
        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("weapon spread bonus", 0.5)
    end
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function applyKnockbackRageEffect(activator)
    for attr, func in pairs(RAGE_OVERRIDES_APPLY) do
        if activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):GetAttributeValue(attr) then
            func(activator)
            break
        end
    end
end

local function removeKnockbackRageEffect(activator)
    for attr, func in pairs(RAGE_OVERRIDES_REMOVE) do
        if activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):GetAttributeValue(attr) then
            func(activator)
            break
        end
    end
end

function KnockbackRageStart(_, activator)
    local handleIndex = activator:GetHandleIndex()

    local draining = false
    local fakeMeter = 0
    local meterLerp = 0

    knockbackHandles[handleIndex] = timer.Create(UPDATE_INTERVAL, function ()
        if not IsValid(activator) then
            KnockbackRageStop(nil, nil, handleIndex)
            return
        end

        if draining then
            -- fakeMeter = math.max(fakeMeter - (UPDATE_INTERVAL * RAGE_DURATION) * 10, 0)
            meterLerp = meterLerp + (UPDATE_INTERVAL / RAGE_DURATION * 2)
            fakeMeter = math.max(100 - lerp(0, 100, meterLerp), 0)

            activator:SetFakeSendProp("m_flRageMeter", fakeMeter)

            if fakeMeter <= 0 then
                activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("increase buff duration HIDDEN", nil)
                activator:ResetFakeSendProp("m_bRageDraining")
                activator:ResetFakeSendProp("m_flRageMeter")
                activator.m_flRageMeter = 0

                fakeMeter = 0
                meterLerp = 0
                draining = false

                removeKnockbackRageEffect(activator)
            end

            return
        end

        if activator.m_bRageDraining == 0 then
            return
        end

        activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("increase buff duration HIDDEN", 100)
        activator:SetFakeSendProp("m_bRageDraining", 1)
        activator.m_bRageDraining = 0
        activator.m_flRageMeter = -100000
        fakeMeter = 100
        meterLerp = 0
        draining  = true

        applyKnockbackRageEffect(activator)
    end, 0)
end

function KnockbackRageStop(_, activator, handle)
    if activator then
        activator:ResetFakeSendProp("m_bRageDraining")
        activator:ResetFakeSendProp("m_flRageMeter")
    end

    local handleIndex = handle or activator:GetHandleIndex()

    pcall(timer.Stop, knockbackHandles[handleIndex]);
    knockbackHandles[handleIndex] = nil
end