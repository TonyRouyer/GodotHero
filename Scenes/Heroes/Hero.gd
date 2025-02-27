extends CharacterBody2D
class_name Hero

# Variables de stats et attributs du héros
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

@export var moral: int = 100
@export var fatigue: int = 100
@export var experience: int = 0
@export var level: int = 1
@export var skill_point: int = 0
@export var rang: int = 0
@export var speed:int = 65

# Références aux nœuds
@onready var animatedSprite : AnimationPlayer= $AnimatedSprite2D/AnimationPlayer
@onready var hero_panel_info : Control = %HeroPanelInfo
@onready var pathfinding : Node2D = %HeroPathfinding
@onready var mouse_in : bool = false


func _ready() -> void:
	# Si il y une animation de hero, lance l'animation
	if skin != "":
		animatedSprite.play("idle_down")


func _physics_process(_delta) -> void:
	var direction = to_local(pathfinding.navigation_agent.get_next_path_position()).normalized()
	velocity = direction * speed
	
	if direction.length() > 0:  # Vérifie si le PNJ bouge
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animatedSprite.play("walk_right")
			else:
				animatedSprite.play("walk_left")
		else:
			if direction.y > 0:
				animatedSprite.play("walk_down")
			else:
				animatedSprite.play("walk_up")
				
			# Pour les diagonales, on favorise gauche/droite
				if direction.x < 0.25 && direction.x > 0.25:
					if direction.x > 0:
						animatedSprite.play("walk_right")  # Haut-Droite / Bas-Droite
					elif direction.x < 0:
						animatedSprite.play("walk_left")  # Haut-Gauche / Bas-Gauche
	else:
		animatedSprite.stop()  # Stop l'animation si le PNJ ne bouge plus
		animatedSprite.play("idle_down")

	move_and_slide()


func _input(event : InputEvent) -> void:
	if mouse_in and event.is_action_pressed("click_cancel"):
		GameData.hide_ui()
		GameData.set_active_hero(self)
		hero_panel_info.show_stats_overlay()


func _on_mouse_entered() -> void:
	mouse_in = true


func _on_mouse_exited() -> void:
	mouse_in = false


# Fonction pour appliquer les attributs de l'équipement
func apply_equipment_attributes(item : Dictionary, remove : bool = false):
	print(item)
	var modifier = -1 if remove else 1
	if item.has("attack"):
		strength += item["attack"] * modifier
	if item.has("defense"):
		defense += item["defense"] * modifier


func rank_up():
	if rang < 6:
		rang += 1


func get_ranks():
	var ranks = ["F","E","D","C","B","A","S"]
	return ranks[rang]


#Return le total d'xp necessaire pour lvl up
func get_remaning_xp():
	var remaning_xp = 100 * pow(1.7, level - 1)
	return remaning_xp


func gain_xp(value):
	var remaning_xp = get_remaning_xp()
	experience += value
	if experience >= remaning_xp:
		level_up()


func level_up():
	level += 1
	skill_point += 15
	
	strength += randi_range(1,5)
	defense += randi_range(1,5)
	agility += randi_range(1,5)
	mana += randi_range(1,5)
	luck += randi_range(1,5)
