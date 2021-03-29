extends Sprite


var _pathIdx = -1 # for iterating through path
var _path : Array = []

var _speed : float = 120.0

func _ready():
	add_to_group(Global.groups.units)
	add_to_group(Global.groups.selectable_units)


func _process(delta: float) -> void:
	if _pathIdx != -1:
		if get_global_position().distance_to(_path[_pathIdx]) > 5.0:
			var dir = get_global_position().direction_to(_path[_pathIdx])
			global_position.x += delta * _speed * dir.x
			global_position.y += delta * _speed * dir.y
		elif !get_next_path():
			_pathIdx = -1


func set_path(path : Array):
	if path.empty():
		return false
	_path = path
	_pathIdx = 0


func get_next_path() -> bool:
	if _path.empty():
		return false
	
	_pathIdx += 1
	
	if _pathIdx >= _path.size():
		return false
	
	return true
