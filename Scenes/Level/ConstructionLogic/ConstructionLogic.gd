extends Node2D
class_name Room

# Signaux permettant de communiquer des événements importants aux autres nœuds
signal previsu_signal
signal selecting_signal(state: bool, start_pos: Vector2, end_pos: Vector2)

# Variables prêtes à l'emploi (onready) pour référencer les nœuds importants dans la scène
@onready var construction_ui : Control = $"../UICanvasLayer/Menu/ConstructionUi"
@onready var previsu : Node2D = %Previsu
@onready var grid : Node2D = %Grid
@onready var build_logic : Node2D = %BuildLogic
@onready var rooms_logic : Node2D = %RoomsLogic
@onready var objects_logic : Node2D = %ObjectsLogic
@onready var object_modal : PanelContainer = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/ObjectModal")
@onready var room_ui : PanelContainer = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/RoomUI")

@export var grid_size : int = 16  # Taille de la grille en pixels

# Variables globales pour gérer les positions de départ/fin et l'état de sélection
var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2 = Vector2.ZERO
var is_selecting : bool = false
var selected_object_position : Vector2 =  Vector2.ZERO

var rotation_name: Array = ["front", "left", "back", "right"]
var current_rotation : int = 0

var menu_open: bool = false
var occupied_objects :Dictionary = {}

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
	
	var hovered_zone = rooms_logic.get_hovered_zone(grid.check_cell())

	if event.is_action_pressed("click"):
		# Si nous ne sommes pas en mode construction : affiche ou non le menu contextuel
		if not GameData.construction_type:
	
			var object_in_cell = check_object_under(checked_cell, Vector2(1,1))
			if object_in_cell:
				#on veux recuperer l'origin de l'objet
				selected_object_position = get_object_at(checked_cell).origin
				room_ui.close()
				object_modal.open() 
			elif hovered_zone:
				object_modal.close()
				var zone_type_data = rooms_logic.zone_types.get(hovered_zone.name)
				if zone_type_data:
					room_ui.open_with_zone(hovered_zone, zone_type_data)
			else:
				object_modal.close()
				room_ui.close()
			
		# Si l'on déplace un objet
		if GameData.construction_type in ["move"]:
			start_pos = selected_object_position
			end_pos = checked_cell
			objects_logic.move_object(start_pos, end_pos)
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
			build_logic.destroy_construction()
		else:
			create_construction()

	# Réinitialisation sur le clic droit
	if event.is_action_pressed("click_cancel"):
		if get_tree().get_root().get_node("Main/UICanvasLayer/Menu/ConstructionUi").visible:
			GameData.construction_type = ""
			GameData.construction_item = ""
			current_rotation = 0
			previsu.reset_previsualisation()
			construction_ui.hide_all_panels()
			GameData.hide_ui()
		
	# Rotation de l'objet
	if event.is_action_pressed("rotate"):
		if current_rotation == 3:
			current_rotation = 0
		else:
			current_rotation += 1


#Reception du signal construction: reset les rotation et lance la previsu
func _on_construct_signal() -> void:
	current_rotation = 0
	previsu_signal.emit()


# Fonction pour créer une construction en fonction du type actuel
func create_construction() -> void:
	match GameData.construction_type:
		"wall":
			build_logic.create_wall(GameData.construction_item)
		"floor":
			build_logic.create_floor(GameData.construction_item)
		"door":
			build_logic.create_door(GameData.construction_item)
		"object":
			objects_logic.create_object(GameData.construction_item)
		"room":
			rooms_logic.create_room(GameData.construction_item)


# Vérifie s'il y a un mur sous une position spécifiée
func check_wall_under(tile_origin: Vector2, size: Vector2) -> bool:
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var check_position = Vector2(x, y)
			# Si sur le tilemap sur la couche 1 (mur) il y a une tile avec l'id 2 (celle du mur)
			var tile_data = build_logic.wall_layer.get_cell_tile_data(check_position)
			if tile_data:
				return true
	return false


# Vérifie s'il y a un objet sous une position spécifiée
func check_object_under(tile_origin: Vector2, size: Vector2) -> bool:	
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var check_position = Vector2(x, y)
			
			# Si check_position est contenue dans le tableau des cellules occupées
			if check_position in occupied_objects:
				return true
	return false


# Retourne l'objet à la position spécifiée
func get_object_at(tile_origin: Vector2) -> Dictionary:
	if tile_origin in occupied_objects:
		return occupied_objects[tile_origin]
	return {}  # Aucun objet trouvé


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
