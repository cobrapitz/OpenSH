extends Node2D


export(TileSet) var tileset : TileSet = null


const Cell = preload("res://custom_tile_map/Cell.tres")

var chunks = {}

var used_rect := Rect2()

var shapes = []
var pols = []



func _ready():
	pass


func _draw():
	for idx in chunks.keys():
		print("drawing ", chunks[idx].cells.size(), " cells.")
		for cell in chunks[idx].cells:
			if cell == null:
				continue
			draw_texture_rect_region(cell.texture, Rect2(cell.position + cell.offset, cell.size), cell.region_rect)
			


func set_cell(cell_x: int, cell_y: int, tile_id: int, offset := Vector2(0, 0)):
	var cell = get_cell(cell_x, cell_y)
	
	if cell == null:
		print("create tile at: ", cell_x, ", ", cell_y)
		cell = Cell.duplicate(true)
		cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
		cell.position.x -= Global.CELL_SIZE.x
		cell.texture = tileset.tile_get_texture(tile_id)
		cell.size = Vector2(64, 124)
		cell.region_rect = Rect2(Vector2(777, 389), Vector2(64, 124))
		cell.offset = offset
	
	var chunk = _get_chunk(cell_x, cell_y)
	if chunk == null:
		chunk = _create_chunk(cell_x, cell_y)
	
	chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] = cell
	update()


func get_cell(cell_x: int, cell_y: int):
	var chunk = _get_chunk(cell_x, cell_y) 
	if chunk == null:
		print("no chunk")
		return null
	if not chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] == null:
		print("no cell: ", TileMapUtils.chunk_cell_to_1D(cell_x, cell_y))
		return null
	return chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)]


func _get_chunk_cell(cell_x: int, cell_y: int):
	
	return null


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
	chunk.fill_chunk_empty()
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

