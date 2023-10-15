//Pachinko - Area #100
//Roulette - Area #264
//Slots - Area #5335
//Blackjack - Area #269

local area_list = {}
local path = []
local path_in_line_of_sight = []
local area_start = NavMesh.GetNearestNavArea(self.GetOrigin(), 900, false, true)
local area_end = 0

local roulette = NavMesh.GetNearestNavArea((Entities.FindByName(null, "roulettetarget")).GetOrigin(), 900, false, true)
local pachinko = NavMesh.GetNearestNavArea((Entities.FindByName(null, "pachinkotarget")).GetOrigin(), 900, false, true)
local slots = NavMesh.GetNearestNavArea((Entities.FindByName(null, "slotstarget")).GetOrigin(), 900, false, true)
local blackjack = NavMesh.GetNearestNavArea((Entities.FindByName(null, "blackjacktarget")).GetOrigin(), 900, false, true)

local distance = [NavMesh.NavAreaTravelDistance(area_start, roulette, 0), NavMesh.NavAreaTravelDistance(area_start, pachinko, 0), NavMesh.NavAreaTravelDistance(area_start, slots, 0), NavMesh.NavAreaTravelDistance(area_start, blackjack, 0)]
for (local i = 0; i < 4; i++)
    if (distance[i] == -1)
    distance [i] = 9999

distance.sort()

if (distance[0] == NavMesh.NavAreaTravelDistance(area_start, roulette, 0)) {area_end =  roulette}
else if (distance[0] == NavMesh.NavAreaTravelDistance(area_start, pachinko, 0)) {area_end =  pachinko}
else if (distance[0] == NavMesh.NavAreaTravelDistance(area_start, slots, 0)) {area_end =  slots}
else if (distance[0] == NavMesh.NavAreaTravelDistance(area_start, blackjack, 0)) {area_end =  blackjack}

NavMesh.GetNavAreasFromBuildPath(area_start, area_end, Vector(-2646, 2050, 192), 0.0, Constants.ETFTeam.TEAM_ANY, false, area_list)

local area = area_list["area0"];
local area_count = area_list.len();
path.append(area.GetCenter())

for (local i = 1; i < area_count && area != null; i++)
{
    local next_area = area_list["area" + i]
    path.append(next_area.GetCenter())
    if (TraceLine(self.GetOrigin() + Vector(0, 0, 64), next_area.GetCenter() + Vector(0, 0, 10), null) == 1)
    {
        break
    }
    if (TraceLine(area.GetCenter() + Vector(0, 0, 10), next_area.GetCenter() + Vector(0, 0, 10), null) == 1)
        path.pop()
    else 
        area = next_area
}

if (NavMesh.GetNearestNavArea(self.GetOrigin(), 900, false, true) == NavMesh.GetNavAreaByID(3))
{
    path.append(NavMesh.GetNavAreaByID(3).GetCorner(3))
}
path.append(self.GetOrigin())

SpawnEntityFromTable("info_particle_system", {
    origin = path[0] + Vector(0, 0, 30)
    cpoint1 = "trail_cpoint" + self.entindex() + 0
    targetname = "trail_cpoint" + self.entindex() + 0
    effect_name = "medicgun_beam_red"
    start_active = 1
})

for (local i = 1; i < (path.len()); i++)
{
    local angles = Vector(0, 0, 0)
    local direction_vector = Vector2D(path[i].x, path[i].y) - Vector2D(path[i - 1].x, path[i - 1].y)
    local yaw = 0

    if (direction_vector.y < 0)
        yaw = -acos(direction_vector.x / direction_vector.Length()) * 180 / PI
    else if (direction_vector.y > 0)
        yaw = acos(direction_vector.x / direction_vector.Length()) * 180 / PI
    else
        yaw = 0
    angles = Vector(0, yaw, 0)
    
    SpawnEntityFromTable("info_particle_system", {
        origin = path[i] + Vector(0, 0, 30)
        angles = angles
        cpoint1 = "trail_cpoint" + self.entindex() + (i - 1) 
        targetname = "trail_cpoint" + self.entindex() + i 
        effect_name = "medicgun_beam_red"
        start_active = 1
    })
}

for (local i = 0; i < (path.len()); i++)
{
    DoEntFire("trail_cpoint" + self.entindex() + i, "Kill", "", 0.9, null, null)
}

/* for (local i = 0; i < (area_list.len()); i++)
{
    SpawnEntityFromTable("info_particle_system", {
        origin = area_list["area" + i].GetCenter() + Vector(0, 0, 30)
        cpoint1 = "help" + self.entindex() + i 
        targetname = "help" + self.entindex() + i 
        effect_name = "medicgun_beam_blue"
        start_active = 1
    })
}

for (local i = 0; i < (area_list.len()); i++)
{
    DoEntFire("help" + self.entindex() + i, "Kill", "", 0.1, null, null)
} */