#ifndef GODOT_MAPMANAGER_H
#define GODOT_MAPMANAGER_H

#include <Godot.hpp>
#include <YSort.hpp>

#include "chunk_manager.h"

namespace godot {

class MapManager : public YSort {
    GODOT_CLASS(MapManager, YSort)

private:
    Node* global;
    Node* cell_manager;
    ChunkManager* chunk_manager;

public:
    
public:
    static void _register_methods();

    MapManager();
    ~MapManager();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

    void batch_change_cell_height_delta(Vector2 offset, int width, int height, int height_delta);
    void batch_set_cell_size(Vector2 offset, int width, int height, String tile_name);

    void set_cellv(Vector2 cell_position, String tile_name, Vector2 offset = Vector2::ZERO, int tile_type = 0);
    void set_cell(int cell_x, int cell_y, String tile_name, Vector2 offset = Vector2::ZERO, int tile_type = 0);
    void set_cell_biomev(Vector2 cell_position, String tile_name);

    ChunkManager* get_chunk_manager();

};

}

#endif