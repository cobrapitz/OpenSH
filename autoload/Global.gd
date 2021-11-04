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


const MAX_INT = 9223372036854775807
const MAX_SQURE_INT = 3000000000 #3037000499

const CELL_SIZE := Vector2(30, 16)#Vector2(64, 32)
const CELL_X = CELL_SIZE.x
const CELL_Y = CELL_SIZE.y
const CELL_X_HALF = CELL_SIZE.x / 2
const CELL_Y_HALF = CELL_SIZE.y / 2

# Map editor different chunks size as ingame since editing causes chunks to redraw
# so we shrink the chunk size for the map editor
const MAP_EDITOR_CHUNK_SIZE = Vector2(20, 20)

var CHUNK_SIZE = MAP_EDITOR_CHUNK_SIZE#Vector2(50, 50)#Vector2(50, 50)
const MAP_SIZE = int(MAX_SQURE_INT * 0.1) # arbitrary large number for 1Dimensional array of cells/tiles

# chunks is 1D Array for faster access, max chunks -> max_width * max_width
const MAX_CHUNKS_SIZE_WIDTH = 40 #500
const CACHE_CELLS_SIZE = 5000

const MAX_CELL_HEIGHT = 124
const PIXEL_PER_HEIGHT = 8


# 200 x (randi() % 2147483646)
var RANDOM_VALUES = PoolIntArray([
	1165934310, 669612565, 1424820038, 1868795075, 1940855634, 898051367, 1067670816, 1551156550, 1639847550, 106018252, 1951382077, 1077777856, 957775798, 1444661513, 1361700819, 163661895, 1441541754, 843494663, 1886753727, 929708002, 399890570, 1413156978, 1230721421, 978615599, 528192260, 809617626, 
	2050730441, 1585239794, 1869889706, 953190020, 1460899329, 930465829, 884541042, 1240859211, 257119583, 13760727, 1030178576, 303534184, 39081953, 1162109526, 442014264, 13001996, 1596448587, 1369725520, 984121976, 264456267, 1144697789, 880670563, 1119898307, 977056412, 1628336806, 
	863464975, 588032386, 2075187222, 612483302, 1916754522, 940469507, 1022269919, 1502949859, 49097677, 1938210654, 479116854, 2111170364, 712410156, 411170892, 64743945, 852469376, 398038510, 284042158, 80669883, 617322351, 1748991420, 1107105107, 1864318402, 1655196946, 209624522, 
	2063985437, 280387403, 1721722878, 1051990904, 695614564, 435994372, 1860778926, 1054527433, 1920199838, 1668807585, 185044468, 1355840676, 440762277, 91340296, 1056851303, 2106479915, 149845388, 1754993522, 2078420742, 730540045, 1220324864, 591206342, 1242092045, 1539484263, 500134710, 
	2097281562, 1503491838, 1408840812, 82514731, 2118110143, 77056488, 2011238594, 1502741861, 1644084450, 1297152632, 1790577754, 1128155123, 1712211559, 1588510544, 902326127, 2130932739, 783743451, 1217278929, 1789746899, 2053345263, 2077677550, 2066194216, 519949184, 207128069, 414503154, 
	1427422614, 2002258801, 719553860, 635318045, 645222711, 1178264623, 694130420, 1509376323, 1640372012, 417680343, 1752475664, 1111429143, 5457966, 1858173770, 661390799, 137204175, 2033112000, 1644804706, 952757164, 1415737757, 1230286723, 229938278, 1651751804, 1912360862, 1745309350, 
	219602560, 1544392077, 543835699, 1436097110, 93129540, 460015524, 215357034, 1779827218, 488261395, 464739049, 1891128889, 1870016001, 1375504288, 698241028, 2024525071, 523967891, 171973775, 1393948132, 1474241433, 798393730, 387932198, 521870215, 1614405741, 1647806137, 595423233, 
	49253952, 654721673, 628033982, 308188907, 678905977, 352479322, 1077180448, 1860281535, 1779664865, 1329677346, 1984330901, 930435987, 1898639207, 1805401418, 1511112908, 766367898, 450881110, 727910420, 1747254276, 1827638003, 1583965836, 1847907042, 942477082, 44696764,
])

var _rand = 0
func get_pseudo_random():
	_rand += 1
	return RANDOM_VALUES[int(_rand) % RANDOM_VALUES.size()]

#https://stackoverflow.com/questions/52432739/consistent-random-number-based-on-position-not-noise-based (modified)
func get_fixed_value_for_position(x, y):
	var rval = x * x * y + 2*y * y *x + RANDOM_VALUES[int(x * x + y * y) % RANDOM_VALUES.size()]
	return int(rval)


func _ready():
	randomize()
	add_child(_map)
	_map.cell_size = CELL_SIZE
	_map.mode = TileMap.MODE_ISOMETRIC
	
	#_region_gen(12, 16, 30, 23)


func _region_gen(width, height, size_x, size_y, offset=Vector2.ZERO):
	for x in range(width):
		for y in range(height):
			print("[", x * size_x, ", ", y * size_y, ", ", width, ", ", height ,"],")


func world_to_isotile(position: Vector2) -> Vector2:
	return _map.world_to_map(position)


func isotile_to_world(position: Vector2) -> Vector2:
	return _map.map_to_world(position)


func get_mouse_center_isometric() -> Vector2:
	return isotile_to_world(world_to_isotile(_map.get_global_mouse_position()))



#########################################################
# Time Measurement
#########################################################

func set_timer(timer_name : String):
	_timers[timer_name] = OS.get_system_time_msecs()


func get_time(timer_name : String, message = ""):
	if not _timers.has(timer_name):
		return
	if message.empty():
		message = timer_name + " took: "
	print(message, OS.get_system_time_msecs() - _timers[timer_name])


#########################################################
# Usages
#########################################################

const USAGES := {
	"MapEditor": 0,
	"Ingame": 1,
}

var usage = USAGES.MapEditor

func get_usage():
	return USAGES.keys()[usage]


func set_usage(usage):
	if not usage in USAGES.values():
		print("Usage not found!")
		return
	self.usage = usage
	print("set usage to ", get_usage())


