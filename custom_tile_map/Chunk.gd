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
	var cell
	for idx in _to_draw:
		cell = cells[idx]
		draw_texture_rect_region(cell.texture, Rect2(cell.position + cell.offset, cell.size), cell.region_rect)
	_to_draw.clear()


func _on_visibility_changed():
	if visible:
		for idx in range(cells.size()):
			if cells[idx] != null:
				_to_draw.append(idx)


func get_cell_idv(cell_position: Vector2):
	return int(cell_position.x + cell_position.y * Global.CHUNK_SIZE.x)


func set_cellv(cell_position: Vector2, cell):
	cells[get_cell_idv(cell_position)] = cell
	_to_draw.append(get_cell_idv(cell_position))







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
