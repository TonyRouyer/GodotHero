extends Control

@onready var v_box_container : VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var scroll_container : ScrollContainer = $PanelContainer/MarginContainer/ScrollContainer
@onready var confirmation_panel : PanelContainer = %ConfirmationPanel
var hero: Hero


func _ready() -> void:
	add_to_group("UI")
	#var slider = scroll_container.get_node("_v_scroll")


#Affiche/Masque et met a jour le contenue de la fenettre de gestion des hero
func _on_hero_gestion_btn_pressed() -> void:
	if !self.visible:
		GameData.hide_ui()
		populate()
		GameData.construction_type = ""
	self.visible = !self.visible
	GameData.menu_open = !GameData.menu_open


#Confirmation de licenciment d'un hero, le supprime et met a jour l'interface 
func _on_confirm_fire() -> void:
	hero.queue_free()
	confirmation_panel.hide()
	var items = v_box_container.get_children()
	for item in items:
		if item.hero == hero:
			item.queue_free()

#Masque la confirmation de supression d'un hero
func _on_cancel_fire() -> void:
	confirmation_panel.hide()


#Met a jour le contenue de la fenetre de gestion des hero
func populate() -> void:
	var items = v_box_container.get_children()
	for item in items:
		item.queue_free()
	
	var heros = get_tree().get_root().get_node("Main/Heroes").get_children()
	for hero_item in heros:
		var item = preload("res://Scenes/Heroes/HeroGestion/hero_gestion_item.tscn").instantiate()
		item.connect("fire_pressed", fire_hero.bind(hero_item))
		item.set_nom(hero_item.name)
		item.set_level(hero_item.level)
		item.set_classe(hero_item.classe)
		item.hero = hero_item
		item.set_custom_minimum_size(Vector2(470,30))
		v_box_container.add_child(item)


#Affiche la confirmation de livcenssiment des hero
func fire_hero(selected_hero : Hero) -> void:
	confirmation_panel.show()
	hero = selected_hero
