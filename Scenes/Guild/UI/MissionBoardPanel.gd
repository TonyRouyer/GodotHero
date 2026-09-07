## MissionBoardPanel.gd
## Tableau des missions : affiche les missions disponibles et actives.
## Construit entièrement en GDScript — aucun .tscn requis.
## Ouvert via EventBus.ui_panel_open_requested("mission_panel").
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel          : PanelContainer = null
var _avail_vbox     : VBoxContainer  = null
var _active_vbox    : VBoxContainer  = null
var _selected_hero  : int            = -1  ## hero_id sélectionné pour envoyer en mission


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const _DIFF_COLORS : Array = [
	Color(0.30, 0.70, 0.30),  # 1 — vert
	Color(0.60, 0.80, 0.20),  # 2 — jaune-vert
	Color(0.90, 0.70, 0.10),  # 3 — orange
	Color(0.85, 0.35, 0.10),  # 4 — rouge-orange
	Color(0.80, 0.10, 0.10),  # 5 — rouge
]


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	MissionManager.missions_changed.connect(_refresh)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if MissionManager.missions_changed.is_connected(_refresh):
		MissionManager.missions_changed.disconnect(_refresh)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(320, 0)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	_panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	## En-tête
	var hdr_row := HBoxContainer.new()
	root.add_child(hdr_row)
	var title := Label.new()
	title.text = "Tableau des Missions"
	title.add_theme_font_size_override("font_size", 12)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_row.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	hdr_row.add_child(close_btn)

	root.add_child(HSeparator.new())

	## Sélection héros disponible
	var hero_row := HBoxContainer.new()
	hero_row.add_theme_constant_override("separation", 8)
	root.add_child(hero_row)
	var hero_lbl := Label.new()
	hero_lbl.text = "Héros :"
	hero_lbl.add_theme_font_size_override("font_size", 10)
	hero_row.add_child(hero_lbl)
	var hero_option := OptionButton.new()
	hero_option.name = "HeroOption"
	hero_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_option.add_theme_font_size_override("font_size", 10)
	hero_option.item_selected.connect(_on_hero_selected)
	hero_row.add_child(hero_option)
	_populate_hero_option(hero_option)

	root.add_child(HSeparator.new())

	## Missions disponibles
	var avail_title := Label.new()
	avail_title.text = "Missions disponibles"
	avail_title.add_theme_font_size_override("font_size", 10)
	avail_title.modulate = Color(0.8, 0.8, 0.8)
	root.add_child(avail_title)

	var avail_scroll := ScrollContainer.new()
	avail_scroll.custom_minimum_size = Vector2(0, 160)
	root.add_child(avail_scroll)
	_avail_vbox = VBoxContainer.new()
	_avail_vbox.add_theme_constant_override("separation", 4)
	_avail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	avail_scroll.add_child(_avail_vbox)

	root.add_child(HSeparator.new())

	## Missions actives
	var active_title := Label.new()
	active_title.text = "Missions en cours"
	active_title.add_theme_font_size_override("font_size", 10)
	active_title.modulate = Color(0.8, 0.8, 0.8)
	root.add_child(active_title)

	var active_scroll := ScrollContainer.new()
	active_scroll.custom_minimum_size = Vector2(0, 100)
	root.add_child(active_scroll)
	_active_vbox = VBoxContainer.new()
	_active_vbox.add_theme_constant_override("separation", 4)
	_active_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_scroll.add_child(_active_vbox)


func _populate_hero_option(opt: OptionButton) -> void:
	opt.clear()
	opt.add_item("— Choisir un héros —", -1)
	for data in HeroManager.get_all_data():
		if not data.on_mission:
			opt.add_item(data.hero_name, data.hero_id)
	_selected_hero = -1


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh() -> void:
	if not _panel.visible:
		return
	_rebuild_available()
	_rebuild_active()
	## Met à jour le sélecteur de héros
	var opt := _panel.find_child("HeroOption", true, false) as OptionButton
	if opt:
		_populate_hero_option(opt)


func _rebuild_available() -> void:
	for child in _avail_vbox.get_children():
		child.queue_free()

	var missions : Array = MissionManager.get_available()
	if missions.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucune mission disponible."
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.modulate = Color(0.6, 0.6, 0.6)
		_avail_vbox.add_child(lbl)
		return

	for m in missions:
		_avail_vbox.add_child(_build_mission_card(m))


func _rebuild_active() -> void:
	for child in _active_vbox.get_children():
		child.queue_free()

	var missions : Array = MissionManager.get_active()
	if missions.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucune mission en cours."
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.modulate = Color(0.6, 0.6, 0.6)
		_active_vbox.add_child(lbl)
		return

	for entry in missions:
		_active_vbox.add_child(_build_active_card(entry))


## Carte d'une mission disponible (avec bouton "Envoyer").
func _build_mission_card(m: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 3)
	card.add_child(inner)
	_add_card_margin(card, inner)

	## Ligne titre + difficulté
	var top := HBoxContainer.new()
	inner.add_child(top)
	var name_lbl := Label.new()
	name_lbl.text = m.get("name", "Mission")
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	var diff : int = m.get("difficulty", 1)
	var diff_lbl := Label.new()
	diff_lbl.text = "★".repeat(diff) + "☆".repeat(5 - diff)
	diff_lbl.add_theme_font_size_override("font_size", 9)
	diff_lbl.modulate = _DIFF_COLORS[clamp(diff - 1, 0, 4)]
	top.add_child(diff_lbl)

	## Description
	var desc := Label.new()
	desc.text = m.get("description", "")
	desc.add_theme_font_size_override("font_size", 9)
	desc.modulate = Color(0.75, 0.75, 0.75)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	inner.add_child(desc)

	## Récompenses + stat requise + durée
	var rewards := Label.new()
	rewards.text = "+%d or  +%d rep  +%d XP  |  Stat : %s  |  %dh" % [
		m.get("gold", 0), m.get("reputation", 0), m.get("xp", 0),
		m.get("required_stat", "?").capitalize(),
		m.get("duration_hours", 0),
	]
	rewards.add_theme_font_size_override("font_size", 9)
	rewards.modulate = Color(0.85, 0.85, 0.60)
	inner.add_child(rewards)

	## Boutons d'action
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	inner.add_child(btn_row)

	var send_btn := Button.new()
	send_btn.text = "Envoyer"
	send_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	send_btn.add_theme_font_size_override("font_size", 9)
	send_btn.tooltip_text = "Résolution automatique à la fin du délai"
	send_btn.pressed.connect(_on_send_pressed.bind(m.get("id", "")))
	btn_row.add_child(send_btn)

	var play_btn := Button.new()
	play_btn.text = "⚔ Jouer"
	play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_btn.add_theme_font_size_override("font_size", 9)
	play_btn.tooltip_text = "Jouer la mission en temps réel"
	_style_play_btn(play_btn, diff)
	play_btn.pressed.connect(_on_play_pressed.bind(m))
	btn_row.add_child(play_btn)

	return card


## Carte d'une mission en cours (héros + heure de retour).
func _build_active_card(entry: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 8)
	card.add_child(inner)
	_add_card_margin(card, inner)

	var hero_data : HeroData = HeroManager.get_hero_data(entry.get("hero_id", -1))
	var hero_name : String   = hero_data.hero_name if hero_data else "?"

	var info := Label.new()
	info.text = "%s — %s" % [hero_name, entry.get("name", "Mission")]
	info.add_theme_font_size_override("font_size", 9)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(info)

	var ret := Label.new()
	ret.text = "Jour %d %02d:00" % [entry.get("return_day", 0), entry.get("return_hour", 0)]
	ret.add_theme_font_size_override("font_size", 9)
	ret.modulate = Color(0.7, 0.9, 1.0)
	inner.add_child(ret)

	return card


func _add_card_margin(card: PanelContainer, _inner: Container) -> void:
	## Ajoute une StyleBox légère à la carte
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.18, 0.22)
	style.corner_radius_top_left     = 3
	style.corner_radius_top_right    = 3
	style.corner_radius_bottom_left  = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	card.add_theme_stylebox_override("panel", style)


# ─────────────────────────────────────────────
#  CALLBACKS
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "mission_panel":
		_panel.hide()
		return
	_refresh()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _on_hero_selected(idx: int) -> void:
	var opt := _panel.find_child("HeroOption", true, false) as OptionButton
	if opt:
		_selected_hero = opt.get_item_id(idx)


func _on_send_pressed(mission_id: String) -> void:
	if _selected_hero <= 0:
		EventBus.ui_notification_requested.emit("Sélectionne d'abord un héros.", "warning")
		return
	if not MissionManager.assign(mission_id, _selected_hero):
		EventBus.ui_notification_requested.emit("Ce héros ne peut pas partir en mission.", "error")


func _on_play_pressed(mission_data: Dictionary) -> void:
	if _selected_hero <= 0:
		EventBus.ui_notification_requested.emit("Sélectionne d'abord un héros.", "warning")
		return
	var hero_data : HeroData = HeroManager.get_hero_data(_selected_hero)
	if hero_data == null or hero_data.on_mission:
		EventBus.ui_notification_requested.emit("Ce héros ne peut pas partir en mission.", "error")
		return
	_close()
	MissionManager.start_playable_mission(mission_data, [_selected_hero])


func _style_play_btn(btn: Button, difficulty: int) -> void:
	var color : Color = _DIFF_COLORS[clamp(difficulty - 1, 0, 4)]
	var style := StyleBoxFlat.new()
	style.bg_color = color.darkened(0.45)
	style.border_color = color
	style.border_width_left   = 1
	style.border_width_right  = 1
	style.border_width_top    = 1
	style.border_width_bottom = 1
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	btn.add_theme_stylebox_override("normal",  style)
	btn.add_theme_stylebox_override("hover",   style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color.WHITE)


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
