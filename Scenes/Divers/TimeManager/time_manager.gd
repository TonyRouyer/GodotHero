extends Node2D

signal time_tick(hour, minute)
signal hour_changed(new_hour)
signal day_changed(new_day)


const MINUTES_PER_HOUR = 60
const HOURS_PER_DAY = 24
const MINUTES_PER_DAY = HOURS_PER_DAY * MINUTES_PER_HOUR
const TIME_STEP = 5  # intervalle logique en minutes

var current_minute: int = 0
var current_hour: int = 0
var current_day: int = 1



var hours_per_day : int = 24
var seconds_per_hour : int = 5

var is_daytime : bool = true


func timer_finished():
	current_minute += TIME_STEP

	if current_minute >= MINUTES_PER_HOUR:
		current_minute = 0
		current_hour += 1
		emit_signal("hour_changed", current_hour)

		if current_hour >= HOURS_PER_DAY:
			current_hour = 0
			current_day += 1
			emit_signal("day_changed", current_day)

	emit_signal("time_tick", current_hour, current_minute)
	
	
	
	#current_hour += 1
	#emit_signal("hour_changed", TimeManager.current_hour)
	#
	#if current_hour >= hours_per_day:
		#current_hour = 0
		#current_day += 1
		#emit_signal("day_changed", TimeManager.current_day)
