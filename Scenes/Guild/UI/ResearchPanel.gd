## ResearchPanel.gd
## Panneau de recherche en deux parties :
##   • Gauche  : détails de la recherche sélectionnée + barre de progression + bouton Start/Pause
##   • Droite  : arbre interactif (icônes reliées par des lignes, scroll horizontal)
##
## Ouvert via EventBus.ui_panel_open_requested("research_panel").
extends Control


# ─────────────────────────────────────────────
#  RÉFÉRENCES UI
# ─────────────────────────────────────────────
var _panel          : PanelContainer    = null
var _gold_label     : Label             = null
var _name_label     : Label             = null
var _cost_label     : Label             = null
var _desc_label     : Label             = null
var _unlocks_label  : Label             = null
var _prereq_hbox    : HBoxContainer     = null
var _progress_bar   : ProgressBar       = null
var _action_btn     : Button            = null
var _status_label   : Label             = null
var _tree_canvas    : ResearchTreeCanvas = null

var _selected_id : String = ""


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	ResearchManager.research_changed.connect(_refresh_detail)
	ResearchManager.research_progress_updated.connect(_on_progress_updated)
	EventBus.gold_changed.connect(_on_gold_changed)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if ResearchManager.research_changed.is_connected(_refresh_detail):
		ResearchManager.research_changed.disconnect(_refresh_detail)
	if ResearchManager.research_progress_updated.is_connected(_on_progress_updated):
		ResearchManager.research_progress_updated.disconnect(_on_progress_updated)
	if EventBus.gold_changed.is_connected(_on_gold_changed):
		EventBus.gold_changed.disconnect(_on_gold_changed)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(940, 520)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	_panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	_build_header(root)
	root.add_child(HSeparator.new())
	_build_body(root)


func _build_header(parent: VBoxContainer) -> void:
	var hdr := HBoxContainer.new()
	parent.add_child(hdr)

	var title := Label.new()
	title.text = "Arbre de Recherche"
	title.add_theme_font_size_override("font_size", 13)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	_gold_label = Label.new()
	_gold_label.text = "💰 %d" % GameData.gold
	_gold_label.add_theme_font_size_override("font_size", 10)
	_gold_label.modulate = Color(1.0, 0.85, 0.20)
	hdr.add_child(_gold_label)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(28, 0)
	close_btn.pressed.connect(_close)
	hdr.add_child(close_btn)


func _build_body(parent: VBoxContainer) -> void:
	var main_hbox := HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 8)
	main_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(main_hbox)

	_build_detail_panel(main_hbox)
	main_hbox.add_child(VSeparator.new())
	_build_tree_panel(main_hbox)


func _build_detail_panel(parent: HBoxContainer) -> void:
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(265, 0)
	vbox.add_theme_constant_override("separation", 7)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(vbox)

	## Nom de la recherche
	_name_label = Label.new()
	_name_label.text = "Sélectionner une recherche"
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_name_label)

	vbox.add_child(HSeparator.new())

	## Coût
	_cost_label = Label.new()
	_cost_label.text = ""
	_cost_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_cost_label)

	## Description
	_desc_label = Label.new()
	_desc_label.text = ""
	_desc_label.add_theme_font_size_override("font_size", 11)
	_desc_label.modulate = Color(0.82, 0.82, 0.82)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

	## Déblocages
	_unlocks_label = Label.new()
	_unlocks_label.text = ""
	_unlocks_label.add_theme_font_size_override("font_size", 11)
	_unlocks_label.modulate = Color(0.60, 0.80, 1.00)
	_unlocks_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_unlocks_label)

	## Prérequis
	_prereq_hbox = HBoxContainer.new()
	_prereq_hbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_prereq_hbox)

	## Barre de progression
	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 1.0
	_progress_bar.value     = 0.0
	_progress_bar.custom_minimum_size = Vector2(0, 18)
	_progress_bar.show_percentage = true
	vbox.add_child(_progress_bar)

	## Bouton action + statut
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	_action_btn = Button.new()
	_action_btn.text = "Démarrer"
	_action_btn.disabled = true
	_action_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_action_btn.pressed.connect(_on_action_pressed)
	btn_row.add_child(_action_btn)

	_status_label = Label.new()
	_status_label.text = ""
	_status_label.add_theme_font_size_override("font_size", 9)
	_status_label.modulate = Color(0.65, 0.65, 0.65)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_status_label)


func _build_tree_panel(parent: HBoxContainer) -> void:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)

	_tree_canvas = ResearchTreeCanvas.new()
	_tree_canvas.research_selected.connect(_on_research_selected)
	scroll.add_child(_tree_canvas)


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT DU PANNEAU GAUCHE
# ─────────────────────────────────────────────
func _on_research_selected(id: String) -> void:
	_selected_id = id
	_refresh_detail()


func _refresh_detail() -> void:
	if not _panel.visible:
		return
	_gold_label.text = "💰 %d" % GameData.gold
	if _selected_id == "":
		_clear_detail()
		return
	var r : ResearchData = ResearchLibrary.get_definition(_selected_id)
	if r == null:
		_clear_detail()
		return

	## Nom
	_name_label.text = r.label
	var is_done : bool = ResearchManager.is_unlocked(_selected_id)
	if is_done:
		_name_label.modulate = Color(0.35, 0.95, 0.35)
	else:
		_name_label.modulate = Color(1.0, 1.0, 1.0)

	## Coût
	var can_afford : bool = GameData.gold >= r.cost or ResearchManager.has_started(_selected_id)
	_cost_label.text = "Coût : %d Po" % r.cost
	_cost_label.modulate = Color(1.0, 0.85, 0.2) if can_afford else Color(0.85, 0.35, 0.35)

	## Description + déblocages
	_desc_label.text    = r.description
	_unlocks_label.text = "► " + r.unlocks if r.unlocks != "" else ""

	## Prérequis
	for c in _prereq_hbox.get_children():
		c.queue_free()
	if not r.prerequisites.is_empty():
		var ptitle := Label.new()
		ptitle.text = "Prérequis :"
		ptitle.add_theme_font_size_override("font_size", 9)
		ptitle.modulate = Color(0.55, 0.55, 0.55)
		_prereq_hbox.add_child(ptitle)
		for prereq_id : String in r.prerequisites:
			var pd : ResearchData = ResearchLibrary.get_definition(prereq_id)
			var plbl := Label.new()
			plbl.text = pd.label if pd else prereq_id
			plbl.add_theme_font_size_override("font_size", 9)
			plbl.modulate = Color(0.25, 0.85, 0.25) if ResearchManager.is_unlocked(prereq_id) \
			                else Color(0.85, 0.30, 0.30)
			_prereq_hbox.add_child(plbl)

	## Barre de progression
	var req  : float = ResearchManager.points_required(r)
	var prog : float = ResearchManager.get_progress(_selected_id)
	_progress_bar.max_value = req
	_progress_bar.value     = req if is_done else prog

	## Bouton + statut
	_update_action_button(r, is_done)


func _update_action_button(r: ResearchData, is_done: bool) -> void:
	var is_act    : bool = ResearchManager.is_active(r.id)
	var paused    : bool = ResearchManager.is_paused
	var can_do    : bool = ResearchManager.can_start(r.id)

	if is_done:
		_action_btn.text     = "✓ Débloqué"
		_action_btn.disabled = true
		_set_status("", Color(0.65, 0.65, 0.65))

	elif is_act and not paused:
		_action_btn.text     = "Pause"
		_action_btn.disabled = false
		_set_status("En cours...", Color(0.25, 0.90, 1.00))

	elif is_act and paused:
		_action_btn.text     = "Reprendre"
		_action_btn.disabled = false
		_set_status("En pause", Color(0.90, 0.65, 0.25))

	elif not can_do:
		_action_btn.text     = "Démarrer"
		_action_btn.disabled = true
		var missing : Array[String] = ResearchManager.missing_prerequisites(r.id)
		_set_status("Prérequis manquants" if not missing.is_empty() else "Impossible",
		            Color(0.75, 0.30, 0.30))

	else:
		_action_btn.text     = "Démarrer"
		_action_btn.disabled = false
		if ResearchManager.has_started(r.id):
			_set_status("Reprendre (déjà payé)", Color(0.65, 0.80, 0.65))
		elif GameData.gold < r.cost:
			_set_status("Or insuffisant", Color(0.85, 0.35, 0.35))
		else:
			_set_status("", Color(0.65, 0.65, 0.65))


func _set_status(text: String, color: Color) -> void:
	_status_label.text     = text
	_status_label.modulate = color


func _clear_detail() -> void:
	_name_label.text    = "Sélectionner une recherche"
	_name_label.modulate = Color(1.0, 1.0, 1.0)
	_cost_label.text    = ""
	_desc_label.text    = ""
	_unlocks_label.text  = ""
	for c in _prereq_hbox.get_children():
		c.queue_free()
	_progress_bar.max_value = 1.0
	_progress_bar.value     = 0.0
	_action_btn.text        = "Démarrer"
	_action_btn.disabled    = true
	_set_status("", Color(0.65, 0.65, 0.65))


func _on_progress_updated(research_id: String, progress: float, required: float) -> void:
	if not _panel.visible or research_id != _selected_id:
		return
	_progress_bar.max_value = required
	_progress_bar.value     = progress


func _on_gold_changed(new_val: int, _delta: int) -> void:
	if _panel.visible:
		_gold_label.text = "💰 %d" % new_val
		_refresh_detail()


# ─────────────────────────────────────────────
#  BOUTON ACTION
# ─────────────────────────────────────────────
func _on_action_pressed() -> void:
	if _selected_id == "":
		return

	var is_act  : bool = ResearchManager.is_active(_selected_id)
	var paused  : bool = ResearchManager.is_paused

	if is_act and not paused:
		ResearchManager.pause_research()
	elif is_act and paused:
		ResearchManager.resume_research()
	else:
		if not ResearchManager.start_research(_selected_id):
			EventBus.ui_notification_requested.emit(
				"Impossible de démarrer cette recherche.", "warning")

	_refresh_detail()


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "research_panel":
		_panel.hide()
		return
	_tree_canvas.build()
	## Pré-sélectionne la recherche active si elle existe
	if _selected_id == "" and ResearchManager.active_id != "":
		_selected_id = ResearchManager.active_id
		_tree_canvas.select_silent(_selected_id)
	_refresh_detail()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	UIState.menu_open = false


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
