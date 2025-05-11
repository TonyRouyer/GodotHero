extends Control

signal activity_selected(instance)

@onready var color_rect : ColorRect = $ColorRect
@export var type : String
@export var hour: int
var activity_color: Color

func _ready() -> void:
	set_data()


func set_type(new_type : String):
	type = new_type
	set_data()


func set_data() -> void:
	match type:
		"sleep":
			activity_color =  Color.html("#9a796b")
		"train":
			activity_color = Color.html("#b45b5b")
		"free":
			activity_color = Color.html("#5df25d")
		"work":
			activity_color = Color.html("#b9db0b")
	color_rect.color = activity_color


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("activity_selected", self)
