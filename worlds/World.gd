extends Node2D


onready var player = $Player
onready var main_camera = $Camera2D
onready var navi : Navigation2D = $Navigation
onready var building_preview = $Misc/BuildingPreview
onready var building_placement_preview = $Misc/BuildingPlacementPreview
onready var tile_marker = $Misc/TileMarker
onready var astar_tilemap : TileMap = $AStarMap
onready var astar_path : Line2D = $AStarPath
onready var spawn_unit_parent = $Navigation
onready var cell_boundaries = $CellBoundaries

const TileBoundary = preload("res://misc/TileBoundary.tscn")


var ground_tilemap : TileMap
var map

var select_units_marker : Sprite

var building_preview_active = false
var building_selected = Global.Buildings.NONE

var astar = AStar2D.new()
var _map_cell_width = -1
var _map_cell_height = -1

var _building_placement_ids = [] # 1-D array of ids, save the buildings (id : building)

var shapes = []
var pols = []


func _ready():
	Global.world = self
	map = $Navigation/Map0
	ground_tilemap = map.get_ground_tilemap()
	_map_cell_width = ground_tilemap.get_used_rect().size.x + ground_tilemap.get_used_rect().position.x
	_map_cell_height = ground_tilemap.get_used_rect().size.y + ground_tilemap.get_used_rect().position.y
	select_units_marker = create_select_units_marker()
	
	print()
	var now = OS.get_ticks_msec()
	now = OS.get_ticks_msec()
	_init_units()
	print("units: ", OS.get_ticks_msec() - now)
	print(OS.get_ticks_msec() - now)
	now = OS.get_ticks_msec()
	_init_pathfinding()
	print("pathfinding: ", OS.get_ticks_msec() - now)
	print(OS.get_ticks_msec() - now)
	now = OS.get_ticks_msec()
	_init_buildings()
	print("buildings: ", OS.get_ticks_msec() - now)
	print(OS.get_ticks_msec() - now)
	now = OS.get_ticks_msec()
	_init_map()
	print("map: ", OS.get_ticks_msec() - now)
	
	print("map size (x): ", _map_cell_width)
	print(OS.get_ticks_msec() - now)
	now = OS.get_ticks_msec()
	
	spawn_unit(Global.Units.KNIGHT, Vector2(10, 20))
	spawn_unit(Global.Units.SPEARMAN, Vector2(20, 20))
	
	#place_building(Global.Buildings.TRAINING_CAMP, Vector2(-250, 750))
	
	tile_marker.enable(ground_tilemap, ground_tilemap.get_cell_size())
	
	EventSystem.register_to_event(EventSystem.Events.selected_building, funcref(self, "_set_building_preview"))


func _process(delta: float) -> void:
#	var ids = get_astar_path(Vector2(0, 650), get_global_mouse_position())
#	if !ids.empty():
#		visualize_path(ids)
	
	#for unit in get_tree().get_nodes_in_group(Global.groups.selectable_units):
	#	pass
	pass


func _input(event: InputEvent) -> void:
	if building_preview_active:
		if Input.is_action_just_pressed("mouse_right"):
			building_preview.disable()
			building_selected = Global.Buildings.NONE
			building_preview_active = false
			building_placement_preview.disable()
		elif Input.is_action_just_released("mouse_left"):
			place_building_preview()
		
	else:
		if Input.is_action_pressed("left_ctrl"):
			if Input.is_action_just_pressed("mouse_right"):
				add_astar_cell(Global.world_to_isotile(get_global_mouse_position()))
				return
			elif Input.is_action_just_pressed("mouse_left"):
				remove_astar_cell(Global.world_to_isotile(get_global_mouse_position()))
				return
			
		if Input.is_action_just_pressed("mouse_left"):
			select_units_marker.start(get_global_mouse_position())
			
			#get_tile_texture(Global.world_to_isotile(get_global_mouse_position()))
			
			var selected_tile = select_tile()
			
			if selected_tile != -1 and pols[selected_tile] != null:
				set_tile(selected_tile, ground_tilemap.world_to_map(pols[selected_tile].position), -1)
			
			
			#get_tile_height(Global.world_to_isotile(get_global_mouse_position()))
			#print("Tile height: ", get_cells_height(get_global_mouse_position()))
			
			#var img = main_camera.get_viewport().get_texture().get_data()
			#img.flip_y()
			#print(img.get_size())
			#print(Global.gui.get_local_mouse_position())
			#print(img.get_pixelv(Global.gui.get_local_mouse_position()))
			#viewport_image = ImageTexture.new()
			#viewport_sprite.texture = viewport_image.create_from_image(img)
		
		if Input.is_action_just_released("mouse_left"):
			select_units()
	
		if Input.is_action_just_pressed("mouse_right"):
			move_selected_units()


func set_tile(selected_id, cell_position: Vector2, tile, coord:=Vector2()):
	ground_tilemap.set_cell(cell_position.x, cell_position.y, tile, false, false, false, coord)
	var tile_id = selected_id
	if tile == -1:
		if shapes[tile_id] != null:
			shapes[tile_id].call_deferred("free")
			shapes[tile_id] = null
		if pols[tile_id] != null:
			pols[tile_id].call_deferred("free")
			pols[tile_id] = null


func get_tile_by_collision(world_position : Vector2):
	var cp = ground_tilemap.world_to_map(world_position)
	
	var selected_shapes = []
	
	for i in range(shapes.size()):
		if shapes[i] == null:
			continue
		var inside = true
		var shape : Shape2D = shapes[i].shape
		$MouseCollision.global_position = world_position
		
		var col = shape.collide(pols[i].transform, $MouseCollision/CollisionShape2D.shape, $MouseCollision.transform)
		
		if col:
			selected_shapes.append(i)
	
	if !selected_shapes.empty():
		var selected_shape = selected_shapes[0]
		for idx in selected_shapes:
			if shapes[selected_shape].position.y < shapes[idx].position.y:
				selected_shape = idx
		return selected_shape
	return -1


func select_tile() -> int:
	var mp = get_global_mouse_position()
	var cp = ground_tilemap.world_to_map(mp)
	
	var selected_shapes = []
	
	for i in range(shapes.size()):
		if shapes[i] == null:
			continue
		var inside = true
		var shape : Shape2D = shapes[i].shape
		$MouseCollision.global_position = mp
		
		var col = shape.collide(pols[i].transform, $MouseCollision/CollisionShape2D.shape, $MouseCollision.transform)
		
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
		#pols[selected_shape].color = Color(randf(), randf(), randf())


func visualize_path(ids : Array):
	var path = []
	for id in ids:
		var p = Global.isotile_to_world(_astar_id_to_cell_position(id))
		p.y += Global.CELL_Y_HALF
		
		path.append(p)
	
	astar_path.points = path


# TODO: consider height per tile
# TODO: for debug mark picked tile
# TODO: Add "clicked" position like in template
func _init_map():
	var size = ground_tilemap.get_used_cells().size()
	pols.resize(size)
	shapes.resize(size)
	
	var idx = 0
	var used = []
	
	for cell in ground_tilemap.get_used_cells():
		var cell_area := Polygon2D.new()
		var shape := ConvexPolygonShape2D.new()
		var cell_shape := CollisionShape2D.new()
		
		var cell_type = ground_tilemap.get_cellv(cell)
		var cell_coord = ground_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		
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
		
		if not cell_coord.x in used:
			used.append(cell_coord.x) 
		
		for i in range(polygon.size()):
			polygon[i] *= 32.0
			polygon[i].y += 16
			polygon[i].y += 8 * cell_coord.x
		
		cell_area.polygon = polygon
		cell_area.color = Color(randf(), randf(), randf())
		cell_area.position = ground_tilemap.map_to_world(Vector2(cell.x, cell.y))
		
		shape.points = polygon
		cell_shape.position = ground_tilemap.map_to_world(Vector2(cell.x, cell.y))
		
		pols[idx] = cell_area
		shapes[idx] = cell_shape
		
		idx += 1
	
	print(used)
	
	var i = 0
	for cell in ground_tilemap.get_used_cells():
		#if i % 10 == 0:
		#	print(i)
		i += 1
		var world_position = ground_tilemap.map_to_world(cell)
		var tile_boundary = TileBoundary.instance()
		cell_boundaries.add_child(tile_boundary)
		tile_boundary.global_position = world_position


func _init_buildings():
	for i in range(_map_cell_width * _map_cell_height):
		_building_placement_ids.append(-1)


func _init_pathfinding():
	print("used map size: ", astar_tilemap.get_used_rect())
	var width = _map_cell_width
	var height = _map_cell_height
	
	for cell in ground_tilemap.get_used_cells():
		var w = cell.x
		var h = cell.y
		if get_astar_cell(Vector2(w,h)) == -1:
			continue
		var astar_id = _get_astar_cell_id(Vector2(w, h))
		astar.add_point(astar_id, Vector2(w, h))
	
	_init_neighbours()


func _init_neighbours():
	var width = _map_cell_width
	var height = _map_cell_height
	
	for cell in ground_tilemap.get_used_cells():
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
	print(center_position)
	
	print(get_astar_cell(center_position))
	
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
	print("add cell to ", cell_position)
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
#	print("x = ", cell_position.x)
#	print("y = ", cell_position.y)
#	print("w = ", _map_cell_width)
#	print("x + y * WIDTH = ", int(cell_position.x + cell_position.y * _map_cell_width))
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


func _set_building_preview(selected_building, preview_texture):
	building_preview.enable(preview_texture)
	building_selected = selected_building
	print("selected: ", Global.BuildingsDict[selected_building])
	building_preview_active = true
	building_placement_preview.enable(Global.BuildingPlacement[selected_building])


func create_select_units_marker() -> Sprite:
	var marker = preload("res://misc/SelectUnitsMarker.tscn").instance()
	marker.hide()
	add_child(marker)
	return marker


func get_navigation_path(a : Vector2, b : Vector2):
	var path = navi.get_simple_path(a, b)
	return path


func move_selected_units():
	if get_tree().get_nodes_in_group(Global.groups.selected_units).size() <= 0:
		return
	
	var target_position = get_global_mouse_position()
	var center = Vector2.ZERO
	for unit in get_tree().get_nodes_in_group(Global.groups.selected_units):
		center += unit.get_global_position()
	
	center /= get_tree().get_nodes_in_group(Global.groups.selected_units).size()
	
#	var path = get_navigation_path(center, target_position) # navmesh
	var path = get_astar_path(center, target_position)
	
	for unit in get_tree().get_nodes_in_group(Global.groups.selected_units):
#		path = get_navigation_path(unit.get_global_position(), target_position)
		path = get_astar_path(unit.get_global_position(), target_position)
		var path_positions = []
		for p in path:
			path_positions.append(_astar_id_to_world_position(p))
		unit.set_path(path_positions)
		visualize_path(path)


func select_units():
	deselect_units()
	var rect : Rect2 = select_units_marker.get_select_rect()
	select_units_marker.stop()
	
	for unit in get_tree().get_nodes_in_group(Global.groups.selectable_units):
		if rect.has_point(unit.get_global_position()):
			unit.add_to_group(Global.groups.selected_units)
			unit.modulate = Color.blue


func deselect_units():
	for unit in get_tree().get_nodes_in_group(Global.groups.selected_units):
		unit.remove_from_group(Global.groups.selected_units)
		unit.modulate = Color.white


func _init_units() -> void:
	pass


func spawn_unit(unit_type, pos : Vector2) -> Sprite:
	print("added unit: ", Global.UnitNames[unit_type])
	
	match unit_type:
		Global.Units.SPEARMAN:
			var unit = Global.UnitTemplates[unit_type].instance()
			spawn_unit_parent.add_child(unit)
			unit.global_position = Global.isotile_to_world(pos)
			return unit
		Global.Units.KNIGHT:
			var unit = Global.UnitTemplates[unit_type].instance()
			spawn_unit_parent.add_child(unit)
			unit.global_position = Global.isotile_to_world(pos)
			return unit
		Global.Units.NONE:
			print("couldn't find unit to spawn")
	return null


func place_building_preview():
	place_building(building_selected, get_global_mouse_position())


func place_building(building_type, world_position : Vector2) -> void:
	print("Placed building: ", Global.BuildingsDict[building_type])
	
	# use this to get cells for building placement
	var cells = building_placement_preview.calculate_cell_positions_for_building(
			Global.BuildingPlacement[building_type])
	
	# needed for offset
	for i in range(cells.size()):
		cells[i] += world_position
	
	if can_building_be_placed_on_cells(cells):
		for i in range(cells.size()):
			remove_astar_cell(Global.world_to_isotile(cells[i]))
		set_cells_from_world_positions(cells)


func set_cells_from_world_positions(arr : Array) -> void:
	for pos in arr:
		set_cell_world(pos, -1)


func set_cell_world(pos, tile_id) -> void:
	ground_tilemap.set_cellv(Global.world_to_isotile(pos), tile_id)


func get_cell_world(pos : Vector2) -> int:
	return ground_tilemap.get_cellv(Global.world_to_isotile(pos))


func get_cell_auto_world(pos : Vector2) -> Vector2:
	var p = Global.world_to_isotile(pos)
	return ground_tilemap.get_cell_autotile_coord(p.x, p.y)


func can_building_be_placed_on_cells(cells : Array) -> bool:
	for pos in cells:
		if get_cell_world(pos) == -1:
			return false
	return true


func get_tile_height(cell_position : Vector2):
	var tile_height = Global.MAX_CELL_HEIGHT - \
			ground_tilemap.get_cell_autotile_coord(cell_position.x, cell_position.y).x * Global.PIXEL_PER_HEIGHT
	tile_height -= 36
	return tile_height


func get_cells_height(world_position: Vector2) -> Array:
	var cells = []
	
	var center_cell = Global.world_to_isotile(world_position)
	var vis_cells = []
	
	for d in [-1, 0, 1]:
		for i in range(5):
			var cell = Vector2(center_cell.x + i - 2 + d, center_cell.y + i - 2)
			cells.append(cell)
			vis_cells.append(_get_astar_cell_id(cell))
	
	visualize_path(vis_cells)
	
	return cells


func get_tile_center_cell(cell_position : Vector2) -> Vector2:
	return Global.isotile_to_world(cell_position)


func get_tile_center_world(world_position : Vector2) -> Vector2:
	return Global.isotile_to_world(Global.world_to_isotile(world_position))


func get_tile_texture(cell_position: Vector2):
	var auto_coord = ground_tilemap.get_cell_autotile_coord(cell_position.x, cell_position.y)
	var cell = ground_tilemap.get_cell(cell_position.x, cell_position.y)
	
	print("--------------------------------")
	print("auto coord: ", auto_coord)
	print("cell: ", cell)
	print("cell height: ", get_tile_height(cell_position))
	
	print("cell size: ", ground_tilemap.tile_set.autotile_get_size(cell))
	print("cell size: ", ground_tilemap.tile_set.tile_get_texture(cell))
	
	$SelectedTile.texture = ground_tilemap.tile_set.tile_get_texture(cell)
	


func _check_front_tile(cells : Array) -> Vector2:
	var front_tile
	var areas = []
	
	for cell in cells:
		var height = get_tile_height(cell)
		var world_position = Global.isotile_to_world(cell)
		if height == 0:
			
			var p = world_position
			
			CollisionPolygon2D
			
			p.x += Global.CELL_X_HALF # <- ...
			areas.append(p)
			areas.append(world_position - Global.CELL_X_HALF)
			areas.append(world_position + Global.CELL_Y_HALF)
			areas.append(world_position - Global.CELL_Y_HALF)
		else:
			areas.append(world_position + Global.CELL_X_HALF)
			areas.append(world_position - Global.CELL_X_HALF)
			areas.append(world_position + Global.CELL_Y_HALF)
			
			areas.append(world_position + Global.CELL_X_HALF)
			areas.append(world_position - Global.CELL_X_HALF)
			areas.append(world_position + Global.CELL_Y_HALF)
		
	
	return front_tile

