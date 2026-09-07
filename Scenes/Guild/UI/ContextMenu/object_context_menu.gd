## object_context_menu.gd
## Menu contextuel pour les objets posés dans la guilde.
## Créé programmatiquement, sans scène .tscn associée.
## Usage : show_for(object_node, screen_position)
extends PanelContainer
class_name ObjectContextMenu


signal move_pressed(object_node: Node2D)
signal sell_pressed(object_node: Node2D)
signal farm_pressed(object_node: Node2D)


var _target       : Node2D = null
var _title_label  : Label  = null
var _move_button  : Button = null
var _sell_button  : Button = null
var _farm_button  : Button = null


func _ready() -> void:
	var vbox : VBoxContainer = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(150.0, 0.0)
	add_child(vbox)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_title_label)

	var sep : HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_move_button = Button.new()
	_move_button.text = "Déplacer"
	_move_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_move_button.pressed.connect(_on_move_pressed)
	vbox.add_child(_move_button)

	_sell_button = Button.new()
	_sell_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_sell_button.pressed.connect(_on_sell_pressed)
	vbox.add_child(_sell_button)

	_farm_button = Button.new()
	_farm_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_farm_button.pressed.connect(_on_farm_pressed)
	vbox.add_child(_farm_button)

	z_index = 100
	hide()


func show_for(object_node: Node2D, screen_pos: Vector2) -> void:
	_target = object_node
	var item_data : Dictionary = {}
	if object_node.has_method("get_item_data"):
		item_data = object_node.get_item_data()
	var label    : String = item_data.get("label", "Objet")
	var cost     : int    = item_data.get("cost",  0)
	var sell_val : int    = int(cost * 0.5)

	_title_label.text = label
	_sell_button.text = "Vendre (%d or)" % sell_val

	## Bouton farming : visible uniquement pour les planting_beds
	var is_bed : bool = (object_node is GuildObject) and \
		(object_node as GuildObject).object_id == "planting_beds"
	_farm_button.visible = is_bed
	if is_bed:
		var origin : Vector2i = (object_node as GuildObject).get_origin()
		if FarmingManager.is_ready(origin):
			_farm_button.text = "Récolter"
			_farm_button.disabled = false
		elif FarmingManager.is_planted(origin):
			var progress : float = FarmingManager.get_growth_progress(origin)
			_farm_button.text = "En croissance... (%d%%)" % int(progress * 100.0)
			_farm_button.disabled = true
		else:
			_farm_button.text = "Planter"
			_farm_button.disabled = false

	position = screen_pos
	show()
	call_deferred("_clamp_to_viewport")


func hide_menu() -> void:
	_target = null
	hide()


func _clamp_to_viewport() -> void:
	var vp_size : Vector2 = get_viewport_rect().size
	position.x = clamp(position.x, 0.0, vp_size.x - size.x)
	position.y = clamp(position.y, 0.0, vp_size.y - size.y)


## Ferme le menu si le clic est hors de sa zone.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventMouseButton:
		return
	if not (event as InputEventMouseButton).pressed:
		return
	if not Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
		hide_menu()
		get_viewport().set_input_as_handled()


func _on_move_pressed() -> void:
	var target : Node2D = _target
	hide_menu()
	move_pressed.emit(target)


func _on_sell_pressed() -> void:
	var target : Node2D = _target
	hide_menu()
	sell_pressed.emit(target)


func _on_farm_pressed() -> void:
	var target : Node2D = _target
	hide_menu()
	farm_pressed.emit(target)
