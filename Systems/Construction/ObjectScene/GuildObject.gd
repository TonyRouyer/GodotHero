## GuildObject.gd — Classe de base pour tous les objets posables dans la guilde.
##
## Chaque objet est une scène .tscn autonome :
##   • Les sprites, collisions et positions d'utilisation sont définis dans la scène.
##   • Les exports (effect, restore_stat…) sont réglés dans l'inspecteur par scène.
##   • Cette classe gère tout le comportement générique.
##
## Structure attendue dans chaque .tscn :
##   GuildObject (Node2D)
##     ├── CollisionShape2D
##     └── Rotations (Node2D)
##         ├── Rot0 (Node2D)  [meta: col_size, col_offset]
##         │     ├── Sprite2D           (optionnel — absent → placeholder magenta)
##         │     └── UsePos0 (Marker2D) (position d'utilisation du héros)
##         ├── Rot1 (Node2D, visible=false)
##         ├── Rot2 (Node2D, visible=false)
##         └── Rot3 (Node2D, visible=false)
##
## Pour ajouter un objet : créer la scène + ligne dans ItemRegistry. C'est tout.
extends Node2D
class_name GuildObject


# ─────────────────────────────────────────────
#  EXPORTS — réglés dans l'inspecteur de chaque scène
# ─────────────────────────────────────────────
@export var object_id            : String = ""
@export var max_users            : int    = 1
@export var rotation_index       : int    = 0

## "none" | "restore" | "release_when_full" | "eat"
@export var effect               : String = "none"
@export var restore_stat         : String = ""
@export var restore_per_tick     : float  = 0.0
@export var release_threshold    : float  = 100.0


# ─────────────────────────────────────────────
#  ÉTAT INTERNE
# ─────────────────────────────────────────────
var used         : bool        = false
var _users       : Array[Node] = []
var _origin      : Vector2i
var _rotation    : int         = 0
var _active_hero : Node        = null
var _placeholder : Sprite2D    = null


# ─────────────────────────────────────────────
#  NŒUDS ENFANTS
# ─────────────────────────────────────────────
@onready var col      : CollisionShape2D = $CollisionShape2D
@onready var _rot_root: Node2D           = $Rotations


# ─────────────────────────────────────────────
#  INITIALISATION
# ─────────────────────────────────────────────
func _ready() -> void:
	_origin = Vector2i(int(position.x) / GameConfig.TILE_SIZE,
					   int(position.y) / GameConfig.TILE_SIZE)
	add_to_group("guild_objects")
	col.shape = col.shape.duplicate()
	_ensure_placeholder()
	apply_rotation(rotation_index)


## Crée un sprite placeholder magenta/gris si aucun Rot node ne contient de Sprite2D.
func _ensure_placeholder() -> void:
	for rot_node in _rot_root.get_children():
		for child in rot_node.get_children():
			if child is Sprite2D:
				return   ## Au moins un sprite trouvé, pas de placeholder
	var img := Image.create(16, 16, false, Image.FORMAT_RGB8)
	var c1  := Color(0.85, 0.15, 0.65)
	var c2  := Color(0.25, 0.25, 0.25)
	for y in 16:
		for x in 16:
			img.set_pixel(x, y, c1 if ((x / 8 + y / 8) % 2 == 0) else c2)
	_placeholder = Sprite2D.new()
	_placeholder.texture = ImageTexture.create_from_image(img)
	_placeholder.centered = false
	add_child(_placeholder)


# ─────────────────────────────────────────────
#  ROTATION
# ─────────────────────────────────────────────

## Affiche le Rot node actif, met à jour la collision depuis ses métadonnées.
func apply_rotation(rot: int) -> void:
	_rotation = rot
	for i in _rot_root.get_child_count():
		_rot_root.get_child(i).visible = (i == rot)
	if _rot_root.get_child_count() > rot:
		var rot_node : Node2D = _rot_root.get_child(rot)
		_set_collision(
			rot_node.get_meta("col_size",   Vector2(16.0, 32.0)),
			rot_node.get_meta("col_offset", Vector2(8.0,  16.0))
		)
	if _placeholder:
		_placeholder.visible = not _has_sprite_in_rot(rot)


func _has_sprite_in_rot(rot: int) -> bool:
	if _rot_root.get_child_count() <= rot:
		return false
	for child in _rot_root.get_child(rot).get_children():
		if child is Sprite2D:
			return true
	return false


func _set_collision(size: Vector2, center: Vector2) -> void:
	(col.shape as RectangleShape2D).size = size
	col.position                         = center


# ─────────────────────────────────────────────
#  API HÉROS
# ─────────────────────────────────────────────

func use(hero: Node) -> void:
	if _users.size() >= max_users:
		return
	if effect == "eat":
		if not GameData.consume_food(1):
			if hero.activity:
				hero.activity.used_object = null
			return
	_users.append(hero)
	used = _users.size() >= max_users
	hero.global_position = get_use_position()
	hero.freeze_movement()
	EventBus.object_used.emit(object_id, hero.data.hero_id)
	if effect != "none":
		_active_hero = hero
		if not EventBus.time_tick.is_connected(_on_time_tick):
			EventBus.time_tick.connect(_on_time_tick)


func exit(hero: Node) -> void:
	_users.erase(hero)
	used = false
	hero.unfreeze_movement()
	EventBus.object_freed.emit(object_id, hero.data.hero_id)
	if effect != "none":
		_active_hero = null
		_disconnect_tick()
		clear_state()


func is_available() -> bool:
	if _users.size() >= max_users:
		return false
	if effect == "eat":
		return GameData.food > 0
	return true


## Nettoyage visuel à la libération. Surcharger dans les sous-classes si besoin.
func clear_state() -> void:
	pass


# ─────────────────────────────────────────────
#  POSITION D'UTILISATION
# ─────────────────────────────────────────────

## Retourne la position monde où le héros courant doit se placer.
## Lit les Marker2D du Rot node actif dans l'ordre d'arrivée.
func get_use_position() -> Vector2:
	if _rot_root.get_child_count() <= _rotation:
		return global_position
	var markers : Array[Marker2D] = []
	for child in _rot_root.get_child(_rotation).get_children():
		if child is Marker2D:
			markers.append(child as Marker2D)
	if markers.is_empty():
		return global_position
	var idx : int = clamp(_users.size() - 1, 0, markers.size() - 1)
	return global_position + markers[idx].position


# ─────────────────────────────────────────────
#  EFFET HORAIRE
# ─────────────────────────────────────────────

func _on_time_tick(hour: int, _minute: int) -> void:
	if _active_hero == null or not is_instance_valid(_active_hero):
		_active_hero = null
		used         = false
		_disconnect_tick()
		clear_state()
		return
	var data = _active_hero.data
	if data == null:
		return
	match effect:
		"restore", "eat":
			var current : float = data.get(restore_stat)
			data.set(restore_stat, minf(100.0, current + restore_per_tick))
			if data.get(restore_stat) >= release_threshold:
				if _active_hero.activity:
					_active_hero.activity.release_from_object()
		"release_when_full":
			if data.get(restore_stat) >= release_threshold:
				if _active_hero.activity:
					_active_hero.activity.release_from_object()
	var _h : int = hour


func _disconnect_tick() -> void:
	if EventBus.time_tick.is_connected(_on_time_tick):
		EventBus.time_tick.disconnect(_on_time_tick)


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────
func get_rotation_index() -> int:    return rotation_index
func get_origin()          -> Vector2i: return _origin
func get_item_data()       -> Dictionary: return ItemRegistry.get_item(object_id)


# ─────────────────────────────────────────────
#  INPUT — CLIC DROIT → MENU CONTEXTUEL
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb : InputEventMouseButton = event as InputEventMouseButton
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_RIGHT:
		return
	if UIState.menu_open or GameData.construction_type != "":
		return
	if _get_click_bounds().has_point(get_global_mouse_position()):
		get_viewport().set_input_as_handled()
		EventBus.object_context_menu_requested.emit(self, get_viewport().get_mouse_position())


func _get_click_bounds() -> Rect2:
	for child in get_children():
		if child is CollisionShape2D and not (child as CollisionShape2D).disabled:
			var shape = (child as CollisionShape2D).shape
			if shape is RectangleShape2D:
				var sz  : Vector2 = (shape as RectangleShape2D).size
				var off : Vector2 = (child as CollisionShape2D).position - sz * 0.5
				return Rect2(global_position + off, sz)
	var obj_data  : Dictionary = ConstructionManager.get_object_at(_origin)
	var item_data : Dictionary = get_item_data()
	var obj_size : Vector2 = obj_data.get("size", item_data.get("size", Vector2.ONE)) * GameConfig.TILE_SIZE
	return Rect2(global_position, obj_size)
