extends Control

@onready var activity_container : VBoxContainer = %ActivityContainer
@onready var activity_selector_container : HBoxContainer = %ActivitySelectorContainer
@onready var hour_tracker : Control= $HourTracker

#free, rest , sleep , train
var planning: Dictionary = {
	0 : "train",
	1 : "train",
	2 : "train",
	3 : "train",
	4 : "train",
	5 : "train",
	6 : "train",
	7 : "train",
	8 : "train",
	9 : "train",
	10 : "train",
	11 : "train",
	12 : "train",
	13 : "train",
	14 : "train",
	15 : "train",
	16 : "train",
	17 : "train",
	18 : "train",
	19 : "train",
	20 : "train",
	21 : "train",
	22 : "train",
	23 : "train"
}
var selected_type: String = ""


func _ready() -> void:
	add_to_group("UI")
	TimeManager.connect("hour_changed", _on_hour_changed)
	var actual_hour = TimeManager.current_hour
	hour_tracker.position.y = 56 + (actual_hour * 20)
		
	for activity in activity_container.get_children():
		activity.connect("activity_selected", _on_activity_selected)
		activity.connect("mouse_in", _mouse_enter_activity)
		
	for selector in activity_selector_container.get_children():
		selector.connect("selector_selected", _on_selector_selected)
	update_activity_list()


#Mes a jour les data d'un slot en fonction de la selection
func _on_activity_selected(instance : Object) -> void:
	var type = instance.type
	if selected_type in ["train", "free", "work"] and selected_type != type:
		instance.set_type(selected_type)
		update_activity_list()


#Selectionne une type d'activite (et affiche son overlay)
func _on_selector_selected(instance : Object) -> void:
	selected_type = instance.type
	for selector in activity_selector_container.get_children():
		selector.get_node("Hover").hide()

	if instance.is_selector:
		instance.get_node("Hover").show()


#Met a jours chaque slot pour afficher/masquer les label
func update_activity_list() -> void:
	var activity_type: String
	for activity in activity_container.get_children():
		planning[activity.hour] = activity.type
		activity.show_label()
		if activity_type == activity.type:
			activity.hide_label()
		activity_type = activity.type


#Affiche/masque le menu planning
func _on_planning_btn_pressed() -> void:
	selected_type = ""
	if !self.visible:
		GameData.hide_ui()
		GameData.construction_type = ""
	self.visible  = !self.visible 
	GameData.menu_open = !GameData.menu_open


func _mouse_enter_activity(instance : Object) -> void:
	for activity in activity_container.get_children():
		activity.get_node("Hover").hide()
	instance.get_node("Hover").show()


func _on_hour_changed(new_hour : int) -> void:
	hour_tracker.position.y = 56 + (new_hour * 20)
	hour_tracker.get_node("Label").text = str(TimeManager.current_hour) + "h00"
