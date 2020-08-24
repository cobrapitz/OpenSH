extends Sprite



func _ready():
	hide()
	set_process(false)


func enable(preview_texture : Texture):
	texture = preview_texture
	set_process(true)
	show()


func disable():
	hide()
	set_process(false)


func _process(delta: float) -> void:
	global_position = Global.get_mouse_center_isometric()


