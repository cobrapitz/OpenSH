extends Sprite
class_name Building

export(Vector2) var building_size = Vector2.ONE

func _ready():
	add_to_group(Global.groups.buildings)
	
