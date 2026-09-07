## options.gd
## Écran Options complet — Audio | Affichage | Gameplay.
## Fonctionne depuis le menu principal ET depuis la pause en jeu.
extends Control


var _back_scene_id : String = "main_menu"


# ─────────────────────────────────────────────
#  AUDIO
# ─────────────────────────────────────────────
@onready var master_slider : HSlider = %MasterSlider
@onready var master_value  : Label   = %MasterValue
@onready var music_slider  : HSlider = %MusicSlider
@onready var music_value   : Label   = %MusicValue
@onready var sfx_slider    : HSlider = %SFXSlider
@onready var sfx_value     : Label   = %SFXValue

# ─────────────────────────────────────────────
#  AFFICHAGE
# ─────────────────────────────────────────────
@onready var window_mode_btn : OptionButton = %WindowModeBtn
@onready var resolution_btn  : OptionButton = %ResolutionBtn
@onready var vsync_check     : CheckButton  = %VsyncCheck

# ─────────────────────────────────────────────
#  GAMEPLAY
# ─────────────────────────────────────────────
@onready var camera_speed_slider : HSlider      = %CameraSpeedSlider
@onready var camera_speed_value  : Label        = %CameraSpeedValue
@onready var game_speed_btn      : OptionButton = %GameSpeedBtn
@onready var notifications_check : CheckButton  = %NotificationsCheck
@onready var language_btn        : OptionButton = %LanguageBtn


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_populate_option_buttons()
	_load_current_settings()


func init_params(params: Dictionary) -> void:
	_back_scene_id = params.get("back_scene", "main_menu")


func _populate_option_buttons() -> void:
	window_mode_btn.clear()
	window_mode_btn.add_item("Fenetre",     0)
	window_mode_btn.add_item("Sans bords",  1)
	window_mode_btn.add_item("Plein ecran", 2)

	resolution_btn.clear()
	for res in SettingsManager.RESOLUTIONS:
		resolution_btn.add_item(res)

	game_speed_btn.clear()
	game_speed_btn.add_item("x1 - Normal",      0)
	game_speed_btn.add_item("x2 - Rapide",      1)
	game_speed_btn.add_item("x4 - Tres rapide", 2)

	language_btn.clear()
	for lang in SettingsManager.LANGUAGES:
		language_btn.add_item(lang["label"])


func _load_current_settings() -> void:
	master_slider.value = SettingsManager.get_value("volume_master")
	music_slider.value  = SettingsManager.get_value("volume_music")
	sfx_slider.value    = SettingsManager.get_value("volume_sfx")
	_update_label(master_value, master_slider.value)
	_update_label(music_value,  music_slider.value)
	_update_label(sfx_value,    sfx_slider.value)

	var mode_idx = SettingsManager.WINDOW_MODES.find(SettingsManager.get_value("window_mode"))
	window_mode_btn.selected = max(mode_idx, 0)

	var res_idx = SettingsManager.RESOLUTIONS.find(SettingsManager.get_value("resolution"))
	resolution_btn.selected  = max(res_idx, 0)
	resolution_btn.disabled  = (SettingsManager.get_value("window_mode") != "windowed")

	vsync_check.button_pressed = SettingsManager.get_value("vsync")

	camera_speed_slider.value = SettingsManager.get_value("camera_speed")
	_update_camera_label(SettingsManager.get_value("camera_speed"))

	var speed_map := {1: 0, 2: 1, 4: 2}
	game_speed_btn.selected = speed_map.get(SettingsManager.get_value("default_game_speed"), 0)

	notifications_check.button_pressed = SettingsManager.get_value("notifications")

	var current_code : String = SettingsManager.get_value("language")
	var lang_idx : int = 0
	for i in SettingsManager.LANGUAGES.size():
		if SettingsManager.LANGUAGES[i]["code"] == current_code:
			lang_idx = i
			break
	language_btn.selected = lang_idx


# ─────────────────────────────────────────────
#  SIGNAUX AUDIO
# ─────────────────────────────────────────────
func _on_master_slider_value_changed(value: float) -> void:
	_update_label(master_value, value)

func _on_music_slider_value_changed(value: float) -> void:
	_update_label(music_value, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	_update_label(sfx_value, value)


# ─────────────────────────────────────────────
#  SIGNAUX AFFICHAGE
# ─────────────────────────────────────────────
func _on_window_mode_btn_item_selected(index: int) -> void:
	resolution_btn.disabled = (SettingsManager.WINDOW_MODES[index] != "windowed")


# ─────────────────────────────────────────────
#  SIGNAUX GAMEPLAY
# ─────────────────────────────────────────────
func _on_camera_speed_slider_value_changed(value: float) -> void:
	_update_camera_label(value)


# ─────────────────────────────────────────────
#  BOUTONS
# ─────────────────────────────────────────────
func _on_apply_pressed() -> void:
	SettingsManager.set_value("volume_master", master_slider.value)
	SettingsManager.set_value("volume_music",  music_slider.value)
	SettingsManager.set_value("volume_sfx",    sfx_slider.value)

	SettingsManager.set_value("window_mode", SettingsManager.WINDOW_MODES[window_mode_btn.selected])
	SettingsManager.set_value("resolution",  SettingsManager.RESOLUTIONS[resolution_btn.selected])
	SettingsManager.set_value("vsync",       vsync_check.button_pressed)

	SettingsManager.set_value("camera_speed", camera_speed_slider.value)
	var speed_values := [1, 2, 4]
	SettingsManager.set_value("default_game_speed", speed_values[game_speed_btn.selected])
	SettingsManager.set_value("notifications", notifications_check.button_pressed)
	var selected_lang : Dictionary = SettingsManager.LANGUAGES[language_btn.selected]
	SettingsManager.set_value("language", selected_lang["code"])

	SettingsManager.apply_all()
	SettingsManager.save_prefs()

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var vp := get_viewport()
	if vp:
		vp.grab_focus()

	EventBus.ui_notification_requested.emit("Options sauvegardees.", "success")


func _on_reset_pressed() -> void:
	for key in SettingsManager.DEFAULTS:
		SettingsManager.set_value(key, SettingsManager.DEFAULTS[key])
	_load_current_settings()
	EventBus.ui_notification_requested.emit("Options reinitialisees.", "info")


func _on_back_pressed() -> void:
	UIState.menu_open = false
	SceneManager.go_to(_back_scene_id)


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _update_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(value * 100)

func _update_camera_label(value: float) -> void:
	camera_speed_value.text = "%d" % int(value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
