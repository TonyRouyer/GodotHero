## EventBus — Autoload #2
## Bus de signaux global. Permet à n'importe quel node d'émettre ou d'écouter
## des événements sans référence directe → zéro couplage fort entre scènes.
##
## Convention d'usage :
##   Émetteur  → EventBus.hero_hired.emit(data)
##   Écouteur  → EventBus.hero_hired.connect(_on_hero_hired)
extends Node


# ─────────────────────────────────────────────
#  SCÈNES / NAVIGATION
# ─────────────────────────────────────────────
signal scene_change_requested(scene_id: String, params: Dictionary)
signal scene_loaded(scene_id: String)

# ─────────────────────────────────────────────
#  CAMÉRA
# ─────────────────────────────────────────────
signal camera_focus_requested(world_position: Vector2)

# ─────────────────────────────────────────────
#  TEMPS
# ─────────────────────────────────────────────
signal time_tick(hour: int, minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal time_speed_changed(speed_index: int)
signal game_paused(is_paused: bool)
signal day_night_changed(is_day: bool)

# ─────────────────────────────────────────────
#  HÉROS
# ─────────────────────────────────────────────
signal hero_hired(hero_data: Resource)
signal hero_fired(hero_id: int)
signal hero_inspect_requested(hero_data: HeroData, screen_pos: Vector2)
signal hero_died(hero_id: int)
signal hero_selected(hero_data: Resource)
signal hero_deselected()
signal hero_stat_changed(hero_id: int, stat_name: String, new_value: float)
signal hero_need_changed(hero_id: int, need_name: String, new_value: float)
signal hero_task_changed(hero_id: int, task_type: String)
signal hero_level_up(hero_id: int, stat_name: String, new_level: int)
signal hero_moral_effects_changed(hero_id: int, effects: Array)

# ─────────────────────────────────────────────
#  CONSTRUCTION / OBJETS
# ─────────────────────────────────────────────
signal object_placed(object_type: String, grid_position: Vector2i)
signal object_removed(grid_position: Vector2i)
signal object_context_menu_requested(object_node: Node2D, screen_position: Vector2)
signal object_used(object_type: String, hero_id: int)
signal object_freed(object_type: String, hero_id: int)
signal wall_placed(grid_position: Vector2i, item_id: String)
signal wall_removed(grid_position: Vector2i)
signal floor_placed(grid_position: Vector2i, floor_type: String)
signal construction_mode_changed(construction_type: String, item_id: String)
signal construction_task_requested(hero_id: int)
signal construction_task_assigned(hero_id: int, task: Dictionary)
signal construction_task_added(task: Dictionary)
signal construction_task_completed(task: Dictionary)
signal construction_task_failed(task: Dictionary, hero_id: int)
signal reset_preview()
signal walls_destroyed(positions: Array[Vector2i], neighbors: Array[Vector2i])
signal rooms_updated(rooms: Array)
signal navigation_map_changed()


# ─────────────────────────────────────────────
#  ÉCONOMIE / RESSOURCES
# ─────────────────────────────────────────────
signal gold_changed(new_value: int, delta: int)
signal food_changed(new_value: int, delta: int)
signal reputation_changed(new_value: int, delta: int)
signal resource_changed(resource_name: String, new_value: float)
signal inventory_changed(item_name: String, new_quantity: int)

# ─────────────────────────────────────────────
#  MISSIONS
# ─────────────────────────────────────────────
signal mission_available(mission_data: Resource)
signal mission_started(mission_data: Resource)
signal mission_completed(mission_data: Resource, success: bool)
signal bounty_accepted(bounty_data: Resource)

# ─────────────────────────────────────────────
#  RECHERCHE / CRAFT
# ─────────────────────────────────────────────
signal research_completed(research_id: String)
signal recipe_unlocked(recipe_id: String)
signal item_crafted(item_name: String, quantity: int)

## station_key = "%d,%d" % [origin.x, origin.y]
signal craft_queue_changed(station_key: String, queue: Array)
signal craft_progress_updated(station_key: String, material_id: String, progress: float)
signal craft_material_missing(station_key: String, material_id: String)

# ─────────────────────────────────────────────
#  UI
# ─────────────────────────────────────────────
## Pour ouvrir/fermer des panels sans référence directe
signal ui_panel_open_requested(panel_id: String, payload: Dictionary)
signal ui_panel_close_requested(panel_id: String)
signal ui_notification_requested(message: String, type: String)
signal ui_tooltip_show(text: String, position: Vector2)
signal ui_tooltip_hide()
