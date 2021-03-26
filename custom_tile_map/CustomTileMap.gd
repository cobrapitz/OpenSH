extends YSort
class_name CustomTileMap

"""
Children of this node are cells/tiles

The idea to draw this is:
	draw each row of tiles -> <><><><><><> 
	

"""

export(TileSet) var tileset : TileSet = null
export(Vector2) var cell_size = Vector2(64, 32)

export(Vector2) var map_size = Vector2(250, 250)

export(Texture) var prefab_texture

const Cell = preload("res://custom_tile_map/Cell.tres")

onready var cell_boundaries = $CellBoundaries


const TileBoundary = preload("res://misc/TileBoundary.tscn")

var _cells := [] # 1D-idx to cell
var shapes = []
var pols = []

var _map_cell_width = -1
var _map_cell_height = -1

var _used_rect := Rect2()

var _next_cell_id = 0

var _chunks := {}
var _shown_chunks = [] # shown chunks by id



func _ready():
	pass


func _draw():
	#var t = 0 
	for idx in _chunks.keys():
		for cell in _chunks[idx]:
			draw_texture(cell.texture, cell.position + Vector2(0.0, -cell.offset.y))
		#draw_texture(prefab_texture, cell.position * Vector2(32, 64))
		#draw_texture_rect(prefab_texture, Rect2(), false)
		
		#draw_texture_rect_region(cell.texture, Rect2(cell.position, cell.size), Rect2(cell.region_rect, cell.size))


func create(new_mapsize : Vector2):
	Global.set_timer(name)
	
	map_size = new_mapsize
	
	_map_cell_width = _used_rect.size.x + _used_rect.position.x
	_map_cell_height = _used_rect.size.y + _used_rect.position.y
	if _map_cell_width == 0:
		_map_cell_width = 1
	if _map_cell_height == 0:
		_map_cell_height = 1
	
	_cells.resize(Global.MAP_SIZE * Global.MAP_SIZE)
#	print("Max Chunks: ", _chunks.size())
	for x in range(map_size.x):
		for y in range(map_size.y):
			set_cell(x, y, 19)
	
	Global.get_time(name, "creating map took: ")


func restock_cache():
	Global.set_timer(name)
	
	#var idx = _cells.size()
	_cells.resize(_cells.size() + Global.CACHE_CELLS_SIZE)
	
	for i in range(_cells.size()):
		_cells[i] = Cell.new()
	
	print("Max Map size: ", _cells.size())
	
	Global.get_time(name, "restocking cache took: ")


func fill_chunk(world_pos):
	var cell_pos = TileMapUtils.world_to_map(world_pos)
	var chunk_idx = get_chunk_idx(cell_pos)
	
	var chunk_cell_idx = get_local_chunk_idx(cell_pos)
	
	print("chunk ", chunk_idx, " - ", chunk_cell_idx)
	
	if _chunks.has(chunk_idx):
		print("exists already")
		return
	_chunks[chunk_idx] = []
	
	for x in range(Global.CHUNK_SIZE.x):
		for y in range(Global.CHUNK_SIZE.y):
			var cx = cell_pos.x
			var cy = cell_pos.y
			
			if cx < 0:
				cx -= Global.CHUNK_SIZE
			
			if cy < 0:
				cy -= Global.CHUNK_SIZE
			
			cx -= int(cx) % int(Global.CHUNK_SIZE.x)
			cy -= int(cy) % int(Global.CHUNK_SIZE.y)
			
			cx += x
			cy += y
			
			var cell = Cell.new()
			
			cell.position = TileMapUtils.map_to_world(Vector2(cx, cy)) #Vector2(x, y)
			cell.texture = prefab_texture
			cell.size = Vector2(64, 124)
			cell.region_rect = Rect2(Vector2(), Vector2(777, 389))
			cell.offset.y = randi() % 100
			
			_chunks[chunk_idx].append(cell)
	
	update()


func get_tiles_row(start_cell: Vector2, size: int) -> Array:
	var tiles = []
	
	for i in range(size):
		if i % 2 == 0:
			start_cell.x += 1
		else:
			start_cell.y -= 1
		tiles.append(start_cell)
	
	return tiles


func get_local_chunk_idx(cell_pos : Vector2) -> int:
	var x = int(cell_pos.x) % int(Global.CHUNK_SIZE.x)
	var y = int(cell_pos.y) % int(Global.CHUNK_SIZE.y)
	var idx = x + y * int(Global.CHUNK_SIZE.x)
	return idx


func get_chunk_idx(cell_pos):
	var x = int(cell_pos.x / Global.CHUNK_SIZE.x)
	var y = int(cell_pos.y / Global.CHUNK_SIZE.y)
	
	if cell_pos.x < 0:
		x -= 1
	
	if cell_pos.y < 0:
		y -= 1
	
	return Vector2(x, y)
#	return _chunks[(cell_pos.x / Global.CHUNK_SIZE) + (cell_pos.y / Global.CHUNK_SIZE)]


# world_pos_1 = (50, 50)
# get_chunk( world_pos_1 )    => (50/300, 50/300)       => (0, 0)
func get_chunk_world_idx(world_pos):
	var cp = TileMapUtils.world_to_map(world_pos)
	cp.x /= Global.CHUNK_SIZE.x
	cp.y /= Global.CHUNK_SIZE.y
	
	return Vector2(int(cp.x), int(cp.y))
#	return _chunks[Vector2(int(cp.x), int(cp.y))]


func get_cell_texture_region(id, subtile):
	var pos = tileset.autotile_get_size(id)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	return Rect2(pos, cell_size)


func draw_sourouding_chunks(world_x, world_y):
	var cp = TileMapUtils.world_to_map(Vector2(world_x, world_y))
	var new_shown = []
	
	for cx in [-1, 0, 1]:
		for cy in [-1, 0, 1]:
			var chunk_p = Vector2(
				int(cp.x / Global.CHUNK_SIZE.x + cx) * Global.CHUNK_SIZE.x, 
				int(cp.y / Global.CHUNK_SIZE.y + cy) * Global.CHUNK_SIZE.y)
			new_shown.append(chunk_p)
			for x in range(Global.CHUNK_SIZE.x):
				for y in range(Global.CHUNK_SIZE.y):
					var cell = get_cell(chunk_p.x + x, chunk_p.y + y)
					if cell != null:
						cell.visible = true
	
	for prev_chunk in _shown_chunks:
		if not prev_chunk in new_shown:
			_hide_chunk(prev_chunk.x, prev_chunk.y)
	
	_shown_chunks = new_shown


#func _draw() -> void:
#	pass


func _set_chunk_visible(cell_x, cell_y, vis):
	var chunk_p = Vector2(
		int(cell_x / Global.CHUNK_SIZE.x) * Global.CHUNK_SIZE.x, 
		int(cell_y / Global.CHUNK_SIZE.y) * Global.CHUNK_SIZE.y)
	
	for x in range(Global.CHUNK_SIZE.x):
		for y in range(Global.CHUNK_SIZE.y):
			var cell = get_cell(chunk_p.x + x, chunk_p.y + y)
			if cell != null:
				cell.visible = vis


func _set_chunk_visible_world(world_x, world_y, vis):
	var cp = TileMapUtils.world_to_map(Vector2(world_x, world_y))
	var chunk_p = Vector2(
		int(cp.x / Global.CHUNK_SIZE.x) * Global.CHUNK_SIZE.x, 
		int(cp.y / Global.CHUNK_SIZE.y) * Global.CHUNK_SIZE.y)
	
	for x in range(Global.CHUNK_SIZE.x):
		for y in range(Global.CHUNK_SIZE.y):
			var cell = get_cell(chunk_p.x + x, chunk_p.y + y)
			if cell != null:
				cell.visible = vis


func _draw_chunk(world_x, world_y):
	_set_chunk_visible(world_x, world_y, true)


func _hide_chunk(cell_x, cell_y):
	_set_chunk_visible(cell_x, cell_y, false)


func get_texture(id):
	return tileset.tile_get_texture(id)


func set_cell(x, y, tile_id, subtile = Vector2(0, 0)):
	if get_cell(x, y) != null:
		return get_cell(x, y)
	
	if _next_cell_id >= _cells.size():
		restock_cache()
	
	_next_cell_id += 1
	var cell = _cells[_next_cell_id]
	
	if cell == null:
		_cells[_next_cell_id] = Cell.new()
		cell = _cells[_next_cell_id]
	
	cell.position = TileMapUtils.map_to_world(Vector2(x, y))
	cell.position.y += cell_size.y * 0.5
	
	cell.texture = tileset.tile_get_texture(tile_id)
	var pos = tileset.autotile_get_size(tile_id)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y
	
	# temp
	pos = Vector2(777, 389)
	var size = Vector2(64, 124)
	
	cell.region_rect = Rect2(pos, size)
	
	_cells[TileMapUtils._cell_to_1D(x, y)] = cell
	
	return cell
	
#	if get_cell(x, y) != null:
#		return get_cell(x, y)
#
#	var cell = Sprite.new()
#	var cell_bg = Sprite.new()
#	cell_bg.show_behind_parent = true
#	add_child(cell)
#	cell.add_child(cell_bg)
#	cell_bg.position.y + 100
#
#	#cell_bg.texture = preload("res://resources/cells/cell_bg.png")
#	cell_bg.texture = preload("res://resources/walls/hjm-mossy_wall_low.png")
#
#	cell.position = TileMapUtils.map_to_world(Vector2(x, y))
#	cell.position.y += cell_size.y * 0.5
#
#	cell.texture = tileset.tile_get_texture(2)
#	cell.region_enabled = true
#	var pos = tileset.autotile_get_size(2)
#	pos.x += cell_size.x * subtile.x - cell_size.x
#	pos.y += cell_size.y * subtile.y - cell_size.y 
#	cell.region_rect = Rect2(pos, cell_size)
#	
#	_cells[TileMapUtils.world_to_map(cell.position)] = cell
#	_cell_bg_position_map[TileMapUtils.world_to_map(cell.position)] = cell_bg
#	add_astar_cell(TileMapUtils.world_to_map(cell.position))
#	_update_used_rect(cell)
#	_update_pathfinding()
#	_init_map()
	


func set_cell_world(x, y, tile_id, subtile = Vector2(0, 0)):
	#var now = OS.get_ticks_msec()
	var cp = TileMapUtils.world_to_map(Vector2(x, y))
	
	if cp.x < 0 or cp.y < 0:
		return null
	
	if get_cell(cp.x, cp.y) != null:
		return get_cell(cp.x, cp.y)
	
	if _next_cell_id >= _cells.size():
		restock_cache()
	
	_next_cell_id += 1
	var cell = _cells[_next_cell_id]
	cell.visible = true
	
	cell.position = TileMapUtils.map_to_world(cp)
	cell.position.y += cell_size.y * 0.5
	
	cell.texture = tileset.tile_get_texture(tile_id)
	#cell.region_enabled = true
	var pos = tileset.autotile_get_size(tile_id)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	
	# temp
	pos = Vector2(777, 389)
	cell_size = Vector2(64, 124)
	
	cell.region_rect = Rect2(pos, cell_size)
	
	if !_cells.has(TileMapUtils._world_to_1D(x, y)):
		return null
	_cells[TileMapUtils._world_to_1D(x, y)] = cell
	
	return cell


func ___old(x, y, tile_id, subtile = Vector2(0, 0)):
	#var now = OS.get_ticks_msec()
	var cp = TileMapUtils.world_to_map(Vector2(x, y))
	if get_cell(cp.x, cp.y) != null:
		return get_cell(cp.x, cp.y)
	var ysort = YSort.new()
	var cell = Sprite.new()
	var cell_bg = Sprite.new()
	
	add_child(ysort)
	#ysort.add_child(cell_bg)
	ysort.add_child(cell)
	
	cell_bg.texture = preload("res://resources/cells/cell_bg.png")
	
	cell.position = TileMapUtils.map_to_world(cp)
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
	
	_cells[cp] = cell
	#_cell_bg_position_map[cp] = cell_bg
	#print("time: ", OS.get_ticks_msec() - now)
	
	return cell


func set_cell_offset_world(x, y, offset : Vector2):
	var cp = TileMapUtils.world_to_map(Vector2(x, y))
	var cell = get_cell(cp.x, cp.y)
	#var cell_bg = get_cell_bg(cp.x, cp.y)
	if cell == null:
		return
	
	cell.offset.y = offset.y
	#cell_bg.offset = offset + Vector2(0, 49)
	_init_map()


func set_cell_offset(x, y, offset : Vector2):
	var cell = get_cell(x, y)
	if cell == null:
		return
	
	cell.offset.y = offset


func get_cell(x : int, y : int):
	if x < 0 or y < 0:
		return null
	
	var p = TileMapUtils._cell_to_1D(x, y)
	if p < _cells.size():
		return _cells[p]
	printerr("cell out of bounds!")
	return null


#func get_cell_world(x, y):
#	var p = _world_to_1D(x, y)
#	if p < _cells.size():
#		return _cells[p]
#	printerr("cell out of bounds!")
#	return null


#func get_cell_bg(x, y):
#	if _cell_bg_position_map.has(Vector2(x, y)):
#		return _cell_bg_position_map[Vector2(x, y)]
#	return null


#func get_cells():
#	return _cells.values()
#
#
#func get_used_cells_amount() -> int:
#	return _cells.size()



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
	
	var size = _cells.size()
	pols.resize(size)
	shapes.resize(size)
	#_cells.clear()
	#_bg_cells.clear()
	
	var idx = 0
	var used = []
	
	for cell in _cells:
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
		#var current_cell_bg = get_cell_bg(cell.x, cell.y)
		
		for i in range(polygon.size()):
			polygon[i] *= cell_size.x / 2
			polygon[i].y += cell_size.y / 2
			polygon[i].y += current_cell.offset.y
		
		cell_area.polygon = polygon
		cell_area.color = Color(randf(), randf(), randf())
		cell_area.position = TileMapUtils.map_to_world(cell)
		
		shape.points = polygon
		cell_shape.position = TileMapUtils.map_to_world(cell)
		
		pols[idx] = cell_area
		shapes[idx] = cell_shape
		#_cells[idx] = current_cell
		#_bg_cells[idx] = current_cell_bg
		
		idx += 1
	
	#print(used)
	
	var i = 0
	for cell in _cells:
		i += 1
		var world_position = TileMapUtils.map_to_world(cell)
		var tile_boundary = TileBoundary.instance()
		cell_boundaries.add_child(tile_boundary)
		tile_boundary.global_position = world_position


	
