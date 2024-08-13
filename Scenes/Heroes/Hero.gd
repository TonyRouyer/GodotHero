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
@export var idle_animation: String
@export var moral: int
@export var rang: Array
@export var skill_point: int
@export var fatigue: int = 100
# Références aux nœuds
@onready var animatedSprite = $AnimatedSprite2D
@onready var ui_stats_overlay = $stats_overlay
@onready var ui_stats_panel = $CanvasLayer/HeroInventorySystem/statsWindow
@onready var inventory_system = $CanvasLayer/HeroInventorySystem
@onready var global_inventory = $CanvasLayer/HeroInventorySystem/GlobalInventory
@onready var drag_drop_system = $HeroDragDropSystem

@onready var navigation
@onready var move_target = global_position


func _ready():
	# Si il y une animation de hero, lance l'animation
	if idle_animation != "":
		animatedSprite.play(idle_animation)
		
	inventory_system._ready()

func _process(_delta):
	#met en pause l'animation du sprite quand le jeu est en pause
	if global.game_paused:
		animatedSprite.stop()
	else:
		animatedSprite.play(idle_animation)
		
	if drag_drop_system.draggable:
		ui_stats_overlay.visible = true

	if drag_drop_system.draggable and Input.is_action_just_pressed("r_click"):
		GameData.set_active_hero(self)
		show_stats_overlay()


func show_stats_overlay():
	# Affiche la fenêtre des statistiques
	ui_stats_panel.visible = true
	# Remplit les informations du héros dans l'UI
	%Nom.text = self.name
	%Race.text = self.race
	%Classe.text = self.classe
	%Level.text = "Level: " + str(self.level)
	%Strength.text = "Strength: " + str(self.strength)
	%Defense.text = "Defense: " + str(self.defense)
	%Agility.text = "Agility: " + str(self.agility)
	%Mana.text = "Mana: " + str(self.mana)
	%Luck.text = "Luck: " + str(self.luck)

	# Mise à jour de la barre de progression HP
	%Hp.max_value = float(self.hp_max)
	%Hp.value = float(self.hp)

	# Charge le sprite du héros dans l'UI
	%Sprite.animation = self.idle_animation
	global_inventory.load_inventory()
	inventory_system.show()

func _on_button_pressed():
	ui_stats_panel.visible = false
	inventory_system.hide()

# Met à jour l'overlay des statistiques
func update_stats_data():
	#overlay
	%str.text = "Str : " + str(self.strength)
	%def.text = "Def : " + str(self.defense)
	%agi.text = "Agi : " + str(self.agility)
	%mana.text = "Mana : " + str(self.mana)
	%luck.text = "Luck " + str(self.luck)
	%hp.text = str(self.hp) + "/" + str(self.hp_max)
	%lvl.text = "lvl " + str(self.level)
	
	#stat panel
	%Strength.text = "Strength: " + str(self.strength)
	%Defense.text = "Defense: " + str(self.defense)
	%Agility.text = "Agility: " + str(self.agility)
	%Mana.text = "Mana: " + str(self.mana)
	%Luck.text = "Luck: " + str(self.luck)


# Fonction pour appliquer les attributs de l'équipement
func apply_equipment_attributes(item, remove = false):
	var modifier = -1 if remove else 1
	if item.has("attack"):
		strength += item["attack"] * modifier
	if item.has("defense"):
		defense += item["defense"] * modifier
	update_stats_data()
