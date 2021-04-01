extends Node2D


export(TileSet) var tileset : TileSet = null


onready var chunk_manager = $ChunkManager

const Cell = preload("res://custom_tile_map/Cell.tres")

var chunks = {}

var used_rect := Rect2()

var shapes = []
var pols = []



func _ready():
	pass


func set_cellv(cell_position: Vector2, tile_id: int, offset := Vector2(0, 0)):
	set_cell(cell_position.x, cell_position.y, tile_id, offset)


func set_cell(cell_x: int, cell_y: int, tile_id: int, offset := Vector2(0, 0)):
	if cell_x < 0 or cell_y < 0:
		return
	
	var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
	if cell == null:
		cell = Cell.duplicate()
		cell.visible = false
		cell.position = TileMapUtils.map_to_world(Vector2(cell_x, cell_y))
		cell.position.x -= Global.CELL_SIZE.x / 2
		cell.texture = tileset.tile_get_texture(tile_id)
		#cell.texture_path = 
		cell.size = Vector2(64, 124)
		cell.texture_region_rect = Rect2(Vector2(0, 0), Vector2(64, 124))
	cell.offset = offset
	
	var chunk = chunk_manager.set_cellv(Vector2(cell_x, cell_y), cell)
	
	#print("from -> ", cell_x, ", ", cell_y, " in chunk: (", chunk_manager.get_chunk_id(Vector2(cell_x, cell_y)), ")")
	#chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] = cell


func get_cell(cell_x: int, cell_y: int):
	var chunk = _get_chunk(cell_x, cell_y) 
	if chunk == null:
		print("no chunk")
		return null
		
	if not chunk.cells[TileMapUtils.chunk_cell_to_1D(cell_x, cell_y)] == null:
		#print("no cell: ", TileMapUtils.chunk_cell_to_1D(cell_x, cell_y))
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

