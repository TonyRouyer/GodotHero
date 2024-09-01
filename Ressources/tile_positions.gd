extends Node

# Définition des positions des tuiles pour les murs, les portes, les sols et les objets

#Id du terrain (autotile)
const WALL_TILES = {
	"wooden_wall" : Vector2(0, 0),
	"stone_wall" : Vector2(4, 0),
}

const DOOR_TILES = {
	"wooden_door": Vector2(9, 3),
	"reinforced_door": Vector2(9, 2)
}

const FLOOR_TILES = {
	"wooden_floor": Vector2(8, 3),
	"stone_floor": Vector2(8, 1),
	"dirt": Vector2(8, 0),
	"grass": Vector2(6, 5)
	
}


const USABLE_OBJECTS = {
	"bed": preload("res://Scenes/Level/Usables/bed.tscn"),
	"table": preload("res://Scenes/Level/Usables/table.tscn"),
	"training_dummy": preload("res://Scenes/Level/Usables/training_dummy.tscn"),
	"anvil": preload("res://Scenes/Level/Usables/anvil.tscn")
}
