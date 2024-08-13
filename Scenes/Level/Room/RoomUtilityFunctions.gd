extends Node2D

@onready var tilemap = $"../../TileMap".get_node("TileMap")
@onready var TilePositions = get_parent().TilePositions
@onready var grid_size = get_parent().grid_size

var occupied_cells = [Vector2(1,1), Vector2(2,1), Vector2(25,23), Vector2(25,26), Vector2(38,22)]


#TODO
	#Empecher creation mur sur falaise


func check_cell():
	return tilemap.local_to_map(get_global_mouse_position()) #map_pos
	
func is_within_bounds(pos):
	var grid_wide = 124
	var grid_height = 64
	return pos.x >= 0 and pos.x < grid_wide and pos.y >= 0 and pos.y < grid_height
	
func mark_occupied_cells(tile_origin: Vector2i, size: Vector2i):
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var cell_position = Vector2(x, y)
			occupied_cells.append(cell_position)  # Marquer la cellule comme occupée

func clear_occupied_cells(tile_origin: Vector2, size: Vector2):
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var cell_position = Vector2(x, y)
			if cell_position in occupied_cells:
				occupied_cells.erase(cell_position)  # Libérer la cellule

func get_tile_size(atlas_coords: Vector2i):
	var tile_set = tilemap.tile_set
	var atlas = tile_set.get_source(1) as TileSetAtlasSource
	var tileImage = atlas.get_tile_size_in_atlas(atlas_coords)
	return tileImage

func can_place_object(tile_origin: Vector2, size: Vector2):
	for x in range(tile_origin.x - size.x + 1, tile_origin.x + 1):
		for y in range(tile_origin.y - size.y + 1, tile_origin.y + 1):
			var check_position = Vector2(x, y)
			
			#Si sur le tilemap sur la layer 1 (wall) il y a une tile avec l'id 2 (celuis du wall)
			if tilemap.get_cell_source_id(1, check_position) == 2:
				return true
			
			#Si check_position est contenue dans le tableau occuper cell
			if check_position in occupied_cells:
				return true

	return false

func update_neighbors(pos):
	var neighbors = [
		Vector2(pos.x, pos.y - 1),
		Vector2(pos.x + 1, pos.y),
		Vector2(pos.x, pos.y + 1),
		Vector2(pos.x - 1, pos.y)
	]
	for neighbor in neighbors:
		#if tilemap.get_cell_source_id(1, neighbor) != -1:
		if tilemap.get_cell_source_id(1, neighbor) != -1 and tilemap.get_cell_source_id(1, neighbor) == 2:
			if global.construction_type == "wall":
				var tile_id = determine_wall_tile_id(neighbor, global.construction_item)
				tilemap.set_cell(1, neighbor, 2, tile_id)
			else:
				var wall_type = null
				if tilemap.get_cell_atlas_coords(1,neighbor)[0] > 6:
					wall_type = "stone_wall"
				else:
					wall_type = "wooden_wall"
				var tile_id = determine_wall_tile_id(neighbor, wall_type)
				tilemap.set_cell(1, neighbor, 2, tile_id)

func determine_wall_tile_id(tile_origin, wall_type):
	var neighbors = get_neighbors(tile_origin)
	var wall_tiles = TilePositions.WALL_TILES[wall_type]
	# Aucun bloc adjacent
	if neighbors.size() == 0:
		return wall_tiles["WALL_VERTICAL"]

	# 1 bloc adjacent
	if neighbors.size() == 1:
		var direction = neighbors.keys()[0]
		if direction == "north":
			return wall_tiles["WALL_END_VERTICAL_BOTTOM"]
		elif direction == "south":
			return wall_tiles["WALL_END_VERTICAL_TOP"]
		elif direction == "west":
			return wall_tiles["WALL_END_HORIZONTAL_RIGHT"]
		elif direction == "east":
			return wall_tiles["WALL_END_HORIZONTAL_LEFT"]

	# 2 blocs adjacents
	if neighbors.size() == 2:
		if neighbors.has("north") and neighbors.has("west"):
			return wall_tiles["ANGLE_BOTTOM_RIGHT"]
		elif neighbors.has("north") and neighbors.has("east"):
			return wall_tiles["ANGLE_BOTTOM_LEFT"]
		elif neighbors.has("south") and neighbors.has("west"):
			return wall_tiles["ANGLE_TOP_RIGHT"]
		elif neighbors.has("south") and neighbors.has("east"):
			return wall_tiles["ANGLE_TOP_LEFT"]
		elif neighbors.has("west") and neighbors.has("east"):
			return wall_tiles["WALL_HORIZONTAL"]
		elif neighbors.has("north") and neighbors.has("south"):
			return wall_tiles["WALL_VERTICAL"]

	# 3 blocs adjacents
	if neighbors.size() == 3:
		if neighbors.has("north") and neighbors.has("west") and neighbors.has("east"):
			return wall_tiles["WALL_T_INTERSECTION_UP"]
		elif neighbors.has("south") and neighbors.has("west") and neighbors.has("east"):
			return wall_tiles["WALL_T_INTERSECTION_DOWN"]
		elif neighbors.has("north") and neighbors.has("south") and neighbors.has("west"):
			return wall_tiles["WALL_T_INTERSECTION_LEFT"]
		elif neighbors.has("north") and neighbors.has("south") and neighbors.has("east"):
			return wall_tiles["WALL_T_INTERSECTION_RIGHT"]

	# 4 blocs adjacents
	if neighbors.size() == 4:
		return wall_tiles["WALL_X_INTERSECTION"]

	return wall_tiles["WALL_HORIZONTAL"]
	
func get_neighbors(pos):
	var neighbors = {}
	var tileset_id = 2  # ID du TileSet des murs
	
	if tilemap.get_cell_source_id(1, pos + Vector2(0, -1)) == tileset_id:
		neighbors["north"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(0, 1)) == tileset_id:
		neighbors["south"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(-1, 0)) == tileset_id:
		neighbors["west"] = true
	if tilemap.get_cell_source_id(1, pos + Vector2(1, 0)) == tileset_id:
		neighbors["east"] = true
		
	print(neighbors)
	return neighbors

func destroy_tile_and_scene_objects(tile_origin: Vector2):
	# Détruire les objets dans le TileMap (comme avant)
	var cell_source_id = tilemap.get_cell_source_id(2, tile_origin)
	if cell_source_id != -1 and cell_source_id == 1:
		var atlas_coords = tilemap.get_cell_atlas_coords(2, tile_origin)
		var object_size = get_tile_size(atlas_coords)
		clear_occupied_cells(tile_origin, object_size)
		tilemap.set_cell(2, tile_origin, -1)

	# Supprimer les instances de scène à la position spécifiée
	var object_container = get_node("../../TileMap/Object")
	var children = object_container.get_children()
	for child in children:
		if child is Node2D:
			var child_position = floor(child.global_position / grid_size)
			var object_size = child.get_node("Sprite2D").region_rect.size / grid_size
			if int(child_position.x) == tile_origin.x and int(child_position.y) == tile_origin.y:
				print(occupied_cells)
				clear_occupied_cells(tile_origin, object_size)
				child.queue_free()  # Supprime l'objet de la scène
				print(occupied_cells)

func move_object(from: Vector2, to: Vector2):
	print("move object")
	# Vérifier si la destination est libre et dans les limites
	if tilemap.get_cell_source_id(2, to) == -1 and is_within_bounds(to):
		# Déplacer une tile du TileMap (layer 2)
		var obj_source_id = tilemap.get_cell_source_id(2, from)
		if obj_source_id != -1:
			# Copier la tile à la nouvelle position
			tilemap.set_cell(2, to,1,obj_source_id)


			# Supprimer la tile à l'ancienne position
			tilemap.set_cell(2, from, -1)
		
		# Déplacer une instance de scène (si elle existe à la position 'from')
		var children = get_children()
		for child in children:
			if child is Node2D:
				var child_position = floor(child.global_position / grid_size)
				if int(child_position.x) == from.x and int(child_position.y) == from.y:
					# Mettre à jour la position de l'objet
					child.position = to * grid_size
					break  # Sortir de la boucle une fois que l'objet est déplacé)
	global.construction_type = null
