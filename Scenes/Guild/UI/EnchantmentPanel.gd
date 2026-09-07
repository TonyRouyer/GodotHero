## EnchantmentPanel.gd
## Panel d'enchantement des équipements héros.
## Code-only — ouvert via EventBus.ui_panel_open_requested("enchantment_panel", {}).
## Nécessite la recherche "enchantement" débloquée.
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel          : PanelContainer  = null
var _hero_option    : OptionButton    = null
var _slots_vbox     : VBoxContainer   = null
var _ench_scroll    : ScrollContainer = null
var _ench_vbox      : VBoxContainer   = null
var _apply_btn      : Button          = null
var _status_lbl     : Label           = null

var _selected_hero  : HeroData        = null
var _selected_slot  : String          = ""
var _selected_ench  : String          = ""

const _RANK_COLORS : Dictionary = {
	"C": Color(0.75, 0.55, 0.10),
	"B": Color(0.70, 0.10, 0.80),
	"A": Color(1.00, 0.45, 0.10),
	"S": Color(1.00, 0.85, 0.10),
}

const _SLOT_LABELS : Dictionary = {
	"weapon":    "Arme",
	"head":      "Tête",
	"torso":     "Torse",
	"legs":      "Jambes",
	"accessory": "Accessoire",
}


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
	## Fond semi-transparent
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_panel = PanelContainer.new()
	_panel.set_anchor_and_offset(SIDE_LEFT,   0.15, 0.0)
	_panel.set_anchor_and_offset(SIDE_TOP,    0.05, 0.0)
	_panel.set_anchor_and_offset(SIDE_RIGHT,  0.85, 0.0)
	_panel.set_anchor_and_offset(SIDE_BOTTOM, 0.95, 0.0)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	## ── En-tête ────────────────────────────────────────────────────────────
	var header := HBoxContainer.new()
	root.add_child(header)

	var title := Label.new()
	title.text = "Enchantement d'Équipements"
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.flat = true
	close_btn.pressed.connect(func() -> void: _panel.hide())
	header.add_child(close_btn)

	root.add_child(HSeparator.new())

	## ── Sélecteur de héros ──────────────────────────────────────────────
	var hero_row := HBoxContainer.new()
	hero_row.add_theme_constant_override("separation", 8)
	root.add_child(hero_row)

	var hero_lbl := Label.new()
	hero_lbl.text = "Héros :"
	hero_lbl.custom_minimum_size = Vector2(60, 0)
	hero_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hero_row.add_child(hero_lbl)

	_hero_option = OptionButton.new()
	_hero_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hero_option.item_selected.connect(_on_hero_selected)
	hero_row.add_child(_hero_option)

	## ── Corps principal (2 colonnes) ────────────────────────────────────
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	## Colonne gauche : slots d'équipement du héros
	var left_panel := PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(220, 0)
	var left_style := StyleBoxFlat.new()
	left_style.bg_color = Color(0.08, 0.08, 0.12)
	left_style.corner_radius_top_left     = 4
	left_style.corner_radius_top_right    = 4
	left_style.corner_radius_bottom_left  = 4
	left_style.corner_radius_bottom_right = 4
	left_panel.add_theme_stylebox_override("panel", left_style)
	body.add_child(left_panel)

	var left_margin := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		left_margin.add_theme_constant_override("margin_" + side, 8)
	left_panel.add_child(left_margin)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 4)
	left_margin.add_child(left_vbox)

	var slots_title := Label.new()
	slots_title.text = "Équipements"
	slots_title.add_theme_font_size_override("font_size", 12)
	slots_title.modulate = Color(0.65, 0.65, 0.65)
	left_vbox.add_child(slots_title)

	_slots_vbox = VBoxContainer.new()
	_slots_vbox.add_theme_constant_override("separation", 4)
	left_vbox.add_child(_slots_vbox)

	## Colonne droite : liste des enchantements disponibles
	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 6)
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	body.add_child(right_vbox)

	var ench_title := Label.new()
	ench_title.text = "Enchantements disponibles"
	ench_title.add_theme_font_size_override("font_size", 12)
	ench_title.modulate = Color(0.65, 0.65, 0.65)
	right_vbox.add_child(ench_title)

	_ench_scroll = ScrollContainer.new()
	_ench_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_ench_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_vbox.add_child(_ench_scroll)

	_ench_vbox = VBoxContainer.new()
	_ench_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ench_vbox.add_theme_constant_override("separation", 4)
	_ench_scroll.add_child(_ench_vbox)

	## ── Bas : statut + bouton appliquer ─────────────────────────────────
	root.add_child(HSeparator.new())

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)

	_status_lbl = Label.new()
	_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_lbl.add_theme_font_size_override("font_size", 11)
	_status_lbl.text = "Sélectionnez un équipement puis un enchantement."
	bottom.add_child(_status_lbl)

	_apply_btn = Button.new()
	_apply_btn.text = "Appliquer l'enchantement"
	_apply_btn.disabled = true
	_apply_btn.pressed.connect(_on_apply_pressed)
	bottom.add_child(_apply_btn)


# ─────────────────────────────────────────────
#  REFRESH
# ─────────────────────────────────────────────
func _refresh_heroes() -> void:
	_hero_option.clear()
	var heroes := HeroManager.get_all_data()
	for hero : HeroData in heroes:
		_hero_option.add_item(hero.hero_name)
	if heroes.size() > 0:
		_selected_hero = heroes[0]
		_refresh_slots()
	else:
		_selected_hero = null
		_refresh_slots()


func _refresh_slots() -> void:
	for child in _slots_vbox.get_children():
		child.queue_free()
	_selected_slot = ""
	_selected_ench = ""
	_refresh_enchantments()

	if _selected_hero == null:
		return

	for slot_name : String in ["weapon", "head", "torso", "legs", "accessory"]:
		var item_id : String = _selected_hero.equipment.get(slot_name, "")
		var slot_row := _make_slot_button(slot_name, item_id)
		_slots_vbox.add_child(slot_row)


func _make_slot_button(slot_name: String, item_id: String) -> Button:
	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment             = HORIZONTAL_ALIGNMENT_LEFT

	var slot_label : String = _SLOT_LABELS.get(slot_name, slot_name)
	if item_id == "":
		btn.text    = "[%s] — vide" % slot_label
		btn.disabled = true
	else:
		var item : Dictionary = EquipmentLibrary.get_item(item_id)
		var ench_id : String  = _selected_hero.enchantments.get(slot_name, "")
		var ench_label : String = ""
		if ench_id != "":
			var ench : Dictionary = EnchantmentLibrary.get_enchantment(ench_id)
			ench_label = "  ✨ %s" % ench.get("label", ench_id)
		btn.text = "[%s] %s%s" % [slot_label, item.get("label", item_id), ench_label]

	btn.pressed.connect(func() -> void: _on_slot_selected(slot_name, item_id))
	return btn


func _refresh_enchantments() -> void:
	for child in _ench_vbox.get_children():
		child.queue_free()
	_apply_btn.disabled = true

	if _selected_slot == "" or _selected_hero == null:
		_status_lbl.text = "Sélectionnez un équipement."
		return

	## Vérifie si déjà enchanté
	var current_ench : String = _selected_hero.enchantments.get(_selected_slot, "")
	if current_ench != "":
		var ce : Dictionary = EnchantmentLibrary.get_enchantment(current_ench)
		_status_lbl.text = "Déjà enchanté : %s (irréversible)" % ce.get("label", current_ench)
		_status_lbl.modulate = Color(1.0, 0.5, 0.2)
		return
	_status_lbl.modulate = Color.WHITE

	## Détermine le type compatible ("weapon", "armor", "accessory")
	var item_id : String = _selected_hero.equipment.get(_selected_slot, "")
	var item : Dictionary = EquipmentLibrary.get_item(item_id)
	var item_type : String = item.get("type", "")

	var available : Array = EnchantmentLibrary.get_available_for_type(item_type)
	if available.is_empty():
		_status_lbl.text = "Aucun enchantement disponible pour ce type d'item."
		return

	_status_lbl.text = "Sélectionnez un enchantement à appliquer."

	for ench : Dictionary in available:
		var card := _make_ench_card(ench)
		_ench_vbox.add_child(card)


func _make_ench_card(ench: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.16)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 8
	style.content_margin_right  = 8
	style.content_margin_top    = 6
	style.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)

	## Rang coloré
	var rank_lbl := Label.new()
	rank_lbl.text = "[%s]" % ench["rank"]
	rank_lbl.add_theme_font_size_override("font_size", 10)
	rank_lbl.modulate = _RANK_COLORS.get(ench["rank"], Color.WHITE)
	rank_lbl.custom_minimum_size = Vector2(28, 0)
	rank_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(rank_lbl)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = ench["label"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = ench["description"]
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.modulate = Color(0.65, 0.65, 0.65)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc_lbl)

	## Coût
	var cost_parts : Array = []
	for c in ench.get("cost", []):
		cost_parts.append("%d× %s" % [c["qty"], c["item_id"]])
	var cost_lbl := Label.new()
	cost_lbl.text = "Coût : " + ", ".join(cost_parts)
	cost_lbl.add_theme_font_size_override("font_size", 9)
	var can_afford : bool = EnchantmentLibrary.can_afford(ench["id"])
	cost_lbl.modulate = Color(0.40, 1.0, 0.40) if can_afford else Color(1.0, 0.35, 0.35)
	info.add_child(cost_lbl)

	## Bouton Sélectionner
	var sel_btn := Button.new()
	sel_btn.text = "Choisir"
	sel_btn.disabled = not can_afford
	sel_btn.pressed.connect(func() -> void: _on_ench_selected(ench["id"], style))
	hbox.add_child(sel_btn)

	return card


# ─────────────────────────────────────────────
#  ÉVÉNEMENTS
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "enchantment_panel":
		return
	if not ResearchManager.is_unlocked("enchantement"):
		EventBus.ui_notification_requested.emit(
			"Débloquez la recherche 'Enchantement' pour accéder à l'enchantement.", "warning")
		return
	_refresh_heroes()
	_panel.show()


func _on_hero_selected(index: int) -> void:
	var heroes := HeroManager.get_all_data()
	if index < 0 or index >= heroes.size():
		return
	_selected_hero = heroes[index]
	_selected_slot = ""
	_selected_ench = ""
	_refresh_slots()


func _on_slot_selected(slot_name: String, item_id: String) -> void:
	if item_id == "":
		return
	_selected_slot = slot_name
	_selected_ench = ""
	_refresh_enchantments()


func _on_ench_selected(ench_id: String, _highlight: StyleBoxFlat) -> void:
	_selected_ench = ench_id
	var ench : Dictionary = EnchantmentLibrary.get_enchantment(ench_id)
	_status_lbl.text = "Sélectionné : %s  —  Cliquez 'Appliquer' pour confirmer." % ench.get("label", ench_id)
	_apply_btn.disabled = not EnchantmentLibrary.can_afford(ench_id)


func _on_apply_pressed() -> void:
	if _selected_hero == null or _selected_slot == "" or _selected_ench == "":
		return
	## Vérification finale
	var current : String = _selected_hero.enchantments.get(_selected_slot, "")
	if current != "":
		_status_lbl.text = "Cet emplacement est déjà enchanté."
		return
	if not EnchantmentLibrary.can_afford(_selected_ench):
		_status_lbl.text = "Matériaux insuffisants."
		return
	## Consommation + application
	EnchantmentLibrary.consume_cost(_selected_ench)
	_selected_hero.enchantments[_selected_slot] = _selected_ench
	EventBus.hero_stat_changed.emit(_selected_hero.hero_id, "enchantment", 0.0)
	var ench : Dictionary = EnchantmentLibrary.get_enchantment(_selected_ench)
	_status_lbl.text = "✨ %s appliqué avec succès !" % ench.get("label", _selected_ench)
	_status_lbl.modulate = Color(0.40, 1.0, 0.40)
	_selected_ench = ""
	_apply_btn.disabled = true
	_refresh_slots()
