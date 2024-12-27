local HAMMERTANK_VALUES_TABLE = {
	HAMMERTANK_MODEL_HAMMER  = "models/props_halloween/hammer_mechanism.mdl"
	HAMMERTANK_DAMAGE        = 2500
	HAMMERTANK_FRIENDLY_FIRE = false
	HAMMERTANK_COOLDOWN      = 2.6
}
foreach(k,v in HAMMERTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

::HammerTankEvents <- {
	OnGameEvent_recalculate_holidays = function(_) { if(GetRoundState() == 3) delete ::HammerTankEvents }
	OnScriptHook_OnTakeDamage = function(params)
	{
		local hVictim = params.const_entity
		local hAttacker = params.attacker
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss" && "HammerThink" in hAttacker.GetScriptScope())
		{
			if(!("HAMMERTANK_KILL_ICON" in ROOT) || !HAMMERTANK_KILL_ICON || !HAMMERTANK_KILL_ICON.IsValid())
				::HAMMERTANK_KILL_ICON <- SpawnEntityFromTable("info_target", { classname = "necro_smasher" })
			params.force_friendly_fire = HAMMERTANK_FRIENDLY_FIRE
			params.inflictor = HAMMERTANK_KILL_ICON
			HAMMERTANK_KILL_ICON.SetAbsOrigin(hAttacker.GetScriptScope().vecSmash)
		}
	}
}
__CollectGameEventCallbacks(HammerTankEvents)

TankExt.PrecacheSound("misc/halloween/strongman_fast_swing_01.wav")
TankExt.PrecacheSound("misc/halloween/strongman_fast_whoosh_01.wav")
TankExt.PrecacheSound("misc/halloween/strongman_fast_impact_01.wav")
TankExt.PrecacheSound("ambient/explosions/explode_1.wav")
TankExt.PrecacheSound("doors/vent_open2.wav")

TankExt.NewTankScript("hammertank", {
	OnSpawn = function(hTank, sName, hPath)
	{
		local hTank_scope = hTank.GetScriptScope()
		local hHammer = SpawnEntityFromTable("prop_dynamic", {
			model          = HAMMERTANK_MODEL_HAMMER
			origin         = "-143 48 -28"
			angles         = "-30 0 0"
			modelscale     = 0.6
			disableshadows = 1
		})
		TankExt.SetParentArray([hHammer], hTank)
		hTank_scope.bSmashing <- false
		hTank_scope.vecSmash <- Vector()
		hTank_scope.SmashImpact <- function()
		{
			EmitSoundEx({
				sound_name = "ambient/explosions/explode_1.wav"
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			EmitSoundEx({
				sound_name = "misc/halloween/strongman_fast_impact_01.wav"
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			DispatchParticleEffect("hammer_impact_button", vecSmash, Vector(1, 0, 0))
			ScreenShake(vecSmash, 9, 2.5, 3, 1500, 0, true)

			local iTeamNum = self.GetTeam()
			for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecSmash, 384);)
				if(hPlayer.IsAlive() && (HAMMERTANK_FRIENDLY_FIRE || hPlayer.GetTeam() != iTeamNum))
				{
					local vecTowards = hPlayer.GetOrigin() - vecSmash
					local flDist = vecTowards.Length()
					vecTowards.Norm()
					hPlayer.ApplyAbsVelocityImpulse(vecTowards * 200 + Vector(0, 0, 500))
					if(flDist < 128)
						hPlayer.TakeDamageEx(self, self, null, Vector(), Vector(), HAMMERTANK_DAMAGE, DMG_CRUSH)
				}
		}
		hTank_scope.HammerThink <- function()
		{
			vecSmash = self.GetOrigin() + self.GetForwardVector() * 352 + self.GetRightVector() * -48
			local iTeamNum = self.GetTeam()
			if(!bSmashing)
				for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecSmash, 256);)
					if(hPlayer.IsAlive() && hPlayer.GetTeam() != iTeamNum)
					{
						bSmashing = true
						local DelayCode = @(delay, string) EntFireByHandle(self, "RunScriptCode", string, delay, null, null)
						hHammer.AcceptInput("SetAnimation", "smash", null, null)
						EmitSoundEx({
							sound_name = "misc/halloween/strongman_fast_swing_01.wav"
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
						DelayCode(0.5, "EmitSoundEx({ sound_name = `misc/halloween/strongman_fast_swing_01.wav`, pitch = 70, filter_type = RECIPIENT_FILTER_GLOBAL })")
						DelayCode(1, "EmitSoundEx({ sound_name = `misc/halloween/strongman_fast_whoosh_01.wav`, filter_type = RECIPIENT_FILTER_GLOBAL, })")
						DelayCode(1.3, "SmashImpact()")
						DelayCode(3.4, "EmitSoundEx({ sound_name = `doors/vent_open2.wav`, pitch = 70, filter_type = RECIPIENT_FILTER_GLOBAL })")
						DelayCode(3.4 + HAMMERTANK_COOLDOWN, "bSmashing = false")
						break
					}
			return -1
		}
		TankExt.AddThinkToEnt(hTank, "HammerThink")
	}
})