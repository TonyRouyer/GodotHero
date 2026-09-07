## ConstructionManager.gd — Autoload
## Cerveau du système de construction.
## Responsabilités :
##   - Valider et appliquer les demandes de placement/destruction
##   - Tenir la liste des tâches en attente (héros à construire)
##   - Répondre aux demandes de tâche des héros (via EventBus)
##   - Sérialiser/désérialiser l'état pour la sauvegarde
##
extends Node


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────

## ObjectData = { "object_id", "origin", "size", "rotation", "instance_node" }
var placed_objects : Dictionary = {}

## Tâches de construction en attente (murs, sols, objets)
## { "id", "type", "item_id", "origin", "rotation", "assigned_hero", "priority" }
var pending_tasks  : Array = []

var _task_id_counter : int = 0

# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.construction_task_completed.connect(_on_task_completed)
	EventBus.construction_task_failed.connect(_on_task_failed)


# ─────────────────────────────────────────────
#  PLACEMENT — MURS
# ─────────────────────────────────────────────
func request_wall(item_id: String, positions: Array[Vector2i]) -> bool:
	var valid_positions : Array[Vector2i] = []
	for pos in positions:
		if not _is_in_bounds(pos):
			EventBus.ui_notification_requested.emit("Construction hors zone", "error")
			return false
		if _has_wall(pos):
			EventBus.ui_notification_requested.emit("Mur déjà construit", "error")
			return false
		if _has_object(pos):
			EventBus.ui_notification_requested.emit("Emplacement occupé par un objet", "error")
			return false
		valid_positions.append(pos)

	if valid_positions.is_empty():
		return false

	var item :Dictionary = ItemRegistry.get_item(item_id)
	var cost : int = item.get("cost", 0) * valid_positions.size()
	if not GameData.can_afford(cost):
		EventBus.ui_notification_requested.emit("Or insuffisant (%d requis)" % cost, "error")
		return false

	GameData.spend_gold(cost)

	for pos in valid_positions:
		## Si une tâche mur/porte est déjà en attente ici, on la remplace (remboursement inclus)
		_replace_pending_wall_at(pos)
		var task : Dictionary = _make_task("wall", item_id, pos, 0, 10)
		pending_tasks.append(task)
		EventBus.construction_task_added.emit(task)
	return true


# ─────────────────────────────────────────────
#  PLACEMENT — SOLS
# ─────────────────────────────────────────────
func request_floor(item_id: String, positions: Array[Vector2i]) -> bool:
	var valid_positions : Array[Vector2i] = []
	for pos in positions:
		if not _is_in_bounds(pos):
			EventBus.ui_notification_requested.emit("Construction hors zone", "error")
			return false
		valid_positions.append(pos)

	if valid_positions.is_empty():
		return false

	var item : Dictionary = ItemRegistry.get_item(item_id)
	var cost : int = item.get("cost", 0) * valid_positions.size()
	if not GameData.can_afford(cost):
		EventBus.ui_notification_requested.emit("Or insuffisant (%d requis)" % cost, "error")
		return false
		
	GameData.spend_gold(cost)

	for pos in valid_positions:
		var task : Dictionary = _make_task("floor", item_id, pos, 0, 8)
		pending_tasks.append(task)
		EventBus.construction_task_added.emit(task)

	return true


# ─────────────────────────────────────────────
#  PLACEMENT — OBJETS
# ─────────────────────────────────────────────
func request_object(item_id: String, origin: Vector2i, rotation: int) -> bool:
	var item : Dictionary = ItemRegistry.get_item(item_id)
	if item.is_empty():
		push_error("ConstructionManager: item inconnu '%s'" % item_id)
		return false

	var size = _rotated_size(item.get("size", Vector2.ONE), rotation)

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var check : Vector2i = origin + Vector2i(x, y)
			if not _is_in_bounds(check):
				EventBus.ui_notification_requested.emit("Emplacement hors zone", "error")
				return false
			if _has_wall(check):
				EventBus.ui_notification_requested.emit("Emplacement occupé par un mur", "error")
				return false
			if _has_object(check):
				EventBus.ui_notification_requested.emit("Emplacement déjà occupé", "error")
				return false

	var cost : int = item.get("cost", 0)
	if not GameData.can_afford(cost):
		EventBus.ui_notification_requested.emit("Or insuffisant (%d requis)" % cost, "error")
		return false

	GameData.spend_gold(cost)

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var cell : Vector2i = origin + Vector2i(x, y)
			placed_objects[cell] = {
				"object_id":     item_id,
				"origin":        origin,
				"size":          size,
				"rotation":      rotation,
				"constructed":   false,   ## pas encore construit
				"instance_node": null,
			}

	var task : Dictionary = _make_task("object", item_id, origin, rotation, 12, size)
	pending_tasks.append(task)
	EventBus.construction_task_added.emit(task)
	return true


# ─────────────────────────────────────────────
#  DESTRUCTION
# ─────────────────────────────────────────────
func request_destroy_all(positions: Array[Vector2i]) -> void:
	var destroyed : Array[Vector2i] = []

	for pos in positions:
		if _has_wall(pos):
			destroyed.append(pos)
		EventBus.wall_removed.emit(pos)
		EventBus.floor_placed.emit(pos, "grass")
		if _has_object(pos):
			_remove_object_at(pos)

	if destroyed.is_empty():
		return

	var min_x :int = destroyed[0].x
	var max_x :int = destroyed[0].x
	var min_y :int = destroyed[0].y
	var max_y :int = destroyed[0].y
	for pos in destroyed:
		min_x = mini(min_x, pos.x)
		max_x = maxi(max_x, pos.x)
		min_y = mini(min_y, pos.y)
		max_y = maxi(max_y, pos.y)

	var neighbors : Array[Vector2i] = []
	for x in range(min_x - 1, max_x + 2):
		for y in range(min_y - 1, max_y + 2):
			var pos := Vector2i(x, y)
			if not destroyed.has(pos) and _has_wall(pos):
				neighbors.append(pos)

	if neighbors.size() > 0:
		var wall_layer := get_tree().get_root().get_node("GuildScene/World/Level/Wall") as TileMapLayer
		if wall_layer:
			BetterTerrain.update_terrain_cells(wall_layer, neighbors)


func request_destroy_wall(positions: Array[Vector2i]) -> void:
	var destroyed : Array[Vector2i] = []

	for pos in positions:
		if _has_wall(pos):
			destroyed.append(pos)

	if destroyed.is_empty():
		return

	# Collecte les voisins AVANT la destruction (pendant qu'ils sont encore dans GameData)
	var neighbors : Array[Vector2i] = []
	var neighbor_offsets :Array = [
		Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1),
	]
	for pos in destroyed:
		for offset in neighbor_offsets:
			var neighbor = pos + offset
			# Voisin valide : pas dans les détruits, a un mur, pas déjà dans la liste
			if not destroyed.has(neighbor) \
			and _has_wall(neighbor) \
			and not neighbors.has(neighbor):
				neighbors.append(neighbor)

	# Émet les suppressions
	for pos in destroyed:
		EventBus.wall_removed.emit(pos)
		EventBus.floor_placed.emit(pos, "grass")

	# Signal unique avec tout le contexte pour que ConstructionLayer mette à jour BetterTerrain
	EventBus.walls_destroyed.emit(destroyed, neighbors)


func request_destroy_floor(positions: Array[Vector2i]) -> void:
	for pos in positions:
		if not _has_wall(pos):
			EventBus.floor_placed.emit(pos, "grass")


func request_destroy_object(positions: Array[Vector2i]) -> void:
	for pos in positions:
		if _has_object(pos):
			_remove_object_at(pos)


func _remove_object_at(cell: Vector2i) -> void:
	if not placed_objects.has(cell):
		return
	var data   = placed_objects[cell]
	var origin = data["origin"]
	var size : Vector2 = data["size"]
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			placed_objects.erase(origin + Vector2i(x, y))
	EventBus.object_removed.emit(origin)


# ─────────────────────────────────────────────
#  GESTION DES TÂCHES HÉROS
# ─────────────────────────────────────────────

## Retourne la tâche non assignée la plus proche du héros et la marque comme assignée.
## Retourne {} si aucune tâche disponible.
func claim_nearest_task(hero_pos: Vector2, hero_id: int) -> Dictionary:
	var best_task : Dictionary = {}
	var best_dist : float = INF

	for task in pending_tasks:
		if task.get("assigned_hero", -1) != -1:
			continue
		var size   : Vector2 = task.get("size", Vector2.ONE)
		## Distance au centre de la zone de construction
		var center : Vector2 = (Vector2(task["origin"]) + size * 0.5) * GameConfig.TILE_SIZE
		var dist   : float   = hero_pos.distance_to(center)
		if dist < best_dist:
			best_dist = dist
			best_task = task

	if best_task.is_empty():
		return {}

	best_task["assigned_hero"] = hero_id
	return best_task


func _on_task_completed(task: Dictionary) -> void:
	_finalize_task(task)
	_remove_pending_task(task["id"])


func _on_task_failed(task: Dictionary, _hero_id: int) -> void:
	var found : Dictionary = _find_pending_task(task.get("id", -1))
	if not found.is_empty():
		found["assigned_hero"] = -1


func _finalize_task(task: Dictionary) -> void:
	var t_type  : String   = task.get("type", "")
	var item_id : String   = task.get("item_id", "")
	var origin  : Vector2i = task.get("origin", Vector2i.ZERO)

	match t_type:
		"wall":
			EventBus.wall_placed.emit(origin, item_id)
		"floor":
			EventBus.floor_placed.emit(origin, item_id)
		"object":
			if placed_objects.has(origin):
				placed_objects[origin]["constructed"] = true
			EventBus.object_placed.emit(item_id, origin)


# ─────────────────────────────────────────────
#  QUERY — utilisé par HeroRoutine / HeroActivity / Preview
# ─────────────────────────────────────────────
func has_pending_tasks() -> bool:
	for t in pending_tasks:
		if t.get("assigned_hero", -1) == -1:
			return true
	return false

## Non utilisée
func get_available_tasks() -> Array:
	var result := []
	for t in pending_tasks:
		if t.get("assigned_hero", -1) == -1:
			result.append(t)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["priority"] > b["priority"])
	return result


func is_position_occupied(pos: Vector2i) -> bool:
	return _has_object(pos)


func get_object_at(pos: Vector2i) -> Dictionary:
	return placed_objects.get(pos, {})

## Non utilisée
func get_object_origin(pos: Vector2i) -> Vector2i:
	var data : Dictionary = placed_objects.get(pos, {})
	return data.get("origin", pos)


# ─────────────────────────────────────────────
#  HELPERS INTERNES (publics pour Preview)
# ─────────────────────────────────────────────
func _is_in_bounds(pos: Vector2i) -> bool:
	return (pos.x >= GameConfig.BUILD_ZONE_MIN.x and
			pos.y >= GameConfig.BUILD_ZONE_MIN.y and
			pos.x < GameConfig.BUILD_ZONE_MAX.x and
			pos.y < GameConfig.BUILD_ZONE_MAX.y)


func _has_wall(pos: Vector2i) -> bool:
	return GameData.walls.has(pos)


func _has_object(pos: Vector2i) -> bool:
	return placed_objects.has(pos)


func _rotated_size(base_size: Vector2, rotation: int) -> Vector2:
	if rotation % 2 == 1:
		return Vector2(base_size.y, base_size.x)
	return base_size


## Wrappers publics — ConstructionPreview ne doit pas appeler les méthodes privées
func is_in_bounds(pos: Vector2i) -> bool:
	return _is_in_bounds(pos)


func get_rotated_size(base_size: Vector2, rotation: int) -> Vector2:
	return _rotated_size(base_size, rotation)


# ─────────────────────────────────────────────
#  VENTE & DÉPLACEMENT D'OBJETS
# ─────────────────────────────────────────────

## Vend un objet posé : retire du monde et rembourse 50 % du coût.
func sell_object(origin: Vector2i) -> void:
	if not placed_objects.has(origin):
		return
	var data     : Dictionary = placed_objects[origin]
	var act_orig : Vector2i   = data.get("origin", origin)
	var item     : Dictionary = ItemRegistry.get_item(data["object_id"])
	var cost     : int        = item.get("cost", 0)
	var refund   : int        = int(cost * 0.5)
	var size     : Vector2    = data.get("size", Vector2.ONE)

	_cancel_pending_tasks_at(act_orig, size)
	_remove_object_at(act_orig)
	GameData.add_gold(refund)
	EventBus.ui_notification_requested.emit(
		"%s vendu · +%d or" % [item.get("label", "Objet"), refund], "info"
	)


## Démarre le déplacement : retire l'objet du monde sans rembourser
## et active le mode construction "move".
func start_move(origin: Vector2i) -> void:
	if not placed_objects.has(origin):
		return
	var data     : Dictionary = placed_objects[origin]
	var act_orig : Vector2i   = data.get("origin", origin)
	var item_id  : String     = data["object_id"]
	var rotation : int        = data.get("rotation", 0)
	var size     : Vector2    = data.get("size", Vector2.ONE)

	_cancel_pending_tasks_at(act_orig, size)
	_remove_object_at(act_orig)

	GameData.move_original_origin   = act_orig
	GameData.move_original_rotation = rotation

	GameData.construction_type     = "move"
	GameData.construction_item     = item_id
	GameData.construction_rotation = rotation
	EventBus.construction_mode_changed.emit("move", item_id)


## Place un objet en mode déplacement : sans déduire de coût.
func request_move_object(item_id: String, origin: Vector2i, rotation: int) -> bool:
	var item : Dictionary = ItemRegistry.get_item(item_id)
	if item.is_empty():
		return false

	var size : Vector2 = _rotated_size(item.get("size", Vector2.ONE), rotation)

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var check : Vector2i = origin + Vector2i(x, y)
			if not _is_in_bounds(check):
				EventBus.ui_notification_requested.emit("Emplacement hors zone", "error")
				return false
			if _has_wall(check):
				EventBus.ui_notification_requested.emit("Emplacement occupé par un mur", "error")
				return false
			if _has_object(check):
				EventBus.ui_notification_requested.emit("Emplacement déjà occupé", "error")
				return false

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var cell : Vector2i = origin + Vector2i(x, y)
			placed_objects[cell] = {
				"object_id":     item_id,
				"origin":        origin,
				"size":          size,
				"rotation":      rotation,
				"constructed":   false,
				"instance_node": null,
			}

	var task : Dictionary = _make_task("object", item_id, origin, rotation, 12, size)
	pending_tasks.append(task)
	EventBus.construction_task_added.emit(task)
	return true


## Restaure un objet annulé directement, sans tâche de construction ni coût.
## Si l'emplacement est bloqué, rembourse intégralement.
func restore_object(item_id: String, origin: Vector2i, rotation: int) -> void:
	var item : Dictionary = ItemRegistry.get_item(item_id)
	if item.is_empty():
		return

	var size : Vector2 = _rotated_size(item.get("size", Vector2.ONE), rotation)

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var check : Vector2i = origin + Vector2i(x, y)
			if _has_wall(check) or _has_object(check):
				GameData.add_gold(item.get("cost", 0))
				EventBus.ui_notification_requested.emit(
					"Déplacement annulé · objet remboursé", "warning"
				)
				return

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var cell : Vector2i = origin + Vector2i(x, y)
			placed_objects[cell] = {
				"object_id":     item_id,
				"origin":        origin,
				"size":          size,
				"rotation":      rotation,
				"constructed":   true,
				"instance_node": null,
			}
	EventBus.object_placed.emit(item_id, origin)


## Annule toutes les tâches en attente couvrant les cases de l'objet.
func _cancel_pending_tasks_at(origin: Vector2i, size: Vector2) -> void:
	var occupied : Array[Vector2i] = []
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			occupied.append(origin + Vector2i(x, y))

	for i in range(pending_tasks.size() - 1, -1, -1):
		var task        : Dictionary = pending_tasks[i]
		var task_origin : Vector2i   = task.get("origin", Vector2i(-9999, -9999))
		if occupied.has(task_origin):
			var assigned_id : int = task.get("assigned_hero", -1)
			if assigned_id != -1:
				EventBus.construction_task_failed.emit(task, assigned_id)
			pending_tasks.remove_at(i)


## Annule et rembourse une tâche de mur en attente à cette position (pour remplacement).
func _replace_pending_wall_at(pos: Vector2i) -> void:
	for i in range(pending_tasks.size() - 1, -1, -1):
		var task : Dictionary = pending_tasks[i]
		if task.get("origin", Vector2i(-9999, -9999)) != pos:
			continue
		if task.get("type", "") != "wall":
			continue
		## Rembourse le coût de l'ancienne tâche
		var old_item : Dictionary = ItemRegistry.get_item(task.get("item_id", ""))
		GameData.add_gold(old_item.get("cost", 0))
		## Libère le héros assigné si nécessaire
		var assigned_id : int = task.get("assigned_hero", -1)
		if assigned_id != -1:
			EventBus.construction_task_failed.emit(task, assigned_id)
		pending_tasks.remove_at(i)
		## Retire le placeholder visuel
		EventBus.wall_removed.emit(pos)
		return


func _make_task(type: String, item_id: String, origin: Vector2i, rotation: int, priority: int, size: Vector2 = Vector2.ONE) -> Dictionary:
	var task : Dictionary = {
		"id":            _task_id_counter,
		"type":          type,
		"item_id":       item_id,
		"origin":        origin,
		"size":          size,
		"rotation":      rotation,
		"priority":      priority,
		"assigned_hero": -1,
	}
	_task_id_counter += 1
	return task


func _find_pending_task(task_id: int) -> Dictionary:
	for t in pending_tasks:
		if t["id"] == task_id:
			return t
	return {}


func _remove_pending_task(task_id: int) -> void:
	for i in range(pending_tasks.size() - 1, -1, -1):
		if pending_tasks[i]["id"] == task_id:
			pending_tasks.remove_at(i)
			return


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var objects_data :Array = []
	var seen_origins :Dictionary = {}
	for cell_data in placed_objects.values():
		var origin = cell_data["origin"]
		if seen_origins.has(origin):
			continue
		seen_origins[origin] = true
		objects_data.append({
			"object_id": cell_data["object_id"],
			"origin":    [origin.x, origin.y],
			"size":      [cell_data["size"].x, cell_data["size"].y],
			"rotation":  cell_data["rotation"],
		})
	return {
		"placed_objects":   objects_data,
		"task_id_counter":  _task_id_counter,
	}


func deserialize(data: Dictionary) -> void:
	placed_objects.clear()
	pending_tasks.clear()
	_task_id_counter = data.get("task_id_counter", 0)

	for obj in data.get("placed_objects", []):
		var origin = Vector2i(obj["origin"][0], obj["origin"][1])
		var size   = Vector2(obj["size"][0], obj["size"][1])
		var rot    = obj.get("rotation", 0)
		var oid    = obj["object_id"]
		for x in range(int(size.x)):
			for y in range(int(size.y)):
				placed_objects[origin + Vector2i(x, y)] = {
					"object_id":   oid,
					"origin":      origin,
					"size":        size,
					"rotation":    rot,
					"constructed": true,
					"instance_node": null,
				}

func rebuild_visuals() -> void:
	for pos in GameData.walls:
		var item_id = GameData.walls[pos]
		EventBus.wall_placed.emit(pos, item_id)

	for pos in GameData.floors:
		var floor_id = GameData.floors[pos]
		EventBus.floor_placed.emit(pos, floor_id)

	var seen_origins := {}
	for cell_data in placed_objects.values():
		var origin = cell_data["origin"]
		if seen_origins.has(origin):
			continue
		seen_origins[origin] = true
		## Ne ré-instancie pas un objet déjà présent (posé dans l'éditeur Godot)
		if is_instance_valid(cell_data.get("instance_node")):
			continue
		EventBus.object_placed.emit(cell_data["object_id"], origin)
