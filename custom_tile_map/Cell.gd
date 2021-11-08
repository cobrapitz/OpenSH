extends Resource


# for save/load
export(String) var tile_name

export(bool) var visible
export(Vector2) var size # unused probably
export(Vector2) var position
export(Vector2) var offset # used for height
export(Vector2) var tile_offset # used bc stronghold has no standard tile size

export(Texture) var texture
export(Rect2) var texture_region_rect

export(Texture) var chevron # part below a tile (needed for tiles that can have height)
export(Rect2) var chevron_region_rect

export(Array) var polygon

# used for 
export(int) var tile_type

var cell_position
var cell_ref
 

