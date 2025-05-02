extends Node2D

@onready var parent = get_parent()


func eat() -> void:
	parent.last_need = parent.Besoins.HUNGER
	var object_position = Vector2.ZERO
	var found_meal = false
	var meal_drawer : Node2D = null
	
	#3.5 si le hero utilisait un objet on le quitte
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)

	# Cherche un tiroir contenant un repas
	for object in parent.objects_node.get_children():
		if object.node_name == "furnace" and object.disponible_meal >= 1:
			found_meal = true
			meal_drawer = object
			object_position = object.global_position
			break

	if found_meal:
		parent.used_object = meal_drawer
		parent.hero_pathfinding.set_destination(object_position)


		# Une fois le repas récupéré, cherche un tabouret pour s’asseoir
		for object in parent.objects_node.get_children():
			if object.node_name == "stool" and object.used == false:
				object_position = object.global_position
				object.used = true
				break

		# Si aucun tabouret disponible, reste sur place pour manger
		if object_position == Vector2.ZERO:
			object_position = parent.hero.global_position
			
		parent.hero_pathfinding.set_destination(object_position)
		
		parent.hero.faim += 30

	else:
		# Pas de repas : le héros retourne à sa tâche planifiée
		print("Pas de repas disponible. Retour au planning.")
		var current_time = TimeManager.currentHour
		var task = parent.hero_planning.planning[current_time]
		match task:
			"train":
				var pos = %Train.choose_training_activity()
				if pos != Vector2.ZERO:
					%Train.train(pos)
			"work":
				var pos = %Work.chose_work_object()
				if pos != Vector2.ZERO:
					%Work.work(pos)
			_:
				%Free.free_time()
