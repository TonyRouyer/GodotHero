extends Node2D

@onready var tilemap = $"../TileMap".get_node("TileMap")
@onready var grid = $"../Grid"

@export var grid_size = 16
@export var grid_wide = 64
@export var grid_height = 32
@export var preview_color = Color(0, 1, 0, 0.5)  # Couleur des cases en prévisualisation (vert)

var start_pos = Vector2()
var end_pos = Vector2()
var is_selecting = false
var mouse_in_menu = true

# Définition des coordonnées des tuiles pour les murs
const ANGLE_TOP_LEFT = Vector2(2, 0)
const ANGLE_TOP_RIGHT = Vector2(3, 0)
const ANGLE_BOTTOM_LEFT = Vector2(2, 1)
const ANGLE_BOTTOM_RIGHT = Vector2(3, 1)

const WALL_HORIZONTAL = Vector2(1, 0)
const WALL_VERTICAL = Vector2(0, 0)

const WALL_END_HORIZONTAL_LEFT = Vector2(1, 1)
const WALL_END_HORIZONTAL_RIGHT = Vector2(4, 3)
const WALL_END_VERTICAL_BOTTOM = Vector2(0, 2)
const WALL_END_VERTICAL_TOP = Vector2(0, 3)

const WALL_T_INTERSECTION_UP = Vector2(4, 1)
const WALL_T_INTERSECTION_RIGHT = Vector2(4, 2)
const WALL_T_INTERSECTION_DOWN = Vector2(4, 0)
const WALL_T_INTERSECTION_LEFT = Vector2(5, 2)
const WALL_X_INTERSECTION = Vector2(6, 2)

# Définition des coordonnées des tuiles pour le sol
const FLOOR_TILE_ID = Vector2(0, 9)

# Définition de l'ID de tuile pour la porte
const DOOR_TILE_ID = Vector2(5, 9)

func _ready():
	grid.visible = false

func _draw():
	# Dessiner la prévisualisation si en mode sélection
	if is_selecting:
		if global.construction_type == "floor" or global.construction_type == "wall":
			var rect_pos = Vector2(min(start_pos.x, end_pos.x) * grid_size, min(start_pos.y, end_pos.y) * grid_size)
			var rect_size = Vector2(abs(start_pos.x - end_pos.x) + 1, abs(start_pos.y - end_pos.y) + 1) * grid_size
			draw_rect(Rect2(rect_pos, rect_size), preview_color, true)
		elif global.construction_type == "door":
			var door_pos = start_pos * grid_size
			draw_rect(Rect2(door_pos, Vector2(grid_size, grid_size)), preview_color, true)

func _input(_event):
	if !mouse_in_menu:
		if Input.is_action_just_pressed("click") and global.construction_mode:
			start_pos = check_cell()
			is_selecting = true
		
		if Input.is_action_just_released("click") and global.construction_mode:
			if global.construction_type == "door":
				end_pos = start_pos
			else:
				end_pos = check_cell()
			is_selecting = false

			create_construction()
			reset_previsualisation()
				
func _process(_delta):
	if global.construction_mode:
		grid.visible = true
	else:
		grid.visible = false
	if is_selecting:
		end_pos = check_cell()
		queue_redraw()

# Determine les coordonnées de la case sous la souris
func check_cell():
	var mouse_pos = get_global_mouse_position()
	var map_pos = tilemap.local_to_map(mouse_pos)
	return map_pos

# Reset la prévisualisation
func reset_previsualisation():
	is_selecting = false
	start_pos = check_cell()
	end_pos = Vector2()
	queue_redraw()

# Modifie le tileset en fonction de ce qui doit être créé
func create_construction():
	if global.construction_type == "wall":
		if start_pos.x == end_pos.x:
			# Vertical
			for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
				var tile_origin = Vector2(start_pos.x, y)
				var tile_id = determine_wall_tile_id(tile_origin)
				tilemap.set_cell(1, tile_origin, 4, tile_id)
				update_neighbors(tile_origin)
				
		elif start_pos.y == end_pos.y:
			# Horizontal
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				var tile_origin = Vector2(x, start_pos.y)
				var tile_id = determine_wall_tile_id(tile_origin)
				tilemap.set_cell(1, tile_origin, 4, tile_id)
				update_neighbors(tile_origin)
		
		else:
			# Rectangle
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
						var tile_origin = Vector2(x, y)
						var tile_id = determine_wall_tile_id(tile_origin)
						tilemap.set_cell(1, tile_origin, 4, tile_id)
						update_neighbors(tile_origin)

	elif global.construction_type == "floor":
		for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
			for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
				var tile_origin = Vector2(x, y)
				# Vérifie l'index du tileset sur lequel on veut créer (4 = wall)
				var tile_under = tilemap.get_cell_source_id(1, tile_origin)
				if tile_under != 4:
					tilemap.set_cell(1, tile_origin, 0, FLOOR_TILE_ID)

	elif global.construction_type == "door":
		var tile_origin = start_pos
		tilemap.set_cell(2, tile_origin, 0, DOOR_TILE_ID)
		update_neighbors(tile_origin)

func determine_wall_tile_id(tile_origin):
	# Logique pour déterminer l'ID du tile de mur en fonction de l'orientation et des tiles adjacents
	var neighbors = get_neighbors(tile_origin)
	
	# Aucun bloc adjacent
	if neighbors.size() == 0:
		return WALL_VERTICAL

	# 1 bloc adjacent
	if neighbors.size() == 1:
		var direction = neighbors.keys()[0]
		if direction == "north":
			return WALL_END_VERTICAL_BOTTOM
		elif direction == "south":
			return WALL_END_VERTICAL_TOP
		elif direction == "west":
			return WALL_END_HORIZONTAL_RIGHT
		elif direction == "east":
			return WALL_END_HORIZONTAL_LEFT

	# 2 blocs adjacents
	if neighbors.size() == 2:
		if neighbors.has("north") and neighbors.has("west"):
			return ANGLE_BOTTOM_RIGHT
		elif neighbors.has("north") and neighbors.has("east"):
			return ANGLE_BOTTOM_LEFT
		elif neighbors.has("south") and neighbors.has("west"):
			return ANGLE_TOP_RIGHT
		elif neighbors.has("south") and neighbors.has("east"):
			return ANGLE_TOP_LEFT
		elif neighbors.has("west") and neighbors.has("east"):
			return WALL_HORIZONTAL
		elif neighbors.has("north") and neighbors.has("south"):
			return WALL_VERTICAL

	# 3 blocs adjacents
	if neighbors.size() == 3:
		if neighbors.has("north") and neighbors.has("west") and neighbors.has("east"):
			return WALL_T_INTERSECTION_UP
		elif neighbors.has("south") and neighbors.has("west") and neighbors.has("east"):
			return WALL_T_INTERSECTION_DOWN
		elif neighbors.has("north") and neighbors.has("south") and neighbors.has("west"):
			return WALL_T_INTERSECTION_LEFT
		elif neighbors.has("north") and neighbors.has("south") and neighbors.has("east"):
			return WALL_T_INTERSECTION_RIGHT

	# 4 blocs adjacents
	if neighbors.size() == 4:
		return WALL_X_INTERSECTION

	return WALL_HORIZONTAL

func get_neighbors(pos):
	var neighbors = {}
	if tilemap.get_cell_source_id(1, pos + Vector2(0, -1)) == 4:
		neighbors["north"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(0, 1)) == 4:
		neighbors["south"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(-1, 0)) == 4:
		neighbors["west"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(1, 0)) == 4:
		neighbors["east"] = true
	return neighbors

func update_neighbors(pos):
	var neighbors = [
		Vector2(pos.x, pos.y - 1),  # Nord
		Vector2(pos.x + 1, pos.y),  # Est
		Vector2(pos.x, pos.y + 1),  # Sud
		Vector2(pos.x - 1, pos.y)   # Ouest
	]
	for neighbor in neighbors:
		if tilemap.get_cell_source_id(1, neighbor) == 4:
			var tile_id = determine_wall_tile_id(neighbor)
			tilemap.set_cell(1, neighbor, 4, tile_id)

func _on_construction_ui_mouse_in_menu():
	mouse_in_menu = true

func _on_construction_ui_mouse_out_menu():
	mouse_in_menu = false
