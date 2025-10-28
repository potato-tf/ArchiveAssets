local STICKYTANK_VALUES_TABLE = {
	STICKYTANK_TURRET_MODEL             = "models/props_mvm/stickytankturret.mdl"
	STICKYTANK_SND_SHOOT_CRIT           = ")weapons/stickybomblauncher_shoot_crit.wav"
	STICKYTANK_SND_SHOOT                = ")weapons/stickybomblauncher_shoot.wav"
	STICKYTANK_PROJECTILE_MODEL         = "models/weapons/w_models/w_stickybomb_d.mdl"
	STICKYTANK_PROJECTILE_SPREAD        = 25
	STICKYTANK_PROJECTILE_SPLASH_RADIUS = 189
	STICKYTANK_PROJECTILE_SPEED         = 525
	STICKYTANK_PROJECTILE_DAMAGE        = 105
}
foreach(k,v in STICKYTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(STICKYTANK_TURRET_MODEL)
PrecacheModel(STICKYTANK_PROJECTILE_MODEL)
TankExt.PrecacheSound(STICKYTANK_SND_SHOOT)
TankExt.PrecacheSound(STICKYTANK_SND_SHOOT_CRIT)

TankExt.NewTankType("stickytank", {
	function OnSpawn()
	{
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
		local hModel    = SpawnEntityFromTableSafe("prop_dynamic", { origin = "-46 0 127.75", angles = "-55 0 0", model = STICKYTANK_TURRET_MODEL, skin = bBlueTeam ? 1 : 0 })
		TankExt.SetParentArray([hModel], self)
		local hMimic1   = SpawnEntityFromTableSafe("tf_point_weapon_mimic", {
			damage        = STICKYTANK_PROJECTILE_DAMAGE
			modelscale    = 1
			modeloverride = STICKYTANK_PROJECTILE_MODEL
			speedmax      = STICKYTANK_PROJECTILE_SPEED
			speedmin      = STICKYTANK_PROJECTILE_SPEED
			splashradius  = STICKYTANK_PROJECTILE_SPLASH_RADIUS
			weapontype    = 3
			spreadangle   = STICKYTANK_PROJECTILE_SPREAD
		})
		TankExt.SetParentArray([hMimic1], hModel, "muzzle_l")
		local hMimic2   = SpawnEntityFromTableSafe("tf_point_weapon_mimic", {
			damage        = STICKYTANK_PROJECTILE_DAMAGE
			modelscale    = 1
			modeloverride = STICKYTANK_PROJECTILE_MODEL
			speedmax      = STICKYTANK_PROJECTILE_SPEED
			speedmin      = STICKYTANK_PROJECTILE_SPEED
			splashradius  = STICKYTANK_PROJECTILE_SPLASH_RADIUS
			weapontype    = 3
			spreadangle   = STICKYTANK_PROJECTILE_SPREAD
		})
		TankExt.SetParentArray([hMimic2], hModel, "muzzle_r")

		local ShootStickies = function(iStickyCount = 1, bCrit = false)
		{
			if(!(hMimic1.IsValid() && hMimic2.IsValid() && self.IsValid())) return

			local sMultiple    = iStickyCount > 1 ? "FireMultiple" : "FireOnce"
			local sStickyCount = iStickyCount.tostring()
			SetPropBool(hMimic1, "m_bCrits", bCrit)
			SetPropBool(hMimic2, "m_bCrits", bCrit)
			hMimic1.AcceptInput(sMultiple, sStickyCount, null, null)
			hMimic2.AcceptInput(sMultiple, sStickyCount, null, null)
			EmitSoundEx({
				sound_name  = bCrit ? STICKYTANK_SND_SHOOT_CRIT : STICKYTANK_SND_SHOOT
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				sound_level = 82
			})
			TankExt.DispatchParticleEffectOn(hModel, "muzzle_bignasty", "muzzle_l")
			TankExt.DispatchParticleEffectOn(hModel, "muzzle_bignasty", "muzzle_r")
			TankExt.DispatchParticleEffectOn(hModel, "muzzle_minigun_core", "muzzle_l")
			TankExt.DispatchParticleEffectOn(hModel, "muzzle_minigun_core", "muzzle_r")

			local iTeamNum = self.GetTeam()
			foreach(hEnt in [hMimic1, hMimic2])
			{
				local vecOrigin = hEnt.GetOrigin()
				for(local hSticky; hSticky = FindByClassnameWithin(hSticky, "tf_projectile_pipe", vecOrigin, 1);)
					if(!GetPropEntity(hSticky, "m_hThrower"))
					{
						SetPropEntity(hSticky, "m_hThrower", self)
						hSticky.SetOwner(self)
						hSticky.SetTeam(iTeamNum)
						hSticky.SetSkin(iTeamNum == TF_TEAM_BLUE ? 1 : 0)
						hStickies.append(hSticky)
					}
			}
		}

		hStickies <- []
		local flTimeNext = Time() + 7
		function Think()
		{
			foreach(i, hSticky in hStickies)
				if(!hSticky.IsValid())
					hStickies.remove(i)

			if(flTime >= flTimeNext)
			{
				flTimeNext = flTime + 7
				ShootStickies()
				TankExt.DelayFunction(self, this, 0.1, ShootStickies )
				TankExt.DelayFunction(self, this, 0.2, ShootStickies )
				TankExt.DelayFunction(self, this, 0.3, ShootStickies )
				TankExt.DelayFunction(self, this, 0.4, ShootStickies )
				TankExt.DelayFunction(self, this, 0.5, function() { ShootStickies(4) })
				TankExt.DelayFunction(self, this, 0.6, ShootStickies)
				TankExt.DelayFunction(self, this, 0.7, ShootStickies)
				TankExt.DelayFunction(self, this, 0.8, ShootStickies)
				TankExt.DelayFunction(self, this, 0.9, ShootStickies)
				TankExt.DelayFunction(self, this, 1.0, function() { ShootStickies(4) })
				TankExt.DelayFunction(self, this, 1.5, function() { ShootStickies(1, true) })
				TankExt.DelayFunction(self, this, 2.0, function() { ShootStickies(2, true) })
				TankExt.DelayFunction(self, this, 2.5, function() { ShootStickies(3, true) })
				TankExt.DelayFunction(self, this, 3.0, function() { ShootStickies(6, true) })
				EntFireByHandle(hMimic1, "DetonateStickies", null, 6.5, null, null)
				EntFireByHandle(hMimic2, "DetonateStickies", null, 6.5, null, null)
			}
		}
	}
	function OnDeath()
	{
		foreach(hSticky in hStickies)
			if(hSticky.IsValid())
				hSticky.Kill()
	}
})