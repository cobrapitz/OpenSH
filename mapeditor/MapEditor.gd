extends Node


onready var _tilemap = $World/CustomTileMap

onready var _sidebar : Panel
onready var _height_box : SpinBox

onready var _tileset_preview_button : TextureButton
onready var _tile_preview_grid : GridContainer
onready var _tile_preview : TextureButton


func _ready():
	_sidebar = find_node("Sidebar")
	_height_box = find_node("HeightSpinBox")
	_tileset_preview_button = find_node("TilesetPreviewButton")
	_tile_preview_grid = find_node("TilePreivewGrid")
	_tile_preview = find_node("TilePreview")
	
	var region = _tilemap.get_cell_texture_region(2, Vector2())
	var texture = _tilemap.get_texture(2)
	
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	_tile_preview.texture_normal = atlas
	
	# usage examples
	#_tilemap.set_cell_world(_tilemap.cell_size.x, _tilemap.cell_size.y, 2)
	#_tilemap.set_cell_world(2 * _tilemap.cell_size.x, _tilemap.cell_size.y, 2, Vector2(5, 1))
	#_tilemap.set_cell(7, 4, 2).offset = Vector2(0, -50)
	#_tilemap.set_cell(8, 4, 2, Vector2(5, 1))


func _unhandled_input(event):
	if Input.is_action_pressed("left_ctrl"):
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_height_box.value += 1
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_height_box.value -= 1
	
	if Input.is_action_just_pressed("mouse_left"):
		#var now = OS.get_ticks_msec()
		
		var mp = _tilemap.get_global_mouse_position()
		_tilemap.set_cell_world(\
				mp.x, \
				mp.y, 19)
		_tilemap.set_cell_offset_world(mp.x, mp.y, Vector2(0, -_height_box.value))
		#print("total: ", OS.get_ticks_msec() - now)
		
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
