#include "tileset_manager.h"

#include <File.hpp>
#include <ResourceLoader.hpp>
#include <JSON.hpp>
#include <Directory.hpp>
#include <JSONParseResult.hpp>
#include <ProjectSettings.hpp>

#include "common.h"

using namespace godot;
using namespace sh;


void TilesetManager::_register_methods() {
    register_method("_init", &TilesetManager::_init);
    register_method("_ready", &TilesetManager::_ready);

    register_method("get_tileset_texture", &TilesetManager::get_tileset_texture);
    register_method("load_tileset", &TilesetManager::load_tileset);
}

TilesetManager::TilesetManager() {
    
}

TilesetManager::~TilesetManager() {
    
}


void TilesetManager::_init() {
    
}

void TilesetManager::_ready() {
    

}


Ref<Texture> TilesetManager::get_tileset_texture(String tileset) {
    return tilesets[tileset].texture;
}

const Tileset& TilesetManager::get_tileset(String tileset) {
    return tilesets[tileset];
}

void TilesetManager::load_tileset(String mod_name, String tileset_path) {
    
    auto file = File::_new();

    if (file->open(tileset_path, File::READ) != Error::OK) {
        GODOT_PRINT_ERROR(("Couldn't load tileset: " + tileset_path).alloc_c_string());
        return;
    }

    Ref<JSONParseResult> content = JSON::get_singleton()->parse(file->get_as_text());
    assertm(content != nullptr, "Couldn't parse tileset JSON!");
    GODOT_PRINT_ERROR(("Couldn't parse tileset JSON: " + tileset_path).alloc_c_string());

    if (content->get_error() != Error::OK) {
        GODOT_PRINT_ERROR(("Couldn't read tileset file: " + tileset_path).alloc_c_string());
        return;
    }

    auto result = (Dictionary)content->get_result();
	
    // assertm(result != nullptr, "Couldn't parse JSON to dictionary!");
    // GODOT_PRINT_ERROR(("Couldn't parse JSON to dictionary: " + tileset_path).alloc_c_string());


    // for (int i = 0; i < result->keys().size(); i++) { 
    //     String key = result->keys()[i];
    //     String value = (*result)[key];

    //     tilesets.insert(std::make_pair(
    //         mod_name + key,
    //         sh::Tileset{
    //             ResourceLoader::get_singleton()->load(ProjectSettings::get_singleton()->globalize_path("res://mods/") + value),
    //             value,
    //         }
    //     ));
    // }
    file->close();
}
  
