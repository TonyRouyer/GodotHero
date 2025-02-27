extends Node

signal gold_changed(new_gold)

var game_items : Dictionary = {}
var file_path : String = "res://Json/items.json"
var default_icon : String = "res://Sprites/items/arrosoire.png"
var active_hero : Hero = null  # Référence au héros actif
var menu_open : bool = false
var construction_type : String = ""
var construction_item : String = ""
var game_paused : bool = false
var gold : int = 10000
var research_finished : Array = []
var inventory : Dictionary = {}
var reputation : int = 0


func _ready() -> void:
	load_game_data(file_path)


func load_game_data(path : String) -> void:
	var data:FileAccess
	if FileAccess.file_exists(path):
		data = FileAccess.open(path,FileAccess.READ)
	if data:
		game_items = JSON.parse_string(data.get_as_text())
		return
	print("file load failed")


func get_item(item_id : String,quantity : int) -> Dictionary:
	#var data = get_item_data(item_id)
	var item = {
		"item_name": item_id,
		"quantity": quantity
	}
	return item


func get_item_data(item_id : String):
	if has_item(item_id):
		return game_items[item_id]


func get_item_name(item_id : String) -> String:
	if has_item(item_id):
		return game_items[item_id].item_name
	else:
		return "name not found"


func get_icon_path(item_id : String) -> String:
	return game_items[item_id].icon_path


func get_stackable(item_id : String) -> int:
	return game_items[item_id].max_stack > 1


func max_stack(item_id : String) -> int:
	return game_items[item_id].max_stack


func get_item_type(item_id : String) -> int:
	var type = ""
	if has_item(item_id):
		type = game_items[item_id].type
	else:
		assert(has_item(item_id)==false,"Error Item not found")
	match type:
		"head":
			return 1
		"hand":
			return 2
		"weapon":
			return 3
		"chest":
			return 4
		"pants":
			return 5
		"feet":
			return 6
		_:
			return 0


func has_item(item_id : String) -> bool:
	return game_items.has(item_id)


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
