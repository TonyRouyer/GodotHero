extends Control

@onready var heroesNode = $"../../../Heroes"

const HeroData = preload("res://Scenes/Heroes/HeroData.gd")
var heroDataInstance = HeroData.new()
var selectedHeroes = []

@onready var hero_recruitment_ui = $"."


func _ready():
	# Sélectionne aléatoirement 3 héros au démarrage
	for x in 3:
		selectedHeroes.append(heroDataInstance.get_random_hero())
	create_new_hero(0)



#Action fermeture de la fenetre de recrutement
func _on_btn_close_pressed():
	global.move_camera = true
	# Ferme la fenêtre des détails des héros
	hero_recruitment_ui.hide()

# refresh la liste des hero a recruter
func _on_refresh_btn_pressed():
	selectedHeroes = []
	for x in 3:
		selectedHeroes.append(heroDataInstance.get_random_hero())
	create_heros_liste(true)

#Action quand recrute un Hero
func _on_recrute_btn_pressed(hero_index):
	# Positionne le héros à la première position disponible
	create_new_hero(hero_index)

func create_new_hero(hero_index): 
	var heroInstance = create_hero_instance( selectedHeroes[hero_index] )

	# Vérifiez que le héros a bien été créé
	if heroInstance:
		print("Héros créé: ", heroInstance.name)
	
		heroInstance.position = Vector2(500,475)
		heroesNode.add_child(heroInstance)
	
		var heroContainers = [$ColorRect/VBoxContainer/Hero1, $ColorRect/VBoxContainer/Hero2, $ColorRect/VBoxContainer/Hero3]
		heroContainers[hero_index].get_node("RecruteBtn").disabled = true

#Affiche la liste des hero a recuter dans la fenetre
func create_heros_liste(refresh):
	# Conteneurs pour les héros (Hero1, Hero2, Hero3)
	var heroContainers = [$ColorRect/VBoxContainer/Hero1, $ColorRect/VBoxContainer/Hero2, $ColorRect/VBoxContainer/Hero3]

	# Ajoute les détails des héros sélectionnés
	for i in range(heroContainers.size()):
		if i < selectedHeroes.size():
			var heroName = selectedHeroes[i].name
			var heroRace = selectedHeroes[i].race
			var heroClass = selectedHeroes[i].classe
			var heroLevel = selectedHeroes[i].level
			# Récupère le conteneur actuel
			var heroContainer = heroContainers[i]
			if refresh == true:
				heroContainer.get_node("RecruteBtn").disabled = false
			# Assigne les valeurs aux labels
			heroContainer.get_node("Name").text = "Name: " + heroName
			heroContainer.get_node("Lvl").text = "Level: " + str(heroLevel)
			heroContainer.get_node("Classe").text = "Class: " + heroClass
			heroContainer.get_node("Race").text = "Race: " + heroRace
			heroContainer.get_node("RecruteBtn").text = "Recruit"
			heroContainer.visible = true  # Assure que le conteneur est visible si nécessaire
		else:
			# Cache les conteneurs non utilisés
			heroContainers[i].visible = false


func create_hero_instance(heroInfo) -> Node2D:
	var heroScene = preload("res://Scenes/Heroes/Hero.tscn")  # Changez cela par le chemin de votre scène de héros
	var heroInstance = heroScene.instantiate() as Node2D
	# Configurez les propriétés du héros ici
	heroInstance.set("name", heroInfo.name)
	heroInstance.set("level", heroInfo.level)
	heroInstance.set("strength", heroInfo.strength)
	heroInstance.set("defense", heroInfo.defense)
	heroInstance.set("agility", heroInfo.agility)
	heroInstance.set("mana", heroInfo.mana)
	heroInstance.set("luck", heroInfo.luck)
	heroInstance.set("hp_max", heroInfo.hp_max)
	heroInstance.set("hp", heroInfo.hp_max)
	heroInstance.set("race", heroInfo.race)
	heroInstance.set("classe", heroInfo.classe)
	heroInstance.set("idle_animation", heroInfo.animated_skin)
	heroInstance.set("moral", 100)
	heroInstance.set("rang", "F")
	heroInstance.set("skill_point", 0)
	
	return heroInstance


func _on_recrut_btn_pressed():
	global.move_camera = false
	# Affiche la fenêtre des détails des héros

	hero_recruitment_ui.show()
	create_heros_liste(false)
