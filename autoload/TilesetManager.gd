extends Node
"""
Custom tilesets for isometric map with individual cell heights.

tileset:
	- texture_id = texture_path

will be loaded as
	mod_name + texture_id 

"""


var tilesets = {}


func _ready():
	pass


func get_tileset(tileset_name: String):
	return tilesets[tileset_name]


func load_tileset(mod_name: String, tileset_path: String):
	var file = File.new()
	
	if file.open(tileset_path, File.READ) != OK:
		printerr("Couldn't load tileset: ", tileset_path)
		return
	
	var content = JSON.parse(file.get_as_text())
	
	if content.error != OK:
		printerr("Couldn't read tileset file: ", tileset_path)
		return
	
	content = content.result
	
	for key in content.keys():
		tilesets[mod_name+key] = content[key]
	
