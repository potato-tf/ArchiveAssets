local BANNERTANK_VALUES_TABLE = {
	BANNERTANK_BUFF_SELF_DAMAGE_MULT = 1.35
	BANNERTANK_BUFF_SOUND_RED        = ")weapons/buff_banner_horn_red.wav"
	BANNERTANK_BUFF_SOUND_BLUE       = ")weapons/buff_banner_horn_blue.wav"

	BANNERTANK_CONCH_SELF_HEAL_MULT  = 0.35
	BANNERTANK_CONCH_SELF_SPEED_MULT = 1.4
	BANNERTANK_CONCH_SOUND_RED       = ")items/samurai/tf_conch.wav"
	BANNERTANK_CONCH_SOUND_BLUE      = ")items/samurai/tf_conch.wav"

	BANNERTANK_BACKUP_SELF_RESIST_MULT = 0.65
	BANNERTANK_BACKUP_SOUND_RED        = ")weapons/battalions_backup_red.wav"
	BANNERTANK_BACKUP_SOUND_BLUE       = ")weapons/battalions_backup_blue.wav"

	BANNERTANK_RANGE_MULT     = 1.2
	BANNERTANK_ACTIVATE_DELAY = 2.33
	BANNERTANK_SOUND_FLAG     = ")weapons/buff_banner_flag.wav"
}
foreach(k,v in BANNERTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(BANNERTANK_BUFF_SOUND_RED)
TankExt.PrecacheSound(BANNERTANK_BUFF_SOUND_BLUE)
TankExt.PrecacheSound(BANNERTANK_CONCH_SOUND_RED)
TankExt.PrecacheSound(BANNERTANK_CONCH_SOUND_BLUE)
TankExt.PrecacheSound(BANNERTANK_BACKUP_SOUND_RED)
TankExt.PrecacheSound(BANNERTANK_BACKUP_SOUND_BLUE)
TankExt.PrecacheSound(BANNERTANK_SOUND_FLAG)

local BANNER_NONE   = 1 << 0
local BANNER_BUFF   = 1 << 1
local BANNER_CONCH  = 1 << 2
local BANNER_BACKUP = 1 << 3

::BannerTankEvents <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) delete ::BannerTankEvents }
	function OnScriptHook_OnTakeDamage(params)
	{
		local hAttacker  = params.attacker
		local hVictim    = params.const_entity
		local hInflictor = params.inflictor
		if(hAttacker && hVictim && hVictim.IsAlive() && hAttacker.GetTeam() != hVictim.GetTeam())
		{
			local BannerCheck = function(hEnt, iBannerType)
			{
				if(hEnt.GetClassname() == "tank_boss")
				{
					local BannerScope = TankExt.GetMultiScopeTable(hEnt.GetScriptScope(), "bannertank")
					if(BannerScope && !BannerScope.bNoSelfEffect && BannerScope.iActiveBanners & iBannerType)
						return true
					else
						return false
				}
			}
			if(BannerCheck(hAttacker, BANNER_BUFF) && !(params.damage_type & DMG_CRITICAL)) params.crit_type = CRIT_MINI
			if(hVictim.IsPlayer() && BannerCheck(hAttacker, BANNER_CONCH))
			{
				local flAmount = params.damage * BANNERTANK_CONCH_SELF_HEAL_MULT
				if(params.damage_type & DMG_CRITICAL) flAmount * 3
				else if(params.crit_type == CRIT_MINI) flAmount * 1.35
				flAmount *= BANNERTANK_CONCH_SELF_HEAL_MULT

				local iMaxHealth = hVictim.GetMaxHealth()
				if(flAmount > iMaxHealth) flAmount = iMaxHealth

				hAttacker.AcceptInput("AddHealth", format("%f", flAmount), null, null)
				hAttacker.TakeDamage(0, DMG_GENERIC, First()) // refresh healthbar, attacker needs to not be the same team as the tank
				DispatchParticleEffect(hAttacker.GetTeam() == TF_TEAM_BLUE ? "healthgained_blu_giant" : "healthgained_red_giant", hAttacker.GetOrigin() + hAttacker.GetUpVector() * hAttacker.GetBoundingMaxs().z, Vector(1))
			}
			if(BannerCheck(hVictim, BANNER_BACKUP))
			{
				local bSentry = hInflictor && GetPropInt(hInflictor, "m_iObjectType") == OBJ_SENTRYGUN
				params.damage      *= (bSentry ? 0.5 : 0.65)
				params.damage_type  = params.damage_type & ~DMG_CRITICAL
				if(hAttacker.IsPlayer() && (hAttacker.InCond(TF_COND_OFFENSEBUFF) || hAttacker.InCond(TF_COND_ENERGY_BUFF) || hAttacker.InCond(TF_COND_NOHEALINGDAMAGEBUFF)))
					params.damage *= 0.74 // 1 / 1.35, minicrits are applied after OnTakeDamage
			}
		}
	}
}
__CollectGameEventCallbacks(BannerTankEvents)

TankExt.NewTankType("bannertank*", {
	function OnSpawn()
	{
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE

		local hPackBuff = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-48 -19 40"
			angles        = "0 90 0"
			model         = "models/weapons/c_models/c_buffpack/c_buffpack.mdl"
			modelscale    = 1.5
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
			rendermode    = 1
			renderamt     = 0
		})
		local hBannerBuff = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-57 -33 78"
			angles        = "0 90 0"
			model         = "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl"
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
		})

		local hPackConch = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-60 -18 40"
			angles        = "0 0 0"
			model         = "models/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl"
			modelscale    = 1.5
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
			rendermode    = 1
			renderamt     = 0
		})
		local hBannerConch = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-74 -10 78"
			angles        = "0 0 0"
			model         = "models/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl"
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
		})

		local hPackBackup = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-48 19 40"
			angles        = "0 270 0"
			model         = "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl"
			modelscale    = 1.5
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
			rendermode    = 1
			renderamt     = 0
		})
		local hBannerBackup = SpawnEntityFromTableSafe("prop_dynamic", {
			origin        = "-37 33 78"
			angles        = "0 270 0"
			model         = "models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl"
			skin          = bBlueTeam ? 1 : 0
			startdisabled = 1
		})

		TankExt.SetParentArray([hPackBuff, hBannerBuff, hPackConch, hBannerConch, hPackBackup, hBannerBackup], self)

		bNoSelfEffect  <- sTankName.find("_noselfeffect") ? true : false
		iActiveBanners <- 0

		function SetBanner(iAdd, iRemove)
		{
			local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
			local Sound = @(sSound) EmitSoundEx({
				sound_name  = sSound
				sound_level = 100
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			if(iAdd)
			{
				local bAddedBanner = false
				local StartBanner = function(sSoundRed, sSoundBlue, hBanner)
				{
					bAddedBanner = true
					TankExt.DelayFunction(self, this, 0.22, @() Sound(bBlueTeam ? sSoundBlue : sSoundRed) )
					TankExt.DelayFunction(self, this, BANNERTANK_ACTIVATE_DELAY, @() hBanner.AcceptInput("Enable", null, null, null) )
				}
				if(!(iActiveBanners & BANNER_BUFF) && iAdd & BANNER_BUFF)
				{
					StartBanner(BANNERTANK_BUFF_SOUND_RED, BANNERTANK_BUFF_SOUND_BLUE, hBannerBuff)
					hPackBuff.AcceptInput("Enable", null, null, null)
					SetPropInt(hPackBuff, "m_nRenderFX", kRenderFxSolidFast)
				}
				if(!(iActiveBanners & BANNER_CONCH) && iAdd & BANNER_CONCH)
				{
					StartBanner(BANNERTANK_CONCH_SOUND_RED, BANNERTANK_CONCH_SOUND_BLUE, hBannerConch)
					hPackConch.AcceptInput("Enable", null, null, null)
					SetPropInt(hPackConch, "m_nRenderFX", kRenderFxSolidFast)
					TankExt.DelayFunction(self, this, BANNERTANK_ACTIVATE_DELAY, function() { if(!bNoSelfEffect) SetPropFloat(self, "m_speed", GetPropFloat(self, "m_speed") * BANNERTANK_CONCH_SELF_SPEED_MULT) })
				}
				if(!(iActiveBanners & BANNER_BACKUP) && iAdd & BANNER_BACKUP)
				{
					StartBanner(BANNERTANK_BACKUP_SOUND_RED, BANNERTANK_BACKUP_SOUND_BLUE, hBannerBackup)
					hPackBackup.AcceptInput("Enable", null, null, null)
					SetPropInt(hPackBackup, "m_nRenderFX", kRenderFxSolidFast)
				}
				if(bAddedBanner) TankExt.DelayFunction(self, this, BANNERTANK_ACTIVATE_DELAY, function()
				{
					Sound(BANNERTANK_SOUND_FLAG)
					iActiveBanners = iActiveBanners | iAdd
				})
			}
			if(iRemove)
			{
				if(iActiveBanners & BANNER_BUFF && iRemove & BANNER_BUFF)
				{
					hBannerBuff.AcceptInput("Disable", null, null, null)
					SetPropInt(hPackBuff, "m_nRenderFX", kRenderFxFadeFast)
					TankExt.DelayFunction(self, this, 0.15, function() { hPackBuff.AcceptInput("Disable", null, null, null) })
				}
				if(iActiveBanners & BANNER_CONCH && iRemove & BANNER_CONCH)
				{
					hBannerConch.AcceptInput("Disable", null, null, null)
					SetPropInt(hPackConch, "m_nRenderFX", kRenderFxFadeFast)
					TankExt.DelayFunction(self, this, 0.15, function() { hPackConch.AcceptInput("Disable", null, null, null) })
					if(!bNoSelfEffect) SetPropFloat(self, "m_speed", GetPropFloat(self, "m_speed") / BANNERTANK_CONCH_SELF_SPEED_MULT)
				}
				if(iActiveBanners & BANNER_BACKUP && iRemove & BANNER_BACKUP)
				{
					hBannerBackup.AcceptInput("Disable", null, null, null)
					SetPropInt(hPackBackup, "m_nRenderFX", kRenderFxFadeFast)
					TankExt.DelayFunction(self, this, 0.15, function() { hPackBackup.AcceptInput("Disable", null, null, null) })
				}
				iActiveBanners = iActiveBanners & ~iRemove
			}
		}

		SetBanner((sTankName.find("_buff") ? BANNER_BUFF : 0) | (sTankName.find("_conch") ? BANNER_CONCH : 0) | (sTankName.find("_backup") ? BANNER_BACKUP : 0), BANNER_NONE)

		local BannerScope = this
		local hTank_scope = self.GetScriptScope()
		hTank_scope.AddBannerBuff      <- @() BannerScope.SetBanner(BANNER_BUFF, BANNER_NONE)
		hTank_scope.AddBannerConch     <- @() BannerScope.SetBanner(BANNER_CONCH, BANNER_NONE)
		hTank_scope.AddBannerBackup    <- @() BannerScope.SetBanner(BANNER_BACKUP, BANNER_NONE)
		hTank_scope.RemoveBannerBuff   <- @() BannerScope.SetBanner(BANNER_NONE, BANNER_BUFF)
		hTank_scope.RemoveBannerConch  <- @() BannerScope.SetBanner(BANNER_NONE, BANNER_CONCH)
		hTank_scope.RemoveBannerBackup <- @() BannerScope.SetBanner(BANNER_NONE, BANNER_BACKUP)

		local flTimeNext = 0
		function Think()
		{
			if(iActiveBanners != 0 && flTime >= flTimeNext)
			{
				flTimeNext = flTime + 1
				for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, 450 * BANNERTANK_RANGE_MULT);)
					if
					(
						hPlayer.IsAlive() &&
						hPlayer.GetTeam() == iTeamNum &&
						!(hPlayer.InCond(TF_COND_DISGUISED) && hPlayer.GetDisguiseTeam() != iTeamNum) &&
						!hPlayer.IsStealthed()
					)
					{
						if(iActiveBanners & BANNER_BUFF) hPlayer.AddCondEx(TF_COND_OFFENSEBUFF, 1.2, self)
						if(iActiveBanners & BANNER_CONCH) hPlayer.AddCondEx(TF_COND_REGENONDAMAGEBUFF, 1.2, self)
						if(iActiveBanners & BANNER_BACKUP) hPlayer.AddCondEx(TF_COND_DEFENSEBUFF, 1.2, self)
					}
			}
		}
	}
})