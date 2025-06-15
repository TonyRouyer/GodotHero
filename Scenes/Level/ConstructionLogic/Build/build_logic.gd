extends Node2D

@onready var parent = get_parent()
@onready var floor_layer : TileMapLayer = $"../../Level/Floor"
@onready var wall_layer : TileMapLayer = $"../../Level/Wall" 
@onready var construction_layer: TileMapLayer = $"../../Level".get_node("Construction")



## Fonction pour créer un mur en fonction du type spécifié
#func create_wall(wall_type: String) -> void:
	#var start_pos = parent.start_pos
	#var end_pos = parent.end_pos
	#
	##1: Check si pas d'objet sous chaque case de mur
	#for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		#for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			#if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				#if parent.check_object_under(Vector2(x, y)):
					#parent.previsu.reset_preview()
					#return
#
	#var terrain_id = TilePositions.WALLS[wall_type].index
	#var wall_cost = TilePositions.WALLS[wall_type].cost
#
	#var min_x = min(start_pos.x, end_pos.x)
	#var max_x = max(start_pos.x, end_pos.x)
	#var min_y = min(start_pos.y, end_pos.y)
	#var max_y = max(start_pos.y, end_pos.y)
	#
	#var wall_cells = []
#
	## 2: Placer les murs uniquement sur le contour
	#for x in range(min_x, max_x + 1):
		#for y in range(min_y, max_y + 1):
			#if x == min_x or x == max_x or y == min_y or y == max_y:
				#var pos = Vector2(x, y)
#
				#var tile_data = wall_layer.get_cell_tile_data(pos)
				#var actual_wall_type: String = ""
				#if tile_data != null:
					#actual_wall_type = tile_data.get_custom_data("Wall_type")
				#
				#if actual_wall_type != wall_type:
					#BetterTerrain.set_cell(wall_layer, pos, terrain_id)
					#wall_cells.append(pos)
					#GameData.set_gold(-wall_cost)
#
	#BetterTerrain.update_terrain_cells(wall_layer, wall_cells)
#
	##3: On place les tuile au sol entre les mir
	#var floor_tile = TilePositions.FLOORS["wood"].index
#
	#var top_left = Vector2i(min_x + 1, min_y + 1)
	#var bottom_right = Vector2i(max_x - 1, max_y - 1)
	#for x in range(top_left.x, bottom_right.x + 1):
		#for y in range(top_left.y, bottom_right.y + 1):
			#var tile_pos = Vector2(x, y)
#
			## Pose le sol en bois
			#floor_layer.set_cell(tile_pos, floor_tile, Vector2(0,0) )
#
			## Définir custom_data "is_inside" à true
			#var tile_data = floor_layer.get_cell_tile_data(tile_pos)
			#if tile_data:
				#tile_data.set_custom_data("Is_inside", true)
#
	##4: on reset la previsu
	#parent.previsu.reset_preview()
	#parent.audio_player.play()
#
#
## Fonction pour créer un sol en fonction du type spécifié
#func create_floor(floor_type : String) -> void:
	#var start_pos = parent.start_pos
	#var end_pos = parent.end_pos
	#var cost = TilePositions.FLOORS[floor_type].cost
	#var source_id = TilePositions.FLOORS[floor_type].index
	#for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		#for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			#var pos = Vector2(x, y)
			#var tile_data = floor_layer.get_cell_tile_data(pos)
			#var actual_floor_type: String = ""
#
			#if tile_data != null:
				#actual_floor_type = tile_data.get_custom_data("Floor_type")
			#if actual_floor_type != floor_type:
				#floor_layer.set_cell(pos, source_id, Vector2(0,0))
				#GameData.set_gold(-cost) 
				   #
	#parent.previsu.reset_preview()
	#parent.audio_player.play()
#
#
## Fonction pour créer une porte en fonction du type spécifié
#func create_door(door_type : String) -> void:
	#var end_pos = parent.end_pos
	#
	## 1:Vérifie s'il y a un objet sur la case sélectionnée
	#if parent.check_object_under(end_pos):
		#return
	#
	#var tile_origin = end_pos
	#var cost = TilePositions.DOORS[door_type].cost
	#var terrain_id = TilePositions.DOORS[door_type].index 
	#var floor_wood_id = TilePositions.FLOORS["wood"].index
	#
	#floor_layer.set_cell(tile_origin, floor_wood_id, Vector2(0,0))
	#wall_layer.set_cell(tile_origin, terrain_id, Vector2(0,0))
	#
	#GameData.set_gold(-cost)
	#
	#BetterTerrain.update_terrain_cell(wall_layer, tile_origin)
	#parent.mark_occupied_cells(tile_origin, Vector2(1,1))  # Marque les cellules comme occupées
	#
	#parent.previsu.reset_preview()
	#parent.audio_player.play()



func create_wall_construction(wall_type: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	
	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			if x == min(start_pos.x, end_pos.x) or x == max(start_pos.x, end_pos.x) or y == min(start_pos.y, end_pos.y) or y == max(start_pos.y, end_pos.y):
				var pos = Vector2(x, y)
				if parent.check_object_under(pos):
					continue
				# Placeholder visuel
				construction_layer.set_cell(pos, 40, Vector2(0,0))
				
				# Marquer la case comme occupée
				parent.occupied_position[pos] = {
					"type": "wall",
					"wall_type": wall_type,
				}
				
				# Ajouter une tâche de construction
				parent.add_construction_task({
					"type": "wall",
					"wall_type": wall_type,
					"origin": pos * parent.grid_size,
					"assigned": false,
				})

	parent.previsu.reset_preview()
	parent.audio_player.play()


func create_floor_construction(floor_type: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos

	for x in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x) + 1):
		for y in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) + 1):
			var pos = Vector2(x, y)
			
			if parent.check_object_under(pos):
				continue
			
			construction_layer.set_cell(pos, 40, Vector2(0,0))

			parent.occupied_position[pos] = {
				"type": "floor",
				"floor_type": floor_type,
			}
			
			parent.add_construction_task({
				"type": "floor",
				"floor_type": floor_type,
				"origin": pos * parent.grid_size,
				"assigned": false,
			})
	
	parent.previsu.reset_preview()
	parent.audio_player.play()


func create_door_construction(door_type: String) -> void:
	var pos = parent.end_pos
	
	if parent.check_object_under(pos):
		return

	construction_layer.set_cell(pos, 40, Vector2(0,0))
	
	parent.occupied_position[pos] = {
		"type": "door",
		"door_type": door_type,
	}
	
	parent.add_construction_task({
		"type": "door",
		"door_type": door_type,
		"origin": pos * parent.grid_size,
		"assigned": false,
	})
	
	parent.previsu.reset_preview()
	parent.audio_player.play()


func finalize_construction(global_origin: Vector2) -> void:
	var origin = global_origin / parent.grid_size

	if not parent.occupied_position.has(origin):
		push_error("Aucune construction en attente à cette position.")
		return

	var data = parent.occupied_position[origin]
	var task_type = data["type"]

	match task_type:
		"wall":
			var wall_type = data["wall_type"]
			var tile_id = TilePositions.WALLS[wall_type].index
			var cost = TilePositions.WALLS[wall_type].cost

			wall_layer.set_cell(origin, tile_id, Vector2(0,0))
			BetterTerrain.update_terrain_cell(wall_layer, origin)
			GameData.set_gold(-cost)

		"floor":
			var floor_type = data["floor_type"]
			var tile_id = TilePositions.FLOORS[floor_type].index
			var cost = TilePositions.FLOORS[floor_type].cost

			floor_layer.set_cell(origin, tile_id, Vector2(0,0))
			GameData.set_gold(-cost)

		"door":
			var door_type = data["door_type"]
			var tile_id = TilePositions.DOORS[door_type].index
			var cost = TilePositions.DOORS[door_type].cost
			var floor_id = TilePositions.FLOORS["wood"].index

			floor_layer.set_cell(origin, floor_id, Vector2(0,0)) # Plancher sous porte
			wall_layer.set_cell(origin, tile_id, Vector2(0,0))
			BetterTerrain.update_terrain_cell(wall_layer, origin)
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
		if task.origin == global_origin:
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
