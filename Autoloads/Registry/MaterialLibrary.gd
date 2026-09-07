## MaterialLibrary.gd — Autoload
## Registre de toutes les ressources/matériaux du jeu.
##
## Structure d'une entrée :
##   id              : String   — identifiant unique
##   label           : String   — nom affiché
##   description     : String
##   category        : String   — "natural" | "craftable" | "magical" | "mob_drop" | "culinary"
##   value           : int      — valeur de vente de base (en or)
##   texture         : String   — chemin icône (res://Assets/Resources/{id}.png)
##   recipe          : Array    — [{ "item_id": String, "qty": int }]  (vide si non craftable)
##   craft_location  : String   — objet de craft requis ("" si non craftable)
##   craft_time      : float    — durée en heures (0 si non craftable)
extends Node


var _materials : Dictionary = {}


func _ready() -> void:
	_register_natural()
	_register_craftable()
	_register_magical()
	_register_mob_drops()
	_register_culinary()


# ─────────────────────────────────────────────
#  RESSOURCES NATURELLES (brutes)
# ─────────────────────────────────────────────
func _register_natural() -> void:

	_raw("wood_log",        "Bois",             2,
		"Utilisé pour les constructions basiques et armes simples.")
	_raw("stone",           "Pierre",           3,
		"Nécessaire pour fortifications, outils ou socles.")
	_raw("flax",            "Lin",              2,
		"Textile de base pour vêtements et tissus.")
	_raw("water",           "Eau",              1,
		"Sert à la fabrication d'objets alchimiques ou potions.")
	_raw("salt",            "Sel",              1,
		"Pour le tannage et la conservation de nourriture.")
	_raw("black_berry",     "Baie noire",       1,
		"Sert à fabriquer des équipements et potions.")
	_raw("medicinal_plant", "Plante médicinale", 3,
		"Pour crafter des potions.")
	_raw("amber",           "Ambre",            11,
		"Résine fossile aux propriétés conductrices de magie et d'énergie.")
	_raw("sticky_resin",    "Résine collante",   5,
		"Résine épaisse issue de certains arbres magiques. Utilisée comme liant alchimique.")
	_raw("iron_ore",        "Minerai de fer",    3,
		"Minerai brut extrait des roches ferreuses, à raffiner pour obtenir des lingots.")
	_raw("magic_ore",       "Minerai magique",   8,
		"Minerai imprégné d'énergie arcanique. Nécessaire pour les équipements de rang B+.")
	_raw("animal_fat",      "Graisse animale",   3,
		"Matière grasse issue des animaux, utilisée pour l'alchimie et la cuisine.")
	_raw("raw_hide",        "Peau brute",        3,
		"Morceau de cuir non traité récupéré sur des créatures. Nécessite un tannage.")
	_raw("sand",            "Sable",             2,
		"Granulat fin extrait des plages. Utilisé pour fabriquer du verre.")
	_raw("arcane_dust",     "Poussière arcanique", 4,
		"Fine poudre magique récupérée sur certains monstres. Utilisée dans les équipements légers.")
	_raw("butterfly_wing", "Aile de papillon",    3,
		"Aile légère aux propriétés de célérité. Ingrédient pour potions de vitesse.")
	_raw("luck_stone",     "Pierre de chance",    6,
		"Petite pierre porte-bonheur chargée d'une légère énergie magique.")
	_raw("aloe_vera",      "Aloé Véra",           3,
		"Plante cactée aux propriétés apaisantes. Utilisée dans les baumes de brûlure.")


# ─────────────────────────────────────────────
#  MATÉRIAUX ARTISANAUX (craftables)
# ─────────────────────────────────────────────
func _register_craftable() -> void:

	## ── COUTURE / TEXTILE ──────────────────────────────────────────────────────
	_craft("rope",              "Corde",               3,  "atelier",          1.0,
		"Utilisée pour arcs, outils, armures.",
		[_ing("flax", 3)])

	_craft("resistant_thread",  "Fil résistant",       4,  "atelier",          2.0,
		"Renforce les vêtements.",
		[_ing("flax", 2), _ing("sticky_resin", 1)])

	_craft("cloth",             "Tissu",               3,  "metier_a_tisser",  1.0,
		"Tissu brut pour équipements légers.",
		[_ing("flax", 2)])

	_craft("reinforced_cloth",  "Tissu renforcé",      3,  "metier_a_tisser",  2.0,
		"Tissu solide pour réaliser des équipements.",
		[_ing("cloth", 1), _ing("resistant_thread", 1)])

	_craft("elven_cloth",       "Tissu elfique",       18, "metier_a_tisser",  4.0,
		"Tissu tissé avec des fils enchantés. Utilisé pour les armures de rang A.",
		[_ing("cloth", 3), _ing("arcane_crystal", 2)])

	## ── TANNAGE / CUIR ─────────────────────────────────────────────────────────
	_craft("leather",           "Cuir",                3,  "tannage",          1.0,
		"Cuir brut nettoyé, encore rigide.",
		[_ing("raw_hide", 1), _ing("water", 1)])

	_craft("tanned_leather",    "Cuir tanné",          5,  "tannage",          2.0,
		"Matériau basique pour armures.",
		[_ing("leather", 2), _ing("salt", 1), _ing("water", 1)])

	_craft("refined_leather",   "Cuir souple",         8,  "tannage",          3.0,
		"Version raffinée pour armures moyennes et avancées.",
		[_ing("tanned_leather", 2), _ing("ox_oil", 1)])

	## ── FORGE / MÉTALLURGIE ────────────────────────────────────────────────────
	_craft("charcoal",          "Charbon",             3,  "forge",            1.0,
		"Résidu de combustion essentiel pour fondre les métaux.",
		[_ing("wood_log", 2)])

	_craft("iron_ingot",        "Lingot de fer",       4,  "forge",            2.0,
		"Métal de base pour armes et outils.",
		[_ing("iron_ore", 2)])

	_craft("steel_ingot",       "Lingot d'acier",      6,  "forge",            3.0,
		"Métal solide pour équipements de rang D+.",
		[_ing("iron_ore", 3), _ing("charcoal", 1)])

	_craft("tempered_steel",    "Lingot d'acier trempé", 9, "forge",           4.0,
		"Qualité supérieure pour équipements lourds.",
		[_ing("steel_ingot", 2), _ing("quenching_oil", 1), _ing("sticky_resin", 1), _ing("water", 1)])

	_craft("steel_rivets",      "Rivets en acier",     3,  "forge",            1.0,
		"Sert à assembler certaines armures.",
		[_ing("iron_ore", 1)])

	_craft("glass",             "Verre",               3,  "forge",            2.0,
		"Matériau transparent obtenu par fusion. Utilisé pour flacons, orbes et composants magiques.",
		[_ing("sand", 2), _ing("charcoal", 1)])

	_craft("mythril_ingot",     "Lingot de Mythril",   20, "forge",            5.0,
		"Métal magique légendaire pour équipements de rang A.",
		[_ing("magic_ore", 4), _ing("arcane_crystal", 1)])

	_craft("orichalcum_ingot",  "Lingot d'Orichalque", 40, "forge",            6.0,
		"Le métal le plus rare et le plus puissant. Réservé aux équipements de rang S.",
		[_ing("magic_ore", 3), _ing("dragon_scale", 1), _ing("soul_gem", 1)])

	## ── ATELIER ────────────────────────────────────────────────────────────────
	_craft("reinforced_wood",   "Bois renforcé",       15, "atelier",          2.0,
		"Bois traité et solidifié pour structures ou équipements robustes.",
		[_ing("wood_log", 2), _ing("sticky_resin", 1)])

	## ── ALCHIMIE ───────────────────────────────────────────────────────────────
	_craft("ox_oil",            "Huile de bœuf",       4,  "table_alchimie",   2.0,
		"Produit d'alchimie pour souplesse ou trempage.",
		[_ing("animal_fat", 2), _ing("medicinal_plant", 1)])

	_craft("quenching_oil",     "Huile de trempe",     7,  "table_alchimie",   3.0,
		"Renforce les métaux à haute température.",
		[_ing("ox_oil", 1), _ing("sticky_resin", 1), _ing("water", 1)])

	_craft("wind_essence",      "Essence de vent",     12, "table_alchimie",   4.0,
		"Utilisée dans les objets de vitesse.",
		[_ing("arcane_crystal", 2), _ing("slime_gel", 1)])

	_craft("magic_rune",        "Rune magique",        15, "table_alchimie",   5.0,
		"Active enchantements et grimoires.",
		[_ing("arcane_crystal", 1), _ing("black_berry", 1), _ing("ghost_cloth", 1)])

	_craft("magic_essence",     "Essence magique",     20, "table_alchimie",   4.0,
		"Extrait concentré de magie pure. Nécessaire pour les enchantements de rang A et S.",
		[_ing("magic_ore", 2), _ing("arcane_crystal", 1)])

	## ── CUISINE ────────────────────────────────────────────────────────────────
	_craft("flax_flour",        "Farine de lin",       3,  "four",             1.0,
		"Farine rustique obtenue à partir de graines de lin moulues.",
		[_ing("flax", 2)])


# ─────────────────────────────────────────────
#  MATÉRIAUX MAGIQUES & RARES
# ─────────────────────────────────────────────
func _register_magical() -> void:

	_mob("arcane_crystal",  "Cristaux arcaniques",  8,  "magical",
		"Base de l'enchantement. Droppé par tous les mobs.")
	_mob("shadow_essence",  "Essence d'ombre",      15, "magical",
		"Composant rare pour objets occultes.")
	_mob("ghost_cloth",     "Étoffe fantomatique",  9,  "magical",
		"Pour armures magiques.")
	_mob("spirit_fragment", "Fragment d'esprit",    25, "magical",
		"Élément légendaire. Drop du Seigneur Démoniaque et du Spectre d'Oubli.")
	_mob("soul_gem",        "Gemme d'âme",          30, "magical",
		"Gemme rarissime cristallisant l'essence d'une âme ancienne. Utilisée pour les équipements de rang S.")


# ─────────────────────────────────────────────
#  COMPOSANTS DE MONSTRES (mob drops)
# ─────────────────────────────────────────────
func _register_mob_drops() -> void:

	_mob("slime_gel",       "Gelée de slime",       2,  "mob_drop",
		"Base pour potions simples. Drop du Slime.")
	_mob("goblin_teeth",    "Dents de gobelin",     3,  "mob_drop",
		"Composant d'armes légères. Drop du Gobelin.")
	_mob("berserker_bone",  "Os de berserker",      6,  "mob_drop",
		"Sert aux armes lourdes. Drop de l'Orque Berserker.")
	_mob("venom",           "Venin",                5,  "mob_drop",
		"Sert à empoisonner les armes. Drop de la Vipère et du Basilic.")
	_mob("dragon_scale",    "Écailles de dragon",   10, "mob_drop",
		"Matériau ultra résistant. Drop du Dragonnet de Feu.")
	_mob("flame_heart",     "Cœur de flamme",       15, "mob_drop",
		"Sert à forger des armes élémentaires. Drop rare du Dragonnet.")
	_mob("demon_horn",      "Corne démoniaque",     18, "mob_drop",
		"Trophée. Peu utile en craft, à vendre. Drop du Seigneur Démoniaque.")
	_mob("chaos_shard",     "Éclat du chaos",       20, "mob_drop",
		"Sert pour des fusions chaotiques. Drop du Seigneur Démoniaque.")
	_mob("cyclops_eye",     "Œil de cyclope",       12, "mob_drop",
		"Composant optique rare. Drop rare du Cyclope.")
	_mob("totem_corrompu",  "Totem corrompu",       14, "mob_drop",
		"Artéfact maudit. Drop rare du Chaman Corrompu.")
	_mob("dark_heart",      "Cœur des ténèbres",    22, "mob_drop",
		"Composant démoniaque légendaire. Drop rare du Seigneur Démoniaque.")
	_mob("bone",            "Os",                   1,  "mob_drop",
		"Reste d'un ennemi vaincu. Utilisé pour des armes rudimentaires.")
	_mob("venom_gland",     "Glande à venin",       6,  "mob_drop",
		"Glande extraite d'une créature venimeuse. Sert à créer des armes empoisonnées.")
	_mob("troll_hide",      "Peau de troll",        8,  "mob_drop",
		"Cuir épais et régénérant. Drop de l'Orque/Troll.")
	_mob("storm_crystal",   "Cristal de tempête",   12, "mob_drop",
		"Cristal chargé d'électricité. Drop dans les environnements d'orage.")
	_mob("life_crystal",    "Cristal de vie",       10, "mob_drop",
		"Cristal imprégné d'énergie vitale. Utilisé dans les accessoires de soin.")


# ─────────────────────────────────────────────
#  INGRÉDIENTS CULINAIRES
# ─────────────────────────────────────────────
func _register_culinary() -> void:

	_raw_cat("egg",         "Œuf",                  3,  "culinary",
		"Produit courant des poules, utilisé dans de nombreux plats.")
	_mob("wolf_meat",       "Viande de loup",        6,  "culinary",
		"Viande rouge robuste issue d'un animal sauvage. Drop du Loup.")
	_raw_cat("carrot",      "Carotte",               4,  "culinary",
		"Légume racine sucré et croquant. Cultivé sur les plates-bandes.")
	_raw_cat("cabbage",     "Chou",                  3,  "culinary",
		"Légume trapu cultivé sur plates-bandes. Ingrédient de base.")
	_raw_cat("grain",       "Grain",                 2,  "culinary",
		"Céréale cultivée sur plates-bandes. Base du pain, de la bouillie et de la bière.")
	_raw_cat("wild_berry",  "Baies sauvages",        3,  "culinary",
		"Baies sucrées cultivées sur plates-bandes. Utilisées en cuisine et confiture.")
	_raw_cat("raw_meat",    "Viande crue",           5,  "culinary",
		"Morceau de viande générique. Achetable au marché ou drop de certains animaux.")
	_raw_cat("fish",        "Poisson",               4,  "culinary",
		"Poisson frais. Achetable au marché ou pêché dans les niveaux aquatiques.")
	_raw_cat("mushroom",    "Champignons",           5,  "culinary",
		"Ingrédient de base pour de nombreux plats forestiers.")
	_raw_cat("black_pepper","Piment noir",           8,  "culinary",
		"Épice rare et piquante qui donne du caractère aux plats.")
	_raw_cat("wild_herbs",  "Herbes sauvages",       4,  "culinary",
		"Plantes aromatiques utilisées pour assaisonner ou soigner légèrement.")
	_mob("goblin_meat",     "Viande de gobelin",     5,  "culinary",
		"Chair coriace mais consommable. Drop du Gobelin.")
	_mob("viper_meat",      "Viande de vipère",      6,  "culinary",
		"Viande venimeuse nécessitant une cuisson maîtrisée. Drop de la Vipère.")
	_mob("dragonnet_meat",  "Viande de dragon",      15, "culinary",
		"Morceau précieux et rare, aux propriétés énergétiques. Drop rare du Dragonnet.")
	_mob("boar_meat",       "Viande de sanglier",    15, "culinary",
		"Viande sauvage robuste. Drop du Sanglier.")
	_raw_cat("rare_herbs",  "Herbes rares",          10, "culinary",
		"Ingrédient mystique utilisé dans les plats magiques ou élixirs.")
	_raw_cat("honey",       "Miel",                  2,  "culinary",
		"Récupéré sur les ruches, utilisé dans certains plats et dans la préparation d'hydromel.")
	_raw_cat("hops",        "Houblon",               1,  "culinary",
		"Céréales utilisées notamment dans la préparation de bière.")


# ─────────────────────────────────────────────
#  HELPERS D'ENREGISTREMENT
# ─────────────────────────────────────────────

## Ressource naturelle brute
func _raw(id: String, label: String, value: int, description: String) -> void:
	_raw_cat(id, label, value, "natural", description)

## Ressource brute avec catégorie explicite
func _raw_cat(id: String, label: String, value: int, category: String, description: String) -> void:
	_add(id, label, description, category, value, [], "", 0.0)

## Drop de monstre (ou matériau magique)
func _mob(id: String, label: String, value: int, category: String, description: String) -> void:
	_add(id, label, description, category, value, [], "", 0.0)

## Matériau craftable
func _craft(id: String, label: String, value: int, craft_location: String,
		craft_time: float, description: String, recipe: Array) -> void:
	_add(id, label, description, "craftable", value, recipe, craft_location, craft_time)

## Ingrédient de recette
func _ing(item_id: String, qty: int) -> Dictionary:
	return {"item_id": item_id, "qty": qty}

func _add(id: String, label: String, description: String, category: String,
		value: int, recipe: Array, craft_location: String, craft_time: float) -> void:
	_materials[id] = {
		"id":             id,
		"label":          label,
		"description":    description,
		"category":       category,
		"value":          value,
		"texture":        "res://Assets/Resources/%s.png" % id,
		"recipe":         recipe,
		"craft_location": craft_location,
		"craft_time":     craft_time,
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_material(id: String) -> Dictionary:
	return _materials.get(id, {})

func get_all() -> Array:
	return _materials.values()

func get_by_category(category: String) -> Array:
	var result : Array = []
	for mat in _materials.values():
		if mat["category"] == category:
			result.append(mat)
	return result

## Vrai si le matériau est craftable (a une recette)
func is_craftable(id: String) -> bool:
	var mat : Dictionary = get_material(id)
	return not mat.is_empty() and not mat["recipe"].is_empty()

## Valeur de vente total d'un stack
func get_stack_value(id: String, qty: int) -> int:
	return get_material(id).get("value", 0) * qty

## Vérifie si un inventaire (Dictionary id→qty) contient les matériaux d'une recette
func can_craft(id: String, inventory: Dictionary) -> bool:
	var mat : Dictionary = get_material(id)
	if mat.is_empty() or mat["recipe"].is_empty():
		return false
	for ing in mat["recipe"]:
		if inventory.get(ing["item_id"], 0) < ing["qty"]:
			return false
	return true
