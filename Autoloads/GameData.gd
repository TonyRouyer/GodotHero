## GameData — Autoload #3
## État global du jeu EN COURS. Toutes les données runtime qui doivent
## être accessibles depuis n'importe quelle scène.
## Les modifications passent par des setters qui émettent des signaux EventBus.
extends Node


# ─────────────────────────────────────────────
#  ÉTAT GÉNÉRAL
# ─────────────────────────────────────────────
var is_paused: bool = false

# ─────────────────────────────────────────────
#  ÉCONOMIE
# ─────────────────────────────────────────────
var _gold: int = GameConfig.STARTING_GOLD
var _food: int = GameConfig.STARTING_FOOD
var _reputation: int = GameConfig.STARTING_REPUTATION

var gold: int:
	get: return _gold
	set(v):
		var delta = v - _gold
		_gold = v
		EventBus.gold_changed.emit(_gold, delta)

var food: int:
	get: return _food
	set(v):
		var delta = v - _food
		_food = v
		EventBus.food_changed.emit(_food, delta)

var reputation: int:
	get: return _reputation
	set(v):
		var delta = v - _reputation
		_reputation = v
		EventBus.reputation_changed.emit(_reputation, delta)


func add_gold(amount: int) -> void:
	gold += amount


func spend_gold(amount: int) -> bool:
	if _gold < amount:
		return false
	gold -= amount
	return true


func add_food(amount: int) -> void:
	food += amount


func consume_food(amount: int = 1) -> bool:
	if _food < amount:
		return false
	food -= amount
	return true


# ─────────────────────────────────────────────
#  INVENTAIRE GLOBAL DE LA GUILDE
# ─────────────────────────────────────────────
var inventory: Dictionary = {}   # { item_name: quantity }
var inventory_size: int = GameConfig.INVENTORY_SIZE_DEFAULT


func add_item(item_name: String, quantity: int = 1) -> void:
	inventory[item_name] = inventory.get(item_name, 0) + quantity
	EventBus.inventory_changed.emit(item_name, inventory[item_name])


func remove_item(item_name: String, quantity: int = 1) -> bool:
	var current = inventory.get(item_name, 0)
	if current < quantity:
		return false
	inventory[item_name] = current - quantity
	if inventory[item_name] == 0:
		inventory.erase(item_name)
	EventBus.inventory_changed.emit(item_name, inventory.get(item_name, 0))
	return true


func get_item_quantity(item_name: String) -> int:
	return inventory.get(item_name, 0)


# ─────────────────────────────────────────────
#  HÉROS ACTIF (sélection joueur)
# ─────────────────────────────────────────────
var active_hero_data: Resource = null

func select_hero(hero_data: Resource) -> void:
	active_hero_data = hero_data
	EventBus.hero_selected.emit(hero_data)


func deselect_hero() -> void:
	active_hero_data = null
	EventBus.hero_deselected.emit()


# ─────────────────────────────────────────────
#  CONSTRUCTION
# ─────────────────────────────────────────────
var construction_type     : String = ""
var construction_item     : String = ""
var construction_rotation : int    = 0   # 0-3, incrémenté par ConstructionInput

## Données du dernier déplacement d'objet (pour restauration sur annulation)
var move_original_origin   : Vector2i = Vector2i.ZERO
var move_original_rotation : int      = 0

var walls  : Dictionary = {}
var floors : Dictionary = {}


# ─────────────────────────────────────────────
#  ÉTAT CAMÉRA
# ─────────────────────────────────────────────
var _camera_position : Vector2 = Vector2.ZERO
var _camera_zoom     : Vector2 = Vector2(2, 2)
var _camera_saved    : bool    = false


func save_camera_state() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if not main: return
	var container = main.get_node_or_null("SceneContainer")
	if not container: return
	for child in container.get_children():
		var cam : Camera2D = child.get_node_or_null("GuildCamera")
		
		if cam:
			_camera_position = cam.global_position
			_camera_zoom     = cam.zoom
			_camera_saved    = true
			return


func restore_camera_state(camera: Camera2D) -> void:
	if not _camera_saved:
		return
	camera.global_position = _camera_position
	camera.zoom            = _camera_zoom
	_camera_saved          = false   # consommé, on ne restaure qu'une fois


func can_afford(cost: int) -> bool:
	return _gold >= cost



# ─────────────────────────────────────────────
#  PROGRESSION
# ─────────────────────────────────────────────
var research_finished: Array[String] = []
var research_points: float = 0.0
var current_day: int = 1


func complete_research(research_id: String) -> void:
	if research_id not in research_finished:
		research_finished.append(research_id)
		EventBus.research_completed.emit(research_id)


func is_research_done(research_id: String) -> bool:
	return research_id in research_finished


# ─────────────────────────────────────────────
#  SÉRIALISATION 
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	## Sérialise walls/floors avec clés string (JSON ne supporte pas Vector2i)
	var walls_data  :Dictionary = {}
	for pos in walls:
		walls_data["%d,%d" % [pos.x, pos.y]] = walls[pos]
	var floors_data :Dictionary = {}
	for pos in floors:
		floors_data["%d,%d" % [pos.x, pos.y]] = floors[pos]

	return {
		"gold":              _gold,
		"food":              _food,
		"reputation":        _reputation,
		"inventory":         inventory.duplicate(),
		"research_finished": research_finished.duplicate(),
		"research_points":   research_points,
		"current_day":       current_day,
		"walls":             walls_data,
		"floors":            floors_data,
	}


func deserialize(data: Dictionary) -> void:
	_gold       = data.get("gold",       GameConfig.STARTING_GOLD)
	_food       = data.get("food",       GameConfig.STARTING_FOOD)
	_reputation = data.get("reputation", 0)
	inventory   = data.get("inventory",  {})
	research_finished.assign(data.get("research_finished", []))
	research_points = data.get("research_points", 0.0)
	current_day = data.get("current_day", 1)

	walls.clear()
	for key in data.get("walls", {}):
		var parts = key.split(",")
		walls[Vector2i(int(parts[0]), int(parts[1]))] = data["walls"][key]

	floors.clear()
	for key in data.get("floors", {}):
		var parts = key.split(",")
		floors[Vector2i(int(parts[0]), int(parts[1]))] = data["floors"][key]

	EventBus.scene_loaded.emit("data_restored")
