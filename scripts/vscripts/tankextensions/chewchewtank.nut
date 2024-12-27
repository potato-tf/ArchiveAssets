local CHEWCHEWTANK_VALUES_TABLE = {
	CHEWCHEWTANK_MODEL                = "models/lilchewchew/lilchewchew_v3.mdl"
	CHEWCHEWTANK_MODEL_WHEELS         = "models/lilchewchew/lilchewchew_wheels_v3.mdl"
	CHEWCHEWTANK_DAMAGE               = 1000
	CHEWCHEWTANK_FRIENDLY_FIRE        = true
	CHEWCHEWTANK_FUNCTION_CHOMP_SOUND = function()
	{
		local sSound = format(")mvm/melee_impacts/metal_gloves_hit_robo0%i.wav", RandomInt(1, 4))
		TankExt.PrecacheSound(sSound)
		EmitSoundEx({
			sound_name = sSound
			sound_level = 85
			entity = self
			filter_type = RECIPIENT_FILTER_GLOBAL
		})
	}
}
foreach(k,v in CHEWCHEWTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

::ChewChewTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::ChewChewTankEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hVictim = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss" && "ChewChewThink" in hAttacker.GetScriptScope())
			params.force_friendly_fire = CHEWCHEWTANK_FRIENDLY_FIRE
	}
}
__CollectGameEventCallbacks(ChewChewTankEvents)

TankExt.NewTankScript("chewchewtank", {
	DisableChildModels = 1
	DisableSmokestack = 1
	OnSpawn = function(hTank, sName, hPath)
	{
		local hTank_scope = hTank.GetScriptScope()
		hTank_scope.hTrack <- null
		hTank_scope.hBomb <- null
		for(local hChild = hTank.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
		{
			local sChildModel = hChild.GetModelName().tolower()
			if(sChildModel.find("track_r"))
				hTank_scope.hTrack = hChild
			else if(sChildModel.find("bomb_mechanism"))
				hTank_scope.hBomb = hChild
		}

		hTank_scope.hModel <- SpawnEntityFromTable("prop_dynamic", { origin = "40 0 0", defaultanim = "move", model = CHEWCHEWTANK_MODEL })
		hTank_scope.hWheels <- SpawnEntityFromTable("prop_dynamic", { origin = "40 0 0", defaultanim = "move", disableshadows = 1, model = CHEWCHEWTANK_MODEL_WHEELS })
		hTank_scope.hFakeBomb <- SpawnEntityFromTable("prop_dynamic", { origin = "44 0 -38", modelscale = 0.75, disableshadows = 1, model = hTank_scope.hBomb.GetModelName() })
		local hChomp = SpawnEntityFromTable("trigger_multiple", {
			origin = "152 0 66"
			spawnflags = 64
			OnStartTouch = "!selfRunScriptCodeself.GetRootMoveParent().GetScriptScope().Chomp(activator)0-1"
		})
		hChomp.SetSize(Vector(-40, -52, -66), Vector(40, 52, 66))
		hChomp.SetSolid(SOLID_BBOX)
		TankExt.SetParentArray([hTank_scope.hModel, hTank_scope.hWheels, hTank_scope.hFakeBomb, hChomp], hTank)

		hTank_scope.bDeploying <- false
		hTank_scope.Chomp <- function(hEnt)
		{
			if((hEnt.GetClassname() == "player" && !hEnt.IsMiniBoss() && (CHEWCHEWTANK_FRIENDLY_FIRE || hEnt.GetTeam() != self.GetTeam())) || startswith(hEnt.GetClassname(), "obj_"))
			{
				hModel.AcceptInput("SetAnimation", "chomp", null, null)
				EntFireByHandle(hModel, "SetAnimation", "move", 0.33, null, null)
				hEnt.TakeDamageEx(self, self, null, Vector(), Vector(), CHEWCHEWTANK_DAMAGE, DMG_VEHICLE)
				CHEWCHEWTANK_FUNCTION_CHOMP_SOUND()
			}
		}
		local iEmpty = PrecacheModel("models/empty.mdl")
		hTank_scope.ChewChewThink <- function()
		{
			// now i know this looks bad but theres no other reliable way to detect buildings
			hChomp.AcceptInput("Disable", null, null, null)
			hChomp.AcceptInput("Enable", null, null, null)

			// sync wheels with tank speed
			hWheels.SetPlaybackRate(hTrack.GetPlaybackRate() * 0.83)
			if(!bDeploying && hBomb.GetSequenceName(hBomb.GetSequence()) == "deploy")
			{
				bDeploying = true
				hFakeBomb.AcceptInput("SetAnimation", "deploy", null, null)
			}
			SetPropIntArray(self, "m_nModelIndexOverrides", iEmpty, 0)
			SetPropIntArray(self, "m_nModelIndexOverrides", iEmpty, 3)
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "ChewChewThink")
	}
})