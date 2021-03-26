extends TileMap


var tm := TileMap.new()


func _ready():
	cell_size = Global.CELL_SIZE
	mode = TileMap.MODE_ISOMETRIC


func chunk_world_to_1D(x, y) -> int:
	var p = TileMapUtils.world_to_map(Vector2(x, y))
	return int(p.x + p.y * Global.CHUNK_SIZE.x)


func chunk_cell_to_1D(x, y) -> int:
	return int(x + y * Global.CHUNK_SIZE.x)





func _world_to_1D(x, y) -> int:
	var p = TileMapUtils.world_to_map(Vector2(x, y))
	return int(p.x + p.y * Global.MAP_SIZE)


func _cell_to_1D(x, y) -> int:
	return int(x + y * Global.MAP_SIZE)
