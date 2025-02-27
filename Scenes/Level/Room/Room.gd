extends Node2D
class_name Room

# Signaux permettant de communiquer des événements importants aux autres nœuds
signal previsu_signal
signal selecting_signal(state: bool, start_pos: Vector2, end_pos: Vector2)
signal rotation_change(rotation: int)

# Variables prêtes à l'emploi (onready) pour référencer les nœuds importants dans la scène
@onready var floorLayer : TileMapLayer = $"../TileMap/Floor"
@onready var doorLayer : TileMapLayer = $"../TileMap/Door"
@onready var grid : Node2D = $Grid
@onready var construction_ui : Control = $"../UICanvasLayer/BottomMenu/ConstructionUi"
@onready var previsu : Node2D = $Previsu
@onready var delete_btn : Button = $Panel/MarginContainer/HBoxContainer/DeleteBtn
@onready var move_btn : Button = $Panel/MarginContainer/HBoxContainer/MoveBtn
@export var grid_size : int = 16  # Taille de la grille en pixels

# Variables globales pour gérer les positions de départ/fin et l'état de sélection
var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2 = Vector2.ZERO
var is_selecting : bool = false
const TilePositions : Script = preload("res://Ressources/tile_positions.gd")
var selected_object_position : Vector2 =  Vector2.ZERO
var current_rotation : int = 0
var occupied_cells : Array = [Vector2(31,27), Vector2(24,23),Vector2(25,23), Vector2(24,26),Vector2(25,26), Vector2(37,22),Vector2(38,22)]


# Fonction appelée lorsque le nœud est prêt (initialisé)
func _ready() -> void:
	grid.visible = false
	construction_ui.connect("construct_signal", _on_construct_signal)
	delete_btn.connect("pressed", _on_delete_btn_pressed)
	move_btn.connect("pressed", _on_move_btn_pressed)


# Fonction de mise à jour appelée à chaque frame
func _process(_delta) -> void:
	if GameData.construction_type:
		grid.visible = true
	else:
		grid.visible = false


# Fonction gérant les événements d'entrée utilisateur (clavier/souris)
func _input(event) -> void:
	var checked_cell = check_cell()  # Retourne la position sur la grille sous la souris
	if !GameData.menu_open:
		if event.is_action_pressed("click"):
			# Si nous ne sommes pas en mode construction : affiche ou non le menu contextuel
			if not GameData.construction_type:
				var object_in_cell = check_object_under(checked_cell, Vector2(1,1))
				if object_in_cell:
					selected_object_position = checked_cell
					open_contextual_menu()
				else:
					close_contextual_menu()
				
			# Si l'on déplace un objet
			if GameData.construction_type in ["move"]:
				start_pos = selected_object_position
				end_pos = checked_cell
				move_object(start_pos, end_pos)
				selecting_signal.emit(true,start_pos)
				previsu.reset_previsualisation()
				
			# Si clic et n'importe quel autre type de construction
			elif event.pressed and GameData.construction_type:
				start_pos = checked_cell
				is_selecting = true
				selecting_signal.emit(true,start_pos)
						
		# Quand on relâche le clic et que l'on est en train de construire : produit une action ou construit
		if event.is_action_released("click") and GameData.construction_type:
			end_pos = checked_cell
			if GameData.construction_type in ["destroy_all", "destroy_wall", "destroy_floor", "destroy_object"]:
				destroy_construction()
			else:
				create_construction()

		# Réinitialisation sur le clic droit
		if event.is_action_pressed("click_cancel"):
			GameData.construction_type = ""
			GameData.construction_item = ""
			current_rotation = 0
			previsu.reset_previsualisation()
			construction_ui.hide_all_panels()
			
		# Rotation de l'objet
		if event.is_action_pressed("rotate"):
			if current_rotation == 3:
				current_rotation = 0
			else:
				current_rotation += 1
			rotation_change.emit(current_rotation)


# Fonction pour créer une construction en fonction du type actuel
func create_construction() -> void:
	match GameData.construction_type:
		"wall":
			create_wall(GameData.construction_item)
		"floor":
			create_floor(GameData.construction_item)
		"door":
			create_door(GameData.construction_item)
		"object":
			create_object(GameData.construction_item)


# Fonction pour créer un mur en fonction du type spécifié
func create_wall(wall_type) -> void:
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				if check_object_under(Vector2(x, y), Vector2(1, 1)):
					return
	
	var cells = []
	var terrain_id = TilePositions.WALL_TILES[wall_type].index  # 0 (wood) ou 1 (stone)
	var cost = TilePositions.WALL_TILES[wall_type].cost
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				var tile_origin = Vector2(x, y)
				BetterTerrain.set_cell(floorLayer, tile_origin, terrain_id)
				cells.append(tile_origin)
				GameData.set_gold(-cost)     #deduis le prix pour chaque tile posé
	BetterTerrain.update_terrain_cells(floorLayer, cells)
	previsu.reset_previsualisation()


# Fonction pour créer un sol en fonction du type spécifié
func create_floor(floor_type : String) -> void:
	var tile_pos = TilePositions.FLOOR_TILES[floor_type].pos 
	var cost = TilePositions.FLOOR_TILES[floor_type].cost
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			var tile_origin = Vector2(x, y)
			if not check_wall_under(tile_origin, Vector2(1,1)):
				floorLayer.set_cell(tile_origin, 0, tile_pos)
				GameData.set_gold(-cost)     #deduis le prix pour chaque tile posé
	previsu.reset_previsualisation()


# Fonction pour créer une porte en fonction du type spécifié
func create_door(door_type : String) -> void:
	var tile_origin = end_pos
	var tile_pos = TilePositions.DOOR_TILES[door_type].pos 
	var grass_pos =  TilePositions.FLOOR_TILES["grass"].pos
	var cost = TilePositions.DOOR_TILES[door_type].cost

	# Vérifie s'il y a un objet sur la case sélectionnée
	if check_object_under(tile_origin, Vector2(1, 1)):
		return
		
	floorLayer.set_cell(tile_origin, 0, grass_pos)
	doorLayer.set_cell(tile_origin, 0, tile_pos)
	GameData.set_gold(-cost)    
	
	BetterTerrain.update_terrain_cell(floorLayer, tile_origin)
	mark_occupied_cells(tile_origin, Vector2(1,1))  # Marque les cellules comme occupées


# Fonction pour créer un objet utilisable en fonction du type spécifié
func create_object(usable_object_type : String) -> void:
	var tile_origin = get_global_mouse_position()
	var usable_object_scene = TilePositions.USABLE_OBJECTS[usable_object_type]
	var usable_object_instance = usable_object_scene.instantiate()
	rotate_object(usable_object_instance, current_rotation)
	var tile_size = usable_object_instance.get_node("Sprite2D").region_rect.size / grid_size
	var object_pos = floor(tile_origin / grid_size)
	
	# Vérifie s'il y a un mur ou un objet sous chacune des tiles de l'objet
	if check_wall_under(object_pos, tile_size) or check_object_under(object_pos, tile_size):
		return
		
	# Aligne l'objet utilisable sur la grille
	var aligned_position = Vector2(floor(tile_origin.x / grid_size) * grid_size, floor(tile_origin.y / grid_size) * grid_size)

	# Ajuste l'alignement en fonction de la taille et de l'orientation de l'objet
	if tile_size.x > 1:
		aligned_position.y += grid_size / 2
	elif tile_size.y > 1:
		aligned_position.x += grid_size / 2
		
	var pos_in_grid = Vector2(floor(tile_origin.x / grid_size), floor(tile_origin.y / grid_size))
	if check_wall_under(pos_in_grid, tile_size) and check_object_under(pos_in_grid, tile_size):
		return

	usable_object_instance.position = aligned_position
	usable_object_instance.name = usable_object_type
	usable_object_instance.rotate_state = current_rotation
	
	var object_container = get_node("../TileMap/Object")
	object_container.add_child(usable_object_instance)
	mark_occupied_cells(pos_in_grid, tile_size)  # Marque les cellules comme occupées
	
	#On deduis enfin le prix de l'item
	GameData.set_gold(-usable_object_instance.cost)


# Fonction pour détruire une construction en fonction du type actuel
func destroy_construction() -> void:
	match GameData.construction_type:
		"destroy_all":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					floorLayer.set_cell(tile_origin, -1)
					doorLayer.set_cell(tile_origin, -1)
					destroy_objects(tile_origin)
		"destroy_wall":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					var tile_data = floorLayer.get_cell_tile_data(tile_origin)
					# Si un mur est en dessous, ou une case avec la data Door
					if check_wall_under(tile_origin, Vector2(1,1)) or (tile_data and tile_data.get_custom_data('Type') == "Door"):
						# On supprime sur les 2 couches puis on remplace
						floorLayer.set_cell(tile_origin, -1)
						doorLayer.set_cell(tile_origin, -1)
						floorLayer.set_cell(tile_origin, 0, TilePositions.FLOOR_TILES["grass"].pos)
		"destroy_floor":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					if not check_wall_under(tile_origin, Vector2(1,1)):
						floorLayer.set_cell(tile_origin, -1)
						floorLayer.set_cell(tile_origin, 0, TilePositions.FLOOR_TILES["grass"].pos)
		"destroy_object":
			# TODO : Modifier la fonction pour que les objets soient retrouvés via occupied_cells
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					destroy_objects(tile_origin)
	previsu.reset_previsualisation()


# Ouvre le menu contextuel à la position actuelle de la souris
func open_contextual_menu() -> void:
	$Panel.global_position = get_global_mouse_position() - Vector2(-50,10)
	$Panel.show()


# Ferme le menu contextuel
func close_contextual_menu() -> void:
	$Panel.hide()



# Permet de supprimer des objets via le menu contextuel
func _on_delete_btn_pressed() -> void:
	if selected_object_position != Vector2.ZERO:
		destroy_objects(selected_object_position)
		selected_object_position = Vector2.ZERO
		close_contextual_menu()


# Permet de déplacer des objets via le menu contextuel
func _on_move_btn_pressed() -> void:
	close_contextual_menu()
	if get_object_at(selected_object_position):
		var node_instance = get_object_at(selected_object_position)
		GameData.construction_type = "move"
		GameData.construction_item = node_instance.node_name
		rotation_change.emit(node_instance.rotate_state)
		previsu.instantiate_preview()


# Ferme le menu contextuel
func _on_close_btn_pressed() -> void:
	close_contextual_menu()


# Vérifie la cellule sous la souris et la retourne
func check_cell() -> Vector2:
	return floorLayer.local_to_map(get_global_mouse_position())  # map_pos


# Vérifie si une position est dans les limites de la grille
func is_within_bounds(pos : Vector2) -> bool:
	var grid_wide = 124
	var grid_height = 64
	return pos.x >= 0 and pos.x < grid_wide and pos.y >= 0 and pos.y < grid_height


# Vérifie s'il y a un mur sous une position spécifiée
func check_wall_under(tile_origin: Vector2, size: Vector2) -> bool:
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var check_position = Vector2(x, y)
			
			# Si sur le tilemap sur la couche 1 (mur) il y a une tile avec l'id 2 (celle du mur)
			var tile_data = floorLayer.get_cell_tile_data(check_position)
			if tile_data and tile_data.get_custom_data('Type') == "Wall":
				return true
	return false


# Vérifie s'il y a un objet sous une position spécifiée
func check_object_under(tile_origin: Vector2, size: Vector2) -> bool:
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var check_position = Vector2(x, y)
			
			# Si check_position est contenue dans le tableau des cellules occupées
			if check_position in occupied_cells:
				return true
	return false


# Supprime les objets à la position spécifiée
func destroy_objects(tile_origin: Vector2) -> void:
	# Supprime les instances de scène à la position spécifiée
	var object_container = get_node("../TileMap/Object")
	var children = object_container.get_children()
	for child in children:
		if child is Node2D:
			var child_position = floor(child.global_position / grid_size)
			var object_size = child.get_node("Sprite2D").region_rect.size / grid_size
			if int(child_position.x) == tile_origin.x and int(child_position.y) == tile_origin.y:
				clear_occupied_cells(tile_origin, object_size)
				child.queue_free()  # Supprime l'objet de la scène


# Déplace un objet d'une position à une autre
func move_object(from: Vector2, to: Vector2) -> void:
	var object_container = floorLayer.get_node("../Object")
	var found_object = null
	var object_size = Vector2()

	# Boucle à travers les enfants pour trouver l'objet à la position spécifiée 'from'
	for child in object_container.get_children():
		if child is Node2D:
			var child_position = floor(child.global_position / grid_size)
			object_size = child.get_node("Sprite2D").region_rect.size / grid_size

			if child_position == from:
				found_object = child
				break  # Quitte la boucle une fois l'objet correct trouvé

	if found_object:
		rotate_object(found_object, current_rotation)
		# Vérifie si la destination est dans les limites et non obstruée
		if is_within_bounds(to) and not (check_wall_under(to, object_size) or check_object_under(to, object_size)):
			# Ajuste l'alignement en fonction de la taille et de l'orientation de l'objet
			if object_size.x > 1:
				to.y += 0.5
			elif object_size.y > 1:
				to.x += 0.5
			
			# Déplace l'objet trouvé
			found_object.position = to * grid_size
			clear_occupied_cells(from, object_size)
			mark_occupied_cells(to, object_size)
		else:
			print("La destination est obstruée ou hors des limites.")
	else:
		print("Aucun objet trouvé à la position 'from' spécifiée.")
	
	GameData.construction_type = ""


# Retourne l'objet à la position spécifiée
func get_object_at(tile_origin: Vector2) -> Node2D:
	var object_container = get_node("../TileMap/Object")
	for child in object_container.get_children():
		if child is Node2D:
			var child_position = floor(child.global_position / grid_size)
			var object_size = child.get_node("Sprite2D").region_rect.size / grid_size
			var occupied_area = []

			# Calcule toutes les tiles occupées par l'objet
			for x in range(child_position.x - object_size.x + 1, child_position.x + 1):
				for y in range(child_position.y - object_size.y + 1, child_position.y + 1):
					occupied_area.append(Vector2(x, y))
			# Vérifie si la position cliquée est dans la zone occupée par l'objet
			if tile_origin in occupied_area:
				return child  # Retourne l'instance de l'objet
	return null


# Marque les cellules comme occupées à une position spécifiée
func mark_occupied_cells(tile_origin: Vector2i, size: Vector2i) -> void:
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var cell_position = Vector2(x, y)
			occupied_cells.append(cell_position)  # Marque la cellule comme occupée


# Libère les cellules occupées à une position spécifiée
func clear_occupied_cells(tile_origin: Vector2, size: Vector2) -> void:
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var cell_position = Vector2(x, y)
			if cell_position in occupied_cells:
				occupied_cells.erase(cell_position)  # Libère la cellule


# Fait pivoter un objet en fonction de son état de rotation
func rotate_object(instance, rotate_state) -> void:
	var rotate_list = ["front", "right_side", "back", "left_side"]
	var next_side = rotate_list[rotate_state]
	instance.rotate_state = rotate_state
	if instance.has_method("rotate_item"):
		instance.rotate_item(next_side)


func _on_construct_signal() -> void:
	current_rotation = 0
	previsu_signal.emit()
