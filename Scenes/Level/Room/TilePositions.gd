extends Node

# Définition des positions des tuiles pour les murs, les portes, les sols et les objets

const WALL_TILES = {
	"wooden_wall": {
		"ANGLE_TOP_LEFT": Vector2(2, 0),
		"ANGLE_TOP_RIGHT": Vector2(3, 0),
		"ANGLE_BOTTOM_LEFT": Vector2(2, 1),
		"ANGLE_BOTTOM_RIGHT": Vector2(3, 1),
		"WALL_HORIZONTAL": Vector2(1, 0),
		"WALL_VERTICAL": Vector2(0, 0),
		"WALL_END_HORIZONTAL_LEFT": Vector2(1, 1),
		"WALL_END_HORIZONTAL_RIGHT": Vector2(4, 3),
		"WALL_END_VERTICAL_BOTTOM": Vector2(0, 2),
		"WALL_END_VERTICAL_TOP": Vector2(0, 3),
		"WALL_T_INTERSECTION_UP": Vector2(4, 1),
		"WALL_T_INTERSECTION_RIGHT": Vector2(4, 2),
		"WALL_T_INTERSECTION_DOWN": Vector2(4, 0),
		"WALL_T_INTERSECTION_LEFT": Vector2(5, 2),
		"WALL_X_INTERSECTION": Vector2(6, 2)
	},
	"stone_wall": {
		"ANGLE_TOP_LEFT": Vector2(9, 0),
		"ANGLE_TOP_RIGHT": Vector2(10, 0),
		"ANGLE_BOTTOM_LEFT": Vector2(9, 1),
		"ANGLE_BOTTOM_RIGHT": Vector2(10, 1),
		"WALL_HORIZONTAL": Vector2(8, 0),
		"WALL_VERTICAL": Vector2(7, 0),
		"WALL_END_HORIZONTAL_LEFT": Vector2(8, 1),
		"WALL_END_HORIZONTAL_RIGHT": Vector2(11, 3),
		"WALL_END_VERTICAL_BOTTOM": Vector2(7, 2),
		"WALL_END_VERTICAL_TOP": Vector2(7, 3),
		"WALL_T_INTERSECTION_UP": Vector2(11, 1),
		"WALL_T_INTERSECTION_RIGHT": Vector2(11, 2),
		"WALL_T_INTERSECTION_DOWN": Vector2(11, 0),
		"WALL_T_INTERSECTION_LEFT": Vector2(12, 2),
		"WALL_X_INTERSECTION": Vector2(13, 2)
	}
}

const DOOR_TILES = {
	"wooden_door": Vector2(5, 9),
	"reinforced_door": Vector2(4, 9)
}

const FLOOR_TILES = {
	"wooden_floor": Vector2(0, 9),
	"stone_floor": Vector2(2, 9)
}

const OBJECT_TILES = {
	"anvil": Vector2(3, 1)
}

const USABLE_OBJECTS = {
	"training_dummy": preload("res://Scenes/Level/Usables/TrainingDummy.tscn")
}
