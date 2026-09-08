## ItemRegistry.gd — Autoload #9
## Registre centralisé de tous les items plaçables dans la guilde :
## murs, sols, objets utilisables.
##
## Champs communs à chaque item :
##   id               : String  — identifiant unique
##   label            : String  — nom affiché dans l'UI
##   type             : String  — "wall" | "door" | "floor" | "object"
##   cost             : int     — coût en or
##   texture          : String  — chemin vers la texture (res://Assets/…)
##   region           : Rect2   — région dans l'atlas
##   unlock_research  : String  — id de recherche requise ("" = disponible dès le début)
##
## Champs spécifiques aux murs/sols :
##   atlas_id         : int     — couche dans le TileSet
##   size             : Vector2 — toujours Vector2.ONE
##
## Champs spécifiques aux objets :
##   job              : int     — job héros associé (0 = pas de job requis)
##   size             : Vector2 — taille en tuiles
##   room             : String  — salle de destination (pour le tri UI)
extends Node


# ─────────────────────────────────────────────
#  DONNÉES
# ─────────────────────────────────────────────
var walls   : Dictionary = {}
var floors  : Dictionary = {}
var objects : Dictionary = {}


func _ready() -> void:
	_build_registry()


func _build_registry() -> void:

	# ── MURS ─────────────────────────────────────────────────────────────────
	_add_wall("stone_wall",  "Mur en pierre", 15, "res://Assets/Tiles/stone_wall.png",  Rect2(0, 48, 16, 16), 0)
	_add_wall("wood_wall",   "Mur en bois",   10, "res://Assets/Tiles/wooden_wall.png", Rect2(0, 48, 16, 16), 1)

	# ── PORTES ───────────────────────────────────────────────────────────────
	_add_door("wooden_door",     "Porte en bois",    20, "res://Assets/Tiles/wooden_door.png",       Rect2(0, 0, 16, 16), 2)
	_add_door("reinforced_door", "Porte renforcée",  25, "res://Assets/Objects/reinforced_door.png", Rect2(0, 0, 16, 16), 3)

	# ── SOLS ──────────────────────────────────────────────────────────────────
	_add_floor("dirt",        "Terre",          0,  "res://Assets/Tiles/dirt_floor.png",  Rect2(16, 16, 16, 16), 0)
	_add_floor("grass",       "Herbe",          0,  "res://Assets/Tiles/grass_floor.png", Rect2(32, 0,  16, 16), 1)
	_add_floor("stone_floor", "Dallage pierre", 15, "res://Assets/Tiles/stone_floor.png", Rect2(0,  0,  16, 16), 2)
	_add_floor("wood_floor",  "Plancher bois",  10, "res://Assets/Tiles/wood_floor.png",  Rect2(0,  0,  16, 16), 3)
	_add_floor("gravel",      "Gravier",         8, "res://Assets/Tiles/dirt_floor.png",  Rect2(16, 16, 16, 16), 4)  ## texture provisoire

	# ── HALL ──────────────────────────────────────────────────────────────────
	_add_object("quest_board",    "Tableau des quêtes",    150, Vector2(3,2), 0, "res://Assets/Objects/bounty_board.png",   Rect2(0,0,32,32), "", "hall")
	_add_object("reception_desk", "Comptoir de réception", 200, Vector2(4,2), 1, "res://Assets/Objects/reception_desk.png", Rect2(0,0,64,32), "", "hall")
	_add_object("table",          "Table en bois",          75, Vector2(4,2), 0, "res://Assets/Objects/table.png",          Rect2(0,0,64,32), "menuiserie", "hall")
	_add_object("drink_barrel",   "Baril de boisson",       50, Vector2(1,2), 0, "", Rect2(), "brassage", "hall")
	_add_object("reception_bell", "Cloche de réception",    20, Vector2(1,1), 0, "", Rect2(), "ameublement", "hall")
	_add_object("serving_table",  "Self (buffet)",           50, Vector2(4,2), 0, "res://Assets/Objects/serving_table.png",  Rect2(0,0,64,32), "", "hall")

	# ── CHAMBRE ───────────────────────────────────────────────────────────────
	_add_object("bed",               "Lit simple",        120, Vector2(1,2), 0, "res://Assets/Objects/bed_bottom.png", Rect2(0,0,16,32), "", "chambre")
	_add_object("personal_wardrobe", "Placard personnel",  60, Vector2(1,2), 0, "", Rect2(), "menuiserie", "chambre")
	_add_object("shelf",             "Étagère",            40, Vector2(2,1), 0, "", Rect2(), "menuiserie", "chambre")

	# ── FORGE ─────────────────────────────────────────────────────────────────
	_add_object("forge",          "Forge",                  300, Vector2(2,2), 2, "res://Assets/Objects/forge.png", Rect2(0,0,32,32), "forge_basique",      "forge")
	_add_object("anvil",          "Enclume",                180, Vector2(2,2), 0, "res://Assets/Objects/anvil.png", Rect2(32,0,16,16), "forge_basique",     "forge")
	_add_object("bellows",        "Soufflet",               100, Vector2(1,2), 0, "", Rect2(), "forge_avancee",      "forge")
	_add_object("tools_rack",     "Râtelier à outils",       80, Vector2(2,2), 0, "", Rect2(), "forge_maitre",       "forge")
	_add_object("schema_library", "Bibliothèque de schémas", 60, Vector2(2,2), 0, "", Rect2(), "forge_haute_qualite","forge")

	# ── COUTURE ───────────────────────────────────────────────────────────────
	_add_object("loom",             "Métier à tisser",    120, Vector2(1,2), 0, "res://Assets/Objects/loom.png",         Rect2(0,0,16,32), "couture_rudimentaire", "couture")
	_add_object("sewing_table",     "Table de couture",    75, Vector2(2,2), 0, "", Rect2(), "couture_rudimentaire", "couture")
	_add_object("fabric_wardrobe",  "Armoire à tissus",    60, Vector2(1,2), 0, "", Rect2(), "tannage_avance",       "couture")
	_add_object("mannequin_sewing", "Mannequin couture",   40, Vector2(1,2), 0, "", Rect2(), "armurier_agile",       "couture")
	_add_object("spinning_wheel",   "Rouet",              100, Vector2(1,2), 0, "", Rect2(), "tissage_renforce",     "couture")
	_add_object("tanning_rack",     "Chevalet de tannage", 90, Vector2(1,2), 0, "res://Assets/Objects/tanning_rack.png", Rect2(0,0,16,32), "armurier_agile", "couture")

	# ── ATELIER ───────────────────────────────────────────────────────────────
	_add_object("workbench_craft",   "Établi de craft",      140, Vector2(2,2), 0, "res://Assets/Objects/workbench.png",          Rect2(0,0,32,32), "artisanat_general",  "atelier")
	_add_object("tool_chest",        "Coffre à outils",       65, Vector2(1,2), 0, "", Rect2(), "ameublement",        "atelier")
	_add_object("recycling_station", "Atelier de recyclage", 100, Vector2(2,2), 0, "res://Assets/Objects/recycling_workshop.png", Rect2(0,0,32,32), "recyclage_primaire", "atelier")

	# ── INFIRMERIE ────────────────────────────────────────────────────────────
	_add_object("medical_bed",       "Lit médical",    130, Vector2(1,2), 0, "", Rect2(), "medecine",        "infirmerie")
	_add_object("medical_desk",      "Bureau médical",  80, Vector2(2,2), 0, "", Rect2(), "medecine",        "infirmerie")
	_add_object("examination_table", "Table d'examen",  90, Vector2(2,2), 0, "", Rect2(), "soins_innovants", "infirmerie")

	# ── ENTRAÎNEMENT ──────────────────────────────────────────────────────────
	_add_object("training_dummy", "Mannequin de combat", 120, Vector2(1,2), 0, "res://Assets/Objects/training_dummy.png", Rect2(0,0,16,32), "entrainement_martial", "entrainement")
	_add_object("weights",        "Haltères",             70, Vector2(1,2), 0, "", Rect2(), "entrainement_martial", "entrainement")
	_add_object("wooden_target",  "Cible en bois",        60, Vector2(1,2), 0, "", Rect2(), "entrainement_martial", "entrainement")
	_add_object("sandbags",       "Sacs de sable",        50, Vector2(2,1), 0, "", Rect2(), "entrainement_martial", "entrainement")

	# ── ALCHIMIE ──────────────────────────────────────────────────────────────
	_add_object("alchemy_table",  "Établi d'alchimie", 160, Vector2(2,2), 3, "", Rect2(), "alchimie_basique", "alchimie")
	_add_object("magic_cauldron", "Chaudron magique",  120, Vector2(1,2), 0, "", Rect2(), "alchimie_avancee", "alchimie")

	# ── ARCANUM ───────────────────────────────────────────────────────────────
	_add_object("research_desk",     "Bureau de recherche",    120, Vector2(2,2), 4, "", Rect2(), "",                     "arcanum")
	_add_object("enchanted_desk",    "Bureau enchanté",        120, Vector2(2,2), 0, "", Rect2(), "entrainement_magique", "arcanum")
	_add_object("runic_globe",       "Globe runique",           80, Vector2(1,1), 0, "", Rect2(), "ameublement",          "arcanum")
	_add_object("enchantment_altar", "Autel d'enchantement",    50, Vector2(2,2), 0, "", Rect2(), "enchantement",         "arcanum")
	_add_object("lectern",           "Lutrin",                  25, Vector2(1,2), 0, "", Rect2(), "ameublement",          "arcanum")

	# ── JARDIN ────────────────────────────────────────────────────────────────
	_add_object("planting_beds",     "Plates-bandes",    50, Vector2(4,2), 0, "", Rect2(), "jardin_botanique",    "jardin")
	_add_object("compost_bin",       "Bac de compost",   60, Vector2(1,2), 0, "", Rect2(), "agriculture_avancee", "jardin")
	_add_object("magic_watering_can","Arrosoir magique",  80, Vector2(1,1), 0, "", Rect2(), "agriculture_avancee", "jardin")

	# ── SALLE D'ASCENSION ─────────────────────────────────────────────────────
	_add_object("ascension_altar", "Autel d'évolution",  200, Vector2(2,2), 0, "", Rect2(), "salle_ascension", "ascension")
	_add_object("ancient_relics",  "Reliques anciennes", 120, Vector2(2,2), 0, "", Rect2(), "salle_ascension", "ascension")
	_add_object("ceremony_carpet", "Tapis de cérémonie",  50, Vector2(4,2), 0, "", Rect2(), "salle_ascension", "ascension")

	# ── LOISIRS ───────────────────────────────────────────────────────────────
	_add_object("luth",       "Instrument de musique", 60, Vector2(1,2), 0, "res://Assets/Objects/luth.png", Rect2(0,0,16,32), "",              "loisirs")
	_add_object("chess_board","Plateau d'échecs",       70, Vector2(2,2), 0, "", Rect2(), "divertissement", "loisirs")
	_add_object("game_table", "Table de jeu",           50, Vector2(2,2), 0, "", Rect2(), "divertissement", "loisirs")

	# ── SANITAIRES ────────────────────────────────────────────────────────────
	_add_object("toilet", "Latrines",   40, Vector2(1,2), 0, "res://Assets/Objects/toilet.png", Rect2(0,0,16,32), "", "sanitaires")
	_add_object("sink",   "Lave-mains", 25, Vector2(1,2), 0, "res://Assets/Objects/sink.png",   Rect2(0,0,16,32), "", "sanitaires")

	# ── CUISINE ───────────────────────────────────────────────────────────────
	_add_object("furnace",             "Fourneau",              150, Vector2(1,2), 5, "res://Assets/Objects/furnace.png", Rect2(32,0,16,16), "",          "cuisine")
	_add_object("kitchen_counter",     "Plan de travail",        80, Vector2(2,1), 0, "", Rect2(), "ameublement", "cuisine")
	_add_object("kitchen_sink",        "Évier rustique",         90, Vector2(1,2), 0, "", Rect2(), "ameublement", "cuisine")
	_add_object("fermentation_barrel", "Baril de fermentation", 120, Vector2(1,2), 0, "", Rect2(), "brassage",    "cuisine")

	# ── DÉCORATIF ─────────────────────────────────────────────────────────────
	_add_object("statue",            "Statue de héros",     150, Vector2(1,2), 0, "", Rect2(), "esthetique", "decoratif")
	_add_object("fountain",          "Fontaine décorative", 120, Vector2(2,2), 0, "", Rect2(), "esthetique", "decoratif")
	_add_object("royal_carpet",      "Tapis rouge royal",    80, Vector2(4,2), 0, "", Rect2(), "esthetique", "decoratif")
	_add_object("decorative_carpet", "Tapis décoratif",      35, Vector2(2,2), 0, "", Rect2(), "esthetique", "decoratif")
	_add_object("torch",             "Torche / chandelier",  30, Vector2(1,1), 0, "res://Assets/Objects/torch.png", Rect2(0,0,16,16), "", "decoratif")


# ─────────────────────────────────────────────
#  HELPERS D'AJOUT
# ─────────────────────────────────────────────

func _add_wall(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	walls[id] = {
		"id": id, "label": label, "type": "wall",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_door(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	walls[id] = {
		"id": id, "label": label, "type": "door",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_floor(id: String, label: String, cost: int, texture: String, region: Rect2, atlas_id: int, unlock: String = "") -> void:
	floors[id] = {
		"id": id, "label": label, "type": "floor",
		"cost": cost, "texture": texture, "region": region, "atlas_id": atlas_id,
		"size": Vector2.ONE, "unlock_research": unlock,
	}


func _add_object(id: String, label: String, cost: int, size: Vector2, job: int,
				 texture: String, region: Rect2, unlock: String = "", room: String = "") -> void:
	objects[id] = {
		"id": id, "label": label, "type": "object",
		"cost": cost, "texture": texture, "region": region,
		"size": size, "job": job,
		"unlock_research": unlock, "room": room,
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_all_walls()   -> Dictionary: return walls
func get_all_floors()  -> Dictionary: return floors
func get_all_objects() -> Dictionary: return objects

func get_item(id: String) -> Dictionary:
	if walls.has(id):   return walls[id]
	if floors.has(id):  return floors[id]
	if objects.has(id): return objects[id]
	return {}

## Retourne tous les objets d'une salle donnée.
func get_objects_for_room(room: String) -> Array:
	var result : Array = []
	for obj in objects.values():
		if obj["room"] == room:
			result.append(obj)
	return result

## Retourne les objets accessibles (unlock vide ou recherche débloquée).
func get_available_objects() -> Array:
	var result : Array = []
	for obj in objects.values():
		var unlock : String = obj.get("unlock_research", "")
		if unlock == "" or ResearchManager.is_unlocked(unlock):
			result.append(obj)
	return result

## Retourne les objets liés à un job (pour affichage UI du job).
func get_objects_for_job(job_id: int) -> Array:
	var result : Array = []
	for obj in objects.values():
		if obj["job"] == job_id:
			result.append(obj)
	return result
