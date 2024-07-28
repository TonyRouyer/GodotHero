extends Control

@export var day_length_seconds: float = 10.0  # Temps pour un jour complet en secondes
@export var initial_day: int = 1  # Le jour de départ

var current_day: int
@onready var day_timer = $Timer
@onready var day_progress_bar = $Progress_clock

signal day_passed

func _ready():
	# Initialisation du jour et du Timer
	global.current_day = initial_day
	$Label.text = "day: " + str(global.current_day)
	day_timer.wait_time = day_length_seconds
	day_timer.start()

	# Configurer la ProgressBar pour afficher comme une horloge
	day_progress_bar.max_value = day_length_seconds
	day_progress_bar.value = 0

func _process(_delta):
	# Mettre à jour la ProgressBar en fonction du temps restant
	day_progress_bar.value = day_length_seconds - day_timer.time_left


func _on_timer_timeout():
	# Incrémenter le jour et redémarrer le Timer
	global.current_day += 1
	$Label.text = "day: " + str(global.current_day)
	emit_signal("day_passed")
	day_timer.start()
	#print("Jour actuel: ", global.current_day)

