## InspectionOverlay.gd
## Ajouté programmatiquement dans $UILayer par guild_scene.gd.
## Quand actif, affiche sous la souris la surface de la pièce survolée.
extends Control


# ─────────────────────────────────────────────
#  NŒUDS INTERNES
# ─────────────────────────────────────────────
var _toggle_btn : Button         = null
var _tooltip    : PanelContainer = null
var _area_label : Label          = null

var _active : bool = false


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_toggle_button()
	_build_tooltip()
	_reposition_button()
	get_viewport().size_changed.connect(_reposition_button)


func _build_toggle_button() -> void:
	_toggle_btn = Button.new()
	_toggle_btn.text            = "Inspection"
	_toggle_btn.toggle_mode     = true
	_toggle_btn.custom_minimum_size = Vector2(110, 30)
	_toggle_btn.pressed.connect(_on_toggle_pressed)
	add_child(_toggle_btn)


func _build_tooltip() -> void:
	_tooltip = PanelContainer.new()
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color                   = Color(0.08, 0.08, 0.08, 0.82)
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left        = 8
	style.content_margin_right       = 8
	style.content_margin_top         = 4
	style.content_margin_bottom      = 4
	_tooltip.add_theme_stylebox_override("panel", style)

	_area_label = Label.new()
	_area_label.add_theme_font_size_override("font_size", 13)
	_area_label.add_theme_color_override("font_color", Color.WHITE)
	_tooltip.add_child(_area_label)

	add_child(_tooltip)
	_tooltip.hide()


## Positionne le bouton en bas à gauche en coordonnées absolues.
func _reposition_button() -> void:
	if _toggle_btn == null:
		return
	var vp_h : float = get_viewport().get_visible_rect().size.y
	_toggle_btn.position = Vector2(8.0, vp_h - _toggle_btn.custom_minimum_size.y - 8.0)


# ─────────────────────────────────────────────
#  BOUCLE
# ─────────────────────────────────────────────
func _process(_delta: float) -> void:
	if not _active:
		return

	var screen_pos : Vector2    = get_viewport().get_mouse_position()
	var world_pos  : Vector2    = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	var tile_pos   : Vector2i   = Vector2i(world_pos / GameConfig.TILE_SIZE)
	var room       : Dictionary = RoomManager.get_room_at(tile_pos)

	if room.is_empty():
		_tooltip.hide()
		return

	_area_label.text = "Surface : %d tuiles" % room["area"]
	_tooltip.show()
	call_deferred("_place_tooltip", screen_pos)


func _place_tooltip(screen_pos: Vector2) -> void:
	var offset  : Vector2 = Vector2(14.0, 14.0)
	var vp_size : Vector2 = get_viewport_rect().size
	var pos     : Vector2 = screen_pos + offset
	pos.x = clamp(pos.x, 0.0, vp_size.x - _tooltip.size.x)
	pos.y = clamp(pos.y, 0.0, vp_size.y - _tooltip.size.y)
	_tooltip.position = pos


# ─────────────────────────────────────────────
#  TOGGLE
# ─────────────────────────────────────────────
func _on_toggle_pressed() -> void:
	_active = _toggle_btn.button_pressed
	if not _active:
		_tooltip.hide()
