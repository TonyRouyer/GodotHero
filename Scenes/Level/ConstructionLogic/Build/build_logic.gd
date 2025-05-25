extends Node2D

const TilePositions : Script = preload("res://Ressources/tile_positions.gd")

@onready var parent = get_parent()
@onready var floor_layer : TileMapLayer = $"../../Level/Floor"
@onready var wall_layer : TileMapLayer = $"../../Level/Wall" 

# Fonction pour créer un mur en fonction du type spécifié
func create_wall(wall_type: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	
	#1: Check si pas d'objet sous chaque case de mur
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				if parent.check_object_under(Vector2(x, y), Vector2(1, 1)):
					parent.previsu.reset_previsualisation()
					return

	var terrain_id = TilePositions.WALL_TILES[wall_type].index
	var wall_cost = TilePositions.WALL_TILES[wall_type].cost

	var min_x = min(start_pos.x, end_pos.x)
	var max_x = max(start_pos.x, end_pos.x)
	var min_y = min(start_pos.y, end_pos.y)
	var max_y = max(start_pos.y, end_pos.y)
	
	var wall_cells = []

	# 2: Placer les murs uniquement sur le contour
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if x == min_x or x == max_x or y == min_y or y == max_y:
				var pos = Vector2(x, y)
				BetterTerrain.set_cell(wall_layer, pos, terrain_id)
				wall_cells.append(pos)
				
				var tile_data = wall_layer.get_cell_tile_data(pos)
				tile_data.set_custom_data("Type", "Wall")

				GameData.set_gold(-wall_cost)

	BetterTerrain.update_terrain_cells(wall_layer, wall_cells)

	#3: On place les tuile au sol entre les mir
	var floor_tile = TilePositions.FLOOR_TILES["wood"].index
	var floor_cost = TilePositions.FLOOR_TILES["wood"].cost

	var top_left = Vector2i(min_x + 1, min_y + 1)
	var bottom_right = Vector2i(max_x - 1, max_y - 1)
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			var tile_pos = Vector2(x, y)

			# Pose le sol en bois
			floor_layer.set_cell(tile_pos, floor_tile, Vector2(0,0) )

			# Définir custom_data "is_inside" à true
			var tile_data = floor_layer.get_cell_tile_data(tile_pos)
			if tile_data:
				tile_data.set_custom_data("Is_inside", true)

			GameData.set_gold(-floor_cost)
	#4: on reset la previsu
	parent.previsu.reset_previsualisation()


# Fonction pour créer un sol en fonction du type spécifié
func create_floor(floor_type : String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	var cost = TilePositions.FLOOR_TILES[floor_type].cost
	var source_id = TilePositions.FLOOR_TILES[floor_type].index
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			var tile_origin = Vector2(x, y)
			#on (rem)place le sol si il n'y a pas de mur
			if not parent.check_wall_under(tile_origin, Vector2(1,1)):
				floor_layer.set_cell(tile_origin, source_id, Vector2(0,0))
				GameData.set_gold(-cost)     #deduis le prix pour chaque tile posé
	parent.previsu.reset_previsualisation()


# Fonction pour créer une porte en fonction du type spécifié
func create_door(door_type : String) -> void:
	var end_pos = parent.end_pos
	
	# 1:Vérifie s'il y a un objet sur la case sélectionnée
	if parent.check_object_under(end_pos, Vector2(1, 1)):
		return
	
	var tile_origin = end_pos
	var cost = TilePositions.DOOR_TILES[door_type].cost
	var terrain_id = TilePositions.DOOR_TILES[door_type].index 
	var floor_wood_id = TilePositions.FLOOR_TILES["wood"].index
	
	floor_layer.set_cell(tile_origin, floor_wood_id, Vector2(0,0))
	wall_layer.set_cell(tile_origin, terrain_id, Vector2(0,0))
	
	var tile_data = wall_layer.get_cell_tile_data(tile_origin)
	tile_data.set_custom_data("Type", "Door")

	GameData.set_gold(-cost)
	
	BetterTerrain.update_terrain_cell(wall_layer, tile_origin)
	parent.mark_occupied_cells(tile_origin, Vector2(1,1))  # Marque les cellules comme occupées
	
	parent.previsu.reset_previsualisation()





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
					floor_layer.set_cell(tile_origin, TilePositions.FLOOR_TILES["grass"].index, Vector2(0,0))
					
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
					if parent.check_wall_under(tile_origin, Vector2(1,1)):
						# On supprime sur les 2 couches puis on remplace
						floor_layer.set_cell(tile_origin, -1)
						wall_layer.set_cell(tile_origin, -1)
						floor_layer.set_cell(tile_origin, TilePositions.FLOOR_TILES["grass"].index, Vector2(0,0))
		"destroy_floor":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					if not parent.check_wall_under(tile_origin, Vector2(1,1)):
						floor_layer.set_cell(tile_origin, -1)
						floor_layer.set_cell(tile_origin, TilePositions.FLOOR_TILES["grass"].index, Vector2(0,0))
						
						var tile_data = floor_layer.get_cell_tile_data(tile_origin)
						if tile_data:
							tile_data.set_custom_data("Is_inside", false)
		"destroy_object":
			for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
				for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
					var tile_origin = Vector2(x, y)
					parent.objects_logic.destroy_objects(tile_origin)
	parent.previsu.reset_previsualisation()
