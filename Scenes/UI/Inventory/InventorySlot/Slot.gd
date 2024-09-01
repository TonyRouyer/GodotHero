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
@onready var quantity = $Quantity
@onready var global_inventory = get_node("../../..")


#setup the slot data
func set_slot(data:Dictionary):
	quantity.hide()
	if data.is_empty():
		tooltip_text = ""
		icon.texture = null
		return
	tooltip_text = GameData.get_item_name(data.item_name)

	icon.texture = load("res://Sprites/items/items_transparent_drop_shadow.png")
	icon.region_enabled = true
	icon.region_rect = get_item_texture(data.item_name)
	icon.scale = Vector2(2,2)
	icon.position = Vector2(32,32)
	
	quantity.text = "%2d" % data.quantity
	if data.quantity > 1:
		quantity.show()
		
#begin of a drag from this slot generate data needed
func _get_drag_data(_at_position: Vector2) -> Variant:
	if Global.inventory[name].is_empty():
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
	var data = Global.inventory[name].duplicate()
	if Input.is_action_pressed("shift"):
		if data.quantity > 1:
			data.quantity = round(data.quantity/2)
	elif Input.is_action_pressed("control"):
		data.quantity = 1
	
	data.from_slot = name
	data.dragged = self
	
		# Add attack and defense if they exist
	if "attack" in  GameData.get_item_data(data.item_name):
		data.attack = GameData.get_item_data(data.item_name)["attack"]
	if "defense" in GameData.get_item_data(data.item_name):
		data.defense = GameData.get_item_data(data.item_name)["defense"]
		
	return data

#check if data can be dropped on this slot
#useful for equipment i.e swords can only go in weapon slot
#just returning true here
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
#drop the data on this slot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.dragged.slot_type == 0: 
		#si drop dans l'inventaire
		global_inventory.move_item(data,name) 
	else: 
		#si drop dans un slot equipement
		var hero_node = GameData.get_active_hero().get_node("HeroInventorySystem")
		hero_node.unequip_item(data.from_slot,name, data)
		
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
	if event is InputEventMouseButton and event.double_click  and not Global.inventory[name].is_empty():
		equip_item_double_click()

func equip_item_double_click():
	var item = Global.inventory[name]
	var item_type = GameData.get_item_type(item.item_name)
	var hero_node = GameData.get_active_hero().get_node("HeroInventorySystem")
	var equip_slot = hero_node.find_first_empty_slot(item_type)
	if equip_slot:
		hero_node.equip_item(name, equip_slot, item, true)
