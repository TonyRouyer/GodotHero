## DishLibrary.gd — Autoload
## Registre des 11 recettes de cuisine produites au fourneau.
## Les plats restaurent la faim et accordent un buff temporaire au héros.
##
## Structure d'une entrée :
##   id           : String        — identifiant unique (utilisé dans GuildInventoryManager)
##   label        : String        — nom affiché
##   satiety      : float         — points de faim restaurés (0–100)
##   buff         : Dictionary    — { "stat": String, "value": float, "duration_days": float }
##                                  stat : "strength"|"defense"|"agility"|"magic"|"luck"|"moral"
##   recipe       : Array         — [{ "item_id": String, "qty": int }]  (ingrédients GuildInventory)
##   cook_time    : float         — secondes de cuisson réels (à GameConfig.COOK_SPEED)
##   price        : int           — valeur en or si vendu
##   description  : String
extends Node


var _dishes : Dictionary = {}


func _ready() -> void:
	_register_dishes()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_dish(id: String) -> Dictionary:
	return _dishes.get(id, {})


func get_all() -> Dictionary:
	return _dishes


func get_all_list() -> Array:
	return _dishes.values()


# ─────────────────────────────────────────────
#  HELPER
# ─────────────────────────────────────────────
func _d(id: String, label: String, satiety: float, buff: Dictionary,
		recipe: Array, cook_time: float, price: int, desc: String) -> void:
	_dishes[id] = {
		"id":          id,
		"label":       label,
		"satiety":     satiety,
		"buff":        buff,
		"recipe":      recipe,
		"cook_time":   cook_time,
		"price":       price,
		"description": desc,
	}


# ─────────────────────────────────────────────
#  RECETTES (11 plats)
# ─────────────────────────────────────────────
func _register_dishes() -> void:
	pass
