#ifndef GODOT_CELLMANAGER_H
#define GODOT_CELLMANAGER_H

#include <Node.hpp>
#include <Godot.hpp>

namespace godot {

class CellManager : public Node {

    GODOT_CLASS(CellManager, Node)

private:
    Node* global;

public:
    
public:
    static void _register_methods();

    CellManager();
    ~CellManager();

    void _init();
    void _ready();
    void _process(float delta);
    void _draw();

};

}

#endif