// WOW! IT'S THE ZOMBIES!
// Here's where we load some shit

IncludeScript("popextensions_main.nut", getroottable());
IncludeScript("zombiemode/hooks.nut",getroottable());
IncludeScript("zombiemode/customweapons.nut");
IncludeScript("zombiemode/zm_util.nut");
IncludeScript("zombiemode/playerlogic.nut");
IncludeScript("zombiemode/zeds/zed_init.nut");
IncludeScript("zombiemode/roundlogic.nut");
IncludeScript("zombiemode/mysterybox.nut");
IncludeScript("zombiemode/packapunch.nut");
IncludeScript("zombiemode/barricades.nut");
IncludeScript("zombiemode/pointtemplates.nut");
PrecacheScriptSound("MVM.BotStep");
PrecacheScriptSound("Zombie.Walk");
PrecacheScriptSound("Zombie.Jogger");
PrecacheScriptSound("Zombie.Yell");
PrecacheScriptSound("Zombie.Attack");
PrecacheScriptSound("Zombie.Death");
PrecacheScriptSound("Fat.Roam");
PrecacheScriptSound("Fat.Attack");
PrecacheScriptSound("Fat.BlastOff");
PrecacheScriptSound("Fat.Death");
PrecacheScriptSound("Sock.Roam");
PrecacheScriptSound("Sock.Death");
PrecacheScriptSound("Axe.Idle");
PrecacheScriptSound("Necronaut.Idle");
PrecacheScriptSound("Necronaut.Warp");
PrecacheScriptSound("Shotgunner.Idle");
PrecacheScriptSound("Shotgunner.Death");
PrecacheScriptSound("Shotgunner.Fire");
PrecacheScriptSound("Constructor.Idle");
PrecacheScriptSound("Researcher.Idle");
PrecacheScriptSound("Heavysec.Idle");
PrecacheScriptSound("Announcer.AM_LastManAlive01");
PrecacheScriptSound("Announcer.AM_LastManAlive02");
PrecacheScriptSound("Announcer.AM_LastManAlive03");
PrecacheScriptSound("Announcer.AM_LastManAlive04");

// Precache things
function Precache()
{
	PrecacheScriptSound("mvm/mvm_bought_upgrade.wav");
	PrecacheScriptSound("buttons/button4.wav");
	PrecacheScriptSound("doors/door_latch1.wav");
	PrecacheScriptSound("buttons/button8.wav"); // button fail
	PrecacheScriptSound("doors/door_locked2.wav"); // door fail
	PrecacheScriptSound("misc/halloween/merasmus_spell.wav"); // powerup spawn sound
	PrecacheScriptSound("misc/doomsday_missile_explosion.wav"); // nuke
	PrecacheScriptSound("Halloween.TeleportVortex.BookSpawn"); // teleport sounds
	PrecacheScriptSound("Halloween.TeleportVortex.BookExit"); // teleport sounds
	PrecacheScriptSound("misc/halloween/merasmus_stun.wav"); // ostarion
	
	PrecacheScriptSound("deadlands/telephone.mp3"); 
	PrecacheScriptSound("deadlands/powerup_instagib.mp3"); 
	PrecacheScriptSound("deadlands/powerup_maxammo.mp3"); 
	PrecacheScriptSound("deadlands/powerup_nuke.mp3"); 
	PrecacheScriptSound("deadlands/powerup_bonuspoints.mp3"); 
	PrecacheScriptSound("deadlands/powerup_doublepoints.mp3"); 
	PrecacheScriptSound("deadlands/powerup_minigun.mp3"); 
	PrecacheScriptSound("deadlands/pickup_maxammo.mp3"); 
	PrecacheScriptSound("deadlands/pickup_bonuspoints.mp3"); 
	PrecacheScriptSound("items/powerup_pickup_crits.wav");
	PrecacheScriptSound("items/powerup_pickup_haste.wav");
	
	PrecacheScriptSound("deadlands/vending_use.wav");
	PrecacheScriptSound("deadlands/wallgun_purchase.mp3");
	PrecacheScriptSound("ui/item_heavy_gun_pickup.wav");
	PrecacheScriptSound("misc/happy_birthday_tf_10.wav");
	PrecacheScriptSound("deadlands/thedud_laugh.mp3");
	PrecacheScriptSound("misc/halloween/merasmus_disappear.wav");
	PrecacheScriptSound("misc/halloween/merasmus_appear.wav");
	PrecacheScriptSound("weapons/sentry_upgrading2.wav");	// we have to precache a sound already played by the game...
	PrecacheScriptSound("player/cyoa_pda_beep4.wav");
	PrecacheScriptSound("weapons/draw_gas_can.wav");
	
//	MissionAttributes.SetConvar("tf_tournament_classlimit_demoman",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_engineer",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_heavy",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_medic",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_pyro",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_scout",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_sniper",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_soldier",2);
//	MissionAttributes.SetConvar("tf_tournament_classlimit_spy",2);

	printl("Zombie Mode loaded.")
	
	if (MaxClients().tointeger() < 32) printl("Running below 32 players is not recommended!!")
	if (MaxClients().tointeger() <= 10)
	{
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
		printl("MAXPLAYERS TOO LOW, MAP WILL NOT WORK!!")
	}
}