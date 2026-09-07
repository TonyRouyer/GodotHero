## TraitLibrary.gd — Autoload
## Définit les 42 traits de héros (21 positifs + 21 négatifs) selon le GDD §5.3.
##
## ── Clés d'effets supportées ──────────────────────────────────────────────────
##   stat_bonus             : Dictionary  { stat: float }    bonus flat aux stats
##   need_mult              : Dictionary  { need: float }    multiplicateur dégradation besoin
##   sleep_mult             : float       multiplicateur récupération énergie pendant sommeil
##   xp_mult                : float       multiplicateur XP global
##   work_speed_mult        : float       multiplicateur vitesse de travail (XP prod)
##   hp_mult                : float       multiplicateur PV max
##   moral_constant         : float       modificateur moral constant par tick
##   moral_amplifier        : float       amplifie TOUS les effets moraux (+ et −)
##   max_positive_moral     : float       plafond d'un seul effet moral positif
##   moral_cap              : float       plafond moral global (défaut 100)
##   moral_floor            : float       plancher moral global (défaut 0)
##   day_moral_bonus        : float       bonus moral temporaire ajouté chaque début de jour
##   quit_threshold         : float       seuil moral déclenchant les vérifs de démission
##   unpaid_quit_days       : int         jours sans salaire avant départ forcé
##   craft_fail_chance      : float       (futur CraftManager) — prob. d'échec partiel craft
##   mission_creature_mult  : float       (futur MissionManager) — bonus missions créatures
extends Node


var _traits : Dictionary = {}


func _ready() -> void:
	_register_positive()
	_register_negative()


# ─────────────────────────────────────────────
#  REGISTRATION
# ─────────────────────────────────────────────
func _add(id: String, label: String, desc: String, positive: bool, effects: Dictionary) -> void:
	_traits[id] = {
		"id": id, "label": label, "description": desc, "positive": positive, "effects": effects,
	}


func _register_positive() -> void:

	## Charismatique : +10% efficacité tâches sociales, +3 moral aux héros proches
	## → simplifié : bonus moral constant + work_speed bonus pour job social (réception)
	_add("charismatic", "Charismatique",
		"+10 % efficacité tâches sociales. Rayonne positivement sur les compagnons.",
		true, { "moral_constant": 3.0, "work_speed_mult": 1.10 })

	## Travailleur : +15% vitesse toutes tâches non-combattantes
	_add("hardworking", "Travailleur",
		"+15 % de vitesse sur toutes les tâches. XP accrue.",
		true, { "xp_mult": 1.15, "work_speed_mult": 1.15 })

	## Stoïque : malus moraux réduits de 50%
	## → implémenté via moral_amplifier sur les effets négatifs uniquement
	_add("stoic", "Stoïque",
		"Les événements négatifs l'affectent deux fois moins.",
		true, { "neg_moral_mult": 0.50 })

	## Inspiration Divine : 10% chance terminer tâche instantanément / +10 moral allié
	## → simplifié : bonus XP + bonus moral
	_add("divine_inspiration", "Inspiration Divine",
		"10 % de chance par tâche de terminer en un éclair ou d'inspirer un allié.",
		true, { "xp_mult": 1.10, "moral_constant": 2.0 })

	## Ami des Animaux : +20% missions créatures
	_add("animal_friend", "Ami des Animaux",
		"+20 % efficacité sur les missions impliquant des créatures.",
		true, { "mission_creature_mult": 1.20 })

	## Résilient : guérit 2× plus vite, malus blessure -10%
	_add("resilient", "Résilient",
		"Guérit deux fois plus vite. Malus de blessure réduit.",
		true, { "hp_mult": 1.10 })

	## Leader Naturel : +5 moral à tous les héros du groupe
	## → simplifié : bonus moral constant (l'aura sur les alliés sera implémentée plus tard)
	_add("natural_leader", "Leader Naturel",
		"+5 moral à toute l'équipe lors des missions communes.",
		true, { "moral_constant": 3.0 })

	## Dévoué à la Guilde : ne quitte jamais sauf moral=0 pendant 10+ jours
	_add("guild_devoted", "Dévoué à la Guilde",
		"Ne démissionne jamais, sauf si son moral est à zéro depuis plus de 10 jours.",
		true, { "unpaid_quit_days": 30, "quit_threshold": 0.0 })

	## Bonne Constitution : faim et énergie descendent 20% moins vite
	_add("good_constitution", "Bonne Constitution",
		"Les besoins Sommeil et Faim descendent 20 % moins vite.",
		true, { "need_mult": {"hunger": 0.80, "energy": 0.80} })

	## Compagnon Loyal : malus perte camarade -50%
	## → simplifié : moral floor légèrement élevé
	_add("loyal_companion", "Compagnon Loyal",
		"Les pertes de camarades l'affectent deux fois moins.",
		true, { "neg_moral_mult": 0.70, "moral_floor": 10.0 })

	## Apprend Vite : +25% XP combat et métier
	_add("fast_learner", "Apprend Vite",
		"+25 % d'expérience sur toutes les activités.",
		true, { "xp_mult": 1.25 })

	## Cuistot Passionné : +15% vitesse cuisine, +3 moral aux héros qui mangent ses plats
	_add("passionate_cook", "Cuistot Passionné",
		"+15 % de vitesse en cuisine. Les plats qu'il prépare remontent le moral.",
		true, { "work_speed_mult": 1.15, "moral_constant": 2.0 })

	## Forgeur d'Élite : +20% qualité forge
	_add("elite_smith", "Forgeur d'Élite",
		"+20 % de qualité sur les équipements forgés (futur système de qualité).",
		true, { "work_speed_mult": 1.20 })

	## Enthousiaste : +15 moral au début de chaque journée (12h)
	_add("enthusiastic", "Enthousiaste",
		"+15 de moral au lever du soleil chaque jour (effet 12 h).",
		true, { "day_moral_bonus": 15.0 })

	## Mémoire Visuelle : +10% efficacité tâches Savoir
	_add("visual_memory", "Mémoire Visuelle",
		"+10 % d'efficacité sur les tâches liées au Savoir.",
		true, { "xp_mult": 1.10 })

	## Combatif : +10% vitesse d'attaque, initiative +1 en combat
	_add("combative", "Combatif",
		"+10 % de vitesse d'attaque et initiative en combat.",
		true, { "stat_bonus": {"strength": 2} })

	## Esprit d'Équipe : réduit conflits internes de 70%
	_add("team_spirit", "Esprit d'Équipe",
		"Réduit de 70 % les risques de conflits entre héros.",
		true, { "moral_constant": 2.0 })

	## Artisan Inspiré : 5% chance qualité supérieure par craft
	_add("inspired_artisan", "Artisan Inspiré",
		"5 % de chance de produire un objet de qualité supérieure à chaque craft.",
		true, { "craft_quality_chance": 0.05, "work_speed_mult": 1.10 })

	## Sang-froid : effets Stun/Peur réduits de 50%
	_add("cool_headed", "Sang-froid",
		"Durée des effets Stun et Peur réduite de 50 % en combat.",
		true, { "moral_floor": 20.0 })

	## Robuste : PV Max +15%
	_add("robust", "Robuste",
		"+15 % de PV maximum.",
		true, { "hp_mult": 1.15 })

	## Infatigable : Hygiène et Toilette descendent 25% moins vite
	_add("tireless", "Infatigable",
		"Les besoins Hygiène et Toilette descendent 25 % moins vite.",
		true, { "need_mult": {"hygiene": 0.75, "toilet": 0.75} })


func _register_negative() -> void:

	## Colérique : 20% chance/jour de conflit avec un héros aléatoire (-8 moral chacun)
	## → simplifié : malus moral constant
	_add("hot_headed", "Colérique",
		"20 % de risque de déclencher un conflit chaque jour (−8 moral pour les deux).",
		false, { "moral_constant": -4.0, "quit_threshold": 15.0 })

	## Fainéant : -20% vitesse toutes tâches
	_add("lazy", "Fainéant",
		"−20 % de vitesse sur toutes les tâches.",
		false, { "xp_mult": 0.80, "work_speed_mult": 0.80 })

	## Instable Émotionnellement : effets moraux ×1.5
	_add("emotionally_unstable", "Instable Émotionnellement",
		"Tous les effets moraux (positifs et négatifs) sont amplifiés × 1.5.",
		false, { "moral_amplifier": 1.50 })

	## Cynique : ne bénéficie pas des bonus moraux collectifs
	## → simplifié : moral cap bas
	_add("cynical", "Cynique",
		"N'est pas touché par les bonus moraux collectifs (festivals, cérémonies).",
		false, { "moral_cap": 82.0 })

	## Solitaire : -5 moral constant si 3+ héros dans la même pièce
	## → simplifié : malus moral constant
	_add("loner", "Solitaire",
		"−5 de moral constant si plusieurs héros sont à proximité.",
		false, { "moral_constant": -4.0 })

	## Gourmand : besoin Faim descend 2× plus vite
	_add("glutton", "Gourmand",
		"Le besoin Faim descend deux fois plus vite.",
		false, { "need_mult": {"hunger": 2.0} })

	## Somnoleur : Sommeil descend 1.5× plus vite, récupère 20% moins vite
	_add("sleepy_head", "Somnoleur",
		"Le besoin Sommeil descend 1.5× plus vite et récupère 20 % moins bien.",
		false, { "need_mult": {"energy": 1.50}, "sleep_mult": 0.80 })

	## Maladroit : 10% chance d'échec partiel sur craft
	_add("clumsy", "Maladroit",
		"10 % de chance d'échec partiel sur chaque craft (qualité inférieure).",
		false, { "craft_fail_chance": 0.10 })

	## Hypocondriaque : arrêt maladie si PV ≤ 80%
	## → simplifié : malus moral constant
	_add("hypochondriac", "Hypocondriaque",
		"Se met en arrêt maladie si ses PV tombent sous 80 %.",
		false, { "moral_constant": -2.0 })

	## Orgueilleux : 15% chance d'ignorer une affectation
	_add("proud", "Orgueilleux",
		"15 % de chance d'ignorer son planning et de faire autre chose.",
		false, { "quit_threshold": 20.0, "moral_constant": -1.0 })

	## Mauvais Perdant : -20 moral après mission échouée
	_add("sore_loser", "Mauvais Perdant",
		"−20 de moral supplémentaire après chaque mission échouée.",
		false, { "extra_fail_moral": -20.0, "moral_constant": -2.0 })

	## Tête en l'Air : 10% chance de changer d'activité sans raison
	_add("scatterbrained", "Tête en l'Air",
		"10 % de chance par heure de changer d'activité sans raison.",
		false, { "xp_mult": 0.85, "moral_constant": -1.0 })

	## Addict au Combat : -5 moral si aucune mission dans les 5 derniers jours
	_add("combat_addict", "Addict au Combat",
		"−5 moral constant s'il n'a pas participé à une mission depuis 5 jours.",
		false, { "moral_constant": -4.0 })

	## Insomnie : récupère le besoin Sommeil 40% moins vite
	_add("insomniac", "Insomnie",
		"Récupère le besoin Sommeil 40 % moins vite (lit comme sol).",
		false, { "sleep_mult": 0.60 })

	## Apathique : aucun bonus moral positif > +5
	_add("apathetic", "Apathique",
		"Aucun effet moral positif ne peut dépasser +5.",
		false, { "xp_mult": 0.90, "max_positive_moral": 5.0 })

	## Voleur : événement si moral < 30 pendant 3+ jours
	## → simplifié : malus moral
	_add("thief", "Voleur",
		"Peut déclencher un vol si son moral reste sous 30 pendant 3 jours.",
		false, { "moral_constant": -2.0 })

	## Superstitieux : -10 moral sur événements "maudits"
	_add("superstitious", "Superstitieux",
		"−10 de moral lors d'événements néfastes (mort d'un compagnon, objet maudit…).",
		false, { "moral_constant": -2.0 })

	## Dépressif : moral -1/heure sans interaction positive
	## → simplifié : malus moral constant
	_add("depressive", "Dépressif",
		"−1 de moral par heure en l'absence d'interaction positive.",
		false, { "moral_constant": -4.0, "moral_cap": 70.0 })

	## Allergique aux Animaux : -5 moral constant
	_add("animal_allergy", "Allergique aux Animaux",
		"−5 de moral constant et −10 % de PV max dans les pièces avec animaux.",
		false, { "moral_constant": -4.0, "hp_mult": 0.90 })

	## Indiscret : 20% chance de révéler infos sensibles
	_add("indiscreet", "Indiscret",
		"20 % de risque de révéler des informations sensibles lors des accueils.",
		false, { "moral_constant": -1.0 })

	## Claustrophobe : -5 moral dans les petites pièces
	_add("claustrophobe", "Claustrophobe",
		"−5 de moral constant dans les pièces de superficie inférieure à 6 cases.",
		false, { "moral_constant": -4.0 })


# ─────────────────────────────────────────────
#  ACCESSEURS SIMPLES
# ─────────────────────────────────────────────
func get_trait(id: String) -> Dictionary:
	return _traits.get(id, {})

func get_label(id: String) -> String:
	return _traits.get(id, {}).get("label", id)

func get_description(id: String) -> String:
	return _traits.get(id, {}).get("description", "")

func is_positive(id: String) -> bool:
	return _traits.get(id, {}).get("positive", true)

func get_all() -> Array:
	return _traits.values()


# ─────────────────────────────────────────────
#  HELPERS AGRÉGÉS — appelés depuis HeroData / HeroNeeds
# ─────────────────────────────────────────────

## Bonus flat à une stat (somme de tous les traits).
func get_stat_bonus(traits: Array, stat: String) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("stat_bonus", {}).get(stat, 0.0)
	return total


## Multiplicateur dégradation d'un besoin (produit de tous les traits).
func get_need_mult(traits: Array, need: String) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("need_mult", {}).get(need, 1.0)
	return mult


## Multiplicateur récupération énergie pendant le sommeil.
func get_sleep_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("sleep_mult", 1.0)
	return mult


## Multiplicateur XP global.
func get_xp_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("xp_mult", 1.0)
	return mult


## Multiplicateur vitesse de travail / production.
func get_work_speed_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("work_speed_mult", 1.0)
	return mult


## Multiplicateur PV max.
func get_hp_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("hp_mult", 1.0)
	return mult


## Modificateur moral constant (somme).
func get_moral_constants(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("moral_constant", 0.0)
	return total


## Amplificateur de tous les effets moraux (produit — ex : 1.5 pour instable).
func get_moral_amplifier(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("moral_amplifier", 1.0)
	return mult


## Multiplicateur sur les effets moraux NÉGATIFS uniquement (ex : 0.5 pour stoïque).
func get_neg_moral_mult(traits: Array) -> float:
	var mult : float = 1.0
	for id in traits:
		mult *= _traits.get(id, {}).get("effects", {}).get("neg_moral_mult", 1.0)
	return mult


## Plafond d'un effet moral positif unique (le plus bas l'emporte).
func get_max_positive_moral(traits: Array) -> float:
	var cap : float = INF
	for id in traits:
		var v : float = _traits.get(id, {}).get("effects", {}).get("max_positive_moral", INF)
		cap = minf(cap, v)
	return cap


## Plafond moral global (le plus bas l'emporte).
func get_moral_cap(traits: Array) -> float:
	var cap : float = 100.0
	for id in traits:
		var c : float = _traits.get(id, {}).get("effects", {}).get("moral_cap", 100.0)
		cap = minf(cap, c)
	return cap


## Plancher moral global (le plus haut l'emporte).
func get_moral_floor(traits: Array) -> float:
	var floor_val : float = 0.0
	for id in traits:
		var f : float = _traits.get(id, {}).get("effects", {}).get("moral_floor", 0.0)
		floor_val = maxf(floor_val, f)
	return floor_val


## Bonus moral temporaire ajouté chaque début de journée (somme).
func get_day_moral_bonus(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("day_moral_bonus", 0.0)
	return total


## Seuil moral déclenchant les vérifications de démission (le plus haut l'emporte).
func get_quit_threshold(traits: Array) -> float:
	var threshold : float = 5.0
	for id in traits:
		var t : float = _traits.get(id, {}).get("effects", {}).get("quit_threshold", 5.0)
		threshold = maxf(threshold, t)
	return threshold


## Jours sans salaire avant départ forcé (le plus haut l'emporte).
func get_unpaid_quit_days(traits: Array) -> int:
	var days : int = 7
	for id in traits:
		var d : int = _traits.get(id, {}).get("effects", {}).get("unpaid_quit_days", 7)
		days = maxi(days, d)
	return days


## Malus moral supplémentaire après une mission échouée (somme, valeur négative).
func get_extra_fail_moral(traits: Array) -> float:
	var total : float = 0.0
	for id in traits:
		total += _traits.get(id, {}).get("effects", {}).get("extra_fail_moral", 0.0)
	return total
