extends Control

signal updated()

@onready var item_grid : GridContainer = %ItemGrid
@export var slots_count : int = GameData.inventory_size


func _ready() -> void:
	add_to_group("UI")
	create_inventory_slots(slots_count)
	
	#charge les item que lors du 1er chargement de l'inventaire
	#Evite les duplication pour les hero qui possede une instance de l'inventaire
	if GameData.inventory_first_load:
		create_sample_inventory()
		
	load_inventory()


#cree un inventaire par defaut
func create_sample_inventory() -> void:	
	add_item(GameData.get_item("red_hat"), 1, "Slot0")
	add_item(GameData.get_item("wooden_sword"), 1, "Slot1")
	add_item(GameData.get_item("iron_sword"), 1, "Slot2")
	#add_item(GameData.get_item("iron_sword"), 3, "Slot2")
	add_item(GameData.get_item("life_potion"), 10, "Slot3")
	add_item(GameData.get_item("life_potion"), 14, "Slot4")
	add_item(GameData.get_item("mana_potion"), 7, "Slot5")
	
	GameData.inventory_first_load = false


#Cree les slots de l'inventaire
func create_inventory_slots(nb_slots : int) -> void:
	# Check if slots are already created
	if item_grid.get_child_count() > 0:
		return
	
	for i in range(nb_slots):
		const slot_instance = preload("res://Scenes/Inventory/InventorySlot/slot.tscn")
		var slot = slot_instance.instantiate()
		slot.name = "Slot" + str(i)
		slot.custom_minimum_size = Vector2(64, 64)
		slot.global_inventory = self
		item_grid.add_child(slot)
		if not GameData.inventory.has("Slot" + str(i)):
			GameData.inventory["Slot" + str(i)] = {}
		
		slot.connect("slot_click", _on_slot_click)


func _on_slot_click(item_data) -> void:
	var type = ["Default","Usable","Weapon","Jewelery","Head","Chest","Pant"]
	
	%ItemName.text = item_data.item.item_name
	%ItemCategory.text = type[item_data.item.item_type]
	%ItemDescription.text = item_data.item.item_description

#Charge les objet de la variabla inventory dans l'inventaire
func load_inventory() -> void:
	for child in item_grid.get_children():
		var data = GameData.inventory[child.name]
		child.set_slot(data)
	
		

#AJoute un objet dans le slot selectionné
func add_item(item : ItemData, quantity : int, slot : String) -> void:
	var inventory_slot = GameData.inventory[slot]

	#si le slot est vide on ajoute l'objet
	if inventory_slot.is_empty():
		inventory_slot.item = item
		inventory_slot.quantity = quantity
		
	#si le slot est deja prit parle meme objet on adapte le quantité en fonctio nde max_stack
	else:
		var new_item_stackable : bool = item.item_stackable
		var new_item_max_stack : int = item.item_max_stack
		
		#Si l'objet qu'on ajoute est stackable et le meme que celui en place
		if new_item_stackable and item == inventory_slot.item:
			var new_qty = quantity + inventory_slot.quantity
			if new_qty <= new_item_max_stack:
				inventory_slot.item = item
				inventory_slot.quantity = new_qty
			else:
				print("impossible d'ajouter l'objet (qty > max_stack)")
		else:
			print("impossible d'ajouter l'objet (objet different ou non stackable)")
	#Possibliter d'ajouter le reste dans un autre slot si qty > max_stack


#Retire un objet de l'inventaire au slot selectioné
func remove_item(slot : String) -> void:
	GameData.inventory[slot].clear()
	load_inventory()


#Tente de deplacer un item entre 2 emplacement
func move_item(from_data : Variant, to : String) -> void:
	var from_slot : Dictionary = GameData.inventory[from_data.from_slot]
	var to_slot : Dictionary = GameData.inventory[to]
	
	#Si l'emplacement de base est vide on ne fait rien
	if from_slot.is_empty():
		return
	
	#Si l'emplacement de destination n'est pas vide
	if not to_slot.is_empty():
		var to_slot_item = to_slot.item
		
		#et si l'item de destionation est le meme que celui de base , et qu'il est stackable
		if from_slot.item == to_slot_item and to_slot_item.item_stackable:
			var new_qty = from_data.quantity + to_slot.quantity
			#Si le total ne depasse pas le stack max
			if new_qty <= to_slot_item.item_max_stack:
				from_slot.quantity -= from_data.quantity
				to_slot.quantity += from_data.quantity
			else:
				var left_qty = new_qty - to_slot_item.item_max_stack
				#Exemple : max_stack = 16, max_qty = 24 -> left_qty =  24 - 16 = 8
				from_slot.quantity = left_qty
				to_slot.quantity = to_slot_item.item_max_stack
		else:
			swap_item(from_data.from_slot, to)
	else:
		from_slot.quantity -= from_data.quantity
		to_slot.item = from_slot.item
		to_slot.quantity = from_data.quantity
	
	if from_slot.quantity <= 0:
		from_slot.clear()
		
	load_inventory()


#Swap le contenue de 2 emplacement d'inventaire
func swap_item(from_slot : String, to_slot : String) -> void:
	var item_to_move = GameData.inventory[from_slot]
	var item_to_replace = GameData.inventory[to_slot]
	GameData.inventory[to_slot] = item_to_move
	GameData.inventory[from_slot] = item_to_replace


#Ouvre et ferme l'inventaire principal
func _on_open_inv_btn_pressed() -> void:
	if self.visible:
		self.visible = false
		GameData.menu_open = false
	else:
		GameData.hide_ui()
		load_inventory()
		self.visible = true
		GameData.menu_open = true
		

# Find the first empty slot of the given type
func find_first_empty_slot():
	for slot in GameData.inventory.keys():
		var data = GameData.inventory[slot]
		if data.is_empty():
			return slot
	return null
