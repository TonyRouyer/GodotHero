## HeroEquipmentView.gd
## Vue "Équipement" du HeroPanel.
## Affiche le sprite du héros (placeholder coloré) entouré de 4 slots (paperdoll).
## En bas : inventaire filtré sur les équipements compatibles avec la classe du héros.
## Drag & Drop : glisser depuis l'inventaire → déposer sur un slot pour équiper.
## Clic gauche sur un slot plein → déséquiper (item rendu à l'inventaire).
extends VBoxContainer
class_name HeroEquipmentView


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const SLOT_COLORS : Dictionary = {
	"weapon":     Color(0.55, 0.55, 0.80),
	"head":       Color(0.25, 0.65, 0.50),
	"torso":      Color(0.20, 0.60, 0.45),
	"legs":       Color(0.18, 0.55, 0.40),
	"accessory":  Color(0.85, 0.75, 0.15),
	"consumable": Color(0.80, 0.15, 0.15),
}

const SLOT_LABELS : Dictionary = {
	"weapon":     "ARME",
	"head":       "TÊTE",
	"torso":      "TORSE",
	"legs":       "JAMBES",
	"accessory":  "ACCESSOIRE",
	"consumable": "CONSOMM.",
}

const CLASS_COLORS : Dictionary = {
	"warrior":    Color(0.70, 0.20, 0.20),
	"mage":       Color(0.20, 0.20, 0.80),
	"roublard":   Color(0.20, 0.55, 0.20),
	"chasseur":   Color(0.60, 0.45, 0.10),
	"guerisseur": Color(0.75, 0.75, 0.20),
	"invocateur": Color(0.60, 0.20, 0.75),
}

const RANK_COLORS : Dictionary = {
	"F": Color(0.55, 0.55, 0.55),
	"E": Color(0.30, 0.75, 0.30),
	"D": Color(0.25, 0.50, 1.00),
	"C": Color(0.75, 0.55, 0.10),
	"B": Color(0.70, 0.10, 0.80),
	"A": Color(1.00, 0.45, 0.10),
	"S": Color(1.00, 0.85, 0.10),
}


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _hero_data  : HeroData = null
var _hero_list  : Array    = []   ## Array[HeroData]
var _hero_idx   : int      = 0
var _ui_built   : bool     = false


# ─────────────────────────────────────────────
#  REFS UI (construites dans _build_ui)
# ─────────────────────────────────────────────
var _name_label    : Label
var _class_label   : Label
var _hero_sprite   : PanelContainer
var _slot_widgets  : Dictionary = {}   ## slot_name → _EquipSlot
var _stat_labels   : Dictionary = {}   ## stat_key  → Label
var _inv_grid      : GridContainer
var _inv_slots     : Array = []        ## Array[_InvEquipSlot]
var _prev_btn      : Button
var _next_btn      : Button


# ─────────────────────────────────────────────
#  LIFECYCLE
# ─────────────────────────────────────────────
func _ready() -> void:
	add_theme_constant_override("separation", 8)
	GuildInventoryManager.inventory_changed.connect(_on_inventory_changed)


func _exit_tree() -> void:
	if GuildInventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		GuildInventoryManager.inventory_changed.disconnect(_on_inventory_changed)


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────
func setup(heroes: Array) -> void:
	_hero_list = heroes
	_hero_idx  = clamp(_hero_idx, 0, max(0, heroes.size() - 1))
	_build_ui()
	_refresh_display()


func add_hero(hero_data: HeroData) -> void:
	_hero_list.append(hero_data)
	_refresh_nav_buttons()
	_refresh_display()


func remove_hero(hero_id: int) -> void:
	_hero_list = _hero_list.filter(func(d : HeroData) -> bool: return d.hero_id != hero_id)
	_hero_idx  = clamp(_hero_idx, 0, max(0, _hero_list.size() - 1))
	_refresh_nav_buttons()
	_refresh_display()


func select_hero(hero_data: HeroData) -> void:
	for i : int in _hero_list.size():
		if _hero_list[i].hero_id == hero_data.hero_id:
			_hero_idx = i
			_refresh_display()
			return


# ─────────────────────────────────────────────
#  CONSTRUCTION UI (une seule fois)
# ─────────────────────────────────────────────
func _build_ui() -> void:
	if _ui_built:
		return
	_ui_built = true

	## ── Sélecteur de héros ────────────────────────────────────────────────
	var selector := HBoxContainer.new()
	selector.add_theme_constant_override("separation", 6)
	add_child(selector)

	_prev_btn = Button.new()
	_prev_btn.text = "<"
	_prev_btn.custom_minimum_size = Vector2(26, 26)
	_prev_btn.flat = true
	_prev_btn.pressed.connect(_on_prev_hero)
	selector.add_child(_prev_btn)

	_name_label = Label.new()
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	selector.add_child(_name_label)

	_next_btn = Button.new()
	_next_btn.text = ">"
	_next_btn.custom_minimum_size = Vector2(26, 26)
	_next_btn.flat = true
	_next_btn.pressed.connect(_on_next_hero)
	selector.add_child(_next_btn)

	_class_label = Label.new()
	_class_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_class_label.add_theme_font_size_override("font_size", 10)
	_class_label.modulate = Color(0.65, 0.65, 0.65)
	add_child(_class_label)

	## ── Zone paperdoll ───────────────────────────────────────────────────
	## Layout : [col gauche] [sprite] [col droite]
	##   Gauche : ARME / ACCESSOIRE / CONSOMM.
	##   Droite : TÊTE / TORSE / JAMBES
	var doll_center := CenterContainer.new()
	doll_center.custom_minimum_size = Vector2(0, 240)
	add_child(doll_center)

	var doll_hbox := HBoxContainer.new()
	doll_hbox.add_theme_constant_override("separation", 12)
	doll_center.add_child(doll_hbox)

	## Colonne gauche : arme, accessoire, consommable
	var left_col := VBoxContainer.new()
	left_col.add_theme_constant_override("separation", 8)
	left_col.alignment = BoxContainer.ALIGNMENT_CENTER
	doll_hbox.add_child(left_col)

	_slot_widgets["weapon"] = _make_equip_slot("weapon")
	left_col.add_child(_slot_widgets["weapon"])
	_slot_widgets["accessory"] = _make_equip_slot("accessory")
	left_col.add_child(_slot_widgets["accessory"])
	_slot_widgets["consumable"] = _make_equip_slot("consumable")
	left_col.add_child(_slot_widgets["consumable"])

	## Centre : sprite du héros
	_hero_sprite = _make_sprite_placeholder()
	doll_hbox.add_child(_hero_sprite)

	## Colonne droite : tête, torse, jambes
	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 8)
	right_col.alignment = BoxContainer.ALIGNMENT_CENTER
	doll_hbox.add_child(right_col)

	_slot_widgets["head"] = _make_equip_slot("head")
	right_col.add_child(_slot_widgets["head"])
	_slot_widgets["torso"] = _make_equip_slot("torso")
	right_col.add_child(_slot_widgets["torso"])
	_slot_widgets["legs"] = _make_equip_slot("legs")
	right_col.add_child(_slot_widgets["legs"])

	## ── Résumé des bonus d'équipement ────────────────────────────────────
	add_child(_make_hsep())

	var stats_hbox := HBoxContainer.new()
	stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_hbox.add_theme_constant_override("separation", 12)
	add_child(stats_hbox)

	for stat_key : String in ["atk", "matk", "def", "mdef", "spd", "crit", "hp", "mana"]:
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		stats_hbox.add_child(vb)

		var key_lbl := Label.new()
		key_lbl.text = stat_key.to_upper()
		key_lbl.add_theme_font_size_override("font_size", 8)
		key_lbl.modulate = Color(0.55, 0.55, 0.55)
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(key_lbl)

		var val_lbl := Label.new()
		val_lbl.add_theme_font_size_override("font_size", 11)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(val_lbl)
		_stat_labels[stat_key] = val_lbl

	## ── Inventaire filtré ─────────────────────────────────────────────────
	add_child(_make_hsep())

	var inv_header := Label.new()
	inv_header.text = "Équipements disponibles (drag → slot)"
	inv_header.add_theme_font_size_override("font_size", 10)
	inv_header.modulate = Color(0.60, 0.60, 0.60)
	add_child(inv_header)

	var inv_scroll := ScrollContainer.new()
	inv_scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	inv_scroll.custom_minimum_size    = Vector2(0, 80)
	inv_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(inv_scroll)

	_inv_grid = GridContainer.new()
	_inv_grid.columns = 5
	_inv_grid.add_theme_constant_override("h_separation", 4)
	_inv_grid.add_theme_constant_override("v_separation", 4)
	inv_scroll.add_child(_inv_grid)


# ─────────────────────────────────────────────
#  REFRESH
# ─────────────────────────────────────────────
func _refresh_display() -> void:
	if not _ui_built:
		return
	if _hero_list.is_empty():
		_name_label.text  = "— Aucun héros —"
		_class_label.text = ""
		_refresh_nav_buttons()
		return

	_hero_data = _hero_list[_hero_idx]
	_refresh_nav_buttons()

	## Nom
	_name_label.text = _hero_data.hero_name

	## Classe + rang
	var rank_col : Color = RANK_COLORS.get(_hero_data.rank, Color.WHITE)
	_class_label.text    = "[%s]  %s  —  Niv. %d" % [
		_hero_data.rank,
		_hero_data.hero_class.capitalize(),
		_hero_data.level,
	]
	_class_label.modulate = rank_col.lerp(Color(0.65, 0.65, 0.65), 0.4)

	## Sprite (coloré selon la classe)
	_refresh_sprite()

	## Slots paperdoll
	for slot_name : String in _slot_widgets:
		(_slot_widgets[slot_name] as _EquipSlot).refresh(_hero_data)

	## Bonus stats
	_refresh_stats()

	## Inventaire filtré
	_refresh_inventory()


func _refresh_sprite() -> void:
	for child in _hero_sprite.get_children():
		child.queue_free()

	var cls_color : Color = CLASS_COLORS.get(_hero_data.hero_class, Color(0.35, 0.35, 0.45))

	var bg := ColorRect.new()
	bg.color = cls_color.darkened(0.40)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hero_sprite.add_child(bg)

	var lbl := Label.new()
	lbl.text                    = _hero_data.hero_class.capitalize()
	lbl.horizontal_alignment    = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment      = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.modulate                = cls_color.lightened(0.5)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hero_sprite.add_child(lbl)


func _refresh_stats() -> void:
	if _hero_data == null:
		return
	for stat_key : String in _stat_labels:
		var bonus : float = _hero_data.get_equipment_bonus(stat_key)
		var lbl   : Label = _stat_labels[stat_key]
		if bonus > 0.0:
			lbl.text    = "+%d" % int(bonus)
			lbl.modulate = Color(0.35, 0.90, 0.40)
		elif bonus < 0.0:
			lbl.text    = "%d" % int(bonus)
			lbl.modulate = Color(0.90, 0.30, 0.30)
		else:
			lbl.text    = "—"
			lbl.modulate = Color(0.35, 0.35, 0.35)


func _refresh_inventory() -> void:
	for child in _inv_grid.get_children():
		child.queue_free()
	_inv_slots.clear()

	for i : int in GuildInventoryManager.slots.size():
		var slot_data = GuildInventoryManager.slots[i]
		if slot_data == null:
			continue
		var item_id : String      = slot_data["item_id"]
		var item    : Dictionary  = EquipmentLibrary.get_item(item_id)
		if item.is_empty():
			continue
		if _hero_data != null and not _is_equippable_by_hero(item):
			continue

		var inv_slot := _InvEquipSlot.new()
		inv_slot.init(i, item, self)
		_inv_grid.add_child(inv_slot)
		_inv_slots.append(inv_slot)


func _refresh_nav_buttons() -> void:
	if _prev_btn == null:
		return
	var has_multiple : bool = _hero_list.size() > 1
	_prev_btn.visible = has_multiple
	_next_btn.visible = has_multiple


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _is_equippable_by_hero(item: Dictionary) -> bool:
	var type    : String = item.get("type", "")
	var subtype : String = item.get("subtype", "")
	match type:
		"weapon":     return subtype in _hero_data.weapon_types
		"armor":      return subtype == _hero_data.armor_type
		"accessory":  return true
		"consumable": return true
	return false


func _make_equip_slot(slot_name: String) -> _EquipSlot:
	var slot := _EquipSlot.new()
	slot.init(slot_name, self)
	return slot


func _make_sprite_placeholder() -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(76, 96)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.10, 0.10, 0.14)
	s.border_color = Color(0.30, 0.30, 0.45)
	s.set_border_width_all(1)
	s.corner_radius_top_left     = 5
	s.corner_radius_top_right    = 5
	s.corner_radius_bottom_left  = 5
	s.corner_radius_bottom_right = 5
	p.add_theme_stylebox_override("panel", s)
	return p


func _make_spacer(w: float, h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	return c


func _make_hsep() -> HSeparator:
	return HSeparator.new()


# ─────────────────────────────────────────────
#  ACTIONS (appelées par les slots)
# ─────────────────────────────────────────────
func equip_from_inventory(inv_slot_idx: int, item: Dictionary) -> void:
	if _hero_data == null:
		return
	if _hero_data.equip(item["id"]):
		GuildInventoryManager.remove_from_slot(inv_slot_idx, 1)
		_refresh_display()
		EventBus.hero_stat_changed.emit(_hero_data.hero_id, "equipment", 0.0)
	else:
		EventBus.ui_notification_requested.emit(
			"%s ne peut pas équiper : %s" % [_hero_data.hero_name, item.get("label", "?")],
			"warning")


func unequip_slot(slot_name: String) -> void:
	if _hero_data == null:
		return
	var item_id : String = _hero_data.equipment.get(slot_name, "")
	if item_id == "":
		return
	if GuildInventoryManager.add_item(item_id, 1):
		_hero_data.unequip(slot_name)
		_refresh_display()
		EventBus.hero_stat_changed.emit(_hero_data.hero_id, "equipment", 0.0)
	else:
		EventBus.ui_notification_requested.emit(
			"Inventaire plein — impossible de déséquiper.", "warning")


# ─────────────────────────────────────────────
#  NAVIGATION
# ─────────────────────────────────────────────
func _on_prev_hero() -> void:
	if _hero_list.is_empty():
		return
	_hero_idx = (_hero_idx - 1 + _hero_list.size()) % _hero_list.size()
	_refresh_display()


func _on_next_hero() -> void:
	if _hero_list.is_empty():
		return
	_hero_idx = (_hero_idx + 1) % _hero_list.size()
	_refresh_display()


func _on_inventory_changed() -> void:
	if visible:
		_refresh_inventory()


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Slot paperdoll
# ─────────────────────────────────────────────
class _EquipSlot extends PanelContainer:

	const _SLOT_COLORS : Dictionary = {
		"weapon":     Color(0.55, 0.55, 0.80),
		"head":       Color(0.25, 0.65, 0.50),
		"torso":      Color(0.20, 0.60, 0.45),
		"legs":       Color(0.18, 0.55, 0.40),
		"accessory":  Color(0.85, 0.75, 0.15),
		"consumable": Color(0.80, 0.15, 0.15),
	}
	const _SLOT_LABELS : Dictionary = {
		"weapon":     "ARME",
		"head":       "TÊTE",
		"torso":      "TORSE",
		"legs":       "JAMBES",
		"accessory":  "ACCESSOIRE",
		"consumable": "CONSOMM.",
	}

	var _slot_name  : String
	var _view       : HeroEquipmentView
	var _type_lbl   : Label
	var _item_lbl   : Label
	var _rank_lbl   : Label
	var _s_empty    : StyleBoxFlat
	var _s_full     : StyleBoxFlat
	var _s_hover    : StyleBoxFlat
	var _s_candrop  : StyleBoxFlat


	func init(slot_name: String, view: HeroEquipmentView) -> void:
		_slot_name = slot_name
		_view      = view
		custom_minimum_size = Vector2(84, 72)

		_s_empty  = _mk_style(Color(0.10, 0.10, 0.14), Color(0.28, 0.28, 0.42), 1)
		_s_full   = _mk_style(Color(0.14, 0.14, 0.20), Color(0.50, 0.50, 0.75), 2)
		_s_hover  = _mk_style(Color(0.18, 0.18, 0.28), Color(0.70, 0.70, 1.00), 2)
		_s_candrop = _mk_style(Color(0.08, 0.22, 0.08), Color(0.25, 0.85, 0.25), 2)
		add_theme_stylebox_override("panel", _s_empty)

		var margin := MarginContainer.new()
		for side : String in ["left", "right", "top", "bottom"]:
			margin.add_theme_constant_override("margin_" + side, 6)
		add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		margin.add_child(vbox)

		_type_lbl = Label.new()
		_type_lbl.text = _SLOT_LABELS.get(slot_name, slot_name.to_upper())
		_type_lbl.add_theme_font_size_override("font_size", 8)
		_type_lbl.modulate = Color(0.45, 0.45, 0.55)
		_type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(_type_lbl)

		_item_lbl = Label.new()
		_item_lbl.add_theme_font_size_override("font_size", 9)
		_item_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_item_lbl.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
		_item_lbl.custom_minimum_size  = Vector2(0, 28)
		vbox.add_child(_item_lbl)

		_rank_lbl = Label.new()
		_rank_lbl.add_theme_font_size_override("font_size", 8)
		_rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(_rank_lbl)

		mouse_entered.connect(func() -> void:
			if _view._hero_data and _view._hero_data.equipment.get(_slot_name, "") != "":
				add_theme_stylebox_override("panel", _s_hover)
		)
		mouse_exited.connect(_restore_style)


	func refresh(hero_data: HeroData) -> void:
		var item_id : String = hero_data.equipment.get(_slot_name, "")
		if item_id == "":
			_item_lbl.text    = "— vide —"
			_item_lbl.modulate = Color(0.30, 0.30, 0.30)
			_rank_lbl.text    = ""
			add_theme_stylebox_override("panel", _s_empty)
		else:
			var item : Dictionary = EquipmentLibrary.get_item(item_id)
			_item_lbl.text    = item.get("label", item_id)
			_item_lbl.modulate = _SLOT_COLORS.get(item.get("type", ""), Color.GRAY)
			var rank : String  = item.get("rank", "")
			_rank_lbl.text    = "Rang %s" % rank if rank != "" else ""
			_rank_lbl.modulate = Color(0.55, 0.55, 0.55)
			add_theme_stylebox_override("panel", _s_full)


	func gui_input(event: InputEvent) -> void:
		if not (event is InputEventMouseButton) or not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_view.unequip_slot(_slot_name)
			get_viewport().set_input_as_handled()


	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		if not (data is Dictionary):
			return false
		var item_id : String = ""

		if data.has("from_inv_slot"):
			## Depuis la liste filtrée de ce panel
			item_id = data.get("item", {}).get("id", "")
		elif data.has("from_slot"):
			## Depuis le panel inventaire global
			var slot_data = GuildInventoryManager.slots[data["from_slot"]]
			if slot_data == null:
				return false
			item_id = slot_data["item_id"]
		else:
			return false

		if item_id == "":
			return false
		var item : Dictionary = EquipmentLibrary.get_item(item_id)
		if item.is_empty():
			return false
		## Pour les armures : vérifier que le slot de l'item correspond au slot du widget
		var item_type : String = item.get("type", "")
		if item_type == "armor":
			return item.get("slot", "torso") == _slot_name
		## Pour les autres : le type doit correspondre au nom du slot
		return item_type == _slot_name


	func _drop_data(_at: Vector2, data: Variant) -> void:
		if data.has("from_inv_slot"):
			_view.equip_from_inventory(data["from_inv_slot"], data["item"])
		elif data.has("from_slot"):
			var idx : int    = data["from_slot"]
			var sd           = GuildInventoryManager.slots[idx]
			if sd == null:
				return
			var item : Dictionary = EquipmentLibrary.get_item(sd["item_id"])
			if not item.is_empty():
				_view.equip_from_inventory(idx, item)


	func _restore_style() -> void:
		if _view._hero_data and _view._hero_data.equipment.get(_slot_name, "") != "":
			add_theme_stylebox_override("panel", _s_full)
		else:
			add_theme_stylebox_override("panel", _s_empty)


	func _mk_style(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color    = bg
		s.border_color = border
		s.set_border_width_all(bw)
		s.corner_radius_top_left     = 4
		s.corner_radius_top_right    = 4
		s.corner_radius_bottom_left  = 4
		s.corner_radius_bottom_right = 4
		return s


# ─────────────────────────────────────────────
#  CLASSE INTERNE — Slot inventaire filtré
# ─────────────────────────────────────────────
class _InvEquipSlot extends PanelContainer:

	const _SLOT_COLORS : Dictionary = {
		"weapon":     Color(0.55, 0.55, 0.80),
		"head":       Color(0.25, 0.65, 0.50),
		"torso":      Color(0.20, 0.60, 0.45),
		"legs":       Color(0.18, 0.55, 0.40),
		"accessory":  Color(0.85, 0.75, 0.15),
		"consumable": Color(0.80, 0.15, 0.15),
	}
	const _RANK_COLORS : Dictionary = {
		"F": Color(0.55, 0.55, 0.55), "E": Color(0.30, 0.75, 0.30),
		"D": Color(0.25, 0.50, 1.00), "C": Color(0.75, 0.55, 0.10),
		"B": Color(0.70, 0.10, 0.80), "A": Color(1.00, 0.45, 0.10),
		"S": Color(1.00, 0.85, 0.10),
	}

	var _inv_idx : int
	var _item    : Dictionary
	var _view    : HeroEquipmentView


	func init(inv_idx: int, item: Dictionary, view: HeroEquipmentView) -> void:
		_inv_idx = inv_idx
		_item    = item
		_view    = view
		custom_minimum_size = Vector2(62, 62)

		## Fond avec bordure colorée selon le rang
		var rank_col : Color = _RANK_COLORS.get(item.get("rank", "F"), Color.GRAY)
		var s := StyleBoxFlat.new()
		s.bg_color    = Color(0.12, 0.12, 0.18)
		s.border_color = rank_col.darkened(0.3)
		s.set_border_width_all(2)
		s.corner_radius_top_left     = 4
		s.corner_radius_top_right    = 4
		s.corner_radius_bottom_left  = 4
		s.corner_radius_bottom_right = 4
		add_theme_stylebox_override("panel", s)

		var margin := MarginContainer.new()
		for side : String in ["left", "right", "top", "bottom"]:
			margin.add_theme_constant_override("margin_" + side, 4)
		add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		margin.add_child(vbox)

		## Icône colorée (ColorRect) — pour les armures, on utilise le slot plutôt que le type
		var icon := ColorRect.new()
		var _color_key : String = item.get("slot", "") if item.get("type", "") == "armor" and item.get("slot", "") != "" else item.get("type", "")
		icon.color = _SLOT_COLORS.get(_color_key, Color.GRAY)
		icon.custom_minimum_size   = Vector2(30, 30)
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		vbox.add_child(icon)

		## Rang
		var rank_lbl := Label.new()
		rank_lbl.text = item.get("rank", "?")
		rank_lbl.add_theme_font_size_override("font_size", 8)
		rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rank_lbl.modulate = rank_col
		vbox.add_child(rank_lbl)

		## Tooltip au survol
		mouse_entered.connect(func() -> void:
			modulate = Color(1.25, 1.25, 1.25)
			var stats_str : String = _format_stats(item.get("stats", {}))
			var tt : String = "%s\n%s  Rang %s\n%s%s" % [
				item.get("label", "?"),
				item.get("subtype", "?").capitalize(),
				item.get("rank", "?"),
				("\n" + stats_str) if stats_str != "" else "",
				("\n\n" + item.get("description", "")) if item.has("description") else "",
			]
			EventBus.ui_tooltip_show.emit(tt, get_global_mouse_position())
		)
		mouse_exited.connect(func() -> void:
			modulate = Color.WHITE
			EventBus.ui_tooltip_hide.emit()
		)


	func _get_drag_data(_at: Vector2) -> Variant:
		var col : Color = _SLOT_COLORS.get(_item.get("type", ""), Color.GRAY)
		var preview := ColorRect.new()
		preview.color               = col
		preview.custom_minimum_size = Vector2(44, 44)
		preview.modulate.a          = 0.80
		set_drag_preview(preview)
		return {"from_inv_slot": _inv_idx, "item": _item}


	func _format_stats(stats: Dictionary) -> String:
		var parts : Array = []
		for k : String in stats:
			var v : float = stats[k]
			parts.append("%s %s%d" % [k.to_upper(), "+" if v >= 0.0 else "", int(v)])
		return "  ".join(parts)
