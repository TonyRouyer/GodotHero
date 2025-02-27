extends Node2D

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
var parent: Hero
var destination : Vector2
var position_save : Vector2

func _ready() -> void:
	parent = get_parent()


func _on_timer_timeout() -> void:
	navigation_agent.target_position = destination
	
	#print('***********')
	#print("nav finished ? ", navigation_agent.is_navigation_finished())
	if navigation_agent.is_navigation_finished() == false and position_save:

		var offset = Vector2(0.2, 0.2)  # Valeur à ajouter ou soustraire en X et Y
		var new_position_plus = position_save + offset  # Position + offset
		var new_position_minus = position_save - offset  # Position - offset
		

		#if parent.position.x >= new_position_minus.x and parent.position.y >= new_position_minus.y:
			#print("STUCK")
		#else:
			#print("pas dtuck")
		#
		#if parent.position.x <= new_position_plus.x  and parent.position.y <= new_position_plus.y:
			#print("STUCK")
		#else:
			#print("pas dtuck")
		
		#print(global_position)
		#print(position_save)
		#print(global_position.distance_to(position_save))
		
		if global_position.distance_to(position_save) < 1.0:  # Si la position ne change presque pas
			pass
			#print("Le joueur est bloqué !")
			# Ici, tu peux stopper le pathfinding ou repositionner le joueur
		else:
			#print("player mouve")
			pass
		position_save = parent.global_position


func set_destination(pos: Vector2):
	parent.set_physics_process(true)
	destination = pos
	#print(destination)
	navigation_agent.target_position = destination
