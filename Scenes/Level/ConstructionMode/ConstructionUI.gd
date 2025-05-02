extends Control

signal construct_signal

@onready var global_panel : PanelContainer= $GlobalPanel
@onready var walls_and_doors_panel : Control= $GlobalPanel/MarginContainer/Menu/WallsAndDoorsPanel
@onready var wall : GridContainer= $GlobalPanel/MarginContainer/Menu/WallsAndDoorsPanel/Wall
@onready var door : GridContainer= $GlobalPanel/MarginContainer/Menu/WallsAndDoorsPanel/Door
@onready var floors_panel : GridContainer= $GlobalPanel/MarginContainer/Menu/FloorsPanel
@onready var objects_panel : GridContainer = $GlobalPanel/MarginContainer/Menu/ObjectsPanel
@onready var actions_panel : HBoxContainer= $GlobalPanel/MarginContainer/Menu/ActionsPanel
@onready var wall_and_door_button : Button= $Button/WallAndDoor
@onready var floor_button : Button = $Button/Floor
@onready var object_button : Button = $Button/Object
@onready var action_button : Button = $Button/Action
@onready var show_wall_panel_button : Button = $GlobalPanel/MarginContainer/Menu/WallsAndDoorsPanel/PanelSelector/Button
@onready var show_door_panel_button : Button = $GlobalPanel/MarginContainer/Menu/WallsAndDoorsPanel/PanelSelector/Button2


func _ready() -> void:
	# Ensure only one panel is visible at a time
	walls_and_doors_panel.add_to_group("UI")
	floors_panel.add_to_group("UI")
	objects_panel.add_to_group("UI")
	actions_panel.add_to_group("UI")
	global_panel.add_to_group("UI")
	hide_all_panels()


func _on_wall_and_door_pressed() -> void:
	if walls_and_doors_panel.visible == false:
		hide_all_panels()
		global_panel.show()
		walls_and_doors_panel.show()
		GameData.menu_open = false
	else:
		GameData.construction_type = ""
		hide_all_panels()


func _on_floor_pressed() -> void:
	if floors_panel.visible == false:
		hide_all_panels()
		global_panel.show()
		floors_panel.show()
		GameData.menu_open = false
	else:
		GameData.construction_type = ""
		hide_all_panels()


func _on_object_pressed() -> void:
	if objects_panel.visible == false:
		hide_all_panels()
		global_panel.show()
		objects_panel.show()
		GameData.menu_open = false
	else:
		GameData.construction_type = ""
		hide_all_panels()


func _on_action_pressed() -> void:
	if actions_panel.visible == false:
		hide_all_panels()
		global_panel.show()
		actions_panel.show()
		GameData.menu_open = false
	else:
		GameData.construction_type = ""
		hide_all_panels()



func _on_show_wall_panel_pressed() -> void:
	door.hide()
	wall.show()


func _on_show_door_panel_pressed() -> void:
	wall.hide()
	door.show()


func _on_item_pressed(item_type, item_name) -> void:
	GameData.construction_type = item_type
	GameData.construction_item = item_name
	emit_signal("construct_signal")


func _on_destroy_all_pressed() -> void:
	GameData.construction_type = "destroy_all"
	emit_signal("construct_signal")


func _on_destroy_wall_pressed() -> void:
	GameData.construction_type = "destroy_wall"
	emit_signal("construct_signal")


func _on_destroy_floor_pressed() -> void:
	GameData.construction_type = "destroy_floor"
	emit_signal("construct_signal")


func _on_destroy_object_pressed() -> void:
	GameData.construction_type = "destroy_object"
	emit_signal("construct_signal")


func hide_all_panels() -> void:
	GameData.hide_ui()
