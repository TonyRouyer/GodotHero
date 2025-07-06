extends Control

signal close_planning()

@onready var activity_container = %TimeBlock
@onready var hour_tracker : Line2D = %HourTracker/Line2D

#sleep, train , work , free
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
	%CloseButton.connect("pressed", _on_close_button_pressed)
	%Sleep.connect("pressed", _on_sleep_pressed.bind("sleep"))
	%Train.connect("pressed", _on_train_pressed.bind("train"))
	%Work.connect("pressed", _on_work_pressed.bind("work"))
	%Free.connect("pressed", _on_free_pressed.bind("free"))
	#%Copy.connect("pressed", _on_copy_pressed)
	#%Past.connect("pressed", _on_past_pressed)
	%Night.connect("pressed", _on_night_layout_pressed)
	%Morning.connect("pressed", _on_morning_layout_pressed)
	%Day.connect("pressed", _on_afternoon_layout_pressed)
	%Evening.connect("pressed", _on_journey_layout_pressed)
	
	var actual_hour = TimeManager.current_hour
	hour_tracker.position.y = -46
	hour_tracker.position.x = -425 + (actual_hour * 37)
	
	for activity in activity_container.get_children():
		activity.connect("activity_selected", _on_activity_selected)
		
	update_activity_list()


#Mes a jour les data d'un slot en fonction de la selection
func _on_activity_selected(instance : Object) -> void:
	var type = instance.type
	if selected_type in ["train", "free", "work", "sleep"] and selected_type != type:
		instance.set_type(selected_type)
		update_activity_list()


#Met a jours chaque slot de la variable planning
func update_activity_list() -> void:
	for activity in activity_container.get_children():
		planning[activity.hour] = activity.type


func update_visual_by_planning() -> void:
	for item in activity_container.get_children():
		var new_type = planning[item.hour]
		item.type = new_type
		item.set_type(new_type)


func _on_hour_changed(new_hour : int) -> void:
	hour_tracker.position.x = -425 + (new_hour * 37)


func _on_sleep_pressed(activity):
	selected_type = activity
	update_activity_list()


func _on_train_pressed(activity):
	selected_type = activity
	update_activity_list()


func _on_work_pressed(activity):
	selected_type = activity
	update_activity_list()


func _on_free_pressed(activity):
	selected_type = activity
	update_activity_list()


func _on_copy_pressed():
	GameData.planning_copy = planning.duplicate(true)


func _on_past_pressed():
	planning = GameData.planning_copy
	update_visual_by_planning()


func _on_night_layout_pressed():
	var new_plannning: Dictionary = {
		0 : "free",
		1 : "free",
		2 : "train",
		3 : "train",
		4 : "train",
		5 : "train",
		6 : "free",
		7 : "free",
		8 : "sleep",
		9 : "sleep",
		10 : "sleep",
		11 : "sleep",
		12 : "sleep",
		13 : "sleep",
		14 : "sleep",
		15 : "sleep",
		16 : "free",
		17 : "free",
		18 : "free",
		19 : "free",
		20 : "work",
		21 : "work",
		22 : "work",
		23 : "work"
	}
	planning = new_plannning
	update_visual_by_planning()


func _on_morning_layout_pressed():
	var new_plannning: Dictionary = {
		0 : "sleep",
		1 : "sleep",
		2 : "sleep",
		3 : "sleep",
		4 : "free",
		5 : "free",
		6 : "work",
		7 : "work",
		8 : "work",
		9 : "work",
		10 : "work",
		11 : "work",
		12 : "work",
		13 : "free",
		14 : "free",
		15 : "free",
		16 : "train",
		17 : "train",
		18 : "train",
		19 : "train",
		20 : "free",
		21 : "free",
		22 : "sleep",
		23 : "sleep"
	}
	planning = new_plannning
	update_visual_by_planning()


func _on_afternoon_layout_pressed():
	var new_plannning: Dictionary = {
		0 : "sleep",
		1 : "sleep",
		2 : "sleep",
		3 : "sleep",
		4 : "free",
		5 : "free",
		6 : "train",
		7 : "train",
		8 : "train",
		9 : "train",
		10 : "free",
		11 : "free",
		12 : "work",
		13 : "work",
		14 : "work",
		15 : "work",
		16 : "work",
		17 : "work",
		18 : "work",
		19 : "free",
		20 : "free",
		21 : "free",
		22 : "sleep",
		23 : "sleep"
	}
	planning = new_plannning
	update_visual_by_planning()


func _on_journey_layout_pressed():
	var new_plannning: Dictionary = {
		0 : "sleep",
		1 : "sleep",
		2 : "sleep",
		3 : "sleep",
		4 : "free",
		5 : "train",
		6 : "train",
		7 : "work",
		8 : "work",
		9 : "work",
		10 : "work",
		11 : "work",
		12 : "free",
		13 : "free",
		14 : "work",
		15 : "work",
		16 : "work",
		17 : "work",
		18 : "work",
		19 : "train",
		20 : "train",
		21 : "free",
		22 : "sleep",
		23 : "sleep"
	}
	planning = new_plannning
	update_visual_by_planning()


func _on_close_button_pressed():
	close_planning.emit()
