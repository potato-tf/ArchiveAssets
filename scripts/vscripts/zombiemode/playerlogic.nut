// player-related logic here~
local cooldown = 0
local player = self
::MAX_WEAPONS <- 8
const BUTTON_RADIUS = 96 // effectively Interact radius
const BUTTON_COOLDOWN_TIME = 3
const HURT_COOLDOWN_TIME = 2
const TIMER_INTERVAL = 0.2352941176470588 // ((1/60) / 255).
local exitsign = Entities.FindByName(null, "strongmann_exitbrush")
local boardsign = Entities.FindByName(null, "secretroom_brush")
local quickrev_math = Entities.FindByName(null, "quickrev_math")
local car_fuel_counter = Entities.FindByName(null, "car_fuel_counter")
local overload_button = Entities.FindByName(null, "overload_button")
local computer_button = Entities.FindByName(null, "computer_button")
local overload_check = Entities.FindByName(null, "overload_check")
local activeweapon = "null"

local Powerups = {
	vnd_speed_button = { powerup = "Quickola", price = 3000 }
	vnd_dtap_button = { powerup = "Double Tap", price = 2000 }
	vnd_saxton_button = { powerup = "Saxton Ale", price = 2500 }
	vnd_quickrev_button = { powerup = "Ostarion's Reserve", price = 1500 }
	vnd_ammo_button = { powerup = "Max Ammo", price = 1000 }
}

local WallGuns =
{
	wallgun_sniper = { itemname = "ZM_Sniper", supername = "ZM_SuperSniper", price = 750, slot = "primary" }
	wallgun_shotgun = { itemname = "ZM_Shotgun", supername = "ZM_SuperShotgun", price = 500, slot = "secondary" }
	wallgun_smg = { itemname = "ZM_SMG", supername = "ZM_SuperSMG", price = 1000, slot = "secondary" }
	wallgun_pep = { itemname = "ZM_Pep", supername = "ZM_SuperPep", price = 2000, slot = "primary" }
	wallgun_heatsink = { itemname = "ZM_Heatsink", supername = "ZM_SuperHeatsink", price = 1500, slot = "secondary" }
	wallgun_shiv = { itemname = "ZM_Shiv", price = 3000, slot = "melee" }
}

local DoorButtons =
{
	door_warehouse_1 = 		750
	door_hallways_1 = 		750
	door_warehouse_2 = 		1000
	door_hallways_2 = 		1000
	door_hallways_3 = 		1000
	door_exterior_1 = 		1250
	door_maintenance_1 = 	1250
	door_powerstation_1 = 	1250
	door_powerstation_2 = 	1250
}

local Mysteryboxes = // maybe can be expanded if Fire Sale gets implemented?
{
	dumpster_button1 = 		950
}

local Strongmann = 
{
	strongmann_button = 5000
}

local Paplist =
{
	ZM_Pistol = {}
	ZM_Shotgun = {}
	ZM_Sniper = {}
	ZM_SMG = {}
	ZM_Pep = {}
	ZM_Heatsink = {}
	ZM_FaN = {}
	ZM_Crossbow = {}
	ZM_AutoAss = {}
	ZM_Thumpy = {}
	ZM_TGat = {}
	ZM_BMMH = {}
	ZM_Packer = {}
	ZM_Rusty = {}
	ZM_RPG = {}
	ZM_Flamer = {}
	ZM_Panic = {}
	ZM_PistolB = {}
	ZM_Raygun = {}
	ZM_BurningLove = {}
}

local GenericButtons =
{
	power_button = { message = "Hold Action key to turn on the power", input = "Press" }
	teleport_button_1 = { message = "Hold Action key to begin warmup sequence", input = "Press" }
	teleport_button_2 = { message = "Hold Action key to synchronize data link", input = "Press" }
	teleport_button_3 = { message = "Hold Action key to activate teleporter", input = "Press" }
	lift_button = { message = "Hold Action key to lower the lift", input = "Press" }
	computer_button = { message = "Hold Action key to print the files", input = "Press" }
	overload_button = { message = "Hold Action key to override safety parameters", input = "Press" }
	telephone_1 = { message = "", input = "Press" }
	telephone_2 = { message = "", input = "Press" }
}
local Traps =
{
	trap_button_1 = { price = 1000, relay = "activate_trap_1" }
	trap_button_2 = { price = 1000, relay = "activate_trap_2" }
	trap_button_3 = { price = 1000, relay = "activate_trap_3" }
	trap_button_4 = { price = 1000, relay = "activate_trap_4" }
}

local ImportantItems = 
{
	car_interacter = { item = "Escape Van" }
	pickup_gascan_1 = { item = "Gas Can" }
	pickup_gascan_2 = { item = "Gas Can" }
	pickup_gascan_3 = { item = "Gas Can" }
	pickup_gascan_4 = { item = "Gas Can" }
	pickup_gascan_5 = { item = "Gas Can" }
	pickup_gascan_drop = { item = "Gas Can" }
	codebook_button = { item = "Codebook" }
}

::PowerupHints <-
[
	"powerup_instakill",
	"powerup_bonuspoints",
	"powerup_maxammo",
	"powerup_nuke",
	"powerup_doublepoints",
	"powerup_minigun",
]

::ApplyPerkBonuses <- function(self) // apply perk bonuses to weapons
{
	local scope = self.GetScriptScope()
	if ("Quickola" in scope.Preserved.powerups) 	self.AddCustomAttribute("Reload time decreased" ,0.5, -1);
	if ("Double Tap" in scope.Preserved.powerups) self.AddCustomAttribute("fire rate bonus" ,0.67, -1);
}

::ApplyPlayerAttributes <- function(self) // moved here because popfile version is not reliable
{
	local playerclass = self.GetPlayerClass()
	if (playerclass == 1)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,25, -1);
		self.AddCustomAttribute("move speed penalty" ,0.75, -1);
	}
	if (playerclass == 2)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,25, -1);
		self.AddCustomAttribute("headshot damage increase" ,2, -1);
	}
	if (playerclass == 3)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,-50, -1);
		self.AddCustomAttribute("move speed penalty" ,1.25, -1);
	}
	if (playerclass == 4)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,-25, -1);
		self.AddCustomAttribute("move speed penalty" ,1.071428, -1);	// wtf demoman
	}
	if (playerclass == 5) self.AddCustomAttribute("move speed penalty" ,0.9375, -1);
	if (playerclass == 6)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,-150, -1);
		self.AddCustomAttribute("move speed penalty" ,1.304, -1);
	}
	if (playerclass == 7)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,-25, -1);
	}
	if (playerclass == 8)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,25, -1);
		self.AddCustomAttribute("move speed penalty" ,0.9375, -1);
		self.AddCustomAttribute("cannot disguise" ,1, -1);
	}
	if (playerclass == 9)
	{
		self.AddCustomAttribute("hidden maxhealth non buffed" ,25, -1);
		self.AddCustomAttribute("metal regen" ,50, -1);
		self.AddCustomAttribute("upgrade rate decrease" ,0, -1);
		self.AddCustomAttribute("engy dispenser radius increased" ,6, -1);
		self.AddCustomAttribute("building cost reduction" ,1.5384, -1);
		self.AddCustomAttribute("mod teleporter cost" ,0, -1);
		self.AddCustomAttribute("cannot pick up buildings" ,1, -1);
		self.AddCustomAttribute("engy sentry fire rate increased" ,1.3, -1);
	}
	self.SetHealth(self.GetMaxHealth())
}

::ButtonThink <- function() // the button think, repurposed to general playerthink
{
	local scope = self.GetScriptScope()
	local main_viewmodel = GetPropEntity(self, "m_hViewModel")
	local playermoney = self.GetCurrency()
	local buttons = NetProps.GetPropInt(self, "m_nButtons")
	
	if (!self.IsAlive())
	{
		self.SetScriptOverlayMaterial("")
		return
	}
	UpdatePlayerCurrency(self)
//	if (buttons & Constants.FButtons.IN_SCORE)
//	{
//		for (local node; node = Entities.FindByClassname(node, "point_commentary_node");)
//		{
//			if (node.IsValid()) node.Destroy()
//			NetProps.SetPropInt(self, "m_nButtons",Constants.FButtons.IN_SCORE)
//		}
//	}
	if (scope.Preserved.isinstrongmannroom == true && (scope.Preserved.teleporttime < Time()))
	{
		if (scope.Preserved.isusingstrongmann == false) // teleport back to start if not using strongmann machine
		{
			if (scope.Preserved.timesteleported == 3)
			{
				EntFireByHandle(boardsign, "StartTouch", "", -1, self, self) // also exists in the bot prison
				scope.Preserved.isinstrongmannroom = false // stop touching it forever
				scope.Preserved.timesteleported = 0
			}
			else
			{
				EntFireByHandle(exitsign, "StartTouch", "", -1, self, self) // also exists in the bot prison
				scope.Preserved.isinstrongmannroom = false // stop touching it forever
			}
		}
	}
	if (scope.Preserved.isinanimation == true && main_viewmodel.IsSequenceFinished() == true) // only really used by the perk boost animation
	{
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			if (weapon == null)
			continue
			if (weapon.GetSlot() == 1) 
			{
				NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
				weapon.Destroy()
				if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden secondary max ammo penalty")
				break
			}
		}
		::CustomWeapons.GiveItem(scope.Preserved.weapon_secondary, self);
		EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0,null,self);
		self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
		ApplyPerkBonuses(self);
		scope.Preserved.isinanimation = false
		if (scope.Preserved.weapon_secondary == null) PopExtUtil.WeaponSwitchSlot(self,2)
	}
	if (scope.Preserved.hasdeathmachine == true && scope.Preserved.miniguntime < Time())
	{
		NetProps.SetPropEntity(self, "m_hActiveWeapon", null)
		for (local i = 0; i < MAX_WEAPONS; i++)
		{
			local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			if (weapon == null)
			continue
			if (weapon.GetSlot() == 0) 
			{
				NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
				weapon.Destroy()
				if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden primary max ammo bonus")
				break
			}
		}
		::CustomWeapons.GiveItem(scope.Preserved.weapon_primary,self)
		EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self);
		ApplyPerkBonuses(self)
		if (scope.Preserved.weapon_primary == "null") // give a sniper to avoid player having permanent death machine
		{
			::CustomWeapons.GiveItem("ZM_Sniper",self)
			scope.Preserved.weapon_primary = "ZM_Sniper"
			ApplyPerkBonuses(self)
			EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self);
		}
		self.SetIsMiniBoss(false)
		PopExtUtil.SwitchToFirstValidWeapon(self)
		scope.Preserved.hasdeathmachine = false
	}
	else
	if (scope.Preserved.doublepointstime > Time())
	{
		scope.Preserved.multiplier = 2
//		UpdatePowerupDurations(self)
	}
	else
	{
		scope.Preserved.multiplier = 1
	}
	if ((self.GetHealth() < self.GetMaxHealth()) && (scope.Preserved.hurttime < Time()))
	{
		if ("Saxton Ale" in scope.Preserved.powerups)
		{
			self.AddCustomAttribute("health regen",25, 1)
		}
		else
		{
			self.AddCustomAttribute("health regen",10, 1)
		}
	}
	if (self.GetActiveWeapon() != null)
	{
		if (self.GetActiveWeapon().GetClassname() != scope.Preserved.activeweapon) 
		{
			if (scope != null && "popWearablesToDestroy" in scope)
			{
				foreach(wearable in scope.popWearablesToDestroy)
				if (wearable.IsValid()) EntFireByHandle(wearable, "Kill", "", -1, null, null)
				delete scope.popWearablesToDestroy
			}
			local wep = self.GetActiveWeapon().GetClassname()
			UpdatePlayerModel(self, wep)
		}
	}
	for (local button; button = FindByClassnameWithin(button, "func_rot_button", self.GetOrigin(), BUTTON_RADIUS); ) // button think
	{
		local currentweapon = self.GetActiveWeapon()
		if (GetPropBool(button, "m_bLocked")) 
		{
			ClientPrint(self, HUD_PRINTCENTER, "You must turn on the power first!")
			return
		}

		function GivePowerup(button, powerup, price)
		{
			if (powerup in scope.Preserved.powerups || (powerup == "Ostarion's Reserve" && self.InCond(129))) return // NO
			
			if (powerup == "Max Ammo")
			{
				price = price + (500 * scope.Preserved.ammobuys)
			}
			ClientPrint(self, HUD_PRINTCENTER, format("Hold Action key to purchase %s for $%d", powerup, price));
			if (self.IsUsingActionSlot())
			{
				if (playermoney < price)
				{
					button.EmitSound("buttons/button8.wav");
					self.AcceptInput("speakresponseconcept", "TLK_PLAYER_NEGATIVE", self, self);
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME - 2;
					SetPropBool(self, "m_bUsingActionSlot", false)
					return
				}

				button.EmitSound("deadlands/vending_use.wav");
				ClientPrint(self, HUD_PRINTCENTER, "");
				if (powerup != "Max Ammo")
				{
					PlayPerkAnimation(self)
					scope.Preserved.isinanimation = true
				}
				if (powerup == "Saxton Ale")
				{
					EntFireByHandle(self,"runscriptcode","self.AddCustomAttribute(`max health additive bonus`,100,-1)",1.2,null,self);
					EntFireByHandle(self,"speakresponseconcept","TLK_PLAYER_SPELL_PICKUP_RARE",1.2,null,self);
					EntFireByHandle(self,"runscriptcode","UpdateHUDForPerks(self)",1.25,null,self);
					ClientPrint(self, HUD_PRINTCENTER,"Perk Bonus activated: Increased max health and regeneration!")
					self.RemoveCurrency(price);
					scope.Preserved.powerups[powerup] <- true
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
				if (powerup == "Double Tap")
				{
					self.AddCustomAttribute("fire rate bonus" ,0.67, -1);
					EntFireByHandle(self,"speakresponseconcept","TLK_PLAYER_SPELL_PICKUP_RARE",1.2,null,self);
					EntFireByHandle(self,"runscriptcode","UpdateHUDForPerks(self)",1.25,null,self);
					ClientPrint(self, HUD_PRINTCENTER,"Perk Bonus activated: Increased fire rate!")
					self.RemoveCurrency(price);
					scope.Preserved.powerups[powerup] <- true
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
				if (powerup == "Quickola")
				{
					self.AddCustomAttribute("Reload time decreased" ,0.5, -1);
					EntFireByHandle(self,"speakresponseconcept","TLK_PLAYER_SPELL_PICKUP_RARE",1.2,null,self);
					EntFireByHandle(self,"runscriptcode","UpdateHUDForPerks(self)",1.25,null,self);
					ClientPrint(self, HUD_PRINTCENTER,"Perk Bonus activated: Increased reload speed!")
					self.RemoveCurrency(price);
					scope.Preserved.powerups[powerup] <- true
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
				if (powerup == "Ostarion's Reserve")
				{
					EntFireByHandle(self,"runscriptcode","self.AddCondEx(70,-1,null)",1.2,null,self);
					EntFireByHandle(self,"runscriptcode","self.AddCondEx(129,-1,null)",1.2,null,self);
					EntFireByHandle(self,"runscriptcode","UpdateHUDForPerks(self)",1.25,null,self);
					ClientPrint(self, HUD_PRINTCENTER,"Perk Bonus activated: Survive one fatal hit!")
					EntFireByHandle(self,"speakresponseconcept","TLK_PLAYER_SPELL_PICKUP_RARE",1.2,null,self);
					self.RemoveCurrency(price); 
					EntFireByHandle(quickrev_math,"Subtract","1",1.2,null,self);

					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
				if (powerup == "Max Ammo")
				{
					PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
					PopExtUtil.PlaySoundOnClient(self,"deadlands/pickup_maxammo.mp3",1.0,100)
					SetPropIntArray(self, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(self, 1), 1)
					SetPropIntArray(self, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(self, 2), 2) 
					self.RemoveCurrency(price); 
					scope.Preserved.ammobuys += 1
	
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
			}
		}
	
		function GiveWallGun(button, weapon, price, slot, responseconcept = "TLK_MVM_LOOT_COMMON") 
		{
			if ( weapon == scope.Preserved.weapon_primary || weapon == scope.Preserved.weapon_secondary ) // OH RIGHT WE CAN ACTUALLY USE THESE!!!
			{
				price *= 0.5
				ClientPrint(self, HUD_PRINTCENTER, format("Hold Action key to buy ammo ($%d)", price.tointeger()));
			}
			else
			ClientPrint(self, HUD_PRINTCENTER, format("Hold Action key to purchase ($%d)", price.tointeger()));
			if (self.IsUsingActionSlot() && playermoney >= price && weapon != scope.Preserved.weapon_primary && weapon != scope.Preserved.weapon_secondary && scope.Preserved.cooldowntime < Time())
			{
				button.EmitSound("ui/item_heavy_gun_pickup.wav");
				PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
				ClientPrint(self, HUD_PRINTCENTER, "");
				self.AcceptInput("speakresponseconcept", responseconcept, self, self);
				
				if (slot == "primary")
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 0) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden primary max ammo bonus")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_primary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self);
					self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
				}
				if (slot == "secondary") // redundancy fallbacks in case players die during perk bottle / death machine
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 1) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden secondary max ammo penalty")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_secondary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0,null,self);
					self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
				}
				if (slot == "melee")
				{
					scope.Preserved.weapon_melee <- weapon
					::CustomWeapons.GiveItem(weapon, self);
				}
				PopExtUtil.PlaySoundOnClient(self,"deadlands/wallgun_purchase.mp3",0.7,100)
				self.RemoveCurrency(price)
				ApplyPerkBonuses(self)
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
			if (self.IsUsingActionSlot() && playermoney >= price && (weapon == scope.Preserved.weapon_primary || weapon == scope.Preserved.weapon_secondary) && scope.Preserved.cooldowntime < Time())
			{
				button.EmitSound("items/gunpickup2.wav");
				PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
				ClientPrint(self, HUD_PRINTCENTER, "");
				if (weapon == scope.Preserved.weapon_primary)
				{
					SetPropIntArray(self, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(self, 1), 1) 
				}
				else if (weapon == scope.Preserved.weapon_secondary)
				{
					SetPropIntArray(self, "m_iAmmo", ::CustomWeapons.GetMaxAmmo(self, 2), 2) 
				}
				
				self.RemoveCurrency(price)
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
			if (self.IsUsingActionSlot() && playermoney < price)
			{
				self.AcceptInput("speakresponseconcept", "TLK_PLAYER_NEGATIVE", self, self);
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
		}
		
		function ActivateTrap(button, relay, price) 
		{
			ClientPrint(self, HUD_PRINTCENTER, format("Hold Action key to activate trap ($%d)", price.tointeger()));
			if (self.IsUsingActionSlot() && playermoney >= price && scope.Preserved.cooldowntime < Time())
			{
				button.EmitSound("ui/item_heavy_gun_pickup.wav");
				PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
				ClientPrint(self, HUD_PRINTCENTER, "");
				self.RemoveCurrency(price)
				EntFire(relay, "trigger");
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
			if (self.IsUsingActionSlot() && playermoney < price)
			{
				self.AcceptInput("speakresponseconcept", "TLK_PLAYER_NEGATIVE", self, self);
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME;
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
		}
		
		function InteractImportantItem(button, item)
		{
			if (item == "Escape Van")
			{
				local timesfueled = GetPropInt(car_fuel_counter, "m_iHealth")
				if (timesfueled < 5)
				{
					if (scope.Preserved.gasheld == 0)
					{
						ClientPrint(self, HUD_PRINTCENTER,"The van seems out of fuel")
						return
					}
					
					ClientPrint(self, HUD_PRINTCENTER,"Hold Action key to fuel up the van")
					if (self.IsUsingActionSlot())
					{
						timesfueled+= 1
						SetPropInt(car_fuel_counter, "m_iHealth", timesfueled)
						EntFireByHandle(car_fuel_counter,"Add","1",1.2,null,self);
						ClientPrint(self, HUD_PRINTCENTER,"")
						PopExtUtil.PlaySoundOnClient(self,"weapons/draw_gas_can.wav",0.7,100)
						button.AcceptInput("Press", "", self, null);
						scope.Preserved.gasheld = scope.Preserved.gasheld - (BUTTON_COOLDOWN_TIME -2);
						scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME -1.5;
						SetPropBool(self, "m_bUsingActionSlot", false)
					}
				}
				if (timesfueled == 5)
				{
					ClientPrint(self, HUD_PRINTCENTER,"")
				}
			}
			if (item == "Gas Can")
			{
				ClientPrint(self, HUD_PRINTCENTER,"Hold Action key to take the gas can")
				if (self.IsUsingActionSlot())
				{
					ClientPrint(self, HUD_PRINTCENTER,"")
					PopExtUtil.PlaySoundOnClient(self,"weapons/draw_gas_can.wav",0.7,100)
					button.AcceptInput("Press", "", self, null);
					if (!Preserved.gasheld in self.GetScriptScope())
					{
						local items = 
						{							 
							gasheld = 0
						}
						foreach (k, v in items)
						self.GetScriptScope().Preserved[k] <- v
					}
					scope.Preserved.gasheld = scope.Preserved.gasheld + (BUTTON_COOLDOWN_TIME -2);
					ShowGasOnPlayer(self)
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME - 2;
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
			}
			if (item == "Codebook")
			{
				ClientPrint(self, HUD_PRINTCENTER,"Hold Action key to deactivate executive lockdown")
				if (self.IsUsingActionSlot())
				{
					local computer_prompt_1 = Entities.FindByName(null, "computer_prompt_1")
					local computer_prompt_2 = Entities.FindByName(null, "computer_prompt_2")
					ClientPrint(self, HUD_PRINTCENTER,"")
					PopExtUtil.PlaySoundOnClient(self,"weapons/draw_gas_can.wav",0.7,100)
					button.AcceptInput("Press", "", self, null);
					overload_button.AcceptInput("Unlock", "", self, null);
					computer_button.AcceptInput("Unlock", "", self, null);
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME - 2;
					SetPropBool(self, "m_bUsingActionSlot", false)
					if (computer_prompt_1 && computer_prompt_2 && computer_prompt_1.IsValid() && computer_prompt_2.IsValid())	// delete the prompts if you somehow got the codebook before even getting the hint for it
					{
						computer_prompt_1.AcceptInput("Kill","",null,null)
						computer_prompt_2.AcceptInput("Kill","",null,null)
					}
				}
			}
		}
		
		local key = ""
		local buttonname = button.GetName()

		if (buttonname in WallGuns)
			key = buttonname
		else 
			foreach(name, func in WallGuns)
				if (startswith(buttonname, name))
				{
					key = name
					break
				}

		if (buttonname in Powerups)
			key = buttonname
		else 
			foreach(name, func in Powerups)
				if (startswith(buttonname, name))
				{
					key = name
					break
				}
		
		if (buttonname in Traps)
			key = buttonname
		else 
			foreach(name, func in Traps)
				if (startswith(buttonname, name))
				{
					key = name
					break
				}
				
		if (buttonname in ImportantItems)
			key = buttonname
		else 
			foreach(name, func in ImportantItems)
				if (startswith(buttonname, name))
				{
					key = name
					break
				}
		
		if (key in WallGuns && scope.Preserved.cooldowntime < Time()) GiveWallGun(button, WallGuns[key].itemname, WallGuns[key].price, WallGuns[key].slot)
		if (key in Powerups && scope.Preserved.cooldowntime < Time()) GivePowerup(button, Powerups[key].powerup, Powerups[key].price)
		if (key in Traps && scope.Preserved.cooldowntime < Time()) 	ActivateTrap(button, Traps[key].relay, Traps[key].price)
		if (key in ImportantItems && scope.Preserved.cooldowntime < Time()) 	InteractImportantItem(button, ImportantItems[key].item)

	}
	for (local door; door = FindByClassnameWithin(door, "func_door", self.GetOrigin(), BUTTON_RADIUS); ) // door checks
	{	
		function PurchaseDoor(door, price) {

			ClientPrint(self, HUD_PRINTCENTER, format("Hold Action Key to open ($%d)", price))

			if (self.IsUsingActionSlot())
			{	
				if (playermoney < price)
				{
					door.EmitSound("doors/door_locked2.wav")
					self.AcceptInput("SpeakResponseConcept", "TLK_PLAYER_NEGATIVE", self, self)
		
					//set cooldown time
					scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME - 2)
					//manually set it here just in case
					SetPropBool(self, "m_bUsingActionSlot", false)
					return
				}

				//press the button
				door.EmitSound("doors/door_latch1.wav")
				PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
				EntFireByHandle(door, "Open", "", -1, self, self)
				self.RemoveCurrency(price)
				ClientPrint(self, HUD_PRINTCENTER, "") // blank out message
			
				//set cooldown time
				scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME - 2)
				//manually set it here just in case
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
			
		}

		local key = ""
		local doorname = door.GetName()

		if (doorname in DoorButtons)
			key = doorname
		else 
			foreach(name, func in WallGuns)
				if (startswith(doorname, name))
				{
					key = name
					break
				}

		if (key in DoorButtons && scope.Preserved.cooldowntime < Time()) PurchaseDoor(door, DoorButtons[key])
	}
	for (local box; box = FindByClassnameWithin(box, "func_button", self.GetOrigin(), BUTTON_RADIUS); ) 
	{	
		if (GetPropBool(box, "m_bLocked") && (box.GetName() == "computer_button" || box.GetName() == "overload_button")) 
		{
			ClientPrint(self, HUD_PRINTCENTER, "It's locked by executive lockdown")
			return
		}
		
		function RollForGun(box, price)
		{
			ClientPrint(self, HUD_PRINTCENTER, format("Hold Action Key to purchase a random weapon ($%d)", price))

			if (self.IsUsingActionSlot())
			{	
				if (playermoney < price)
				{
					box.EmitSound("doors/door_locked2.wav")
					self.AcceptInput("SpeakResponseConcept", "TLK_PLAYER_NEGATIVE", self, self)
		
					//set cooldown time
					scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME
					//manually set it here just in case
					SetPropBool(self, "m_bUsingActionSlot", false)
					return
				}

				//press the button
				::Mysterybox.Activate(self)
				PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
				self.RemoveCurrency(price)
				ClientPrint(self, HUD_PRINTCENTER, "") // blank out message
				scope.Preserved.isusingbox = true
			
				//set cooldown time
				scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME + 1.15)
				//manually set it here just in case
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
		}
		function ReceiveGun(box, weapon, slot, response)
		{
			if (slot != null) // this can only be null if dud happens
			{
				ClientPrint(self, HUD_PRINTCENTER, format("Hold Action Key to receive a %s weapon", slot))
			}
			if (self.IsUsingActionSlot())
			{	
				//press the button
				ClientPrint(self, HUD_PRINTCENTER, "") // blank out message
				
				if (slot == "primary")
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 0) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden primary max ammo penalty")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_primary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self);
					self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
				}
				if (slot == "secondary") // redundancy fallbacks in case players die during perk bottle / death machine
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 1) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden secondary max ammo penalty")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_secondary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0,null,self);
					self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
				}
				box.EmitSound("ui/item_heavy_gun_pickup.wav");
				self.AcceptInput("speakresponseconcept", response, self, self);
				scope.Preserved.isusingbox = false
				ClearBoxScope(self)
				::Mysterybox.MarkAsTaken()
				::Mysterybox.Reset()
				ApplyPerkBonuses(self)
				
				scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME)
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
		}
		// packapunch stuff
		function UpgradeWeapon(box, price)
		{
			if (self.GetActiveWeapon().GetSlot() == 0)
			{
				activeweapon = scope.Preserved.weapon_primary
			}
			if (self.GetActiveWeapon().GetSlot() == 1)
			{
				activeweapon = scope.Preserved.weapon_secondary
			}
			if (self.GetActiveWeapon().GetSlot() == 2)
			{
				activeweapon = "null" // deny melee weapons
			}
			
			if (activeweapon == "null")
			{
				ClientPrint(self, HUD_PRINTCENTER,"")
				return
			}
			
			if ( activeweapon in Paplist )
			{
				ClientPrint(self, HUD_PRINTCENTER, format("Hold Action Key to upgrade your weapon ($%d)", price))
				
				if (!ConfirmNotInUse()) return
				if (self.IsUsingActionSlot())
				{	
					if (playermoney < price)
					{
						box.EmitSound("doors/door_locked2.wav")
					
						//set cooldown time
						scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME
						//manually set it here just in case
						SetPropBool(self, "m_bUsingActionSlot", false)
						return
					}

					//press the button
					::Strongmachine.Activate(self,activeweapon)
					self.GetActiveWeapon().Destroy()
					PopExtUtil.WeaponSwitchSlot(self,2) // use MELEE_ONLY cond to force swap player
					PopExtUtil.PlaySoundOnClient(self,"mvm/mvm_bought_upgrade.wav",0.7,100)
					self.RemoveCurrency(price)
					ClientPrint(self, HUD_PRINTCENTER, "") // blank out message
					scope.Preserved.isusingstrongmann = true
			
					//set cooldown time
					scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME + 2)
					//manually set it here just in case
					SetPropBool(self, "m_bUsingActionSlot", false)
				}
			}
		}
		function TakeUpgradeWeapon(box, weapon, slot)
		{
			ClientPrint(self, HUD_PRINTCENTER,"Hold Action Key to take your upgraded weapon")
			if (self.IsUsingActionSlot())
			{	
				//press the button
				ClientPrint(self, HUD_PRINTCENTER, "") // blank out message
				box.EmitSound("ui/item_heavy_gun_pickup.wav");
				if (weapon == "ZM_SVDL")
				{
					slot = "primary"
				}
				if (slot == "primary")
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 0) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden primary max ammo penalty")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_primary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 1), 1)",0,null,self)
					if (weapon != "ZM_SuperRusty" && weapon != "ZM_SuperFlamer") self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
					if (weapon == "ZM_SVDL") scope.Preserved.weapon_secondary <- null;
				}
				if (slot == "secondary") // redundancy fallbacks in case players die during perk bottle / death machine
				{
					for (local i = 0; i < MAX_WEAPONS; i++)
					{
						local oldweapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
						if (oldweapon == null)
						continue
						if (oldweapon.GetSlot() == 1) 
						{
							NetProps.SetPropEntityArray(self, "m_hMyWeapons", null, i)
							oldweapon.Destroy()
							if ("ammofix" in self.GetScriptScope().CustomWeapons) self.GetScriptScope().CustomWeapons.ammofix.RemoveAttribute("hidden secondary max ammo penalty")
							break
						}
					}
					::CustomWeapons.GiveItem(weapon, self);
					scope.Preserved.weapon_secondary <- weapon;
					EntFireByHandle(self,"runscriptcode","SetPropIntArray(self, `m_iAmmo`, ::CustomWeapons.GetMaxAmmo(self, 2), 2)",0,null,self);
					self.GetActiveWeapon().SetClip1(self.GetActiveWeapon().GetMaxClip1())
				}
				ApplyPerkBonuses(self);
				self.AcceptInput("speakresponseconcept", "TLK_MVM_LOOT_ULTRARARE", self, self);
				scope.Preserved.isusingstrongmann = false
				ClearPaPScope(self)
				::Strongmachine.Reset()
				scope.Preserved.cooldowntime = Time() + (BUTTON_COOLDOWN_TIME)
				SetPropBool(self, "m_bUsingActionSlot", false)
			}
		}
		function PressButton(box, message, input, param = "", delay = -1, activator = null, caller = null)
		{
			if (GetPropBool(box, "m_bLocked")) // shouldnt call something box if the box isnt the only one using it!!
			{
				ClientPrint(self, HUD_PRINTCENTER, "")
				return
			}
			
			ClientPrint(self, HUD_PRINTCENTER, message)

			if (self.IsUsingActionSlot())
			{
				box.EmitSound("buttons/button4.wav")
				EntFireByHandle(box, input, param, delay, activator, caller)
				if (box.GetName() == "teleport_button_1") ClientPrint(self, HUD_PRINTCENTER, "Data Link connection lost. Please resynchronize.")	// add a hint for teleporter
				else ClientPrint(self, HUD_PRINTCENTER, "")
			
				//set cooldown time
				scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME
				//manually set it here just in case
				SetPropBool(self, "m_bUsingActionSlot", false)
				
			}
		}
		local key = ""
		local boxname = box.GetName()

		if (boxname in Mysteryboxes)
			key = boxname
		else 
			foreach(name, func in Mysteryboxes)
				if (startswith(boxname, name))
				{
					key = name
					break
				}
		if (boxname in Strongmann)
			key = boxname
		else 
			foreach(name, func in Strongmann)
				if (startswith(boxname, name))
				{
					key = name
					break
				}
		if (boxname in GenericButtons)
			key = boxname
		else 
			foreach(name, func in GenericButtons)
				if (startswith(boxname, name))
				{
					key = name
					break
				}
		
		if (key in Mysteryboxes && scope.Preserved.cooldowntime < Time() && !GetPropBool(box, "m_bLocked") && scope.Preserved.isusingbox == false) RollForGun(box, Mysteryboxes[key])
		if (key in Mysteryboxes && scope.Preserved.cooldowntime < Time() && GetPropBool(box, "m_bLocked") && scope.Preserved.isusingbox == true) ReceiveGun(box, Preserved.mysteryitemname, Preserved.mysteryslot, Preserved.mysteryresponse)
		if (key in Strongmann   && scope.Preserved.cooldowntime < Time() && !GetPropBool(box, "m_bLocked") && scope.Preserved.isusingstrongmann == false) UpgradeWeapon(box, Strongmann[key])
		if (key in Strongmann 	&& scope.Preserved.cooldowntime < Time() && GetPropBool(box, "m_bLocked") && scope.Preserved.isusingstrongmann == true) TakeUpgradeWeapon(box, Preserved.papweapon, Preserved.papslot)
		if (key in GenericButtons && scope.Preserved.cooldowntime < Time())
		{
			local param = "", delay = -1, activator, caller
			if ("param" in GenericButtons[key]) param = GenericButtons[key].param 
			if ("delay" in GenericButtons[key]) param = GenericButtons[key].delay 
			if ("activator" in GenericButtons[key]) param = GenericButtons[key].activator 
			if ("caller" in GenericButtons[key]) param = GenericButtons[key].caller
	
			PressButton(box, GenericButtons[key].message, GenericButtons[key].input, param, delay, activator, caller)
			
		}
	}
	for (local reanimator; reanimator = FindByClassnameWithin(reanimator, "entity_revive_marker", self.GetOrigin(), BUTTON_RADIUS); ) 
	{
		ClientPrint(self, HUD_PRINTCENTER,"Hold Action Key to revive your teammate")
		if (self.IsUsingActionSlot() && scope.Preserved.cooldowntime < Time() && self.IsAllowedToTaunt()) 
		{
			ClientPrint(self, HUD_PRINTCENTER,"")
			self.Taunt(1,92)
			EntFireByHandle(self,"runscriptcode","RevivePlayer()",0.65,null,self);
			scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME - 2
			SetPropBool(self, "m_bUsingActionSlot", false)
		}
		function RevivePlayer()
		{
			local reanimator = FindByClassnameWithin(reanimator, "entity_revive_marker", self.GetOrigin(), BUTTON_RADIUS);
			local owner = GetPropEntity(reanimator, "m_hOwner")
			local multiplier = self.GetScriptScope().Preserved.multiplier
			if (owner == null)
			{
				self.StunPlayer(0.2,1,2,self)
				return
			}
			owner.ForceRespawn();
		//	owner.SetAbsOrigin(self.GetCenter()); // old
			owner.Teleport(true,self.GetCenter(),true,self.GetAbsAngles(),true,self.GetAbsVelocity());
		//	UnstuckEntity(owner) // kinda redundant and brings its own funk that don't mix
			GetPlayerLoadout(owner)
			owner.AcceptInput("speakresponseconcept", "TLK_RESURRECTED", owner, owner);
			owner.AddCondEx(51,2,self);
			self.StunPlayer(0.2,1,2,self);
			EmitSoundEx
			({
				sound_name = "MVM.PlayerRevived",
				origin = owner.GetCenter(),
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_DEFAULT
			});
			if (GetRoundState() == 4) // no more free money, you cheeky sods
			self.RemoveCurrency((owner.GetCurrency() * 0.05)*-1);
		}
	}
	for (local barricade; barricade = Entities.FindByNameWithin(barricade, "barricade*", self.GetOrigin(), BUTTON_RADIUS); ) 
	{
		local health = barricade.GetHealth()
		if (health == 7)
		{
			ClientPrint(self, HUD_PRINTCENTER,"")
			SetPropBool(self, "m_bUsingActionSlot", false)
			return
		}
		ClientPrint(self, HUD_PRINTCENTER,"Hold Action Key to build barricade")
		if (self.IsUsingActionSlot() && scope.Preserved.cooldowntime < Time() && health < 7) 
		{
			::Barricades.RepairBarricade(self,barricade)
			scope.Preserved.cooldowntime = Time() + BUTTON_COOLDOWN_TIME - 1.95	// for jank prevention, let above function finish before we get to do it again
		}
	}
	return -1
}