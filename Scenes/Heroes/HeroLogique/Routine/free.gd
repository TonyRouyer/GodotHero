extends Node2D

@onready var parent = get_parent()
@onready var free_activity_timer = $"../FreeActivityTimer"

var last_free_activity :String = ""

func _on_free_activity_timer_timeout():
	if parent.hero_planning.planning[TimeManager.current_hour] == "free":
		free_time()


func free_time() -> void:
	parent.last_need = parent.Needs.FREE
	
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

	# 2. Jouer d’un instrument
	if last_free_activity != "play":
		for object in parent.objects_node.get_children():
			if object.node_name == "luth" and object.used == false:
				object.used = true
				parent.used_object = object
				parent.hero_pathfinding.set_destination(object.global_position)
				last_free_activity = "play"
				free_activity_timer.wait_time = randi_range(5, 10)
				free_activity_timer.start()
				return

	# 3. Se promener
	if last_free_activity != "walk":
		var rand_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		var walk_position = parent.hero.global_position + rand_offset
		parent.hero_pathfinding.set_destination(walk_position)
		last_free_activity = "walk"
		free_activity_timer.wait_time = randi_range(5, 10)
		free_activity_timer.start()
		return
