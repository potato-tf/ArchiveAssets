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
		if(hVictim && hAttacker && hAttacker.GetClassname() == "tank_boss")
		{
			local HammerScope = TankExt.GetMultiScopeTable(hAttacker.GetScriptScope(), "hammertank")
			if(HammerScope)
			{
				if(!("HAMMERTANK_KILL_ICON" in ROOT) || !HAMMERTANK_KILL_ICON || !HAMMERTANK_KILL_ICON.IsValid())
					::HAMMERTANK_KILL_ICON <- SpawnEntityFromTableSafe("info_target", { classname = "necro_smasher" })
				params.force_friendly_fire = HAMMERTANK_FRIENDLY_FIRE
				params.inflictor = HAMMERTANK_KILL_ICON
				HAMMERTANK_KILL_ICON.SetAbsOrigin(HammerScope.vecSmash)
			}
		}
	}
}
__CollectGameEventCallbacks(HammerTankEvents)

PrecacheModel(HAMMERTANK_MODEL_HAMMER)
TankExt.PrecacheSound(")misc/halloween/strongman_fast_swing_01.wav")
TankExt.PrecacheSound(")misc/halloween/strongman_fast_whoosh_01.wav")
TankExt.PrecacheSound(")misc/halloween/strongman_fast_impact_01.wav")
TankExt.PrecacheSound(")ambient/explosions/explode_1.wav")
TankExt.PrecacheSound(")doors/vent_open2.wav")

TankExt.NewTankType("hammertank", {
	function OnSpawn()
	{
		local hHammer = SpawnEntityFromTableSafe("prop_dynamic", {
			model          = HAMMERTANK_MODEL_HAMMER
			origin         = "-143 48 -28"
			angles         = "-30 0 0"
			modelscale     = 0.6
			disableshadows = 1
		})
		TankExt.SetParentArray([hHammer], self)

		local SmashImpact = function()
		{
			if(!self.IsValid()) return
			EmitSoundEx({
				sound_name  = ")ambient/explosions/explode_1.wav"
				sound_level = 100
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			EmitSoundEx({
				sound_name  = ")misc/halloween/strongman_fast_impact_01.wav"
				sound_level = 100
				entity      = self
				filter_type = RECIPIENT_FILTER_GLOBAL
			})
			DispatchParticleEffect("hammer_impact_button", vecSmash, Vector(1, 0, 0))
			ScreenShake(vecSmash, 9, 2.5, 3, 1500, 0, true)

			for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecSmash, 384);)
				if(hPlayer.IsAlive() && (HAMMERTANK_FRIENDLY_FIRE || hPlayer.GetTeam() != iTeamNum))
				{
					local vecTowards = hPlayer.GetOrigin() - vecSmash
					if(vecTowards.LengthSqr() < 16384) // sqr(128)
						hPlayer.TakeDamageEx(self, self, null, Vector(), Vector(), HAMMERTANK_DAMAGE, DMG_CRUSH)
					else
					{
						vecTowards.Norm()
						hPlayer.ApplyAbsVelocityImpulse(vecTowards * 200 + Vector(0, 0, 500))
					}
				}
		}

		vecSmash <- Vector()
		local bSmashing = false
		function Think()
		{
			vecSmash = vecOrigin + self.GetForwardVector() * 352 + self.GetRightVector() * -48
			if(!bSmashing)
				for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecSmash, 256);)
					if(hPlayer.IsAlive() && hPlayer.GetTeam() != iTeamNum)
					{
						bSmashing = true
						hHammer.AcceptInput("SetAnimation", "smash", null, null)
						EmitSoundEx({
							sound_name = ")misc/halloween/strongman_fast_swing_01.wav"
							sound_level = 100
							entity      = self
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
						TankExt.DelayFunction(self, this, 0.5, function() { EmitSoundEx({ sound_name = ")misc/halloween/strongman_fast_swing_01.wav", pitch = 70, sound_level = 100, entity = self, filter_type = RECIPIENT_FILTER_GLOBAL }) })
						TankExt.DelayFunction(self, this, 1.0, function() { EmitSoundEx({ sound_name = ")misc/halloween/strongman_fast_whoosh_01.wav", sound_level = 100, entity = self, filter_type = RECIPIENT_FILTER_GLOBAL, }) })
						TankExt.DelayFunction(self, this, 1.3, SmashImpact)
						TankExt.DelayFunction(self, this, 3.4, function() { EmitSoundEx({ sound_name = ")doors/vent_open2.wav", pitch = 70, sound_level = 100, entity = self, filter_type = RECIPIENT_FILTER_GLOBAL }) })
						TankExt.DelayFunction(self, this, 3.4 + HAMMERTANK_COOLDOWN, function() { bSmashing = false })
						break
					}
		}
	}
})