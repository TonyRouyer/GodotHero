extends Node2D

@onready var equipement_container : Control = $"../CanvasLayer/HeroPanelInfo/HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi/HeroEquipementUi"
@onready var global_inventory_node : Control = $"../CanvasLayer/HeroPanelInfo/HBoxContainer/GlobalInventory"
@onready var parent = get_parent()
var equipment : Dictionary = {}


func _ready() -> void:
	for i in range(equipement_container.get_children().size()):
		equipment["EquipementSlot" + str(i)] = {}
	#global_inventory_node.load_inventory()


func load_equipment() -> void:
	for child in equipement_container.get_children():
		var data = equipment[child.name]
		child.set_slot(data)


# Equip and item removing it from the inventory slot and add it to the equipment slot
func equip_item(from_slot : String, equip_slot : String, item : Dictionary, from_inventory: bool = true) -> void:
	#print("hero inventory equip_item ", item)
	if from_inventory:
		if equipment[equip_slot].is_empty():
			# Si on ajoute une nouveau equipement depuis l'inventaire
			equipment[equip_slot] = item.duplicate()
			GameData.inventory[from_slot].clear()
			parent.apply_equipment_attributes(item)
		else:
			# si l'on veux swap un equipement deja present depuis l'inventaire
			var equipped_item = equipment[equip_slot].duplicate()
			parent.apply_equipment_attributes(equipment[equip_slot], true)
			equipment[equip_slot] = item.duplicate()
			GameData.inventory[from_slot] = equipped_item
			parent.apply_equipment_attributes(item)
	else:
		if equipment[equip_slot].is_empty():
			# Si on equipe depuis les equipement dans une case vide
			equipment[equip_slot] = item.duplicate()
			parent.apply_equipment_attributes(item)
			equipment[from_slot].clear()
		else:
			# si on swap 2 equipement du meme type
			var equipped_item = equipment[equip_slot].duplicate()
			parent.apply_equipment_attributes(equipment[equip_slot], true)
			equipment[equip_slot] = item.duplicate()
			equipment[from_slot] = equipped_item
			parent.apply_equipment_attributes(item)
			
	load_equipment()
	global_inventory_node.load_inventory()


# Remove item from equipment slot and put it in inventory
func unequip_item(from_slot : String, equip_slot : String, item : Dictionary):
	if GameData.inventory[equip_slot].is_empty():
		# Si de equipe un equipement vers une case vide de l'inventaire
		GameData.inventory[equip_slot] = item.duplicate()
		equipment[from_slot].clear()
		parent.apply_equipment_attributes(item, true)
	else:
		# Si de equipe un equipement vers une case deja occuper de l'inventaire
		var inventory_slot = GameData.inventory[equip_slot].duplicate()
		GameData.inventory[equip_slot] = equipment[from_slot].duplicate()
		equipment[from_slot] = inventory_slot
		parent.apply_equipment_attributes(inventory_slot, true)
		parent.apply_equipment_attributes(GameData.inventory[equip_slot])

	load_equipment()
	global_inventory_node.load_inventory()


# Find the first empty slot of the given type
func find_first_empty_slot(item_type : int):
	for slot in equipment.keys():
		if equipment[slot].is_empty() and get_node("../CanvasLayer/HeroPanelInfo/HBoxContainer/StatsWindow/VBoxContainer/ContentContainer/VBoxContainer/HeroEquipementUi/HeroEquipementUi/" + str(slot)).slot_type == item_type:
			return slot
	return null
