extends TextureRect

enum Type{
	Default,
	Head,
	Hand,
	Weapon,
	Chest,
	Pants,
	Feet
}
@export var slot_type:Type = Type.Default
@onready var icon = $Icon
@onready var root_hero_node = get_node("../../..")
@onready var inventory_node = get_node("../../../GlobalInventory")

#setup the slot data
func set_slot(data:Dictionary):
	if data.is_empty():
		tooltip_text = ""
		icon.texture = null
		return
	tooltip_text = GameData.get_item_name(data.item_name)
	icon.texture = load("res://Sprites/items/items_transparent_drop_shadow.png")
	icon.region_enabled = true
	icon.region_rect = get_item_texture(data.item_name)
	icon.position = Vector2(16,16)
	
#begin of a drag from this slot generate data needed
func _get_drag_data(_at_position: Vector2) -> Variant:
	if root_hero_node.equipment[name].is_empty():
		return
	var prev = Control.new()
	var picon = Sprite2D.new()
	picon.position -= Vector2(16,16)
	picon.texture = icon.texture
	picon.region_enabled = true
	picon.region_rect = icon.region_rect
	prev.add_child(picon)
	set_drag_preview(prev)
	modulate = Color(1,1,1,0.5)
	var data = root_hero_node.equipment[name].duplicate()	
	data.from_slot = name
	data.dragged = self
	return data

#check if data can be dropped on this slot
#useful for equipment i.e swords can only go in weapon slot
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if GameData.get_item_type(data.item_name) == slot_type:
		return true
	return false
	
#drop the data on this slot
#make all changes here 
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if slot_type != data.dragged.slot_type: #depuis l'inventaire
		root_hero_node.equip_item(data.from_slot,name,data) 
	else: #depuis l'equipement
		root_hero_node.equip_item(data.from_slot,name,data, false)
		
#end of a drag
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate = Color(1,1,1,1)

func get_item_texture(item_name: String):
	var icon_path = GameData.get_icon_path(item_name)
	if icon_path:
		var coords = icon_path.split(",")
		var x = int(coords[0])
		var y = int(coords[1])
		var w = int(coords[2])
		var h = int(coords[3])
		var region = Rect2(x, y, w, h)
		return region

# Handle double click to equip item
func _gui_input(event):
	if event is InputEventMouseButton and event.double_click  and not root_hero_node.equipment[name].is_empty():
		desequip_item_double_click()

func desequip_item_double_click():
	var item = root_hero_node.equipment[name]
	var equip_slot = inventory_node.find_first_empty_slot()
	if equip_slot:
		root_hero_node.unequip_item(name, equip_slot, item)
