## ConstructionPreview.gd
extends Node2D

@onready var grid          : Node2D       = $"../Grid"
@onready var preview_layer : TileMapLayer = $"../../World/Level/Preview"

const VALID_COLOR   := Color(0.3, 1.0, 0.3, 0.55)
const INVALID_COLOR := Color(1.0, 0.25, 0.25, 0.55)

var _start_pos        : Vector2i = Vector2i.ZERO
var _end_pos          : Vector2i = Vector2i.ZERO
var _is_selecting     : bool     = false
var _object_preview   : Node2D   = null
var _current_rotation : int      = 0

var _last_preview_cells : Array[Vector2i] = []
## { Vector2i → bool } — validité par case pour le _draw
var _cell_validity      : Dictionary       = {}
## Cache AtlasTexture pour les sols { item_id → Texture2D }
var _tex_cache          : Dictionary       = {}


# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.reset_preview.connect(reset)


func _exit_tree() -> void:
	if EventBus.reset_preview.is_connected(reset):
		EventBus.reset_preview.disconnect(reset)


# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _process(_delta: float) -> void:
	if GameData.construction_type == "":
		if _object_preview:
			_object_preview.visible = false
		_clear_preview_layer()
		return

	var cell = grid.get_hovered_cell()

	match GameData.construction_type:
		"object", "move":
			_clear_preview_layer()
			_update_object_preview(cell)
		_:
			_end_pos = cell
			if not _is_selecting:
				_start_pos = cell
			_update_tile_preview()


# ─────────────────────────────────────────────
#  PREVIEW TILES
# ─────────────────────────────────────────────
func _update_tile_preview() -> void:
	var t_type  : String = GameData.construction_type
	var item_id : String = GameData.construction_item
	var is_destroy : bool = t_type.begins_with("destroy")

	# Pas d'item requis pour les destructions
	if not is_destroy:
		if item_id == "":
			_clear_preview_layer()
			return
		var item : Dictionary = ItemRegistry.get_item(item_id)
		if item.is_empty():
			_clear_preview_layer()
			return

	var min_x := mini(_start_pos.x, _end_pos.x)
	var max_x := maxi(_start_pos.x, _end_pos.x)
	var min_y := mini(_start_pos.y, _end_pos.y)
	var max_y := maxi(_start_pos.y, _end_pos.y)

	_clear_preview_layer()

	# Pour les destructions : pas de tile sur le layer, juste le _draw
	if is_destroy:
		for x in range(min_x, max_x + 1):
			for y in range(min_y, max_y + 1):
				var pos := Vector2i(x, y)
				if not _should_include_cell(t_type, x, y, min_x, max_x, min_y, max_y):
					continue
				_cell_validity[pos] = _is_cell_valid(t_type, pos)
				_last_preview_cells.append(pos)
		queue_redraw()
		return

	# Construction normale (mur ou sol)
	var new_item        : Dictionary = ItemRegistry.get_item(item_id)
	var atlas_id    : int        = new_item.get("atlas_id", -1)
	var is_wall     : bool       = (new_item.get("type", "") == "wall")
	var _terrain_set : int        = new_item.get("terrain_set", -1)
	var _terrain_id  : int        = new_item.get("terrain_id",  -1)

	var cells_to_terrain : Array[Vector2i] = []

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var pos := Vector2i(x, y)
			if not _should_include_cell(t_type, x, y, min_x, max_x, min_y, max_y):
				continue
			_cell_validity[pos] = _is_cell_valid(t_type, pos)
			_last_preview_cells.append(pos)

			if is_wall and atlas_id >= 0:
				preview_layer.set_cell(pos, atlas_id, Vector2i.ZERO)
				cells_to_terrain.append(pos)

	if cells_to_terrain.size() > 0:
		BetterTerrain.update_terrain_cells(preview_layer, cells_to_terrain)

	queue_redraw()

# ─────────────────────────────────────────────
#  DRAW — couleur sur murs + texture pour sols
# ─────────────────────────────────────────────
func _draw() -> void:
	# Gère maintenant TOUS les types y compris les destructions
	if GameData.construction_type in ["", "object", "move"]:
		return

	var item_id  : String = GameData.construction_item
	var t_type   : String = GameData.construction_type
	var is_destroy : bool = t_type.begins_with("destroy")

	# Les destructions n'ont pas d'item_id — on dessine juste la couleur
	if not is_destroy:
		if item_id == "":
			return
		var item : Dictionary = ItemRegistry.get_item(item_id)
		if item.is_empty():
			return

	var is_wall : bool = not is_destroy and (ItemRegistry.get_item(item_id).get("type", "") == "wall")
	var atlas   : Texture2D = null
	if not is_destroy and not is_wall:
		atlas = _get_atlas_texture(item_id)

	var ts : int = GameConfig.TILE_SIZE

	for pos in _cell_validity.keys():
		var color : Color = VALID_COLOR if _cell_validity[pos] else INVALID_COLOR
		var dest  := Rect2(Vector2(pos.x * ts, pos.y * ts), Vector2(ts, ts))

		if is_destroy:
			# Destruction : rectangle semi-transparent rouge/vert uni
			draw_rect(dest, color)
		elif is_wall:
			# Mur : couleur par-dessus la tile BetterTerrain
			draw_rect(dest, color)
		else:
			# Sol : texture avec couleur
			if atlas:
				draw_texture_rect(atlas, dest, false, color)
			else:
				draw_rect(dest, color)

# ─────────────────────────────────────────────
#  CACHE ATLAS TEXTURE (sols)
# ─────────────────────────────────────────────
func _get_atlas_texture(item_id: String) -> Texture2D:
	if _tex_cache.has(item_id):
		return _tex_cache[item_id]

	var item   : Dictionary = ItemRegistry.get_item(item_id)
	var path   : String     = item.get("texture", "")
	var region : Rect2      = item.get("region",  Rect2())

	if path == "" or not ResourceLoader.exists(path):
		_tex_cache[item_id] = null
		return null

	var base := load(path) as Texture2D
	var result : Texture2D

	if region == Rect2() or region.size == Vector2.ZERO:
		result = base
	else:
		var atlas_tex      := AtlasTexture.new()
		atlas_tex.atlas    = base
		atlas_tex.region   = region
		result             = atlas_tex

	_tex_cache[item_id] = result
	return result


# ─────────────────────────────────────────────
#  NETTOYAGE
# ─────────────────────────────────────────────
func _clear_preview_layer() -> void:
	for pos in _last_preview_cells:
		preview_layer.erase_cell(pos)
	_last_preview_cells.clear()
	_cell_validity.clear()
	queue_redraw()


# ─────────────────────────────────────────────
#  LOGIQUE DE SÉLECTION
# ─────────────────────────────────────────────
func _should_include_cell(
		t_type: String, x: int, y: int,
		min_x: int, max_x: int, min_y: int, max_y: int) -> bool:
	match t_type:
		"wall":
			# Contour uniquement
			return (x == min_x or x == max_x or y == min_y or y == max_y)
		"floor":
			# Plein, saute les cases avec mur
			return not GameData.walls.has(Vector2i(x, y))
		_:
			# destroy_wall, destroy_floor, destroy_all, destroy_object → plein
			return true



func _is_cell_valid(t_type: String, pos: Vector2i) -> bool:
	match t_type:
		"wall":
			if not ConstructionManager.is_in_bounds(pos):
				return false
			if ConstructionManager.is_position_occupied(pos):
				return false
			return true
		"floor":
			if not ConstructionManager.is_in_bounds(pos):
				return false
			if GameData.walls.has(pos):
				return false
			return true
		"destroy_wall":
			return GameData.walls.has(pos)
		"destroy_floor":
			return GameData.floors.has(pos)
		"destroy_all":
			return (GameData.walls.has(pos)
				or GameData.floors.has(pos)
				or ConstructionManager.is_position_occupied(pos))
		"destroy_object":
			return ConstructionManager.is_position_occupied(pos)
		_:
			return true


# ─────────────────────────────────────────────
#  CONTRÔLE
# ─────────────────────────────────────────────
func start_selection(pos: Vector2i) -> void:
	_start_pos    = pos
	_end_pos      = pos
	_is_selecting = true


func end_selection() -> void:
	_is_selecting = false
	_clear_preview_layer()


func refresh_rotation(rotation_val: int) -> void:
	_current_rotation = rotation_val
	if _object_preview and _object_preview.has_method("apply_rotation"):
		_object_preview.apply_rotation(rotation_val)


func reset() -> void:
	_is_selecting = false
	_start_pos    = Vector2i.ZERO
	_end_pos      = Vector2i.ZERO
	_clear_preview_layer()
	if _object_preview:
		_object_preview.queue_free()
		_object_preview = null


# ─────────────────────────────────────────────
#  PRÉVISUALISATION D'OBJET
# ─────────────────────────────────────────────
func _update_object_preview(cell: Vector2i) -> void:
	var item_id := GameData.construction_item
	if item_id == "":
		return
	if _object_preview == null:
		_spawn_object_preview(item_id)
	if _object_preview:
		_object_preview.position = Vector2(cell) * GameConfig.TILE_SIZE
		_object_preview.visible  = true
		_check_object_validity(cell, item_id)


func _spawn_object_preview(item_id: String) -> void:
	var folder     := item_id.capitalize()
	var scene_path := "res://Entities/Objects/%s/%s.tscn" % [folder, item_id]
	if not ResourceLoader.exists(scene_path):
		push_warning("ConstructionPreview: scène introuvable '%s'" % scene_path)
		return
	_object_preview = (load(scene_path) as PackedScene).instantiate()
	_object_preview.modulate = VALID_COLOR
	_object_preview.z_index  = 10
	for child in _object_preview.get_children():
		if child is CollisionShape2D:
			child.disabled = true
		elif child is CollisionPolygon2D:
			child.disabled = true
	add_child(_object_preview)
	if _object_preview.has_method("apply_rotation"):
		_object_preview.apply_rotation(_current_rotation)


func _check_object_validity(origin: Vector2i, item_id: String) -> void:
	if not _object_preview:
		return
	var item := ItemRegistry.get_item(item_id)
	var size := ConstructionManager.get_rotated_size(
		item.get("size", Vector2.ONE), _current_rotation
	)
	var valid := true
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var check := origin + Vector2i(x, y)
			if not ConstructionManager.is_in_bounds(check):
				valid = false
				break
			if GameData.walls.has(check) or ConstructionManager.is_position_occupied(check):
				valid = false
				break
		if not valid:
			break
	_object_preview.modulate = VALID_COLOR if valid else INVALID_COLOR
