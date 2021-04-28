extends Node2D


onready var preview = $Preview

onready var astar_tilemap = $AStarMap
onready var map_manager = $MapManager

var selected_tile = 18


func _ready():
	#create_example_map(Vector2(50, 50))
	#_update_used_rect(cell)
	#_update_pathfinding()
	#_init_map()
	preview.modulate.a = 0.5
	
	DebugOverlay.track_func(Engine, "get_frames_per_second", "FPS: ")
	DebugOverlay.track_func(self, "get_current_cell_mouse", "Mouse Position: ")
	DebugOverlay.track_func(self, "get_current_chunk_cell_mouse", "Chunk Cell Position: ")
	DebugOverlay.track_func(self, "get_current_chunk_mouse", "Chunk: ")
	
	#create_example_map(Global.CHUNK_SIZE)
	#create_example_map(Vector2(Global.CHUNK_SIZE.x * 3, Global.CHUNK_SIZE.y * 3))
	create_example_map(Vector2(Global.CHUNK_SIZE.x * 5, Global.CHUNK_SIZE.y * 5))
	
	save_to_file("map_editor_test_save.txt")


func _unhandled_input(event):
	if Input.is_action_pressed("mouse_left"):
		var mp = get_global_mouse_position()
		mp = Global.world_to_isotile(mp)
		var radius = 1
		for y in range(radius):
			for x in range(radius):
				map_manager.set_cellv(Vector2(mp.x + x, mp.y + y), selected_tile, Vector2(0, -100))
		return


func _process(delta: float) -> void:
	#print(_chunks.size() * Global.CHUNK_SIZE * Global.CHUNK_SIZE)
	var mp = get_global_mouse_position()
	preview.global_position = TileMapUtils.map_to_world(TileMapUtils.world_to_map(Vector2(mp.x, mp.y)))


##################################################################
# Save/Load
##################################################################

func save_to_file(file_path: String):
	print("#".repeat(30))
	print("saving file: ", file_path)
	var file = File.new()
	
	file.open(file_path, File.WRITE)
	
	file.store_string(JSON.print(map_manager.get_save_data()))
	
	file.close()
	print("saved file: ", file_path)
	


func load_from_file(file_path: String):
	print(name, " loading data: ", file_path)



##################################################################
# Cell placement
##################################################################


func set_cell_world(world_x: float, world_y: float, cell_id: float, offset: Vector2 = Vector2()):
	var cell_position = TileMapUtils.world_to_map(Vector2(world_x, world_y))
	map_manager.set_cellv(cell_position, cell_id, offset)


func create_example_map(new_mapsize : Vector2):
	Global.set_timer(name)
	
	for x in range(new_mapsize.x):
		for y in range(new_mapsize.y):
			map_manager.set_cell((x), (y), selected_tile)
	
	Global.get_time(name, "creating map took: ")




##################################################################
# Debug
##################################################################


func get_current_cell_mouse():
	var mp = get_global_mouse_position()
	return TileMapUtils.world_to_map(Vector2(mp.x, mp.y))


func get_current_chunk_cell_mouse():
	var mp = get_global_mouse_position()
	var mp_cell = TileMapUtils.world_to_map(Vector2(mp.x, mp.y))
	return TileMapUtils.chunk_cell_to_1D(mp_cell.x, mp_cell.y)


func get_current_chunk_mouse():
	var mp = get_global_mouse_position()
	var mp_cell = TileMapUtils.world_to_map(Vector2(mp.x, mp.y))
	return TileMapUtils.chunk_cell_to_chunk_pos(mp_cell.x, mp_cell.y)


func _on_Button_pressed():
	selected_tile = 19


func _on_Button2_pressed():
	selected_tile = 18
