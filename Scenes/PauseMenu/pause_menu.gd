extends Control

@onready var option_btn = %OptionBtn
@onready var save_btn = %SaveBtn
@onready var load_btn = %LoadBtn
@onready var quit_btn = %QuitBtn

func _ready():
	option_btn.connect("pressed", _on_option_pressed)
	save_btn.connect("pressed", _on_save_pressed)
	load_btn.connect("pressed", _on_load_pressed)
	quit_btn.connect("pressed", _on_quit_pressed)


func _on_menu_btn_pressed() -> void:
	if self.visible:
		self.visible = false
		GameData.menu_open = false
	else:
		GameData.hide_ui()
		self.visible = true
		GameData.menu_open = true	
	
	
func _on_option_pressed() -> void:
	print("option pressed")

func _on_save_pressed() -> void:
	print("save pressed")
	
func _on_load_pressed() -> void:
	print("load pressed")
	
func _on_quit_pressed() -> void:
	print("qui pressed")
