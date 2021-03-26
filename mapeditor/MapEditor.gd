extends Node


onready var _tilemap = $World/CustomTileMap

onready var _sidebar : Panel
onready var _height_box : SpinBox

onready var _tileset_preview_button : TextureButton
onready var _tile_preview_grid : GridContainer
onready var _tile_preview : TextureButton

onready var _map_boundary_isometric = $MapBoundaryIso
onready var _map_boundary_rect = $MapBoundaryRect

var _map_height_box : SpinBox
var _map_width_box : SpinBox


func _ready():
	_sidebar = find_node("Sidebar")
	_height_box = find_node("HeightSpinBox")
	_tileset_preview_button = find_node("TilesetPreviewButton")
	_tile_preview_grid = find_node("TilePreivewGrid")
	_tile_preview = find_node("TilePreview")
	
	_map_width_box = find_node("MapWidth")
	_map_height_box = find_node("MapHeight")
	
	var region = _tilemap.get_cell_texture_region(2, Vector2())
	var texture = _tilemap.get_texture(2)
	
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	_tile_preview.texture_normal = atlas


func _unhandled_input(event):
	if Input.is_action_pressed("left_ctrl"):
		if Input.is_action_pressed("mouse_left"):
			var mp = _tilemap.get_global_mouse_position()
			_tilemap.set_cell_world(\
					mp.x, \
					mp.y, 19)
			_tilemap.set_cell_offset_world(mp.x, mp.y, Vector2(0, -_height_box.value))
			return
			
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_height_box.value += 1
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_height_box.value -= 1
	
	if Input.is_action_just_released("mouse_left"):
		var rect : Rect2 = $SelectUnitsMarker.get_select_rect()
		$SelectUnitsMarker.stop()
		#print(rect)
	
	if Input.is_action_just_pressed("mouse_left"):
		$SelectUnitsMarker.start($SelectUnitsMarker.get_global_mouse_position())
		
	if Input.is_action_pressed("mouse_left"):
		#var now = OS.get_ticks_msec()
		
		var mp = _tilemap.get_global_mouse_position()
		
#		_tilemap.fill_chunk(mp)
#		_tilemap.draw_sourouding_chunks(mp.x, mp.y)
		#ds_tilemap._draw_chunk(mp.x, mp.y)
		
	if Input.is_action_just_pressed("mouse_middle"):
		var selected_tile = _tilemap.select_cell()
		if selected_tile != -1:
			var p = _tilemap.get_cells()[selected_tile].position
			_tilemap.set_cell_offset_world(p.x, p.y, Vector2(0, 0))
		
		return
		
		if selected_tile != -1 and _tilemap.pols[selected_tile] != null:
			_tilemap.set_tile(selected_tile, _tilemap.world_to_map(_tilemap.pols[selected_tile].position), -1)
		
	if Input.is_action_pressed("left_ctrl"):
		if Input.is_action_just_pressed("mouse_right"):
			_tilemap.add_astar_cell(Global.world_to_isotile(_tilemap.get_global_mouse_position()))
			return
		elif Input.is_action_just_pressed("mouse_left"):
			_tilemap.remove_astar_cell(Global.world_to_isotile(_tilemap.get_global_mouse_position()))
			return


func _get_isometric_boundary(map_size):
	var diag_length = sqrt(pow(_tilemap.cell_size.x * 0.5, 2) + pow(_tilemap.cell_size.y * 0.5, 2))
	
	var dx = 32 * map_size.x
	var dy = 16 * map_size.y
	
	var polygon = []
	
	polygon.append(Vector2(0, 0))
	polygon.append(Vector2(dx, dy))
	polygon.append(Vector2(0, dy*2))
	polygon.append(Vector2(-dx, dy))
	
	return polygon


func _get_rect_boundary(map_size):
	var diag_length = sqrt(pow(_tilemap.cell_size.x * 0.5, 2) + pow(_tilemap.cell_size.y * 0.5, 2))
	
	var dx = 32 * map_size.x
	var dy = 16 * map_size.y
	
	var polygon = []
	
	polygon.append(Vector2(0, 0))
	polygon.append(Vector2(dx, dy))
	polygon.append(Vector2(0, dy*2))
	polygon.append(Vector2(-dx, dy))
	
	
	return polygon


func _on_CreateMap_pressed() -> void:
	var map_size = Vector2(int(_map_width_box.get_value()), int(_map_height_box.get_value()))
	_tilemap.create(map_size)
	_map_boundary_rect.polygon = _get_isometric_boundary(map_size)

