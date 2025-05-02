extends Control

@onready var hero : Hero = $"../.."
@onready var ui_stats_panel : PanelContainer = %StatsWindow
@onready var global_inventory : Control = %GlobalInventory

@onready var nameLabel : Label = %Nom
@onready var nameInput : LineEdit = %NameInput

var strength_priority : float = 0
var defense_priority : float = 0
var agility_priority : float = 0
var mana_priority : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_stats_panel.add_to_group("UI")
	global_inventory.add_to_group("UI")
	
func _process(_delta):
	#S'assure de bien reset les data si on ferme le hero detail via un autre moyen que le btn close
	if ui_stats_panel.visible == false and GameData.active_hero == hero:
		_on_button_pressed()
		
	%Faim.value = hero.faim
	%Sommeil.value = hero.fatigue
	%Moral.value = hero.moral


# Affiche info detailler d'un hero
func show_stats_overlay() -> void:
	ui_stats_panel.show()
	# Remplit les informations du héros dans l'UI
	%Nom.text = hero.name
	%Race.text = hero.race
	%Classe.text = "Classe: " + str(hero.classe)
	%Level.text = "Lvl: " + str(hero.level)
	%Strength.text = "Strength: " + str(hero.strength)
	%Defense.text = "Defense: " + str(hero.defense)
	%Agility.text = "Agility: " + str(hero.agility)
	%Mana.text = "Mana: " + str(hero.mana)
	%Luck.text = "Luck: " + str(hero.luck)
	# Mise à jour de la barre de progression HP
	%Hp.max_value = float(hero.hp_max)
	%Hp.value = float(hero.hp)

	# Charge lE sprite du héros dans l'UI
	self.get_node("HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi/Sprite/AnimationPlayer").play("idle_up")
	global_inventory.load_inventory()
	global_inventory.show()


#met a jour les stats du hero
func update_stats() -> void:
	%Level.text = "Lvl: " + str(hero.level)
	%Strength.text = "Strength: " + str(hero.strength)
	%Defense.text = "Defense: " + str(hero.defense)
	%Agility.text = "Agility: " + str(hero.agility)
	%Mana.text = "Mana: " + str(hero.mana)
	%Luck.text = "Luck: " + str(hero.luck)


#Quand on ferme le menu detail du hero
func _on_button_pressed() -> void:
	#Masque des panneau
	ui_stats_panel.hide()
	global_inventory.hide()
	
	#Reset du champ nameInput
	if nameInput.visible:
		nameInput.visible = false
		nameLabel.visible = true
		
	#deselection du hero actif + autorise le mouvement dans le tileset
	GameData.active_hero = null
	GameData.menu_open = !GameData.menu_open


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


#Affiche et setup le champ input pour modifier le nom
func _on_name_label_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		nameLabel.visible = false
		nameInput.text = hero.name
		nameInput.visible = true


#Change le nom du hero quand on soumet le champ
func _on_name_input_text_submitted(new_text):
	hero.name = new_text
	nameInput.visible = false
	
	nameLabel.text = hero.name
	nameLabel.visible = true


func _on_metier_selected(index):
	hero.job = index
