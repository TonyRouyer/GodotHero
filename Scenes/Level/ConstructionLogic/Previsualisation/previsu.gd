extends Node2D
class_name Previsualisation

@onready var construction_logic: Node2D = get_parent()
@onready var grid_size: int =  get_parent().grid_size
@onready var current_rotation: int = get_parent().current_rotation
@onready var preview_layer: TileMapLayer = $"../../Level".get_node("Preview")
@onready var start_pos : Vector2 = Vector2.ZERO
@onready var end_pos : Vector2 = Vector2.ZERO
@onready var preview_instance : Node2D = null  # Instance de l'objet de prévisualisation

@export var valid_color :Color = Color(0.2, 0.9, 0, 0.5)
@export var invalid_color :Color = Color(0.9, 0.2, 0, 0.5)

var preview_sprite: Sprite2D = null
var object_name: String = ""

var is_selecting:bool = false


func _ready():
	construction_logic.connect("selecting_signal", _on_selecting_signal)
	construction_logic.connect("previsu_signal", _on_previsu_signal)
	construction_logic.connect("rotated", _rotate_preview)


func _process(_delta):
	end_pos = construction_logic.grid.check_cell()

	if GameData.construction_type in ["floor", "wall", "door"]:
		preview_sprite.position = (construction_logic.grid.check_cell()  * grid_size) 
		if GameData.construction_type in  ["floor", "door"]: preview_sprite.position += Vector2(8,8)
		preview_layer.clear()
		_draw_preview_area()
	


	if GameData.construction_type in ["object", "move"]:
		# position de la sourie sur le tileset (haut gauche d'une tile)/ exemple Vector2(832,176)
		var pos = construction_logic.grid.check_cell()  * grid_size
		var aligned_pos = pos		
		preview_instance.position = aligned_pos

		# Vérification de placement
		var sprite_size = Vector2(preview_instance.x_size, preview_instance.y_size)
		
		var is_valid = check_placement_valid(aligned_pos, sprite_size)		
		if is_valid:
			preview_instance.modulate = valid_color
		else:
			preview_instance.modulate = invalid_color
	

# Appelé par le signal quand un objet est sélectionné
func _on_previsu_signal():
	# Effacer ancienne preview
	reset_preview()
	for child in self.get_children():
		child.queue_free()
	set_preview_sprite(GameData.construction_type)


#Appelé quand un selectione un floor ou wall
func _on_selecting_signal(state: bool, start: Vector2):
	is_selecting = state
	start_pos = start


func _draw_preview_area():
	if is_selecting: 
		var type = GameData.construction_type
		var tile_id = null
		match type:
			"wall":
				tile_id = TilePositions.WALLS[GameData.construction_item].index
			"floor":
				tile_id = TilePositions.FLOORS[GameData.construction_item].index

		if type == "wall":
			var min_x = min(start_pos.x, end_pos.x)
			var max_x = max(start_pos.x, end_pos.x)
			var min_y = min(start_pos.y, end_pos.y)
			var max_y = max(start_pos.y, end_pos.y)
			
			var wall_cells = []
			for x in range(min_x, max_x + 1):
				for y in range(min_y, max_y + 1):
					if x == min_x or x == max_x or y == min_y or y == max_y:
						var pos = Vector2i(x, y)
						BetterTerrain.set_cell(preview_layer, pos, tile_id)
						wall_cells.append(pos)
						
						#TODO faire en sorte que quand selection survole mur du meme type ou objet -> tile invalide
						#var is_valid = construction_logic.check_object_under(pos)
						#if is_valid:
							#preview_instance.modulate = valid_color
						#else:
							#preview_instance.modulate = invalid_color

			preview_layer.modulate = valid_color
			BetterTerrain.update_terrain_cells(preview_layer, wall_cells)
		elif type == "floor":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var pos = Vector2(x, y)
					#on (rem)place le sol si il n'y a pas de mur
					if not construction_logic.check_wall_under(pos):
						preview_layer.set_cell(pos, tile_id, Vector2(0,0))
						preview_layer.modulate = valid_color
		elif type == "door":
			tile_id = TilePositions.DOORS[GameData.construction_item].index
			BetterTerrain.set_cell(preview_layer, end_pos, tile_id)




func _rotate_preview() -> void:
	current_rotation = get_parent().current_rotation
	if preview_instance: 
		construction_logic.objects_logic.rotate_object(preview_instance, current_rotation)

func check_placement_valid(world_pos: Vector2, object_size: Vector2) -> bool:
	var world_pos_in_tile = world_pos / grid_size
	var obj_size_in_tile = object_size / grid_size
	
	for x in int(obj_size_in_tile.x):
		for y in int(obj_size_in_tile.y):
			var check_pos = world_pos_in_tile + Vector2(x, y)
			if construction_logic.check_wall_under(check_pos):
				return false
			if construction_logic.check_object_under(check_pos):
				return false
	return true



func set_preview_sprite(type: String) -> void:
	if preview_instance:
		preview_instance.queue_free()
		
	object_name = GameData.construction_item
	var obj_data = null
	var texture = null
	
	if type in ["object", "move"]:
			obj_data = TilePositions.USABLE_OBJECTS.get(object_name).scene
			preview_instance = obj_data.instantiate()
			construction_logic.objects_logic.rotate_object(preview_instance, current_rotation)
			preview_instance.modulate = valid_color
			
			if preview_instance:
				add_child(preview_instance)
				return
		

	match type:
		"wall":
			obj_data = TilePositions.WALLS.get(object_name)
			texture = obj_data.texture
		"floor":
			obj_data = TilePositions.FLOORS.get(object_name)
			texture = obj_data.texture
		"door":
			obj_data = TilePositions.DOORS.get(object_name)
			texture = obj_data.texture
			
	if not texture:
		push_error("Texture manquante pour l'objet: " + object_name)
		return

	# Créer et configurer sprite
	preview_sprite = Sprite2D.new()
	preview_sprite.texture = texture
	preview_sprite.modulate = Color(1, 1, 1, 0.5)
	
	if type == "wall":
		var region_rect = obj_data.region 

		preview_sprite.region_enabled = true
		preview_sprite.region_rect = region_rect
		preview_sprite.centered = false
		preview_sprite.offset = Vector2.ZERO
	
	add_child(preview_sprite)


# Supprimer proprement la prévisualisation
func reset_preview():	
	is_selecting = false
	start_pos = construction_logic.grid.check_cell()
	end_pos = Vector2.ZERO
	construction_logic.current_rotation = 0
	preview_layer.clear()
