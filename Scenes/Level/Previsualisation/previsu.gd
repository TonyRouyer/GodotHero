extends Node2D
class_name Previsualisation

@onready var TilePositions : Script = get_parent().TilePositions
@onready var tilemap : TileMapLayer = $"../../TileMap".get_node("Floor")
@onready var room : Node2D = $".."

@onready var preview_instance : Node2D = null  # Instance de l'objet de prévisualisation
@export var preview_color : Color = Color(0, 1, 0, 0.5)
@export var border_color : Color = Color(0, 0, 1, 1) # Couleur de la bordure bleue
@onready var grid_size : int = get_parent().grid_size
@onready var is_selecting : bool = false
@onready var start_pos : Vector2 = Vector2.ZERO
@onready var end_pos : Vector2 = Vector2.ZERO
var tileset_texture : Texture = null
var current_rotation : int = 0

func _ready() -> void:
	room.connect("previsu_signal", _on_previsu_signal)
	room.connect("selecting_signal", _on_selecting_signal )
	room.connect("rotation_change", _on_rotation_change )


func _draw() -> void:
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


func _process(_delta) -> void:
	end_pos = room.check_cell()
	
	if GameData.construction_type in ["object", "move"]:
		if preview_instance:
			var aligned_pos = room.check_cell()  * grid_size
			room.rotate_object(preview_instance, current_rotation)
			
			var new_pos: Vector2i
			if preview_instance.rotate_state == 0:
				new_pos = aligned_pos + Vector2i(0,8)
			elif preview_instance.rotate_state == 1:
				new_pos = aligned_pos + Vector2i(8,0)
			elif preview_instance.rotate_state == 2:
				new_pos = aligned_pos + Vector2i(0,8)
			elif preview_instance.rotate_state == 3:
				new_pos = aligned_pos + Vector2i(8,0)
	
			preview_instance.position = new_pos 
	elif GameData.construction_type in ["door"]:
		if preview_instance:
			var aligned_pos = room.check_cell() * grid_size
			preview_instance.position = aligned_pos
	elif is_selecting:
		queue_redraw()


func _on_selecting_signal(state : bool, pos : Vector2) -> void:
	is_selecting = state
	start_pos = pos


func _on_previsu_signal():
	reset_previsualisation()
	instantiate_preview()

func _on_rotation_change(rotation_state):
	current_rotation = rotation_state

func instantiate_preview() -> void:
	if preview_instance:
		preview_instance.queue_free()

	match GameData.construction_type:
		"door":
			preview_instance = Sprite2D.new()
			preview_instance.texture = get_preview_atlas_texture(GameData.construction_item)
			preview_instance.modulate = Color(1, 1, 1, 0.5)
		"object", "move":
			var usable_object_scene = TilePositions.USABLE_OBJECTS[GameData.construction_item]
			preview_instance = usable_object_scene.instantiate()
			preview_instance.modulate = Color(1, 1, 1, 0.5)
	if preview_instance:
		add_child(preview_instance)


func reset_previsualisation() -> void:
	is_selecting = false
	start_pos = room.check_cell()
	end_pos = Vector2()
	current_rotation = 0  # Reset rotation to the front face when resetting the preview
	queue_redraw()
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null


func get_preview_atlas_texture(item_type : String) -> AtlasTexture:
	# Récupère les coordonnées sur le TileSet
	var tile_coords = null
	var grid_size_x = grid_size
	
	match GameData.construction_type:
		"door":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.DOOR_TILES[item_type].pos
		"object", "move":
			tileset_texture = preload("res://Sprites/terrain/interior.png")
			tile_coords = TilePositions.USABLE_OBJECTS[item_type].pos
			grid_size_x *= 2
		"wall":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.WALL_TILES[item_type].pos
		"floor":
			tileset_texture = preload("res://Sprites/terrain/terrain.png")
			tile_coords = TilePositions.FLOOR_TILES[item_type].pos
			
	# Créer une AtlasTexture et définir la texture et la région
	var atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(tileset_texture)
	
	atlas_texture.set_region(Rect2(tile_coords.x * grid_size, tile_coords.y * grid_size, grid_size_x, grid_size))
	return atlas_texture
