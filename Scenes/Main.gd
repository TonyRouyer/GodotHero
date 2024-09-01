extends Node2D

@onready var gold_label = $UICanvasLayer/TopMenu/HBoxContainer2/GoldLabel

@onready var bottom_panel = $UICanvasLayer/BottomMenu/HBoxContainer/Panel
@onready var top_panel = $UICanvasLayer/TopMenu/HBoxContainer/Panel




# Called when the node enters the scene tree for the first time.
func _ready():
	gold_label.text = "gold: " + str(Global.gold)
	Global.connect("gold_changed", _on_gold_changed)
	get_tree().root.connect("size_changed", _on_viewport_size_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#func _input(event):
	#if Input.is_action_pressed("click"):
		#var map = $TileMap/TileMap
		#print(map.local_to_map(get_global_mouse_position()))

func _on_gold_changed(new_gold):
	gold_label.text = "Gold: " + str(new_gold)

func _on_viewport_size_changed():
	var size_x = get_viewport().size.x
	bottom_panel.size.x = size_x
	top_panel.size.x = size_x
