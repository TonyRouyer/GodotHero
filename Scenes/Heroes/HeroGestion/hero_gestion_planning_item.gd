extends Control

var hero: Hero
@onready var timeblock: HBoxContainer = %TimeBlock



func _ready() -> void:
	%Nom.text = hero.name
	var planning = hero.get_node("CanvasLayer/HeroPlanning").planning
	
	for item in timeblock.get_children():
		var new_type = planning[item.hour]
		item.type = new_type
		item.set_type(new_type)
		item.connect("activity_selected", _on_activity_selected)
	
	self.custom_minimum_size.x = timeblock.position.x + timeblock.size.x


func _on_activity_selected(instance : Object) -> void:
	var gestion_node = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/HeroGestion")
	var type = instance.type
	var selected_type = gestion_node.selected_type

	if selected_type in ["train", "free", "work", "sleep"] and selected_type != type:
		instance.set_type(selected_type)
		update_activity_list()



#Met a jours chaque slot de la variable planning
func update_activity_list() -> void:
	var hero_planning_node = hero.get_node("CanvasLayer/HeroPlanning")

	for activity in timeblock.get_children():
		hero_planning_node.planning[activity.hour] = activity.type
