## HeroClassRegistry.gd — Autoload
## Définit toutes les classes de héros : 6 de base, 12 avancées.
##
## Structure d'une entrée :
##   id             : String          — identifiant unique
##   label          : String          — nom affiché
##   description    : String          — texte de présentation
##   advanced_of    : String          — id classe de base ("" si classe de base)
##   skin           : String          — clé spritesheet
##   job            : int             — métier par défaut (0=libre)
##   class_type     : String          — "physique" | "magique"
##   weapon_types   : Array[String]   — catégories d'armes équipables
##   armor_type     : String          — catégorie d'armure équipable
##   stat_range     : { stat → Vector2i(min, max) }  — plage au niveau 1
##   stat_gain      : { stat → gain_par_niveau }
##   secondary_weights : { métier → poids 0–1 }
extends Node


var _classes : Dictionary = {}


func _ready() -> void:
	_register_base_classes()


# ─────────────────────────────────────────────
#  CLASSES DE BASE (6)
# ─────────────────────────────────────────────
func _register_base_classes() -> void:

	## ── GUERRIER ──────────────────────────────────────────────────────────────
	_add("warrior", "Guerrier", "physique",
		"Les Guerriers sont les piliers de la bataille, capables de résister aux coups les plus puissants et de riposter avec une force brute.",
		"", "warrior", 2,
		["epee", "hache"], "lourde",
		{
			"strength": Vector2i(10, 14), "defense": Vector2i(10, 14),
			"agility":  Vector2i(5,  9),  "magic":   Vector2i(3,  7),
			"luck":     Vector2i(5,  10),
		},
		{"strength": 3, "defense": 2, "agility": 1, "magic": 0, "luck": 1},
		{"manual_work": 0.8, "social": 0.1, "occult_work": 0.0, "cooking": 0.1, "knowledge": 0.1}
	)

	## ── MAGE ──────────────────────────────────────────────────────────────────
	_add("mage", "Mage", "magique",
		"Les Mages sont les maîtres des arcanes, lançant des sorts dévastateurs à distance. Fragiles mais puissants.",
		"", "mage", 3,
		["baton", "grimoire"], "legere",
		{
			"strength": Vector2i(3,  7),  "defense": Vector2i(4,  8),
			"agility":  Vector2i(6,  10), "magic":   Vector2i(12, 16),
			"luck":     Vector2i(8,  12),
		},
		{"strength": 0, "defense": 1, "agility": 1, "magic": 4, "luck": 1},
		{"manual_work": 0.0, "social": 0.2, "occult_work": 0.9, "cooking": 0.0, "knowledge": 0.7}
	)





# ─────────────────────────────────────────────
#  HELPER D'ENREGISTREMENT
# ─────────────────────────────────────────────
func _add(
	id           : String,
	label        : String,
	class_type   : String,
	description  : String,
	advanced_of  : String,
	skin         : String,
	job          : int,
	weapon_types : Array,
	armor_type   : String,
	stat_range   : Dictionary,
	stat_gain    : Dictionary,
	secondary_weights : Dictionary
) -> void:
	## stat_base = midpoint des plages (pour la compatibilité avec l'ancien code)
	var stat_base : Dictionary = {}
	for s in stat_range:
		var r : Vector2i = stat_range[s]
		stat_base[s] = int((r.x + r.y) / 2.0)

	_classes[id] = {
		"id":                id,
		"label":             label,
		"class_type":        class_type,
		"description":       description,
		"advanced_of":       advanced_of,
		"skin":              skin,
		"job":               job,
		"weapon_types":      weapon_types,
		"armor_type":        armor_type,
		"stat_range":        stat_range,
		"stat_base":         stat_base,
		"stat_gain":         stat_gain,
		"secondary_weights": secondary_weights,
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_class_by_id(id: String) -> Dictionary:
	return _classes.get(id, {})

func get_all_base_classes() -> Array:
	var result := []
	for c in _classes.values():
		if c["advanced_of"] == "":
			result.append(c)
	return result

func get_advanced_classes_for(base_id: String) -> Array:
	var result : Array = []
	for c in _classes.values():
		if c["advanced_of"] == base_id:
			result.append(c)
	return result

func get_all_ids() -> Array:
	return _classes.keys()

func is_advanced(class_id: String) -> bool:
	return get_class_by_id(class_id).get("advanced_of", "") != ""

## Retourne les classes de type "physique" ou "magique"
func get_classes_of_type(type: String) -> Array:
	var result : Array = []
	for c in _classes.values():
		if c["class_type"] == type:
			result.append(c)
	return result
