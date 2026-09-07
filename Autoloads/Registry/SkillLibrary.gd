## SkillLibrary.gd — Autoload
## Registre de toutes les compétences des 6 classes de base.
##
## Structure d'une entrée :
##   id         : String   — identifiant unique
##   label      : String   — nom affiché
##   class_id   : String   — classe propriétaire
##   rank       : String   — rang minimum requis (F E D C B A S)
##   type       : String   — "active" | "passive"
##   description: String
##   cooldown   : float    — en secondes (0 si passif)
##   mana_cost  : int      — 0 pour les classes physiques
extends Node


const RANK_ORDER : Array[String] = ["F", "E", "D", "C", "B", "A", "S"]

var _skills : Dictionary = {}   # id → skill dict
var _by_class : Dictionary = {} # class_id → Array[id]

## Effets de combat des compétences passives.
## Clés possibles : atk_bonus_pct, dmg_reduction, crit_bonus,
##                  on_kill_heal_pct, mana_regen_mult, def_bonus_pct
const PASSIVE_COMBAT_EFFECTS : Dictionary = {
	"war_endurance":             { "dmg_reduction":    0.05 },
	"war_entrainement_bouclier": { "dmg_reduction":    0.10 },
	"war_durcissement":          { "def_bonus_pct":    0.10 },
	"war_resilience":            { "dmg_reduction":    0.05 },
	"war_maitrise_epee":         { "atk_bonus_pct":   0.15 },
	"war_implacable":            { "on_kill_heal_pct": 0.02 },
	"war_maitrise_bouclier":     { "dmg_reduction":    0.15 },
	"war_maitre_armes":          { "atk_bonus_pct":   0.20 },
	"mag_maitrise_mana":         { "mana_regen_mult":  0.10 },
	"mag_maitrise_arcanes":      { "atk_bonus_pct":   0.25 },
	"cha_oeil_faucon":           { "atk_bonus_pct":   0.10 },
	"cha_concentration":         { "crit_bonus":       0.05 },
}


func _ready() -> void:
	_register_warrior_skills()
	_register_mage_skills()
	_register_roublard_skills()
	_register_chasseur_skills()
	_register_guerisseur_skills()
	_register_invocateur_skills()


# ─────────────────────────────────────────────
#  GUERRIER
# ─────────────────────────────────────────────
func _register_warrior_skills() -> void:
	## F
	_a("war_coup_direct",        "Coup Direct",             "warrior", "F",  3.0,  0,
		"Inflige un coup puissant avec l'arme, augmentant les dégâts de 10%.")
	_p("war_endurance",          "Endurance",               "warrior", "F",
		"Augmente la résistance aux dégâts physiques de 5%.")
	## E
	_a("war_taillade",           "Taillade",                "warrior", "E",  6.0,  0,
		"Attaque tranchante infligeant 20% de dégâts supplémentaires si l'ennemi est sous 50% de santé.")
	_p("war_entrainement_bouclier", "Entraînement au Bouclier", "warrior", "E",
		"Augmente l'efficacité du bouclier, réduisant les dégâts de 10%.")
	## D
	_a("war_rage",               "Rage",                    "warrior", "D", 30.0,  0,
		"Augmente la force de 15% pendant 15 secondes.")
	_p("war_durcissement",       "Durcissement",            "warrior", "D",
		"Augmente la défense de 10% de manière permanente.")
	## C
	_a("war_coup_bouclier",      "Coup de Bouclier",        "warrior", "C", 12.0,  0,
		"Inflige des dégâts (50% de l'arme) et étourdit l'ennemi pendant 2 secondes.")
	_p("war_resilience",         "Résilience",              "warrior", "C",
		"Réduit tous les dégâts entrants de 5%.")
	_a("war_attaque_frenetique", "Attaque Frénétique",      "warrior", "C", 15.0,  0,
		"Inflige une série de 5 coups rapides, chaque coup infligeant 75% des dégâts normaux.")
	## B
	_a("war_cri_guerre",         "Cri de Guerre",           "warrior", "B", 45.0,  0,
		"Augmente la force et la défense de tous les alliés à proximité de 10% pendant 30 secondes.")
	_p("war_maitrise_epee",      "Maîtrise de l'Épée",      "warrior", "B",
		"Augmente les dégâts infligés avec une épée de 15%.")
	_a("war_briseur_armure",     "Briseur d'Armure",        "warrior", "B", 30.0,  0,
		"Réduit la défense de l'ennemi de 20% pendant 10 secondes.")
	_p("war_implacable",         "Implacable",              "warrior", "B",
		"Récupère 2% de la santé maximale à chaque ennemi tué.")
	## A
	_p("war_maitrise_bouclier",  "Maîtrise du Bouclier",    "warrior", "A",
		"Réduit les dégâts de toutes les attaques de 15%.")
	_a("war_frappe_jugement",    "Frappe du Jugement",      "warrior", "A", 30.0,  0,
		"Inflige 200% des dégâts normaux et réduit la défense de l'ennemi de 25% pendant 10 secondes.")
	_a("war_fureur_bataille",    "Fureur de Bataille",      "warrior", "A", 45.0,  0,
		"Augmente les dégâts de 30% et réduit la durée des effets négatifs de 50% pendant 20 secondes.")
	## S
	_a("war_invincible",         "Invincible",              "warrior", "S", 60.0,  0,
		"Pendant 10 secondes, le guerrier devient invulnérable aux dégâts.")
	_p("war_maitre_armes",       "Maître d'Armes",          "warrior", "S",
		"Augmente les dégâts infligés avec toutes les armes de 20%.")
	_a("war_defenseur_roi",      "Défenseur du Roi",        "warrior", "S", 60.0,  0,
		"Réduit les dégâts subis par les alliés proches de 10% et transfère 5% de leurs dégâts au guerrier pendant 30 secondes.")
	_a("war_coup_grace",         "Coup de Grâce",           "warrior", "S", 90.0,  0,
		"Inflige un coup final à un ennemi à moins de 20% de vie, le tuant instantanément.")


# ─────────────────────────────────────────────
#  MAGE
# ─────────────────────────────────────────────
func _register_mage_skills() -> void:
	## F
	_a("mag_projectiles",         "Projectiles Magiques",   "mage", "F",  3.0, 10,
		"Lance une série de projectiles magiques infligeant des dégâts légers.")
	_a("mag_protection_mineure",  "Protection Mineure",     "mage", "F", 20.0,  8,
		"Réduit les dégâts subis de 5% pendant 15 secondes.")
	## E
	_a("mag_boule_feu",           "Boule de Feu",           "mage", "E",  5.0, 15,
		"Lance une boule de feu infligeant des dégâts de feu modérés à une cible unique.")
	_p("mag_maitrise_mana",       "Maîtrise du Mana",       "mage", "E",
		"Augmente la régénération de mana de 10%.")
	_a("mag_eclair",              "Éclair",                  "mage", "E",  5.0, 14,
		"Lance un éclair infligeant des dégâts de foudre avec une chance de stun de 2 secondes.")
	## D
	_a("mag_bouclier_magique",    "Bouclier Magique",       "mage", "D", 25.0, 20,
		"Crée un bouclier qui absorbe 50% des dégâts pendant 10 secondes.")
	## C
	_a("mag_explosion_arcanique", "Explosion Arcanique",    "mage", "C", 30.0, 30,
		"Inflige des dégâts magiques à tous les ennemis dans un rayon de 50px.")
	_a("mag_canalisation",        "Canalisation",           "mage", "C", 35.0, 25,
		"Augmente les dégâts des sorts de 15% pendant 20 secondes.")
	_a("mag_flammes_infernales",  "Flammes Infernales",     "mage", "C", 30.0, 35,
		"Invoque une colonne de flammes infligeant des dégâts de feu continus sur une zone pendant 10 secondes.")
	## B
	_a("mag_gelure",              "Gelure",                  "mage", "B", 45.0, 28,
		"Inflige des dégâts de glace et immobilise la cible pendant 5 secondes.")
	_a("mag_nova_glace",          "Nova de Glace",           "mage", "B", 45.0, 32,
		"Inflige des dégâts de glace à tous les ennemis autour du mage et les ralentit de 50% pendant 5 secondes.")
	_p("mag_volonte_fer",         "Volonté de Fer",          "mage", "B",
		"Réduit la durée des effets négatifs sur le mage de 25%.")
	## A
	_a("mag_tempete_foudre",      "Tempête de Foudre",      "mage", "A", 45.0, 40,
		"Invoque une tempête de foudre infligeant des dégâts à plusieurs cibles dans une large zone.")
	_a("mag_drain_vie",           "Drain de Vie",            "mage", "A", 45.0, 35,
		"Draine 10% de la vie de la cible sur 5 secondes et guérit le mage pour un montant équivalent.")
	_a("mag_explosion_magique",   "Explosion Magique",       "mage", "A", 45.0, 45,
		"Libère une explosion magique massive infligeant des dégâts élevés à toutes les cibles dans un rayon de 75px.")
	## S
	_p("mag_maitrise_arcanes",    "Maîtrise des Arcanes",   "mage", "S",
		"Augmente tous les dégâts des sorts de 25%.")
	_a("mag_inversion_sorts",     "Inversion des Sorts",     "mage", "S", 30.0, 30,
		"Renvoie tous les sorts magiques ciblés contre le mage pendant 5 secondes.")
	_a("mag_flamme_eternelle",    "Flamme Éternelle",        "mage", "S", 60.0, 50,
		"Invoque une flamme magique infligeant des dégâts constants à tous les ennemis dans une large zone pendant 15 secondes.")
	_a("mag_metamorphose",        "Métamorphose",            "mage", "S", 90.0, 60,
		"Transforme le mage en entité magique puissante pendant 20 secondes : dégâts +50%, dégâts subis -30%.")


# ─────────────────────────────────────────────
#  ROUBLARD
# ─────────────────────────────────────────────
func _register_roublard_skills() -> void:
	## F
	_a("rou_coup_rapide",         "Coup Rapide",             "roublard", "F",  3.0, 0,
		"Inflige 10% de dommage à la cible avec une attaque rapide.")
	_a("rou_esquive",             "Esquive",                 "roublard", "F", 20.0, 0,
		"Augmente la chance d'esquiver une attaque de 5% pendant 10 secondes.")
	## E
	_a("rou_lancer_dague",        "Lancer de Dague",         "roublard", "E",  5.0, 0,
		"Lance une dague sur une cible, infligeant 20% de dommage à distance.")
	_a("rou_camouflage",          "Camouflage",              "roublard", "E", 15.0, 0,
		"Rend le roublard invisible pendant 5 secondes, réduisant l'aggro de 100.")
	## D
	_a("rou_coup_bas",            "Coup Bas",                "roublard", "D", 12.0, 0,
		"Inflige 20% de dommage et réduit la défense de l'ennemi de 10% pendant 5 secondes.")
	_p("rou_maitre_poisons",      "Maître des Poisons",      "roublard", "D",
		"Augmente les dégâts des poisons appliqués de 15%.")
	## C
	_a("rou_pas_ombre",           "Pas de l'Ombre",          "roublard", "C", 15.0, 0,
		"Le roublard se téléporte derrière un ennemi et inflige des dégâts critiques.")
	_a("rou_piege",               "Piège",                   "roublard", "C", 20.0, 0,
		"Place un piège au sol qui immobilise un ennemi pendant 3 secondes.")
	_p("rou_attaque_furtive",     "Attaque Furtive",         "roublard", "C",
		"Inflige 30% de dégâts supplémentaires si le roublard est en mode furtif.")
	## B
	_a("rou_coup_critique",       "Coup Critique",           "roublard", "B", 20.0, 0,
		"Augmente les chances de coup critique de 20% pendant 10 secondes.")
	_p("rou_maitre_ombres",       "Maître des Ombres",       "roublard", "B",
		"Augmente la durée des compétences de furtivité de 30%.")
	_a("rou_paralysie",           "Paralysie",               "roublard", "B", 25.0, 0,
		"Paralyse l'ennemi pendant 5 secondes.")
	## A
	_a("rou_saignee",             "Saignée",                 "roublard", "A", 25.0, 0,
		"Inflige 30% de dommage à une cible unique et applique un effet de saignement.")
	_a("rou_danse_lames",         "Danse des Lames",         "roublard", "A", 25.0, 0,
		"Enchaîne une série d'attaques rapides infligeant 30% de dommage dans un rayon de 30px.")
	_a("rou_evasion",             "Évasion",                 "roublard", "A", 30.0, 0,
		"50% de chance d'esquiver toutes les attaques pendant 10 secondes.")
	## S
	_a("rou_assassinat",          "Assassinat",              "roublard", "S", 60.0, 0,
		"Inflige 50% de dommage à une cible unique, 25% de chance de tuer instantanément si sous 30% de santé.")
	_a("rou_toxines_mortelles",   "Toxines Mortelles",       "roublard", "S", 60.0, 0,
		"Toutes les attaques infligent des dégâts de poison supplémentaires pendant 15 secondes.")


# ─────────────────────────────────────────────
#  CHASSEUR
# ─────────────────────────────────────────────
func _register_chasseur_skills() -> void:
	## F
	_a("cha_tir_precis",          "Tir Précis",              "chasseur", "F",  3.0, 0,
		"Tire une flèche infligeant 20% de dommage avec une précision accrue.")
	_a("cha_fleche_empoisonnee",  "Flèche Empoisonnée",      "chasseur", "F",  5.0, 0,
		"Tire une flèche empoisonnée qui inflige 10% de dommage et empoisonne la cible.")
	## E
	_a("cha_tir_rapide",          "Tir Rapide",              "chasseur", "E", 10.0, 0,
		"Tire deux flèches rapidement, chacune infligeant 15% de dommage.")
	_p("cha_oeil_faucon",         "Œil de Faucon",           "chasseur", "E",
		"Augmente la portée de base de 10% et les dégâts de l'arc de 10%.")
	## D
	_a("cha_tir_explosif",        "Tir Explosif",            "chasseur", "D", 10.0, 0,
		"Tire une flèche explosive infligeant 20% de dégâts de zone autour de la cible.")
	## C
	_a("cha_fleche_enflammee",    "Flèche Enflammée",        "chasseur", "C", 12.0, 0,
		"Tire une flèche enflammée qui inflige des dégâts de feu sur la durée.")
	_a("cha_piege_loups",         "Piège à Loups",           "chasseur", "C", 20.0, 0,
		"Place un piège qui immobilise un ennemi pendant 5 secondes.")
	## B
	_a("cha_fleche_perforante",   "Flèche Perforante",       "chasseur", "B", 18.0, 0,
		"Tire une flèche (20% dégâts) qui ignore 20% de la défense de la cible.")
	_a("cha_tir_cascade",         "Tir en Cascade",          "chasseur", "B", 20.0, 0,
		"Tire une série de 5 flèches touchant plusieurs cibles, chacune infligeant 15% de dommage.")
	## A
	_p("cha_concentration",       "Concentration",           "chasseur", "A",
		"Augmente les chances de coup critique de 5%.")
	_a("cha_fleche_mortelle",     "Flèche Mortelle",         "chasseur", "A", 30.0, 0,
		"Tire une flèche infligeant 50% de dommage avec une chance accrue de coup critique de 50%.")
	_a("cha_piqure_scorpion",     "Piqûre de Scorpion",      "chasseur", "A", 25.0, 0,
		"Tire une flèche qui paralyse et empoisonne la cible pendant 3 secondes.")
	## S
	_a("cha_tir_legendaire",      "Tir Légendaire",          "chasseur", "S", 60.0, 0,
		"Tire une flèche infligeant 300% des dégâts normaux, chance de tuer instantanément si l'ennemi est sous 20% de santé.")
	_a("cha_pluie_fleches",       "Pluie de Flèches",        "chasseur", "S", 45.0, 0,
		"Tire une salve de flèches dans une large zone, infligeant des dégâts massifs à tous les ennemis à portée.")


# ─────────────────────────────────────────────
#  GUÉRISSEUR
# ─────────────────────────────────────────────
func _register_guerisseur_skills() -> void:
	## F
	_a("gue_soin_mineur",         "Soin Mineur",             "guerisseur", "F",  3.0, 10,
		"Soigne 15% de points de vie d'un allié.")
	_a("gue_lumiere_purificatrice", "Lumière Purificatrice", "guerisseur", "F",  5.0,  8,
		"Dissipe un effet négatif d'un allié.")
	## E
	_a("gue_bouclier_lumiere",    "Bouclier de Lumière",     "guerisseur", "E",  5.0, 15,
		"Crée un bouclier protecteur autour d'un allié, absorbant 15% des dommages pendant 10 secondes.")
	_a("gue_regeneration",        "Régénération",            "guerisseur", "E", 20.0, 20,
		"Soigne progressivement un allié de 2% de vie par seconde pendant 10 secondes.")
	## D
	_a("gue_priere",              "Prière",                  "guerisseur", "D", 20.0, 18,
		"Augmente la défense de tous les alliés à portée (50px) de 10% pendant 15 secondes.")
	## C
	_a("gue_soin_groupe",         "Soin de Groupe",          "guerisseur", "C", 20.0, 25,
		"Soigne tous les alliés dans une zone (50px) de 20% de points de vie.")
	_a("gue_barriere_protectrice","Barrière Protectrice",    "guerisseur", "C", 25.0, 30,
		"Crée une barrière magique autour de tous les alliés, réduisant les dégâts subis de 15% pendant 10 secondes.")
	## B
	_a("gue_lumiere_divine",      "Lumière Divine",          "guerisseur", "B", 25.0, 35,
		"Soigne 40% de points de vie d'un allié et dissipe tous les effets négatifs.")
	_a("gue_main_lumiere",        "Main de Lumière",         "guerisseur", "B", 20.0, 30,
		"Soigne un allié de 50% de points de vie instantanément.")
	## A
	_a("gue_purification_masse",  "Purification de Masse",   "guerisseur", "A", 30.0, 35,
		"Dissipe tous les effets négatifs de tous les alliés à portée (50px).")
	_a("gue_bouclier_sacre",      "Bouclier Sacré",          "guerisseur", "A", 35.0, 40,
		"Crée un bouclier qui absorbe tous les dégâts pour un allié pendant 10 secondes.")
	## S
	_a("gue_soin_supreme",        "Soin Suprême",            "guerisseur", "S", 45.0, 60,
		"Soigne tous les alliés à portée (75px) de 75% de points de vie.")
	_a("gue_resurrection",        "Résurrection",            "guerisseur", "S", 90.0, 70,
		"Ressuscite tous les alliés tombés au combat avec 30% de santé.")
	_a("gue_benediction_divine",  "Bénédiction Divine",      "guerisseur", "S", 60.0, 50,
		"Augmente toutes les statistiques de tous les alliés à portée (75px) de 20% pendant 15 secondes.")


# ─────────────────────────────────────────────
#  INVOCATEUR
# ─────────────────────────────────────────────
func _register_invocateur_skills() -> void:
	## F
	_a("inv_invocation_mineure",  "Invocation Mineure",      "invocateur", "F", 30.0, 10,
		"Invoque un familier mineur pour combattre à vos côtés pendant 10 secondes.")
	_p("inv_maitrise_esprits",    "Maîtrise des Esprits",    "invocateur", "F",
		"Augmente la durée des invocations de 5%.")
	## E
	_a("inv_lien_spirituel",      "Lien Spirituel",          "invocateur", "E", 15.0, 15,
		"Augmente les points de vie et les dégâts des invocations de 10%.")
	_a("inv_loup_fantome",        "Invocation de Loup Fantôme", "invocateur", "E", 30.0, 20,
		"Invoque un loup spectral qui attaque les ennemis pendant 15 secondes.")
	## D
	_a("inv_invocation_golem",    "Invocation de Golem",     "invocateur", "D", 30.0, 25,
		"Invoque un golem qui absorbe les dégâts pour l'invocateur pendant 15 secondes.")
	_a("inv_reanimation",         "Réanimation",             "invocateur", "D", 30.0, 30,
		"Ressuscite un ennemi tombé pendant 15 secondes pour qu'il combatte à vos côtés.")
	## C
	_a("inv_feu_follet",          "Invocation de Feu Follet","invocateur", "C", 25.0, 22,
		"Invoque un feu follet qui explose à proximité des ennemis, infligeant des dégâts de feu dans une zone de 15px.")
	_a("inv_canalisation_spirituelle", "Canalisation Spirituelle", "invocateur", "C", 25.0, 25,
		"Augmente la puissance des invocations de 15% pendant 20 secondes.")
	_a("inv_elementaire",         "Invocation d'Élémentaire","invocateur", "C", 30.0, 35,
		"Invoque un élémentaire de feu, d'eau, ou de terre (aléatoire) pendant 30 secondes.")
	## B
	_p("inv_maitre_invocations",  "Maître des Invocations",  "invocateur", "B",
		"Augmente la durée des invocations de 20%.")
	## A
	_a("inv_dragonnet",           "Invocation de Dragonnet", "invocateur", "A", 45.0, 40,
		"Invoque un dragonnet qui crache des flammes sur les ennemis pendant 15 secondes.")
	_a("inv_siphon_vie",          "Siphon de Vie",           "invocateur", "A", 30.0, 20,
		"Draine 10% de la vie d'une invocation active pour guérir l'invocateur de la même quantité.")
	## S
	_a("inv_phenix",              "Invocation de Phénix",    "invocateur", "S", 60.0, 50,
		"Invoque un phénix qui inflige de lourds dégâts de feu pendant 30 secondes et ressuscite une fois.")
	_a("inv_armee_ombres",        "Armée des Ombres",        "invocateur", "S", 60.0, 45,
		"Invoque 5 ombres qui attaquent les ennemis, chacune infligeant des dégâts modérés.")
	_a("inv_gardien_celeste",     "Gardien Céleste",         "invocateur", "S", 60.0, 50,
		"Invoque un gardien céleste protégeant tous les alliés à portée (75px), réduisant les dégâts subis de 20%.")


# ─────────────────────────────────────────────
#  HELPERS D'ENREGISTREMENT
# ─────────────────────────────────────────────

## Active skill
func _a(id: String, label: String, class_id: String, rank: String,
		cooldown: float, mana_cost: int, description: String) -> void:
	_register(id, label, class_id, rank, "active", cooldown, mana_cost, description)

## Passive skill
func _p(id: String, label: String, class_id: String, rank: String,
		description: String) -> void:
	_register(id, label, class_id, rank, "passive", 0.0, 0, description)

func _register(id: String, label: String, class_id: String, rank: String,
		type: String, cooldown: float, mana_cost: int, description: String) -> void:
	_skills[id] = {
		"id":          id,
		"label":       label,
		"class_id":    class_id,
		"rank":        rank,
		"type":        type,
		"description": description,
		"cooldown":    cooldown,
		"mana_cost":   mana_cost,
	}
	if not _by_class.has(class_id):
		_by_class[class_id] = []
	_by_class[class_id].append(id)


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_skill(id: String) -> Dictionary:
	return _skills.get(id, {})

func get_passive_combat_effects(skill_id: String) -> Dictionary:
	return PASSIVE_COMBAT_EFFECTS.get(skill_id, {})

## Toutes les compétences d'une classe
func get_skills_for_class(class_id: String) -> Array:
	var ids : Array = _by_class.get(class_id, [])
	var result : Array = []
	for id in ids:
		result.append(_skills[id])
	return result

## Compétences d'une classe accessibles jusqu'à un rang donné (inclusif)
func get_skills_up_to_rank(class_id: String, hero_rank: String) -> Array:
	var max_idx : int = RANK_ORDER.find(hero_rank)
	if max_idx == -1:
		max_idx = 0
	var result : Array = []
	for skill in get_skills_for_class(class_id):
		var skill_idx : int = RANK_ORDER.find(skill["rank"])
		if skill_idx <= max_idx:
			result.append(skill)
	return result

## Compétences d'un rang exact pour une classe
func get_skills_at_rank(class_id: String, rank: String) -> Array:
	var result : Array = []
	for skill in get_skills_for_class(class_id):
		if skill["rank"] == rank:
			result.append(skill)
	return result
