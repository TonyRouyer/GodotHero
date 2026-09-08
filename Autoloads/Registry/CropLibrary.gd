## CropLibrary.gd — Autoload
## Registre des 8 cultures disponibles dans les planting_beds.
## Temps de pousse en jours de jeu (GameConfig.DAY_DURATION).
##
## Structure :
##   id            : String  — identifiant unique
##   label         : String  — nom affiché
##   growth_days   : float   — jours de jeu nécessaires à maturité
##   yield_id      : String  — ID matériau produit (dans MaterialLibrary ou DishLibrary ingrédients)
##   yield_qty     : int     — quantité produite à la récolte
##   seed_cost_id  : String  — ID item pour planter (graine, bouture…) — "" si aucun coût
##   seed_cost_qty : int     — quantité de graine nécessaire
##   price         : int     — valeur de la récolte en or
##   description   : String
extends Node


var _crops : Dictionary = {}


func _ready() -> void:
	_register_crops()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_crop(id: String) -> Dictionary:
	return _crops.get(id, {})


func get_all() -> Dictionary:
	return _crops


func get_all_list() -> Array:
	return _crops.values()


# ─────────────────────────────────────────────
#  HELPER
# ─────────────────────────────────────────────
func _c(id: String, label: String, growth_days: float, yield_id: String, yield_qty: int,
		seed_cost_id: String, seed_cost_qty: int, price: int, desc: String) -> void:
	_crops[id] = {
		"id":            id,
		"label":         label,
		"growth_days":   growth_days,
		"yield_id":      yield_id,
		"yield_qty":     yield_qty,
		"seed_cost_id":  seed_cost_id,
		"seed_cost_qty": seed_cost_qty,
		"price":         price,
		"description":   desc,
	}


# ─────────────────────────────────────────────
#  CULTURES (8)
# ─────────────────────────────────────────────
func _register_crops() -> void:
	pass
