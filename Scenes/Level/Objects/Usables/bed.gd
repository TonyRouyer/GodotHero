extends Node2D

@export var node_name:String = "bed"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 20
var used: bool = false
var x_size: int
var y_size: int


func use(hero: Hero):
	var marker = $Marker2D

	if hero:
		var animation_player = hero.get_node("AnimatedSprite2D/AnimationPlayer")
		hero.set_physics_process(false)
		hero.position = marker.global_position
		var animation_name: String = "" 
		match rotate_state:
			0:
				animation_name = "idle_down"
			1:
				hero.rotation = deg_to_rad(-90)
				animation_name = "idle_left"
			2:
				hero.rotation = deg_to_rad(180)
				animation_name = "idle_down"
			3:
				hero.rotation = deg_to_rad(90)
				animation_name = "idle_left"
		animation_player.play(animation_name) 

		

func exit(hero: Hero):
	if hero:
		var hero_sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero.rotation = 0
		hero_sprite.flip_h = false
	used = false


func rotate_item(side):
	match side:
		"front":
			#choix de la taille et du placement du coolision shape
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)
			#choix et mise en place du sprite
			%SpriteUnder.set_region_rect(Rect2(0,0,16,32))
			%SpriteUnder.flip_h = false
			%SpriteUnder.position = Vector2(8,16)
			
			%SpriteUpper.set_region_rect(Rect2(0,0,16,16))
			%SpriteUpper.flip_h = false
			%SpriteUpper.position = Vector2(8,16)
			#Placement du marker
			$Marker2D.position = Vector2(8,32)
		"right_side":
			%CollisionShape2D.shape.size = Vector2(32,32)
			%CollisionShape2D.position = Vector2(16,16)

			%SpriteUnder.set_region_rect(Rect2(32,0,32,32))
			%SpriteUnder.flip_h = false
			%SpriteUnder.position = Vector2(16,16)

			%SpriteUpper.set_region_rect(Rect2(32,0,32,32))
			%SpriteUpper.flip_h = false
			%SpriteUpper.position = Vector2(16,16)
			
			$Marker2D.position = Vector2(8,24)
		"back":
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)

			%SpriteUnder.set_region_rect(Rect2(16,0,16,32))
			%SpriteUnder.flip_h = false
			%SpriteUnder.position = Vector2(8,16)

			%SpriteUpper.set_region_rect(Rect2(16,0,16,32))
			%SpriteUpper.flip_h = false
			%SpriteUpper.position = Vector2(8,16)

			$Marker2D.position = Vector2(8,8)
		"left_side":
			%CollisionShape2D.shape.size = Vector2(32,32)
			%CollisionShape2D.position = Vector2(16,16)

			%SpriteUnder.set_region_rect(Rect2(32,0,32,32))
			%SpriteUnder.flip_h = true
			%SpriteUnder.position = Vector2(16,16)

			%SpriteUpper.set_region_rect(Rect2(32,0,32,32))
			%SpriteUpper.flip_h = true
			%SpriteUpper.position = Vector2(16,16)
			
			$Marker2D.position = Vector2(24,24)
			
	x_size = %CollisionShape2D.shape.size.x
	y_size = %CollisionShape2D.shape.size.y
