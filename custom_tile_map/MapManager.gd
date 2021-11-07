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
	
	for y in range(height * 2):
		for x in range(width * 2):
			var cell_x = offset.x + x
			var cell_y = offset.y + y - height
			chunk_manager.reset_cell_refv(Vector2(cell_x, cell_y))
			var cell = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
			#set_cell(cell_x, cell_y, "base_sh_swamp_tileset", Vector2.ZERO, 
			#0)
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
				set_cell(cell_x, cell_y, tile_name, Vector2.ZERO, tile_type)
	# fill left empty with 1x1
	var filled = 0
	for y in range(height * 2):
		for x in range(width * 2):
			var cell_x = offset.x + x
			var cell_y = offset.y + y - height
			var cell_ref = chunk_manager.get_cell_refv(Vector2(cell_x, cell_y))
			var c = chunk_manager.get_cellv(Vector2(cell_x, cell_y))
			if c == null:
				continue
			
			if cell_ref == null:
				filled += 1
				set_cell(cell_x, cell_y, tile_name, Vector2.ZERO, 0)
	print("Filled ", filled, "x 1x1 tiles")



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
	
	for x in range(tile_type + 1):
		for y in range(tile_type + 1):
			var cell_ref = chunk_manager.get_cell_refv(cell_position + Vector2(x, y))
			if cell_ref != null:
				return
	
	
	if cell == null:
		cell = CellManager._create_cell(cell_x, cell_y, tile_name, offset, tile_type)
	else:
		CellManager._change_cell(cell, tile_name, offset, tile_type)
	
	# to update the chunks
	chunk_manager.set_cellv(cell_position, cell)
	
	for x in range(tile_type + 1):
		for y in range(tile_type + 1):
			var other_cell = chunk_manager.get_cellv(cell_position + Vector2(x, y))
			if other_cell == null:
				continue
			other_cell.visible = false
			chunk_manager.set_cell_refv(cell_position + Vector2(x, y), cell)
			
	cell.visible = true


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


