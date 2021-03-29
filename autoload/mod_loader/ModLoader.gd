extends Node


func _ready():
	var dir = Directory.new()
	
	var mods_path = ""
	
	if OS.has_feature("standalone"):
		print("Running an exported build.")
		mods_path = OS.get_executable_path().get_base_dir()
	else:
		print("Running from the editor.")
		mods_path = "res://"
	
	mods_path += "/mods"
	
	print("Path to mod folder: " + mods_path)
	var file = File.new()
	
	file.open("cell_data.json", _File.READ)
	
	#cells_data = JSON.parse(file.get_as_text()).result
	
	file.close()
