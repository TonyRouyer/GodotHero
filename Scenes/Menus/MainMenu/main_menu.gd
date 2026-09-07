## main_menu.gd
## Logique du menu principal.
extends Control


@onready var continue_btn : Button = %ContinueBtn
@onready var save_info    : Label  = %SaveInfo


func _ready() -> void:
	_refresh_save_state()


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _refresh_save_state() -> void:
	if SaveManager.save_exists():
		continue_btn.disabled = false
		var meta = SaveManager.get_save_metadata()
		if not meta.is_empty():
			var ts   = meta.get("timestamp", 0)
			var day  = meta.get("day", 1)
			var gold = meta.get("gold", 0)
			var date = Time.get_datetime_string_from_unix_time(ts).left(10)
			save_info.text = "Dernière sauvegarde : Jour %d — %d or — %s" % [day, gold, date]
	else:
		continue_btn.disabled = true
		save_info.text = "Aucune sauvegarde trouvée"


# ─────────────────────────────────────────────
#  BOUTONS
# ─────────────────────────────────────────────
func _on_new_game_pressed() -> void:
	# Si une sauvegarde existe, demander confirmation
	if SaveManager.save_exists():
		_show_new_game_confirm()
	else:
		_start_new_game()


func _on_continue_pressed() -> void:
	## On charge les données AVANT de changer de scène.
	## HeroManager.deserialize() appelle spawn_hero() qui a besoin
	## du conteneur World/Heroes → on ne spawne donc PAS les héros ici,
	## on les re-spawne depuis guild_scene._ready() via HeroManager.
	## La séquence correcte : charger les données → aller en GuildScene →
	## guild_scene._ready() appelle rebuild_visuals() + respawne les héros.
	if not SaveManager.load_game():
		EventBus.ui_notification_requested.emit("Erreur lors du chargement.", "error")
		return
	SceneManager.go_to("guild")


func _on_options_pressed() -> void:
	SceneManager.go_to("options")


func _on_quit_pressed() -> void:
	get_tree().quit()


# ─────────────────────────────────────────────
#  CONFIRMATION NOUVELLE PARTIE
# ─────────────────────────────────────────────
func _show_new_game_confirm() -> void:
	## Affiche une popup de confirmation inline (pas de scène séparée)
	var dialog = ConfirmationDialog.new()
	dialog.title = "Nouvelle partie"
	dialog.dialog_text = "Démarrer une nouvelle partie effacera la sauvegarde actuelle.\nConfirmer ?"
	dialog.confirmed.connect(_start_new_game)
	add_child(dialog)
	dialog.popup_centered()


func _start_new_game() -> void:
	SaveManager.delete_save()
	## Réinitialise TOUS les systèmes dans l'ordre de dépendance
	GameData.deserialize({})
	TimeManager.deserialize({})
	ConstructionManager.deserialize({})
	HeroManager.clear()
	SceneManager.go_to("guild")


# ─────────────────────────────────────────────
#  INPUT CLAVIER
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
