## SettingsManager — Autoload
## Centralise toutes les préférences utilisateur (audio, affichage, gameplay).
## Persiste dans user://preferences.json, indépendamment de la save de jeu.
extends Node

const PREFS_PATH := "user://preferences.json"

signal display_changed 
signal audio_changed   
signal language_changed 

const LANGUAGES : Array[Dictionary] = [
	{"code": "fr", "label": "Francais"},
	{"code": "en", "label": "English"},
]

# ─────────────────────────────────────────────
#  VALEURS PAR DÉFAUT
# ─────────────────────────────────────────────
const DEFAULTS : Dictionary = {
	"volume_master":      0.8,
	"volume_music":       0.6,
	"volume_sfx":         1.0,
	"window_mode":        "windowed",
	"resolution":         "1920x1080",
	"vsync":              true,
	"camera_speed":       400.0,
	"default_game_speed": 1,
	"notifications":      true,
	"language":           "fr",
}

const RESOLUTIONS :Array = [
	"1280x720",
	"1600x900",
	"1920x1080",
	"2560x1440",
	"3840x2160",
]

const WINDOW_MODES :Array= ["windowed", "borderless", "fullscreen"]

# ─────────────────────────────────────────────
#  ÉTAT COURANT
# ─────────────────────────────────────────────
var _prefs : Dictionary = {}


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_prefs = DEFAULTS.duplicate(true)
	load_prefs()
	apply_all()


# ─────────────────────────────────────────────
#  GETTERS / SETTERS
# ─────────────────────────────────────────────
func get_value(key: String) -> Variant:
	return _prefs.get(key, DEFAULTS.get(key))


func set_value(key: String, value: Variant) -> void:
	_prefs[key] = value


# ─────────────────────────────────────────────
#  APPLICATION
# ─────────────────────────────────────────────
func apply_all() -> void:
	apply_audio()
	apply_display()
	apply_language()


func apply_audio() -> void:
	AudioManager.volume_master = get_value("volume_master")
	AudioManager.volume_music  = get_value("volume_music")
	AudioManager.volume_sfx    = get_value("volume_sfx")
	audio_changed.emit()


func apply_language() -> void:
	var code : String = get_value("language")
	TranslationServer.set_locale(code)
	language_changed.emit()


func apply_display() -> void:
	apply_vsync()
	apply_window_mode()
	apply_resolution()
	display_changed.emit()


func apply_vsync() -> void:
	var enabled : bool = get_value("vsync")
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	)


func apply_window_mode() -> void:
	var new_mode :String = get_value("window_mode")
	var _current_mode := DisplayServer.window_get_mode()

	match new_mode:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_: # "windowed"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	display_changed.emit()


func apply_resolution() -> void:
	## N'applique qu'en mode fenêtré
	if get_value("window_mode") != "windowed":
		return
	var res_str : String = get_value("resolution")
	var parts   = res_str.split("x")
	if parts.size() == 2:
		var w = int(parts[0])
		var h = int(parts[1])
		DisplayServer.window_set_size(Vector2i(w, h))
		## Centre la fenêtre
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_position(Vector2i(
			(screen_size.x - w) / 2,
			(screen_size.y - h) / 2
		))


# ─────────────────────────────────────────────
#  PERSISTANCE
# ─────────────────────────────────────────────
func save_prefs() -> void:
	var file : FileAccess = FileAccess.open(PREFS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_prefs, "\t"))
		file.close()


func load_prefs() -> void:
	if not FileAccess.file_exists(PREFS_PATH):
		return
	var file : FileAccess = FileAccess.open(PREFS_PATH, FileAccess.READ)
	if not file:
		return
	var json : JSON = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data = json.get_data()
		if data is Dictionary:
			for key in DEFAULTS:
				if data.has(key):
					_prefs[key] = data[key]
	file.close()
