extends Node2D


var _cells = []

func _ready():
	hide()
	set_process(false)
	z_index = 500


func _process(delta: float) -> void:
	global_position = Global.get_mouse_center_isometric()


# e.g.: [(0, 0), (1, 0), (0, 1), (1, 1)]
func enable(cells : Array):
	if cells.empty():
		return
	
	for child in get_children():
		child.queue_free()
	
	_cells.clear()
	
	for cell in cells:
		_place_preview_tile(cell)
	
	set_process(true)
	show()


func calculate_cell_positions_for_building(cell_placements : Array):
	var cells = []
	
	for cell_offset in cell_placements:
		var marker_position = Vector2.ZERO
		marker_position.x = (cell_offset.x - cell_offset.y) * Global.CELL_SIZE.x * 0.5
		marker_position.y = (cell_offset.x + cell_offset.y) * Global.CELL_SIZE.y * 0.5 
		cells.append(marker_position)
	return cells


func _create_preview_tile() -> Sprite:
	var tile = Sprite.new()
	tile.texture = preload("res://resources/marker.png")
	return tile


func _place_preview_tile(cell_offset):
	var preview_tile = _create_preview_tile()
	add_child(preview_tile)
	
	var marker_position = Vector2.ZERO 
	
	marker_position.x = (cell_offset.x - cell_offset.y) * Global.CELL_SIZE.x * 0.5
	marker_position.y = (cell_offset.x + cell_offset.y) * Global.CELL_SIZE.y * 0.5 
	_cells.append(marker_position)
	marker_position.y += Global.CELL_SIZE.y * 0.5 # offset
	
	preview_tile.position = marker_position


func disable():
	hide()
	set_process(false)
	for child in get_children():
		child.queue_free()


func get_cells() -> Array:
	return _cells
