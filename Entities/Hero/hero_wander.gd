## HeroWander.gd
## Composant de test — déplacement aléatoire pour valider
## le pathfinding et les animations.
## À attacher temporairement sur le node Hero.
## Supprimer quand HeroRoutine prend le relais.
extends Node

@onready var hero      : Hero    = get_parent()
@onready var navigator : Node2D  = %HeroNavigator

# Rayon de déplacement en pixels
@export var wander_radius : float = 200.0
# Délai entre deux destinations (secondes IRL)
@export var wait_time     : float = 2.0

var _timer : float = 0.0


func _ready() -> void:
	# Laisse le temps au NavigationServer de se construire
	await get_tree().process_frame
	await get_tree().process_frame
	_pick_new_destination()


func _process(delta: float) -> void:
	if not hero.data:
		return

	# Quand le navigator a fini → attend puis repart
	if navigator.is_finished():
		_timer += delta
		if _timer >= wait_time:
			_timer = 0.0
			_pick_new_destination()


func _pick_new_destination() -> void:
	var origin := hero.global_position
	# Cherche une destination valide dans le rayon
	for _attempt in range(20):
		var angle  := randf() * TAU
		var dist   := randf_range(50.0, wander_radius)
		var target := origin + Vector2(cos(angle), sin(angle)) * dist
		navigator.set_destination(target)
		return  # set_destination vérifie l'atteignabilité en interne
