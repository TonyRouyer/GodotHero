## HeroRoutine.gd
## Composant de décision — système de score d'urgence.
##
## Principe :
##   Chaque action possible reçoit un score flottant (0–1+).
##   L'action avec le score le plus élevé l'emporte.
##   score_total = score_besoin + bonus_planning + modificateur_moral
##
## Anti-oscillation :
##   Une tâche en cours avec un objet reçoit CONTINUATION_BONUS (+0.45).
##   Un changement n'a lieu que si new_score > effective_current + HYSTERESIS.
##   Exception : score ≥ CRITICAL_BYPASS → contourne le bonus de continuation
##   (compare seulement score_brut_actuel + HYSTERESIS).
##
## Cible 100% :
##   Le héros continue un soin (manger, dormir…) jusqu'à ce que l'objet le libère (à 100%).
##   Le CONTINUATION_BONUS garantit qu'il faut un besoin vraiment urgent pour l'interrompre.
extends Node


# ─────────────────────────────────────────────
#  CONSTANTES ANTI-OSCILLATION
# ─────────────────────────────────────────────

## Bonus accordé à la tâche en cours quand le héros utilise un objet.
## Force les besoins concurrents à être nettement plus urgents pour interrompre.
const CONTINUATION_BONUS : float = 0.45

## Bonus minimal quand le héros est sur la même tâche sans objet (idle, wander…).
const CONTINUATION_IDLE  : float = 0.10

## Delta minimal requis pour changer de tâche (hors bypass).
const HYSTERESIS         : float = 0.20

## Score au-dessus duquel un besoin contourne le bonus de continuation.
## Compare seulement score_brut_actuel + HYSTERESIS.
const CRITICAL_BYPASS    : float = 0.75


# ─────────────────────────────────────────────
#  SEUILS DE SCORE PAR BESOIN
## Valeur en-dessous de laquelle le score passe de 0 vers 1.
## Plus le seuil est haut, plus le héros est proactif.
# ─────────────────────────────────────────────
const _SCORE_THRESH := {
	"sleep":  45.0,   ## héros cherche un lit quand énergie < ~28 (en temps libre)
	"eat":    45.0,   ## cherche à manger quand faim < ~28
	"toilet": 40.0,   ## toilettes quand < ~25
	"wash":   30.0,   ## hygiène quand < ~18
	"fun":    35.0,   ## divertissement quand < ~22
}


# ─────────────────────────────────────────────
#  ÉTATS MENTAUX
# ─────────────────────────────────────────────
enum MentalState {
	NORMAL,       ## > 75 moral  — comportement normal
	GRUMPY,       ## 50–75       — bonus travail × 0.5
	UNMOTIVATED,  ## 25–50       — ignore le planning travail/entraînement
	DEPRESSED,    ## < 25        — erre, ne fait rien d'utile
}


# ─────────────────────────────────────────────
#  RÉFÉRENCES
# ─────────────────────────────────────────────
@onready var hero     : Hero = get_parent()
@onready var activity : Node = %HeroActivity

var current_task         : Dictionary = {"type": "idle"}
var current_construction : Dictionary = {}


# ─────────────────────────────────────────────
#  VARIÉTÉ EN TEMPS LIBRE
## {activity_key → total_game_hours_at_last_use}
# ─────────────────────────────────────────────
var _activity_last_used : Dictionary = {}
const COOLDOWN_HOURS    : int        = 2


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.time_tick.connect(_on_time_tick)


func _exit_tree() -> void:
	if EventBus.time_tick.is_connected(_on_time_tick):
		EventBus.time_tick.disconnect(_on_time_tick)


# ─────────────────────────────────────────────
#  TICK
# ─────────────────────────────────────────────
func _on_time_tick(_hour: int, _minute: int) -> void:
	if not hero.data or hero.data.on_mission:
		return
	_update_routine()


func _update_routine() -> void:
	if hero.data.control_by_player:
		hero.set_activity_label("Joueur")
		return

	var scores    : Dictionary = _evaluate_all_scores()
	var best_type : String     = _pick_best(scores)

	## Même tâche — pas d'interruption
	if best_type == current_task.get("type", ""):
		return

	## Note l'heure pour les activités avec cooldown
	if best_type in ["idle_social", "fun"]:
		_activity_last_used[best_type] = _total_hours()

	current_task = {"type": best_type}
	hero.set_activity_label(best_type.capitalize())
	activity.perform(current_task)


# ─────────────────────────────────────────────
#  ÉVALUATION GLOBALE
# ─────────────────────────────────────────────
func _evaluate_all_scores() -> Dictionary:
	var data    : HeroData    = hero.data
	var hour    : int         = TimeManager.current_hour
	var planned : String      = data.planning.get(hour, "free")
	var mental  : MentalState = _get_mental_state(data.moral)

	## Héros déprimé : erre, ne travaille pas, peut dormir si vraiment épuisé
	if mental == MentalState.DEPRESSED:
		return {
			"idle":        0.30,
			"idle_social": _score_social(),
			"sleep":       _score_sleep(data, planned),
		}

	var mult   : float      = _work_multiplier(mental)
	var scores : Dictionary = {}

	## Besoins primaires
	scores["sleep"]  = _score_sleep  (data, planned)
	scores["eat"]    = _score_eat    (data)
	scores["toilet"] = _score_toilet (data)
	scores["wash"]   = _score_wash   (data)
	scores["fun"]    = _score_fun    (data)

	## Tâches productives
	scores["work"]      = _score_work     (data, planned, mult)
	scores["train"]     = _score_train    (data, planned, mult)
	scores["construct"] = _score_construct(data, mental,  planned)

	## Temps libre
	scores["idle_social"] = _score_social()
	scores["idle"]        = 0.05  ## Fallback toujours disponible

	return scores


# ─────────────────────────────────────────────
#  SÉLECTION DE LA MEILLEURE ACTION
# ─────────────────────────────────────────────
func _pick_best(scores: Dictionary) -> String:
	var current_type  : String = current_task.get("type", "idle")
	var current_score : float  = scores.get(current_type, 0.05)
	var has_object    : bool   = _current_has_object()

	## Score effectif de la tâche courante (avec bonus de continuation)
	var continuation : float = CONTINUATION_BONUS if has_object else CONTINUATION_IDLE
	var effective    : float = current_score + continuation

	var best_type  : String = current_type
	var best_score : float  = -1.0

	for action in scores:
		if action == current_type:
			continue
		var s : float = scores[action]
		if s <= 0.0:
			continue

		## Besoin critique : compare contre le score brut + HYSTERESIS seulement
		var threshold : float
		if s >= CRITICAL_BYPASS:
			threshold = current_score + HYSTERESIS
		else:
			threshold = effective + HYSTERESIS

		if s > threshold and s > best_score:
			best_score = s
			best_type  = action

	return best_type


# ─────────────────────────────────────────────
#  SCORES INDIVIDUELS
# ─────────────────────────────────────────────

## Formule de base : score monte de 0 à 1 quand la valeur descend sous le seuil.
func _need_score(value: float, threshold: float) -> float:
	return clamp((threshold - value) / threshold, 0.0, 1.0)


func _score_sleep(data: HeroData, planned: String) -> float:
	var s : float = _need_score(data.energy, _SCORE_THRESH["sleep"])
	if planned == "sleep":
		s += 0.60
	## Légère pénalité si pas de lit (dort au sol — moins désirable)
	if not ObjectFinder.object_available("bed"):
		s = max(0.0, s - 0.05)
	return s


func _score_eat(data: HeroData) -> float:
	if not ObjectFinder.object_available("serving_table"):
		return 0.0
	return _need_score(data.hunger, _SCORE_THRESH["eat"])


func _score_toilet(data: HeroData) -> float:
	if not ObjectFinder.object_available("toilet"):
		return 0.0
	return _need_score(data.toilet, _SCORE_THRESH["toilet"])


func _score_wash(data: HeroData) -> float:
	if not ObjectFinder.find_free_object_in_list(["sink", "shower", "bath"]):
		return 0.0
	return _need_score(data.hygiene, _SCORE_THRESH["wash"])


func _score_fun(data: HeroData) -> float:
	if not ObjectFinder.object_available("luth"):
		return 0.0
	var s : float = _need_score(data.entertainment, _SCORE_THRESH["fun"])
	## Cooldown : réduit fortement si récemment joué
	if _on_cooldown("fun"):
		s *= 0.15
	return s


func _score_work(data: HeroData, planned: String, mult: float) -> float:
	if mult <= 0.0:
		return 0.0
	var job_obj : String = GameConfig.JOB_OBJECTS.get(data.job, "")
	if job_obj == "" or not ObjectFinder.object_available(job_obj):
		return 0.0
	var s : float = 0.10
	if planned == "work":
		s += 0.55 * mult
	return s


func _score_train(data: HeroData, planned: String, mult: float) -> float:
	if mult <= 0.0:
		return 0.0
	## Vérifie qu'au moins un objet d'entraînement est disponible
	var has_obj : bool = false
	for p in _get_sorted_priorities(data):
		if ObjectFinder.object_available(p["object"]):
			has_obj = true
			break
	if not has_obj:
		return 0.0
	var s : float = 0.10
	if planned == "train":
		s += 0.50 * mult
	return s


func _score_construct(data: HeroData, mental: MentalState, planned: String) -> float:
	## Les héros démotivés ne construisent pas
	if mental == MentalState.UNMOTIVATED or mental == MentalState.DEPRESSED:
		return 0.0
	if not ConstructionManager.has_pending_tasks():
		return 0.0
	var s : float = 0.28
	## Bonus si la tâche planifiée est "work" mais que l'objet de job est absent
	## → la construction remplace le travail impossible
	if planned == "work":
		var job_obj : String = GameConfig.JOB_OBJECTS.get(data.job, "")
		if job_obj == "" or not ObjectFinder.object_available(job_obj):
			s += 0.25
	return s


func _score_social() -> float:
	## Pas de socialisation si seul dans la guilde
	if HeroManager.get_hero_count() <= 1:
		return 0.0
	var s : float = 0.12
	if _on_cooldown("idle_social"):
		s = 0.02
	return s


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

func _get_mental_state(moral: float) -> MentalState:
	if moral > 75.0: return MentalState.NORMAL
	if moral > 50.0: return MentalState.GRUMPY
	if moral > 25.0: return MentalState.UNMOTIVATED
	return MentalState.DEPRESSED


func _work_multiplier(mental: MentalState) -> float:
	match mental:
		MentalState.NORMAL:      return 1.0
		MentalState.GRUMPY:      return 0.5
		_:                       return 0.0


func _current_has_object() -> bool:
	return (
		(activity.used_object != null and is_instance_valid(activity.used_object))
		or activity.is_ground_sleeping
	)


func _on_cooldown(key: String) -> bool:
	return (_total_hours() - _activity_last_used.get(key, -9999)) < COOLDOWN_HOURS


func _total_hours() -> int:
	return GameData.current_day * 24 + TimeManager.current_hour


func _get_sorted_priorities(data: HeroData) -> Array[Dictionary]:
	var list : Array[Dictionary] = [
		{"object": "training_dummy", "priority": data.strength_priority},
		{"object": "anvil",          "priority": data.defense_priority},
		{"object": "tanning_rack",   "priority": data.agility_priority},
		{"object": "loom",           "priority": data.mana_priority},
	]
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["priority"] > b["priority"])
	return list
