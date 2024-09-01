extends Node2D
class_name Previsualisation

@onready var TilePositions = get_parent().TilePositions
@onready var tilemap = $"../../TileMap".get_node("TileMap")
@onready var room = $".."

@onready var preview_instance = null  # Instance de l'objet de prévisualisation
@export var preview_color = Color(0, 1, 0, 0.5)
@export var border_color = Color(0, 0, 1, 1) # Couleur de la bordure bleue
@onready var grid_size = get_parent().grid_size

@onready var is_selecting = false
@onready var start_pos = Vector2()
@onready var end_pos = Vector2()

var tileset_texture = null
var current_rotation = 0

func _ready():
	room.connect("previsu_signal", _on_previsu_signal)
	room.connect("selecting_signal", _on_selecting_signal )
	room.connect("rotation_change", _on_rotation_change )

func _draw():
	if is_selecting:
		var rect_pos = Vector2(min(start_pos.x, end_pos.x) * grid_size, min(start_pos.y, end_pos.y) * grid_size)
		var rect_size = Vector2(abs(start_pos.x - end_pos.x) + 1, abs(start_pos.y - end_pos.y) + 1) * grid_size
		
		# Dessiner les bordures extérieures
		var top_left = rect_pos
		var top_right = rect_pos + Vector2(rect_size.x, 0)
		var bottom_left = rect_pos + Vector2(0, rect_size.y)
		var bottom_right = rect_pos + Vector2(rect_size.x, rect_size.y)
		
		draw_line(top_left, top_right, border_color, 2)
		draw_line(bottom_left, bottom_right, border_color, 2)
		draw_line(top_left, bottom_left, border_color, 2)
		draw_line(top_right, bottom_right, border_color, 2)

func _process(_delta):
	end_pos = room.check_cell()
	
	if Global.construction_type in ["object", "move"]:
		if preview_instance:
			var aligned_pos = room.check_cell()   * grid_size
			room.rotate_object(preview_instance, current_rotation)
			preview_instance.position = aligned_pos
	elif Global.construction_type in ["door"]:
		if preview_instance:

			var aligned_pos = room.check_cell() * grid_size
			preview_instance.position = aligned_pos
	elif is_selecting:
		queue_redraw()

func _on_selecting_signal(state, pos):
	is_selecting = state
	start_pos = pos

func _on_previsu_signal():
	reset_previsualisation()
	instantiate_preview()

func _on_rotation_change(rotation_state):
	current_rotation = rotation_state

func instantiate_preview():
	if preview_instance:
		preview_instance.queue_free()

	match Global.construction_type:
		"door":
			preview_instance = Sprite2D.new()
			preview_instance.texture = get_preview_atlas_texture(Global.construction_item)
			preview_instance.modulate = Color(1, 1, 1, 0.5)
		"object", "move":
			var usable_object_scene = TilePositions.USABLE_OBJECTS[Global.construction_item]
			preview_instance = usable_object_scene.instantiate()
			preview_instance.modulate = Color(1, 1, 1, 0.5)
	if preview_instance:
		add_child(preview_instance)

func reset_previsualisation():
	is_selecting = false
	start_pos = room.check_cell()
	end_pos = Vector2()
	current_rotation = 0  # Reset rotation to the front face when resetting the preview
	queue_redraw()
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null

func get_preview_atlas_texture(item_type):
	# Récupère les coordonnées sur le TileSet
	var tile_coords = null
	var grid_size_x = grid_size
	
	match Global.construction_type:
		"door":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.DOOR_TILES[item_type]
		"object", "move":
			tileset_texture = preload("res://Sprites/terrain/interior.png")
			tile_coords = TilePositions.USABLE_OBJECTS[item_type]
			grid_size_x *= 2
		"wall":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.WALL_TILES[item_type]
		"floor":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.FLOOR_TILES[item_type]
			
	# Créer une AtlasTexture et définir la texture et la région
	var atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(tileset_texture)
	
	# Supposons que chaque tile sur le tileset est de la taille `grid_size`
	atlas_texture.set_region(Rect2(tile_coords.x * grid_size, tile_coords.y * grid_size, grid_size_x, grid_size))
	return atlas_texture
