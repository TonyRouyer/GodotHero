## ResearchManager — Autoload
## Gère l'état des recherches et la progression de la recherche active.
## Une seule recherche peut être active à la fois ; les autres conservent leur progression.
extends Node


signal research_completed(research_id: String)
signal research_changed
signal active_research_changed(research_id: String)
signal research_progress_updated(research_id: String, progress: float, required: float)


var unlocked  : Array[String] = []
var active_id : String        = ""
var is_paused : bool          = false
var _progress : Dictionary    = {}   ## {id: float} — points accumulés par recherche
var _started  : Array[String] = []   ## ids dont l'or a déjà été déduit


# ─────────────────────────────────────────────
#  FORMULES
# ─────────────────────────────────────────────

## Points de recherche nécessaires pour compléter une recherche.
func points_required(r: ResearchData) -> float:
	return float(r.level) * float(GameConfig.RESEARCH_DIFFICULTY.get(r.level, r.level)) * 5.0


## Durée estimée en heures (avec 1 chercheur au niveau 0 de knowledge).
func estimated_hours(r: ResearchData) -> int:
	return int(ceil(points_required(r) / GameConfig.RESEARCH_POINTS_PER_HOUR))


# ─────────────────────────────────────────────
#  REQUÊTES
# ─────────────────────────────────────────────

func is_unlocked(id: String) -> bool:
	return id in unlocked


func is_active(id: String) -> bool:
	return active_id == id


func has_started(id: String) -> bool:
	return id in _started


func get_progress(id: String) -> float:
	return _progress.get(id, 0.0)


## Retourne true si tous les prérequis sont débloqués (et la recherche pas encore faite).
func can_start(id: String) -> bool:
	var def : ResearchData = ResearchLibrary.get_definition(id)
	if def == null or is_unlocked(id):
		return false
	for prereq in def.prerequisites:
		if not is_unlocked(prereq):
			return false
	return true


func missing_prerequisites(id: String) -> Array[String]:
	var def : ResearchData = ResearchLibrary.get_definition(id)
	if def == null:
		return []
	var missing : Array[String] = []
	for prereq in def.prerequisites:
		if not is_unlocked(prereq):
			missing.append(prereq)
	return missing


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────

## Démarre ou reprend une recherche.
## Déduit l'or seulement si la recherche n'a jamais été lancée.
## Retourne false si impossible (prérequis manquants ou or insuffisant).
func start_research(id: String) -> bool:
	if not can_start(id):
		return false
	## Déduit l'or si c'est la première fois que cette recherche est lancée
	if id not in _started:
		var def : ResearchData = ResearchLibrary.get_definition(id)
		if not GameData.spend_gold(def.cost):
			EventBus.ui_notification_requested.emit(
				"Pas assez d'or pour lancer « %s »." % def.label, "warning")
			return false
		_started.append(id)
	## Active cette recherche (l'ancienne perd juste son statut "active")
	active_id = id
	is_paused = false
	active_research_changed.emit(active_id)
	research_changed.emit()
	return true


func pause_research() -> void:
	if active_id == "":
		return
	is_paused = true
	research_changed.emit()


func resume_research() -> void:
	if active_id == "":
		return
	is_paused = false
	research_changed.emit()


## Appelée par HeroNeeds chaque heure quand un chercheur travaille.
func add_progress(points: float) -> void:
	if active_id == "" or is_paused:
		return
	var def : ResearchData = ResearchLibrary.get_definition(active_id)
	if def == null:
		return
	var required : float = points_required(def)
	_progress[active_id] = get_progress(active_id) + points
	research_progress_updated.emit(active_id, _progress[active_id], required)
	if _progress[active_id] >= required:
		_complete_active()


func _complete_active() -> void:
	var id := active_id
	active_id = ""
	is_paused = false
	if id not in unlocked:
		unlocked.append(id)
	var def : ResearchData = ResearchLibrary.get_definition(id)
	research_completed.emit(id)
	research_changed.emit()
	active_research_changed.emit("")
	EventBus.research_completed.emit(id)
	EventBus.ui_notification_requested.emit(
		"Recherche complétée : %s" % def.label, "success")


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────

func serialize() -> Dictionary:
	return {
		"unlocked":  unlocked.duplicate(),
		"active_id": active_id,
		"is_paused": is_paused,
		"progress":  _progress.duplicate(),
		"started":   _started.duplicate(),
	}


func deserialize(d: Dictionary) -> void:
	unlocked  = d.get("unlocked",  [])
	active_id = d.get("active_id", "")
	is_paused = d.get("is_paused", false)
	_progress = d.get("progress",  {})
	_started  = d.get("started",   [])
	research_changed.emit()
