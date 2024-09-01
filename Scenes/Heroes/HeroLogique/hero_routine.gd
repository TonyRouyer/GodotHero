extends Node2D

@onready var navigation_agent = $"../NavigationAgent2D"
@onready var tilemap = $"../../../TileMap/TileMap"
@onready var objects_node = $"../../../TileMap/Object"

var current_path: Array[Vector2i]
var performed_activity = null
var parent
var speed = 75
var routine = [
	{"start": 0, "end": 6, "activity": "sleep", "object": "bed"},
	{"start": 7, "end": 8, "activity": "train", "object": "training_dummy"},
	{"start": 9, "end": 13, "activity": "rest", "object": "table"},
	{"start": 14, "end": 17, "activity": "train", "object": "training_dummy"},
	{"start": 18, "end": 22, "activity": "eat", "object": "table"},
	{"start": 23, "end": 24, "activity": "sleep", "object": "bed"}
]


func _ready():
	parent = get_parent()
	
	var scene_tree = get_tree()
	var time_manager = scene_tree.get_root().get_node("Main/UICanvasLayer/TopMenu/TimeManager")
	if time_manager:
		time_manager.connect("hour_changed", _on_hour_changed)
		
func _physics_process(delta):
		if current_path.is_empty():
			return
		var target_position = tilemap.map_to_local(current_path.front())
		var direction = (target_position - global_position).normalized()
		play_animation_based_on_direction(direction)
		parent.global_position = global_position.move_toward(target_position, speed * delta)
		
		if parent.global_position == target_position:
			current_path.pop_front()
		
func _on_hour_changed(new_hour):
	for period in routine:
		if period["start"] <= new_hour and new_hour < period["end"]:
			perform_activity(period)
			break
			

func play_animation_based_on_direction(direction: Vector2):
	var animated_sprite = parent.get_node("AnimatedSprite2D/AnimationPlayer")
	parent.flip_sprite(false)
	if direction.x > 0:
		animated_sprite.play("walk_side")
	elif direction.x < 0:
		parent.flip_sprite(true)
		animated_sprite.play("walk_side")
	elif direction.y > 0:
		animated_sprite.play("walk_front")
	elif direction.y < 0:
		animated_sprite.play("walk_back")

func perform_activity(activity):
	if activity["activity"] != performed_activity:
		performed_activity = activity["activity"]
		match activity:
			"sleep":
				parent.fatigue += 5
			"train":
				parent.fatigue -= 5
			"rest":
				parent.fatigue += 2
			"eat":
				parent.fatigue += 3
		parent.fatigue = clamp(parent.fatigue, 0, 100)
		move_to_activity(activity["object"])

func move_to_activity(position_name):
	var activity_position = null
	var objects = objects_node.get_children()
	for object in objects:
		if object.node_name == position_name and object.used == false:
			object.used = true
			activity_position = object.global_position
			break
	
	if activity_position:
		if tilemap.is_point_walkable(activity_position):
			current_path = tilemap.astar.get_id_path(
				tilemap.local_to_map(global_position),
				tilemap.local_to_map(activity_position)
			).slice(1)
