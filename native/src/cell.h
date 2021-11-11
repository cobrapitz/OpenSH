#ifndef GODOT_CELL_H
#define GODOT_CELL_H


#include <Godot.hpp>
#include <Resource.hpp>
#include <Texture.hpp>

namespace godot {

class Cell : public Resource {
    GODOT_CLASS(Cell, Resource)

public:
    bool visible;
    String tile_name;
    int tile_type;

    Vector2 size;
    Vector2 position;
    Vector2 cell_position;
    // used for height
    Vector2 offset;
    // used bc stronghold has no standard tile size
    Vector2 tile_offset; 
    
    Ref<Texture> texture;
    Rect2 texture_region_rect;

    // part below a tile (needed for tiles that can have height)
    Ref<Texture> chevron;
    Rect2 chevron_region_rect;

    Ref<Cell> cell_ref;

    Array polygons;

public:
    static void _register_methods() {
        register_property<Cell, bool>("visible", &Cell::visible, false);
        register_property<Cell, String>("tile_name", &Cell::tile_name, String{""});
        register_property<Cell, int>("tile_type", &Cell::tile_type, -1);

        register_property<Cell, Vector2>("size", &Cell::size, Vector2::ZERO);
        register_property<Cell, Vector2>("position", &Cell::position, Vector2::ZERO);
        register_property<Cell, Vector2>("cell_position", &Cell::cell_position, Vector2::ZERO);
        register_property<Cell, Vector2>("offset", &Cell::offset, Vector2::ZERO);
        register_property<Cell, Vector2>("tile_offset", &Cell::tile_offset, Vector2::ZERO);

        register_property<Cell, Ref<Texture>>("texture", &Cell::texture, Ref<Texture>{});
        register_property<Cell, Rect2>("texture_region_rect", &Cell::texture_region_rect, Rect2{});
        register_property<Cell, Ref<Texture>>("chevron", &Cell::chevron, Ref<Texture>{});
        register_property<Cell, Rect2>("chevron_region_rect", &Cell::chevron_region_rect, Rect2{});
        register_property<Cell, Ref<Cell>>("cell_ref", &Cell::cell_ref, Ref<Cell>{});
       
        register_property<Cell, Array>("polygons", &Cell::polygons, Array{});
    }

    Cell() {}
    ~Cell() {}

    void _init() {

    }
    
    void _ready() {

    }

    void _draw() {

    }

};

}

#endif