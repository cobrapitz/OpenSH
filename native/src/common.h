#ifndef GD_COMMON_H
#define GD_COMMON_H

#include <cassert>
#include <Godot.hpp>

#define assertm(expr, msg) assert(((void)msg, expr))

// defined in common.cpp
extern real_t CHUNK_SIZEX;
extern real_t CHUNK_SIZEY;
extern real_t MAX_CHUNKS_SIZE_WIDTH;

extern const int MAX_CELL_HEIGHT;

#endif