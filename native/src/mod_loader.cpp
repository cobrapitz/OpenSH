#include "mod_loader.h"

#include "common.h"
#include "tileset_manager.h"
#include "cell_manager.h"

#include <OS.hpp>
#include <Directory.hpp>

using namespace godot;



void ModLoader::_register_methods() {
    register_method("_init", &ModLoader::_init);
    register_method("_ready", &ModLoader::_ready);
}

ModLoader::ModLoader() {
   
}

ModLoader::~ModLoader() {
    
}


void ModLoader::_init() {
    
}

void ModLoader::_ready() {
    Godot::print("Beginning Native Modloader.");
    String mods_base_path;
    
    if (OS::get_singleton()->has_feature("standalone")) {
        Godot::print("Running an exported build.");
        mods_base_path = OS::get_singleton()->get_executable_path().get_base_dir();
    } else {
        Godot::print("Running from the editor.");
        mods_base_path = "res:/";
    }

    mods_base_path += "/mods";

    Godot::print(String("Path to mod folder: ") + mods_base_path);

    auto mod_base_paths = get_directory_paths(mods_base_path);

    for (auto& mod_name : mod_base_paths) {
        Godot::print("trying to load: " + mod_name);
        load_mod(mod_name, mods_base_path);
    }
}

void ModLoader::load_mod(String mod_name, String mods_base_path) {
	Godot::print(String("################################################"));
	Godot::print("Loading tilesets...");

    auto tileset_manager = Object::cast_to<TilesetManager>(get_node("/root/TilesetManager")); // Cast will get validated and return `null` in case is invalid
    CRASH_COND(tileset_manager == nullptr);

    auto& tileset_paths = get_file_paths(mods_base_path + "/" + mod_name + "/resources/tilesets");
	for (auto&& tileset_name : tileset_paths) {
		Godot::print("loading tileset from: " + mods_base_path + "/" + mod_name + "/resources/tilesets/" + tileset_name);
		tileset_manager->load_tileset(mod_name + "_", mods_base_path + "/" + mod_name + "/resources/tilesets/" + tileset_name);
    }

	Godot::print("Finished loading tilesets.");
	Godot::print("################################################");

    Godot::print("Loading tiles...");
    
    auto cell_manager = Object::cast_to<CellManager>(get_node("/root/CellManager")); // Cast will get validated and return `null` in case is invalid
    CRASH_COND(cell_manager == nullptr);

    auto tile_paths = get_file_paths(mods_base_path + "/" + mod_name + "/resources/tiles");
    
	for (auto&& tile_name : tile_paths) {
		Godot::print("loading tiles from: " + String(mods_base_path + "/" + mod_name + "/resources/tiles/" + tile_name));
        cell_manager->load_cells(mod_name + "_", mods_base_path + "/" + mod_name + "/resources/tiles/" + tile_name);
    } 

    
	Godot::print("Finished loading tiles.");
	Godot::print("################################################");


	
    Godot::print("Loading chevrons...");

    auto chevron_paths = get_file_paths(mods_base_path + "/" + mod_name + "/resources/chevrons");


    for (auto&& chevron_name : chevron_paths) {
		Godot::print("loading chevrons from: " + mods_base_path + "/" + mod_name + "/resources/chevrons/" + chevron_name);
        cell_manager->load_cells(mod_name + "_", mods_base_path + "/" + mod_name + "/resources/chevrons/" + chevron_name);
    } 

    Godot::print("Finished chevrons tiles.");
	Godot::print("################################################");

    Godot::print("Finished Native.");
}

std::vector<String> ModLoader::get_directory_paths(String base_folder) {
    std::vector<String> dirs;
    Directory* dir = Directory::_new();

    dir->open(base_folder);
    dir->list_dir_begin();
    
    while (true) {
        String& file = dir->get_next();
        if (file.empty()) {
            break;
        } else if (!file.begins_with(".") && dir->current_is_dir()) {
            dirs.push_back(file);
        }
    }

    dir->list_dir_end();

    return dirs;
}

std::vector<String> ModLoader::get_file_paths(String base_folder) {
    std::vector<String> dirs;
    Directory* dir = Directory::_new();

    dir->open(base_folder);
    dir->list_dir_begin();
    
    while (true) {
        String& file = dir->get_next();
        if (file.empty()) {
            break;
        } else if (!file.begins_with(".") && !dir->current_is_dir()) {
            dirs.push_back(file);
        }
    }

    dir->list_dir_end();

    return dirs;
}
