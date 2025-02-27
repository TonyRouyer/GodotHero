extends Node2D

@onready var marker = $Marker2D
@onready var timer = $Timer

#A MODIFIER SPRITE TETE A PLACER AVEC ROTATIOON

@export var node_name:String = "bed"
@export var rotate_state:int
@export var cost:int = 20
@export var views :Dictionary = {
	"front": [0,32, 32,16],
	"right_side": [32,32,16,32],
	"back": [0,48,32,16],
	"left_side": [48,32,16,32]
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
		hero.set_physics_process(false)
		hero.position = marker.global_position - Vector2(0,6)
		used = true
		match rotate_state:
			0:
				hero.get_node("AnimatedSprite2D/AnimationPlayer").play("idle_right")
			1:
				hero.get_node("AnimatedSprite2D/AnimationPlayer").play("idle_down")
			2:
				hero.get_node("AnimatedSprite2D/AnimationPlayer").play("idle_left")
			3:
				hero.get_node("AnimatedSprite2D/AnimationPlayer").play("idle_up")
		timer.start()


func _on_area_2d_body_exited(_body):
	used = false
	hero = null


func rotate_item(side):
	var sprite = $Sprite2D
	var collision = $Area2D/CollisionShape2D

	if views.has(side):
		var view = views[side]
		var pos = Vector2(view[0], view[1])
		var size = Vector2(view[2], view[3])
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = size
		
		collision.set_shape(rect_shape)
		marker.position = collision_pos[side]
		sprite.region_rect = Rect2(pos, size) 
