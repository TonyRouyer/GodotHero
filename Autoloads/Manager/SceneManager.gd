## SceneManager — Autoload #6
## Gère toutes les transitions de scènes depuis un point central.
extends Node

# ─────────────────────────────────────────────
#  SIGNAUX LOCAUX 
# ─────────────────────────────────────────────
signal transition_started()
signal transition_finished()

# ─────────────────────────────────────────────
#  CONSTANTES — ID des scènes
# ─────────────────────────────────────────────
const SCENES := {
	"main_menu":  "res://Scenes/Menus/MainMenu/MainMenu.tscn",
	"options":    "res://Scenes/Menus/Options/Options.tscn",
	"guild":      "res://Scenes/Guild/GuildScene.tscn",
	"mission":    "res://Scenes/Mission/MissionScene.tscn",
}

# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _current_scene_id: String = ""
var _is_loading: bool = false


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────
func go_to(scene_id: String, params: Dictionary = {}) -> void:
	if _is_loading:
		push_warning("SceneManager: changement de scène déjà en cours, ignoré.")
		return

	if not SCENES.has(scene_id):
		push_error("SceneManager: scène inconnue '%s'" % scene_id)
		return

	_is_loading = true
	EventBus.scene_change_requested.emit(scene_id, params)
	
	_load_scene(SCENES[scene_id], scene_id, params)


func go_to_guild() -> void:
	go_to("guild")


func go_to_main_menu() -> void:
	go_to("main_menu")


func go_to_mission(mission_data: Resource) -> void:
	go_to("mission", {"mission_data": mission_data})


func reload_current() -> void:
	if _current_scene_id != "":
		go_to(_current_scene_id)


# ─────────────────────────────────────────────
#  CHARGEMENT INTERNE
# ─────────────────────────────────────────────
func _load_scene(path: String, scene_id: String, params: Dictionary) -> void:
	## ── 1. Fade in (écran noir) ──────────────────────────────────────────
	var main_node : Node = get_tree().get_root().get_node_or_null("Main")
	if main_node == null:
		push_error("SceneManager: nœud 'Main' introuvable à la racine.")
		_is_loading = false
		return

	var transition_layer : CanvasLayer = main_node.get_node_or_null("TransitionLayer")
	if transition_layer and transition_layer.has_method("fade_in"):
		await transition_layer.fade_in()

	## ── 2. Chargement de la ressource (en parallèle du fade si possible) ─
	ResourceLoader.load_threaded_request(path)
	await _wait_for_load(path)

	var packed: PackedScene = ResourceLoader.load_threaded_get(path)
	if packed == null:
		push_error("SceneManager: impossible de charger '%s'" % path)
		_is_loading = false
		return

	## ── 3. Vidage du SceneContainer ──────────────────────────────────────
	var container = main_node.get_node_or_null("SceneContainer")
	if container == null:
		push_error("SceneManager: nœud 'SceneContainer' introuvable dans Main.")
		_is_loading = false
		return

	for child in container.get_children():
		child.queue_free()
	## Attendre que queue_free soit effectif avant d'ajouter la nouvelle scène
	await get_tree().process_frame

	## ── 4. Instanciation et ajout de la nouvelle scène ───────────────────
	var instance : Node = packed.instantiate()
	container.add_child(instance)

	_current_scene_id = scene_id
	_is_loading = false

	## ── 5. Injection des paramètres ──────────────────────────────────────
	await get_tree().process_frame
	if instance and instance.has_method("init_params"):
		instance.init_params(params)

	EventBus.scene_loaded.emit(scene_id)

	## ── 6. Fade out ───────────────────────────────────────────────────────
	if transition_layer and transition_layer.has_method("fade_out"):
		await transition_layer.fade_out()

	transition_finished.emit()


func _wait_for_load(path: String) -> void:
	while true:
		var status = ResourceLoader.load_threaded_get_status(path)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				return
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("SceneManager: échec du chargement de '%s'" % path)
				return
			_:
				await get_tree().process_frame


# ─────────────────────────────────────────────
#  GETTERS
# ─────────────────────────────────────────────
func get_current_scene_id() -> String:
	return _current_scene_id


func is_loading() -> bool:
	return _is_loading
