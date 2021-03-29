extends Node
"""
This holds the data to all cells.
The dictionary data structure makes it easy to modify it externally.

"""


var cells_data := {
	"stone_wall": {
		"size": Vector2(64, 128),
		"region_rect": Rect2(0,0, 64, 128),
		"texture": "res://tilesets/basic_tileset.tres",
	}
}



func get_cell_data(cell_id):
	return cells_data[cell_id]



