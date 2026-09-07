## TransitionLayer.gd
## Overlay de fondu noir entre les changements de scène.
## Utilisé par Main.gd, contrôlé par SceneManager via signaux.
extends CanvasLayer


@onready var fade_rect: ColorRect = $FadeRect

const FADE_DURATION := 0.3


func fade_in() -> void:
	## Fondu vers le noir (début de transition)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, FADE_DURATION)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # bloque les clics
	await tween.finished


func fade_out() -> void:
	## Fondu depuis le noir (fin de transition)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, FADE_DURATION)
	await tween.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
