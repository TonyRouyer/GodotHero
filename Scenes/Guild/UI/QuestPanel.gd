## QuestPanel.gd
## Interface de sélection de quêtes.
## Panneau gauche : lettres de quête placées aléatoirement sur un tableau.
## Panneau droit  : détail de la quête sélectionnée.
## Ouvert via EventBus.ui_panel_open_requested("quest_panel").
extends Control


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const _LETTER_W  : int = 62
const _LETTER_H  : int = 80
const _BOARD_PAD : int = 24

const _RANK_LABEL : Array = ["F", "F", "D", "C", "B", "S"]   ## index = difficulty 0-5

const _RANK_COLORS : Dictionary = {
	"F": Color(0.70, 0.70, 0.70),
	"D": Color(0.30, 0.80, 0.30),
	"C": Color(0.20, 0.55, 1.00),
	"B": Color(0.65, 0.10, 0.90),
	"S": Color(1.00, 0.55, 0.00),
}

const _STAT_LABELS : Dictionary = {
	"strength": "Force",
	"agility":  "Agilité",
	"defense":  "Défense",
	"magic":    "Magie",
	"luck":     "Chance",
}

## Palette de couleurs pour les lettres (une par quête, cycle)
const _LETTER_COLORS : Array = [
	Color(0.85, 0.78, 0.55),
	Color(0.78, 0.88, 0.70),
	Color(0.72, 0.80, 0.92),
	Color(0.90, 0.76, 0.72),
]


# ─────────────────────────────────────────────
#  WIDGETS
# ─────────────────────────────────────────────
var _panel          : PanelContainer = null
var _board_area     : Control        = null
var _letter_buttons : Array          = []   ## Array[Button]

## Détail droit
var _det_title  : Label = null
var _det_rank   : Label = null
var _det_desc   : Label = null
var _det_obj    : Label = null
var _det_rew    : Label = null
var _accept_btn : Button = null
var _refuse_btn : Button = null
var _detail_box : VBoxContainer = null

## Popup confirmation refus
var _confirm_popup : PanelContainer = null

## Mission sélectionnée
var _selected_mission : Dictionary = {}
var _selected_idx     : int        = -1


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_build_confirm_popup()
	_panel.hide()
	_confirm_popup.hide()

	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	MissionManager.missions_changed.connect(_refresh_board)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if MissionManager.missions_changed.is_connected(_refresh_board):
		MissionManager.missions_changed.disconnect(_refresh_board)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(740, 480)
	add_child(_panel)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	_panel.add_child(root)

	## ── Panneau gauche : tableau de quêtes ───────────────────────────────────
	var board_panel := PanelContainer.new()
	board_panel.custom_minimum_size = Vector2(400, 480)
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var board_style := StyleBoxFlat.new()
	board_style.bg_color = Color(0.82, 0.76, 0.60)
	board_style.set_border_width_all(0)
	board_panel.add_theme_stylebox_override("panel", board_style)
	root.add_child(board_panel)

	_board_area = Control.new()
	_board_area.mouse_filter = Control.MOUSE_FILTER_PASS
	_board_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_panel.add_child(_board_area)

	## Titre du tableau
	var board_title := Label.new()
	board_title.text = "Tableau des contrats"
	board_title.add_theme_font_size_override("font_size", 11)
	board_title.modulate = Color(0.35, 0.25, 0.15)
	board_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	board_title.offset_top  = 6
	board_title.offset_left = 12
	board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_board_area.add_child(board_title)

	## ── Séparateur vertical ──────────────────────────────────────────────────
	root.add_child(VSeparator.new())

	## ── Panneau droit : détail de la quête ───────────────────────────────────
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(300, 480)
	root.add_child(detail_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	detail_panel.add_child(margin)

	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override("separation", 8)
	margin.add_child(_detail_box)

	## Ligne titre + bouton fermer
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 6)
	_detail_box.add_child(title_row)

	_det_title = Label.new()
	_det_title.text = "Sélectionnez une quête"
	_det_title.add_theme_font_size_override("font_size", 13)
	_det_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_det_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_row.add_child(_det_title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(26, 0)
	close_btn.flat = true
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	## Rang
	_det_rank = Label.new()
	_det_rank.text = ""
	_det_rank.add_theme_font_size_override("font_size", 11)
	_detail_box.add_child(_det_rank)

	_detail_box.add_child(HSeparator.new())

	## Description
	_det_desc = Label.new()
	_det_desc.text = ""
	_det_desc.add_theme_font_size_override("font_size", 10)
	_det_desc.modulate = Color(0.85, 0.85, 0.85)
	_det_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	_det_desc.custom_minimum_size = Vector2(0, 80)
	_detail_box.add_child(_det_desc)

	_detail_box.add_child(HSeparator.new())

	## Objectifs
	var obj_title := Label.new()
	obj_title.text = "Objectifs"
	obj_title.add_theme_font_size_override("font_size", 11)
	_detail_box.add_child(obj_title)

	_det_obj = Label.new()
	_det_obj.text = ""
	_det_obj.add_theme_font_size_override("font_size", 10)
	_det_obj.modulate = Color(0.80, 0.80, 0.80)
	_det_obj.autowrap_mode = TextServer.AUTOWRAP_WORD
	_detail_box.add_child(_det_obj)

	_detail_box.add_child(HSeparator.new())

	## Récompenses
	var rew_title := Label.new()
	rew_title.text = "Récompenses"
	rew_title.add_theme_font_size_override("font_size", 11)
	_detail_box.add_child(rew_title)

	_det_rew = Label.new()
	_det_rew.text = ""
	_det_rew.add_theme_font_size_override("font_size", 10)
	_det_rew.modulate = Color(0.80, 0.80, 0.80)
	_det_rew.autowrap_mode = TextServer.AUTOWRAP_WORD
	_detail_box.add_child(_det_rew)

	## Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_box.add_child(spacer)

	## Boutons Refuser / Accepter
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	_detail_box.add_child(btn_row)

	_refuse_btn = Button.new()
	_refuse_btn.text = "Refuser"
	_refuse_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refuse_btn.modulate = Color(1.0, 0.55, 0.55)
	_refuse_btn.disabled = true
	_refuse_btn.pressed.connect(_on_refuse_pressed)
	btn_row.add_child(_refuse_btn)

	_accept_btn = Button.new()
	_accept_btn.text = "Accepter"
	_accept_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accept_btn.disabled = true
	_accept_btn.pressed.connect(_on_accept_pressed)
	btn_row.add_child(_accept_btn)

	_set_detail_visible(false)


func _build_confirm_popup() -> void:
	_confirm_popup = PanelContainer.new()
	add_child(_confirm_popup)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.14, 0.18)
	style.border_color = Color(0.50, 0.50, 0.60)
	style.set_border_width_all(1)
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	_confirm_popup.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	_confirm_popup.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Refuser cette quête ?\nElle disparaîtra définitivement."
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Annuler"
	cancel_btn.custom_minimum_size = Vector2(80, 0)
	cancel_btn.pressed.connect(func() -> void: _confirm_popup.hide())
	row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "Confirmer"
	confirm_btn.custom_minimum_size = Vector2(80, 0)
	confirm_btn.modulate = Color(1.0, 0.45, 0.45)
	confirm_btn.pressed.connect(_on_confirm_refuse)
	row.add_child(confirm_btn)


# ─────────────────────────────────────────────
#  TABLEAU DES LETTRES
# ─────────────────────────────────────────────
func _refresh_board() -> void:
	## Supprime les anciennes lettres
	for btn in _letter_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	_letter_buttons.clear()
	_selected_mission = {}
	_selected_idx = -1
	_set_detail_visible(false)

	var missions : Array = MissionManager.available
	if missions.is_empty():
		_show_empty_board()
		return

	## Calcule la zone disponible pour le placement
	var area_size : Vector2 = _board_area.size
	## Fallback si la taille n'est pas encore calculée
	if area_size.x < 50:
		area_size = Vector2(390, 440)

	var usable := Rect2(
		_BOARD_PAD,
		_BOARD_PAD + 26,   ## 26 = espace sous le titre
		area_size.x - _BOARD_PAD * 2 - _LETTER_W,
		area_size.y - _BOARD_PAD * 2 - 26 - _LETTER_H
	)

	var placed_rects : Array = []

	for i in missions.size():
		var mission : Dictionary = missions[i]
		var pos : Vector2 = _find_free_position(placed_rects, usable)
		placed_rects.append(Rect2(pos, Vector2(_LETTER_W, _LETTER_H)))
		_spawn_letter(i, mission, pos)


func _show_empty_board() -> void:
	var lbl := Label.new()
	lbl.text = "Aucune quête disponible."
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.modulate = Color(0.45, 0.35, 0.20)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_board_area.add_child(lbl)
	_letter_buttons.append(lbl)   ## stocké pour nettoyage futur


func _find_free_position(placed: Array, usable: Rect2) -> Vector2:
	var max_tries : int = 60
	for _t in max_tries:
		var x : float = usable.position.x + randf() * usable.size.x
		var y : float = usable.position.y + randf() * usable.size.y
		var candidate := Rect2(x, y, _LETTER_W, _LETTER_H)
		var overlap : bool = false
		for r in placed:
			if candidate.intersects(r.grow(6)):
				overlap = true
				break
		if not overlap:
			return Vector2(x, y)
	## Fallback : placement en grille simple
	var idx : int = placed.size()
	return Vector2(
		usable.position.x + (idx % 2) * (_LETTER_W + 16),
		usable.position.y + (idx / 2) * (_LETTER_H + 12)
	)


func _spawn_letter(idx: int, mission: Dictionary, pos: Vector2) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(_LETTER_W, _LETTER_H)
	btn.position = pos
	btn.flat = false

	## Style lettre
	var diff : int  = mission.get("difficulty", 1)
	var rank : String = _RANK_LABEL[clamp(diff, 0, _RANK_LABEL.size() - 1)]
	var col  : Color = _LETTER_COLORS[idx % _LETTER_COLORS.size()]

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = col
	normal_style.border_color = col.darkened(0.25)
	normal_style.set_border_width_all(2)
	normal_style.corner_radius_top_left     = 3
	normal_style.corner_radius_top_right    = 3
	normal_style.corner_radius_bottom_left  = 3
	normal_style.corner_radius_bottom_right = 3
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = col.lightened(0.15)
	hover_style.border_color = _RANK_COLORS.get(rank, Color.WHITE)
	hover_style.set_border_width_all(3)
	btn.add_theme_stylebox_override("hover", hover_style)

	## Icône lettre : abréviation du rang
	btn.text = rank
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", col.darkened(0.55))

	btn.pressed.connect(_on_letter_pressed.bind(idx))
	_board_area.add_child(btn)
	_letter_buttons.append(btn)


# ─────────────────────────────────────────────
#  DÉTAIL DE LA QUÊTE
# ─────────────────────────────────────────────
func _on_letter_pressed(idx: int) -> void:
	if idx >= MissionManager.available.size():
		return
	_selected_idx     = idx
	_selected_mission = MissionManager.available[idx]
	_confirm_popup.hide()
	_show_mission_detail(_selected_mission)

	## Mise en évidence de la lettre sélectionnée
	for i in _letter_buttons.size():
		var btn = _letter_buttons[i]
		if not (btn is Button):
			continue
		btn.modulate = Color(1.0, 1.0, 1.0) if i == idx else Color(0.65, 0.65, 0.65)


func _show_mission_detail(m: Dictionary) -> void:
	var diff  : int    = m.get("difficulty", 1)
	var rank  : String = _RANK_LABEL[clamp(diff, 0, _RANK_LABEL.size() - 1)]
	var hours : int    = m.get("duration_hours", 0)
	var stat  : String = _STAT_LABELS.get(m.get("required_stat", ""), m.get("required_stat", ""))

	_det_title.text    = m.get("name", "Quête inconnue")
	_det_title.modulate = Color(1, 1, 1)
	_det_rank.text     = "Rang  %s  ·  Difficulté %d" % [rank, diff]
	_det_rank.modulate = _RANK_COLORS.get(rank, Color.WHITE)
	_det_desc.text     = m.get("description", "")

	_det_obj.text = (
		"• Accomplir la mission en %dh\n• Stat principale : %s" % [hours, stat]
	)

	_det_rew.text = (
		"• %d 💰 Or\n• %d ⭐ Réputation\n• %d XP" % [
			m.get("gold", 0), m.get("reputation", 0), m.get("xp", 0)
		]
	)

	_set_detail_visible(true)


func _set_detail_visible(is_show: bool) -> void:
	_det_desc.visible   = is_show
	_det_obj.visible    = is_show
	_det_rew.visible    = is_show
	_accept_btn.disabled = not is_show
	_refuse_btn.disabled = not is_show
	if not is_show:
		_det_rank.text  = ""
		_det_rank.modulate = Color(1, 1, 1)


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func _on_accept_pressed() -> void:
	if _selected_mission.is_empty():
		return
	_close()
	EventBus.ui_panel_open_requested.emit("quest_prep_panel", {
		"mission": _selected_mission
	})


func _on_refuse_pressed() -> void:
	if _selected_mission.is_empty():
		return
	_confirm_popup.show()
	## Positionne la popup au centre du panel
	await get_tree().process_frame
	_confirm_popup.position = (_panel.position + _panel.size * 0.5 - _confirm_popup.size * 0.5)


func _on_confirm_refuse() -> void:
	_confirm_popup.hide()
	if _selected_idx < 0 or _selected_idx >= MissionManager.available.size():
		return
	MissionManager.available.remove_at(_selected_idx)
	MissionManager.missions_changed.emit()
	_selected_mission = {}
	_selected_idx = -1
	_set_detail_visible(false)
	_refresh_board()


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "quest_panel":
		_panel.hide()
		_confirm_popup.hide()
		return
	_refresh_board()
	_panel.show()
	_confirm_popup.hide()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	_confirm_popup.hide()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _confirm_popup.visible:
			_confirm_popup.hide()
		else:
			_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("click"):
		if _confirm_popup.visible:
			var cr := Rect2(_confirm_popup.global_position, _confirm_popup.size)
			if not cr.has_point(get_viewport().get_mouse_position()):
				_confirm_popup.hide()
			return
		var rect := Rect2(_panel.global_position, _panel.size)
		if not rect.has_point(get_viewport().get_mouse_position()):
			_close()
