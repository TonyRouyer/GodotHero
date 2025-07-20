extends Node2D

@onready var parent = get_parent()
@onready var free_activity_timer = $"../FreeActivityTimer"

var last_free_activity :String = ""

func _on_free_activity_timer_timeout():
	if parent.hero_planning.planning[TimeManager.current_hour] == "free":
		free_time()


func free_time() -> void:
	parent.last_need = parent.Needs.FREE
	
	#0. on check si il y a des chose a construire
	var construction_logic = get_tree().get_root().get_node("Main/ConstructionLogic")
	var construction_task = construction_logic.get_available_task()
	if construction_task :
		
		# Réserver la tâche pour éviter qu’un autre héros ne la prenne
		construction_task["assigned"] = true
		parent.current_construction_task = construction_task

		# Définir une destination vers la position d’origine de la tâche
		var destination = parent.hero_pathfinding.get_adjacent_reachable_position(construction_task["origin"])
		
		#print("destination de base: ", construction_task["origin"])
		#print("destination adjacente: ", destination)
		
		parent.hero_pathfinding.set_destination(destination)
		
		return
	
	# 1. Parler avec un autre héros
	if last_free_activity != "talk":
		var all_heroes = parent.hero.get_parent().get_children()
		all_heroes.shuffle()
		for target_hero in all_heroes:
			if target_hero != parent.hero and target_hero.has_node("HeroRoutine"):
				parent.hero_pathfinding.set_destination(target_hero.global_position)
				last_free_activity = "talk"
				free_activity_timer.wait_time = randi_range(5, 10)
				free_activity_timer.start()
				return

	# 2. Se promener
	if last_free_activity != "walk":
		var rand_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		var walk_position = parent.hero.global_position + rand_offset
		parent.hero_pathfinding.set_destination(walk_position)
		last_free_activity = "walk"
		free_activity_timer.wait_time = randi_range(5, 10)
		free_activity_timer.start()
		return
