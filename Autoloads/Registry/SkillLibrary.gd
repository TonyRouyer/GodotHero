## SkillLibrary.gd — Autoload
## Registre de toutes les compétences des 6 classes de base.
##
## Structure d'une entrée :
##   id         : String   — identifiant unique
##   label      : String   — nom affiché
##   class_id   : String   — classe propriétaire
##   rank       : String   — rang minimum requis (F E D C B A S)
##   type       : String   — "active" | "passive"
##   description: String
##   cooldown   : float    — en secondes (0 si passif)
##   mana_cost  : int      — 0 pour les classes physiques
extends Node


const RANK_ORDER : Array[String] = ["F", "E", "D", "C", "B", "A", "S"]

var _skills : Dictionary = {}   # id → skill dict
var _by_class : Dictionary = {} # class_id → Array[id]

## Effets de combat des compétences passives.
## Clés possibles : atk_bonus_pct, dmg_reduction, crit_bonus,
##                  on_kill_heal_pct, mana_regen_mult, def_bonus_pct
const PASSIVE_COMBAT_EFFECTS : Dictionary = {}


func _ready() -> void:
	pass






# ─────────────────────────────────────────────
#  HELPERS D'ENREGISTREMENT
# ─────────────────────────────────────────────

## Active skill
func _a(id: String, label: String, class_id: String, rank: String,
		cooldown: float, mana_cost: int, description: String) -> void:
	_register(id, label, class_id, rank, "active", cooldown, mana_cost, description)

## Passive skill
func _p(id: String, label: String, class_id: String, rank: String,
		description: String) -> void:
	_register(id, label, class_id, rank, "passive", 0.0, 0, description)

func _register(id: String, label: String, class_id: String, rank: String,
		type: String, cooldown: float, mana_cost: int, description: String) -> void:
	_skills[id] = {
		"id":          id,
		"label":       label,
		"class_id":    class_id,
		"rank":        rank,
		"type":        type,
		"description": description,
		"cooldown":    cooldown,
		"mana_cost":   mana_cost,
	}
	if not _by_class.has(class_id):
		_by_class[class_id] = []
	_by_class[class_id].append(id)


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_skill(id: String) -> Dictionary:
	return _skills.get(id, {})

func get_passive_combat_effects(skill_id: String) -> Dictionary:
	return PASSIVE_COMBAT_EFFECTS.get(skill_id, {})

## Toutes les compétences d'une classe
func get_skills_for_class(class_id: String) -> Array:
	var ids : Array = _by_class.get(class_id, [])
	var result : Array = []
	for id in ids:
		result.append(_skills[id])
	return result

## Compétences d'une classe accessibles jusqu'à un rang donné (inclusif)
func get_skills_up_to_rank(class_id: String, hero_rank: String) -> Array:
	var max_idx : int = RANK_ORDER.find(hero_rank)
	if max_idx == -1:
		max_idx = 0
	var result : Array = []
	for skill in get_skills_for_class(class_id):
		var skill_idx : int = RANK_ORDER.find(skill["rank"])
		if skill_idx <= max_idx:
			result.append(skill)
	return result

## Compétences d'un rang exact pour une classe
func get_skills_at_rank(class_id: String, rank: String) -> Array:
	var result : Array = []
	for skill in get_skills_for_class(class_id):
		if skill["rank"] == rank:
			result.append(skill)
	return result
