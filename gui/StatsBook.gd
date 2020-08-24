extends TextureButton



func _ready():
	pass


func _process(delta: float) -> void:
	$Gold.text = "Gold " + str(int(Stats.gold))

