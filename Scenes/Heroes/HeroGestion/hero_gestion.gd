extends Control

@onready var panel_container = %PanelContainer
@onready var HeroStatContainer : VBoxContainer = %HeroStatContainer
@onready var HeroPlanningContainer : VBoxContainer = %HeroPlanningContainer
@onready var confirmation_panel : PanelContainer = %ConfirmationPanel

var hero: Hero
var selected_type: String = ""


func _ready() -> void:
	add_to_group("UI")
#	
	#%TabContainer.connect("tab_clicked", _on_tab_container_tab_clicked)
	
	%Sleep.connect("pressed", _on_sleep_pressed.bind("sleep"))
	%Train.connect("pressed", _on_train_pressed.bind("train"))
	%Work.connect("pressed", _on_work_pressed.bind("work"))
	%Free.connect("pressed", _on_free_pressed.bind("free"))
	
	%ConfirmFire.connect("pressed", _on_confirm_fire)
	%CancelFire.connect("pressed", _on_cancel_fire)



#Affiche/Masque et met a jour le contenue de la fenetre de gestion des hero
func _on_hero_gestion_btn_pressed() -> void:
	if self.visible:
		self.visible = false
		GameData.menu_open = false
	else:
		GameData.hide_ui()
		populate()
		self.visible = true
		GameData.menu_open = true


#Confirmation de licenciment d'un hero, le supprime et met a jour l'interface 
func _on_confirm_fire() -> void:
	hero.queue_free()
	confirmation_panel.hide()
	var items = HeroStatContainer.get_children()
	for item in items:
		if item.hero == hero:
			item.queue_free()

#Masque la confirmation de supression d'un hero
func _on_cancel_fire() -> void:
	confirmation_panel.hide()


#Met a jour le contenue de la fenetre de gestion des hero
func populate() -> void:
	var infos = HeroStatContainer.get_children()
	for item in infos:
		item.queue_free()
	var plannings = HeroPlanningContainer.get_children()
	for item in plannings:
		item.queue_free()
	
	var heros = get_tree().get_root().get_node("Main/Heroes").get_children()
	for hero_item in heros:
		#Infos
		var info_instance = preload("res://Scenes/Heroes/HeroGestion/hero_gestion_item.tscn").instantiate()
		info_instance.connect("fire_pressed", fire_hero.bind(hero_item))

		info_instance.hero = hero_item
		info_instance.set_custom_minimum_size(Vector2(470,30))
		HeroStatContainer.add_child(info_instance)
		
		#Planning
		var planning_instance = preload("res://Scenes/Heroes/HeroGestion/hero_gestion_planning_item.tscn").instantiate()
		planning_instance.hero = hero_item
		HeroPlanningContainer.add_child(planning_instance)
		


#Affiche la confirmation de livcenssiment des hero
func fire_hero(selected_hero : Hero) -> void:
	confirmation_panel.show()
	hero = selected_hero
 


#func _on_tab_container_tab_clicked(tab):
	#match tab:
		#0:
			#panel_container.size.x = 560
		#1:
			#panel_container.size.x = 1030
			#
#
	#panel_container.position.x = (panel_container.get_parent().size.x / 2 - panel_container.size.x / 2)


func _on_sleep_pressed(activity: String):
	selected_type = activity


func _on_train_pressed(activity: String):
	selected_type = activity


func _on_work_pressed(activity: String):
	selected_type = activity


func _on_free_pressed(activity: String):
	selected_type = activity
