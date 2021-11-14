#include "map_manager.h"

#include "common.h"

using namespace godot;

void MapManager::_register_methods() {
    register_method("_process", &MapManager::_process);
    register_method("_draw", &MapManager::_draw);
    register_method("_init", &MapManager::_init);
    register_method("_ready", &MapManager::_ready);

    register_method("batch_change_cell_height_delta", &MapManager::batch_change_cell_height_delta);
    register_method("batch_set_cell_size", &MapManager::batch_set_cell_size);

    register_method("set_cellv", &MapManager::set_cellv);
    register_method("set_cell", &MapManager::set_cell);
    register_method("set_cell_biomev", &MapManager::set_cell_biomev);
    
    register_method("get_chunk_manager", &MapManager::get_chunk_manager);

    // doesn't seem to work
    //register_property<MapManager, ChunkManager*>("chunk_manager", &MapManager::chunk_manager, (ChunkManager*)nullptr);
}

MapManager::MapManager() {

}

MapManager::~MapManager() {

}


void MapManager::_init() {

}

void MapManager::_ready() {
    global = get_node("/root/Global");
    cell_manager = Object::cast_to<CellManager>(get_node("/root/CellManager"));

    assertm(global != nullptr, "Couldn't find 'Global'!");
    assertm(cell_manager != nullptr, "Couldn't find 'CellManager'!");

    chunk_manager = Object::cast_to<ChunkManager>(get_child(0)); // Cast will get validated and return `null` in case is invalid
    CRASH_COND(chunk_manager == nullptr);

    for (int x = 0; x < 5; x++) {
        for (int y = 0; y < 5; y++) {
            set_cell(x * 20, y * 20, "base_debug_numbers_tileset");
        }   
    }
}

void MapManager::_process(float delta) {

}

void MapManager::_draw() {

}


void MapManager::batch_change_cell_height_delta(Vector2 offset, int width, int height, int height_delta) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            for (int i = 0; i < 2; i++) {
                int cell_x = int(offset.x + x + y + i);
                int cell_y = int(offset.y - x + y);
                //Godot::print(String("height cell: ") + String::num(cell_x) + ", ", String::num(cell_y));
                sh::Cell* cell = chunk_manager->get_cellv(Vector2{(real_t)cell_x, (real_t)cell_y});

                if (cell == nullptr) {
                    Godot::print(String("height cell is null "));
                    continue;
                } else {
                    // Godot::print(String("height cell is NOT null "));
                }

                if (cell->cell_ref != nullptr) {
                    int tile_it = cell->cell_ref->tile_type + 1;

                    for (int iy = 0; iy < tile_it; iy++) {
                        for (int ix = 0; ix < tile_it; ix++) {
							Vector2 cell_p = Vector2{
								cell->cell_ref->cell_position.x + ix,
								cell->cell_ref->cell_position.y + iy
                            };
							sh::Cell* other_cell = chunk_manager->get_cellv(cell_p);

                            if (other_cell == cell) {
								continue;
                            }
                            other_cell->cell_ref = nullptr;
                            set_cell(int(cell_p.x), int(cell_p.y), other_cell->tile_name, other_cell->offset - Vector2(0, (real_t)height_delta), 0); //CellManager.SMALL
                        }
                    }
					cell->cell_ref = nullptr;
					set_cell(int(cell->cell_position.x), int(cell->cell_position.y), 
                            cell->tile_name, cell->offset - Vector2(0, (real_t)height_delta), 0); //CellManager.SMALL

                } else if (cell->tile_type > 0) { //CellManager.SMALL
                    for (int iy = 0; iy < cell->tile_type; iy++) {
                        for (int ix = 0; ix < cell->tile_type; ix++) {
							sh::Cell* other_cell = chunk_manager->get_cellv(Vector2{(real_t)(cell_x + ix), (real_t)(cell_y + iy)});
							other_cell->cell_ref = nullptr;
							set_cell(cell_x + ix, cell_y + iy, cell->tile_name, other_cell->offset - Vector2(0, (real_t)height_delta), 0); //CellManager.SMALL
                        }
                    }
                } else {
                    cell->cell_ref = nullptr;
					set_cell(cell_x, cell_y, cell->tile_name, cell->offset - Vector2(0, (real_t)height_delta), 0); // CellManager.SMALL
                }
            }
        }    
    }
	//chunk_manager->update_range(offset, width, height)
	chunk_manager->update();
}

void MapManager::batch_set_cell_size(Vector2 offset, int width, int height, String tile_name) {

}


void MapManager::set_cellv(Vector2 cell_position, String tile_name, Vector2 offset, int tile_type) {
    set_cell(int(cell_position.x), int(cell_position.y), tile_name, offset, tile_type);
}

void MapManager::set_cell(int cell_x, int cell_y, String tile_name, Vector2 offset, int tile_type) {
    if (cell_x < 0 || cell_y < 0) {
        return;
    }
    real_t max_cell_height = static_cast<real_t>(MAX_CELL_HEIGHT);

	offset.y = Math::max(offset.y, -max_cell_height);
	
	Vector2 cell_position = Vector2{(real_t)cell_x, (real_t)cell_y};

	sh::Cell* cell = chunk_manager->get_cellv(cell_position);
	
    if (cell == nullptr) {
        cell = cell_manager->create_cell(cell_x, cell_y, tile_name, offset, tile_type);
    } else {
        cell_manager->change_cell(cell, tile_name, offset, tile_type);
    }

	cell->cell_ref = nullptr;
	// to update the chunks
	int chunk_index = chunk_manager->set_cellv(cell_position, cell);
	if (tile_type > 0) {
		for (int x = 0; x < tile_type + 1; x++) {
            for (int y = 0; y < tile_type + 1; y++) {
				sh::Cell* other_cell = chunk_manager->get_cellv(cell_position + Vector2((real_t)x, (real_t)y));
				other_cell->visible = false;
				other_cell->cell_ref = cell;
            }
        }
    }
			
	cell->visible = true;
}

void MapManager::set_cell_biomev(Vector2 cell_position, String tile_name) {
    if (cell_position.x < 0 || cell_position.y < 0) {
        return;
    }
    sh::Cell* cell = chunk_manager->get_cellv(cell_position);
    
    cell_manager->change_cell(cell, tile_name, cell->offset, cell->tile_type);
	chunk_manager->set_cellv(cell_position, cell);
}

ChunkManager* MapManager::get_chunk_manager() {
    return chunk_manager;
}

