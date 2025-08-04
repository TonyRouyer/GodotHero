extends Node2D

@onready var hero: Hero = get_parent()
@onready var animated_sprite: AnimationPlayer = $"../AnimatedSprite2D/AnimationPlayer"
@onready var routine : Node2D = get_parent().get_node("HeroRoutine")
@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D

var destination: Vector2

func _ready():
	%NavigationAgent2D.connect("navigation_finished", _on_hero_navigation_finished)


func _physics_process(_delta: float) -> void:	
	if navigation_agent.is_navigation_finished():
		# Stop animation et reset vitesse
		hero.velocity = Vector2.ZERO
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
		pass

	# Appliquer le mouvement
	hero.move_and_slide()


func set_destination(pos: Vector2):
	navigation_agent.target_position = pos
	navigation_agent.set_velocity(Vector2.ZERO)  # Optionnel pour être clean
	navigation_agent.get_next_path_position()  #  FORCE le calcul du chemin
	
	destination = pos


#func _on_hero_navigation_finished():
	#var object = routine.used_object
	#if object:
		#object.use(hero)
		#routine.used_object = null  # Réinitialiser
#
	#var construction_task = routine.current_construction_task
	#if construction_task:
		#var task_type = construction_task.get("type")
		#var origin = construction_task.get("origin")
		#
		#print(origin)
		#
		#match task_type:
			#"object":
				#var object_logic = get_tree().get_root().get_node("Main/ConstructionLogic/ObjectsLogic")
				#object_logic.finalize_construction(origin)
#
			#"wall", "floor", "door":
				#var build_logic = get_tree().get_root().get_node("Main/ConstructionLogic/BuildLogic")
				#build_logic.finalize_construction(origin)
#
			#_:
				#push_warning("Type de construction inconnu : %s" % task_type)
#
		#routine.current_construction_task = {}


func _on_hero_navigation_finished():
	var object = routine.used_object
	if object != null:
		object.use(hero)
		routine.used_object = null

	var construction_task = routine.current_construction_task
	if construction_task:
		var task_type = construction_task.get("type")
		var origin = construction_task.get("origin")

		if hero.global_position.distance_to(origin) > 32:
			return  # Trop loin pour construire

		match task_type:
			"object":
				var object_logic = get_tree().get_root().get_node("Main/ConstructionLogic/ObjectsLogic")
				object_logic.finalize_construction(origin)

			"wall", "floor", "door":
				var build_logic = get_tree().get_root().get_node("Main/ConstructionLogic/BuildLogic")
				build_logic.finalize_construction(origin)

			_:
				push_warning("Type de construction inconnu : %s" % task_type)

		routine.current_construction_task = {}



func get_adjacent_reachable_position(target_pos: Vector2) -> Vector2:
	var offsets = [
		Vector2(1, 0), Vector2(-1, 0),
		Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 1), Vector2(-1, -1),
		Vector2(1, -1), Vector2(-1, 1),
	]

	var cell_size = 16  # adapte à ton grid_size
	for offset in offsets:
		var check_pos = target_pos + (offset * cell_size) *2
		if navigation_agent.is_target_reachable():
			return check_pos

	return target_pos
