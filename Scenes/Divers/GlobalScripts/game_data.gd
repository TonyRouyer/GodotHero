extends Node

var game_items = {}
var file_path = "res://Json/items.json"
var default_icon = "res://Sprites/items/arrosoire.png"
var active_hero = null  # Référence au héros actif


func _ready() -> void:
	load_game_data(file_path)

func load_game_data(path):
	var data:FileAccess
	if FileAccess.file_exists(path):
		data = FileAccess.open(path,FileAccess.READ)
	if data:
		game_items = JSON.parse_string(data.get_as_text())
		return
	print("file load failed")

func get_item(item_id,quantity):
	#var data = get_item_data(item_id)
	var item = {
		"item_name": item_id,
		"quantity": quantity
	}
	return item
	
func get_item_data(item_id):
	if has_item(item_id):
		return game_items[item_id]

func get_item_name(item_id):
	if has_item(item_id):
		return game_items[item_id].item_name
	else:
		return "name not found"

func get_icon_path(item_id):
	return game_items[item_id].icon_path

func get_stackable(item_id):
	return game_items[item_id].max_stack > 1

func max_stack(item_id):
	return game_items[item_id].max_stack

func get_item_type(item_id):
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

func has_item(item_id):
	return game_items.has(item_id)

func set_active_hero(hero):
	active_hero = hero

func get_active_hero():
	return active_hero
