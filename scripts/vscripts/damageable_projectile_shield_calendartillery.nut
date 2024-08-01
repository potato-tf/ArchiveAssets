//Destructible Projectile shield
//Written by royal
//Modified for use by Seelpit

//DEPENDENCY: popextensionsPlus

local damageNumberHolder = SpawnEntityFromTable("obj_sentrygun", {
	teamnum = 3
})

damageNumberHolder.ValidateScriptScope()
damageNumberHolder.GetScriptScope().FullHealth <-  function() {
	EntFireByHandle(damageNumberHolder, "SetHealth", "100000000", 0, null, null)
}
damageNumberHolder.GetScriptScope().PutAway <- function () {
	damageNumberHolder.SetAbsOrigin(Vector(0, -100000, 0))
}

damageNumberHolder.GetScriptScope().FullHealth()
damageNumberHolder.GetScriptScope().PutAway()
damageNumberHolder.DisableDraw()
damageNumberHolder.AddEFlags(Constants.FEntityEFlags.EFL_NO_THINK_FUNCTION)
damageNumberHolder.SetSolid(Constants.ESolidType.SOLID_NONE)

::DamageableProjectileShield <- {
	DAMAGE_MULT = 0.02 // remember that shield takes full rampup damage regardless of distance
	MIN_DAMAGE_METER = 0 // damage cannot bring shield below this threshold. put at 0 to disable this grace period

	// MEDIGUN_CLASSNAME = "tf_weapon_medigun"
	PROJECTILE_SHIELD_CLASSNAME = "entity_medigun_shield"

	loadedProjectileShields = {}

	OnScriptHook_OnTakeDamage = function(params) {
		local entity = params.const_entity
		if (entity.IsPlayer())
			return

		if (entity.GetClassname() != PROJECTILE_SHIELD_CLASSNAME)
			return

		local owner = entity.GetOwner()
		if (!owner)
			return
		
		if (!owner.IsBotOfType(TF_BOT_TYPE))
			return
		
		if (!owner.HasBotTag("destructible_shield"))
			return
		
		local rageMeter = NetProps.GetPropFloat(owner, "m_Shared.m_flRageMeter")

		if (rageMeter <= MIN_DAMAGE_METER)
			return

		local fullDamage = params.damage + params.damage_bonus

		// if (fullDamage > params.max_damage)
		// 	fullDamage = params.max_damage

		if (fullDamage > 10000000)
			fullDamage = 10000000

		if (fullDamage <= 0)
			return

		rageMeter = rageMeter - (fullDamage * DAMAGE_MULT)
		if (rageMeter < MIN_DAMAGE_METER)
			rageMeter = MIN_DAMAGE_METER

		if (params.attacker) {
			damageNumberHolder.SetAbsOrigin(entity.GetOrigin() + Vector(0, 0, 15))
			damageNumberHolder.SetTeam(owner.GetTeam())

			damageNumberHolder.TakeDamage(fullDamage, params.damage_type, params.attacker)

			EntFireByHandle(damageNumberHolder, "CallScriptFunction", "FullHealth", -1, null, null)
			EntFireByHandle(damageNumberHolder, "CallScriptFunction", "PutAway", -1, null, null)
		}

		// make shield flicker
		NetProps.SetPropFloat(owner, "m_Shared.m_flRageMeter", rageMeter)
		EntFireByHandle(entity, "Color", "0 100 0", -1, null, null)

		entity.ValidateScriptScope()
		local entityScope =  entity.GetScriptScope()
		if (!("shieldFuncsLoaded" in entityScope))
		{
			entityScope.shieldFuncsLoaded <- true
			entityScope.timerId <- "-1"

			entityScope.RestoreColor <- function(inputTimerId) {
				local strTimerId = inputTimerId.tostring()

				if (strTimerId != timerId)
					return

				EntFireByHandle(entity, "Color", "18 255 0", -1, null, null)
			}
		}

		local id = Time()
		local strId = id.tostring()
		entityScope.timerId = strId

		local restoreColorFuncStr = format("RestoreColor(%s)", strId)
		EntFireByHandle(entity, "RunScriptCode", restoreColorFuncStr, 0.1, null, null)
	}

	Cleanup = function() {
		delete::DamageableProjectileShield
	}

	OnGameEvent_recalculate_holidays = function(_) {
		if (GetRoundState() != 3) return
		Cleanup()
	}

	OnGameEvent_mvm_wave_complete = function(_) {
		Cleanup()
	}
}

DamageableProjectileShield.damageNumberHolder <- damageNumberHolder

__CollectGameEventCallbacks(DamageableProjectileShield)