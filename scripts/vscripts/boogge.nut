if (Entities.FindByName(null, "a")) {
	return;
}

SpawnEntityFromTable("logic_relay",
{
	targetname = "a"
})

local nav=SpawnEntityFromTable("func_nav_avoid",
{
	targetname = "bombpath_left_avoid"
	origin = Vector(1952, -1632, -96)
	tags = "common bomb_carrier"
	team = "3"
	start_disabled = "0"
})
nav.KeyValueFromInt("solid", 2)
nav.KeyValueFromString("mins", "-1248 -672 -160")
nav.KeyValueFromString("maxs", "1248 672 160")

local nav=SpawnEntityFromTable("func_nav_avoid",
{
	targetname = "bombpath_right_avoid"
	origin = Vector(2688, -64, -80)
	tags = "common bomb_carrier"
	team = "3"
	start_disabled = "0"
})
nav.KeyValueFromInt("solid", 2)
nav.KeyValueFromString("mins", "-1600 -512 -176")
nav.KeyValueFromString("maxs", "1600 512 176")

EntFire("bombpath_choose_relay","Trigger")