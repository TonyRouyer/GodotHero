extends Node2D

@onready var gold_label : Label = %GoldLabel
@onready var bottom_panel : Panel = %BottomPanel
@onready var top_panel : Panel = %TopPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label.text = "gold: " + str(GameData.gold)
	GameData.connect("gold_changed", _on_gold_changed)
	get_tree().root.connect("size_changed", _on_viewport_size_changed)


func _on_gold_changed(new_gold : int) -> void:
	gold_label.text = "Gold: " + str(new_gold)

func _on_viewport_size_changed() -> void:
	var size_x = get_viewport().size.x
	bottom_panel.size.x = size_x
	top_panel.size.x = size_x
