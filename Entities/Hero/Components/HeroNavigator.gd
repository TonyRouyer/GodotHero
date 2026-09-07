## HeroNavigator.gd
## Composant de navigation. Responsabilités :
##   - Suivre un chemin via NavigationAgent2D
##   - Appliquer la vitesse (base + bonus agilité)
##   - Notifier quand la destination est atteinte
##   - Gérer les chemins non atteignables
extends Node2D


signal navigation_finished()
signal path_failed()


@onready var hero  : Hero             = get_parent()
@onready var nav   : NavigationAgent2D = %NavigationAgent2D

var destination : Vector2 = Vector2.ZERO

## Détection de blocage
var _stuck_timer    : float  = 0.0
var _last_position  : Vector2 = Vector2.ZERO
const STUCK_CHECK_INTERVAL : float = 0.8   ## secondes entre deux vérifications
const STUCK_MIN_MOVE       : float = 3.0   ## pixels minimum attendus sur l'intervalle


func _ready() -> void:
	nav.navigation_finished.connect(_on_navigation_finished)
	nav.velocity_computed.connect(_on_velocity_computed)
	EventBus.navigation_map_changed.connect(_on_navigation_map_changed)


# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if nav.is_navigation_finished():
		hero.velocity = Vector2.ZERO
		_stuck_timer   = 0.0
		_last_position = hero.global_position
		return

	var pos      = hero.global_position
	var next_pos = nav.get_next_path_position()
	var speed    = _get_speed()

	var new_velocity = pos.direction_to(next_pos) * speed

	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

	## Détection de blocage : si le héros n'a pas bougé assez sur l'intervalle,
	## on force un recalcul du chemin vers la même destination.
	_stuck_timer += delta
	if _stuck_timer >= STUCK_CHECK_INTERVAL:
		var moved : float = hero.global_position.distance_to(_last_position)
		_last_position = hero.global_position
		_stuck_timer   = 0.0
		if moved < STUCK_MIN_MOVE:
			nav.target_position = destination


func _get_speed() -> float:
	if not hero.data:
		return GameConfig.HERO_BASE_SPEED
	return hero.data.get_speed() * TimeManager.current_speed


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────
func set_destination(pos: Vector2) -> void:
	destination = pos
	nav.target_position = pos

	## Vérification immédiate de l'atteignabilité
	## (on attend 1 frame pour que l'agent calcule)
	await get_tree().process_frame
	if not nav.is_target_reachable():
		path_failed.emit()


func set_arrival_distance(distance: float) -> void:
	nav.target_desired_distance = distance


func stop() -> void:
	destination        = hero.global_position
	nav.target_position = hero.global_position
	hero.velocity      = Vector2.ZERO


func is_finished() -> bool:
	return nav.is_navigation_finished()


func get_adjacent_reachable_position(target_pos: Vector2) -> Vector2:
	## Cherche la première position adjacente atteignable autour de target_pos
	var offsets = [
		Vector2(16, 0), Vector2(-16, 0),
		Vector2(0, 16),  Vector2(0, -16),
		Vector2(16, 16),  Vector2(-16, -16),
		Vector2(16, -16), Vector2(-16, 16),
	]
	for offset in offsets:
		var check = target_pos + offset
		nav.target_position = check
		await get_tree().process_frame
		if nav.is_target_reachable():
			return check
	return target_pos


# ─────────────────────────────────────────────
#  CALLBACKS
# ─────────────────────────────────────────────
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	hero.velocity = safe_velocity


func _on_navigation_finished() -> void:
	hero.velocity = Vector2.ZERO
	navigation_finished.emit()


## Quand le nav mesh change, recalcule le chemin après 1 frame
## (le nouveau mesh doit être actif dans NavigationServer avant de requêter).
func _on_navigation_map_changed() -> void:
	if nav.is_navigation_finished():
		return
	await get_tree().process_frame
	if is_instance_valid(self) and not nav.is_navigation_finished():
		nav.target_position = destination


func _exit_tree() -> void:
	if EventBus.navigation_map_changed.is_connected(_on_navigation_map_changed):
		EventBus.navigation_map_changed.disconnect(_on_navigation_map_changed)


# ─────────────────────────────────────────────
#  DIRECTION (pour l'animateur)
# ─────────────────────────────────────────────
func get_move_direction() -> Vector2:
	if nav.is_navigation_finished():
		return Vector2.ZERO
	return (nav.get_next_path_position() - hero.global_position).normalized()
