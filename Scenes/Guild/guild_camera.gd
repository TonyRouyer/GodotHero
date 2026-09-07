## guild_camera.gd
## Caméra de la GuildScene. Reprend l'existant (zoom, pan clavier, clic-drag)
## en ajoutant : limites de la carte, désactivation pendant les menus, focus héros.
extends Camera2D


@export var zoom_speed   : float = 10.0
@export var zoom_min     : Vector2 = Vector2(0.9, 0.9)
@export var zoom_max     : Vector2 = Vector2(5.0, 5.0)
@export var pan_speed    : float = 1000.0

## Limites de la carte en pixels 
@export var map_min      : Vector2 = Vector2(0, 0)
@export var map_max      : Vector2 = Vector2(1920, 1080)

var _zoom_target     : Vector2 = Vector2(2, 2)
var _drag_start_mouse : Vector2 = Vector2.ZERO
var _drag_start_cam   : Vector2 = Vector2.ZERO
var _is_dragging      : bool = false


func _ready() -> void:
	zoom = Vector2(2, 2)
	_zoom_target = zoom
	global_position = Vector2(0, 0)
	_apply_limits()

	if Engine.has_singleton("SettingsManager"):
		pan_speed = SettingsManager.get_value("camera_speed")
		SettingsManager.display_changed.connect(_on_display_changed)

	## Restaure position/zoom si on revient depuis les options
	GameData.restore_camera_state(self)
	_zoom_target = zoom

	EventBus.camera_focus_requested.connect(focus_on)


func _on_display_changed() -> void:
	## Après un changement de mode fenêtre, on attend que Godot ait
	## fini de recréer/reconfigurer la fenêtre (peut prendre 2-3 frames)
	## avant de forcer le focus clavier.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	## get_viewport() retourne le viewport courant (potentiellement recréé)
	var vp := get_viewport()
	if vp:
		vp.grab_focus()


func _process(delta: float) -> void:
	# Bloqué si un menu est ouvert (mais pas la pause — la pause gère elle-même)
	if UIState.menu_open:
		return

	_handle_zoom(delta)
	_handle_pan(delta)
	_handle_drag()


# ─────────────────────────────────────────────
#  ZOOM
# ─────────────────────────────────────────────
func _handle_zoom(delta: float) -> void:
	if Input.is_action_just_pressed("camera_zoom_in"):
		_zoom_target *= 1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		_zoom_target *= 0.9

	_zoom_target.x = clamp(_zoom_target.x, zoom_min.x, zoom_max.x)
	_zoom_target.y = clamp(_zoom_target.y, zoom_min.y, zoom_max.y)
	zoom = zoom.slerp(_zoom_target, zoom_speed * delta)


# ─────────────────────────────────────────────
#  PAN CLAVIER
# ─────────────────────────────────────────────
func _handle_pan(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("camera_move_right"): dir.x += 1
	if Input.is_action_pressed("camera_move_left"):  dir.x -= 1
	if Input.is_action_pressed("camera_move_down"):  dir.y += 1
	if Input.is_action_pressed("camera_move_up"):    dir.y -= 1

	#Limite la position de la camera pour ne pas la deplacer hros zone
	if global_position.x < map_min.x : global_position.x = map_min.x
	if global_position.x > map_max.x  : global_position.x =  map_max.x
	if global_position.y < map_min.y : global_position.y =  map_min.y
	if global_position.y > map_max.y  : global_position.y =  map_max.y

	if dir != Vector2.ZERO:
		position += dir.normalized() * delta * pan_speed * (1.0 / zoom.x)


# ─────────────────────────────────────────────
#  CLIC-DRAG (bouton milieu ou "camera_pan")
# ─────────────────────────────────────────────
func _handle_drag() -> void:
	if not _is_dragging and Input.is_action_just_pressed("camera_pan"):
		_drag_start_mouse = get_viewport().get_mouse_position()
		_drag_start_cam   = position
		_is_dragging = true

	if _is_dragging and Input.is_action_just_released("camera_pan"):
		_is_dragging = false

	if _is_dragging:
		var delta_mouse = get_viewport().get_mouse_position() - _drag_start_mouse
		position = _drag_start_cam - delta_mouse * (1.0 / zoom.x)


# ─────────────────────────────────────────────
#  LIMITES
# ─────────────────────────────────────────────
func _apply_limits() -> void:
	limit_left   = int(map_min.x)
	limit_top    = int(map_min.y)
	limit_right  = int(map_max.x)
	limit_bottom = int(map_max.y)


# ─────────────────────────────────────────────
#  FOCUS (aller vers un héros ou un objet)
# ─────────────────────────────────────────────
func focus_on(world_pos: Vector2, duration: float = 0.4) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", world_pos, duration)
