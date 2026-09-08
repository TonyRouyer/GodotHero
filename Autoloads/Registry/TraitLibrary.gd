## TraitLibrary.gd — Autoload
## Définit les 42 traits de héros (21 positifs + 21 négatifs) selon le GDD §5.3.
##
## ── Clés d'effets supportées ──────────────────────────────────────────────────
##   stat_bonus             : Dictionary  { stat: float }    bonus flat aux stats
##   need_mult              : Dictionary  { need: float }    multiplicateur dégradation besoin
##   sleep_mult             : float       multiplicateur récupération énergie pendant sommeil
##   xp_mult                : float       multiplicateur XP global
##   work_speed_mult        : float       multiplicateur vitesse de travail (XP prod)
##   hp_mult                : float       multiplicateur PV max
##   moral_constant         : float       modificateur moral constant par tick
##   moral_amplifier        : float       amplifie TOUS les effets moraux (+ et −)
##   max_positive_moral     : float       plafond d'un seul effet moral positif
##   moral_cap              : float       plafond moral global (défaut 100)
##   moral_floor            : float       plancher moral global (défaut 0)
##   day_moral_bonus        : float       bonus moral temporaire ajouté chaque début de jour
##   quit_threshold         : float       seuil moral déclenchant les vérifs de démission
##   unpaid_quit_days       : int         jours sans salaire avant départ forcé
##   craft_fail_chance      : float       (futur CraftManager) — prob. d'échec partiel craft
##   mission_creature_mult  : float       (futur MissionManager) — bonus missions créatures
extends Node


var _traits : Dictionary = {}


func _ready() -> void:
	_register_positive()
	_register_negative()


# ─────────────────────────────────────────────
#  REGISTRATION
# ─────────────────────────────────────────────
func _add(id: String, label: String, desc: String, positive: bool, effects: Dictionary) -> void:
	_traits[id] = {
		"id": id, "label": label, "description": desc, "positive": positive, "effects": effects,
	}


func _register_positive() -> void:
	pass


func _register_negative() -> void:
	pass


# ─────────────────────────────────────────────
#  ACCESSEURS SIMPLES
# ─────────────────────────────────────────────
func get_trait(id: String) -> Dictionary:
	return _traits.get(id, {})

func get_label(id: String) -> String:
	return _traits.get(id, {}).get("label", id)

func get_description(id: String) -> String:
	return _traits.get(id, {}).get("description", "")

func is_positive(id: String) -> bool:
	return _traits.get(id, {}).get("positive", true)

func get_all() -> Array:
	return _traits.values()


# ─────────────────────────────────────────────
#  HELPERS AGRÉGÉS — appelés depuis HeroData / HeroNeeds
# ─────────────────────────────────────────────

## Bonus flat à une stat (somme de tous les traits).
func get_stat_bonus(traits: Array, stat: String) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("stat_bonus", {}).get(stat, 0.0)
	return total


## Multiplicateur dégradation d'un besoin (produit de tous les traits).
func get_need_mult(traits: Array, need: String) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("need_mult", {}).get(need, 1.0)
	return mult


## Multiplicateur récupération énergie pendant le sommeil.
func get_sleep_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("sleep_mult", 1.0)
	return mult


## Multiplicateur XP global.
func get_xp_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("xp_mult", 1.0)
	return mult


## Multiplicateur vitesse de travail / production.
func get_work_speed_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("work_speed_mult", 1.0)
	return mult


## Multiplicateur PV max.
func get_hp_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("hp_mult", 1.0)
	return mult


## Modificateur moral constant (somme).
func get_moral_constants(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("moral_constant", 0.0)
	return total


## Amplificateur de tous les effets moraux (produit — ex : 1.5 pour instable).
func get_moral_amplifier(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("moral_amplifier", 1.0)
	return mult


## Multiplicateur sur les effets moraux NÉGATIFS uniquement (ex : 0.5 pour stoïque).
func get_neg_moral_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("neg_moral_mult", 1.0)
	return mult


## Plafond d'un effet moral positif unique (le plus bas l'emporte).
func get_max_positive_moral(traits: Array) -> float:
	var cap : float = INF
	for id in traits:
		var v : float = _traits.get(id, {}).get("effects", {}).get("max_positive_moral", INF)
		cap = minf(cap, v)
	return cap


## Plafond moral global (le plus bas l'emporte).
func get_moral_cap(traits: Array) -> float:
	var cap : float = 100.0
	for id in traits:
		var c : float = _traits.get(id, {}).get("effects", {}).get("moral_cap", 100.0)
		cap = minf(cap, c)
	return cap


## Plancher moral global (le plus haut l'emporte).
func get_moral_floor(traits: Array) -> float:
	var floor_val : float = 0.0
	for id in traits:
		var f : float = _traits.get(id, {}).get("effects", {}).get("moral_floor", 0.0)
		floor_val = maxf(floor_val, f)
	return floor_val


## Bonus moral temporaire ajouté chaque début de journée (somme).
func get_day_moral_bonus(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("day_moral_bonus", 0.0)
	return total


## Seuil moral déclenchant les vérifications de démission (le plus haut l'emporte).
func get_quit_threshold(traits: Array) -> float:
	var threshold : float = 5.0
	for id in traits:
		var t : float = _traits.get(id, {}).get("effects", {}).get("quit_threshold", 5.0)
		threshold = maxf(threshold, t)
	return threshold


## Jours sans salaire avant départ forcé (le plus haut l'emporte).
func get_unpaid_quit_days(traits: Array) -> int:
	var days : int = 7
	for id in traits:
		var d : int = _traits.get(id, {}).get("effects", {}).get("unpaid_quit_days", 7)
		days = maxi(days, d)
	return days


## Malus moral supplémentaire après une mission échouée (somme, valeur négative).
func get_extra_fail_moral(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("extra_fail_moral", 0.0)
	return total
