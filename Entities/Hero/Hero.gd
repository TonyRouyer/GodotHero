## Hero.gd
## Nœud racine du héros. Rôle minimal :
##   - Détient la référence à HeroData 
##   - Expose les composants pour qu'ils se trouvent mutuellement
##   - Gère le clic souris → sélection
##   - Applique move_and_slide() (physique)
## Toute la logique est dans les composants.
extends CharacterBody2D
class_name Hero


# ─────────────────────────────────────────────
#  DONNÉES
# ─────────────────────────────────────────────
 # assigné par HeroManager.spawn_hero()
var data: HeroData = null  


# ─────────────────────────────────────────────
#  COMPOSANTS
# ─────────────────────────────────────────────
@onready var navigator  : Node2D = %HeroNavigator
@onready var needs      : Node   = %HeroNeeds
@onready var routine    : Node   = %HeroRoutine
@onready var activity   : Node   = %HeroActivity
@onready var animator   : Node   = %HeroAnimator

@onready var visuals : Node2D = %HeroVisuals 
@onready var activity_label : Label        = %ActivityLabel

var _mouse_over : bool = false


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_setup_mouse_detection()

func initialize() -> void:
	if data:
		visuals.setup(data)

func _setup_mouse_detection() -> void:
	var area   : Area2D            = Area2D.new()
	var shape  : CollisionShape2D  = CollisionShape2D.new()
	var circle : CircleShape2D     = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	area.add_child(shape)
	area.input_pickable = true
	area.mouse_entered.connect(func() -> void: _mouse_over = true)
	area.mouse_exited.connect(func() -> void: _mouse_over = false)
	add_child(area)


# ─────────────────────────────────────────────
#  PHYSIQUE
# ─────────────────────────────────────────────
func _physics_process(_delta: float) -> void:
	move_and_slide()


# ─────────────────────────────────────────────
#  SÉLECTION
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if not _mouse_over:
		return
	if event.is_action_pressed("click"):
		GameData.select_hero(data)
	elif event.is_action_pressed("click_cancel"):
		EventBus.hero_inspect_requested.emit(data, get_viewport().get_mouse_position())


# ─────────────────────────────────────────────
#  API UTILITAIRES 
# ─────────────────────────────────────────────
func set_activity_label(text: String) -> void:
	if data:
		activity_label.text = text
		EventBus.hero_task_changed.emit(data.hero_id, text)


func freeze_movement() -> void:
	set_physics_process(false)


func unfreeze_movement() -> void:
	set_physics_process(true)


func get_planning_for_hour(hour: int) -> String:
	if data:
		return data.planning.get(hour, "free")
	return "free"
