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
	for view in self.get_children():
		view.visible = false
		
	match side:
		"front":
			$FrontView.visible = true
			$Marker2D.position = Vector2(8,16)
			x_size = $FrontView/Area2D/CollisionShape2D.shape.size.x
			y_size = $FrontView/Area2D/CollisionShape2D.shape.size.y
		"right_side":
			$RightView.visible = true
			$Marker2D.position = Vector2(16,4)
			x_size = $RightView/Area2D/CollisionShape2D.shape.size.x
			y_size = $RightView/Area2D/CollisionShape2D.shape.size.y
		"back":
			$BackView.visible = true
			$Marker2D.position = Vector2(8,16)
			x_size = $BackView/Area2D/CollisionShape2D.shape.size.x
			y_size = $BackView/Area2D/CollisionShape2D.shape.size.y
		"left_side":
			$LeftView.visible = true
			$Marker2D.position = Vector2(16,4)
			x_size = $LeftView/Area2D/CollisionShape2D.shape.size.x
			y_size = $LeftView/Area2D/CollisionShape2D.shape.size.y
