## ConstructionLayer.gd
## Nœud de scène (dans World/Construction).
## C'est lui qui touche aux TileMaps et instancie les nodes d'objets.
## ConstructionManager décide, ConstructionLayer exécute.
##
## Arbre attendu dans la scène :
##   Construction/
##   ├── ConstructionLayer  ← ce script
##   ├── Grid               ← grille visuelle (Grid.gd)
##   └── Preview            ← prévisualisation (ConstructionPreview.gd)
extends Node2D
class_name ConstructionLayer


# ─────────────────────────────────────────────
#  RÉFÉRENCES AUX TILEMAPS (dans World/Level)
# ─────────────────────────────────────────────
@onready var floor_layer       : TileMapLayer = $"../../World/Level/Floor"
@onready var wall_layer        : TileMapLayer = $"../../World/Level/Wall"
@onready var placeholder_layer : TileMapLayer = $"../../World/Level/Placeholder"
@onready var objects_container : Node2D       = $"../../World/Objects"

@onready var grid    : Node2D = $"../Grid"
@onready var preview : Node2D = $"../Preview"



## Placeholders visuels : Sprite2D/ColorRect pour sols/objets, tiles BetterTerrain pour murs.
## { Vector2i → Node2D|null }  (null = tile BetterTerrain sur placeholder_layer)
var _placeholder_nodes      : Dictionary = {}
## Positions des placeholders murs placés sur placeholder_layer { Vector2i → true }
var _wall_placeholder_cells : Dictionary = {}
const TILE : int = 16   ## GameConfig.TILE_SIZE — copié ici pour éviter la dépendance circulaire


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	## Écoute les signaux de résultat de ConstructionManager
	EventBus.wall_placed.connect(_on_wall_placed)
	EventBus.wall_removed.connect(_on_wall_removed)
	EventBus.floor_placed.connect(_on_floor_placed)
	EventBus.object_placed.connect(_on_object_placed)
	EventBus.object_removed.connect(_on_object_removed)
	EventBus.construction_task_added.connect(_on_task_added)
	EventBus.walls_destroyed.connect(_on_walls_destroyed)


	## Teinte bleue sur le layer de placeholders murs
	placeholder_layer.modulate = Color(0.55, 0.80, 1.0, 0.72)

	## Écoute les changements de mode (pour afficher/cacher la grille)
	EventBus.construction_mode_changed.connect(_on_mode_changed)
	EventBus.ui_panel_close_requested.connect(_on_panel_closed)


func _exit_tree() -> void:
	if EventBus.wall_placed.is_connected(_on_wall_placed):
		EventBus.wall_placed.disconnect(_on_wall_placed)
	if EventBus.wall_removed.is_connected(_on_wall_removed):
		EventBus.wall_removed.disconnect(_on_wall_removed)
	if EventBus.floor_placed.is_connected(_on_floor_placed):
		EventBus.floor_placed.disconnect(_on_floor_placed)
	if EventBus.object_placed.is_connected(_on_object_placed):
		EventBus.object_placed.disconnect(_on_object_placed)
	if EventBus.object_removed.is_connected(_on_object_removed):
		EventBus.object_removed.disconnect(_on_object_removed)
	if EventBus.construction_task_added.is_connected(_on_task_added):
		EventBus.construction_task_added.disconnect(_on_task_added)
	if EventBus.walls_destroyed.is_connected(_on_walls_destroyed):
		EventBus.walls_destroyed.disconnect(_on_walls_destroyed)
	if EventBus.construction_mode_changed.is_connected(_on_mode_changed):
		EventBus.construction_mode_changed.disconnect(_on_mode_changed)
	if EventBus.ui_panel_close_requested.is_connected(_on_panel_closed):
		EventBus.ui_panel_close_requested.disconnect(_on_panel_closed)


# ─────────────────────────────────────────────
#  CALLBACKS RÉSULTATS
# ─────────────────────────────────────────────
func _erase_placeholder(pos: Vector2i) -> void:
	if not _placeholder_nodes.has(pos):
		return

	## Placeholder mur (tile BetterTerrain sur placeholder_layer)
	if _wall_placeholder_cells.has(pos):
		_wall_placeholder_cells.erase(pos)
		_placeholder_nodes.erase(pos)
		placeholder_layer.erase_cell(pos)
		## Met à jour le terrain des voisins encore présents
		var neighbors : Array[Vector2i] = []
		var offsets : Array[Vector2i] = [
			Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0),
			Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)
		]
		for offset in offsets:
			var n := pos + offset
			if _wall_placeholder_cells.has(n):
				neighbors.append(n)
		if neighbors.size() > 0:
			BetterTerrain.update_terrain_cells(placeholder_layer, neighbors)
		return

	## Placeholder sol/objet (Sprite2D ou ColorRect)
	var node = _placeholder_nodes[pos]
	_placeholder_nodes.erase(pos)
	## Ne libère que si plus aucune case ne référence ce node (multi-tiles)
	if is_instance_valid(node) and not _placeholder_nodes.values().has(node):
		node.queue_free()


func _on_wall_placed(pos: Vector2i, item_id: String) -> void:
	var item     : Dictionary = ItemRegistry.get_item(item_id)
	var atlas_id : int        = item.get("atlas_id", 0)
	_erase_placeholder(pos)
	wall_layer.set_cell(pos, atlas_id, _get_wall_atlas(item_id))
	GameData.walls[pos] = item_id
	## Efface le sol sous le mur
	floor_layer.erase_cell(pos)
	GameData.floors.erase(pos)
	BetterTerrain.update_terrain_cells(wall_layer, [pos])


func _on_wall_removed(pos: Vector2i) -> void:
	wall_layer.erase_cell(pos)
	GameData.walls.erase(pos)
	_erase_placeholder(pos)

func _on_walls_destroyed(destroyed: Array[Vector2i], neighbors: Array[Vector2i]) -> void:
	# Efface les tiles détruites du layer mur
	for pos in destroyed:
		wall_layer.erase_cell(pos)

	# Met à jour BetterTerrain sur les voisins restants
	if neighbors.size() > 0:
		BetterTerrain.update_terrain_cells(wall_layer, neighbors)

func _on_floor_placed(pos: Vector2i, floor_id: String) -> void:
	var atlas_id : int    = ItemRegistry.get_item(floor_id).get("atlas_id", 0)
	var atlas    : Vector2i = _get_floor_atlas(floor_id)
	_erase_placeholder(pos)
	floor_layer.set_cell(pos, atlas_id, atlas)
	if floor_id == "grass":
		GameData.floors.erase(pos)
	else:
		GameData.floors[pos] = floor_id


func _on_task_added(task: Dictionary) -> void:
	match task["type"]:
		"wall", "floor":
			_add_tile_placeholder(task["origin"], task.get("item_id", ""), task["type"])
		"object":
			_add_object_placeholder(task)


## Placeholder mur : tile sur placeholder_layer avec BetterTerrain (se connecte aux voisins).
## Placeholder sol : Sprite2D avec texture (pas de BetterTerrain).
func _add_tile_placeholder(pos: Vector2i, item_id: String, task_type: String) -> void:
	if _placeholder_nodes.has(pos):
		return
	var item : Dictionary = ItemRegistry.get_item(item_id)

	if task_type == "wall":
		var ts        := placeholder_layer.tile_set
		var count     := BetterTerrain.terrain_count(ts)
		var terrain_idx : int = -1
		for i in range(count):
			if BetterTerrain.get_terrain(ts, i).get("name", "") == item_id:
				terrain_idx = i
				break
		if terrain_idx >= 0:
			BetterTerrain.set_cell(placeholder_layer, pos, terrain_idx)
			BetterTerrain.update_terrain_cells(placeholder_layer, [pos])
			_wall_placeholder_cells[pos] = true
			_placeholder_nodes[pos] = null  ## sentinel tile-based
			return

	## Sol : Sprite2D avec texture
	var tex_path : String = item.get("texture", "")
	var region   : Rect2  = item.get("region",  Rect2())

	var sprite : Sprite2D = Sprite2D.new()
	sprite.centered = false
	sprite.position = Vector2(pos) * TILE
	sprite.z_index  = 5
	sprite.modulate = Color(0.55, 0.80, 1.0, 0.72)

	if tex_path != "" and ResourceLoader.exists(tex_path):
		var base : Texture2D = load(tex_path) as Texture2D
		if region.size != Vector2.ZERO:
			var atlas : AtlasTexture = AtlasTexture.new()
			atlas.atlas    = base
			atlas.region   = region
			sprite.texture = atlas
		else:
			sprite.texture = base

	placeholder_layer.get_parent().add_child(sprite)
	_placeholder_nodes[pos] = sprite


## Instancie la scène de l'objet comme placeholder visuel (sans collisions ni groupe).
func _add_object_placeholder(task: Dictionary) -> void:
	var origin   : Vector2i = task["origin"]
	var item_id  : String   = task.get("item_id", "")
	var size     : Vector2  = task.get("size", Vector2.ONE)
	var object_rotation : int      = task.get("rotation", 0)

	if _placeholder_nodes.has(origin):
		return

	var folder     : String = item_id.to_pascal_case()
	var scene_path : String = "res://Entities/Objects/%s/%s.tscn" % [folder, item_id]
	var node  ## Variant — peut être une scène Node2D ou un ColorRect Control

	if ResourceLoader.exists(scene_path):
		node          = (load(scene_path) as PackedScene).instantiate()
		node.position = Vector2(origin) * TILE
		node.z_index  = 5
		node.modulate = Color(0.55, 0.80, 1.0, 0.72)
		placeholder_layer.get_parent().add_child(node)

		## Désactive les collisions et retire du groupe pour que les héros ignorent ce node
		for child in node.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).disabled = true
			elif child is CollisionPolygon2D:
				(child as CollisionPolygon2D).disabled = true
		if node.is_in_group("guild_objects"):
			node.remove_from_group("guild_objects")
		if node.has_method("apply_rotation"):
			node.apply_rotation(object_rotation)
	else:
		## Fallback : rectangle couvrant l'empreinte de l'objet
		var cr : ColorRect = ColorRect.new()
		cr.size         = size * Vector2(TILE, TILE)
		cr.color        = Color(1.0, 1.0, 1.0, 0.72)
		cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cr.position     = Vector2(origin) * TILE
		cr.z_index      = 5
		cr.modulate     = Color(0.55, 0.80, 1.0, 0.72)
		node = cr
		placeholder_layer.get_parent().add_child(node)

	for x in range(int(size.x)):
		for y in range(int(size.y)):
			_placeholder_nodes[origin + Vector2i(x, y)] = node


func _on_object_placed(object_id: String, origin: Vector2i) -> void:
	var obj_data : Dictionary = ConstructionManager.get_object_at(origin)
	var size     : Vector2    = obj_data.get("size", Vector2.ONE)

	## Efface les placeholders ColorRect
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			_erase_placeholder(origin + Vector2i(x, y))

	## Instancie le node de l'objet
	## Convention : res://Entities/Objects/Anvil/anvil.tscn
	var folder     = object_id.to_pascal_case()
	var scene_path = "res://Entities/Objects/%s/%s.tscn" % [folder, object_id]
	if not ResourceLoader.exists(scene_path):
		push_warning("ConstructionLayer: scène introuvable '%s'" % scene_path)
		return

	var scene    = load(scene_path) as PackedScene
	var instance = scene.instantiate()
	instance.object_id = object_id
	instance.position  = Vector2(origin) * GameConfig.TILE_SIZE

	objects_container.add_child(instance)

	if instance.has_method("apply_rotation"):
		instance.apply_rotation(obj_data.get("rotation", 0))

	## Stocke la référence dans ConstructionManager
	if ConstructionManager.placed_objects.has(origin):
		ConstructionManager.placed_objects[origin]["instance_node"] = instance


func _on_object_removed(origin: Vector2i) -> void:
	## Détruit TOUS les nodes à cette position (gère les éventuels doublons éditeur+spawné)
	var target_pos := Vector2(origin) * GameConfig.TILE_SIZE
	for obj in objects_container.get_children():
		if obj.position == target_pos:
			obj.queue_free()


# ─────────────────────────────────────────────
#  GRILLE VISUELLE
# ─────────────────────────────────────────────
func _on_mode_changed(construction_type: String, _item_id: String) -> void:
	grid.visible = (construction_type != "")
	if construction_type == "":
		## Reset complet du preview quand on quitte le mode construction
		preview.reset()

func _on_panel_closed(panel_id: String) -> void:
	if panel_id == "build_menu":
		grid.visible = false
		preview.reset()


# ─────────────────────────────────────────────
#  ATLAS COORDS (à adapter selon ton TileSet)
# ─────────────────────────────────────────────
func _get_wall_atlas(wall_id: String) -> Vector2i:
	var map := {
		"stone_wall": Vector2i(0, 0),
		"wood_wall":  Vector2i(0, 0),
		"brick_wall": Vector2i(0, 0),
		"door":       Vector2i(0, 0),
	}
	return map.get(wall_id, Vector2i(0, 0))


func _get_floor_atlas(floor_id: String) -> Vector2i:
	var map := {
		"grass":       Vector2i(0, 0),
		"wood_floor":  Vector2i(0, 0),
		"stone_floor": Vector2i(0, 0),
		#"carpet":      Vector2i(3, 0),
	}
	return map.get(floor_id, Vector2i(0, 0))
