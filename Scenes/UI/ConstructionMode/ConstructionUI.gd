extends Control

signal construct_signal
signal mouse_in_menu
signal mouse_out_menu

@onready var walls_and_doors_panel = $Menu/WallsAndDoorsPanel
@onready var wall = $Menu/WallsAndDoorsPanel/Wall
@onready var door = $Menu/WallsAndDoorsPanel/Door

@onready var floors_panel = $Menu/FloorsPanel
@onready var objects_panel = $Menu/ObjectsPanel
@onready var actions_panel = $Menu/ActionsPanel

@onready var wall_and_door_button = $Button/WallAndDoor
@onready var floor_button = $Button/Floor
@onready var object_button = $Button/Object
@onready var action_button = $Button/Action

@onready var show_wall_panel_button = $Menu/WallsAndDoorsPanel/PanelSelector/Button
@onready var show_door_panel_button = $Menu/WallsAndDoorsPanel/PanelSelector/Button2

func _ready():
	# Ensure only one panel is visible at a time
	hide_all_panels()


func _on_mouse_entered():
	emit_signal("mouse_in_menu")

func _on_mouse_exited():
	emit_signal("mouse_out_menu")

func _on_wall_and_door_pressed():
	if walls_and_doors_panel.visible == false:
		hide_all_panels()
		walls_and_doors_panel.show()
	else:
		global.construction_type = null
		hide_all_panels()

func _on_floor_pressed():
	if floors_panel.visible == false:
		hide_all_panels()
		floors_panel.show()
	else:
		global.construction_type = null
		hide_all_panels()

func _on_object_pressed():
	if objects_panel.visible == false:
		hide_all_panels()
		objects_panel.show()
	else:
		global.construction_type = null
		hide_all_panels()

func _on_action_pressed():
	if actions_panel.visible == false:
		hide_all_panels()
		actions_panel.show()
	else:
		global.construction_type = null
		hide_all_panels()

func _on_show_wall_panel_pressed():
	door.hide()
	wall.show()

func _on_show_door_panel_pressed():
	wall.hide()
	door.show()

func hide_all_panels():
	walls_and_doors_panel.hide()
	floors_panel.hide()
	objects_panel.hide()
	actions_panel.hide()

func _on_item_pressed(item_type, item_name):
	global.construction_type = item_type
	global.construction_item = item_name
	emit_signal("construct_signal")

func _on_destroy_all_pressed():
	global.construction_type = "destroy_all"
	emit_signal("construct_signal")

func _on_destroy_wall_pressed():
	global.construction_type = "destroy_wall"
	emit_signal("construct_signal")

func _on_destroy_floor_pressed():
	global.construction_type = "destroy_floor"
	emit_signal("construct_signal")

func _on_destroy_object_pressed():
	global.construction_type = "destroy_object"
	emit_signal("construct_signal")

