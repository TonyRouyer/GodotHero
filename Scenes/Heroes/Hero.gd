extends CharacterBody2D
class_name Hero


# Stats Principal
@export var strength: int
@export var defense: int
@export var agility: int
@export var mana: int
@export var luck: int

#Stats metier
@export var social : int
@export var work_manual : int
@export var work_magic : int
@export var research : int
@export var cook : int

#Attribut primaire
@export var energy: float = 100
@export var hunger: float = 100
@export var entertainment: float = 100 #divertisement
@export var toilet: float = 100 #envie d'aller au WC
@export var hygiene: float = 100 #propreté/hygiène

#stats secondaire
@export var hp_max: int
@export var hp: int
@export var moral: float = 100
@export var speed:int = 65
#@export var speed:int = 300

#Variable progression
@export var experience: int = 0
@export var skill_point: int = 0
@export var level: int = 1
@export var rang: int = 0

#variable Definition du hero
@export var race: String
@export var classe: String
@export var skin: String
@export var job : int = 0 # 0.aucun / 1.Acceuil / 2.Artisant / 3.Mage / 4.Chercheur / 5.Cuisinier



# Références aux nœuds
@onready var animatedSprite : AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var hero_panel_info : Control = %HeroPanelInfo
@onready var pathfinding : Node2D = %HeroPathfinding
@onready var mouse_in : bool = false


func _ready() -> void:
	# Si il y une animation de hero, lance l'animation
	if skin != "":
		animatedSprite.play("idle_down")
	%HeroPlanning.connect("close_planning", _on_close_Planning_pressed)


func _input(event : InputEvent) -> void:
	if mouse_in and event.is_action_pressed("click_cancel"):
		GameData.hide_ui()
		GameData.menu_open = !GameData.menu_open
		GameData.set_active_hero(self)
		hero_panel_info.show_stats_overlay()


func _on_mouse_entered() -> void:
	mouse_in = true


func _on_mouse_exited() -> void:
	mouse_in = false


# Fonction pour appliquer les attributs de l'équipement
func apply_equipment_attributes(item : Dictionary, add_stats: bool):
	var item_resource = item.item
	var item_attack = item_resource.item_attack
	var item_defense = item_resource.item_defense

	if add_stats == true:
		if item_attack != 0:
			strength += item_attack
		if item_defense != 0:
			defense += item_defense
	else:
		if item_attack != 0:
			strength -= item_attack
		if item_defense != 0:
			defense -= item_defense
		
	hero_panel_info.update_stats()

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

func _on_close_Planning_pressed():
	%HeroPanelInfo.show()
	%HeroPlanning.hide()
