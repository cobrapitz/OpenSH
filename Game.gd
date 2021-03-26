extends Node


onready var _trade_menu_button : Button
onready var _statistics_menu_button : Button

onready var _main_menu_button : Button
onready var _info_button : Button
onready var _delete_cursor_button : Button

onready var _overview_button : TextureButton

onready var _panel_overview : Control

onready var _buildings_display_container : Control
onready var _buildings_types_container : Control



func _ready() -> void:
	_assign_nodes()
	_connnect_signals()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_right"):
		
		if _panel_overview.is_visible():
			_panel_overview.visible = false
			return


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		
		if _panel_overview.is_visible():
			_panel_overview.visible = false
			return
		
	if Input.is_action_just_pressed("mouse_right"):
		
		if _panel_overview.is_visible():
			_panel_overview.visible = false
			return


func _on_building_type_pressed(type : String):
	for display in _buildings_display_container.get_children():
		display.hide()
	
	var buildings_display = find_node(str(type, "Buildings"))
	if buildings_display == null:
		return
	buildings_display.show()


func _on_building_pressed(pressed_idx, preview_texture):
	EventSystem.emit_signal("on_building_selected", pressed_idx, preview_texture)


func _on_overview_book_pressed():
	_panel_overview.show()


func _on_trade_pressed():
	print("open trade menu")


func _on_statistics_pressed():
	print("open stats menu")


func _on_main_menu_pressed():
	print("open main menu")


func _on_info_pressed():
	print("open info")


func _on_delete_cursor_pressed():
	print("open delete cursor")


func _assign_nodes():
	_trade_menu_button = find_node("TradeMenu")
	_statistics_menu_button = find_node("StatisticsMenu")
	
	_main_menu_button = find_node("MainMenuButton")
	_info_button = find_node("InfoButton")
	_delete_cursor_button = find_node("DeleteCursorButton")
	
	_overview_button = find_node("OverviewBookButton")
	
	_panel_overview = find_node("PanelOverview")
	
	_buildings_display_container = find_node("BuildingsDisplay")
	_buildings_types_container = find_node("BuildingTypesContainer")


func get_texture_from_preview(texture_name : String) -> Texture:
	if !Global.BuildingTextures.has(texture_name):
		#print("no preview texture: ", texture_name)
		return null
	return Global.BuildingTextures[texture_name]


func _connnect_signals():
	var unique_building_ids = 0
	for container in _buildings_display_container.get_children():
		for btn in container.get_children():
			btn.connect("pressed", self, "_on_building_pressed", 
				[unique_building_ids, get_texture_from_preview(btn.name)])
			unique_building_ids +=1
			print(str(container.name, "-", btn.name))
	
	for button in _buildings_types_container.get_children():
		button.connect("pressed", self, "_on_building_type_pressed", [button.name])
	
	_trade_menu_button.connect("pressed", self, "_on_trade_pressed")
	_statistics_menu_button.connect("pressed", self, "_on_statistics_pressed")
	
	_main_menu_button.connect("pressed", self, "_on_main_menu_pressed")
	_info_button.connect("pressed", self, "_on_info_pressed")
	_delete_cursor_button.connect("pressed", self, "_on_delete_cursor_pressed")
	
	_overview_button.connect("pressed", self, "_on_overview_book_pressed")
	_buildings_types_container.connect("pressed", self, "_on_buildings_types_pressed")
