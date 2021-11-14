#include "map_manager.h"
#include "chunk.h"
#include "cell.h"
#include "chunk_manager.h"
#include "cell_manager.h"
#include "tile_map_utils.h"
#include "mod_loader.h"
#include "tileset.h"
#include "helper.h"

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
    godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
    godot::Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    godot::Godot::nativescript_init(handle);

    godot::register_class<godot::ChunkManager>();
    godot::register_class<godot::Chunk>();
    // godot::register_class<godot::sh::Cell>();
    godot::register_class<godot::ModLoader>();
    godot::register_class<godot::MapManager>();
    godot::register_class<godot::CellManager>();
    godot::register_class<godot::sh::TileMapUtils>();
    godot::register_class<godot::TilesetManager>();    
    godot::register_class<godot::CellManager>();
    // godot::register_class<godot::sh::Tileset>();
    godot::register_class<godot::sh::Helper>();
}

