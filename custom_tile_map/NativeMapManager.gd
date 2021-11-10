extends Node2D


export(TileSet) var tileset : TileSet = null


onready var chunk_manager = get_child(0)


func _ready():
	#reset_optimize_container()
	print("map manager starts setting some tiles...")
	for x in range(5):
		for y in range(5):
			set_cell(x * 20, y * 20, "base_debug_numbers_tileset", Vector2.ZERO, CellManager.LARGE)



func clear_map():
	chunk_manager.hide_chunks()


func batch_change_cell_height_delta(offset, width, height, height_delta):
	"""
	1. change all cells and nearby ones to 1x1 tiles
	"""
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
				
				if cell.cell_ref != null:
					var tile_it = cell.cell_ref.tile_type + 1
					for ix in range(tile_it):
						for iy in range(tile_it):
							var cell_p = Vector2(
								cell.cell_ref.cell_position.x + ix,
								cell.cell_ref.cell_position.y + iy
							)
							var other_cell = chunk_manager.get_cellv(cell_p)
							if other_cell == cell:
								#print("continue: ", ix, ", ", iy, " -> ", cell_p)
								continue
							#print(ix, ", ", iy, " -> ", cell_p)
							other_cell.cell_ref = null
							set_cell(cell_p.x, cell_p.y, other_cell.tile_name, other_cell.offset - Vector2(0, height_delta), CellManager.SMALL)
					
					cell.cell_ref = null
					set_cell(cell.cell_position.x, cell.cell_position.y, cell.tile_name, cell.offset - Vector2(0, height_delta), CellManager.SMALL)
				# if the cell is a bigger than 1x1 then replace it with 1x1 tiles
				elif cell.tile_type > CellManager.SMALL:
					for ix in range(cell.tile_type + 1):
						for iy in range(cell.tile_type + 1):
							var other_cell = chunk_manager.get_cellv(Vector2(cell_x + ix, cell_y + iy))
							other_cell.cell_ref = null
							set_cell(cell_x + ix, cell_y + iy, cell.tile_name, other_cell.offset - Vector2(0, height_delta), CellManager.SMALL)
				else:
					cell.cell_ref = null
					set_cell(cell_x, cell_y, cell.tile_name, cell.offset - Vector2(0, height_delta), CellManager.SMALL)
	#chunk_manager.update_range(offset, width, height)
	chunk_manager.update()



func batch_set_cell_size(offset, width, height, tile_name):
	"""
	1. set biome in brush-area (square shape)
	2. break all cells in area, that holds the square inside up
	   to 1x1 without changing biome (<> shape)
	3. combine areas to 4x4,3x3,2x2 (<> shape)
	4. fill rest with 1x1 (<> shape)
	"""
	
	# 1. Set biome
	for y in range(height):
		for x in range(width):
			for i in [0, 1]:
				var cell_x = offset.x + x + y + i
				var cell_y = offset.y +-x + y
				var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
				cell.tile_name = tile_name
				set_cell_biomev(Vector2(cell_x, cell_y), cell.tile_name)
	
	# 2. break all cells in area 4x4,3x3,2x2, without changing biome
	for y in range(height * 2):
		for x in range(width * 2):
			var cell_x = offset.x + x
			var cell_y = offset.y + y - height
			var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
			
			# if the cell ref and cell are not the same (and not null)
			# that means that the tile is hidden, because it's overlapped by
			# a 2x2,3x3,4x4 tile
			# note: cell_ref is always the tile on the top 
			if cell.cell_ref != null:
				var tile_it = cell.cell_ref.tile_type + 1
				for ix in range(tile_it):
					for iy in range(tile_it):
						var cell_p = Vector2(
							cell.cell_ref.cell_position.x + ix,
							cell.cell_ref.cell_position.y + iy
						)
						var other_cell = chunk_manager.get_cellv(cell_p)
						if other_cell == cell:
							#print("continue: ", ix, ", ", iy, " -> ", cell_p)
							continue
						#print(ix, ", ", iy, " -> ", cell_p)
						other_cell.cell_ref = null
						set_cell(cell_p.x, cell_p.y, other_cell.tile_name, other_cell.offset, CellManager.SMALL)
				
				cell.cell_ref = null
				set_cell(cell.cell_position.x, cell.cell_position.y, cell.tile_name, cell.offset, CellManager.SMALL)
			# if the cell is a bigger than 1x1 then replace it with 1x1 tiles
			elif cell.tile_type > CellManager.SMALL:
				for ix in range(cell.tile_type + 1):
					for iy in range(cell.tile_type + 1):
						var other_cell = chunk_manager.get_cellv(Vector2(cell_x + ix, cell_y + iy))
						other_cell.cell_ref = null
						set_cell(cell_x + ix, cell_y + iy, cell.tile_name, other_cell.offset, CellManager.SMALL)
			else:
				cell.cell_ref = null
				set_cell(cell_x, cell_y, cell.tile_name, cell.offset, CellManager.SMALL)
	
	# 3. combine areas with same biome to 2x2,3x3,4x4 areas
	for y in range(height * 2):
		for x in range(width * 2):
			var cell_x = offset.x + x
			var cell_y = offset.y + y - height
			var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
			
			# get random tile shape 1x1, 2x2, 3x3, 4x4
			var tile_type = Global.get_fixed_value_for_position(cell_x, cell_y)
			tile_type = tile_type % CellManager.TILE_SIZES
			
			var is_same = true
			var current_biome = cell.tile_name
			# check if tile type fits
			for ix in range(tile_type + 1):
				for iy in range(tile_type + 1):
					var other_cell = chunk_manager.get_cellv(Vector2(cell_x + ix, cell_y + iy))
					if other_cell.tile_name != current_biome:
						is_same = false
						break
					if other_cell.cell_ref != null:
						is_same = false
						break
				if not is_same:
					break
			
			if not is_same:
				continue
			set_cell(cell_x, cell_y, cell.tile_name, cell.offset, tile_type)
	
	#chunk_manager.update_range(offset, width, height)
	# 4. last step: fill left empty with 1x1
	# not sure if this step is needed



###############################################################################
# Set/Get cells
###############################################################################

func set_cell_biomev(cell_position: Vector2, tile_name: String):
	if cell_position.x < 0 or cell_position.y < 0:
		return
	var cell = chunk_manager.get_cellv(cell_position)
	CellManager._change_cell(cell, tile_name, cell.offset, cell.tile_type)
	chunk_manager.set_cellv(cell_position, cell)


func set_cellv(cell_position: Vector2, tile_name: String, offset := Vector2(0, 0), tile_type = CellManager.SMALL):
	set_cell(int(cell_position.x), int(cell_position.y), tile_name, offset, tile_type)


func set_cell(cell_x: int, cell_y: int, tile_name: String, offset := Vector2(0, 0), tile_type = CellManager.SMALL):
	if cell_x < 0 or cell_y < 0:
		return
	
	offset.y = max(offset.y, -Global.MAX_CELL_HEIGHT)
	
	var cell_position = Vector2(cell_x, cell_y)
	var cell = chunk_manager.get_cellv(cell_position)
	
#	for x in range(tile_type + 1):
#		for y in range(tile_type + 1):
#			var tcell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
#			if tcell.cell_ref != null:
#				return
	
	if cell == null:
		cell = CellManager._create_cell(cell_x, cell_y, tile_name, offset, tile_type)
	else:
		CellManager._change_cell(cell, tile_name, offset, tile_type)
	
	cell.cell_ref = null
	# to update the chunks
	var chunk_index = chunk_manager.set_cellv(cell_position, cell)
	
	#print("chunk_index: ", chunk_index)
	
	if tile_type > 0:
		for x in range(tile_type + 1):
			for y in range(tile_type + 1):
				var other_cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
				other_cell.visible = false
				other_cell.cell_ref = cell
			
	cell.visible = true


#func area_same_tile(cell_position, size):
#	for x in range(size):
#		for y in range(size):
#			var cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
#			if not cell:
#				return false
#	var same = true
#	var tile_name = chunk_manager.get_cellv(cell_position).tile_name
#	for x in range(size):
#		for y in range(size):
#			var cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
#			if not (cell.tile_name == tile_name and cell.visible):
#				return false
#	return true



###############################################################################
# Load/Save
###############################################################################

#func get_save_data():
#	var data = {}
#	data["chunk_data"] = chunk_manager.get_save_data()
#	return data
#
#
#func load_save_data(data):
#	# TODO add chunk size and other infos here aswell
#	chunk_manager.load_save_data(data["chunk_data"])


