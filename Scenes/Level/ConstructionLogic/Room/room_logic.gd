extends Node2D

@onready var parent = get_parent()

var zones = [] # contient des dictionnaires {name, tiles, label}
var zone_types = {
	"hall": preload("res://Scenes/Level/ConstructionLogic/Room/Rooms/hall.tres"),
	"kitchen": preload("res://Scenes/Level/ConstructionLogic/Room/Rooms/kitchen.tres"),
}


func create_room(room_name: String) -> void:
	var start_pos = parent.start_pos
	var end_pos = parent.end_pos
	var type = zone_types.get(room_name)
	
	if type == null:
		return
	
	var new_tiles := []
	for x in range(int(start_pos.x), int(end_pos.x) + 1):
		for y in range(int(start_pos.y), int(end_pos.y) + 1):
			var tile := Vector2(x, y)
			var tile_data = parent.build_logic.floor_layer.get_cell_tile_data(tile)

			# Si une tuile est manquante ou n'est pas "inside", on annule
			if not tile_data or tile_data.get_custom_data("Is_inside") != true:
				print("Zone invalide : une tuile est à l'extérieur.")
				parent.previsu.reset_previsualisation()
				return

			new_tiles.append(tile)

	if new_tiles.is_empty():
		print("Aucune tuile intérieure valide pour cette zone.")
		return

	# 1. Supprimer les tuiles des autres zones si différent type
	for zone in zones:
		if zone.name != room_name:
			zone.tiles = zone.tiles.filter(func(t): return not new_tiles.has(t))

	# 2. Fusionner les zones de même type
	var merged = false
	for zone in zones:
		if zone.name == room_name and zone.tiles.any(func(t): return new_tiles.has(t) or is_adjacent(t, new_tiles)):
			zone.tiles = (zone.tiles + new_tiles).duplicate()
			zone.tiles = zone.tiles.duplicate()  # nettoie les doublons
			update_zone_label(zone)
			merged = true
			break

	# 3. Sinon, créer une nouvelle zone
	if not merged:
		var label = Label.new()
		label.text = room_name.capitalize()
		label.name = room_name
		label.scale = Vector2(0.5, 0.5)
		add_child(label)
		label.position = get_zone_center(new_tiles) * 16

		zones.append({ "name": room_name, "tiles": new_tiles, "label": label })

	parent.previsu.reset_previsualisation()


func get_hovered_zone(tile: Vector2):
	for zone in zones:
		if tile in zone.tiles:
			return zone
	return null


func is_enclosed(tiles: Array) -> bool:
	for tile in tiles:
		if not is_tile_surrounded(tile):
			return false
	return true


func is_tile_surrounded(pos: Vector2) -> bool:
	var neighbors = [
		pos + Vector2(1, 0), pos + Vector2(-1, 0),
		pos + Vector2(0, 1), pos + Vector2(0, -1)
	]
	for n in neighbors:
		if not is_wall(n):
			return false
	return true


func is_wall(pos: Vector2i) -> bool:
	var tile_data = parent.build_logic.wall_layer.get_cell_tile_data(pos)
	if tile_data:
		return tile_data.get_custom_data("Type") == "Wall"
	return false


func is_adjacent(tile: Vector2, tile_array: Array) -> bool:
	for t in tile_array:
		if tile.distance_to(t) == 1 or (abs(tile.x - t.x) + abs(tile.y - t.y)) == 1:
			return true
	return false

func get_zone_center(tiles: Array) -> Vector2:
	var total := Vector2.ZERO
	for t in tiles:
		total += t
	return total / tiles.size()

func update_zone_label(zone: Dictionary) -> void:
	if zone.has("label"):
		zone.label.position = get_zone_center(zone.tiles) * 16
