extends Control

@onready var goldLabel = $Panel/GoldLabel
var gold :int = 0

func _ready():
	goldLabel.text = "Gold: " + str(gold)


