extends Control

@onready var ui_stats_panel : PanelContainer = %StatsWindow
@onready var global_inventory : Control = %GlobalInventory

var parent : CharacterBody2D
var strength_priority : float = 0
var defense_priority : float = 0
var agility_priority : float = 0
var mana_priority : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_stats_panel.add_to_group("UI")
	global_inventory.add_to_group("UI")
	parent = self.get_parent().get_parent()


# Affiche info detailler d'un hero
func show_stats_overlay() -> void:
	ui_stats_panel.show()
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
	self.get_node("HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi/Sprite/AnimationPlayer").play("idle_up")
	global_inventory.load_inventory()
	global_inventory.show()


func _on_button_pressed() -> void:
	ui_stats_panel.hide()
	global_inventory.hide()


func _on_priority_slider_changed(value : int, stats : String):
	match stats:
		"strength":
			strength_priority = value
		"defense":
			defense_priority = value
		"agility":
			agility_priority = value
		"mana":
			mana_priority = value
