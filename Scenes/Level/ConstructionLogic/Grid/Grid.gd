extends Node2D

@onready var parent : Node2D = get_parent()

@export var tile_size : int = 16
@export var grid_width : int = 72
@export var grid_height : int = 41
@export var grid_color : Color = Color(1, 1, 1, 0.3)


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
	return parent.build_logic.floor_layer.local_to_map(get_global_mouse_position())  # map_pos


# Vérifie si une position est dans les limites de la grille
func is_within_bounds(pos : Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height
