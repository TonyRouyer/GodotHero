extends Node2D

@onready var gold_label : Label = %GoldLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label.text = "gold: " + str(GameData.gold)
	GameData.connect("gold_changed", _on_gold_changed)


func _on_gold_changed(new_gold : int) -> void:
	gold_label.text = "Gold: " + str(new_gold)
