extends Node2D
class_name ConstructionLogic

# Signaux permettant de communiquer des événements importants aux autres nœuds
signal previsu_signal
signal selecting_signal(state: bool, start_pos: Vector2)
signal rotated

# Variables prêtes à l'emploi (onready) pour référencer les nœuds importants dans la scène
@onready var construction_ui : Control = $"../UICanvasLayer/Menu/ConstructionUi"
@onready var previsu : Node2D = %Previsu
@onready var grid : Node2D = %Grid
@onready var build_logic : Node2D = %BuildLogic
@onready var objects_logic : Node2D = %ObjectsLogic
@onready var audio_player: AudioStreamPlayer = %ConstructionSound
@onready var object_modal : PanelContainer = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/ObjectModal")

@export var grid_size : int = 16  # Taille de la grille en pixels

# Variables globales pour gérer les positions de départ/fin et l'état de sélection
var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2 = Vector2.ZERO

var selected_object_position : Vector2 =  Vector2.ZERO

var rotation_name: Array = ["front", "left", "back", "right"]
var current_rotation : int = 0

var construction_tasks: Array = []
var occupied_position :Dictionary = {}
var object_placed :Dictionary = {}

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

# Fonction gérant les événements d'entrée utilisateur (clavier/souris)
func _unhandled_input(event) -> void:
	var checked_cell = grid.check_cell()  # Retourne la position sur la grille sous la souris
	
	if event.is_action_pressed("click"):
		# Si nous ne sommes pas en mode construction : affiche ou non le menu contextuel
		if not GameData.construction_type:
			var object_in_cell = check_object_under(checked_cell)
			if object_in_cell:
				#on veux recuperer l'origin de l'objet
				selected_object_position = get_object_at(checked_cell).origin
				object_modal.open() 
			else:
				object_modal.close()
			
		# Si l'on déplace un objet
		if GameData.construction_type in ["move"]:
			start_pos = selected_object_position
			end_pos = checked_cell
			objects_logic.move_object(start_pos, end_pos)
			selecting_signal.emit(true,start_pos)
			previsu.reset_preview()
			
		# Si clic et n'importe quel autre type de construction
		if event.pressed and GameData.construction_type:
			start_pos = checked_cell
			previsu.is_selecting = true
			selecting_signal.emit(true,start_pos)
					
	# Quand on relâche le clic et que l'on est en train de construire : produit une action ou construit
	if event.is_action_released("click") and GameData.construction_type:
		end_pos = checked_cell

		if GameData.construction_type in ["destroy_all", "destroy_wall", "destroy_floor", "destroy_object"]:
			build_logic.destroy_construction()
		else:
			create_construction()

	# Réinitialisation sur le clic droit
	if event.is_action_pressed("click_cancel") or event.is_action_pressed("escape"):
		if get_tree().get_root().get_node("Main/UICanvasLayer/Menu/ConstructionUi").visible:
			GameData.construction_type = ""
			GameData.construction_item = ""
			previsu.reset_preview()
			if previsu.preview_instance:
				previsu.preview_instance.queue_free()
				previsu.preview_instance = null
			if previsu.preview_sprite:
				previsu.preview_sprite.queue_free()
				previsu.preview_sprite = null
			GameData.hide_ui()
		
	# Rotation de l'objet
	if event.is_action_pressed("rotate"):
		if current_rotation == 3:
			current_rotation = 0
		else:
			current_rotation += 1
		rotated.emit()


#Reception du signal construction: reset les rotation et lance la previsu
func _on_construct_signal() -> void:
	previsu.reset_preview()
	previsu_signal.emit()


# Fonction pour créer une construction en fonction du type actuel
func create_construction() -> void:
	match GameData.construction_type:
		"wall":
			build_logic.create_wall_construction(GameData.construction_item)
		"floor":
			build_logic.create_floor_construction(GameData.construction_item)
		"door":
			build_logic.create_door_construction(GameData.construction_item)
		"object":
			objects_logic.create_object(GameData.construction_item)


# Vérifie s'il y a un mur sous une position spécifiée
func check_wall_under(tile_origin: Vector2i) -> bool:
	var used_cell = build_logic.wall_layer.get_used_cells()
	var check_position = tile_origin
	if check_position in used_cell:
		return true
	return false


# Vérifie s'il y a un objet sous une position spécifiée
func check_object_under(tile_origin: Vector2) -> bool:	
	var check_position = tile_origin	
	# Si check_position est contenue dans le tableau des cellules occupées
	if check_position in occupied_position:
		return true
	return false


# Retourne l'objet à la position spécifiée
func get_object_at(tile_origin: Vector2) -> Dictionary:
	if tile_origin in occupied_position:
		return occupied_position[tile_origin]
	return {}  # Aucun objet trouvé


# Marque les cellules comme occupées à une position spécifiée
func mark_occupied_cells(tile_origin: Vector2, size: Vector2) -> void:
	for x in range(tile_origin.x, tile_origin.x + size.x):
		for y in range(tile_origin.y, tile_origin.y + size.y):
			var cell_position = Vector2(x, y)
			occupied_position[cell_position] = {
				"origin": tile_origin,
				"size": size
			}


# Libère les cellules occupées à une position spécifiée
func clear_occupied_cells(tile_origin: Vector2, object_size: Vector2) -> void:
	if tile_origin in occupied_position:
		# Supprime toutes les cellules occupées par cet objet
		for x in range(tile_origin.x, tile_origin.x + object_size.x):
			for y in range(tile_origin.y, tile_origin.y + object_size.y):
				occupied_position.erase(Vector2(x, y))


func add_construction_task(task_data: Dictionary) -> void:
	construction_tasks.append(task_data)
	# Tu peux ici déclencher la recherche d’un héros disponible, etc.


func get_available_task() -> Dictionary:
	for task in construction_tasks:
		if not task.assigned:
			task.assigned = true
			return task
	return {}
