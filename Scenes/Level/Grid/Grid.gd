extends Node2D

@onready var room : Node2D = get_parent()

@export var tile_size : int = 16
@export var grid_width : int = 72
@export var grid_height : int = 41
@export var grid_color : Color = Color(1, 1, 1, 0.3)

var occupied_cells : Array = []
var occupied_objects :Dictionary = {}

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var width = grid_width * tile_size
	var height = grid_height * tile_size
	
	# Dessiner les lignes horizontales
	for y in range(0, int(height), tile_size):
		draw_line(Vector2(0, y), Vector2(width, y), grid_color)
	
	# Dessiner les lignes verticales
	for x in range(0, int(width), tile_size):
		draw_line(Vector2(x, 0), Vector2(x, height), grid_color)

# Vérifie la cellule sous la souris et la retourne
func check_cell() -> Vector2:
	return room.floorLayer.local_to_map(get_global_mouse_position())  # map_pos


# Vérifie si une position est dans les limites de la grille
func is_within_bounds(pos : Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height


# Marque les cellules comme occupées à une position spécifiée
func mark_occupied_cells(tile_origin: Vector2, size: Vector2) -> void:
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var cell_position = Vector2(x, y)
			occupied_objects[cell_position] = {
				"origin": tile_origin,
				"size": size
			}


# Libère les cellules occupées à une position spécifiée
func clear_occupied_cells(tile_origin: Vector2) -> void:
	if tile_origin in occupied_objects:
		var obj_data = occupied_objects[tile_origin]
		var object_size = obj_data["size"]
		# Supprime toutes les cellules occupées par cet objet
		for x in range(tile_origin.x, tile_origin.x + object_size.x):
			for y in range(tile_origin.y, tile_origin.y + object_size.y):
				occupied_objects.erase(Vector2(x, y))
