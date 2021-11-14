#ifndef GODOT_CHUNK_H
#define GODOT_CHUNK_H

#include <Godot.hpp>
#include <YSort.hpp>

#include <vector>

#include "cell.h"
#include "cell_manager.h"

namespace godot {

class Chunk : public YSort {
    GODOT_CLASS(Chunk, YSort)

private:
    Node* global;
    CellManager* cell_manager;

public:
    Array _to_draw;
    Array _drawn;
    std::vector<sh::Cell*> cells;
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

    void set_cellv(Vector2 cell_position, sh::Cell* cell);
    sh::Cell* get_cell_by_position(Vector2 cell_position);
    int get_cell_idv(Vector2 cell_position);

};

}

#endif