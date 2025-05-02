extends Node2D

@export var node_name:String = "stool"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 25
var used: bool = false
var x_size: int
var y_size: int


func use(hero: Hero):
	var marker = $Marker2D

	if hero:
		var animation_player = hero.get_node("AnimatedSprite2D/AnimationPlayer")
		var sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero.set_physics_process(false)
		hero.position = marker.global_position

		match rotate_state:
			0:
				animation_player.play("idle_up")
			1:
				animation_player.play("idle_left")
			2:
				animation_player.play("idle_down")
			3:
				sprite.flip_h = true
				animation_player.play("idle_right")
		used = true
		
		
		hero.faim += 30
		print("hero faim: ", hero.faim)


func exit(hero):
	print("exit ", self.name)
	if hero:
		var hero_sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero_sprite.flip_h = false
	used = false


func rotate_item(_side):
	x_size = $Area2D/CollisionShape2D.shape.size.x
	y_size = $Area2D/CollisionShape2D.shape.size.y
