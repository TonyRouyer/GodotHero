extends Node2D

@onready var objects_node : Node2D = $"../../../../Level/Object"
@onready var parent = get_parent()

var is_ground_sleeping: bool = false
var used_object : Node2D

func _ready():
	pass

func perform(task: Dictionary) -> void:
	var type = task["type"]
		
	match type:
		"sleep":
			sleep()
		"eat":
			eat()
		"work":
			work()
		"train":
			train()
		"toilet":
			toilet()
		"wash":
			wash()
		"fun":
			fun()
		"construct":
			construct()
		"idle":
			idle()


func sleep() -> void:
	is_ground_sleeping = false
	
	#si le hero utilisait un objet on le quitte
	if used_object != null:
		used_object.exit(parent.hero)
	
	#Si le hero doit dormir cherche le 1er lit disponible 
	for object in objects_node.get_children():
		if object.node_name == "bed" and not object.used:
			object.used = true
			used_object = object
			parent.hero_pathfinding.set_destination(object.global_position)
			return
			
	#si pas d'objet dispo le hero dort sur place 
	is_ground_sleeping = true
	
	#TODO Ajouter fonction pour dormir par terre sur place


func eat() -> void:
	var object_position = Vector2.ZERO
	var meal_drawer : Node2D = null
	var total_food = GameData.food_stock
	
	#3.5 si le hero utilisait un objet on le quitte
	if used_object != null:
		used_object.exit(parent.hero)

	# Cherche un tiroir contenant un repas
	for object in objects_node.get_children():
		if object.node_name == "furnace" and object.disponible_meal >= 1:
			meal_drawer = object
			object_position = object.global_position
			break


	if total_food > 0:
		used_object = meal_drawer
		parent.hero_pathfinding.set_destination(object_position)


		# Une fois le repas récupéré, cherche un tabouret pour s’asseoir
		for object in objects_node.get_children():
			if object.node_name == "table" and object.used == false:
				object_position = object.global_position
				break

		# Si aucun tabouret disponible, reste sur place pour manger
		if object_position == Vector2.ZERO:
			object_position = parent.hero.global_position
			
		parent.hero_pathfinding.set_destination(object_position)
		
		GameData.food_stock -= 1
		
		parent.hero.hunger += 30
		parent.hero.toilet -= 15

	else:
		# Pas de repas : le héros retourne à sa tâche planifiée
		var current_time = TimeManager.current_hour
		var task = parent.hero_planning.planning[current_time]
		match task:
			"train":
				train()
			"work":
				work()
			_:
				idle()


func work() -> void:
	#1. On recupere la position de l'objet en fonction du metier
	var job_map = {
		1: "reception_desk",
		2: "anvil",
		3: "alchemy_workshop",
		4: "research_desk",
		5: "furnace"
	}
	var obj_name = job_map.get(parent.hero.job, "")
	var obj_pos: Vector2 = Vector2.ZERO
	if obj_name == "":
		obj_pos = Vector2.ZERO
		
	#3.5 si le hero utilisait un objet on le quitte
	if used_object != null:
		used_object.exit(parent.hero)
		
	for object in objects_node.get_children():
		if object.node_name == obj_name and not object.used:
			object.used = true
			used_object = object
			obj_pos =  object.global_position

	parent.hero_pathfinding.set_destination(obj_pos)
	return


func train() -> void:
	#Logique
		#Cherche ordonne les priorité du hero en matiere d'entrainement
		#exemple: force,agilité puis magie
		#Pour chaque, cherche le/les objet diponible et libre et renvois la position
	
	# 1. Récupérer les priorités d'entraînement
	var strength_priority = parent.panel_info.strength_priority
	var defense_priority = parent.panel_info.defense_priority
	var agility_priority = parent.panel_info.agility_priority
	var mana_priority = parent.panel_info.mana_priority
	
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
	if used_object != null:
		used_object.exit(parent.hero)
	
	# 4. Parcourir les priorités et essayer de trouver un objet disponible
	var objects = objects_node.get_children()
	var obj_pos: Vector2 = Vector2.ZERO
	for priority_entry in priorities:
		# Cherche un objet non occupé du bon type
		for object in objects:
			if object.node_name == priority_entry.object and object.used == false:
				used_object = object
				object.used = true
				obj_pos = object.global_position

	parent.hero_pathfinding.set_destination(obj_pos)


func fun() -> void:
	pass


func toilet() -> void:
	# Quitte un objet s’il en utilisait un
	if used_object != null:
		used_object.exit(parent.hero)

	# Cherche une toilette disponible
	for object in objects_node.get_children():
		if object.node_name == "toilet" and not object.used:
			object.used = true
			used_object = object
			parent.hero_pathfinding.set_destination(object.global_position)
			return

	#TODO  Si aucune toilette disponible, le héros attend sur place (ou tu peux ajouter une file d'attente plus tard)


func wash() -> void:
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
			
	#TODO ajouter fallback si aucun objet dispo


#Logique de construction:	
		#1.Le joueur place un objet → création placeholder + tâche. (fonctoin build_*)
		#2.Tâche ajoutée dans construction_tasks avec assigned = false.
		#3.Quand le planning du Héros == "construct" cherche une tâche disponible (assigned == false) :
			#Trie → prend la première non assignée  (assigned == false) .
			#Passe assigned = true et réserve les positions.
			#Pour le hero "current_construction" prend la valeur de la tache actuel
		#4.Héros va à la position de construction (ou proche selon type).
		#5.Vérification avant finalisation :
			#Si encore valide (placeholder existe + pas occupé) et pathfinding possible → finalize_construction().
			#Sinon → libère la réservation et remet la tâche assigned = false.
		#6.A la fin du pathfinding :
			#Objet/mur/porte ajouté.
			#Placeholder supprimé.
			#Tâche supprimée.
			#Héro "current_construction" reset
		#
		#Note : pour les objet on est obliger de verifier grace au tableau occupied_position car ce sont des node 2d, pour les mur et porte on peut simplement verifier via le tileset
		#activity.gd construct fonction
		#build_logic.gd mur/porte/floor
		#object.gd
		#hero_pathfinding.gd


func construct() -> void:
	#0. on check si il y a des chose a construire
	var construction_logic = get_tree().get_root().get_node("Main/ConstructionLogic")
	var construction_task = construction_logic.get_available_task()
	
	if construction_task :
		 #Recupere le 1er resultat et la Réserve pour éviter qu’un autre héros ne la prenne
		var first_task = construction_task[0]
		# Passer "assigned" à true
		first_task["assigned"] = true
	
		#On precise que le hero est en train de craft quelque chose
		parent.current_construction = first_task

		# Définir une destination vers la position d’origine de la tâche
		var destination = parent.hero_pathfinding.get_adjacent_reachable_position(first_task["origin"])
		parent.hero_pathfinding.set_destination(destination)


func idle() -> void:
	#walk random / talk / admire art ?
	var nav = parent.hero_pathfinding.nav
	var max_attempts = 20  # nombre d'essais avant d'abandonner
	var tile_size = 16  # taille d'un tile en pixels
	var origin = parent.hero.global_position

	for i in range(max_attempts):
		# Choisir un offset aléatoire dans un rayon de 10 tiles
		var offset_x = randi() % 21 - 10  # -10 à +10
		var offset_y = randi() % 21 - 10
		var target_pos = origin + Vector2(offset_x * tile_size, offset_y * tile_size)
		
		# Vérifier si la position est atteignable
		nav.target_position = target_pos
		if nav.is_target_reachable():
			print("🎯 Idle : nouvelle destination atteignable :", target_pos)
			return  # destination assignée avec succès
		else:
			# réessaie avec une nouvelle position aléatoire
			continue

	# Si aucune position atteignable trouvée après max_attempts
	print("⚠️ Idle : aucune position aléatoire atteignable trouvée, le héros reste sur place")
	nav.target_position = origin  # reste sur place
