extends Control


func _ready():
	pass


func _on_MapEditor_pressed():
	get_tree().change_scene_to(preload("res://mapeditor/MapEditorNew.tscn"))


func _on_Start_pressed():
	get_tree().change_scene_to(preload("res://Game.tscn"))
