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
    //register_method("set_cellv", &Chunk::set_cellv);
    //register_method("get_cell_by_position", &Chunk::get_cell_by_position);
    register_method("get_cell_id", &Chunk::get_cell_id);
    
    // register_property("cells", &Chunk::cells, Array());
    register_property("_drawn", &Chunk::_drawn, Array());
    register_property("_to_draw", &Chunk::_to_draw, Array());
    register_property("chunk_position", &Chunk::chunk_position, Vector2::ZERO);
    register_property("filled", &Chunk::filled, false);
    register_property("chunk_id", &Chunk::chunk_id, -1);
}

Chunk::Chunk() {

}

Chunk::~Chunk() {
    for (int i = 0; i < cells.size(); i++) {
        if (cells[i] == nullptr) {
            continue;
        }
        delete cells[i];
        cells[i] = nullptr;
    }    
}


void Chunk::Chunk::_init() {

}

void Chunk::_ready() {
    global = get_node("/root/Global");
    cell_manager = Object::cast_to<CellManager>(get_node("/root/CellManager"));

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
    //cells.resize(int(chunk_size.x * chunk_size.y));

    Godot::print(String("filling chunk at ") + String(chunk_position));
    // Godot::print(String("Cells size: ") + String::num(cells.size()));
    // Godot::print(String("Chunk position: ") + String(chunk_position));
    // Godot::print(String("Chunk size: ") + String(chunk_size));

    assert(cell_manager != nullptr);
    assert(!cell_manager->cells.empty());

    auto it_begin = cell_manager->cells.begin();
    // Godot::print("Fill with " + String(it_begin->first));
    for (int x = 0; x < (int)chunk_size.x; x++) {
        for (int y = 0; y < (int)chunk_size.y; y++) {
            auto cell = cell_manager->create_cell(
                    int(x + (chunk_position.x * chunk_size.x)),
                    int(y + (chunk_position.y * chunk_size.y)),
                    "base_sh_grass_tileset" //it_begin->first
            );
            cells[x + y * (int) chunk_size.x] = cell;
        }
    }
        
    assert(cells.size() == (chunk_size.x * chunk_size.y));
}

void Chunk::fill_empty() {  
    Vector2 chunk_size = {CHUNK_SIZEX, CHUNK_SIZEY};
    assert(cells.empty());
    cells.resize(int(chunk_size.x * chunk_size.y));
    filled = false;
}

void Chunk::set_cell(int cell_x, int cell_y, sh::Cell* cell) {
    cells[get_cell_id(cell_x, cell_y)] = cell;
}   

sh::Cell* Chunk::get_cell_by_position(int cell_x, int cell_y) {
    int cell_id = get_cell_id(cell_x, cell_y);
    //assert(cells[cell_id] != nullptr);
    //assert(cell_id >= 0 && cell_id < cells.size());
    if (cell_id < 0 || cell_id >= cells.size()) {
        return nullptr;
    }
    return cells[cell_id];
}

int Chunk::get_cell_id(int cell_x, int cell_y) {
    return int(cell_x + cell_y * CHUNK_SIZEX);
}


