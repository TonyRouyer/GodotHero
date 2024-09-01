extends Node2D


@export var node_name:String
@export var used :bool = false
@export var rotate_state:int
@export var cost:int
@export var views :Dictionary = {
	"front": [0,0, 32,16],
	"right_side": [32,0,16,32],
	"back": [0,16,32,16],
	"left_side": [48,0,16,32]
}





func rotate_item(side):
	var sprite = $Sprite2D

	if views.has(side):
		var view = views[side]
		var pos = Vector2(view[0], view[1])
		var size = Vector2(view[2], view[3])

		sprite.region_rect = Rect2(pos, size) 
