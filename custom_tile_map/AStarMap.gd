extends TileMap




var astar = AStar2D.new()

var _cells


func _ready():
	pass


func _update_pathfinding():
	for cell in _cells:
		var w = cell.x
		var h = cell.y
		if get_astar_cell(Vector2(w, h)) == -1:
			continue
		var astar_id = _get_astar_cell_id(Vector2(w, h))
		astar.add_point(astar_id, Vector2(w, h))
	
	_update_neighbours()


func _update_neighbours():
	for cell in _cells:
		var x = cell.x
		var y = cell.y
		var center = _get_astar_cell_id(Vector2(x, y))
		
		var l = _get_astar_cell_id(Vector2(x - 1, y))
		var r = _get_astar_cell_id(Vector2(x + 1, y))
		var t = _get_astar_cell_id(Vector2(x, y - 1))
		var b = _get_astar_cell_id(Vector2(x, y + 1))
		
		if get_astar_cell(Vector2(x - 1, y)) != -1:
			astar.connect_points(center, l)
		if get_astar_cell(Vector2(x + 1, y)) != -1:
			astar.connect_points(center, r)
		if get_astar_cell(Vector2(x, y - 1)) != -1:
			astar.connect_points(center, t)
		if get_astar_cell(Vector2(x, y + 1)) != -1:
			astar.connect_points(center, b)
		
		var bl = _get_astar_cell_id(Vector2(x - 1, y + 1))
		var br = _get_astar_cell_id(Vector2(x + 1, y + 1))
		var tr = _get_astar_cell_id(Vector2(x + 1, y - 1))
		var tl = _get_astar_cell_id(Vector2(x - 1, y - 1))
		
		if get_astar_cell(Vector2(x - 1, y + 1)) != -1:
			astar.connect_points(center, bl)
		if get_astar_cell(Vector2(x + 1, y + 1)) != -1:
			astar.connect_points(center, br)
		if get_astar_cell(Vector2(x + 1, y - 1)) != -1:
			astar.connect_points(center, tr)
		if get_astar_cell(Vector2(x - 1, y - 1)) != -1:
			astar.connect_points(center, tl)
			
#			print("center: ", astar_id)
#			print("left: ", l)
#			print("right: ", r)
#			print("top: ", t)
#			print("bottom: ", b)
#			print("cell-left: ", get_astar_cell(Vector2(x - 1, y)))
#			print("cell-right: ", get_astar_cell(Vector2(x + 1, y)))
#			print("cell-top: ", get_astar_cell(Vector2(x, y - 1)))
#			print("cell-bottom: ", get_astar_cell(Vector2(x, y + 1)))
#			print(get_astar_cell(Vector2(x, y)))


func _add_astar_vicinity_cells(center_id : int):
	var center_position = _astar_id_to_cell_position(center_id)
	#print(center_position)
	
	#print(get_astar_cell(center_position))
	
	if get_astar_cell(center_position) != -1:
		return
	
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var other_position = Vector2(center_position.x + x, center_position.y + y)
			var other_id = _get_astar_cell_id(other_position)
			if center_id == other_id:
				continue
			 
			if get_astar_cell(other_position) != -1:
				astar.connect_points(center_id, other_id)
	
	set_cell(center_position.x, center_position.y, 16, false, false, false, Vector2(1, 0))


func get_astar_cell(cell_position : Vector2):
	return get_cellv(cell_position)


func remove_astar_cell(cell_position : Vector2):
	var id = _get_astar_cell_id(cell_position)
	astar.remove_point(id)
	set_cellv(cell_position, -1)


func add_astar_cell(cell_position : Vector2):
	#print("add cell to ", cell_position)
	var id = _get_astar_cell_id(cell_position)
	astar.add_point(id, cell_position)
	_add_astar_vicinity_cells(id)


func get_astar_path_cell(from_cell: Vector2, to_cell: Vector2):
	print("find path from ", from_cell, " to ", to_cell, " (ids: ", 
			_get_astar_cell_id(from_cell), ", ", _get_astar_cell_id(to_cell), ")")
#	print("from cell ", from_cell, " to ", _get_astar_cell_id(from_cell))
#	print("to cell ", to_cell, " to ", _get_astar_cell_id(to_cell))
	
	return astar.get_id_path(
			_get_astar_cell_id(from_cell), 
			_get_astar_cell_id(to_cell))


func get_astar_path(from : Vector2, to : Vector2):
	from = Global.world_to_isotile(from)
	to = Global.world_to_isotile(to)
	
	if !astar.has_point(_get_astar_cell_id(from)) or !astar.has_point(_get_astar_cell_id(to)):
		return []
	
	return astar.get_id_path(
			_get_astar_cell_id(from), 
			_get_astar_cell_id(to))


func _get_astart_id_by_position(world_position : Vector2) -> int:
	var cell_position = Global.world_to_isotile(world_position)
	return int(cell_position.x + cell_position.y * Global.MAP_SIZE)


func _get_astar_cell_id(cell_position: Vector2) -> int:
	return int(cell_position.x + cell_position.y * Global.MAP_SIZE) 


func _astar_id_to_cell_position(id : int) -> Vector2:
	return Vector2(
		floor(id % int(Global.MAP_SIZE)),
		floor(float(id) / Global.MAP_SIZE)
	)


func _astar_id_to_world_position(id : int) -> Vector2:
	
	print("id: ", id)
	var cell_position = _astar_id_to_cell_position(id)
	print("cell position: ", cell_position)
	
	var world_position = Vector2(
			(cell_position.x - cell_position.y) * Global.CELL_X_HALF,
			(cell_position.x + cell_position.y) * Global.CELL_Y_HALF
		)
		
	print("world position: ", world_position)
	return world_position
