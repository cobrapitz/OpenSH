#include "chunk_manager.h"

#include <string>

#include "common.h"
#include "tile_map_utils.h"
#include "helper.h"

using namespace godot;


void ChunkManager::_register_methods() {
    register_method("_process", &ChunkManager::_process);
    register_method("_draw", &ChunkManager::_draw);
    register_method("_init", &ChunkManager::_init);
    register_method("_ready", &ChunkManager::_ready);

    register_method("set_draw_range", &ChunkManager::set_draw_range);
    register_method("get_chunk_position", &ChunkManager::get_chunk_position);
    register_method("get_chunk_id", &ChunkManager::get_chunk_id);
    register_method("get_cellv", &ChunkManager::get_cellv);
    register_method("set_cellv", &ChunkManager::set_cellv);
    
    register_property<ChunkManager, Array>("chunks", &ChunkManager::chunks, Array());
    register_property<ChunkManager, Array>("shown_chunks", &ChunkManager::shown_chunks, Array());
    
    register_property<ChunkManager, int>("draw_width", &ChunkManager::draw_width, 10);
    register_property<ChunkManager, int>("draw_height", &ChunkManager::draw_height, 10);
    register_property<ChunkManager, Vector2>("draw_offset", &ChunkManager::draw_offset, Vector2(10.0, 10.0));
}

ChunkManager::ChunkManager() {
}

ChunkManager::~ChunkManager() {
    
}

void ChunkManager::_ready() {
    global = get_node("/root/Global");
    cell_manager = Object::cast_to<CellManager>(get_node("/root/CellManager"));

    assertm(global != nullptr, "Couldn't find 'Global'!");
    assertm(cell_manager != nullptr, "Couldn't find 'CellManager'!");

    sh::Helper::get_singleton()->set_timer("ChunkManager");

    int max_chunks_size_width = static_cast<int>(MAX_CHUNKS_SIZE_WIDTH);
    //chunks.resize(max_chunks_size_width * max_chunks_size_width);
    Godot::print(String("init Chunk size -> ") + String::num(max_chunks_size_width * max_chunks_size_width));

    int test = 0;

    for (int i = 0; i < max_chunks_size_width * max_chunks_size_width; i++) {
        Chunk* new_chunk = Chunk::_new();
        new_chunk->chunk_position = chunk_id_to_chunk_pos(i);
        add_child(new_chunk);
        chunks.append(new_chunk);
        new_chunk->fill_empty();
    }

    set_draw_range(Vector2(200.0, 200.0), 100, 100);

    Godot::print(String("Creating chunks: ") + String::num(chunks.size()));

    sh::Helper::get_singleton()->get_time("ChunkManager");
}

void ChunkManager::_init() {
    
}

void ChunkManager::_process(float delta) {
    
}

void ChunkManager::_draw() {
    // Godot::print("Calling -> ChunkManager::_draw");
    // Godot::print(String("draw_height: ") + String::num(draw_height));
    // Godot::print(String("draw_width: ") + String::num(draw_width));
    // Godot::print(String("draw_offset: " + String(draw_offset)));

    sh::Helper::get_singleton()->set_timer("ChunkManagerDraw");

    for (int y = 0; y < draw_height; y++) {
        for (int i = 0; i < 2; i++) {
            for (int x = 0; x < draw_width; x++) {
                int cell_x = int(draw_offset.x) + x + y + i;
                int cell_y = int(draw_offset.y) -x + y;
                Vector2 cell_position = {real_t(cell_x), real_t(cell_y)};
                Ref<Cell> cell = get_cellv(cell_position);
                if (cell == nullptr) {
                    continue;
                }
                if (!cell->visible || cell->tile_type > 0 || cell->offset.y == 0) {
                    continue;
                }
                // Godot::print(String("cell_x: ") + String::num(x));
                // Godot::print(String("cell_y: ") + String::num(x));
                // Godot::print(String("cell_position: ") + String(cell_position));
                // Godot::print(String("cell->position: ") + String(cell->position));
                // Godot::print(String("cell->offset: ") + String(cell->offset));
                // Godot::print(String("cell->offset: ") + String(cell->tile_offset));
                // Godot::print(String("cell->size: ") + String(cell->size));
                // Godot::print(String("cell->texture_region_rect: ") + String(cell->texture_region_rect));
                draw_texture_rect_region(
								cell->chevron, 
                                Rect2(
                                    Vector2(
                                        cell->position.x + cell->offset.x + 0,
                                        cell->position.y + cell->offset.y +  cell->size.y
                                    ),
								    cell_manager->call("get_chevron_size", cell->tile_name)
                                ),
								cell->chevron_region_rect //, color
                            );
            }
            for (int x = 0; x < draw_width; x++) {
                int cell_x = int(draw_offset.x) + x + y + i;
                int cell_y = int(draw_offset.y) -x + y;
                Vector2 cell_position = {real_t(cell_x), real_t(cell_y)};
                Ref<Cell> cell = get_cellv(cell_position);
                if (cell == nullptr) {
                    continue;
                }

                draw_texture_rect_region(
                    cell->texture,
                    Rect2(cell->position + cell->offset + cell->tile_offset, cell->size),
                    cell->texture_region_rect
                );
            }    
        }
    }
    sh::Helper::get_singleton()->get_time("ChunkManagerDraw");
}

Vector2 ChunkManager::get_chunk_position(Vector2 cell_position) {
    // Godot::print(String("get chunk pos: ") + String(cell_position));
    Vector2 chunk_position = {};
    // Godot::print("b1");
    chunk_position.x = static_cast<real_t>((int)(cell_position.x / CHUNK_SIZEX));
    chunk_position.y = static_cast<real_t>((int)(cell_position.y / CHUNK_SIZEY));
    // Godot::print(String("-> ") + String(chunk_position));
    // Godot::print("b4");
    return chunk_position;
}

int ChunkManager::get_chunk_id(Vector2 cell_position) {
    // Godot::print(String("cell_position: ") + String(cell_position));
    Vector2 chunk_pos = get_chunk_position(cell_position);

    return int(chunk_pos.x + chunk_pos.y * MAX_CHUNKS_SIZE_WIDTH);
}

Ref<Cell> ChunkManager::get_cellv(Vector2 cell_position) {
    int chunk_id = get_chunk_id(cell_position);

    if (chunk_id >= int(chunks.size())) {
        Godot::print(String("Not enough chunks for id: ") + String::num(chunk_id));
		return Ref<Cell>();
    }

    Chunk* chunk = chunks[chunk_id];

    assertm(chunk != nullptr, "chunk is null!");

    if (!chunk->filled) {
        // Godot::print(String("filling chunk get_cellv: ") + String::num(chunk_id));
        chunk->fill();
        chunk->update();
    }

    Vector2 cell_in_chunk_position = {
        static_cast<real_t>(int(cell_position.x) % int(CHUNK_SIZEX)),
        static_cast<real_t>(int(cell_position.y) % int(CHUNK_SIZEY))
    };

    return chunk->get_cell_by_position(cell_in_chunk_position);
}

int ChunkManager::set_cellv(Vector2 cell_position, Ref<Cell> cell) {
    int chunk_id = get_chunk_id(cell_position);
    if (chunk_id >= chunks.size()) {
        Godot::print(String("Not enough chunks for id: ") + String::num(chunk_id));
		return -1;
    }

    Chunk* chunk = chunks[chunk_id];

    Vector2 cell_in_chunk_position = {
        static_cast<real_t>(int(cell_position.x) % int(CHUNK_SIZEX)),
        static_cast<real_t>(int(cell_position.y) % int(CHUNK_SIZEY))
    };
    
    if (!chunk->filled) {
        // Godot::print(String("filling chunk set_cellv: ") + String::num(chunk_id));
        chunk->fill();
        chunk->update();
    }

    chunk->set_cellv(cell_in_chunk_position, cell);

    return chunk_id;
}


void ChunkManager::set_draw_range(Vector2 offset, int width, int height) {
    this->draw_offset = offset;
    this->draw_width = width;
    this->draw_height = height;
}

Vector2 ChunkManager::chunk_id_to_chunk_pos(int chunk_id) {
    Vector2 chunk_position{};
    chunk_position.x = (real_t)static_cast<int>(chunk_id % (int)MAX_CHUNKS_SIZE_WIDTH);
    chunk_position.y = (real_t)static_cast<int>(chunk_id / MAX_CHUNKS_SIZE_WIDTH);
    return chunk_position; 
}

