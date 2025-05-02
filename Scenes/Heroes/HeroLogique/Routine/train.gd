extends Node2D

@onready var parent = get_parent()


func choose_training_activity() -> Vector2:
	#Logique
		#Cherche ordonne les priorité du hero en matiere d'entrainement
		#exemple: force,agilité puis magie
		#Pour chaque, cherche le/les objet diponible et libre et renvois la position
	var objects = parent.objects_node.get_children()
	
	# 1. Récupérer les priorités d'entraînement
	var strength_priority = parent.hero_panel_info.strength_priority
	var defense_priority = parent.hero_panel_info.defense_priority
	var agility_priority = parent.hero_panel_info.agility_priority
	var mana_priority = parent.hero_panel_info.mana_priority
	
	# 2. Créer une liste ordonnée des priorités avec les noms d'objets correspondants
	var priorities = [
		{"priority": strength_priority, "object": "training_dummy"},
		{"priority": defense_priority, "object": "weight"},
		{"priority": agility_priority, "object": "archery_target"},
		{"priority": mana_priority, "object": "magical_library"}
	]
	
	# 3. Trier les priorités par ordre décroissant
	priorities.sort_custom(func(a, b):
		return b["priority"] < a["priority"]
	)
	
	#3.5 si le hero utilisait un objet on le quitte
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)
	
	# 4. Parcourir les priorités et essayer de trouver un objet disponible
	for priority_entry in priorities:
		# Cherche un objet non occupé du bon type
		for object in objects:
			if object.node_name == priority_entry.object and object.used == false:
				parent.used_object = object
				object.used = true
				return object.global_position
	return Vector2.ZERO


func train(object_pos: Vector2) -> void:
	parent.last_need = parent.Besoins.TRAIN
	parent.hero_pathfinding.set_destination(object_pos)
