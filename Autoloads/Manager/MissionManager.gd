## MissionManager — Autoload
## Gère la génération, l'assignation et la résolution des missions.
##
## Cycle de vie d'une mission :
##   1. Générée dans le pool "available" chaque jour / selon la réputation.
##   2. Le joueur assigne un héros → la mission devient "active".
##   3. Au retour (jour+heure prévus), la mission est résolue (succès/échec).
##   4. Récompenses distribuées, héros libéré.
extends Node


signal missions_changed


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────

## Missions affichées sur le tableau (dicts sérialisables).
var available : Array = []

## Missions en cours { "template_id", "hero_id", "return_day", "return_hour",
##                      "name", "difficulty", "gold", "reputation", "xp", "required_stat" }
var active : Array = []

## Mission jouable en attente de chargement de scène.
## Structure : { "mission_data": Dictionary, "hero_ids": Array }
var pending_playable_mission : Dictionary = {}

## Templates de missions (définis dans _build_templates).
var _templates : Array = []

var _hours_since_refresh : float = 0.0
const MAX_AVAILABLE     : int   = 4
const REFRESH_INTERVAL  : float = 20.0   ## heures in-game entre chaque tentative de refresh


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_build_templates()
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.day_changed.connect(_on_day_changed)
	## Génère une première fournée au lancement
	_try_refresh_missions()


func _exit_tree() -> void:
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)
	if EventBus.day_changed.is_connected(_on_day_changed):
		EventBus.day_changed.disconnect(_on_day_changed)


# ─────────────────────────────────────────────
#  TICK
# ─────────────────────────────────────────────
func _on_hour_changed(hour: int) -> void:
	_check_completions(hour)
	_hours_since_refresh += 1.0
	if _hours_since_refresh >= REFRESH_INTERVAL:
		_hours_since_refresh = 0.0
		_try_refresh_missions()


func _on_day_changed(_day: int) -> void:
	## Expire les missions disponibles trop vieilles (optionnel — pour l'instant on garde tout)
	pass


# ─────────────────────────────────────────────
#  GÉNÉRATION DE MISSIONS
# ─────────────────────────────────────────────

func _try_refresh_missions() -> void:
	## Nombre max selon la réputation (1 de base, +1 tous les 15 pts)
	var max_slots : int = min(MAX_AVAILABLE, 1 + int(GameData.reputation / 15.0))
	while available.size() < max_slots:
		var tpl : Dictionary = _pick_template()
		if tpl.is_empty():
			break
		available.append(tpl.duplicate())
	missions_changed.emit()


## Choisit un template en tenant compte de la réputation (missions plus dures si plus de rep).
func _pick_template() -> Dictionary:
	if _templates.is_empty():
		return {}
	## Filtre par difficulté accessible (1 à 2 + rep/20)
	var max_diff : int = min(5, 1 + int(GameData.reputation / 20.0) + randi() % 2)
	var eligible : Array = _templates.filter(func(t : Dictionary) -> bool:
		return t["difficulty"] <= max_diff
	)
	if eligible.is_empty():
		eligible = _templates
	return eligible[randi() % eligible.size()]


# ─────────────────────────────────────────────
#  ASSIGNATION
# ─────────────────────────────────────────────

## Assigne un héros à une mission disponible.
## Retourne false si le héros est déjà en mission ou si la mission n'existe pas.
func assign(template_id: String, hero_id: int) -> bool:
	var hero_data : HeroData = HeroManager.get_hero_data(hero_id)
	if hero_data == null or hero_data.on_mission:
		return false

	var tpl_idx : int = -1
	for i in available.size():
		if available[i].get("id", "") == template_id:
			tpl_idx = i
			break
	if tpl_idx < 0:
		return false

	var tpl : Dictionary = available[tpl_idx]
	available.remove_at(tpl_idx)

	## Calcule l'heure et le jour de retour
	var duration  : int = tpl.get("duration_hours", 4)
	var cur_hour  : int = TimeManager.current_hour
	var cur_day   : int = GameData.current_day
	var ret_hour  : int = cur_hour + duration
	var ret_day   : int = cur_day + ret_hour / 24
	ret_hour      = ret_hour % 24

	## Met le héros en état "en mission"
	hero_data.on_mission          = true
	hero_data.mission_return_day  = ret_day
	hero_data.mission_return_hour = ret_hour

	## Masque le héros dans le monde
	var hero_node : Hero = HeroManager.get_hero_node(hero_id)
	if hero_node:
		hero_node.visible = false
		hero_node.freeze_movement()

	## Enregistre la mission active
	active.append({
		"id":            template_id,
		"hero_id":       hero_id,
		"return_day":    ret_day,
		"return_hour":   ret_hour,
		"name":          tpl.get("name",          "Mission"),
		"difficulty":    tpl.get("difficulty",    1),
		"gold":          tpl.get("gold",          0),
		"reputation":    tpl.get("reputation",    0),
		"xp":            tpl.get("xp",            0),
		"required_stat": tpl.get("required_stat", "strength"),
	})

	EventBus.mission_started.emit(tpl)
	EventBus.ui_notification_requested.emit(
		"%s part en mission : %s" % [hero_data.hero_name, tpl.get("name", "")], "info"
	)
	missions_changed.emit()
	return true


## Assigne une party entière (mode auto-resolve) à une mission.
## Supprime la mission du pool available et envoie chaque héros.
func start_party_auto(mission_data: Dictionary, hero_ids: Array) -> void:
	## Retire la mission du pool available
	for i in available.size():
		if available[i].get("id", "") == mission_data.get("id", ""):
			available.remove_at(i)
			break

	var duration : int = mission_data.get("duration_hours", 4)
	var cur_hour : int = TimeManager.current_hour
	var cur_day  : int = GameData.current_day
	var ret_hour : int = (cur_hour + duration) % 24
	var ret_day  : int = cur_day + (cur_hour + duration) / 24

	for hero_id in hero_ids:
		var hero_data : HeroData = HeroManager.get_hero_data(hero_id)
		if hero_data == null or hero_data.on_mission:
			continue
		hero_data.on_mission          = true
		hero_data.mission_return_day  = ret_day
		hero_data.mission_return_hour = ret_hour
		var hero_node : Hero = HeroManager.get_hero_node(hero_id)
		if hero_node:
			hero_node.visible = false
			hero_node.freeze_movement()
		active.append({
			"id":            mission_data.get("id",            ""),
			"hero_id":       hero_id,
			"return_day":    ret_day,
			"return_hour":   ret_hour,
			"name":          mission_data.get("name",          "Mission"),
			"difficulty":    mission_data.get("difficulty",    1),
			"gold":          mission_data.get("gold",          0),
			"reputation":    mission_data.get("reputation",    0),
			"xp":            mission_data.get("xp",            0),
			"required_stat": mission_data.get("required_stat", "strength"),
		})
		EventBus.ui_notification_requested.emit(
			"%s part en mission : %s" % [hero_data.hero_name, mission_data.get("name","")], "info"
		)

	EventBus.mission_started.emit(mission_data)
	missions_changed.emit()


# ─────────────────────────────────────────────
#  RÉSOLUTION
# ─────────────────────────────────────────────

func _check_completions(current_hour: int) -> void:
	var current_day : int = GameData.current_day
	var to_resolve  : Array = []

	for entry in active:
		var is_ready : bool = (
			entry["return_day"] < current_day or
			(entry["return_day"] == current_day and entry["return_hour"] <= current_hour)
		)
		if is_ready:
			to_resolve.append(entry)

	for entry in to_resolve:
		active.erase(entry)
		_resolve(entry)

	if to_resolve.size() > 0:
		missions_changed.emit()


func _resolve(entry: Dictionary) -> void:
	var hero_id   : int      = entry.get("hero_id", -1)
	var hero_data : HeroData = HeroManager.get_hero_data(hero_id)
	if hero_data == null:
		return

	## Calcul du succès : stat du héros vs seuil de la mission
	var stat_name  : String = entry.get("required_stat", "strength")
	var stat_val   : float  = hero_data.get(stat_name)
	var difficulty : int    = entry.get("difficulty", 1)
	var threshold  : float  = difficulty * 15.0
	var chance     : float  = clamp((stat_val / threshold) * 70.0 + 15.0, 10.0, 95.0)
	var success    : bool   = randf_range(0.0, 100.0) < chance

	## Récompenses — GDD §8.3 : Or = Or_base × CR, CR = 1 + (Réputation / 100)
	if success:
		var cr      : float = 1.0 + GameData.reputation / 100.0
		var gold    : int   = int(entry.get("gold", 0) * cr)
		GameData.add_gold(gold)
		GameData.reputation += entry.get("reputation", 0)
		hero_data.xp        += entry.get("xp", 0)
		EventBus.ui_notification_requested.emit(
			"%s est de retour ! Mission réussie (+%d or, +%d réputation)" % [
				hero_data.hero_name, gold, entry.get("reputation", 0)
			], "success"
		)
	else:
		EventBus.ui_notification_requested.emit(
			"%s est de retour... Mission échouée." % hero_data.hero_name, "warning"
		)

	## Historique et rang
	hero_data.missions_last_20.append(success)
	if hero_data.missions_last_20.size() > 20:
		hero_data.missions_last_20 = hero_data.missions_last_20.slice(-20)
	_recalculate_rank(hero_data)

	## Libère le héros
	hero_data.on_mission          = false
	hero_data.mission_return_day  = -1
	hero_data.mission_return_hour = -1

	var hero_node : Hero = HeroManager.get_hero_node(hero_id)
	if hero_node:
		hero_node.visible = true
		hero_node.unfreeze_movement()
		## Effets moraux via HeroNeeds (table 6.2 : +10/12h succès, -10/10h échec).
		var needs : Node = hero_node.get_node_or_null("%HeroNeeds")
		if needs:
			if success:
				needs.add_timed_effect("Mission réussie", 10.0, 12)
			else:
				needs.add_timed_effect("Mission échouée", -10.0, 10)
			## Trait Mauvais Perdant : malus supplémentaire après un échec.
			if needs.has_method("apply_mission_result_traits"):
				needs.apply_mission_result_traits(success)

	EventBus.mission_completed.emit(null, success)
	missions_changed.emit()


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func _recalculate_rank(hero_data: HeroData) -> void:
	var total : int = hero_data.missions_last_20.size()
	if total < 5:
		hero_data.rank = "F"
		return
	var successes : int = 0
	for result in hero_data.missions_last_20:
		if result:
			successes += 1
	var rate : float = float(successes) / float(total)
	if   rate >= 0.90: hero_data.rank = "S"
	elif rate >= 0.78: hero_data.rank = "A"
	elif rate >= 0.65: hero_data.rank = "B"
	elif rate >= 0.50: hero_data.rank = "C"
	elif rate >= 0.35: hero_data.rank = "D"
	else:              hero_data.rank = "E"


func get_available() -> Array:
	return available.duplicate()


func get_active() -> Array:
	return active.duplicate()


## Retourne true si un héros est déjà assigné à une mission active.
func hero_is_on_mission(hero_id: int) -> bool:
	for entry in active:
		if entry["hero_id"] == hero_id:
			return true
	return false


# ─────────────────────────────────────────────
#  MISSIONS JOUABLES
# ─────────────────────────────────────────────

## Lance une mission en mode jouable (chargement de la scène de combat).
## mission_data : un dict de mission (depuis available ou un template direct).
## hero_ids     : liste d'IDs de héros envoyés en mission.
func start_playable_mission(mission_data: Dictionary, hero_ids: Array, player_hero_id: int = -1) -> void:
	pending_playable_mission = {
		"mission_data":   mission_data.duplicate(),
		"hero_ids":       hero_ids.duplicate(),
		"player_hero_id": player_hero_id,
	}
	## Met tous les héros en état "on_mission" pour bloquer la routine
	for hid in hero_ids:
		var hdata : HeroData = HeroManager.get_hero_data(hid)
		if hdata:
			hdata.on_mission = true
		var hnode : Node = HeroManager.get_hero_node(hid)
		if hnode and hnode.has_method("freeze_movement"):
			hnode.visible = false
			hnode.freeze_movement()
	## Charge la scène de mission
	get_tree().change_scene_to_file("res://Scenes/Mission/MissionScene.tscn")


func has_pending_playable() -> bool:
	return not pending_playable_mission.is_empty()


func consume_pending_playable() -> Dictionary:
	var data := pending_playable_mission.duplicate()
	pending_playable_mission.clear()
	return data


## Appelé par mission_scene à la fin du combat.
## hero_ids : liste d'IDs de héros participant.
## success  : true = victoire.
## gold/rep/xp : récompenses (0 en cas d'échec).
func resolve_playable_mission(hero_ids: Array, success: bool, gold: int, rep: int, xp: int) -> void:
	## Distribue les récompenses
	if success:
		GameData.add_gold(gold)
		GameData.reputation += rep

	for hid in hero_ids:
		var hdata : HeroData = HeroManager.get_hero_data(hid)
		if hdata == null:
			continue

		if success:
			hdata.xp += xp

		## Historique et rang
		hdata.missions_last_20.append(success)
		if hdata.missions_last_20.size() > 20:
			hdata.missions_last_20 = hdata.missions_last_20.slice(-20)
		_recalculate_rank(hdata)

		## Libère le héros
		hdata.on_mission          = false
		hdata.mission_return_day  = -1
		hdata.mission_return_hour = -1

		var hnode : Node = HeroManager.get_hero_node(hid)
		if is_instance_valid(hnode):
			hnode.visible = true
			if hnode.has_method("unfreeze_movement"):
				hnode.unfreeze_movement()
			var needs : Node = hnode.get_node_or_null("%HeroNeeds")
			if needs and needs.has_method("add_timed_effect"):
				if success:
					needs.add_timed_effect("Mission réussie", 10.0, 12)
				else:
					needs.add_timed_effect("Mission échouée", -10.0, 10)

	if success:
		EventBus.ui_notification_requested.emit(
			"Mission jouable réussie ! +%d or, +%d réputation" % [gold, rep], "success"
		)
	else:
		EventBus.ui_notification_requested.emit(
			"Mission jouable échouée.", "warning"
		)

	EventBus.mission_completed.emit(null, success)
	missions_changed.emit()


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────

func serialize() -> Dictionary:
	return {
		"available":            available.duplicate(true),
		"active":               active.duplicate(true),
		"hours_since_refresh":  _hours_since_refresh,
	}


func deserialize(data: Dictionary) -> void:
	available             = data.get("available",           [])
	active                = data.get("active",              [])
	_hours_since_refresh  = data.get("hours_since_refresh", 0.0)
	missions_changed.emit()


# ─────────────────────────────────────────────
#  TEMPLATES DE MISSIONS
# ─────────────────────────────────────────────

func _build_templates() -> void:
	_templates = [
		## ── Difficulté 1 ────────────────────────────────────────────────────
		{
			"id": "escort_merchants", "name": "Escorte de marchands",
			"description": "Protégez un convoi sur la route principale.",
			"difficulty": 1, "duration_hours": 4, "required_stat": "strength",
			"gold": 40, "reputation": 3, "xp": 80,
		},
		{
			"id": "bandit_patrol", "name": "Patrouille anti-brigands",
			"description": "Chassez les bandits du village voisin.",
			"difficulty": 1, "duration_hours": 3, "required_stat": "agility",
			"gold": 35, "reputation": 2, "xp": 60,
		},
		{
			"id": "lost_artifact", "name": "Objet perdu",
			"description": "Retrouvez l'héritage d'un noble.",
			"difficulty": 1, "duration_hours": 5, "required_stat": "luck",
			"gold": 50, "reputation": 3, "xp": 90,
		},
		## ── Difficulté 2 ────────────────────────────────────────────────────
		{
			"id": "crypt_cleaning", "name": "Nettoyage de crypte",
			"description": "Éliminez les morts-vivants qui infestent le mausolée.",
			"difficulty": 2, "duration_hours": 6, "required_stat": "defense",
			"gold": 80, "reputation": 5, "xp": 150,
		},
		{
			"id": "missing_child", "name": "Enfant disparu",
			"description": "Retrouvez l'enfant kidnappé par des gobelins.",
			"difficulty": 2, "duration_hours": 8, "required_stat": "agility",
			"gold": 100, "reputation": 7, "xp": 140,
		},
		{
			"id": "potion_delivery", "name": "Livraison urgente de potions",
			"description": "Traversez une zone dangereuse avec une cargaison précieuse.",
			"difficulty": 2, "duration_hours": 5, "required_stat": "strength",
			"gold": 70, "reputation": 4, "xp": 120,
		},
		## ── Difficulté 3 ────────────────────────────────────────────────────
		{
			"id": "night_infiltration", "name": "Infiltration nocturne",
			"description": "Pénétrez dans la forteresse ennemie sans être vu.",
			"difficulty": 3, "duration_hours": 8, "required_stat": "agility",
			"gold": 130, "reputation": 8, "xp": 200,
		},
		{
			"id": "cursed_forest", "name": "La forêt maudite",
			"description": "Brisez la malédiction qui empoisonne les terres environnantes.",
			"difficulty": 3, "duration_hours": 10, "required_stat": "magic",
			"gold": 150, "reputation": 10, "xp": 220,
		},
		{
			"id": "arena_champion", "name": "Champion de l'arène",
			"description": "Participez au tournoi de la ville et ramenez la gloire.",
			"difficulty": 3, "duration_hours": 6, "required_stat": "strength",
			"gold": 120, "reputation": 9, "xp": 180,
		},
		## ── Difficulté 4 ────────────────────────────────────────────────────
		{
			"id": "artifact_recovery", "name": "Récupération d'artefact",
			"description": "Un puissant artefact est gardé par des monstres anciens.",
			"difficulty": 4, "duration_hours": 12, "required_stat": "magic",
			"gold": 200, "reputation": 12, "xp": 280,
		},
		{
			"id": "assassin_hunt", "name": "Chasse à l'assassin",
			"description": "Traitez le contrat sur un tueur à gages insaisissable.",
			"difficulty": 4, "duration_hours": 10, "required_stat": "agility",
			"gold": 180, "reputation": 11, "xp": 260,
		},
		## ── Difficulté 5 ────────────────────────────────────────────────────
		{
			"id": "boss_fight", "name": "Combat de boss",
			"description": "Un dragon terrorise la région. Il faut l'arrêter.",
			"difficulty": 5, "duration_hours": 16, "required_stat": "strength",
			"gold": 300, "reputation": 20, "xp": 400,
		},
		{
			"id": "ancient_ritual", "name": "Rituel ancien",
			"description": "Invoquez et contrôlez une entité pour sauver la cité.",
			"difficulty": 5, "duration_hours": 12, "required_stat": "magic",
			"gold": 280, "reputation": 18, "xp": 380,
		},
	]
