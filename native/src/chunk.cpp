#include "chunk.h"

#include "common.h"

using namespace godot;

void Chunk::_register_methods() {

    register_method("_process", &Chunk::_process);
    register_method("_draw", &Chunk::_draw);
    register_method("_init", &Chunk::_init);
    register_method("_ready", &Chunk::_ready);

    register_method("fill", &Chunk::fill);
    register_method("fill_empty", &Chunk::fill_empty);
    register_method("set_cellv", &Chunk::set_cellv);
    register_method("get_cell_by_position", &Chunk::get_cell_by_position);
    register_method("get_cell_idv", &Chunk::get_cell_idv);
    
    register_property("cells", &Chunk::cells, Array());
    register_property("_drawn", &Chunk::_drawn, Array());
    register_property("_to_draw", &Chunk::_to_draw, Array());
    register_property("chunk_position", &Chunk::chunk_position, Vector2::ZERO);
    register_property("filled", &Chunk::filled, false);
    register_property("chunk_id", &Chunk::chunk_id, -1);
}

Chunk::Chunk() {

}

Chunk::~Chunk() {
    
}


void Chunk::Chunk::_init() {

}

void Chunk::_ready() {
    global = get_node("/root/Global");
    cell_manager = get_node("/root/CellManager");

    assertm(global != nullptr, "Couldn't find 'Global'!");
    assertm(cell_manager != nullptr, "Couldn't find 'CellManager'!");

    filled = false;
}

void Chunk::_process(float delta) {

}

void Chunk::_draw() {   

}

void Chunk::fill() {
    filled = true;
    Vector2 chunk_size = {CHUNK_SIZEX, CHUNK_SIZEY};
    cells.resize(int(chunk_size.x * chunk_size.y));

    Godot::print(String("filling chunk at ") + String(chunk_position));
    // Godot::print(String("Cells size: ") + String::num(cells.size()));
    // Godot::print(String("Chunk position: ") + String(chunk_position));
    // Godot::print(String("Chunk size: ") + String(chunk_size));

    for (int x = 0; x < (int)chunk_size.x; x++) {
        for (int y = 0; y < (int)chunk_size.y; y++) {
            cells[x + y * (int) chunk_size.x] = cell_manager->call("_create_cell",
                (x + (chunk_position.x * chunk_size.x)),
                (y + (chunk_position.y * chunk_size.y)),
                static_cast<Dictionary>(cell_manager->get("cells_data")).keys()[0]
            );
        }
    }
}

void Chunk::fill_empty() {  
    Vector2 chunk_size = {CHUNK_SIZEX, CHUNK_SIZEY};
    cells.resize(int(chunk_size.x * chunk_size.y));
}

void Chunk::set_cellv(Vector2 cell_position, Ref<Cell> cell) {
    if (cell == nullptr) {
        Godot::print("is null");
    } else {
        //Godot::print("cell is not null");
    }
    cells[get_cell_idv(cell_position)] = cell;
}   

Ref<Cell> Chunk::get_cell_by_position(Vector2 cell_position) {
    int cell_id = get_cell_idv(cell_position);
    if (cell_id < 0 || cell_id >= cells.size()) {
        return nullptr;
    }
    return cells[cell_id];
}

int Chunk::get_cell_idv(Vector2 cell_position) {
    return int(cell_position.x + cell_position.y * CHUNK_SIZEX);
}


