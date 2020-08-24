extends Node


var gold = 0.0


func _ready():
	pass


func _process(delta: float) -> void:
	gold += delta
