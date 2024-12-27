::ExtraItems <-
{
	"ZM_Pistol" : // everyone's starting weapon
	{
        OriginalItemName = "Upgradeable TF_WEAPON_PISTOL"
		Slot = "secondary"
		ItemClass = "tf_weapon_pistol"
        AnimSet = "engineer"
		"hidden secondary max ammo penalty" : 0.48
		"can headshot" : 1
	}
	"ZM_SuperPistol" : 
	{
        OriginalItemName = "Upgradeable TF_WEAPON_PISTOL"
        Model = "models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_pistol"
        AnimSet = "engineer"
		"hidden secondary max ammo penalty" : 0.96
		"clip size bonus" : 2
		"bullets per shot bonus" : 2
		"damage bonus" : 3
		"projectile spread angle penalty" : 2
		"override projectile type" : 2 
		"projectile speed increased" : 1.4
		"mult projectile scale" : 2 // I like my bullets like my women. BIG
		"no self blast dmg" : 2
		"custom projectile model" : "models/weapons/w_models/w_rocketbullet.mdl"
	}
	"ZM_Sniper" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SNIPERRIFLE"
		Slot = "primary"
		ItemClass = "tf_weapon_sniperrifle"
        AnimSet = "sniper"
		"maxammo primary increased" : 2
		"SRifle Charge rate increased" : 2
		"can headshot" : 1
	}
	"ZM_SuperSniper" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SNIPERRIFLE"
		Slot = "primary"
		ItemClass = "tf_weapon_sniperrifle"
        AnimSet = "sniper"
		"maxammo primary increased" : 4
		"SRifle Charge rate increased" : 3
		"dmg penalty vs players" : 4
		"explosive sniper shot" : 3		// yup no head rattle this time, bauernhof boys!
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"can headshot" : 1
	}
	"ZM_Shotgun" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
		Slot = "secondary"
		ItemClass = "tf_weapon_shotgun_pyro"
        AnimSet = "pyro"
		"can headshot" : 1
	}
	"ZM_SuperShotgun" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_shotgun_pyro"
        AnimSet = "pyro"
		"maxammo secondary increased" : 2
		"clip size bonus" : 2
		"bullets per shot bonus" : 2
		"damage bonus" : 2
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"can headshot" : 1
	}
	"ZM_SMG" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"maxammo secondary increased" : 2
		"can headshot" : 1
	}
	"ZM_SuperSMG" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"maxammo secondary increased" : 4
		"clip size bonus" : 2
		"bullets per shot bonus" : 2
		"damage bonus" : 2
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"can headshot" : 1
	}
	"ZM_Pep" :
	{
        OriginalItemName = "The Loch-n-Load"
		Slot = "primary"
		ItemClass = "tf_weapon_grenadelauncher"
        AnimSet = "demo"
		"self dmg push force decreased" : 0.15
		"maxammo primary increased" : 1.5
	}
	"ZM_SuperPep" :
	{
        OriginalItemName = "The Loch-n-Load"
		Slot = "primary"
		ItemClass = "tf_weapon_grenadelauncher"
        AnimSet = "demo"
		"maxammo primary increased" : 3
		"clip size penalty" : 0.25
		"damage bonus" : 3
		"sticky air burst mode" : -2
		"override projectile type" : 3
		"custom projectile model" : "models/props_lakeside_event/bomb_temp.mdl"
		"Blast radius increased" : 2
		"use large smoke explosion" : 2
		"self dmg push force decreased" : 0.15
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_Heatsink" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
        Model = "models/weapons/c_models/c_heatsink/c_heatsink.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"fire rate bonus HIDDEN" : 0.8
		"maxammo secondary increased" : 2.13
		"clip size penalty HIDDEN" : 1.6
		"mult_spread_scales_consecutive" : 1
		"damage bonus HIDDEN" : 1.5
		"can headshot" : 1
	}
	"ZM_SuperHeatsink" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
        Model = "models/weapons/c_models/c_heatsink/c_heatsink.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"damage bonus" : 2.5
		"fire rate bonus HIDDEN" : 0.8
		"maxammo secondary increased" : 4.26
		"clip size penalty HIDDEN" : 2.6
		"mult_spread_scales_consecutive" : 1
		"can headshot" : 1
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	// stuff that is box-only
	"ZM_FaN" :
	{
		OriginalItemName = "The Force-a-Nature"
        Model = "models/weapons/c_models/c_double_barrel.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_scattergun"
        AnimSet = "scout"
		"maxammo primary increased" : 2
		"can headshot" : 1
	}
	"ZM_SuperFaN" :
	{
		OriginalItemName = "The Force-a-Nature"
        Model = "models/weapons/c_models/c_funny_doom_db.mdl" // find longer barrel FaN model
		Slot = "primary"
		ItemClass = "tf_weapon_scattergun"
        AnimSet = "scout"
		"scattergun knockback mult" : 2
	//	"clip size penalty" : 0.1
		"bullets per shot bonus" : 6
		"maxammo primary increased" : 3
		"can headshot" : 1
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"replace weapon fire sound" : ["Weapon_Scatter_Gun_Double.Single","Deadlands_BigGun.Single"]
	}
	"ZM_Thumpy" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
        Model = "models/weapons/c_models/c_thump/c_thump.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"maxammo secondary increased" : 2.4
		"clip size penalty HIDDEN" : 1.2
		"damage bonus HIDDEN" : 2
		"can headshot" : 1
	}
	"ZM_SuperThumpy" :
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SMG"
        Model = "models/weapons/c_models/c_thump/c_thump.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_smg"
        AnimSet = "sniper"
		"maxammo secondary increased" : 4.8
		"clip size penalty HIDDEN" : 2.4
		"damage bonus HIDDEN" : 3
		"can headshot" : 1
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_TGat" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"	// can't do burst fire weapons, so instead fire all barrels at once
        Model = "models/weapons/c_models/c_tgat/c_tgat.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"fire rate bonus HIDDEN" : 1.2
		"mod max primary clip override" : 3
		"bullets per shot bonus" : 3
		"Reload time increased" : 1.3
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_TGat.Single"]
		"can headshot" : 1
	}
	"ZM_SuperTGat" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_tgat/c_tgat.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"fire rate bonus HIDDEN" : 1.2
		"bullets per shot bonus" : 6
		"Reload time increased" : 1.1
		"maxammo primary increased" : 2
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_TGat.Single"]
		"can headshot" : 1
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_BMMH" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_bmmh/c_bmmh.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"explosive bullets ext" :
		{
			damage = 25
			radius = 112
			particle = "rd_robot_explosion"
			killicon = "shotgun_pyro"
			sound = "misc/null.wav"
		}
		"clip size penalty" : 0.5
		"fire rate penalty" : 1.25
		"blast dmg to self increased" : 0.1 // lower self damage?
		"spread penalty" : 1.33
		"self dmg push force decreased" : 0
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_BMMH.Single"]
	}
	"ZM_SuperBMMH" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_bmmh/c_bmmh.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"explosive bullets ext" :
		{
			damage = 50
			radius = 112
			particle = "rd_robot_explosion"
			killicon = "shotgun_pyro"
			sound = "misc/null.wav"
		}
		"damage bonus HIDDEN" : 4
		"fire rate penalty" : 1.25
		"blast dmg to self increased" : 0.1 // lower self damage?
		"spread penalty" : 1.15
		"self dmg push force decreased" : 0
		"maxammo primary increased" : 2
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_BMMH.Single"]
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_Packer" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_packer.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_scattergun"
        AnimSet = "scout"
		"panic_attack" : 1
	//	"auto fires full clip" : 1
		"damage bonus HIDDEN" : 2.5
		"fire rate bonus HIDDEN" : 0.5
		"mod max primary clip override" : 4
		"mult_spread_scales_consecutive" : 1
		"maxammo primary increased" : 1.5
		"can headshot" : 1
	}
	"ZM_SuperPacker" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/weapons/c_models/c_packer.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_scattergun"
        AnimSet = "scout"
		"panic_attack" : 1
	//	"auto fires full clip" : 1
		"damage bonus HIDDEN" : 3.5
		"fire rate bonus HIDDEN" : 0.5
		"mod max primary clip override" : 8
		"mult_spread_scales_consecutive" : 1
		"maxammo primary increased" : 3
		"can headshot" : 1
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_RPG" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_ROCKETLAUNCHER"
		Slot = "primary"
		ItemClass = "tf_weapon_rocketlauncher"
        AnimSet = "soldier"
		"damage bonus HIDDEN" : 1.5
		"maxammo primary increased" : 1.5
		"self dmg push force decreased" : 0.15
	}
	"ZM_SuperRPG" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_ROCKETLAUNCHER"
		Slot = "primary"
		ItemClass = "tf_weapon_rocketlauncher"
        AnimSet = "soldier"
		"damage bonus HIDDEN" : 2.5
		"clip size bonus" : 2
		"self dmg push force decreased" : 0.15
		"maxammo primary increased" : 3
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_Flamer" :
	{
		OriginalItemName = "The Nostromo Napalmer"
        Model = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_flamethrower"
        AnimSet = "pyro"
		"damage bonus HIDDEN" : 2
		"maxammo primary increased" : 2
	}
	"ZM_SuperFlamer" :
	{
		OriginalItemName = "The Nostromo Napalmer"
        Model = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_flamethrower"
        AnimSet = "pyro"
		"damage bonus HIDDEN" : 3
		"slow enemy on hit" : 1
		"maxammo primary increased" : 4
		"lunchbox adds maxhealth bonus" : 2
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
	}
	"ZM_Rusty" :
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SCATTERGUN"
        Model = "models/weapons/c_models/c_rusty/c_rusty.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_scattergun"	// despite this being here, the game thinks it's a shotgun ??
        AnimSet = "scout"
		"bullets per shot bonus" : 0.33
		"mod max primary clip override" : 150
		"fire rate bonus HIDDEN" : 0.2
		"damage bonus HIDDEN" : 4
		"maxammo primary increased" : 9.375
		"Reload time increased" : 1.6
		"scattergun no reload single" : 1
		"replace weapon fire sound" : ["Weapon_Scatter_Gun.Single","Deadlands_Rusty.Single"]
		"can headshot" : 1
	}
	"ZM_SuperRusty" :
	{
		OriginalItemName = "Iron Curtain"
        Model = "models/weapons/c_models/c_ver_menace/c_ver_menace.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_minigun"
        AnimSet = "heavy"
		"bullets per shot bonus" : 1.33	// give spread
		"damage bonus HIDDEN" : 3
		"maxammo primary increased" : 3
		"weapon spread bonus" : 0.8
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"can headshot" : 1
	}
	"ZM_Panic" : // using multiclass weapons dont work so go around
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_shotgun_pyro"
        AnimSet = "pyro"
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Weapon_BackShot_Shotty.Single"]
		"bullets per shot bonus" : 1.5
		"fire rate bonus with reduced health" : 0.25
		"panic_attack_negative" : 0.25
		"maxammo secondary increased" : 2
		"can headshot" : 1
	}
	"ZM_SuperPanic" : // using multiclass weapons dont work so go around
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
        Model = "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_shotgun_pyro"
        AnimSet = "pyro"
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Weapon_BackShot_Shotty.Single"]
		"bullets per shot bonus" : 3
		"fire rate bonus with reduced health" : 0.1
		"panic_attack_negative" : 0.25
		"reload time increased hidden" : 0.75
		"maxammo secondary increased" : 4
		"clip size bonus" : 2
		"paintkit_proto_def_index" : 402
		"set_item_texture_wear" : 0
		"can headshot" : 1
	}
	"ZM_PistolB" : // everyone's starting weapon but with B
	{
        OriginalItemName = "Upgradeable TF_WEAPON_PISTOL"
        Model = "models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_pistol"
        AnimSet = "engineer"
		"mod max primary clip override" : 8
		"hidden secondary max ammo penalty" : 0.48
		"fire rate bonus HIDDEN" : 1.33
		"damage bonus HIDDEN" : 2
		"can headshot" : 1
	//	"replace weapon fire sound" : ["Weapon_Pistol.Single","Weapon_PickPocket_Pistol.Single"]
	}
	"ZM_Raygun" : // this
	{
        OriginalItemName = "The C.A.P.P.E.R"
        Model = "models/weapons/c_models/c_zapper/c_zapper.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_pistol"
        AnimSet = "engineer"
		"explosive bullets ext" :
		{
			damage = 100
			radius = 96
			particle = "merasmus_bomb_explosion"
			sound = "weapons/cow_mangler_explode.wav"
			killicon = "the_capper"
		}
		"fire rate penalty"  : 1.5
		"mod max primary clip override" : 20
		"blast dmg to self increased" : 0.1
		"self dmg push force decreased" : 0
		"can headshot" : 1
		"replace weapon fire sound" : ["Weapon_Capper.Single","Deadlands_Raygun.Single"]
	}
	"ZM_SuperRaygun" : // thiser
	{
        OriginalItemName = "The C.A.P.P.E.R"
        Model = "models/weapons/c_models/c_zapper/c_zapper.mdl"
		Slot = "secondary"
		ItemClass = "tf_weapon_pistol"
        AnimSet = "engineer"
		"explosive bullets ext" :
		{
			damage = 200
			radius = 96
			particle = "merasmus_bomb_explosion"
			sound = "weapons/cow_mangler_explode.wav"
			killicon = "the_capper"
		}
		"fire rate penalty"  : 1.5
		"mod max primary clip override" : 40
		"maxammo secondary increased" : 2
		"blast dmg to self increased" : 0.1
		"self dmg push force decreased" : 0
		"can headshot" : 1
		"replace weapon fire sound" : ["Weapon_Capper.Single","Deadlands_Raygun.Single"]
	}
	"ZM_SVDL" : // aka Smith's Violent Death Laser
	{
		OriginalItemName = "The Cow Mangler 5000" // test later if it's possible to have mangler without inf ammo
        Model = "models/weapons/c_models/c_megalaser/c_megalaser.mdl"	// we can actually bullshit it with itemclass below
		Slot = "primary"
		ItemClass = "tf_weapon_rocketlauncher"
        AnimSet = "soldier"
		"damage bonus HIDDEN" : 4
		"Projectile speed increased" : 7
		"rocket specialist" : 4
		"self dmg push force decreased" : 0.15
		"clip size bonus" : 2.5
		"maxammo primary increased" : 3
		"custom projectile model" : "models/weapons/w_models/w_drg_ball.mdl"
	}
	"ZM_BurningLove" : // that one gun
	{
		OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"	
        Model = "models/weapons/c_models/c_pyroshot/c_pyroshot.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"set_item_texture_wear" : 0
		"damage bonus" : 2
		"damage bonus vs burning" : 5
		"bullets per shot bonus" : 2
		"fire rate bonus" : 0.9
		"faster reload rate" : 0.75
		"Set DamageType Ignite" : 1
		"attach particle effect" : 13
		"can headshot" : 1
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_BurningLove.Single"]
	}
	"ZM_DrainingLoveStory" : // even better now
	{
        OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"	
        Model = "models/weapons/c_models/c_pyroshot/c_pyroshot.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_shotgun_primary"
        AnimSet = "engineer"
		"maxammo primary increased" : 2
		"damage bonus" : 3
		"damage bonus vs burning" : 5
		"bullets per shot bonus" : 3
		"fire rate bonus" : 0.9
		"faster reload rate" : 0.75
		"Set DamageType Ignite" : 1
		"attach particle effect" : 13
		"can headshot" : 1
		"replace weapon fire sound" : ["Weapon_Shotgun.Single","Deadlands_BurningLove.Single"]
	}
	"ZM_Shiv" : // only in pap room
	{
        OriginalItemName = "Prinny Machete"
        Model = "models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl"
		Slot = "melee"
		"damage bonus HIDDEN" : 10
	}
	"Death Machine" : // powerup only
	{
        OriginalItemName = "Upgradeable TF_WEAPON_MINIGUN"
        Model = "models/weapons/c_models/c_minigun/c_minigun.mdl"
		Slot = "primary"
		ItemClass = "tf_weapon_minigun"
        AnimSet = "heavy"
		"bullets per shot bonus" : 2
		"damage bonus" : 1.5
		"maxammo primary increased" : 4.995
		"can headshot" : 1
		"mod minigun can holster while spinning" : 1
	}
	"Perk Bottle" : // not usable
	{
		OriginalItemName = "The Buff Banner"
        Model = "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"
		ItemClass = "tf_weapon_buff_item"
        AnimSet = "soldier"
		"provide on active" : 1
		"disable weapon switch" : 1
		"deploy time increased" : 20
	}
	"ZedShotgun" :	// enemy only weapons
	{
		OriginalItemName = "The Widowmaker"
		"fire rate penalty" : 2.75
		"bullets per shot bonus" : 0.5
		"damage bonus" : 1.45
		"SET BONUS: max health additive bonus" : 150
		"gesture speed increase" : 1.55
		"replace weapon fire sound" : ["Weapon_WidowMaker.Single","Shotgunner.Fire"]
	}
	"ZedPhlog" :
	{
		OriginalItemName = "The Phlogistinator"
		"damage penalty" : 0.5
		"gesture speed increase" : 0.8
		"SET BONUS: max health additive bonus" : 2000
	}
	"ZedRanger" :
	{
		OriginalItemName = "The Rescue Ranger"
		"fire rate penalty" : 2
		"mark for death" : 1
		"fire rate penalty" : 2.75
		"damage bonus HIDDEN" : 0.3
	}
	"ZedMinigun" :
	{
		OriginalItemName = "Deflector"
		"bullets per shot bonus" : 0.25
		"damage bonus HIDDEN" : 1.67
		"minigun spinup time increased" : 1.5
		"SET BONUS: max health additive bonus" : 3000
	}
}