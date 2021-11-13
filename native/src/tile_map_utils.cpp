#include "tile_map_utils.h"

#include "common.h"

using namespace godot;
using namespace sh;

TileMapUtils *TileMapUtils::_singleton = nullptr;

void TileMapUtils::_register_methods() {
    register_method("_init", &TileMapUtils::_init);
    register_method("_ready", &TileMapUtils::_ready);

    register_method("chunk_world_to_1D", &TileMapUtils::chunk_world_to_1D);
    register_method("chunk_cell_to_chunk_pos", &TileMapUtils::chunk_cell_to_chunk_pos);
    register_method("chunk_cell_to_1D", &TileMapUtils::chunk_cell_to_1D);
    register_method("_world_to_1D", &TileMapUtils::_world_to_1D);
    register_method("_cell_to_1D", &TileMapUtils::_cell_to_1D);
    register_method("get_mouse_center_isometric", &TileMapUtils::get_mouse_center_isometric);
}

TileMapUtils::TileMapUtils() {
    
}

TileMapUtils::~TileMapUtils() {
       
}

void TileMapUtils::_init() {

}

void TileMapUtils::_ready() {
	this->set_cell_size(CELL_SIZE);
    set_mode(TileMap::MODE_ISOMETRIC);
}

int TileMapUtils::chunk_world_to_1D(int x, int y) {
	Vector2 p = world_to_map(Vector2{(real_t)x, (real_t)y});
	return int(p.x + p.y * CHUNK_SIZEX);
}

Vector2 TileMapUtils::chunk_cell_to_chunk_pos(int cell_x, int cell_y) {
	return Vector2{
        (real_t)int(cell_x / CHUNK_SIZEX), 
        (real_t)int(cell_y / CHUNK_SIZEY), 
    };
}

int TileMapUtils::chunk_cell_to_1D(int cell_x, int cell_y) {
	cell_x = cell_x % int(CHUNK_SIZEX);
	cell_y = cell_y % int(CHUNK_SIZEY);
	return int(cell_x + cell_y * CHUNK_SIZEX);
}

int TileMapUtils::_world_to_1D(int x, int y) {
	Vector2 p = world_to_map(Vector2{(real_t)x, (real_t)y});
	return int(p.x + p.y * MAP_SIZE);
}

int TileMapUtils::_cell_to_1D(int x, int y) {
    return int(x + y * MAP_SIZE);
}

godot::Vector2 TileMapUtils::get_mouse_center_isometric(godot::Vector2 position) {
    return map_to_world(world_to_map(get_global_mouse_position()));
}
