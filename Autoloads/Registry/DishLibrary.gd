## DishLibrary.gd — Autoload
## Registre des 11 recettes de cuisine produites au fourneau.
## Les plats restaurent la faim et accordent un buff temporaire au héros.
##
## Structure d'une entrée :
##   id           : String        — identifiant unique (utilisé dans GuildInventoryManager)
##   label        : String        — nom affiché
##   satiety      : float         — points de faim restaurés (0–100)
##   buff         : Dictionary    — { "stat": String, "value": float, "duration_days": float }
##                                  stat : "strength"|"defense"|"agility"|"magic"|"luck"|"moral"
##   recipe       : Array         — [{ "item_id": String, "qty": int }]  (ingrédients GuildInventory)
##   cook_time    : float         — secondes de cuisson réels (à GameConfig.COOK_SPEED)
##   price        : int           — valeur en or si vendu
##   description  : String
extends Node


var _dishes : Dictionary = {}


func _ready() -> void:
	_register_dishes()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_dish(id: String) -> Dictionary:
	return _dishes.get(id, {})


func get_all() -> Dictionary:
	return _dishes


func get_all_list() -> Array:
	return _dishes.values()


# ─────────────────────────────────────────────
#  HELPER
# ─────────────────────────────────────────────
func _d(id: String, label: String, satiety: float, buff: Dictionary,
		recipe: Array, cook_time: float, price: int, desc: String) -> void:
	_dishes[id] = {
		"id":          id,
		"label":       label,
		"satiety":     satiety,
		"buff":        buff,
		"recipe":      recipe,
		"cook_time":   cook_time,
		"price":       price,
		"description": desc,
	}


# ─────────────────────────────────────────────
#  RECETTES (11 plats)
# ─────────────────────────────────────────────
func _register_dishes() -> void:

	## ── SIMPLES ────────────────────────────────────────────────────────────
	_d("bouillie_avoine", "Bouillie d'Avoine", 25.0,
		{"stat": "energy_regen", "value": 0.0, "duration_days": 0.0},  ## pas de buff — simple nourriture
		[{"item_id": "grain",  "qty": 2}, {"item_id": "water", "qty": 1}],
		30.0, 3,
		"La base de l'alimentation des héros débutants. Rassasie un peu sans effets particuliers.")

	_d("soupe_legumes", "Soupe de Légumes", 35.0,
		{"stat": "defense", "value": 2.0, "duration_days": 1.0},
		[{"item_id": "carrot", "qty": 2}, {"item_id": "cabbage", "qty": 1}, {"item_id": "water", "qty": 1}],
		45.0, 5,
		"Une soupe réconfortante. +2 DEF pendant 1 jour.")

	_d("pain_de_campagne", "Pain de Campagne", 30.0,
		{"stat": "", "value": 0.0, "duration_days": 0.0},
		[{"item_id": "grain", "qty": 3}, {"item_id": "salt", "qty": 1}],
		60.0, 4,
		"Simple mais nutritif. Tient les héros en forme pour une journée.")

	## ── PLATS MIJOTÉS ──────────────────────────────────────────────────────
	_d("ragout_viande", "Ragoût de Viande", 55.0,
		{"stat": "strength", "value": 5.0, "duration_days": 1.0},
		[{"item_id": "raw_meat",  "qty": 2}, {"item_id": "carrot", "qty": 1}, {"item_id": "wild_herbs", "qty": 1}],
		90.0, 12,
		"Un ragoût roboratif. +5 Force pendant 1 jour.")

	_d("grillades_champion", "Grillades du Champion", 60.0,
		{"stat": "strength", "value": 8.0, "duration_days": 1.5},
		[{"item_id": "raw_meat",  "qty": 3}, {"item_id": "salt",  "qty": 1}, {"item_id": "wild_herbs", "qty": 1}],
		120.0, 18,
		"De la viande grillée à la perfection. +8 Force pendant 1,5 jours.")

	_d("poisson_fume", "Poisson Fumé", 45.0,
		{"stat": "agility", "value": 5.0, "duration_days": 1.0},
		[{"item_id": "fish", "qty": 2}, {"item_id": "salt", "qty": 1}],
		75.0, 10,
		"Fumé lentement sur des braises aromatiques. +5 Agilité pendant 1 jour.")

	_d("tourte_gibier", "Tourte au Gibier", 70.0,
		{"stat": "luck", "value": 6.0, "duration_days": 2.0},
		[{"item_id": "raw_meat",  "qty": 2}, {"item_id": "grain", "qty": 2}, {"item_id": "wild_herbs", "qty": 2}],
		150.0, 22,
		"Recette ancestrale. +6 Chance pendant 2 jours. La fortune sourit au gourmand.")

	## ── PLATS MAGIQUES / SPÉCIAUX ──────────────────────────────────────────
	_d("elixir_miel_herbes", "Élixir Miel & Herbes", 40.0,
		{"stat": "magic", "value": 8.0, "duration_days": 1.0},
		[{"item_id": "honey",    "qty": 2}, {"item_id": "rare_herbs", "qty": 1}, {"item_id": "water", "qty": 1}],
		90.0, 20,
		"Un mélange odorant qui éveille les sens arcaniques. +8 Magie pendant 1 jour.")

	_d("biere_houblon", "Bière de Houblon", 30.0,
		{"stat": "moral", "value": 20.0, "duration_days": 0.5},
		[{"item_id": "hops",  "qty": 2}, {"item_id": "grain", "qty": 1}, {"item_id": "water", "qty": 2}],
		180.0, 8,
		"Une bière mousseuse brassée sur place. +20 Moral pendant 12h. (L'ivresse modérée reste modérée.)")

	_d("festin_royal", "Festin Royal", 90.0,
		{"stat": "strength", "value": 6.0, "duration_days": 2.0},
		[{"item_id": "raw_meat",  "qty": 3}, {"item_id": "rare_herbs", "qty": 2},
		 {"item_id": "honey", "qty": 1}, {"item_id": "salt", "qty": 1}],
		240.0, 40,
		"Digne d'un roi. Restaure presque toute la faim. +6 Force pendant 2 jours.")

	_d("confiture_baies", "Confiture de Baies", 20.0,
		{"stat": "agility", "value": 3.0, "duration_days": 1.0},
		[{"item_id": "wild_berry", "qty": 3}, {"item_id": "honey", "qty": 1}],
		45.0, 6,
		"Sucrée et légère. +3 Agilité pendant 1 jour. Appréciée par les roublards.")
