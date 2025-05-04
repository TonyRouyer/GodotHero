extends Node

# Définition des positions des tuiles pour les murs, les portes, les sols et les objets

#Id du terrain (autotile)
const WALL_TILES = {
	"wooden_wall" : {"index": 0, "cost": 10},
	"stone_wall" : {"index": 1, "cost": 15}
}

const DOOR_TILES = {
	"wooden_door": {"pos": Vector2(9, 3), "cost": 20},
	"reinforced_door": {"pos": Vector2(9, 2), "cost": 25},
}

const FLOOR_TILES = {
	"wooden_floor": {"pos": Vector2(8, 3), "cost": 10},
	"stone_floor": {"pos": Vector2(8, 1), "cost": 15},
	"dirt": {"pos": Vector2(8, 0), "cost": 8},
	"grass":{"pos": Vector2(6, 5), "cost": 0},
	
}


const USABLE_OBJECTS = {
	"bed": preload("res://Scenes/Level/Items/Usables/bed.tscn"),
	"anvil": preload("res://Scenes/Level/Items/Usables/anvil.tscn"),
	"training_dummy": preload("res://Scenes/Level/Items/Usables/training_dummy.tscn"),
	"stool": preload("res://Scenes/Level/Items/Usables/stool.tscn"),
	"luth": preload("res://Scenes/Level/Items/Usables/luth.tscn"),
	"furnace": preload("res://Scenes/Level/Items/Usables/furnace.tscn"),
	
	"table": preload("res://Scenes/Level/Items/Decoration/table.tscn"),
}
