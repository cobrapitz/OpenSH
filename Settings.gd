extends Node

# Singleton that contains all user defined game settings
# Stores data inside user folder in a ssettings.json file
# To access it Settings.name_option
# Remember to save setting after every change Settings.save_settings()

var resolution_height = 1080
var resolution_width = 1920

var _storage_path = "user://settings.json" # translates to %appdata% for windows
var _loaded = false # Helps to enforce singleton pattern

func _enter_tree():
	if Settings._loaded:
		printerr("Error: Settings is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Settings._loaded = false

	var file = File.new()
	if file.file_exists(_storage_path):
		file.open(_storage_path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		resolution_height = data["resolution_height"]
		resolution_width = data["resolution_width"]
	else:
		save_settings()

func save_settings():
	var file = File.new()
	file.open(_storage_path, File.WRITE)
	var data = {
		"resolution_height": resolution_height,
		"resolution_width": resolution_width,
	}
	file.store_string(to_json(data))
	file.close()
