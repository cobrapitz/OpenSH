extends Node
"""
This holds the data to all cells.
The dictionary data structure makes it easy to modify it externally.

Textures will be assigned by the mod loader.
"""


const TILE_SIZES = 4

const SMALL = 0
const MEDIUM = 1
const BIG = 2
const LARGE = 3

var cells := {}



func get_cell_data(cell_id):
	match cells[cell_id].type:
		"tree":
			return cells[cell_id]
		"cell":
			return cells[cell_id]
	
	if typeof(cells[cell_id]) == TYPE_ARRAY:
		return cells[cell_id][Global.get_pseudo_random() % cells[cell_id].size()]
	else:
		return cells[cell_id]


func get_cell_size(cell_id, cell_type = SMALL):
	return Vector2(
			cells[cell_id].ground_texture_data.values()[cell_type].cell_width, 
			cells[cell_id].ground_texture_data.values()[cell_type].cell_height)


func get_cell_region(cell_id, offset = Vector2.ZERO, cell_type = SMALL):
	match cells[cell_id].type:
		"tile":
			var texture_regions = get_ground_tile_region(cell_id, cell_type)
			return texture_regions[Global.get_pseudo_random() % texture_regions.size()]
		_:
			print("Invalid Resource type: ", cells[cell_id].type)


func get_cell_texture_name(cell_id, cell_type = SMALL):
	return cells[cell_id].ground_texture_data.values()[cell_type].texture


func get_ground_tile_region(cell_id, cell_type = SMALL):
	var texture_regions = cells[cell_id].ground_texture_data.values()[cell_type].regions
	return texture_regions


func get_cell_texture_with_shadows(cell_id, shadow=0):
	var texture_regions = cells[cell_id].ground_texture_data.texture_regions
	return texture_regions[texture_regions.keys()[shadow]]


func has_shadow_enabled(cell_id) -> bool:
	return "shadow_enabled" in cells[cell_id] and cells[cell_id].shadow_enabled


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
				cells[mod_name+key] = {
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
							cells[mod_name+key].ground_texture_data[texture_key].regions.append(
								[x * width, y * height, width, height]
							)
				
#				for region_key in range(data.ground_texture_data.texture_regions):
#					cells[mod_name+key].ground_texture_data.texture = \
#							mod_name + cells[mod_name+key].ground_texture_data.regions
#
#					cells[mod_name+key].chevrons_data.texture = \
#							mod_name + cells[mod_name+key].chevrons_data.texture
				
#				for region_rect in content[key].regions:
#					cells[mod_name+key].append({
#						"region_rect": region_rect,
#						"texture": mod_name + content[key].texture,
#						"chevron_texture": mod_name + content[key].chevron_texture,
#					})
#		continue
#		if "regions" in content[key]:
#			cells[mod_name+key] = []
#			for region_rect in content[key].regions:
#				cells[mod_name+key].append({
#					"region_rect": region_rect,
#					"texture": mod_name + content[key].texture
#				})
#		else:
#			cells[mod_name+key] = {}
#			cells[mod_name+key].region_rect = content[key].region_rect
#			cells[mod_name+key].texture = mod_name + content[key].texture
