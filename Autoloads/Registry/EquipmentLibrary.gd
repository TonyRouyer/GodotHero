## EquipmentLibrary.gd — Autoload
## Registre de tous les équipements : armes, armures, accessoires, consommables.
##
## Structure d'une entrée :
##   id            : String        — identifiant unique
##   label         : String        — nom affiché
##   type          : String        — "weapon" | "armor" | "accessory" | "consumable"
##   subtype       : String        — catégorie (ex: "epee", "lourde", "anneau", "potion_soin")
##   rank          : String        — F E D C B A S
##   stats         : Dictionary    — bonus de stats appliqués au héros
##   effects       : Array         — effets spéciaux (consommables / enchantements)
##   recipe        : Array         — [{ "item_id": String, "qty": int }]
##   craft_location: String        — lieu de craft ("forge", "atelier", "alchimie", "")
##   price         : int           — valeur en or
##   description   : String
##
## Types de stats pour "stats" :
##   "atk"       : bonus dégâts physiques
##   "matk"      : bonus dégâts magiques
##   "def"       : bonus défense physique
##   "mdef"      : bonus défense magique
##   "spd"       : bonus vitesse
##   "crit"      : bonus critique (%)
##   "hp"        : bonus HP max
##   "mana"      : bonus mana max
extends Node


var _items : Dictionary = {}


func _ready() -> void:
	_register_weapons()
	_register_armors()
	_register_armor_heads()
	_register_armor_legs()
	_register_accessories()
	_register_consumables()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_item(item_id: String) -> Dictionary:
	return _items.get(item_id, {})


func get_all() -> Dictionary:
	return _items


func get_by_type(type: String) -> Array:
	var result : Array = []
	for id in _items:
		if _items[id]["type"] == type:
			result.append(_items[id])
	return result


func get_by_subtype(subtype: String) -> Array:
	var result : Array = []
	for id in _items:
		if _items[id]["subtype"] == subtype:
			result.append(_items[id])
	return result


func get_weapons_for_class(weapon_types: Array) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "weapon" and item["subtype"] in weapon_types:
			result.append(item)
	return result


func get_armors_for_class(armor_type: String) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "armor" and item["subtype"] == armor_type:
			result.append(item)
	return result


## Retourne les armures filtrées par poids ET slot (head | torso | legs)
func get_armors_for_slot(armor_type: String, slot: String) -> Array:
	var result : Array = []
	for id in _items:
		var item : Dictionary = _items[id]
		if item["type"] == "armor" and item["subtype"] == armor_type and item.get("slot", "") == slot:
			result.append(item)
	return result


func is_craftable(item_id: String) -> bool:
	var item : Dictionary = get_item(item_id)
	return not item.is_empty() and not item.get("recipe", []).is_empty()


func get_rank_index(rank: String) -> int:
	match rank:
		"F": return 0
		"E": return 1
		"D": return 2
		"C": return 3
		"B": return 4
		"A": return 5
		"S": return 6
	return 0


# ─────────────────────────────────────────────
#  INTERNAL HELPERS
# ─────────────────────────────────────────────

func _add(id: String, label: String, type: String, subtype: String, rank: String,
		stats: Dictionary, effects: Array, recipe: Array, craft_location: String,
		price: int, description: String) -> void:
	_items[id] = {
		"id":             id,
		"label":          label,
		"type":           type,
		"subtype":        subtype,
		"slot":           "",   ## utilisé par les armures : "head" | "torso" | "legs"
		"rank":           rank,
		"stats":          stats,
		"effects":        effects,
		"recipe":         recipe,
		"craft_location": craft_location,
		"price":          price,
		"description":    description,
	}


func _w(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "weapon", subtype, rank, stats, [], recipe, "forge", price, desc)


## Armure torse (les existantes)
func _a(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "armor", subtype, rank, stats, [], recipe, "forge", price, desc)
	_items[id]["slot"] = "torso"


## Armure avec slot explicite (tête / torse / jambes)
func _ah(id: String, label: String, subtype: String, slot: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "armor", subtype, rank, stats, [], recipe, "forge", price, desc)
	_items[id]["slot"] = slot


func _acc(id: String, label: String, subtype: String, rank: String, stats: Dictionary,
		recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "accessory", subtype, rank, stats, [], recipe, "forge", price, desc)


func _cons(id: String, label: String, subtype: String, stats: Dictionary,
		effects: Array, recipe: Array, price: int, desc: String) -> void:
	_add(id, label, "consumable", subtype, "F", stats, effects, recipe, "alchimie", price, desc)


# ─────────────────────────────────────────────
#  ARMES — ÉPÉES  (Guerrier)
# ─────────────────────────────────────────────
func _register_weapons() -> void:

	## ── ÉPÉES ────────────────────────────────────────────────────────────────
	_w("epee_rouille",    "Épée Rouillée",     "epee", "F",
		{"atk": 5},
		[{"item_id": "iron_ore", "qty": 2}], 15,
		"Une vieille épée rongée par la rouille. Peu fiable mais mieux que rien.")

	_w("epee_courte",     "Épée Courte",        "epee", "E",
		{"atk": 12, "spd": 2},
		[{"item_id": "iron_ore", "qty": 4}, {"item_id": "wood_log", "qty": 1}], 35,
		"Légère et maniable, idéale pour les débutants.")

	_w("epee_longue",     "Épée Longue",        "epee", "D",
		{"atk": 20, "crit": 3},
		[{"item_id": "iron_ingot", "qty": 3}, {"item_id": "leather", "qty": 1}], 80,
		"Allonge et puissance au service du guerrier.")

	_w("epee_acier",      "Épée d'Acier",       "epee", "C",
		{"atk": 32, "def": 5, "crit": 5},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "refined_leather", "qty": 1}], 180,
		"Forgée dans un acier de qualité, elle tient sa promesse au combat.")

	_w("epee_runique",    "Épée Runique",       "epee", "B",
		{"atk": 48, "matk": 10, "crit": 8},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "magic_ore", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 420,
		"Des runes anciennes gravées dans la lame libèrent une énergie magique.")

	_w("epee_draconique", "Épée Draconique",    "epee", "A",
		{"atk": 68, "matk": 20, "crit": 12, "hp": 15},
		[{"item_id": "mythril_ingot", "qty": 4}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "arcane_crystal", "qty": 2}], 950,
		"Trempée dans le sang d'un dragon, cette épée brûle d'un feu intérieur.")

	_w("epee_legendaire", "Excalivran",         "epee", "S",
		{"atk": 95, "matk": 35, "crit": 18, "hp": 30, "spd": 10},
		[{"item_id": "orichalcum_ingot", "qty": 5}, {"item_id": "dragon_scale", "qty": 3}, {"item_id": "soul_gem", "qty": 1}], 2500,
		"Une lame de légende dont le nom résonne à travers les âges.")

	## ── HACHES ───────────────────────────────────────────────────────────────
	_w("hache_pierre",    "Hache de Pierre",    "hache", "F",
		{"atk": 7},
		[{"item_id": "stone", "qty": 3}, {"item_id": "wood_log", "qty": 1}], 10,
		"Rudimentaire mais tranchante.")

	_w("hache_fer",       "Hache de Fer",       "hache", "E",
		{"atk": 14},
		[{"item_id": "iron_ore", "qty": 4}, {"item_id": "wood_log", "qty": 2}], 30,
		"Une hache robuste pour des coups lourds.")

	_w("hache_guerre",    "Hache de Guerre",    "hache", "D",
		{"atk": 25, "def": 3},
		[{"item_id": "iron_ingot", "qty": 4}, {"item_id": "leather", "qty": 1}], 90,
		"L'arme des guerriers qui préfèrent l'intimidation à la finesse.")

	_w("hache_acier",     "Hache d'Acier",      "hache", "C",
		{"atk": 38, "hp": 10},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "refined_leather", "qty": 1}], 200,
		"Lourde et dévastatrice, elle fend les armures les plus solides.")

	_w("hache_ogre",      "Couperet d'Ogre",    "hache", "B",
		{"atk": 55, "hp": 20, "spd": -3},
		[{"item_id": "steel_ingot", "qty": 6}, {"item_id": "troll_hide", "qty": 2}], 480,
		"Arrachée à un chef ogre, immense et terriblement lourde.")

	_w("hache_tempete",   "Hache-Tempête",      "hache", "A",
		{"atk": 75, "crit": 10, "hp": 25},
		[{"item_id": "mythril_ingot", "qty": 5}, {"item_id": "storm_crystal", "qty": 2}], 1050,
		"L'impact de cette hache déchaîne un coup de tonnerre.")

	_w("hache_fracasse",  "Fracasse-Mondes",    "hache", "S",
		{"atk": 100, "hp": 50, "crit": 15, "def": 10},
		[{"item_id": "orichalcum_ingot", "qty": 6}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2800,
		"Forgée par un dieu oublié, on dit qu'elle peut fendre une montagne.")

	## ── DAGUES ───────────────────────────────────────────────────────────────
	_w("dague_os",        "Dague d'Os",         "dague", "F",
		{"atk": 4, "spd": 3},
		[{"item_id": "bone", "qty": 2}], 8,
		"Taillée dans un os solide. Discrète et rapide.")

	_w("dague_silex",     "Dague de Silex",     "dague", "E",
		{"atk": 9, "spd": 5, "crit": 5},
		[{"item_id": "stone", "qty": 2}, {"item_id": "leather", "qty": 1}], 22,
		"Tranchante comme du verre, parfaite pour les assassins débutants.")

	_w("dague_venin",     "Dague Empoisonnée",  "dague", "D",
		{"atk": 16, "spd": 8, "crit": 8},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "venom_gland", "qty": 1}], 75,
		"Son tranchant est enduit d'un poison à action lente.")

	_w("dague_ombre",     "Lame de l'Ombre",    "dague", "C",
		{"atk": 26, "spd": 12, "crit": 12},
		[{"item_id": "steel_ingot", "qty": 3}, {"item_id": "shadow_essence", "qty": 1}], 190,
		"S'imprègne de l'obscurité pour frapper depuis l'invisible.")

	_w("dague_nuit",      "Croc de la Nuit",    "dague", "B",
		{"atk": 38, "spd": 18, "crit": 18},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "shadow_essence", "qty": 2}, {"item_id": "venom_gland", "qty": 2}], 450,
		"Une paire de crocs acérés forgés dans l'obscurité absolue.")

	_w("dague_eclipse",   "Dague d'Éclipse",    "dague", "A",
		{"atk": 55, "spd": 25, "crit": 25, "matk": 15},
		[{"item_id": "mythril_ingot", "qty": 3}, {"item_id": "shadow_essence", "qty": 3}, {"item_id": "arcane_crystal", "qty": 1}], 980,
		"Son tranchant absorbe la lumière et déchire le tissu de la réalité.")

	_w("dague_neant",     "L'Inévitable",       "dague", "S",
		{"atk": 80, "spd": 35, "crit": 35, "matk": 25},
		[{"item_id": "orichalcum_ingot", "qty": 4}, {"item_id": "shadow_essence", "qty": 4}, {"item_id": "soul_gem", "qty": 1}], 2600,
		"Celui qui la reçoit ne voit jamais la mort venir.")

	## ── ARCS ─────────────────────────────────────────────────────────────────
	_w("arc_bois",        "Arc de Bois",        "arc", "F",
		{"atk": 5, "spd": 2},
		[{"item_id": "wood_log", "qty": 3}], 12,
		"Un arc simple taillé dans du bois de chêne.")

	_w("arc_chasse",      "Arc de Chasse",      "arc", "E",
		{"atk": 11, "spd": 4, "crit": 4},
		[{"item_id": "wood_log", "qty": 4}, {"item_id": "leather", "qty": 1}], 28,
		"Solide et précis, idéal pour la chasse et les embuscades.")

	_w("arc_composite",   "Arc Composite",      "arc", "D",
		{"atk": 20, "spd": 7, "crit": 6},
		[{"item_id": "hardwood", "qty": 3}, {"item_id": "iron_ingot", "qty": 1}, {"item_id": "leather", "qty": 2}], 85,
		"L'alliage de bois dur et de métal décuple la portée de tir.")

	_w("arc_long",        "Grand Arc",          "arc", "C",
		{"atk": 32, "spd": 10, "crit": 9},
		[{"item_id": "hardwood", "qty": 4}, {"item_id": "steel_ingot", "qty": 2}, {"item_id": "refined_leather", "qty": 2}], 195,
		"La force et la précision réunies en un seul arc de maître.")

	_w("arc_elfe",        "Arc des Elfes",      "arc", "B",
		{"atk": 46, "spd": 16, "crit": 14, "matk": 8},
		[{"item_id": "elven_wood", "qty": 4}, {"item_id": "steel_ingot", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 500,
		"Taillé dans le bois sacré des forêts elfiques, il guide les flèches.")

	_w("arc_tempete",     "Arc-Tempête",        "arc", "A",
		{"atk": 65, "spd": 22, "crit": 20, "matk": 15},
		[{"item_id": "elven_wood", "qty": 5}, {"item_id": "mythril_ingot", "qty": 2}, {"item_id": "storm_crystal", "qty": 2}], 1020,
		"Chaque flèche tirée crépite d'électricité statique.")

	_w("arc_destin",      "Arc du Destin",      "arc", "S",
		{"atk": 90, "spd": 30, "crit": 30, "matk": 20},
		[{"item_id": "orichalcum_ingot", "qty": 4}, {"item_id": "elven_wood", "qty": 5}, {"item_id": "soul_gem", "qty": 1}], 2700,
		"On dit que ses flèches ne ratent jamais leur cible désignée par le destin.")

	## ── BÂTONS ───────────────────────────────────────────────────────────────
	_w("baton_bois",      "Bâton de Bois",      "baton", "F",
		{"matk": 6, "mana": 5},
		[{"item_id": "wood_log", "qty": 3}], 15,
		"Un simple bâton de marche qui canalise vaguement l'énergie magique.")

	_w("baton_novice",    "Bâton du Novice",    "baton", "E",
		{"matk": 13, "mana": 10},
		[{"item_id": "wood_log", "qty": 4}, {"item_id": "arcane_dust", "qty": 1}], 32,
		"Le premier bâton d'un apprenti mage.")

	_w("baton_chene",     "Bâton de Chêne",     "baton", "D",
		{"matk": 22, "mana": 20, "spd": 3},
		[{"item_id": "hardwood", "qty": 3}, {"item_id": "arcane_crystal", "qty": 1}], 88,
		"La densité du bois de chêne amplifie les flux magiques.")

	_w("baton_runes",     "Bâton Runique",      "baton", "C",
		{"matk": 35, "mana": 35, "crit": 6},
		[{"item_id": "hardwood", "qty": 4}, {"item_id": "arcane_crystal", "qty": 2}, {"item_id": "iron_ingot", "qty": 1}], 200,
		"Des runes de puissance sculptées tout au long du fût.")

	_w("baton_arcane",    "Bâton Arcanique",    "baton", "B",
		{"matk": 52, "mana": 55, "crit": 10, "hp": 10},
		[{"item_id": "elven_wood", "qty": 3}, {"item_id": "arcane_crystal", "qty": 3}, {"item_id": "magic_ore", "qty": 2}], 520,
		"Un condensé de magie brute dans un bâton cristallisé.")

	_w("baton_grand",     "Grand Bâton des Arcanes", "baton", "A",
		{"matk": 74, "mana": 80, "crit": 15, "hp": 20},
		[{"item_id": "elven_wood", "qty": 5}, {"item_id": "arcane_crystal", "qty": 4}, {"item_id": "mythril_ingot", "qty": 2}], 1100,
		"Un bâton d'archimage qui plie la réalité à sa volonté.")

	_w("baton_omniscient","Œil de l'Omniscient", "baton", "S",
		{"matk": 100, "mana": 120, "crit": 22, "hp": 30, "spd": 5},
		[{"item_id": "orichalcum_ingot", "qty": 3}, {"item_id": "arcane_crystal", "qty": 6}, {"item_id": "soul_gem", "qty": 1}], 2900,
		"L'arme des plus grands mages de l'histoire.")

	## ── GRIMOIRES ─────────────────────────────────────────────────────────────
	_w("grimoire_candide", "Grimoire Candide",  "grimoire", "F",
		{"matk": 5, "mana": 8, "knowledge": 1},
		[{"item_id": "parchment", "qty": 3}], 18,
		"Un recueil de sorts élémentaires rédigés en encre ordinaire.")

	_w("grimoire_etude",   "Grimoire d'Étude",  "grimoire", "E",
		{"matk": 12, "mana": 18, "knowledge": 2},
		[{"item_id": "parchment", "qty": 5}, {"item_id": "arcane_dust", "qty": 1}], 40,
		"Un grimoire d'apprentissage renforcé d'encre runique.")

	_w("grimoire_arcane",  "Grimoire Arcanique", "grimoire", "D",
		{"matk": 20, "mana": 30, "knowledge": 3},
		[{"item_id": "parchment", "qty": 6}, {"item_id": "arcane_crystal", "qty": 1}, {"item_id": "leather", "qty": 1}], 95,
		"Un grimoire relié en cuir de drake contenant des formules avancées.")

	_w("grimoire_ancien",  "Grimoire Ancien",   "grimoire", "C",
		{"matk": 33, "mana": 50, "knowledge": 5, "crit": 5},
		[{"item_id": "ancient_parchment", "qty": 4}, {"item_id": "arcane_crystal", "qty": 2}], 210,
		"Rédigé par un mage disparu depuis des siècles, sa sagesse est intacte.")

	_w("grimoire_abyssal", "Grimoire Abyssal",  "grimoire", "B",
		{"matk": 50, "mana": 75, "knowledge": 8, "crit": 9},
		[{"item_id": "ancient_parchment", "qty": 5}, {"item_id": "shadow_essence", "qty": 2}, {"item_id": "arcane_crystal", "qty": 2}], 540,
		"Ses pages suintent d'énergie sombre. Déconseillé aux âmes faibles.")

	_w("grimoire_verite",  "Livre de Vérité",   "grimoire", "A",
		{"matk": 72, "mana": 105, "knowledge": 12, "crit": 14, "hp": 15},
		[{"item_id": "ancient_parchment", "qty": 6}, {"item_id": "arcane_crystal", "qty": 4}, {"item_id": "mythril_ingot", "qty": 1}], 1150,
		"La vérité gravée dans chaque page amplifie chaque sort lancé.")

	_w("grimoire_creation","Grimoire de Création", "grimoire", "S",
		{"matk": 98, "mana": 150, "knowledge": 20, "crit": 20, "hp": 25},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "ancient_parchment", "qty": 8}, {"item_id": "soul_gem", "qty": 1}], 3000,
		"On dit que ce grimoire contient les formules que les dieux utilisèrent pour créer le monde.")

	## ── LANCES ────────────────────────────────────────────────────────────────
	_w("lance_bois",       "Lance de Bois",       "lance", "F",
		{"atk": 6, "def": 2},
		[{"item_id": "wood_log", "qty": 3}], 14,
		"Une lance rustique taillée dans du bois robuste. Portée longue, dégâts modestes.")

	_w("lance_fer",        "Lance de Fer",        "lance", "E",
		{"atk": 13, "def": 4},
		[{"item_id": "iron_ore", "qty": 4}, {"item_id": "wood_log", "qty": 2}], 38,
		"La garde typique des miliciens. Solide et polyvalente.")

	_w("lance_acier",      "Lance d'Acier",       "lance", "D",
		{"atk": 22, "def": 7},
		[{"item_id": "iron_ingot", "qty": 3}, {"item_id": "wood_log", "qty": 2}], 95,
		"Allonge et résistance au service du chevalier de rang intermédiaire.")

	_w("lance_garde",      "Lance de la Garde",   "lance", "C",
		{"atk": 34, "def": 12, "hp": 8},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "leather", "qty": 1}], 210,
		"L'arme réglementaire de la garde royale. Équilibre et puissance.")

	_w("lance_runique",    "Lance Runique",        "lance", "B",
		{"atk": 50, "def": 18, "matk": 8},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "arcane_crystal", "qty": 2}], 490,
		"Des runes de protection gravées sur le fût renforcent son porteur.")

	_w("lance_mythril",    "Lance de Mythril",    "lance", "A",
		{"atk": 70, "def": 25, "hp": 15},
		[{"item_id": "mythril_ingot", "qty": 4}, {"item_id": "dragon_scale", "qty": 1}], 1080,
		"Légère comme une plume, résistante comme une forteresse.")

	_w("lance_celeste",    "Lance Céleste",        "lance", "S",
		{"atk": 98, "def": 35, "hp": 20, "matk": 15},
		[{"item_id": "orichalcum_ingot", "qty": 5}, {"item_id": "soul_gem", "qty": 1}, {"item_id": "arcane_crystal", "qty": 2}], 2700,
		"Forgée dans les hauteurs célestes, réservée aux chevaliers légendaires.")

	## ── MARTEAUX ──────────────────────────────────────────────────────────────
	_w("marteau_pierre",   "Marteau de Pierre",   "marteau", "F",
		{"atk": 8, "hp": 5},
		[{"item_id": "stone", "qty": 4}, {"item_id": "wood_log", "qty": 2}], 12,
		"Lourd et peu précis, mais chaque coup ébranle l'adversaire.")

	_w("marteau_fer",      "Marteau de Fer",      "marteau", "E",
		{"atk": 16, "hp": 10, "spd": -2},
		[{"item_id": "iron_ore", "qty": 5}, {"item_id": "wood_log", "qty": 2}], 35,
		"La masse favorite des mineurs reconvertis en guerriers.")

	_w("marteau_guerre",   "Marteau de Guerre",   "marteau", "D",
		{"atk": 27, "hp": 18, "spd": -3},
		[{"item_id": "iron_ingot", "qty": 4}, {"item_id": "leather", "qty": 2}], 100,
		"Conçu pour fracasser armures et boucliers. Rien ne lui résiste longtemps.")

	_w("marteau_acier",    "Marteau d'Acier",     "marteau", "C",
		{"atk": 40, "hp": 30, "spd": -3},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "refined_leather", "qty": 1}], 220,
		"La puissance brute à l'état pur. Chaque coup fait trembler le sol.")

	_w("marteau_ogre",     "Massue d'Ogre",       "marteau", "B",
		{"atk": 58, "hp": 40, "spd": -4},
		[{"item_id": "steel_ingot", "qty": 6}, {"item_id": "troll_hide", "qty": 3}], 510,
		"Arrachée à un ogre géant, sa masse est dévastatrice mais épuisante.")

	_w("marteau_titan",    "Marteau du Titan",    "marteau", "A",
		{"atk": 80, "hp": 55, "spd": -3},
		[{"item_id": "mythril_ingot", "qty": 5}, {"item_id": "dragon_scale", "qty": 2}], 1120,
		"La légende dit qu'il a aplati une montagne. L'impact laisse un cratère.")

	_w("marteau_dieu",     "Poing des Dieux",     "marteau", "S",
		{"atk": 108, "hp": 70, "spd": -2, "def": 10},
		[{"item_id": "orichalcum_ingot", "qty": 6}, {"item_id": "soul_gem", "qty": 1}, {"item_id": "dragon_scale", "qty": 2}], 2900,
		"Un marteau de légende qui renferme la rage des dieux oubliés.")

	## ── ORBES ─────────────────────────────────────────────────────────────────
	_w("orbe_verre",       "Orbe de Verre",       "orbe", "F",
		{"matk": 7, "mana": 10},
		[{"item_id": "glass", "qty": 2}, {"item_id": "arcane_dust", "qty": 1}], 20,
		"Une sphère de verre qui amplifie les flux magiques de base.")

	_w("orbe_cristal",     "Orbe de Cristal",     "orbe", "E",
		{"matk": 15, "mana": 20},
		[{"item_id": "arcane_crystal", "qty": 2}, {"item_id": "glass", "qty": 1}], 48,
		"Un cristal taillé en sphère parfaite, idéal pour focaliser les sorts.")

	_w("orbe_arcane",      "Orbe Arcanique",      "orbe", "D",
		{"matk": 25, "mana": 35},
		[{"item_id": "arcane_crystal", "qty": 3}, {"item_id": "magic_ore", "qty": 2}], 105,
		"Pulse doucement d'une énergie magique concentrée.")

	_w("orbe_ancien",      "Orbe Ancien",         "orbe", "C",
		{"matk": 38, "mana": 52, "crit": 5},
		[{"item_id": "arcane_crystal", "qty": 4}, {"item_id": "magic_ore", "qty": 3}, {"item_id": "iron_ingot", "qty": 1}], 225,
		"Un orbe retrouvé dans des ruines, chargé d'une magie oubliée.")

	_w("orbe_abyssal",     "Orbe Abyssal",        "orbe", "B",
		{"matk": 56, "mana": 75, "crit": 9},
		[{"item_id": "arcane_crystal", "qty": 5}, {"item_id": "shadow_essence", "qty": 2}, {"item_id": "magic_ore", "qty": 2}], 560,
		"Plonge ses victimes dans les ténèbres de l'abîsse. Frissonnant.")

	_w("orbe_stellaire",   "Orbe Stellaire",      "orbe", "A",
		{"matk": 78, "mana": 100, "crit": 14},
		[{"item_id": "arcane_crystal", "qty": 6}, {"item_id": "mythril_ingot", "qty": 2}, {"item_id": "storm_crystal", "qty": 1}], 1150,
		"Capte l'énergie des étoiles pour alimenter des sorts dévastateurs.")

	_w("orbe_divin",       "Orbe Divin",          "orbe", "S",
		{"matk": 105, "mana": 140, "crit": 20},
		[{"item_id": "orichalcum_ingot", "qty": 3}, {"item_id": "arcane_crystal", "qty": 7}, {"item_id": "soul_gem", "qty": 1}], 3100,
		"Un fragment de divinité emprisonné dans une sphère parfaite.")

	## ── SHURIKENS ─────────────────────────────────────────────────────────────
	_w("shuriken_os",      "Shuriken d'Os",       "shuriken", "F",
		{"atk": 3, "spd": 5, "crit": 5},
		[{"item_id": "bone", "qty": 3}], 8,
		"Des éclats d'os aiguisés, silencieux et traîtres.")

	_w("shuriken_fer",     "Shuriken de Fer",     "shuriken", "E",
		{"atk": 7, "spd": 9, "crit": 8},
		[{"item_id": "iron_ore", "qty": 3}, {"item_id": "leather", "qty": 1}], 24,
		"Des étoiles de fer qui sifflent dans l'obscurité.")

	_w("shuriken_acier",   "Shuriken d'Acier",    "shuriken", "D",
		{"atk": 14, "spd": 14, "crit": 12},
		[{"item_id": "iron_ingot", "qty": 3}, {"item_id": "leather", "qty": 1}], 78,
		"Forgées avec précision, elles pénètrent les armures légères.")

	_w("shuriken_venin",   "Shuriken Empoisonné", "shuriken", "C",
		{"atk": 22, "spd": 20, "crit": 16},
		[{"item_id": "steel_ingot", "qty": 3}, {"item_id": "venom_gland", "qty": 2}], 195,
		"Enduites d'un venin à action rapide. La cible ralentit, puis tombe.")

	_w("shuriken_ombre",   "Étoile de l'Ombre",  "shuriken", "B",
		{"atk": 33, "spd": 27, "crit": 22},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "shadow_essence", "qty": 3}], 470,
		"Se fond dans l'obscurité. La cible ne la voit jamais venir.")

	_w("shuriken_eclipse",  "Shuriken d'Éclipse", "shuriken", "A",
		{"atk": 48, "spd": 36, "crit": 30},
		[{"item_id": "mythril_ingot", "qty": 3}, {"item_id": "shadow_essence", "qty": 4}, {"item_id": "arcane_crystal", "qty": 1}], 1000,
		"Frappe en éclipse — disparaît dans l'ombre avant même d'avoir touché.")

	_w("shuriken_neant",    "Éclat du Néant",     "shuriken", "S",
		{"atk": 68, "spd": 48, "crit": 40},
		[{"item_id": "orichalcum_ingot", "qty": 3}, {"item_id": "shadow_essence", "qty": 5}, {"item_id": "soul_gem", "qty": 1}], 2600,
		"Une étoile forgée dans le néant. Celui qu'elle touche ne se souvient de rien.")


# ─────────────────────────────────────────────
#  ARMURES
# ─────────────────────────────────────────────
func _register_armors() -> void:

	## ── ARMURES LÉGÈRES ───────────────────────────────────────────────────────
	_a("tunique_tissu",   "Tunique de Tissu",   "legere", "F",
		{"def": 3, "mdef": 3, "spd": 2},
		[{"item_id": "cloth", "qty": 3}], 10,
		"Protection minimale pour les mages et roublards débutants.")

	_a("robe_novice",     "Robe du Novice",     "legere", "E",
		{"def": 6, "mdef": 8, "mana": 8},
		[{"item_id": "cloth", "qty": 5}, {"item_id": "arcane_dust", "qty": 1}], 30,
		"Légère et confortable, elle ne gêne pas les gestes des lanceurs de sorts.")

	_a("robe_cuir",       "Robe de Cuir Souple","legere", "D",
		{"def": 12, "mdef": 14, "mana": 15, "spd": 4},
		[{"item_id": "leather", "qty": 4}, {"item_id": "cloth", "qty": 3}], 85,
		"Un mariage de souplesse et de résistance pour les aventuriers mobiles.")

	_a("robe_enchantee",  "Robe Enchantée",     "legere", "C",
		{"def": 20, "mdef": 24, "mana": 25, "spd": 6},
		[{"item_id": "refined_leather", "qty": 3}, {"item_id": "arcane_crystal", "qty": 2}], 195,
		"Des fils d'énergie arcanique renforcent cette robe de mage.")

	_a("manteau_ombre",   "Manteau de l'Ombre", "legere", "B",
		{"def": 32, "mdef": 36, "mana": 40, "spd": 10, "crit": 5},
		[{"item_id": "refined_leather", "qty": 4}, {"item_id": "shadow_essence", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 480,
		"Se fond dans les ombres, offrant une discrétion surnaturelle.")

	_a("robe_archmage",   "Robe d'Archimage",   "legere", "A",
		{"def": 45, "mdef": 55, "mana": 60, "spd": 14, "hp": 15},
		[{"item_id": "elven_cloth", "qty": 5}, {"item_id": "arcane_crystal", "qty": 3}, {"item_id": "mythril_ingot", "qty": 1}], 1050,
		"Portée par les plus grands mages de la guilde, elle amplifie la magie.")

	_a("robe_creation",   "Voile de Création",  "legere", "S",
		{"def": 62, "mdef": 80, "mana": 90, "spd": 20, "hp": 25, "crit": 8},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "elven_cloth", "qty": 6}, {"item_id": "soul_gem", "qty": 1}], 2800,
		"Un voile tissé avec des fils de pure magie, réservé aux élus.")

	## ── ARMURES MOYENNES ──────────────────────────────────────────────────────
	_a("armure_cuir",     "Armure de Cuir",     "moyenne", "F",
		{"def": 7, "mdef": 4, "spd": 1},
		[{"item_id": "leather", "qty": 4}], 20,
		"Protection de base pour les aventuriers qui préfèrent la mobilité.")

	_a("armure_renforcee","Armure Renforcée",   "moyenne", "E",
		{"def": 14, "mdef": 7, "spd": 2, "hp": 5},
		[{"item_id": "leather", "qty": 5}, {"item_id": "iron_ore", "qty": 2}], 48,
		"Des plaques de métal cousues sur du cuir offrent une protection décente.")

	_a("cotte_mailles",   "Cotte de Mailles",   "moyenne", "D",
		{"def": 24, "mdef": 12, "hp": 10},
		[{"item_id": "iron_ingot", "qty": 4}, {"item_id": "leather", "qty": 3}], 100,
		"Des anneaux de fer entrelacés pour une protection équilibrée.")

	_a("armure_acier",    "Armure d'Écailles",  "moyenne", "C",
		{"def": 36, "mdef": 18, "hp": 20, "spd": -2},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "refined_leather", "qty": 3}], 215,
		"Des écailles d'acier imitant celles des lézards géants du désert.")

	_a("armure_drake",    "Armure de Drake",    "moyenne", "B",
		{"def": 52, "mdef": 28, "hp": 30, "spd": -1},
		[{"item_id": "dragon_scale", "qty": 3}, {"item_id": "steel_ingot", "qty": 3}, {"item_id": "refined_leather", "qty": 2}], 540,
		"Forgée à partir d'écailles de drake, résistante au feu.")

	_a("armure_chasseur", "Armure du Grand Chasseur", "moyenne", "A",
		{"def": 70, "mdef": 40, "hp": 45, "spd": 5, "crit": 8},
		[{"item_id": "dragon_scale", "qty": 4}, {"item_id": "mythril_ingot", "qty": 3}, {"item_id": "elven_cloth", "qty": 2}], 1100,
		"L'armure du chasseur légendaire qui traqua le dragon des neiges.")

	_a("armure_legende",  "Armure du Prédateur","moyenne", "S",
		{"def": 92, "mdef": 55, "hp": 65, "spd": 12, "crit": 15},
		[{"item_id": "orichalcum_ingot", "qty": 4}, {"item_id": "dragon_scale", "qty": 4}, {"item_id": "soul_gem", "qty": 1}], 2900,
		"L'armure du plus grand chasseur qui ait jamais vécu.")

	## ── ARMURES LOURDES ───────────────────────────────────────────────────────
	_a("cotte_fer",       "Cotte de Fer",       "lourde", "F",
		{"def": 10, "mdef": 3, "hp": 5, "spd": -3},
		[{"item_id": "iron_ore", "qty": 5}], 25,
		"Lourde et peu pratique, mais elle encaisse bien les coups.")

	_a("plaque_fer",      "Armure de Plaques",  "lourde", "E",
		{"def": 18, "mdef": 5, "hp": 12, "spd": -4},
		[{"item_id": "iron_ingot", "qty": 4}, {"item_id": "leather", "qty": 1}], 60,
		"Des plaques de fer soigneusement assemblées par un forgeron compétent.")

	_a("plaque_acier",    "Plaque d'Acier",     "lourde", "D",
		{"def": 30, "mdef": 8, "hp": 22, "spd": -5},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "leather", "qty": 2}], 115,
		"Une armure complète en acier, la fierté des guerriers de métier.")

	_a("armure_chevalier","Armure du Chevalier", "lourde", "C",
		{"def": 45, "mdef": 14, "hp": 35, "spd": -4},
		[{"item_id": "steel_ingot", "qty": 6}, {"item_id": "refined_leather", "qty": 2}, {"item_id": "iron_ingot", "qty": 2}], 230,
		"L'équipement standard des chevaliers de la garde royale.")

	_a("armure_forteresse","Armure-Forteresse",  "lourde", "B",
		{"def": 65, "mdef": 22, "hp": 55, "spd": -3},
		[{"item_id": "steel_ingot", "qty": 8}, {"item_id": "magic_ore", "qty": 2}, {"item_id": "refined_leather", "qty": 2}], 570,
		"Aussi résistante qu'un mur de forteresse. Presque impossible à pénétrer.")

	_a("armure_titan",    "Armure du Titan",    "lourde", "A",
		{"def": 88, "mdef": 32, "hp": 80, "spd": -2},
		[{"item_id": "mythril_ingot", "qty": 6}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "arcane_crystal", "qty": 2}], 1200,
		"Réservée aux guerriers d'élite, sa résistance défie la raison.")

	_a("armure_dieu",     "Armure des Dieux",   "lourde", "S",
		{"def": 115, "mdef": 45, "hp": 110, "spd": -1},
		[{"item_id": "orichalcum_ingot", "qty": 7}, {"item_id": "dragon_scale", "qty": 3}, {"item_id": "soul_gem", "qty": 1}], 3200,
		"Forgée selon les plans divins, elle rend son porteur presque invulnérable.")


# ─────────────────────────────────────────────
#  ARMURES — TÊTES (casques, capuches, coiffes)
# ─────────────────────────────────────────────
func _register_armor_heads() -> void:

	## ── LÉGÈRE ────────────────────────────────────────────────────────────────
	_ah("capuche_tissu",     "Capuche de Tissu",       "legere", "head", "F",
		{"mdef": 2, "mana": 3},
		[{"item_id": "cloth", "qty": 2}], 8,
		"Une simple capuche de tissu qui concentre vaguement les flux magiques.")

	_ah("capuche_novice",    "Capuche du Novice",      "legere", "head", "E",
		{"mdef": 4, "mana": 6},
		[{"item_id": "cloth", "qty": 3}, {"item_id": "arcane_dust", "qty": 1}], 22,
		"Légère et confortable, elle laisse l'esprit libre pour les arcanes.")

	_ah("capuche_cuir",      "Capuche de Cuir",        "legere", "head", "D",
		{"def": 4, "mdef": 6, "mana": 8},
		[{"item_id": "leather", "qty": 2}, {"item_id": "cloth", "qty": 2}], 65,
		"Souplesse du cuir et protection arcanique réunies.")

	_ah("capuche_enchantee", "Capuche Enchantée",      "legere", "head", "C",
		{"def": 7, "mdef": 10, "mana": 12},
		[{"item_id": "refined_leather", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 145,
		"Des fils magiques tissés dans le cuir amplifient les sorts du porteur.")

	_ah("capuche_ombre",     "Capuche de l'Ombre",    "legere", "head", "B",
		{"def": 11, "mdef": 16, "mana": 20, "crit": 3},
		[{"item_id": "refined_leather", "qty": 2}, {"item_id": "shadow_essence", "qty": 2}], 360,
		"Absorbe la lumière, rendant le visage presque invisible.")

	_ah("tiare_archmage",    "Tiare d'Archimage",     "legere", "head", "A",
		{"def": 16, "mdef": 22, "mana": 28, "crit": 5},
		[{"item_id": "elven_cloth", "qty": 3}, {"item_id": "arcane_crystal", "qty": 2}], 800,
		"Un diadème d'énergie arcanique porté par les plus grands mages.")

	_ah("voile_creation",    "Voile de Création",     "legere", "head", "S",
		{"def": 22, "mdef": 32, "mana": 40, "crit": 8},
		[{"item_id": "orichalcum_ingot", "qty": 1}, {"item_id": "elven_cloth", "qty": 3}, {"item_id": "soul_gem", "qty": 1}], 2200,
		"Tissé avec des fils de pure magie, il illumine l'esprit de son porteur.")

	## ── MOYENNE ───────────────────────────────────────────────────────────────
	_ah("coiffe_cuir",       "Coiffe de Cuir",         "moyenne", "head", "F",
		{"def": 3, "mdef": 2},
		[{"item_id": "leather", "qty": 3}], 15,
		"Une coiffe de cuir brut, protection basique pour les aventuriers débutants.")

	_ah("coiffe_renforcee",  "Coiffe Renforcée",       "moyenne", "head", "E",
		{"def": 5, "mdef": 3, "hp": 3},
		[{"item_id": "leather", "qty": 3}, {"item_id": "iron_ore", "qty": 2}], 36,
		"Des plaques de métal cousues sur du cuir protègent le crâne.")

	_ah("heaume_mailles",    "Heaume de Mailles",      "moyenne", "head", "D",
		{"def": 9, "mdef": 5, "hp": 6},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "leather", "qty": 2}], 78,
		"Des anneaux de fer entrelacés forment une protection solide.")

	_ah("heaume_ecailles",   "Heaume d'Écailles",     "moyenne", "head", "C",
		{"def": 13, "mdef": 7, "hp": 10},
		[{"item_id": "steel_ingot", "qty": 2}, {"item_id": "refined_leather", "qty": 2}], 165,
		"Des écailles d'acier imitant les reptiles géants du désert du sud.")

	_ah("heaume_drake",      "Heaume de Drake",        "moyenne", "head", "B",
		{"def": 19, "mdef": 11, "hp": 15},
		[{"item_id": "dragon_scale", "qty": 2}, {"item_id": "steel_ingot", "qty": 2}], 415,
		"Façonné à partir d'une tête de drake. Résistant au feu.")

	_ah("heaume_chasseur",   "Heaume du Grand Chasseur","moyenne", "head", "A",
		{"def": 26, "mdef": 15, "hp": 22, "crit": 5},
		[{"item_id": "dragon_scale", "qty": 2}, {"item_id": "mythril_ingot", "qty": 2}], 840,
		"L'heaume du chasseur légendaire, taillé dans l'os d'un dragon des neiges.")

	_ah("heaume_predateur",  "Heaume du Prédateur",   "moyenne", "head", "S",
		{"def": 34, "mdef": 20, "hp": 30, "crit": 8},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2200,
		"Le heaume du plus redouté des chasseurs. Son regard seul terrifiait les proies.")

	## ── LOURDE ────────────────────────────────────────────────────────────────
	_ah("couvre_chef_fer",   "Couvre-Chef de Fer",    "lourde", "head", "F",
		{"def": 4, "mdef": 2, "hp": 3, "spd": -1},
		[{"item_id": "iron_ore", "qty": 3}], 18,
		"Un casque rudimentaire en fer brut. Mieux que rien face aux gourdins.")

	_ah("heaume_fer",        "Heaume de Fer",          "lourde", "head", "E",
		{"def": 7, "mdef": 3, "hp": 5, "spd": -1},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "leather", "qty": 1}], 45,
		"Un heaume complet en fer qui protège bien mais pèse lourd.")

	_ah("heaume_acier",      "Heaume d'Acier",         "lourde", "head", "D",
		{"def": 11, "mdef": 4, "hp": 8, "spd": -1},
		[{"item_id": "steel_ingot", "qty": 2}, {"item_id": "leather", "qty": 1}], 88,
		"La fierté des soldats de métier. Solide et intimidant.")

	_ah("heaume_chevalier",  "Heaume du Chevalier",   "lourde", "head", "C",
		{"def": 17, "mdef": 6, "hp": 13, "spd": -1},
		[{"item_id": "steel_ingot", "qty": 3}, {"item_id": "refined_leather", "qty": 1}], 175,
		"Le heaume de la garde royale. Arborant fièrement l'écusson de la couronne.")

	_ah("heaume_forteresse", "Heaume-Forteresse",     "lourde", "head", "B",
		{"def": 24, "mdef": 9, "hp": 20, "spd": -1},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "magic_ore", "qty": 1}], 430,
		"Aussi résistant qu'un mur de pierre. Aucun coup de tête ne passe.")

	_ah("heaume_titan",      "Heaume du Titan",        "lourde", "head", "A",
		{"def": 33, "mdef": 13, "hp": 30, "spd": -1},
		[{"item_id": "mythril_ingot", "qty": 3}, {"item_id": "dragon_scale", "qty": 1}], 920,
		"Le casque des guerriers d'élite qui ont survécu à cent batailles.")

	_ah("heaume_dieu",       "Heaume des Dieux",       "lourde", "head", "S",
		{"def": 44, "mdef": 18, "hp": 42, "spd": -1},
		[{"item_id": "orichalcum_ingot", "qty": 3}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2500,
		"Forgé selon les plans divins. Son porteur semble invulnérable.")


# ─────────────────────────────────────────────
#  ARMURES — JAMBES (jambières, leggings, grèves)
# ─────────────────────────────────────────────
func _register_armor_legs() -> void:

	## ── LÉGÈRE ────────────────────────────────────────────────────────────────
	_ah("pantalon_tissu",    "Pantalon de Tissu",      "legere", "legs", "F",
		{"mdef": 1, "spd": 2},
		[{"item_id": "cloth", "qty": 2}], 7,
		"Un simple pantalon de tissu, léger et peu contraignant.")

	_ah("jupe_novice",       "Robe du Novice (bas)",   "legere", "legs", "E",
		{"def": 2, "mdef": 3, "spd": 3},
		[{"item_id": "cloth", "qty": 3}, {"item_id": "arcane_dust", "qty": 1}], 20,
		"La partie basse de la robe du novice. Légère et confortable.")

	_ah("pantalon_cuir",     "Pantalon de Cuir Souple","legere", "legs", "D",
		{"def": 5, "mdef": 5, "spd": 4},
		[{"item_id": "leather", "qty": 2}, {"item_id": "cloth", "qty": 2}], 60,
		"Cuir souple pour une liberté de mouvement totale.")

	_ah("leggings_enchantes","Leggings Enchantés",     "legere", "legs", "C",
		{"def": 8, "mdef": 9, "spd": 6},
		[{"item_id": "refined_leather", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 140,
		"Des fils arcaniques renforcent la protection sans nuire à l'agilité.")

	_ah("leggings_ombre",    "Leggings de l'Ombre",   "legere", "legs", "B",
		{"def": 12, "mdef": 14, "spd": 10, "crit": 3},
		[{"item_id": "refined_leather", "qty": 2}, {"item_id": "shadow_essence", "qty": 2}], 350,
		"Aussi discrets que l'ombre. Le pas de leur porteur est silencieux.")

	_ah("leggings_archmage", "Leggings d'Archimage",  "legere", "legs", "A",
		{"def": 17, "mdef": 21, "spd": 14, "mana": 15},
		[{"item_id": "elven_cloth", "qty": 3}, {"item_id": "arcane_crystal", "qty": 2}], 780,
		"Tissés d'énergie magique, ils permettent des déplacements ultra-rapides.")

	_ah("leggings_creation", "Leggings de Création",  "legere", "legs", "S",
		{"def": 24, "mdef": 30, "spd": 20, "mana": 25},
		[{"item_id": "orichalcum_ingot", "qty": 1}, {"item_id": "elven_cloth", "qty": 3}, {"item_id": "soul_gem", "qty": 1}], 2100,
		"Le bas du voile de création. Chaque pas laisse une trace lumineuse.")

	## ── MOYENNE ───────────────────────────────────────────────────────────────
	_ah("pantalon_cuir_m",   "Pantalon de Cuir",       "moyenne", "legs", "F",
		{"def": 3, "spd": 1},
		[{"item_id": "leather", "qty": 3}], 14,
		"Du cuir brut taillé en pantalon. Protection minimale.")

	_ah("jambiere_renforcee","Jambière Renforcée",     "moyenne", "legs", "E",
		{"def": 6, "mdef": 2, "hp": 3},
		[{"item_id": "leather", "qty": 3}, {"item_id": "iron_ore", "qty": 2}], 35,
		"Des plaques de métal protègent les genoux et les tibias.")

	_ah("jambiere_mailles",  "Jambière de Mailles",   "moyenne", "legs", "D",
		{"def": 10, "mdef": 5, "hp": 6},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "leather", "qty": 2}], 75,
		"Des anneaux entrelacés offrent légèreté et protection équilibrée.")

	_ah("jambiere_acier",    "Jambière d'Acier",       "moyenne", "legs", "C",
		{"def": 14, "mdef": 7, "hp": 10, "spd": -1},
		[{"item_id": "steel_ingot", "qty": 3}, {"item_id": "refined_leather", "qty": 2}], 160,
		"Des écailles d'acier sur du cuir : solidité sans rigidité totale.")

	_ah("jambiere_drake",    "Jambière de Drake",      "moyenne", "legs", "B",
		{"def": 20, "mdef": 10, "hp": 15},
		[{"item_id": "dragon_scale", "qty": 2}, {"item_id": "steel_ingot", "qty": 2}], 400,
		"Des écailles de drake protègent les jambes du feu et des coups.")

	_ah("jambiere_chasseur", "Jambière du Grand Chasseur","moyenne", "legs", "A",
		{"def": 27, "mdef": 14, "hp": 20, "spd": 5},
		[{"item_id": "dragon_scale", "qty": 2}, {"item_id": "mythril_ingot", "qty": 2}], 820,
		"Légères et solides, elles permettent une course silencieuse à grande vitesse.")

	_ah("jambiere_predateur","Jambière du Prédateur",  "moyenne", "legs", "S",
		{"def": 35, "mdef": 20, "hp": 28, "spd": 10},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2200,
		"Les jambes du prédateur. Rien ne peut lui échapper.")

	## ── LOURDE ────────────────────────────────────────────────────────────────
	_ah("jambiere_fer",      "Jambière de Fer",        "lourde", "legs", "F",
		{"def": 5, "hp": 3, "spd": -2},
		[{"item_id": "iron_ore", "qty": 4}], 20,
		"Lourdes et peu maniables, mais elles encaissent les coups aux jambes.")

	_ah("greve_fer",         "Grève de Fer",           "lourde", "legs", "E",
		{"def": 7, "mdef": 2, "hp": 5, "spd": -2},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "leather", "qty": 1}], 46,
		"Des plaques de fer protégeant tibias et genoux des guerriers.")

	_ah("greve_acier",       "Grève d'Acier",          "lourde", "legs", "D",
		{"def": 12, "mdef": 3, "hp": 8, "spd": -2},
		[{"item_id": "steel_ingot", "qty": 3}, {"item_id": "leather", "qty": 1}], 90,
		"L'équipement standard des soldats de métier. Robuste et éprouvé.")

	_ah("greve_chevalier",   "Grève du Chevalier",    "lourde", "legs", "C",
		{"def": 18, "mdef": 5, "hp": 13, "spd": -2},
		[{"item_id": "steel_ingot", "qty": 4}, {"item_id": "refined_leather", "qty": 1}], 175,
		"Les jambières de la garde royale. Fières et imposantes.")

	_ah("greve_forteresse",  "Grève-Forteresse",      "lourde", "legs", "B",
		{"def": 25, "mdef": 8, "hp": 20, "spd": -2},
		[{"item_id": "steel_ingot", "qty": 5}, {"item_id": "magic_ore", "qty": 1}], 430,
		"Aussi solides que les remparts d'un château. Rien ne passe.")

	_ah("greve_titan",       "Grève du Titan",        "lourde", "legs", "A",
		{"def": 34, "mdef": 12, "hp": 28, "spd": -1},
		[{"item_id": "mythril_ingot", "qty": 4}, {"item_id": "dragon_scale", "qty": 1}], 900,
		"Des jambières de mythril forgées pour les guerriers d'élite.")

	_ah("greve_dieu",        "Grève des Dieux",       "lourde", "legs", "S",
		{"def": 44, "mdef": 17, "hp": 40, "spd": -1},
		[{"item_id": "orichalcum_ingot", "qty": 3}, {"item_id": "dragon_scale", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2400,
		"Forgées selon les plans divins, elles écrasent ce qui ose s'y attaquer.")


# ─────────────────────────────────────────────
#  ACCESSOIRES
# ─────────────────────────────────────────────
func _register_accessories() -> void:

	## ── ANNEAUX ──────────────────────────────────────────────────────────────
	_acc("anneau_cuivre",   "Anneau de Cuivre",    "anneau", "F",
		{"hp": 5},
		[{"item_id": "copper_ore", "qty": 2}], 12,
		"Un simple anneau de cuivre qui confère une vitalité légère.")

	_acc("anneau_force",    "Anneau de Force",     "anneau", "D",
		{"atk": 8, "hp": 10},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "ruby_gem", "qty": 1}], 90,
		"Un rubis incrusté canalise la force du porteur.")

	_acc("anneau_mage",     "Anneau du Mage",      "anneau", "C",
		{"matk": 8, "mana": 15},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 95,
		"Amplifie les flux magiques à travers les doigts du lanceur de sorts.")

	_acc("anneau_chance",   "Anneau de Chance",    "anneau", "C",
		{"crit": 10, "spd": 5},
		[{"item_id": "steel_ingot", "qty": 2}, {"item_id": "luck_stone", "qty": 1}], 200,
		"La chance s'accroche à son porteur comme l'or au midas.")

	_acc("anneau_mythril",  "Anneau de Mythril",   "anneau", "B",
		{"atk": 12, "matk": 12, "hp": 20, "mana": 20},
		[{"item_id": "mythril_ingot", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 480,
		"Un anneau d'une finesse remarquable aux propriétés universelles.")

	_acc("anneau_dragon",   "Anneau du Dragon",    "anneau", "A",
		{"atk": 18, "matk": 18, "hp": 35, "crit": 8},
		[{"item_id": "mythril_ingot", "qty": 3}, {"item_id": "dragon_scale", "qty": 1}, {"item_id": "ruby_gem", "qty": 1}], 1050,
		"Fondu autour d'une dent de dragon, il pulse d'une puissance ardente.")

	_acc("anneau_roi",      "Anneau Royal",        "anneau", "S",
		{"atk": 25, "matk": 25, "hp": 50, "mana": 50, "crit": 12, "spd": 8},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "soul_gem", "qty": 1}], 2500,
		"L'anneau qu'arborait le premier roi de Valoria. Son aura est palpable.")

	## ── AMULETTES ─────────────────────────────────────────────────────────────
	_acc("amulette_bois",   "Amulette de Bois",    "amulette", "F",
		{"mdef": 5},
		[{"item_id": "wood_log", "qty": 2}, {"item_id": "leather", "qty": 1}], 10,
		"Une amulette sculptée dans du bois béni par un guérisseur itinérant.")

	_acc("amulette_vie",    "Amulette de Vie",     "amulette", "D",
		{"hp": 20, "def": 5},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "life_crystal", "qty": 1}], 100,
		"Pulse doucement, accordant de la vitalité à son porteur.")

	_acc("amulette_magie",  "Amulette Arcanique",  "amulette", "D",
		{"mana": 25, "mdef": 10},
		[{"item_id": "iron_ingot", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 105,
		"Absorbe une partie des énergies magiques ennemies.")

	_acc("amulette_gardien","Amulette du Gardien", "amulette", "B",
		{"def": 15, "mdef": 20, "hp": 30},
		[{"item_id": "mythril_ingot", "qty": 2}, {"item_id": "life_crystal", "qty": 2}], 520,
		"Un disque de mythril gravé du sceau du gardien éternel.")

	_acc("amulette_destin", "Amulette du Destin",  "amulette", "S",
		{"hp": 60, "mana": 60, "def": 20, "mdef": 30, "crit": 10},
		[{"item_id": "orichalcum_ingot", "qty": 2}, {"item_id": "soul_gem", "qty": 1}, {"item_id": "arcane_crystal", "qty": 3}], 2700,
		"Son porteur semble guidé par une force mystérieuse vers la victoire.")

	## ── CEINTURES ─────────────────────────────────────────────────────────────
	_acc("ceinture_cuir",   "Ceinture de Cuir",    "ceinture", "E",
		{"hp": 8, "spd": 2},
		[{"item_id": "leather", "qty": 3}], 20,
		"Robuste et pratique, elle maintient l'équipement du héros en place.")

	_acc("ceinture_force",  "Ceinture de Force",   "ceinture", "C",
		{"atk": 10, "hp": 15},
		[{"item_id": "refined_leather", "qty": 3}, {"item_id": "iron_ingot", "qty": 1}], 185,
		"Renforcée de métal, elle canalise la force dans les coups du porteur.")

	_acc("ceinture_titan",  "Ceinture du Titan",   "ceinture", "A",
		{"atk": 20, "def": 15, "hp": 40},
		[{"item_id": "mythril_ingot", "qty": 2}, {"item_id": "dragon_scale", "qty": 1}, {"item_id": "refined_leather", "qty": 2}], 1000,
		"La ceinture d'un champion légendaire. Sa boucle en mythril brille de mille feux.")


# ─────────────────────────────────────────────
#  CONSOMMABLES (POTIONS)
# ─────────────────────────────────────────────
func _register_consumables() -> void:

	## ── SOINS ─────────────────────────────────────────────────────────────────
	_cons("potion_soin_mineure", "Potion de Soin Mineure", "potion_soin",
		{},
		[{"type": "heal", "value": 20, "duration": 0}],
		[{"item_id": "medicinal_plant", "qty": 2}, {"item_id": "water", "qty": 1}], 18,
		"Restaure 20 PV immédiatement. La base de tout aventurier.")

	_cons("potion_soin", "Potion de Soin", "potion_soin",
		{},
		[{"type": "heal", "value": 50, "duration": 0}],
		[{"item_id": "medicinal_plant", "qty": 3}, {"item_id": "rare_herbs", "qty": 1}, {"item_id": "water", "qty": 1}], 45,
		"Restaure 50 PV immédiatement.")

	_cons("potion_soin_majeure", "Potion de Soin Majeure", "potion_soin",
		{},
		[{"type": "heal", "value": 120, "duration": 0}],
		[{"item_id": "medicinal_plant", "qty": 4}, {"item_id": "rare_herbs", "qty": 2}, {"item_id": "magic_essence", "qty": 1}], 100,
		"Restaure 120 PV instantanément. Pour les situations désespérées.")

	_cons("elixir_vie", "Élixir de Vie", "potion_soin",
		{},
		[{"type": "heal", "value": 999, "duration": 0}],
		[{"item_id": "rare_herbs", "qty": 5}, {"item_id": "arcane_crystal", "qty": 2}, {"item_id": "life_crystal", "qty": 1}], 400,
		"Restaure la totalité des PV. Extrêmement précieux.")

	## ── MANA ──────────────────────────────────────────────────────────────────
	_cons("potion_mana_mineure", "Potion de Mana Mineure", "potion_mana",
		{},
		[{"type": "restore_mana", "value": 15, "duration": 0}],
		[{"item_id": "arcane_dust", "qty": 2}, {"item_id": "water", "qty": 1}], 20,
		"Restaure 15 points de mana. Utile pour prolonger les sorts.")

	_cons("potion_mana", "Potion de Mana", "potion_mana",
		{},
		[{"type": "restore_mana", "value": 40, "duration": 0}],
		[{"item_id": "arcane_dust", "qty": 3}, {"item_id": "magic_essence", "qty": 1}, {"item_id": "water", "qty": 1}], 50,
		"Restaure 40 points de mana.")

	_cons("potion_mana_majeure", "Potion de Mana Majeure", "potion_mana",
		{},
		[{"type": "restore_mana", "value": 100, "duration": 0}],
		[{"item_id": "arcane_crystal", "qty": 2}, {"item_id": "magic_essence", "qty": 2}], 110,
		"Restaure 100 points de mana d'un coup.")

	## ── FORCE ─────────────────────────────────────────────────────────────────
	_cons("potion_force", "Potion de Force", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "atk", "value": 15, "duration": 300}],
		[{"item_id": "mushroom", "qty": 2}, {"item_id": "medicinal_plant", "qty": 1}], 35,
		"Augmente l'ATK de 15 pendant 5 minutes.")

	_cons("potion_vigueur", "Potion de Vigueur", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "def", "value": 12, "duration": 300}],
		[{"item_id": "mushroom", "qty": 2}, {"item_id": "medicinal_plant", "qty": 1}], 35,
		"Augmente la DEF de 12 pendant 5 minutes.")

	_cons("potion_rapidite", "Potion de Rapidité", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "spd", "value": 15, "duration": 180}],
		[{"item_id": "butterfly_wing", "qty": 1}, {"item_id": "arcane_dust", "qty": 1}], 40,
		"Augmente la vitesse de 15 pendant 3 minutes.")

	_cons("potion_acuite", "Potion d'Acuité", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "matk", "value": 15, "duration": 300}],
		[{"item_id": "arcane_dust", "qty": 2}, {"item_id": "rare_herbs", "qty": 1}], 45,
		"Augmente l'MATK de 15 pendant 5 minutes.")

	_cons("potion_chanceux", "Élixir de Chance", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "crit", "value": 10, "duration": 240}],
		[{"item_id": "luck_stone", "qty": 1}, {"item_id": "rare_herbs", "qty": 1}], 55,
		"Augmente le taux de critique de 10 % pendant 4 minutes.")

	## ── ANTIDOTES / UTILITAIRES ────────────────────────────────────────────────
	_cons("antidote", "Antidote", "potion_utilitaire",
		{},
		[{"type": "cure_status", "status": "poison", "duration": 0}],
		[{"item_id": "medicinal_plant", "qty": 2}, {"item_id": "water", "qty": 1}], 22,
		"Neutralise instantanément le venin et les poisons.")

	_cons("baume_brulure", "Baume contre les Brûlures", "potion_utilitaire",
		{},
		[{"type": "cure_status", "status": "burn", "duration": 0}],
		[{"item_id": "aloe_vera", "qty": 2}, {"item_id": "water", "qty": 1}], 22,
		"Apaise immédiatement la douleur des brûlures.")

	_cons("sel_reveil", "Sels de Réveil", "potion_utilitaire",
		{},
		[{"type": "cure_status", "status": "stun", "duration": 0}],
		[{"item_id": "salt", "qty": 2}, {"item_id": "arcane_dust", "qty": 1}], 25,
		"Tire instantanément un allié de l'étourdissement.")

	_cons("potion_regeneration", "Potion de Régénération", "potion_soin",
		{},
		[{"type": "heal_over_time", "value": 5, "duration": 600}],
		[{"item_id": "rare_herbs", "qty": 2}, {"item_id": "life_crystal", "qty": 1}, {"item_id": "water", "qty": 1}], 90,
		"Régénère 5 PV par seconde pendant 10 minutes.")

	_cons("elixir_puissance", "Élixir de Toute-Puissance", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "atk", "value": 30, "duration": 120},
		 {"type": "stat_buff", "stat": "matk", "value": 30, "duration": 120},
		 {"type": "stat_buff", "stat": "spd", "value": 20, "duration": 120}],
		[{"item_id": "arcane_crystal", "qty": 2}, {"item_id": "rare_herbs", "qty": 3}, {"item_id": "life_crystal", "qty": 1}], 250,
		"Une explosion de puissance brute pendant 2 minutes. Épuise totalement ensuite.")

	_cons("potion_invisible", "Potion d'Invisibilité", "potion_utilitaire",
		{},
		[{"type": "apply_status", "status": "invisible", "duration": 60}],
		[{"item_id": "shadow_essence", "qty": 2}, {"item_id": "arcane_dust", "qty": 1}], 120,
		"Rend le héros invisible pendant 60 secondes. Utile pour les embuscades.")

	_cons("potion_berserker", "Potion du Berserker", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "atk", "value": 50, "duration": 90},
		 {"type": "stat_buff", "stat": "def", "value": -20, "duration": 90}],
		[{"item_id": "troll_hide", "qty": 1}, {"item_id": "mushroom", "qty": 2}, {"item_id": "rare_herbs", "qty": 1}], 150,
		"Décuple la rage du héros pendant 90s mais le rend vulnérable.")

	_cons("elixir_protection", "Élixir de Protection", "potion_buff",
		{},
		[{"type": "stat_buff", "stat": "def", "value": 30, "duration": 180},
		 {"type": "stat_buff", "stat": "mdef", "value": 30, "duration": 180}],
		[{"item_id": "life_crystal", "qty": 1}, {"item_id": "medicinal_plant", "qty": 3}, {"item_id": "iron_ingot", "qty": 1}], 180,
		"Renforce l'armure physique et magique du héros pendant 3 minutes.")

	_cons("potion_resurrection", "Potion de Résurrection", "potion_soin",
		{},
		[{"type": "prevent_death", "heal_percent": 30, "duration": 0}],
		[{"item_id": "soul_gem", "qty": 1}, {"item_id": "life_crystal", "qty": 2}, {"item_id": "arcane_crystal", "qty": 1}], 600,
		"Si le héros tombe à 0 PV, la potion se brise et le ressuscite à 30 % de ses PV.")
