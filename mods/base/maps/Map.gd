extends YSort


onready var tile_map_ground = $Ground

onready var cell_map = $CellMap


func _ready():
	var i = 0
	var cells = 0
	for child in get_children():
		i += 1
		if child.name.begins_with("Ground"):
			cells += child.get_used_cells().size()
			
		child.global_position.y += i
	
	print("cells used: ", cells)


func get_ground_tilemap() -> TileMap:
	return tile_map_ground


func get_cell_size() -> Vector2:
	return tile_map_ground.get_cell_size()



