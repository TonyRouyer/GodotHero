## InventoryPanel.gd
## Panneau inventaire de la guilde.
## Grille 9 colonnes avec scroll vertical.
## Détails de l'item survolé affichés sous la grille.
## Ouvert via EventBus.ui_panel_open_requested("inventory_panel").
extends Control


const _COLS      : int = 9
const _SLOT_SIZE : int = 52


# ─────────────────────────────────────────────
#  WIDGETS
# ─────────────────────────────────────────────
var _panel   : PanelContainer     = null
var _slots   : Array[InventorySlot] = []

## Détail de l'item survolé
var _det_name : Label = null
var _det_cat  : Label = null
var _det_desc : Label = null

## Menu contextuel
var _ctx_panel : PanelContainer = null
var _ctx_slot  : int            = -1


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_build_context_menu()
	_panel.hide()
	_ctx_panel.hide()

	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	GuildInventoryManager.inventory_changed.connect(_refresh_all_slots)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if GuildInventoryManager.inventory_changed.is_connected(_refresh_all_slots):
		GuildInventoryManager.inventory_changed.disconnect(_refresh_all_slots)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	## Largeur calculée sur la grille : 9 slots × 52 + 8 gaps × 4 = 500 px + marges 20 = 520
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(540, 0)
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
	title.text = "Inventaire de la Guilde"
	title.add_theme_font_size_override("font_size", 12)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(28, 0)
	close_btn.pressed.connect(_close)
	hdr.add_child(close_btn)

	root.add_child(HSeparator.new())

	## ── Grille dans un scroll vertical ───────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	scroll.custom_minimum_size    = Vector2(0, 180)
	scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = _COLS
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	for i in GuildInventoryManager.MAX_SLOTS:
		var slot := InventorySlot.new()
		slot.setup(i)
		slot.hovered.connect(_on_slot_hovered)
		slot.hover_exited.connect(_on_slot_hover_exited)
		slot.right_clicked.connect(_on_slot_right_clicked)
		grid.add_child(slot)
		_slots.append(slot)

	root.add_child(HSeparator.new())

	## ── Détails de l'item survolé ─────────────────────────────────────────────
	var det_box := VBoxContainer.new()
	det_box.add_theme_constant_override("separation", 4)
	det_box.custom_minimum_size = Vector2(0, 70)
	root.add_child(det_box)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)
	det_box.add_child(name_row)

	_det_name = Label.new()
	_det_name.text = ""
	_det_name.add_theme_font_size_override("font_size", 12)
	_det_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(_det_name)

	_det_cat = Label.new()
	_det_cat.text = ""
	_det_cat.add_theme_font_size_override("font_size", 10)
	_det_cat.modulate = Color(0.65, 0.65, 0.65)
	_det_cat.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	name_row.add_child(_det_cat)

	_det_desc = Label.new()
	_det_desc.text = ""
	_det_desc.add_theme_font_size_override("font_size", 10)
	_det_desc.modulate = Color(0.78, 0.78, 0.78)
	_det_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	_det_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	det_box.add_child(_det_desc)


func _build_context_menu() -> void:
	_ctx_panel = PanelContainer.new()
	add_child(_ctx_panel)

	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.14, 0.14, 0.18)
	style.border_color = Color(0.45, 0.45, 0.55)
	style.set_border_width_all(1)
	style.corner_radius_top_left     = 3
	style.corner_radius_top_right    = 3
	style.corner_radius_bottom_left  = 3
	style.corner_radius_bottom_right = 3
	_ctx_panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	_ctx_panel.add_child(vbox)

	var split_btn := Button.new()
	split_btn.name = "SplitBtn"
	split_btn.text = "Diviser le stack"
	split_btn.add_theme_font_size_override("font_size", 9)
	split_btn.flat = true
	split_btn.pressed.connect(_on_ctx_split)
	vbox.add_child(split_btn)

	var one_btn := Button.new()
	one_btn.name = "OneBtn"
	one_btn.text = "Prendre 1"
	one_btn.add_theme_font_size_override("font_size", 9)
	one_btn.flat = true
	one_btn.pressed.connect(_on_ctx_take_one)
	vbox.add_child(one_btn)

	var drop_btn := Button.new()
	drop_btn.text = "Jeter l'item"
	drop_btn.add_theme_font_size_override("font_size", 9)
	drop_btn.flat = true
	drop_btn.modulate = Color(1.0, 0.45, 0.45)
	drop_btn.pressed.connect(_on_ctx_drop)
	vbox.add_child(drop_btn)


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh_all_slots() -> void:
	for slot in _slots:
		slot.refresh()


# ─────────────────────────────────────────────
#  DÉTAIL AU SURVOL
# ─────────────────────────────────────────────
func _on_slot_hovered(slot_idx: int) -> void:
	_ctx_panel.hide()
	var slot_data = GuildInventoryManager.slots[slot_idx]
	if slot_data == null:
		_clear_detail()
		return
	var item_id : String = slot_data["item_id"]
	var mat : Dictionary = MaterialLibrary.get_material(item_id)
	if not mat.is_empty():
		_det_name.text     = mat.get("label", item_id)
		_det_name.modulate = Color.WHITE
		_det_cat.text      = mat.get("category", "").capitalize()
		_det_desc.text     = mat.get("description", "")
	else:
		var eq : Dictionary = EquipmentLibrary.get_item(item_id)
		if eq.is_empty():
			_clear_detail()
			return
		_det_name.text     = eq.get("label", item_id)
		_det_name.modulate = _rank_color(eq.get("rank", "F"))
		_det_cat.text      = _type_label(eq.get("type", ""))
		_det_desc.text     = eq.get("description", "")


func _on_slot_hover_exited(_slot_idx: int) -> void:
	_clear_detail()


func _clear_detail() -> void:
	_det_name.text = ""
	_det_name.modulate = Color(1, 1, 1)
	_det_cat.text  = ""
	_det_desc.text = ""


func _rank_color(rank: String) -> Color:
	match rank:
		"D", "C": return Color(0.20, 0.85, 0.20)
		"B", "A": return Color(0.30, 0.55, 1.00)
		"S":      return Color(1.00, 0.55, 0.00)
		_:        return Color(0.90, 0.90, 0.90)


func _rarity_color(rarity: String) -> Color:
	match rarity:
		"uncommon":  return Color(0.20, 0.85, 0.20)
		"rare":      return Color(0.30, 0.55, 1.00)
		"epic":      return Color(0.70, 0.20, 0.95)
		"legendary": return Color(1.00, 0.55, 0.00)
		_:           return Color(0.90, 0.90, 0.90)


func _type_label(type: String) -> String:
	match type:
		"weapon":     return "Arme"
		"armor":      return "Armure"
		"accessory":  return "Accessoire"
		"consumable": return "Consommable"
		"material":   return "Matériau"
		_:            return type.capitalize()


# ─────────────────────────────────────────────
#  MENU CONTEXTUEL
# ─────────────────────────────────────────────
func _on_slot_right_clicked(slot_idx: int) -> void:
	_ctx_slot = slot_idx
	var slot_data = GuildInventoryManager.slots[slot_idx]

	var stackable : bool = slot_data != null and GuildInventoryManager._is_stackable(slot_data["item_id"])
	var qty : int = slot_data["quantity"] if slot_data != null else 0
	var split_btn := _ctx_panel.find_child("SplitBtn", true, false) as Button
	var one_btn   := _ctx_panel.find_child("OneBtn",   true, false) as Button
	if split_btn: split_btn.visible = stackable and qty > 1
	if one_btn:   one_btn.visible   = stackable and qty > 1

	var slot_node : InventorySlot = _slots[slot_idx]
	var pos : Vector2 = slot_node.global_position + Vector2(slot_node.size.x, 0)
	_ctx_panel.show()
	await get_tree().process_frame
	var vp_size : Vector2 = get_viewport().get_visible_rect().size
	if pos.x + _ctx_panel.size.x > vp_size.x:
		pos.x = slot_node.global_position.x - _ctx_panel.size.x
	_ctx_panel.position = pos


func _on_ctx_split() -> void:
	GuildInventoryManager.split_stack(_ctx_slot)
	_ctx_panel.hide()


func _on_ctx_take_one() -> void:
	var empty := GuildInventoryManager._find_empty_slot()
	if empty >= 0:
		GuildInventoryManager.move_one(_ctx_slot, empty)
	_ctx_panel.hide()


func _on_ctx_drop() -> void:
	GuildInventoryManager.remove_from_slot(_ctx_slot)
	_ctx_panel.hide()


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "inventory_panel":
		_panel.hide()
		_ctx_panel.hide()
		return
	_refresh_all_slots()
	_panel.show()
	_ctx_panel.hide()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	_ctx_panel.hide()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  INPUT — ferme sur ESC ou clic hors panel
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if _ctx_panel.visible:
			var ctx_rect := Rect2(_ctx_panel.global_position, _ctx_panel.size)
			if not ctx_rect.has_point(get_viewport().get_mouse_position()):
				_ctx_panel.hide()
				return

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
