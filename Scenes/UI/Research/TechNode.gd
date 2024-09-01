extends Control

@onready var button = $"."
@onready var container = $".."

@export var btn_content: String
@export var tech_name: String
@export var tech_icon: String
@export var description: String
@export var parents: Array = []
@export var duration: int
@export var cost: int
var checked: bool = false





