extends Node2D

#	add_astar_cell(cp)


onready var astar_tilemap = $AStarMap

onready var map = $TileMaps/IsometricTileMap


func _ready():
	#create_example_map(Vector2(50, 50))
	#_update_used_rect(cell)
	#_update_pathfinding()
	#_init_map()
	pass


func set_cell(cell_x: int, cell_y: int, cell_id: float):
	pass


func set_cell_world(world_x: float, world_y: float, cell_id: float, offset: Vector2 = Vector2()):
	var cell_position = TileMapUtils.world_to_map(Vector2(world_x, world_y))
	map.set_cell(cell_position.x, cell_position.y, cell_id, offset)


func create_example_map(new_mapsize : Vector2):
	Global.set_timer(name)
	
	for x in range(new_mapsize.x):
		for y in range(new_mapsize.y):
			set_cell_world((x + 100) * Global.CELL_SIZE.x /2, (y + 100) * Global.CELL_SIZE.y/ 2, 19)
	
	Global.get_time(name, "creating map took: ")
