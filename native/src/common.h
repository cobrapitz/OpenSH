    #ifndef GD_COMMON_H
#define GD_COMMON_H

#include <cassert>
#include <Godot.hpp>
#include <Vector2.hpp>
#include <String.hpp>

#define assertm(expr, msg) assert(((void)msg, expr))

#define GODOT_PRINT_ERROR(message) \
    godot::api->godot_print_error(message, __FUNCTION__, __FILE__, __LINE__)

// defined in common.cpp
extern real_t CHUNK_SIZEX;
extern real_t CHUNK_SIZEY;
extern real_t MAX_CHUNKS_SIZE_WIDTH;
extern godot::Vector2 CELL_SIZE;

extern const int MAX_CELL_HEIGHT;

extern const int MAX_SQURE_INT;
extern const int MAP_SIZE;


typedef godot::String CellID;
typedef int CellType;


// common class here ?




#endif