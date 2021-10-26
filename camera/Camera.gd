extends Camera2D


var _zoom_speed = 150.0
var _zoom_margin = 0.1

var _zoom_position = Vector2.ZERO
var _zoom_factor = 1.0

const zoom_min = 0.1
const zoom_max = 50.0

var _speed = 17.0

var base_zoom = Vector2(1.0, 1.0)


func _ready():
	Global.camera = self
	DebugOverlay.track_func(self, "get_zoom", "Zoom: ")
	zoom.x = 64.0 * 60.0 / get_viewport_rect().size.x
	zoom.y = zoom.x
	base_zoom = zoom
	#print(get_viewport_rect().size)
	#print(OS.get_window_size())


func _process(delta: float) -> void:
	var target = _get_move_input() * _speed * zoom
	position.x = lerp(position.x, position.x + target.x, _speed * delta)
	position.y = lerp(position.y, position.y + target.y, _speed * delta)
	
	return
	
	if !is_zero_approx(_zoom_factor - 1.0):
		zoom.x = lerp(zoom.x, zoom.x * _zoom_factor, delta * _zoom_speed)
		zoom.y = lerp(zoom.y, zoom.y * _zoom_factor, delta * _zoom_speed)
	
		zoom.x = clamp(zoom.x, zoom_min, zoom_max)
		zoom.y = clamp(zoom.y, zoom_min, zoom_max)
		
		_zoom_factor = 1.0


func _get_move_input() -> Vector2:
	return Vector2(
			int(Input.is_action_pressed("key_right")) - int(Input.is_action_pressed("key_left")),
			int(Input.is_action_pressed("key_down")) - int(Input.is_action_pressed("key_up")))


func _input(event: InputEvent) -> void:
	if abs(_zoom_position.x - get_global_mouse_position().x) > _zoom_margin:
		_zoom_factor = 1.0
	if abs(_zoom_position.y - get_global_mouse_position().y) > _zoom_margin:
		_zoom_factor = 1.0
	
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
		#zoom += Vector2(1.0, 1.0)
		zoom *= 2.0
		return
		_zoom_factor += 1.0
		_zoom_position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
		
		if zoom.x / 2.0 <= base_zoom.x:
			zoom = base_zoom
		else:
			zoom /= 2.0
		
#		if zoom.x - 1.0 <= 1.0:
#			zoom = Vector2(1.0, 1.0)
#		else:
#			zoom -= Vector2(1.0, 1.0)
		return
		_zoom_factor -= 1.0
		_zoom_position = get_global_mouse_position()

