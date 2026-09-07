## RecruitPanel.gd
## Panneau de recrutement centré à l'écran.
## Affiche les aventuriers disponibles dans le pool de RecruitManager.
## Ouvert via EventBus.ui_panel_open_requested("recruit_panel").
extends Control


const _ROW_SCENE := preload("res://Scenes/Guild/UI/HeroPanel/RecruitRow.tscn")


# ─────────────────────────────────────────────
#  WIDGETS
# ─────────────────────────────────────────────
var _panel      : PanelContainer = null
var _list_vbox  : VBoxContainer  = null
var _empty_lbl  : Label          = null


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()

	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	RecruitManager.pool_changed.connect(_refresh)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if RecruitManager.pool_changed.is_connected(_refresh):
		RecruitManager.pool_changed.disconnect(_refresh)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(480, 0)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	_panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	## ── En-tête ──────────────────────────────────────────────────────────────
	var hdr := HBoxContainer.new()
	root.add_child(hdr)

	var title := Label.new()
	title.text = "Recrutement"
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(28, 0)
	close_btn.pressed.connect(_close)
	hdr.add_child(close_btn)

	root.add_child(HSeparator.new())

	## ── En-tête colonnes ─────────────────────────────────────────────────────
	var col_hdr := HBoxContainer.new()
	col_hdr.add_theme_constant_override("separation", 6)
	root.add_child(col_hdr)

	var _make_col_lbl := func(txt: String, min_w: int, expand: bool = false) -> void:
		var lbl := Label.new()
		lbl.text = txt
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = Color(0.6, 0.6, 0.6)
		lbl.custom_minimum_size = Vector2(min_w, 0)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if expand:
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col_hdr.add_child(lbl)

	## Marges internes du MarginContainer de chaque row : 8px à gauche
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(8, 0)
	col_hdr.add_child(spacer)

	_make_col_lbl.call("Rg",    18)
	_make_col_lbl.call("Nom",   90, true)
	_make_col_lbl.call("Classe",56)
	_make_col_lbl.call("Niv",   28)
	_make_col_lbl.call("Coût",  48)
	## Espace pour les deux boutons ✓ ✕
	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(64, 0)
	col_hdr.add_child(btn_spacer)

	root.add_child(HSeparator.new())

	## ── Liste des candidats ───────────────────────────────────────────────────

	_list_vbox = VBoxContainer.new()
	_list_vbox.add_theme_constant_override("separation", 4)
	root.add_child(_list_vbox)

	## ── Bouton debug ─────────────────────────────────────────────────────────
	var debug_btn := Button.new()
	debug_btn.text = "[DEBUG] Ajouter un héros aléatoire"
	debug_btn.add_theme_font_size_override("font_size", 10)
	debug_btn.modulate = Color(0.6, 0.6, 0.6)
	debug_btn.pressed.connect(func() -> void: RecruitManager.add_random_for_test())
	root.add_child(debug_btn)

	## ── Message si pool vide ─────────────────────────────────────────────────
	_empty_lbl = Label.new()
	_empty_lbl.text = "Aucun aventurier disponible pour le moment.\nRevenez plus tard…"
	_empty_lbl.add_theme_font_size_override("font_size", 11)
	_empty_lbl.modulate = Color(0.6, 0.6, 0.6)
	_empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	_empty_lbl.custom_minimum_size = Vector2(0, 60)
	_empty_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_empty_lbl)


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh() -> void:
	if not _panel.visible:
		return
	for child in _list_vbox.get_children():
		child.queue_free()

	var pool : Array[HeroData] = RecruitManager.get_pool()
	_empty_lbl.visible = pool.is_empty()

	for hero_data in pool:
		var row = _ROW_SCENE.instantiate()
		_list_vbox.add_child(row)
		row.setup(hero_data)


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "recruit_panel":
		_panel.hide()
		return
	_refresh()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  INPUT — ferme sur ESC ou clic hors panel
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return

	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("click"):
		var rect := Rect2(_panel.global_position, _panel.size)
		if not rect.has_point(get_viewport().get_mouse_position()):
			_close()
