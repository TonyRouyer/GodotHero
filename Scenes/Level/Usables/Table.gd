extends Node2D

signal hero_resting(hero)

@export var node_name:String
@export var rotate_state:int
@export var views :Dictionary = {
	"front": [64,0,32,16],
	"right_side": [96,0,16,32],
	"back": [64,16,32,16],
	"left_side": [112,0,16,32]
}
var collision_pos :Dictionary = {
	"front": Vector2(6.5,2),
	"right_side": Vector2(1,10),
	"back": Vector2(-7,2), 
	"left_side":  Vector2(1,-4)
}
var used = false

func _on_Hero_body_entered(body):
	if body is Hero:
		emit_signal("hero_resting", body)

func rotate_item(side):
	var sprite = $Sprite2D
	var collision = $Area2D/CollisionShape2D

	if views.has(side):
		var view = views[side]
		var pos = Vector2(view[0], view[1])
		var size = Vector2(view[2], view[3])
		
		collision.position = collision_pos[side]
		sprite.region_rect = Rect2(pos, size) 
