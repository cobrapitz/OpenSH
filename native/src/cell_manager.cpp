#include "cell_manager.h"

#include <File.hpp>
#include <JSON.hpp>
#include <JSONParseResult.hpp>
#include <Dictionary.hpp>

#include "common.h"
#include "tileset_manager.h"
#include "tile_map_utils.h"
#include "cell.h"
#include "helper.h"

using namespace godot;


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
    tileset_manager = Object::cast_to<TilesetManager>(get_node("/root/TilesetManager")); // Cast will get validated and return `null` in case is invalid
    CRASH_COND(tileset_manager == nullptr);
}

void CellManager::load_cells(String mode_name, String cells_path) {
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

	Dictionary result = content->get_result();

	for (int i = 0; i < result.keys().size(); i++) {
		String key = result.keys()[i];
		Dictionary value = result[key];
		String type = value["type"];

		if (type == "chevron") {
			
		} else if (type == "tile") {
			
		}
	}
	
    

	// for key in content.keys():
	// 	match content[key].type:
	// 		"chevron":
	// 			var data = content[key]
	// 			cells_data[mod_name+key] = {
	// 				"mod_name": mod_name,
	// 				"type": data.type,
	// 				"variant": data.variant,
	// 				"cell_height": data.cell_height,
	// 				"cell_width": data.cell_width,
	// 				"texture": mod_name + data.texture,
	// 				"regions": []
	// 			}
	// 			var width = data.cell_height
	// 			var height = data.cell_width
				
	// 			var start_x = data.texture_regions.start[0]
	// 			var start_y = data.texture_regions.start[1]
	// 			var end_x = data.texture_regions.end[0]
	// 			var end_y =  data.texture_regions.end[1]
				
	// 			for x in range(start_x, end_x):
	// 				for y in range(start_y, end_y):
	// 					cells_data[mod_name+key].regions.append(
	// 						[x * width, y * height, width, height]
	// 					)
				
	// 		"tree":
	// 			pass
	// 		"tile":
	// 			var data = content[key]
	// 			cells_data[mod_name+key] = {
	// 				"mod_name": mod_name,
	// 				"type": data.type,
	// 				"variant": data.variant,
	// 				"height_enabled": data.height_chevrons_enabled,
	// 				"chevrons": data.chevrons,
	// 				"hills": data.hills,
	// 				"ground_texture_data": {
	// 					"small": {
	// 						"cell_width": data.ground_textures.small.cell_size[0],
	// 						"cell_height": data.ground_textures.small.cell_size[1],
	// 						"texture": mod_name + data.ground_textures.small.texture,
	// 						"regions": [],
	// 					},
	// 					"medium": {
	// 						"cell_width": data.ground_textures.medium.cell_size[0],
	// 						"cell_height": data.ground_textures.medium.cell_size[1],
	// 						"texture": mod_name + data.ground_textures.medium.texture,
	// 						"regions": [],
	// 					},
	// 					"big": {
	// 						"cell_width": data.ground_textures.big.cell_size[0],
	// 						"cell_height": data.ground_textures.big.cell_size[1],
	// 						"texture": mod_name + data.ground_textures.big.texture,
	// 						"regions": [],
	// 					},
	// 					"large": {
	// 						"cell_width": data.ground_textures.large.cell_size[0],
	// 						"cell_height": data.ground_textures.large.cell_size[1],
	// 						"texture": mod_name + data.ground_textures.large.texture,
	// 						"regions": [],
	// 					},
	// 				},
	// 			}
				
	// 			for texture_key in data.ground_textures:
	// 				var texture_data = data.ground_textures[texture_key]
					
	// 				var width = data.ground_textures[texture_key].cell_size[0]
	// 				var height = data.ground_textures[texture_key].cell_size[1]
					
	// 				var start_x = data.ground_textures[texture_key].start[0]
	// 				var start_y = data.ground_textures[texture_key].start[1]
	// 				var end_x = data.ground_textures[texture_key].end[0]
	// 				var end_y = data.ground_textures[texture_key].end[1]
					
	// 				for x in range(start_x, end_x):
	// 					for y in range(start_y, end_y):
	// 						cells_data[mod_name+key].ground_texture_data[texture_key].regions.append(
	// 							[x * width, y * height, width, height]
	// 						)
}

void CellManager::change_cell(Ref<Cell> cell, String tile_name, Vector2 offset , CellType cell_type) {
	cell->tile_name = tile_name;
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

Ref<Cell> CellManager::create_cell(int cell_x, int cell_y, String tile_name, Vector2 offset , CellType cell_type) {
	auto cell = Cell::_new();
	cell->position = sh::TileMapUtils::get_singleton()->map_to_world(Vector2{(real_t)cell_x, (real_t)cell_y});
	cell->position.x -= CELL_SIZE.x / 2.f;
	cell->cell_position = Vector2{(real_t)cell_x, (real_t)cell_y};
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
	} else {
		assertm(false, "Tile type not found!");
	}
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
	return chevrons[cells[cell_id].chevron].texture;
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


