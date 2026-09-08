## EnchantmentLibrary.gd — Autoload
## Registre des 18 enchantements d'équipement (rang C → S).
## Un enchantement par item, irréversible, coûte des matériaux.
## Gating par recherche dans ResearchManager.
##
## Structure d'une entrée :
##   id          : String        — identifiant unique
##   label       : String        — nom affiché
##   rank        : String        — C | B | A | S
##   stats       : Dictionary    — bonus de stats ajoutés à l'item (clés identiques à EquipmentLibrary)
##   compatible  : Array[String] — types d'équipement compatibles : "weapon"|"armor"|"accessory"
##   cost        : Array         — [{ "item_id": String, "qty": int }]
##   research    : String        — ID recherche requise
##   description : String
extends Node


var _enchantments : Dictionary = {}

## Mapping rang → recherche requise
const RANK_RESEARCH : Dictionary = {
	"C": "enchantement",
	"B": "enchantement_avance",
	"A": "enchantement_expert",
	"S": "enchantement_expert",
}


func _ready() -> void:
	_register_rank_c()
	_register_rank_b()
	_register_rank_a()
	_register_rank_s()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_enchantment(id: String) -> Dictionary:
	return _enchantments.get(id, {})


func get_all() -> Dictionary:
	return _enchantments


func get_by_rank(rank: String) -> Array:
	var result : Array = []
	for e in _enchantments.values():
		if e["rank"] == rank:
			result.append(e)
	return result


## Retourne les enchantements compatibles avec un type d'item donné ("weapon" | "armor" | "accessory")
func get_for_type(item_type: String) -> Array:
	var result : Array = []
	for e in _enchantments.values():
		if item_type in e["compatible"]:
			result.append(e)
	return result


## Retourne les enchantements disponibles (research débloquée) pour un type d'item
func get_available_for_type(item_type: String) -> Array:
	var result : Array = []
	for e in _enchantments.values():
		if not (item_type in e["compatible"]):
			continue
		var req : String = e.get("research", "")
		if req != "" and not ResearchManager.is_unlocked(req):
			continue
		## Accessoires : nécessitent la recherche bijoux en plus
		if item_type == "accessory" and not ResearchManager.is_unlocked("maitrise_enchantement_bijoux"):
			continue
		result.append(e)
	return result


## Vérifie si GuildInventoryManager contient les matériaux nécessaires
func can_afford(enchantment_id: String) -> bool:
	var e : Dictionary = get_enchantment(enchantment_id)
	if e.is_empty():
		return false
	for cost_entry in e.get("cost", []):
		var needed : int = cost_entry["qty"]
		var found  : int = 0
		for slot in GuildInventoryManager.slots:
			if slot != null and slot["item_id"] == cost_entry["item_id"]:
				found += slot["qty"]
		if found < needed:
			return false
	return true


## Consomme les matériaux dans GuildInventoryManager. Retourne false si insuffisant.
func consume_cost(enchantment_id: String) -> bool:
	if not can_afford(enchantment_id):
		return false
	var e : Dictionary = get_enchantment(enchantment_id)
	for cost_entry in e.get("cost", []):
		var remaining : int = cost_entry["qty"]
		for i in GuildInventoryManager.slots.size():
			var slot = GuildInventoryManager.slots[i]
			if slot == null or slot["item_id"] != cost_entry["item_id"]:
				continue
			var take : int = mini(remaining, slot["qty"])
			GuildInventoryManager.remove_from_slot(i, take)
			remaining -= take
			if remaining <= 0:
				break
	return true


# ─────────────────────────────────────────────
#  HELPER
# ─────────────────────────────────────────────
func _e(id: String, label: String, rank: String, stats: Dictionary,
		compatible: Array, cost: Array, desc: String) -> void:
	_enchantments[id] = {
		"id":          id,
		"label":       label,
		"rank":        rank,
		"stats":       stats,
		"compatible":  compatible,
		"cost":        cost,
		"research":    RANK_RESEARCH.get(rank, "enchantement"),
		"description": desc,
	}


# ─────────────────────────────────────────────
#  RANG C (5 enchantements)
# ─────────────────────────────────────────────
func _register_rank_c() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG B (5 enchantements)
# ─────────────────────────────────────────────
func _register_rank_b() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG A (5 enchantements)
# ─────────────────────────────────────────────
func _register_rank_a() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG S (3 enchantements)
# ─────────────────────────────────────────────
func _register_rank_s() -> void:
	pass
