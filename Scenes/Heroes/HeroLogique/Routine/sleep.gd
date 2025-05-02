extends Node2D

@onready var parent = get_parent()

var is_ground_sleeping: bool = false

func sleep() -> void:
	parent.last_need = parent.Besoins.SLEEP
	is_ground_sleeping = false
	
	
	#3.5 si le hero utilisait un objet on le quitte
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)
	
	#Si le hero doit dormir cherche le 1er lit disponible 
	for object in parent.objects_node.get_children():
		if object.node_name == "bed" and not object.used:
			object.used = true
			parent.used_object = object
			parent.hero_pathfinding.set_destination(object.global_position)
			return
	#si pas d'objet dispo le hero dort sur place 
	is_ground_sleeping = true
	parent.hero_pathfinding.set_destination(parent.hero.global_position)
