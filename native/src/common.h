#ifndef GD_COMMON_H
#define GD_COMMON_H

#include <cassert>
#include <Godot.hpp>
#include <Vector2.hpp>
#include <String.hpp>

#define assertm(expr, msg) assert(((void)msg, expr))

#define GODOT_PRINT_ERROR(message) \
    godot::api->godot_print_error(message, __FUNCTION__, __FILE__, __LINE__)

#define i32 int //int32_t
#define u32 unsigned int //uint32_t


// defined in common.cpp
extern real_t CHUNK_SIZEX;
extern real_t CHUNK_SIZEY;
extern real_t MAX_CHUNKS_SIZE_WIDTH;
extern godot::Vector2 CELL_SIZE;

extern const int MAX_CELL_HEIGHT;

extern const int MAX_SQURE_INT;
extern const int MAP_SIZE;



typedef godot::String CellID;
typedef unsigned int CellType;

// struct Vector2i {
//     i32 x, y;

//     Vector2i() = default;
//     Vector2i(i32 _x, i32 _y) : x(_x), y(_y) {}
//     Vector2i(real_t _x, real_t _y) : x((i32)_x), y((i32)_y) {}
//     Vector2i(godot::Vector2 v) : x((i32)v.x), y((i32)v.y) {}

//     Vector2i operator=(const godot::Vector2& v) {return Vector2i(v);}

//     godot::String operator godot::String() const { return "(" + godot::String::num_int64(x) + ", " + godot::String::num_int64(y) + ")";}
// };


// common class here ?




#endif