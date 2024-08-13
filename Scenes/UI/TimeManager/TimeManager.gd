extends Control

signal hour_changed(new_hour)
signal day_changed(new_day)

@onready var day_timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var jour_label = $mask/jourLabel
@onready var heure_label = $mask/HeureLabel
@onready var selecteur = $mask/Selecteur

@export var hours_per_day = 24
@export var seconds_per_hour = 5
@export var day_length_seconds = hours_per_day * seconds_per_hour  # Un jour complet en secondes

var current_hour = 5
var current_day = 1
var is_daytime = true

func _ready():
	jour_label.text = "Day: " + str(current_day)
	heure_label.text = str(current_hour) + "h00"
	day_timer.wait_time = seconds_per_hour
	day_timer.start()

	# Déterminer si c'est le jour ou la nuit au démarrage
	if current_hour >= 6 and current_hour < 21:
		is_daytime = true
		animation_player.play("move_day")
	else:
		is_daytime = false
		animation_player.play("move_night")


func _on_timer_timeout():
	current_hour += 1
	if current_hour >= hours_per_day:
		current_hour = 0
		current_day += 1
		emit_signal("day_changed", current_day)
	jour_label.text = "Day: " + str(current_day)
	heure_label.text = str(current_hour) + "h00"
	emit_signal("hour_changed", current_hour)
	handle_time_change()
	day_timer.start()

func handle_time_change():
	if current_hour == 6:
		animation_player.play("begin_day")
		is_daytime = true
	elif current_hour == 21:
		animation_player.play("begin_night")
		is_daytime = false

func _on_animation_finished(anim_name):
	if anim_name == "begin_day" or anim_name == "begin_night":
		play_continuous_animation()

func play_continuous_animation():
	if is_daytime:
		if not animation_player.is_playing() or animation_player.current_animation != "move_day":
			animation_player.play("move_day")
	else:
		if not animation_player.is_playing() or animation_player.current_animation != "move_night":
			animation_player.play("move_night")


func _on_btn_pause_pressed():
	selecteur.position = Vector2(194,125)
	day_timer.paused = true
	global.game_paused = true


func _on_btn_play_pressed():
	selecteur.position = Vector2(263,125)
	day_timer.paused = false
	global.game_paused = false
	

