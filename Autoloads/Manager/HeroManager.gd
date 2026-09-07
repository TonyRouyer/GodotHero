## HeroManager.gd — Autoload #8
## Registre central de tous les héros en vie.
## Responsabilités :
##   - Instancier les héros (spawn_hero)
##   - Les supprimer (fire_hero)
##   - Tenir la liste à jour
##   - Sérialiser/désérialiser pour la sauvegarde
extends Node

const HERO_SCENE := preload("res://Entities/Hero/Hero.tscn")

var _heroes   : Dictionary = {}  
var _nodes    : Dictionary = {}  
var _next_id  : int        = 0


# ─────────────────────────────────────────────
#  SPAWN
# ─────────────────────────────────────────────
func spawn_hero(data: HeroData, spawn_position: Vector2 = Vector2(400, 900)) -> Hero:
	if data.hero_id == -1:
		data.hero_id = _next_id
		_next_id    += 1

	var hero_node : Hero = HERO_SCENE.instantiate()
	hero_node.data = data
	hero_node.name = "Hero_%d" % data.hero_id

	var container = _get_heroes_container()
	if container:
		container.add_child(hero_node)
		hero_node.global_position = spawn_position
		hero_node.initialize()   
	else:
		push_error("HeroManager: conteneur Heroes introuvable.")
		hero_node.queue_free()
		return null

	_heroes[data.hero_id] = data
	_nodes[data.hero_id]  = hero_node

	EventBus.hero_hired.emit(data)
	return hero_node


func fire_hero(hero_id: int) -> void:
	if not _heroes.has(hero_id):
		return

	var node = _nodes.get(hero_id)
	if node:
		node.queue_free()

	_heroes.erase(hero_id)
	_nodes.erase(hero_id)
	EventBus.hero_fired.emit(hero_id)


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────
func get_all_data() -> Array[HeroData]:
	var result : Array[HeroData] = []
	for d in _heroes.values():
		result.append(d)
	return result


#Non utiliser
func get_hero_data(hero_id: int) -> HeroData:
	return _heroes.get(hero_id, null)


func get_hero_node(hero_id: int) -> Hero:
	var node = _nodes.get(hero_id, null)
	if not is_instance_valid(node):
		return null
	return node as Hero


func get_hero_count() -> int:
	return _heroes.size()


# ─────────────────────────────────────────────
#  NETTOYAGE (changement de scène)
# ─────────────────────────────────────────────
func clear() -> void:
	## Appelé par SceneManager avant de changer de scène
	for node in _nodes.values():
		if is_instance_valid(node):
			node.queue_free()
	_heroes.clear()
	_nodes.clear()


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var heroes_data :Array = []
	for data in _heroes.values():
		heroes_data.append(data.serialize())
	return {
		"heroes":  heroes_data,
		"next_id": _next_id,
	}


func deserialize(save_data: Dictionary) -> void:
	## Charge uniquement les HeroData en mémoire — les nodes seront
	## spawnés par guild_scene._respawn_saved_heroes() une fois la scène prête.
	clear()
	_next_id = save_data.get("next_id", 0)
	for hero_dict in save_data.get("heroes", []):
		var data = HeroData.new()
		data.deserialize(hero_dict)
		## Enregistre sans spawner (pas de SceneContainer disponible ici)
		if data.hero_id == -1:
			data.hero_id = _next_id
			_next_id += 1
		_heroes[data.hero_id] = data


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _get_heroes_container() -> Node2D:
	## Le chemin réel est Main/SceneContainer/GuildScene/World/Heroes
	var main :Node  = get_tree().get_root().get_node_or_null("Main")
	if not main:
		push_error("HeroManager: nœud 'Main' introuvable.")
		return null
	var container: Node = main.get_node_or_null("SceneContainer")
	if not container:
		push_error("HeroManager: nœud 'SceneContainer' introuvable.")
		return null
	## La GuildScene est le premier enfant du SceneContainer
	for child in container.get_children():
		var heroes: Node2D = child.get_node_or_null("World/Heroes")
		if heroes:
			return heroes
	push_error("HeroManager: nœud 'World/Heroes' introuvable dans la scène courante.")
	return null
