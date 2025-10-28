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
			sound_name  = sSound
			sound_level = 85
			entity      = self
			filter_type = RECIPIENT_FILTER_GLOBAL
		})
	}
}
foreach(k,v in CHEWCHEWTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

PrecacheModel(CHEWCHEWTANK_MODEL)
PrecacheModel(CHEWCHEWTANK_MODEL_WHEELS)

::ChewChewTankEvents <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) delete ::ChewChewTankEvents }
	function OnScriptHook_OnTakeDamage(params)
	{
		local hVictim   = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss")
		{
			local hAttacker_scope = hAttacker.GetScriptScope()
			local ChewChewScope   = TankExt.GetMultiScopeTable(hAttacker_scope, "chewchewtank")
			if(ChewChewScope)
				params.force_friendly_fire = CHEWCHEWTANK_FRIENDLY_FIRE
		}
	}
}
__CollectGameEventCallbacks(ChewChewTankEvents)

TankExt.NewTankType("chewchewtank", {
	DisableChildModels     = 1
	DisableSmokestack      = 1
	NoDestructionModel     = 1
	ReplaceModelCollisions = 1
	EngineLoopSound        = ")ambient/machines/train_freight_loop2.wav"
	Model = {
		Visual = "models/empty.mdl"
	}
	function OnSpawn()
	{
		self.SetSize(Vector(-110, -50, 0), Vector(114, 50, 150))

		local hTrack = null
		local hBomb  = null
		for(local hChild = self.FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().tolower().find("track_r"))
				{ hTrack = hChild; break }

		local hModel    = SpawnEntityFromTableSafe("prop_dynamic", { origin = "40 0 0", defaultanim = "move", model = CHEWCHEWTANK_MODEL })
		local hWheels   = SpawnEntityFromTableSafe("prop_dynamic", { origin = "40 0 0", defaultanim = "move", disableshadows = 1, model = CHEWCHEWTANK_MODEL_WHEELS })
		local hParticle = SpawnEntityFromTableSafe("info_particle_system", { origin = "64 0 192", start_active = 1, effect_name = "smoke_train" })
		local hFakeBomb = SpawnEntityFromTableSafe("prop_dynamic", { origin = "44 0 -38", modelscale = 0.75, disableshadows = 1, model = "models/bots/boss_bot/bomb_mechanism.mdl" })
		local hChomp    = SpawnEntityFromTableSafe("trigger_multiple", {
			origin       = "152 0 66"
			spawnflags   = 64
			OnStartTouch = "!selfRunScriptCodeChomp(activator)-1-1"
		})
		hChomp.SetSize(Vector(-40, -48, -66), Vector(40, 48, 66))
		hChomp.SetSolid(SOLID_BBOX)
		hChomp.ValidateScriptScope()

		local hTank     = self
		local ChewScope = this
		hChomp.GetScriptScope().Chomp <- function(hEnt)
		{
			if((hEnt.IsPlayer() && !hEnt.IsMiniBoss() && (CHEWCHEWTANK_FRIENDLY_FIRE || hEnt.GetTeam() != hTank.GetTeam())) || HasProp(hEnt, "m_iObjectType"))
			{
				hModel.AcceptInput("SetAnimation", "chomp", null, null)
				EntFireByHandle(hModel, "SetAnimation", ChewScope.bDeploying ? "idle" : "move", 0.33, null, null)
				hEnt.TakeDamageEx(hTank, hTank, null, Vector(), Vector(), CHEWCHEWTANK_DAMAGE, DMG_VEHICLE)
				CHEWCHEWTANK_FUNCTION_CHOMP_SOUND()
			}
		}

		TankExt.SetParentArray([hModel, hWheels, hParticle, hFakeBomb, hChomp], self)
		SetPropEntity(hChomp, "m_pParent", null)

		function Think()
		{
			// now i know this looks bad but theres no other reliable way to detect buildings
			hChomp.AcceptInput("Disable", null, null, null)
			hChomp.AcceptInput("Enable", null, null, null)

			// sync wheels with tank speed
			hWheels.SetPlaybackRate(hTrack.GetPlaybackRate() * 0.83)
		}
		function OnStartDeploy()
		{
			hFakeBomb.AcceptInput("SetAnimation", "deploy", null, null)
			hModel.AcceptInput("SetAnimation", "idle", null, null)
		}
	}
})