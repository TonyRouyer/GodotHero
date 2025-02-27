extends Node

var research_list : Dictionary = {}
var file_path : String= "res://Json/research.json"


func _ready() -> void:
	load_game_data(file_path)

func load_game_data(path : String) -> void:
	var data:FileAccess
	if FileAccess.file_exists(path):
		data = FileAccess.open(path,FileAccess.READ)
	if data:
		research_list = JSON.parse_string(data.get_as_text())
		return
	print("file load failed")

func has_item(item_id : String) -> bool:
	return research_list.has(item_id)

func get_research(research_id):
	if has_item(research_id):
		return research_list[research_id]
	return null
