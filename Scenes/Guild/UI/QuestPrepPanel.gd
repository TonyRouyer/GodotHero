## QuestPrepPanel.gd
## Interface de préparation de quête.
## Gauche : 4 slots de héros avec toggle AI/Joueur + bouton "Choisir héros".
## Droite : résumé de la mission + boutons Retour / Démarrer.
## Ouvert via EventBus.ui_panel_open_requested("quest_prep_panel", {"mission": dict}).
extends Control


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const MAX_HEROES  : int = 4

const _RANK_LABEL : Array = ["F", "F", "D", "C", "B", "S"]

const _STAT_LABELS : Dictionary = {
	"strength": "Force",  "agility": "Agilité",
	"defense":  "Défense","magic":   "Magie",   "luck": "Chance",
}


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _mission        : Dictionary = {}
var _party          : Array      = []   ## Array of hero_id (int), max 4
var _player_hero_id : int        = -1  ## -1 = tout AI


# ─────────────────────────────────────────────
#  WIDGETS
# ─────────────────────────────────────────────
var _panel        : PanelContainer  = null
var _slot_rows    : Array           = []   ## Array[PanelContainer], 4 entries
var _count_label  : Label           = null
var _start_btn    : Button          = null
var _picker_popup : PanelContainer  = null
var _picker_scroll_vbox : VBoxContainer = null
var _picker_count_label : Label     = null
var _picker_selected    : Array     = []   ## hero_ids choisis dans le picker


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_build_picker_popup()
	_panel.hide()
	_picker_popup.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI PRINCIPALE
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(740, 500)
	add_child(_panel)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	_panel.add_child(root)

	## ── Gauche : sélection des héros ─────────────────────────────────────────
	var left_margin := MarginContainer.new()
	left_margin.custom_minimum_size = Vector2(400, 0)
	left_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left","right","top","bottom"]:
		left_margin.add_theme_constant_override("margin_" + side, 14)
	root.add_child(left_margin)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	left_margin.add_child(left_vbox)

	## En-tête gauche
	var left_hdr := HBoxContainer.new()
	left_vbox.add_child(left_hdr)

	var left_title := Label.new()
	left_title.text = "Sélection des héros"
	left_title.add_theme_font_size_override("font_size", 13)
	left_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_hdr.add_child(left_title)

	_count_label = Label.new()
	_count_label.text = "0 / %d" % MAX_HEROES
	_count_label.add_theme_font_size_override("font_size", 11)
	_count_label.modulate = Color(0.65, 0.65, 0.65)
	left_hdr.add_child(_count_label)

	left_vbox.add_child(HSeparator.new())

	## 4 slots
	for i in MAX_HEROES:
		var slot := _build_hero_slot(i)
		left_vbox.add_child(slot)

	## Spacer + bouton picker
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(spacer)

	var pick_btn := Button.new()
	pick_btn.text = "Choisir héros"
	pick_btn.pressed.connect(_open_picker)
	left_vbox.add_child(pick_btn)

	## ── Séparateur ───────────────────────────────────────────────────────────
	root.add_child(VSeparator.new())

	## ── Droite : résumé de la mission ────────────────────────────────────────
	var right_margin := MarginContainer.new()
	right_margin.custom_minimum_size = Vector2(300, 0)
	for side in ["left","right","top","bottom"]:
		right_margin.add_theme_constant_override("margin_" + side, 14)
	root.add_child(right_margin)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_margin.add_child(right_vbox)

	## Titre quête
	var q_title_row := HBoxContainer.new()
	right_vbox.add_child(q_title_row)

	var q_title := Label.new()
	q_title.name = "QuestTitle"
	q_title.text = ""
	q_title.add_theme_font_size_override("font_size", 13)
	q_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	q_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	q_title_row.add_child(q_title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.flat = true
	close_btn.custom_minimum_size = Vector2(26, 0)
	close_btn.pressed.connect(_close)
	q_title_row.add_child(close_btn)

	right_vbox.add_child(HSeparator.new())

	## Objectifs
	var obj_title := Label.new()
	obj_title.text = "Objectif"
	obj_title.add_theme_font_size_override("font_size", 11)
	right_vbox.add_child(obj_title)

	var obj_lbl := Label.new()
	obj_lbl.name = "ObjLabel"
	obj_lbl.text = ""
	obj_lbl.add_theme_font_size_override("font_size", 10)
	obj_lbl.modulate = Color(0.80, 0.80, 0.80)
	obj_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	right_vbox.add_child(obj_lbl)

	right_vbox.add_child(HSeparator.new())

	## Récompenses
	var rew_title := Label.new()
	rew_title.text = "Récompenses"
	rew_title.add_theme_font_size_override("font_size", 11)
	right_vbox.add_child(rew_title)

	var rew_lbl := Label.new()
	rew_lbl.name = "RewLabel"
	rew_lbl.text = ""
	rew_lbl.add_theme_font_size_override("font_size", 10)
	rew_lbl.modulate = Color(0.80, 0.80, 0.80)
	rew_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	right_vbox.add_child(rew_lbl)

	## Spacer
	var r_spacer := Control.new()
	r_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(r_spacer)

	## Boutons bas droite
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	right_vbox.add_child(btn_row)

	var back_btn := Button.new()
	back_btn.text = "Retour"
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.pressed.connect(_on_back_pressed)
	btn_row.add_child(back_btn)

	_start_btn = Button.new()
	_start_btn.text = "Démarrer"
	_start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_start_btn.disabled = true
	_start_btn.pressed.connect(_on_start_pressed)
	btn_row.add_child(_start_btn)


func _build_hero_slot(idx: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = "Slot%d" % idx
	slot.custom_minimum_size = Vector2(0, 60)

	var style_empty := StyleBoxFlat.new()
	style_empty.bg_color     = Color(0.18, 0.18, 0.22)
	style_empty.border_color = Color(0.30, 0.30, 0.38)
	style_empty.set_border_width_all(1)
	style_empty.corner_radius_top_left     = 4
	style_empty.corner_radius_top_right    = 4
	style_empty.corner_radius_bottom_left  = 4
	style_empty.corner_radius_bottom_right = 4
	slot.add_theme_stylebox_override("panel", style_empty)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	slot.add_child(hbox)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_" + side, 6)
	hbox.add_child(margin)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 2)
	margin.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.name = "NameLbl"
	name_lbl.text = "Slot libre"
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.modulate = Color(0.50, 0.50, 0.55)
	info_vbox.add_child(name_lbl)

	var class_lbl := Label.new()
	class_lbl.name = "ClassLbl"
	class_lbl.text = ""
	class_lbl.add_theme_font_size_override("font_size", 9)
	class_lbl.modulate = Color(0.45, 0.45, 0.50)
	info_vbox.add_child(class_lbl)

	var ai_btn := Button.new()
	ai_btn.name = "AIBtn"
	ai_btn.text = "AI"
	ai_btn.custom_minimum_size = Vector2(70, 0)
	ai_btn.visible = false
	ai_btn.pressed.connect(_on_ai_btn_pressed.bind(idx))
	hbox.add_child(ai_btn)

	_slot_rows.append(slot)
	return slot


# ─────────────────────────────────────────────
#  POPUP DE SÉLECTION DE HÉROS
# ─────────────────────────────────────────────
func _build_picker_popup() -> void:
	_picker_popup = PanelContainer.new()
	add_child(_picker_popup)

	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.14, 0.14, 0.18)
	style.border_color = Color(0.45, 0.45, 0.55)
	style.set_border_width_all(1)
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	_picker_popup.add_theme_stylebox_override("panel", style)
	_picker_popup.custom_minimum_size = Vector2(380, 400)

	var outer := MarginContainer.new()
	for side in ["left","right","top","bottom"]:
		outer.add_theme_constant_override("margin_" + side, 12)
	_picker_popup.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	outer.add_child(vbox)

	## En-tête
	var hdr := HBoxContainer.new()
	vbox.add_child(hdr)

	var hdr_title := Label.new()
	hdr_title.text = "Sélectionner des héros"
	hdr_title.add_theme_font_size_override("font_size", 12)
	hdr_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(hdr_title)

	_picker_count_label = Label.new()
	_picker_count_label.text = "0 / %d" % MAX_HEROES
	_picker_count_label.add_theme_font_size_override("font_size", 11)
	_picker_count_label.modulate = Color(0.65, 0.65, 0.65)
	hdr.add_child(_picker_count_label)

	vbox.add_child(HSeparator.new())

	## Liste scrollable
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_picker_scroll_vbox = VBoxContainer.new()
	_picker_scroll_vbox.add_theme_constant_override("separation", 4)
	_picker_scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_picker_scroll_vbox)

	## Boutons bas
	vbox.add_child(HSeparator.new())

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Annuler"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.pressed.connect(func() -> void: _picker_popup.hide())
	btn_row.add_child(cancel_btn)

	var validate_btn := Button.new()
	validate_btn.text = "Valider"
	validate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	validate_btn.pressed.connect(_on_picker_validated)
	btn_row.add_child(validate_btn)


func _open_picker() -> void:
	## Réinitialise la sélection avec les héros déjà dans la party
	_picker_selected = _party.duplicate()
	_populate_picker()
	_picker_popup.show()
	await get_tree().process_frame
	_picker_popup.position = _panel.position + (_panel.size - _picker_popup.size) * 0.5


func _populate_picker() -> void:
	for child in _picker_scroll_vbox.get_children():
		child.queue_free()

	var all_heroes : Array[HeroData] = HeroManager.get_all_data()
	for hero in all_heroes:
		_add_picker_row(hero)

	_update_picker_count()


func _add_picker_row(hero: HeroData) -> void:
	var already_selected : bool = hero.hero_id in _picker_selected
	var unavailable      : bool = hero.on_mission and not already_selected

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left","top","bottom"]:
		margin.add_theme_constant_override("margin_" + side, 4)
	row.add_child(margin)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	margin.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = hero.hero_name
	name_lbl.add_theme_font_size_override("font_size", 11)
	if unavailable:
		name_lbl.modulate = Color(0.45, 0.45, 0.45)
	info.add_child(name_lbl)

	var detail_lbl := Label.new()
	#var rank_str : String = _RANK_LABEL[clamp(0, 0, _RANK_LABEL.size()-1)]   ## fallback F
	detail_lbl.text = "%s  —  Rang %s  —  Niv.%d" % [hero.hero_class, hero.rank, hero.level]
	detail_lbl.add_theme_font_size_override("font_size", 9)
	detail_lbl.modulate = Color(0.50, 0.50, 0.55)
	info.add_child(detail_lbl)

	var toggle_btn := Button.new()
	toggle_btn.name = "Toggle_%d" % hero.hero_id
	toggle_btn.custom_minimum_size = Vector2(36, 0)
	toggle_btn.disabled = unavailable
	if already_selected:
		toggle_btn.text = "✓"
		toggle_btn.modulate = Color(0.4, 0.9, 0.4)
	else:
		toggle_btn.text = "+"
	toggle_btn.pressed.connect(_on_picker_toggle.bind(hero.hero_id, toggle_btn))
	row.add_child(toggle_btn)

	if unavailable:
		var miss_lbl := Label.new()
		miss_lbl.text = "En mission"
		miss_lbl.add_theme_font_size_override("font_size", 9)
		miss_lbl.modulate = Color(0.55, 0.45, 0.25)
		row.add_child(miss_lbl)

	_picker_scroll_vbox.add_child(row)


func _on_picker_toggle(hero_id: int, btn: Button) -> void:
	if hero_id in _picker_selected:
		_picker_selected.erase(hero_id)
		btn.text = "+"
		btn.modulate = Color(1, 1, 1)
	else:
		if _picker_selected.size() >= MAX_HEROES:
			return
		_picker_selected.append(hero_id)
		btn.text = "✓"
		btn.modulate = Color(0.4, 0.9, 0.4)
	_update_picker_count()


func _update_picker_count() -> void:
	_picker_count_label.text = "%d / %d" % [_picker_selected.size(), MAX_HEROES]


func _on_picker_validated() -> void:
	_picker_popup.hide()
	## Si le héros joueur n'est plus dans la sélection, reset
	if _player_hero_id != -1 and _player_hero_id not in _picker_selected:
		_player_hero_id = -1
	_party = _picker_selected.duplicate()
	_refresh_slots()


# ─────────────────────────────────────────────
#  AFFICHAGE DES SLOTS
# ─────────────────────────────────────────────
func _refresh_slots() -> void:
	_count_label.text = "%d / %d" % [_party.size(), MAX_HEROES]

	for i in MAX_HEROES:
		var slot : PanelContainer = _slot_rows[i]
		var name_lbl  : Label  = slot.find_child("NameLbl",  true, false) as Label
		var class_lbl : Label  = slot.find_child("ClassLbl", true, false) as Label
		var ai_btn    : Button = slot.find_child("AIBtn",    true, false) as Button

		if i < _party.size():
			var hero_id   : int      = _party[i]
			var hero_data : HeroData = HeroManager.get_hero_data(hero_id)
			if hero_data == null:
				continue

			## Style slot rempli
			var style_full := StyleBoxFlat.new()
			style_full.bg_color     = Color(0.22, 0.22, 0.28)
			style_full.border_color = Color(0.45, 0.45, 0.60)
			style_full.set_border_width_all(1)
			style_full.corner_radius_top_left     = 4
			style_full.corner_radius_top_right    = 4
			style_full.corner_radius_bottom_left  = 4
			style_full.corner_radius_bottom_right = 4
			slot.add_theme_stylebox_override("panel", style_full)

			name_lbl.text    = hero_data.hero_name
			name_lbl.modulate = Color(1, 1, 1)
			class_lbl.text   = "%s  —  Rang %s  —  Niv.%d" % [
				hero_data.hero_class, hero_data.rank, hero_data.level
			]
			class_lbl.modulate = Color(0.70, 0.70, 0.70)

			var is_player : bool = (hero_id == _player_hero_id)
			ai_btn.visible = true
			ai_btn.text    = "Joueur" if is_player else "AI"
			ai_btn.modulate = Color(0.4, 0.85, 0.4) if is_player else Color(1, 1, 1)
		else:
			## Slot vide
			var style_empty := StyleBoxFlat.new()
			style_empty.bg_color     = Color(0.18, 0.18, 0.22)
			style_empty.border_color = Color(0.30, 0.30, 0.38)
			style_empty.set_border_width_all(1)
			style_empty.corner_radius_top_left     = 4
			style_empty.corner_radius_top_right    = 4
			style_empty.corner_radius_bottom_left  = 4
			style_empty.corner_radius_bottom_right = 4
			slot.add_theme_stylebox_override("panel", style_empty)

			name_lbl.text    = "Slot libre"
			name_lbl.modulate = Color(0.40, 0.40, 0.45)
			class_lbl.text   = ""
			ai_btn.visible   = false

	_start_btn.disabled = _party.is_empty()


func _on_ai_btn_pressed(slot_idx: int) -> void:
	if slot_idx >= _party.size():
		return
	var hero_id : int = _party[slot_idx]
	if _player_hero_id == hero_id:
		## Déjà joueur → repasse en AI
		_player_hero_id = -1
	else:
		_player_hero_id = hero_id
	_refresh_slots()


# ─────────────────────────────────────────────
#  RÉSUMÉ DE LA MISSION
# ─────────────────────────────────────────────
func _load_mission(m: Dictionary) -> void:
	_mission = m
	var diff  : int    = m.get("difficulty", 1)
	var rank  : String = _RANK_LABEL[clamp(diff, 0, _RANK_LABEL.size()-1)]
	var hours : int    = m.get("duration_hours", 0)
	var stat  : String = _STAT_LABELS.get(m.get("required_stat",""), m.get("required_stat",""))

	_panel.find_child("QuestTitle", true, false).text = (
		"%s  [%s]" % [m.get("name","Quête"), rank]
	)
	_panel.find_child("ObjLabel", true, false).text = (
		"• Accomplir la mission en %dh\n• Stat principale : %s" % [hours, stat]
	)
	_panel.find_child("RewLabel", true, false).text = (
		"• %d 💰 Or\n• %d ⭐ Réputation\n• %d XP" % [
			m.get("gold",0), m.get("reputation",0), m.get("xp",0)
		]
	)


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func _on_start_pressed() -> void:
	if _party.is_empty() or _mission.is_empty():
		return

	## Toujours charger la scène de combat (jouable ou spectateur full-AI)
	MissionManager.start_playable_mission(_mission, _party, _player_hero_id)

	_close()


func _on_back_pressed() -> void:
	_close()
	EventBus.ui_panel_open_requested.emit("quest_panel", {})


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, payload: Dictionary) -> void:
	if panel_id != "quest_prep_panel":
		_panel.hide()
		_picker_popup.hide()
		return

	_mission        = payload.get("mission", {})
	_party          = []
	_player_hero_id = -1
	_picker_popup.hide()

	if _mission.is_empty():
		return

	_refresh_slots()
	_load_mission(_mission)
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	_picker_popup.hide()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _picker_popup.visible:
			_picker_popup.hide()
		else:
			_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("click"):
		if _picker_popup.visible:
			var cr := Rect2(_picker_popup.global_position, _picker_popup.size)
			if not cr.has_point(get_viewport().get_mouse_position()):
				_picker_popup.hide()
