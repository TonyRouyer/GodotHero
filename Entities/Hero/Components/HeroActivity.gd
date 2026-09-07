## HeroActivity.gd
## Composant d'exécution des tâches.
## Reçoit un Dictionary task depuis HeroRoutine et envoie le héros au bon objet.
## Gère aussi la libération d'objet quand on change de tâche.
extends Node


# ─────────────────────────────────────────────
#  RÉFÉRENCES
# ─────────────────────────────────────────────
@onready var hero      : Hero   = get_parent()
@onready var navigator : Node2D = %HeroNavigator
@onready var routine   : Node   = %HeroRoutine

var used_object        : Node2D = null
var is_ground_sleeping : bool   = false

## Anti-spam : une seule notif "dort au sol" par nuit
var _notified_ground_sleep : bool = false


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	navigator.navigation_finished.connect(_on_navigation_finished)
	navigator.path_failed.connect(_on_path_failed)
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.construction_task_failed.connect(_on_construction_task_cancelled)


func _exit_tree() -> void:
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)
	if EventBus.construction_task_failed.is_connected(_on_construction_task_cancelled):
		EventBus.construction_task_failed.disconnect(_on_construction_task_cancelled)


# ─────────────────────────────────────────────
#  EXÉCUTION
# ─────────────────────────────────────────────
func perform(task: Dictionary) -> void:
	_release_used_object()

	match task.get("type", "idle"):
		"sleep":     _sleep()
		"eat":       _eat()
		"work":      _work()
		"train":     _train()
		"toilet":    _toilet()
		"wash":      _wash()
		"fun":       _fun()
		"construct":    _construct()
		"idle_social":  _idle_social()
		"idle":         _idle()


func _release_used_object() -> void:
	if used_object != null and is_instance_valid(used_object):
		## Si c'est un poste de craft, libère le slot dans CraftManager
		if _is_craft_station(used_object):
			CraftManager.unregister_worker(used_object)
		used_object.exit(hero)
		used_object = null
	is_ground_sleeping = false
	_release_construction_task()


## Libère la tâche de construction en cours si elle n'est pas encore finalisée.
## Appelé à chaque changement de tâche pour garantir qu'aucune tâche ne reste
## bloquée en "assigned" si le héros abandonne en cours de route.
func _release_construction_task() -> void:
	if routine.current_construction.is_empty():
		return
	var hero_id : int = hero.data.hero_id if hero.data else -1
	EventBus.construction_task_failed.emit(routine.current_construction, hero_id)
	routine.current_construction = {}


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func _sleep() -> void:
	var bed : Node2D = ObjectFinder.find_free_object("bed")
	if bed:
		bed.used = true
		used_object = bed
		navigator.set_destination(bed.get_use_position())
		_notified_ground_sleep = false
	else:
		## Dort sur place — l'effet moral -7 est géré en CONSTANT par HeroNeeds._update_ground_sleep()
		is_ground_sleeping = true
		if not _notified_ground_sleep:
			_notified_ground_sleep = true
			EventBus.ui_notification_requested.emit(
				"%s dort sur le sol faute de lit !" % hero.data.hero_name, "warning"
			)


func _eat() -> void:
	var table : Node2D = ObjectFinder.find_free_object("serving_table")
	if table:
		table.used  = true
		used_object = table
		navigator.set_destination(table.get_use_position())
	else:
		_idle()


func _work() -> void:
	var craft_objects : Array = GameConfig.JOB_CRAFT_OBJECTS.get(hero.data.job, [])
	if craft_objects.is_empty():
		_idle()
		return
	var obj : Node2D = ObjectFinder.find_free_object_in_list(craft_objects)
	if obj:
		obj.used    = true
		used_object = obj
		navigator.set_destination(obj.get_use_position())
	else:
		_idle()


func _train() -> void:
	var priorities : Array[Dictionary] = _get_sorted_training_priorities()
	for p in priorities:
		var obj : Node2D = ObjectFinder.find_free_object(p["object"])
		if obj:
			obj.used    = true
			used_object = obj
			navigator.set_destination(obj.get_use_position())
			return
	_idle()


func _toilet() -> void:
	var obj : Node2D = ObjectFinder.find_free_object("toilet")
	if obj:
		obj.used    = true
		used_object = obj
		navigator.set_destination(obj.get_use_position())
	else:
		_idle()


func _wash() -> void:
	var obj : Node2D = ObjectFinder.find_free_object_in_list(["sink", "shower", "bath"])
	if obj:
		obj.used    = true
		used_object = obj
		navigator.set_destination(obj.get_use_position())
	else:
		_idle()


func _fun() -> void:
	var obj : Node2D = ObjectFinder.find_free_object("luth")
	if obj:
		obj.used    = true
		used_object = obj
		navigator.set_destination(obj.get_use_position())
	else:
		_idle()


func _construct() -> void:
	var task : Dictionary = ConstructionManager.claim_nearest_task(
		hero.global_position, hero.data.hero_id
	)
	if task.is_empty():
		## Plus aucune tâche disponible — laisse HeroRoutine reprendre le contrôle
		routine.current_task = {"type": "idle"}
		_idle()
		return

	routine.current_construction = task
	var dest : Vector2 = _find_adjacent_dest(task)
	navigator.set_arrival_distance(2.0)
	navigator.set_destination(dest)
	hero.set_activity_label("Construit")


func _find_adjacent_dest(task: Dictionary) -> Vector2:
	## Cherche la case adjacente au chantier la plus proche du héros,
	## qui ne soit pas un mur ni un objet placé.
	var origin : Vector2i = task.get("origin", Vector2i.ZERO)
	var size   : Vector2  = task.get("size", Vector2.ONE)
	var tile   : int      = GameConfig.TILE_SIZE

	## Génère toutes les cases adjacentes au périmètre du chantier
	var candidates : Array[Vector2i] = []
	for x in range(-1, int(size.x) + 1):
		for y in range(-1, int(size.y) + 1):
			## Garde uniquement le périmètre (pas l'intérieur)
			if x >= 0 and x < int(size.x) and y >= 0 and y < int(size.y):
				continue
			candidates.append(origin + Vector2i(x, y))

	## Filtre les cases occupées par un mur ou un objet
	var free_candidates : Array[Vector2i] = []
	for c in candidates:
		if not GameData.walls.has(c) and not ConstructionManager.placed_objects.has(c):
			free_candidates.append(c)

	if free_candidates.is_empty():
		## Fallback : case à droite du chantier quoi qu'il arrive
		return Vector2(origin.x + int(size.x), origin.y) * tile + Vector2(tile * 0.5, tile * 0.5)

	## Choisit la case libre la plus proche du héros
	var best : Vector2i = free_candidates[0]
	var best_dist : float = hero.global_position.distance_to(Vector2(best) * tile)
	for c in free_candidates:
		var dist : float = hero.global_position.distance_to(Vector2(c) * tile)
		if dist < best_dist:
			best_dist = dist
			best = c

	## Centre de la case en coordonnées monde
	return Vector2(best) * tile + Vector2(tile * 0.5, tile * 0.5)


func _idle_social() -> void:
	var target : Node2D = _find_social_target()
	if not target:
		_idle()
		return
	var offset : Vector2 = Vector2(randi_range(-24, 24), randi_range(-8, 8))
	navigator.set_destination(target.global_position + offset)


func _find_social_target() -> Node2D:
	var heroes_container : Node2D = WorldContext.heroes_container
	if not heroes_container:
		return null
	var best      : Node2D = null
	var best_dist : float  = INF
	for other in heroes_container.get_children():
		if other == hero or not other.is_in_group("heroes"):
			continue
		if other.data and other.data.on_mission:
			continue
		var d : float = hero.global_position.distance_to(other.global_position)
		if d < best_dist:
			best_dist = d
			best      = other
	return best


func _idle() -> void:
	var nav    : NavigationAgent2D = navigator.nav
	var origin : Vector2 = hero.global_position
	var tile   : int = GameConfig.TILE_SIZE

	for _i in range(20):
		var offset : Vector2 = Vector2(
			(randi() % 21 - 10) * tile,
			(randi() % 21 - 10) * tile
		)
		nav.target_position = origin + offset
		await get_tree().process_frame
		if nav.is_target_reachable():
			return

	nav.target_position = origin


# ─────────────────────────────────────────────
#  CALLBACKS NAVIGATION
# ─────────────────────────────────────────────
func _on_navigation_finished() -> void:
	if used_object != null and is_instance_valid(used_object):
		used_object.use(hero)
		## Enregistre dans CraftManager si c'est un poste de craft (jobs 2 et 3)
		if _is_craft_station(used_object):
			CraftManager.register_worker(used_object, hero)
		return

	var task : Dictionary = routine.current_construction
	if task.is_empty():
		return

	## Restaure la distance d'arrêt normale
	navigator.set_arrival_distance(4.0)

	## Vérifie la proximité : le héros doit être sur une case adjacente au chantier
	var origin_tile  : Vector2i = task.get("origin", Vector2i.ZERO)
	var size         : Vector2  = task.get("size", Vector2.ONE)
	var tile         : float    = GameConfig.TILE_SIZE
	var hero_tile    : Vector2i = Vector2i(hero.global_position / tile)

	var is_adjacent  : bool = false
	for x in range(-1, int(size.x) + 1):
		for y in range(-1, int(size.y) + 1):
			if x >= 0 and x < int(size.x) and y >= 0 and y < int(size.y):
				continue
			if hero_tile == origin_tile + Vector2i(x, y):
				is_adjacent = true
				break
		if is_adjacent:
			break

	if not is_adjacent:
		## Réessaie de naviguer vers une case plus proche
		var dest : Vector2 = _find_adjacent_dest(task)
		navigator.set_arrival_distance(2.0)
		navigator.set_destination(dest)
		return

	## Le héros est en place — attend 1 seconde (animation de travail) puis finalise
	hero.set_activity_label("Construit...")
	await get_tree().create_timer(1.0).timeout

	## Vérifie que le héros et la tâche sont toujours valides après l'attente.
	## routine.current_construction peut avoir été vidé si HeroRoutine a interrompu
	## pendant le timer (besoin urgent) — dans ce cas la tâche a déjà été libérée.
	if not is_instance_valid(hero) or not hero.data:
		return
	if routine.current_construction.is_empty():
		return

	_finish_construction_task()


func _finish_construction_task() -> void:
	## Recule le héros AVANT que la collision du mur/objet n'apparaisse.
	_push_hero_away_from_construction(routine.current_construction)
	## Stop net : vide destination pour que _on_navigation_map_changed
	## ne re-navigue pas vers l'ancienne position du chantier pendant les awaits.
	navigator.stop()
	EventBus.construction_task_completed.emit(routine.current_construction)
	routine.current_construction = {}
	## Attend 2 frames : nav mesh rebuild + navigation_map_changed se propagent
	## avant de réclamer la prochaine tâche (évite de naviguer avec l'ancien mesh).
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(hero) or not hero.data:
		return
	_construct()


## Éloigne le héros de la zone de construction avant que la collision n'apparaisse.
## Ne fait rien pour les sols (pas de collision statique).
## Vérifie que la destination n'est pas à l'intérieur d'un mur déjà posé.
func _push_hero_away_from_construction(task: Dictionary) -> void:
	## Murs et sols : le héros est déjà adjacent, la physique gère la dépénétration.
	if task.get("type", "") in ["floor", "wall"]:
		return

	var tile_sz  : int      = GameConfig.TILE_SIZE
	var origin   : Vector2i = task.get("origin", Vector2i.ZERO)
	var size     : Vector2  = task.get("size", Vector2.ONE)

	var center    : Vector2 = (Vector2(origin) + size * 0.5) * tile_sz
	var dir       : Vector2 = (hero.global_position - center).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN

	var half_size : float = max(size.x, size.y) * 0.5 * tile_sz
	var safe_dist : float = half_size + tile_sz * 1.5

	if hero.global_position.distance_to(center) >= safe_dist:
		return

	var target     : Vector2  = center + dir * safe_dist
	var target_tile : Vector2i = Vector2i(target / tile_sz)

	## Ne téléporte pas si la destination atterrit dans un mur existant.
	## Dans ce cas on essaie la direction opposée, puis on renonce.
	if GameData.walls.has(target_tile):
		var alt : Vector2 = center + (-dir) * safe_dist
		var alt_tile : Vector2i = Vector2i(alt / tile_sz)
		if not GameData.walls.has(alt_tile):
			target = alt
		else:
			return  ## Aucune direction libre — la physique gèrera la dépénétration
	hero.global_position = target


func _on_path_failed() -> void:
	navigator.stop()
	var task : Dictionary = routine.current_construction

	if not task.is_empty():
		EventBus.construction_task_failed.emit(task, hero.data.hero_id)
		routine.current_construction = {}

	routine.current_task = {"type": "idle"}
	hero.set_activity_label("Idle")


# ─────────────────────────────────────────────
#  CALLBACK — TÂCHE ANNULÉE EXTERNEMENT
# ─────────────────────────────────────────────

## Appelé quand une tâche de construction est annulée (vente ou déplacement d'objet).
## Libère current_construction si ce héros était l'assigné.
func _on_construction_task_cancelled(task: Dictionary, hero_id: int) -> void:
	if not hero.data:
		return
	if hero_id != hero.data.hero_id:
		return
	if routine.current_construction.get("id", -1) != task.get("id", -2):
		return
	routine.current_construction = {}
	## Force le héros à stopper et réévaluer sa routine au prochain tick.
	navigator.stop()
	routine.current_task = {"type": "idle"}


# ─────────────────────────────────────────────
#  RESET ANTI-SPAM NUIT
# ─────────────────────────────────────────────
func _on_hour_changed(hour: int) -> void:
	## Réinitialise le flag "dort au sol" au lever du jour
	if hour == 6:
		_notified_ground_sleep = false


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
## Retourne true si cet objet est un poste de craft géré par CraftManager.
func _is_craft_station(obj: Node2D) -> bool:
	if obj == null or not ("object_id" in obj):
		return false
	return obj.object_id in GameConfig.CRAFT_STATION_IDS


func _get_sorted_training_priorities() -> Array[Dictionary]:
	var data : HeroData = hero.data
	## Chaque stat peut utiliser plusieurs objets (fallback si l'objet principal est occupé).
	## FOR : mannequin de combat / haltères
	## DEF : sacs de sable
	## AGI : séchoir / cible en bois
	## MAG : métier à tisser / bureau enchanté
	var list : Array[Dictionary] = [
		{"object": "training_dummy", "priority": data.strength_priority},
		{"object": "weights",        "priority": data.strength_priority},
		{"object": "sandbags",       "priority": data.defense_priority},
		{"object": "tanning_rack",   "priority": data.agility_priority},
		{"object": "wooden_target",  "priority": data.agility_priority},
		{"object": "loom",           "priority": data.mana_priority},
		{"object": "enchanted_desk", "priority": data.mana_priority},
	]
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["priority"] > b["priority"])
	return list
