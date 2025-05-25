extends Node2D

@export var node_name:String = "luth"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 20
var used: bool = false
var x_size: int
var y_size: int
var hero_in_use: Hero = null

func _ready():
	TimeManager.connect("time_tick", _update_entertainement)

func _update_entertainement(_hour:int, _minute:int) -> void:
	if hero_in_use:
		hero_in_use.entertainment += 2

func use(hero : Hero):
	var marker = $Marker2D
	
	if hero:
		print(hero.name, " use ", self.name)
		hero_in_use = hero
		var animation_player = hero.get_node("AnimatedSprite2D/AnimationPlayer")
		hero.set_physics_process(false)
		hero.position = marker.global_position
		var animation_name: String = "" 
		match rotate_state:
			0:
				animation_name = "hit_up"
			1:
				animation_name = "hit_left"
			2:
				animation_name = "hit_down"
			3:
				animation_name = "hit_right"
		animation_player.play(animation_name) 


func exit(hero):
	print("exit ", self.name)
	if hero:
		var hero_sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero_sprite.flip_h = false
	used = false


func rotate_item(side):
	match side:
		"front":
			#choix de la taille et du placement du coolision shape
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)
			#choix et mise en place du sprite
			%Sprite.set_region_rect(Rect2(16,0,16,16))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,16)
			#Placement du marker
			$Marker2D.position = Vector2(8,16)
		"right_side":
			%CollisionShape2D.shape.size = Vector2(32,16)
			%CollisionShape2D.position = Vector2(16,24)

			%Sprite.set_region_rect(Rect2(32,0,16,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,16)

			$Marker2D.position = Vector2(24,32)
		"back":
			%CollisionShape2D.shape.size = Vector2(16,32)
			%CollisionShape2D.position = Vector2(8,16)

			%Sprite.set_region_rect(Rect2(0,0,16,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(8,16)

			$Marker2D.position = Vector2(8,32)
		"left_side":
			%CollisionShape2D.shape.size = Vector2(32,16)
			%CollisionShape2D.position = Vector2(16,24)

			%Sprite.set_region_rect(Rect2(32,0,16,32))
			%Sprite.flip_h = true
			%Sprite.position = Vector2(24,16)

			$Marker2D.position = Vector2(8,32)
			
	x_size = %CollisionShape2D.shape.size.x
	y_size = %CollisionShape2D.shape.size.y
