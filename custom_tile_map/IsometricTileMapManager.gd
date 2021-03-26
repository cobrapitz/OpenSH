extends Node2D
class_name IsometricTileMap

#	add_astar_cell(cp)


onready var astar_tilemap = $AStarMap
onready var preview = $Preview

onready var map = $TileMaps/IsometricTileMap


func _ready():
	preview.modulate.a = 0.5
	#_update_used_rect(cell)
	#_update_pathfinding()
	#_init_map()
	pass


func _unhandled_input(event):
	if Input.is_action_pressed("mouse_left"):
		var mp = get_global_mouse_position()
		set_cell_world(\
				mp.x, \
				mp.y, 19, Vector2(0, -randf()*10.0))
		return


func _process(delta: float) -> void:
	#print(_chunks.size() * Global.CHUNK_SIZE * Global.CHUNK_SIZE)
	var mp = get_global_mouse_position()
	preview.global_position = Global.isotile_to_world(Global.world_to_isotile(mp))


func create_example_map(new_mapsize : Vector2):
	Global.set_timer(name)
	
	for x in range(new_mapsize.x):
		for y in range(new_mapsize.y):
			set_cell(x, y, 19)
	
	Global.get_time(name, "creating map took: ")


func set_cell(cell_x: int, cell_y: int, cell_id: float):
	pass


func set_cell_world(world_x: float, world_y: float, cell_id: float, offset: Vector2 = Vector2()):
	var cell_position = TileMapUtils.world_to_map(Vector2(world_x, world_y))
	map.set_cell(cell_position.x, cell_position.y, cell_id, offset)


