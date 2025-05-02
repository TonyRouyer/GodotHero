extends Node2D

@onready var tilemap : TileMapLayer = $"../../../TileMap/Floor"
@onready var objects_node : Node2D = $"../../../TileMap/Object"
@onready var hero_planning : Control= $"../../../UICanvasLayer/Menu/HeroPlanning"
@onready var hero_panel_info : Control = %HeroPanelInfo
@onready var hero_pathfinding = %HeroPathfinding
@onready var hero_needs : Node2D = %HeroNeeds
@onready var hero: Hero = get_parent()

# Définition des besoins de base des héros
enum Besoins { HUNGER, SLEEP, TRAIN, WORK, FREE }

var last_need : Besoins = Besoins.FREE
var fatigue_seuil : float = 30  
var faim_seuil : float = 40 
var used_object : Node2D


func update_besoins():
	perform_activity()

# Méthode qui détermine les besoins immédiats du héros (faim, fatigue, etc.)
func get_besoins_immédiats() -> Besoins:
	var current_time = TimeManager.current_hour  # Obtenez l'heure actuelle du jeu
	var task_for_the_hour = hero_planning.planning[current_time]  # Obtenez la tâche définie pour cette heure
	var is_sleeping = last_need == Besoins.SLEEP

	
	#Si le hero a faim, il va manger
	if hero.faim <= faim_seuil:
		return Besoins.HUNGER
		
	# Si le héros est en train de dormir, il continue tant qu'il n'est pas à 100% de fatigue
	if is_sleeping and hero.fatigue < 100.0:
		return Besoins.SLEEP
		
	#Si il est fatiguer
	elif hero.fatigue <= fatigue_seuil:
		#Mais qu'il doit travailler plutot
		if task_for_the_hour == "work":
			return Besoins.WORK
		#Sinon il essaie de dormir
		else:
			return Besoins.SLEEP
	#Si le hero doit s'entainer , il y va
	elif task_for_the_hour == "train":
		return Besoins.TRAIN
	#Si il doit travailler plutot
	elif task_for_the_hour == "work":
		return Besoins.WORK
	#Si le hero n'a rien a faire il est libre
	return Besoins.FREE


# Mise à jour de la planification du héros
func perform_activity():
	#recupere le besoin actuel 
	var besoin = get_besoins_immédiats()
	
	#si le besoin actuel est le meme que le dernier on stop
	if besoin == last_need:
		return
		
	#Selon le besoin on recupere une pos d'un objet
	match besoin:
		Besoins.SLEEP:
			print("Repos")
			# Si toutes les activités sont faites, recommencer le cycle
			%Free.last_free_activity = ""
			%Sleep.sleep()
		Besoins.HUNGER:
			print("Manger")
			%Free.last_free_activity = ""
			%Eat.eat()
		Besoins.TRAIN:
			print("Entraînement")
			%Free.last_free_activity = ""
			var pos = %Train.choose_training_activity()
			if pos == Vector2.ZERO:
				perform_activity_fallback()
			else:
				%Train.train(pos)
		Besoins.WORK:
			print("Travaille")
			%Free.last_free_activity = ""
			var pos = %Work.chose_work_object()
			if pos == Vector2.ZERO:
				perform_activity_fallback()
			else:
				%Work.work(pos)
		Besoins.FREE:
			print("temps libre")
			%Free.free_time()


func perform_activity_fallback():
	%Free.free_time()
