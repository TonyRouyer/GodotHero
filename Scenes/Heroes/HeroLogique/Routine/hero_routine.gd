extends Node2D

#@onready var tilemap : TileMapLayer = $"../../../Level/Floor"
#@onready var objects_node : Node2D = $"../../../Level/Object"
@onready var hero_planning : Control = %HeroPlanning
@onready var activity: Node2D = %Activity
@onready var hero_pathfinding = %HeroPathfinding
#@onready var hero_needs : Node2D = %HeroNeeds
@onready var hero: Hero = get_parent()
@onready var panel_info = get_node("../CanvasLayer/HeroPanelInfo")

# Définition des besoins de base des héros
#enum Needs { HUNGER, SLEEP, TOILET, HYGIENE, ENTERTAINMENT, TRAIN, WORK, FREE }

#var last_need : Needs = Needs.FREE
#var used_object : Node2D
var current_task : Dictionary = {"type": "idle"}
var current_construction: Dictionary = {}

var energy_limit : float = 30  
var hunger_limit : float = 40 
var toilet_limit : float = 70
var hygiene_limit : float = 30
var entertainment_limit : float = 40

func _ready():
	TimeManager.connect("time_tick", _update_routine)
	
	GameData.food_stock += 15


func _update_routine(_hour: int, _minute: int):
	#perform_activity()
	routine()


func routine():
	# 0. Contrôle joueur
	if hero.control_by_player:
		#effectuer_action_selectionnee(hero)
		hero.change_activity_label("control by player")
		return

	# 1. Si en train de manger ou dormir, continuer jusqu'à fin -> on ne fait rien
	if current_task != null:
		var t_type = current_task["type"]
		if t_type == "eat" and hero.hunger < 100:
			return
		elif t_type == "sleep" and hero.energy < 100:
			return

	# 2. Choisir nouvelle tâche si rien de bloquant
	var task = chose_best_task()
	if task != null:
		current_task = task
		hero.change_activity_label(str(task["type"]))
		activity.perform(task)
	else:
		current_task = {"type": "idle"}
		hero.change_activity_label("Idle")
		#rester_inactif(hero)
		activity.perform(task)


# ---------------------------------------------------------
# Génération de toutes les tâches
# ---------------------------------------------------------
func generate_tasks() -> Array:
	var tasks: Array = []

	# 1. Besoins vitaux (toujours priorité max)
	if hero.hunger < hunger_limit and available_object("food"):
		tasks.append({
			"type": "eat",
			"required_object": "food",
			"urgent": true,
			"global_priority": 100
		})

	# 2. Tâches selon planning
	var current_time = TimeManager.current_hour  # Obtenez l'heure actuelle du jeu
	var planning_type = hero_planning.planning[current_time]  # Obtenez la tâche définie pour cette heure
	
	var job_map = {
		1: "reception_desk",
		2: "anvil",
		3: "alchemy_workshop",
		4: "research_desk",
		5: "furnace"
	}
	# A. Récupérer les priorités d'entraînement
	var strength_priority = panel_info.strength_priority
	var defense_priority = panel_info.defense_priority
	var agility_priority = panel_info.agility_priority
	var mana_priority = panel_info.mana_priority
	
	# B. Créer une liste ordonnée des priorités avec les noms d'objets correspondants
	var priorities = [
		{"name":"strength_priority", "priority": strength_priority, "object": "training_dummy"},
		{"name":"defense_priority", "priority": defense_priority, "object": "weight"},
		{"name":"agility_priority", "priority": agility_priority, "object": "archery_target"},
		{"name":"mana_priority", "priority": mana_priority, "object": "magical_library"}
	]

	# Si work prévu mais pas de métier ou objet dispo → considérer comme libre
	if planning_type == "work":
		var job_object = job_map.get(hero.job)
		if hero.job == 0 : #si le hero n'est pas sans job
			planning_type = "free"
		if hero.job != 0:
			if not available_object(job_object):
				planning_type = "free"

	# Si train prévu mais aucun objet d'entraînement dispo → considérer comme libre
	if planning_type == "train":
		var entrainement_dispo = false
		
		for skill in priorities:
			if available_object(skill["object"]):
				entrainement_dispo = true
				break
		if not entrainement_dispo:
			planning_type = "free"

	# Traitement selon planning ajusté
	match planning_type:
		"sleep":
			tasks.append({
				"type": "sleep",
				"global_priority": 80
			})
		"work":
			tasks.append({
				"type": "work",
				"job_name": hero.job,
				"required_object": job_map.get(hero.job),
				"global_priority": 90
			})
		"train":
			for skill in priorities:
				var obj_entrainement = skill["object"]
				if available_object(obj_entrainement):
					var train_name = skill["name"]
					var priority = skill["priority"]
					tasks.append({
						"type": "train",
						"sub_type": train_name,
						"priority": priority,
						"required_object": obj_entrainement,
						"global_priority": int(priority * 50)
					})
		"free":
			# 3. Besoins secondaires si planning libre
			if hero.energy < energy_limit:
				tasks.append({"type": "sleep", "global_priority": 70})
			if hero.toilet < toilet_limit and available_object("toilet"):
				tasks.append({"type": "toilet", "global_priority": 60})
			if hero.hygiene < hygiene_limit and available_object("shower"):
				tasks.append({"type": "wash", "global_priority": 60})
			if hero.entertainment < entertainment_limit and available_object("jeu"):
				tasks.append({"type": "fun", "global_priority": 50})

			# Construction
			#0. on check si il y a des chose a construire
			var construction_logic = get_tree().get_root().get_node("Main/ConstructionLogic")
			var construction_task = construction_logic.get_available_task()
			if not  construction_task.is_empty() and current_construction.is_empty():
				tasks.append({
					"type": "construct",
					"global_priority": 50
				})

	# 4. Idle toujours disponible
	tasks.append({"type": "idle", "global_priority": 1})

	return tasks


# ---------------------------------------------------------
# Score / choix tâche
# ---------------------------------------------------------
func chose_best_task() -> Dictionary:
	var tasks = generate_tasks()

	var best_task: Dictionary = {}
	var best_score = -1

	for task in tasks:
		var score = 0

		# 1. Besoin critique
		if "urgent" in task:
			score += 100

		# 2. Correspondance avec le planning
		var current_time = TimeManager.current_hour  # Obtenez l'heure actuelle du jeu
		var planning_type = hero_planning.planning[current_time]  # Obtenez la tâche définie pour cette heure
		if planning_type == task["type"]:
			score += 50

		# 3. Métier
		if task["type"] == "work" and hero.job == task.get("job_name"):
			score += 50

		# 4. Entraînement
		if task["type"] == "train":
			var sub_type = task["sub_type"]
			var train_priority = {
				"strength_priority" : panel_info.strength_priority,
				"defense_priority" : panel_info.defense_priority,
				"agility_priority" : panel_info.agility_priority,
				"mana_priority" : panel_info.mana_priority,
			}
			
			if sub_type in train_priority:
				score += hero.priorites_entrainement[sub_type] * 50

		# 5. Disponibilité de l'objet
		if "required_object" in task and task["required_object"] != null:
			if available_object(task["required_object"]):
				score += 20

		# 6. Priorité intrinsèque
		if "global_priority" in task:
			score += task["global_priority"]

		# Sélection de la meilleure tâche
		if score > best_score:
			best_score = score
			best_task = task

	return best_task


# ---------------------------------------------------------
# Vérification objets
# ---------------------------------------------------------
func available_object(object_type: String) -> bool:
	if object_type == "food":
		return GameData.food_stock > 0
		
	var objects = get_tree().get_root().get_node("Main/Level/Object").get_children()

		
	for obj in objects:
		if obj.node_name == object_type and obj.used == false:
			return true
	return false










#
#
#
## Mise à jour de la planification du héros
#func perform_activity():
	##recupere le besoin actuel 
	#var besoin = get_immediate_needs()
	#
	##si le besoin actuel est le meme que le dernier on stop
	#if besoin == last_need:
		#return
	#
	##Selon le besoin on recupere une pos d'un objet
	#match besoin:
		#Needs.SLEEP:
			## Si toutes les activités sont faites, recommencer le cycle
			#%Free.last_free_activity = ""
			#%Sleep.sleep()
		#Needs.HUNGER:
			#%Free.last_free_activity = ""
			#%Eat.eat()
		#Needs.TRAIN:
			#%Free.last_free_activity = ""
			#var pos = %Train.choose_training_activity()
			#if pos == Vector2.ZERO:
				#perform_activity_fallback()
			#else:
				#%Train.train(pos)
		#Needs.WORK:
			#%Free.last_free_activity = ""
			#var pos = %Work.chose_work_object()
			#if pos == Vector2.ZERO:
				#perform_activity_fallback()
			#else:
				#%Work.work(pos)
		#Needs.TOILET:
			#%Free.last_free_activity = ""
			#%Toilet.go_to_toilet()
		#Needs.HYGIENE:
			#%Free.last_free_activity = ""
			#%Hygiene.take_shower()
			#
		#Needs.ENTERTAINMENT:
			#%Free.last_free_activity = ""
			#%Free.use_entertainment()
		#Needs.FREE:
			#%Free.free_time()
#
## Méthode qui détermine les besoins immédiats du héros (faim, fatigue, etc.)
#func get_immediate_needs() -> Needs:
	#var current_time = TimeManager.current_hour  # Obtenez l'heure actuelle du jeu
	#var task_for_the_hour = hero_planning.planning[current_time]  # Obtenez la tâche définie pour cette heure
	#
	## Si le héros est en phase de repos, il dor jusqu'a la fin de la phase
	#if task_for_the_hour == "sleep":
		#return Needs.SLEEP
#
	## Si il doit travailler ou s'entrainer il le fait malgrer les autre constante
	#if task_for_the_hour == "train":
		#return Needs.TRAIN
	#if task_for_the_hour == "work":
		#return Needs.WORK
#
	## Si le hero est en temps libre (autre que entrainement/travaille et sommeille)
	## Priorité aux besoins critiques
	#if hero.hunger <= hunger_limit:
		#return Needs.HUNGER
	#if hero.toilet >= toilet_limit:
		#return Needs.TOILET
	#if hero.hygiene <= hygiene_limit:
		#return Needs.HYGIENE
	#if hero.entertainment <= entertainment_limit:
		#return Needs.ENTERTAINMENT
	#
	##Si le hero n'a rien a faire il est libre
	#return Needs.FREE
#
#
#func perform_activity_fallback():
	#%Free.free_time()
