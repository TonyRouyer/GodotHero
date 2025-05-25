extends Node2D

@onready var hero: Hero = get_node("../..")
@onready var panel_info = get_node("../../CanvasLayer/HeroPanelInfo")
@onready var hero_routine = get_node("..")

func choose_training_activity() -> Vector2:
	#Logique
		#Cherche ordonne les priorité du hero en matiere d'entrainement
		#exemple: force,agilité puis magie
		#Pour chaque, cherche le/les objet diponible et libre et renvois la position
	
	# 1. Récupérer les priorités d'entraînement
	var strength_priority = panel_info.strength_priority
	var defense_priority = panel_info.defense_priority
	var agility_priority = panel_info.agility_priority
	var mana_priority = panel_info.mana_priority
	
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
	if hero_routine.used_object != null:
		hero_routine.used_object.exit(hero)
	
	# 4. Parcourir les priorités et essayer de trouver un objet disponible
	var objects = get_tree().get_root().get_node("Main/Level/Object").get_children()
	for priority_entry in priorities:
		# Cherche un objet non occupé du bon type
		for object in objects:
			if object.node_name == priority_entry.object and object.used == false:
				hero_routine.used_object = object
				object.used = true
				return object.global_position
	return Vector2.ZERO


func train(object_pos: Vector2) -> void:
	hero_routine.last_need = hero_routine.Needs.TRAIN
	hero.get_node("HeroPathfinding").set_destination(object_pos)
