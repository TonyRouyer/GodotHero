extends Node2D

@onready var parent = get_parent()
@onready var floor_layer : TileMapLayer = $"../../Level/Floor"
@onready var wall_layer : TileMapLayer = $"../../Level/Wall" 
@onready var construction_layer: TileMapLayer = $"../../Level/Placeholder"

func create_wall_construction(wall_type: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	var positions = []
	
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == start_pos.x or x == end_pos.x or y == start_pos.y or y == end_pos.y:
				var pos = Vector2i(x, y)
				
				# Vérifier validité
				if not GameData.is_in_build_zone(pos):
					return
				if parent.check_object_under(pos):
					return
					
				positions.append(pos)

	var tile_id = TilePositions.WALLS[GameData.construction_item].index

	# Si tout est valide, on construit
	for pos in positions:
		construction_layer.set_cell(pos, tile_id, Vector2i.ZERO)

		parent.add_construction_task({
			"type": "wall",
			"priority": 10,
			"wall_type": wall_type,
			"origin": pos * parent.grid_size + Vector2i(8,8), #position sur le tileset * taille grille pour pos absolue + 8 pour centrée
			"assigned": false,
		})
	
	BetterTerrain.update_terrain_cells(construction_layer, positions)

	parent.previsu.reset_preview()
	parent.audio_player.play()


func create_floor_construction(floor_type: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	var positions = []

	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			var pos = Vector2(x, y)
			
			# Vérifier validité
			if not GameData.is_in_build_zone(pos):
				return
			if parent.check_wall_under(pos):
				continue  # On ignore, mais ne bloque pas

			positions.append(pos)

	# Si une seule case au sol est construisible, on construit
	if positions.is_empty():
		return
		
	var tile_id = TilePositions.FLOORS[GameData.construction_item].index

	for pos in positions:
		construction_layer.set_cell(pos, tile_id, Vector2i.ZERO)

		parent.add_construction_task({
			"type": "floor",
			"priority": 8,
			"floor_type": floor_type,
			"origin": pos * parent.grid_size,
			"assigned": false,
		})
	
	BetterTerrain.update_terrain_cells(construction_layer, positions)

	parent.previsu.reset_preview()
	parent.audio_player.play()



func finalize_construction(construction_task: Dictionary) -> void:
	var origin: Vector2 = construction_task.get("origin", Vector2.ZERO) / parent.grid_size
	var task_type: String = construction_task.get("type", "")

	match task_type:
		"wall":
			var wall_type = construction_task.get("wall_type", "")
			var tile_id = TilePositions.WALLS[wall_type].index
			var cost = TilePositions.WALLS[wall_type].cost

			wall_layer.set_cell(origin, tile_id, Vector2(0,0))
			var tile_data = floor_layer.get_cell_tile_data(origin)
			if tile_data:
				tile_data.set_navigation_polygon(0, null)
			
			
			BetterTerrain.update_terrain_cell(wall_layer, origin)
			GameData.set_gold(-cost)

		"floor":
			var floor_type =  construction_task.get("floor_type", "")
			var tile_id = TilePositions.FLOORS[floor_type].index
			var cost = TilePositions.FLOORS[floor_type].cost
			
			floor_layer.set_cell(origin, tile_id, Vector2(0,0))
			BetterTerrain.update_terrain_cell(floor_layer, origin)
			GameData.set_gold(-cost)
		_:
			push_warning("Type de tâche inconnu : " + task_type)
			return

	# Supprimer le placeholder
	construction_layer.set_cell(origin, -1, Vector2(0,0))

	# Nettoyer les données
	parent.occupied_position.erase(origin)

	# Supprimer la tâche de la liste
	for task in parent.construction_tasks:
		if task.origin == construction_task.get("origin", ""):
			parent.construction_tasks.erase(task)
			break





# Fonction pour détruire une construction en fonction du type actuel
func destroy_construction() -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	
	match GameData.construction_type:
		"destroy_all":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					floor_layer.set_cell(tile_origin, -1)
					floor_layer.set_cell(tile_origin, TilePositions.FLOORS["grass"].index, Vector2(0,0))
					
					var tile_data = floor_layer.get_cell_tile_data(tile_origin)
					if tile_data:
						tile_data.set_custom_data("Is_inside", false)
					
					wall_layer.set_cell(tile_origin, -1)
					parent.objects_logic.destroy_objects(tile_origin)
		"destroy_wall":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					#var tile_data = floor_layer.get_cell_tile_data(tile_origin)
					# Si un mur est en dessous,
					if parent.check_wall_under(tile_origin):
						# On supprime sur les 2 couches puis on remplace
						floor_layer.set_cell(tile_origin, -1)
						wall_layer.set_cell(tile_origin, -1)
						floor_layer.set_cell(tile_origin, TilePositions.FLOORS["grass"].index, Vector2(0,0))
		"destroy_floor":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					if not parent.check_wall_under(tile_origin):
						floor_layer.set_cell(tile_origin, -1)
						floor_layer.set_cell(tile_origin, TilePositions.FLOORS["grass"].index, Vector2(0,0))
						
						var tile_data = floor_layer.get_cell_tile_data(tile_origin)
						if tile_data:
							tile_data.set_custom_data("Is_inside", false)
		"destroy_object":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					parent.objects_logic.destroy_objects(tile_origin)
	parent.previsu.reset_preview()
