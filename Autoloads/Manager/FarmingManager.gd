## FarmingManager.gd — Autoload
## Gère la plantation, la croissance et la récolte des cultures dans les planting_beds.
## Les beds sont identifiés par leur position de grille (Vector2i).
##
## État d'un bed :
##   { "crop_id": String, "planted_day": int, "planted_hour": int, "ready": bool }
extends Node


signal bed_updated(grid_pos: Vector2i)
signal harvest_ready(grid_pos: Vector2i, crop_id: String)


## { Vector2i → { "crop_id", "planted_day", "planted_hour", "ready" } }
var beds : Dictionary = {}


func _ready() -> void:
	EventBus.day_changed.connect(_on_day_changed)


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

## Plante une culture dans un bed libre. Retourne false si occupé.
func plant(grid_pos: Vector2i, crop_id: String) -> bool:
	if beds.has(grid_pos):
		return false   ## Bed déjà occupé
	var crop : Dictionary = CropLibrary.get_crop(crop_id)
	if crop.is_empty():
		push_warning("FarmingManager.plant: culture inconnue '%s'" % crop_id)
		return false
	beds[grid_pos] = {
		"crop_id":     crop_id,
		"planted_day": TimeManager.current_day,
		"planted_hour": TimeManager.current_hour,
		"ready":       false,
	}
	bed_updated.emit(grid_pos)
	return true


## Récolte un bed prêt. Retourne {} si non prêt ou vide.
func harvest(grid_pos: Vector2i) -> Dictionary:
	if not beds.has(grid_pos):
		return {}
	var bed : Dictionary = beds[grid_pos]
	if not bed["ready"]:
		return {}
	var crop : Dictionary = CropLibrary.get_crop(bed["crop_id"])
	beds.erase(grid_pos)
	bed_updated.emit(grid_pos)
	## Ajoute le rendement à l'inventaire de la guilde
	if not crop.is_empty():
		GuildInventoryManager.add_item(crop["yield_id"], crop["yield_qty"])
	return crop


## Retourne true si le bed est planté et prêt à récolter.
func is_ready(grid_pos: Vector2i) -> bool:
	return beds.get(grid_pos, {}).get("ready", false)


## Retourne true si le bed est planté (prêt ou en croissance).
func is_planted(grid_pos: Vector2i) -> bool:
	return beds.has(grid_pos)


## Retourne l'état d'un bed, ou {} si vide.
func get_bed(grid_pos: Vector2i) -> Dictionary:
	return beds.get(grid_pos, {})


## Progrès de croissance (0.0–1.0) pour affichage.
func get_growth_progress(grid_pos: Vector2i) -> float:
	var bed : Dictionary = beds.get(grid_pos, {})
	if bed.is_empty():
		return 0.0
	if bed["ready"]:
		return 1.0
	var crop : Dictionary = CropLibrary.get_crop(bed["crop_id"])
	if crop.is_empty():
		return 0.0
	var growth_days : float = crop["growth_days"]
	var elapsed     : float = float(TimeManager.current_day - bed["planted_day"])
	return clampf(elapsed / growth_days, 0.0, 1.0)


# ─────────────────────────────────────────────
#  TICK JOURNALIER
# ─────────────────────────────────────────────
func _on_day_changed(new_day: int) -> void:
	for pos : Vector2i in beds.keys():
		var bed  : Dictionary = beds[pos]
		if bed["ready"]:
			continue
		var crop : Dictionary = CropLibrary.get_crop(bed["crop_id"])
		if crop.is_empty():
			continue
		var elapsed     : float = float(new_day - bed["planted_day"])
		if elapsed >= crop["growth_days"]:
			bed["ready"] = true
			beds[pos] = bed
			bed_updated.emit(pos)
			harvest_ready.emit(pos, bed["crop_id"])


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var data : Dictionary = {}
	for pos : Vector2i in beds:
		var key : String = "%d,%d" % [pos.x, pos.y]
		data[key] = beds[pos].duplicate()
	return data


func deserialize(data: Dictionary) -> void:
	beds.clear()
	for key : String in data:
		var parts : PackedStringArray = key.split(",")
		if parts.size() != 2:
			continue
		var pos : Vector2i = Vector2i(int(parts[0]), int(parts[1]))
		beds[pos] = data[key]
