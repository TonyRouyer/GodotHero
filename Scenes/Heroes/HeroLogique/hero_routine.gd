extends Node2D

#@onready var navigation_agent = $"../NavigationAgent2D"
@onready var tilemap : TileMapLayer = $"../../../TileMap/Floor"
@onready var objects_node : Node2D = $"../../../TileMap/Object"
@onready var hero_pathfinding = $"../HeroPathfinding"
@onready var hero_panel_info : Control= %HeroPanelInfo
@onready var hero_planning : Control= $"../../../UICanvasLayer/Menu/HeroPlanning"
@onready var parent: Hero = get_parent()
var current_path: Array[Vector2i]
var performed_activity : String = ""
var speed : int = 75 
var planning: Dictionary


func _ready() -> void:
	var time_manager = get_tree().get_root().get_node("Main/UICanvasLayer/TopMenu/TimeManager")
	if time_manager:
		time_manager.connect("hour_changed", _on_hour_changed)
	planning = hero_planning.planning


func _on_hour_changed(new_hour : int) -> void:
	planning = hero_planning.planning
	if new_hour in planning:
		var activity = planning[new_hour]
		perform_activity(activity)


# Fonction pour effectuer une activité
func perform_activity(activity : String) -> void:
	var object_pos = null
	if activity != performed_activity:
		performed_activity = activity
		match activity:
			"sleep":
				object_pos = choose_sleep_object()
			"train":
				object_pos = choose_training_activity()
			"rest":
				object_pos = chose_rest_object()
			"eat":
				object_pos = chose_rest_object()
		parent.fatigue = clamp(parent.fatigue, 0, 100)
		move_to_activity(object_pos)


# Se déplacer vers le premier objet non occupé
func move_to_activity(object_pos : Vector2) -> void:
	#print("print ",object_pos)
	var activity_position = object_pos

	if activity_position:
		hero_pathfinding.set_destination(activity_position)
	else:
		move_randomly()


# Choisir une activité d'entraînement en fonction des priorités
func choose_training_activity() -> Vector2:
	var objects = objects_node.get_children()
	
	# Récupérer les priorités d'entraînement
	var strength_priority = hero_panel_info.strength_priority
	var defense_priority = hero_panel_info.defense_priority
	var agility_priority = hero_panel_info.agility_priority
	var mana_priority = hero_panel_info.mana_priority
	
	# Créer une liste ordonnée des priorités avec les noms d'objets correspondants
	var priorities = [
		{"priority": strength_priority, "object": "training_dummy"},
		{"priority": defense_priority, "object": "weight"},
		{"priority": agility_priority, "object": "archery_target"},
		{"priority": mana_priority, "object": "magical_library"}
	]
	
	# Trier les priorités par ordre décroissant
	priorities.sort_custom(func(a, b):
		return b["priority"] < a["priority"]
	)
	
	# Parcourir les priorités et essayer de trouver un objet disponible
	for priority_entry in priorities:
		# Cherche un objet non occupé du bon type
		for object in objects:
			if object.node_name == priority_entry.object and object.used == false:
				#object.used = true 
				return object.global_position
	return Vector2.ZERO


func choose_sleep_object() -> Vector2:
	var objects = objects_node.get_children()
	
	# Cherche un objet non occupé du bon type
	for object in objects:
		if object.node_name == "bed" and object.used == false:
			object.used = true
			return object.global_position
	return Vector2.ZERO


func chose_rest_object() -> Vector2:
	var objects = objects_node.get_children()
	
	# Cherche un objet non occupé du bon type
	for object in objects:
		if object.node_name == "chair" and object.used == false:
			object.used = true
			return object.global_position
	return Vector2.ZERO


func chose_eat_object() -> Vector2:
	var objects = objects_node.get_children()
	
	# Cherche un objet non occupé du bon type
	for object in objects:
		if object.node_name == "bed" and object.used == false:
			object.used = true
			return object.global_position
	return Vector2.ZERO


# Déplacer aléatoirement si aucune tâche n'est en cours
func move_randomly() -> void:
	var random_position = Vector2(randi() % tilemap.get_used_rect().size.x, randi() % tilemap.get_used_rect().size.y)
	#print(random_position)
	var tile_data = tilemap.get_cell_tile_data(random_position)
	if tile_data and tile_data.get_custom_data('Type') == "Wall":
		move_randomly()
	else:
		#print("go to ", tilemap.map_to_local(random_position) )
		hero_pathfinding.set_destination(tilemap.map_to_local(random_position))
