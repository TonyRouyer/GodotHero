extends CharacterBody2D
class_name Hero

# Variables de stats et attributs du héros
@export var level: int
@export var strength: int
@export var defense: int
@export var agility: int
@export var mana: int
@export var luck: int
@export var hp_max: int
@export var hp: int
@export var race: String
@export var classe: String
@export var skin: String
@export var moral: int
@export var rang: Array
@export var skill_point: int
@export var fatigue: int = 100

# Références aux nœuds
@onready var animatedSprite = $AnimatedSprite2D/AnimationPlayer
@onready var hero_panel_info = $CanvasLayer/HeroPanelInfo

@onready var navigation
@onready var move_target = global_position
@onready var mouse_in = false


func _ready():
	# Si il y une animation de hero, lance l'animation
	if skin != "":
		animatedSprite.play("idle_front")
		

func _input(event):
	if mouse_in and event.is_action_pressed("click_cancel"):
		GameData.set_active_hero(self)
		hero_panel_info.show_stats_overlay()


# Fonction pour appliquer les attributs de l'équipement
func apply_equipment_attributes(item, remove = false):
	var modifier = -1 if remove else 1
	if item.has("attack"):
		strength += item["attack"] * modifier
	if item.has("defense"):
		defense += item["defense"] * modifier


func _on_mouse_entered():
	mouse_in = true


func _on_mouse_exited():
	mouse_in = false


func flip_sprite(flip):
	var hair_node = get_node("AnimatedSprite2D/Hair")
	var skin_node = get_node("AnimatedSprite2D/Skin")
	var body_node = get_node("AnimatedSprite2D/Body")
	if flip:
		hair_node.flip_h = true
		skin_node.flip_h = true
		body_node.flip_h = true
	else:
		hair_node.flip_h = false
		skin_node.flip_h = false
		body_node.flip_h = false
	
