extends PanelContainer

@onready var name_label = %Name
@onready var size_label = %SizeMini
@onready var contained_label = %NeedObjectsContainer

var zone_data = null

func _ready() -> void:
	add_to_group("UI")


func open_with_zone(zone: Dictionary, type_data: Resource) -> void:
	zone_data = zone
	show()

	# Nom
	name_label.text = "Name : %s" % zone.name.capitalize()

	# Taille 
	var bounds = get_zone_bounds(zone.tiles)
	var actual_size = Vector2i(bounds.size.x, bounds.size.y)
	
	if actual_size < type_data.min_size:
		size_label.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		size_label.add_theme_color_override("font_color", Color(0, 1, 0))
	size_label.text = "Size : %dx%d" % [type_data.min_size.x, type_data.min_size.y]


	# Objets présents
	var present := get_present_objects(zone.tiles)

	
	#On reset la liste
	var children = contained_label.get_children()
	for child in children:
		child.free()
	
	for object in type_data.required_objects:
		var obj_label = Label.new()
		obj_label.text = object
		
		if object in present:
			obj_label.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			obj_label.add_theme_color_override("font_color", Color(1, 0, 0))

		contained_label.add_child(obj_label)


func close() -> void:
	self.hide()


func get_zone_bounds(tiles: Array) -> Rect2:
	var min_x = tiles[0].x
	var max_x = tiles[0].x
	var min_y = tiles[0].y
	var max_y = tiles[0].y

	for t in tiles:
		min_x = min(min_x, t.x)
		max_x = max(max_x, t.x)
		min_y = min(min_y, t.y)
		max_y = max(max_y, t.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x + 1, max_y - min_y + 1))


func get_present_objects(tiles: Array) -> Array:
	var found := []
	var construction_logic = get_tree().get_root().get_node("Main/ConstructionLogic")
	var object_layer = get_tree().get_root().get_node("Main/Level/Object")

	for t in tiles:
		if construction_logic.occupied_objects.has(t):
			var origin = construction_logic.occupied_objects[t]["origin"]
			for obj in object_layer.get_children():
				if obj is Node2D and floor(obj.global_position / construction_logic.grid_size) == origin:
					found.append(obj.node_name)
	return found
