extends Sprite


var _cell_size := Vector2.ZERO
var _map : WeakRef = null


func _ready() -> void:
	if !_cell_size:
		set_process(false)
		hide()


func _process(delta: float) -> void:
	var mp = Vector2(get_global_mouse_position().x, get_global_mouse_position().y)
	var marker_position = Vector2.ZERO 
	mp = _map.get_ref().world_to_map(mp)
	mp.x += -1
	mp.y += -1
	
	marker_position.x = (mp.x - mp.y) * _cell_size.x * 0.5
	marker_position.y = (mp.x + mp.y) * _cell_size.y * 0.5 
	
	#sssmarker_position.y += _cell_size.y * 0.5 # offset
	
	set_global_position(marker_position)


func enable(map : TileMap, cell_size:= Vector2(48,24)):
	_cell_size = cell_size
	_map = weakref(map)
	set_process(true)
	show()


func disable():
	hide()
	set_process(false)
