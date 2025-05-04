extends Node2D

@export var node_name:String = "training_dummy"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 40
var used: bool = false
var x_size: int
var y_size: int


func use(hero : Hero):
	var marker = $Marker2D
	if hero:
		hero.set_physics_process(false)
		var animation_player = hero.get_node("AnimatedSprite2D/AnimationPlayer")
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


func exit(hero: Hero):
	print("exit ", self.name)
	if hero:
		var hero_sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero_sprite.flip_h = false
	used = false


func rotate_item(side):
	for view in self.get_children():
		view.visible = false
		
	match side:
		"front":
			$FrontView.visible = true
			$Marker2D.position = Vector2(8,24)
			x_size = $FrontView/Area2D/CollisionShape2D.shape.size.x
			y_size = $FrontView/Area2D/CollisionShape2D.shape.size.y
		"right_side":
			$RightView.visible = true
			$Marker2D.position = Vector2(24,8)
			x_size = $RightView/Area2D/CollisionShape2D.shape.size.x
			y_size = $RightView/Area2D/CollisionShape2D.shape.size.y
		"back":
			$BackView.visible = true
			$Marker2D.position = Vector2(8,8)
			x_size = $BackView/Area2D/CollisionShape2D.shape.size.x
			y_size = $BackView/Area2D/CollisionShape2D.shape.size.y
		"left_side":
			$LeftView.visible = true
			$Marker2D.position = Vector2(8,8)
			x_size = $LeftView/Area2D/CollisionShape2D.shape.size.x
			y_size = $LeftView/Area2D/CollisionShape2D.shape.size.y
