extends Control

func _ready() -> void:
	add_to_group("UI")

func _on_craft_btn_pressed() -> void:
	if self.visible:
		self.visible = false
		GameData.menu_open = false
	else:
		GameData.hide_ui()
		self.visible = true
		GameData.menu_open = true
