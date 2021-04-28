extends Node2D


var shown_chunks = []
var chunks = []

var to_draw_ids = []


func _ready():
	Global.set_timer(name)
	
	# prepare for insertion of chunks, only width is important bc of 1Dim array
	# of chunks see get_chunk_id
	chunks.resize(Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH)
	for i in range(chunks.size()):
		var chunk = Chunk.new()
		chunk.chunk_position = chunk_id_to_chunk_pos(i)
		add_child(chunk)
		chunk.visible = false
		chunks[i] = chunk

	Global.get_time(name)


func _draw():
	var drawnChunks = 0
	
	for idx in to_draw_ids:
		chunks[idx].hide()
	
	to_draw_ids = get_surrounding_chunks(get_chunk_position_world(get_global_mouse_position()))
	
	for idx in to_draw_ids:
		drawnChunks += 1
		chunks[idx].show()
	
	#print("Drawing Map")
	#print("drawing ", drawnChunks, " chunks.")


func get_save_data():
	var data = {}
	for chunk in chunks:
		if chunk is Chunk:
			data[chunk.chunk_position] = chunk.get_save_data()
	return data


func get_surrounding_chunks(chunk_pos):
	var chunk_ids = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var cx = chunk_pos.x + x
			var cy = chunk_pos.y + y
			if cx < 0 or cy < 0:
				continue
			chunk_ids.append(chunk_pos_to_chunk_id(Vector2(cx, cy)))
	
	return chunk_ids


func create_chunkv(chunk_position: Vector2):
	var chunk = Chunk.new()
	chunk.chunk_position = chunk_position
	chunks[get_chunk_id(chunk_position)] = chunk
	add_child(chunk)
	return chunk


func create_chunk(x: int, y: int):
	var chunk = Chunk.new()
	chunk.chunk_position = Vector2(x, y)
	chunks[get_chunk_id(Vector2(x, y))] = chunk
	add_child(chunk)
	return chunk


func get_chunk_worldv(world_pos: Vector2):
	return chunks[get_chunk_id_world(world_pos)]


func get_chunk(cell_position: Vector2):
	return chunks[get_chunk_id(cell_position)]


func set_cellv(cell_position: Vector2, cell):
	var id = get_chunk_id(cell_position)
	
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	chunks[id].set_cellv(cell_position, cell)
	update()


func get_cellv(cell_position: Vector2):
	var chunk_id = get_chunk_id(cell_position)
	
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	
	return chunks[chunk_id].get_cell_by_position(cell_position)


##############################################
# Chunk helper to get chunk id and chunk position
##############################################

func get_chunk_id_world(pos: Vector2):
	var cell = TileMapUtils.world_to_map(pos)
	return get_chunk_id(cell)


func get_chunk_position_world(pos: Vector2):
	var cell = TileMapUtils.world_to_map(pos)
	return get_chunk_position(cell)


func get_chunk_id(cell_position: Vector2):
	var chunk_pos = get_chunk_position(cell_position)
	return int(chunk_pos.x + chunk_pos.y * Global.MAX_CHUNKS_SIZE_WIDTH)


func chunk_pos_to_chunk_id(chunk_pos: Vector2):
	return int(chunk_pos.x + chunk_pos.y * Global.MAX_CHUNKS_SIZE_WIDTH)


func chunk_id_to_chunk_pos(chunk_id: int) -> Vector2:
	var pos = Vector2()
	pos.x = (chunk_id % Global.MAX_CHUNKS_SIZE_WIDTH)
	pos.y = (chunk_id / Global.MAX_CHUNKS_SIZE_WIDTH)
	return pos


func get_chunk_position(cell_position: Vector2):
	var chunk_position = Vector2.ZERO
	chunk_position.x = int(cell_position.x / Global.CHUNK_SIZE.x)
	chunk_position.y = int(cell_position.y / Global.CHUNK_SIZE.y)
	return chunk_position
