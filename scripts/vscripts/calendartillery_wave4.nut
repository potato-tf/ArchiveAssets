
ClientPrint(null,3,"\x07F1C232The General \x078FCE00: It seems the six of you are more of a threat than I'd given you credit for.")
ClientPrint(null,3,"\x078FCE00However, I think you'll find that I'm not quite out of commission yet.")
ClientPrint(null,3,"\x078FCE00These next troops haven't...passed certification, as it were. But all great innovations began somewhere.")
ClientPrint(null,3,"\x078FCE00I had hoped to give them proper testing; but perhaps this presents an opportunity for us both.")
IncludeScript("calendartillery_pointtemplates.nut",getroottable())
IncludeScript("popextensions_main.nut",getroottable())
MissionAttrs({
"ForceHoliday" : 2
"NoCrumpkins" : 1
"NoThrillerTaunt" : 1
})

PrecacheModel("models/bots/boss_bot/robo_sleigh/robo_sleigh.mdl") //Apparently this doesn't force players to actually download it...
::TankPos <- Vector(2940,-2960,-95) //Spawnbot: ideally bot should not spawn here but this is a backup of sorts
PopExt.AddRobotTag("leave_squad", {
	OnSpawn = function(bot,tag) { bot.LeaveSquad(); }
});
PopExt.AddTankName("sleightank", {
	Model = {
		Default = "models/bots/boss_bot/robo_sleigh/robo_sleigh.mdl",
		Damage1 = "models/bots/boss_bot/robo_sleigh/robo_sleigh_damage1.mdl",
		Damage2 = "models/bots/boss_bot/robo_sleigh/robo_sleigh_damage2.mdl",
		Damage3 = "models/bots/boss_bot/robo_sleigh/robo_sleigh_damage3.mdl",
	}
	DisableBomb = true
	DisableTracks = true
	NoDeathFX = 2
	SoundOverrides = {
		Ping = "misc/null.wav",
		Start = "vo/mvm/norm/heavy_mvm_cartmovingforwardoffense17.mp3",
		// EngineLoop = "misc/null.wav", //temporarily commented out until fix deployed
		Destroy = "vo/mvm/norm/taunts/heavy_mvm_taunts15.mp3",
		Deploy = "vo/mvm/norm/taunts/heavy_mvm_taunts08.mp3",
	}
	OnSpawn = function(tank,params) { TankPos = tank.GetOrigin() }
	OnTakeDamagePost = function(tank,params) { TankPos = tank.GetOrigin() }
})
PopExt.AddRobotTag("santa", {
	OnSpawn = function(bot,tag) {
		bot.Teleport(true,TankPos,false,bot.GetAbsAngles(),false,bot.GetAbsVelocity())
		PopExtUtil.CreatePlayerWearable(bot, "models/player/items/all_class/xms_santa_hat_heavy.mdl",true, "head")
		DispatchParticleEffect("hightower_explosion",Vector(TankPos.x,TankPos.y,TankPos.z + 5),Vector(0,0,0))
		::SantaCanteenUsed <- false
	},
	OnTakeDamage = function(bot,params) {
		if (params.const_entity.GetHealth() - params.damage <= 0.55 * params.const_entity.GetMaxHealth() && !SantaCanteenUsed)
		{
			ClientPrint(null,3,"\x0799CCFFDeadly Morozko \x07FBEBCAhas used their \x0799CCFFPERMANENT CRITS \x07FBEBCAPower Up Canteen!")
			params.const_entity.AddCondEx(34,999,params.const_entity)
			SantaCanteenUsed = true
			PrecacheSound("mvm/mvm_used_powerup.wav")
			EmitSoundEx({sound_name = "mvm/mvm_used_powerup.wav", volume = 0.5, filter_type = 5})
		}
	}
})
PopExt.AddRobotTag("fireball_knight", {
	OnSpawn = function(bot,tag) { bot.Weapon_Switch(PopExtUtil.GetItemInSlot(bot, 2)); }
})
PopExt.AddRobotTag("learnerspermit", {
	OnSpawn = function(bot,tag) { EntFireByHandle(bot,"RunScriptCode","ApplyDecals(self)",0.1,null,null) }
})
::ApplyDecals <- function(bot)
{
	PopExtUtil.GetItemInSlot(bot,SLOT_MELEE).AddAttribute("custom texture lo",-4.403380311492439e+25,-1)
	PopExtUtil.GetItemInSlot(bot,SLOT_MELEE).AddAttribute("custom texture hi",1.5604179093481017e-18,-1)
}
PopExt.AddRobotTag("neondemo", {
	OnSpawn = function(bot,tag)
	{
		bot.GetScriptScope().PlayerThinkTable.spawnNeonTemplates <- function()
		{
			for (local projectile; projectile = FindByClassname(projectile, "tf_projectile_arrow");) {
				projectile.ValidateScriptScope()
				if (projectile.IsValid() && projectile.GetOwner() == bot && !("NeonSign" in projectile.GetScriptScope()))
				{
					SpawnTemplate("RotatingNeonSign", projectile)
					projectile.GetScriptScope().NeonSign <- true;
					EntFire("neon_prop*","CallScriptFunction","NeonRotate")
				}
			}
		}
	}
})
::NeonRotate <- function()
{
	if (GetPropString(self, "m_iszScriptThinkFunction") == "NeonRotateThink") return;
	// printl("Adding think!")
	AddThinkToEnt(self,"NeonRotateThink")
}
::NeonRotateThink <- function()
{
	if (!self.IsValid()) return;
	if (self.GetAbsVelocity().Length() == 0)
	{
		self.Destroy()
		return
	}
	local newAngles = self.GetAbsAngles() + QAngle(10,0,0)
	self.SetAbsAngles(newAngles)
	return -1
}
::W4 <- {
	function OnScriptHook_OnTakeDamage(params) {
		local victim = params.const_entity
		local attacker = params.attacker
		local damage = params.damage
		if (attacker == null) return
		if (!attacker.IsValid()) return
		if (!attacker.IsPlayer())
		{
			// printl("You ain't a player!")
			return
		}
		if (attacker != null && attacker.IsBotOfType(TF_BOT_TYPE) && victim != attacker && victim.IsPlayer() && victim.GetHealth() - damage > 0)
		{
			if (attacker.HasBotTag("milkdemo"))
				victim.AddCondEx(27, 6, null)
			else if (attacker.HasBotTag("jarcher"))
				victim.AddCondEx(24, 4, null)
		}
	}
}
__CollectGameEventCallbacks(W4)