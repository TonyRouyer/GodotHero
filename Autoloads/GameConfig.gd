## GameConfig — Autoload #1
## Toutes les constantes, chemins et valeurs de balancing du jeu.
## Ne contient AUCUN état — uniquement des valeurs en lecture seule.
## Modifier ici pour rebalancer sans chercher dans tout le code.
extends Node


# ─────────────────────────────────────────────
#  CHEMINS DE RESSOURCES
# ─────────────────────────────────────────────
const PATH_HERO_DATA      := "res://Resources/Heroes/"
const PATH_ITEMS          := "res://Resources/Items/"
const PATH_RECIPES        := "res://Resources/Recipes/"
const PATH_RESEARCH       := "res://Resources/Research/"
const PATH_OBJECTS        := "res://Resources/Objects/"
const PATH_SCENES_MENUS   := "res://Scenes/Menus/"
const PATH_SCENES_GUILD   := "res://Scenes/Guild/GuildScene.tscn"
const PATH_SCENES_MISSION := "res://Scenes/Mission/MissionScene.tscn"
const PATH_SAVE           := "user://save.json"

# ─────────────────────────────────────────────
#  TEMPS
# ─────────────────────────────────────────────
const MINUTES_PER_TICK    :int   = 5      # chaque tick = 5 minutes de jeu
const TICKS_PER_HOUR      :int   = 12     # 60 min / 5 = 12 ticks
const HOURS_PER_DAY       :int   = 24
const TICKS_PER_DAY       :int   = TICKS_PER_HOUR * HOURS_PER_DAY  # 288 ticks/jour
const SECONDS_PER_TICK    :float = 1.0    # 1 seconde réelle par tick (vitesse x1)

# Multiplicateurs de vitesse disponibles 
const TIME_SPEEDS         :Array = [0.0, 1.0, 2.0, 4.0]  # 0=pause, 1=normal, 2=rapide, 4=x4

# ─────────────────────────────────────────────
#  HÉROS — BESOINS (valeurs 0–100)
# ─────────────────────────────────────────────
## Perte par tick (5 min de jeu). Valeurs négatives = besoin qui diminue.
## Exemples : hunger -0.7/tick → de 100 à 0 en ~143 ticks ≈ 12h de jeu.
##            energy  -0.5/tick → critique(8) atteint après ~184 ticks ≈ 15h.
const NEED_DECAY :Dictionary = {
	"hunger":        -0.7,
	"energy":        -0.5,
	"toilet":        -0.9,
	"hygiene":       -0.25,
	"entertainment": -0.4,
}

# Seuils critiques — interrompent TOUJOURS la tâche en cours, même le travail
const NEED_CRITICAL_THRESHOLD :Dictionary = {
	"hunger":  10.0,
	"energy":   8.0,
	"toilet":   8.0,
}

# Seuils d'urgence — interrompent le travail/entraînement/construction
const NEED_URGENT_THRESHOLD :Dictionary = {
	"hunger":        30.0,
	"energy":        20.0,
	"toilet":        25.0,
	"hygiene":       20.0,
	"entertainment": 25.0,  ## GDD §3.3 : seuil de recherche autonome
}

# Seuils du planning (libre)
const NEED_FREE_THRESHOLD :Dictionary = {
	"hunger":        50.0,
	"energy":        40.0,
	"toilet":        40.0,
	"hygiene":       35.0,
	"entertainment": 30.0,
}

# ─────────────────────────────────────────────
#  HÉROS — STATS & MOUVEMENT
# ─────────────────────────────────────────────
const HERO_BASE_SPEED         :float = 100.0   # pixels/seconde (GDD §7.7)
const HERO_SPEED_PER_AGILITY  :float = 0.5    # bonus vitesse par point d'agilité
const HERO_MAX_STAT           :float = 100.0
const HERO_STAT_XP_BASE       :float = 100.0  # XP nécessaire niveau 1→2
const HERO_STAT_XP_GROWTH     :float = 1.7    # coefficient de croissance (GDD §2.5)

# Malus moral si le héros dort au sol
const PENALTY_SLEEP_FLOOR_MORALE :float = -7.0

# ─────────────────────────────────────────────
#  TRAVAIL & ENTRAÎNEMENT
# ─────────────────────────────────────────────
## Restauration des besoins par tick (pendant utilisation de l'objet)
const TOILET_RESTORE_PER_TICK        : float = 12.0
const HYGIENE_RESTORE_PER_TICK       : float = 8.0
const ENTERTAINMENT_RESTORE_PER_TICK : float = 6.0
const HUNGER_RESTORE_PER_TICK        : float = 10.0

const COOK_FOOD_PER_HOUR      :int   = 3
const RECEPTION_REP_PER_HOUR  :int   = 1      # réputation gagnée par heure par le réceptionniste      # repas produits par heure par le cuisinier
const SERVING_TABLE_RESTORE_PER_TICK : float = 10.0  # faim restaurée par tick à la table de service
const WORK_XP_PER_HOUR        :int   = 10     # XP gagné en travaillant
const TRAIN_XP_PER_HOUR       :int   = 8      # XP gagné en s'entraînant
const TRAIN_STAT_PER_HOUR     :float = 0.5    # points de stat gagnés par heure d'entraînement
const SKILL_GROWTH_PER_HOUR   :float = 0.2    # progression du skill métier par heure

# ─────────────────────────────────────────────
#  CONSTRUCTION
# ─────────────────────────────────────────────
const TILE_SIZE               :int      = 16      # pixels
const BUILD_ZONE_MIN          :Vector2i = Vector2i(0, 0)
const BUILD_ZONE_MAX          :Vector2i = Vector2i(99, 72)
const ADJACENT_OFFSETS        :Array    = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
]

const DAY_CYCLE_COLORS: Dictionary = {
	0:  Color(0.20, 0.20, 0.35),  # Minuit 
	5:  Color(0.30, 0.25, 0.40),  # Avant l'aube
	6:  Color(0.80, 0.50, 0.30),  # Lever de soleil 
	8:  Color(1.00, 1.00, 1.00),  # Plein jour
	12: Color(1.00, 1.00, 0.95),  # Midi 
	18: Color(1.00, 0.75, 0.45),  # Coucher de soleil 
	20: Color(0.40, 0.30, 0.50),  # Crépuscule 
	22: Color(0.22, 0.22, 0.38),  # Nuit 
}

# ─────────────────────────────────────────────
#  ÉCONOMIE
# ─────────────────────────────────────────────
const STARTING_GOLD           :int = 5000
const STARTING_FOOD           :int = 10
const STARTING_REPUTATION     :int = 0
const INVENTORY_SIZE_DEFAULT  :int = 25

# ─────────────────────────────────────────────
#  JOBS — mappings travail & craft
# ─────────────────────────────────────────────
## Rétro-compat : objet principal par job (utilisé dans UI et anciens systèmes).
const JOB_OBJECTS :Dictionary = {
	0: "",
	1: "reception_desk",
	2: "forge",
	3: "alchemy_table",
	4: "research_desk",
	5: "furnace",
}

## Objets valides par job (ordre de préférence).
## HeroActivity._work() cherche le premier libre dans cette liste.
const JOB_CRAFT_OBJECTS : Dictionary = {
	0: [],
	1: ["reception_desk"],
	2: ["forge", "workbench_craft", "tanning_rack", "loom"],
	3: ["alchemy_table", "magic_cauldron"],
	4: ["research_desk"],
	5: ["furnace"],
}

## Stat de compétence métier progressée par job.
const JOB_SKILL_STAT : Dictionary = {
	1: "social",
	2: "manual_work",
	3: "occult_work",
	4: "knowledge",
	5: "cooking",
}

## Lieu de craft (MaterialLibrary.craft_location) → object_id correspondant.
const CRAFT_LOCATION_TO_OBJECT : Dictionary = {
	"forge":           "forge",
	"atelier":         "workbench_craft",
	"metier_a_tisser": "loom",
	"tannage":         "tanning_rack",
	"table_alchimie":  "alchemy_table",
	"four":            "furnace",
}

## Objets de craft des jobs 2 et 3 (subissent la gestion de file CraftManager).
const CRAFT_STATION_IDS : Array[String] = [
	"forge", "workbench_craft", "tanning_rack", "loom", "alchemy_table", "magic_cauldron",
]

## Facteur de vitesse de craft (GDD §8.1).
## progress_per_tick = (skill / craft_time_hours) * CRAFT_SPEED_FACTOR
## Exemple : skill=20, craft_time=6h → 20/6 × 0.35 ≈ 1.17/tick → ~85 ticks ≈ 7h.
const CRAFT_SPEED_FACTOR : float = 0.35

## Points de recherche produits par heure par un Chercheur (base, avant bonus knowledge).
const RESEARCH_POINTS_PER_HOUR : float = 5.0

## Difficulté de recherche par niveau (§4 design doc travail/chercheur).
const RESEARCH_DIFFICULTY : Dictionary = {
	1: 3, 2: 4, 3: 5, 4: 6, 5: 7,
	6: 8, 7: 9, 8: 10, 9: 12, 10: 14,
}

# ─────────────────────────────────────────────
#  AUDIO
# ─────────────────────────────────────────────
const VOLUME_MASTER_DEFAULT   :float = 0.8
const VOLUME_MUSIC_DEFAULT    :float = 0.6
const VOLUME_SFX_DEFAULT      :float = 1.0
