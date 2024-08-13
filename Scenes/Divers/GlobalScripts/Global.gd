extends Node2D

signal gold_changed(new_gold)

var is_dragging = false
var move_camera = true

var construction_mode = false
var construction_type = null
var construction_item = null


var game_paused = false
var gold :int = 1000
var research_finished = []
var inventory = {}

func set_gold(value):
	gold = gold + value
	emit_signal("gold_changed", gold)


