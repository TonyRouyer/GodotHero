## InventorySlot.gd
## Widget d'un slot d'inventaire.
## Icône plein slot, compteur en bas-droite, drag & drop natif Godot 4.
extends PanelContainer
class_name InventorySlot


signal hovered(slot_idx: int)
signal hover_exited(slot_idx: int)
signal right_clicked(slot_idx: int)


const _RARITY_COLORS : Dictionary = {
	"common":    Color(0.60, 0.60, 0.60),
	"uncommon":  Color(0.15, 0.80, 0.15),
	"rare":      Color(0.20, 0.45, 1.00),
	"epic":      Color(0.65, 0.10, 0.90),
	"legendary": Color(1.00, 0.50, 0.00),
}

const _TYPE_COLORS : Dictionary = {
	"weapon":     Color(0.70, 0.70, 0.85),
	"armor":      Color(0.30, 0.75, 0.55),
	"accessory":  Color(0.90, 0.80, 0.20),
	"consumable": Color(0.85, 0.18, 0.18),
	"material":   Color(0.62, 0.50, 0.30),
}


var slot_idx   : int          = -1
var _icon      : ColorRect    = null
var _qty_label : Label        = null
var _s_empty   : StyleBoxFlat = null
var _s_full    : StyleBoxFlat = null
var _s_hover   : StyleBoxFlat = null


func setup(idx: int) -> void:
	slot_idx = idx
	custom_minimum_size = Vector2(52, 52)

	_s_empty = _make_style(Color(0.11, 0.11, 0.15), Color(0.28, 0.28, 0.35), 1)
	_s_full  = _make_style(Color(0.16, 0.16, 0.22), Color(0.45, 0.45, 0.60), 2)
	_s_hover = _make_style(Color(0.22, 0.22, 0.30), Color(0.70, 0.70, 0.95), 2)
	add_theme_stylebox_override("panel", _s_empty)

	## Superposition : icône remplit tout le slot, compteur en bas à droite
	var content := Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(content)

	_icon = ColorRect.new()
	_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_icon.color        = Color(0.10, 0.10, 0.13)
	_icon.mouse_filter = Control.MOUSE_FILTER_PASS
	content.add_child(_icon)

	## Compteur en bas à droite (visible seulement si quantité > 1)
	_qty_label = Label.new()
	_qty_label.anchor_left              = 0.0
	_qty_label.anchor_top               = 0.0
	_qty_label.anchor_right             = 1.0
	_qty_label.anchor_bottom            = 1.0
	_qty_label.offset_right             = -2
	_qty_label.offset_bottom            = -2
	_qty_label.horizontal_alignment     = HORIZONTAL_ALIGNMENT_RIGHT
	_qty_label.vertical_alignment       = VERTICAL_ALIGNMENT_BOTTOM
	_qty_label.add_theme_font_size_override("font_size", 9)
	_qty_label.text        = ""
	_qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_qty_label)

	mouse_entered.connect(func() -> void:
		add_theme_stylebox_override("panel", _s_hover)
		hovered.emit(slot_idx)
	)
	mouse_exited.connect(func() -> void:
		_restore_style()
		hover_exited.emit(slot_idx)
	)


func refresh() -> void:
	var slot_data = GuildInventoryManager.slots[slot_idx]
	if slot_data == null:
		_icon.color     = Color(0.10, 0.10, 0.13)
		_qty_label.text = ""
		add_theme_stylebox_override("panel", _s_empty)
		return

	var item_id : String = slot_data["item_id"]
	var def : ItemDefinition = ItemLibrary.get_definition(item_id)
	if def != null:
		_icon.color          = _TYPE_COLORS.get(def.type, Color.GRAY)
		_s_full.border_color = _RARITY_COLORS.get(def.rarity, Color.GRAY)
		_qty_label.text      = str(slot_data["quantity"]) if def.stackable and slot_data["quantity"] > 1 else ""
	else:
		var eq : Dictionary = EquipmentLibrary.get_item(item_id)
		if eq.is_empty():
			return
		_icon.color          = _TYPE_COLORS.get(eq.get("type", ""), Color.GRAY)
		_s_full.border_color = _rank_to_border_color(eq.get("rank", "F"))
		_qty_label.text      = str(slot_data["quantity"]) if slot_data["quantity"] > 1 else ""
	add_theme_stylebox_override("panel", _s_full)


# ─────────────────────────────────────────────
#  DRAG & DROP
# ─────────────────────────────────────────────
func _get_drag_data(_at: Vector2) -> Variant:
	var slot_data = GuildInventoryManager.slots[slot_idx]
	if slot_data == null:
		return null

	var preview := ColorRect.new()
	preview.color               = _icon.color
	preview.modulate.a          = 0.75
	preview.custom_minimum_size = Vector2(44, 44)
	set_drag_preview(preview)

	return {"from_slot": slot_idx}


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return (data is Dictionary
		and data.has("from_slot")
		and data["from_slot"] != slot_idx)


func _drop_data(_at: Vector2, data: Variant) -> void:
	var from : int = data["from_slot"]
	if Input.is_key_pressed(KEY_SHIFT):
		GuildInventoryManager.move_half(from, slot_idx)
	else:
		GuildInventoryManager.move_item(from, slot_idx)


# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
func gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or not event.pressed:
		return
	match event.button_index:
		MOUSE_BUTTON_RIGHT:
			right_clicked.emit(slot_idx)
			get_viewport().set_input_as_handled()


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _restore_style() -> void:
	var has_item : bool = GuildInventoryManager.slots[slot_idx] != null
	add_theme_stylebox_override("panel", _s_full if has_item else _s_empty)


func _rank_to_border_color(rank: String) -> Color:
	match rank:
		"D", "C": return _RARITY_COLORS.get("uncommon",  Color.GRAY)
		"B", "A": return _RARITY_COLORS.get("rare",      Color.GRAY)
		"S":      return _RARITY_COLORS.get("legendary", Color.GRAY)
		_:        return _RARITY_COLORS.get("common",    Color.GRAY)


func _make_style(bg: Color, border: Color, border_w: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.corner_radius_top_left     = 3
	s.corner_radius_top_right    = 3
	s.corner_radius_bottom_left  = 3
	s.corner_radius_bottom_right = 3
	return s
