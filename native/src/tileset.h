#ifndef SH_TILESET_H
#define SH_TILESET_H

#include <Texture.hpp>
#include <String.hpp>

namespace godot::sh {

struct Tileset {
    Ref<Texture> texture;
    String path;
};

}

#endif