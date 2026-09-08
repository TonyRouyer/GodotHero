## MobLibrary.gd — Autoload
## Registre de tous les mobs du jeu.
##
## Structure d'un mob :
##   id             : String
##   label          : String
##   rank           : String           — F E D C B A S
##   description    : String
##   threat_factor  : float            — 0.0–1.0 (poids en mission)
##   speed          : float            — px/s
##   stats          : { strength, defense, agility, magic, luck }
##   drops          : Array[{ item_id, min, max, rare }]
##   attacks.basic  : { label, description, power, aoe, aoe_radius, effect }
##   attacks.special: { label, description, power, aoe, aoe_radius, effect }
##
## Structure d'un effect (null si aucun) :
##   type     : String  — voir constantes EFFECT_*
##   value    : float   — force de l'effet (%, dégâts/s, unités…)
##   duration : float   — durée en secondes
##   chance   : float   — probabilité d'application (0.0–1.0)
##   target   : String  — "target" | "self" | "allies" | "aoe"
extends Node


# ─────────────────────────────────────────────
#  CONSTANTES EFFETS
# ─────────────────────────────────────────────
const EFFECT_POISON     : String = "poison"        # dégâts/s
const EFFECT_BURN       : String = "burn"          # dégâts feu/s
const EFFECT_STUN       : String = "stun"          # immobilise
const EFFECT_SLOW       : String = "slow"          # réduit vitesse (%)
const EFFECT_FEAR       : String = "fear"          # fuite
const EFFECT_KNOCKBACK  : String = "knockback"     # repousse
const EFFECT_SILENCE    : String = "silence"       # bloque les skills
const EFFECT_DEBUFF_DEF : String = "debuff_defense"
const EFFECT_DEBUFF_AGI : String = "debuff_agility"
const EFFECT_DEBUFF_STR : String = "debuff_strength"
const EFFECT_DEBUFF_MAG : String = "debuff_magic"
const EFFECT_BUFF_AGI   : String = "buff_agility"
const EFFECT_BUFF_DEF   : String = "buff_defense"
const EFFECT_BUFF_STR   : String = "buff_strength"
const EFFECT_LIFESTEAL  : String = "lifesteal"     # soigne % des dégâts infligés
const EFFECT_HEAL_ALLIES: String = "heal_allies"   # soigne alliés (%)
const EFFECT_MANA_DRAIN : String = "mana_drain"    # vole % mana


var _mobs : Dictionary = {}


func _ready() -> void:
	_register_f_mobs()
	_register_e_mobs()
	_register_d_mobs()
	_register_c_mobs()
	_register_b_mobs()
	_register_a_mobs()
	_register_s_mobs()


# ─────────────────────────────────────────────
#  RANG F
# ─────────────────────────────────────────────
func _register_f_mobs() -> void:

	_add("slime", "Slime", "F",
		"Petite créature gélatineuse inoffensive seule, mais gênante en groupe.",
		0.10, 100.0,
		_stats(3, 4, 6, 1, 5),
		[_drop("slime_gel", 1, 1), _drop("arcane_crystal", 1, 1, true)],
		_atk("Coup gluant",   "Le slime bondit pour heurter l'ennemi.", 4),
		_atk("Charge instable", "S'écrase sur l'ennemi, infligeant de légers dégâts de zone.", 3,
			true, 30.0)
	)



# ─────────────────────────────────────────────
#  RANG E
# ─────────────────────────────────────────────
func _register_e_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG D
# ─────────────────────────────────────────────
func _register_d_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG C
# ─────────────────────────────────────────────
func _register_c_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG B
# ─────────────────────────────────────────────
func _register_b_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG A
# ─────────────────────────────────────────────
func _register_a_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  RANG S
# ─────────────────────────────────────────────
func _register_s_mobs() -> void:
	pass


# ─────────────────────────────────────────────
#  HELPERS DE CONSTRUCTION
# ─────────────────────────────────────────────

func _stats(strength: int, def: int, agi: int, mag: int, lck: int) -> Dictionary:
	return {"strength": strength, "defense": def, "agility": agi, "magic": mag, "luck": lck}

func _drop(item_id: String, min_qty: int, max_qty: int, rare: bool = false) -> Dictionary:
	return {"item_id": item_id, "min": min_qty, "max": max_qty, "rare": rare}

func _fx(type: String, value: float, duration: float,
		chance: float = 1.0, target: String = "target") -> Dictionary:
	return {"type": type, "value": value, "duration": duration, "chance": chance, "target": target}

func _atk(label: String, description: String, power: int,
		aoe: bool = false, aoe_radius: float = 0.0, effect = null) -> Dictionary:
	return {
		"label":       label,
		"description": description,
		"power":       power,
		"aoe":         aoe,
		"aoe_radius":  aoe_radius,
		"effect":      effect,
	}

func _add(id: String, label: String, rank: String, description: String,
		threat_factor: float, speed: float,
		stats: Dictionary, drops: Array,
		basic_attack: Dictionary, special_attack: Dictionary) -> void:
	_mobs[id] = {
		"id":            id,
		"label":         label,
		"rank":          rank,
		"description":   description,
		"threat_factor": threat_factor,
		"speed":         speed,
		"stats":         stats,
		"drops":         drops,
		"attacks": {
			"basic":   basic_attack,
			"special": special_attack,
		},
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_mob(id: String) -> Dictionary:
	return _mobs.get(id, {})

func get_all_mobs() -> Array:
	return _mobs.values()

func get_mobs_by_rank(rank: String) -> Array:
	var result : Array = []
	for mob in _mobs.values():
		if mob["rank"] == rank:
			result.append(mob)
	return result

## PV_max calculé selon la même formule que les héros
func get_hp_max(id: String) -> float:
	var mob : Dictionary = get_mob(id)
	if mob.is_empty():
		return 0.0
	var s : Dictionary = mob["stats"]
	return 100.0 + (s["strength"] * 2.0) + (s["defense"] * 1.5)

## Retourne tous les drops non-rares d'un mob
func roll_drops(id: String, rng: RandomNumberGenerator = null) -> Array:
	var mob : Dictionary = get_mob(id)
	if mob.is_empty():
		return []
	var result : Array = []
	for drop in mob["drops"]:
		if drop["rare"]:
			continue
		var qty : int
		if rng:
			qty = rng.randi_range(drop["min"], drop["max"])
		else:
			qty = randi_range(drop["min"], drop["max"])
		result.append({"item_id": drop["item_id"], "qty": qty})
	return result
