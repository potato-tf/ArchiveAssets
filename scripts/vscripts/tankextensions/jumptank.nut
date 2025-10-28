local JUMPTANK_VALUES_TABLE = {
	JUMPTANK_JUMP_COOLDOWN      = 8
	JUMPTANK_USE_SPECIAL_DEPLOY = false
}
foreach(k,v in JUMPTANK_VALUES_TABLE)
	if(!(k in TankExt.ValueOverrides))
		ROOT[k] <- v

TankExt.PrecacheSound(")misc/halloween/strongman_fast_impact_01.wav")
TankExt.PrecacheSound(")ambient/explosions/explode_1.wav")
TankExt.PrecacheSound(")player/fall_damage_indicator.wav")
TankExt.PrecacheSound(")weapons/rocket_pack_boosters_fire.wav")
TankExt.PrecacheSound(")weapons/rocket_pack_boosters_charge.wav")

TankExt.NewTankType("jumptank", {
	function OnSpawn()
	{
		local hTracks = []
		for(local hChild = self.FirstMoveChild(); hChild != null; hChild = hChild.NextMovePeer())
			if(hChild.GetModelName().find("track_"))
				hTracks.append(hChild)

		local hParticle = SpawnEntityFromTableSafe("info_particle_system", {
			origin      = "0 0 64"
			angles      = "-90 0 0"
			effect_name = "rockettrail_burst_doomsday"
		})
		TankExt.SetParentArray([hParticle], self)

		local ValidPlayers    = []
		local vecFakeVelocity = Vector()
		local vecFakeOrigin   = Vector()
		local flTimeNext      = Time() + JUMPTANK_JUMP_COOLDOWN
		local flGravity       = Convars.GetInt("sv_gravity")
		local bPreparing      = false
		local bJumping        = false
		local bFalling        = false

		local JumpScope = this
		local function Jump()
		{
			if(bPreparing) return
			local vecOrigin = self.GetOrigin()
			local Trace = {
				start  = vecOrigin
				end    = vecOrigin + Vector(0, 0, 850)
				mask   = CONTENTS_SOLID
				ignore = self
			}
			TraceLineEx(Trace)
			if(Trace.fraction >= 0.4)
			{
				bPreparing = true
				EmitSoundEx({
					sound_name  = ")weapons/rocket_pack_boosters_charge.wav"
					pitch       = 85
					sound_level = 100
					entity      = self
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
				TankExt.DelayFunction(self, JumpScope, 0.75, function()
				{
					local vecOrigin = self.GetOrigin()
					bJumping        = true
					vecFakeOrigin   = vecOrigin
					vecFakeVelocity = (!bDeploying ? self.GetForwardVector() * GetPropFloat(self, "m_speed") : Vector()) + Vector(0, 0, 1024) * pow(Trace.fraction, 0.65)
					ValidPlayers.clear()
					for(local i = 1; i <= MAX_CLIENTS; i++)
					{
						local hPlayer = PlayerInstanceFromIndex(i)
						if(hPlayer && hPlayer.IsAlive()) ValidPlayers.append(hPlayer)
					}
					EmitSoundEx({
						sound_name  = ")weapons/rocket_pack_boosters_fire.wav"
						pitch       = 85
						sound_level = 100
						entity      = self
						filter_type = RECIPIENT_FILTER_GLOBAL
					})
					hParticle.AcceptInput("Start", null, null, null)
					EntFireByHandle(hParticle, "Stop", null, 0.4, null, null)
				})
			}
		}
		self.GetScriptScope().Jump <- Jump

		function Think()
		{
			if(!bPreparing && !bDeploying && JUMPTANK_JUMP_COOLDOWN >= 0 && flTime >= flTimeNext) Jump()
			if(bJumping)
			{
				if(bDeploying && JUMPTANK_USE_SPECIAL_DEPLOY)
				{
					if(!("flSpin" in this)) flSpin <- 0
					local flUpCenter = 88.1 * self.GetModelScale()
					local vecCenter  = vecOrigin + self.GetUpVector() * flUpCenter
					self.SetAbsAngles(self.GetAbsAngles() + QAngle((flSpin += 0.015) * 16))
					vecFakeOrigin += vecCenter - (vecOrigin + self.GetUpVector() * flUpCenter)
				}

				local flFrameTime   = FrameTime()
				local vecNextOrigin = vecFakeOrigin + vecFakeVelocity * flFrameTime
				local Trace = {
					start      = vecFakeOrigin
					end        = vecNextOrigin
					mask       = CONTENTS_SOLID // tf_tank_boss_body GetSolidMask
					startsolid = false
				}
				TraceLineEx(Trace)
				local vecNormal = Trace.plane_normal
				if(!Trace.startsolid && Trace.hit)
					if(TankExt.NormalizeAngle(TankExt.VectorAngles(vecNormal).x) > -45)
					{
						vecFakeVelocity -= (vecNormal * vecFakeVelocity.Dot(vecNormal) * 2)
						vecNextOrigin = Trace.endpos + vecFakeVelocity * flFrameTime
						local sSound = format(")physics/metal/metal_canister_impact_hard%i.wav", RandomInt(1, 3))
						TankExt.PrecacheSound(sSound)
						EmitSoundEx({
							sound_name  = sSound
							sound_level = 95
							entity      = self
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
					}
					else if(bFalling)
					{
						flTimeNext = flTime + JUMPTANK_JUMP_COOLDOWN
						bPreparing = false
						bJumping   = false
						bFalling   = false
						self.SetAbsOrigin(Trace.endpos)

						if(bDeploying && JUMPTANK_USE_SPECIAL_DEPLOY)
						{
							SpawnEntityFromTableSafe("info_particle_system", {
								origin       = vecOrigin
								angles       = "-90 0 0"
								effect_name  = "fireSmoke_collumnP"
								start_active = 1
							})
							self.AcceptInput("RemoveHealth", format("%i", iMaxHealth), null, null)
							EntFire("boss_deploy_relay", "Trigger")
							return
						}

						for(local hPlayer; hPlayer = FindByClassnameWithin(hPlayer, "player", vecOrigin, 384);)
							if(hPlayer.IsAlive() && hPlayer.GetTeam() != iTeamNum)
							{
								local vecTowards = hPlayer.GetOrigin() - vecOrigin
								vecTowards.z = 0
								vecTowards.Norm()
								hPlayer.ApplyAbsVelocityImpulse(vecTowards * 600 + Vector(0, 0, 500))
								hPlayer.StunPlayer(0.3, 1, TF_STUN_MOVEMENT, null)
							}

						DispatchParticleEffect("hammer_impact_button", vecOrigin + Vector(0, 0, 2), Vector(1))
						ScreenShake(vecOrigin, 9, 2.5, 3, 1500, 0, true)
						EmitSoundEx({
							sound_name  = ")player/fall_damage_indicator.wav"
							entity      = self
							flags       = SND_STOP
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
						EmitSoundEx({
							sound_name  = ")weapons/rocket_pack_boosters_fire.wav"
							entity      = self
							flags       = SND_STOP
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
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
					}

				if(bJumping)
				{
					self.GetLocomotionInterface().Reset()
					self.SetAbsOrigin(vecFakeOrigin = vecNextOrigin)
					if(!bFalling && vecFakeVelocity.z <= -200)
					{
						bFalling = true
						EmitSoundEx({
							sound_name  = ")player/fall_damage_indicator.wav"
							sound_level = 100
							entity      = self
							filter_type = RECIPIENT_FILTER_GLOBAL
						})
					}
					vecFakeVelocity.z -= flGravity * flFrameTime

					local vecMins  = self.GetBoundingMins()
					local vecMaxs  = self.GetBoundingMaxs()
					local vecCheck = vecOrigin
					vecCheck.z = vecNextOrigin.z - (bFalling ? 24 : 0)
					local vecDisplace = Vector(0, 0, vecFakeVelocity.z * FrameTime() + 1)
					foreach(hPlayer in ValidPlayers)
						if(hPlayer.IsValid() && hPlayer.IsAlive())
						{
							local vecPlayer = hPlayer.GetOrigin()
							if(TankExt.IntersectionBoxBox(vecCheck, vecMins, vecMaxs, vecPlayer, hPlayer.GetPlayerMins(), hPlayer.GetPlayerMaxs()))
								if(bFalling && hPlayer.GetTeam() != iTeamNum)
								{
									hPlayer.TakeDamageCustom(self, self, null, Vector(), Vector(), hPlayer.GetHealth(), DMG_CRUSH, TF_DMG_CUSTOM_BOOTS_STOMP)
									self.EmitSound("Weapon_Mantreads.Impact")
									self.EmitSound("Player.FallDamageDealt")
								}
								else hPlayer.SetAbsOrigin(vecPlayer + vecDisplace)
						}
				}
			}
		}
		function OnStartDeploy()
		{
			bDeploying = true
			if(JUMPTANK_USE_SPECIAL_DEPLOY) TankExt.DelayFunction(self, this, 3.5, Jump)
			else if(bJumping)
			{
				vecFakeVelocity.x = 0
				vecFakeVelocity.y = 0
			}
		}
	}
})