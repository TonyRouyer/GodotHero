extends Node2D

@export var node_name:String = "bed"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 20
var used: bool = false
var x_size: int
var y_size: int


func use(hero: Hero):
	var marker = $Marker2D
	hero = hero

	if hero:
		var sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero.set_physics_process(false)
		hero.position = marker.global_position

		match rotate_state:
			#0:
				#animation_player.play("idle_right")
			1:
				sprite.rotation = -90
				#animation_player.play("idle_down")
			2:
				sprite.rotation = -180
				#animation_player.play("idle_left")
			3:
				sprite.rotation = 90
				sprite.flip_h = true
				#animation_player.play("idle_up")
		used = true
		

func exit(hero: Hero):
	if hero:
		var hero_sprite = hero.get_node("AnimatedSprite2D/Skin")
		hero_sprite.rotation = 0
		hero_sprite.flip_h = false
	used = false


func rotate_item(side):
	for view in self.get_children():
		view.visible = false
		
	match side:
		"front":
			$FrontView.visible = true
			$Marker2D.position = Vector2(0,8)
			x_size = $FrontView/Area2D/CollisionShape2D.shape.size.x
			y_size = $FrontView/Area2D/CollisionShape2D.shape.size.y
		"right_side":
			$RightView.visible = true
			$Marker2D.position = Vector2(8,3)
			x_size = $RightView/Area2D/CollisionShape2D.shape.size.x
			y_size = $RightView/Area2D/CollisionShape2D.shape.size.y
		"back":
			$BackView.visible = true
			$Marker2D.position = Vector2(0,-9)
			x_size = $BackView/Area2D/CollisionShape2D.shape.size.x
			y_size = $BackView/Area2D/CollisionShape2D.shape.size.y
		"left_side":
			$LeftView.visible = true
			$Marker2D.position = Vector2(-9,3)
			x_size = $LeftView/Area2D/CollisionShape2D.shape.size.x
			y_size = $LeftView/Area2D/CollisionShape2D.shape.size.y
