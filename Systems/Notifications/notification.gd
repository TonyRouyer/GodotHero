## notification.gd
## Carte de notification individuelle.
## Apparaît en slide-in depuis la droite, disparaît automatiquement après DURATION secondes.
## Instanciée par main.gd via EventBus.ui_notification_requested.
##
## Types supportés : "success" | "error" | "info" | "warning"
## Utilisation :
##   EventBus.ui_notification_requested.emit("Partie sauvegardée !", "success")   # vert  ✓
##   EventBus.ui_notification_requested.emit("Or insuffisant (50 requis)", "error")  # rouge ✕
##   EventBus.ui_notification_requested.emit("Héros non payé !", "warning")       # orange ⚠
##   EventBus.ui_notification_requested.emit("Nouvelle mission disponible", "info") # bleu  ℹ
extends PanelContainer


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const DURATION       := 3.5   # secondes avant disparition automatique
const SLIDE_DURATION := 0.18  # durée de l'animation d'entrée/sortie

## Couleurs de fond selon le type (légèrement transparentes pour le style pixel)
const TYPE_COLORS := {
	"success": Color(0.15, 0.55, 0.25, 0.92),
	"error":   Color(0.65, 0.15, 0.15, 0.92),
	"warning": Color(0.70, 0.50, 0.10, 0.92),
	"info":    Color(0.15, 0.35, 0.65, 0.92),
}

const TYPE_ICONS := {
	"success": "✓",
	"error":   "✕",
	"warning": "⚠",
	"info":    "ℹ",
}


# ─────────────────────────────────────────────
#  NŒUDS
# ─────────────────────────────────────────────
@onready var icon_label    : Label = $MarginContainer/HBox/Icon
@onready var message_label : Label = $MarginContainer/HBox/Message
@onready var timer         : Timer = $Timer


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func setup(message: String, type: String) -> void:
	var color = TYPE_COLORS.get(type, TYPE_COLORS["info"])
	var icon  = TYPE_ICONS.get(type, "ℹ")

	## Couleur de fond via StyleBoxFlat
	var style = StyleBoxFlat.new()
	style.bg_color          = color
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left   = 12
	style.content_margin_right  = 12
	style.content_margin_top    = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)

	icon_label.text    = icon
	message_label.text = message

	## Démarre hors écran à droite, glisse vers la gauche
	modulate.a = 0.0
	_animate_in()

	timer.wait_time = DURATION
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


# ─────────────────────────────────────────────
#  ANIMATIONS
# ─────────────────────────────────────────────
func _animate_in() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "modulate:a", 1.0, SLIDE_DURATION)


func _animate_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "modulate:a", 0.0, SLIDE_DURATION)
	await tween.finished
	queue_free()


# ─────────────────────────────────────────────
#  INTERACTIONS
# ─────────────────────────────────────────────
func _on_timer_timeout() -> void:
	_animate_out()


## Clic sur la notification = fermeture immédiate
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		timer.stop()
		_animate_out()
