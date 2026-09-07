## MarketPanel.gd
## Marché de la guilde : acheter des équipements, vendre des items de l'inventaire.
## Code-only — ouvert via EventBus.ui_panel_open_requested("market_panel", {}).
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel       : PanelContainer = null
var _gold_label  : Label          = null
var _buy_vbox    : VBoxContainer  = null
var _sell_vbox   : VBoxContainer  = null
var _active_type : String         = "weapon"

const _RANK_COLORS : Dictionary = {
	"F": Color(0.55, 0.55, 0.55),
	"E": Color(0.30, 0.70, 0.30),
	"D": Color(0.20, 0.60, 0.85),
	"C": Color(0.65, 0.20, 0.90),
	"B": Color(0.90, 0.55, 0.10),
	"A": Color(0.90, 0.15, 0.15),
	"S": Color(1.00, 0.85, 0.10),
}

const _TYPE_LABELS : Dictionary = {
	"weapon":     "Armes",
	"armor":      "Armures",
	"accessory":  "Accessoires",
	"consumable": "Consommables",
}

## Prix de vente = SELL_RATIO × prix d'achat
const SELL_RATIO : float = 0.50


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)
	EventBus.gold_changed.connect(_on_gold_changed)
	GuildInventoryManager.inventory_changed.connect(_on_inventory_changed)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if EventBus.gold_changed.is_connected(_on_gold_changed):
		EventBus.gold_changed.disconnect(_on_gold_changed)
	if GuildInventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		GuildInventoryManager.inventory_changed.disconnect(_on_inventory_changed)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(400, 0)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	_panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	## En-tête
	var hdr := HBoxContainer.new()
	root.add_child(hdr)

	var title := Label.new()
	title.text = "Marché"
	title.add_theme_font_size_override("font_size", 13)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 11)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hdr.add_child(_gold_label)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	hdr.add_child(close_btn)

	root.add_child(HSeparator.new())

	## Onglets Acheter / Vendre
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(0, 380)
	root.add_child(tabs)

	## ── Tab Acheter ───────────────────────────
	var buy_root := VBoxContainer.new()
	buy_root.name = "Acheter"
	buy_root.add_theme_constant_override("separation", 6)
	tabs.add_child(buy_root)
	_build_buy_tab(buy_root)

	## ── Tab Vendre ────────────────────────────
	var sell_root := VBoxContainer.new()
	sell_root.name = "Vendre"
	sell_root.add_theme_constant_override("separation", 4)
	tabs.add_child(sell_root)
	_build_sell_tab(sell_root)


func _build_buy_tab(parent: VBoxContainer) -> void:
	## Filtres par type
	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 4)
	parent.add_child(filter_row)

	for type_id in _TYPE_LABELS:
		var btn := Button.new()
		btn.name = "Filter_%s" % type_id
		btn.text = _TYPE_LABELS[type_id]
		btn.toggle_mode = true
		btn.button_pressed = (type_id == _active_type)
		btn.add_theme_font_size_override("font_size", 10)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_type_filter_pressed.bind(type_id))
		filter_row.add_child(btn)

	## Scroll + liste
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)

	_buy_vbox = VBoxContainer.new()
	_buy_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buy_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_buy_vbox)


func _build_sell_tab(parent: VBoxContainer) -> void:
	var info := Label.new()
	info.text = "Prix de vente = 50 % de la valeur d'achat"
	info.add_theme_font_size_override("font_size", 9)
	info.modulate = Color(0.65, 0.65, 0.65)
	parent.add_child(info)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)

	_sell_vbox = VBoxContainer.new()
	_sell_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sell_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_sell_vbox)


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh() -> void:
	_gold_label.text = "Or : %d" % GameData.gold
	_rebuild_buy_list()
	_rebuild_sell_list()


func _rebuild_buy_list() -> void:
	for child in _buy_vbox.get_children():
		child.queue_free()

	var items : Array = EquipmentLibrary.get_by_type(_active_type)
	## Tri par rang (F → S)
	var rank_order := ["F", "E", "D", "C", "B", "A", "S"]
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return rank_order.find(a.get("rank","F")) < rank_order.find(b.get("rank","F"))
	)

	if items.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun article disponible."
		lbl.modulate = Color(0.6, 0.6, 0.6)
		lbl.add_theme_font_size_override("font_size", 10)
		_buy_vbox.add_child(lbl)
		return

	for item in items:
		_buy_vbox.add_child(_build_buy_card(item))


func _rebuild_sell_list() -> void:
	for child in _sell_vbox.get_children():
		child.queue_free()

	var has_items := false
	var slots : Array = GuildInventoryManager.slots
	for i in slots.size():
		var slot = slots[i]
		if slot == null:
			continue
		has_items = true
		_sell_vbox.add_child(_build_sell_card(i, slot))

	if not has_items:
		var lbl := Label.new()
		lbl.text = "Inventaire vide."
		lbl.modulate = Color(0.6, 0.6, 0.6)
		lbl.add_theme_font_size_override("font_size", 10)
		_sell_vbox.add_child(lbl)


# ─────────────────────────────────────────────
#  CARTES
# ─────────────────────────────────────────────
func _build_buy_card(item: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.20)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	card.add_theme_stylebox_override("panel", style)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	card.add_child(row)

	## Badge rang
	var rank_lbl := Label.new()
	var rank : String = item.get("rank", "F")
	rank_lbl.text    = rank
	rank_lbl.add_theme_font_size_override("font_size", 11)
	rank_lbl.add_theme_color_override("font_color", _RANK_COLORS.get(rank, Color.WHITE))
	rank_lbl.custom_minimum_size = Vector2(14, 0)
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(rank_lbl)

	## Infos
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 1)
	row.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = item.get("label", "?")
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	info_vbox.add_child(name_lbl)

	## Stats résumé
	var stats_text := _format_stats(item.get("stats", {}))
	if stats_text != "":
		var stats_lbl := Label.new()
		stats_lbl.text    = stats_text
		stats_lbl.add_theme_font_size_override("font_size", 9)
		stats_lbl.modulate = Color(0.70, 0.85, 0.70)
		info_vbox.add_child(stats_lbl)

	## Description courte
	var desc : String = item.get("description", "")
	if desc != "":
		var desc_lbl := Label.new()
		desc_lbl.text         = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 9)
		desc_lbl.modulate     = Color(0.60, 0.60, 0.60)
		info_vbox.add_child(desc_lbl)

	## Prix + bouton
	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 4)
	row.add_child(right_vbox)

	var price : int = item.get("price", 0)
	var price_lbl := Label.new()
	price_lbl.text = "%d ◆" % price
	price_lbl.add_theme_font_size_override("font_size", 10)
	price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_vbox.add_child(price_lbl)

	var buy_btn := Button.new()
	buy_btn.text = "Acheter"
	buy_btn.add_theme_font_size_override("font_size", 9)
	buy_btn.custom_minimum_size = Vector2(70, 0)
	buy_btn.pressed.connect(_on_buy_pressed.bind(item.get("id", ""), price))
	right_vbox.add_child(buy_btn)

	return card


func _build_sell_card(slot_idx: int, slot: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.15)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	card.add_theme_stylebox_override("panel", style)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	card.add_child(row)

	var item_id : String = slot.get("item_id", "")
	var qty     : int    = slot.get("quantity", 1)

	## Nom + quantité — cherche dans EquipmentLibrary puis MaterialLibrary
	var item_def : Dictionary = EquipmentLibrary.get_item(item_id)
	if item_def.is_empty():
		item_def = MaterialLibrary.get_material(item_id)

	var label : String = item_def.get("label", item_id.replace("_", " ").capitalize())
	var rank  : String = item_def.get("rank", "")

	var info_lbl := Label.new()
	info_lbl.text = ("%s [%s]" % [label, rank]) if rank != "" else label
	info_lbl.add_theme_font_size_override("font_size", 10)
	if rank != "":
		info_lbl.add_theme_color_override("font_color", _RANK_COLORS.get(rank, Color.WHITE))
	info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info_lbl)

	## Quantité
	if qty > 1:
		var qty_lbl := Label.new()
		qty_lbl.text    = "×%d" % qty
		qty_lbl.add_theme_font_size_override("font_size", 10)
		qty_lbl.modulate = Color(0.75, 0.75, 0.75)
		row.add_child(qty_lbl)

	## Prix de vente
	var base_price : int = item_def.get("price", 0)
	var sell_price : int = maxi(1, int(base_price * SELL_RATIO))

	var price_lbl := Label.new()
	price_lbl.text = "%d ◆" % sell_price
	price_lbl.add_theme_font_size_override("font_size", 10)
	price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	row.add_child(price_lbl)

	var sell_btn := Button.new()
	sell_btn.text = "Vendre"
	sell_btn.add_theme_font_size_override("font_size", 9)
	sell_btn.custom_minimum_size = Vector2(60, 0)
	sell_btn.pressed.connect(_on_sell_pressed.bind(slot_idx, sell_price))
	row.add_child(sell_btn)

	return card


# ─────────────────────────────────────────────
#  CALLBACKS
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "market_panel":
		_panel.hide()
		return
	_refresh()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _on_type_filter_pressed(type_id: String) -> void:
	_active_type = type_id
	## Synchronise l'état visuel des boutons filtres
	var filter_btns : Node = _panel.find_child("Filter_%s" % "weapon", true, false)
	if filter_btns == null:
		return
	for type_key in _TYPE_LABELS:
		var btn : Button = _panel.find_child("Filter_%s" % type_key, true, false)
		if btn:
			btn.button_pressed = (type_key == type_id)
	_rebuild_buy_list()


func _on_buy_pressed(item_id: String, price: int) -> void:
	if not GameData.spend_gold(price):
		EventBus.ui_notification_requested.emit(
			"Pas assez d'or ! (%d requis)" % price, "warning"
		)
		return
	if not GuildInventoryManager.add_item(item_id, 1):
		## Inventaire plein — rembourse
		GameData.add_gold(price)
		EventBus.ui_notification_requested.emit("Inventaire plein !", "warning")
		return
	var item : Dictionary = EquipmentLibrary.get_item(item_id)
	EventBus.ui_notification_requested.emit(
		"%s acheté pour %d or." % [item.get("label", item_id), price], "info"
	)


func _on_sell_pressed(slot_idx: int, sell_price: int) -> void:
	if not GuildInventoryManager.remove_from_slot(slot_idx, 1):
		return
	GameData.add_gold(sell_price)
	EventBus.ui_notification_requested.emit(
		"Item vendu pour %d or." % sell_price, "info"
	)


func _on_gold_changed(new_gold: int, _delta: int) -> void:
	if _panel.visible and _gold_label:
		_gold_label.text = "Or : %d" % new_gold


func _on_inventory_changed() -> void:
	if _panel.visible:
		_rebuild_sell_list()


func _close() -> void:
	_panel.hide()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
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


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _format_stats(stats: Dictionary) -> String:
	if stats.is_empty():
		return ""
	const STAT_NAMES : Dictionary = {
		"atk": "ATK", "matk": "M.ATK", "def": "DEF", "mdef": "M.DEF",
		"spd": "VIT",  "crit": "CRIT%", "hp": "PV",  "mana": "Mana",
	}
	var parts : Array = []
	for key in stats:
		if stats[key] != 0:
			parts.append("%s +%g" % [STAT_NAMES.get(key, key), stats[key]])
	return "  ".join(parts)
