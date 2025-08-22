extends Node2D

@onready var parent = get_parent()
@onready var construction_layer: TileMapLayer = $"../../Level".get_node("Construction")
@onready var object_container: Node2D = $"../../Level".get_node("Object")


# Fonction pour créer un objet utilisable en fonction du type spécifié
func create_object(_usable_object_type: String) -> void:
	var obj_data = TilePositions.USABLE_OBJECTS.get(_usable_object_type)
	if obj_data == null:
		push_error("Objet non trouvé : " + _usable_object_type)
		return

	# 1. Récupération des données de taille depuis la ressource ObjectData
	var object_scene = obj_data.scene
	var object_instance = object_scene.instantiate()
	var current_rotation = parent.current_rotation

	rotate_object(object_instance, current_rotation)

	var object_size = Vector2(object_instance.x_size, object_instance.y_size) / parent.grid_size
	var origin = parent.grid.check_cell() 

	# 2. Calcul des positions occupées 
	var occupied_positions = []
	for x in range(int(object_size.x)):
		for y in range(int(object_size.y)):
			var cell = origin + Vector2(x, y)
			occupied_positions.append(cell)
			#On annule si le placement est impossible
			if parent.check_wall_under(cell) or parent.check_object_under(cell):
				occupied_positions.clear()
				return

	
	# 3. Placer la texture "construction_placeholder.png" sur chaque cellule
	for pos in occupied_positions:
		construction_layer.set_cell(pos,-1, Vector2(0,0)) # efface ancienne
		construction_layer.set_cell(pos, 40, Vector2(0,0))


	# 4. Marquer les positions comme occupées dans `occupied_position`
	for pos in occupied_positions:
		parent.occupied_position[Vector2(pos)] = {
			"origin": Vector2(origin),
			"object_type": _usable_object_type,
			"rotation": current_rotation,
		}
		
	# 5. Ajouter une tâche de construction à la file
	parent.add_construction_task({
		"type": "object",
		"priority": 5,
		"object_type": _usable_object_type,
		"origin": origin * parent.grid_size,
		"assigned": false,
	})
	parent.audio_player.play()


func finalize_construction(global_origin: Vector2) -> void:
	var origin = global_origin / parent.grid_size
	
	# Récupère les données de l’objet à construire
	if not parent.occupied_position.has(origin):
		push_error("Aucune construction en attente à cette position.")
		return
#
	var data = parent.occupied_position[origin]
	
	var object_type = data["object_type"]
	var obj_rotation = data.get("rotation")
#
	# Récupère la scène et l’instancie
	var obj_data = TilePositions.USABLE_OBJECTS.get(object_type)
	if obj_data == null:
		push_error("Objet inconnu dans TilePositions : " + object_type)
		return

	var object_scene = obj_data.scene
	var instance = object_scene.instantiate()
	rotate_object(instance,obj_rotation)

	var object_size = Vector2(instance.x_size, instance.y_size) / parent.grid_size
	
	instance.position = origin * parent.grid_size
	object_container.add_child(instance)

	#Suprime les placeholder de construction
	for x in range(int(object_size.x)):
		for y in range(int(object_size.y)):
			var cell = origin + Vector2(x, y)
			construction_layer.set_cell(cell,-1, Vector2(0,0)) # efface ancienne

	# Met à jour les données occupées
	for x in range(int(object_size.x)):
		for y in range(int(object_size.y)):
			var pos = Vector2(x,y)
			construction_layer.set_cell(pos,-1, Vector2(0,0)) # efface ancienne
			#parent.occupied_position[pos]["under_construction"] = false


	# Supprimer la tâche de la file
	for task in parent.construction_tasks:
		if task.origin == (origin * parent.grid_size):
			parent.construction_tasks.erase(task)
			break







# Supprime les objets à la position spécifiée
func destroy_objects(_tile_origin: Vector2) -> void:
	pass
	##1. On recupere les data d'un objet via son origin
	#if tile_origin in parent.occupied_position:
		#var obj_data = parent.occupied_position[tile_origin]
		#var object_origin = obj_data["origin"]
		#
		#var source = object_layer.tile_set.get_source()
		#var tile_size = source.get_tile_size_in_atlas(object_origin)
#
#
		##2. on supprime le node 2d approprié
		#object_layer.set_cell(object_origin, -1)
		#
		##3. on libere les case du tableau
		#parent.clear_occupied_cells(tile_origin, tile_size)
#
	##3. on reset le construction type
	#GameData.construction_type = ""


# Déplace un objet d'une position à une autre
func move_object(_from: Vector2, _to: Vector2) -> void:
	pass
	##1. On recupere les data d'un objet via son origin
	#if from in parent.occupied_position:
		#var obj_data = parent.occupied_position[from]
		#var object_origin = obj_data["origin"]
		#var source_id = object_layer.get_cell_source_id(from)
		#var atlas_coord = object_layer.get_cell_atlas_coords(from)
		#var tile_data = parent.objects_logic.object_layer.get_cell_tile_data(parent.selected_object_position)
		#var object_name = tile_data.get_custom_data("object_name")
		#var usable_object_ressource = TilePositions.OBJECTS[object_name] 
		#var source = object_layer.tile_set.get_source(usable_object_ressource.first_tile_index)
		#var current_rotation = parent.rotation_name[parent.current_rotation]
		#var tile_coord = usable_object_ressource.first_tile_layer_coord[current_rotation]
		#var tile_size = source.get_tile_size_in_atlas(tile_coord)
		#
		##2. on supprimer l'objet de sa position de base
		#object_layer.set_cell(object_origin, -1)
	#
		##3. on replace l'objet a la nouvelle position
		#object_layer.set_cell(to, source_id, atlas_coord)
	#
	#
		#parent.clear_occupied_cells(from, tile_size)
		#parent.mark_occupied_cells(to, tile_size)
	#
	##5. on reset le construction type
	#GameData.construction_type = ""


# Fait pivoter un objet en fonction de son état de rotation
func rotate_object(instance, rotate_state) -> void:	
	var rotate_list = ["front", "right_side", "back", "left_side"]
	var next_side = rotate_list[rotate_state]
	instance.rotate_state = rotate_state
	if instance.has_method("rotate_item"):
		instance.rotate_item(next_side)
