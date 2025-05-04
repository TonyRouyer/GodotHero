extends Control

@onready var heroesNode : Node2D = $"../../../Heroes"
@onready var hero_recruitment_ui : Control = $"."
#const HeroDataScript : Script = preload("res://Scenes/Heroes/hero_data.gd")
var heroDataInstance : HeroData = preload("res://Scenes/Heroes/hero_data.gd").new()
var selectedHeroes : Array


func _ready() -> void:
	add_to_group("UI")
	# Sélectionne aléatoirement 3 héros au démarrage
	for x in 3:
		selectedHeroes.append( heroDataInstance.get_random_hero())
	create_new_hero(0)


#Action fermeture de la fenetre de recrutement
func _on_btn_close_pressed() -> void:
	GameData.menu_open = false
	# Ferme la fenêtre des détails des héros
	hero_recruitment_ui.hide()


# refresh la liste des hero a recruter
func _on_refresh_btn_pressed() -> void:
	selectedHeroes = []
	for x in 3:
		selectedHeroes.append(heroDataInstance.get_random_hero())
	create_heros_liste(true)


#Action quand recrute un Hero
func _on_recrute_btn_pressed(hero_index):
	# Positionne le héros à la première position disponible
	create_new_hero(hero_index)


func create_new_hero(hero_index : int) -> void: 
	var heroInstance = create_hero_instance( selectedHeroes[hero_index] )

	# Vérifiez que le héros a bien été créé
	if heroInstance:
		print("Héros créé: ", heroInstance.name)
	
		heroInstance.position = Vector2(500,475)
		heroesNode.add_child(heroInstance)
	
		var heroContainers = [$PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero1, $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero2, $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero3]
		heroContainers[hero_index].get_node("RecruteBtn").disabled = true


#Affiche la liste des hero a recuter dans la fenetre
func create_heros_liste(refresh : bool) -> void:
	# Conteneurs pour les héros (Hero1, Hero2, Hero3)
	var heroContainers = [$PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero1, $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero2, $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/Hero3]

	# Ajoute les détails des héros sélectionnés
	for i in range(heroContainers.size()):
		if i < selectedHeroes.size():
			var heroName = selectedHeroes[i].name
			var heroRace = selectedHeroes[i].race
			var heroClass = selectedHeroes[i].classe
			# Récupère le conteneur actuel
			var heroContainer = heroContainers[i]
			if refresh == true:
				heroContainer.get_node("RecruteBtn").disabled = false
			# Assigne les valeurs aux labels
			heroContainer.get_node("Name").text = "Name: " + heroName
			heroContainer.get_node("Classe").text = "Class: " + heroClass
			heroContainer.get_node("Race").text = "Race: " + heroRace
			heroContainer.get_node("RecruteBtn").text = "Recruit"
			heroContainer.visible = true  # Assure que le conteneur est visible si nécessaire
		else:
			# Cache les conteneurs non utilisés
			heroContainers[i].visible = false


func create_hero_instance(heroInfo : Dictionary) -> Node2D:
	var heroScene = preload("res://Scenes/Heroes/hero.tscn") 
	var heroInstance = heroScene.instantiate() as Node2D
	
	# Configurez les propriétés du héros ici
	heroInstance.set("name", heroInfo.name)
	heroInstance.set("strength", heroInfo.strength)
	heroInstance.set("defense", heroInfo.defense)
	heroInstance.set("agility", heroInfo.agility)
	heroInstance.set("mana", heroInfo.mana)
	heroInstance.set("luck", heroInfo.luck)
	heroInstance.set("hp_max", heroInfo.hp_max)
	heroInstance.set("hp", heroInfo.hp_max)
	heroInstance.set("race", heroInfo.race)
	heroInstance.set("classe", heroInfo.classe)
	heroInstance.set("skin", heroInfo.skin)
	
	#on ajoute le skin au hero
	var animation_node = load("res://Scenes/Heroes/SpriteAnimations/"+ str(heroInfo.skin) +".tscn")
	var animation = animation_node.instantiate()
	animation.name = "AnimatedSprite2D"
	
	animation.get_node("Hair").texture = load("res://Sprites/hero/hair/" + str(heroInfo.hair) + ".png")
	animation.get_node("Chest").texture = load("res://Sprites/hero/chest/" + str(heroInfo.chest) + ".png")
	animation.get_node("Pant").texture = load("res://Sprites/hero/pant/" + str(heroInfo.pant) + ".png")
	
	heroInstance.add_child(animation)
	
	#Instantie une 2nf fois le sprite pour l'afficher dans les detail du hero
	var animation_ui = animation_node.instantiate()
	animation_ui.name = "Sprite"
	heroInstance.get_node("CanvasLayer/HeroPanelInfo/HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi").add_child(animation_ui)
	animation_ui.position = Vector2(105,107)
	animation_ui.scale = Vector2(5,5)
	
	animation_ui.get_node("Hair").texture = load("res://Sprites/hero/hair/" + str(heroInfo.hair) + ".png")
	animation_ui.get_node("Chest").texture = load("res://Sprites/hero/chest/" + str(heroInfo.chest) + ".png")
	animation_ui.get_node("Pant").texture = load("res://Sprites/hero/pant/" + str(heroInfo.pant) + ".png")

	return heroInstance


func _on_recrut_btn_pressed() -> void:
	if !self.visible:
		GameData.hide_ui()
		create_heros_liste(false)
		GameData.construction_type = ""
	self.visible = !self.visible
	GameData.menu_open = !GameData.menu_open
	
	GameData.menu_open = !GameData.menu_open
	## Affiche la fenêtre des détails des héros
	#hero_recruitment_ui.show()
