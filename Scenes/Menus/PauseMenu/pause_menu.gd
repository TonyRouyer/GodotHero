## pause_menu.gd
## Menu pause in-game. S'affiche par-dessus la GuildScene sans la détruire.
## Géré en toggle via l'action "ui_cancel" (Échap).
extends CanvasLayer


func _ready() -> void:
	hide()


# ─────────────────────────────────────────────
#  TOGGLE
# ─────────────────────────────────────────────
func toggle() -> void:
	if visible:
		_close()
	else:
		_open()


func _open() -> void:
	show()
	TimeManager.pause()
	UIState.menu_open = true


func _close() -> void:
	hide()
	TimeManager.unpause()
	UIState.menu_open = false


# ─────────────────────────────────────────────
#  BOUTONS
# ─────────────────────────────────────────────
func _on_resume_pressed() -> void:
	_close()


func _on_save_pressed() -> void:
	if SaveManager.save_game():
		EventBus.ui_notification_requested.emit("Partie sauvegardée !", "success")
	else:
		EventBus.ui_notification_requested.emit("Erreur lors de la sauvegarde.", "error")


func _on_options_pressed() -> void:
	## Sauvegarde la position/zoom caméra avant de quitter la GuildScene
	GameData.save_camera_state()
	UIState.menu_open = false
	SceneManager.go_to("options", {"back_scene": "guild"})


func _on_main_menu_pressed() -> void:
	_show_confirm_dialog()


func _show_confirm_dialog() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Quitter la partie"
	dialog.dialog_text = "Retourner au menu principal ?\nLes changements non sauvegardés seront perdus."
	dialog.confirmed.connect(_go_to_main_menu)
	add_child(dialog)
	dialog.popup_centered()


func _go_to_main_menu() -> void:
	TimeManager.unpause()
	UIState.menu_open = false
	SceneManager.go_to("main_menu")
