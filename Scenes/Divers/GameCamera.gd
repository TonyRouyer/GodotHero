extends Camera2D

@export var zoom_step: float = 0.1  # Contrôle la granularité du zoom
@export var zoom_min: float = 0.5   # Zoom minimum
@export var zoom_max: float = 3.0   # Zoom maximum
@export var move_speed: float = 200 # Vitesse de déplacement de la caméra
@export var edge_threshold: int = 30  # La distance en pixels du bord pour déclencher le mouvement
@export var mouse_drag_sensitivity: float = 0.01  # Sensibilité du déplacement avec le clic molette

# Variables pour stocker la taille de la fenêtre
var window_size: Vector2
var mouse_dragging: bool = false
var mouse_drag_start: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Centrer la caméra au démarrage
	global_position = Vector2(605, 300)
	# Configurer le zoom initial
	zoom = Vector2(2, 2)
	# Récupérer la taille de la fenêtre actuelle
	window_size = get_viewport().get_visible_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.move_camera == true:
		# Déplacement avec les flèches
		var move_vector = Vector2()
		if Input.is_action_pressed("ui_right"):
			move_vector.x += 1
		if Input.is_action_pressed("ui_left"):
			move_vector.x -= 1
		if Input.is_action_pressed("ui_down"):
			move_vector.y += 1
		if Input.is_action_pressed("ui_up"):
			move_vector.y -= 1
		
		global_position += move_vector.normalized() * move_speed * delta

		# Déplacement avec la souris (clic molette)
		if mouse_dragging:
			var mouse_delta = (get_viewport().get_mouse_position() - mouse_drag_start) * mouse_drag_sensitivity
			global_position -= mouse_delta / zoom
		
		# Détection des bords de l'écran pour le déplacement
#		var screen_mouse_pos = get_viewport().get_mouse_position()
#
#		if screen_mouse_pos.x <= edge_threshold:
#			global_position.x -= move_speed * delta
#		elif screen_mouse_pos.x >= window_size.x - edge_threshold:
#			global_position.x += move_speed * delta
#		if screen_mouse_pos.y <= edge_threshold:
#			global_position.y -= move_speed * delta
#		elif screen_mouse_pos.y >= window_size.y - edge_threshold:
#			global_position.y += move_speed * delta

# Capture des événements de la molette pour gérer le zoom
func _unhandled_input(event):
	if global.move_camera == true:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MIDDLE :  # Clic molette
				if event.is_pressed():
					mouse_dragging = true
					mouse_drag_start = get_viewport().get_mouse_position()
				else:
					mouse_dragging = false
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var new_zoom = zoom - Vector2(zoom_step, zoom_step)
				new_zoom.x = clamp(new_zoom.x, zoom_min, zoom_max)
				new_zoom.y = clamp(new_zoom.y, zoom_min, zoom_max)
				zoom = new_zoom
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var new_zoom = zoom + Vector2(zoom_step, zoom_step)
				new_zoom.x = clamp(new_zoom.x, zoom_min, zoom_max)
				new_zoom.y = clamp(new_zoom.y, zoom_min, zoom_max)
				zoom = new_zoom
