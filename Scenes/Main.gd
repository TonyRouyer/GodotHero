extends Node2D

@onready var gold_label = $UICanvasLayer/TopMenu/GoldLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	gold_label.text = "gold: " + str(global.gold)
	global.connect("gold_changed", _on_gold_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_gold_changed(new_gold):
	gold_label.text = "Gold: " + str(new_gold)
