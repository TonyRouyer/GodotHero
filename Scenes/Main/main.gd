## Main.gd
## Scène racine — ne change jamais, ne se recharge jamais.
## Son seul rôle : héberger le SceneContainer et l'UI globale.
## Le SceneManager gère lui-même le fade et le swap de scène.
extends Node

const NOTIFICATION_SCENE := preload("res://Systems/Notifications/Notification.tscn")
const MAX_NOTIFICATIONS   := 5   # nombre max de cartes visibles simultanément

@onready var scene_container        : Node          = $SceneContainer
@onready var transition_layer                       = $TransitionLayer
@onready var notification_container : VBoxContainer = $GlobalUI/NotificationContainer

func _ready() -> void:
	EventBus.ui_notification_requested.connect(_on_notification_requested)
	EventBus.ui_tooltip_show.connect(_on_tooltip_show)
	EventBus.ui_tooltip_hide.connect(_on_tooltip_hide)
	#SceneManager.go_to("main_menu")

	SceneManager.go_to("guild")


# ─────────────────────────────────────────────
#  NOTIFICATIONS
# ─────────────────────────────────────────────
func _on_notification_requested(message: String, type: String) -> void:
	## Respecte le paramètre notifications des options
	if not SettingsManager.get_value("notifications"):
		return

	## Supprime la plus ancienne si on dépasse le max
	if notification_container.get_child_count() >= MAX_NOTIFICATIONS:
		notification_container.get_child(0).queue_free()

	var notif = NOTIFICATION_SCENE.instantiate()
	notification_container.add_child(notif)
	notif.setup(message, type)


# ─────────────────────────────────────────────
#  TOOLTIP
# ─────────────────────────────────────────────
func _on_tooltip_show(text: String, position: Vector2) -> void:
	var tooltip = $GlobalUI/Tooltip
	var label   = $GlobalUI/Tooltip/TooltipLabel
	label.text = text
	tooltip.global_position = position + Vector2(12, 12)
	tooltip.show()


func _on_tooltip_hide() -> void:
	$GlobalUI/Tooltip.hide()
