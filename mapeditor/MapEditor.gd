extends Node


onready var _tilemap = $World/CustomTileMap


func _ready():
	_tilemap.set_cell_world(_tilemap.cell_size.x, _tilemap.cell_size.y, 2)
	_tilemap.set_cell_world(2 * _tilemap.cell_size.x, _tilemap.cell_size.y, 2, Vector2(5, 1))
	
	_tilemap.set_cell(7, 4, 2).offset = Vector2(0, -50)
	_tilemap.set_cell(8, 4, 2, Vector2(5, 1))


func _input(event):
	if Input.is_action_just_pressed("mouse_left"):
		_tilemap.set_cell_world(\
				_tilemap.get_global_mouse_position().x, \
				_tilemap.get_global_mouse_position().y, 2)
