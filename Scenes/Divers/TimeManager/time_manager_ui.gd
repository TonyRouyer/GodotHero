extends Control

@onready var timer = %Timer
@onready var time = %Time
#@onready var day = %Day

var is_daytime : bool = true


func _ready():
	%Pause.connect("pressed", _on_pause_pressed)
	%Play.connect("pressed", _on_play_pressed)
	%PlayFast.connect("pressed", _on_play_fast_pressed)
	%PlayVeryFast.connect("pressed", _on_play_very_fast_pressed)
	
	timer.wait_time = TimeManager.seconds_per_hour
	#day.text = "Day: " + str(TimeManager.current_day)
	time.text = "%02dh%02d" % [TimeManager.current_hour, TimeManager.current_minute]

	# Déterminer si c'est le jour ou la nuit au démarrage
	if TimeManager.current_hour >= 6 and TimeManager.current_hour < 21:
		is_daytime = true
		#On pourra par la suite ajouter un fond selon le jour ou la nuit
	else:
		is_daytime = false
		
	update_speed_ui(1)



func _timer_timeout():
	TimeManager.timer_finished()
	timer.start()

	if TimeManager.current_hour == 6 and TimeManager.current_minute == 0:
		is_daytime = true
		#On pourra par la suite ajouter un fond selon le jour ou la nuit	
	elif TimeManager.current_hour == 21 and TimeManager.current_minute == 0:
		is_daytime = false
		
	time.text = "%02dh%02d" % [TimeManager.current_hour, TimeManager.current_minute]
	#day.text = "Day: " + str(TimeManager.current_day)


func _on_pause_pressed():
	update_speed_ui(0)
	$Timer.paused = true
	GameData.game_paused = true
	GameData.time_speed = 0
	get_tree().paused = true


func _on_play_pressed():
	update_speed_ui(1)
	$Timer.paused = false
	GameData.game_paused = false
	GameData.time_speed = 1
	get_tree().paused = false
	timer.wait_time = 3


func _on_play_fast_pressed():
	update_speed_ui(2)
	$Timer.paused = false
	GameData.game_paused = false
	GameData.time_speed = 2
	get_tree().paused = false
	timer.wait_time = 2


func _on_play_very_fast_pressed():
	update_speed_ui(3)
	$Timer.paused = false
	GameData.game_paused = false
	GameData.time_speed = 3
	get_tree().paused = false
	timer.wait_time = 1





func update_speed_ui(speed: int) -> void:
	_reset_modulate()

	match speed:
		0: %Pause.modulate = Color(0.5, 0.5, 0.5, 1) # blanc = actif
		1: %Play.modulate = Color(0.5, 0.5, 0.5, 1)
		2: %PlayFast.modulate = Color(0.5, 0.5, 0.5, 1)
		3: %PlayVeryFast.modulate = Color(0.5, 0.5, 0.5, 1)

func _reset_modulate():
	var buttons = [%Pause, %Play, %PlayFast, %PlayVeryFast]
	for b in buttons:
		b.modulate = Color(1, 1, 1, 1) 
