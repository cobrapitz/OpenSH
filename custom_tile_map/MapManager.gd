extends Node2D


export(TileSet) var tileset : TileSet = null


onready var chunk_manager = $ChunkManager

const Cell : Resource = preload("res://custom_tile_map/Cell.tres")

var chunks = {}

var used_rect := Rect2()

var shapes = []
var pols = []


const OPTIMZE_AREA_SIZE = 12
var optimize_area = PoolIntArray()


func _ready():
	optimize_area.resize(OPTIMZE_AREA_SIZE * OPTIMZE_AREA_SIZE)
	reset_optimize_container()


func get_save_data():
	var data = {}
	data["chunk_data"] = chunk_manager.get_save_data()
	return data


func load_save_data(data):
	# TODO add chunk size and other infos here aswell
	chunk_manager.load_save_data(data["chunk_data"])


func clear_map():
	for chunk in chunk_manager.chunks:
		chunk_manager.remove_child(chunk)
		chunk.queue_free()


func batch_set_cell_size(offset, width, height, tile_name):
	var chunks_to_update = []
	var max_x = 0
	var max_y = 0
	var min_x = offset.x
	var min_y = offset.y
	
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				
				var cell_offset = Vector2.ZERO
#				if cell_data.size() > 3:
#					cell_offset = cell_data[3]
#				cell.offset = offset
				
				if cell_x < 0 or cell_y < 0 or \
						cell_x >= Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH or \
						cell_y >= Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH:
					continue
				
				# update/create cell
				var cell_position = Vector2(cell_x, cell_y)
				var cell = chunk_manager.get_cellv(cell_position)
				if cell == null:
					cell = _create_cell(cell_x, cell_y, tile_name, cell_offset)
				else:
					_change_cell(cell, tile_name)
				
				if cell.tile_type != -1:
					reset_tile_group(cell)
				
				cell.tile_offset = Vector2(0, 0)
				cell.offset = cell_offset
				var chunk_id = chunk_manager.set_cellv(cell_position, cell)
				if not chunk_id in chunks_to_update:
					chunks_to_update.append(chunk_id)
	
	randomize_area(offset + Vector2(int(width/2), int(-height / 2)), OPTIMZE_AREA_SIZE)
	
	for chunk_id in chunks_to_update:
		chunk_manager.chunks[chunk_id].update()
	chunk_manager.update()


func batch_set_cell(cells_data: Array):
	var chunks_to_update = []
	var max_x = 0
	var max_y = 0
	for cell_data in cells_data:
		var cell_x = int(cell_data[0])
		var cell_y = int(cell_data[1])
		var tile_name = cell_data[2]
		
		if cell_x > max_x:
			max_x = cell_x
		if cell_y > max_y:
			max_y = cell_y
		
		var offset = Vector2.ZERO #Vector2(0, -randi() % Global.MAX_CELL_HEIGHT)
		if cell_data.size() > 3:
			offset = cell_data[3]
		
		if cell_x < 0 or cell_y < 0 or \
				cell_x >= Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH or \
				cell_y >= Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH:
			continue
			
		# update/create cell
		var cell_position = Vector2(cell_x, cell_y)
		var cell = chunk_manager.get_cellv(cell_position)
		if cell == null:
			cell = _create_cell(cell_x, cell_y, tile_name, offset)
#		elif cell.tile_name != tile_name:
		else:
			_change_cell(cell, tile_name)
		cell.tile_offset = Vector2(0, 0)
		cell.offset = offset
		var chunk_id = chunk_manager.set_cellv(cell_position, cell)
		if not chunk_id in chunks_to_update:
			chunks_to_update.append(chunk_id)
	
	for chunk_id in chunks_to_update:
		chunk_manager.chunks[chunk_id].update()
	chunk_manager.update()


func prepare_randomize_area(top_position, size: int):
	reset_optimize_container()
	
	var cell_position
	for x in range(size):
		for y in range(size):
			var value = optimize_area[x + y * OPTIMZE_AREA_SIZE]
			if value == -1:
				cell_position = Vector2(top_position.x + x, top_position.y + y)
				
				# possible values 0, 1, 2, 3
				value = Global.get_fixed_value_for_position(cell_position.x, cell_position.y) % CellManager.TILE_SIZES
				
				# check if area is the same biome
				#if not area_same_tile(cell_position, value + 1):
				#	continue
				
				var temp = 0
				var occupied = false
				for ix in range(value + 1):
					for iy in range(value + 1):
						if (x + ix) + (iy + y) * OPTIMZE_AREA_SIZE >= optimize_area.size():
							occupied = true
							break
						if optimize_area[(x + ix) + (iy + y) * OPTIMZE_AREA_SIZE] != -1:
							occupied = true
							break
					if occupied:
						break
				if occupied:
					continue
				
				# set cells 1x1,2x2,3x3,4x4 // +1 because of start at 0
				for ix in range(value + 1):
					for iy in range(value + 1):
						optimize_area.set(ix + x + (iy + y) * OPTIMZE_AREA_SIZE, value)


func reset_optimize_container():
	for i in range(OPTIMZE_AREA_SIZE * OPTIMZE_AREA_SIZE):
		optimize_area.set(i, -1)


func debug_print_randomize_area():
	var debug_text = ""
	for i in range(OPTIMZE_AREA_SIZE):
		for _i in range(OPTIMZE_AREA_SIZE):
			debug_text += str(optimize_area[_i + i * OPTIMZE_AREA_SIZE] + 1) + " "
		debug_text += "\n"
	print(debug_text)


func retrieve_randomize_area_tile_type(cell_position, erase_ids: bool):
	var tile_type = optimize_area[cell_position.x + cell_position.y * OPTIMZE_AREA_SIZE]
	if tile_type == -1:
		return -1
	debug_print_randomize_area()
	for x in range(tile_type + 1):
		for y in range(tile_type + 1):
			optimize_area.set((cell_position.x + x)  + (cell_position.y + y) * OPTIMZE_AREA_SIZE, -1)
	debug_print_randomize_area()
	return tile_type


func reset_tile_group(cell):
	for x in range(cell.tile_type + 1):
		for y in range(cell.tile_type + 1):
			var c = chunk_manager.get_cellv(Vector2(cell.tile_origin.x + x, cell.tile_origin.y + y))
			_change_cell(c, cell.tile_name)



###############################################################################
# Set area
###############################################################################

func randomize_area(top_position, size: int):
	# set area to 1
	prepare_randomize_area(top_position, size)
#	debug_print_randomize_area()
	
	var cell
	var tile_name
	var rand_val = Global.get_fixed_value_for_position(top_position.x, top_position.y)
	var pos_val
	var cell_position
	
	for x in range(size):
		for y in range(size):
			cell_position = top_position + Vector2(x, y)
			cell = chunk_manager.get_cellv(cell_position)
			if cell == null:
				continue
			
			tile_name = cell.tile_name
			var tile_type = retrieve_randomize_area_tile_type(Vector2(x, y), true) #pos_val % CellManager.TILE_SIZES
			if tile_type == -1:
				continue
			
			var cell_size = CellManager.get_cell_size(tile_name, tile_type)
			var cell_texture = TilesetManager.get_tileset_texture(CellManager.get_cell_texture_name(tile_name, tile_type))
			var region_rect = CellManager.get_cell_region(tile_name, Vector2.ZERO, tile_type)
			var cell_pos = cell.position
			cell.size = cell_size
			cell.visible = true
			cell.texture = cell_texture
			cell.texture_region_rect = Rect2(
				region_rect[0], region_rect[1],
				region_rect[2], region_rect[3])
			match tile_type:
				0:
					cell.tile_offset = Vector2(0, 0)
				1:
					cell.tile_offset = Vector2(-16, -12)
				2:
					cell.tile_offset = Vector2(-32, -18)
				3:
					cell.tile_offset = Vector2(-48, -23)
				
			for ix in range(tile_type+1):
				for iy in range(tile_type+1):
					if not (ix == 0 and iy == 0):
						cell = chunk_manager.get_cellv(cell_position + Vector2(ix, iy))
						if cell == null:
							continue
						cell.visible = false
						cell.tile_origin = cell_position


func area_same_tile(cell_position, size):
	for x in range(size):
		for y in range(size):
			var cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
			if not cell:
				return false
	var same = true
	var tile_name = chunk_manager.get_cellv(cell_position).tile_name
	for x in range(size):
		for y in range(size):
			var cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
			if not (cell.tile_name == tile_name and cell.visible):
				return false
	return true


func _change_cell(cell, tile_name: String):
	cell.texture = TilesetManager.get_tileset_texture(CellManager.get_cell_texture_name(tile_name))
	cell.tile_name = tile_name
	cell.visible = true
	cell.size = CellManager.get_cell_size(tile_name)
	var region_rect = CellManager.get_cell_region(tile_name)
	cell.texture_region_rect = Rect2(
		region_rect[0], region_rect[1],
		region_rect[2], region_rect[3])
	

func _create_cell(cell_x: int, cell_y: int, tile_name: String, offset: Vector2 = Vector2.ZERO):
	var cell = Cell.duplicate()
	created_cells += 1
	cell.tile_name = tile_name
	cell.visible = true
	cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
	cell.position.x -= Global.CELL_SIZE.x / 2
	cell.tile_type = -1
	
	if offset.y == 0:
		var cell_texture = CellManager.get_cell_texture_name(tile_name)
		cell.texture = TilesetManager.get_tileset_texture(cell_texture)
		var region_rect = CellManager.get_cell_region(tile_name, offset)
		cell.size = CellManager.get_cell_size(tile_name)
		cell.texture_region_rect = Rect2(
			region_rect[0], region_rect[1],
			region_rect[2], region_rect[3])
	else:
		print("no height implemented!")
	return cell


var created_cells = 0
func set_cell_data(cell_x: int, cell_y: int, tile_name, offset := Vector2(0, 0)):
	if cell_x < 0 or cell_y < 0:
		return
	
	var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
	if cell == null:
		cell = _create_cell(cell_x, cell_y, tile_name, offset)
	
	cell.offset = offset
	var chunk = chunk_manager.set_cellv(Vector2(cell_x, cell_y), cell)
	chunk.update()
	chunk_manager.update()


func set_cellv(cell_position: Vector2, tile_name: String, offset := Vector2(0, 0)):
	set_cell(int(cell_position.x), int(cell_position.y), tile_name, offset)


func set_cell(cell_x: int, cell_y: int, tile_name: String, offset := Vector2(0, 0)):
	if cell_x < 0 or cell_y < 0:
		return
	
	var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
	if cell == null:
		cell = _create_cell(cell_x, cell_y, tile_name, offset)
	cell.offset = offset
	var chunk_id = chunk_manager.set_cellv(Vector2(cell_x, cell_y), cell)
	chunk_manager.chunks[chunk_id].update()
	chunk_manager.update()


func get_cell(cell_x: int, cell_y: int):
	var chunk = _get_chunk(cell_x, cell_y) 
	if chunk == null:
		print("no chunk")
		return null
		
	if not chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] == null:
		#print("no cell: ", TileMapUtils.chunk_cell_to_1D(cell_x, cell_y))
		return null
	return chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)]


func _get_chunk(cell_x: int, cell_y: int):
	var chunk_position = calc_chunk_position(cell_x, cell_y)
	if chunks.has(chunk_position):
		return chunks[chunk_position]
	return null


func calc_chunk_position(cell_x: int, cell_y: int):
	var x = int(cell_x / Global.CHUNK_SIZE.x)
	var y = int(cell_y / Global.CHUNK_SIZE.y)
	
	if cell_x < 0:
		x -= 1
	
	if cell_y < 0:
		y -= 1
	
	return Vector2(x, y)


func _create_chunk(cell_x: int, cell_y: int):
	var chunk_position = calc_chunk_position(cell_x, cell_y)
	print("creating chunk for ", chunk_position)
	var chunk = _get_chunk(cell_x, cell_y)
	if chunk != null:
		return chunk
	
	chunk = Chunk.new()
	chunks[chunk_position] = chunk
	
	return chunk


func _updateused_rect(cell):
	if cell.position.x < used_rect.position.x:
		used_rect.position.x = cell.position.x
	if cell.position.y < used_rect.position.y:
		used_rect.position.y = cell.position.y
		
	if cell.position.x + Global.CELL_SIZE.x > used_rect.size.x:
		used_rect.size.x = cell.position.x
	if cell.position.y + Global.CELL_SIZE.y > used_rect.size.y:
		used_rect.size.y = cell.position.y

