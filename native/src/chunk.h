#ifndef GODOT_CHUNK_H
#define GODOT_CHUNK_H

#include <Godot.hpp>
#include <YSort.hpp>

#include "cell.h"

namespace godot {

class Chunk : public YSort {
    GODOT_CLASS(Chunk, YSort)

private:
    Node* global;
    Node* cell_manager;

public:
    Array _to_draw;
    Array _drawn;
    Array cells;
    Vector2 chunk_position;

    bool filled;
    int chunk_id;
    
public:
    static void _register_methods();

    Chunk();
    ~Chunk();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

    void fill();
    void fill_empty();

    void set_cellv(Vector2 cell_position, Ref<Cell> cell);
    Ref<Cell> get_cell_by_position(Vector2 cell_position);
    int get_cell_idv(Vector2 cell_position);

};

}

#endif