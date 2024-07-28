extends Control

signal updated()

@onready var item_grid = $ScrollContainer/ItemGrid
@onready var global_inventory = $"."



@export var SLOTS = 25
var inventory = {}

func _ready():
	create_inventory_slots(SLOTS)
	create_sample_inventory()

	
func create_inventory_slots(nb_slots):
	for i in range(nb_slots):
		const slot_instance = preload("res://Scenes/UI/Inventory/InventorySlot/Slot.tscn")
		var slot = slot_instance.instantiate()
		slot.name = "Slot" + str(i)
		slot.custom_minimum_size = Vector2(64, 64)
		item_grid.add_child(slot)
		inventory["Slot" + str(i)] = {}

func create_sample_inventory():
	inventory.Slot0 = GameData.get_item("red_hat",1)
	inventory.Slot1 = GameData.get_item("wooden_sword",1)
	inventory.Slot2 = GameData.get_item("iron_sword",1)
	inventory.Slot3 = GameData.get_item("iron_sword",1)
	inventory.Slot4 = GameData.get_item("life_potion",7)
	load_inventory()

func load_inventory():
	for child in item_grid.get_children():
		var data = inventory[child.name]
		child.set_slot(data)
	
func add_item(item_name, quantity):
	var item_added = false
	for slot in inventory:
		if inventory[slot].get("item_name") == item_name and GameData.get_stackable(item_name):
			var potential_new_quantity = inventory[slot].quantity + quantity
			var max_stack = GameData.max_stack(item_name)
			if potential_new_quantity <= max_stack:
				inventory[slot].quantity = potential_new_quantity
				item_added = true
				break
			else:
				quantity = potential_new_quantity - max_stack
				inventory[slot].quantity = max_stack
	# Find first empty slot if item not fully added
	if not item_added or quantity > 0:
		for slot in inventory:
			if inventory[slot].is_empty() or inventory[slot].get("item_name", "") == "":
				inventory[slot] = {
					"item_name": item_name,
					"quantity": min(quantity, GameData.max_stack(item_name)),
					"type": GameData.get_item_type(item_name)
				}
				quantity -= inventory[slot].quantity
				if quantity <= 0:
					break
	load_inventory()
	
func remove_item(slot, quantity):
	inventory[slot].quantity -= quantity
	if inventory[slot].quantity <= 0:
		inventory[slot] = {}
	load_inventory()
	
func move_item(data, to_slot):
	var quantity = data.quantity
	var from_slot = data.from_slot
	var from_slot_type = data.dragged.slot_type

	if from_slot_type == 0: #si on bouge depuis un equipement slot
		var item = inventory[from_slot]
		if inventory[to_slot].is_empty():
			inventory[to_slot] = {
				"item_name" : item.item_name,
				"quantity" : quantity
			}
			inventory[from_slot].quantity -= quantity
		elif inventory[to_slot].item_name == item.item_name:
			if GameData.get_stackable(item.item_name):
				inventory[to_slot].quantity += quantity
				inventory[from_slot].quantity -= quantity
		else:
			swap_item(from_slot,to_slot)
			
		if inventory[from_slot].quantity <= 0:
			inventory[from_slot].clear()
	else:
		pass
	load_inventory()
	
	
func swap_item(from_slot, to_slot):
	var item_to_move = inventory[from_slot]
	var item_to_replace = inventory[to_slot]
	inventory[to_slot] = item_to_move
	inventory[from_slot] = item_to_replace
	
func _on_area_2d_mouse_entered():
	global.move_camera = false

func _on_area_2d_mouse_exited():
	global.move_camera = true





func _on_open_inv_btn_pressed():
	global_inventory.visible = !global_inventory.visible
