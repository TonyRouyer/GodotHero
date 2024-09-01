extends Camera2D

@export var zoomSpeed : float = 10;

var zoomTarget :Vector2

var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging : bool = false

# Limites de zoom
@export var zoomMin : float = 0.9
@export var zoomMax : float = 3.0

func _ready():
	#Initie le zoom
	zoom =  Vector2(2, 2)
	zoomTarget = zoom
	# Centrer la caméra au démarrage
	global_position = Vector2(550, 350)

func _process(delta):
	if not Global.mouse_in_menu:
		Zoom(delta)
		SimplePan(delta)
		ClickAndDrag()
	
func Zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
		
	# Limiter les valeurs de zoomTarget
	zoomTarget.x = clamp(zoomTarget.x, zoomMin, zoomMax)
	zoomTarget.y = clamp(zoomTarget.y, zoomMin, zoomMax)
	
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	
func SimplePan(delta):
	var moveAmount = Vector2.ZERO
	if Input.is_action_pressed("camera_move_right"):
		moveAmount.x += 1
		
	if Input.is_action_pressed("camera_move_left"):
		moveAmount.x -= 1
		
	if Input.is_action_pressed("camera_move_up"):
		moveAmount.y -= 1
		
	if Input.is_action_pressed("camera_move_down"):
		moveAmount.y += 1
		
	moveAmount = moveAmount.normalized()
	position += moveAmount * delta * 1000 * (1/zoom.x)
	
func ClickAndDrag():
	if !isDragging and Input.is_action_just_pressed("camera_pan"):
		dragStartMousePos = get_viewport().get_mouse_position()
		dragStartCameraPos = position
		isDragging = true
		
	if isDragging and Input.is_action_just_released("camera_pan"):
		isDragging = false
		
	if isDragging:
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * 1/zoom.x	
		
