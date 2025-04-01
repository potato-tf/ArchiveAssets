local pap_weaponmodel = Entities.FindByName(null, "strongmann_model")
local pap_train = Entities.FindByName(null, "strongmann_train")
local pap_door = Entities.FindByName(null, "strongmann_door")
local pap_start = Entities.FindByName(null, "strongmann_activate_relay")
local pap_sfx_end = Entities.FindByName(null, "strongmann_finishsfx")
local pap_button = Entities.FindByName(null, "strongmann_button")
local pap_effect = Entities.FindByName(null, "strongmann_particle")
local pap_zap = Entities.FindByName(null, "strongmann_zap_relay")
local model = ""
local model2 = ""
local upgraded = ""
local wepslot = ""
local boxuser = null

local Upgradelist = // so we know what weapon turns into what
{
	ZM_Pistol = { model1 = "models/weapons/c_models/c_pistol/c_pistol.mdl", upgradesinto = "ZM_SuperPistol", model2 = "models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl", slot = "secondary" }
	ZM_Shotgun = { model1 = "models/weapons/c_models/c_shotgun/c_shotgun.mdl", upgradesinto = "ZM_SuperShotgun", model2 = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary" }
	ZM_Sniper = { model1 = "models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl", upgradesinto = "ZM_SuperSniper", model2 = "null", slot = "primary" }
	ZM_SMG = { model1 = "models/weapons/c_models/c_smg/c_smg.mdl", upgradesinto = "ZM_SuperSMG", model2 = "null", slot = "secondary" }
	ZM_Pep = { model1 = "models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl", upgradesinto = "ZM_SuperPep", model2 = "null", slot = "primary" }
	ZM_Heatsink = { model1 = "models/weapons/c_models/c_heatsink/c_heatsink.mdl", upgradesinto = "ZM_SuperHeatsink", model2 = "null", slot = "secondary" }
	ZM_FaN = { model1 = "models/weapons/c_models/c_double_barrel.mdl", upgradesinto = "ZM_SuperFaN", model2 = "models/weapons/c_models/c_funny_doom_db.mdl", slot = "primary" }
	ZM_Thumpy = { model1 = "models/weapons/c_models/c_thump/c_thump.mdl", upgradesinto = "ZM_SuperThumpy", model2 = "null", slot = "secondary" }
	ZM_TGat = { model1 = "models/weapons/c_models/c_tgat/c_tgat.mdl", upgradesinto = "ZM_SuperTGat", model2 = "null", slot = "primary" }
	ZM_BMMH = { model1 = "models/weapons/c_models/c_bmmh/c_bmmh.mdl", upgradesinto = "ZM_SuperBMMH", model2 = "null", slot = "primary" }
	ZM_Packer = { model1 = "models/weapons/c_models/c_packer.mdl", upgradesinto = "ZM_SuperPacker", model2 = "null", slot = "primary" }
	ZM_Rusty = { model1 = "models/weapons/c_models/c_rusty/c_rusty.mdl", upgradesinto = "ZM_SuperRusty", model2 = "models/weapons/c_models/c_ver_menace/c_ver_menace.mdl", slot = "primary" }
	ZM_RPG = { model1 = "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl", upgradesinto = "ZM_SuperRPG", model2 = "null", slot = "primary" }
	ZM_Flamer = { model1 = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", upgradesinto = "ZM_SuperFlamer", model2 = "null", slot = "primary" }
	ZM_Panic = { model1 = "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl", upgradesinto = "ZM_SuperPanic", model2 = "null", slot = "secondary" }
	ZM_PistolB = { model1 = "models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl", upgradesinto = "ZM_SuperPistol", model2 = "models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl", slot = "secondary" }
	ZM_Raygun = { model1 = "models/weapons/c_models/c_zapper/c_zapper.mdl", upgradesinto = "ZM_SuperRaygun", model2 = "", slot = "secondary" }
	ZM_BurningLove = { model1 = "models/weapons/c_models/c_pyroshot/c_pyroshot.mdl", upgradesinto = "ZM_DrainingLoveStory", model2 = "null", slot = "primary" } 
}

::Strongmachine <- 
{
	function Activate(activator, weapon)
	{
		boxuser = activator
		pap_weaponmodel.AcceptInput("enable","",null,null)
		pap_button.AcceptInput("lock","",null,null)
		pap_door.AcceptInput("open","",null,null)
		EntFireByHandle(pap_door,"close","",1,null,null);
		pap_train.AcceptInput("SetSpeedForwardModifier","0.15",null,null)
		pap_train.AcceptInput("startforward","",null,null)
		EntFireByHandle(pap_train,"stop","",1.4,null,null);
		model = Upgradelist[weapon].model1
		model2 = Upgradelist[weapon].model2
		upgraded = Upgradelist[weapon].upgradesinto
		wepslot = Upgradelist[weapon].slot
		pap_weaponmodel.SetModel(model)
		local scope = activator.GetScriptScope()
		scope.Preserved.papweapon = upgraded
		scope.Preserved.papslot = wepslot
		pap_train.AcceptInput("SetSpeedForwardModifier","5",null,null)
		pap_start.AcceptInput("trigger","",null,null)
		if (model2 != "null")
		{
			EntFireByHandle(pap_weaponmodel,"SetModel",model2,2,null,null);
		}
		EntFireByHandle(pap_weaponmodel,"runscriptcode","Strongmachine.ReturnUberWeapon(activator)",5,activator,null);
	}
	function ReturnUberWeapon(activator)
	{
		pap_door.AcceptInput("open","",null,null)
		pap_train.AcceptInput("SetSpeedForwardModifier","0.02",null,null)
		pap_train.AcceptInput("TeleportToPathTrack","strongmann_track1",null,null)
		pap_train.AcceptInput("startforward","",null,null)
		pap_train.AcceptInput("SetSpeedForwardModifier","0.02",null,null)
		pap_effect.AcceptInput("start","",null,null)
		pap_zap.AcceptInput("trigger","",null,null)
		EntFireByHandle(pap_effect,"stop","",3,null,null);
		pap_sfx_end.AcceptInput("playsound","",null,null)
		EntFireByHandle(activator,"runscriptcode","ClearPaPScope(self)",10,null,null);
	}
	function Reset()
	{
		pap_weaponmodel.AcceptInput("disable","",null,null)
		pap_door.AcceptInput("close","",null,null)
		pap_train.AcceptInput("teleporttopathtrack","strongmann_track1",null,null)
		pap_train.AcceptInput("SetSpeedForwardModifier","1",null,null)
		pap_train.AcceptInput("stop","",null,null)
		pap_button.AcceptInput("unlock","",null,null)
		if (boxuser != null)
		{
			boxuser.GetScriptScope().Preserved.isusingstrongmann = false
			ClearPaPScope(boxuser)
			boxuser = null
		}
	}
}