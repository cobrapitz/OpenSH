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

    auto content = JSON::get_singleton()->parse(file->get_as_text());
    assertm(content != nullptr, "Couldn't parse tileset JSON!");

    if (content->get_error() != Error::OK) {
        GODOT_PRINT_ERROR(("Couldn't read tileset file: " + tileset_path).alloc_c_string());
        return;
    }

    auto result = content->get_result();
	
    if (result.get_type() != Variant::Type::DICTIONARY) {
        GODOT_PRINT_ERROR(("Read tileset is no Dictionary: " + tileset_path).alloc_c_string());
        return;
    }

    auto dict = result.operator godot::Dictionary();

    for (int i = 0; i < dict.keys().size(); i++) { 
        String key = dict.keys()[i];
        String value = dict[key];

        //Godot::print("Adding tileset: " + mod_name + key);
        //Godot::print("from: " + String(ProjectSettings::get_singleton()->globalize_path("res://mods/") + value));

        tilesets.insert(std::make_pair(
            mod_name + key,
            sh::Tileset{
                ResourceLoader::get_singleton()->load(ProjectSettings::get_singleton()->globalize_path("res://mods/") + value),
                value,
            }
        ));
    }
    file->close();
}
  
