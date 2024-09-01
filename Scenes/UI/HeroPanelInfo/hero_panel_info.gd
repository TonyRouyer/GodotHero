extends Control

@onready var ui_stats_panel = $HBoxContainer/StatsWindow
@onready var global_inventory = $HBoxContainer/GlobalInventory

var parent: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent().get_parent()


func show_stats_overlay():
	# Affiche la fenêtre des statistiques
	ui_stats_panel.visible = true
	# Remplit les informations du héros dans l'UI
	%Nom.text = parent.name
	%Race.text = parent.race
	%Classe.text = "Classe: " + str(parent.classe)
	%Level.text = "Lvl: " + str(parent.level)
	%Strength.text = "Strength: " + str(parent.strength)
	%Defense.text = "Defense: " + str(parent.defense)
	%Agility.text = "Agility: " + str(parent.agility)
	%Mana.text = "Mana: " + str(parent.mana)
	%Luck.text = "Luck: " + str(parent.luck)

	# Mise à jour de la barre de progression HP
	%Hp.max_value = float(parent.hp_max)
	%Hp.value = float(parent.hp)

	# Charge lE sprite du héros dans l'UI
	self.get_node("HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi/Sprite/AnimationPlayer").play("idle_front")
	global_inventory.load_inventory()
	global_inventory.show()


func _on_button_pressed():
	ui_stats_panel.hide()
	global_inventory.hide()

