extends Node2D


onready var tm = $TileMap

const ColTile = preload("res://TileReplacement.tscn")


var bodies
var immediate
var _wait_for_update = false


var pols = []
var shapes = []

func _ready():
	var size = tm.get_used_cells().size()
	pols.resize(size)
	shapes.resize(size)
	_replace_tiles()


func _replace_tiles():
	var idx = 0
	for cell in tm.get_used_cells():
		var cell_area := Polygon2D.new()
		var shape := ConvexPolygonShape2D.new()
		var cell_shape := CollisionShape2D.new()
		
		cell_shape.shape = shape
		
		$Cells.add_child(cell_area)
		$Shapes.add_child(cell_shape)
		
		var polygon = []
		polygon.append(Vector2(-1, 0))
		polygon.append(Vector2(0, -0.5))
		polygon.append(Vector2(1, 0))
		polygon.append(Vector2(1, 4))
		polygon.append(Vector2(0, 3.5))
		polygon.append(Vector2(-1, 4))
		
		for i in range(polygon.size()):
			polygon[i] *= 32.0
		
		cell_area.polygon = polygon
		cell_area.color = Color(randf(), randf(), randf())
		cell_area.position = tm.map_to_world(Vector2(cell.x, cell.y))
		
		shape.points = polygon
		cell_shape.position = tm.map_to_world(Vector2(cell.x, cell.y))
		
		cell_shape.visible = false
		
		pols[idx] = cell_area
		shapes[idx] = cell_shape
		
		idx += 1
		
		#var space_state = Physics2DDirectSpaceState.new()


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("mouse_left"):
		var mp = get_global_mouse_position()
		var cp = tm.world_to_map(mp)
		
		var selected_shapes = []
		
		for i in range(shapes.size()):
			var inside = true
			var shape : Shape2D = shapes[i].shape
			$Sprite.global_position = mp
			
			var col = shape.collide(pols[i].transform, $Sprite/CollisionShape2D.shape, $Sprite.transform)
			
			if col:
				print(i)
				selected_shapes.append(i)
		
		if !selected_shapes.empty():
			var selected_shape = selected_shapes[0]
			for idx in selected_shapes:
				if shapes[selected_shape].position.y < shapes[idx].position.y:
					selected_shape = idx
			
			pols[selected_shape].color = Color(randf(), randf(), randf())


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		var mp = get_global_mouse_position()
		var cp = tm.world_to_map(mp)
		$Sprite.global_position = mp - Vector2(0.5, 0.5)
		bodies = $Sprite.get_overlapping_bodies()
		_wait_for_update = true
	
	if _wait_for_update:
		if $Sprite.get_overlapping_bodies() != bodies:
			_wait_for_update = false
			for t in $Cells.get_children():
				t.modulate = Color.white
			bodies = $Sprite.get_overlapping_bodies()
			print("signal: ", bodies)
			var min_p = -99999999
			var highlight
			for body in bodies:
				if body.global_position.y > min_p:
					min_p = body.global_position.y
					highlight = body
			if highlight:
				highlight.modulate = Color.black


