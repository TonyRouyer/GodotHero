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
#  ARMES — ÉPÉES
# ─────────────────────────────────────────────
func _register_epees() -> void:
	_w("epee_entrainement", "Épée d'Entraînement", "epee", "F",
		{"atk": 3},
		[], 5,
		"Épée émoussée utilisée pour l'entraînement. Inoffensive mais pratique.")
	_w("epee_rouille", "Épée Rouillée", "epee", "F",
		{"atk": 5},
		[{"item_id": "iron_ore", "qty": 2}], 15,
		"Une vieille épée rongée par la rouille. Peu fiable mais mieux que rien.")


# ─────────────────────────────────────────────
#  ARMES — HACHES
# ─────────────────────────────────────────────
func _register_haches() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — LANCES
# ─────────────────────────────────────────────
func _register_lances() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — DAGUES
# ─────────────────────────────────────────────
func _register_daggers() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — MARTEAUX
# ─────────────────────────────────────────────
func _register_marteaux() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — BÂTONS
# ─────────────────────────────────────────────
func _register_batons() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — ARCS
# ─────────────────────────────────────────────
func _register_arcs() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — ORBES
# ─────────────────────────────────────────────
func _register_orbes() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — GRIMOIRES
# ─────────────────────────────────────────────
func _register_grimoires() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMES — SHURIKENS
# ─────────────────────────────────────────────
func _register_shurikens() -> void:
	pass


func _register_weapons() -> void:
	_register_epees()
	_register_haches()
	_register_lances()
	_register_daggers()
	_register_marteaux()
	_register_batons()
	_register_arcs()
	_register_orbes()
	_register_grimoires()
	_register_shurikens()


# ─────────────────────────────────────────────
#  ARMURES TORSE — LÉGÈRES (tissu/lin)
# ─────────────────────────────────────────────
func _register_armors_legeres() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES TORSE — MOYENNES (cuir)
# ─────────────────────────────────────────────
func _register_armors_moyennes() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES TORSE — LOURDES (métal)
# ─────────────────────────────────────────────
func _register_armors_lourdes() -> void:
	pass


func _register_armors() -> void:
	_register_armors_legeres()
	_register_armors_moyennes()
	_register_armors_lourdes()


# ─────────────────────────────────────────────
#  ARMURES TÊTE — LÉGÈRES
# ─────────────────────────────────────────────
func _register_armor_heads_legeres() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES TÊTE — MOYENNES
# ─────────────────────────────────────────────
func _register_armor_heads_moyennes() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES TÊTE — LOURDES
# ─────────────────────────────────────────────
func _register_armor_heads_lourdes() -> void:
	pass


func _register_armor_heads() -> void:
	_register_armor_heads_legeres()
	_register_armor_heads_moyennes()
	_register_armor_heads_lourdes()


# ─────────────────────────────────────────────
#  ARMURES JAMBES — LÉGÈRES
# ─────────────────────────────────────────────
func _register_armor_legs_legeres() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES JAMBES — MOYENNES
# ─────────────────────────────────────────────
func _register_armor_legs_moyennes() -> void:
	pass


# ─────────────────────────────────────────────
#  ARMURES JAMBES — LOURDES
# ─────────────────────────────────────────────
func _register_armor_legs_lourdes() -> void:
	pass


func _register_armor_legs() -> void:
	_register_armor_legs_legeres()
	_register_armor_legs_moyennes()
	_register_armor_legs_lourdes()


# ─────────────────────────────────────────────
#  ACCESSOIRES — ANNEAUX
# ─────────────────────────────────────────────
func _register_anneaux() -> void:
	pass


# ─────────────────────────────────────────────
#  ACCESSOIRES — AMULETTES
# ─────────────────────────────────────────────
func _register_amulettes() -> void:
	pass


func _register_accessories() -> void:
	_register_anneaux()
	_register_amulettes()


# ─────────────────────────────────────────────
#  CONSOMMABLES — POTIONS DE SOIN
# ─────────────────────────────────────────────
func _register_potions_soins() -> void:
	pass


# ─────────────────────────────────────────────
#  CONSOMMABLES — POTIONS MAGIQUES
# ─────────────────────────────────────────────
func _register_potions_magiques() -> void:
	pass


# ─────────────────────────────────────────────
#  CONSOMMABLES — POTIONS DÉFENSIVES
# ─────────────────────────────────────────────
func _register_potions_defensives() -> void:
	pass


# ─────────────────────────────────────────────
#  CONSOMMABLES — POTIONS OFFENSIVES
# ─────────────────────────────────────────────
func _register_potions_offensives() -> void:
	pass


# ─────────────────────────────────────────────
#  CONSOMMABLES — POTIONS SPÉCIALES / RARES
# ─────────────────────────────────────────────
func _register_potions_speciales() -> void:
	pass


func _register_consumables() -> void:
	_register_potions_soins()
	_register_potions_magiques()
	_register_potions_defensives()
	_register_potions_offensives()
	_register_potions_speciales()
