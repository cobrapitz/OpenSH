extends Camera2D


var _zoom_speed = 150.0
var _zoom_margin = 0.1

var _zoom_position = Vector2.ZERO
var _zoom_factor = 1.0

const zoom_min = 0.2
const zoom_max = 3.0

var _speed = 17.0


func _ready():
	pass


func _process(delta: float) -> void:
	var target = _get_move_input() * _speed * zoom
	
	position.x = lerp(position.x, position.x + target.x, _speed * delta)
	position.y = lerp(position.y, position.y + target.y, _speed * delta)
	
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
		_zoom_factor += 0.1
		_zoom_position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
		_zoom_factor -= 0.1
		_zoom_position = get_global_mouse_position()

