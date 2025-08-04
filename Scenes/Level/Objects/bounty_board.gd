extends Node2D

@export var node_name:String = "bounty_board"
@export var rotate_state: int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 50
var used: bool = false
var x_size: int
var y_size: int

func use(_hero: Hero):
	pass


func exit(_hero):
	pass


func rotate_item(side):
	# S'assurer que le shape est unique à cette instance
	%CollisionShape2D.shape = %CollisionShape2D.shape.duplicate()
	
	match side:
		"front":
			#choix de la taille et du placement du coolision shape
			%CollisionShape2D.shape.size = Vector2(48,32)
			%CollisionShape2D.position = Vector2(24,16)
			#choix et mise en place du sprite
			%Sprite.set_region_rect(Rect2(0,0,48,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(24,16)
			%Sprite.z_index = 0
		"right_side":
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)
			%Sprite.set_region_rect(Rect2(96,0,16,32))
			%Sprite.flip_h = false
			%Sprite.z_index = 0
			%Sprite.position = Vector2(8,16)
		"back":
			%CollisionShape2D.shape.size = Vector2(48,32)
			%CollisionShape2D.position = Vector2(24,16)
			#choix et mise en place du sprite
			%Sprite.set_region_rect(Rect2(48,0,48,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(24,16)
			%Sprite.z_index = 1
		"left_side":
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)
			%Sprite.set_region_rect(Rect2(96,0,16,32))
			%Sprite.flip_h = true
			%Sprite.z_index = 0
			%Sprite.position = Vector2(8,16)
			
	x_size = %CollisionShape2D.shape.size.x
	y_size = %CollisionShape2D.shape.size.y
