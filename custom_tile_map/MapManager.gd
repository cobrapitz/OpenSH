extends Node2D


export(TileSet) var tileset : TileSet = null


onready var chunk_manager = $ChunkManager

const Cell : Resource = preload("res://custom_tile_map/Cell.tres")

var chunks = {}

var used_rect := Rect2()

var shapes = []
var pols = []



func _ready():
	pass


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


func batch_set_cell(cells_data: Array):
	var chunks_to_update = []
	for cell_data in cells_data:
		var cell_x = int(cell_data[0])
		var cell_y = int(cell_data[1])
		var tile_name = cell_data[2]
		
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
		cell.offset = offset
	
		var chunk_id = chunk_manager.set_cellv(cell_position, cell)
		if not chunk_id in chunks_to_update:
			chunks_to_update.append(chunk_id)
	
	for chunk_id in chunks_to_update:
		chunk_manager.chunks[chunk_id].update()
	chunk_manager.update()


func _change_cell(cell, tile_name: String):
	var cell_data = CellManager.get_cell_data(tile_name)
	cell.texture = TilesetManager.get_tileset_texture(cell_data.tileset)
	cell.tile_name = tile_name
	cell.size = Vector2(cell_data.region_rect[2], cell_data.region_rect[3])
	#cell.texture_region_rect = Rect2(Vector2(0, 0), Vector2(64, 124))
	cell.texture_region_rect = Rect2(
		cell_data.region_rect[0], cell_data.region_rect[1],
		cell_data.region_rect[2], cell_data.region_rect[3])
	

func _create_cell(cell_x: int, cell_y: int, tile_name: String, offset: Vector2 = Vector2.ZERO):
	var cell = Cell.duplicate()
	created_cells += 1
	cell.visible = false
	cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
	cell.position.x -= Global.CELL_SIZE.x / 2
	#cell.texture = tileset.tile_get_texture(tile_name)
	
	var cell_data = CellManager.get_cell_data(tile_name)
	cell.texture = TilesetManager.get_tileset_texture(cell_data.tileset)
	cell.tile_name = tile_name
	
	cell.size = Vector2(cell_data.region_rect[2], cell_data.region_rect[3])
	#cell.texture_region_rect = Rect2(Vector2(0, 0), Vector2(64, 124))
	cell.texture_region_rect = Rect2(
		cell_data.region_rect[0], cell_data.region_rect[1],
		cell_data.region_rect[2], cell_data.region_rect[3])
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
	set_cell(cell_position.x, cell_position.y, tile_name, offset)


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

