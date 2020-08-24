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
	#test_performance_many_sprites()


func test_performance_many_sprites():
	
	var mapsize = Vector2(100, 400)
	
	for x in range(mapsize.x):
		for y in range(mapsize.y):
			var test_tile = $TestTile.duplicate()
			cell_map.add_child(test_tile)
			test_tile.global_position = Vector2(x * 32, y * 32) 
			#test_tile.global_position = Vector2(randi() % 1000, randi() % 1000) 


func get_ground_tilemap() -> TileMap:
	return tile_map_ground


func get_cell_size() -> Vector2:
	return tile_map_ground.get_cell_size()



