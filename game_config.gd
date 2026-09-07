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
const MINUTES_PER_TICK    := 5      # chaque tick = 5 minutes de jeu
const TICKS_PER_HOUR      := 12     # 60 min / 5 = 12 ticks
const HOURS_PER_DAY       := 24
const SECONDS_PER_TICK    := 1.0    # 1 seconde réelle par tick (vitesse x1)

# Multiplicateurs de vitesse disponibles (index = ID vitesse)
const TIME_SPEEDS         := [0.0, 1.0, 2.0, 4.0]  # 0=pause, 1=normal, 2=rapide, 4=x4

# ─────────────────────────────────────────────
#  HÉROS — BESOINS (valeurs 0–100)
# ─────────────────────────────────────────────
const NEED_DECAY := {
	"hunger":        -2.0,   # par heure
	"energy":        -3.0,
	"toilet":        -4.0,
	"hygiene":       -1.5,
	"entertainment": -2.5,
}

# Seuils déclenchant l'urgence
const NEED_URGENT_THRESHOLD := {
	"hunger":        30.0,
	"energy":        20.0,
	"toilet":        25.0,
	"hygiene":       20.0,
	"entertainment": 15.0,
}

# Seuils du planning (libre)
const NEED_FREE_THRESHOLD := {
	"hunger":        50.0,
	"energy":        40.0,
	"toilet":        40.0,
	"hygiene":       35.0,
	"entertainment": 30.0,
}

# ─────────────────────────────────────────────
#  HÉROS — STATS & MOUVEMENT
# ─────────────────────────────────────────────
const HERO_BASE_SPEED         := 80.0    # pixels/seconde
const HERO_SPEED_PER_AGILITY  := 0.5    # bonus vitesse par point d'agilité
const HERO_MAX_STAT           := 100.0
const HERO_STAT_XP_BASE       := 100.0  # XP nécessaire niveau 1→2
const HERO_STAT_XP_GROWTH     := 1.5    # coefficient de croissance

# Malus moral si le héros dort au sol
const PENALTY_SLEEP_FLOOR_MORALE := -7.0

# ─────────────────────────────────────────────
#  TRAVAIL & ENTRAÎNEMENT
# ─────────────────────────────────────────────
const CRAFT_GOLD_PER_HOUR     := 5      # or gagné par heure de travail à l'enclume
const WORK_XP_PER_HOUR        := 10     # XP gagné en travaillant
const TRAIN_XP_PER_HOUR       := 8      # XP gagné en s'entraînant
const TRAIN_STAT_PER_HOUR     := 0.5    # points de stat gagnés par heure d'entraînement
const SKILL_GROWTH_PER_HOUR   := 0.2    # progression du skill métier par heure

# ─────────────────────────────────────────────
#  CONSTRUCTION
# ─────────────────────────────────────────────
const TILE_SIZE               := 16      # pixels
const BUILD_ZONE_MIN          := Vector2i(0, 0)
const BUILD_ZONE_MAX          := Vector2i(99, 72)
const ADJACENT_OFFSETS        := [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
]

# ─────────────────────────────────────────────
#  ÉCONOMIE
# ─────────────────────────────────────────────
const STARTING_GOLD           := 5000
const STARTING_FOOD           := 10
const STARTING_REPUTATION     := 0
const INVENTORY_SIZE_DEFAULT  := 25

# ─────────────────────────────────────────────
#  JOBS — mapping id → objet de travail requis
# ─────────────────────────────────────────────
const JOB_OBJECTS := {
	0: "",                  # sans emploi
	1: "reception_desk",
	2: "anvil",
	3: "alchemy_workshop",
	4: "research_desk",
	5: "furnace",
}

# ─────────────────────────────────────────────
#  AUDIO
# ─────────────────────────────────────────────
const VOLUME_MASTER_DEFAULT   := 0.8
const VOLUME_MUSIC_DEFAULT    := 0.6
const VOLUME_SFX_DEFAULT      := 1.0
