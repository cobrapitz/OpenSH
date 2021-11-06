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
	#reset_optimize_container()


func clear_map():
	chunk_manager.hide_chunks()


func batch_set_cell_size(offset, width, height, tile_name):
	var chunks_to_update = []
	var max_x = 0
	var max_y = 0
	var min_x = offset.x
	var min_y = offset.y
	
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + int(width / 2)
				var cell_y = offset.y + y - int(height / 2)
				chunk_manager.reset_cell_refv(Vector2(cell_x, cell_y))
				var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
				#set_cell(cell_x, cell_y, "base_sh_swamp_tileset", Vector2.ZERO,
				#Global.get_fixed_value_for_position(cell_x, cell_y) % 4)
	
	# fill with 2x2,3x3,4x4
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				var tile_type = Global.get_fixed_value_for_position(cell_x, cell_y)
			
				var cell_ref = chunk_manager.get_cell_refv(Vector2(cell_x, cell_y))
				
				tile_type = tile_type % CellManager.TILE_SIZES
				set_cell(cell_x, cell_y, tile_name, Vector2.ZERO, 2)
	
	# fill left empty with 1x1
	var filled = 0
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				
				var cell_ref = chunk_manager.get_cell_refv(Vector2(cell_x, cell_y))
				var c = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
				
				if c == null:
					continue
				
				#c.visible = false
				
				filled += 1
				if cell_ref == null:
					set_cell(cell_x, cell_y, tile_name, Vector2.ZERO, 0)
	print(filled)
	
	return
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				var tile_type = Global.get_fixed_value_for_position(cell_x, cell_y) % CellManager.TILE_SIZES
				
				set_cell(cell_x, cell_y, tile_name, Vector2.ZERO, tile_type)
				
				#if cell.tile_type != -1:
					#reset_tile_group(cell)
	
	#randomize_area(offset + Vector2(int(width/2), int(-height / 2)), OPTIMZE_AREA_SIZE)



###############################################################################
# Set/Get cells
###############################################################################



func set_cellv(cell_position: Vector2, tile_name: String, offset := Vector2(0, 0), tile_type = CellManager.SMALL):
	set_cell(int(cell_position.x), int(cell_position.y), tile_name, offset, tile_type)


func set_cell(cell_x: int, cell_y: int, tile_name: String, offset := Vector2(0, 0), tile_type = CellManager.SMALL):
	if cell_x < 0 or cell_y < 0:
		return
	
	# check if any of the tiles is already taken 
	var cell_position = Vector2(cell_x, cell_y)
	var cell = chunk_manager.get_cellv(cell_position)
	var cell_ref = chunk_manager.get_cell_refv(cell_position)
	
	for x in range(tile_type + 1):
		for y in range(tile_type + 1):
			if x == 0 and y == 0:
				continue
			var c = chunk_manager.get_cell_refv(cell_position + Vector2(x, y))
			if c != null and c != cell:
				return false
	
	if cell_ref != null and cell_ref == cell:
		return
	
	if cell == null:
		cell = CellManager._create_cell(cell_x, cell_y, tile_name, offset, tile_type)
	else:
		CellManager._change_cell(cell, tile_name, offset, tile_type)
		
	cell.offset = offset
	var chunk_id = chunk_manager.set_cellv(cell_position, cell)
#
	match tile_type:
		0:
			cell.tile_offset = Vector2(0, -1)
		1:
			cell.tile_offset = Vector2(-16, 0)
		2:
			cell.tile_offset = Vector2(-33, -17)
		3:
			cell.tile_offset = Vector2(-48, -23)
	
	for x in range(tile_type + 1):
		for y in range(tile_type + 1):
			var c_ref = chunk_manager.set_cell_refv(cell_position + Vector2(x, y), cell)
			var c = chunk_manager.get_cellv(cell_position + Vector2(x, y))
			
			if c_ref != null and c_ref != cell:
				continue
			
			if c != null and c != cell:
				c.visible = false
				
	cell.visible = true
	
	return true
	#return cell
	#if chunk_id != -1:
		#chunk_manager.chunks[chunk_id].update()
	#chunk_manager.update()


func get_cell(cell_x: int, cell_y: int):
	var chunk = _get_chunk(cell_x, cell_y) 
	if chunk == null:
		print("no chunk")
		return null
		
	if not chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] == null:
		#print("no cell: ", TileMapUtils.chunk_cell_to_1D(cell_x, cell_y))
		return null
	return chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)]


func reset_cell_ref(offset, width, height):
	for y in range(height * 2):
		for x in range(width * 2):
			chunk_manager.reset_cell_refv(offset + Vector2(x - width, y - height))
			
			#TODO replace all tile types with 1x1 
			



###############################################################################
# Chunks
###############################################################################

func _get_chunk(cell_x: int, cell_y: int):
	var chunk_position = TileMapUtils.chunk_cell_to_chunk_pos(cell_x, cell_y)
	if chunks.has(chunk_position):
		return chunks[chunk_position]
	return null


func _create_chunk(cell_x: int, cell_y: int):
	var chunk_position = TileMapUtils.chunk_cell_to_chunk_pos(cell_x, cell_y)
	print("creating chunk for ", chunk_position)
	var chunk = _get_chunk(cell_x, cell_y)
	if chunk != null:
		return chunk
	
	chunk = Chunk.new()
	chunks[chunk_position] = chunk
	
	return chunk





###############################################################################
# Randomize area
###############################################################################

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
			CellManager._change_cell(c, cell.tile_name)


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



###############################################################################
# Load/Save
###############################################################################

func get_save_data():
	var data = {}
	data["chunk_data"] = chunk_manager.get_save_data()
	return data


func load_save_data(data):
	# TODO add chunk size and other infos here aswell
	chunk_manager.load_save_data(data["chunk_data"])


