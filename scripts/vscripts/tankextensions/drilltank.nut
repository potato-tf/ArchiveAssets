local DRILLTANK_VALUES_TABLE = {
	DRILLTANK_MODEL_DRILL            = "models/bots/boss_bot/tank_drill.mdl"
	DRILLTANK_DAMAGE                 = 10
	DRILLTANK_DAMAGE_DELAY           = 0.05
	DRILLTANK_DAMAGE_SPEED_PENALTY   = 0.3
	DRILLTANK_DAMAGE_DEBUFF_DURATION = 1
	DRILLTANK_FRIENDLY_FIRE          = true
	DRILLTANK_SOUND_SPIN             = ")ambient/sawblade.wav"
}
foreach(k,v in DRILLTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(DRILLTANK_MODEL_DRILL)
TankExt.PrecacheSound(DRILLTANK_SOUND_SPIN)
PrecacheSound(")physics/metal/canister_scrape_smooth_loop1.wav")

::DrillTankEvents <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) delete ::DrillTankEvents }
	function OnScriptHook_OnTakeDamage(params)
	{
		local hVictim   = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss")
		{
			local DrillScope = TankExt.GetMultiScopeTable(hAttacker.GetScriptScope(), "drilltank")
			if(DrillScope) params.force_friendly_fire = DRILLTANK_FRIENDLY_FIRE
		}
	}
}
__CollectGameEventCallbacks(DrillTankEvents)

TankExt.NewTankType("drilltank", {
	function OnSpawn()
	{
		EmitSoundEx({
			sound_name  = DRILLTANK_SOUND_SPIN
			sound_level = 80
			pitch       = 90
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		local bFinalSkin = self.GetSkin() == 1
		local bBlueTeam  = self.GetTeam() == TF_TEAM_BLUE
		local iSkin      = bBlueTeam ? bFinalSkin ? 2 : 0 : bFinalSkin ? 6 : 4
		local hModel     = SpawnEntityFromTableSafe("prop_dynamic", { model = DRILLTANK_MODEL_DRILL, skin = iSkin })
		hModel.AcceptInput("SetAnimation", "drill_spin", null, null)
		local hDrillHurt = SpawnEntityFromTableSafe("trigger_multiple", {
			origin       = "162 0 97"
			spawnflags   = 1
		})
		hDrillHurt.SetSize(Vector(-46, -40, -40), Vector(46, 40, 40))
		hDrillHurt.SetSolid(SOLID_OBB)
		hDrillHurt.ConnectOutput("OnStartTouch", "StartTouch")
		hDrillHurt.ConnectOutput("OnEndTouch", "EndTouch")
		TankExt.SetParentArray([hModel, hDrillHurt], self)

		local hTank     = self
		local hTouching = {}
		hDrillHurt.ValidateScriptScope()
		hDrillHurt.GetScriptScope().StartTouch <- function()
		{
			local iPlayerTeamNum = activator.GetTeam()
			if(DRILLTANK_FRIENDLY_FIRE || iPlayerTeamNum != hTank.GetTeam())
			{
				if(hTouching.len() == 0)
				{
					EmitSoundEx({
						sound_name  = DRILLTANK_SOUND_SPIN
						sound_level = 80
						pitch       = 80
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
						flags       = SND_CHANGE_PITCH
					})
					EmitSoundEx({
						sound_name  = ")physics/metal/canister_scrape_smooth_loop1.wav"
						sound_level = 85
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
				}
				hTouching[activator] <- iPlayerTeamNum
			}
		}
		hDrillHurt.GetScriptScope().EndTouch <- function()
		{
			if(activator in hTouching)
			{
				delete hTouching[activator]
				if(hTouching.len() == 0)
				{
					EmitSoundEx({
						sound_name  = DRILLTANK_SOUND_SPIN
						sound_level = 80
						pitch       = 90
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
						flags       = SND_CHANGE_PITCH
					})
					EmitSoundEx({
						sound_name  = ")physics/metal/canister_scrape_smooth_loop1.wav"
						entity      = hTank
						filter_type = RECIPIENT_FILTER_GLOBAL
						flags       = SND_STOP
					})
				}
			}
		}

		local flTimeDrillLast = 0
		function Think()
		{
			local iDrillSkin = hModel.GetSkin()
			if(iHealth / iMaxHealth.tofloat() <= 0.5) { if(iDrillSkin != iSkin + 1) hModel.SetSkin(iSkin + 1) }
			else if(iDrillSkin != iSkin) hModel.SetSkin(iSkin)

			if(flTime >= flTimeDrillLast)
			{
				flTimeDrillLast = flTime + DRILLTANK_DAMAGE_DELAY
				local bPlayDrillSound = false

				foreach(hPlayer, iPlayerTeamNum in hTouching)
					if(hPlayer.IsValid())
					{
						bPlayDrillSound = true
						hPlayer.TakeDamageEx(self, self, null, Vector(), Vector(), DRILLTANK_DAMAGE, DMG_CRUSH)
						hPlayer.SetAbsVelocity(hPlayer.GetAbsVelocity() * 0.75)
						hPlayer.BleedPlayer(DRILLTANK_DAMAGE_DEBUFF_DURATION)
						hPlayer.StunPlayer(DRILLTANK_DAMAGE_DEBUFF_DURATION, 1 - DRILLTANK_DAMAGE_SPEED_PENALTY, 1, null)
					}
					else delete hTouching[hPlayer]
			}
		}
		function OnStartDeploy()
		{
			hModel.AcceptInput("SetAnimation", "drill_deploy", null, null)
			hDrillHurt.Kill()
			hTouching.clear()
			EmitSoundEx({
				sound_name  = DRILLTANK_SOUND_SPIN
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_STOP
			})
			EmitSoundEx({
				sound_name  = ")physics/metal/canister_scrape_smooth_loop1.wav"
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags       = SND_STOP
			})
		}
	}
	function OnDeath()
	{
		EmitSoundEx({
			sound_name  = "misc/null.wav"
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
			flags       = SND_STOP | SND_IGNORE_NAME
		})
	}
})