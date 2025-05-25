extends Node

# Définition des positions des tuiles pour les murs, les portes, les sols et les objets

#Id du terrain (autotile)
const WALL_TILES = {
	"wooden_wall" : {"index": 0, "cost": 10},
	"stone_wall" : {"index": 1, "cost": 15}
}

const DOOR_TILES = {
	"wooden_door": {"index": 20, "cost": 20},
	"reinforced_door": {"index": 21, "cost": 25}
}

const FLOOR_TILES = {
	"wood":  {"index": 31, "cost": 10},
	"stone": {"index": 32, "cost": 15},
	"dirt": {"index": 33, "cost": 8},
	"grass": {"index": 34, "cost": 1},
}



const WALLS = {
	"wooden_wall" = preload("res://Sprites/terrain/wooden_wall.png"),
	"stone_wall" = preload("res://Sprites/terrain/stone_wall.png"),
}
const FLOORS = {
	"dirt" = preload("res://Sprites/terrain/dirt.png"),
	"grass" = preload("res://Sprites/terrain/grass.png"),
	"wood" = preload("res://Sprites/terrain/wood.png"),
	"stone" = preload("res://Sprites/terrain/stone.png"),
}

const DOORS = {
	"wooden_door" = preload("res://Sprites/items/wooden_door.png"),
	"reinforced_door" = preload("res://Sprites/items/reinforced_door.png"),
	
}

#const USABLE_OBJECTS = {
	#"bed": preload("res://Scenes/Level/Items/Usables/bed.tscn"),
	#"anvil": preload("res://Scenes/Level/Items/Usables/anvil.tscn"),
	#"training_dummy": preload("res://Scenes/Level/Items/Usables/training_dummy.tscn"),
	#"luth": preload("res://Scenes/Level/Items/Usables/luth.tscn"),
	#"furnace": preload("res://Scenes/Level/Items/Usables/furnace.tscn"),
	#"table": preload("res://Scenes/Level/Items/Usables/table.tscn"),
#}

const OBJECTS = {
	"table": preload("res://Scenes/Level/Objects/table.tres")
}


const ROOMS = {
	"hall": preload("res://Scenes/Level/ConstructionLogic/Room/Rooms/hall.tres"),
	"kitchen": preload("res://Scenes/Level/ConstructionLogic/Room/Rooms/kitchen.tres")
}
