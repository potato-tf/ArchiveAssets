local classIndices_Internal = {
	[1] = "Scout",
	[3] = "Soldier",
	[7] = "Pyro",
	[4] = "Demoman",
	[6] = "Heavy",
	[9] = "Engineer",
	[5] = "Medic",
	[2] = "Sniper",
	[8] = "Spy",
}

function RemoveZombieModel(_, activator)
	local className = classIndices_Internal[activator.m_iClass]
	local vodooName = "Zombie "..className
	local skin = activator.m_iTeamNum == 2 and 2 or 1 -- non-zombie skin for each team

	activator:AcceptInput("$SetProp$m_bForcedSkin", "1")
	activator:AcceptInput("$SetProp$m_nForcedSkin", tostring(skin))

	activator:RemoveItem(vodooName)
end