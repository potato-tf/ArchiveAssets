//By washy
//credit to ficool2, Yaki and LizardofOz
//special thanks to fellen for help on tf_item_map.nut
//ExtraItems <-	// Example, make your own script and use ::ExtraItems to set up custom weapon list
//{
//	"Wasp Launcher" :
//	{
//        OriginalItemName = "Upgradeable TF_WEAPON_ROCKETLAUNCHER"
//        Model = "models/weapons/c_models/c_wasp_launcher/c_wasp_launcher.mdl"
//        "blast radius increased" : 1.5
//        "max health additive bonus" : 100
//	}
//	"Thumper" :
//	{
//        OriginalItemName = "Upgradeable TF_WEAPON_SHOTGUN_PRIMARY"
//        Model = "models/weapons/c_models/c_rapidfire/c_rapidfire_1.mdl"
//		//defaults to engineer's primary shotgun, need to specify
//		//ItemClass and Animset to use secondary shotgun on non shotgun wielding classes
//		//specify Slot to make sure the reserve ammo fix is applied properly
//		ItemClass = "tf_weapon_shotgun_soldier"
//        AnimSet = "soldier"
//		Slot = "secondary"
//        "damage bonus" : 2.3
//        "clip size bonus" : 1.25
//        "weapon spread bonus" : 0.85
//        "maxammo secondary increased" : 1.5
//        "fire rate penalty" : 1.2
//        "bullets per shot bonus" : 0.5
//        "Reload time increased" : 1.13
//        "single wep deploy time increased" : 1.15
//        "minicritboost on kill" : 5
//	}
//	"Crowbar" :
//	{
//        OriginalItemName = "Necro Smasher"
//        Model = "models/weapons/c_models/c_cratesmasher/c_cratesmasher_1.mdl"
//		"deploy time decreased" : 0.75
//		"fire rate bonus" : 0.30
//		"damage penalty" : 0.54
//	}
//}

::CustomWeapons <- {

	//arrays copied from Yaki's gtfw
	//Order based on internal constants of ETFClass
	TF_AMMO_PER_CLASS_PRIMARY = {
		"scout" : 32,	//Scout
		"sniper" : 25,	//Sniper
		"soldier" : 20	//Soldier
		"demo" : 16,	//Demo
		"medic" : 150	//Medic
		"heavy" : 200,	//Heavy
		"pyro" : 200,	//Pyro
		"spy" : 20,	//Spy
		"engineer" : 32,	//Engineer
	}

	//Order based on internal constants of ETFClass
	TF_AMMO_PER_CLASS_SECONDARY = {
		"scout" : 36,	//Scout
		"sniper" : 75,	//Sniper
		"soldier" : 32	//Soldier
		"demo" : 24,	//Demo
		"medic" : 150	//Medic
		"heavy" : 32,	//Heavy
		"pyro" : 32,	//Pyro
		"spy" : 24,	//Spy
		"engineer" : 200,	//Engineer
	}

	//regenerating players by default will clear custom weapons
	//give all weapons in the player's class's extraloadout and set hp
	SpawnHookTable = {
		function RegenerateCustomWeapons(params) {
			local player = GetPlayerFromUserID(params.userid)
			if (("ExtraLoadout" in player.GetScriptScope())) {

				if (player.GetScriptScope().ExtraLoadout.len() > 10)
				{
					foreach (entity in player.GetScriptScope().ExtraLoadout)
					{
						if ((typeof(entity) == "instance") && entity.IsValid())
						entity.Kill()
					}
					player.GetScriptScope().ExtraLoadout.resize(10)
				}
				local playerclass = player.GetPlayerClass()
				if (player.GetScriptScope().ExtraLoadout[playerclass] != null)
					foreach (item in player.GetScriptScope().ExtraLoadout[playerclass])
						CustomWeapons.GiveItem(item, player)
					player.SetHealth(player.GetMaxHealth())

				SetPropIntArray(player, "m_iAmmo", CustomWeapons.GetMaxAmmo(player, 1), 1)
				SetPropIntArray(player, "m_iAmmo", CustomWeapons.GetMaxAmmo(player, 2), 2)
				SetPropIntArray(player, "m_iAmmo", CustomWeapons.GetMaxAmmo(player, 3), 3)
				SetPropIntArray(player, "m_iAmmo", CustomWeapons.GetMaxAmmo(player, 4), 4)
			}
		}
	}

	//give item to specified player
	//itemname accepts strings
	//player accepts player entities
	function GiveItem(itemname, player)
	{
		player.ValidateScriptScope()

		if (!player || player.GetPlayerClass() < 1) return
		local playerclass = PopExtUtil.Classes[player.GetPlayerClass()]

		local extraitem = null
		local model = null
		local modelindex = null
		local animset = null
		local id = null
		local item_class = null
		local item_slot = null

		//if item is a custom item, overwrite itemname with OriginalItemName
		if (itemname in ExtraItems)
		{
			extraitem = ExtraItems[itemname]
			itemname = ExtraItems[itemname].OriginalItemName
		}

		if (itemname in PopExtItems)
		{
			id = PopExtItems[itemname].id
			model = PopExtItems[itemname].model_player
			modelindex = PrecacheModel(model)
			animset = PopExtItems[itemname].animset
			item_class = PopExtItems[itemname].item_class
			item_slot = PopExtItems[itemname].item_slot

			if (typeof(PopExtItems[itemname].animset) == "array")
			{
				if (PopExtItems[itemname].animset.find(playerclass) == null)
				{
					animset = PopExtItems[itemname].animset[0]
					item_class = PopExtItems[itemname].item_class[0]
					item_slot = PopExtItems[itemname].item_slot[0]
				}
				else
				{
					animset = PopExtItems[itemname].animset[PopExtItems[itemname].animset.find(playerclass)]
					item_class = PopExtItems[itemname].item_class[PopExtItems[itemname].animset.find(playerclass)]
					item_slot = PopExtItems[itemname].item_slot[PopExtItems[itemname].animset.find(playerclass)]
				}
			}

			//multiclass items will not spawn unless they are specified for a certain class
			//this includes multiclass shotguns, melees, base jumper, pain train (but not half zatoichi)
			//the stock pistol, tf_weapon_pistol is a valid classname and will spawn however tf_weapon_pistol_scout is also supported

			//animset can be a array or a string, arrays exist for weapons that are multi class (shotgun pistol and all class melees)
			//if the current player's class is not one of the classes listed in the table, it will fall back to the first index
		}
		else return

		//replace overrides if they exist in extraitems
		if (extraitem != null)
		{
			if ("ItemClass" in extraitem) item_class = extraitem.ItemClass
			if ("Model" in extraitem) model = extraitem.Model; modelindex = PrecacheModel(model)
			if ("AnimSet" in extraitem) animset = extraitem.AnimSet
			if ("Slot" in extraitem) item_slot = extraitem.Slot
		}

		//create item entity
		local item = CreateByClassname(item_class)
		SetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", id)
		SetPropBool(item, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropBool(item, "m_bValidatedAttachedEntity", true)
		item.SetTeam(player.GetTeam())
		DispatchSpawn(item)
		local reservedKeywords = {
			"OriginalItemName" : null
			"ItemClass" : null
			"Name" : null
			"Model" : null
			"AnimSet" : null
			"Slot" : null
		}

		if (!("CustomWeapons" in player.GetScriptScope()))
			player.GetScriptScope().CustomWeapons <- {}
		player.GetScriptScope().CustomWeapons[item] <- modelindex
		item.ValidateScriptScope()
		local scope = item.GetScriptScope()
		scope.ItemThinkTable <- {}
		scope.ItemThinks <- function() { foreach (name, func in scope.ItemThinkTable) func.call(scope); return -1 }
		_AddThinkToEnt(item, "ItemThinks")

		//if max ammo needs to be changed, create a tf_wearable and assign attributes to it
		if (item_slot == "primary")
		{
			if (this.TF_AMMO_PER_CLASS_PRIMARY[playerclass] != this.TF_AMMO_PER_CLASS_PRIMARY[animset])
			{
				if (!("ammofix" in player.GetScriptScope().CustomWeapons))
				{
					local ammofix = CreateByClassname("tf_wearable")
					SetPropBool(ammofix, "m_bValidatedAttachedEntity", true)
					SetPropBool(ammofix, "m_AttributeManager.m_Item.m_bInitialized", true)
					SetPropEntity(ammofix, "m_hOwnerEntity", player)
					ammofix.SetOwner(player)
					ammofix.DispatchSpawn()
					ammofix.AcceptInput("SetParent", "!activator", player, player)
					player.GetScriptScope().CustomWeapons.ammofix <- ammofix
					if (!("ExtraLoadout" in player.GetScriptScope()))
					{
						local ExtraLoadout = array(10)
						player.GetScriptScope().ExtraLoadout <- ExtraLoadout
					}
					player.GetScriptScope().ExtraLoadout.append(ammofix) //for clean up
				}
				player.GetScriptScope().CustomWeapons.ammofix.AddAttribute("hidden primary max ammo bonus", this.TF_AMMO_PER_CLASS_PRIMARY[animset].tofloat() / this.TF_AMMO_PER_CLASS_PRIMARY[playerclass].tofloat(), -1.0)
				player.GetScriptScope().CustomWeapons.ammofix.ReapplyProvision()
				SetPropIntArray(player, "m_iAmmo", GetMaxAmmo(player, 1), 1)
			}
		}

		if (item_slot == "secondary")
		{
			if (this.TF_AMMO_PER_CLASS_SECONDARY[playerclass] != this.TF_AMMO_PER_CLASS_SECONDARY[animset])
			{
				if (!("ammofix" in player.GetScriptScope().CustomWeapons))
				{
					local ammofix = CreateByClassname("tf_wearable")
					SetPropBool(ammofix, "m_bValidatedAttachedEntity", true)
					SetPropBool(ammofix, "m_AttributeManager.m_Item.m_bInitialized", true)
					SetPropEntity(ammofix, "m_hOwnerEntity", player)
					ammofix.SetOwner(player)
					ammofix.DispatchSpawn()
					ammofix.AcceptInput("SetParent", "!activator", player, player)
					player.GetScriptScope().CustomWeapons.ammofix <- ammofix
					if (!("ExtraLoadout" in player.GetScriptScope()))
					{
						local ExtraLoadout = array(10)
						player.GetScriptScope().ExtraLoadout <- ExtraLoadout
					}
					player.GetScriptScope().ExtraLoadout.append(ammofix) //for clean up
				}
				player.GetScriptScope().CustomWeapons.ammofix.AddAttribute("hidden secondary max ammo penalty", this.TF_AMMO_PER_CLASS_SECONDARY[animset].tofloat() / this.TF_AMMO_PER_CLASS_SECONDARY[playerclass].tofloat(), -1.0)
				player.GetScriptScope().CustomWeapons.ammofix.ReapplyProvision()
				SetPropIntArray(player, "m_iAmmo", GetMaxAmmo(player, 2), 2)
			}
		}

		//adjust clip size
		item.SetClip1(item.GetMaxClip1())

		//find the slot of the weapon then iterate through all entities parented to the player
		//and kill the entity that occupies the required slot
		local slot = FindSlot(item)
		if (slot != null)
		{
			local itemreplace = player.FirstMoveChild()
			while (itemreplace)
			{
				if (FindSlot(itemreplace) == slot)
				{
					itemreplace.Destroy()
					break
				}
				itemreplace = itemreplace.NextMovePeer()
			}
			player.Weapon_Equip(item)
			item.AcceptInput("SetParent", "!activator", player, player)

			// Apply attributes
			// THIS MUST BE DONE AFTER WEAPON_EQUIP!!!
			// Normal attributes can work for owner-less items, custom attributes cannot.

			if (extraitem != null)
			foreach (attribute, value in extraitem)
				if (!(attribute in reservedKeywords))
					PopExtUtil.SetPlayerAttributes(player, attribute, value, item)

			// copied from ficool2 mw2_highrise
			// viewmodel
			local main_viewmodel = GetPropEntity(player, "m_hViewModel")

			local armmodel = "models/weapons/c_models/c_" + animset + "_arms.mdl"

			//animset ? armmodel = animset : armmodel = main_viewmodel.GetModelName()

			item.SetModelSimple(armmodel)
			item.SetCustomViewModel(armmodel)
			item.SetCustomViewModelModelIndex(PrecacheModel(armmodel))
			SetPropInt(item, "m_iViewModelIndex", PrecacheModel(armmodel))

			// worldmodel
			player.GetScriptScope().PlayerThinkTable.CustomWeaponWorldmodel <- UpdateWorldmodel
			if (!("worldmodel" in player.GetScriptScope().CustomWeapons))
			{
				local tpWearable = CreateByClassname("tf_wearable")
				SetPropInt(tpWearable, "m_nModelIndex", modelindex)
				SetPropBool(tpWearable, "m_bValidatedAttachedEntity", true)
				SetPropBool(tpWearable, "m_AttributeManager.m_Item.m_bInitialized", true)
				SetPropEntity(tpWearable, "m_hOwnerEntity", player)
				tpWearable.SetOwner(player)
				tpWearable.DispatchSpawn()
				tpWearable.AcceptInput("SetParent", "!activator", player, player)
				SetPropInt(tpWearable, "m_fEffects", 129) // EF_BONEMERGE|EF_BONEMERGE_FASTCULL
				player.GetScriptScope().CustomWeapons.worldmodel <- tpWearable
				if (!("ExtraLoadout" in player.GetScriptScope()))
				{
					local ExtraLoadout = array(10)
					player.GetScriptScope().ExtraLoadout <- ExtraLoadout
				}
				player.GetScriptScope().ExtraLoadout.append(tpWearable) //for clean up
			}

			// copied from LizardOfOz open fortress dm_crossfire
			// viewmodel arms
			SetPropInt(item, "m_nRenderMode", kRenderTransColor)
			SetPropInt(item, "m_clrRender", 1)

			local hands = SpawnEntityFromTable("tf_wearable_vm", {
				modelindex = PrecacheModel(format("models/weapons/c_models/c_%s_arms.mdl", playerclass))
			})
			SetPropBool(hands, "m_bForcePurgeFixedupStrings", true)
			player.EquipWearableViewModel(hands)

			local hands2 = SpawnEntityFromTable("tf_wearable_vm", {
				modelindex = PrecacheModel(model)
			})
			SetPropBool(hands2, "m_bForcePurgeFixedupStrings", true)
			player.EquipWearableViewModel(hands2)

			SetPropEntity(hands2, "m_hWeaponAssociatedWith", item)
			SetPropEntity(item, "m_hExtraWearableViewModel", hands2)

			player.Weapon_Switch(item)
		}
		return item;
	}

	//returns the slot number of entities with classname tf_weapon_
	//also includes exceptions for passive weapons such as demo shields, soldier/demo boots and sniper backpacks
	//action items includes canteen, contracker
	//return null if the entity is not a weapon or passive weapon
	function FindSlot(item)
	{
		if (item.GetClassname().find("tf_weapon_") == 0) return item.GetSlot()
		else
		{
			//base jumper and invis watches are not included as they have classnames starting with "tf_weapon_"
			local id = GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

			//Ali Baba's Wee Booties and Bootlegger
			if ([405, 608].find(id) != null) return 0

			//Razorback, Gunboats, Darwin's Danger Shield, Mantreads, Cozy Camper
			else if ([57, 133, 231, 444, 642].find(id) != null) return 1

			//All demo shields
			else if (item.GetClassname() == "tf_wearable_demoshield") return 1

			//Action items, Canteens and Contracker
			else if ((item.GetClassname() == "tf_powerup_bottle"|| item.GetClassname() == "tf_wearable_campaign_item")) return 5
		}
		return null
	}

	//equip item in player's loadout, does not give item
	//itemname accepts strings
	//player accepts player entities
	//playerclass accepts integers, will default to player's current class if null, optional
	function EquipItem(itemname, player, playerclass = null)
	{
		if (playerclass == null) playerclass = player.GetPlayerClass()
		player.ValidateScriptScope()
		if (!("ExtraLoadout" in player.GetScriptScope()))
		{
			local ExtraLoadout = array(10)
			player.GetScriptScope().ExtraLoadout <- ExtraLoadout
		}
		if (player.GetScriptScope().ExtraLoadout[playerclass] == null)
			player.GetScriptScope().ExtraLoadout[playerclass] = []

		if (player.GetScriptScope().ExtraLoadout[playerclass].find(itemname) == null)
			player.GetScriptScope().ExtraLoadout[playerclass].append(itemname)
	}

	//unequip item in player's loadout
	//itemname accepts strings
	//player accepts player entities
	//playerclass accepts integers, will default to player's current class if null, optional
	function UnequipItem(itemname, player, playerclass = null)
	{
		if (playerclass == null) playerclass = player.GetPlayerClass()
		player.ValidateScriptScope()
		if ("ExtraLoadout" in player.GetScriptScope())
			if (player.GetScriptScope().ExtraLoadout[playerclass] != null)
				if (player.GetScriptScope().ExtraLoadout[playerclass].find(itemname) != null)
					player.GetScriptScope().ExtraLoadout[playerclass].remove(player.GetScriptScope().ExtraLoadout[playerclass].find(itemname))

	}

	//think function that runs on players to update viewmodels
	//runs every tick
	function UpdateWorldmodel()
	{
		self.ValidateScriptScope()
		if ("CustomWeapons" in self.GetScriptScope())
			{
				local activeweapon = self.GetActiveWeapon()
				if (activeweapon in self.GetScriptScope().CustomWeapons)
				{
					if (("worldmodel" in self.GetScriptScope().CustomWeapons) && (GetPropInt(self.GetScriptScope().CustomWeapons.worldmodel, "m_nModelIndex") != self.GetScriptScope().CustomWeapons[activeweapon]))
					{
						if (self.GetScriptScope().CustomWeapons.worldmodel.IsValid()) self.GetScriptScope().CustomWeapons.worldmodel.Kill()

						local modelindex = self.GetScriptScope().CustomWeapons[activeweapon]
						local tpWearable = CreateByClassname("tf_wearable")
						SetPropInt(tpWearable, "m_iTeamNum", self.GetTeam())
						SetPropInt(tpWearable, "m_nModelIndex", modelindex)
						SetPropBool(tpWearable, "m_bValidatedAttachedEntity", true)
						SetPropBool(tpWearable, "m_AttributeManager.m_Item.m_bInitialized", true)
						SetPropEntity(tpWearable, "m_hOwnerEntity", self)
						tpWearable.SetOwner(self)
						tpWearable.SetSkin(self.GetTeam()-2)
						tpWearable.DispatchSpawn()
						tpWearable.AcceptInput("SetParent", "!activator", self, self)
						SetPropInt(tpWearable, "m_fEffects", 129) // EF_BONEMERGE|EF_BONEMERGE_FASTCULL
						self.GetScriptScope().CustomWeapons.worldmodel <- tpWearable
						if (!("ExtraLoadout" in self.GetScriptScope()))
						{
							local ExtraLoadout = array(10)
							self.GetScriptScope().ExtraLoadout <- ExtraLoadout
						}
						self.GetScriptScope().ExtraLoadout.append(tpWearable) //for clean up
					}
				}
				else
				{
					if (("worldmodel" in self.GetScriptScope().CustomWeapons) && (self.GetScriptScope().CustomWeapons.worldmodel.IsValid()))
					{
						self.GetScriptScope().CustomWeapons.worldmodel.Kill()
					}
				}
			}
		return -1
	}

	//returns max ammo of player by slot after attributes
	//player accepts player entities
	//slot accepts integers 1 to 4
	function GetMaxAmmo(player, slot)
	{
		local multiplier = 1
		local attributearray = []
		local slottable = null
		switch(slot) {
			case 1: //primary ammo
				attributearray = ["hidden primary max ammo bonus", "maxammo primary increased", "maxammo primary reduced"]
				slottable = this.TF_AMMO_PER_CLASS_PRIMARY
				break
			case 2: //secondary ammo
				attributearray = ["hidden secondary max ammo penalty", "maxammo secondary increased", "maxammo secondary reduced"]
				slottable = this.TF_AMMO_PER_CLASS_SECONDARY
				break
			case 3: //metal
				attributearray = ["maxammo metal increased", "maxammo metal reduced"]
				break
			case 4: //grenades1 ammo (sandman, wrap assassin, jarate, heavy lunchbox)
				attributearray = ["maxammo grenades1 increased"]
				break
			case 5: //grenades2 ammo (mad milk, bonk)
				return
			case 6: //grenades3 ammo (spellbook)
				return
			default:
				return
		}

		foreach (attribute in attributearray)
		{
			multiplier = multiplier * player.GetCustomAttribute(attribute, 1)
		}

		local item = player.FirstMoveChild()
		while (item && item instanceof CEconEntity)
		{
			foreach (attribute in attributearray)
			{
				multiplier = multiplier * item.GetAttribute(attribute, 1)
			}
			item = item.NextMovePeer()
		}

		if (slot == 3)
		{
			player.GetPlayerClass() == 9 ? slottable = 200 : slottable = 100
			return multiplier * slottable
		}
		if (slot == 4) return multiplier * 1

		return multiplier * slottable[PopExtUtil.Classes[player.GetPlayerClass()]]
	}
}
