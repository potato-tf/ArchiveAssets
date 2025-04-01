::ROOT <- getroottable()
::MAX_CLIENTS <- MaxClients().tointeger()

if (!("ConstantNamingConvention" in ROOT))
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

::AthazarWeaponPack <- {
	function OnGameEvent_recalculate_holidays(_) { if(GetRoundState() == 3) { delete ::AthazarWeaponPack } }
	function OnGameEvent_player_builtobject(params)
	{
		if(params.object == 0)
		{
			local hBuilding = EntIndexToHScript(params.index)
			local flModelScale = hBuilding.GetModelScale()
			for(local hChild = EntIndexToHScript(params.index).FirstMoveChild(); hChild; hChild = hChild.NextMovePeer())
				if(hChild.GetClassname() == "vgui_screen")
				{
					SetPropFloat(hChild, "m_flWidth", 20 * flModelScale)
					SetPropFloat(hChild, "m_flHeight", 11 * flModelScale)
				}
		}
	}

	function SetDestroyCallback(entity, callback)
	{
		entity.ValidateScriptScope();
		local scope = entity.GetScriptScope();
		scope.setdelegate({}.setdelegate({
				parent   = scope.getdelegate()
				id       = entity.GetScriptId()
				index    = entity.entindex()
				callback = callback
				_get = function(k)
				{
					return parent[k];
				}
				_delslot = function(k)
				{
					if (k == id)
					{
						entity = EntIndexToHScript(index);
						local scope = entity.GetScriptScope();
						scope.self <- entity;
						callback.pcall(scope);
					}
					delete parent[k];
				}
			})
		);
	}
	
	function IntersectionBoxBox(xorigin, xmins, xmaxs, yorigin, ymins, ymaxs)
	{
		xmins += xorigin
		xmaxs += xorigin
		ymins += yorigin
		ymaxs += yorigin
		return (xmins.x <= ymaxs.x && xmaxs.x >= ymins.x) &&
			(xmins.y <= ymaxs.y && xmaxs.y >= ymins.y) &&
			(xmins.z <= ymaxs.z && xmaxs.z >= ymins.z)
	}

	function PillPopper()
	{
		local hHealer = activator
		local hPatient = self
		if(hPatient.GetTeam() == hHealer.GetTeam() && hHealer != hPatient)
		{
			local flHealth = hPatient.GetHealth()
			hPatient.SetHealth(flHealth + 50)
			local flMaxHealth = hPatient.GetMaxHealth()
			if(hPatient.GetHealth() > flMaxHealth)
				hPatient.SetHealth(flMaxHealth)
			
			flHealth = hPatient.GetHealth() - flHealth

			if(flHealth > 0)
			{
				EmitSoundOn("Weapon_Arrow.ImpactFleshCrossbowHeal", hPatient)
		
				local hPlayerManager = FindByClassname(null, "tf_player_manager")
				local GetUserIDFromIndex = @(iIndex) GetPropIntArray(hPlayerManager, "m_iUserID", iIndex)

				local iPatientIndex = hPatient.entindex()
				local iPatientUserID = GetUserIDFromIndex(iPatientIndex)
				local iHealerUserID = GetUserIDFromIndex(hHealer.entindex())

				local hPatientWeapon = hPatient.GetActiveWeapon()

				SendGlobalGameEvent("player_healed", {
					patient = iPatientUserID
					healer = iHealerUserID
					amount = flHealth
				})
				SendGlobalGameEvent("player_healonhit", {
					entindex = iPatientIndex
					weapon_def_index = hPatientWeapon ? GetPropInt(hPatientWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") : -1
					amount = flHealth
				})
				SendGlobalGameEvent("crossbow_heal", {
					patient = iPatientUserID
					healer = iHealerUserID
					amount = flHealth
				})
			}
		}
	}

	function PolarityPoint()
	{
		local hPlayer = self
		local hPolarityPoint
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 1)
				{ hPolarityPoint = hWeapon; break }
		}
		if(!hPolarityPoint) return

		local hGrenadeLauncher = CreateByClassname("tf_weapon_grenadelauncher")
		SetPropInt(hGrenadeLauncher, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 206)
		SetPropBool(hGrenadeLauncher, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropEntity(hGrenadeLauncher, "m_hOwner", hPlayer)
		hGrenadeLauncher.AddAttribute("override projectile type", 4, -1)
		hGrenadeLauncher.AddAttribute("sticky arm time penalty", 9999, -1)
		hGrenadeLauncher.AddAttribute("stickybomb stick to enemies", 1, -1)
		hGrenadeLauncher.DispatchSpawn()
		hGrenadeLauncher.SetClip1(-1)
		
		hPolarityPoint.ValidateScriptScope()
		local hPolarityPoint_scope = hPolarityPoint.GetScriptScope()

		if("hMagnet" in hPolarityPoint_scope && hPolarityPoint_scope.hMagnet && hPolarityPoint_scope.hMagnet.IsValid())
			hPolarityPoint_scope.hMagnet.Kill()
		if("hMagnetLauncher" in hPolarityPoint_scope && hPolarityPoint_scope.hMagnetLauncher && hPolarityPoint_scope.hMagnetLauncher.IsValid())
			hPolarityPoint_scope.hMagnetLauncher.Kill()

		hPolarityPoint_scope.hMagnetLauncher <- hGrenadeLauncher
		hPolarityPoint_scope.hMagnet <- null
		hPolarityPoint_scope.flTimeMagnet <- 0
		hPolarityPoint_scope.flTimeError <- 0
		hPolarityPoint_scope.iButtonsLast <- 0
		hPolarityPoint_scope.Think <- function()
		{
			if(!self.IsValid()) return
			if(!hPlayer.IsAlive() && hMagnet && hMagnet.IsValid())
				hMagnet.Kill()

			local hActiveWeapon = hPlayer.GetActiveWeapon()
			local iButtons = GetPropInt(hPlayer, "m_nButtons")
			local iButtonsChanged = iButtonsLast ^ iButtons
			local iButtonsPressed = iButtonsChanged & iButtons
			local iButtonsReleased = iButtonsChanged & (~iButtons)
			iButtonsLast = iButtons
			if(hActiveWeapon == self)
			{
				local flTime = Time()

				if(iButtons & IN_ATTACK2)
				{
					if(flTime >= flTimeMagnet)
					{
						flTimeError = flTime + 0.5
						flTimeMagnet = flTime + 2.5 * self.GetAttribute("fire rate bonus", 1)

						local hViewModel = GetPropEntity(hPlayer, "m_hViewModel")
						local sb_fire = hViewModel.LookupSequence("sb_fire")
						hViewModel.ResetSequence(sb_fire)
						SetPropFloat(self, "m_flTimeWeaponIdle", flTime + hViewModel.GetSequenceDuration(sb_fire))

						if(hMagnet && hMagnet.IsValid())
							hMagnet.Kill()
						SetPropFloat(hMagnetLauncher, "m_flNextPrimaryAttack", 0)
						hMagnetLauncher.PrimaryAttack()

						hMagnet = FindByClassnameNearest("tf_projectile_pipe_remote", hPlayer.EyePosition(), 32)
						if(hMagnet)
						{
							SetPropBool(hMagnet, "m_bForcePurgeFixedupStrings", true)
							hMagnet.SetModelSimple("models/empty.mdl")

							local hParticle = SpawnEntityFromTable("info_particle_system", {
								effect_name = hMagnet.GetTeam() == 3 ? "spell_fireball_small_glow_blue" : "spell_fireball_small_glow_red"
								start_active = 1
							})
							hParticle.AcceptInput("SetParent", "!activator", hMagnet, null)
							hParticle.SetLocalOrigin(Vector())
							hParticle.SetTeam(5)
							
							local hBolt = SpawnEntityFromTable("prop_dynamic", { model = "models/weapons/w_models/w_repair_claw.mdl", modelscale = 1.2, skin = hMagnet.GetTeam() == 3 ? 1 : 0})

							SetPropBool(hMagnet, "m_bForcePurgeFixedupStrings", true)
							hMagnet.ValidateScriptScope()
							local hMagnet_scope = hMagnet.GetScriptScope()
							hMagnet_scope.flTimeFizzle <- Time() + 5 + self.GetAttribute("obsolete ammo penalty", 0)
							hMagnet_scope.SawsTable <- {}
							hMagnet_scope.Think <- function()
							{
								if(!self.IsValid()) return

								if(Time() >= flTimeFizzle)
									{ self.Kill(); return }

								local vecMagnet = self.GetOrigin()
								local vecForward = self.GetPhysVelocity()
								vecForward.Norm()
								if(!GetPropBool(self, "m_bTouched"))
									hBolt.SetForwardVector(vecForward)
								hBolt.SetAbsOrigin(vecMagnet + hBolt.GetForwardVector() * 10)

								for(local hProjectile; hProjectile = FindByClassnameWithin(hProjectile, "tf_projectile_*", vecMagnet, 192);)
									if(hProjectile != self)
									{
										local sProjectileClassname = hProjectile.GetClassname()
										if(sProjectileClassname == "tf_projectile_pipe") continue
										if
										(
											sProjectileClassname == "tf_projectile_arrow" &&
											hProjectile.FirstMoveChild() &&
											hProjectile.FirstMoveChild().GetClassname() == "func_rotating"
										)
										{
											local vecOrigin = hProjectile.GetOrigin()
											local bInTable = true

											// i hate this
											try SawsTable[hProjectile] catch(_) bInTable = false

											if(!bInTable)
												SawsTable[hProjectile] <- { bReverse = false, vecOriginLast = Vector(), HitLastTick = [[], []] }
											else if((SawsTable[hProjectile].vecOriginLast - vecOrigin).Length() < 0.1)
												SawsTable[hProjectile].bReverse = SawsTable[hProjectile].bReverse ? false : true
											SawsTable[hProjectile].vecOriginLast = vecOrigin
											SawsTable[hProjectile].HitLastTick.remove(0)
											SawsTable[hProjectile].HitLastTick.append([])

											local hHurt = SpawnEntityFromTable("trigger_multiple", {
												origin = vecOrigin
												spawnflags = 64
												"OnStartTouch" : "!self,CallScriptFunction,Hurt,-1,-1"
											})
											SetPropBool(hHurt, "m_bForcePurgeFixedupStrings", true)
											hHurt.KeyValueFromInt("solid", 2)
											hHurt.SetSize(Vector(-32, -32, -16), Vector(32, 32, 16))
											EntFireByHandle(hHurt, "Kill", null, 0.033, null, null)
											hHurt.SetOwner(hProjectile)
											hHurt.ValidateScriptScope()
											local hMagnet = self
											local hMagnet_scope = this
											local hWeapon = GetPropEntity(hProjectile, "m_hLauncher")
											hHurt.GetScriptScope().Hurt <- function()
											{
												if(!(hMagnet && hMagnet.IsValid())) return
												local hVictim = activator
												local hSaw = self.GetOwner()
												if(hSaw && hSaw.IsValid())
												{
													local bInTable = true
													try SawsTable[hSaw] catch(_) bInTable = false
													if(bInTable && hVictim.GetTeam() != hSaw.GetTeam())
													{
														hMagnet_scope.SawsTable[hSaw].HitLastTick[1].append(hVictim)
														if(hMagnet_scope.SawsTable[hSaw].HitLastTick[0].find(hVictim) == null)
															hVictim.TakeDamageEx(hSaw, hPlayer, hWeapon, Vector(), Vector(), 7 * hWeapon.GetAttribute("damage bonus", 1), DMG_SLOWBURN | DMG_BUCKSHOT)
													}
												}
											}

											local vecOriginBetween = vecOrigin - vecMagnet
											local vecOriginAfter = RotatePosition(Vector(), QAngle(0, SawsTable[hProjectile].bReverse ? -94 : 94, 0), Vector(vecOriginBetween.x, vecOriginBetween.y, 0))
											vecOriginBetween.Norm()
											hProjectile.SetAbsOrigin(vecMagnet + vecOriginBetween * 150)
											hProjectile.SetAbsVelocity(vecOriginAfter * 10)
											hProjectile.SetAbsAngles(QAngle())
										}
										else if(GetPropEntity(hProjectile, "m_hThrower") == hPlayer)
										{
											local vecTowardsMagnet = vecMagnet - hProjectile.GetOrigin()
											local vecVelocity = Vector(0, 0, 12)
											if(vecTowardsMagnet.Length() > 8)
											{
												vecTowardsMagnet.Norm()
												vecVelocity = vecTowardsMagnet * 512
												if(sProjectileClassname == "tf_projectile_pipe_remote" && GetPropBool(hProjectile, "m_bTouched"))
													hProjectile.TakeDamageEx(null, hParticle, null, Vector(12000), Vector(), 0, DMG_BLAST)
											}
											hProjectile.SetPhysVelocity(vecVelocity)
											hProjectile.SetAbsVelocity(vecVelocity)
										}
									}
								return -1
							}
							AddThinkToEnt(hMagnet, "Think")
							AthazarWeaponPack.SetDestroyCallback(hMagnet, function()
							{
								DispatchParticleEffect("arm_detonate_sparks", self.GetOrigin(), Vector(1))
								if(hBolt && hBolt.IsValid())
									hBolt.Kill()
							})
						}
					}
					else if(flTime >= flTimeError)
					{
						flTimeError = flTime + 0.5
						PrecacheSound("common/wpn_denyselect.wav")
						EmitSoundEx({
							sound_name  = "common/wpn_denyselect.wav"
							entity      = hPlayer
							filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
						})
					}
				}
			}
			if(iButtonsPressed & IN_ATTACK3 && hMagnet && hMagnet.IsValid())
				hMagnet.Kill()
			return -1
		}
		AddThinkToEnt(hPolarityPoint, "Think")
		AthazarWeaponPack.SetDestroyCallback(hPolarityPoint, function()
		{
			if(hMagnet && hMagnet.IsValid())
				hMagnet.Kill()
			if(hMagnetLauncher && hMagnetLauncher.IsValid())
				hMagnetLauncher.Kill()
		})
	}

	function MiniPDA()
	{
		local hPlayer = self
		local hMiniPDA
		for(local i = 0; i < 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 3)
				{ hMiniPDA = hWeapon; break }
		}
		if(!hMiniPDA) return

		hMiniPDA.ValidateScriptScope()
		local hMiniPDA_scope = hMiniPDA.GetScriptScope()
		hMiniPDA_scope.Think <- function()
		{
			local hWeapon = hPlayer.GetActiveWeapon()
			if(hWeapon && hWeapon.GetSlot() == 5)
				for(local hBuilding; hBuilding = FindByClassname(hBuilding, "obj_*");)
				{
					local sClassname = hBuilding.GetClassname()
					if
					(
						GetPropBool(hBuilding, "m_bPlacing") &&
						GetPropEntity(hBuilding, "m_hBuilder") == hPlayer &&
						sClassname != "obj_sentrygun" &&
						!hBuilding.IsEFlagSet(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
					)
					{
						hBuilding.AddEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
						hBuilding.SetModelScale(0.75, 0)
						if(sClassname == "obj_dispenser")
						{
							hBuilding.ValidateScriptScope()
							local hBuilding_scope = hBuilding.GetScriptScope()
							hBuilding_scope.bHasSiren <- false
							hBuilding_scope.Think <- function()
							{
								if(!self.IsValid()) return
								local bPlacing = GetPropBool(self, "m_bPlacing")
								local bBuilding = GetPropBool(self, "m_bBuilding")
								if(!bHasSiren && !bPlacing && !bBuilding)
								{
									bHasSiren = true
									local hParticle = CreateByClassname("trigger_particle")
									hParticle.KeyValueFromString("particle_name", self.GetTeam() == 2 ? "cart_flashinglight_red" : "cart_flashinglight")
									hParticle.KeyValueFromString("attachment_name", "siren")
									hParticle.KeyValueFromInt("attachment_type", 4)
									hParticle.KeyValueFromInt("spawnflags", 64)
									hParticle.DispatchSpawn()
									hParticle.AcceptInput("StartTouch", null, self, self)
									hParticle.Kill()
								}
								else if(bHasSiren && (bPlacing || bBuilding))
									bHasSiren = false

								if(!bBuilding)
									EmitSoundEx({
										sound_name = "misc/null.wav"
										flags = 2 | 512
										pitch = 120
										entity = self
									})
								return -1
							}
							AddThinkToEnt(hBuilding, "Think")
						}
					}
				}
			return -1
		}
		AddThinkToEnt(hMiniPDA, "Think")
	}

	function CannedConserva()
	{
		local hPlayer = self
		local hRation
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 1)
				{ hRation = hWeapon; break }
		}
		if(!hRation) return
		hRation.ValidateScriptScope()
		hRation.GetScriptScope().Think <- function()
		{
			if(GetPropInt(hPlayer, "m_nButtons") & IN_ATTACK2)
				for(local hKit; hKit = FindByClassnameWithin(hKit, "item_healthkit_medium", hPlayer.GetOrigin(), 128);)
					if(hKit.GetOwner() == hPlayer && !(hKit.GetFlags() & FL_ONGROUND) && !hKit.IsEFlagSet(EFL_NO_MEGAPHYSCANNON_RAGDOLL))
					{
						hKit.SetEFlags(EFL_NO_MEGAPHYSCANNON_RAGDOLL)
						hKit.SetModelSimple("models/weapons/c_models/c_canned_ration/c_ration_plate.mdl")
						hKit.SetSkin(hPlayer.GetTeam() == 3 ? 1 : 0)

						local hAmmo = SpawnEntityFromTable("item_ammopack_medium", { OnPlayerTouch = "!self,RunScriptCode,self.GetRootMoveParent().GetScriptScope().Pickup(activator),-1,-1" })
						SetPropEntity(hAmmo, "m_hMovePeer", hKit.FirstMoveChild())
						SetPropEntity(hKit, "m_hMoveChild", hAmmo)
						SetPropEntity(hAmmo, "m_hMoveParent", hKit)
						hAmmo.DisableDraw()
						local vecMins = hKit.GetBoundingMins()
						local vecMaxs = hKit.GetBoundingMaxs()
						hAmmo.SetSize(vecMins, vecMaxs)

						local RedPlayers = []
						for(local i = 0; i <= MAX_CLIENTS; i++)
						{
							local hPlayer = PlayerInstanceFromIndex(i)
							if(hPlayer && hPlayer.GetTeam() == TF_TEAM_RED)
								RedPlayers.append(hPlayer)
						}

						hKit.ValidateScriptScope()
						local hKit_scope = hKit.GetScriptScope()
						hKit_scope.Pickup <- function(hActivator)
						{
							self.Kill()
							SendGlobalGameEvent("player_bonuspoints", {
								points = 10
								player_entindex = hPlayer.entindex()
								source_entindex = hActivator.entindex()
							})
						}

						hKit_scope.Think <- function()
						{
							if(!self.IsValid()) return
							local vecOrigin = self.GetOrigin()
							local hFoundPlayer
							foreach(hPlayer in RedPlayers)
							{
								local vecPOrigin = hPlayer.GetOrigin()
								local vecPMins = hPlayer.GetPlayerMins()
								local vecPMaxs = hPlayer.GetPlayerMaxs()
								if(AthazarWeaponPack.IntersectionBoxBox(vecOrigin, vecMins, vecMaxs, vecPOrigin, vecPMins, vecPMaxs))
									{ hFoundPlayer = hPlayer; break }
							}
							if(hFoundPlayer)
							{
								if(hFoundPlayer == hPlayer)
								{
									self.SetSolid(SOLID_BBOX)
									hAmmo.SetSolid(SOLID_NONE)
								}
								else
								{
									self.SetSolid(SOLID_NONE)
									hAmmo.SetSolid(SOLID_BBOX)
								}
							}
							else
							{
								self.SetSolid(SOLID_NONE)
								hAmmo.SetSolid(SOLID_NONE)
							}
							return -1
						}
						AddThinkToEnt(hKit, "Think")
					}
			return -1
		}
		AddThinkToEnt(hRation, "Think")
	}

	function SolarCarbonizer()
	{
		local hPlayer = self
		local hCarbon
		for(local i = 0; i <= 8; i++)
		{
			local hWeapon = GetPropEntityArray(hPlayer, "m_hMyWeapons", i)
			if(hWeapon && hWeapon.GetSlot() == 0)
				{ hCarbon = hWeapon; break }
		}
		if(!hCarbon) return

		local MakeArms = function(bool)
		{
			local hViewModel = SpawnEntityFromTable("tf_wearable_vm", {})
			hViewModel.SetModelSimple("models/weapons/c_models/c_pyro_arms.mdl")
			hPlayer.EquipWearableViewModel(hViewModel)
			if(!bool) hViewModel.DisableDraw()
			return hViewModel
		}

		local MakeWeaponVM = function(bool)
		{
			local hViewModel = SpawnEntityFromTable("tf_wearable_vm", {})
			hViewModel.SetModelSimple("models/weapons/c_models/c_solar_carbonizer/c_solar_carbonizer.mdl")
			hPlayer.EquipWearableViewModel(hViewModel)
			if(!bool) hViewModel.DisableDraw()
			return hViewModel
		}

		local hTemp = CreateByClassname("tf_weapon_parachute")
		SetPropInt(hTemp, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
		SetPropBool(hTemp, "m_AttributeManager.m_Item.m_bInitialized", true)
		hTemp.SetTeam(hPlayer.GetTeam())
		hTemp.DispatchSpawn() 
		hPlayer.Weapon_Equip(hTemp)
		local hWorldModel = GetPropEntity(hTemp, "m_hExtraWearable")
		hTemp.Kill()
		hWorldModel.SetModelSimple("models/weapons/c_models/c_solar_carbonizer/c_solar_carbonizer.mdl")
		SetPropBool(hWorldModel, "m_bValidatedAttachedEntity", true)
		hWorldModel.DisableDraw()
		
		hCarbon.ValidateScriptScope()
		local hCarbon_scope = hCarbon.GetScriptScope()

		if("ExtraModels" in hCarbon_scope)
			foreach(hEnt in hCarbon_scope.ExtraModels)
				if(hEnt && hEnt.IsValid())
					hEnt.Kill()

		hCarbon_scope.bActive <- false
		hCarbon_scope.ExtraModels <- [MakeArms(false), MakeWeaponVM(false), hWorldModel]
		hCarbon_scope.Think <- function()
		{
			local hWeapon = hPlayer.GetActiveWeapon()

			if(hWeapon == self && !bActive)
			{
				bActive = true
				foreach(hEnt in ExtraModels)
					if(hEnt && hEnt.IsValid())
						hEnt.EnableDraw()
			}
			else if(hWeapon != self && bActive)
			{
				bActive = false
				foreach(hEnt in ExtraModels)
					if(hEnt && hEnt.IsValid())
						hEnt.DisableDraw()
			}

			if(!ExtraModels[0].IsValid()) ExtraModels[0] = MakeArms(bActive)
			if(!ExtraModels[1].IsValid()) ExtraModels[1] = MakeWeaponVM(bActive)
			if(bActive && ExtraModels[2].IsValid())
			{
				if(hPlayer.InCond(TF_COND_TAUNTING))
				{
					SetPropInt(self, "m_nRenderMode", kRenderNormal)
					SetPropInt(self, "m_clrRender", ~0)
					SetPropInt(ExtraModels[2], "m_fEffects", EF_BONEMERGE | EF_NODRAW | EF_BONEMERGE_FASTCULL)
				}
				else
				{
					SetPropInt(self, "m_nRenderMode", kRenderTransColor)
					SetPropInt(self, "m_clrRender", 0)
					SetPropInt(self, "m_fEffects", EF_BONEMERGE | EF_NODRAW | EF_BONEMERGE_FASTCULL)
					SetPropInt(ExtraModels[2], "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
				}
			}

			if(!hPlayer.IsAlive()) self.Kill()
			return -1
		}
		AddThinkToEnt(hCarbon, "Think")
		AthazarWeaponPack.SetDestroyCallback(hCarbon, function()
		{
			foreach(hEnt in ExtraModels)
				if(hEnt && hEnt.IsValid())
					hEnt.Kill()
		})
	}
}
__CollectGameEventCallbacks(AthazarWeaponPack)