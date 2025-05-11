extends Control

@onready var timer = %Timer
@onready var time = %Time
@onready var day = %Day
@onready var selector = %Selector

var is_daytime : bool = true


func _ready():
	timer.wait_time = TimeManager.seconds_per_hour
	day.text = "Day: " + str(TimeManager.current_day)
	time.text = "%02dh%02d" % [TimeManager.current_hour, TimeManager.current_minute]

	# Déterminer si c'est le jour ou la nuit au démarrage
	if TimeManager.current_hour >= 6 and TimeManager.current_hour < 21:
		is_daytime = true
		#On pourra par la suite ajouter un fond selon le jour ou la nuit
	else:
		is_daytime = false


func _timer_timeout() -> void:
	TimeManager.timer_finished()
	timer.start()

	if TimeManager.current_hour == 6 and TimeManager.current_minute == 0:
		is_daytime = true
		#On pourra par la suite ajouter un fond selon le jour ou la nuit	
	elif TimeManager.current_hour == 21 and TimeManager.current_minute == 0:
		is_daytime = false
		
	time.text = "%02dh%02d" % [TimeManager.current_hour, TimeManager.current_minute]
	day.text = "Day: " + str(TimeManager.current_day)


func _on_pause_pressed():
	selector.size = Vector2(35,35)
	selector.position = Vector2(-32,47)
	$Timer.paused = true
	GameData.game_paused = true
	get_tree().paused = true


func _on_play_pressed():
	selector.size = Vector2(35,35)
	selector.position = Vector2(5,47)
	$Timer.paused = false
	GameData.game_paused = false
	get_tree().paused = false
	timer.wait_time = 3


func _on_play_fast_pressed():
	selector.size = Vector2(35,35)
	selector.position = Vector2(40,47)
	$Timer.paused = false
	GameData.game_paused = false
	get_tree().paused = false
	timer.wait_time = 2


func _on_play_very_fast_pressed():
	selector.size = Vector2(48,35)
	selector.position = Vector2(76,47)
	$Timer.paused = false
	GameData.game_paused = false
	get_tree().paused = false
	timer.wait_time = 1
