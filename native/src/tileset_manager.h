#ifndef GODOT_TILESETMANAGER_H
#define GODOT_TILESETMANAGER_H

#include <Node.hpp>
#include <Godot.hpp>
#include <String.hpp>
#include <map>

#include "cell.h"
#include "common.h"
#include "tileset.h"

namespace godot {

class TilesetManager : public Node {

    GODOT_CLASS(TilesetManager, Node)

private:
    Node* global;

public:
    std::map<String, sh::Tileset> tilesets;


public:
    static void _register_methods();

    TilesetManager();
    ~TilesetManager();

    void _init();
    void _ready();

    Ref<Texture> get_tileset_texture(String tileset);
    const sh::Tileset& get_tileset(String tileset);
    void load_tileset(String mod_name, String tileset_path);    

};

}

#endif