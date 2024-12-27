local DRILLTANK_VALUES_TABLE = {
	DRILLTANK_MODEL_DRILL            = "models/bots/boss_bot/tank_drill.mdl"
	DRILLTANK_DAMAGE                 = 50
	DRILLTANK_DAMAGE_DELAY           = 0.33
	DRILLTANK_DAMAGE_SPEED_PENALTY   = 0.25
	DRILLTANK_DAMAGE_DEBUFF_DURATION = 1
	DRILLTANK_FRIENDLY_FIRE          = false
	DRILLTANK_SOUND_SPIN             = ")ambient/sawblade.wav"
	DRILLTANK_FUNCTION_SOUND_HURT    = function()
	{
		local sSound = format(")ambient/sawblade_impact%i.wav", RandomInt(1, 2))
		TankExt.PrecacheSound(sSound)
		EmitSoundEx({
			sound_name = sSound
			sound_level = 85
			pitch = 90
			entity = self
			filter_type = RECIPIENT_FILTER_GLOBAL
		})
	}
}
foreach(k,v in DRILLTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(DRILLTANK_SOUND_SPIN)

::DrillTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::DrillTankEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hVictim = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss" && "DrillThink" in hAttacker.GetScriptScope())
			params.force_friendly_fire = DRILLTANK_FRIENDLY_FIRE
	}
}
__CollectGameEventCallbacks(DrillTankEvents)

TankExt.NewTankScript("drilltank", {
	OnSpawn = function(hTank, sName, hPath)
	{
		EmitSoundEx({
			sound_name = DRILLTANK_SOUND_SPIN
			sound_level = 80
			pitch = 85
			entity = hTank
			filter_type = RECIPIENT_FILTER_GLOBAL
		})

		local hTank_scope = hTank.GetScriptScope()
		hTank_scope.hBomb <- null
		for(local hChild = hTank.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if(sChildModel.find("bomb_mechanism"))
				hTank_scope.hBomb = hChild
		}

		local bFinalSkin = hTank.GetSkin() & 1
		local bBlueTeam = hTank.GetTeam() == 3
		hTank_scope.hModel <- SpawnEntityFromTable("prop_dynamic", { model = DRILLTANK_MODEL_DRILL, skin = (bBlueTeam ? 0 : 4) + (bFinalSkin ? 2 : 0)})
		hTank_scope.hModel.AcceptInput("SetAnimation", "drill_spin", null, null)
		hTank_scope.hDrillHurt <- SpawnEntityFromTable("trigger_multiple", {
			origin = "162 0 97"
			spawnflags = 64
			OnStartTouch = "!selfRunScriptCodeself.GetRootMoveParent().GetScriptScope().Drill(activator)0-1"
		})
		hTank_scope.hDrillHurt.SetSize(Vector(-46, -40, -40), Vector(46, 40, 40))
		hTank_scope.hDrillHurt.SetSolid(SOLID_BBOX)
		TankExt.SetParentArray([hTank_scope.hModel, hTank_scope.hDrillHurt], hTank)

		hTank_scope.bDeploying <- false
		hTank_scope.Drill <- function(hEnt)
		{
			if((hEnt.GetClassname() == "player" && (DRILLTANK_FRIENDLY_FIRE || hEnt.GetTeam() != self.GetTeam())))
			{
				hDrillHurt.AcceptInput("Disable", null, null, null)
				EntFireByHandle(hDrillHurt, "Enable", null, DRILLTANK_DAMAGE_DELAY, null, null)
				hEnt.TakeDamageEx(self, self, null, Vector(), Vector(), DRILLTANK_DAMAGE, DMG_CLUB)
				hEnt.SetAbsVelocity(Vector())
				hEnt.BleedPlayer(DRILLTANK_DAMAGE_DEBUFF_DURATION)
				hEnt.StunPlayer(DRILLTANK_DAMAGE_DEBUFF_DURATION, 1 - DRILLTANK_DAMAGE_SPEED_PENALTY, 1, self)
				DRILLTANK_FUNCTION_SOUND_HURT()
			}
		}
		hTank_scope.DrillThink <- function()
		{
			if(!bDeploying && hBomb.GetSequenceName(hBomb.GetSequence()) == "deploy")
			{
				bDeploying = true
				hModel.AcceptInput("SetAnimation", "drill_deploy", null, null)
				hDrillHurt.Kill()
				EmitSoundEx({
					sound_name = DRILLTANK_SOUND_SPIN
					entity = self
					filter_type = RECIPIENT_FILTER_GLOBAL
					flags = 4
				})
			}
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "DrillThink")
		SetDestroyCallback(hTank, function()
		{
			EmitSoundEx({
				sound_name = DRILLTANK_SOUND_SPIN
				entity = self
				filter_type = RECIPIENT_FILTER_GLOBAL
				flags = 4
			})
		})
	}
})