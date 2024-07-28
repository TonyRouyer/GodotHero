extends StaticBody2D

@export var body_in : bool = false
@export var for_mana :bool = false
@export var for_def :bool = false

func _ready():
#	Colore en violet les zone droppable
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)

#func _process(_delta):
##	rend visible les zone dropable quand la variable is_dragging est positive
#	if global.is_dragging:
#		visible = true
#	else:
#		visible = false

func _on_area_2d_body_entered(_body):
	body_in = true

func _on_area_2d_body_exited(_body):
	body_in = false
	

