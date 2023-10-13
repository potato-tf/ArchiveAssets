local SWITCH_COOLDOWN = 5

local classIndices = {
	[1] = "Scout",
	[2] = "Soldier",
	[3] = "Pyro",
	[4] = "Demoman",
	[5] = "Heavyweapons",
	[6] = "Engineer",
	[7] = "Medic",
	[8] = "Sniper",
	[9] = "Spy",
}

local classIndices_Internal = {
	[1] = "Scout",
	[3] = "Soldier",
	[7] = "Pyro",
	[4] = "Demoman",
	[6] = "Heavyweapons",
	[9] = "Engineer",
	[5] = "Medic",
	[2] = "Sniper",
	[8] = "Spy",
}

local cooldowns = {}

local function getMaxHealth(player)
	local net = player:GetNetIndex() + 1

	local playerResource = ents.FindByClass("tf_player_manager")

	local props = playerResource:DumpProperties()

	for playerNetIndex, maxHealth in pairs(props.m_iMaxBuffedHealth) do
		if playerNetIndex == net then
			return maxHealth
		end
	end
end

function FreelanceMerc_PromptMenu(currentClass, activator)
	local handleIndex = activator:GetHandleIndex()

	if cooldowns[handleIndex] then
		--display text center
		activator:Print(2, "Freelance Mercenary switch on cooldown")
		return
	end

	local menu = {
		timeout = 0,
		title = "Classes",
		itemsPerPage = 10,
		flags = MENUFLAG_BUTTON_EXIT,
		onSelect = function(player, index)
			if not player:IsAlive() then
				return
			end

			player.PreFreelanceSwitchHealth = player.m_iHealth

			player:SwitchClassInPlace(classIndices[index])

			timer.Simple(0.1, function()
				local chosenHealth = player.PreFreelanceSwitchHealth

				local maxHealth = tonumber(getMaxHealth(player))

				if chosenHealth > maxHealth then
					chosenHealth = maxHealth
				end

				player.m_iHealth = chosenHealth
			end)

			player:HideMenu()

			local secondary = player:GetPlayerItemBySlot(1)
			local melee = player:GetPlayerItemBySlot(2)


			-- shoutout to np_sub for giving me the idea to do .... whatever this is
			-- I hate

			for i = 1, #player.m_iAmmo do
				local v = player.m_iAmmo[i]
				if v == 1 then
					player:AcceptInput("$SetProp$m_iAmmo$" .. i - 1, 0)
					-- player.m_iAmmo[i] = 0
				end
			end

			secondary.m_flEffectBarRegenTime = CurTime() + 8
			melee.m_flEffectBarRegenTime = CurTime() + 8 -- wrap assassin/sandman

			-- for lunch boxes to display properly
			for i = 1, #player.m_flItemChargeMeter do
				player:AcceptInput("$SetProp$m_flItemChargeMeter$" .. i - 1, 0)
				-- player.m_flItemChargeMeter[i] = 0
			end

			cooldowns[handleIndex] = true

			timer.Simple(SWITCH_COOLDOWN, function()
				cooldowns[handleIndex] = nil
			end)
		end,
		onCancel = nil,
	}

	for index, className in pairs(classIndices) do
		menu[index] = { text = className, value = index, disabled = classIndices_Internal[currentClass] == className }
	end

	activator:DisplayMenu(menu)
end
