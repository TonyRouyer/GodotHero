extends Control

signal activity_selected(instance)
signal selector_selected(instance)
signal mouse_in(instance)


@onready var color_rect : ColorRect = $ColorRect
@onready var label : Label = $ColorRect/Label
@export var type : String
@export var hour: int
@export var is_selector: bool
var activity_color: Color
var activity_text: String


func _ready() -> void:
	set_data()


func set_type(new_type : String):
	type = new_type
	set_data()


func set_data() -> void:
	match type:
		"sleep":
			activity_color =  Color.html("#9a796b")
			activity_text = "Sleep"
		"eat":
			activity_color = Color.html("#9cb09d")
			activity_text = "Eat"
		"train":
			activity_color = Color.html("#b45b5b")
			activity_text = "train"
		"free":
			activity_color = Color.html("#5df25d")
			activity_text = "Free"
		"work":
			activity_color = Color.html("#b9db0b")
			activity_text = "Work"
	color_rect.color = activity_color
	label.text = activity_text


func hide_label() -> void:
	label.hide()


func show_label() -> void:
	label.show()


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_selector:
			emit_signal("selector_selected", self)
		else:
			emit_signal("activity_selected", self)


func _on_mouse_entered() -> void:
	emit_signal("mouse_in", self)
