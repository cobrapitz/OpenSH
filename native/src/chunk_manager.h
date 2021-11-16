#ifndef GODOT_CHUNKMANAGER_H
#define GODOT_CHUNKMANAGER_H

#include <Node2D.hpp>

#include "chunk.h"
#include "cell_manager.h"

namespace godot {

class ChunkManager : public Node2D {
    GODOT_CLASS(ChunkManager, Node2D)

private:
    CellManager* cell_manager;

public:
    Array shown_chunks;
    Array chunks;

    int draw_width;
    int draw_height;
    Vector2 draw_offset;

public:
    static void _register_methods();

    ChunkManager();
    ~ChunkManager();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

    void set_draw_range(Vector2 offset, int width, int height);
    
    int set_cell(int cell_x, int cell_y, sh::Cell* cell);

    sh::Cell* get_cell(int cell_x, int cell_y);
    Vector2 get_chunk_position(int cell_x, int cell_y);
    int get_chunk_id(int cell_x, int cell_y);

    Vector2 chunk_id_to_chunk_pos(int chunk_id);

};

}

#endif