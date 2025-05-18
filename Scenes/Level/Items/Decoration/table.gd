extends Node2D

@export var node_name:String = "table"
@export var rotate_state:int # 1: Front / 2: Right / 3: Back / 4: Left
@export var cost:int = 50
var x_size: int
var y_size: int


func rotate_item(_side):
	x_size = $Area2D/CollisionShape2D.shape.size.x
	y_size = $Area2D/CollisionShape2D.shape.size.y
