extends Node2D

signal hero_sleeping(hero)

@export var used :bool = false

func _on_Hero_body_entered(body):
	if body is Hero:
		emit_signal("hero_sleeping", body)
	used = true
	print(used)


func _on_area_2d_body_exited(_body):
	used = false
	print(used)
