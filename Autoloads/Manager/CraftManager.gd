## CraftManager.gd — Autoload
## Gère les files de craft pour tous les postes de travail (forge, alchimie, atelier…).
## Seuls les jobs 2 (forgeron) et 3 (alchimiste) alimentent le système.
##
## Fonctionnement général :
##   1. Le joueur ajoute des items à la file d'un poste : add_to_queue(object, material_id, qty)
##   2. Quand un héros s'assoit à ce poste : register_worker(object, hero)
##   3. Chaque tick : le héros avance la progression de l'item actif
##   4. À 100 % : un item est produit → ajouté à GameData.inventory, matériaux consommés
##
## Formule : progress_per_tick = (skill * CRAFT_SPEED_FACTOR) / craft_time_hours
##   → skill  : stat métier du héros (manual_work ou occult_work, 1.0–100.0)
##   → craft_time_hours : défini dans MaterialLibrary
##
## Clé de station : "%d,%d" % [grid_origin.x, grid_origin.y]
## (stable entre les sessions car liée à la position dans la grille)
extends Node


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────

## { station_key → station_dict }
## station_dict : {
##   "queue"    : Array[{ material_id: String, qty: int }]   — items en attente
##   "active"   : null | { material_id: String, qty_remaining: int }
##   "progress" : float  — 0.0–100.0 pour l'item actif
## }
var _stations : Dictionary = {}

## { station_key → Hero node } — héros actuellement au travail sur ce poste
var _workers  : Dictionary = {}


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.time_tick.connect(_on_time_tick)


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

## Ajoute qty exemplaires de material_id à la file du poste.
## Vérifie que le matériau est craftable et que le lieu de craft correspond à l'objet.
func add_to_queue(object: Node2D, material_id: String, qty: int) -> bool:
	var mat : Dictionary = MaterialLibrary.get_material(material_id)
	if mat.is_empty() or not MaterialLibrary.is_craftable(material_id):
		push_warning("CraftManager: '%s' n'est pas craftable." % material_id)
		return false

	## Vérifie que l'objet peut produire ce matériau (lieu de craft compatible)
	var expected_obj : String = GameConfig.CRAFT_LOCATION_TO_OBJECT.get(mat["craft_location"], "")
	var obj_id       : String = object.get("object_id") if "object_id" in object else ""
	if expected_obj != obj_id:
		push_warning("CraftManager: '%s' ne peut pas être crafté sur '%s' (attendu '%s')."
			% [material_id, obj_id, expected_obj])
		return false

	var key     : String = _key(object)
	var station : Dictionary = _get_or_create(key)
	station["queue"].append({"material_id": material_id, "qty": qty})

	## Si aucun craft actif, tente d'en démarrer un
	if station["active"] == null:
		_try_start_next(key)

	EventBus.craft_queue_changed.emit(key, _get_queue_snapshot(key))
	return true


## Enregistre un héros comme travaillant au poste (appelé par HeroActivity).
func register_worker(object: Node2D, hero: Node) -> void:
	var key : String = _key(object)
	_workers[key] = hero
	_get_or_create(key)  ## s'assure que la station existe


## Libère le poste quand le héros part (appelé par HeroActivity).
func unregister_worker(object: Node2D) -> void:
	var key : String = _key(object)
	_workers.erase(key)


## Retourne la file d'attente lisible pour l'UI.
func get_queue(object: Node2D) -> Array:
	return _get_queue_snapshot(_key(object))


## Retourne la station complète pour l'UI (active + queue + progress).
func get_station_info(object: Node2D) -> Dictionary:
	var key : String = _key(object)
	if not _stations.has(key):
		return {"active": null, "queue": [], "progress": 0.0}
	var s : Dictionary = _stations[key]
	return {
		"active":   s["active"].duplicate() if s["active"] else null,
		"queue":    s["queue"].duplicate(true),
		"progress": s["progress"],
	}


## Vide la file d'un poste (n'annule pas le craft en cours).
func clear_queue(object: Node2D) -> void:
	var key : String = _key(object)
	if _stations.has(key):
		_stations[key]["queue"].clear()
		EventBus.craft_queue_changed.emit(key, [])


## Annule le craft en cours (matériaux perdus) et passe au suivant.
func cancel_active(object: Node2D) -> void:
	var key : String = _key(object)
	if not _stations.has(key):
		return
	_stations[key]["active"]   = null
	_stations[key]["progress"] = 0.0
	_try_start_next(key)
	EventBus.craft_queue_changed.emit(key, _get_queue_snapshot(key))


# ─────────────────────────────────────────────
#  TICK
# ─────────────────────────────────────────────
func _on_time_tick(_hour: int, _minute: int) -> void:
	for key in _workers:
		var hero : Node = _workers[key]
		if not is_instance_valid(hero) or hero.data == null:
			continue
		if not _stations.has(key):
			continue
		var station : Dictionary = _stations[key]
		if station["active"] == null:
			_try_start_next(key)
			continue

		## Calcul de la progression
		var mat_id    : String = station["active"]["material_id"]
		var mat       : Dictionary = MaterialLibrary.get_material(mat_id)
		var craft_time : float = max(mat.get("craft_time", 1.0), 0.1)

		var skill_stat : String = GameConfig.JOB_SKILL_STAT.get(hero.data.job, "manual_work")
		var skill      : float  = max(hero.data.get(skill_stat), 1.0)
		var increment  : float  = (skill / craft_time) * GameConfig.CRAFT_SPEED_FACTOR

		station["progress"] += increment

		EventBus.craft_progress_updated.emit(key, mat_id, station["progress"])

		if station["progress"] >= 100.0:
			_complete_one(key, hero)


# ─────────────────────────────────────────────
#  INTERNE
# ─────────────────────────────────────────────

## Produit 1 exemplaire de l'item actif.
func _complete_one(key: String, hero: Node) -> void:
	var station : Dictionary = _stations[key]
	var active  : Dictionary = station["active"]
	var mat_id  : String     = active["material_id"]

	## Ajoute au stock de la guilde
	GameData.add_item(mat_id, 1)
	station["progress"] = 0.0

	## Notification
	var mat   : Dictionary = MaterialLibrary.get_material(mat_id)
	var label : String     = mat.get("label", mat_id)
	EventBus.item_crafted.emit(mat_id, 1)
	EventBus.ui_notification_requested.emit(
		"%s a fabriqué : %s" % [hero.data.hero_name if hero.data else "?", label], "success")

	active["qty_remaining"] -= 1
	if active["qty_remaining"] <= 0:
		## Lot terminé → passe à l'item suivant
		station["active"] = null
		_try_start_next(key)
	else:
		## Consomme les matériaux pour le prochain exemplaire du même lot
		if not _consume_materials(mat_id):
			station["active"] = null
			EventBus.craft_material_missing.emit(key, mat_id)
			EventBus.ui_notification_requested.emit(
				"Matériaux manquants pour continuer : %s" % label, "warning")
			_try_start_next(key)

	EventBus.craft_queue_changed.emit(key, _get_queue_snapshot(key))


## Tente de démarrer le prochain item de la file.
func _try_start_next(key: String) -> void:
	var station : Dictionary = _get_or_create(key)
	if station["active"] != null or station["queue"].is_empty():
		return

	var next : Dictionary = station["queue"][0]
	var mat_id : String   = next["material_id"]

	## Vérifie et consomme les matériaux pour 1 exemplaire
	if not _can_consume(mat_id):
		EventBus.craft_material_missing.emit(key, mat_id)
		var label : String = MaterialLibrary.get_material(mat_id).get("label", mat_id)
		EventBus.ui_notification_requested.emit(
			"Matériaux insuffisants pour crafter : %s" % label, "warning")
		return

	_consume_materials(mat_id)
	station["queue"].remove_at(0)
	station["active"]         = {"material_id": mat_id, "qty_remaining": next["qty"]}
	station["progress"]       = 0.0


## Vérifie que tous les ingrédients d'un item sont disponibles (pour 1 exemplaire).
func _can_consume(material_id: String) -> bool:
	var mat : Dictionary = MaterialLibrary.get_material(material_id)
	for ing in mat.get("recipe", []):
		if GameData.get_item_quantity(ing["item_id"]) < ing["qty"]:
			return false
	return true


## Consomme les ingrédients pour 1 exemplaire. Retourne false si stock insuffisant.
func _consume_materials(material_id: String) -> bool:
	if not _can_consume(material_id):
		return false
	var mat : Dictionary = MaterialLibrary.get_material(material_id)
	for ing in mat.get("recipe", []):
		GameData.remove_item(ing["item_id"], ing["qty"])
	return true


func _get_or_create(key: String) -> Dictionary:
	if not _stations.has(key):
		_stations[key] = {"queue": [], "active": null, "progress": 0.0}
	return _stations[key]


func _key(object: Node2D) -> String:
	## Utilise la position en grille comme clé stable
	if object.has_method("get_origin"):
		var origin : Vector2i = object.get_origin()
		return "%d,%d" % [origin.x, origin.y]
	return str(object.get_instance_id())


func _get_queue_snapshot(key: String) -> Array:
	if not _stations.has(key):
		return []
	var result : Array = []
	var s : Dictionary = _stations[key]
	if s["active"] != null:
		result.append({
			"material_id":    s["active"]["material_id"],
			"qty":            s["active"]["qty_remaining"],
			"progress":       s["progress"],
			"is_active":      true,
		})
	for entry in s["queue"]:
		result.append({
			"material_id": entry["material_id"],
			"qty":         entry["qty"],
			"progress":    0.0,
			"is_active":   false,
		})
	return result


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var data : Dictionary = {}
	for key in _stations:
		data[key] = {
			"queue":    _stations[key]["queue"].duplicate(true),
			"active":   _stations[key]["active"].duplicate() if _stations[key]["active"] else null,
			"progress": _stations[key]["progress"],
		}
	return data


func deserialize(d: Dictionary) -> void:
	_stations.clear()
	for key in d:
		_stations[key] = {
			"queue":    d[key].get("queue", []),
			"active":   d[key].get("active", null),
			"progress": d[key].get("progress", 0.0),
		}
