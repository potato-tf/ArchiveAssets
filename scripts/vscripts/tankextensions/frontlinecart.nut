local FRONTLINECART_VALUES_TABLE = {
	FRONTLINECART_MODEL                  = "models/props_frontline/tank_cart.mdl"
	FRONTLINECART_FIRE_RATE_BONUS        = 1
	FRONTLINECART_RANGE                  = 1024
	FRONTLINECART_CLOSE_RANGE            = 256
	FRONTLINECART_CLOSE_RANGE_SPEED_MULT = 0.2

	FRONTLINECART_ROCKET_MODEL   = "models/weapons/w_models/w_rocket.mdl"
	FRONTLINECART_ROCKET_SOUND   = ")player/taunt_tank_shoot.wav"
	FRONTLINECART_ROCKET_DAMAGE  = 150
	FRONTLINECART_ROCKET_SPEED   = 1100
	FRONTLINECART_ROCKET_SPLASH  = 146
	FRONTLINECART_ROCKET_GRAVITY = 200 // hu/s^2

	FRONTLINECART_GRENADE_MODEL  = "models/weapons/w_models/w_grenade_grenadelauncher.mdl"
	FRONTLINECART_GRENADE_DAMAGE = 150
	FRONTLINECART_GRENADE_SPEED  = 1100
	FRONTLINECART_GRENADE_SPLASH = 225
	FRONTLINECART_GRENADE_SOUND  = ")mvm/giant_demoman/giant_demoman_grenade_shoot.wav"

	FRONTLINECART_JAR_SPEED = 1000
	FRONTLINECART_JAR_SOUND = ")mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
}
foreach(k,v in FRONTLINECART_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(FRONTLINECART_MODEL)
PrecacheModel(FRONTLINECART_ROCKET_MODEL)
PrecacheModel(FRONTLINECART_GRENADE_MODEL)
TankExt.PrecacheSound(FRONTLINECART_ROCKET_SOUND)
TankExt.PrecacheSound(FRONTLINECART_GRENADE_SOUND)
TankExt.PrecacheSound(FRONTLINECART_JAR_SOUND)

TankExt.NewTankType("frontlinecart*", {
	DisableChildModels = 1
	DisableSmokestack  = 1
	Scale              = 0.5
	NoDestructionModel = 1
	Model              = {
		Visual = "models/empty.mdl"
	}
	function OnSpawn()
	{
		local bFinalSkin = self.GetSkin() == 1
		local bBlueTeam  = self.GetTeam() == TF_TEAM_BLUE
		local hModel     = SpawnEntityFromTableSafe("prop_dynamic", { angles = "0 180 0", defaultanim = "idle", model = FRONTLINECART_MODEL, skin = bBlueTeam ? bFinalSkin ? 2 : 0 : bFinalSkin ? 3 : 1 })
		local hFakeBomb  = SpawnEntityFromTableSafe("prop_dynamic", { origin = "-8 0 -16", modelscale = 0.5, model = "models/bots/boss_bot/bomb_mechanism.mdl", startdisabled = 1 })
		local hWeapon    = SpawnEntityFromTableSafe("tf_point_weapon_mimic", {
			angles     = QAngle(0, 90, 0)
			modelscale = 1
		})
		TankExt.SetParentArray([hModel, hFakeBomb], self)
		TankExt.SetParentArray([hWeapon], hModel, "fire")
		TankExt.DispatchParticleEffectOn(hModel, bBlueTeam ? "cart_flashinglight" : "cart_flashinglight_red", "light")
		TankExt.DispatchParticleEffectOn(hModel, "taunt_heavy_table_steam", "exhaust_smoke")

		local sUniqueName = UniqueString()
		local hTouch = SpawnEntityFromTableSafe("dispenser_touch_trigger", { targetname = sUniqueName, spawnflags = 1 })
		hTouch.SetSize(Vector(-224, -224, 0), Vector(224, 224, 96))
		hTouch.SetSolid(SOLID_BBOX)
		local hDisp = SpawnEntityFromTableSafe("mapobj_cart_dispenser", { touch_trigger = sUniqueName, origin = "12.5 19 -1", angles = "-90 0 0", defaultupgrade = 2, spawnflags = 4, teamnum = bBlueTeam ? TF_TEAM_BLUE : TF_TEAM_RED })
		EmitSoundEx({ entity = hDisp, sound_name = "misc/null.wav", filter_type = RECIPIENT_FILTER_GLOBAL, flags = SND_STOP | SND_IGNORE_NAME })
		TankExt.SetParentArray([hTouch], self)
		SetPropEntity(hTouch, "m_pParent", null)
		TankExt.SetParentArray([hDisp], hModel, "light")

		local PROJECTILE_ROCKET  = 0
		local PROJECTILE_GRENADE = 1
		local PROJECTILE_JARATE  = 2
		local PROJECTILE_MILK    = 3
		local PROJECTILE_GAS     = 4
		local Redefinitions = {
			"none"    : -1
			"rocket"  : PROJECTILE_ROCKET
			"grenade" : PROJECTILE_GRENADE
			"jarate"  : PROJECTILE_JARATE
			"milk"    : PROJECTILE_MILK
			"gas"     : PROJECTILE_GAS
		}

		local Params = split(sTankName, "|")
		local iParamsLength = Params.len()
		if(iParamsLength <= 1) Params.append("rocket")
		if(iParamsLength <= 2) Params.append("none")
		iProjectileType <- Redefinitions[Params[1]]
		iProjectileTypeClose <- Redefinitions[Params[2]]

		local MakeOutlinedModel = function(sModel, flModelScale, vecOrigin)
		{
			local hEnt = CreateByClassnameSafe("obj_teleporter")
			hEnt.SetAbsOrigin(vecOrigin)
			hEnt.SetAbsAngles(QAngle(180))
			hEnt.DispatchSpawn()
			PrecacheModel(sModel), hEnt.SetModel(sModel)
			hEnt.SetModelScale(flModelScale, -1)
			hEnt.AddEFlags(EFL_NO_THINK_FUNCTION)
			hEnt.SetSolid(SOLID_NONE)
			hEnt.SetTeam(bBlueTeam ? TF_TEAM_BLUE : TF_TEAM_RED)
			SetPropBool(hEnt, "m_bGlowEnabled", true)
			SetPropString(hEnt, "m_iClassname", "prop_dynamic")
			return hEnt
		}

		if(iProjectileType == PROJECTILE_JARATE)
		{
			local hProp = MakeOutlinedModel("models/weapons/c_models/urinejar.mdl", 4.5, Vector(9, 8.2, 0))
			TankExt.SetParentArray([hProp], hModel, "light")
		}
		if(iProjectileType == PROJECTILE_MILK)
		{
			local hProp = MakeOutlinedModel("models/weapons/c_models/c_madmilk/c_madmilk.mdl", 5, Vector(9, 8.2, -11))
			TankExt.SetParentArray([hProp], hModel, "light")
		}
		if(iProjectileType == PROJECTILE_GAS)
		{
			local hProp = MakeOutlinedModel("models/props_farm/oilcan01.mdl", 0.6, Vector(9, 8.2, 15))
			hProp.SetSkin(bBlueTeam ? 1 : 0)
			TankExt.SetParentArray([hProp], hModel, "light")
		}

		local bCrit = Params[0].find("_crit") ? true : false
		local Shoot = function(bCloseRange)
		{
			if(!(hWeapon && hWeapon.IsValid())) return
			local iType = bCloseRange ? iProjectileTypeClose : iProjectileType
			local ApplyToProjectile = function(hEnt)
			{
				MarkForPurge(hEnt)
				hEnt.SetSolid(SOLID_BSP)
				hEnt.SetTeam(iTeamNum)
				hEnt.SetOwner(self)
				hEnt.SetSkin(iTeamNum == TF_TEAM_BLUE ? 1 : 0)
				SetPropBool(hEnt, "m_bCritical", bCrit)

				hEnt.ValidateScriptScope()
				local hEnt_scope = hEnt.GetScriptScope()

				// did you know the gas passer requires a player to spawn the gas cloud? its true!
				local hThrower = self
				if(iType == PROJECTILE_GAS)
				{
					for(local i = 1; i <= MAX_CLIENTS; i++)
					{
						local hPlayer = PlayerInstanceFromIndex(i)
						if(hPlayer && hPlayer.GetTeam() == iTeamNum)
							{ hThrower = hPlayer; break }
					}
					local hTank    = self
					local iTeamNum = iTeamNum
					hEnt_scope.bDeflected <- false
					TankExt.SetDestroyCallback(hEnt, function()
					{
						if(bDeflected) return

						local vecOrigin = self.GetOrigin()
						local flDuration = 10 - FrameTime()

						for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, 768);)
							if(hPlayer.GetTeam() != iTeamNum && hPlayer.GetCondDuration(TF_COND_GAS) == flDuration)
								hPlayer.AddCondEx(TF_COND_GAS, flDuration, hTank)

						for(local hGas; hGas = FindByClassnameWithin(hGas, "tf_gas_manager", vecOrigin, 32);)
							if(GetPropInt(hGas, "touchStamp") <= 1)
								hGas.SetOwner(hTank)
					})
				}
				SetPropEntity(hEnt, "m_hThrower", hThrower)

				if(iType == PROJECTILE_ROCKET) hEnt.SetSize(Vector(), Vector())

				local hTank  = self
				local iType  = iType
				local bSolid = false
				hEnt_scope.Think <- function()
				{
					if(!self.IsValid()) return
					local vecOrigin = self.GetOrigin()
					if(!bSolid && (!hTank.IsValid() || !TankExt.IntersectionBoxBox(vecOrigin, self.GetBoundingMins(), self.GetBoundingMaxs(), hTank.GetOrigin(), hTank.GetBoundingMins(), hTank.GetBoundingMaxs())))
						{ bSolid = true; self.SetSolid(SOLID_BBOX) }

					if(iType == PROJECTILE_ROCKET)
					{
						self.ApplyAbsVelocityImpulse(Vector(0, 0, -FRONTLINECART_ROCKET_GRAVITY * FrameTime()))
						self.SetForwardVector(self.GetAbsVelocity())
					}
					else if(iType == PROJECTILE_GAS && GetPropInt(self, "m_iDeflected"))
						bDeflected = true
					return -1
				}
				TankExt.AddThinkToEnt(hEnt, "Think")
			}

			local Sound = @(sSound) EmitSoundEx({
				sound_name  = sSound
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				sound_level = 94
			})
			local flSpeedMult = bCloseRange ? FRONTLINECART_CLOSE_RANGE_SPEED_MULT : 1

			if(iType <= PROJECTILE_GRENADE)
			{
				if(iType == PROJECTILE_ROCKET)
				{
					Sound(FRONTLINECART_ROCKET_SOUND)
					hWeapon.KeyValueFromInt("weapontype", PROJECTILE_ROCKET)
					hWeapon.KeyValueFromInt("damage", FRONTLINECART_ROCKET_DAMAGE)
					hWeapon.KeyValueFromString("modeloverride", FRONTLINECART_ROCKET_MODEL)
					hWeapon.KeyValueFromFloat("speedmax", FRONTLINECART_ROCKET_SPEED * flSpeedMult)
					hWeapon.KeyValueFromFloat("speedmin", FRONTLINECART_ROCKET_SPEED * flSpeedMult)
					hWeapon.KeyValueFromFloat("splashradius", FRONTLINECART_ROCKET_SPLASH)
				}
				else
				{
					Sound(FRONTLINECART_GRENADE_SOUND)
					hWeapon.KeyValueFromInt("weapontype", PROJECTILE_GRENADE)
					hWeapon.KeyValueFromInt("damage", FRONTLINECART_GRENADE_DAMAGE)
					hWeapon.KeyValueFromString("modeloverride", FRONTLINECART_GRENADE_MODEL)
					hWeapon.KeyValueFromFloat("speedmax", FRONTLINECART_GRENADE_SPEED * flSpeedMult)
					hWeapon.KeyValueFromFloat("speedmin", FRONTLINECART_GRENADE_SPEED * flSpeedMult)
					hWeapon.KeyValueFromFloat("splashradius", FRONTLINECART_GRENADE_SPLASH)
				}

				hWeapon.AcceptInput("FireOnce", null, null, null)
				DispatchParticleEffect("rocketbackblast", hWeapon.GetOrigin(), hWeapon.GetForwardVector())

				for(local hEnt; hEnt = FindByClassnameWithin(hEnt, "tf_projectile_*", hWeapon.GetOrigin(), 64);)
				{
					if(hEnt.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL || (hEnt.GetOwner() != hWeapon && GetPropEntity(hEnt, "m_hThrower") != null)) continue
					hEnt.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
					ApplyToProjectile(hEnt)
				}
			}
			else
			{
				Sound(FRONTLINECART_JAR_SOUND)
				local sClassname = "tf_projectile_jar"
				switch(iType)
				{
					case PROJECTILE_JARATE : sClassname = "tf_projectile_jar"; break
					case PROJECTILE_MILK   : sClassname = "tf_projectile_jar_milk"; break
					case PROJECTILE_GAS    : sClassname = "tf_projectile_jar_gas"; break
				}
				local hEnt = CreateByClassnameSafe(sClassname)
				hEnt.SetAbsOrigin(hWeapon.GetOrigin())
				hEnt.SetAbsAngles(hWeapon.GetAbsAngles())
				hEnt.DispatchSpawn()
				hEnt.SetPhysVelocity(hWeapon.GetForwardVector() * FRONTLINECART_JAR_SPEED * flSpeedMult + Vector(0, 0, 200))
				hEnt.SetPhysAngularVelocity(Vector(500, 0, 0))
				ApplyToProjectile(hEnt)
			}
		}

		local flAngleE  = -45 - 22.5
		local flAngleNE = -22.5
		local flAngleN  = 0
		local flAngleNW = 22.5
		local flAngleW  = 45 + 22.5

		local flTimeFire = Time() + 2
		function Think()
		{
			EmitSoundEx({
				sound_name  = "misc/null.wav"
				pitch       = 105
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_CHANGE_PITCH | SND_IGNORE_NAME
			})

			if(bDeploying) return

			local hTarget
			local flAngle = 0
			local flDist  = FRONTLINECART_RANGE
			for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, flDist);)
			{
				if(!hPlayer.IsAlive() || TankExt.IsPlayerStealthedOrDisguised(hPlayer) || hPlayer.GetTeam() == iTeamNum) continue
				local vecDist = hPlayer.GetOrigin() - vecOrigin
				flAngle = (TankExt.VectorAngles(vecDist) - angRotation).y
				if(fabs(flAngle) > 90 + 22.5) continue
				hTarget = hPlayer
				flDist  = vecDist.Length()
			}

			local bCloseRange = false
			if(iProjectileTypeClose > -1)
				if(flDist < FRONTLINECART_CLOSE_RANGE)
					bCloseRange = true

			if(hTarget && hWeapon.IsValid() && flTime >= flTimeFire)
			{
				local sSeq = "shoot_N"
				if(flAngle >= flAngleW)
					sSeq = "shoot_W"
				else if(flAngle >= flAngleNW)
					sSeq = "shoot_NW"
				else if(flAngle <= flAngleE)
					sSeq = "shoot_E"
				else if(flAngle <= flAngleNE)
					sSeq = "shoot_NE"

				hModel.AcceptInput("SetAnimation", sSeq, null, null)
				hModel.SetPlaybackRate(1.0 / FRONTLINECART_FIRE_RATE_BONUS)
				TankExt.DelayFunction(self, this, 0.5 * FRONTLINECART_FIRE_RATE_BONUS, function() { Shoot(bCloseRange) } )
				flTimeFire = flTime + 1.6 * FRONTLINECART_FIRE_RATE_BONUS
			}
		}
		function OnStartDeploy()
		{
			hModel.AcceptInput("SetAnimation", "reload", null, null)
			hFakeBomb.AcceptInput("Enable", null, null, null)
			hFakeBomb.AcceptInput("SetAnimation", "deploy", null, null)
			EntFireByHandle(hModel, "SetPlaybackRate", "0", 0.5, null, null)
		}
	}
})