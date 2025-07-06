extends Node2D

@onready var hero: Hero = get_parent()
@onready var global_inventory_node : Control = get_tree().get_root().get_node("Main/UICanvasLayer/Menu/GlobalInventory")

var slots: Array = []
var equipment : Dictionary = {}


func load_equipment() -> void:
	for child in slots:
		var data = equipment[child.name]
		child.set_slot(data)


# Equip and item removing it from the inventory slot and add it to the equipment slot
func equip_item(from_slot : String, equip_slot : String, item : Dictionary, from_inventory: bool = true) -> void:
	if from_inventory:
		if equipment[equip_slot].is_empty():
			# Si on ajoute une nouveau equipement depuis l'inventaire
			equipment[equip_slot] = item.duplicate()
			equipment[equip_slot].quantity = 1
			var equipped_item = equipment[equip_slot]
			if GameData.inventory[from_slot].quantity > 1:
				GameData.inventory[from_slot].quantity -= 1
			else:
				GameData.inventory[from_slot].clear()
				
			hero.apply_equipment_attributes(equipped_item, true)
		else:
			var equipped_item = equipment[equip_slot].duplicate() # 1. on copie l'item actuelement equipé

			if GameData.inventory[from_slot].quantity > 1:
				var next_free_slot = global_inventory_node.find_first_empty_slot()
				if next_free_slot != null:
					GameData.inventory[from_slot].quantity -= 1 # 2. on soutrait 1 a la qty en inventaire
					GameData.inventory[next_free_slot] = equipment[equip_slot].duplicate() # 3. on ajoute l'item equiper dans le 1er enplacement libre de l'inventaire
					equipment[equip_slot] = item.duplicate() # 4. On remplace l'item equipé par le nouvelle
					equipment[equip_slot].quantity = 1
			else:
				# swap
				equipment[equip_slot] = item.duplicate() # 2. On remplace l'item equipé par le nouvelle
				equipment[equip_slot].quantity = 1
				GameData.inventory[from_slot] = equipped_item # 3. On remplace le slot d'inventaire par l'item sauvegardé
			
			var item_to_remove_stats = GameData.inventory[from_slot]
			var item_to_add_stats = equipment[equip_slot]
			hero.apply_equipment_attributes(item_to_remove_stats, false) # on soustrait les stats de l'item equiper
			hero.apply_equipment_attributes(item_to_add_stats, true) # et on ajouter celle du nouveau
	else:
		#Note si on ajoute un item depuis un objet deja equiper , on n'a pas besoin de re attribuer les stats
		if equipment[equip_slot].is_empty():
			# Si on equipe depuis les equipement dans une case vide
			equipment[equip_slot] = item.duplicate()
			equipment[from_slot].clear()
		else:
			# si on swap 2 equipement du meme type
			var equipped_item = equipment[equip_slot].duplicate()
			equipment[equip_slot] = item.duplicate()
			equipment[from_slot] = equipped_item
			
	load_equipment()
	global_inventory_node.load_inventory()
	update_hero_inventory()
	
	
func update_hero_inventory() -> void:
	var inv_container = hero.hero_panel_info.inv_container
	for child in inv_container.get_children():
		var data = GameData.inventory[child.name]
		child.set_slot(data)


# Remove item from equipment slot and put it in inventory
func unequip_item(from_slot : String, equip_slot : String, item : Dictionary):
	if GameData.inventory[equip_slot].is_empty():
		# Si de equipe un equipement vers une case vide de l'inventaire
		GameData.inventory[equip_slot] = item.duplicate()
		equipment[from_slot].clear()
		var equipped_item = GameData.inventory[equip_slot]
		hero.apply_equipment_attributes(equipped_item, false)
	else:
		#Si l'objet est le meme que celuis desequipé
		if equipment[from_slot].item == GameData.inventory[equip_slot].item:
			var potential_total_qty = 1 + GameData.inventory[equip_slot].quantity
			#et si le total ne depasse pas max_stack
			if potential_total_qty <= GameData.inventory[equip_slot].item.item_max_stack:
				GameData.inventory[equip_slot].quantity += 1
				equipment[from_slot].clear()
				var equipped_item = GameData.inventory[equip_slot]
				hero.apply_equipment_attributes(equipped_item, false)
				
	load_equipment()
	global_inventory_node.load_inventory()
	update_hero_inventory()

# Find the first empty slot of the given type
func find_first_empty_slot(item_type : int):
	#Trouve le 1er slot vide du meme type	
	for slot in slots:
		var data = slot.get_node("Icon")
				
		if data.texture == null and  slot.slot_type == item_type:
			return slot.name
			
			
	#retourne le 1er slot du type demander / sinon nul
	for slot in slots:
		if slot.slot_type == item_type:
			return slot.name
	
	return null


#Cree les slots de l'inventaire
func create_inventory_slots(inv_container: GridContainer, nb_slots : int) -> void:
	# Check if slots are already created
	if  inv_container.get_child_count() > 0:
		return
	
	for i in range(nb_slots):
		const slot_instance = preload("res://Scenes/Inventory/InventorySlot/slot.tscn")
		var slot = slot_instance.instantiate()
		slot.name = "Slot" + str(i)
		slot.custom_minimum_size = Vector2(64, 64)
		slot.global_inventory = global_inventory_node
		inv_container.add_child(slot)
		if not GameData.inventory.has("Slot" + str(i)):
			GameData.inventory["Slot" + str(i)] = {}
