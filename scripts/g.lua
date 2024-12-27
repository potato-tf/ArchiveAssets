function OnGameTick()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player.m_nDesiredDisguiseTeam == player.m_iTeamNum then
			player.m_nDesiredDisguiseTeam = TEAM_SPECTATOR
		end
	end
end
local function IsInvulnerable(player)
	if player:InCond(TF_COND_INVULNERABLE)
	or player:InCond(TF_COND_INVULNERABLE_CARD_EFFECT)
	or player:InCond(TF_COND_INVULNERABLE_USER_BUFF)
	or player:InCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED) then
		return true
	end
	return false
end
function OnPlayerConnected(player)
	player:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		if damageinfo.DamageCustom == TF_DMG_CUSTOM_BACKSTAB then
			local wep = damageinfo.Weapon
			local attr = wep:GetAttributeValue("disguise on backstab", true)
			if player.m_bIsMiniBoss == 1 then
				realdamage = (damageinfo.Damage * 3) + 1
			elseif player.m_bIsMiniBoss == 0 then
				realdamage = damageinfo.Damage
			end
			if attr ~= nil and attr == 1 then
				if player.m_iHealth < realdamage and not IsInvulnerable(player) and player.m_iTeamNum == TEAM_SPECTATOR then
					local attacker = damageinfo.Attacker
					attacker:AddCond(TF_COND_SPEED_BOOST, 0.01, nil) -- recalculate speed
					attacker:AddCond(TF_COND_DISGUISED)
					attacker.m_nDisguiseClass = player.m_iClass
					attacker.m_nDisguiseTeam = TEAM_SPECTATOR
					attacker.m_nDesiredDisguiseClass = player.m_iClass
					attacker.m_nDesiredDisguiseTeam = TEAM_SPECTATOR
					attacker.m_hDisguiseTarget = player
					attacker.m_iDisguiseHealth = player.m_iHealth
					attacker.m_hDisguiseWeapon = player.m_hActiveWeapon
				end
			end
		end
	end)
end