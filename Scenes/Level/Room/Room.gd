extends Node2D

@onready var tilemap = $"../TileMap".get_node("TileMap")
@onready var grid = $"../Grid"
@onready var construction_ui = $"../UICanvasLayer/BottomMenu/ConstructionUi"
@onready var previsu = $Previsu
@onready var room_utility_functions = $RoomUtilityFunctions
@onready var delete_btn = $Panel/MarginContainer/HBoxContainer/DeleteBtn
@onready var move_btn = $Panel/MarginContainer/HBoxContainer/MoveBtn




@export var grid_size = 16

var start_pos = Vector2()
var end_pos = Vector2()
var is_selecting = false
var mouse_in_menu = false
const TilePositions = preload("res://Scenes/Level/Room/TilePositions.gd")
var selected_object_position = null


func _ready():
	grid.visible = false
	construction_ui.connect("mouse_in_menu", _on_mouse_in_menu)
	construction_ui.connect("mouse_out_menu", _on_mouse_out_menu)
	
	delete_btn.connect("pressed", _on_delete_btn_pressed)
	move_btn.connect("pressed", _on_move_btn_pressed)




func _process(_delta):
	if global.construction_type:
		grid.visible = true
	else:
		grid.visible = false


func _input(event):
	if !mouse_in_menu:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var checked_cell = room_utility_functions.check_cell()
			print(global.construction_type)
			
			if event.pressed and not global.construction_type:
				print("1")
				var object_in_cell = room_utility_functions.can_place_object(checked_cell, Vector2(1,1))
				if object_in_cell:
					selected_object_position = checked_cell
					open_contextual_menu()
				else:
					close_contextual_menu()
					
			elif event.pressed and global.construction_type == "move":
				print("2")
				room_utility_functions.move_object(selected_object_position, end_pos)
				
			elif event.pressed and global.construction_type:
				print("3")
				start_pos = checked_cell
				is_selecting = true
			elif not event.pressed and global.construction_type:
				print("4")
				end_pos = checked_cell
				is_selecting = false
				if global.construction_type in ["destroy_all", "destroy_wall", "destroy_floor", "destroy_object"]:
					destroy_construction()
				else:
					create_construction()
				previsu.reset_previsualisation()

func create_construction():
	match global.construction_type:
		"wall":
			create_wall(global.construction_item)
		"floor":
			create_floor(global.construction_item)
		"door":
			create_door(global.construction_item)
		"object":
			create_object(global.construction_item)
		"usable_object":
			create_usable_object(global.construction_item)

func create_wall(wall_type):
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				if room_utility_functions.can_place_object( Vector2(x, y),  Vector2(1, 1)):
					return
	
	
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			# Create wall only on the borders
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				var tile_origin = Vector2(x, y)
				var tile_id = room_utility_functions.determine_wall_tile_id(tile_origin, wall_type)
				
				# Supprimer le sol sous le mur
				if tilemap.get_cell_source_id(0, tile_origin) != -1:
					tilemap.set_cell(0, tile_origin, -1)
				
				tilemap.set_cell(1, tile_origin, 2, tile_id)
				room_utility_functions.update_neighbors(tile_origin)

func create_floor(floor_type):
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			var tile_origin = Vector2(x, y)
			if tilemap.get_cell_source_id(0, tile_origin) == 0:
				tilemap.set_cell(0, tile_origin, 0, TilePositions.FLOOR_TILES[floor_type])

func create_door(door_type):
	var tile_origin = end_pos

	# Supprimer le sol sous le mur
	if tilemap.get_cell_source_id(1, tile_origin) != -1:
		tilemap.set_cell(0, tile_origin,0, Vector2(2,5))
		#tilemap.set_cell(1, tile_origin, -1)
	
	if tilemap.get_cell_source_id(1, tile_origin) != -1 or tilemap.get_cell_source_id(1, tile_origin) == -1:
		tilemap.set_cell(1, tile_origin, 0, TilePositions.DOOR_TILES[door_type])
		room_utility_functions.update_neighbors(tile_origin)

func create_object(object_type):
	var tile_origin = end_pos
	var object_tile = TilePositions.OBJECT_TILES[object_type]
	var tile_size = room_utility_functions.get_tile_size(object_tile)
	var aligned_position = Vector2(tile_origin.x,tile_origin.y)
	
	# Vérifie si la case contient un objet ou un mur
	if room_utility_functions.can_place_object(tile_origin, tile_size):
		return

	if tilemap.get_cell_source_id(2, aligned_position) == -1:
		tilemap.set_cell(2, aligned_position, 1, object_tile)
		room_utility_functions.mark_occupied_cells(tile_origin, tile_size)  # Marque les cellules comme occupées

func create_usable_object(usable_object_type):
	var tile_origin = get_global_mouse_position()

	if tilemap.get_cell_source_id(2, tile_origin) == -1:
		var usable_object_scene = TilePositions.USABLE_OBJECTS[usable_object_type]
		var usable_object_instance = usable_object_scene.instantiate()
		var tile_size = usable_object_instance.get_node("Sprite2D").region_rect.size / grid_size

		# Align the usable object to the grid
		var aligned_position = Vector2(floor(tile_origin.x / grid_size) * grid_size, floor(tile_origin.y / grid_size) * grid_size)
		#Replace l'objet sur la grid en Y
		var object_size_y = grid_size  # Modify this based on the height of your object
		aligned_position.y += (object_size_y / 2)
		
		
		var pos_in_grid = Vector2(floor(tile_origin.x / grid_size), floor(tile_origin.y / grid_size))
		if room_utility_functions.can_place_object(pos_in_grid, tile_size):
			return

		usable_object_instance.position = aligned_position
		usable_object_instance.name = usable_object_type
		var object_container = get_node("../TileMap/Object")
		object_container.add_child(usable_object_instance)
		room_utility_functions.mark_occupied_cells(pos_in_grid, tile_size)  # Marque les cellules comme occupées

func destroy_construction():
	match global.construction_type:
		"destroy_all":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					tilemap.set_cell(0, tile_origin, -1)
					tilemap.set_cell(1, tile_origin, -1)
					room_utility_functions.destroy_tile_and_scene_objects(tile_origin)
		"destroy_wall":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					tilemap.set_cell(1, tile_origin, -1)
		"destroy_floor":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					tilemap.set_cell(0, tile_origin, -1)
		"destroy_object":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					room_utility_functions.destroy_tile_and_scene_objects(tile_origin)



func _on_mouse_in_menu():
	mouse_in_menu = true

func _on_mouse_out_menu():
	mouse_in_menu = false


func open_contextual_menu():
	$Panel.global_position = get_global_mouse_position() + Vector2(-100,10)
	$Panel.show()
func close_contextual_menu():
	$Panel.hide()

func _on_delete_btn_pressed():
	print("delete")
	room_utility_functions.destroy_tile_and_scene_objects(selected_object_position)
	selected_object_position = null
	close_contextual_menu()

func _on_move_btn_pressed():
	print("move")
	#room_utility_functions.move_object(selected_object_position)
	#close_contextual_menu()

	# Par exemple, activer un mode de déplacement
	global.construction_type = "move"
	#penser a changer opciter objet
	close_contextual_menu()

func _on_close_btn_pressed():
	print("close")
	close_contextual_menu()


