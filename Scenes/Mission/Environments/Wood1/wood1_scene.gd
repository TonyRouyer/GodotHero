## wood1_scene.gd
## Scène d'environnement : Forêt (Wood 1)
## Architecture :
##   - TeamSpawn   : Marker2D — position de départ de l'équipe
##   - MobZones    : 3× Area2D (ZoneA/B/C) — zones de spawn des ennemis
##   - LootZones   : 1× Area2D (ZoneLoot) — zone de spawn du loot
##   - Ennemis et loot sont placés via setup_for_mission() selon la mission reçue
extends Node2D

const TILE_SIZE    : int = 16
const MAP_W        : int = 40   # tuiles
const MAP_H        : int = 30   # tuiles

const TREE_TEXTURE : String = "res://Assets/Objects/tree.png"
const GRASS_TEX    : String = "res://Assets/Tiles/grass_floor.png"
const DIRT_TEX     : String = "res://Assets/Tiles/dirt_floor.png"

# Données de mission courante
var _mission_data : Dictionary = {}

# Containers
@onready var _heroes_container   : Node2D = $Heroes
@onready var _enemies_container  : Node2D = $Enemies
@onready var _loot_container     : Node2D = $Loot
@onready var _mission_map        : Node2D = $MissionMap
@onready var _team_spawn         : Marker2D = $TeamSpawn

# Zones
@onready var _zone_a    : Area2D = $MobZones/ZoneA
@onready var _zone_b    : Area2D = $MobZones/ZoneB
@onready var _zone_c    : Area2D = $MobZones/ZoneC
@onready var _zone_loot : Area2D = $LootZones/ZoneLoot

# UI
@onready var _mission_label : Label = $UI/MissionLabel


func _ready() -> void:
	_paint_map()
	_place_trees()


## Appelé par mission_scene pour configurer la mission.
## mission_data : le Dictionary de la mission (name, difficulty, gold, …)
func setup_for_mission(mission_data: Dictionary) -> void:
	_mission_data = mission_data
	if _mission_label:
		_mission_label.text = mission_data.get("name", "Mission")
	_place_enemies()
	_place_loot()


## ── Accesseurs publics pour mission_scene ────────────────────────────────────
func get_team_spawn_position() -> Vector2:
	return _team_spawn.global_position if _team_spawn else Vector2(320.0, 448.0)

func get_heroes_container() -> Node2D:
	return _heroes_container

func get_enemies_container() -> Node2D:
	return _enemies_container


# ─────────────────────────────────────────────
#  GÉNÉRATION DE LA CARTE
# ─────────────────────────────────────────────

func _paint_map() -> void:
	var grass_tex : Texture2D = load(GRASS_TEX)
	var dirt_tex  : Texture2D = load(DIRT_TEX)
	if not grass_tex or not dirt_tex:
		push_warning("Wood1Scene : textures de tuiles introuvables")
		return

	# Grille de base : grass
	for tx in MAP_W:
		for ty in MAP_H:
			_place_tile(tx, ty, grass_tex, Rect2(32, 0, 16, 16))

	# Chemin de terre sinueux (bas-centre → haut-centre)
	var path_tiles : Array[Vector2i] = _generate_dirt_path()
	for pt in path_tiles:
		_place_tile(pt.x, pt.y, dirt_tex, Rect2(16, 16, 16, 16))
		# Élargir le chemin de 1 tuile de chaque côté
		if pt.x > 0:
			_place_tile(pt.x - 1, pt.y, dirt_tex, Rect2(16, 16, 16, 16))
		if pt.x < MAP_W - 1:
			_place_tile(pt.x + 1, pt.y, dirt_tex, Rect2(16, 16, 16, 16))


func _place_tile(tx: int, ty: int, texture: Texture2D, region: Rect2) -> void:
	var sp := Sprite2D.new()
	sp.texture        = texture
	sp.region_enabled = true
	sp.region_rect    = region
	sp.centered       = false
	sp.position       = Vector2(tx * TILE_SIZE, ty * TILE_SIZE)
	sp.z_index        = -10
	_mission_map.add_child(sp)


func _generate_dirt_path() -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	var cx    : int = MAP_W / 2   # colonne de départ (bas-centre)
	for ty in range(MAP_H - 1, -1, -1):
		tiles.append(Vector2i(cx, ty))
		# Déviation aléatoire (seed fixe pour reproductibilité)
		var r := randi_range(0, 3)
		if   r == 0 and cx > 2:              cx -= 1
		elif r == 1 and cx < MAP_W - 3:     cx += 1
	return tiles


func _place_trees() -> void:
	var tex : Texture2D = load(TREE_TEXTURE)
	if not tex:
		push_warning("Wood1Scene : texture arbre introuvable")
		return

	# Bordure gauche (x=0,1) et droite (x=MAP_W-2, MAP_W-1)
	for ty in range(0, MAP_H, 2):
		_add_tree(tex, 0,          ty)
		_add_tree(tex, 1,          ty)
		_add_tree(tex, MAP_W - 2,  ty)
		_add_tree(tex, MAP_W - 1,  ty)

	# Bordure haute (y=0,1), milieu exclu pour laisser le chemin
	for tx in range(4, MAP_W - 4, 2):
		_add_tree(tex, tx, 0)
		_add_tree(tex, tx, 1)

	# Quelques arbres aléatoires au milieu
	for _i in 30:
		var tx := randi_range(3, MAP_W - 4)
		var ty := randi_range(3, MAP_H - 6)
		_add_tree(tex, tx, ty)


func _add_tree(tex: Texture2D, tx: int, ty: int) -> void:
	var sp := Sprite2D.new()
	sp.texture  = tex
	sp.centered = false
	sp.position = Vector2(tx * TILE_SIZE, ty * TILE_SIZE)
	sp.z_index  = ty   # tri Y simple
	_mission_map.add_child(sp)


# ─────────────────────────────────────────────
#  PLACEMENT ENNEMIS / LOOT
# ─────────────────────────────────────────────

## Difficulté → rang des mobs
const DIFF_TO_RANK : Dictionary = {
	1: "F", 2: "E", 3: "D", 4: "C", 5: "B",
}

## Loot par difficulté : liste d'item_id possibles
const LOOT_POOLS : Dictionary = {
	1: ["slime_gel", "wood_log", "stone"],
	2: ["venom", "iron_ore", "raw_hide"],
	3: ["shadow_essence", "arcane_crystal", "leather"],
	4: ["dragon_scale", "ghost_cloth", "refined_metal"],
	5: ["chaos_shard", "spirit_fragment", "magic_alloy"],
}


func _place_enemies() -> void:
	var difficulty : int    = _mission_data.get("difficulty", 1)
	var rank       : String = DIFF_TO_RANK.get(difficulty, "F")
	var mob_pool   : Array  = MobLibrary.get_mobs_by_rank(rank)
	if mob_pool.is_empty():
		mob_pool = MobLibrary.get_mobs_by_rank("F")
	if mob_pool.is_empty():
		push_warning("Wood1Scene: aucun mob de rang %s dans MobLibrary" % rank)
		return

	var count     : int  = 3 + difficulty * 2
	var zones     : Array = [_zone_a, _zone_b, _zone_c]

	for i in count:
		var mob_def  : Dictionary = mob_pool[randi() % mob_pool.size()]
		var zone     : Area2D     = zones[i % zones.size()]
		var zone_pos : Vector2    = _random_pos_in_zone(zone)

		var mob := MobNode.new()
		mob.name = "Mob_%d" % i
		_enemies_container.add_child(mob)
		mob.global_position = zone_pos
		mob.setup(mob_def.get("id", "slime"), _heroes_container)


func _place_loot() -> void:
	var difficulty : int   = _mission_data.get("difficulty", 1)
	var pool       : Array = LOOT_POOLS.get(difficulty, LOOT_POOLS[1])
	var count      : int   = randi_range(1, 3)

	for i in count:
		var item_id : String = pool[randi() % pool.size()]
		var loot_pos : Vector2 = _random_pos_in_zone(_zone_loot)

		var loot := LootPickup.new()
		loot.name = "Loot_%d" % i
		_loot_container.add_child(loot)
		loot.global_position = loot_pos
		loot.setup(item_id, 1)


func _random_pos_in_zone(zone: Area2D) -> Vector2:
	if zone == null:
		return Vector2(200.0, 200.0)
	var half_size := Vector2(64.0, 48.0)
	for child in zone.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			half_size = child.shape.size * 0.5
			break
	return zone.global_position + Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)
