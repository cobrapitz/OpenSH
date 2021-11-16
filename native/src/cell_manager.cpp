#include "cell_manager.h"

#include <File.hpp>
#include <JSON.hpp>
#include <JSONParseResult.hpp>
#include <Dictionary.hpp>
#include <Array.hpp>

#include "common.h"
#include "tileset_manager.h"
#include "tile_map_utils.h"
#include "cell.h"
#include "helper.h"

using namespace godot;


const unsigned int SMALL = 0;
const unsigned int MEDIUM = 1;
const unsigned int BIG = 2;
const unsigned int LARGE = 3;
const unsigned int CELL_SIZES = 4;


void CellManager::_register_methods() {
    register_method("_init", &CellManager::_init);
    register_method("_ready", &CellManager::_ready);

    
}

CellManager::CellManager() {
    
}

CellManager::~CellManager() {
    
}

void CellManager::_init() {
    
}

void CellManager::_ready() {
	auto tileset_manager_node = get_node("/root/TilesetManager");
    tileset_manager = Object::cast_to<TilesetManager>(tileset_manager_node); // Cast will get validated and return `null` in case is invalid
    CRASH_COND(tileset_manager == nullptr);
}

void CellManager::load_cells(String mod_name, String cells_path) {
	auto file = File::_new();
	if (file->open(cells_path, File::READ) != Error::OK) {
		GODOT_PRINT_ERROR(("Couldn't load cell path file: " + cells_path).alloc_c_string());
		return;
	}

	auto content = JSON::get_singleton()->parse(file->get_as_text());
	file->close();
	if (content->get_error() != Error::OK) {
		GODOT_PRINT_ERROR(("Couldn't read cell path file: ", cells_path).alloc_c_string());
		return;
	}

	auto result = content->get_result();

    if (result.get_type() != Variant::Type::DICTIONARY) {
        GODOT_PRINT_ERROR(("Read tileset is no Dictionary: " + cells_path).alloc_c_string());
        return;
    }

	auto dict = result.operator godot::Dictionary(); 

	for (int i = 0; i < dict.keys().size(); i++) {
		String key = dict.keys()[i];
		Dictionary data = dict[key];
		String type = data["type"];

		//Godot::print("loading " + type + " -> " + mod_name + key);

		if (type == "chevron") {
			auto chevron_data = ChevronData{};
			
			chevron_data.mod_name = mod_name;
			chevron_data.type = type;
			chevron_data.variant = data["variant"];
			chevron_data.cell_width = data["cell_width"];
			chevron_data.cell_height = data["cell_height"];
			chevron_data.texture_name = mod_name + data["texture"];
			chevron_data.cell_size = Vector2{(real_t)chevron_data.cell_width, (real_t)chevron_data.cell_height};

			auto texture_regions = (Dictionary) data["texture_regions"];

			auto start_arr = (Array) texture_regions["start"]; 
			auto end_arr = (Array) texture_regions["end"];

			auto start_x = int(start_arr[0]);
			auto start_y = int(start_arr[1]);
			auto end_x = int(end_arr[0]);
			auto end_y = int(end_arr[1]);

			for (int x = start_x; x < end_x; x++) {
				for (int y = start_y; y < end_y; y++) {
					chevron_data.regions.push_back(
						Rect2{
							(real_t)x * chevron_data.cell_size.x, (real_t)y * chevron_data.cell_size.y, 
							chevron_data.cell_size.x, chevron_data.cell_size.y
					});
				}	
			}
			chevrons.insert(std::make_pair(mod_name+key, chevron_data));

		} else if (type == "tile") {
			auto cell_data = CellData{};
			
			cell_data.mod_name = mod_name;
			cell_data.type = data["type"];
			cell_data.variant = data["variant"];
			cell_data.height_enabled = data["height_chevrons_enabled"];
			cell_data.chevrons = data["chevrons"];
			cell_data.hills = data["hills"];

			auto cell_types = (Dictionary) data["ground_textures"];

			for (int ci = 0; ci < CellManager::CELL_SIZES; ci++) {
				String cell_type = cell_types.keys()[ci];
				int cell_type_index = -1;
				if (cell_type == "small") {
					cell_type_index = 0;
				} else if (cell_type == "medium") {
					cell_type_index = 1;
				} else if (cell_type == "big") {
					cell_type_index = 2;
				} else if (cell_type == "large") {
					cell_type_index = 3;
				} else {
					assertm(false, "Couldn't find cell type!");
				}

				Dictionary cell_type_data = cell_types[cell_type];

				auto type_data = CellTypeData{};
				auto cell_size_arr = (Array)cell_type_data["cell_size"];
				auto cell_size = Vector2{cell_size_arr[0], cell_size_arr[1]};
				type_data.cell_width = (int)cell_size.x;
				type_data.cell_height = (int)cell_size.y;
				type_data.texture_name = mod_name + cell_type_data["texture"];
				type_data.cell_size = cell_size;

				auto start_arr = (Array) cell_type_data["start"]; 
				auto end_arr = (Array) cell_type_data["end"];

				auto start_x = int(start_arr[0]);
				auto start_y = int(start_arr[1]);
				auto end_x = int(end_arr[0]);
				auto end_y = int(end_arr[1]);

				for (int x = start_x; x < end_x; x++) {
					for (int y = start_y; y < end_y; y++) {
						type_data.regions.push_back(
							Rect2{
								(real_t)x * cell_size.x, (real_t)y * cell_size.y, 
								cell_size.x, cell_size.y
						});
					}	
				}
				cell_data.ground_texture_data[cell_type_index] = type_data;
			}
			cells.insert(std::make_pair(mod_name + key, cell_data));
		}
	}
}

void CellManager::change_cell(sh::Cell* cell, String tile_name, Vector2 offset, CellType cell_type) {
	cell->tile_name = tile_name;
	cell->tile_type = cell_type;
	cell->visible = true;
	cell->offset = offset;
	cell->size = get_cell_size(tile_name, cell_type);

    String cell_texture_name = get_cell_texture_name(tile_name, cell_type);
    cell->texture = tileset_manager->get_tileset_texture(cell_texture_name);
	cell->tile_offset = get_cell_offset(cell_type);
	cell->texture_region_rect = get_cell_region(tile_name, offset, cell_type);
	
	String chevron_texture_name = get_cell_chevron_texture_name(tile_name, cell_type);
	cell->chevron = tileset_manager->get_tileset_texture(chevron_texture_name);
	cell->chevron_region_rect = get_chevron_region(chevron_texture_name, offset, cell_type);
}

sh::Cell* CellManager::create_cell(int cell_x, int cell_y, String tile_name, Vector2 offset, CellType cell_type) {
	auto cell = new sh::Cell{};
	cell->position = sh::TileMapUtils::get_singleton()->map_to_world(Vector2{(real_t)cell_x, (real_t)cell_y});
	cell->position.x -= CELL_SIZE.x / 2.f;
	cell->cell_position = Vector2{(real_t)cell_x, (real_t)cell_y};
	cell->cell_ref = nullptr;
	
	change_cell(cell, tile_name, offset, cell_type);
	return cell;
}

Vector2 CellManager::get_cell_offset(CellType cell_type) {
	switch (cell_type) {
		case SMALL:
			return Vector2{0, 0};
		case MEDIUM:
			return Vector2{-16, -9};
		case BIG:
			return Vector2{-33, -17};
		case LARGE:
			return Vector2{-48, -23};
		default:
			assertm(false, "Celltype not found!");
			break;
	}
	return Vector2::ZERO;
}

int CellManager::get_cell_height(CellID cell_id, CellType cell_type) {
	return cells[cell_id].ground_texture_data[cell_type].cell_height;
}


const Rect2& CellManager::get_cell_region(CellID cell_id, Vector2 offset , CellType cell_type) {
	const String& type = cells[cell_id].type;

	if (type == "tile") {
		return get_ground_cell_region(cell_id, cell_type);
	}

	assertm(false, "Tile type not found!");
}

const Vector2& CellManager::get_cell_size(CellID cell_id, CellType cell_type) {
	return cells[cell_id].ground_texture_data[cell_type].cell_size;
}

const String& CellManager::get_cell_texture_name(CellID cell_id, CellType cell_type) {
	return cells[cell_id].ground_texture_data[cell_type].texture_name;
}

const Rect2& CellManager::get_chevron_region(CellID chevron_id, Vector2 offset , CellType cell_type) {
	// TOOD maybe make this changeable separately in config
	static const Rect2 chevron_region = {0, 0, CELL_SIZE.x, CELL_SIZE.y};
    return chevron_region;
}

const Vector2& CellManager::get_chevron_size(CellID chevron_id, CellType cell_type) {
    return chevrons[chevron_id].cell_size;
}

const String& CellManager::get_cell_chevron_texture_name(CellID cell_id, CellType cell_type) {
	return chevrons[cells[cell_id].chevrons].texture_name;
}

const Rect2& CellManager::get_ground_cell_region(CellID cell_id, CellType cell_type) {
    return cells[cell_id].ground_texture_data[cell_type].regions[
			sh::Helper::get_singleton()->get_pseudo_random() % cells[cell_id].ground_texture_data[cell_type].regions.size()
		];
}

Rect2 CellManager::get_cell_texture_with_shadows(CellID cell_id, CellType cell_type) {
	Godot::print("Shadows not implemented yet!");
	return Rect2{};
}

bool CellManager::has_shadow_enabled(CellID cell_id) {
	Godot::print("Shadows not implemented yet!");
	return false;
    // return cells[cell_id].shadow
}


