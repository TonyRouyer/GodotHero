extends Node2D

signal hero_resting(hero)

func _on_Hero_body_entered(body):
	if body is Hero:
		emit_signal("hero_resting", body)
