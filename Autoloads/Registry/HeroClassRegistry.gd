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
	_register_advanced_classes()


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

	## ── ROUBLARD ──────────────────────────────────────────────────────────────
	_add("roublard", "Roublard", "physique",
		"Les Roublards sont des maîtres de la furtivité, préférant frapper dans l'ombre. Rapides, agiles, capables de coups critiques dévastateurs.",
		"", "rogue", 0,
		["dague"], "moyenne",
		{
			"strength": Vector2i(6,  10), "defense": Vector2i(3,  7),
			"agility":  Vector2i(12, 16), "magic":   Vector2i(5,  9),
			"luck":     Vector2i(10, 14),
		},
		{"strength": 1, "defense": 1, "agility": 3, "magic": 0, "luck": 2},
		{"manual_work": 0.4, "social": 0.5, "occult_work": 0.1, "cooking": 0.1, "knowledge": 0.2}
	)

	## ── CHASSEUR ──────────────────────────────────────────────────────────────
	_add("chasseur", "Chasseur", "physique",
		"Les Chasseurs sont des experts en tir à longue distance et en survie. Ils infligent des dégâts à distance tout en esquivant les attaques.",
		"", "archer", 0,
		["arc"], "moyenne",
		{
			"strength": Vector2i(7,  11), "defense": Vector2i(7,  11),
			"agility":  Vector2i(11, 15), "magic":   Vector2i(4,  8),
			"luck":     Vector2i(8,  12),
		},
		{"strength": 2, "defense": 1, "agility": 2, "magic": 0, "luck": 2},
		{"manual_work": 0.5, "social": 0.3, "occult_work": 0.0, "cooking": 0.3, "knowledge": 0.2}
	)

	## ── GUÉRISSEUR ────────────────────────────────────────────────────────────
	_add("guerisseur", "Guérisseur", "magique",
		"Les Guérisseurs utilisent la magie pour soigner les blessures et protéger leurs alliés. Leur capacité à maintenir l'équipe en vie les rend essentiels.",
		"", "cleric", 4,
		["baton"], "legere",
		{
			"strength": Vector2i(4,  8),  "defense": Vector2i(6,  10),
			"agility":  Vector2i(6,  10), "magic":   Vector2i(11, 15),
			"luck":     Vector2i(10, 14),
		},
		{"strength": 1, "defense": 2, "agility": 1, "magic": 3, "luck": 1},
		{"manual_work": 0.1, "social": 0.7, "occult_work": 0.8, "cooking": 0.4, "knowledge": 0.5}
	)

	## ── INVOCATEUR ────────────────────────────────────────────────────────────
	_add("invocateur", "Invocateur", "magique",
		"Les Invocateurs appellent des créatures ou entités pour les assister au combat. Leur puissance réside dans le contrôle de ces invocations.",
		"", "mage", 3,
		["baton", "grimoire"], "legere",
		{
			"strength": Vector2i(3,  7),  "defense": Vector2i(5,  9),
			"agility":  Vector2i(6,  10), "magic":   Vector2i(11, 15),
			"luck":     Vector2i(10, 14),
		},
		{"strength": 0, "defense": 1, "agility": 1, "magic": 4, "luck": 1},
		{"manual_work": 0.0, "social": 0.3, "occult_work": 1.0, "cooking": 0.0, "knowledge": 0.8}
	)


# ─────────────────────────────────────────────
#  CLASSES AVANCÉES (12)
# ─────────────────────────────────────────────
func _register_advanced_classes() -> void:

	## ── GUERRIER → ────────────────────────────────────────────────────────────

	_add("chevalier", "Chevalier", "physique",
		"Guerriers en armure lourde spécialisés dans la défense et les attaques puissantes. Protecteurs et leaders sur le champ de bataille.",
		"warrior", "knight", 2,
		["epee", "hache", "lance"], "lourde",
		{
			"strength": Vector2i(14, 18), "defense": Vector2i(14, 18),
			"agility":  Vector2i(6,  10), "magic":   Vector2i(4,  8),
			"luck":     Vector2i(6,  11),
		},
		{"strength": 3, "defense": 3, "agility": 1, "magic": 0, "luck": 1},
		{"manual_work": 0.9, "social": 0.4, "occult_work": 0.0, "cooking": 0.1, "knowledge": 0.2}
	)

	_add("berserker", "Berserker", "physique",
		"Combattants féroces qui utilisent leur rage pour infliger des dégâts massifs. Ils sacrifient la défense pour une puissance offensive dévastatrice.",
		"warrior", "berserker", 2,
		["epee", "hache", "marteau"], ["moyenne", "lourde"][0],
		{
			"strength": Vector2i(16, 20), "defense": Vector2i(8,  12),
			"agility":  Vector2i(8,  12), "magic":   Vector2i(2,  6),
			"luck":     Vector2i(6,  10),
		},
		{"strength": 5, "defense": 1, "agility": 2, "magic": 0, "luck": 1},
		{"manual_work": 0.8, "social": 0.0, "occult_work": 0.0, "cooking": 0.0, "knowledge": 0.0}
	)

	## ── MAGE → ────────────────────────────────────────────────────────────────

	_add("sage_arcanique", "Sage Arcanique", "magique",
		"Mages érudits avec une maîtrise avancée des sorts arcaniques. Ils manipulent les forces magiques avec une précision redoutable.",
		"mage", "archmage", 3,
		["baton", "grimoire", "orbe"], "legere",
		{
			"strength": Vector2i(3,  7),  "defense": Vector2i(5,  9),
			"agility":  Vector2i(7,  11), "magic":   Vector2i(16, 20),
			"luck":     Vector2i(9,  13),
		},
		{"strength": 0, "defense": 1, "agility": 1, "magic": 6, "luck": 1},
		{"manual_work": 0.0, "social": 0.2, "occult_work": 1.0, "cooking": 0.0, "knowledge": 1.0}
	)

	_add("maitre_elements", "Maître des Éléments", "magique",
		"Mages spécialisés dans le contrôle des éléments naturels : feu, eau, terre, air. Ils infligent des dégâts massifs ou contrôlent le terrain.",
		"mage", "mage", 3,
		["baton", "grimoire", "orbe"], "legere",
		{
			"strength": Vector2i(4,  8),  "defense": Vector2i(5,  9),
			"agility":  Vector2i(8,  12), "magic":   Vector2i(15, 19),
			"luck":     Vector2i(9,  13),
		},
		{"strength": 0, "defense": 1, "agility": 2, "magic": 5, "luck": 1},
		{"manual_work": 0.0, "social": 0.1, "occult_work": 1.0, "cooking": 0.0, "knowledge": 0.8}
	)

	## ── ROUBLARD → ────────────────────────────────────────────────────────────

	_add("assassin", "Assassin", "physique",
		"Maîtres de l'assassinat spécialisés dans les attaques furtives et mortelles. Ils frappent rapidement et avec précision.",
		"roublard", "assassin", 0,
		["dague", "arc"], ["legere", "moyenne"][0],
		{
			"strength": Vector2i(8,  12), "defense": Vector2i(5,  9),
			"agility":  Vector2i(16, 20), "magic":   Vector2i(5,  9),
			"luck":     Vector2i(12, 16),
		},
		{"strength": 2, "defense": 1, "agility": 4, "magic": 0, "luck": 3},
		{"manual_work": 0.3, "social": 0.2, "occult_work": 0.2, "cooking": 0.0, "knowledge": 0.1}
	)

	_add("ombre", "Ombre", "physique",
		"Maîtres de l'ombre, les Ombres utilisent l'obscurité pour se cacher et attaquer. Quasiment indétectables, ils portent des coups mortels.",
		"roublard", "rogue", 0,
		["dague", "shuriken"], ["legere", "moyenne"][0],
		{
			"strength": Vector2i(7,  11), "defense": Vector2i(4,  8),
			"agility":  Vector2i(15, 19), "magic":   Vector2i(8,  12),
			"luck":     Vector2i(12, 16),
		},
		{"strength": 1, "defense": 1, "agility": 3, "magic": 2, "luck": 2},
		{"manual_work": 0.3, "social": 0.3, "occult_work": 0.4, "cooking": 0.0, "knowledge": 0.2}
	)

	## ── CHASSEUR → ────────────────────────────────────────────────────────────

	_add("ranger", "Ranger", "physique",
		"Chasseurs expérimentés spécialisés dans le pistage et le tir longue portée. Experts de la survie, ils se fondent dans la nature.",
		"chasseur", "archer", 0,
		["arc"], "moyenne",
		{
			"strength": Vector2i(9,  13), "defense": Vector2i(9,  13),
			"agility":  Vector2i(14, 18), "magic":   Vector2i(5,  9),
			"luck":     Vector2i(9,  13),
		},
		{"strength": 2, "defense": 2, "agility": 2, "magic": 1, "luck": 2},
		{"manual_work": 0.5, "social": 0.3, "occult_work": 0.2, "cooking": 0.5, "knowledge": 0.3}
	)

	_add("archer_mystique", "Archer Mystique", "magique",
		"Archers qui combinent leurs compétences de tir avec la magie. Ils enchantent leurs flèches pour infliger des dégâts magiques ou des effets spéciaux.",
		"chasseur", "archer", 0,
		["arc"], "moyenne",
		{
			"strength": Vector2i(8,  12), "defense": Vector2i(7,  11),
			"agility":  Vector2i(13, 17), "magic":   Vector2i(9,  13),
			"luck":     Vector2i(9,  13),
		},
		{"strength": 1, "defense": 1, "agility": 2, "magic": 3, "luck": 2},
		{"manual_work": 0.4, "social": 0.3, "occult_work": 0.5, "cooking": 0.2, "knowledge": 0.4}
	)

	## ── GUÉRISSEUR → ──────────────────────────────────────────────────────────

	_add("pretre", "Prêtre", "magique",
		"Soigneurs sacrés capables de soigner et de protéger avec des pouvoirs divins. Ils renforcent leurs alliés et repoussent les ténèbres.",
		"guerisseur", "cleric", 4,
		["baton", "grimoire"], "legere",
		{
			"strength": Vector2i(5,  9),  "defense": Vector2i(8,  12),
			"agility":  Vector2i(7,  11), "magic":   Vector2i(14, 18),
			"luck":     Vector2i(11, 15),
		},
		{"strength": 1, "defense": 2, "agility": 1, "magic": 4, "luck": 1},
		{"manual_work": 0.2, "social": 0.8, "occult_work": 0.9, "cooking": 0.4, "knowledge": 0.6}
	)

	_add("druide", "Druide", "magique",
		"Soigneurs qui utilisent le pouvoir de la nature pour guérir et aider leurs alliés. Ils invoquent la puissance des éléments naturels.",
		"guerisseur", "druid", 4,
		["baton"], "legere",
		{
			"strength": Vector2i(6,  10), "defense": Vector2i(8,  12),
			"agility":  Vector2i(9,  13), "magic":   Vector2i(13, 17),
			"luck":     Vector2i(10, 14),
		},
		{"strength": 1, "defense": 2, "agility": 2, "magic": 3, "luck": 2},
		{"manual_work": 0.2, "social": 0.6, "occult_work": 0.9, "cooking": 0.6, "knowledge": 0.7}
	)

	## ── INVOCATEUR → ──────────────────────────────────────────────────────────

	_add("maitre_esprits", "Maître des Esprits", "magique",
		"Invocateurs spécialisés dans la convocation d'esprits puissants du monde spirituel, pour le combat ou des tâches spécifiques.",
		"invocateur", "mage", 3,
		["baton", "grimoire"], "legere",
		{
			"strength": Vector2i(3,  7),  "defense": Vector2i(6,  10),
			"agility":  Vector2i(7,  11), "magic":   Vector2i(14, 18),
			"luck":     Vector2i(12, 16),
		},
		{"strength": 0, "defense": 1, "agility": 1, "magic": 5, "luck": 2},
		{"manual_work": 0.0, "social": 0.4, "occult_work": 1.0, "cooking": 0.0, "knowledge": 0.9}
	)

	_add("conjurateur_elementaire", "Conjurateur Élémentaire", "magique",
		"Invocateurs qui appellent des entités élémentaires pour écraser leurs ennemis ou protéger leurs alliés. Ils contrôlent les forces de la nature.",
		"invocateur", "mage", 3,
		["baton", "grimoire", "orbe"], "legere",
		{
			"strength": Vector2i(4,  8),  "defense": Vector2i(7,  11),
			"agility":  Vector2i(7,  11), "magic":   Vector2i(13, 17),
			"luck":     Vector2i(11, 15),
		},
		{"strength": 0, "defense": 2, "agility": 1, "magic": 4, "luck": 2},
		{"manual_work": 0.0, "social": 0.3, "occult_work": 1.0, "cooking": 0.0, "knowledge": 0.8}
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
