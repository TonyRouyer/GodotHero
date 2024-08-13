extends Node2D

@onready var navigation_agent = $"../NavigationAgent2D"

var parent
var routine = [
	{"start": 0, "end": 6, "activity": "sleep", "position": "Bed"},
	{"start": 7, "end": 10, "activity": "train", "position": "TrainingDummy"},
	{"start": 11, "end": 13, "activity": "rest", "position": "Table"},
	{"start": 14, "end": 17, "activity": "train", "position": "TrainingDummy"},
	{"start": 18, "end": 22, "activity": "eat", "position": "Table"},
	{"start": 23, "end": 24, "activity": "sleep", "position": "Bed"}
]

func _ready():
	parent = get_parent()
	
	var scene_tree = get_tree()
	var time_manager = scene_tree.get_root().get_node("Main/UICanvasLayer/TopMenu/TimeManager")
	if time_manager:
		time_manager.connect("hour_changed", _on_hour_changed)
		
func _physics_process(_delta):
	if !navigation_agent.is_navigation_finished() and !global.game_paused:
		var curent_position = global_position
		var next_path_position = navigation_agent.get_next_path_position()
		parent.velocity = curent_position.direction_to(next_path_position) * 50
		parent.move_and_slide()
		
		
func _on_hour_changed(new_hour):
	#print("hour change: ", new_hour)
	for period in routine:
		if period["start"] <= new_hour and new_hour < period["end"]:
			#print(period["activity"])
			move_to_activity(period["position"])
			perform_activity(period["activity"])
			break
			

func perform_activity(activity):

	match activity:
		"sleep":
			parent.fatigue += 5
		"train":
			parent.fatigue -= 5
			parent.strength += 1
		"rest":
			parent.fatigue += 2
		"eat":
			parent.fatigue += 3
	parent.fatigue = clamp(parent.fatigue, 0, 100)

func move_to_activity(position_name):
	var activity_position = get_node("../../../TileMap/Object/" + position_name)
	if activity_position:
		parent.move_target = activity_position.global_position
		navigation_agent.target_position = activity_position.global_position
