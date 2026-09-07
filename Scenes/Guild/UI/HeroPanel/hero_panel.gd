## hero_panel.gd
## Panneau de gestion des héros. Deux vues : Hero | Planning.
extends PanelContainer

const HERO_ROW_SCENE := preload("res://Scenes/Guild/UI/HeroPanel/HeroListRow.tscn")
var _planning_row_scene : PackedScene = null

# ─── Vues ────────────────────────────────────
@onready var list_view     : ScrollContainer = $MarginContainer/VBoxContainer/ContentStack/HeroListView
@onready var planning_view : VBoxContainer   = $MarginContainer/VBoxContainer/ContentStack/PlanningView

# ─── Conteneurs ──────────────────────────────
@onready var hero_list_vbox : VBoxContainer = %HeroListVBox
@onready var planning_vbox  : VBoxContainer = %PlanningVBox

# ─── Planning contrôles ──────────────────────
@onready var activity_btns  : HBoxContainer = %ActivityBtns
@onready var preset_btns    : HBoxContainer = %PresetBtns

var _selected_activity  : String = "sleep"
var _selected_preset    : String = ""
var _planning_rows      : Array  = []


# ─────────────────────────────────────────────
#  COULEURS ACTIVITÉ
# ─────────────────────────────────────────────
const ACTIVITY_COLORS := {
	"sleep": Color(0.20, 0.30, 0.70),
	"work":  Color(0.80, 0.55, 0.10),
	"train": Color(0.15, 0.60, 0.25),
	"free":  Color(0.40, 0.40, 0.45),
}


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_planning_row_scene = load("res://Scenes/Guild/UI/HeroPanel/PlanningRow.tscn")

	## Assigne les meta et couleurs aux boutons d'activité
	var activity_map := {
		"sleepbtn": "sleep",
		"workbtn":  "work",
		"trainbtn": "train",
		"freebtn":  "free",
	}
	for btn_name in activity_map:
		var btn := activity_btns.get_node_or_null(btn_name)
		if btn:
			btn.set_meta("activity", activity_map[btn_name])
			_style_activity_btn(btn, activity_map[btn_name], false)

	## Assigne les meta aux boutons de préréglage
	var preset_map := {
		"MorningBtn":   "morning",
		"NightWorkBtn": "night",
		"TrainingBtn":  "training",
		"FreeDayBtn":   "free_day",
	}
	for btn_name in preset_map:
		var btn := preset_btns.get_node_or_null(btn_name)
		if btn:
			btn.set_meta("preset", preset_map[btn_name])

	EventBus.hero_hired.connect(_on_hero_hired)
	EventBus.hero_fired.connect(_on_hero_fired)
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.ui_panel_open_requested.connect(_on_open_requested)

	for data in HeroManager.get_all_data():
		_add_hero_row(data)
		_add_planning_row(data)

	hide()
	_show_list()
	_select_activity("sleep")


func _exit_tree() -> void:
	if EventBus.hero_hired.is_connected(_on_hero_hired):
		EventBus.hero_hired.disconnect(_on_hero_hired)
	if EventBus.hero_fired.is_connected(_on_hero_fired):
		EventBus.hero_fired.disconnect(_on_hero_fired)
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────
func load_hero(_hero_data: Resource) -> void:
	_show_list()


func get_selected_activity() -> String:
	return _selected_activity


func get_selected_preset() -> String:
	return _selected_preset


# ─────────────────────────────────────────────
#  VUES
# ─────────────────────────────────────────────
func _show_list() -> void:
	list_view.show()
	planning_view.hide()


func _show_planning() -> void:
	list_view.hide()
	planning_view.show()


func _on_list_tab_pressed()     -> void: _show_list()
func _on_planning_tab_pressed() -> void: _show_planning()


func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "hero_panel":
		hide()
		return
	show()
	await get_tree().process_frame
	position = (get_viewport().get_visible_rect().size - size) * 0.5
	UIState.menu_open = true


func _on_close_pressed() -> void:
	hide()
	UIState.menu_open = false
	EventBus.hero_deselected.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("click"):
		var rect := Rect2(global_position, size)
		if not rect.has_point(get_viewport().get_mouse_position()):
			_on_close_pressed()


# ─────────────────────────────────────────────
#  LISTE DES HÉROS
# ─────────────────────────────────────────────
func _add_hero_row(hero_data: HeroData) -> void:
	var row = HERO_ROW_SCENE.instantiate()
	row.name = "Row_%d" % hero_data.hero_id
	hero_list_vbox.add_child(row)
	row.setup(hero_data)


func _on_hero_hired(hero_data: Resource) -> void:
	_add_hero_row(hero_data)
	_add_planning_row(hero_data)


func _on_hero_fired(hero_id: int) -> void:
	var list_node : Node = hero_list_vbox.get_node_or_null("Row_%d" % hero_id)
	if list_node:
		list_node.queue_free()
	var plan_node : Node = planning_vbox.get_node_or_null("Plan_%d" % hero_id)
	if plan_node:
		plan_node.queue_free()
		_planning_rows = _planning_rows.filter(func(r : Node) -> bool: return r != plan_node)


# ─────────────────────────────────────────────
#  PLANNING — LIGNES
# ─────────────────────────────────────────────
func _add_planning_row(hero_data: HeroData) -> void:
	var row : Node
	if _planning_row_scene:
		row = _planning_row_scene.instantiate()
	if not row or not row.has_method("setup"):
		if row:
			row.queue_free()
		var script = load("res://Scenes/Guild/UI/HeroPanel/planning_row.gd")
		row = HBoxContainer.new()
		row.set_script(script)
		var name_lbl := Label.new()
		name_lbl.name = "NameLabel"
		name_lbl.custom_minimum_size = Vector2(72, 0)
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.clip_contents = true
		row.add_child(name_lbl)
		var hours_hbox := HBoxContainer.new()
		hours_hbox.name = "HoursContainer"
		hours_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hours_hbox.add_theme_constant_override("separation", 1)
		row.add_child(hours_hbox)

	row.name = "Plan_%d" % hero_data.hero_id
	planning_vbox.add_child(row)
	row.setup(hero_data, self)
	_planning_rows.append(row)


func _on_hour_changed(hour: int) -> void:
	for row in _planning_rows:
		if is_instance_valid(row):
			row.highlight_current_hour(hour)


# ─────────────────────────────────────────────
#  PLANNING — ACTIVITÉ
# ─────────────────────────────────────────────
func _on_sleep_pressed() -> void: _select_activity("sleep")
func _on_work_pressed()  -> void: _select_activity("work")
func _on_train_pressed() -> void: _select_activity("train")
func _on_free_pressed()  -> void: _select_activity("free")


func _select_activity(activity: String) -> void:
	_selected_activity = activity
	_selected_preset   = ""
	_refresh_preset_highlight()
	_refresh_activity_highlight()


func _style_activity_btn(btn: Button, activity: String, active: bool) -> void:
	var color : Color = ACTIVITY_COLORS.get(activity, Color.GRAY)
	var style := StyleBoxFlat.new()
	style.bg_color = color if active else color.darkened(0.4)
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left   = 8
	style.content_margin_right  = 8
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	if active:
		style.border_width_left   = 2
		style.border_width_right  = 2
		style.border_width_top    = 2
		style.border_width_bottom = 2
		style.border_color = Color.WHITE
	btn.add_theme_stylebox_override("normal",  style)
	btn.add_theme_stylebox_override("hover",   style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color.WHITE)


func _refresh_activity_highlight() -> void:
	for btn in activity_btns.get_children():
		var activity : String = btn.get_meta("activity", "free")
		_style_activity_btn(btn, activity, activity == _selected_activity)


# ─────────────────────────────────────────────
#  PLANNING — PRÉRÉGLAGES
# ─────────────────────────────────────────────
func _on_morning_pressed()    -> void: _select_preset("morning")
func _on_night_work_pressed() -> void: _select_preset("night")
func _on_training_pressed()   -> void: _select_preset("training")
func _on_free_day_pressed()   -> void: _select_preset("free_day")


func _select_preset(preset_id: String) -> void:
	_selected_preset = "" if _selected_preset == preset_id else preset_id
	_selected_activity = ""
	_refresh_activity_highlight()
	_refresh_preset_highlight()


func _refresh_preset_highlight() -> void:
	for btn in preset_btns.get_children():
		var is_active = btn.get_meta("preset", "") == _selected_preset and _selected_preset != ""
		btn.modulate = Color.WHITE if is_active else Color(1, 1, 1, 0.55)


func _apply_preset_to_hero(hero_id: int) -> void:
	if _selected_preset == "":
		return
	var preset := _build_preset(_selected_preset)
	for row in _planning_rows:
		if is_instance_valid(row) and row._data and row._data.hero_id == hero_id:
			row._data.planning = preset.duplicate()
			row.refresh()
			break


func _build_preset(preset_id: String) -> Dictionary:
	var p := {}
	match preset_id:
		"morning":
			for h in range(24):
				if h < 6:    p[h] = "sleep"
				elif h < 8:  p[h] = "free"
				elif h < 12: p[h] = "work"
				elif h < 13: p[h] = "free"
				elif h < 18: p[h] = "work"
				elif h < 22: p[h] = "free"
				else:        p[h] = "sleep"
		"night":
			for h in range(24):
				if h < 4:    p[h] = "work"
				elif h < 10: p[h] = "sleep"
				elif h < 22: p[h] = "free"
				else:        p[h] = "work"
		"training":
			for h in range(24):
				if h < 6:    p[h] = "sleep"
				elif h < 20: p[h] = "train"
				else:        p[h] = "free"
		"free_day":
			for h in range(24):
				p[h] = "sleep" if h < 8 else "free"
	return p
