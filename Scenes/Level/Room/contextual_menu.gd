extends Control

@onready var room : Node2D = get_parent().get_parent()


# Ouvre le menu contextuel à la position actuelle de la souris
func open_contextual_menu() -> void:
	self.global_position = get_global_mouse_position() - Vector2(-50,10)
	self.show()
	#contextual_menu_open = true
	
# Ferme le menu contextuel
func close_contextual_menu() -> void:
	self.hide()
	#contextual_menu_open = false


# Ferme le menu contextuel
func _on_close_btn_pressed() -> void:
	close_contextual_menu()


# Permet de supprimer des objets via le menu contextuel
func _on_delete_btn_pressed() -> void:
	if room.selected_object_position != Vector2.ZERO:
		room.destroy_objects(room.selected_object_position)
		room.selected_object_position = Vector2.ZERO
		close_contextual_menu()
		
# Permet de déplacer des objets via le menu contextuel
func _on_move_btn_pressed() -> void:
	close_contextual_menu()
	
	if get_object_at(room.selected_object_position):
		var node_instance = get_object_at(room.selected_object_position)
		GameData.construction_type = "move"
		GameData.construction_item = node_instance.node_name
		room.rotation_change.emit(node_instance.rotate_state)
		room.previsu.instantiate_preview()



# Retourne l'objet à la position spécifiée
func get_object_at(tile_origin: Vector2) -> Node2D:
	var occupied_objects = room.grid.occupied_objects
	if tile_origin in occupied_objects:
		var object_origin = occupied_objects[tile_origin]["origin"]
		var object_container = get_tree().get_first_node_in_group("tilemap").get_node("Object")

		# Chercher l'objet dont l'origine correspond
		for child in object_container.get_children():
			if child is Node2D:
				var child_position = floor(child.global_position / room.grid.tile_size)
				if child_position == object_origin:
					return child  # Retourne l'instance de l'objet
	return null  # Aucun objet trouvé
