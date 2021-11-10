extends YSort
class_name Chunk

const Cell = preload("res://custom_tile_map/Cell.tres")


var chunk_position: Vector2
var chunk_id: int
var cells := []

var _to_draw := []
var _drawn := []

var filled = false


class ChunkCellsSorter:
	static func sort_by_tile_type(cell, other_cell):
		if cell == null:
			return false
		elif other_cell == null:
			return true
		if cell.tile_type < other_cell.tile_type:
			return true
		return false

func _init():
	#sort_enabled = false
	connect("visibility_changed", self, "_on_visibility_changed")


func fill_empty():
	cells.resize(int(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y))


func fill():
	filled = true
	cells.resize(int(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y))
	for x in range(Global.CHUNK_SIZE.x):
		for y in range(Global.CHUNK_SIZE.y):
			cells[x + y * Global.CHUNK_SIZE.x] = CellManager._create_cell(
				(x + (chunk_position.x * Global.CHUNK_SIZE.x)),
				(y + (chunk_position.y * Global.CHUNK_SIZE.y)),
				CellManager.cells_data.keys()[0]
			)


func _sort_cells():
	#print_cells()
	cells.sort_custom(ChunkCellsSorter, "sort_by_tile_type")
	#print_cells()


func print_cells():
	var text = ""
	var i = 0
	for cell in cells:
		if cell != null:
			text += str(cell.tile_type, ", ")
			if i % 50 == 0:
				text += "\n"
		i += 1
	print(text)


const tile_type_colors =[
	Color(0.0, 1.0, 0.0, 0.2),
#	Color(1.0, 1.0, 0.0, 0.2),
#	Color(0.0, 0.0, 1.0, 0.2),
#	Color(1.0, 0.0, 0.0, 0.2),
#	Color.green,
	Color.violet,
	Color.yellow,
	Color.red,
]
func _draw():
#	for y in range(Global.CHUNK_SIZE.y):
#		for i in [0, 1]:
#			for x in range(Global.CHUNK_SIZE.x):
#				var cell_x = x + y + i
#				var cell_y = -x + y
#
#				if cell_x + cell_y * Global.CHUNK_SIZE.x >= cells.size():
#					continue
#				var cell = cells[cell_x + cell_y * Global.CHUNK_SIZE.x] 
#				if cell == null:
#					continue
#				var c = Color(
#						1 - 0.6 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 
#						1 - 0.1 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 
#						1 - 0.6 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 1)
#				if cell.chevron and cell.tile_type < 1 and cell.offset.y < 0:
#					draw_texture_rect_region(
#						cell.chevron, Rect2(cell.position + cell.offset + Vector2(0, cell.size.y), 
#						CellManager.get_chevron_size(cell.tile_name)),
#						cell.chevron_region_rect, c
#					)
#				draw_texture_rect_region(
#					cell.texture, Rect2(cell.position + cell.offset + cell.tile_offset, cell.size),
#					cell.texture_region_rect
#					#, tile_type_colors[cell.tile_type]
#				)
#
	return
	for cell in cells:
		if cell == null: #or not cell.visible:
			continue
		if cell.visible:
			var c = Color(
					1 - 0.6 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 
					1 - 0.1 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 
					1 - 0.6 * (cell.offset.y) / Global.MAX_CELL_HEIGHT, 1)
			if cell.chevron and cell.tile_type < 1 and cell.offset.y < 0:
				draw_texture_rect_region(
					cell.chevron, Rect2(cell.position + cell.offset + Vector2(0, cell.size.y), 
					CellManager.get_chevron_size(cell.tile_name)),
					cell.chevron_region_rect, c
					)
			draw_texture_rect_region(
				cell.texture, Rect2(cell.position + cell.offset + cell.tile_offset, cell.size),
				cell.texture_region_rect
				#, tile_type_colors[cell.tile_type]
				)
		elif DebugOverlay.show_hidden_tiles:
			draw_texture_rect_region(
					cell.texture, Rect2(cell.position + cell.offset + cell.tile_offset, cell.size),
					cell.texture_region_rect, Color.slateblue)
		
			#if cell.tile_name == "base_sh_grass_tileset":
			#	continue
		
#		if cell.tile_type > 0:
#			print("here")
#
			#var x = TileMapUtils.world_to_map(cell.position).x
			#var y = TileMapUtils.world_to_map(cell.position).y
			#var val = Global.get_fixed_value_for_position(x, y) % 12
			#val /= 12.0
#		else:
#			draw_texture_rect_region(
#				cell.texture, Rect2(cell.position + cell.offset + cell.tile_offset, cell.size),
#				cell.texture_region_rect, Color(1.0, 0.0, 0.0, 0.2))
#		if cell.chevron:
#			draw_texture_rect_region(
#				cell.chevron, Rect2(cell.position + cell.offset, cell.size),
#				cell.texture_region_rect)


func _on_visibility_changed():
	if visible:
		pass
	else:
		for idx in range(cells.size()):
			if cells[idx] == null:
				continue
			cells[idx].visible = false


func get_cell_idv(cell_position: Vector2):
	return int(cell_position.x + cell_position.y * Global.CHUNK_SIZE.x)


func get_cell_by_position(cell_position: Vector2):
	return cells[get_cell_idv(cell_position)]


func set_cellv(cell_position: Vector2, cell):
	cells[get_cell_idv(cell_position)] = cell


func get_cellv(cell_position: Vector2):
	cell_position.x = int(cell_position.x) % int(Global.CHUNK_SIZE.x)
	cell_position.y = int(cell_position.y) % int(Global.CHUNK_SIZE.y)
	return cell_position



######################################################
# SAVE/LOAD
######################################################

func get_save_data():
	var data = {}
	
	for cell in cells:
		if cell == null:
			continue
		data[var2str(get_cellv(TileMapUtils.world_to_map(cell.position)))] = {
			#"visible": cell.visible,
			"position": var2str(cell.position),
			#"size": var2str(cell.size), # probably don't need
			#"region_rect": var2str(cell.texture_region_rect), # probably don't need
			"tile_name": cell.tile_name,
			"offset": var2str(cell.offset),
		}
	
	return data


func load_save_data(data: Dictionary):
	cells.resize(int(Global.CHUNK_SIZE.x * Global.CHUNK_SIZE.y))
	
	for cell_map_position in data.keys():
		var cell_data = data[cell_map_position]
		
		var cell_pos = str2var(cell_data.position)
		cell_pos = TileMapUtils.world_to_map(cell_pos)
		var cell_offset = str2var(cell_data.offset)
		var cell_chunk_pos = str2var(cell_map_position)
		
		# TODO add tile type
		var cell = CellManager._create_cell(
				cell_pos.x, cell_pos.y, 
				cell_data.tile_name, cell_offset)
		
		set_cellv(cell_chunk_pos, cell)

