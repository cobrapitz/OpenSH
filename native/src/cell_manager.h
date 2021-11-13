#ifndef GODOT_CELLMANAGER_H
#define GODOT_CELLMANAGER_H

#include <Node.hpp>
#include <Godot.hpp>
#include <vector>
#include <map>

#include "tileset_manager.h"
#include "cell.h"
#include "common.h"

namespace godot {

class CellManager : public Node {

    GODOT_CLASS(CellManager, Node)

private:
    Node* global;
    TilesetManager* tileset_manager;

public:
    static const int SMALL = 0;
    static const int MEDIUM = 1;
    static const int BIG = 2;
    static const int LARGE = 3;
    static const int TILE_SIZES = 4;

    struct CellTypeData {
        int cell_width;
        int cell_height;
        Vector2 cell_size;
        String texture_name;
        std::vector<Rect2> regions;
    };
    struct CellData {
        String mod_name;
        String type;
        String variant;
        bool height_enabled;

        String chevron;
        String hills;
        CellTypeData ground_texture_data[TILE_SIZES];
    };
    struct ChevronData {
        String mod_name;
        String type;
        String variant;
        int cell_height;
        int cell_width;
        Vector2 cell_size;
        String texture;
        std::vector<Rect2> regions;
    };

    std::map<String, ChevronData> chevrons;
    std::map<String, CellData> cells;


public:
    static void _register_methods();

    CellManager();
    ~CellManager();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

    void load_cells(String mode_name, String cells_path);

    void change_cell(Ref<Cell> cell, String tile_name, Vector2 offset = Vector2::ZERO, CellType cell_type = CellManager::SMALL);
    Ref<Cell> create_cell(int cell_x, int cell_y, String tile_name, Vector2 offset = Vector2::ZERO, CellType cell_type = CellManager::SMALL);

    Vector2 get_cell_offset(CellType cell_type);
    int get_cell_height(CellID cell_id, CellType cell_type = CellManager::SMALL);

    const Rect2& get_cell_region(CellID cell_id, Vector2 offset = Vector2::ZERO, CellType cell_type = CellManager::SMALL);
    const Vector2& get_cell_size(CellID cell_id, CellType cell_type = CellManager::SMALL);
    const String& get_cell_texture_name(CellID cell_id, CellType cell_type = CellManager::SMALL);
    
    const Rect2& get_chevron_region(CellID chevron_id, Vector2 offset = Vector2::ZERO, CellType cell_type = CellManager::SMALL);
    const Vector2& get_chevron_size(CellID chevron_id, CellType cell_type = CellManager::SMALL);
    const String&  get_cell_chevron_texture_name(CellID cell_id, CellType cell_type = CellManager::SMALL);
    
    const Rect2& get_ground_cell_region(CellID cell_id, CellType cell_type = CellManager::SMALL);
    Rect2 get_cell_texture_with_shadows(CellID cell_id, CellType cell_type = CellManager::SMALL);

    bool has_shadow_enabled(CellID cell_id);
};

}

#endif