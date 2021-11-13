#ifndef GODOT_MODLOADER_H
#define GODOT_MODLOADER_H

#include <Node.hpp>
#include <Godot.hpp>

#include "cell.h"
#include "common.h"
#include <vector>

namespace godot {

class ModLoader : public Node {

    GODOT_CLASS(ModLoader, Node)

private:

    std::vector<String> loaded_mods;
    static ModLoader *_singleton;

public:

    static inline ModLoader *get_singleton()
	{
		if (!ModLoader::_singleton) {
			ModLoader::_singleton = new ModLoader;
		}
		return ModLoader::_singleton;
	}

public:
    static void _register_methods();

    ModLoader();
    ~ModLoader();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

    void load_mod(String mod_name, String mod_base_path);

    std::vector<String>& get_directory_paths(String base_folder);
    std::vector<String>& get_file_paths(String base_folder);


};

}

#endif