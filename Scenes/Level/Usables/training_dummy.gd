extends Node2D

signal hero_trained(hero)

@onready var timer = $Timer

@export var node_name:String
@export var rotate_state:int
@export var cost:int
@export var views :Dictionary = {
	"front": [64,32,32,16],
	"right_side": [96,32,16,32],
	"back": [64,48,32,16],
	"left_side": [112,32,16,32]
}
var collision_pos :Dictionary = {
	"front": Vector2(6.5,2),
	"right_side": Vector2(1,10),
	"back": Vector2(-7,2), 
	"left_side":  Vector2(1,-4)
}
var used: bool = false
var hero:Hero

func _ready():
	timer.wait_time = 5


func _on_Hero_body_entered(body):
	if body is Hero:
		hero = body
		#hero.position = position + Vector2(9,2)
		hero.flip_sprite(false)
		hero.get_node("AnimatedSprite2D/AnimationPlayer").play("idle_side")
		timer.start()
		
func _on_area_2d_body_exited(_body):
	used = false
	if hero != null:
		hero.flip_sprite(false)
	hero = null
	
func _on_timer_timeout():
	if hero != null:
		hero.strength += 1
		print(hero.strength)


func rotate_item(side):
	var sprite = $Sprite2D
	var collision = $Area2D/CollisionShape2D

	if views.has(side):
		var view = views[side]
		var pos = Vector2(view[0], view[1])
		var size = Vector2(view[2], view[3])
		
		collision.position = collision_pos[side]
		sprite.region_rect = Rect2(pos, size) 



