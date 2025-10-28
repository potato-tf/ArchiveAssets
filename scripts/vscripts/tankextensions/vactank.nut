local VACTANK_VALUES_TABLE = {
	VACTANK_MODEL             = "models/props_tumb/mvm/tank_shield.mdl"
	VACTANK_SND_DEPLOY        = "player/invuln_on_vaccinator.wav"
	VACTANK_SND_RESIST        = ")player/resistance_medium1.wav"
	VACTANK_RESIST_MULT       = 0
	VACTANK_COLOR_CYCLE_SPEED = 5
}
foreach(k,v in VACTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(VACTANK_MODEL)
TankExt.PrecacheSound(VACTANK_SND_DEPLOY)

::VacTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::VacTankEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hVictim = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hVictim.GetClassname() == "tank_boss" && hAttacker.GetTeam() != hVictim.GetTeam())
		{
			local VacScope = TankExt.GetMultiScopeTable(hVictim.GetScriptScope(), "vactank")
			if(VacScope && params.damage_type & VacScope.iDamageFilter)
			{
				params.damage *= VACTANK_RESIST_MULT
				VacScope.Resist()
				EmitSoundEx({
					sound_name  = VACTANK_SND_RESIST
					sound_level = 90
					entity      = hVictim
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
		}
	}
}
__CollectGameEventCallbacks(VacTankEvents)

TankExt.NewTankType("vactank*", {
	function OnSpawn()
	{
		EmitSoundEx({
			sound_name  = VACTANK_SND_DEPLOY
			pitch       = 90
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		iDamageFilter <- 0
		local hShields = []

		if(sTankName.find("_bullet"))
		{
			local hShield = SpawnEntityFromTableSafe("prop_dynamic", { model = VACTANK_MODEL, skin = 2, disableshadows = 1, rendermode = 1 })
			hShields.append(hShield)
			TankExt.SetParentArray([hShield], self)
			iDamageFilter = iDamageFilter | DMG_BULLET | DMG_BUCKSHOT
		}
		if(sTankName.find("_blast"))
		{
			local hShield = SpawnEntityFromTableSafe("prop_dynamic", { model = VACTANK_MODEL, skin = 3, disableshadows = 1, rendermode = 1 })
			hShields.append(hShield)
			TankExt.SetParentArray([hShield], self)
			iDamageFilter = iDamageFilter | DMG_BLAST
		}
		if(sTankName.find("_fire"))
		{
			local hShield = SpawnEntityFromTableSafe("prop_dynamic", { model = VACTANK_MODEL, skin = 4, disableshadows = 1, rendermode = 1 })
			hShields.append(hShield)
			TankExt.SetParentArray([hShield], self)
			iDamageFilter = iDamageFilter | DMG_BURN | DMG_IGNITE
		}

		local iShieldsLength = hShields.len()
		local iCenterOffset  = 16 * (iShieldsLength - 1)
		local iOffset        = 0
		local iTeamNum       = self.GetTeam()
		foreach(hShield in hShields)
		{
			local hParticle = SpawnEntityFromTableSafe("info_particle_system", {
				origin       = Vector(0, iOffset - iCenterOffset, 200)
				effect_name  = format("vaccinator_%s_buff%i", iTeamNum == TF_TEAM_BLUE ? "blue" : "red", hShield.GetSkin() - 1)
				start_active = 1
			})
			TankExt.SetParentArray([hParticle], self)
			iOffset += 32
		}

		function Resist()
		{
			local DeleteArray = []
			for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
				if(GetPropInt(hChild, "m_nRenderFX") == kRenderFxFadeFast)
					DeleteArray.append(hChild)
			foreach(hShield in DeleteArray)
				hShield.Destroy()

			foreach(hShield in hShields)
			{
				local hShieldFade = SpawnEntityFromTableSafe("prop_dynamic", { model = VACTANK_MODEL, skin = hShield.GetSkin(), disableshadows = 1, renderfx = kRenderFxFadeFast })
				SetPropInt(hShieldFade, "m_clrRender", GetPropInt(hShield, "m_clrRender"))
				TankExt.SetParentArray([hShieldFade], self)
				EntFireByHandle(hShieldFade, "Kill", null, 1, null, null)
			}
		}
		if(iShieldsLength > 1)
		{
			local iAlphas = []
			foreach(k, v in hShields)
				iAlphas.append(k == 0 ? 255 : 0)
			local iColorIndex = 0
			function Think()
			{
				local iNextColorIndex = iColorIndex == iAlphas.len() - 1 ? 0 : iColorIndex + 1
				iAlphas[iColorIndex] -= VACTANK_COLOR_CYCLE_SPEED
				iAlphas[iNextColorIndex] += VACTANK_COLOR_CYCLE_SPEED
				if(iAlphas[iColorIndex] <= 0)
					iColorIndex = iNextColorIndex

				foreach(k, hShield in hShields)
					TankExt.SetEntityColor(hShield, 255, 255, 255, iAlphas[k])
			}
		}
	}
})