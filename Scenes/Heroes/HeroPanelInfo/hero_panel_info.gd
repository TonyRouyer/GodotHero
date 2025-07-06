extends Control


@onready var hero : Hero = $"../.."
@onready var nameLabel : Label = %Nom
@onready var nameInput : LineEdit = %NameInput
@onready var inv_container = %InvContainer
@onready var right_page = %RightPage

@onready var hero_texture =  %HeroTexture
@onready var global_inventory : Control

@onready var tab_stack = %TabStack
@onready var tab_buttons = %TabButton.get_children()

var strength_priority : float = 0
var defense_priority : float = 0
var agility_priority : float = 0
var mana_priority : float = 0

var social_skill_progress: float = 0
var manual_work_skill_progress: float = 0
var magic_work_skill_progress: float = 0
var cook_skill_progress: float = 0
var research_skill_progress: float = 0

var equip_slots: Array = []


func _ready() -> void:
	add_to_group("UI")
	
	global_inventory = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/GlobalInventory")
	for node in inv_container.get_children():
		node.global_inventory = global_inventory

	equip_slots = get_all_equipement_slots(%Equip_slot_container)


	#Connexion Button
	%CenterViewButton .connect("pressed", _on_center_view_button_pressed)
	%CompetenceButton.connect("pressed", _on_competence_button_pressed)
	%PlanningButton.connect("pressed", _on_planning_button_pressed)
	%CloseButton.connect("pressed", _on_close_button_pressed)
	for i in tab_buttons.size():
		tab_buttons[i].connect("pressed", _on_tab_pressed.bind(i))
	
	_on_tab_pressed(0) # Affiche le premier onglet
	



func get_hero_texture():
	return hero_texture

func _on_tab_pressed(index):
	print(index)
	tab_stack.current_tab = index




func _process(_delta):
	##S'assure de bien reset les data si on ferme le hero detail via un autre moyen que le btn close
	#if self.visible == false and GameData.active_hero == hero:
		#_on_close_button_pressed()
		
	%Hunger.value = hero.hunger
	%Energy.value = hero.energy
	%Toilet.value = hero.toilet
	%Hygiene.value = hero.hygiene
	
	%Hp.value = hero.hp
	%Moral.value = hero.moral


# Affiche info detailler d'un hero
func show_stats_overlay() -> void:
	# Remplit les informations du héros dans l'UI
	%Nom.text = hero.name
	%Classe.text = "Class: " + str(hero.classe)
	%Level.text = "Lvl: " + str(hero.level)
	
	%Strength.text = "Strength: " + str(hero.strength)
	%Defense.text = "Defense: " + str(hero.defense)
	%Agility.text = "Agility: " + str(hero.agility)
	%Mana.text = "Mana: " + str(hero.mana)
	%Luck.text = "Luck: " + str(hero.luck)
	# Mise à jour de la barre de progression HP
	%Hp.max_value = float(hero.hp_max)
	%Hp.value = float(hero.hp)
	%Moral.value = float(hero.moral)

	# Charge lE sprite du héros dans l'UI
	#hero_texture.get_node("Sprite/AnimationPlayer").play("idle_down")
	global_inventory.load_inventory()
	load_inventory()


#met a jour les stats du hero
func update_stats() -> void:
	%Level.text = "Lvl: " + str(hero.level)
	%Strength.text = "Strength: " + str(hero.strength)
	%Defense.text = "Defense: " + str(hero.defense)
	%Agility.text = "Agility: " + str(hero.agility)
	%Mana.text = "Mana: " + str(hero.mana)
	%Luck.text = "Luck: " + str(hero.luck)


#Quand on ferme le menu detail du hero
func _on_close_button_pressed() -> void:
	#Reset du champ nameInput
	if nameInput.visible:
		nameInput.visible = false
		nameLabel.visible = true
		
	#deselection du hero actif + autorise le mouvement dans le tileset
	self.visible = false
	GameData.active_hero = null
	GameData.menu_open = false


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



func _on_center_view_button_pressed():
	self.hide()
	get_tree().get_root().get_node("Main/GameCamera").position = Vector2(hero.global_position)
	
func _on_competence_button_pressed():
	hero.get_node("CanvasLayer/HeroSkills").visible = true
	
	self.visible = false

	GameData.menu_open = true
	
	
func _on_planning_button_pressed():
	self.hide()
	hero.hero_planning.show()
	hero.hero_planning.update_visual_by_planning()
	GameData.menu_open = true



#Charge les objet de la variabla inventory dans l'inventaire
func load_inventory() -> void:
	for child in %InvContainer.get_children():
		var data = GameData.inventory[child.name]
		child.set_slot(data)


func get_all_equipement_slots(root_node) -> Array:
	var result := []
	if root_node is EquipementSlot:
		result.append(root_node)
	for child in root_node.get_children():
		result += get_all_equipement_slots(child)
	return result
