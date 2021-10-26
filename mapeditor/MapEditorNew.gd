extends Node
"""
Some info:
	Stronghold crusader HD (Steam Edition) uses
		~60  tiles in width when zoomed in
		~120 tiles in width when zoomed out
	with tiles being 32/16
	
	32px * 60 (tiles) => 1920px
	
	we currently use tiles with 64px width (2 * 32px)
	
	So in order to get the same window frame as in stronghold we need
	1920 * 2 pixels in width -> 3840px for the standard zoom in stronghold
	
	currently we use 1280 px width in window mode for development
	which means 1280px / 64px = 20, so we need to zoom out 3x (for the 60 tiles in standard view)
	
	Also Stronghold maps use <><><><> counting (2 lines)
							  <><><><>
	while we use <><><><><> (single line)
"""


onready var preview = $Preview

onready var astar_tilemap = $AStarMap
onready var map_manager = $MapManager

onready var brush_size_box = find_node("BrushSize")

var selected_tile = 18
var brush_size = 1


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
	#DebugOverlay.track_func(self, "", "Zoom: ")
	
	###############
	# init
	###############
	brush_size_box.text = str(brush_size)
	
	#create_example_map(Global.CHUNK_SIZE)
	#create_example_map(Vector2(Global.CHUNK_SIZE.x * 3, Global.CHUNK_SIZE.y * 3))
	
	brush_draw_rect(400, 400)
	
	return
	
	create_example_map(Vector2(Global.CHUNK_SIZE.x * 10, Global.CHUNK_SIZE.y * 10))
	
	save_to_file("map_editor_test_save.txt")
	
	print("#".repeat(30))
	
	print("Cells:")
	for cell in CellManager.cells:
		print(cell, " - ", CellManager.cells[cell])
	
	print("-".repeat(15))
	
	print("Tilesets:")
	for tileset in TilesetManager.tilesets:
		print(tileset, " - ", TilesetManager.tilesets[tileset])
	
	print("#".repeat(30))
	
	load_from_file("map_editor_test_save.txt")


func brush_draw_rect(width, height):
	var offset = Vector2(0, width)
	for y in range(height):
		for x in range(width):
			if x % 20 == 0:
				continue
			map_manager.set_cell_data(offset.x + x + y, offset.y + -x + y, "base_grass")
			map_manager.set_cell_data(offset.x + x + y + 1, offset.y + -x + y, "base_grass")


func _unhandled_input(event):
	if Input.is_action_pressed("mouse_left"):
		var mp = map_manager.get_global_mouse_position()
		mp = Global.world_to_isotile(mp)
		var radius = brush_size
		for yi in range(radius):
			var y = yi - radius/2
			for xi in range(radius):
				var x = xi - radius/2
				map_manager.set_cellv(Vector2(mp.x + x, mp.y + y), selected_tile, Vector2(0, -100))
		return


func _process(delta: float) -> void:
	#print(_chunks.size() * Global.CHUNK_SIZE * Global.CHUNK_SIZE)
	var mp = map_manager.get_global_mouse_position()
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
	
	var file = File.new()
	
	file.open(file_path, File.READ)
	
	var content = JSON.parse(file.get_as_text()).result
	
	file.close()
	
	for chunk in content.chunks:
		for cell in content.chunks[chunk]:
			var pos = str2var(cell)
			var data = content.chunks[chunk][cell]
			map_manager.set_cell_data(pos.x, pos.y, data.tile_name)


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
			
			map_manager.set_cell_data(x, y, "base_grass")
	
	Global.get_time(name, "creating map took: ")




##################################################################
# Debug
##################################################################


func get_current_cell_mouse():
	var mp = map_manager.get_global_mouse_position()
	return TileMapUtils.world_to_map(Vector2(mp.x, mp.y))


func get_current_chunk_cell_mouse():
	var mp = map_manager.get_global_mouse_position()
	var mp_cell = TileMapUtils.world_to_map(Vector2(mp.x, mp.y))
	return TileMapUtils.chunk_cell_to_1D(mp_cell.x, mp_cell.y)


func get_current_chunk_mouse():
	var mp = map_manager.get_global_mouse_position()
	var mp_cell = TileMapUtils.world_to_map(Vector2(mp.x, mp.y))
	return TileMapUtils.chunk_cell_to_chunk_pos(mp_cell.x, mp_cell.y)


func _on_Button_pressed():
	selected_tile = 19


func _on_Button2_pressed():
	selected_tile = 18


func _on_BrushSize_text_changed(new_text):
	brush_size = int(new_text)
	brush_size_box.text = str(brush_size)
	brush_size_box.caret_position = str(brush_size).length()



func _on_BrushRect_pressed():
	pass # Replace with function body.


func _on_BrushSquare_pressed():
	pass # Replace with function body.
