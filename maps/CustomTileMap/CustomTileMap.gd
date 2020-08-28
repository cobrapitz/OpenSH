extends YSort

"""
Children of this node are cells/tiles
"""

export(TileSet) var tileset : TileSet = null
export(Vector2) var cell_size = Vector2(64, 32)


onready var astar_tilemap = $AStarMap
onready var cell_boundaries = $CellBoundaries


const TileBoundary = preload("res://misc/TileBoundary.tscn")


var _cells = {}
var _bg_cells = {}
var _cell_position_map = {}
var _cell_bg_position_map = {}

# used for selecting tiles
var shapes = []
var pols = []

# used to swap between world and map coords
var _tilemap = TileMap.new()

var astar = AStar2D.new()
var _map_cell_width = -1
var _map_cell_height = -1

var _used_rect := Rect2()


func _ready():
	add_child(_tilemap)
	_tilemap.cell_size = cell_size
	_tilemap.mode = TileMap.MODE_ISOMETRIC
	_map_cell_width = _used_rect.size.x + _used_rect.position.x
	_map_cell_height = _used_rect.size.y + _used_rect.position.y
	if _map_cell_width == 0:
		_map_cell_width = 1
	if _map_cell_height == 0:
		_map_cell_height = 1


func get_cell_texture_region(id, subtile):
	var pos = tileset.autotile_get_size(id)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	return Rect2(pos, cell_size)


func get_texture(id):
	return tileset.tile_get_texture(id)


func set_cell(x, y, tile_id, subtile = Vector2(0, 0)):
	if get_cell(x, y) != null:
		return get_cell(x, y)

	var cell = Sprite.new()
	var cell_bg = Sprite.new()
	cell_bg.show_behind_parent = true
	add_child(cell)
	cell.add_child(cell_bg)
	cell_bg.position.y + 100
	
	#cell_bg.texture = preload("res://resources/cells/cell_bg.png")
	cell_bg.texture = preload("res://resources/walls/hjm-mossy_wall_low.png")
	
	cell.position = _tilemap.map_to_world(Vector2(x, y))
	cell.position.y += cell_size.y * 0.5
	
	cell.texture = tileset.tile_get_texture(2)
	cell.region_enabled = true
	var pos = tileset.autotile_get_size(2)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	cell.region_rect = Rect2(pos, cell_size)
	
	_cell_position_map[_tilemap.world_to_map(cell.position)] = cell
	_cell_bg_position_map[_tilemap.world_to_map(cell.position)] = cell_bg
	add_astar_cell(_tilemap.world_to_map(cell.position))
	_update_used_rect(cell)
	_update_pathfinding()
	_init_map()
	
	return cell


func set_cell_world(x, y, tile_id, subtile = Vector2(0, 0)):
	#var now = OS.get_ticks_msec()
	var cp = _tilemap.world_to_map(Vector2(x, y))
	if get_cell(cp.x, cp.y) != null:
		return get_cell(cp.x, cp.y)
	
	var ysort = YSort.new()
	
	var cell = Sprite.new()
	var cell_bg = Sprite.new()
	
	add_child(ysort)
	#ysort.add_child(cell_bg)
	ysort.add_child(cell)
	
	cell_bg.texture = preload("res://resources/cells/cell_bg.png")
	
	cell.position = _tilemap.map_to_world(cp)
	cell.position.y += cell_size.y * 0.5
	
	cell_bg.position = cell.position
	cell_bg.position.y -= 1
	cell_bg.offset.y += 49
	
	cell.texture = tileset.tile_get_texture(tile_id)
	cell.region_enabled = true
	var pos = tileset.autotile_get_size(tile_id)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	
	# temp
	pos = Vector2(777, 389)
	cell_size = Vector2(64, 124)
	
	cell.region_rect = Rect2(pos, cell_size)
	#print(cell.region_rect)
	return cell
	
	_cell_position_map[cp] = cell
	_cell_bg_position_map[cp] = cell_bg
	add_astar_cell(cp)
	_update_used_rect(cell)
	_update_pathfinding()
	_init_map()
	#print("time: ", OS.get_ticks_msec() - now)
	
	return cell


func set_cell_offset_world(x, y, offset : Vector2):
	var cp = _tilemap.world_to_map(Vector2(x, y))
	var cell = get_cell(cp.x, cp.y)
	var cell_bg = get_cell_bg(cp.x, cp.y)
	if cell == null or cell_bg == null:
		return
	
	cell.offset = offset
	cell_bg.offset = offset + Vector2(0, 49)
	_init_map()


func set_cell_offset(x, y, offset : Vector2):
	var cell = get_cell(x, y)
	if cell == null:
		return
	
	cell.offset = offset


func get_cell(x, y):
	if _cell_position_map.has(Vector2(x, y)):
		return _cell_position_map[Vector2(x, y)]
	return null


func get_cell_bg(x, y):
	if _cell_bg_position_map.has(Vector2(x, y)):
		return _cell_bg_position_map[Vector2(x, y)]
	return null


func get_cells():
	return _cells.values()


func get_used_cells_amount() -> int:
	return _cells.size()


func _update_used_rect(cell):
	if cell.position.x < _used_rect.position.x:
		_used_rect.position.x = cell.position.x
	if cell.position.y < _used_rect.position.y:
		_used_rect.position.y = cell.position.y
		
	if cell.position.x + cell_size.x > _used_rect.size.x:
		_used_rect.size.x = cell.position.x
	if cell.position.y + cell_size.y > _used_rect.size.y:
		_used_rect.size.y = cell.position.y


func select_cell() -> int:
	var mp = get_global_mouse_position()
	
	var selected_shapes = []
	
	for i in range(shapes.size()):
		if shapes[i] == null:
			continue
		var inside = true
		var shape : Shape2D = shapes[i].shape
		$MouseCollision.global_position = mp
		
		var col = shape.collide(pols[i].transform, 
				$MouseCollision/CollisionShape2D.shape, $MouseCollision.transform)
		
		if col:
			#print(i)ds
			selected_shapes.append(i)
	
	if !selected_shapes.empty():
		var selected_shape = selected_shapes[0]
		for idx in selected_shapes:
			if shapes[selected_shape].position.y < shapes[idx].position.y:
				selected_shape = idx
		return selected_shape
	return -1


func get_tile_by_collision(world_position : Vector2):
	var selected_shapes = []
	
	for i in range(shapes.size()):
		if shapes[i] == null:
			continue
		var inside = true
		var shape : Shape2D = shapes[i].shape
		$MouseCollision.global_position = world_position
		
		var col = shape.collide(pols[i].transform, 
				$MouseCollision/CollisionShape2D.shape, $MouseCollision.transform)
		
		if col:
			selected_shapes.append(i)
	
	if !selected_shapes.empty():
		var selected_shape = selected_shapes[0]
		for idx in selected_shapes:
			if shapes[selected_shape].position.y < shapes[idx].position.y:
				selected_shape = idx
		return selected_shape
	return -1


func _init_map():
	for child in $CellBoundaries.get_children():
		child.queue_free()
	for child in $Shapes.get_children():
		child.queue_free()
	for child in $Shapes.get_children():
		child.queue_free()
	
	
	var size = _cell_position_map.size()
	pols.resize(size)
	shapes.resize(size)
	_cells.clear()
	_bg_cells.clear()
	
	var idx = 0
	var used = []
	
	for cell in _cell_position_map.keys():
		var cell_area := Polygon2D.new()
		var shape := ConvexPolygonShape2D.new()
		var cell_shape := CollisionShape2D.new()
		
		cell_shape.shape = shape
		
		$CellBoundaries.add_child(cell_area)
		$Shapes.add_child(cell_shape)
		
		var polygon = []
		polygon.append(Vector2(-1, 0))
		polygon.append(Vector2(0, -0.5))
		polygon.append(Vector2(1, 0))
		polygon.append(Vector2(1, 4))
		polygon.append(Vector2(0, 3.5))
		polygon.append(Vector2(-1, 4))
		
		var current_cell = get_cell(cell.x, cell.y)
		var current_cell_bg = get_cell_bg(cell.x, cell.y)
		
		for i in range(polygon.size()):
			polygon[i] *= cell_size.x / 2
			polygon[i].y += cell_size.y / 2
			polygon[i].y += current_cell.offset.y
		
		cell_area.polygon = polygon
		cell_area.color = Color(randf(), randf(), randf())
		cell_area.position = _tilemap.map_to_world(cell)
		
		shape.points = polygon
		cell_shape.position = _tilemap.map_to_world(cell)
		
		pols[idx] = cell_area
		shapes[idx] = cell_shape
		_cells[idx] = current_cell
		_bg_cells[idx] = current_cell_bg
		
		idx += 1
	
	#print(used)
	
	var i = 0
	for cell in _cell_position_map.keys():
		i += 1
		var world_position = _tilemap.map_to_world(cell)
		var tile_boundary = TileBoundary.instance()
		cell_boundaries.add_child(tile_boundary)
		tile_boundary.global_position = world_position


# PATHFINDING


func _update_pathfinding():
	var width = _map_cell_width
	var height = _map_cell_height
	
	for cell in _cell_position_map.keys():
		var w = cell.x
		var h = cell.y
		if get_astar_cell(Vector2(w, h)) == -1:
			continue
		var astar_id = _get_astar_cell_id(Vector2(w, h))
		astar.add_point(astar_id, Vector2(w, h))
	
	_update_neighbours()


func _update_neighbours():
	var width = _map_cell_width
	var height = _map_cell_height
	
	for cell in _cell_position_map.keys():
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
	
	astar_tilemap.set_cell(center_position.x, center_position.y, 16, false, false, false, Vector2(1, 0))


func get_astar_cell(cell_position : Vector2):
	return astar_tilemap.get_cellv(cell_position)


func remove_astar_cell(cell_position : Vector2):
	var id = _get_astar_cell_id(cell_position)
	astar.remove_point(id)
	astar_tilemap.set_cellv(cell_position, -1)


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
	return int(cell_position.x + cell_position.y * _map_cell_width)


func _get_astar_cell_id(cell_position: Vector2) -> int:
	return int(cell_position.x + cell_position.y * _map_cell_width) 


func _astar_id_to_cell_position(id : int) -> Vector2:
	return Vector2(
		floor(id % int(_map_cell_width)),
		floor(id / _map_cell_width)
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

