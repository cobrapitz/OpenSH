#ifndef GODOT_CELL_H
#define GODOT_CELL_H

#include <Vector2.hpp>
#include <String.hpp>
#include <Texture.hpp>
#include <Ref.hpp>
#include <Array.hpp>

namespace godot::sh {

class Cell {
public:
    bool visible;
    godot::String tile_name;
    unsigned int tile_type;

    godot::Vector2 size;
    godot::Vector2 position;
    godot::Vector2 cell_position;
    // used for height
    godot::Vector2 offset;
    // used bc stronghold has no standard tile size
    godot::Vector2 tile_offset; 
    
    godot::Ref<godot::Texture> texture;
    godot::Rect2 texture_region_rect;

    // part below a tile (needed for tiles that can have height)
    godot::Ref<godot::Texture> chevron;
    godot::Rect2 chevron_region_rect;

    Cell* cell_ref;

    godot::Array polygons;

public:

};

}

#endif