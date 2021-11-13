#ifndef SH_TILEMAPUTILS_H
#define SH_TILEMAPUTILS_H

#include <Godot.hpp>
#include <TileMap.hpp>


namespace godot::sh {

class TileMapUtils : public TileMap {
    GODOT_CLASS(TileMapUtils, TileMap)

private:

    static TileMapUtils *_singleton;

public:

    static inline TileMapUtils *get_singleton() {
		if (!TileMapUtils::_singleton) {
			TileMapUtils::_singleton = new TileMapUtils;
		}
		return TileMapUtils::_singleton;
	}
    
public:
    static void _register_methods();

    TileMapUtils();
    ~TileMapUtils();

    void _init();
    void _ready();

    int chunk_world_to_1D(int x, int y);
    Vector2 chunk_cell_to_chunk_pos(int x, int y);
    int chunk_cell_to_1D(int x, int y);
    int _world_to_1D(int x, int y);
    int _cell_to_1D(int x, int y);

    Vector2 get_mouse_center_isometric(Vector2 position);
};

}

#endif