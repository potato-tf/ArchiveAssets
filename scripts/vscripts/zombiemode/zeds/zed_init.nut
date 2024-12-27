local cooldown = 0;
local player = self;
const BREAK_RADIUS = 96;
const VOICE_COOLDOWN_TIME = 4;
const WARP_TIME = 20;
const TIMER_INTERVAL = 0.2352941176470588; // ((1/60) / 255).

::ZombieSpawn <- function(self)
{
	local scope = self.GetScriptScope()
	PopExtUtil.StripWeapon(self,0)
	PopExtUtil.StripWeapon(self,1)
	SelectZedType(self)
	MoveToSpawnLocation(self)
	PopExtUtil.AddThinkToEnt(self, "ZedThink")
}

::Zombie_GetHealth <- function(bot) 
{
//	::REMOVE_ON_DEATH <- Constants.FTFBotAttributeType.REMOVE_ON_DEATH
	local playerclass = bot.GetPlayerClass();
	if (bot.HasBotAttribute(REMOVE_ON_DEATH)) return // we don't want this running multiple times on the same guy!!
	bot.AddBotAttribute(REMOVE_ON_DEATH)
	bot.AddBotAttribute(DISABLE_DODGE) // I suspect this is not carrying over from bot_generator
//	bot.AddWeaponRestriction(2) // meleeonly?
	
	// apply round health
	local health = 50
	local o = Entities.FindByClassname(null, "tf_objective_resource")
	local wavecount = NetProps.GetPropInt(o, "m_nMannVsMachineWaveCount") // get wave number
		
	health = health + (100 * wavecount)
	if ( wavecount >= 10)
	{
		health = health * 1.10 // does it work like this??
	}
		PopExtUtil.AddAttributeToLoadout(bot, "max health additive penalty" ,-300, -1); // remove heavy's normal health to get 'proper' health value
		PopExtUtil.AddAttributeToLoadout(bot, "max health additive bonus" ,health, -1);
		bot.SetHealth(health);
	if (playerclass == 2)
	{
		health = health * 0.6
	}
		// after all of that, roll the dice and become a type of zed
}
	
::SelectZedType <- function(self)
{
	local round_number = NetProps.GetPropInt(PopExtUtil.ObjectiveResource, "m_nMannVsMachineWaveCount")
	local speedrandomizer = RandomInt(1,10) // our random chance dice
	local speedrandomizer_2 = RandomInt(1,10) // our second chance dice
	local scope = self.GetScriptScope();
	local playerclass = self.GetPlayerClass();
	self.AddCondEx(87,3,null) // hold in place to apply the stuff
//	self.SetMaxVisionRangeOverride(100)		// breaks pathfinding??
	PopExtUtil.AddAttributeToLoadout(self, "voice pitch scale",0,-1)
	PopExtUtil.AddAttributeToLoadout(self, "alt-fire disabled",1,-1)
	PopExtUtil.AddAttributeToLoadout(self, "fire rate penalty",1.4,-1)
	PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.77,-1)
	PopExtUtil.AddAttributeToLoadout(self, "player skin override",2,-1)
	PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",1.75,-1)
	PopExtUtil.AddAttributeToLoadout(self, "dmg from melee increased",2.307,-1)
	PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",2,-1)
	PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",8.5,-1)
	PopExtUtil.AddAttributeToLoadout(self, "SET BONUS: dmg from sentry reduced",0.5,-1)
	PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.75,-1)
	PopExtUtil.AddAttributeToLoadout(self, "cancel falling damage",1,-1)
	scope.Preserved.warpcooldown = Time() + WARP_TIME
	
	// check round number to determine spawn table
	RollZombieModel(self);
	if (round_number == 1) 	// round_number is global from roundlogic so this should work as-is
	{						// no it won't, hence why it's as local up above
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.6,-1)
		scope.Preserved.zombie_type = 1;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
	}
	if (round_number > 1 && round_number <= 2)
	{
	//	ClientPrint(null,HUD_PRINTTALK,format("speed %d", speedrandomizer))
		if (speedrandomizer >= 4)
		{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.75,-1)
		scope.Preserved.zombie_type = 2;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		}
		else
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.6,-1)
			scope.Preserved.zombie_type = 1;
			SetFakeClientConVarValue(self, "name", "Zombie");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 2 && round_number <= 4) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.75,-1)
		scope.Preserved.zombie_type = 2;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
	}
	if ((round_number > 4 && round_number <= 6) && playerclass != 2)
	{
		if (speedrandomizer <= 6)
		{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.75,-1)
		scope.Preserved.zombie_type = 2;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		}
		if (speedrandomizer > 6 && speedrandomizer < 10)
		{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.9,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
	//		self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 6 && round_number <= 8) && playerclass != 2)
	{
		if (speedrandomizer <= 9)
		{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 8 && round_number <= 11) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 11 && round_number <= 13) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 8 && playerclass != 2)
		{
			self.SetPlayerClass(3)	// don't use sniper, tied to doe hopper
			scope.Preserved.zombie_type = 8;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/sniper.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_cranium_cover_style1/sum23_cranium_cover_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedShotgun", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deadeye");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 13 && round_number <= 15) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 7)
		{
			scope.Preserved.zombie_type = 9;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/engineer.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_hazard_handler_style1/sum23_hazard_handler_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_cargo_constructor/sum23_cargo_constructor.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/engineer_blueprints_back.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/fwk_engineer_blueprints.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedRanger", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deconstructor");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 8)
		{
			self.SetPlayerClass(3)	// don't use sniper, tied to doe hopper
			scope.Preserved.zombie_type = 8;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/sniper.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_cranium_cover_style1/sum23_cranium_cover_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedShotgun", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deadeye");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 15 && round_number <= 19) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 6)
		{
			scope.Preserved.zombie_type = 9;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/engineer.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_hazard_handler_style1/sum23_hazard_handler_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_cargo_constructor/sum23_cargo_constructor.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/engineer_blueprints_back.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/fwk_engineer_blueprints.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedRanger", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deconstructor");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 7)
		{
			self.SetPlayerClass(3)	// don't use sniper, tied to doe hopper
			scope.Preserved.zombie_type = 8;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/sniper.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_cranium_cover_style1/sum23_cranium_cover_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedShotgun", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deadeye");
			Zombie_GetHealth(self)
		}
		if ((speedrandomizer == 8 && speedrandomizer_2 > 6))
		{
			self.SetPlayerClass(7)
			self.SetModelScale(1.1,0)
			PopExtUtil.AddAttributeToLoadout(self, "bombinomicon effect on death",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.55,-1)
			scope.Preserved.isenteringlevel = 0;
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.35,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",1.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",6,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from fire increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/pyro.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/all_class/invasion_captain_space_mann/invasion_captain_space_mann_pyro.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/pyro/invasion_the_space_diver/invasion_the_space_diver.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/pyro/drg_pyro_fuelTank.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedPhlog", self);
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.6,-1)
			SetFakeClientConVarValue(self, "name", "Necronaut");
			scope.Preserved.zombie_type = 6;
			Zombie_GetHealth(self)
			TeleportToTarget(self)
		}
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if ((round_number > 18 && round_number <= 19) && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 4)
		{
			self.SetPlayerClass(2)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "cancel falling damage",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "fire rate penalty",1.2,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus",0.62,-1)
			self.SetAutoJump(3.0,8.0)
			scope.Preserved.zombie_type = 4;
			PopExtUtil.AddAttributeToLoadout(self, "player skin override",1,-1) // figure out later how to stop sock from gibbing
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/sock_v4.mdl")
			PopExtUtil.StripWeapon(self,0)
			PopExtUtil.StripWeapon(self,1)
			self.GetActiveWeapon().DisableDraw()
		//	::CustomWeapons.GiveItem("HopperMelee", self);
			UseBossSpawnLocation(self)
			SetFakeClientConVarValue(self, "name", "Doe Hopper");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 5)
		{
			scope.Preserved.zombie_type = 10;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/medic.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/medic/medic_goggles.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/medic/medic_gasmask/medic_gasmask.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/medic/hwn2022_lavish_labwear/hwn2022_lavish_labwear.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_uberneedle/c_uberneedle.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg penalty vs players",2.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "fire penalty HIDDEN",1.4,-1)
			PopExtUtil.AddAttributeToLoadout(self, "bleeding duration",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.05,-1)
			SetFakeClientConVarValue(self, "name", "Atomic Researcher");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 6)
		{
			scope.Preserved.zombie_type = 9;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/engineer.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_hazard_handler_style1/sum23_hazard_handler_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_cargo_constructor/sum23_cargo_constructor.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/engineer_blueprints_back.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/fwk_engineer_blueprints.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedRanger", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deconstructor");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 7)
		{
			self.SetPlayerClass(3)	// don't use sniper, tied to doe hopper
			scope.Preserved.zombie_type = 8;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/sniper.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_cranium_cover_style1/sum23_cranium_cover_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedShotgun", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deadeye");
			Zombie_GetHealth(self)
		}
		if ((speedrandomizer == 8 && speedrandomizer_2 > 6))
		{
			self.SetPlayerClass(7)
			self.SetModelScale(1.1,0)
			PopExtUtil.AddAttributeToLoadout(self, "bombinomicon effect on death",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.55,-1)
			scope.Preserved.isenteringlevel = 0;
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.35,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",1.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",6,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from fire increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/pyro.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/all_class/invasion_captain_space_mann/invasion_captain_space_mann_pyro.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/pyro/invasion_the_space_diver/invasion_the_space_diver.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/pyro/drg_pyro_fuelTank.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedPhlog", self);
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0,-1)
			SetFakeClientConVarValue(self, "name", "Necronaut");
			scope.Preserved.zombie_type = 6;
			Zombie_GetHealth(self)
			TeleportToTarget(self)
		}
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if (round_number > 19 && playerclass != 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.25,-1)
		scope.Preserved.zombie_type = 3;
		SetFakeClientConVarValue(self, "name", "Zombie");
		Zombie_GetHealth(self)
		if (speedrandomizer == 3)
		{
			scope.Preserved.zombie_type = 10;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/medic.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/medic/medic_goggles.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/medic/medic_gasmask/medic_gasmask.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/medic/hwn2022_lavish_labwear/hwn2022_lavish_labwear.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_uberneedle/c_uberneedle.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg penalty vs players",2.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "fire penalty HIDDEN",1.4,-1)
			PopExtUtil.AddAttributeToLoadout(self, "bleeding duration",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.05,-1)
			SetFakeClientConVarValue(self, "name", "Atomic Researcher");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 4)
		{
			scope.Preserved.zombie_type = 9;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/engineer.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_hazard_handler_style1/sum23_hazard_handler_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/engineer/sum23_cargo_constructor/sum23_cargo_constructor.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/engineer_blueprints_back.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/engineer/fwk_engineer_blueprints.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedRanger", self);
			SetFakeClientConVarValue(self, "name", "Deconstructor");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 6)
		{
			self.SetPlayerClass(3)	// don't use sniper, tied to doe hopper
			scope.Preserved.zombie_type = 8;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/sniper.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_cranium_cover_style1/sum23_cranium_cover_style1.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedShotgun", self);
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			SetFakeClientConVarValue(self, "name", "Deadeye");
			Zombie_GetHealth(self)
		}
		if ((speedrandomizer == 7 && speedrandomizer_2 <= 6))
		{
			self.SetPlayerClass(7)
			self.SetModelScale(1.1,0)
			PopExtUtil.AddAttributeToLoadout(self, "bombinomicon effect on death",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.55,-1)
			scope.Preserved.isenteringlevel = 0;
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",0.35,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",1.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",6,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from fire increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/pyro.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/all_class/invasion_captain_space_mann/invasion_captain_space_mann_pyro.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/pyro/invasion_the_space_diver/invasion_the_space_diver.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/pyro/drg_pyro_fuelTank.mdl",true,null,false)
			::CustomWeapons.GiveItem("ZedPhlog", self);
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.6,-1)
			SetFakeClientConVarValue(self, "name", "Necronaut");
			scope.Preserved.zombie_type = 6;
			Zombie_GetHealth(self)
			TeleportToTarget(self)
		}
		if ((speedrandomizer == 7 && speedrandomizer_2 > 6))
		{
			scope.Preserved.zombie_type = 11;
			self.SetPlayerClass(6)
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/heavy.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/player/items/heavy/heavy_wolf_chest.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/heavy/dec22_ol_reliable_style2/dec22_ol_reliable_style2.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/heavy/hwn2016_mad_mask/hwn2016_mad_mask.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/heavy/sbox2014_war_pants/sbox2014_war_pants.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",2.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			::CustomWeapons.GiveItem("ZedMinigun", self);
			SetFakeClientConVarValue(self, "name", "Heavy Security");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 8)
		{
			self.SetPlayerClass(2)
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "cancel falling damage",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "fire rate penalty",1.2,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus",0.62,-1)
			self.SetAutoJump(3.0,8.0)
			scope.Preserved.zombie_type = 4;
			PopExtUtil.AddAttributeToLoadout(self, "player skin override",1,-1) // figure out later how to stop sock from gibbing
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/sock_v4.mdl")
			PopExtUtil.StripWeapon(self,0)
			PopExtUtil.StripWeapon(self,1)
		//	::CustomWeapons.GiveItem("HopperMelee", self);
			UseBossSpawnLocation(self)
			self.GetActiveWeapon().DisableDraw()
			SetFakeClientConVarValue(self, "name", "Doe Hopper");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 9)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",0.85,-1)
			scope.Preserved.zombie_type = 7;
			self.SetCustomModelWithClassAnimations("models/lazy_zombies_v2/demo.mdl")
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl",true,null,false)
			PopExtUtil.CreatePlayerWearable(self,"models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl",true,null,false)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken ranged decreased",0.75,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage force reduction",0.5,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "is_a_sword",72,-1)
			SetFakeClientConVarValue(self, "name", "Dead of Knight");
			Zombie_GetHealth(self)
		}
		if (speedrandomizer == 10)
		{
			PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1,-1)
			PopExtUtil.AddAttributeToLoadout(self, "damage bonus HIDDEN",1.16,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",3,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from bullets increased",0.8,-1)
			PopExtUtil.AddAttributeToLoadout(self, "dmg taken from blast increased",4,-1)
		//	self.SetModelScale(1.05,0)
			scope.Preserved.zombie_type = 5;
			self.SetCustomModelWithClassAnimations("models/kirillian/infected/hoomer_v4.mdl")
			SetFakeClientConVarValue(self, "name", "Fat Man");
			Zombie_GetHealth(self)
		}
	}
	if (playerclass == 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "move speed penalty",1.1,-1)
		PopExtUtil.AddAttributeToLoadout(self, "dmg taken from crit increased",5,-1)
		PopExtUtil.AddAttributeToLoadout(self, "cancel falling damage",1,-1)
		PopExtUtil.AddAttributeToLoadout(self, "fire rate penalty",1.2,-1)
		PopExtUtil.AddAttributeToLoadout(self, "damage bonus",0.62,-1)
		self.SetAutoJump(3.0,8.0)
		scope.Preserved.zombie_type = 4;
		PopExtUtil.AddAttributeToLoadout(self, "player skin override",1,-1) // figure out later how to stop sock from gibbing
		self.SetCustomModelWithClassAnimations("models/kirillian/infected/sock_v4.mdl")
		PopExtUtil.StripWeapon(self,0)
		PopExtUtil.StripWeapon(self,1)
	//	::CustomWeapons.GiveItem("HopperMelee", self);
		UseBossSpawnLocation(self)
		SetFakeClientConVarValue(self, "name", "Doe Hopper");
		Zombie_GetHealth(self)
	}
}

::ZedThink <- function() // I try to think
{
	local scope = self.GetScriptScope();
//	self.GetLocomotionInterface().FaceTowards
	local buttons = NetProps.GetPropInt(self, "m_nButtons")
	local playerclass = self.GetPlayerClass();

	if (scope.Preserved.warpcooldown < Time() && (self.GetHealth() / self.GetMaxHealth().tofloat()) > 0.7 && (!GetPropBool(self,"m_bGlowEnabled")))
	{
		AttemptRelocation(self)
		scope.Preserved.warpcooldown = Time() + WARP_TIME
	}
	
	if (buttons & Constants.FButtons.IN_ATTACK && scope.Preserved.isenteringlevel == 0)
	{
		if (scope.Preserved.zombie_type <= 3 && Preserved.attackcooldown < Time())
		{
			EmitSoundEx
			({
				sound_name = "Zombie.Attack",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			scope.Preserved.attackcooldown = Time() + (VOICE_COOLDOWN_TIME -1.8);
			scope.Preserved.voicecooldown = Time() + (VOICE_COOLDOWN_TIME);
		}
		if (scope.Preserved.zombie_type == 5 && Preserved.attackcooldown < Time())
		{
			EmitSoundEx
			({
				sound_name = "Fat.Attack",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			scope.Preserved.attackcooldown = Time() + (VOICE_COOLDOWN_TIME -1.8);
			scope.Preserved.voicecooldown = Time() + (VOICE_COOLDOWN_TIME);
		}
		if (playerclass == 2 && Preserved.attackcooldown < Time())
		{
			self.GetLocomotionInterface().Jump()
			scope.Preserved.attackcooldown = Time() + (VOICE_COOLDOWN_TIME -1);
		}
	}
	if (buttons & Constants.FButtons.IN_JUMP && playerclass == 2)
	{
		PopExtUtil.AddAttributeToLoadout(self, "major move speed bonus",1.25,2)
		self.SetSequence(self.LookupSequence("Pounce"))
	}
	if (scope.Preserved.attackcooldown < Time() && scope.Preserved.zombie_type == 6)
	{
		if (self.IsAllowedToTaunt())
		{
			self.Taunt(0,11)
		}
	}
	if (self.InCond(7) && scope.Preserved.zombie_type == 6 && scope.Preserved.attackcooldown < Time())
	{
		self.AddCustomAttribute("no_attack", 1, 3.3)
		TeleportToTarget(self)
	}
	if (scope.Preserved.voicecooldown < Time()) // time has passed, lets make noise
	{
		if (scope.Preserved.zombie_type == 1)
		{
			EmitSoundEx
			({
				sound_name = "Zombie.Walk",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + (VOICE_COOLDOWN_TIME +1);
		}
		if (scope.Preserved.zombie_type == 2)
		{
			EmitSoundEx
			({
				sound_name = "Zombie.Jogger",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 3)
		{
			EmitSoundEx
			({
				sound_name = "Zombie.Yell",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 4)
		{
			EmitSoundEx
			({
				sound_name = "Sock.Roam",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 5)
		{
			EmitSoundEx
			({
				sound_name = "Fat.Roam",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME -1;
		}
		if (scope.Preserved.zombie_type == 6)
		{
			EmitSoundEx
			({
				sound_name = "Necronaut.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME +1;
		}
		if (scope.Preserved.zombie_type == 7)
		{
			EmitSoundEx
			({
				sound_name = "Axe.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME +1;
		}
		if (scope.Preserved.zombie_type == 8)
		{
			EmitSoundEx
			({
				sound_name = "Shotgunner.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 9)
		{
			EmitSoundEx
			({
				sound_name = "Constructor.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 10)
		{
			EmitSoundEx
			({
				sound_name = "Researcher.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
		if (scope.Preserved.zombie_type == 11)
		{
			EmitSoundEx
			({
				sound_name = "Heavysec.Idle",
				origin = self.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			//set cooldown time
			scope.Preserved.voicecooldown = Time() + VOICE_COOLDOWN_TIME;
		}
	}
	for (local breakable; breakable = FindByNameWithin(breakable, "break_obj", self.GetOrigin(), BREAK_RADIUS); )
	{
		breakable.AcceptInput("Break","",self,null)
	}
	return -1;
}