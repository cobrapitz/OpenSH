extends Node
"""
This holds the data to all cells.
The dictionary data structure makes it easy to modify it externally.

Textures will be assigned by the mod loader.
"""


var cells := {}



func get_cell_data(cell_id):
	return cells[cell_id]


func load_cells(mod_name: String, tiles_path: String):
	var file = File.new()
	
	if file.open(tiles_path, File.READ) != OK:
		printerr("Couldn't load tileset: ", tiles_path)
		return
	
	var content = JSON.parse(file.get_as_text())
	
	if content.error != OK:
		printerr("Couldn't read tileset file: ", tiles_path)
		return
	
	content = content.result
	
	for key in content.keys():
		cells[mod_name+key] = {}
		cells[mod_name+key].region_rect = content[key].region_rect
		cells[mod_name+key].tileset = mod_name + content[key].texture
