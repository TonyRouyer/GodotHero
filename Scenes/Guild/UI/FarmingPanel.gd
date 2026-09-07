## FarmingPanel.gd
## Panel de sélection de culture pour les planting_beds.
## Code-only — ouvert via EventBus.ui_panel_open_requested("farming_panel", {"object_node": node}).
## Affiche les cultures disponibles avec coût en graines et durée de pousse.
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel         : PanelContainer  = null
var _title_lbl     : Label           = null
var _crop_vbox     : VBoxContainer   = null
var _status_lbl    : Label           = null
var _close_btn     : Button          = null

var _target_node   : Node2D          = null
var _selected_crop : String          = ""
var _crop_buttons  : Dictionary      = {}   ## crop_id → Button


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(320.0, 0.0)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	add_child(_panel)

	var vbox : VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	## En-tête
	var header : HBoxContainer = HBoxContainer.new()
	vbox.add_child(header)

	_title_lbl = Label.new()
	_title_lbl.text = "Choisir une culture"
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.add_theme_font_size_override("font_size", 14)
	header.add_child(_title_lbl)

	_close_btn = Button.new()
	_close_btn.text = "✕"
	_close_btn.pressed.connect(_on_close)
	header.add_child(_close_btn)

	vbox.add_child(HSeparator.new())

	## Liste des cultures
	var scroll : ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 300.0)
	vbox.add_child(scroll)

	_crop_vbox = VBoxContainer.new()
	_crop_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_crop_vbox)

	vbox.add_child(HSeparator.new())

	_status_lbl = Label.new()
	_status_lbl.add_theme_font_size_override("font_size", 11)
	_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_status_lbl)

	var plant_btn : Button = Button.new()
	plant_btn.text = "Planter"
	plant_btn.pressed.connect(_on_plant_pressed)
	vbox.add_child(plant_btn)


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, payload: Dictionary) -> void:
	if panel_id != "farming_panel":
		return
	_target_node   = payload.get("object_node", null)
	_selected_crop = ""
	_status_lbl.text = ""
	_refresh_crops()
	_panel.show()


func _on_close() -> void:
	_target_node   = null
	_selected_crop = ""
	_panel.hide()


# ─────────────────────────────────────────────
#  PEUPLEMENT
# ─────────────────────────────────────────────
func _refresh_crops() -> void:
	for child in _crop_vbox.get_children():
		child.queue_free()
	_crop_buttons.clear()

	for crop_id : String in CropLibrary.get_all().keys():
		var crop : Dictionary = CropLibrary.get_crop(crop_id)
		if crop.is_empty():
			continue

		var row : HBoxContainer = HBoxContainer.new()
		_crop_vbox.add_child(row)

		var btn : Button = Button.new()
		btn.text = crop["label"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.toggle_mode = true
		btn.pressed.connect(_on_crop_selected.bind(crop_id, btn))
		row.add_child(btn)
		_crop_buttons[crop_id] = btn

		var info : Label = Label.new()
		var seed_qty : int    = crop.get("seed_cost_qty", 1)
		var seed_id  : String = crop.get("seed_cost_id", "")
		var days     : float  = crop.get("growth_days", 0.0)
		info.text = "%s×%d — %.1fj" % [seed_id, seed_qty, days]
		info.add_theme_font_size_override("font_size", 10)
		info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		row.add_child(info)


func _on_crop_selected(crop_id: String, pressed_btn: Button) -> void:
	_selected_crop = crop_id
	_status_lbl.text = ""
	## Dé-sélectionne les autres boutons
	for id : String in _crop_buttons:
		var b : Button = _crop_buttons[id]
		if b != pressed_btn:
			b.button_pressed = false


# ─────────────────────────────────────────────
#  PLANTATION
# ─────────────────────────────────────────────
func _on_plant_pressed() -> void:
	if _selected_crop.is_empty():
		_status_lbl.text = "Sélectionnez une culture."
		return
	if _target_node == null or not (_target_node is GuildObject):
		_on_close()
		return

	var origin : Vector2i = (_target_node as GuildObject).get_origin()
	var crop   : Dictionary = CropLibrary.get_crop(_selected_crop)

	## Vérifier les graines en inventaire
	var seed_id  : String = crop.get("seed_cost_id", "")
	var seed_qty : int    = crop.get("seed_cost_qty", 0)
	if seed_id != "" and seed_qty > 0:
		if GuildInventoryManager.get_item_count(seed_id) < seed_qty:
			_status_lbl.text = "Graines insuffisantes (%s ×%d)." % [seed_id, seed_qty]
			return
		## Consommer les graines
		var remaining : int = seed_qty
		for i in GuildInventoryManager.MAX_SLOTS:
			var slot = GuildInventoryManager.slots[i]
			if slot == null or slot["item_id"] != seed_id:
				continue
			var take : int = mini(remaining, slot["quantity"])
			GuildInventoryManager.remove_from_slot(i, take)
			remaining -= take
			if remaining <= 0:
				break

	var ok : bool = FarmingManager.plant(origin, _selected_crop)
	if not ok:
		_status_lbl.text = "Ce lit est déjà planté."
		return

	_on_close()
