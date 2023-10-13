-- projectile shields moving outward in a spiral pattern to mimic a 'shockwave attack'

local DESPAWN_TIME = 8

local Y_OFFSET = -5
local SHIELDS_COUNT = 4

local CONTACT_DAMAGE = 100

local BASE_MAX_SPEED = 10
local BASE_SHIELD_DISTANCE = 10

local BASE_SPEED_INCREMENT = 5
local BASE_SPEED_INCREMENT_INCREASE_PER_UPDATE = 0.05

local ANGLES = {
	[1] = Vector(0, 0, 0),
	[2] = Vector(-180, 0, -180),
	[3] = Vector(0, 90, 0),
	[4] = Vector(-180, 90, -180),
}

function CreateShockwave(_, activator)
	local namePrefix = "thunderdome" .. tostring(activator:GetHandleIndex())

	for i = 1, SHIELDS_COUNT do
		-- Init
		local speedIncrement = BASE_SPEED_INCREMENT

		local maxSpeed = BASE_MAX_SPEED
		local shieldDistance = BASE_SHIELD_DISTANCE

		local rotate = ents.CreateWithKeys("func_rotating", {
			mins = Vector(-0.1, -0.1, -0.1),
			maxs = Vector(0.1, 0.1, 0.1),
			dmg = 0,
			fanfriction = 100,
			maxspeed = maxSpeed,
			spawnflags = 65,
			volume = 0,
			solid = 0,
		})

		local function getShieldOffset()
			local DISTANCES = {
				[1] = Vector(shieldDistance, 0, Y_OFFSET),
				[2] = Vector(-shieldDistance, 0, Y_OFFSET),
				[3] = Vector(0, shieldDistance, Y_OFFSET),
				[4] = Vector(0, -shieldDistance, Y_OFFSET),
			}

			return DISTANCES[i]
		end

		local shieldOffset = getShieldOffset()
		local shieldAngles = ANGLES[i]

		rotate["$positiononly"] = 1

		rotate:SetName(namePrefix .. tostring(rotate:GetHandleIndex()))
		rotate:SetFakeParent(activator)

		local shield = ents.CreateWithKeys("entity_medigun_shield", {
			angles = shieldAngles,
			spawnflags = 1,
			teamnum = activator.m_iTeamNum,
			skin = activator.m_iTeamNum == TEAM_BLUE and 1 or 2,
		}, true, true)

		shield["$fakeparentoffset"] = shieldOffset
		shield["$fakeparentrotation"] = shieldAngles

		shield:SetFakeParent(rotate)
		local shieldName = namePrefix .. tostring(shield:GetHandleIndex() .. "Shield")
		shield:SetName(shieldName)

		-- Damage
		local damagedPlayers = {}
		shield:AddCallback(ON_TOUCH, function(_, target, hitPosition)
			if target:IsPlayer() and not damagedPlayers[target:GetHandleIndex()] and target.m_iTeamNum ~= activator.m_iTeamNum then
				damagedPlayers[target:GetHandleIndex()] = true

				local visualHitPosition = hitPosition + Vector(0, 0, 50)

				local damageInfo = {
					Attacker = activator,
					Inflictor = nil,
					Weapon = nil,
					Damage = CONTACT_DAMAGE,
					DamageType = DMG_BURN,
					DamageCustom = 0,
					DamagePosition = visualHitPosition,
					DamageForce = Vector(0, 0, 0),
					ReportedPosition = visualHitPosition,
				}

				target:TakeDamage(damageInfo)
			end
		end)

		-- Think
		local despawnTimestamp = CurTime() + DESPAWN_TIME

		local think
		think = timer.Create(0.05, function()
			if not activator:IsAlive() or not IsValid(shield) or CurTime() >= despawnTimestamp then
				timer.Stop(think)
				if IsValid(shield) then
					shield:Remove()
					rotate:Remove()
				end
				return
			end

			speedIncrement = speedIncrement + BASE_SPEED_INCREMENT_INCREASE_PER_UPDATE

			shieldDistance = shieldDistance + speedIncrement
			maxSpeed = maxSpeed + speedIncrement * 5

			rotate:AddOutput("maxSpeed " .. tostring(maxSpeed))

			shieldOffset = getShieldOffset()
			shield["$fakeparentoffset"] = shieldOffset
		end, 0)
	end
end
