extends Node2D

@onready var tilemap : TileMapLayer = $"../../../TileMap/Floor"
@onready var objects_node : Node2D = $"../../../TileMap/Object"
@onready var hero_planning : Control = %HeroPlanning
@onready var hero_pathfinding = %HeroPathfinding
@onready var hero_needs : Node2D = %HeroNeeds
@onready var hero: Hero = get_parent()

# Définition des besoins de base des héros
enum Needs { HUNGER, SLEEP, TOILET, HYGIENE, ENTERTAINMENT, TRAIN, WORK, FREE }

var last_need : Needs = Needs.FREE
var used_object : Node2D

var energy_limit : float = 30  
var hunger_limit : float = 40 
var toilet_limit : float = 70
var hygiene_limit : float = 30
var entertainment_limit : float = 40

func _ready():
	TimeManager.connect("time_tick", _update_needs)


func _update_needs(_hour: int, _minute: int):
	perform_activity()


# Mise à jour de la planification du héros
func perform_activity():
	print("perform activity")
	#recupere le besoin actuel 
	var besoin = get_immediate_needs()
	
	#print("last_need ", last_need)
	print("besoin ", besoin)
	
	
	#si le besoin actuel est le meme que le dernier on stop
	if besoin == last_need:
		return
	
	#Selon le besoin on recupere une pos d'un objet
	match besoin:
		Needs.SLEEP:
			# Si toutes les activités sont faites, recommencer le cycle
			%Free.last_free_activity = ""
			%Sleep.sleep()
		Needs.HUNGER:
			%Free.last_free_activity = ""
			%Eat.eat()
		Needs.TRAIN:
			%Free.last_free_activity = ""
			var pos = %Train.choose_training_activity()
			if pos == Vector2.ZERO:
				perform_activity_fallback()
			else:
				%Train.train(pos)
		Needs.WORK:
			%Free.last_free_activity = ""
			var pos = %Work.chose_work_object()
			if pos == Vector2.ZERO:
				perform_activity_fallback()
			else:
				%Work.work(pos)
		Needs.TOILET:
			%Free.last_free_activity = ""
			%Toilet.go_to_toilet()
		Needs.HYGIENE:
			%Free.last_free_activity = ""
			%Hygiene.take_shower()
			
		Needs.ENTERTAINMENT:
			%Free.last_free_activity = ""
			%Free.use_entertainment()
		Needs.FREE:
			%Free.free_time()


# Méthode qui détermine les besoins immédiats du héros (faim, fatigue, etc.)
func get_immediate_needs() -> Needs:
	var current_time = TimeManager.current_hour  # Obtenez l'heure actuelle du jeu
	var task_for_the_hour = hero_planning.planning[current_time]  # Obtenez la tâche définie pour cette heure
	
	print("current_time =", current_time)
	print("planning =", hero_planning.planning)
	print("planning[current_time] =", hero_planning.planning.get(current_time, "MISSING"))

	# Si le héros est en phase de repos, il dor jusqu'a la fin de la phase
	if task_for_the_hour == "sleep":
		return Needs.SLEEP

	# Si il doit travailler ou s'entrainer il le fait malgrer les autre constante
	if task_for_the_hour == "train":
		return Needs.TRAIN
	if task_for_the_hour == "work":
		return Needs.WORK

	# Si le hero est en temps libre (autre que entrainement/travaille et sommeille)
	# Priorité aux besoins critiques
	if hero.hunger <= hunger_limit:
		return Needs.HUNGER
	if hero.toilet >= toilet_limit:
		return Needs.TOILET
	if hero.hygiene <= hygiene_limit:
		return Needs.HYGIENE
	if hero.entertainment <= entertainment_limit:
		return Needs.ENTERTAINMENT
	
	#Si le hero n'a rien a faire il est libre
	print("hero libre")
	return Needs.FREE




func perform_activity_fallback():
	%Free.free_time()
