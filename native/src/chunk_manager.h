#ifndef GODOT_CHUNKMANAGER_H
#define GODOT_CHUNKMANAGER_H

#include <Node2D.hpp>

#include "chunk.h"
#include "cell_manager.h"

namespace godot {

class ChunkManager : public Node2D {
    GODOT_CLASS(ChunkManager, Node2D)

private:
    Node* global;
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
    
    int set_cellv(Vector2 cell_position, Ref<Cell> cell);

    Ref<Cell> get_cellv(Vector2 cell_position);
    Vector2 get_chunk_position(Vector2 cell_position);
    int get_chunk_id(Vector2 cell_position);

    Vector2 chunk_id_to_chunk_pos(int chunk_id);

};

}

#endif