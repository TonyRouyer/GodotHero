extends Node

signal gold_changed(new_gold)

var active_hero : Hero = null  # Référence au héros actif
var menu_open : bool = false
var construction_type : String = ""
var construction_item : String = ""
var game_paused : bool = false
var gold : int = 10000
var research_finished : Array = []
var inventory : Dictionary = {}
var reputation : int = 0
var inventory_first_load : bool = true



func set_active_hero(hero : Hero) -> void:
	active_hero = hero


func get_active_hero() -> Hero:
	return active_hero

func set_gold(value : int) -> void:
	gold = gold + value
	emit_signal("gold_changed", gold)


func set_reputation(value : int) -> void:
	reputation = reputation + value


func hide_ui() -> void:
	var ui_to_hide = get_tree().get_nodes_in_group("UI")
	for ui in ui_to_hide:
		ui.hide()

#retourne toute les ressource du fichier specifier
func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths


#recupere la ressource pour l'item specifier
func get_item(item_name : String) -> ItemData:
	var resource_path = "res://Scenes/Inventory/ItemRessources/" + item_name + ".tres"
	
	if ResourceLoader.exists(resource_path):
		var resource = load(resource_path)
		if resource:
			return resource
		else:
			push_error("La ressource n'a pas pu être chargée : " + resource_path)
			return null
	else:
		push_error("La ressource n'existe pas : " + resource_path)
		return null
