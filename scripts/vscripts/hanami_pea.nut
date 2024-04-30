::PEA <-
{	
	blimp_path = SpawnEntityGroupFromTable(
	{
		path1 = { path_track = {  origin = Vector(-2939, -1857, 500), targetname = "blimp_path1",  target = "blimp_path2", } },
		path2 = { path_track = {  origin = Vector(-1675, -1857, 500), targetname = "blimp_path2",  target = "blimp_path3", } },
		path3 = { path_track = {  origin = Vector(1264, -1857, 500),  targetname = "blimp_path3",  target = "blimp_path4", } },
		path4 = { path_track = {  origin = Vector(1264, 3029, 500),   targetname = "blimp_path4",  target = "blimp_path5", } },
		path5 = { path_track = {  origin = Vector(-510, 3029, 500),   targetname = "blimp_path5",  target = "blimp_path6", } },
		path6 = { path_track = {  origin = Vector(-510, 4206, 500),   targetname = "blimp_path6",  target = "blimp_path7", } },
		path7 = { path_track = {  origin = Vector(568, 4206, 500),    targetname = "blimp_path7",  target = "blimp_path8", } },
		path8 = { path_track = {  origin = Vector(568, 4720, 500),    targetname = "blimp_path8",  					       } }
	})
	
	CALLBACKS =
	{
		OnGameEvent_mvm_begin_wave = function(params) { if (Wave == 4) ConvertTankIconsToBlimp(false, 1) }
	}
}

try { IncludeScript("pea.nut") }
catch (e) { ClientPrint(null,3,"Failed to locate `pea.nut` file. Some of this mission's features may not work correctly or result in softlocks.") }

if (Wave == 4) ConvertTankIconsToBlimp(false, 1)