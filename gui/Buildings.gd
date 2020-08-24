extends Control


onready var btn_group_military = $MilitaryBuildings


func _ready():
	_connect_signals()
	init_building_buttons()


func _connect_signals():
	var unique_building_ids = 0
	
	for idx in range(btn_group_military.get_child_count()):
		btn_group_military.get_child(idx).connect("pressed", self, "_button_pressed", 
				[unique_building_ids, get_texture_from_preview(btn_group_military.get_child(idx).name)])
		unique_building_ids +=1


func init_building_buttons() -> void:
	pass


func _button_pressed(pressed_idx, preview_texture):
	EventSystem.trigger_event(EventSystem.Events.selected_building, [pressed_idx, preview_texture])


func get_texture_from_preview(texture_name : String) -> Texture:
	if !Global.BuildingTextures.has(texture_name):
		print("no preview texture: ", texture_name)
		return null
	return Global.BuildingTextures[texture_name]
