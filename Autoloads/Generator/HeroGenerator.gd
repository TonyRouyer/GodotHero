## HeroGenerator.gd — Autoload
## Génère des HeroData à la demande selon les formules du design doc.
## Appelé par HeroManager ou le système de recrutement.
##
## Usage :
##   var data = HeroGenerator.generate()                    # héros aléatoire
##   var data = HeroGenerator.generate_for_recruitment()    # calibré sur la réputation
##   var data = HeroGenerator.generate_with(level, class_id) # paramétré
extends Node


# ─────────────────────────────────────────────
#  DONNÉES STATIQUES
# ─────────────────────────────────────────────

## Prénoms et noms pour la génération aléatoire
const FIRST_NAMES :Array = [
	"Aldric", "Brynn", "Corvin", "Dara", "Eolan", "Fira",
	"Gareth", "Hilda", "Ivar", "Jynn", "Kael", "Lyra",
	"Maren", "Noel", "Oryn", "Petra", "Quinn", "Reva",
	"Soren", "Tara", "Uric", "Vael", "Wren", "Xara",
	"Yden", "Zora",
]

const LAST_NAMES :Array = [
	"Ashford", "Blackwood", "Crane", "Dunmore", "Everly",
	"Frost", "Grimshaw", "Harrow", "Ironsides", "Jade",
	"Kestrel", "Lorne", "Marsh", "Nightfall", "Orin",
	"Proudfoot", "Quill", "Ravenscar", "Stone", "Thorne",
	"Underhill", "Vale", "Whitmore", "Xander", "York", "Zarith",
]

## Traits positifs disponibles à la génération
const POSITIVE_TRAITS :Array = [
	"charismatic", "hardworking", "stoic", "divine_inspiration",
	"animal_friend", "resilient", "natural_leader", "guild_devoted",
	"good_constitution", "loyal_companion", "fast_learner",
	"passionate_cook", "elite_smith", "enthusiastic", "visual_memory",
	"combative", "team_spirit", "inspired_artisan", "cool_headed",
	"robust", "tireless",
]

## Traits négatifs disponibles à la génération
const NEGATIVE_TRAITS :Array = [
	"hot_headed", "lazy", "emotionally_unstable", "cynical",
	"loner", "glutton", "sleepy_head", "clumsy", "hypochondriac",
	"proud", "sore_loser", "scatterbrained", "combat_addict",
	"insomniac", "apathetic", "thief", "superstitious",
	"depressive", "animal_allergy", "indiscreet", "claustrophobic",
]

## Traits incompatibles { trait → [traits incompatibles] }
const INCOMPATIBLE_TRAITS :Dictionary = {
	"stoic":              ["emotionally_unstable"],
	"emotionally_unstable": ["stoic", "cool_headed"],
	"hardworking":        ["lazy"],
	"lazy":               ["hardworking"],
	"cool_headed":        ["hot_headed", "emotionally_unstable"],
	"hot_headed":         ["cool_headed"],
}


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

## Génère un héros complètement aléatoire (niveau 1, classe aléatoire)
func generate() -> HeroData:
	return generate_with(1, "")


## Génère un héros calibré sur la réputation actuelle (pour le recrutement)
func generate_for_recruitment() -> HeroData:
	var rep   : float = float(GameData.reputation)
	var avg   : float = _get_average_hero_level()

	# Niveau = niveau_moyen + rep/2 + rand(-5, 0) — formule §4.8
	var level : int = max(1, int(avg + rep / 2.0 + randi_range(-5, 0)))

	# Classe : 80% base, 20% avancée (si disponible)
	var class_id :String = _pick_class_for_recruitment()

	return generate_with(level, class_id)


## Génère un héros avec des paramètres précis
## class_id vide = classe aléatoire parmi les classes de base
func generate_with(level: int, class_id: String) -> HeroData:
	level   = max(1, level)

	if class_id == "":
		class_id = _random_base_class()

	var hero_class :Dictionary = HeroClassRegistry.get_class_by_id(class_id)
	if hero_class.is_empty():
		push_error("HeroGenerator: classe inconnue '%s'" % class_id)
		return null

	var data :HeroData = HeroData.new()
	
	_apply_identity(data, hero_class, level)
	_apply_stats(data, hero_class, level)
	_apply_secondary_stats(data, hero_class, level)
	_apply_derived_stats(data)
	_apply_traits(data, level)
	_apply_skills(data)
	_apply_salary(data, hero_class)
	_apply_planning(data)
	_apply_appearance(data)

	return data


# ─────────────────────────────────────────────
#  ÉTAPES DE GÉNÉRATION
# ─────────────────────────────────────────────

func _apply_identity(data: HeroData, hero_class: Dictionary, level: int) -> void:
	data.hero_name     = _random_name()
	data.hero_class    = hero_class.get("id")
	data.level         = level
	data.is_advanced_class = HeroClassRegistry.is_advanced(hero_class.get("id"))

	# Rang calculé selon formule §4.9 — Score = (level/10) + (rep/3)
	var rep   : float = float(GameData.reputation)
	var score : float = (level / 10.0) + (rep / 3.0)
	data.rank  = _score_to_rank(score)

	data.job         = hero_class.get("job", 0)

	## Propriétés de classe (armes, armure, type)
	data.class_type   = hero_class.get("class_type", "physique")
	data.weapon_types.assign(hero_class.get("weapon_types", []))
	data.armor_type   = hero_class.get("armor_type", "legere")


func _apply_stats(data: HeroData, hero_class: Dictionary, level: int) -> void:
	## Formule §4.1 :
	##   Niveau 1 → valeur tirée aléatoirement dans stat_range[min, max]
	##   Niveaux sup → base + gain × (level - 1)
	var stat_range : Dictionary = hero_class.get("stat_range", {})
	var gain       : Dictionary = hero_class.get("stat_gain",  {})

	for stat_name : String in ["strength", "defense", "agility", "magic", "luck"]:
		var base_val : float
		if stat_range.has(stat_name):
			var r : Vector2i = stat_range[stat_name]
			base_val = randi_range(r.x, r.y)
		else:
			base_val = hero_class.get("stat_base", {}).get(stat_name, 10)
		data.set(stat_name, base_val + gain.get(stat_name, 1) * (level - 1))


func _apply_secondary_stats(data: HeroData, hero_class: Dictionary, level: int) -> void:
	# Formule §4.2 : rand(1, 10) + (level × 0.3) × poids_classe
	var weights : Dictionary = hero_class.get("secondary_weights", {})

	var base_val : float = randf_range(1.0, 10.0) + level * 0.3

	data.social      = max(1.0, base_val * weights.get("social",       0.3))
	data.manual_work = max(1.0, base_val * weights.get("manual_work",  0.3))
	data.occult_work = max(1.0, base_val * weights.get("occult_work",  0.1))
	data.cooking     = max(1.0, base_val * weights.get("cooking",      0.2))
	data.knowledge   = max(1.0, base_val * weights.get("knowledge",    0.2))


func _apply_derived_stats(data: HeroData) -> void:
	# PV_max = 100 + (Force × 2) + (Défense × 1.5)  — formule §1.9
	data.hp_max   = data.get_hp_max()
	data.hp       = data.hp_max
	# Mana_max = 50 + (Magie × 3)  — formule §4.11
	data.mana_max = data.get_mana_max()
	data.mana     = data.mana_max

	# Besoins à plein au départ
	data.energy        = 100.0
	data.hunger        = 100.0
	data.entertainment = 100.0
	data.toilet        = 100.0
	data.hygiene       = 100.0
	data.moral         = 100.0


func _apply_traits(data: HeroData, _level: int) -> void:
	# 1 à 3 traits, max 2 négatifs — formule §5.3
	var nb_traits :int = randi_range(1, 3)

	# Les héros de rang élevé ont plus de chances d'avoir des traits positifs
	var positive_bias : float = 0.5 + (["F","E","D","C","B","A","S"].find(data.rank) * 0.05)

	var picked     : Array[String] = []
	var nb_negative : int = 0

	for _i in range(nb_traits):
		for _attempt in range(20):  # max 20 tentatives par trait
			var pick_positive :bool = randf() < positive_bias
			var pool : Array

			if pick_positive:
				pool = POSITIVE_TRAITS
			else:
				if nb_negative >= 2:
					pool = POSITIVE_TRAITS  # force positif si déjà 2 négatifs
				else:
					pool = NEGATIVE_TRAITS

			var candidate : String = pool[randi() % pool.size()]

			# Vérifie unicité et incompatibilités
			if picked.has(candidate):
				continue
			var compatible :bool = true
			for existing in picked:
				var incompatible_with = INCOMPATIBLE_TRAITS.get(existing, [])
				if incompatible_with.has(candidate):
					compatible = false
					break
				var my_incompatible = INCOMPATIBLE_TRAITS.get(candidate, [])
				if my_incompatible.has(existing):
					compatible = false
					break
			if not compatible:
				continue

			picked.append(candidate)
			if NEGATIVE_TRAITS.has(candidate):
				nb_negative += 1
			break

	data.traits = picked


func _apply_salary(data: HeroData, _hero_class: Dictionary) -> void:
	# Formule §4.7 : Salaire = Base_rang × (1 + 0.03 × level) × (1 + bonus_classe)
	var rank_base :Dictionary = {"F": 10, "E": 20, "D": 40, "C": 60, "B": 100, "A": 150, "S": 200}
	var base      : int   = rank_base.get(data.rank, 10)
	var advanced  : float = 0.30 if data.is_advanced_class else 0.0
	data.salary   = int(base * (1.0 + 0.03 * data.level) * (1.0 + advanced))


func _apply_skills(data: HeroData) -> void:
	## Les compétences ne sont plus auto-apprises : le joueur les achète avec des points.
	## Points de départ : 2 + 2 par rang au-dessus de F (F=2, E=4, D=6, C=8, B=10, A=12, S=14)
	data.skills = []
	var rank_idx : int = SkillLibrary.RANK_ORDER.find(data.rank)
	data.skill_points = 2 + rank_idx * 2


func _apply_planning(data: HeroData) -> void:
	data.apply_default_planning()


func _apply_appearance(data: HeroData) -> void:
	var gender :String = "male" if randf() < 0.5 else "female"

	var bodies :Dictionary = {
		"male":   ["body_male"],
		"female": ["body_female"],
	}
	var eyes   :Dictionary = {
		"male":   ["eye_male"],
		"female": ["eye_female"],
	}
	
	var hairs  :Array = ["hair1_male", "hair2_male"]

	## Tenues selon le type de classe (les assets par classe individuelle seront ajoutés plus tard)
	var physical_classes : Array = ["warrior", "chevalier", "berserker",
									"roublard", "assassin", "ombre",
									"chasseur", "ranger"]
	var is_physical : bool = data.class_type == "physique"

	var tops : Array = ["miner_chest"]
	var pant : Array = ["miner_pant"]
	var helm : Array = ["helm_1", "helm_2"] if is_physical else ["helm_2"]
	## TODO : remplacer par des assets spécifiques à chaque classe
	var _phys = physical_classes  ## supprime l'avertissement "variable inutilisée"


	data.appearance = {
		"body":   bodies[gender][randi() % bodies[gender].size()] if not bodies[gender].is_empty() else "",
		"eyes":   eyes[gender][randi()  % eyes[gender].size()]   if not eyes[gender].is_empty()   else "",
		"hair":   hairs[randi() % hairs.size()]                  if not hairs.is_empty()           else "",
		"top":    tops[randi()  % tops.size()]                   if not tops.is_empty()            else "",
		"helm":   helm[randi()  % helm.size()]                   if not helm.is_empty()            else "",
		"pant":   pant[randi()  % pant.size()]                   if not pant.is_empty()            else "",
	}
	
	var chance = randf()  # nombre aléatoire entre 0.0 et 1.0
	if chance < 0.5:
		data.appearance["helm"] = ""

# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────

func _random_name() -> String:
	var first :String = FIRST_NAMES[randi() % FIRST_NAMES.size()]
	var last  :String = LAST_NAMES[randi()  % LAST_NAMES.size()]
	return "%s %s" % [first, last]


func _random_base_class() -> String:
	var base_classes := HeroClassRegistry.get_all_base_classes()
	if base_classes.is_empty():
		return "warrior"
	return base_classes[randi() % base_classes.size()]["id"]
 
 
func _pick_class_for_recruitment() -> String:
	## GDD §6.3 — 80% classe de base, 20% classe avancée.
	## Condition : le joueur doit déjà posséder un héros de cette classe avancée.
	var advanced_available : Array = _get_available_advanced_classes()
	if advanced_available.size() > 0 and randf() < 0.20:
		return advanced_available[randi() % advanced_available.size()]
	return _random_base_class()
 
 
func _get_available_advanced_classes() -> Array:
	# Une classe avancée est disponible si le joueur a déjà un héros de cette classe
	var result := []
	for data in HeroManager.get_all_data():
		if data.is_advanced_class and not result.has(data.hero_class):
			result.append(data.hero_class)
	return result

func _get_average_hero_level() -> float:
	var heroes :Array = HeroManager.get_all_data()
	if heroes.is_empty():
		return 1.0
	var total :float = 0.0
	for d in heroes:
		total += d.level
	return total / heroes.size()


func _score_to_rank(score: float) -> String:
	# Formule §4.9
	if score <= 1.0: return "F"
	if score <= 2.0: return "E"
	if score <= 3.0: return "D"
	if score <= 4.0: return "C"
	if score <= 5.0: return "B"
	if score <= 6.0: return "A"
	return "S"
