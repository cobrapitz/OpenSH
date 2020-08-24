extends Control


onready var info = $Info


const update_time = 0.05
var _last_update = 0.0

func _ready():
	Global.gui = self


func _process(delta: float) -> void:
	_last_update += delta
	if _last_update < update_time:
		return
	_last_update = 0.0
	info.text = ""
	info.text += "fps: %s\n" % str(Engine.get_frames_per_second())
	info.text += "current tile: %s\n" % str(Global.world_to_isotile(Global._map.get_global_mouse_position()))
	info.text += "real tile: %s\n" % str(Global.world.get_tile_by_collision(Global._map.get_global_mouse_position()))
	
	info.text += "tile height: %s\n" % \
			str(Global.world.get_tile_height(Global.world_to_isotile(Global._map.get_global_mouse_position())))
	
	var center_tile_world = Global.isotile_to_world(Global.world_to_isotile(Global._map.get_global_mouse_position()))
	center_tile_world.y += Global.CELL_Y_HALF
	info.text += "Current tile world pos: %s\n" % str(center_tile_world)
	
	if Global._map.get_global_mouse_position().x < center_tile_world.x:
		info.text += "Mouse on left side of tile\n"
	else:
		info.text += "Mouse on right side of tile\n"
	
	info.text += "Mouse Position: %s\n" % str(Global._map.get_global_mouse_position())
	return
	info.text += "Id: %s\n" % \
			str(Global.world._get_astart_id_by_position(Global.world_to_isotile(Global._map.get_global_mouse_position())))
