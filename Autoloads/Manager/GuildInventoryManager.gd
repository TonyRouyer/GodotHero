## GuildInventoryManager — Autoload
## Inventaire de la guilde : items équipables et consommables.
## Distinct de GameData.inventory (ressources globales : or, repas).
##
## Chaque slot est null (vide) ou {"item_id": String, "quantity": int}.
extends Node


signal inventory_changed


const MAX_SLOTS : int = 30


var slots : Array = []


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	slots.resize(MAX_SLOTS)
	for i in MAX_SLOTS:
		slots[i] = null

	## Inventaire de départ
	## ── Armes (une par type)
	add_item("epee_rouille",      1)
	add_item("hache_fer",         1)
	add_item("dague_silex",       1)
	add_item("arc_bois",          1)
	add_item("baton_novice",      1)
	add_item("lance_fer",         1)
	## ── Armures torse
	add_item("tunique_tissu",     1)  ## légère
	add_item("armure_cuir",       1)  ## moyenne
	add_item("cotte_fer",         1)  ## lourde
	## ── Armures tête
	add_item("capuche_tissu",     1)  ## légère
	add_item("coiffe_cuir",       1)  ## moyenne
	add_item("couvre_chef_fer",   1)  ## lourde
	## ── Armures jambes
	add_item("pantalon_tissu",    1)  ## légère
	add_item("pantalon_cuir_m",   1)  ## moyenne
	add_item("jambiere_fer",      1)  ## lourde
	## ── Accessoires
	add_item("anneau_cuivre",     1)
	add_item("amulette_bois",     1)
	add_item("ceinture_cuir",     1)
	## ── Consommables
	add_item("potion_soin_mineure",  5)
	add_item("potion_soin",          3)
	add_item("potion_mana_mineure",  4)
	add_item("potion_force",         2)
	add_item("antidote",             3)


# ─────────────────────────────────────────────
#  AJOUT
# ─────────────────────────────────────────────
## Ajoute `quantity` items dans l'inventaire.
## Cherche d'abord dans MaterialLibrary, puis dans EquipmentLibrary.
## Remplit d'abord les stacks existants, puis les slots vides.
## Retourne false si l'inventaire est plein avant la fin.
func add_item(item_id: String, quantity: int = 1) -> bool:
	var stackable : bool = false
	var max_stack : int  = 1

	var mat : Dictionary = MaterialLibrary.get_material(item_id)
	if not mat.is_empty():
		stackable = true
		max_stack = 99
	else:
		## Fallback : vérifie EquipmentLibrary (armes, armures, accessoires, potions)
		var eq_item : Dictionary = EquipmentLibrary.get_item(item_id)
		if eq_item.is_empty():
			push_warning("GuildInventoryManager: item inconnu « %s », ignoré" % item_id)
			return false
		## Les consommables se stackent, les autres équipements non
		if eq_item.get("type", "") == "consumable":
			stackable = true
			max_stack = 99

	var remaining : int = quantity

	## Remplissage des stacks existants (stackable uniquement)
	if stackable:
		for i in MAX_SLOTS:
			if slots[i] == null or slots[i]["item_id"] != item_id:
				continue
			var space : int = max_stack - slots[i]["quantity"]
			var add   : int = mini(space, remaining)
			slots[i]["quantity"] += add
			remaining -= add
			if remaining <= 0:
				break

	## Slots vides pour le reste
	while remaining > 0:
		var empty : int = _find_empty_slot()
		if empty < 0:
			inventory_changed.emit()
			return false
		var add : int = mini(max_stack, remaining)
		slots[empty] = {"item_id": item_id, "quantity": add}
		remaining -= add

	inventory_changed.emit()
	return true


# ─────────────────────────────────────────────
#  RETRAIT
# ─────────────────────────────────────────────
func remove_from_slot(slot_idx: int, quantity: int = 1) -> bool:
	if slot_idx < 0 or slot_idx >= MAX_SLOTS or slots[slot_idx] == null:
		return false
	slots[slot_idx]["quantity"] -= quantity
	if slots[slot_idx]["quantity"] <= 0:
		slots[slot_idx] = null
	inventory_changed.emit()
	return true


# ─────────────────────────────────────────────
#  DÉPLACEMENT
# ─────────────────────────────────────────────
## Déplace ou fusionne le slot `from` vers le slot `to`.
func move_item(from_idx: int, to_idx: int) -> void:
	if from_idx == to_idx or from_idx < 0 or to_idx < 0:
		return
	if from_idx >= MAX_SLOTS or to_idx >= MAX_SLOTS:
		return

	var src = slots[from_idx]
	var dst = slots[to_idx]

	## Fusion si même item stackable
	if src != null and dst != null and src["item_id"] == dst["item_id"]:
		if _is_stackable(src["item_id"]):
			var space : int = _get_max_stack(src["item_id"]) - dst["quantity"]
			var move  : int = mini(space, src["quantity"])
			dst["quantity"]  += move
			src["quantity"]  -= move
			if src["quantity"] <= 0:
				slots[from_idx] = null
			inventory_changed.emit()
			return

	## Swap simple
	slots[from_idx] = dst
	slots[to_idx]   = src
	inventory_changed.emit()


## Déplace la moitié du stack `from` vers `to`.
## Si l'item n'est pas stackable, effectue un swap complet.
func move_half(from_idx: int, to_idx: int) -> void:
	if from_idx == to_idx or from_idx < 0 or to_idx < 0:
		return
	var src = slots[from_idx]
	if src == null:
		return
	if not _is_stackable(src["item_id"]):
		move_item(from_idx, to_idx)
		return

	var half : int = max(1, src["quantity"] / 2)
	var dst         = slots[to_idx]

	if dst == null:
		slots[to_idx] = {"item_id": src["item_id"], "quantity": half}
		src["quantity"] -= half
		if src["quantity"] <= 0:
			slots[from_idx] = null
	elif dst["item_id"] == src["item_id"]:
		var space : int = _get_max_stack(src["item_id"]) - dst["quantity"]
		var move  : int = mini(half, space)
		dst["quantity"] += move
		src["quantity"] -= move
		if src["quantity"] <= 0:
			slots[from_idx] = null
	else:
		move_item(from_idx, to_idx)
		return

	inventory_changed.emit()


## Déplace une seule unité du stack `from` vers `to`.
func move_one(from_idx: int, to_idx: int) -> void:
	if from_idx == to_idx or from_idx < 0 or to_idx < 0:
		return
	var src = slots[from_idx]
	if src == null or not _is_stackable(src["item_id"]):
		return
	var dst = slots[to_idx]
	if dst == null:
		slots[to_idx] = {"item_id": src["item_id"], "quantity": 1}
	elif dst["item_id"] == src["item_id"]:
		if dst["quantity"] >= _get_max_stack(src["item_id"]):
			return
		dst["quantity"] += 1
	else:
		return
	src["quantity"] -= 1
	if src["quantity"] <= 0:
		slots[from_idx] = null
	inventory_changed.emit()


## Divise un stack en deux dans un slot vide proche.
func split_stack(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx >= MAX_SLOTS or slots[slot_idx] == null:
		return
	var src : Dictionary = slots[slot_idx]
	if src["quantity"] <= 1:
		return
	if not _is_stackable(src["item_id"]):
		return
	var empty : int = _find_empty_slot()
	if empty < 0:
		return
	var half : int         = src["quantity"] / 2
	slots[slot_idx]["quantity"] -= half
	slots[empty]                 = {"item_id": src["item_id"], "quantity": half}
	inventory_changed.emit()


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────
func get_item_count(item_id: String) -> int:
	var total : int = 0
	for slot in slots:
		if slot != null and slot["item_id"] == item_id:
			total += slot["quantity"]
	return total


func _is_stackable(item_id: String) -> bool:
	if not MaterialLibrary.get_material(item_id).is_empty():
		return true
	return EquipmentLibrary.get_item(item_id).get("type", "") == "consumable"


func _get_max_stack(item_id: String) -> int:
	if not MaterialLibrary.get_material(item_id).is_empty():
		return 99
	if EquipmentLibrary.get_item(item_id).get("type", "") == "consumable":
		return 99
	return 1


func _find_empty_slot() -> int:
	for i in MAX_SLOTS:
		if slots[i] == null:
			return i
	return -1


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var data : Array = []
	for slot in slots:
		data.append(slot.duplicate() if slot != null else null)
	return {"slots": data}


func deserialize(d: Dictionary) -> void:
	var data : Array = d.get("slots", [])
	slots.resize(MAX_SLOTS)
	for i in MAX_SLOTS:
		slots[i] = data[i].duplicate() if i < data.size() and data[i] != null else null
	inventory_changed.emit()
