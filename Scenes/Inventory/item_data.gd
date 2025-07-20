class_name ItemData
extends Resource

enum Type{
	DEFAULT,
	USABLE,
	WEAPON,
	JEWELRY,
	HEAD,
	CHEST,
	PANTS,
	FEET
}

@export var item_type : Type
@export var item_name: String
@export var item_name_serialised : String
@export_multiline var item_description: String
@export var item_stackable: bool
@export var item_max_stack: int
@export var item_icon: CompressedTexture2D

@export var item_effect: Script
@export var item_attack: int
@export var item_defense: int
