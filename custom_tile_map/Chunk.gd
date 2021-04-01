extends YSort
class_name Chunk


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
		if cell == null or cell.visible:
			continue
		cell.visible = true
		draw_texture_rect_region(cell.texture, Rect2(cell.position + cell.offset, cell.size), cell.texture_region_rect)


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


######################################################
# SAVE/LOAD
######################################################
#export(bool) var visible
#export(Vector2) var position
#export(Vector2) var size
#export(Rect2) var region_rect
#export(Texture) var texture
#export(Vector2) var offset

func get_save_data():
	var data = {}
	
	var idx = 0
	for cell in cells:
		if cell == null:
			continue
		data[idx] = {
			"visible": cell.visible,
			"position": cell.position,
			"size": cell.size,
			"region_rect": cell.region_rect,
			"texture": cell.texture,
			"offset": cell.offset,
		}
	
	return data


func load_save_data(data: Dictionary):
	for idx in data.keys():
		var cell = data[idx]
		
		
		


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
