// Helper script file for Nightsky - Night of Fire, to reduce the amount of verbosity InitWaveOutput has

// Wave initialisation
IncludeScript("popextensions_main.nut", getroottable())
MissionAttrs
({
	ForceHoliday = 2
	NoRome = 1
	NoThrillerTaunt = 1
	NoCrumpkins = 1
	HuntsmanDamageFix = 1
})
EntFire("route1_holos*", "SetModel", "models/props_mvm/robot_hologram_color.mdl")
EntFire("route2_holos*", "SetModel", "models/props_mvm/robot_hologram_color.mdl")
EntFire("route1_holos*", "color", "169 56 214")
EntFire("route2_holos*", "color", "169 56 214")

// I basically stole the detect projectile logic from PopExt's customattributes.
// Credit to Royal who wrote the original code RocketPenetration from PopExt.
PopExt.AddRobotTag("bombi_explosion", {
	OnSpawn = function(bot,tag) {
		local scope = bot.GetScriptScope()
		local wep = bot.GetActiveWeapon()
		scope.FindRocket <- function(owner) {
			local entity = null
			for (local entity; entity = FindByClassnameWithin(entity, "tf_projectile_*", owner.GetOrigin(), 500);) {
				if (entity.GetOwner() != owner) {
					continue
				}
				entity.ValidateScriptScope()
				return entity
			}
			return null
		}

		PopExtUtil.OnWeaponFire(wep, function(){
			local rocket = scope.FindRocket(bot)

			if (rocket == null) return

			PopExtUtil.SetDestroyCallback(rocket, function(){
				local impactPoint = self.GetOrigin()
				SpawnEntityFromTable("info_particle_system",
				{
					origin = impactPoint
					start_active = 1
					effect_name = "bombinomicon_burningdebris_halloween"
				})
			})
		})
	}
})

CustomAttributes.TakeDamagePostTable["night_of_fire_lobotomy_bombi_explosion_ignite_on_hit"] <- function(params) {

	local victim = GetPlayerFromUserID(params.userid)
	local attacker = GetPlayerFromUserID(params.attacker)

	if (victim == null || attacker == null || !victim.IsPlayer() || victim.IsInvulnerable() || attacker == victim || !attacker.IsBotOfType(TF_BOT_TYPE) || !attacker.HasBotTag("bombi_explosion") ) return

	PopExtUtil.Ignite(victim)

}

// Since popext's customattributes on bots is not working
PopExt.AddRobotTag("arrow_ignite", {
	OnSpawn = function(bot,tag) {
		bot.ValidateScriptScope()
		local scope = bot.GetScriptScope()
		local wep = bot.GetActiveWeapon()

		scope.PlayerThinkTable["night_of_fire_lobotomy_arrow_ignite"] <- function() {
			if (wep.GetClassname() != "tf_weapon_compound_bow") return

			if (HasProp(wep, "m_bArrowAlight") && !GetPropBool(wep, "m_bArrowAlight"))
				SetPropBool(wep, "m_bArrowAlight", true)
		}
	}
})
