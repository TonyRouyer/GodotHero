## CraftPanel.gd
## Interface de craft : liste les recettes par poste, permet de les ajouter
## à la file d'un poste, et affiche la progression du craft actif.
## Code-only — ouvert via EventBus.ui_panel_open_requested("craft_panel", {}).
extends Control


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _panel           : PanelContainer = null
var _recipe_vbox     : VBoxContainer  = null
var _queue_vbox      : VBoxContainer  = null
var _active_location : String         = "forge"

## material_id → ProgressBar (pour mise à jour temps réel)
var _progress_bars   : Dictionary = {}


const _LOCATION_LABELS : Dictionary = {
	"forge":           "Forge",
	"atelier":         "Atelier",
	"metier_a_tisser": "Tissage",
	"tannage":         "Tannage",
	"table_alchimie":  "Alchimie",
	"four":            "Four",
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
	GuildInventoryManager.inventory_changed.connect(_on_inventory_changed)
	EventBus.craft_queue_changed.connect(_on_craft_queue_changed)
	EventBus.craft_progress_updated.connect(_on_craft_progress_updated)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)
	if GuildInventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		GuildInventoryManager.inventory_changed.disconnect(_on_inventory_changed)
	if EventBus.craft_queue_changed.is_connected(_on_craft_queue_changed):
		EventBus.craft_queue_changed.disconnect(_on_craft_queue_changed)
	if EventBus.craft_progress_updated.is_connected(_on_craft_progress_updated):
		EventBus.craft_progress_updated.disconnect(_on_craft_progress_updated)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(520, 0)
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
	title.text = "Craft"
	title.add_theme_font_size_override("font_size", 13)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(_close)
	hdr.add_child(close_btn)

	root.add_child(HSeparator.new())

	## Filtres lieu de craft
	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 4)
	root.add_child(filter_row)

	for loc_id in _LOCATION_LABELS:
		var btn := Button.new()
		btn.name = "Filter_%s" % loc_id
		btn.text = _LOCATION_LABELS[loc_id]
		btn.toggle_mode = true
		btn.button_pressed = (loc_id == _active_location)
		btn.add_theme_font_size_override("font_size", 10)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_location_filter.bind(loc_id))
		filter_row.add_child(btn)

	root.add_child(HSeparator.new())

	## Liste recettes
	var recipe_title := Label.new()
	recipe_title.text = "Recettes disponibles"
	recipe_title.add_theme_font_size_override("font_size", 11)
	root.add_child(recipe_title)

	var recipe_scroll := ScrollContainer.new()
	recipe_scroll.custom_minimum_size = Vector2(0, 200)
	recipe_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(recipe_scroll)

	_recipe_vbox = VBoxContainer.new()
	_recipe_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_recipe_vbox.add_theme_constant_override("separation", 4)
	recipe_scroll.add_child(_recipe_vbox)

	root.add_child(HSeparator.new())

	## File d'attente du poste
	var queue_title := Label.new()
	queue_title.text = "File du poste"
	queue_title.add_theme_font_size_override("font_size", 11)
	root.add_child(queue_title)

	var queue_scroll := ScrollContainer.new()
	queue_scroll.custom_minimum_size = Vector2(0, 90)
	root.add_child(queue_scroll)

	_queue_vbox = VBoxContainer.new()
	_queue_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_queue_vbox.add_theme_constant_override("separation", 4)
	queue_scroll.add_child(_queue_vbox)


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh() -> void:
	_rebuild_recipe_list()
	_rebuild_queue()


func _rebuild_recipe_list() -> void:
	for child in _recipe_vbox.get_children():
		child.queue_free()

	var station : Node2D = _find_station(_active_location)

	var recipes : Array = []
	for mat in MaterialLibrary.get_all():
		if mat.get("craft_location", "") == _active_location and not mat.get("recipe", []).is_empty():
			recipes.append(mat)

	if recipes.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucune recette disponible pour ce poste."
		lbl.modulate = Color(0.6, 0.6, 0.6)
		lbl.add_theme_font_size_override("font_size", 10)
		_recipe_vbox.add_child(lbl)
		return

	for mat in recipes:
		_recipe_vbox.add_child(_build_recipe_card(mat, station))


func _rebuild_queue() -> void:
	_progress_bars.clear()
	for child in _queue_vbox.get_children():
		child.queue_free()

	var station : Node2D = _find_station(_active_location)
	if station == null:
		var lbl := Label.new()
		lbl.text = "Aucun poste de ce type placé dans la guilde."
		lbl.modulate = Color(0.5, 0.5, 0.5)
		lbl.add_theme_font_size_override("font_size", 10)
		_queue_vbox.add_child(lbl)
		return

	var info : Dictionary = CraftManager.get_station_info(station)

	var snapshot : Array = []
	if info.get("active") != null:
		snapshot.append({
			"material_id": info["active"]["material_id"],
			"qty":         info["active"].get("qty_remaining", 1),
			"progress":    info.get("progress", 0.0),
			"is_active":   true,
		})
	for entry in info.get("queue", []):
		snapshot.append({
			"material_id": entry["material_id"],
			"qty":         entry["qty"],
			"progress":    0.0,
			"is_active":   false,
		})

	if snapshot.is_empty():
		var lbl := Label.new()
		lbl.text = "File vide — en attente d'un héros."
		lbl.modulate = Color(0.5, 0.5, 0.5)
		lbl.add_theme_font_size_override("font_size", 10)
		_queue_vbox.add_child(lbl)
		return

	for entry in snapshot:
		_queue_vbox.add_child(_build_queue_entry(entry))


# ─────────────────────────────────────────────
#  CARTES
# ─────────────────────────────────────────────
func _build_recipe_card(mat: Dictionary, station: Node2D) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.13, 0.18)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6
	style.content_margin_right  = 6
	style.content_margin_top    = 4
	style.content_margin_bottom = 4
	card.add_theme_stylebox_override("panel", style)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)

	## Infos nom + recette + durée
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	row.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = mat.get("label", "?")
	name_lbl.add_theme_font_size_override("font_size", 11)
	info_vbox.add_child(name_lbl)

	var recipe_lbl := Label.new()
	recipe_lbl.text = _format_recipe(mat.get("recipe", []))
	recipe_lbl.add_theme_font_size_override("font_size", 9)
	recipe_lbl.modulate = Color(0.75, 0.85, 0.75)
	info_vbox.add_child(recipe_lbl)

	var time_lbl := Label.new()
	time_lbl.text = "⏱ %.1fh" % mat.get("craft_time", 0.0)
	time_lbl.add_theme_font_size_override("font_size", 9)
	time_lbl.modulate = Color(0.60, 0.60, 0.60)
	info_vbox.add_child(time_lbl)

	## Boutons ×1 et ×5
	var btn_col := VBoxContainer.new()
	btn_col.add_theme_constant_override("separation", 2)
	row.add_child(btn_col)

	var can_craft : bool    = _can_craft(mat)
	var has_station : bool  = (station != null)
	var mat_id : String     = mat.get("id", "")

	for pair in [["×1", 1], ["×5", 5]]:
		var btn := Button.new()
		btn.text = pair[0]
		btn.add_theme_font_size_override("font_size", 9)
		btn.custom_minimum_size = Vector2(42, 0)
		btn.disabled = not (can_craft and has_station)
		if not has_station:
			btn.tooltip_text = "Aucun poste disponible"
		elif not can_craft:
			btn.tooltip_text = "Matériaux insuffisants"
		btn.pressed.connect(_on_craft_pressed.bind(station, mat_id, pair[1]))
		btn_col.add_child(btn)

	return card


func _build_queue_entry(entry: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var mat   : Dictionary = MaterialLibrary.get_material(entry["material_id"])
	var label : String     = mat.get("label", entry["material_id"])

	var status_lbl := Label.new()
	status_lbl.text = "▶" if entry["is_active"] else "⏳"
	status_lbl.add_theme_font_size_override("font_size", 10)
	status_lbl.custom_minimum_size = Vector2(16, 0)
	row.add_child(status_lbl)

	var name_lbl := Label.new()
	name_lbl.text = "%s ×%d" % [label, entry["qty"]]
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	if entry["is_active"]:
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(120, 14)
		bar.max_value = 100.0
		bar.value = entry["progress"]
		bar.show_percentage = false
		row.add_child(bar)
		_progress_bars[entry["material_id"]] = bar

	return row


# ─────────────────────────────────────────────
#  CALLBACKS
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, _payload: Dictionary) -> void:
	if panel_id != "craft_panel":
		_panel.hide()
		return
	_refresh()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _on_location_filter(loc_id: String) -> void:
	_active_location = loc_id
	for loc_key in _LOCATION_LABELS:
		var btn : Button = _panel.find_child("Filter_%s" % loc_key, true, false)
		if btn:
			btn.button_pressed = (loc_key == loc_id)
	_rebuild_recipe_list()
	_rebuild_queue()


func _on_craft_pressed(station: Node2D, material_id: String, qty: int) -> void:
	if not is_instance_valid(station):
		EventBus.ui_notification_requested.emit("Poste de craft non disponible.", "warning")
		return
	if not CraftManager.add_to_queue(station, material_id, qty):
		EventBus.ui_notification_requested.emit("Impossible d'ajouter à la file.", "warning")
		return
	_rebuild_queue()


func _on_inventory_changed() -> void:
	if _panel.visible:
		_rebuild_recipe_list()


func _on_craft_queue_changed(_key: String, _snapshot: Array) -> void:
	if _panel.visible:
		_rebuild_queue()


func _on_craft_progress_updated(_key: String, material_id: String, progress: float) -> void:
	if not _panel.visible:
		return
	if _progress_bars.has(material_id):
		(_progress_bars[material_id] as ProgressBar).value = progress


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

## Cherche le premier poste de ce lieu parmi les objets placés.
## Ne retourne que l'entrée canonique (cellule d'origine) pour éviter les doublons.
func _find_station(craft_location: String) -> Node2D:
	var object_id : String = GameConfig.CRAFT_LOCATION_TO_OBJECT.get(craft_location, "")
	if object_id == "":
		return null
	for pos in ConstructionManager.placed_objects:
		var entry : Dictionary = ConstructionManager.placed_objects[pos]
		if entry.get("object_id") == object_id and entry.get("origin") == pos:
			var node = entry.get("instance_node")
			if is_instance_valid(node):
				return node
	return null


func _can_craft(mat: Dictionary) -> bool:
	for ing in mat.get("recipe", []):
		if GameData.get_item_quantity(ing["item_id"]) < ing["qty"]:
			return false
	return true


## Formate la liste d'ingrédients avec les quantités disponibles en inventaire.
func _format_recipe(recipe: Array) -> String:
	if recipe.is_empty():
		return ""
	var parts : Array = []
	for ing in recipe:
		var ing_mat  : Dictionary = MaterialLibrary.get_material(ing["item_id"])
		var ing_label : String = ing_mat.get("label", ing["item_id"])
		var have : int = GameData.get_item_quantity(ing["item_id"])
		var need : int = ing["qty"]
		var suffix : String = " ✓" if have >= need else " (%d/%d)" % [have, need]
		parts.append("%s ×%d%s" % [ing_label, need, suffix])
	return "  ".join(parts)
