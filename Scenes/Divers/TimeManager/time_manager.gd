extends Node2D

signal hour_changed(new_hour)
signal day_changed(new_day)


var hours_per_day : int = 24
var seconds_per_hour : int = 5
var current_hour : int = 22
var current_day : int = 1
var is_daytime : bool = true


func timer_finished():
	current_hour += 1
	emit_signal("hour_changed", TimeManager.current_hour)
	
	if current_hour >= hours_per_day:
		current_hour = 0
		current_day += 1
		emit_signal("day_changed", TimeManager.current_day)
