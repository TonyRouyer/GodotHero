extends Node2D
class_name Previsualisation

const TilePositions: Script = preload("res://Ressources/tile_positions.gd")

@onready var parent = get_parent()
@onready var preview_layer: TileMapLayer = $"../../Level/Preview"
@onready var room: Node2D = $".."

@onready var grid_size: int = parent.grid_size

var preview_instance: Node2D = null
var is_selecting: bool = false
var start_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO
var can_place: bool = true
var preview_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	room.connect("previsu_signal", _on_previsu_signal)
	room.connect("selecting_signal", _on_selecting_signal)


func _process(_delta: float) -> void:
	end_pos = room.grid.check_cell()
	
	if preview_instance:
		var aligned_pos = room.grid.check_cell() * grid_size
		preview_instance.position = aligned_pos + preview_size / 2

		if GameData.construction_type in ["object", "move"]:
			update_object_preview_texture()

	if is_selecting and GameData.construction_type in ["wall", "floor", "room"]:
		show_preview_with_tileset()

	update_preview_modulate()
	queue_redraw()


func _draw() -> void:
	var hovered_tile = floor(get_global_mouse_position() / grid_size)
	var hovered_zone = parent.rooms_logic.get_hovered_zone(hovered_tile)
	if hovered_zone:
		var directions = {
			Vector2.LEFT: Vector2(-1, 0),
			Vector2.RIGHT: Vector2(1, 0),
			Vector2.UP: Vector2(0, -1),
			Vector2.DOWN: Vector2(0, 1)
		}
		for tile in hovered_zone.tiles:
			var origin = tile * grid_size
			for dir in directions:
				var neighbor = tile + directions[dir]
				if not hovered_zone.tiles.has(neighbor):
					match dir:
						Vector2.LEFT:
							draw_line(origin, origin + Vector2(0, grid_size), Color.WHITE, 2)
						Vector2.RIGHT:
							draw_line(origin + Vector2(grid_size, 0), origin + Vector2(grid_size, grid_size), Color.WHITE, 2)
						Vector2.UP:
							draw_line(origin, origin + Vector2(grid_size, 0), Color.WHITE, 2)
						Vector2.DOWN:
							draw_line(origin + Vector2(0, grid_size), origin + Vector2(grid_size, grid_size), Color.WHITE, 2)


func _on_selecting_signal(state: bool, pos: Vector2) -> void:
	is_selecting = state
	start_pos = pos


func _on_previsu_signal() -> void:
	reset_previsualisation()
	instantiate_preview()


func instantiate_preview() -> void:
	if preview_instance:
		preview_instance.queue_free()

	var path = ""
	match GameData.construction_type:
		"wall":
			path = "res://Sprites/terrain/icon/"
		"door":
			path = "res://Sprites/items/"
		"floor":
			path = "res://Sprites/terrain/"

	if path != "":
		preview_instance = create_preview_sprite(path + GameData.construction_item + ".png", Vector2(grid_size, grid_size))
	elif GameData.construction_type in ["object", "move"]:
		preview_instance = create_object_preview()

	if preview_instance:
		add_child(preview_instance)


func create_preview_sprite(texture_path: String, size: Vector2) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = load(texture_path)
	sprite.modulate = Color(1, 1, 1, 0.5)
	preview_size = size
	return sprite


func create_object_preview() -> Sprite2D:
	var obj_rotation = parent.rotation_name[parent.current_rotation]
	var obj_data = TilePositions.OBJECTS[GameData.construction_item]
	var tile_id = obj_data.object_tile_index
	var coord = obj_data.object_tile_coord[obj_rotation]

	var source = parent.objects_logic.object_layer.tile_set.get_source(tile_id)
	var region = source.get_tile_texture_region(coord)
	var size = source.get_tile_size_in_atlas(coord) * grid_size

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source.texture
	atlas_texture.region = region

	var sprite = Sprite2D.new()
	sprite.texture = atlas_texture
	sprite.modulate = Color(1, 1, 1, 0.5)
	preview_size = size
	return sprite


func update_object_preview_texture() -> void:
	var obj_rotation = parent.rotation_name[parent.current_rotation]
	var obj_data = TilePositions.OBJECTS[GameData.construction_item]
	var tile_id = obj_data.object_tile_index
	var coord = obj_data.object_tile_coord[obj_rotation]

	var source = parent.objects_logic.object_layer.tile_set.get_source(tile_id)
	var region = source.get_tile_texture_region(coord)
	var size = source.get_tile_size_in_atlas(coord) * grid_size

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source.texture
	atlas_texture.region = region

	preview_instance.texture = atlas_texture
	preview_size = size


func update_preview_modulate() -> void:
	var color := Color(0, 1, 0, 0.5)
	if preview_instance:
		preview_instance.modulate = color
	preview_layer.modulate = color


func reset_previsualisation() -> void:
	can_place = true
	is_selecting = false
	start_pos = room.grid.check_cell()
	end_pos = Vector2.ZERO
	parent.current_rotation = 0
	preview_size = Vector2.ZERO
	preview_layer.clear()
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null


func show_preview_with_tileset() -> void:
	preview_layer.clear()

	var min_x = int(min(start_pos.x, end_pos.x))
	var max_x = int(max(start_pos.x, end_pos.x))
	var min_y = int(min(start_pos.y, end_pos.y))
	var max_y = int(max(start_pos.y, end_pos.y))
	var cells: Array = []

	match GameData.construction_type:
		"wall":
			var id = TilePositions.WALL_TILES[GameData.construction_item].index
			for x in range(min_x, max_x + 1):
				for y in range(min_y, max_y + 1):
					if x == min_x or x == max_x or y == min_y or y == max_y:
						var tile_pos = Vector2(x, y)
						BetterTerrain.set_cell(preview_layer, tile_pos, id)
						cells.append(tile_pos)
			BetterTerrain.update_terrain_cells(preview_layer, cells)

		"floor", "room":
			var id = TilePositions.FLOOR_TILES.get(GameData.construction_item, TilePositions.FLOOR_TILES["stone"]).index
			for x in range(min_x, max_x + 1):
				for y in range(min_y, max_y + 1):
					var tile = Vector2(x, y)
					preview_layer.set_cell(tile, id, Vector2.ZERO)
					cells.append(tile)



#extends Node2D
#class_name Previsualisation
#
#const TilePositions : Script = preload("res://Ressources/tile_positions.gd")
#
#@onready var parent = get_parent()
#@onready var preview_layer: TileMapLayer = $"../../Level/Preview"
#@onready var room : Node2D = $".."
#
#@onready var preview_instance : Node2D = null  # Instance de l'objet de prévisualisation
#@onready var grid_size : int = get_parent().grid_size
#@onready var is_selecting : bool = false
#@onready var start_pos : Vector2 = Vector2.ZERO
#@onready var end_pos : Vector2 = Vector2.ZERO
#
#var can_place: bool = true
#var preview_size: Vector2 = Vector2.ZERO
#
#
#func _ready() -> void:
	#room.connect("previsu_signal", _on_previsu_signal)
	#room.connect("selecting_signal", _on_selecting_signal )
#
#
#func _process(_delta) -> void:
	#end_pos = room.grid.check_cell()
	#
	#if GameData.construction_type in ["object", "move", "door"] and preview_instance:
		#var aligned_pos = room.grid.check_cell()  * grid_size # position de la sourie sur le tileset (haut gauche d'une tile)/ exemple Vector2(832,176)
		#preview_instance.position = aligned_pos + (preview_size / 2)
		#if GameData.construction_type in ["object", "move"]:
			#var current_rotation = parent.rotation_name[parent.current_rotation]
			#var object_ressource = TilePositions.OBJECTS[GameData.construction_item]
			#var tile_id = object_ressource.object_tile_index
			#var tile_coord = object_ressource.object_tile_coord[current_rotation]
#
			#var source = parent.objects_logic.object_layer.tile_set.get_source(tile_id)
			#var region = source.get_tile_texture_region(tile_coord)
			#var base_texture = source.texture
			#var tile_size = (source.get_tile_size_in_atlas(tile_coord) * grid_size)
#
			#var atlas_texture = AtlasTexture.new()
			#atlas_texture.atlas = base_texture
			#atlas_texture.region = region
			#preview_instance.texture =  atlas_texture
			#preview_size = tile_size
#
#
			#preview_instance
	#elif GameData.construction_type in  ["wall", "floor"] and preview_instance:
		#var aligned_pos = room.grid.check_cell() * grid_size
		#preview_instance.position = aligned_pos + (preview_size / 2)
#
	#if is_selecting:
		#if GameData.construction_type in ["wall", "floor", "room"]:
			#show_preview_with_tileset()
			#
	#if can_place :
		#if preview_instance:
			#preview_instance.modulate = Color(0, 1, 0, 0.5)
		#preview_layer.modulate = Color(0, 1, 0, 0.5)
	#else:
		#if preview_instance:
			#preview_instance.modulate = Color(0, 1, 0, 0.5)
		#preview_layer.modulate = Color(0, 1, 0, 0.5)
#
	#queue_redraw()
#
#func _draw():
	#var hovered_tile = floor(get_global_mouse_position() / grid_size)
	#var hovered_zone = parent.rooms_logic.get_hovered_zone(hovered_tile)
#
	#if hovered_zone:
		#var directions = {
			#Vector2.LEFT: Vector2(-1, 0),
			#Vector2.RIGHT: Vector2(1, 0),
			#Vector2.UP: Vector2(0, -1),
			#Vector2.DOWN: Vector2(0, 1)
		#}
#
		#var zone_tiles = hovered_zone.tiles
		#var tile_size = grid_size
#
		#for tile in zone_tiles:
			#var origin = tile * tile_size
#
			## Pour chaque direction, on trace le bord si pas de tuile voisine dans cette direction
			#for dir in directions.keys():
				#var neighbor = tile + directions[dir]
				#if not zone_tiles.has(neighbor):
					#match dir:
						#Vector2.LEFT:
							#draw_line(origin, origin + Vector2(0, tile_size), Color.WHITE, 2)
						#Vector2.RIGHT:
							#draw_line(origin + Vector2(tile_size, 0), origin + Vector2(tile_size, tile_size), Color.WHITE, 2)
						#Vector2.UP:
							#draw_line(origin, origin + Vector2(tile_size, 0), Color.WHITE, 2)
						#Vector2.DOWN:
							#draw_line(origin + Vector2(0, tile_size), origin + Vector2(tile_size, tile_size), Color.WHITE, 2)
#
#
#func _on_selecting_signal(state : bool, pos : Vector2) -> void:
	#is_selecting = state
	#start_pos = pos
#
#
#func _on_previsu_signal():
	#reset_previsualisation()
	#instantiate_preview()
#
#
#func instantiate_preview() -> void:
	#if preview_instance:
		#preview_instance.queue_free()
	#
	#match GameData.construction_type:
		#"wall":
			#preview_instance = Sprite2D.new()
			#preview_instance.texture = load("res://Sprites/terrain/icon/"+ str(GameData.construction_item) +".png")
			#preview_instance.modulate = Color(1, 1, 1, 0.5)
			#preview_size = Vector2(grid_size,grid_size)
		#"door":
			#preview_instance = Sprite2D.new()
			#preview_instance.texture = load("res://Sprites/items/"+ str(GameData.construction_item) +".png")
			#preview_instance.modulate = Color(1, 1, 1, 0.5)
			#preview_size =  Vector2(grid_size,grid_size)
		#"floor":
			#preview_instance = Sprite2D.new()
			#preview_instance.texture = load("res://Sprites/terrain/"+ str(GameData.construction_item) +".png")
			#preview_instance.modulate = Color(1, 1, 1, 0.5)
			#preview_size =  Vector2(grid_size,grid_size)
		#"object", "move":
			##1: On recup la taille du tile
			#var current_rotation = parent.rotation_name[parent.current_rotation]
			#var object_ressource = TilePositions.OBJECTS[GameData.construction_item]
			#var tile_id = object_ressource.object_tile_index
			#var tile_coord = object_ressource.object_tile_coord[current_rotation]
#
			#var source = parent.objects_logic.object_layer.tile_set.get_source(tile_id)
			#var region = source.get_tile_texture_region(tile_coord)
			#var base_texture = source.texture
			#var tile_size = (source.get_tile_size_in_atlas(tile_coord) * grid_size)
#
			##2: on recupere l'image du tileset
			#var atlas_texture = AtlasTexture.new()
			#atlas_texture.atlas = base_texture
			#atlas_texture.region = region
			#
			##3: on cree un sprite2d et on applique la texture
			#preview_instance = Sprite2D.new()
			#preview_instance.texture =  atlas_texture
			#
			##4.  on change la couleur
			#preview_instance.modulate = Color(1, 1, 1, 0.5)
			#preview_size = tile_size
	#if preview_instance:
		#add_child(preview_instance)
#
#
#func reset_previsualisation() -> void:
	#can_place = true
	#is_selecting = false
	#start_pos = room.grid.check_cell()
	#end_pos = Vector2()
	#parent.current_rotation = 0  # Reset rotation to the front face when resetting the preview
	#preview_size = Vector2.ZERO
	#preview_layer.clear()
	#if preview_instance:
		#preview_instance.queue_free()
		#preview_instance = null
#
#
#func show_preview_with_tileset():
	#preview_layer.clear()
	#
	#var min_x = int(min(start_pos.x, end_pos.x))
	#var max_x = int(max(start_pos.x, end_pos.x))
	#var min_y = int(min(start_pos.y, end_pos.y))
	#var max_y = int(max(start_pos.y, end_pos.y))
	#var cells := []
	#
	#if GameData.construction_type == "wall":
		#var terrain_id = TilePositions.WALL_TILES[GameData.construction_item].index
		#for x in range(min_x, max_x + 1):
			#for y in range(min_y, max_y + 1):
				#if x == min_x or x == max_x or y == min_y or y == max_y:
					#var tile_pos = Vector2(x, y)
					#BetterTerrain.set_cell(preview_layer, tile_pos, terrain_id)
					#cells.append(tile_pos)
				#BetterTerrain.update_terrain_cells(preview_layer, cells)
	#
	#elif GameData.construction_type == "floor":
		#var tile_pos = TilePositions.FLOOR_TILES[GameData.construction_item].index
		#for x in range(min_x, max_x + 1):
			#for y in range(min_y, max_y + 1):
				#var tile = Vector2(x, y)
				#preview_layer.set_cell(tile, tile_pos, Vector2(0,0))
				#cells.append(tile)
#
	#elif GameData.construction_type == "room":
		## Prévisualise toute la zone en vert
		#var tile_pos = TilePositions.FLOOR_TILES["stone"].index
		#for x in range(min_x, max_x + 1):
			#for y in range(min_y, max_y + 1):
				#var tile = Vector2(x, y)
				#preview_layer.set_cell(tile, tile_pos, Vector2(0,0))
