## mission_scene.gd
## Orchestrateur de combat jouable.
## Lit la mission en attente dans MissionManager, charge l'environnement Wood1,
## spawne les héros + les mobs, et gère la victoire/défaite.
extends Node2D

const WOOD1_SCENE : String = "res://Scenes/Mission/Environments/Wood1/Wood1Scene.tscn"
const GUILD_SCENE : String = "res://Scenes/Guild/GuildScene.tscn"

var _mission_data    : Dictionary = {}
var _hero_ids        : Array      = []
var _player_hero_id  : int        = -1
var _env_scene       : Node2D     = null
var _hud             : CombatHUD  = null
var _mob_count       : int        = 0
var _heroes_alive    : int        = 0
var _combat_over     : bool       = false
var _camera          : Camera2D   = null


func _ready() -> void:
	if not MissionManager.has_pending_playable():
		push_error("MissionScene: aucune mission jouable en attente, retour à la guilde")
		get_tree().change_scene_to_file(GUILD_SCENE)
		return

	var pending    := MissionManager.consume_pending_playable()
	_mission_data   = pending.get("mission_data", {})
	_hero_ids       = pending.get("hero_ids", [])
	_player_hero_id = pending.get("player_hero_id", -1)

	## HUD
	_hud = CombatHUD.new()
	_hud.name = "CombatHUD"
	add_child(_hud)
	_hud.return_pressed.connect(_on_return_pressed)

	## Environnement
	var env_packed : PackedScene = load(WOOD1_SCENE)
	if env_packed == null:
		push_error("MissionScene: environnement Wood1 introuvable : " + WOOD1_SCENE)
		return
	_env_scene = env_packed.instantiate() as Node2D
	_env_scene.name = "Environment"
	add_child(_env_scene)

	## Attendre que _ready() de l'env soit terminé
	await get_tree().process_frame

	## Configurer la mission dans l'env (place les mobs et le loot)
	_env_scene.setup_for_mission(_mission_data)

	var spawn_pos          : Vector2 = _env_scene.get_team_spawn_position()
	var heroes_container   : Node2D  = _env_scene.get_heroes_container()
	var enemies_container  : Node2D  = _env_scene.get_enemies_container()

	## Spawner les héros
	_heroes_alive = 0
	var offset_x       : float             = 0.0
	var player_node    : HeroCombatNode    = null
	for hero_id in _hero_ids:
		var hero_data : HeroData = HeroManager.get_hero_data(hero_id)
		if hero_data == null:
			continue
		var is_player : bool = (hero_id == _player_hero_id)
		var hero_node := HeroCombatNode.new()
		hero_node.name = "Hero_%d" % hero_id
		heroes_container.add_child(hero_node)
		hero_node.global_position = spawn_pos + Vector2(offset_x, 0.0)
		hero_node.setup(hero_data, enemies_container, is_player)
		hero_node.hp_changed.connect(
			func(node: Node2D, hp: float, hp_max: float) -> void:
				_hud.update_hero_hp(node, hp, hp_max)
		)
		hero_node.mana_changed.connect(
			func(node: Node2D, mana: float, mana_max: float) -> void:
				_hud.update_hero_mana(node, mana, mana_max)
		)
		hero_node.hero_died.connect(_on_hero_died)
		hero_node.skill_used.connect(
			func(node: Node2D, sid: String, cd: float) -> void:
				_hud.update_skill_cooldown(node, sid, cd)
		)
		_hud.add_hero_bar(hero_node, hero_data)
		_heroes_alive += 1
		offset_x      += 22.0
		if is_player:
			player_node = hero_node

	## Caméra — suit le joueur ou se centre sur le spawn pour l'IA
	_camera = Camera2D.new()
	_camera.zoom = Vector2(2.0, 2.0)
	## Limites : empêche la caméra de sortir de la carte Wood1 (40×30 tiles × 16 px)
	_camera.limit_left   = 0
	_camera.limit_top    = 0
	_camera.limit_right  = 640
	_camera.limit_bottom = 480
	if player_node != null:
		player_node.add_child(_camera)
	else:
		add_child(_camera)
		_camera.global_position = spawn_pos

	## Connecter les signaux des mobs (placés par setup_for_mission)
	_mob_count = 0
	for mob in enemies_container.get_children():
		if mob.has_signal("mob_died"):
			mob.mob_died.connect(_on_mob_died)
			_mob_count += 1

	_hud.update_enemy_count(_mob_count)
	_hud.log("=== Mission : %s ===" % _mission_data.get("name", "Inconnue"))
	_hud.log("Difficulté : %d — %d ennemis" % [_mission_data.get("difficulty", 1), _mob_count])


# ─────────────────────────────────────────────
#  ÉVÉNEMENTS COMBAT
# ─────────────────────────────────────────────
func _on_mob_died(mob_node: MobNode) -> void:
	if _combat_over:
		return
	_mob_count -= 1
	_hud.update_enemy_count(_mob_count)
	_hud.log("%s éliminé !" % mob_node.mob_data.get("label", "Ennemi"))
	## Passive on_kill_heal — notifie tous les héros vivants
	var heroes_container : Node2D = _env_scene.get_heroes_container()
	for hero in heroes_container.get_children():
		if hero.has_method("on_enemy_killed") and not hero.is_dead():
			hero.on_enemy_killed()
	if _mob_count <= 0:
		_trigger_victory()


func _on_hero_died(_hero_node: HeroCombatNode) -> void:
	if _combat_over:
		return
	_heroes_alive -= 1
	_hud.log("Un héros est tombé au combat...")
	if _heroes_alive <= 0:
		_trigger_defeat()


func _trigger_victory() -> void:
	_combat_over = true
	var gold : int = _mission_data.get("gold", 0)
	var rep  : int = _mission_data.get("reputation", 0)
	var xp   : int = _mission_data.get("xp", 0)
	MissionManager.resolve_playable_mission(_hero_ids, true, gold, rep, xp)
	_hud.show_end_screen(true, gold, rep)
	_hud.log("=== VICTOIRE ! Mission accomplie. ===")


func _trigger_defeat() -> void:
	_combat_over = true
	MissionManager.resolve_playable_mission(_hero_ids, false, 0, 0, 0)
	_hud.show_end_screen(false, 0, 0)
	_hud.log("=== DÉFAITE. L'équipe est vaincue. ===")


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(GUILD_SCENE)
