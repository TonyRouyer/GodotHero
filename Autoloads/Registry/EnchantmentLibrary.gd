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
	var cost_c : Array = [
		{"item_id": "arcane_crystal", "qty": 2},
		{"item_id": "magic_ore",      "qty": 1},
	]

	_e("ench_acier_trempant", "Acier Trempant", "C",
		{"atk": 8},
		["weapon"],
		cost_c,
		"Trempe la lame dans un alliage arcanique. +8 ATK.")

	_e("ench_protection", "Protection", "C",
		{"def": 8},
		["armor"],
		cost_c,
		"Renforce la structure de l'armure. +8 DEF.")

	_e("ench_vitalite", "Vitalité", "C",
		{"hp": 15},
		["weapon", "armor", "accessory"],
		cost_c,
		"Infuse l'item d'une énergie vitale. +15 HP max.")

	_e("ench_mana_flux", "Flux de Mana", "C",
		{"mana": 12},
		["weapon", "armor", "accessory"],
		cost_c,
		"Canalisateur de flux magique. +12 MANA max.")

	_e("ench_rapidite", "Rapidité", "C",
		{"spd": 5},
		["weapon", "armor", "accessory"],
		cost_c,
		"Allège le poids de l'item. +5 SPD.")


# ─────────────────────────────────────────────
#  RANG B (5 enchantements)
# ─────────────────────────────────────────────
func _register_rank_b() -> void:
	var cost_b : Array = [
		{"item_id": "arcane_crystal", "qty": 3},
		{"item_id": "magic_ore",      "qty": 2},
	]

	_e("ench_frappe_vive", "Frappe Vive", "B",
		{"atk": 15, "spd": 5},
		["weapon"],
		cost_b,
		"Accélère la cadence d'attaque. +15 ATK, +5 SPD.")

	_e("ench_resistance_magique", "Résistance Magique", "B",
		{"mdef": 12},
		["armor"],
		cost_b,
		"Tisse un voile anti-magie dans l'armure. +12 MDEF.")

	_e("ench_vigueur", "Vigueur Suprême", "B",
		{"hp": 25},
		["weapon", "armor", "accessory"],
		cost_b,
		"Réserve de force vitale majeure. +25 HP max.")

	_e("ench_arcane", "Arcane", "B",
		{"matk": 12},
		["weapon", "accessory"],
		cost_b,
		"Charge l'item d'énergie arcanique pure. +12 MATK.")

	_e("ench_chance", "Chance du Héros", "B",
		{"crit": 8},
		["weapon", "armor", "accessory"],
		cost_b,
		"La fortune sourit à ce héros. +8 CRIT.")


# ─────────────────────────────────────────────
#  RANG A (5 enchantements)
# ─────────────────────────────────────────────
func _register_rank_a() -> void:
	var cost_a : Array = [
		{"item_id": "arcane_crystal", "qty": 5},
		{"item_id": "magic_ore",      "qty": 2},
		{"item_id": "magic_essence",  "qty": 1},
	]

	_e("ench_devastateur", "Dévastateur", "A",
		{"atk": 22},
		["weapon"],
		cost_a,
		"Une puissance dévastatrice gravée dans le métal. +22 ATK.")

	_e("ench_gardien", "Gardien", "A",
		{"def": 18, "hp": 15},
		["armor"],
		cost_a,
		"Le porteur devient un bastion imprenable. +18 DEF, +15 HP.")

	_e("ench_vitesse_lumiere", "Vitesse de la Lumière", "A",
		{"spd": 20},
		["weapon", "armor", "accessory"],
		cost_a,
		"Se déplace à la vitesse de la lumière. +20 SPD.")

	_e("ench_arcane_majeur", "Arcane Majeur", "A",
		{"matk": 20, "mana": 15},
		["weapon", "accessory"],
		cost_a,
		"Un condensé de magie brute. +20 MATK, +15 MANA.")

	_e("ench_critique_mortel", "Critique Mortel", "A",
		{"crit": 15},
		["weapon", "armor", "accessory"],
		cost_a,
		"Chaque coup porté peut être fatal. +15 CRIT.")


# ─────────────────────────────────────────────
#  RANG S (3 enchantements)
# ─────────────────────────────────────────────
func _register_rank_s() -> void:
	var cost_s : Array = [
		{"item_id": "arcane_crystal", "qty": 5},
		{"item_id": "magic_ore",      "qty": 3},
		{"item_id": "magic_essence",  "qty": 2},
	]

	_e("ench_legendaire_atk", "Légendaire: Attaque", "S",
		{"atk": 35, "crit": 10},
		["weapon"],
		cost_s,
		"Un enchantement de légende. +35 ATK, +10 CRIT.")

	_e("ench_legendaire_def", "Légendaire: Défense", "S",
		{"def": 28, "mdef": 28},
		["armor"],
		cost_s,
		"Un bouclier impénétrable. +28 DEF, +28 MDEF.")

	_e("ench_omnipuissant", "Omnipuissant", "S",
		{"atk": 15, "def": 15, "matk": 15, "mdef": 15},
		["weapon", "armor", "accessory"],
		cost_s,
		"La puissance absolue dans toutes ses formes. +15 à ATK, DEF, MATK, MDEF.")
