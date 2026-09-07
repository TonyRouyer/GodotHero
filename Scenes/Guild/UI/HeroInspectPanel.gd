## HeroInspectPanel.gd
## Panneau "livre ouvert" : page gauche (Info / Stats / Moral) + page droite (équipement + inventaire).
## Ouvert via EventBus.hero_inspect_requested(hero_data, screen_pos).
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel    : PanelContainer = null
var _hero_id  : int            = -1
var _data     : HeroData       = null

## Onglets gauche
var _tab_btns  : Array[Button]       = []
var _pages     : Array[Control]      = []   ## [info_vbox, stats_vbox, moral_vbox]
var _cur_tab   : int                 = 0

## ── Page gauche — Onglet Info ──────────────
var _info_name_lbl  : Label          = null
var _info_class_lbl : Label          = null
var _bars           : Dictionary     = {}   ## key → ProgressBar
var _bar_labels     : Dictionary     = {}   ## key → Label

## ── Page gauche — Onglet Stats ─────────────
var _stat_val_lbls  : Dictionary     = {}   ## key → Label
var _train_sliders  : Dictionary     = {}   ## key → HSlider
var _work_bars      : Dictionary     = {}   ## key → ProgressBar
var _work_val_lbls  : Dictionary     = {}   ## key → Label
var _job_option     : OptionButton   = null

## ── Page gauche — Onglet Moral ─────────────
var _moral_bar      : ProgressBar    = null
#var _moral_val_lbl  : Label          = null
var _effects_box    : VBoxContainer  = null
var _traits_box     : VBoxContainer  = null

## ── Page droite — équipement ───────────────
var _hero_sprite    : PanelContainer = null
var _slot_widgets   : Dictionary     = {}   ## slot_name → _EquipSlot
var _skill_btns     : Array[Control] = []   ## 4 slots actifs
var _inv_grid       : GridContainer  = null
var _inv_filter     : OptionButton   = null

## Context menu inventaire (dans la page droite)
var _inv_ctx_panel  : PanelContainer = null
var _inv_ctx_slot   : int            = -1


# ─────────────────────────────────────────────
#  DONNÉES
# ─────────────────────────────────────────────
const _NEEDS : Array = [
	{"key": "hp",            "label": "HP",           "max_key": "hp_max"},
	{"key": "moral",         "label": "Moral",         "max_key": ""},
	{"key": "energy",        "label": "Energie",       "max_key": ""},
	{"key": "hunger",        "label": "Faim",          "max_key": ""},
	{"key": "toilet",        "label": "Toilettes",     "max_key": ""},
	{"key": "hygiene",       "label": "Hygiene",       "max_key": ""},
	{"key": "entertainment", "label": "Divertiss.",    "max_key": ""},
]

const _STATS : Array = [
	{"key": "strength", "label": "Force"},
	{"key": "defense",  "label": "Défense"},
	{"key": "agility",  "label": "Agilité"},
	{"key": "magic",    "label": "Magie"},
	{"key": "luck",     "label": "Chance"},
]

const _WORK_STATS : Array = [
	{"key": "social",      "label": "Social"},
	{"key": "manual_work", "label": "Trav. manuel"},
	{"key": "occult_work", "label": "Trav. occulte"},
	{"key": "cooking",     "label": "Cuisine"},
	{"key": "knowledge",   "label": "Connaissance"},
]

const _JOB_LABELS : Dictionary = {
	0: "Sans emploi",
	1: "Accueil",
	2: "Forgeron",
	3: "Alchimiste",
	4: "Chercheur",
	5: "Cuisinier",
}

const _EQUIP_SLOTS : Array = [
	{"id": "consumable",  "label": "CONSOMM. 1"},
	{"id": "consumable2", "label": "CONSOMM. 2"},
	{"id": "weapon",      "label": "ARME"},
	{"id": "accessory",   "label": "BIJOU 1"},
	{"id": "head",        "label": "TÊTE"},
	{"id": "torso",       "label": "TORSE"},
	{"id": "legs",        "label": "BOTTES"},
	{"id": "accessory2",  "label": "BIJOU 2"},
]

const _COLOR_GOOD    := Color(0.20, 0.75, 0.25)
const _COLOR_WARNING := Color(0.90, 0.65, 0.10)
const _COLOR_DANGER  := Color(0.85, 0.18, 0.18)
const _TAB_ACTIVE    := Color(0.72, 0.22, 0.18)
const _TAB_INACTIVE  := Color(0.38, 0.18, 0.16)

## Maps stat keys to their HeroData priority property names (luck has none).
const _PRIORITY_PROP := {
	"strength": "strength_priority",
	"defense":  "defense_priority",
	"agility":  "agility_priority",
	"magic":    "mana_priority",
}


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()

	EventBus.hero_inspect_requested.connect(_on_inspect_requested)
	EventBus.hero_need_changed.connect(_on_need_changed)
	EventBus.hero_stat_changed.connect(_on_stat_changed)
	EventBus.hero_moral_effects_changed.connect(_on_moral_effects_changed)
	GuildInventoryManager.inventory_changed.connect(_on_inventory_changed)


func _exit_tree() -> void:
	if EventBus.hero_inspect_requested.is_connected(_on_inspect_requested):
		EventBus.hero_inspect_requested.disconnect(_on_inspect_requested)
	if EventBus.hero_need_changed.is_connected(_on_need_changed):
		EventBus.hero_need_changed.disconnect(_on_need_changed)
	if EventBus.hero_stat_changed.is_connected(_on_stat_changed):
		EventBus.hero_stat_changed.disconnect(_on_stat_changed)
	if EventBus.hero_moral_effects_changed.is_connected(_on_moral_effects_changed):
		EventBus.hero_moral_effects_changed.disconnect(_on_moral_effects_changed)
	if GuildInventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		GuildInventoryManager.inventory_changed.disconnect(_on_inventory_changed)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI — STRUCTURE LIVRE
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(820, 620)
	add_child(_panel)

	var outer_margin := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		outer_margin.add_theme_constant_override("margin_" + side, 10)
	_panel.add_child(outer_margin)

	## ── Ligne titre + bouton fermer ─────────────────────────────────────────
	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 6)
	outer_margin.add_child(root_vbox)

	var title_row := HBoxContainer.new()
	root_vbox.add_child(title_row)

	_info_name_lbl = Label.new()
	_info_name_lbl.add_theme_font_size_override("font_size", 15)
	_info_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(_info_name_lbl)

	_info_class_lbl = Label.new()
	_info_class_lbl.add_theme_font_size_override("font_size", 11)
	_info_class_lbl.modulate = Color(0.65, 0.65, 0.65)
	_info_class_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(_info_class_lbl)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(26, 0)
	close_btn.flat = true
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	root_vbox.add_child(HSeparator.new())

	## ── Corps : [tabs] | [page gauche] | [sep] | [page droite] ──────────────
	var body_hbox := HBoxContainer.new()
	body_hbox.add_theme_constant_override("separation", 0)
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(body_hbox)

	_build_tab_column(body_hbox)
	_build_left_page(body_hbox)

	var vsep := VSeparator.new()
	body_hbox.add_child(vsep)

	_build_right_page(body_hbox)
	_build_inv_context_menu()


func _build_tab_column(parent: HBoxContainer) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.custom_minimum_size = Vector2(78, 0)
	parent.add_child(col)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	var tab_names := ["Profil", "Stats", "Moral"]
	for i : int in tab_names.size():
		var btn := Button.new()
		btn.text = tab_names[i]
		btn.add_theme_font_size_override("font_size", 11)
		btn.custom_minimum_size = Vector2(76, 32)
		btn.flat = false
		_style_tab_btn(btn, i == 0)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		col.add_child(btn)
		_tab_btns.append(btn)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer2)


func _build_left_page(parent: HBoxContainer) -> void:
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(310, 0)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	parent.add_child(margin)

	var stack := VBoxContainer.new()
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(stack)

	## ── Onglet 0 : Info ──────────────────────────────────────────────────────
	var info_page := _build_info_page()
	stack.add_child(info_page)
	_pages.append(info_page)

	## ── Onglet 1 : Stats ─────────────────────────────────────────────────────
	var stats_page := _build_stats_page()
	stats_page.hide()
	stack.add_child(stats_page)
	_pages.append(stats_page)

	## ── Onglet 2 : Moral ─────────────────────────────────────────────────────
	var moral_page := _build_moral_page()
	moral_page.hide()
	stack.add_child(moral_page)
	_pages.append(moral_page)


# ─────────────────────────────────────────────
#  PAGE GAUCHE — ONGLET INFO
# ─────────────────────────────────────────────
func _build_info_page() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for i : int in _NEEDS.size():
		var need : Dictionary = _NEEDS[i]
		var key  : String     = need["key"]

		## Séparateur après HP et Moral
		if i == 2:
			vbox.add_child(HSeparator.new())

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = need["label"]
		lbl.custom_minimum_size = Vector2(78, 0)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.min_value   = 0.0
		bar.max_value   = 100.0
		bar.value       = 100.0
		bar.show_percentage = false
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.custom_minimum_size = Vector2(0, 14)
		row.add_child(bar)
		_bars[key] = bar

		var val_lbl := Label.new()
		val_lbl.custom_minimum_size = Vector2(36, 0)
		val_lbl.add_theme_font_size_override("font_size", 10)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val_lbl)
		_bar_labels[key] = val_lbl

	## Spacer
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(sp)

	## Boutons
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	var center_btn := Button.new()
	center_btn.text = "Centrer vue"
	center_btn.add_theme_font_size_override("font_size", 10)
	center_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_btn.pressed.connect(_on_center_view_pressed)
	btn_row.add_child(center_btn)

	var skills_btn := Button.new()
	skills_btn.text = "Compétences"
	skills_btn.add_theme_font_size_override("font_size", 10)
	skills_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skills_btn.pressed.connect(_on_skills_pressed)
	btn_row.add_child(skills_btn)

	return vbox


# ─────────────────────────────────────────────
#  PAGE GAUCHE — ONGLET STATS
# ─────────────────────────────────────────────
func _build_stats_page() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 5)
	scroll.add_child(vbox)

	## ── Sélecteur de job ─────────────────────────────────────────────────────
	var job_title := _make_section_label("Métier")
	vbox.add_child(job_title)

	_job_option = OptionButton.new()
	_job_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for job_id : int in _JOB_LABELS:
		_job_option.add_item(_JOB_LABELS[job_id], job_id)
	_job_option.item_selected.connect(_on_job_selected)
	vbox.add_child(_job_option)

	vbox.add_child(HSeparator.new())

	## ── Stats de combat + sliders priorité ───────────────────────────────────
	var combat_title := _make_section_label("Statistiques de combat")
	vbox.add_child(combat_title)

	for stat in _STATS:
		var key     : String = stat["key"]
		var row     := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = stat["label"]
		lbl.custom_minimum_size = Vector2(70, 0)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(lbl)

		var val_lbl := Label.new()
		val_lbl.custom_minimum_size = Vector2(28, 0)
		val_lbl.add_theme_font_size_override("font_size", 10)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val_lbl)
		_stat_val_lbls[key] = val_lbl

		if _PRIORITY_PROP.has(key):
			var slider := HSlider.new()
			slider.min_value = 0.0
			slider.max_value = 100.0
			slider.step = 1.0
			slider.value = 50.0
			slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slider.tooltip_text = "Priorité d'entraînement : %s" % stat["label"]
			slider.value_changed.connect(_on_train_priority_changed.bind(key))
			row.add_child(slider)
			_train_sliders[key] = slider

	vbox.add_child(HSeparator.new())

	## ── Stats métier ─────────────────────────────────────────────────────────
	var work_title := _make_section_label("Compétences métier")
	vbox.add_child(work_title)

	for wstat in _WORK_STATS:
		var key : String = wstat["key"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = wstat["label"]
		lbl.custom_minimum_size = Vector2(90, 0)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.min_value   = 0.0
		bar.max_value   = 100.0
		bar.value       = 0.0
		bar.show_percentage = false
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.custom_minimum_size = Vector2(0, 12)
		row.add_child(bar)
		_work_bars[key] = bar

		var wval := Label.new()
		wval.custom_minimum_size = Vector2(30, 0)
		wval.add_theme_font_size_override("font_size", 10)
		wval.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(wval)
		_work_val_lbls[key] = wval

	return scroll


# ─────────────────────────────────────────────
#  PAGE GAUCHE — ONGLET MORAL
# ─────────────────────────────────────────────
func _build_moral_page() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)

	## Barre moral
	var moral_row := HBoxContainer.new()
	moral_row.add_theme_constant_override("separation", 6)
	vbox.add_child(moral_row)

	var m_lbl := Label.new()
	m_lbl.text = "Moral"
	m_lbl.custom_minimum_size = Vector2(50, 0)
	m_lbl.add_theme_font_size_override("font_size", 11)
	m_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	moral_row.add_child(m_lbl)

	_moral_bar = ProgressBar.new()
	_moral_bar.min_value   = 0.0
	_moral_bar.max_value   = 100.0
	_moral_bar.value       = 100.0
	_moral_bar.show_percentage = true
	_moral_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_moral_bar.custom_minimum_size = Vector2(0, 18)
	moral_row.add_child(_moral_bar)

	vbox.add_child(HSeparator.new())

	## Effets actifs
	vbox.add_child(_make_section_label("Effets actifs"))

	_effects_box = VBoxContainer.new()
	_effects_box.add_theme_constant_override("separation", 3)
	vbox.add_child(_effects_box)

	vbox.add_child(HSeparator.new())

	## Traits
	vbox.add_child(_make_section_label("Traits"))

	_traits_box = VBoxContainer.new()
	_traits_box.add_theme_constant_override("separation", 5)
	vbox.add_child(_traits_box)

	return scroll


# ─────────────────────────────────────────────
#  PAGE DROITE — ÉQUIPEMENT + INVENTAIRE
# ─────────────────────────────────────────────
func _build_right_page(parent: HBoxContainer) -> void:
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(360, 0)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	parent.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	_build_paperdoll(vbox)

	vbox.add_child(HSeparator.new())

	_build_skill_row(vbox)

	vbox.add_child(HSeparator.new())

	_build_inventory_section(vbox)


func _build_paperdoll(parent: VBoxContainer) -> void:
	## Layout :
	##   Ligne 1 : [consomm1] [consomm2]  (centrés)
	##   Ligne 2 : [arme]  [sprite]  [tête]
	##             [bijou1][sprite]  [torse]
	##             [bijou2][sprite]  [bottes]

	## ── Ligne consumables ────────────────────────────────────────────────────
	var conso_row := HBoxContainer.new()
	conso_row.add_theme_constant_override("separation", 8)
	conso_row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(conso_row)

	_slot_widgets["consumable"]  = _make_equip_slot("consumable",  "CONSOMM.1")
	_slot_widgets["consumable2"] = _make_equip_slot("consumable2", "CONSOMM.2")
	conso_row.add_child(_slot_widgets["consumable"])
	conso_row.add_child(_slot_widgets["consumable2"])

	## ── Zone centrale : [col gauche] [sprite] [col droite] ───────────────────
	var mid_hbox := HBoxContainer.new()
	mid_hbox.add_theme_constant_override("separation", 8)
	mid_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(mid_hbox)

	## Col gauche : arme, bijou1, bijou2
	var left_col := VBoxContainer.new()
	left_col.add_theme_constant_override("separation", 6)
	left_col.alignment = BoxContainer.ALIGNMENT_CENTER
	mid_hbox.add_child(left_col)

	_slot_widgets["weapon"]     = _make_equip_slot("weapon",     "ARME")
	_slot_widgets["accessory"]  = _make_equip_slot("accessory",  "BIJOU 1")
	_slot_widgets["accessory2"] = _make_equip_slot("accessory2", "BIJOU 2")
	left_col.add_child(_slot_widgets["weapon"])
	left_col.add_child(_slot_widgets["accessory"])
	left_col.add_child(_slot_widgets["accessory2"])

	## Sprite central
	_hero_sprite = _make_sprite_placeholder()
	mid_hbox.add_child(_hero_sprite)

	## Col droite : tête, torse, bottes
	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 6)
	right_col.alignment = BoxContainer.ALIGNMENT_CENTER
	mid_hbox.add_child(right_col)

	_slot_widgets["head"]  = _make_equip_slot("head",  "TÊTE")
	_slot_widgets["torso"] = _make_equip_slot("torso", "TORSE")
	_slot_widgets["legs"]  = _make_equip_slot("legs",  "BOTTES")
	right_col.add_child(_slot_widgets["head"])
	right_col.add_child(_slot_widgets["torso"])
	right_col.add_child(_slot_widgets["legs"])


func _build_skill_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(row)

	for i : int in 4:
		var slot := _SkillSlot.new()
		slot.init(i, self)
		row.add_child(slot)
		_skill_btns.append(slot)


func _build_inventory_section(parent: VBoxContainer) -> void:
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 6)
	parent.add_child(header_row)

	var title := _make_section_label("Inventaire de la guilde")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title)

	_inv_filter = OptionButton.new()
	_inv_filter.add_theme_font_size_override("font_size", 9)
	_inv_filter.add_item("Tout",          0)
	_inv_filter.add_item("Armes",         1)
	_inv_filter.add_item("Armures",       2)
	_inv_filter.add_item("Accessoires",   3)
	_inv_filter.add_item("Consommables",  4)
	_inv_filter.selected = 0
	_inv_filter.item_selected.connect(func(_i: int) -> void: _refresh_inventory())
	header_row.add_child(_inv_filter)

	var inv_scroll := _InvDropZone.new()
	inv_scroll.init_drop(self)
	inv_scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	inv_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inv_scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	inv_scroll.custom_minimum_size    = Vector2(0, 90)
	parent.add_child(inv_scroll)

	_inv_grid = GridContainer.new()
	_inv_grid.columns = 5
	_inv_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inv_grid.add_theme_constant_override("h_separation", 4)
	_inv_grid.add_theme_constant_override("v_separation", 4)
	inv_scroll.add_child(_inv_grid)


# ─────────────────────────────────────────────
#  CALLBACKS SIGNAUX
# ─────────────────────────────────────────────
func _on_inspect_requested(hero_data: HeroData, _screen_pos: Vector2) -> void:
	_hero_id = hero_data.hero_id
	_data    = hero_data

	_info_name_lbl.text  = hero_data.hero_name
	_info_class_lbl.text = "%s  —  Niv. %d  [%s]" % [
		hero_data.hero_class.capitalize(), hero_data.level, hero_data.rank
	]

	_refresh_all()

	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5


func _on_need_changed(hero_id: int, need_name: String, new_value: float) -> void:
	if hero_id != _hero_id or not _panel.visible:
		return
	_set_bar(need_name, new_value)
	if need_name == "moral" and _moral_bar:
		_moral_bar.value = new_value


func _on_stat_changed(hero_id: int, stat_name: String, _new_value: float) -> void:
	if hero_id != _hero_id or not _panel.visible:
		return
	if stat_name == "hp" and _data:
		_set_bar("hp", _data.hp)
	_refresh_equip_slots()
	_refresh_inventory()


func _on_moral_effects_changed(hero_id: int, effects: Array) -> void:
	if hero_id != _hero_id or not _panel.visible:
		return
	_refresh_moral_effects(effects)


func _on_inventory_changed() -> void:
	if _panel.visible:
		_refresh_inventory()


func _on_tab_pressed(idx: int) -> void:
	_cur_tab = idx
	for i : int in _pages.size():
		_pages[i].visible = (i == idx)
	for i : int in _tab_btns.size():
		_style_tab_btn(_tab_btns[i], i == idx)


func _on_train_priority_changed(value: float, stat_key: String) -> void:
	if not _data:
		return
	var prop : String = _PRIORITY_PROP.get(stat_key, "")
	if prop != "":
		_data.set(prop, int(value))


func _on_job_selected(idx: int) -> void:
	if not _data:
		return
	_data.job = _job_option.get_item_id(idx)


func _on_center_view_pressed() -> void:
	if not _data:
		return
	var hero_node : Node = HeroManager.get_hero_node(_hero_id)
	if hero_node and hero_node is Node2D:
		EventBus.camera_focus_requested.emit((hero_node as Node2D).global_position)
	_close()


func _on_skills_pressed() -> void:
	if _data:
		_panel.hide()   ## masqué, pas fermé : _data reste intact
		EventBus.ui_panel_open_requested.emit("skills_panel", {"hero_data": _data})


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh_all() -> void:
	if not _data:
		return

	## Besoins (info tab)
	var hp_max : float = _data.hp_max if _data.hp_max > 0.0 else 100.0
	_bars["hp"].max_value = hp_max
	_set_bar("hp",            _data.hp)
	_set_bar("moral",         _data.moral)
	_set_bar("energy",        _data.energy)
	_set_bar("hunger",        _data.hunger)
	_set_bar("toilet",        _data.toilet)
	_set_bar("hygiene",       _data.hygiene)
	_set_bar("entertainment", _data.entertainment)

	## Stats de combat (stats tab)
	for stat in _STATS:
		var key : String = stat["key"]
		if _stat_val_lbls.has(key):
			_stat_val_lbls[key].text = "%.0f" % float(_data.get(key))
		if _train_sliders.has(key):
			var prop : String = _PRIORITY_PROP.get(key, "")
			_train_sliders[key].value = _data.get(prop) if prop != "" else 0

	## Stats métier
	for ws in _WORK_STATS:
		var key : String = ws["key"]
		var val : float  = float(_data.get(key))
		if _work_bars.has(key):
			_work_bars[key].value = minf(val, 100.0)
		if _work_val_lbls.has(key):
			_work_val_lbls[key].text = "%.1f" % val

	## Job
	if _job_option:
		_job_option.select(_job_option.get_item_index(_data.job))

	## Moral tab
	if _moral_bar:
		_moral_bar.value = _data.moral

	## Effets moraux
	var hero_node : Node = HeroManager.get_hero_node(_hero_id)
	if hero_node:
		var needs_comp : Node = hero_node.get_node_or_null("%HeroNeeds")
		_refresh_moral_effects(needs_comp.moral_effects if needs_comp else [])
	else:
		_refresh_moral_effects([])

	## Traits
	_refresh_traits(_data.traits)

	## Équipement + inventaire
	_refresh_equip_slots()
	_refresh_inventory()
	_refresh_skill_slots()
	_refresh_sprite()


func _set_bar(key: String, value: float) -> void:
	if not _bars.has(key):
		return
	var bar : ProgressBar = _bars[key]
	bar.value = minf(value, bar.max_value)
	var ratio : float = value / bar.max_value
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(2)
	if ratio >= 0.5:
		style.bg_color = _COLOR_GOOD
	elif ratio >= 0.25:
		style.bg_color = _COLOR_WARNING
	else:
		style.bg_color = _COLOR_DANGER
	bar.add_theme_stylebox_override("fill", style)
	if _bar_labels.has(key):
		_bar_labels[key].text = "%d" % int(value)


func _refresh_moral_effects(effects: Array) -> void:
	if not _effects_box:
		return
	for child in _effects_box.get_children():
		child.queue_free()
	if effects.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun effet actif"
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.modulate = Color(0.55, 0.55, 0.55)
		_effects_box.add_child(lbl)
		return
	for effect in effects:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		var n_lbl := Label.new()
		n_lbl.text = effect.get("name", "?")
		n_lbl.add_theme_font_size_override("font_size", 9)
		n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(n_lbl)
		var val : float = effect.get("value", effect.get("start_value", 0.0))
		var v_lbl := Label.new()
		v_lbl.text = "%+.0f" % val
		v_lbl.add_theme_font_size_override("font_size", 9)
		v_lbl.modulate = _COLOR_GOOD if val > 0.0 else _COLOR_DANGER
		row.add_child(v_lbl)
		_effects_box.add_child(row)


func _refresh_traits(traits: Array) -> void:
	if not _traits_box:
		return
	for child in _traits_box.get_children():
		child.queue_free()
	if traits.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun trait"
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.modulate = Color(0.55, 0.55, 0.55)
		_traits_box.add_child(lbl)
		return
	for trait_id : String in traits:
		var tdef     : Dictionary = TraitLibrary.get_trait(trait_id)
		var positive : bool       = tdef.get("positive", true)
		var accent   : Color      = Color(0.20, 0.70, 0.30) if positive else Color(0.80, 0.25, 0.20)
		var badge := PanelContainer.new()
		badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var bs := StyleBoxFlat.new()
		bs.bg_color = accent.darkened(0.55)
		bs.border_color = accent
		bs.border_width_left = 3
		bs.set_corner_radius_all(3)
		bs.content_margin_left = 8
		bs.content_margin_right = 5
		bs.content_margin_top = 3
		bs.content_margin_bottom = 3
		var desc : String = tdef.get("description", "")
		if desc != "":
			badge.tooltip_text = desc
		badge.add_theme_stylebox_override("panel", bs)
		_traits_box.add_child(badge)
		var inner := HBoxContainer.new()
		inner.add_theme_constant_override("separation", 4)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(inner)
		var icon_lbl := Label.new()
		icon_lbl.text = "+" if positive else "−"
		icon_lbl.add_theme_font_size_override("font_size", 10)
		icon_lbl.add_theme_color_override("font_color", accent)
		icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(icon_lbl)
		var name_lbl := Label.new()
		name_lbl.text = tdef.get("label", trait_id)
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(name_lbl)


func _refresh_equip_slots() -> void:
	if not _data:
		return
	for slot_name : String in _slot_widgets:
		(_slot_widgets[slot_name] as _EquipSlot).refresh(_data)


func _refresh_inventory() -> void:
	if not _inv_grid or not _data:
		return
	for child in _inv_grid.get_children():
		child.queue_free()

	## Catégorie active (0=tout 1=armes 2=armures 3=accessoires 4=consommables)
	const _FILTER_TYPE := ["", "weapon", "armor", "accessory", "consumable"]
	var filter_idx  : int    = _inv_filter.selected if _inv_filter else 0
	var filter_type : String = _FILTER_TYPE[filter_idx]

	var found : bool = false
	for i : int in GuildInventoryManager.slots.size():
		var sd = GuildInventoryManager.slots[i]
		if sd == null:
			continue
		var item : Dictionary = EquipmentLibrary.get_item(sd["item_id"])
		if item.is_empty():
			continue
		if filter_type != "" and item.get("type", "") != filter_type:
			continue
		found = true
		var inv_slot := _InvSlot.new()
		inv_slot.init(i, item, self)
		_inv_grid.add_child(inv_slot)

	if not found:
		var lbl := Label.new()
		lbl.text = "Aucun item" if filter_type != "" else "Inventaire vide"
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = Color(0.45, 0.45, 0.45)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_inv_grid.add_child(lbl)


func _refresh_skill_slots() -> void:
	if not _data:
		return
	for slot in _skill_btns:
		(slot as _SkillSlot).refresh(_data)


func _refresh_sprite() -> void:
	if not _hero_sprite or not _data:
		return
	for child in _hero_sprite.get_children():
		child.queue_free()

	var cls_colors : Dictionary = {
		"warrior":    Color(0.70, 0.20, 0.20), "mage":       Color(0.20, 0.20, 0.80),
		"roublard":   Color(0.20, 0.55, 0.20), "chasseur":   Color(0.60, 0.45, 0.10),
		"guerisseur": Color(0.75, 0.75, 0.20), "invocateur": Color(0.60, 0.20, 0.75),
	}
	var col : Color = cls_colors.get(_data.hero_class, Color(0.35, 0.35, 0.45))

	var bg := ColorRect.new()
	bg.color = col.darkened(0.40)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hero_sprite.add_child(bg)

	var lbl := Label.new()
	lbl.text = _data.hero_class.capitalize()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.modulate = col.lightened(0.5)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hero_sprite.add_child(lbl)


# ─────────────────────────────────────────────
#  INPUT — ferme sur ESC ou clic hors panel
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if _inv_ctx_panel and _inv_ctx_panel.visible:
			var cr := Rect2(_inv_ctx_panel.global_position, _inv_ctx_panel.size)
			if not cr.has_point(get_viewport().get_mouse_position()):
				_inv_ctx_panel.hide()
				return

	if not _panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("click"):
		var r := Rect2(_panel.global_position, _panel.size)
		if not r.has_point(get_viewport().get_mouse_position()):
			_close()


func _close() -> void:
	_panel.hide()
	_hero_id = -1
	_data    = null


# ─────────────────────────────────────────────
#  HELPERS UI
# ─────────────────────────────────────────────
func _build_inv_context_menu() -> void:
	_inv_ctx_panel = PanelContainer.new()
	add_child(_inv_ctx_panel)
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(0.14, 0.14, 0.18)
	sty.border_color = Color(0.45, 0.45, 0.55)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(3)
	_inv_ctx_panel.add_theme_stylebox_override("panel", sty)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	_inv_ctx_panel.add_child(vb)
	var split_btn := Button.new()
	split_btn.name = "SplitBtn"
	split_btn.text = "Diviser le stack"
	split_btn.add_theme_font_size_override("font_size", 9)
	split_btn.flat = true
	split_btn.pressed.connect(_on_inv_ctx_split)
	vb.add_child(split_btn)
	var one_btn := Button.new()
	one_btn.name = "OneBtn"
	one_btn.text = "Prendre 1"
	one_btn.add_theme_font_size_override("font_size", 9)
	one_btn.flat = true
	one_btn.pressed.connect(_on_inv_ctx_take_one)
	vb.add_child(one_btn)
	var drop_btn := Button.new()
	drop_btn.text = "Jeter l'item"
	drop_btn.add_theme_font_size_override("font_size", 9)
	drop_btn.flat = true
	drop_btn.modulate = Color(1.0, 0.45, 0.45)
	drop_btn.pressed.connect(_on_inv_ctx_drop)
	vb.add_child(drop_btn)
	_inv_ctx_panel.hide()


func show_inv_context(inv_slot_idx: int, pos: Vector2) -> void:
	_inv_ctx_slot = inv_slot_idx
	var sd = GuildInventoryManager.slots[inv_slot_idx]
	var stackable : bool = sd != null and GuildInventoryManager._is_stackable(sd["item_id"])
	var qty : int = sd["quantity"] if sd != null else 0
	var split_btn := _inv_ctx_panel.find_child("SplitBtn", true, false) as Button
	var one_btn   := _inv_ctx_panel.find_child("OneBtn",   true, false) as Button
	if split_btn: split_btn.visible = stackable and qty > 1
	if one_btn:   one_btn.visible   = stackable and qty > 1
	_inv_ctx_panel.show()
	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	var p  := pos
	if p.x + _inv_ctx_panel.size.x > vp.x:
		p.x = pos.x - _inv_ctx_panel.size.x
	if p.y + _inv_ctx_panel.size.y > vp.y:
		p.y = vp.y - _inv_ctx_panel.size.y
	_inv_ctx_panel.position = p


func _on_inv_ctx_split() -> void:
	GuildInventoryManager.split_stack(_inv_ctx_slot)
	_inv_ctx_panel.hide()


func _on_inv_ctx_take_one() -> void:
	var empty := GuildInventoryManager._find_empty_slot()
	if empty >= 0:
		GuildInventoryManager.move_one(_inv_ctx_slot, empty)
	_inv_ctx_panel.hide()


func _on_inv_ctx_drop() -> void:
	GuildInventoryManager.remove_from_slot(_inv_ctx_slot)
	_inv_ctx_panel.hide()


## Équipe automatiquement un item depuis l'inventaire vers le bon slot du héros.
func auto_equip(inv_slot_idx: int, item: Dictionary) -> void:
	if not _data:
		return
	if not _is_equippable(_data, item):
		return
	var type   : String = item.get("type", "")
	var target : String = ""
	match type:
		"weapon":
			target = "weapon"
		"armor":
			target = item.get("slot", "torso")
		"accessory":
			target = "accessory" if _data.equipment.get("accessory", "") == "" else "accessory2"
		"consumable":
			target = "consumable" if _data.equipment.get("consumable", "") == "" else "consumable2"
	if target == "":
		return
	equip_from_inventory(inv_slot_idx, item, target)


func _make_section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.80, 0.80, 0.55))
	return lbl


func _make_equip_slot(slot_id: String, label_text: String) -> _EquipSlot:
	var s := _EquipSlot.new()
	s.init(slot_id, label_text, self)
	return s



func _make_sprite_placeholder() -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(64, 112)
	var s := StyleBoxFlat.new()
	s.bg_color     = Color(0.10, 0.10, 0.14)
	s.border_color = Color(0.35, 0.30, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	p.add_theme_stylebox_override("panel", s)
	return p


func _style_tab_btn(btn: Button, active: bool) -> void:
	var sty := StyleBoxFlat.new()
	sty.bg_color = _TAB_ACTIVE if active else _TAB_INACTIVE
	sty.set_corner_radius_all(3)
	sty.content_margin_left   = 8
	sty.content_margin_right  = 8
	sty.content_margin_top    = 4
	sty.content_margin_bottom = 4
	btn.add_theme_stylebox_override("normal",   sty)
	btn.add_theme_stylebox_override("hover",    sty)
	btn.add_theme_stylebox_override("pressed",  sty)
	btn.add_theme_color_override("font_color", Color.WHITE)


func _is_equippable(hero: HeroData, item: Dictionary) -> bool:
	var type    : String = item.get("type", "")
	var subtype : String = item.get("subtype", "")
	match type:
		"weapon":     return subtype in hero.weapon_types
		"armor":      return subtype == hero.armor_type
		"accessory":  return true
		"consumable": return true
	return false


func _reposition(screen_pos: Vector2) -> void:
	var vp   := get_viewport().get_visible_rect().size
	var obj_size := _panel.size
	var pos  : Vector2
	if screen_pos == Vector2(-1.0, -1.0):
		pos = (vp - obj_size) * 0.5
	else:
		pos = screen_pos + Vector2(14.0, -obj_size.y * 0.5)
		pos.x = clamp(pos.x, 0.0, vp.x - obj_size.x)
		pos.y = clamp(pos.y, 0.0, vp.y - obj_size.y)
	_panel.position = pos


# ─────────────────────────────────────────────
#  ACTIONS D'ÉQUIPEMENT (appelées par les slots)
# ─────────────────────────────────────────────
func swap_skill_slots(from_idx: int, to_idx: int) -> void:
	if not _data or from_idx == to_idx:
		return
	## S'assurer que les deux positions existent (padding avec "")
	while _data.equipped_skills.size() <= maxi(from_idx, to_idx):
		_data.equipped_skills.append("")
	var tmp : String = _data.equipped_skills[from_idx]
	_data.equipped_skills[from_idx] = _data.equipped_skills[to_idx]
	_data.equipped_skills[to_idx]   = tmp
	## Supprimer les "" en fin de tableau
	while not _data.equipped_skills.is_empty() and _data.equipped_skills.back() == "":
		_data.equipped_skills.resize(_data.equipped_skills.size() - 1)
	_refresh_skill_slots()


## qty = -1 → prend tout le stack ; qty > 0 → prend exactement qty (consommables uniquement)
func equip_from_inventory(inv_slot_idx: int, item: Dictionary, target_slot: String, qty: int = -1) -> void:
	if not _data:
		return
	var is_conso : bool = item.get("type", "") == "consumable"

	## Si le slot cible est déjà occupé, renvoyer l'item dans l'inventaire
	var current_item_id : String = _data.equipment.get(target_slot, "")
	if current_item_id != "":
		var return_qty : int = _data.consumable_quantities.get(target_slot, 1) if is_conso else 1
		if not GuildInventoryManager.add_item(current_item_id, return_qty):
			EventBus.ui_notification_requested.emit("Inventaire plein.", "warning")
			return
		_data.unequip(target_slot)
		if is_conso:
			_data.consumable_quantities[target_slot] = 0

	## Quantité à transférer
	var inv_sd = GuildInventoryManager.slots[inv_slot_idx]
	var available : int = inv_sd.get("quantity", 1) if inv_sd != null else 1
	var inv_qty : int = available
	if is_conso and qty > 0:
		inv_qty = mini(qty, available)

	## Équiper
	_data.equipment[target_slot] = item["id"]
	if is_conso:
		_data.consumable_quantities[target_slot] = inv_qty
	GuildInventoryManager.remove_from_slot(inv_slot_idx, inv_qty)
	_refresh_equip_slots()
	_refresh_inventory()
	EventBus.hero_stat_changed.emit(_data.hero_id, "equipment", 0.0)


func unequip_slot(slot_name: String) -> void:
	if not _data:
		return
	var item_id : String = _data.equipment.get(slot_name, "")
	if item_id == "":
		return
	var item : Dictionary = EquipmentLibrary.get_item(item_id)
	var return_qty : int = 1
	if item.get("type", "") == "consumable":
		return_qty = _data.consumable_quantities.get(slot_name, 1)
	if GuildInventoryManager.add_item(item_id, return_qty):
		_data.equipment.erase(slot_name)
		if _data.consumable_quantities.has(slot_name):
			_data.consumable_quantities[slot_name] = 0
		_refresh_equip_slots()
		_refresh_inventory()
		EventBus.hero_stat_changed.emit(_data.hero_id, "equipment", 0.0)
	else:
		EventBus.ui_notification_requested.emit("Inventaire plein — impossible de déséquiper.", "warning")


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Slot d'équipement (paperdoll)
# ─────────────────────────────────────────────
class _EquipSlot extends PanelContainer:

	const _TYPE_COLORS : Dictionary = {
		"weapon":     Color(0.55, 0.55, 0.80),
		"head":       Color(0.25, 0.65, 0.50),
		"torso":      Color(0.20, 0.60, 0.45),
		"legs":       Color(0.18, 0.55, 0.40),
		"accessory":  Color(0.85, 0.75, 0.15),
		"accessory2": Color(0.85, 0.75, 0.15),
		"consumable": Color(0.80, 0.15, 0.15),
		"consumable2":Color(0.80, 0.15, 0.15),
	}

	## Quels types d'items ce slot accepte
	const _SLOT_ACCEPTS : Dictionary = {
		"weapon":     ["weapon"],
		"head":       ["armor"],
		"torso":      ["armor"],
		"legs":       ["armor"],
		"accessory":  ["accessory"],
		"accessory2": ["accessory"],
		"consumable": ["consumable"],
		"consumable2":["consumable"],
	}

	var _slot_id          : String
	var _panel_ref        : Object   ## HeroInspectPanel
	var _item_lbl         : Label
	var _s_empty          : StyleBoxFlat
	var _s_full           : StyleBoxFlat
	var _s_hover          : StyleBoxFlat
	var _s_candrop        : StyleBoxFlat
	var _last_click_msec  : int = 0


	func init(slot_id: String, label_text: String, panel_ref: Object) -> void:
		_slot_id   = slot_id
		_panel_ref = panel_ref
		custom_minimum_size = Vector2(58, 52)

		_s_empty   = _mk_sty(Color(0.10, 0.10, 0.14), Color(0.28, 0.28, 0.42), 1)
		_s_full    = _mk_sty(Color(0.14, 0.14, 0.20), Color(0.50, 0.50, 0.75), 2)
		_s_hover   = _mk_sty(Color(0.18, 0.18, 0.28), Color(0.70, 0.70, 1.00), 2)
		_s_candrop = _mk_sty(Color(0.08, 0.22, 0.08), Color(0.25, 0.85, 0.25), 2)
		add_theme_stylebox_override("panel", _s_empty)

		var m := MarginContainer.new()
		for side : String in ["left", "right", "top", "bottom"]:
			m.add_theme_constant_override("margin_" + side, 4)
		add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		m.add_child(vb)

		var type_lbl := Label.new()
		type_lbl.text = label_text
		type_lbl.add_theme_font_size_override("font_size", 7)
		type_lbl.modulate = Color(0.45, 0.45, 0.55)
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(type_lbl)

		_item_lbl = Label.new()
		_item_lbl.add_theme_font_size_override("font_size", 8)
		_item_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_item_lbl.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
		_item_lbl.size_flags_vertical  = Control.SIZE_EXPAND_FILL
		vb.add_child(_item_lbl)

		mouse_entered.connect(func() -> void:
			var hero : HeroData = _panel_ref._data
			if hero and hero.equipment.get(_slot_id, "") != "":
				add_theme_stylebox_override("panel", _s_hover)
		)
		mouse_exited.connect(_restore_style)


	func refresh(hero_data: HeroData) -> void:
		var item_id : String = hero_data.equipment.get(_slot_id, "")
		if item_id == "":
			_item_lbl.text     = "—"
			_item_lbl.modulate = Color(0.30, 0.30, 0.30)
			add_theme_stylebox_override("panel", _s_empty)
		else:
			var item : Dictionary = EquipmentLibrary.get_item(item_id)
			var label : String = item.get("label", item_id)
			if item.get("type", "") == "consumable":
				var qty : int = hero_data.consumable_quantities.get(_slot_id, 1)
				if qty > 1:
					label = "%s ×%d" % [label, qty]
			_item_lbl.text     = label
			_item_lbl.modulate = _TYPE_COLORS.get(item.get("type", ""), Color.GRAY)
			add_theme_stylebox_override("panel", _s_full)


	func _get_drag_data(_at: Vector2) -> Variant:
		var hero : HeroData = _panel_ref._data
		if not hero:
			return null
		var item_id : String = hero.equipment.get(_slot_id, "")
		if item_id == "":
			return null
		var item : Dictionary = EquipmentLibrary.get_item(item_id)
		var qty : int = 1
		if item.get("type", "") == "consumable":
			qty = hero.consumable_quantities.get(_slot_id, 1)
		var preview := ColorRect.new()
		preview.color = _TYPE_COLORS.get(_slot_id, Color(0.50, 0.50, 0.80))
		preview.modulate.a = 0.75
		preview.custom_minimum_size = Vector2(44, 44)
		set_drag_preview(preview)
		return {"from_equip_slot": _slot_id, "item": item, "qty": qty}


	func _gui_input(event: InputEvent) -> void:
		if not (event is InputEventMouseButton) or not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var now : int = Time.get_ticks_msec()
			if now - _last_click_msec < 400:
				_panel_ref.unequip_slot(_slot_id)
				_last_click_msec = 0
				accept_event()
			else:
				_last_click_msec = now


	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		if not (data is Dictionary) or not data.has("from_inv_slot"):
			return false
		var item : Dictionary = data.get("item", {})
		var type : String = item.get("type", "")
		var accepted : Array = _SLOT_ACCEPTS.get(_slot_id, [])
		if type not in accepted:
			return false
		## Pour les armures : vérifier que le slot de l'item correspond
		if type == "armor":
			var item_slot : String = item.get("slot", "torso")
			## head → head, torso → torso, legs → legs
			if _slot_id in ["head", "torso", "legs"]:
				return item_slot == _slot_id
			return false
		return true


	func _drop_data(_at: Vector2, data: Variant) -> void:
		if data.has("from_inv_slot"):
			var item : Dictionary = data["item"]
			var qty : int = -1
			if Input.is_key_pressed(KEY_SHIFT) and item.get("type", "") == "consumable":
				var sd = GuildInventoryManager.slots[data["from_inv_slot"]]
				if sd != null and sd["quantity"] > 1:
					qty = maxi(1, sd["quantity"] / 2)
			_panel_ref.equip_from_inventory(data["from_inv_slot"], item, _slot_id, qty)


	func _restore_style() -> void:
		var hero : HeroData = _panel_ref._data
		if hero and hero.equipment.get(_slot_id, "") != "":
			add_theme_stylebox_override("panel", _s_full)
		else:
			add_theme_stylebox_override("panel", _s_empty)


	func _mk_sty(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = bg
		s.border_color = border
		s.set_border_width_all(bw)
		s.set_corner_radius_all(4)
		return s


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Slot inventaire (draggable)
# ─────────────────────────────────────────────
class _InvSlot extends PanelContainer:

	const _TYPE_COLORS : Dictionary = {
		"weapon":     Color(0.55, 0.55, 0.80),
		"armor":      Color(0.25, 0.65, 0.50),
		"accessory":  Color(0.85, 0.75, 0.15),
		"consumable": Color(0.80, 0.15, 0.15),
	}

	var _inv_idx          : int
	var _item             : Dictionary
	var _panel_ref        : Object
	var _last_click_msec  : int = 0


	func init(inv_idx: int, item: Dictionary, panel_ref: Object) -> void:
		_inv_idx   = inv_idx
		_item      = item
		_panel_ref = panel_ref
		custom_minimum_size = Vector2(54, 54)

		var rank_colors : Dictionary = {
			"F": Color(0.55, 0.55, 0.55), "E": Color(0.30, 0.75, 0.30),
			"D": Color(0.25, 0.50, 1.00), "C": Color(0.75, 0.55, 0.10),
			"B": Color(0.70, 0.10, 0.80), "A": Color(1.00, 0.45, 0.10),
			"S": Color(1.00, 0.85, 0.10),
		}
		var rank_col : Color = rank_colors.get(item.get("rank", "F"), Color.GRAY)
		var s := StyleBoxFlat.new()
		s.bg_color    = Color(0.12, 0.12, 0.18)
		s.border_color = rank_col.darkened(0.3)
		s.set_border_width_all(2)
		s.set_corner_radius_all(4)
		add_theme_stylebox_override("panel", s)

		var m := MarginContainer.new()
		for side : String in ["left", "right", "top", "bottom"]:
			m.add_theme_constant_override("margin_" + side, 4)
		add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		m.add_child(vb)

		## Couleur type
		var icon := ColorRect.new()
		icon.color = _TYPE_COLORS.get(item.get("type", ""), Color.GRAY)
		icon.custom_minimum_size = Vector2(0, 26)
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(icon)

		var bottom_row := HBoxContainer.new()
		bottom_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(bottom_row)

		var rank_lbl := Label.new()
		rank_lbl.text = item.get("rank", "?")
		rank_lbl.add_theme_font_size_override("font_size", 8)
		rank_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rank_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_LEFT
		rank_lbl.modulate     = rank_col
		rank_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bottom_row.add_child(rank_lbl)

		var sd = GuildInventoryManager.slots[inv_idx]
		var qty : int = sd.get("quantity", 1) if sd != null else 1
		if qty > 1:
			var qty_lbl := Label.new()
			qty_lbl.text = "×%d" % qty
			qty_lbl.add_theme_font_size_override("font_size", 8)
			qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			qty_lbl.modulate     = Color(0.95, 0.95, 0.70)
			qty_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bottom_row.add_child(qty_lbl)

		tooltip_text = "%s\n%s Rang %s" % [
			item.get("label", "?"),
			item.get("subtype", item.get("type", "")).capitalize(),
			item.get("rank", "?"),
		]

		mouse_entered.connect(func() -> void: modulate = Color(1.25, 1.25, 1.25))
		mouse_exited.connect(func() -> void:  modulate = Color.WHITE)


	func _get_drag_data(_at: Vector2) -> Variant:
		var col     : Color = _TYPE_COLORS.get(_item.get("type", ""), Color.GRAY)
		var preview := ColorRect.new()
		preview.color               = col
		preview.custom_minimum_size = Vector2(44, 44)
		preview.modulate.a          = 0.80
		set_drag_preview(preview)
		return {"from_inv_slot": _inv_idx, "item": _item}


	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		if not (data is Dictionary):
			return false
		if data.has("from_equip_slot"):
			return true
		if data.has("from_inv_slot") and data["from_inv_slot"] != _inv_idx:
			return true
		return false


	func _drop_data(_at: Vector2, data: Variant) -> void:
		if data.has("from_equip_slot"):
			_panel_ref.unequip_slot(data["from_equip_slot"])
		elif data.has("from_inv_slot"):
			if Input.is_key_pressed(KEY_SHIFT):
				GuildInventoryManager.move_half(data["from_inv_slot"], _inv_idx)
			else:
				GuildInventoryManager.move_item(data["from_inv_slot"], _inv_idx)


	func _gui_input(event: InputEvent) -> void:
		if not (event is InputEventMouseButton) or not event.pressed:
			return
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var now : int = Time.get_ticks_msec()
				if now - _last_click_msec < 400:
					_panel_ref.auto_equip(_inv_idx, _item)
					_last_click_msec = 0
					accept_event()
				else:
					_last_click_msec = now
			MOUSE_BUTTON_RIGHT:
				_panel_ref.show_inv_context(_inv_idx, global_position + Vector2(size.x, 0))
				accept_event()


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Drop zone inventaire (accepte drag depuis equip slots)
# ─────────────────────────────────────────────
class _InvDropZone extends ScrollContainer:

	var _panel_ref : Object

	func init_drop(panel_ref: Object) -> void:
		_panel_ref = panel_ref

	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		return data is Dictionary and data.has("from_equip_slot")

	func _drop_data(_at: Vector2, data: Variant) -> void:
		_panel_ref.unequip_slot(data["from_equip_slot"])


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Slot de compétence équipée (drag & drop pour réordonner)
# ─────────────────────────────────────────────
class _SkillSlot extends PanelContainer:

	var _slot_idx  : int
	var _panel_ref : Object
	var _skill_id  : String = ""
	var _lbl       : Label
	var _s_empty   : StyleBoxFlat
	var _s_full    : StyleBoxFlat
	var _s_candrop : StyleBoxFlat


	func init(slot_idx: int, panel_ref: Object) -> void:
		_slot_idx  = slot_idx
		_panel_ref = panel_ref
		custom_minimum_size = Vector2(62, 52)

		_s_empty   = _mk_sty(Color(0.10, 0.10, 0.14), Color(0.30, 0.30, 0.50), 1)
		_s_full    = _mk_sty(Color(0.12, 0.15, 0.22), Color(0.40, 0.55, 0.90), 2)
		_s_candrop = _mk_sty(Color(0.08, 0.22, 0.08), Color(0.25, 0.85, 0.25), 2)
		add_theme_stylebox_override("panel", _s_empty)

		_lbl = Label.new()
		_lbl.add_theme_font_size_override("font_size", 8)
		_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_lbl)


	func refresh(hero_data: HeroData) -> void:
		_skill_id = hero_data.equipped_skills[_slot_idx] if _slot_idx < hero_data.equipped_skills.size() else ""
		if _skill_id != "":
			var sdef : Dictionary = SkillLibrary.get_skill(_skill_id)
			_lbl.text    = sdef.get("label", _skill_id)
			_lbl.modulate = Color(0.5, 0.9, 1.0)
			tooltip_text = sdef.get("description", "")
			add_theme_stylebox_override("panel", _s_full)
		else:
			_lbl.text    = "—"
			_lbl.modulate = Color(0.35, 0.35, 0.35)
			tooltip_text = ""
			add_theme_stylebox_override("panel", _s_empty)


	func _get_drag_data(_at: Vector2) -> Variant:
		if _skill_id == "":
			return null
		var preview := Label.new()
		preview.text = _lbl.text
		preview.add_theme_font_size_override("font_size", 9)
		preview.modulate = Color(0.5, 0.9, 1.0)
		set_drag_preview(preview)
		return {"from_skill_slot": _slot_idx, "skill_id": _skill_id}


	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		if not (data is Dictionary):
			return false
		return data.has("from_skill_slot") and data["from_skill_slot"] != _slot_idx


	func _drop_data(_at: Vector2, data: Variant) -> void:
		if data.has("from_skill_slot"):
			_panel_ref.swap_skill_slots(data["from_skill_slot"], _slot_idx)


	func _mk_sty(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = bg
		s.border_color = border
		s.set_border_width_all(bw)
		s.set_corner_radius_all(3)
		return s
