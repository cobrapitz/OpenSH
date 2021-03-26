extends Polygon2D


func _ready():
	var pol = []
	
	pol.append(Vector2(0,0))
	pol.append(Vector2(1,0))
	pol.append(Vector2(1,1))
	pol.append(Vector2(0,1))
	
	polygon = pol
	
	set_process(false)
	hide()


func _process(delta: float) -> void:
	polygon[2] = get_global_mouse_position()
	
	polygon[1].y = polygon[2].y
	polygon[1].x = polygon[0].x
	
	polygon[3].x = polygon[2].x
	polygon[3].y = polygon[0].y


func start(start_position : Vector2):
	set_process(true)
	show()
	polygon[0] = start_position


func get_select_rect(correct = true) -> Rect2:
	var rect = Rect2(polygon[0], polygon[2] - polygon[0])
	return rect 


func stop():
	hide()
	set_process(false)
