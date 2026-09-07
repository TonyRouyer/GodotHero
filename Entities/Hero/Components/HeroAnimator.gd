## HeroAnimator.gd
## Lit la direction depuis HeroNavigator et demande à HeroVisuals
## de jouer l'animation correspondante.
extends Node

@onready var hero    : Hero    = get_parent()
@onready var navigator : Node2D = %HeroNavigator
@onready var visuals   : Node2D = %HeroVisuals

var _last_anim : String = ""


func _process(_delta: float) -> void:
	if not hero.data:
		return
	_update_animation()


func _update_animation() -> void:
	var dir = navigator.get_move_direction()
	var anim : String

	if dir.length() < 0.1:
		# À l'arrêt — idle dans la dernière direction connue
		anim = _idle_from(_last_anim)
	elif abs(dir.x) > abs(dir.y):
		anim = "walk_right" if dir.x > 0 else "walk_left"
	else:
		anim = "walk_down" if dir.y > 0 else "walk_up"

	if anim != _last_anim:
		_last_anim = anim
		visuals.play(anim)


func _idle_from(last: String) -> String:
	match last:
		"walk_right", "idle_right": return "idle_right"
		"walk_left",  "idle_left":  return "idle_left"
		"walk_up",    "idle_up":    return "idle_up"
		_:                          return "idle_down"
