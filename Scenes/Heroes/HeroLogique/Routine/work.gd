extends Node2D

@onready var parent = get_parent()

func chose_work_object() -> Vector2:
	var job_map = {
		1: "reception_desk",
		2: "anvil",
		3: "alchemy_workshop",
		4: "research_desk",
		5: "furnace"
	}
	var obj_name = job_map.get(parent.hero.job, "")
	if obj_name == "":
		return Vector2.ZERO
		
	#3.5 si le hero utilisait un objet on le quitte
	if parent.used_object != null:
		parent.used_object.exit(parent.hero)
		
	for object in parent.objects_node.get_children():
		if object.node_name == obj_name and not object.used:
			object.used = true
			parent.used_object = object
			return object.global_position
	return Vector2.ZERO
	
	
	
func work(object_pos: Vector2) -> void:
	parent.last_need = parent.Needs.WORK
	parent.hero_pathfinding.set_destination(object_pos)
