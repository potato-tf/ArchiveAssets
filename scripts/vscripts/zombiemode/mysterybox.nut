local timesrolled = 0;
local maxrolls = RandomInt(6,10)
local boxmoved = false; 
local timesmoved = 0;
local rollnumber = -1	// stash diceroll value here
local uberw_picked = false;
local warp_roulette = Entities.FindByName(null, 	 "dumpster_warp_roulette")
local dumpster_lid = Entities.FindByName(null, 	 "dumpster_rotdoor1")
local dumpster_model = Entities.FindByName(null, "dumpster_prop1")
local dumpster_weapon = Entities.FindByName(null, "dumpster_weapon1")
local dumpster_train = Entities.FindByName(null, "dumpster_train1")
local dumpster_light = Entities.FindByName(null, "dumpster_light1")
local dumpster_sound = Entities.FindByName(null, "dumpster_jingle1")
local dumpster_effect = Entities.FindByName(null, "dumpster_particles1")
local dumpster_timer = Entities.FindByName(null, "dumpster_timer1")
local dumpster_button = Entities.FindByName(null, "dumpster_button1")
local dumpster_dud = Entities.FindByName(null, "dumpster_dudprop1")
local dumpster_warpeffect = Entities.FindByName(null, "dumpster_warpeff1")
local dumpster_jail = Entities.FindByName(null, "red_spawnbrush")
local model = "null"
local boxuser = null
local UserTookItem = false

::BoxTable <-
[
	{itemname = "ZM_FaN", slot = "primary", model = "models/weapons/c_models/c_double_barrel.mdl", response = "TLK_MVM_LOOT_COMMON",}
	{itemname = "ZM_Thumpy", slot = "secondary", model = "models/weapons/c_models/c_thump/c_thump.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_TGat", slot = "primary", model = "models/weapons/c_models/c_tgat/c_tgat.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_Rusty", slot = "primary", model = "models/weapons/c_models/c_rusty/c_rusty.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_Raygun", slot = "secondary", model = "models/weapons/c_models/c_zapper/c_zapper.mdl", response = "TLK_MVM_LOOT_ULTRARARE",}
	{itemname = "ZM_BurningLove", slot = "primary", model = "models/weapons/c_models/c_pyroshot/c_pyroshot.mdl", response = "TLK_MVM_LOOT_ULTRARARE",}
	{itemname = "ZM_BMMH", slot = "primary", model = "models/weapons/c_models/c_bmmh/c_bmmh.mdl", response = "TLK_MVM_LOOT_COMMON",}
	{itemname = "ZM_Packer", slot = "primary", model = "models/weapons/c_models/c_packer.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_RPG", slot = "primary", model = "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_Flamer", slot = "primary", model = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_Panic", slot = "secondary", model = "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl", response = "TLK_MVM_LOOT_RARE",}
	{itemname = "ZM_PistolB", slot = "secondary", model = "models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl", response = "TLK_MVM_LOOT_COMMON",}
]

::ModelShuffle <-
[
	"models/weapons/c_models/c_thump/c_thump.mdl",
	"models/weapons/c_models/c_tgat/c_tgat.mdl",
	"models/weapons/c_models/c_bmmh/c_bmmh.mdl",
	"models/weapons/c_models/c_packer.mdl",
	"models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl",
	"models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl",
	"models/workshop_partner/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl",
	"models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl",
	"models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl",
	"models/weapons/c_models/c_zapper/c_zapper.mdl",
	"models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl",
	"models/weapons/c_models/c_pyroshot/c_pyroshot.mdl",
	"models/weapons/c_models/c_rusty/c_rusty.mdl",
	"models/weapons/c_models/c_sandwich/c_sandwich.mdl"
]

::Mysterybox <- 
{
	function Activate(activator)
	{
		boxuser = activator
		UserTookItem = false
		dumpster_weapon.AcceptInput("enable","",null,null)
		dumpster_lid.AcceptInput("open","",null,null)
		dumpster_train.AcceptInput("startforward","",null,null)
		dumpster_light.AcceptInput("turnon","",null,null)
		dumpster_effect.AcceptInput("start","",null,null)
		dumpster_timer.AcceptInput("enable","",null,null)
		dumpster_button.AcceptInput("lock","",null,null)
		dumpster_sound.AcceptInput("playsound","",null,null)
		EntFireByHandle(dumpster_timer,"disable","",3.8,null,null);
		EntFireByHandle(dumpster_weapon,"runscriptcode","Mysterybox.RollWeapon(activator)",4,activator,null);
		timesrolled += 1
	}
	function RollRandomModel()
	{
		local diceroll = RandomInt(0,12)
		model = ModelShuffle[diceroll]	
		dumpster_weapon.SetModel(model)
	}
	function RollWeapon(activator)
	{
		if (timesrolled < maxrolls)
		{
			dumpster_timer.AcceptInput("disable","",null,null)
			dumpster_train.AcceptInput("SetSpeedForwardModifier","0.28",null,null)
			dumpster_train.AcceptInput("startforward","",null,null)
		
			local diceroll = RandomInt(0,10)
			if (diceroll == rollnumber) diceroll = RandomInt(0,10)
			rollnumber = diceroll
			local scope = activator.GetScriptScope()
			
			dumpster_weapon.SetModel(BoxTable[diceroll].model)
			scope.Preserved.mysteryslot = BoxTable[diceroll].slot
			scope.Preserved.mysteryitemname = BoxTable[diceroll].itemname
			scope.Preserved.mysteryresponse = BoxTable[diceroll].response
			EntFireByHandle(activator,"runscriptcode","ClearBoxScope(self)",10,null,null);
			
			if (BoxTable[diceroll].itemname == "ZM_Raygun" && timesmoved == 0)
			{
				dumpster_weapon.SetModel("models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl")
				scope.Preserved.mysteryitemname = "ZM_PistolB";
				scope.Preserved.mysteryslot = "secondary";
				scope.Preserved.mysteryresponse = "TLK_MVM_LOOT_COMMON";
			}
			if ((BoxTable[diceroll].itemname == "ZM_BurningLove" && timesmoved <= 1) || (BoxTable[diceroll].itemname == "ZM_BurningLove" && uberw_picked))
			{
				dumpster_weapon.SetModel("models/weapons/c_models/c_packer.mdl")
				scope.Preserved.mysteryitemname = "ZM_Packer";
				scope.Preserved.mysteryslot = "primary";
				scope.Preserved.mysteryresponse = "TLK_MVM_LOOT_RARE";
			}
		}
		if (timesrolled >= maxrolls) // you rolled too many times, you get the dud!
		{
			activator.RemoveCurrency(-950)
			local scope = activator.GetScriptScope()
			scope.Preserved.isusingbox = false
			timesrolled = 0
			timesmoved += 1
			maxrolls = RandomInt(6,10)
			ClientPrint(activator, HUD_PRINTCENTER,"Surprise!")
			dumpster_weapon.AcceptInput("disable","",null,null)
			dumpster_dud.AcceptInput("enable","",null,null)
			dumpster_effect.AcceptInput("stop","",null,null)
			dumpster_light.AcceptInput("turnoff","",null,null)
			PopExtUtil.PlaySoundOnAllClients("misc/happy_birthday_tf_10.wav")
			EntFireByHandle(dumpster_model,"runscriptcode","PopExtUtil.PlaySoundOnAllClients(`deadlands/thedud_laugh.mp3`)",1,null,activator);
			EntFireByHandle(dumpster_warpeffect,"start","",3,null,null);
			EntFireByHandle(dumpster_model,"runscriptcode","PopExtUtil.PlaySoundOnAllClients(`misc/halloween/merasmus_disappear.wav`)",3,null,activator);
			EntFireByHandle(dumpster_warpeffect,"stop","",3.8,null,null);
			EntFireByHandle(dumpster_model,"runscriptcode","self.SetAbsOrigin(activator.GetCenter())",3.8,dumpster_jail,null);
			EntFireByHandle(dumpster_model,"runscriptcode","Mysterybox.Reset()",4,null,activator);
			EntFireByHandle(dumpster_warpeffect,"start","",29,null,null);
			EntFireByHandle(warp_roulette,"PickRandomShuffle","",30,null,null);
			EntFireByHandle(dumpster_model,"runscriptcode","PopExtUtil.PlaySoundOnAllClients(`misc/halloween/merasmus_appear.wav`)",30,null,activator);
			EntFireByHandle(dumpster_warpeffect,"stop","",31,null,null);
		}
	}
	function MarkAsTaken()
	{
		UserTookItem = true
	}
	function Reset()
	{
		if (rollnumber != -1 && (BoxTable[rollnumber].itemname == "ZM_BurningLove") && timesmoved >= 2 && UserTookItem) uberw_picked = true
		dumpster_weapon.AcceptInput("disable","",null,null)
		dumpster_lid.AcceptInput("close","",null,null)
		dumpster_train.AcceptInput("teleporttopathtrack","dumpster_track1",null,null)
		dumpster_train.AcceptInput("SetSpeedForwardModifier","1",null,null)
		dumpster_train.AcceptInput("stop","",null,null)
		dumpster_light.AcceptInput("turnoff","",null,null)
		dumpster_effect.AcceptInput("stop","",null,null)
		dumpster_button.AcceptInput("unlock","",null,null)
		dumpster_dud.AcceptInput("disable","",null,null)
		if (boxuser != null)
		{
			boxuser.GetScriptScope().Preserved.isusingbox = false
			ClearBoxScope(boxuser)
			boxuser = null
		}
	}
}