extends Node


var _map := TileMap.new()

var gui
var world
var camera

var _timers = {}





const groups = {
	"selectable_units" : "selectable_units",
	"selected_units" : "selected_units",
	"units" : "units",
	"buildings": "buildings"
}


enum Buildings {
	NONE = -1,
	TRAINING_CAMP,
	SIGN_POST,
}

const BuildingNames = {
	Buildings.NONE : "NONE",
	Buildings.SIGN_POST : "SignPost",
	Buildings.TRAINING_CAMP : "TrainingCamp",
}

const BuildingsDict = {
	Buildings.NONE : "NONE",
	Buildings.SIGN_POST : "SIGN_POST",
	Buildings.TRAINING_CAMP : "TRAINING_CAMP",
}

const BuildingPlacement = {
	Buildings.NONE : [],
	Buildings.SIGN_POST : [Vector2(0, 0)],
	Buildings.TRAINING_CAMP : [
			Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0),
			Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(3, 1),
			Vector2(0, 2), Vector2(1, 2), Vector2(2, 2), Vector2(3, 2),
			Vector2(0, 3), Vector2(1, 3), Vector2(2, 3), Vector2(3, 3)
			],
}

var BuildingTextures = {
	BuildingNames[Buildings.TRAINING_CAMP] : preload("res://textures/MilitaryBuildingTrainingCamp.tres"),
	BuildingNames[Buildings.SIGN_POST] : preload("res://textures/MilitaryBuildingSignPost.tres"),
}


#https://stronghold.fandom.com/wiki/Melee_Units
enum Units {
	NONE = -1,
	SPEARMAN,
	KNIGHT,
}

const UnitNames = {
	Units.NONE : "NONE",
	Units.SPEARMAN : "Spear man",
	Units.KNIGHT : "Knight",
}

const UnitTemplates = {
	Units.SPEARMAN : preload("res://mods/base/units/UnitSpearMan.tscn"),
	Units.KNIGHT : preload("res://mods/base/units/UnitKnight.tscn"),
}


const CELL_SIZE := Vector2(64, 32)
const CELL_X = CELL_SIZE.x
const CELL_Y = CELL_SIZE.y
const CELL_X_HALF = CELL_SIZE.x / 2
const CELL_Y_HALF = CELL_SIZE.y / 2

const CHUNK_SIZE = Vector2(40, 40)#Vector2(50, 50)
const MAP_SIZE = 3000000000 # arbitrary large number for 1Dimensional array of cells/tiles
const MAX_CHUNKS_SIZE_WIDTH = 128 #500
const CACHE_CELLS_SIZE = 5000

const MAX_CELL_HEIGHT = 124
const PIXEL_PER_HEIGHT = 8

const MAX_INT = 9223372036854775807
const MAX_SQURE_INT = 3000000000 #3037000499

func _ready():
	add_child(_map)
	_map.cell_size = Vector2(64, 32)
	_map.mode = TileMap.MODE_ISOMETRIC


func world_to_isotile(position: Vector2) -> Vector2:
	return _map.world_to_map(position)


func isotile_to_world(position: Vector2) -> Vector2:
	return _map.map_to_world(position)


func get_mouse_center_isometric() -> Vector2:
	return isotile_to_world(world_to_isotile(_map.get_global_mouse_position()))


func set_timer(timer_name : String):
	_timers[timer_name] = OS.get_system_time_msecs()


func get_time(timer_name : String, message = ""):
	if not _timers.has(timer_name):
		return
	if message.empty():
		message = timer_name + " took: "
	print(message, OS.get_system_time_msecs() - _timers[timer_name])
