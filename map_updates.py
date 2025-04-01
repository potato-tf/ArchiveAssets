import os
import shutil

POPFILE_DIR = "scripts/population"
MAP_DIR = "maps"

def update_missions_and_mapnames():
    maps = os.listdir(os.path.join(os.getcwd(), MAP_DIR))
    split_maps = [map.split(".") for map in maps]
    map_names = [map[0] for map in split_maps if map[1] == "bsp"]
    
    map_times = {map: int(os.path.getmtime(os.path.join(os.getcwd(), MAP_DIR, map + ".bsp"))) for map in map_names}
    newest_maps = {}
    
    for m, t in map_times.items():
        m_split = m.split("_")
        noversion = "_".join(m_split[:-1]) if len(m_split) > 2 else m

        # If we haven't seen this map before, or if this version is newer
        if noversion not in newest_maps or t > newest_maps[noversion][1]:
            newest_maps[noversion] = (m, t)  # Store both the full map name and timestamp

    # Update map files and popfiles
    for base_name, (newest_version, _) in newest_maps.items():
        # Handle map files
        for old_map in map_names:
            if old_map != newest_version and old_map.startswith(base_name + "_"):
                # Delete older version
                old_path = os.path.join(os.getcwd(), MAP_DIR, old_map + ".bsp")
                try:
                    os.remove(old_path)
                    print(f"Removed old map: {old_map}.bsp")
                except OSError as e:
                    print(f"Error removing {old_map}.bsp: {e}")

        # Handle popfiles
        if os.path.exists(POPFILE_DIR):
            pop_files = [f for f in os.listdir(POPFILE_DIR) if f.endswith('.pop')]
            for pop_file in pop_files:
                if pop_file.startswith(base_name + "_"):
                    # Rename popfile to match newest map version
                    old_pop = os.path.join(POPFILE_DIR, pop_file)
                    new_pop = os.path.join(POPFILE_DIR, 
                                         pop_file.replace(base_name, newest_version, 1))
                    try:
                        shutil.move(old_pop, new_pop)
                        print(f"Updated popfile: {pop_file} -> {os.path.basename(new_pop)}")
                    except OSError as e:
                        print(f"Error updating {pop_file}: {e}")

    return newest_maps

result = update_missions_and_mapnames()
print("\nFinal map versions:", {k: v[0] for k, v in result.items()})