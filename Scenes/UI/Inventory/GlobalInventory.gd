extends Control

signal updated()

@onready var item_grid = $ScrollContainer/ItemGrid
@onready var global_inventory = $"."

@export var SLOTS = 25

func _ready():
	# Initialize global inventory if it's empty
	if global.inventory.is_empty():
		create_inventory_slots(SLOTS)
		create_sample_inventory()
	else:
		create_inventory_slots(SLOTS)  # Just create the slots, no need to populate
		load_inventory()

func create_inventory_slots(nb_slots):
	# Check if slots are already created
	if item_grid.get_child_count() > 0:
		return
	
	for i in range(nb_slots):
		const slot_instance = preload("res://Scenes/UI/Inventory/InventorySlot/Slot.tscn")
		var slot = slot_instance.instantiate()
		slot.name = "Slot" + str(i)
		slot.custom_minimum_size = Vector2(64, 64)
		item_grid.add_child(slot)
		if not global.inventory.has("Slot" + str(i)):
			global.inventory["Slot" + str(i)] = {}

func create_sample_inventory():
	# Check if inventory already has items
	if not global.inventory["Slot0"].is_empty():
		load_inventory()
		return
	
	global.inventory["Slot0"] = GameData.get_item("red_hat", 1)
	global.inventory["Slot1"] = GameData.get_item("wooden_sword", 1)
	global.inventory["Slot2"] = GameData.get_item("iron_sword", 1)
	global.inventory["Slot3"] = GameData.get_item("iron_sword", 1)
	global.inventory["Slot4"] = GameData.get_item("life_potion", 7)
	load_inventory()

func load_inventory():
	for child in item_grid.get_children():
		var data = global.inventory[child.name]
		child.set_slot(data)

func add_item(item_name, quantity):
	var item_added = false
	for slot in global.inventory:
		if global.inventory[slot].get("item_name") == item_name and GameData.get_stackable(item_name):
			var potential_new_quantity = global.inventory[slot].quantity + quantity
			var max_stack = GameData.max_stack(item_name)
			if potential_new_quantity <= max_stack:
				global.inventory[slot].quantity = potential_new_quantity
				item_added = true
				break
			else:
				quantity = potential_new_quantity - max_stack
				global.inventory[slot].quantity = max_stack
	# Find first empty slot if item not fully added
	if not item_added or quantity > 0:
		for slot in global.inventory:
			if global.inventory[slot].is_empty() or global.inventory[slot].get("item_name", "") == "":
				global.inventory[slot] = {
					"item_name": item_name,
					"quantity": min(quantity, GameData.max_stack(item_name)),
					"type": GameData.get_item_type(item_name)
				}
				quantity -= global.inventory[slot].quantity
				if quantity <= 0:
					break
	load_inventory()

func remove_item(slot, quantity):
	global.inventory[slot].quantity -= quantity
	if global.inventory[slot].quantity <= 0:
		global.inventory[slot] = {}
	load_inventory()

func move_item(data, to_slot):
	var quantity = data.quantity
	var from_slot = data.from_slot
	var from_slot_type = data.dragged.slot_type

	if from_slot_type == 0: #si on bouge depuis un equipement slot
		var item = global.inventory[from_slot]
		if global.inventory[to_slot].is_empty():
			global.inventory[to_slot] = {
				"item_name" : item.item_name,
				"quantity" : quantity
			}
			global.inventory[from_slot].quantity -= quantity
		elif global.inventory[to_slot].item_name == item.item_name:
			if GameData.get_stackable(item.item_name):
				global.inventory[to_slot].quantity += quantity
				global.inventory[from_slot].quantity -= quantity
		else:
			swap_item(from_slot, to_slot)

		if global.inventory[from_slot].quantity <= 0:
			global.inventory[from_slot].clear()
	else:
		pass
	load_inventory()

func swap_item(from_slot, to_slot):
	var item_to_move = global.inventory[from_slot]
	var item_to_replace = global.inventory[to_slot]
	global.inventory[to_slot] = item_to_move
	global.inventory[from_slot] = item_to_replace

func _on_area_2d_mouse_entered():
	global.move_camera = false

func _on_area_2d_mouse_exited():
	global.move_camera = true

func _on_open_inv_btn_pressed():
	load_inventory()
	global_inventory.visible = !global_inventory.visible

# Find the first empty slot of the given type
func find_first_empty_slot():
	for slot in global.inventory.keys():
		if global.inventory[slot].is_empty():
			return slot
	return null
