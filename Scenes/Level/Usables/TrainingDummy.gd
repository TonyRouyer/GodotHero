extends Node2D

signal hero_trained(hero)
@onready var sprite = $Sprite2D



func _on_Hero_body_entered(body):
	if body is Hero:
		emit_signal("hero_trained", body)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.has("hero")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.has("hero"):
		var hero = data["hero"]
		hero.global_position = global_position
		hero.draggable = false
		hero.perform_activity("train")
