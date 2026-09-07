## RoomManager.gd — Autoload
## Détecte les pièces : zones closes entourées de murs (portes comprises).
##
## Algorithme : flood fill BFS depuis chaque tile non-mur non visitée.
## Si la région atteint l'extérieur de la build zone → zone ouverte (pas une pièce).
## Si elle reste entièrement close → pièce détectée.
##
## Les portes sont traitées comme des murs : elles ferment la pièce.
## (futur : ajouter un état ouvert/fermé pour fusionner des pièces adjacentes)
##
## Données d'une pièce :
##   { "id": int, "tiles": Array[Vector2i], "area": int }
extends Node


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
## Array de Dictionary { "id", "tiles", "area" }
var rooms : Array = []

## Lookup rapide Vector2i → room_id (O(1) pour get_room_at)
var _tile_to_room : Dictionary = {}

## Recalcul différé : évite N recalculs lors d'un placement de mur en masse
var _dirty : bool = false


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.wall_placed.connect(_on_wall_placed)
	EventBus.wall_removed.connect(_on_wall_removed)
	EventBus.walls_destroyed.connect(_on_walls_destroyed)
	## Calcul initial différé (attend que GameData.walls soit peuplé)
	_dirty = true


func _exit_tree() -> void:
	if EventBus.wall_placed.is_connected(_on_wall_placed):
		EventBus.wall_placed.disconnect(_on_wall_placed)
	if EventBus.wall_removed.is_connected(_on_wall_removed):
		EventBus.wall_removed.disconnect(_on_wall_removed)
	if EventBus.walls_destroyed.is_connected(_on_walls_destroyed):
		EventBus.walls_destroyed.disconnect(_on_walls_destroyed)


func _process(_delta: float) -> void:
	if _dirty:
		_dirty = false
		recalculate()


# ─────────────────────────────────────────────
#  CALLBACKS EVENTBUS
# ─────────────────────────────────────────────
func _on_wall_placed(_pos: Vector2i, _item_id: String) -> void:
	_dirty = true


func _on_wall_removed(_pos: Vector2i) -> void:
	_dirty = true


func _on_walls_destroyed(_destroyed: Array[Vector2i], _neighbors: Array[Vector2i]) -> void:
	_dirty = true


# ─────────────────────────────────────────────
#  DÉTECTION DES PIÈCES
# ─────────────────────────────────────────────
func recalculate() -> void:
	rooms.clear()
	_tile_to_room.clear()

	var visited : Dictionary = {}
	var room_id : int        = 0

	var min_x : int = GameConfig.BUILD_ZONE_MIN.x
	var min_y : int = GameConfig.BUILD_ZONE_MIN.y
	var max_x : int = GameConfig.BUILD_ZONE_MAX.x - 1
	var max_y : int = GameConfig.BUILD_ZONE_MAX.y - 1

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var pos := Vector2i(x, y)
			if visited.has(pos):
				continue
			if _is_wall(pos):
				visited[pos] = true
				continue

			var result : Dictionary = _flood_fill(pos, visited, min_x, min_y, max_x, max_y)

			if result["is_exterior"] or result["tiles"].is_empty():
				continue

			var room : Dictionary = {
				"id":   room_id,
				"tiles": result["tiles"],
				"area":  result["tiles"].size(),
			}
			rooms.append(room)

			for tile : Vector2i in result["tiles"]:
				_tile_to_room[tile] = room_id

			room_id += 1

	EventBus.rooms_updated.emit(rooms)


func _flood_fill(
		start: Vector2i,
		visited: Dictionary,
		min_x: int, min_y: int, max_x: int, max_y: int
) -> Dictionary:
	var tiles       : Array[Vector2i] = []
	var is_exterior : bool             = false
	var queue       : Array[Vector2i]  = [start]

	const NEIGHBORS : Array = [
		Vector2i( 1,  0), Vector2i(-1,  0),
		Vector2i( 0,  1), Vector2i( 0, -1),
	]

	while not queue.is_empty():
		var pos : Vector2i = queue.pop_back()

		if visited.has(pos):
			continue
		visited[pos] = true

		## Hors de la build zone → la région touche l'extérieur
		if pos.x < min_x or pos.x > max_x or pos.y < min_y or pos.y > max_y:
			is_exterior = true
			continue

		## Mur ou porte → frontière, on ne traverse pas
		if _is_wall(pos):
			continue

		tiles.append(pos)

		for offset : Vector2i in NEIGHBORS:
			var neighbor : Vector2i = pos + offset
			if not visited.has(neighbor):
				queue.append(neighbor)

	return { "tiles": tiles, "is_exterior": is_exterior }


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

## Retourne true si la tile est un mur OU une porte (les deux ferment la pièce).
func _is_wall(pos: Vector2i) -> bool:
	return GameData.walls.has(pos)


# ─────────────────────────────────────────────
#  QUERY PUBLIQUE
# ─────────────────────────────────────────────

## Retourne la pièce contenant la tile donnée, ou {} si aucune.
func get_room_at(pos: Vector2i) -> Dictionary:
	var id : int = _tile_to_room.get(pos, -1)
	if id == -1:
		return {}
	for room in rooms:
		if room["id"] == id:
			return room
	return {}


## Retourne le nombre de pièces détectées.
func get_room_count() -> int:
	return rooms.size()


## Retourne true si la tile est à l'intérieur d'une pièce.
func is_in_room(pos: Vector2i) -> bool:
	return _tile_to_room.has(pos)
