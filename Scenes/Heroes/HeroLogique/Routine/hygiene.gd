extends Node2D

@onready var parent = get_parent()

func take_shower() -> void:
	parent.last_need = parent.Needs.HYGIENE

	# Quitte l’objet utilisé précédemment
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)

	# Cherche une installation d’hygiène disponible (douche, lavabo, bain...)
	for object in parent.objects_node.get_children():
		if object.node_name in ["shower", "sink", "bath"] and not object.used:
			object.used = true
			parent.used_object = object
			parent.hero_pathfinding.set_destination(object.global_position)
			return

	# Si rien n’est dispo, le héros boucle
	#parent.hero.last_need = parent.Needs.FREE
	#parent.perform_activity()
