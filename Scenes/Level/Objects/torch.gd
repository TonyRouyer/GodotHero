extends Node2D

@export var node_name:String = "torch"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 10
var used: bool = false
var x_size: int
var y_size: int


func use(_hero : Hero):
	pass

func exit(_hero: Hero):
	pass


func rotate_item(side):
	match side:
		"front":
			#choix et mise en place du sprite
			%Sprite.set_region_rect(Rect2(0,0,16,16))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,8)
		"right_side":
			%Sprite.set_region_rect(Rect2(0,0,16,16))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,8)
		"back":
			%Sprite.set_region_rect(Rect2(0,0,16,16))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,8)
		"left_side":
			%Sprite.set_region_rect(Rect2(0,0,16,16))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,8)

			
	x_size = %CollisionShape2D.shape.size.x
	y_size = %CollisionShape2D.shape.size.y
