extends Node


func _ready():
	var dir = Directory.new()
	
	var mods_base_path = ""
	
	if OS.has_feature("standalone"):
		print("Running an exported build.")
		mods_base_path = OS.get_executable_path().get_base_dir()
	else:
		print("Running from the editor.")
		mods_base_path = "res:/"
	
	mods_base_path += "/mods"
	
	print("Path to mod folder: " + mods_base_path)
	var file = File.new()
	
	var mod_base_paths = get_directory_paths(mods_base_path)
	
	for mod_name in mod_base_paths:
		load_mod(mod_name, mods_base_path)
	
	
	#file.open("cell_data.json", _File.READ)
	
	#cells_data = JSON.parse(file.get_as_text()).result
	
	#file.close()


func load_mod(mod_name: String, mods_base_path: String):
	
	#------------------------------- Tileset loader -----------------------------------
	print("#".repeat(35))
	print("Loading tilesets...")
	
	var tileset_paths = get_file_paths(mods_base_path + "/" + mod_name + "/resources/tilesets")
	for tileset_name in tileset_paths:
		print("loading tileset from: ", mods_base_path + "/" + mod_name + "/resources/tilesets/" + tileset_name)
		TilesetManager.load_tileset(mod_name + "_", mods_base_path + "/" + mod_name + "/resources/tilesets/" + tileset_name)
	
#	for tileset in TilesetManager.tilesets:
#		print("result of loading tilesets: ", tileset, " -> ", TilesetManager.tilesets[tileset])
	print("Finished loading tilesets.")
	print("#".repeat(35))
	
	#------------------------------------------------------------------
	
	#------------------------------- tiles loader -----------------------------------
	
	print("Loading tiles...")

	var tile_paths = get_file_paths(mods_base_path + "/" + mod_name + "/resources/tiles")
	for tile_name in tile_paths:
		print("loading tileset from: ", mods_base_path + "/" + mod_name + "/resources/tiles/" + tile_name)
		CellManager.load_cells(mod_name + "_", mods_base_path + "/" + mod_name + "/resources/tiles/" + tile_name)

#	for cell in CellManager.cells_data:
#		print("result of loading tiles: ", cell, " -> ", CellManager.cells_data[cell])
	print("Finished loading tiles.")
	print("#".repeat(35))


func get_directory_paths(base_folder):
	var dirs = []
	var dir = Directory.new()
	
	dir.open(base_folder)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and dir.current_is_dir():
			dirs.append(file)
	
	dir.list_dir_end()
	return dirs


func get_file_paths(base_folder):
	var dirs = []
	var dir = Directory.new()
	
	dir.open(base_folder)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not dir.current_is_dir():
			dirs.append(file)
	
	dir.list_dir_end()
	return dirs




