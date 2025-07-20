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
		"region": Rect2(16,16,16,16), 
		"texture": preload("res://Sprites/terrain/dirt.png") },
	"grass" = {
		"index": 34, 
		"cost": 1, 
		"region": Rect2(0,0,16,16), 
		"texture": preload("res://Sprites/terrain/grass.png") },
	"wood" = {
		"index": 31, 
		"cost": 10, 
		"region": Rect2(0,0,16,16), 
		"texture": preload("res://Sprites/terrain/wood.png") },
	"stone" = {
		"index": 32, 
		"cost": 15, 
		"region": Rect2(0,0,16,16), 
		"texture": preload("res://Sprites/terrain/stone.png") },
}

const DOORS = {
	"wooden_door" = {"index": 20, "cost": 20, "texture": preload("res://Sprites/objects/wooden_door.png")},
	"reinforced_door" = {"index": 21, "cost": 25, "texture": preload("res://Sprites/objects/reinforced_door.png")},
}

const USABLE_OBJECTS = {
	"bed": {
		"name": "bed", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/bed_full.png"), 
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/bed.tscn") },
	"anvil": {
		"name": "anvil", 
		"category": "craft", 
		"texture": preload("res://Sprites/objects/anvil.png"),
		"region": Rect2(0,0,16,16) , 
		"scene": preload("res://Scenes/Level/Objects/anvil.tscn") },
	"training_dummy": {
		"name": "training_dummy", 
		"train": "furniture", 
		"texture": preload("res://Sprites/objects/training_dummy.png"),
		"region": Rect2(0,0,16,21), 
		"scene": preload("res://Scenes/Level/Objects/training_dummy.tscn") },
	"luth": {
		"name": "luth", 
		"category": "divertisement", 
		"texture": preload("res://Sprites/objects/luth.png"),
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/luth.tscn") },
	"forge": {
		"name": "forge", 
		"category": "craft", 
		"texture": preload("res://Sprites/objects/forge.png"),
		"region": Rect2(0,0,16,16), 
		"scene": preload("res://Scenes/Level/Objects/forge.tscn") },
	"table": {
		"name": "table", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/table.png"),
		"region": Rect2(0,0,64,32), 
		"scene": preload("res://Scenes/Level/Objects/table.tscn") },
	"reception_desk": {
		"name": "reception_desk", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/reception_desk.png"),
		"region": Rect2(0,0,64,48), 
		"scene": preload("res://Scenes/Level/Objects/reception_desk.tscn") },
	"serving_table": {
		"name": "reception_desk", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/serving_table.png"),
		"region": Rect2(0,0,80,16), 
		"scene": preload("res://Scenes/Level/Objects/serving_table.tscn") },
	"torch": {
		"name": "torch", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/torch.png"),
		"region": Rect2(0,0,16,16), 
		"scene": preload("res://Scenes/Level/Objects/torch.tscn") },
	"toilet": {
		"name": "toilet", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/toilet.png"),
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/toilet.tscn") },
	"sink": {
		"name": "sink", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/sink.png"),
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/sink.tscn") },
	"furnace": {
		"name": "furnace", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/furnace.png"),
		"region": Rect2(0,0,32,48), 
		"scene": preload("res://Scenes/Level/Objects/furnace.tscn") },
	"loom": {
		"name": "loom", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/loom.png"),
		"region": Rect2(0,0,32,32), 
		"scene": preload("res://Scenes/Level/Objects/loom.tscn") },
	"tanning_rack": {
		"name": "tanning_rack", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/tanning_rack.png"),
		"region": Rect2(0,0,32,32), 
		"scene": preload("res://Scenes/Level/Objects/tanning_rack.tscn") },
	"workbench": {
		"name": "workbench", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/workbench.png"),
		"region": Rect2(0,0,32,48), 
		"scene": preload("res://Scenes/Level/Objects/workbench.tscn") },
	"recycling_workshop": {
		"name": "recycling_workshop", 
		"category": "furniture", 
		"texture": preload("res://Sprites/objects/recycling_workshop.png"),
		"region": Rect2(0,0,16,32), 
		"scene": preload("res://Scenes/Level/Objects/recycling_workshop.tscn") },
}
