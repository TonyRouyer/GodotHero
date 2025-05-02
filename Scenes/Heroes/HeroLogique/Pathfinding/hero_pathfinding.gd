extends Node2D

@onready var hero: Hero = get_parent()
@onready var animated_sprite: AnimationPlayer = $"../AnimatedSprite2D/AnimationPlayer"
@onready var routine : Node2D = get_parent().get_node("HeroRoutine")
@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D



func _physics_process(_delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		# Stop animation et reset vitesse
		hero.velocity = Vector2.ZERO
		animated_sprite.play("idle_down")  # Animation par défaut
		return

	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - hero.global_position).normalized()
	hero.velocity = direction * hero.speed

	# Gérer l’animation directionnelle
	if direction.length() > 0.1:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if direction.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		animated_sprite.play("idle_down")  # Si très proche ou stop

	# Appliquer le mouvement
	hero.move_and_slide()


func set_destination(pos: Vector2):
	print("set destination", pos)
	navigation_agent.target_position = pos
	navigation_agent.set_velocity(Vector2.ZERO)  # Optionnel pour être clean
	navigation_agent.get_next_path_position()  #  FORCE le calcul du chemin


func _on_hero_navigation_finished():
	var object = routine.used_object
	if object:
		object.use(hero)


func get_random_nearby_position() -> Vector2:
	# Génère une position proche au cas où le héros est complètement bloqué
	return hero.global_position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
