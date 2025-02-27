extends Node2D

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
