extends Control

signal construct_signal

@onready var global_panel : PanelContainer= %GlobalPanel
@onready var foundation_container : GridContainer = %Foundations
@onready var door_container : GridContainer= %Doors
@onready var floors_container : GridContainer = %Floors
@onready var objects_container: GridContainer = %Objects
@onready var actions_container : HBoxContainer = %Actions
@onready var rooms_container : GridContainer = %Rooms


const WALL_LIST = preload("res://Ressources/tile_positions.gd").WALLS
const DOOR_LIST = preload("res://Ressources/tile_positions.gd").DOORS
const FLOORS_LIST = preload("res://Ressources/tile_positions.gd").FLOORS
const OBJECT_LIST = preload("res://Ressources/tile_positions.gd").OBJECTS
const ROOMS_LIST = preload("res://Ressources/tile_positions.gd").ROOMS



func _ready() -> void:
	add_to_group("UI")
	hide_all_panels()
	
	%FoundationButton.connect("pressed", _on_foundation_pressed)
	%DoorButton.connect("pressed", _on_door_pressed)
	%FloorButton.connect("pressed", _on_floor_pressed)
	%ObjectButton.connect("pressed", _on_object_pressed)
	%ActionButton.connect("pressed", _on_action_pressed)
	%RoomButton.connect("pressed", _on_room_pressed)
	
	#chargement des mur/fondations
	for wall_item in WALL_LIST:
		var panel_container = PanelContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/terrain/icon/" + str(wall_item) + ".png")
		var label = Label.new()
		
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("wall", wall_item))
		label.text = wall_item
		
		#texture_button.add_child(label)
		panel_container.add_child(texture_button)
		foundation_container.add_child(panel_container)
	
	#Chargement des portes
	for door_item in DOOR_LIST:
		var panel_container = PanelContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/items/" + str(door_item) + ".png")
		var label = Label.new()
		
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("door", door_item))
		label.text = door_item
		
		#texture_button.add_child(label)
		panel_container.add_child(texture_button)
		door_container.add_child(panel_container)	
	
	#Chargement des portes
	for floor_item in FLOORS_LIST:
		var panel_container = PanelContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/terrain/" + str(floor_item) + ".png")
		var label = Label.new()
		
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("floor", floor_item))
		label.text = floor_item
		
		#texture_button.add_child(label)
		panel_container.add_child(texture_button)
		floors_container.add_child(panel_container)	
	
	#Chargement des objets
	for object_item in OBJECT_LIST:
		var panel_container = PanelContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/items/icon/" + str(object_item) + ".png")
		var label = Label.new()
		
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("object", object_item))
		label.text = object_item
		
		#texture_button.add_child(label)
		panel_container.add_child(texture_button)
		objects_container.add_child(panel_container)

	#Chargement des zone
	for room_item in ROOMS_LIST:
		var container = VBoxContainer.new()
		var texture_button = TextureButton.new()
		#var button_image = load("res://Sprites/items/icon/" + str(object_item) + ".png")
		var button_image = load("res://Sprites/items/icon/anvil.png")
		var label = Label.new()
		
		container.name = room_item
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("room", room_item))
		label.text = room_item
		
		#texture_button.add_child(label)
		container.add_child(texture_button)
		container.add_child(label)
		
		rooms_container.add_child(container)


func _on_foundation_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Foundations.show()


func _on_door_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Doors.show()


func _on_floor_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Floors.show()


func _on_object_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Objects.show()

func _on_room_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Rooms.show()


func _on_action_pressed() -> void:
	hide_all_panels()
	%GlobalPanel.show()
	%Actions.show()



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
	for panel in %GlobalPanel.get_children():
		panel.hide()
	%GlobalPanel.hide()

func _on_construction_btn_pressed() -> void:
	if !self.visible:
		GameData.hide_ui()
	self.visible = !self.visible
	GameData.menu_open = !GameData.menu_open
	
