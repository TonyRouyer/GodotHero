extends Node

const WALLS = {
	"wooden_wall" = {
		"index": 0, 
		"cost": 10, 
		"region": Rect2(0,48,16,16), 
		"texture": preload("res://Sprites/terrain/wooden_wall.png") },
	"stone_wall" = {
		"index": 1, 
		"cost": 15, 
		"region": Rect2(0,48,16,16), 
		"texture": preload("res://Sprites/terrain/stone_wall.png") },
}

const FLOORS = {
	"dirt" = {
		"index": 33, 
		"cost": 8,
		"texture": preload("res://Sprites/terrain/dirt.png") },
	"grass" = {
		"index": 34, 
		"cost": 1, 
		"texture": preload("res://Sprites/terrain/grass.png") },
	"wood" = {
		"index": 31, 
		"cost": 10, 
		"texture": preload("res://Sprites/terrain/wood.png") },
	"stone" = {
		"index": 32, 
		"cost": 15, 
		"texture": preload("res://Sprites/terrain/stone.png") },
}

const DOORS = {
	"wooden_door" = {"index": 20, "cost": 20, "texture": preload("res://Sprites/items/wooden_door.png")},
	"reinforced_door" = {"index": 21, "cost": 25, "texture": preload("res://Sprites/items/reinforced_door.png")},
}

const USABLE_OBJECTS = {
	"bed": {
		"name": "bed", 
		"category": "furniture", 
		"texture": preload("res://Sprites/items/bed_full.png"), 
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/Usables/bed.tscn") },
	"anvil": {
		"name": "anvil", 
		"category": "craft", 
		"texture": preload("res://Sprites/items/anvil.png"),
		"region": Rect2(0,0,16,16) , 
		"scene": preload("res://Scenes/Level/Objects/Usables/anvil.tscn") },
	"training_dummy": {
		"name": "training_dummy", 
		"train": "furniture", 
		"texture": preload("res://Sprites/items/training_dummy.png"),
		"region": Rect2(0,0,16,21), 
		"scene": preload("res://Scenes/Level/Objects/Usables/training_dummy.tscn") },
	"luth": {
		"name": "luth", 
		"category": "divertisement", 
		"texture": preload("res://Sprites/items/luth.png"),
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/Usables/luth.tscn") },
	"furnace": {
		"name": "furnace", 
		"category": "craft", 
		"texture": preload("res://Sprites/items/furnace.png"),
		"region": Rect2(0,0,16,16), 
		"scene": preload("res://Scenes/Level/Objects/Usables/furnace.tscn") },
	"table": {
		"name": "table", 
		"category": "furniture", 
		"texture": preload("res://Sprites/items/table.png"),
		"region": Rect2(0,0,64,32), 
		"scene": preload("res://Scenes/Level/Objects/Usables/table.tscn") },
}
