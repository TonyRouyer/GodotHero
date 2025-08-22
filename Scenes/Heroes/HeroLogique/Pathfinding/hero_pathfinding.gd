extends Node2D

@onready var hero: Hero = get_parent()
@onready var animated_sprite: AnimationPlayer = $"../AnimatedSprite2D/AnimationPlayer"
@onready var routine : Node2D = get_parent().get_node("HeroRoutine")
@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D

var destination: Vector2

func _ready():
	%NavigationAgent2D.connect("navigation_finished", _on_hero_navigation_finished)


func _physics_process(delta: float) -> void:	
	if navigation_agent.is_navigation_finished():
		# Stop animation et reset vitesse
		hero.velocity = Vector2.ZERO
		return

	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - hero.global_position).normalized()
	var speed = hero.speed * GameData.time_speed
	hero.velocity = direction * speed	
	
	
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
	destination = pos

	# Vérification immédiate de la reachabilité
	if not navigation_agent.is_target_reachable():
		print("⚠️ Destination non atteignable :", pos)
		_on_path_failed()
	else:
		# Force un calcul immédiat
		navigation_agent.get_next_path_position()


func _on_hero_navigation_finished():
	#TODO : si on annule une construction -> reset routine.current_construction du hero liée
	
	var object = routine.get_node("Activity").used_object
	#Si le hero utilise un objet
	if object != null:
		object.use(hero)
		routine.get_node("Activity").used_object = null
		return
	
	var construction_task = routine.current_construction
	#Si il n'y a pas de tache de construction en cours
	if not construction_task:
		return

	var origin: Vector2 = construction_task.get("origin", Vector2.ZERO)
	var task_type: String = construction_task.get("type", "")
	
	
	# --- Vérif 3 : Le héros doit se placer sur une case adjacente libre
	var stand_positions := [
		origin + Vector2(8, 0),
		origin + Vector2(-8, 0),
		origin + Vector2(0, 8),
		origin + Vector2(0, -8)
	]
	
	var can_build :bool = false
	for pos in stand_positions:
		if hero.global_position.distance_to(pos) <= 16.0:
			can_build = true
			break

	if not can_build:
		print("⚠️ Le héros n'est pas sur une case valide pour construire.")
		return
	
	# --- Si tout est bon : finaliser la construction
	match task_type:
		"object":
			var object_logic = get_tree().get_root().get_node("Main/ConstructionLogic/ObjectsLogic")
			object_logic.finalize_construction(origin)
		"wall", "floor", "door":
			var build_logic = get_tree().get_root().get_node("Main/ConstructionLogic/BuildLogic")
			build_logic.finalize_construction(construction_task)
		_:
			push_warning("Type de construction inconnu : %s" % task_type)

	# --- Libérer la tâche pour que le héros en prenne une nouvelle
	routine.current_construction = {}


func _on_path_failed():
	print("⚠️ Aucun chemin trouvé, annulation de la tâche.")
	var construction_logic = get_tree().get_root().get_node("Main/ConstructionLogic")
	var construction_task = routine.current_construction

	if construction_task and construction_task.has("origin"):
		var origin: Vector2i = construction_task["origin"]

		# Remet la tâche dispo pour un autre héros
		for task in construction_logic.construction_tasks:
			if task["origin"] == origin:
				task["assigned"] = false
				break
	
	routine.current_construction = {}



#TODO : quand on place un mur , le nav agent doit prendre en compte ce placement avant de refaire un chemin

func get_adjacent_reachable_position(target_pos: Vector2) -> Vector2:
	var offsets = [
		Vector2(16, 0), Vector2(-16, 0),
		Vector2(0, 16), Vector2(0, -16),
		Vector2(16, 16), Vector2(-16, -16),
		Vector2(16, -16), Vector2(-16, 16),
	]
	print("target_pos ", target_pos)


	for offset in offsets:
		var check_pos = target_pos + offset
		navigation_agent.target_position = check_pos
		if navigation_agent.is_target_reachable():
			print("✅ case atteignable : ", check_pos)
			return check_pos  # on retourne direct la première valide

	print("target_pos2 ", target_pos)
	return target_pos
