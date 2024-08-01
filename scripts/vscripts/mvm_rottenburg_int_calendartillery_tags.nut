//VScript currently cannot get a table of every tag a bot currently has
//we need to do this horrible workaround of copying every tag from every bot into an array
//then iterate through it on bot spawn to see if the bot has this tag

::__tagarray <-  [

	//Wave 1
	"popext_aimat|flag"
	
	//Wave 2
	"popext_usehumananims"
	
	//Wave 3
	"popext_customweaponmodel|models/empty.mdl"
	"popext_stripslot|0|0"
	"popext_spell|0|7.5|3"
	"popext_spell|0|10|3"
	"popext_homingprojectile|15|0.7"
	"popext_usehumanmodel"
	"popext_meleeai"
	// "popext_addcondonhit|24|4"
	
	//Wave 4
	"popext_giveweapon|tf_weapon_fireaxe|474"
	// "popext_addcondonhit|27|6"
	"popext_customattr|custom projectile model|models/props_halloween/smlprop_spider.mdl"
	
	//Wave 5
	"popext_aimat|head"
	"popext_weaponswitch|0|12|0.1"
	"popext_weaponswitch|1|12|3.6"
	"popext_addcond|46"
	//Wave 6
	
	
	"popext_fireweapon|2048"
]