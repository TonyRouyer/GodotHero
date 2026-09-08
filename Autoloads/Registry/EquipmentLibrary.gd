## EquipmentLibrary.gd — Autoload
## Registre de tous les équipements : armes, armures, accessoires, consommables.
##
## Structure d'une entrée :
##   id            : String        — identifiant unique
##   label         : String        — nom affiché
##   type          : String        — "weapon" | "armor" | "accessory" | "consumable"
##   subtype       : String        — catégorie (ex: "epee", "lourde", "anneau", "potion_soin")
##   rank          : String        — F E D C B A S
##   stats         : Dictionary    — bonus de stats appliqués au héros
##   effects       : Array         — effets spéciaux (consommables / enchantements)
##   recipe        : Array         — [{ "item_id": String, "qty": int }]
##   craft_location: String        — lieu de craft ("forge", "atelier", "alchimie", "")
##   price         : int           — valeur en or
##   description   : String
##
## Types de stats pour "stats" :
##   "atk"       : bonus dégâts physiques
##   "matk"      : bonus dégâts magiques
##   "def"       : bonus défense physique
##   "mdef"      : bonus défense magique
##   "spd"       : bonus vitesse
##   "crit"      : bonus critique (%)
##   "hp"        : bonus HP max
##   "mana"      : bonus mana max
extends Node


var _items : Dictionary = {}


func _ready() -> void:
	_register_weapons()
	_register_armors()
	_register_armor_heads()
	_register_armor_legs()
	_register_accessories()
	_register_consumables()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_item(item_id: String) -> Dictionary:
	return _items.get(item_id, {})


func get_all() -> Dictionary:
	return _items


func get_by_type(type: String) -> Array:
	var result : Array = []
	for id in _items:
		if _items[id]["type"] == type:
			result.append(_items[id])
	return result


func get_by_subtype(subtype: String) -> Array:
	var result : Array = []
	for id in _items:
		if _items[id]["subtype"] == subtype:
			result.append(_items[id])
	return result


func get_weapons_for_class(weapon_types: Array) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "weapon" and item["subtype"] in weapon_types:
			result.append(item)
	return result


func get_armors_for_class(armor_type: String) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "armor" and item["subtype"] == armor_type:
			result.append(item)
	return result


## Retourne les armures filtrées par poids ET slot (head | torso | legs)
func get_armors_for_slot(armor_type: String, slot: String) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "armor" and item["subtype"] == armor_type and item.get("slot", "") == slot:
			result.append(item)
	return result


func is_craftable(item_id: String) -> bool:
	var item : Dictionary = get_item(item_id)
	return not item.is_empty() and not item.get("recipe", []).is_empty()


func get_rank_index(rank: String) -> int:
	match rank:
		"F": return 0
		"E": return 1
		"D": return 2
		"C": return 3
		"B": return 4
		"A": return 5
		"S": return 6
	return 0


# ─────────────────────────────────────────────
#  INTERNAL HELPERS
# ─────────────────────────────────────────────

func _add(id: String, label: String, type: String, subtype: String, rank: String,
		stats: Dictionary, effects: Array, recipe: Array, craft_location: String,
		price: int, description: String) -> void:
	_items[id] = {
		"id":             id,
		"label":          label,
		"type":           type,
		"subtype":        subtype,
		"slot":           "",   ## utilisé par les armures : "head" | "torso" | "legs"
		"rank":           rank,
		"stats":          stats,
		"effects":        effects,
		"recipe":         recipe,
		"craft_location": craft_location,
		"price":          price,
		"description":    description,
	}


func _w(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "weapon", subtype, rank, stats, [], recipe, "forge", price, desc)


## Armure torse (les existantes)
func _a(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "armor", subtype, rank, stats, [], recipe, "forge", price, desc)
	_items[id]["slot"] = "torso"


## Armure avec slot explicite (tête / torse / jambes)
func _ah(id: String, label: String, subtype: String, slot: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "armor", subtype, rank, stats, [], recipe, "forge", price, desc)
	_items[id]["slot"] = slot


func _acc(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "accessory", subtype, rank, stats, [], recipe, "forge", price, desc)


func _cons(id: String, label: String, subtype: String, stats: Dictionary,
		effects: Array, recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "consumable", subtype, "F", stats, effects, recipe, "alchimie", price, desc)


# ─────────────────────────────────────────────
#  ARMES
# ─────────────────────────────────────────────
func _register_weapons() -> void:

	_w("epee_rouille", "Épée Rouillée", "epee", "F",
		{"atk": 5},
		[{"item_id": "iron_ore", "qty": 2}], 15,
		"Une vieille épée rongée par la rouille. Peu fiable mais mieux que rien.")


# ─────────────────────────────────────────────
#  ARMURES
# ─────────────────────────────────────────────
func _register_armors() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES — TÊTES
# ─────────────────────────────────────────────
func _register_armor_heads() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES — JAMBES
# ─────────────────────────────────────────────
func _register_armor_legs() -> void:
	pass


# ─────────────────────────────────────────────
#  ACCESSOIRES
# ─────────────────────────────────────────────
func _register_accessories() -> void:
	pass


# ─────────────────────────────────────────────
#  CONSOMMABLES
# ─────────────────────────────────────────────
func _register_consumables() -> void:
	pass
