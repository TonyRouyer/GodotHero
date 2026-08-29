## guild_scene.gd
## Contrôleur racine de la scène de guilde.
## Rôle : initialiser les sous-systèmes et câbler les références entre eux.
## Ne contient PAS de logique métier — délègue tout aux composants.
extends Node2D


# ─────────────────────────────────────────────
#  RÉFÉRENCES AUX CONTENEURS WORLD
# ─────────────────────────────────────────────
@onready var heroes_container    : Node2D  = $World/Heroes
@onready var objects_container   : Node2D  = $World/Objects
@onready var construction_node   : Node2D  = $Construction
@onready var nav_region          : NavigationRegion2D = $World/NavigationRegion2D


# Tilemaps
@onready var floor_layer         : TileMapLayer = $World/Level/Floor
@onready var wall_layer          : TileMapLayer = $World/Level/Wall
@onready var placeholder_layer   : TileMapLayer = $World/Level/Placeholder
@onready var preview_layer       : TileMapLayer = $World/Level/Preview

# UI
@onready var pause_menu                         = $PauseMenu
@onready var hero_panel                         = $UILayer/HeroPanel
@onready var build_menu                         = $UILayer/BuildMenu

var _context_menu        : ObjectContextMenu = null
var _inspection_overlay  : Control           = null
var _hero_inspect_panel  : Control           = null
var _nav_dirty           : bool              = false

const _INSPECTION_SCRIPT    = preload("res://Scenes/Guild/UI/InspectionOverlay.gd")
const _HERO_INSPECT_SCRIPT  = preload("res://Scenes/Guild/UI/HeroInspectPanel.gd")
const _MISSION_BOARD_SCRIPT = preload("res://Scenes/Guild/UI/MissionBoardPanel.gd")
const _QUEST_PANEL_SCRIPT      = preload("res://Scenes/Guild/UI/QuestPanel.gd")
const _QUEST_PREP_PANEL_SCRIPT = preload("res://Scenes/Guild/UI/QuestPrepPanel.gd")
const _INVENTORY_PANEL_SCRIPT = preload("res://Scenes/Guild/UI/InventoryPanel.gd")
const _RESEARCH_PANEL_SCRIPT  = preload("res://Scenes/Guild/UI/ResearchPanel.gd")
const _RECRUIT_PANEL_SCRIPT   = preload("res://Scenes/Guild/UI/RecruitPanel.gd")
const _MARKET_PANEL_SCRIPT       = preload("res://Scenes/Guild/UI/MarketPanel.gd")
const _ENCHANTMENT_PANEL_SCRIPT  = preload("res://Scenes/Guild/UI/EnchantmentPanel.gd")
const _FARMING_PANEL_SCRIPT      = preload("res://Scenes/Guild/UI/FarmingPanel.gd")
const _SKILLS_PANEL_SCRIPT       = preload("res://Scenes/Guild/UI/HeroSkillsPanel.gd")



# Dans GuildScene.gd ou un autoload dédié
@onready var canvas_modulate: CanvasModulate = $World/CanvasModulate
var _tween: Tween

# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	WorldContext.setup(objects_container, heroes_container)
	_setup_context_menu()
	_setup_inspection_overlay()
	_setup_hero_inspect_panel()
	_setup_mission_board()
	_setup_quest_panel()
	_setup_quest_prep_panel()
	_setup_inventory_panel()
	_setup_research_panel()
	_setup_recruit_panel()
	_setup_market_panel()
	_setup_enchantment_panel()
	_setup_farming_panel()
	_setup_skills_panel()
	_setup_navigation()
	_sync_editor_tiles()
	_connect_event_bus()
	TimeManager.unpause()
	canvas_modulate.color = TimeManager.get_sky_color()

	if Engine.has_singleton("SettingsManager"):
		var default_speed : int = SettingsManager.get_value("default_game_speed")
		var speed_to_index := {1: 1, 2: 2, 4: 3}
		TimeManager.set_speed(speed_to_index.get(default_speed, 1))

	ConstructionManager.rebuild_visuals()

	if HeroManager.get_hero_count() > 0:
		_respawn_saved_heroes()
	else:
		var data : HeroData = HeroGenerator.generate()
		HeroManager.spawn_hero(data)


func _respawn_saved_heroes() -> void:
	## HeroManager.deserialize() a rempli _heroes{} mais les nodes n'existent pas encore
	## (le SceneContainer n'était pas là au moment du load_game()).
	## On re-spawne chaque HeroData depuis la liste en mémoire.
	for hero_data in HeroManager.get_all_data():
		HeroManager.spawn_hero(hero_data)

func init_params(_params: Dictionary) -> void:
	## Appelé par SceneManager si des params sont passés (ex: mission → retour guilde)
	pass


# ─────────────────────────────────────────────
#  CÂBLAGE EVENTBUS
# ─────────────────────────────────────────────
func _setup_inspection_overlay() -> void:
	_inspection_overlay = _INSPECTION_SCRIPT.new()
	$UILayer.add_child(_inspection_overlay)


func _setup_hero_inspect_panel() -> void:
	_hero_inspect_panel = _HERO_INSPECT_SCRIPT.new()
	$UILayer.add_child(_hero_inspect_panel)


func _setup_mission_board() -> void:
	var board = _MISSION_BOARD_SCRIPT.new()
	$UILayer.add_child(board)


func _setup_quest_panel() -> void:
	var panel = _QUEST_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_quest_prep_panel() -> void:
	var panel = _QUEST_PREP_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_inventory_panel() -> void:
	var panel = _INVENTORY_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_research_panel() -> void:
	var panel = _RESEARCH_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_recruit_panel() -> void:
	var panel = _RECRUIT_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_market_panel() -> void:
	var panel = _MARKET_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_enchantment_panel() -> void:
	var panel = _ENCHANTMENT_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_farming_panel() -> void:
	var panel = _FARMING_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_skills_panel() -> void:
	var panel = _SKILLS_PANEL_SCRIPT.new()
	$UILayer.add_child(panel)


func _setup_context_menu() -> void:
	_context_menu = ObjectContextMenu.new()
	$UILayer.add_child(_context_menu)
	_context_menu.move_pressed.connect(_on_context_menu_move)
	_context_menu.sell_pressed.connect(_on_context_menu_sell)
	_context_menu.farm_pressed.connect(_on_context_menu_farm)


func _connect_event_bus() -> void:
	EventBus.hero_selected.connect(_on_hero_selected)
	EventBus.hero_deselected.connect(_on_hero_deselected)
	EventBus.hero_inspect_requested.connect(_on_hero_inspect_requested)
	EventBus.ui_panel_open_requested.connect(_on_panel_open_requested)
	EventBus.ui_panel_close_requested.connect(_on_panel_close_requested)
	EventBus.object_placed.connect(_on_object_placed)
	EventBus.object_removed.connect(_on_object_removed)
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.object_context_menu_requested.connect(_on_object_context_menu_requested)
	EventBus.wall_placed.connect(_on_wall_nav_changed)
	EventBus.wall_removed.connect(_on_wall_removed_nav)
	EventBus.walls_destroyed.connect(_on_walls_destroyed_nav)
	EventBus.floor_placed.connect(_on_floor_nav_changed)


func _exit_tree() -> void:
	WorldContext.clear()
	if EventBus.hero_selected.is_connected(_on_hero_selected):
		EventBus.hero_selected.disconnect(_on_hero_selected)
	if EventBus.hero_deselected.is_connected(_on_hero_deselected):
		EventBus.hero_deselected.disconnect(_on_hero_deselected)
	if EventBus.hero_inspect_requested.is_connected(_on_hero_inspect_requested):
		EventBus.hero_inspect_requested.disconnect(_on_hero_inspect_requested)
	if EventBus.ui_panel_open_requested.is_connected(_on_panel_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_panel_open_requested)
	if EventBus.ui_panel_close_requested.is_connected(_on_panel_close_requested):
		EventBus.ui_panel_close_requested.disconnect(_on_panel_close_requested)
	if EventBus.object_placed.is_connected(_on_object_placed):
		EventBus.object_placed.disconnect(_on_object_placed)
	if EventBus.object_removed.is_connected(_on_object_removed):
		EventBus.object_removed.disconnect(_on_object_removed)
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)
	if EventBus.object_context_menu_requested.is_connected(_on_object_context_menu_requested):
		EventBus.object_context_menu_requested.disconnect(_on_object_context_menu_requested)
	if EventBus.wall_placed.is_connected(_on_wall_nav_changed):
		EventBus.wall_placed.disconnect(_on_wall_nav_changed)
	if EventBus.wall_removed.is_connected(_on_wall_removed_nav):
		EventBus.wall_removed.disconnect(_on_wall_removed_nav)
	if EventBus.walls_destroyed.is_connected(_on_walls_destroyed_nav):
		EventBus.walls_destroyed.disconnect(_on_walls_destroyed_nav)
	if EventBus.floor_placed.is_connected(_on_floor_nav_changed):
		EventBus.floor_placed.disconnect(_on_floor_nav_changed)

# ─────────────────────────────────────────────
#  NAVIGATION — REBUILD DIFFÉRÉ
# ─────────────────────────────────────────────
func _process(_delta: float) -> void:
	if _nav_dirty:
		_nav_dirty = false
		_rebuild_navigation()


func _on_wall_nav_changed(_pos: Vector2i, _id: String) -> void:
	_nav_dirty = true


func _on_wall_removed_nav(_pos: Vector2i) -> void:
	_nav_dirty = true


func _on_walls_destroyed_nav(_d: Array[Vector2i], _n: Array[Vector2i]) -> void:
	_nav_dirty = true


func _on_floor_nav_changed(_pos: Vector2i, _floor_id: String) -> void:
	_nav_dirty = true


## Configure le NavigationPolygon pour qu'il scanne les TileMapLayer de la scène.
## Appelé une fois dans _ready(), avant rebuild_visuals().
## Synchronise GameData avec les tiles pré-posés dans l'éditeur Godot.
## Sans ça, les murs/sols éditeur sont uniquement visuels : GameData ne les connaît pas,
## RoomManager les ignore et le nav mesh ne les prend pas en compte.
func _sync_editor_tiles() -> void:
	## Murs pré-posés → GameData.walls + effacement du sol en dessous
	for pos : Vector2i in wall_layer.get_used_cells():
		if not GameData.walls.has(pos):
			GameData.walls[pos] = _guess_wall_item(pos)
		floor_layer.erase_cell(pos)
		GameData.floors.erase(pos)

	## Sols pré-posés (hors mur) → GameData.floors
	for pos : Vector2i in floor_layer.get_used_cells():
		if not GameData.walls.has(pos) and not GameData.floors.has(pos):
			GameData.floors[pos] = _guess_floor_item(pos)

	## Objets pré-posés dans l'éditeur → ConstructionManager.placed_objects
	for node in objects_container.get_children():
		if not node.is_in_group("guild_objects"):
			continue
		var obj_id : String     = node.object_id
		var origin : Vector2i   = node.get_origin()
		var item   : Dictionary = ItemRegistry.get_item(obj_id)
		var rot    : int        = node.get_rotation_index()
		## Taille réelle tenant compte de la rotation (swap w/h pour rot 1 et 3)
		var size   : Vector2    = ConstructionManager.get_rotated_size(item.get("size", Vector2.ONE), rot)
		if not ConstructionManager.placed_objects.has(origin):
			for x in range(int(size.x)):
				for y in range(int(size.y)):
					ConstructionManager.placed_objects[origin + Vector2i(x, y)] = {
						"object_id":   obj_id,
						"origin":      origin,
						"size":        size,
						"rotation":    rot,
						"instance_node": node,
						"constructed": true,
					}


func _guess_wall_item(pos: Vector2i) -> String:
	var source_id : int = wall_layer.get_cell_source_id(pos)
	for item_id in ItemRegistry.get_all_walls():
		if ItemRegistry.get_item(item_id).get("atlas_id", -1) == source_id:
			return item_id
	return "stone_wall"


func _guess_floor_item(pos: Vector2i) -> String:
	var source_id : int = floor_layer.get_cell_source_id(pos)
	for item_id in ItemRegistry.get_all_floors():
		if ItemRegistry.get_item(item_id).get("atlas_id", -1) == source_id:
			return item_id
	return "wood_floor"


func _setup_navigation() -> void:
	if nav_region.navigation_polygon == null:
		nav_region.navigation_polygon = NavigationPolygon.new()
	var poly := nav_region.navigation_polygon
	poly.agent_radius             = 8.0
	poly.source_geometry_mode     = NavigationPolygon.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	poly.parsed_geometry_type     = NavigationPolygon.PARSED_GEOMETRY_MESH_INSTANCES


## Rebake le nav mesh depuis les tiles de sol du TileMapLayer.
## Les tiles sans navigation polygon (murs, vide) sont automatiquement exclus.
## Exécuté une fois par frame (dirty flag).
func _rebuild_navigation() -> void:
	nav_region.bake_navigation_polygon()
	EventBus.navigation_map_changed.emit()


# ─────────────────────────────────────────────
#  INPUT GLOBAL DE LA SCÈNE
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		## Échap : ferme d'abord le menu contextuel si visible
		if _context_menu != null and _context_menu.visible:
			_context_menu.hide_menu()
			get_viewport().set_input_as_handled()
			return
		## Sinon ferme les panels ouverts, ou ouvre la pause
		if hero_panel.visible or build_menu.visible:
			_close_all_panels()
			GameData.construction_type = ""
			GameData.construction_item = ""
		else:
			pause_menu.toggle()


# ─────────────────────────────────────────────
#  GESTION DES PANELS
# ─────────────────────────────────────────────
func _close_all_panels() -> void:
	hero_panel.hide()
	build_menu.hide()
	if _context_menu != null and _context_menu.visible:
		_context_menu.hide_menu()
	UIState.menu_open = false
	UIState.current_panel = ""


func _on_panel_open_requested(panel_id: String, _payload: Dictionary) -> void:
	_close_all_panels()
	if panel_id == "":
		return
	match panel_id:
		"hero_panel":   hero_panel.show()
		"build_menu":   build_menu.show()
	UIState.menu_open = true
	UIState.current_panel = panel_id


func _on_panel_close_requested(_panel_id: String) -> void:
	_close_all_panels()


# ─────────────────────────────────────────────
#  RÉACTIONS AUX ÉVÉNEMENTS JEUX
# ─────────────────────────────────────────────
func _on_hero_selected(hero_data: Resource) -> void:
	hero_panel.load_hero(hero_data)
	hero_panel.show()
	UIState.menu_open = true


func _on_hero_deselected() -> void:
	hero_panel.hide()
	UIState.menu_open = false


func _on_hero_inspect_requested(_hero_data: HeroData, _screen_pos: Vector2) -> void:
	hero_panel.hide()


func _on_object_placed(_object_type: String, _grid_pos: Vector2i) -> void:
	pass


func _on_object_removed(_grid_pos: Vector2i) -> void:
	pass


# ─────────────────────────────────────────────
#  MENU CONTEXTUEL OBJET
# ─────────────────────────────────────────────
func _on_object_context_menu_requested(object_node: Node2D, screen_pos: Vector2) -> void:
	if _context_menu == null:
		return
	_close_all_panels()
	_context_menu.show_for(object_node, screen_pos)


func _on_context_menu_move(object_node: Node2D) -> void:
	if object_node is GuildObject:
		ConstructionManager.start_move((object_node as GuildObject).get_origin())


func _on_context_menu_sell(object_node: Node2D) -> void:
	if object_node is GuildObject:
		ConstructionManager.sell_object((object_node as GuildObject).get_origin())


func _on_context_menu_farm(object_node: Node2D) -> void:
	if not (object_node is GuildObject):
		return
	var origin : Vector2i = (object_node as GuildObject).get_origin()
	if FarmingManager.is_ready(origin):
		FarmingManager.harvest(origin)
	elif not FarmingManager.is_planted(origin):
		EventBus.ui_panel_open_requested.emit("farming_panel", {"object_node": object_node})


# ─────────────────────────────────────────────
#  Gestion  couleur jour nuit
# ─────────────────────────────────────────────
func _on_hour_changed(_hour: int) -> void:
	var target_color := TimeManager.get_sky_color()
	# Durée = exactement 1 heure in-game en secondes réels
	var duration := (60.0 / GameConfig.MINUTES_PER_TICK) \
					* GameConfig.SECONDS_PER_TICK \
					/ TimeManager.current_speed
	duration = clamp(duration, 2.0, 30.0)

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(canvas_modulate, "color", target_color, duration)


# ─────────────────────────────────────────────
#  ACCESSEURS (pour les sous-systèmes qui ont besoin des refs world)
# ─────────────────────────────────────────────
func get_heroes_container() -> Node2D:
	return heroes_container


func get_objects_container() -> Node2D:
	return objects_container


func get_floor_layer() -> TileMapLayer:
	return floor_layer


func get_wall_layer() -> TileMapLayer:
	return wall_layer
