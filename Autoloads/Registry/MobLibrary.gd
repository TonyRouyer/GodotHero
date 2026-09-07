## MobLibrary.gd — Autoload
## Registre de tous les mobs du jeu.
##
## Structure d'un mob :
##   id             : String
##   label          : String
##   rank           : String           — F E D C B A S
##   description    : String
##   threat_factor  : float            — 0.0–1.0 (poids en mission)
##   speed          : float            — px/s
##   stats          : { strength, defense, agility, magic, luck }
##   drops          : Array[{ item_id, min, max, rare }]
##   attacks.basic  : { label, description, power, aoe, aoe_radius, effect }
##   attacks.special: { label, description, power, aoe, aoe_radius, effect }
##
## Structure d'un effect (null si aucun) :
##   type     : String  — voir constantes EFFECT_*
##   value    : float   — force de l'effet (%, dégâts/s, unités…)
##   duration : float   — durée en secondes
##   chance   : float   — probabilité d'application (0.0–1.0)
##   target   : String  — "target" | "self" | "allies" | "aoe"
extends Node


# ─────────────────────────────────────────────
#  CONSTANTES EFFETS
# ─────────────────────────────────────────────
const EFFECT_POISON     : String = "poison"        # dégâts/s
const EFFECT_BURN       : String = "burn"          # dégâts feu/s
const EFFECT_STUN       : String = "stun"          # immobilise
const EFFECT_SLOW       : String = "slow"          # réduit vitesse (%)
const EFFECT_FEAR       : String = "fear"          # fuite
const EFFECT_KNOCKBACK  : String = "knockback"     # repousse
const EFFECT_SILENCE    : String = "silence"       # bloque les skills
const EFFECT_DEBUFF_DEF : String = "debuff_defense"
const EFFECT_DEBUFF_AGI : String = "debuff_agility"
const EFFECT_DEBUFF_STR : String = "debuff_strength"
const EFFECT_DEBUFF_MAG : String = "debuff_magic"
const EFFECT_BUFF_AGI   : String = "buff_agility"
const EFFECT_BUFF_DEF   : String = "buff_defense"
const EFFECT_BUFF_STR   : String = "buff_strength"
const EFFECT_LIFESTEAL  : String = "lifesteal"     # soigne % des dégâts infligés
const EFFECT_HEAL_ALLIES: String = "heal_allies"   # soigne alliés (%)
const EFFECT_MANA_DRAIN : String = "mana_drain"    # vole % mana


var _mobs : Dictionary = {}


func _ready() -> void:
	_register_f_mobs()
	_register_e_mobs()
	_register_d_mobs()
	_register_c_mobs()
	_register_b_mobs()
	_register_a_mobs()
	_register_s_mobs()


# ─────────────────────────────────────────────
#  RANG F
# ─────────────────────────────────────────────
func _register_f_mobs() -> void:

	_add("slime", "Slime", "F",
		"Petite créature gélatineuse inoffensive seule, mais gênante en groupe.",
		0.10, 100.0,
		_stats(3, 4, 6, 1, 5),
		[_drop("slime_gel", 1, 1), _drop("arcane_crystal", 1, 1, true)],
		_atk("Coup gluant",   "Le slime bondit pour heurter l'ennemi.", 4),
		_atk("Charge instable", "S'écrase sur l'ennemi, infligeant de légers dégâts de zone.", 3,
			true, 30.0)
	)

	_add("araignee_sylvestre", "Araignée Sylvestre", "F",
		"Petite créature forestière tapie dans les bois humides. Tisse des toiles collantes et attaque en embuscade.",
		0.15, 90.0,
		_stats(4, 3, 8, 1, 5),
		[_drop("sticky_resin", 1, 1), _drop("venom", 1, 2), _drop("black_berry", 1, 1, true)],
		_atk("Morsure rapide", "Inflige des dégâts faibles mais rapides.", 5),
		_atk("Jet de toile",   "Ralentit la cible.", 2,
			false, 0.0, _fx(EFFECT_SLOW, 30.0, 3.0))
	)


# ─────────────────────────────────────────────
#  RANG E
# ─────────────────────────────────────────────
func _register_e_mobs() -> void:

	_add("loup", "Loup", "E",
		"Prédateur rapide, commun dans les forêts. Dangereux en meute.",
		0.20, 250.0,
		_stats(8, 6, 12, 2, 5),
		[_drop("raw_hide", 1, 2), _drop("wolf_meat", 1, 2),
		 _drop("animal_fat", 1, 2), _drop("arcane_crystal", 1, 1, true)],
		_atk("Morsure sauvage",    "Mord violemment une cible.", 10),
		_atk("Hurlement de meute", "Buff de 10% en agilité pour les alliés loups pendant 10s.", 0,
			false, 0.0, _fx(EFFECT_BUFF_AGI, 10.0, 10.0, 1.0, "allies"))
	)

	_add("sanglier", "Sanglier", "E",
		"Bête sauvage courante dans les forêts denses. Il charge brutalement les intrus et possède une peau épaisse.",
		0.25, 90.0,
		_stats(9, 7, 6, 1, 4),
		[_drop("boar_meat", 1, 2), _drop("leather", 1, 1),
		 _drop("animal_fat", 1, 3), _drop("raw_hide", 1, 2)],
		_atk("Charge bestiale",    "Attaque frontale puissante, chance de repoussement.", 3,
			false, 0.0, _fx(EFFECT_KNOCKBACK, 1.0, 0.5, 0.4)),
		_atk("Grognement furieux", "Augmente sa propre défense de +10% pendant 6s.", 0,
			false, 0.0, _fx(EFFECT_BUFF_DEF, 10.0, 6.0, 1.0, "self"))
	)

	_add("soldat_squelette", "Soldat Squelette", "E",
		"Guerrier réanimé, garde les ruines du passé. Armé d'armes rouillées.",
		0.20, 100.0,
		_stats(7, 6, 5, 2, 3),
		[_drop("iron_ore", 1, 1), _drop("arcane_crystal", 1, 1),
		 _drop("berserker_bone", 1, 1, true)],
		_atk("Coup d'épée rouillée", "Attaque frontale avec une épée usée.", 8),
		_atk("Cri spectral",         "Réduit la défense de la cible de 5 pendant 5s.", 0,
			false, 0.0, _fx(EFFECT_DEBUFF_DEF, 5.0, 5.0))
	)


# ─────────────────────────────────────────────
#  RANG D
# ─────────────────────────────────────────────
func _register_d_mobs() -> void:

	_add("gobelin", "Gobelin", "D",
		"Créature rusée et sournoise, souvent en groupe.",
		0.15, 120.0,
		_stats(5, 4, 8, 3, 8),
		[_drop("goblin_teeth", 2, 3), _drop("goblin_meat", 1, 1),
		 _drop("iron_ore", 1, 4), _drop("arcane_crystal", 1, 1, true)],
		_atk("Coup de poignard", "Frappe furtive avec une lame courte.", 7),
		_atk("Jet de pierre",    "Inflige des dégâts à distance, 10% de chance d'étourdir 3s.", 5,
			false, 0.0, _fx(EFFECT_STUN, 0.0, 3.0, 0.10))
	)

	_add("vipere", "Vipère", "D",
		"Reptile rapide et venimeux.",
		0.25, 150.0,
		_stats(6, 5, 14, 4, 8),
		[_drop("venom", 1, 2), _drop("viper_meat", 1, 1), _drop("arcane_crystal", 1, 1, true)],
		_atk("Morsure venimeuse", "Mord la cible en infligeant du poison (2 dégâts/s, 5s).", 6,
			false, 0.0, _fx(EFFECT_POISON, 2.0, 5.0)),
		_atk("Constriction",      "Immobilise la cible pendant 2s.", 4,
			false, 0.0, _fx(EFFECT_STUN, 0.0, 2.0))
	)

	_add("esprit_ruines", "Esprit des Ruines", "D",
		"Ombre hantant les anciens lieux magiques. Faible physiquement, dangereux magiquement.",
		0.35, 110.0,
		_stats(2, 5, 10, 12, 6),
		[_drop("shadow_essence", 1, 1), _drop("ghost_cloth", 1, 1), _drop("arcane_crystal", 1, 1)],
		_atk("Toucher spectral",  "Inflige des dégâts magiques purs.", 9),
		_atk("Hurlement du passé","Provoque la peur (3s) et réduit la magie de 5%.", 0,
			false, 0.0, _fx(EFFECT_FEAR, 0.0, 3.0))
	)


# ─────────────────────────────────────────────
#  RANG C
# ─────────────────────────────────────────────
func _register_c_mobs() -> void:

	_add("orque_berserker", "Orque Berserker", "C",
		"Guerrier brutal, au combat frénétique.",
		0.40, 100.0,
		_stats(14, 10, 7, 2, 4),
		[_drop("berserker_bone", 1, 1), _drop("arcane_crystal", 1, 1, true)],
		_atk("Coup de massue",     "Frappe dévastatrice au corps à corps.", 3),
		_atk("Frénésie sanglante", "+5 Force, -5 Défense pendant 15s sur soi-même.", 0,
			false, 0.0, _fx(EFFECT_BUFF_STR, 5.0, 15.0, 1.0, "self"))
	)

	_add("spectre_hante", "Spectre Hanté", "C",
		"Esprit intangible, difficile à atteindre physiquement.",
		0.40, 100.0,
		_stats(3, 7, 12, 15, 6),
		[_drop("ghost_cloth", 1, 2), _drop("shadow_essence", 1, 1, true), _drop("arcane_crystal", 1, 1)],
		_atk("Drain vital",         "Soigne le spectre à hauteur de 50% des dégâts infligés.", 8,
			false, 0.0, _fx(EFFECT_LIFESTEAL, 50.0, 0.0)),
		_atk("Hurlement surnaturel","Provoque la peur pendant 3 secondes.", 0,
			false, 0.0, _fx(EFFECT_FEAR, 0.0, 3.0))
	)

	_add("chasseur_elfe_noir", "Chasseur Elfe Noir", "C",
		"Ennemi furtif et intelligent, utilise des flèches enduites de poison ou de magie.",
		0.45, 130.0,
		_stats(10, 8, 14, 6, 10),
		[_drop("black_berry", 1, 2), _drop("amber", 1, 1), _drop("magic_rune", 1, 1, true)],
		_atk("Tir empoisonné", "Poison 3 dégâts/s pendant 5s.", 8,
			false, 0.0, _fx(EFFECT_POISON, 3.0, 5.0)),
		_atk("Flèche runique",  "Inflige le silence pendant 4s.", 10,
			false, 0.0, _fx(EFFECT_SILENCE, 0.0, 4.0))
	)


# ─────────────────────────────────────────────
#  RANG B
# ─────────────────────────────────────────────
func _register_b_mobs() -> void:

	_add("cyclope", "Cyclope", "B",
		"Géant monoculaire à la force brute et résistante.",
		0.50, 80.0,
		_stats(18, 16, 4, 3, 5),
		[_drop("raw_hide", 2, 4), _drop("cyclops_eye", 1, 1, true), _drop("arcane_crystal", 1, 1, true)],
		_atk("Coup massif",    "Frappe dévastatrice qui pulvérise la cible.", 18),
		_atk("Piétinement",    "Réduit l'agilité de zone de 15% pendant 10s.", 8,
			true, 50.0, _fx(EFFECT_DEBUFF_AGI, 15.0, 10.0, 1.0, "aoe"))
	)

	_add("chaman_corrompu", "Chaman Corrompu", "B",
		"Mage déchu, usant de magie noire.",
		0.35, 100.0,
		_stats(5, 6, 8, 18, 7),
		[_drop("shadow_essence", 1, 2), _drop("totem_corrompu", 1, 1, true), _drop("arcane_crystal", 1, 1)],
		_atk("Flamme noire",        "Brûle la cible (5 dégâts/s pendant 5s).", 0,
			false, 0.0, _fx(EFFECT_BURN, 5.0, 5.0)),
		_atk("Malédiction des ombres", "-5% Force & Défense pendant 15s.", 0,
			false, 0.0, _fx(EFFECT_DEBUFF_DEF, 5.0, 15.0))
	)

	_add("basilic_caverneux", "Basilic Caverneux", "B",
		"Serpent géant aux écailles dures. Vit dans les grottes profondes.",
		0.55, 100.0,
		_stats(12, 12, 8, 3, 5),
		[_drop("venom", 1, 1), _drop("dragon_scale", 1, 2), _drop("animal_fat", 1, 2)],
		_atk("Morsure paralysante", "Chance de stun 2s.", 12,
			false, 0.0, _fx(EFFECT_STUN, 0.0, 2.0, 0.50)),
		_atk("Regard pétrifiant",   "10% de chance de geler une cible pendant 3s.", 0,
			false, 0.0, _fx(EFFECT_STUN, 0.0, 3.0, 0.10))
	)

	_add("gardien_lave", "Gardien de Lave", "B",
		"Créature élémentaire vivant dans les profondeurs volcaniques. Lente mais puissante.",
		0.50, 80.0,
		_stats(14, 14, 3, 10, 4),
		[_drop("charcoal", 2, 2), _drop("flame_heart", 1, 1), _drop("steel_ingot", 1, 1, true)],
		_atk("Poing brûlant",    "Frappe + brûlure 5s.", 16,
			false, 0.0, _fx(EFFECT_BURN, 5.0, 5.0)),
		_atk("Explosion de lave","AoE de feu : 15 dégâts + lenteur 2s.", 15,
			true, 50.0, _fx(EFFECT_SLOW, 50.0, 2.0, 1.0, "aoe"))
	)


# ─────────────────────────────────────────────
#  RANG A
# ─────────────────────────────────────────────
func _register_a_mobs() -> void:

	_add("dragonnet_feu", "Dragonnet de Feu", "A",
		"Jeune dragon extrêmement dangereux malgré sa taille.",
		0.50, 150.0,
		_stats(12, 10, 9, 14, 8),
		[_drop("dragon_scale", 2, 3), _drop("dragonnet_meat", 1, 1),
		 _drop("flame_heart", 1, 1, true), _drop("arcane_crystal", 1, 1),
		 _drop("animal_fat", 1, 3)],
		_atk("Griffure",         "Lacère la cible avec ses serres.", 14),
		_atk("Souffle enflammé", "Crache du feu : brûlure 10 dégâts/s pendant 3s.", 0,
			true, 50.0, _fx(EFFECT_BURN, 10.0, 3.0, 1.0, "aoe"))
	)

	_add("ent_ancien", "Ent Ancien", "A",
		"Gardien millénaire des forêts primordiales. Lourdement défensif, peut soigner ses alliés.",
		0.65, 70.0,
		_stats(16, 18, 4, 10, 7),
		[_drop("amber", 2, 2), _drop("sticky_resin", 2, 2), _drop("reinforced_wood", 1, 1)],
		_atk("Écrasement racinaire",  "AoE physique massif.", 16, true, 50.0),
		_atk("Renaissance sylvestre", "Soigne les alliés à proximité de 10% de leurs PV.", 0,
			true, 75.0, _fx(EFFECT_HEAL_ALLIES, 10.0, 0.0, 1.0, "allies"))
	)


# ─────────────────────────────────────────────
#  RANG S
# ─────────────────────────────────────────────
func _register_s_mobs() -> void:

	_add("seigneur_demoniaque", "Seigneur Démoniaque", "S",
		"Ennemi ultime. Manipulateur, destructeur, et terrifiant.",
		1.00, 110.0,
		_stats(20, 18, 12, 22, 15),
		[_drop("demon_horn", 1, 2), _drop("dark_heart", 1, 1, true),
		 _drop("chaos_shard", 2, 3), _drop("arcane_crystal", 1, 1),
		 _drop("spirit_fragment", 1, 1, true)],
		_atk("Frappe du chaos",  "Attaque physique colossale.", 20),
		_atk("Souffle infernal", "Zone : brûlure 15 dégâts/s pendant 4s.", 0,
			true, 75.0, _fx(EFFECT_BURN, 15.0, 4.0, 1.0, "aoe"))
	)

	_add("spectre_oubli", "Spectre d'Oubli", "S",
		"Manifestation d'une mémoire effacée. Entité rare, puissante, imprévisible.",
		1.00, 150.0,
		_stats(8, 10, 16, 20, 12),
		[_drop("spirit_fragment", 1, 1), _drop("shadow_essence", 1, 1), _drop("arcane_crystal", 1, 1)],
		_atk("Drain mental",     "Vole 10% de mana et inflige des dégâts magiques.", 12,
			false, 0.0, _fx(EFFECT_MANA_DRAIN, 10.0, 0.0)),
		_atk("Brume de l'oubli","Silence de zone (3s) + chance de désactiver une compétence temporairement.", 6,
			true, 75.0, _fx(EFFECT_SILENCE, 0.0, 3.0, 1.0, "aoe"))
	)


# ─────────────────────────────────────────────
#  HELPERS DE CONSTRUCTION
# ─────────────────────────────────────────────

func _stats(strength: int, def: int, agi: int, mag: int, lck: int) -> Dictionary:
	return {"strength": strength, "defense": def, "agility": agi, "magic": mag, "luck": lck}

func _drop(item_id: String, min_qty: int, max_qty: int, rare: bool = false) -> Dictionary:
	return {"item_id": item_id, "min": min_qty, "max": max_qty, "rare": rare}

func _fx(type: String, value: float, duration: float,
		chance: float = 1.0, target: String = "target") -> Dictionary:
	return {"type": type, "value": value, "duration": duration, "chance": chance, "target": target}

func _atk(label: String, description: String, power: int,
		aoe: bool = false, aoe_radius: float = 0.0, effect = null) -> Dictionary:
	return {
		"label":       label,
		"description": description,
		"power":       power,
		"aoe":         aoe,
		"aoe_radius":  aoe_radius,
		"effect":      effect,
	}

func _add(id: String, label: String, rank: String, description: String,
		threat_factor: float, speed: float,
		stats: Dictionary, drops: Array,
		basic_attack: Dictionary, special_attack: Dictionary) -> void:
	_mobs[id] = {
		"id":            id,
		"label":         label,
		"rank":          rank,
		"description":   description,
		"threat_factor": threat_factor,
		"speed":         speed,
		"stats":         stats,
		"drops":         drops,
		"attacks": {
			"basic":   basic_attack,
			"special": special_attack,
		},
	}


# ─────────────────────────────────────────────
#  ACCESSEURS
# ─────────────────────────────────────────────

func get_mob(id: String) -> Dictionary:
	return _mobs.get(id, {})

func get_all_mobs() -> Array:
	return _mobs.values()

func get_mobs_by_rank(rank: String) -> Array:
	var result : Array = []
	for mob in _mobs.values():
		if mob["rank"] == rank:
			result.append(mob)
	return result

## PV_max calculé selon la même formule que les héros
func get_hp_max(id: String) -> float:
	var mob : Dictionary = get_mob(id)
	if mob.is_empty():
		return 0.0
	var s : Dictionary = mob["stats"]
	return 100.0 + (s["strength"] * 2.0) + (s["defense"] * 1.5)

## Retourne tous les drops non-rares d'un mob
func roll_drops(id: String, rng: RandomNumberGenerator = null) -> Array:
	var mob : Dictionary = get_mob(id)
	if mob.is_empty():
		return []
	var result : Array = []
	for drop in mob["drops"]:
		if drop["rare"]:
			continue
		var qty : int
		if rng:
			qty = rng.randi_range(drop["min"], drop["max"])
		else:
			qty = randi_range(drop["min"], drop["max"])
		result.append({"item_id": drop["item_id"], "qty": qty})
	return result
