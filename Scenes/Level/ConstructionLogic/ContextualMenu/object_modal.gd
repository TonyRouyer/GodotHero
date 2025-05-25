extends Control

@onready var construction_logic : Node2D = get_tree().get_root().get_node("Main/ConstructionLogic")

func _ready() -> void:
	add_to_group("UI")
	%DeleteBtn.connect("pressed", _on_delete_btn_pressed)
	%MoveBtn.connect("pressed", _on_move_btn_pressed)
	%CloseBtn.connect("pressed", _on_close_btn_pressed)
	
# Ouvre le menu contextuel à la position actuelle de la souris
func open() -> void:
	self.global_position = get_global_mouse_position() - Vector2(-50,10)
	self.show()
	
# Ferme le menu contextuel
func close() -> void:
	self.hide()


# Ferme le menu contextuel
func _on_close_btn_pressed() -> void:
	close()


# Permet de supprimer des objets via le menu contextuel
func _on_delete_btn_pressed() -> void:
	if construction_logic.selected_object_position != Vector2.ZERO:
		construction_logic.objects_logic.destroy_objects(construction_logic.selected_object_position)
		construction_logic.selected_object_position = Vector2.ZERO
		close()
		
# Permet de déplacer des objets via le menu contextuel
func _on_move_btn_pressed() -> void:
	if construction_logic.get_object_at(construction_logic.selected_object_position):		
		var tile_data = construction_logic.objects_logic.object_layer.get_cell_tile_data(construction_logic.selected_object_position)
		var object_name = tile_data.get_custom_data("object_name")

		GameData.construction_item = object_name
		GameData.construction_type = "move"
		construction_logic.previsu.instantiate_preview()
		close()
