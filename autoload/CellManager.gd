extends Node
"""
This holds the data to all cells.
The dictionary data structure makes it easy to modify it externally.

Textures will be assigned by the mod loader.
"""



const Cell : Resource = preload("res://custom_tile_map/Cell.tres")

const TILE_SIZES = 4

const SMALL = 0
const MEDIUM = 1
const BIG = 2
const LARGE = 3

var cells_data := {}


class CellData:
	var position: Vector2
	var visible: bool
	var size: Vector2
	var tile_type: int
	var offset: Vector2
	
	var texture_rect: Rect2
	var chevron_rect: Rect2
	
	var tile_name: String
	var texture#_id#: String
	var chevron_id: String

enum {
	XPos, YPos,
	Visible,
	TileType,
	Off,
	SizeX, SizeY,
	TRectX, TRectY, TRectW, TRectH,
	TOffX, TOffY,

	ChevRectX, ChevRectY, ChevRectW, ChevRectH,

	TextureId,
	ChevronId,
	TileId,
}




func create_cell(cell_x: int, cell_y: int, tile_name: String, offset: Vector2 = Vector2.ZERO):
	var region_rect = CellManager.get_cell_region(tile_name, offset)
	
	var cell = [
		cell_x, cell_y,
		true,
		-1,
		Vector2.ZERO,
		get_cell_width(tile_name), get_cell_height(tile_name),
		region_rect[0], region_rect[1], region_rect[2], region_rect[3],
		0, 0,
		region_rect[0], region_rect[1], region_rect[2], region_rect[3],
		0, 0,
		CellManager.get_cell_texture_name(tile_name),
		CellManager.get_cell_texture_name(tile_name),
		tile_name,
	]
	#created_cells += 1
#	cell.tile_name = tile_name
#	cell.visible = true
#	cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
#	cell.position.x -= Global.CELL_SIZE.x / 2
#	cell.tile_type = -1
#
#	if offset.y == 0:
#		var cell_texture = CellManager.get_cell_texture_name(tile_name)
#		cell.texture = TilesetManager.get_tileset_texture(cell_texture)
#		cell.size = CellManager.get_cell_size(tile_name)
#		cell.texture_rect = Rect2(
#			region_rect[0], region_rect[1],
#			region_rect[2], region_rect[3])
#	else:
#		print("no height implemented!")
	return cell

	
func _change_cell(cell, tile_name: String, offset:= Vector2.ZERO, tile_type = CellManager.SMALL):
	var cell_texture = CellManager.get_cell_texture_name(tile_name, tile_type)
	cell.texture = TilesetManager.get_tileset_texture(cell_texture)
	cell.tile_name = tile_name
	cell.visible = true
	cell.offset = offset
	cell.tile_type = tile_type
	cell.size = CellManager.get_cell_size(tile_name, tile_type)
	cell.tile_offset = CellManager.get_cell_offset(tile_type)
	var region_rect = CellManager.get_cell_region(tile_name, offset, tile_type)
	cell.texture_region_rect = Rect2(
		region_rect[0], region_rect[1],
		region_rect[2], region_rect[3])


func _create_cell(cell_x: int, cell_y: int, tile_name: String, 
		offset: Vector2 = Vector2.ZERO, tile_type = CellManager.SMALL):
	var cell = Cell.duplicate()
	
	cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
	cell.position.x -= Global.CELL_SIZE.x / 2
	cell.cell_position = Vector2(cell_x, cell_y)
	
	_change_cell(cell, tile_name, offset, tile_type)
	
	return cell


func get_cell_offset(tile_type: int) -> Vector2:
	match tile_type:
		0:
			return Vector2(0, 0)
		1:
			return Vector2(-16, -9)
		2:
			return Vector2(-33, -17)
		3:
			return Vector2(-48, -23)
	
	assert(false, "NO offset for type")
	return Vector2.ZERO


func get_cell_data(cell_id):
	match cells_data[cell_id].type:
		"tree":
			return cells_data[cell_id]
		"cell":
			return cells_data[cell_id]
	
	if typeof(cells_data[cell_id]) == TYPE_ARRAY:
		return cells_data[cell_id][Global.get_pseudo_random() % cells_data[cell_id].size()]
	else:
		return cells_data[cell_id]


func get_cell_size(cell_id, cell_type = SMALL):
	return Vector2(
			cells_data[cell_id].ground_texture_data.values()[cell_type].cell_width, 
			cells_data[cell_id].ground_texture_data.values()[cell_type].cell_height)


func get_cell_width(cell_id, cell_type = SMALL):
	return cells_data[cell_id].ground_texture_data.values()[cell_type].cell_width


func get_cell_height(cell_id, cell_type = SMALL):
	return cells_data[cell_id].ground_texture_data.values()[cell_type].cell_height


func get_cell_region(cell_id, offset = Vector2.ZERO, cell_type = SMALL):
	match cells_data[cell_id].type:
		"tile":
			var texture_regions = get_ground_tile_region(cell_id, cell_type)
			return texture_regions[Global.get_pseudo_random() % texture_regions.size()]
		_:
			print("Invalid Resource type: ", cells_data[cell_id].type)


func get_cell_texture_name(cell_id, cell_type = SMALL):
	return cells_data[cell_id].ground_texture_data.values()[cell_type].texture


func get_ground_tile_region(cell_id, cell_type = SMALL):
	var texture_regions = cells_data[cell_id].ground_texture_data.values()[cell_type].regions
	return texture_regions


func get_cell_texture_with_shadows(cell_id, shadow=0):
	var texture_regions = cells_data[cell_id].ground_texture_data.texture_regions
	return texture_regions[texture_regions.keys()[shadow]]


func has_shadow_enabled(cell_id) -> bool:
	return "shadow_enabled" in cells_data[cell_id] and cells_data[cell_id].shadow_enabled


func load_cells(mod_name: String, cells_path: String):
	var file = File.new()
	
	if file.open(cells_path, File.READ) != OK:
		printerr("Couldn't load cell path file: ", cells_path)
		return
	
	var content = JSON.parse(file.get_as_text())
	
	if content.error != OK:
		printerr("Couldn't read cell path file: ", cells_path)
		return
	
	content = content.result
	
	for key in content.keys():
		match content[key].type:
			"tree":
				pass
			"tile":
				var data = content[key]
				cells_data[mod_name+key] = {
					"mod_name": mod_name,
					"type": data.type,
					"variant": data.variant,
					"height_enabled": data.height_chevrons_enabled,
					"chevrons": data.chevrons,
					"hills": data.hills,
					"ground_texture_data": {
						"small": {
							"cell_width": data.ground_textures.small.cell_size[0],
							"cell_height": data.ground_textures.small.cell_size[1],
							"texture": mod_name + data.ground_textures.small.texture,
							"regions": [],
						},
						"medium": {
							"cell_width": data.ground_textures.medium.cell_size[0],
							"cell_height": data.ground_textures.medium.cell_size[1],
							"texture": mod_name + data.ground_textures.medium.texture,
							"regions": [],
						},
						"big": {
							"cell_width": data.ground_textures.big.cell_size[0],
							"cell_height": data.ground_textures.big.cell_size[1],
							"texture": mod_name + data.ground_textures.big.texture,
							"regions": [],
						},
						"large": {
							"cell_width": data.ground_textures.large.cell_size[0],
							"cell_height": data.ground_textures.large.cell_size[1],
							"texture": mod_name + data.ground_textures.large.texture,
							"regions": [],
						},
					},
				}
				
				for texture_key in data.ground_textures:
					var texture_data = data.ground_textures[texture_key]
					
					var width = data.ground_textures[texture_key].cell_size[0]
					var height = data.ground_textures[texture_key].cell_size[1]
					
					var start_x = data.ground_textures[texture_key].start[0]
					var start_y = data.ground_textures[texture_key].start[1]
					var end_x = data.ground_textures[texture_key].end[0]
					var end_y = data.ground_textures[texture_key].end[1]
					
					for x in range(start_x, end_x):
						for y in range(start_y, end_y):
							cells_data[mod_name+key].ground_texture_data[texture_key].regions.append(
								[x * width, y * height, width, height]
							)
				
#				for region_key in range(data.ground_texture_data.texture_regions):
#					cells_data[mod_name+key].ground_texture_data.texture = \
#							mod_name + cells_data[mod_name+key].ground_texture_data.regions
#
#					cells_data[mod_name+key].chevrons_data.texture = \
#							mod_name + cells_data[mod_name+key].chevrons_data.texture
				
#				for region_rect in content[key].regions:
#					cells_data[mod_name+key].append({
#						"region_rect": region_rect,
#						"texture": mod_name + content[key].texture,
#						"chevron_texture": mod_name + content[key].chevron_texture,
#					})
#		continue
#		if "regions" in content[key]:
#			cells_data[mod_name+key] = []
#			for region_rect in content[key].regions:
#				cells_data[mod_name+key].append({
#					"region_rect": region_rect,
#					"texture": mod_name + content[key].texture
#				})
#		else:
#			cells_data[mod_name+key] = {}
#			cells_data[mod_name+key].region_rect = content[key].region_rect
#			cells_data[mod_name+key].texture = mod_name + content[key].texture
