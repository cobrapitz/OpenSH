extends Sprite


var _end_position := Vector2.ZERO


func _ready():
	set_process(false)
	hide()


func _process(delta: float) -> void:
	scale.x = get_select_rect(false).size.x / texture.get_size().x
	scale.y = get_select_rect(false).size.y / texture.get_size().y


func start(start_position : Vector2):
	set_process(true)
	show()
	global_position = start_position


func get_select_rect(correct = true) -> Rect2:
	var rect = Rect2(global_position, get_global_mouse_position() - global_position)
	
	if correct:
		if global_position.x > get_global_mouse_position().x:
			rect.size.x *= -1.0
			rect.position.x -= rect.size.x
		
		if global_position.y > get_global_mouse_position().y:
			rect.size.y *= -1.0
			rect.position.y -= rect.size.y
	
	return rect 


func stop():
	hide()
	set_process(false)
