extends Node2D

@export var node_name:String = "table"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 50
var used: bool = false
var x_size: int
var y_size: int

var slots := {
	"Marker1": null,
	"Marker2": null,
	"Marker3": null,
	"Marker4": null
}



func use(hero: Hero) -> bool:
	for marker_name in slots.keys():
		if slots[marker_name] == null:
			slots[marker_name] = hero
			
			var marker = get_node(marker_name)
			hero.set_physics_process(false)
			hero.position = marker.global_position

			var anim_player = hero.get_node("AnimatedSprite2D/AnimationPlayer")
			var anim_name: String = ""
			match rotate_state:
				0: anim_name = "sit_up"
				1: anim_name = "sit_left"
				2: anim_name = "sit_down"
				3: anim_name = "sit_right"
			
			anim_player.play(anim_name)
			print(hero.name, " utilise la ", node_name, " sur ", marker_name)
			_update_used_status()
			return true
	
	print("Aucune place libre à la table pour ", hero.name)
	return false


func exit(hero: Hero) -> void:
	for marker_name in slots.keys():
		if slots[marker_name] == hero:
			slots[marker_name] = null
			print(hero.name, " quitte la table depuis ", marker_name)
			_update_used_status()
			return


func _update_used_status() -> void:
	used = !slots.values().has(null)


func rotate_item(side):
	match side:
		"front":
			#choix de la taille et du placement du coolision shape
			%CollisionShape2D.shape.size = Vector2(32,64)
			%CollisionShape2D.position = Vector2(16,32)
			#choix et mise en place du sprite
			%Sprite.set_region_rect(Rect2(64,0,32,64))
			%Sprite.position = Vector2(16,32)
			#Placement du marker
			$Marker1.position = Vector2(8,16)
			$Marker2.position = Vector2(24,16)
			$Marker3.position = Vector2(8,64)
			$Marker4.position = Vector2(24,64)
		"right_side":
			%CollisionShape2D.shape.size = Vector2(64,32)
			%CollisionShape2D.position = Vector2(32,16)

			%Sprite.set_region_rect(Rect2(0,0,64,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(32,16)

			$Marker1.position = Vector2(8,16)
			$Marker2.position = Vector2(8,32)
			$Marker3.position = Vector2(56,16)
			$Marker4.position = Vector2(56,32)
		"back":
			%CollisionShape2D.shape.size = Vector2(32,64)
			%CollisionShape2D.position = Vector2(16,32)

			%Sprite.set_region_rect(Rect2(64,0,32,64))
			%Sprite.position = Vector2(16,32)

			$Marker1.position = Vector2(8,16)
			$Marker2.position = Vector2(24,16)
			$Marker3.position = Vector2(8,64)
			$Marker4.position = Vector2(24,64)
		"left_side":
			%CollisionShape2D.shape.size = Vector2(64,32)
			%CollisionShape2D.position = Vector2(32,16)

			%Sprite.set_region_rect(Rect2(0,0,64,32))
			%Sprite.flip_h = false
			%Sprite.position = Vector2(32,16)

			$Marker1.position = Vector2(8,16)
			$Marker2.position = Vector2(8,32)
			$Marker3.position = Vector2(56,16)
			$Marker4.position = Vector2(56,32)
			
	x_size = %CollisionShape2D.shape.size.x
	y_size = %CollisionShape2D.shape.size.y
