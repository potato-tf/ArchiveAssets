local LEVELS_INFO = {
	[1] = {
		Damage = 3,
		Cooldown = 0.1,
	},
	[2] = {
		Damage = 6,
		Cooldown = 0.1,
	},
	["Thunderdome"] = {
		Damage = 8,
		Cooldown = 0.05,
	},
}

local registeredShields = {} --value is debounce players

local function _register(shieldEnt, level, ownerTeamnum, activator)
	shieldEnt.Registered = true

	local handle = shieldEnt:GetHandleIndex()

	print(activator)

	-- shieldEnt:AcceptInput("$SetKey$teamnum", ownerTeamnum)
	-- shieldEnt:AcceptInput("$SetKey$skin", ownerTeamnum == 3 and 1 or 2)

	registeredShields[handle] = {}

	shieldEnt:AddCallback(ON_REMOVE, function()
		registeredShields[handle] = nil
	end)

	local levelInfo = LEVELS_INFO[level]

	shieldEnt:AddCallback(ON_TOUCH, function(_, target, hitPos)
		if not target then
			return
		end

		if not target:IsCombatCharacter() and target.m_iClassname ~= "tank_boss" then
			return
		end

		local visualHitPost = hitPos + Vector(0, 0, 50)

		local targetHandle = target:GetHandleIndex()

		local nextAllowedDamageTickOnTarget = registeredShields[handle][targetHandle] or -1

		if CurTime() < nextAllowedDamageTickOnTarget then
			return
		end

		local targetTeamnum = target.m_iTeamNum

		if targetTeamnum == ownerTeamnum then
			return
		end

		local damageInfo = {
			Attacker = activator or target,
			Inflictor = nil,
			Weapon = nil,
			Damage = levelInfo.Damage,
			DamageType = DMG_SHOCK,
			DamageCustom = 0,
			DamagePosition = visualHitPost,
			DamageForce = Vector(0, 0, 0),
			ReportedPosition = visualHitPost,
		}

		local dmg = target:TakeDamage(damageInfo)

		registeredShields[handle][targetHandle] = CurTime() + levelInfo.Cooldown

		-- print("damage dealt " .. dmg)
	end)
end

function RegisterShieldLvl1(shieldEntName, activator)
	local shieldEnt = ents.FindByName(shieldEntName)

	local ownerTeamnum = activator.m_iTeamNum

	_register(shieldEnt, 1, ownerTeamnum, activator:IsPlayer() and activator)
end

function RegisterShieldLvl2(shieldEntName, activator)
	local shieldEnt = ents.FindByName(shieldEntName)

	local ownerTeamnum = activator.m_iTeamNum

	_register(shieldEnt, 2, ownerTeamnum, activator:IsPlayer() and activator)
end

function RegisterShieldThunderdome(shieldEntName, activator)
	local shieldEnt = ents.FindByName(shieldEntName)

	local ownerTeamnum = activator.m_iTeamNum

	if ownerTeamnum == 3 then
		shieldEnt.m_nSkin = 1
		shieldEnt.m_iTeamNum = 3
	end

	_register(shieldEnt, "Thunderdome", ownerTeamnum, activator)
end
