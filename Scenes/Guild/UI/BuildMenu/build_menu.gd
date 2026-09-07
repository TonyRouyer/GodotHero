## build_menu.gd
## Menu de construction. Panneau plein bas. Onglets verticaux gauche.
## Filtre par pièce pour l'onglet Objets.
extends PanelContainer


@onready var item_grid         : VBoxContainer   = %ItemGrid
@onready var item_scroll       : ScrollContainer = %ItemScroll
@onready var actions_container : VBoxContainer   = %ActionsContainer
@onready var filter_option     : OptionButton    = %FilterOption


enum Tab { WALLS, FLOORS, OBJECTS, ACTIONS }
var _current_tab : Tab = Tab.WALLS


const ROOM_ORDER : Array = [
	"hall", "chambre", "sanitaires", "cuisine",
	"forge", "couture", "atelier", "infirmerie",
	"entrainement", "alchimie", "arcanum",
	"jardin", "loisirs", "decoratif", "ascension",
]
const ROOM_LABELS : Dictionary = {
	"hall":         "Hall",
	"chambre":      "Chambre",
	"sanitaires":   "Sanitaires",
	"cuisine":      "Cuisine",
	"forge":        "Forge",
	"couture":      "Couture",
	"atelier":      "Atelier",
	"infirmerie":   "Infirmerie",
	"entrainement": "Entraînement",
	"alchimie":     "Alchimie",
	"arcanum":      "Arcanum",
	"jardin":       "Jardin",
	"loisirs":      "Loisirs",
	"decoratif":    "Décoratif",
	"ascension":    "Ascension",
}

var _all_walls   : Dictionary = {}
var _all_floors  : Dictionary = {}
var _all_objects : Dictionary = {}


func _ready() -> void:
	_all_walls   = ItemRegistry.get_all_walls()
	_all_floors  = ItemRegistry.get_all_floors()
	_all_objects = ItemRegistry.get_all_objects()
	_show_tab(Tab.WALLS)


# ─────────────────────────────────────────────
#  ONGLETS
# ─────────────────────────────────────────────
func _show_tab(tab: Tab) -> void:
	_current_tab = tab
	var is_actions := (tab == Tab.ACTIONS)
	item_scroll.visible       = not is_actions
	actions_container.visible = is_actions
	filter_option.get_parent().visible = not is_actions  ## HeaderRow

	if is_actions:
		return

	_rebuild_filter()
	_rebuild_grid()


func _on_walls_tab_pressed()   -> void: _show_tab(Tab.WALLS)
func _on_floors_tab_pressed()  -> void: _show_tab(Tab.FLOORS)
func _on_objects_tab_pressed() -> void: _show_tab(Tab.OBJECTS)
func _on_actions_tab_pressed() -> void: _show_tab(Tab.ACTIONS)


# ─────────────────────────────────────────────
#  FILTRE
# ─────────────────────────────────────────────
func _rebuild_filter() -> void:
	filter_option.clear()
	filter_option.add_item("Tous")

	## Filtre par pièce uniquement pour l'onglet Objets
	if _current_tab != Tab.OBJECTS:
		filter_option.disabled = true
		return

	filter_option.disabled = false
	var rooms_present : Array = []
	for item_id in _all_objects:
		var room : String = _all_objects[item_id].get("room", "")
		if room != "" and room not in rooms_present:
			rooms_present.append(room)

	for room in ROOM_ORDER:
		if room not in rooms_present:
			continue
		filter_option.add_item(ROOM_LABELS.get(room, room.capitalize()))
		filter_option.set_item_metadata(filter_option.item_count - 1, room)

	for room in rooms_present:
		if room in ROOM_ORDER:
			continue
		filter_option.add_item(ROOM_LABELS.get(room, room.capitalize()))
		filter_option.set_item_metadata(filter_option.item_count - 1, room)

	filter_option.select(0)


func _get_filter_room() -> String:
	if _current_tab != Tab.OBJECTS or filter_option.selected <= 0:
		return ""
	return filter_option.get_item_metadata(filter_option.selected)


func _on_filter_changed(_idx: int) -> void:
	_rebuild_grid()


# ─────────────────────────────────────────────
#  GRILLE
# ─────────────────────────────────────────────
func _rebuild_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	## Deux lignes horizontales avec scroll horizontal
	var row0 := HBoxContainer.new()
	var row1 := HBoxContainer.new()
	row0.add_theme_constant_override("separation", 6)
	row1.add_theme_constant_override("separation", 6)
	item_grid.add_child(row0)
	item_grid.add_child(row1)

	var filter_room : String = _get_filter_room()
	var items_to_add : Array = []

	match _current_tab:
		Tab.WALLS:
			for item_id in _all_walls:
				items_to_add.append([_all_walls[item_id], item_id])
		Tab.FLOORS:
			for item_id in _all_floors:
				items_to_add.append([_all_floors[item_id], item_id])
		Tab.OBJECTS:
			for item_id in _all_objects:
				var item : Dictionary = _all_objects[item_id]
				if filter_room != "" and item.get("room", "") != filter_room:
					continue
				items_to_add.append([item, item.get("id", item_id)])

	for i in items_to_add.size():
		var row : HBoxContainer = row0 if (i % 2 == 0) else row1
		_add_grid_item(items_to_add[i][0], items_to_add[i][1], row)


func _add_grid_item(item: Dictionary, item_id: String, row: HBoxContainer) -> void:
	var container := VBoxContainer.new()

	var btn := TextureButton.new()
	btn.custom_minimum_size = Vector2(48, 48)
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.texture_normal = _load_texture(item.get("texture", ""), item.get("region", Rect2()))
	btn.pressed.connect(_on_item_pressed.bind(item.get("type", ""), item_id))

	var lbl := Label.new()
	lbl.text = item.get("label", item_id)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.custom_minimum_size = Vector2(52, 0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD

	container.add_child(btn)
	container.add_child(lbl)
	row.add_child(container)


func _load_texture(path: String, region: Rect2) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		var img := Image.create(16, 16, false, Image.FORMAT_RGB8)
		var c1 := Color(0.85, 0.15, 0.65)
		var c2 := Color(0.25, 0.25, 0.25)
		for y in 16:
			for x in 16:
				img.set_pixel(x, y, c1 if ((x / 8 + y / 8) % 2 == 0) else c2)
		return ImageTexture.create_from_image(img)

	var base := load(path) as Texture2D
	if region == Rect2():
		return base

	var atlas := AtlasTexture.new()
	atlas.atlas  = base
	atlas.region = region
	return atlas


# ─────────────────────────────────────────────
#  SÉLECTION D'ITEM
# ─────────────────────────────────────────────
func _on_item_pressed(item_type: String, item_id: String) -> void:
	GameData.construction_type = item_type
	GameData.construction_item = item_id
	UIState.menu_open = false

	var item = ItemRegistry.get_item(item_id)
	var label = item.get("label", item_id)
	EventBus.construction_mode_changed.emit(item_type, item_id)
	EventBus.ui_notification_requested.emit("Placement : %s" % label, "info")
	EventBus.reset_preview.emit()


func _on_close_pressed() -> void:
	hide()
	GameData.construction_type = ""
	GameData.construction_item = ""
	UIState.menu_open = false
	EventBus.construction_mode_changed.emit("", "")


# ─────────────────────────────────────────────
#  DESTRUCTION
# ─────────────────────────────────────────────
func _on_destroy_all_pressed()    -> void: _set_destroy("destroy_all")
func _on_destroy_wall_pressed()   -> void: _set_destroy("destroy_wall")
func _on_destroy_floor_pressed()  -> void: _set_destroy("destroy_floor")
func _on_destroy_object_pressed() -> void: _set_destroy("destroy_object")


func _set_destroy(destroy_type: String) -> void:
	EventBus.reset_preview.emit()
	GameData.construction_type = destroy_type
	GameData.construction_item = ""
	UIState.menu_open = false
	hide()
	EventBus.construction_mode_changed.emit(destroy_type, "")
