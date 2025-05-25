class_name ObjectData
extends Resource


@export var object_name: String
@export var object_name_serialised : String
@export var object_size : Vector2
@export var object_price: int
@export var usable_slot: int
#@export var object_icon: AtlasTexture
#@export var object_script: Script
@export var object_tile_index: int
@export var object_tile_coord : Dictionary = {
	"front": Vector2i.ZERO,
	"left": Vector2i.ZERO,
	"back":  Vector2i.ZERO,
	"right": Vector2i.ZERO,
}
