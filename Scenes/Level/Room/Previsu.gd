extends Node2D

@onready var TilePositions = get_parent().TilePositions
@onready var tilemap = $"../../TileMap".get_node("TileMap")
@onready var construction_ui = $"../../UICanvasLayer/BottomMenu/ConstructionUi"

@onready var room_utility_functions = $"../RoomUtilityFunctions"
@onready var preview_instance = null  # Instance de l'objet de prévisualisation

@export var preview_color = Color(0, 1, 0, 0.5)
@onready var grid_size = get_parent().grid_size

@onready var is_selecting = false
@onready var start_pos = Vector2()
@onready var end_pos = Vector2()



var tileset_texture = null

func _ready():
	construction_ui.connect("construct_signal", _on_construct_signal)

func _draw():
	# Dessiner la prévisualisation si en mode sélection
	if is_selecting:
		var rect_pos = Vector2(min(start_pos.x, end_pos.x) * grid_size, min(start_pos.y, end_pos.y) * grid_size)
		var rect_size = Vector2(abs(start_pos.x - end_pos.x) + 1, abs(start_pos.y - end_pos.y) + 1) * grid_size
		draw_rect(Rect2(rect_pos, rect_size), preview_color, true)

func _input(event):
	var mouse_in_menu = get_parent().mouse_in_menu
	if !mouse_in_menu:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and global.construction_type in ["door", "usable_object", "object"]:
				start_pos = room_utility_functions.check_cell()
				is_selecting = false
				instantiate_preview()
			elif event.pressed and global.construction_type != null:
				start_pos = room_utility_functions.check_cell()
				is_selecting = true
			elif not event.pressed and global.construction_type:
				end_pos = room_utility_functions.check_cell()
				is_selecting = false
				remove_preview()

func _process(_delta):
	if global.construction_type in ["door", "usable_object", "object"]:
		update_preview_position()
	elif is_selecting:
		end_pos = room_utility_functions.check_cell()
		queue_redraw()

func _on_construct_signal():
	reset_previsualisation()

func instantiate_preview():
	if preview_instance:
		preview_instance.queue_free()

	match global.construction_type:
		"door", "object":
			# On place une texture sur le TileMap en utilisant les coordonnées du TileSet
			preview_instance = Sprite2D.new()
			preview_instance.texture = get_preview_atlas_texture(global.construction_item)
			preview_instance.modulate = Color(1, 1, 1, 0.5) 
		"usable_object":
			# On instancie une scène pour l'objet utilisable
			var usable_object_scene = TilePositions.USABLE_OBJECTS[global.construction_item]
			preview_instance = usable_object_scene.instantiate()
			preview_instance.modulate = Color(1, 1, 1, 0.5)

	if preview_instance:
		add_child(preview_instance)
		update_preview_position()

func get_preview_atlas_texture(item_type):
	# Récupère les coordonnées sur le TileSet
	var tile_coords = null
	var grid_size_x = grid_size
	if global.construction_type =="door":
		tileset_texture = preload("res://Sprites/terrain/plains.png")
		tile_coords = TilePositions.DOOR_TILES[item_type]
	else:
		tileset_texture = preload("res://Sprites/terrain/interior.png")
		tile_coords = TilePositions.OBJECT_TILES[item_type]
		grid_size_x *= 2

	# Créer une AtlasTexture et définir la texture et la région
	var atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(tileset_texture)
	
	# Supposons que chaque tile sur le tileset est de la taille `grid_size`
	atlas_texture.set_region(Rect2(tile_coords.x * grid_size, tile_coords.y * grid_size, grid_size_x, grid_size))
	return atlas_texture


func update_preview_position():
	if preview_instance:
		var aligned_pos = room_utility_functions.check_cell() * grid_size
		preview_instance.position = aligned_pos

func reset_previsualisation():
	is_selecting = false
	start_pos = room_utility_functions.check_cell()
	end_pos = Vector2()
	queue_redraw()
	remove_preview()
	
func remove_preview():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null





