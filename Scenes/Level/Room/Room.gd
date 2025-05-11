extends Node2D
class_name Room

# Signaux permettant de communiquer des événements importants aux autres nœuds
signal previsu_signal
signal selecting_signal(state: bool, start_pos: Vector2, end_pos: Vector2)
signal rotation_change(rotation: int)

# Variables prêtes à l'emploi (onready) pour référencer les nœuds importants dans la scène
@onready var floorLayer : TileMapLayer = $"../TileMap/Floor"
@onready var doorLayer : TileMapLayer = $"../TileMap/Door"
@onready var construction_ui : Control = $"../UICanvasLayer/BottomMenu/ConstructionUi"
@onready var previsu : Node2D = $Previsu
@onready var grid : Node2D = $Grid
@onready var contextualMenu : Control = $CanvasLayer/ContextualMenu

@export var grid_size : int = 16  # Taille de la grille en pixels

# Variables globales pour gérer les positions de départ/fin et l'état de sélection
var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2 = Vector2.ZERO
var is_selecting : bool = false
const TilePositions : Script = preload("res://Ressources/tile_positions.gd")
var selected_object_position : Vector2 =  Vector2.ZERO
var current_rotation : int = 0


# Fonction appelée lorsque le nœud est prêt (initialisé)
func _ready() -> void:
	grid.visible = false
	construction_ui.connect("construct_signal", _on_construct_signal)


# Fonction de mise à jour appelée à chaque frame
func _process(_delta) -> void:
	if GameData.construction_type:
		grid.visible = true
	else:
		grid.visible = false
		previsu.reset_previsualisation()


# Fonction gérant les événements d'entrée utilisateur (clavier/souris)
func _unhandled_input(event) -> void:
	var checked_cell = grid.check_cell()  # Retourne la position sur la grille sous la souris
	if !GameData.menu_open:
		if event.is_action_pressed("click"):
			# Si nous ne sommes pas en mode construction : affiche ou non le menu contextuel
			if not GameData.construction_type:
				var object_in_cell = check_object_under(checked_cell, Vector2(1,1))
				if object_in_cell:
					selected_object_position = contextualMenu.get_object_at(checked_cell).position / grid_size
					contextualMenu.open_contextual_menu()
				else:
					contextualMenu.close_contextual_menu()
				
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
	grid.mark_occupied_cells(tile_origin, Vector2(1,1))  # Marque les cellules comme occupées


# Fonction pour créer un objet utilisable en fonction du type spécifié
func create_object(usable_object_type : String) -> void:
	var tile_origin = get_global_mouse_position() #1. on recup la position de la sourie / ex: Vector2(699,327.5)
	var usable_object_scene = TilePositions.USABLE_OBJECTS[usable_object_type] #2. on recup la scene de l'objet
	var usable_object_instance = usable_object_scene.instantiate() #3. On instantie l'objet
	rotate_object(usable_object_instance, current_rotation) #4. on rotation l'objet du bon sens dans sa scene
	
	var tile_size = Vector2(usable_object_instance.x_size, usable_object_instance.y_size) / grid_size #5. on recup la taille de l'objet / ex: Vector2(32,16)
	var object_pos = floor(tile_origin / grid_size) #6. on recupere la position du click sur le tileset / ex: Vector2(36,24)
	
	#7. Vérifie s'il y a un mur ou un objet sous chacune des tiles de l'objet
	if check_wall_under(object_pos, tile_size) or check_object_under(object_pos, tile_size):
		return
		
	#8. on place l'objet
	usable_object_instance.position = (object_pos * grid_size)

	#9. on rename et applique la rotation a l'objet
	usable_object_instance.name = usable_object_type
	usable_object_instance.rotate_state = current_rotation
	
	#10. on ajoute enfin l'ojet dans le node dedié
	var object_container = get_node("../TileMap/Object")
	object_container.add_child(usable_object_instance)
	grid.mark_occupied_cells(object_pos, tile_size)  #11. Marque les cellules comme occupées
	
	GameData.set_gold(-usable_object_instance.cost) #12. On deduis enfin le prix de l'item


# Fonction pour détruire une construction en fonction du type actuel
func destroy_construction() -> void:
	match GameData.construction_type:
		"destroy_all":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					floorLayer.set_cell(tile_origin, -1)
					floorLayer.set_cell(tile_origin, 0, TilePositions.FLOOR_TILES["grass"].pos)
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


# Supprime les objets à la position spécifiée
func destroy_objects(tile_origin: Vector2) -> void:
	# Vérifier si un objet existe à cette position
	if tile_origin in grid.occupied_objects:
		var obj_data = grid.occupied_objects[tile_origin]
		var object_origin = obj_data["origin"]
		
			# Récupérer l'objet associé
		var obj = contextualMenu.get_object_at(object_origin)
		if obj:
			obj.queue_free()  # Supprime l'objet de la scène
			grid.clear_occupied_cells(object_origin)  # Libère les cellules occupées


# Déplace un objet d'une position à une autre
func move_object(from: Vector2, to: Vector2) -> void:
	var object_container = floorLayer.get_node("../Object")
	var found_object = null
	var object_size = Vector2()

	# Boucle à travers les enfants pour trouver l'objet à la position spécifiée 'from'
	for child in object_container.get_children():
		if child is Node2D:
			var child_position = floor(child.global_position / grid_size)
			object_size = Vector2(child.x_size, child.y_size) / grid_size

			if child_position == from:
				found_object = child
				break  # Quitte la boucle une fois l'objet correct trouvé

	if found_object:
		rotate_object(found_object, current_rotation)
		# Vérifie si la destination est dans les limites et non obstruée
		if grid.is_within_bounds(to) and not (check_wall_under(to, object_size) or check_object_under(to, object_size)):
			# Déplace l'objet trouvé
			found_object.position = to * grid_size
			grid.clear_occupied_cells(from)
			grid.mark_occupied_cells(to, object_size)
		else:
			print("La destination est obstruée ou hors des limites.")
	else:
		print("Aucun objet trouvé à la position 'from' spécifiée.")
	
	GameData.construction_type = ""


# Vérifie s'il y a un mur sous une position spécifiée
func check_wall_under(tile_origin: Vector2, size: Vector2) -> bool:
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var check_position = Vector2(x, y)
			# Si sur le tilemap sur la couche 1 (mur) il y a une tile avec l'id 2 (celle du mur)
			var tile_data = floorLayer.get_cell_tile_data(check_position)
			if tile_data and tile_data.get_custom_data('Type') == "Wall":
				return true
	return false


# Vérifie s'il y a un objet sous une position spécifiée
func check_object_under(tile_origin: Vector2, size: Vector2) -> bool:	
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var check_position = Vector2(x, y)
			
			# Si check_position est contenue dans le tableau des cellules occupées
			if check_position in grid.occupied_objects:
				return true
	return false


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
