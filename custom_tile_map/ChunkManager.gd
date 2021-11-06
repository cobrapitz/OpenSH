extends Node2D


var shown_chunks = []
var chunks = []

var to_draw_ids = []

var redraw_chunks = []


func _ready():
	Global.set_timer(name)
	
	# prepare for insertion of chunks, only width is important bc of 1Dim array
	# of chunks see get_chunk_id
	#chunks.resize(Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH)
	for i in range(Global.MAX_CHUNKS_SIZE_WIDTH * Global.MAX_CHUNKS_SIZE_WIDTH):
		var chunk = Chunk.new()
		chunk.chunk_position = chunk_id_to_chunk_pos(i)
		add_child(chunk)
		chunks.append(chunk)
		chunk.fill_empty()
	
	Global.get_time(name)


func _process(delta: float):
	if not redraw_chunks.empty():
		_update_chunks()


func _update_chunks():
	for chunk_id in redraw_chunks:
		chunks[chunk_id].update()
	#update()
	redraw_chunks.clear()


func _draw_chunk(idx: int):
	pass


func _draw():
	for chunk in chunks:
		chunk.show()
	return
	var mp = get_chunk_position_world(get_global_mouse_position())
	var draw_ids = get_surrounding_chunks(mp, 5)
	for idx in draw_ids:
		if idx >= chunks.size():
			continue
		if idx in to_draw_ids:
			to_draw_ids.erase(idx)
			if not chunks[idx].visible:
				chunks[idx].show()
		elif not chunks[idx].visible:
			chunks[idx].show()
	for idx in to_draw_ids:
		if idx >= chunks.size():
			continue
		chunks[idx].hide()
	to_draw_ids = draw_ids


func get_surrounding_chunks(chunk_pos, radius):
	var chunk_ids = []
	
	var w = []
	var h = []
	for i in range(radius):
		w.append(i - int(radius/2))
		h.append(i - int(radius/2))
	
	for x in w:
		for y in h:
			var cx = chunk_pos.x + x + y
			var cy = chunk_pos.y + y - x
			chunk_ids.append(chunk_pos_to_chunk_id(Vector2(cx, cy)))
			chunk_ids.append(chunk_pos_to_chunk_id(Vector2(cx + 1, cy)))
	
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
	var chunk_id = get_chunk_id(cell_position)
	
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	if chunk_id >= chunks.size():
		return -1
	
	if not chunks[chunk_id].filled:
		chunks[chunk_id].fill()
		chunks[chunk_id].update()
	
	chunks[chunk_id].set_cellv(cell_position, cell)
	
	if not chunk_id in redraw_chunks:
		redraw_chunks.append(chunk_id)
	
	return chunk_id


func get_cellv(cell_position: Vector2):
	var chunk_id = get_chunk_id(cell_position)
	
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	
	return chunks[chunk_id].get_cell_by_position(cell_position)


func set_cell_refv(cell_position: Vector2, cell):
	var chunk_id = get_chunk_id(cell_position)
	
	chunks[chunk_id].set_cell_ref(
			int(cell_position.x) % int(Global.CHUNK_SIZE.x), 
			int(cell_position.y) % int(Global.CHUNK_SIZE.y),
			cell)


func get_cell_refv(cell_position: Vector2):
	var chunk_id = get_chunk_id(cell_position)
	
	return chunks[chunk_id].get_cell_ref(
		int(cell_position.x) % int(Global.CHUNK_SIZE.x),
		int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	)


func reset_cell_refv(cell_position: Vector2):
	var chunk_id = get_chunk_id(cell_position)
	
	chunks[chunk_id].reset_cell_ref(
			int(cell_position.x) % int(Global.CHUNK_SIZE.x), 
			int(cell_position.y) % int(Global.CHUNK_SIZE.y))



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


func hide_chunks():
	for chunk in chunks:
		for cell in chunk.cells:
			if not cell:
				continue
			cell.visible = false
		chunk.update()


###############################################################################
# Load/Save
###############################################################################

func get_save_data():
	var data = {}
	
	data["chunks_width"] = Global.MAX_CHUNKS_SIZE_WIDTH
	 
	data["chunks"] = {}
	for chunk in chunks:
		data["chunks"][var2str(chunk.chunk_position)] = chunk.get_save_data()
	return data


func load_save_data(data):
	Global.set_timer(name)
	
	var max_chunk_size_width = data["chunks_width"]
	chunks.resize(max_chunk_size_width * max_chunk_size_width)
	
	for chunk_position in data["chunks"]:
		var chunk_data = data["chunks"][chunk_position]
		
		var chunk = Chunk.new()
		chunk.chunk_position = str2var(chunk_position)
		add_child(chunk)
		chunk.visible = false
		var chunk_idx = chunk_pos_to_chunk_id(chunk.chunk_position)
		chunks[chunk_idx] = chunk
		
		chunk.load_save_data(chunk_data)
	
	Global.get_time(name)
	
	update()

