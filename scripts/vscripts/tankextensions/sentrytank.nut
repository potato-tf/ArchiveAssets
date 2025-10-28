local SENTRY_FLAG_INVULN        = 2
local SENTRY_FLAG_UPGRADABLE    = 4
local SENTRY_FLAG_INFINITE_AMMO = 8
local SENTRY_FLAG_MINI_SIGSEGV  = 64

local SENTRYTANK_VALUES_TABLE = {
	SENTRYTANK_MODEL                 = "models/bots/boss_bot/boss_tank_building.mdl"
	SENTRYTANK_MODEL_DAMAGE1         = "models/bots/boss_bot/boss_tank_building_damage1.mdl"
	SENTRYTANK_MODEL_DAMAGE2         = "models/bots/boss_bot/boss_tank_building_damage2.mdl"
	SENTRYTANK_MODEL_DAMAGE3         = "models/bots/boss_bot/boss_tank_building_damage3.mdl"
	SENTRYTANK_MODEL_TRACK_L         = "models/bots/boss_bot/tank_track_L_building.mdl"
	SENTRYTANK_MODEL_TRACK_R         = "models/bots/boss_bot/tank_track_R_building.mdl"
	SENTRYTANK_MODEL_BOMB            = "models/bots/boss_bot/bomb_mechanism_building.mdl"
	SENTRYTANK_SENTRY_HEALTH         = 4000
	SENTRYTANK_SENTRY_DEFAULTUPGRADE = 2
	SENTRYTANK_SENTRY_FLAGS          = SENTRY_FLAG_INFINITE_AMMO
}
foreach(k,v in SENTRYTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(SENTRYTANK_MODEL)
PrecacheModel(SENTRYTANK_MODEL_DAMAGE1)
PrecacheModel(SENTRYTANK_MODEL_DAMAGE2)
PrecacheModel(SENTRYTANK_MODEL_DAMAGE3)
PrecacheModel(SENTRYTANK_MODEL_TRACK_L)
PrecacheModel(SENTRYTANK_MODEL_TRACK_R)
PrecacheModel(SENTRYTANK_MODEL_BOMB)

TankExt.NewTankType("sentrytank", {
	Model = {
		Default     = SENTRYTANK_MODEL
		Damage1     = SENTRYTANK_MODEL_DAMAGE1
		Damage2     = SENTRYTANK_MODEL_DAMAGE2
		Damage3     = SENTRYTANK_MODEL_DAMAGE3
		LeftTrack   = SENTRYTANK_MODEL_TRACK_L
		RightTrack  = SENTRYTANK_MODEL_TRACK_R
		Bomb        = SENTRYTANK_MODEL_BOMB
	}
	function OnSpawn()
	{
		self.RemoveEFlags(EFL_DONTBLOCKLOS)
		local bModelHasAttachment = self.LookupAttachment("building_attachment") != 0
		local bBlueTeam = self.GetTeam() == TF_TEAM_BLUE
		if(self.GetModelName() == SENTRYTANK_MODEL) self.SetSkin(bBlueTeam ? 0 : 1)
		local hSentry = SpawnEntityFromTableSafe("obj_sentrygun",
		{
			origin         = bModelHasAttachment ? "0 0 2" : "-34 0 158"
			angles         = self.GetAbsAngles()
			defaultupgrade = SENTRYTANK_SENTRY_DEFAULTUPGRADE
			teamnum        = bBlueTeam ? 3 : 2
			spawnflags     = SENTRYTANK_SENTRY_FLAGS
			vscripts       = "tankextensions/misc/sentry_removesapper"
		})
		TankExt.SetParentArray([hSentry], self, bModelHasAttachment ? "building_attachment" : null)
		hSentry.SetLocalAngles(bModelHasAttachment ? QAngle(-90, 0, -90) : QAngle())
		hSentry.AcceptInput("SetHealth", SENTRYTANK_SENTRY_HEALTH.tostring(), null, null)
		function Think()
		{
			if(hSentry.IsValid())
				for(local hRocket; hRocket = FindByClassnameWithin(hRocket, "tf_projectile_sentryrocket", hSentry.GetAttachmentOrigin(2), 32);)
					if(!(hRocket.GetEFlags() & EFL_NO_MEGAPHYSCANNON_RAGDOLL) && hRocket.GetOwner() == hSentry)
					{
						hRocket.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
						local hTank = self
						TankExt.DelayFunction(hRocket, null, 0.2, @() self.SetOwner(hTank))
					}
		}

		local sUniqueName = UniqueString()
		local hTouch = SpawnEntityFromTableSafe("dispenser_touch_trigger", { targetname = sUniqueName, spawnflags = 1 })
		hTouch.SetSize(Vector(-512, -512, -128), Vector(512, 512, 384))
		hTouch.SetSolid(SOLID_BBOX)
		local hDisp = SpawnEntityFromTableSafe("mapobj_cart_dispenser", { touch_trigger = sUniqueName, origin = "0 8 0", angles = "0 90 0", defaultupgrade = 2, spawnflags = 4, teamnum = bBlueTeam ? TF_TEAM_BLUE : TF_TEAM_RED })
		EmitSoundEx({ entity = hDisp, sound_name = "misc/null.wav", filter_type = RECIPIENT_FILTER_GLOBAL, flags = SND_STOP | SND_IGNORE_NAME })
		TankExt.SetParentArray([hDisp], self, "smoke_attachment")

		local hTouchReal = SpawnEntityFromTableSafe("trigger_multiple", { spawnflags = 1 })
		TankExt.SetParentArray([hTouch, hTouchReal], self)
		SetPropEntity(hTouch, "m_pParent", null)
		SetPropEntity(hTouchReal, "m_pParent", null)
		hTouchReal.SetSize(Vector(-512, -512, -128), Vector(512, 512, 384))
		hTouchReal.SetSolid(SOLID_BBOX)
		local PlayersTouching = []
		hTouchReal.ValidateScriptScope()
		hTouchReal.ConnectOutput("OnStartTouch", "StartTouch")
		hTouchReal.ConnectOutput("OnEndTouch", "EndTouch")
		local hTouchReal_scope = hTouchReal.GetScriptScope()
		hTouchReal_scope.StartTouch <- function()
		{
			if(hDisp.GetTeam() == activator.GetTeam())
				PlayersTouching.append(activator)
		}
		hTouchReal_scope.EndTouch <- function()
		{
			local index = PlayersTouching.find(activator)
			if(index != null)
				PlayersTouching.remove(index)
		}
		hTouchReal_scope.Think <- function()
		{
			foreach(hPlayer in PlayersTouching)
				if(hPlayer.IsValid())
					hPlayer.AddCondEx(TF_COND_RADIUSHEAL, 0.2, null)
			return 0.1
		}
		AddThinkToEnt(hTouchReal, "Think")
	}
})