class_name EquipementSlot
extends TextureRect

enum Type{
	DEFAULT,
	USABLE,
	WEAPON,
	JEWELRY,
	HEAD,
	CHEST,
	PANTS,
	FEET
}

@export var slot_type:Type = Type.DEFAULT
@onready var icon : Sprite2D = $Icon
@onready var root_hero_node : Node2D = get_node("../../../../../../../../../../../HeroInventorySystem")


#setup the slot data
func set_slot(data:Dictionary) -> void:
	if data.is_empty():
		tooltip_text = ""
		icon.texture = null
		return
	var item_data = data.item
	tooltip_text = item_data.item_name
	icon.texture = item_data.item_icon


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
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var item = GameData.get_item(data.item.item_name_serialised)
	if item.item_type == slot_type:
		return true
	return false


#drop the data on this slot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if slot_type != data.dragged.slot_type: #depuis l'inventaire
		root_hero_node.equip_item(data.from_slot,name,data) 
	else: #depuis l'equipement
		root_hero_node.equip_item(data.from_slot,name,data, false)


#end of a drag
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate = Color(1,1,1,1)


 #Handle double click to equip item
func _gui_input(event: InputEvent) -> void:
	var equipedContent = root_hero_node.equipment[name]
	if event is InputEventMouseButton and event.double_click and not equipedContent.is_empty():
		desequip_item_double_click()


func desequip_item_double_click() -> void:
	var item = root_hero_node.equipment[name]
	var select_hero = GameData.get_active_hero()

	if select_hero != null:
		var inventory = get_tree().get_first_node_in_group('inventory')
		var hero_node = select_hero.get_node("HeroInventorySystem")
		var equip_slot = inventory.find_first_empty_slot()
		if equip_slot:
			hero_node.unequip_item(name, equip_slot , item)
