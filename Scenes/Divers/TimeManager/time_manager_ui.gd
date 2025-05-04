extends Control

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var jour_label : Label = %jourLabel
@onready var heure_label : Label = %HeureLabel
@onready var selecteur : Sprite2D = %Selecteur
@onready var timer = $Timer

var is_daytime : bool = true

func _ready():
	timer.wait_time = TimeManager.seconds_per_hour
	jour_label.text = "Day: " + str(TimeManager.current_day)
	heure_label.text = str(TimeManager.current_hour) + "h00"
	
	# Déterminer si c'est le jour ou la nuit au démarrage
	if TimeManager.current_hour >= 6 and TimeManager.current_hour < 21:
		is_daytime = true
		animation_player.play("move_day")
	else:
		is_daytime = false
		animation_player.play("move_night")


func _timer_timeout() -> void:
	TimeManager.timer_finished()
	timer.start()
	
	jour_label.text = "Day: " + str(TimeManager.current_day)
	heure_label.text = str(TimeManager.current_hour) + "h00"
	
	if TimeManager.current_hour == 6:
		animation_player.play("begin_day")
		is_daytime = true
	elif TimeManager.current_hour == 21:
		animation_player.play("begin_night")
		is_daytime = false


func _on_animation_finished(anim_name : String) -> void:
	if anim_name == "begin_day" or anim_name == "begin_night":
		if is_daytime:
			if not animation_player.is_playing() or animation_player.current_animation != "move_day":
				animation_player.play("move_day")
		else:
			if not animation_player.is_playing() or animation_player.current_animation != "move_night":
				animation_player.play("move_night")


func _on_btn_pause_pressed() -> void:
	selecteur.position = Vector2(194,125)
	$Timer.paused = true
	GameData.game_paused = true
	get_tree().paused = true


func _on_btn_play_pressed() -> void:
	selecteur.position = Vector2(263,125)
	$Timer.paused = false
	GameData.game_paused = false
	get_tree().paused = false
