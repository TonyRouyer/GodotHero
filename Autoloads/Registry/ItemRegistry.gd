## ItemRegistry.gd — Autoload #9
## Registre centralisé de tous les items plaçables dans la guilde :
## murs, sols, objets utilisables.
##
## Champs communs à chaque item :
##   id               : String  — identifiant unique
##   label            : String  — nom affiché dans l'UI
##   type             : String  — "wall" | "door" | "floor" | "object"
##   cost             : int     — coût en or
##   texture          : String  — chemin vers la texture (res://Assets/…)
##   region           : Rect2   — région dans l'atlas
##   unlock_research  : String  — id de recherche requise ("" = disponible dès le début)
##
## Champs spécifiques aux murs/sols :
##   atlas_id         : int     — couche dans le TileSet
##   size             : Vector2 — toujours Vector2.ONE
##
## Champs spécifiques aux objets :
##   job              : int     — job héros associé (0 = pas de job requis)
##   size             : Vector2 — taille en tuiles
##   room             : String  — salle de destination (pour le tri UI)
extends Node


# ─────────────────────────────────────────────
#  DONNÉES
# ─────────────────────────────────────────────
var walls   : Dictionary = {}
var floors  : Dictionary = {}
var objects : Dictionary = {}


func _ready() -> void:
	_build_registry()


func _build_registry() -> void:
	_register_murs_sols()
	_register_hall()
	_register_chambre()
	_register_forge()
	_register_couture()
	_register_atelier()
	_register_infirmerie()
	_register_entrainement()
	_register_alchimie()
	_register_arcanum()
	_register_jardin()
	_register_ascension()
	_register_loisirs()
	_register_sanitaires()
	_register_cuisine()
	_register_decoratif()


# ── MURS / SOLS / PORTES (7) ──────────────────────────────────────────────────
func _register_murs_sols() -> void:
	pass


# ── HALL (6) ──────────────────────────────────────────────────────────────────
func _register_hall() -> void:
	pass


# ── CHAMBRE (3) ───────────────────────────────────────────────────────────────
func _register_chambre() -> void:
	pass


# ── FORGE (5) ─────────────────────────────────────────────────────────────────
func _register_forge() -> void:
	pass


# ── COUTURE (6) ───────────────────────────────────────────────────────────────
func _register_couture() -> void:
	pass


# ── ATELIER (3) ───────────────────────────────────────────────────────────────
func _register_atelier() -> void:
	pass


# ── INFIRMERIE (3) ────────────────────────────────────────────────────────────
func _register_infirmerie() -> void:
	pass


# ── ENTRAÎNEMENT (4) ──────────────────────────────────────────────────────────
func _register_entrainement() -> void:
	pass


# ── ALCHIMIE (2) ──────────────────────────────────────────────────────────────
func _register_alchimie() -> void:
	pass


# ── ARCANUM (5) ───────────────────────────────────────────────────────────────
func _register_arcanum() -> void:
	pass


# ── JARDIN (3) ────────────────────────────────────────────────────────────────
func _register_jardin() -> void:
	pass


# ── SALLE D'ASCENSION (3) ─────────────────────────────────────────────────────
func _register_ascension() -> void:
	pass


# ── LOISIRS (3) ───────────────────────────────────────────────────────────────
func _register_loisirs() -> void:
	pass


# ── SANITAIRES (2) ────────────────────────────────────────────────────────────
func _register_sanitaires() -> void:
	pass


# ── CUISINE (4) ───────────────────────────────────────────────────────────────
func _register_cuisine() -> void:
	pass


# ── DÉCORATIF (5) ─────────────────────────────────────────────────────────────
func _register_decoratif() -> void:
	pass


# ─────────────────────────────────────────────
#  HELPERS D'AJOUT
# ─────────────────────────────────────────────

func _add_wall(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	walls[id] = {
		"id": id, "label": label, "type": "wall",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_door(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	walls[id] = {
		"id": id, "label": label, "type": "door",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_floor(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	floors[id] = {
		"id": id, "label": label, "type": "floor",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_object(id: String, label: String, cost: int, size: Vector2, job: int,
				 texture: String, region: Rect2, unlock: String = "", room: String = "") -> void:
	objects[id] = {
		"id": id, "label": label, "type": "object",
		"cost": cost, "texture": texture, "region": region,
		"size": size, "job": job,
		"unlock_research": unlock, "room": room,
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_all_walls()   -> Dictionary: return walls
func get_all_floors()  -> Dictionary: return floors
func get_all_objects() -> Dictionary: return objects

func get_item(id: String) -> Dictionary:
	if walls.has(id):   return walls[id]
	if floors.has(id):  return floors[id]
	if objects.has(id): return objects[id]
	return {}

## Retourne tous les objets d'une salle donnée.
func get_objects_for_room(room: String) -> Array:
	var result : Array = []
	for obj in objects.values():
		if obj["room"] == room:
			result.append(obj)
	return result

## Retourne les objets accessibles (unlock vide ou recherche débloquée).
func get_available_objects() -> Array:
	var result : Array = []
	for obj in objects.values():
		var unlock : String = obj.get("unlock_research", "")
		if unlock == "" or ResearchManager.is_unlocked(unlock):
			result.append(obj)
	return result

## Retourne les objets liés à un job (pour affichage UI du job).
func get_objects_for_job(job_id: int) -> Array:
	var result : Array = []
	for obj in objects.values():
		if obj["job"] == job_id:
			result.append(obj)
	return result
