extends Control

signal close_skills()


func _ready() -> void:
	add_to_group("UI")
	%CloseButton.connect("pressed", _on_close_pressed)


func _on_close_pressed() -> void:
	close_skills.emit()
