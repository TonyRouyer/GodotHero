## Grid.gd
## Grille visuelle affichée en mode construction.
## Dessinée via _draw() — aucune TileMap.
extends Node2D


@export var tile_size   : int   = 16
@export var grid_width  : int   = 99
@export var grid_height : int   = 72
@export var grid_color  : Color = Color(1.0, 1.0, 1.0, 0.18)


func _ready() -> void:
	visible = false
	queue_redraw()


func _draw() -> void:
	var w = grid_width  * tile_size
	var h = grid_height * tile_size

	for y in range(0, h + 1, tile_size):
		draw_line(Vector2(0, y), Vector2(w, y), grid_color, 0.5)
	for x in range(0, w + 1, tile_size):
		draw_line(Vector2(x, 0), Vector2(x, h), grid_color, 0.5)


## Retourne la cellule de grille sous la souris (en coordonnées tuile)
func get_hovered_cell() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return Vector2i(
		int(mouse_pos.x) / tile_size,
		int(mouse_pos.y) / tile_size
	)


## Convertit une position tuile en position monde (coin haut-gauche)
func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile) * tile_size
