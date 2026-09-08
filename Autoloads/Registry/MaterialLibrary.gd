## MaterialLibrary.gd — Autoload
## Registre de toutes les ressources/matériaux du jeu.
##
## Structure d'une entrée :
##   id              : String   — identifiant unique
##   label           : String   — nom affiché
##   description     : String
##   category        : String   — "natural" | "craftable" | "magical" | "mob_drop" | "culinary"
##   value           : int      — valeur de vente de base (en or)
##   texture         : String   — chemin icône (res://Assets/Resources/{id}.png)
##   recipe          : Array    — [{ "item_id": String, "qty": int }]  (vide si non craftable)
##   craft_location  : String   — objet de craft requis ("" si non craftable)
##   craft_time      : float    — durée en heures (0 si non craftable)
extends Node


var _materials : Dictionary = {}


func _ready() -> void:
	_register_natural()
	_register_craftable()
	_register_magical()
	_register_mob_drops()
	_register_culinary()


# ─────────────────────────────────────────────
#  RESSOURCES NATURELLES (brutes)
# ─────────────────────────────────────────────
func _register_natural() -> void:

	_raw("wood_log", "Bois", 2,
		"Utilisé pour les constructions basiques et armes simples.")


# ─────────────────────────────────────────────
#  MATÉRIAUX ARTISANAUX (craftables)
# ─────────────────────────────────────────────
func _register_craftable() -> void:
	pass


# ─────────────────────────────────────────────
#  MATÉRIAUX MAGIQUES & RARES
# ─────────────────────────────────────────────
func _register_magical() -> void:
	pass


# ─────────────────────────────────────────────
#  COMPOSANTS DE MONSTRES (mob drops)
# ─────────────────────────────────────────────
func _register_mob_drops() -> void:
	pass


# ─────────────────────────────────────────────
#  INGRÉDIENTS CULINAIRES
# ─────────────────────────────────────────────
func _register_culinary() -> void:
	pass


# ─────────────────────────────────────────────
#  HELPERS D'ENREGISTREMENT
# ─────────────────────────────────────────────

## Ressource naturelle brute
func _raw(id: String, label: String, value: int, description: String) -> void:
	_raw_cat(id, label, value, "natural", description)

## Ressource brute avec catégorie explicite
func _raw_cat(id: String, label: String, value: int, category: String, description: String) -> void:
	_add(id, label, description, category, value, [], "", 0.0)

## Drop de monstre (ou matériau magique)
func _mob(id: String, label: String, value: int, category: String, description: String) -> void:
	_add(id, label, description, category, value, [], "", 0.0)

## Matériau craftable
func _craft(id: String, label: String, value: int, craft_location: String,
		craft_time: float, description: String, recipe: Array) -> void:
	_add(id, label, description, "craftable", value, recipe, craft_location, craft_time)

## Ingrédient de recette
func _ing(item_id: String, qty: int) -> Dictionary:
	return {"item_id": item_id, "qty": qty}

func _add(id: String, label: String, description: String, category: String,
		value: int, recipe: Array, craft_location: String, craft_time: float) -> void:
	_materials[id] = {
		"id":             id,
		"label":          label,
		"description":    description,
		"category":       category,
		"value":          value,
		"texture":        "res://Assets/Resources/%s.png" % id,
		"recipe":         recipe,
		"craft_location": craft_location,
		"craft_time":     craft_time,
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_material(id: String) -> Dictionary:
	return _materials.get(id, {})

func get_all() -> Array:
	return _materials.values()

func get_by_category(category: String) -> Array:
	var result : Array = []
	for mat in _materials.values():
		if mat["category"] == category:
			result.append(mat)
	return result

## Vrai si le matériau est craftable (a une recette)
func is_craftable(id: String) -> bool:
	var mat : Dictionary = get_material(id)
	return not mat.is_empty() and not mat["recipe"].is_empty()

## Valeur de vente total d'un stack
func get_stack_value(id: String, qty: int) -> int:
	return get_material(id).get("value", 0) * qty

## Vérifie si un inventaire (Dictionary id→qty) contient les matériaux d'une recette
func can_craft(id: String, inventory: Dictionary) -> bool:
	var mat : Dictionary = get_material(id)
	if mat.is_empty() or mat["recipe"].is_empty():
		return false
	for ing in mat["recipe"]:
		if inventory.get(ing["item_id"], 0) < ing["qty"]:
			return false
	return true
