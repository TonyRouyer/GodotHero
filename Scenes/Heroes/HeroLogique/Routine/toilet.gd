extends Node2D

@onready var parent = get_parent()

func go_to_toilet() -> void:
	parent.last_need = parent.Needs.TOILET

	# Quitte un objet s’il en utilisait un
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)

	# Cherche une toilette disponible
	for object in parent.objects_node.get_children():
		if object.node_name == "toilet" and not object.used:
			object.used = true
			parent.used_object = object
			parent.hero_pathfinding.set_destination(object.global_position)
			return

	# Si aucune toilette disponible, le héros attend sur place (ou tu peux ajouter une file d'attente plus tard)
	#parent.last_need = parent.Needs.FREE
	#parent.perform_activity()
