extends Control

signal construct_signal

@onready var foundation_container : GridContainer = %Foundations
@onready var door_container : GridContainer= %Doors
@onready var floors_container : GridContainer = %Floors
@onready var objects_container: GridContainer = %Objects
@onready var actions_container : HBoxContainer = %Actions
@onready var right_panel : VBoxContainer = %RightPanel
@onready var global_panel : PanelContainer = %GlobalPanel


const WALL_LIST = preload("res://Ressources/tile_positions.gd").WALLS
const DOOR_LIST = preload("res://Ressources/tile_positions.gd").DOORS
const FLOORS_LIST = preload("res://Ressources/tile_positions.gd").FLOORS
const OBJECT_LIST = preload("res://Ressources/tile_positions.gd").USABLE_OBJECTS



func _ready() -> void:
	add_to_group("UI")
	hide_all_panels()
	
	%FoundationButton.connect("pressed", _on_foundation_pressed)
	%DoorButton.connect("pressed", _on_door_pressed)
	%FloorButton.connect("pressed", _on_floor_pressed)
	%ObjectButton.connect("pressed", _on_object_pressed)
	%ActionButton.connect("pressed", _on_action_pressed)
	
	#chargement des mur/fondations
	for wall_item in WALL_LIST:
		var wall_data = WALL_LIST.get(wall_item)
		var panel_container = VBoxContainer.new()
		var texture_button = TextureButton.new()
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = wall_data.texture
		atlas_texture.region = wall_data.region
		
		texture_button.custom_minimum_size = Vector2(32, 32)
		texture_button.texture_normal = atlas_texture
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("wall", wall_item))
		
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = wall_item
		
		panel_container.add_child(texture_button)
		panel_container.add_child(label)
		foundation_container.add_child(panel_container)
	
	#Chargement des portes
	for door_item in DOOR_LIST:
		var panel_container = VBoxContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/items/" + str(door_item) + ".png")
		
		texture_button.custom_minimum_size = Vector2(32, 32)
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("door", door_item))
		
		var label = Label.new()
		label.text = door_item
		
		panel_container.add_child(texture_button)
		panel_container.add_child(label)

		door_container.add_child(panel_container)
	
	#Chargement des portes
	for floor_item in FLOORS_LIST:
		var panel_container = VBoxContainer.new()
		var texture_button = TextureButton.new()
		var button_image = load("res://Sprites/terrain/" + str(floor_item) + ".png")
		
		texture_button.custom_minimum_size = Vector2(32, 32)
		texture_button.texture_normal = button_image
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("floor", floor_item))
		
		var label = Label.new()
		label.text = floor_item
		
		panel_container.add_child(texture_button)
		panel_container.add_child(label)
		floors_container.add_child(panel_container)	
	
	#Chargement des objets
	for object_item in OBJECT_LIST:
		var object_data = OBJECT_LIST.get(object_item)
		var panel_container = VBoxContainer.new()
		var texture_button = TextureButton.new()
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = object_data.texture
		atlas_texture.region = object_data.region

		texture_button.custom_minimum_size = Vector2(32, 32)
		texture_button.texture_normal = atlas_texture
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_button.connect("pressed", _on_item_pressed.bind("object", object_item))
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = object_item
		
		panel_container.add_child(texture_button)
		panel_container.add_child(label)
		objects_container.add_child(panel_container)


func _on_foundation_pressed() -> void:
	hide_all_panels()
	right_panel.show()
	%Foundations.show()


func _on_door_pressed() -> void:
	hide_all_panels()
	right_panel.show()
	%Doors.show()


func _on_floor_pressed() -> void:
	hide_all_panels()
	right_panel.show()
	%Floors.show()


func _on_object_pressed() -> void:
	hide_all_panels()
	right_panel.show()
	%Objects.show()


func _on_action_pressed() -> void:
	hide_all_panels()
	right_panel.show()
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
	for panel in global_panel.get_children():
		panel.hide()
	right_panel.hide()

func _on_construction_btn_pressed() -> void:
	if !self.visible:
		GameData.hide_ui()
	self.visible = !self.visible
	GameData.menu_open = false	
