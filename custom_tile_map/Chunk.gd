extends Resource
class_name Chunk


export(Array, Resource) var cells : Array


func fill_chunk_empty():
	cells.resize(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y)


func get_single_row(row_i: int):
	var tiles = []
	
	var x = row_i
	var y = row_i
	for i in range(Global.CHUNK_SIZE.x):
		if i % 2 == 0:
			x += 1
		else:
			y -= 1
		tiles.append(Vector2(x, y))
		
	return tiles


func fill():
	pass

