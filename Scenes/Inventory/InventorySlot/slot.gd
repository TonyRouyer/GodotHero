class_name InventorySlot
extends TextureRect

signal slot_click(item_data)

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

@export var slot_type : Type = Type.DEFAULT
@onready var icon : Sprite2D = $Icon
@onready var quantity : Label = $Quantity

var global_inventory : Control


#setup the slot data
func set_slot(data: Dictionary) -> void:
	quantity.hide()
	if data.is_empty():
		tooltip_text = ""
		icon.texture = null
		return
	var item_data = data.item
	var item_quantity = data.quantity
	tooltip_text = item_data.item_name
	icon.texture = item_data.item_icon
	quantity.text = "%2d" % item_quantity
	if item_quantity > 1:
		quantity.show()


#begin of a drag from this slot generate data needed
func _get_drag_data(_at_position: Vector2) -> Variant:
	if GameData.inventory[name].is_empty():
		return
	var prev = Control.new()
	var picon = Sprite2D.new()
	picon.position -= Vector2(32,32)
	picon.z_index = 2
	picon.texture = icon.texture
	picon.region_enabled = true
	picon.region_rect = icon.region_rect
	#picon.scale = Vector2(2,2)
	picon.position = Vector2(16,16)
	prev.add_child(picon)
	set_drag_preview(prev)
	modulate = Color(1,1,1,0.5)
	var data = GameData.inventory[name].duplicate()
	if Input.is_action_pressed("shift"):
		if data.quantity > 1:
			data.quantity = round(data.quantity/2)
	elif Input.is_action_pressed("control"):
		data.quantity = 1
	data.from_slot = name
	data.dragged = self
	return data


#check if data can be dropped on this slot
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true


#drop the data on this slot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var to_node = name
	
	if data.dragged.slot_type == 0: 
		#si drop dans l'inventaire
		global_inventory.move_item(data,to_node) 
		update_hero_inventory_slot()
	else: 
		#si drop dans un slot equipement
		var hero_node = GameData.get_active_hero().get_node("HeroInventorySystem")
		hero_node.unequip_item(data.from_slot,name, data)


#end of a drag
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate = Color(1,1,1,1)


 #Handle double click to equip item
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click  and not GameData.inventory[name].is_empty():
		equip_item_double_click()
		
	if event is InputEventMouseButton and event.pressed  and not GameData.inventory[name].is_empty():
		emit_signal("slot_click", GameData.inventory[name])
	


func equip_item_double_click() -> void:
	var item = GameData.inventory[name]
	var item_type = item.item.item_type

	var select_hero = GameData.get_active_hero()
	if select_hero != null:
		var hero_node = select_hero.get_node("HeroInventorySystem")
		var equip_slot = hero_node.find_first_empty_slot(item_type)
		if equip_slot:
			hero_node.equip_item(name, equip_slot, item, true)

func update_hero_inventory_slot() -> void:
	var select_hero = GameData.get_active_hero()
	if select_hero != null:
		var hero_node = select_hero.get_node("HeroInventorySystem")
		hero_node.update_hero_inventory()

	
