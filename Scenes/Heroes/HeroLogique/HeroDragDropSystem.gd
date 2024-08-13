extends Node2D

signal drag_started
signal drag_ended

@onready var stats_overlay = $"../stats_overlay"

var draggable = false
var offset: Vector2
var initialPos: Vector2
var parent

func _ready():
	parent = get_parent()

func _process(_delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			print("click")
			initialPos = parent.global_position
			offset = get_global_mouse_position() - parent.global_position
		if Input.is_action_pressed("click"):
			parent.global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", self.position, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered():
	draggable = true
	get_parent().update_stats_data()

func _on_area_2d_mouse_exited():
	draggable = false
	stats_overlay.visible = false
