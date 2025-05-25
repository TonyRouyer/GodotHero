extends Node2D

const TilePositions : Script = preload("res://Ressources/tile_positions.gd")

@onready var parent = get_parent()
@onready var object_layer : TileMapLayer = $"../../Level/Objects" 

# Fonction pour créer un objet utilisable en fonction du type spécifié
func create_object(usable_object_type : String) -> void:
	#1. on recup la position de la sourie / ex: Vector2(699,327.5)
	var tile_origin = get_global_mouse_position() 
	
	#2. on recup la ressource de l'objet
	var usable_object_ressource = TilePositions.OBJECTS[usable_object_type] 
	
	#3. on recupere la rotation
	var current_rotation = parent.rotation_name[parent.current_rotation]
	
	#4. on recupere la source de la tile
	var tile_id = usable_object_ressource.object_tile_index
	var tile_coord = usable_object_ressource.object_tile_coord[current_rotation]
	var source = object_layer.tile_set.get_source(tile_id)

	#5. on recup la taille de l'objet / ex: Vector2(32,16)
	var tile_size = source.get_tile_size_in_atlas(tile_coord)

	#6. on recupere la position du click sur le tileset / ex: Vector2(36,24)
	var object_pos = floor(tile_origin / parent.grid_size)
	
	#7. Vérifie s'il y a un mur ou un objet sous chacune des tiles de l'objet
	if parent.check_wall_under(object_pos, tile_size) or parent.check_object_under(object_pos, tile_size):
		return

	#8. on place l'objet
	object_layer.set_cell(object_pos,tile_id, tile_coord)

	#9. on definie le custom data en fonction de l'objet
	var tile_data = object_layer.get_cell_tile_data(object_pos)
	tile_data.set_custom_data("object_name", usable_object_ressource.object_name_serialised)


	#10. on ajoute les tile occuper par un objet
	parent.mark_occupied_cells(object_pos, tile_size)
	
	GameData.set_gold(-usable_object_ressource.object_price) #12. On deduis enfin le prix de l'item


# Supprime les objets à la position spécifiée
func destroy_objects(tile_origin: Vector2) -> void:
	print("try destroy at: ", tile_origin)
	#1: On recupere un objet sur le tilemaplayer via son origin
	if tile_origin in parent.occupied_objects:
		var obj_data = parent.occupied_objects[tile_origin]
		var object_origin = obj_data["origin"]

		#2. on supprime la tile du layer
		object_layer.set_cell(object_origin, -1)
		
		#3. on libere les case du tableau
		parent.clear_occupied_cells(tile_origin)

	#3. on reset le construction type
	GameData.construction_type = ""


# Déplace un objet d'une position à une autre
func move_object(from: Vector2, to: Vector2) -> void:
	#1. On recupere les data d'un objet via son origin
	if from in parent.occupied_objects:
		var obj_data = parent.occupied_objects[from]
		var object_origin = obj_data["origin"]
		var source_id = object_layer.get_cell_source_id(from)
		var atlas_coord = object_layer.get_cell_atlas_coords(from)
		var tile_data = parent.objects_logic.object_layer.get_cell_tile_data(parent.selected_object_position)
		var object_name = tile_data.get_custom_data("object_name")
		var usable_object_ressource = TilePositions.OBJECTS[object_name] 
		var source = object_layer.tile_set.get_source(usable_object_ressource.object_tile_index)
		var current_rotation = parent.rotation_name[parent.current_rotation]
		var tile_coord = usable_object_ressource.object_tile_coord[current_rotation]
		var tile_size = source.get_tile_size_in_atlas(tile_coord)
		
		#2. on supprimer l'objet de sa position de base
		object_layer.set_cell(object_origin, -1)
	
		#3. on replace l'objet a la nouvelle position
		object_layer.set_cell(to, source_id, atlas_coord)
	
	
		parent.clear_occupied_cells(from)
		parent.mark_occupied_cells(to, tile_size)
	
	#5. on reset le construction type
	GameData.construction_type = ""


# Fait pivoter un objet en fonction de son état de rotation
func rotate_object(instance, rotate_state) -> void:
	var rotate_list = ["front", "right_side", "back", "left_side"]
	var next_side = rotate_list[rotate_state]
	instance.rotate_state = rotate_state
	if instance.has_method("rotate_item"):
		instance.rotate_item(next_side)
