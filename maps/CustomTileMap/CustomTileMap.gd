extends YSort

"""
Children of this node are cells/tiles
"""

var _cells = []
var _cellPositionMap = {}
export(TileSet) var tileset : TileSet = null
export(Vector2) var cell_size = Vector2(64, 32)

# used to swap between world and map coords
var _tilemap = TileMap.new() 


func _ready():
	add_child(_tilemap)
	_tilemap.cell_size = cell_size
	_tilemap.mode = TileMap.MODE_ISOMETRIC


func set_cell(x, y, tile_id, subtile = Vector2(0, 0)):
	if get_cell(x, y) != null:
		print("cell exists")
		return

	var cell = Sprite.new()
	add_child(cell)
	
	cell.position = _tilemap.map_to_world(Vector2(x, y))
	cell.position.y += cell_size.y * 0.5
	
	cell.texture = tileset.tile_get_texture(2)
	cell.region_enabled = true
	var pos = tileset.autotile_get_size(2)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	cell.region_rect = Rect2(pos, cell_size)
	
	_cellPositionMap[_tilemap.world_to_map(cell.position)] = cell
	return cell


func set_cell_world(x, y, tile_id, subtile = Vector2(0, 0)):
	var cp = _tilemap.world_to_map(Vector2(x, y))
	if get_cell(cp.x, cp.y) != null:
		print("cell exists")
		return
	
	var cell = Sprite.new()
	add_child(cell)
	
	cell.position = _tilemap.map_to_world(cp)
	cell.position.y += cell_size.y * 0.5
	
	cell.texture = tileset.tile_get_texture(2)
	cell.region_enabled = true
	var pos = tileset.autotile_get_size(2)
	pos.x += cell_size.x * subtile.x - cell_size.x
	pos.y += cell_size.y * subtile.y - cell_size.y 
	cell.region_rect = Rect2(pos, cell_size)
	
	_cellPositionMap[cp] = cell
	return cell


func get_cell(x, y):
	if _cellPositionMap.has(Vector2(x, y)):
		return _cellPositionMap[Vector2(x, y)]
	return null


func get_cells():
	return _cells


func get_used_cells_amount() -> int:
	return _cells.size()
