extends Node2D

@export var tile_size = 16
@export var grid_width = 124
@export var grid_height = 64
@export var grid_color = Color(1, 1, 1, 0.3)

func _ready():
	queue_redraw()

func _draw():
	var width = grid_width * tile_size
	var height = grid_height * tile_size
	
	# Dessiner les lignes horizontales
	for y in range(0, int(height), tile_size):
		draw_line(Vector2(0, y), Vector2(width, y), grid_color)
	
	# Dessiner les lignes verticales
	for x in range(0, int(width), tile_size):
		draw_line(Vector2(x, 0), Vector2(x, height), grid_color)
