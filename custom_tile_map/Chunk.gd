extends YSort
class_name Chunk

const Cell : Resource = preload("res://custom_tile_map/Cell.tres")


var chunk_position: Vector2
var chunk_id: int
var cells : Array

var _to_draw = []
var _drawn = []


func _init():
	cells.resize(int(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y))
	connect("visibility_changed", self, "_on_visibility_changed")


func _draw():
	for cell in cells:
		if cell == null:
			continue
		cell.visible = true
		draw_texture_rect_region(
			cell.texture, Rect2(cell.position + cell.offset, cell.size),
			cell.texture_region_rect)


func _on_visibility_changed():
	if visible:
		pass
	else:
		for idx in range(cells.size()):
			if cells[idx] == null:
				continue
			cells[idx].visible = false


func get_cell_idv(cell_position: Vector2):
	return int(cell_position.x + cell_position.y * Global.CHUNK_SIZE.x)


func get_cell_by_position(cell_position: Vector2):
	return cells[get_cell_idv(cell_position)]


func get_cell_idx(idx: int):
	return cells[idx]


func set_cellv(cell_position: Vector2, cell):
	cells[get_cell_idv(cell_position)] = cell


func get_cellv(cell_position: Vector2):
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	return cell_position



######################################################
# SAVE/LOAD
######################################################

func get_save_data():
	var data = {}
	
	for cell in cells:
		if cell == null:
			continue
		data[var2str(get_cellv(TileMapUtils.world_to_map(cell.position)))] = {
			#"visible": cell.visible,
			"position": var2str(cell.position),
			#"size": var2str(cell.size), # probably don't need
			#"region_rect": var2str(cell.texture_region_rect), # probably don't need
			"tile_name": cell.tile_name,
			"offset": var2str(cell.offset),
		}
	
	return data


func load_save_data(data: Dictionary):
	cells.resize(int(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y))
	
	for cell_map_position in data.keys():
		var cell_data = data[cell_map_position]
		
		var cell_pos = str2var(cell_data.position)
		cell_pos = TileMapUtils.world_to_map(cell_pos)
		var cell_offset = str2var(cell_data.offset)
		var cell_chunk_pos = str2var(cell_map_position)
		
		var cell = _create_cell(
				cell_pos.x, cell_pos.y, 
				cell_data.tile_name, cell_offset)
		
		set_cellv(cell_chunk_pos, cell)
	


func _create_cell(cell_x: int, cell_y: int, tile_name: String, offset: Vector2 = Vector2.ZERO):
	var cell = Cell.duplicate()
	cell.visible = false
	cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
	cell.position.x -= Global.CELL_SIZE.x / 2
	
	var cell_data = CellManager.cells[tile_name]
	cell.texture = TilesetManager.tilesets[cell_data.tileset].texture
	cell.tile_name = tile_name
	cell.size = Vector2(cell_data.region_rect[2], cell_data.region_rect[3])#Vector2(64, 124)
	cell.texture_region_rect = Rect2(
		cell_data.region_rect[0], cell_data.region_rect[1],
		cell_data.region_rect[2], cell_data.region_rect[3])
	return cell



######################################################

func get_single_row(row_i: int):
	var tiles = []
	
	var x = row_i
	var y = row_i
	for i in range(Global.CHUNK_SIZE.x):
		if i % 2 == 0:
			x += 1
		else:
			y -= 1
		tiles.append(Vector2(x, y))
		
	return tiles
