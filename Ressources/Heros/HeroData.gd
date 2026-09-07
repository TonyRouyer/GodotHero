## HeroData.gd
## Resource de données d'un héros. Source de vérité unique.
## Tous les composants lisent/écrivent ici.
extends Resource
class_name HeroData


# ─────────────────────────────────────────────
#  IDENTITÉ
# ─────────────────────────────────────────────
@export var hero_id    : int    = -1
@export var hero_name  : String = ""
@export var hero_class : String = ""       # ex: "warrior", "mage", "roublard"...
@export var skin       : String = ""       # clé d'animation / spritesheet

## Type de classe : "physique" ou "magique"
@export var class_type    : String          = "physique"
## Catégories d'armes équipables selon la classe (ex: ["epee", "hache"])
@export var weapon_types  : Array[String]   = []
## Catégorie d'armure équipable selon la classe (ex: "lourde", "moyenne", "legere")
@export var armor_type    : String          = "legere"

# ─────────────────────────────────────────────
#  RANG & NIVEAU
# ─────────────────────────────────────────────
@export var level      : int    = 1
@export var xp         : float  = 0.0
@export var rank       : String = "F"      # F E D C B A S
@export var missions_last_20 : Array = []  # historique pour le rang (true/false)

# ─────────────────────────────────────────────
#  STATS PRINCIPALES
# ─────────────────────────────────────────────
@export var strength   : float = 10.0
@export var defense    : float = 10.0
@export var agility    : float = 10.0
@export var magic      : float = 10.0
@export var luck       : float = 10.0

# ─────────────────────────────────────────────
#  STATS DÉRIVÉES
# ─────────────────────────────────────────────
@export var hp_max     : float = 100.0
@export var hp         : float = 100.0
@export var mana_max   : float = 50.0
@export var mana       : float = 50.0
@export var moral      : float = 100.0

# ─────────────────────────────────────────────
#  STATS MÉTIER (secondaires)
# ─────────────────────────────────────────────
@export var social          : float = 1.0
@export var manual_work     : float = 1.0
@export var occult_work     : float = 1.0
@export var cooking         : float = 1.0
@export var knowledge       : float = 1.0

# ─────────────────────────────────────────────
#  BESOINS PRIMAIRES (100 = plein, 0 = vide)
# ─────────────────────────────────────────────
@export var energy        : float = 100.0   # sommeil
@export var hunger        : float = 100.0   # faim (100=rassasié, 0=affamé)
@export var entertainment : float = 100.0
@export var toilet        : float = 100.0
@export var hygiene       : float = 100.0

# ─────────────────────────────────────────────
#  ÉCONOMIE
# ─────────────────────────────────────────────
@export var salary        : int   = 10      # or/jour
@export var days_unpaid   : int   = 0

# ─────────────────────────────────────────────
#  PLANNING  { heure(int) → "sleep"|"work"|"train"|"free" }
# ─────────────────────────────────────────────
@export var planning      : Dictionary = {}

# ─────────────────────────────────────────────
#  TRAVAIL
# ─────────────────────────────────────────────
@export var job           : int    = 0      # 0=libre, 1=accueil, 2=forgeron...
@export var assigned_bed  : NodePath = NodePath()

# ─────────────────────────────────────────────
#  MISSIONS
# ─────────────────────────────────────────────
@export var on_mission           : bool = false
@export var mission_return_day   : int  = -1
@export var mission_return_hour  : int  = -1

# ─────────────────────────────────────────────
#  PRIORITÉS D'ENTRAÎNEMENT (0–100)
# ─────────────────────────────────────────────
@export var strength_priority : int = 25
@export var defense_priority  : int = 25
@export var agility_priority  : int = 25
@export var mana_priority     : int = 25

# ─────────────────────────────────────────────
#  TRAITS
# ─────────────────────────────────────────────
@export var traits        : Array[String] = []

# ─────────────────────────────────────────────
#  COMPÉTENCES  [{ "id", "rank", "level" }]
# ─────────────────────────────────────────────
@export var skills          : Array = []
## Les 4 slots actifs sélectionnés par le joueur (IDs de compétences actives)
@export var equipped_skills : Array[String] = []
## Points disponibles pour apprendre de nouvelles compétences (1 par level up)
@export var skill_points    : int           = 0
## Enchantements actifs par slot d'équipement { slot → enchantment_id }
@export var enchantments    : Dictionary    = {
	"weapon": "", "head": "", "torso": "", "legs": "", "accessory": "",
}
## Buffs temporaires actifs (depuis plats cuisinés) [{ "stat": String, "value": float, "expires_day": int }]
@export var active_buffs    : Array         = []

# ─────────────────────────────────────────────
#  ÉQUIPEMENT  { slot → item_id }
# ─────────────────────────────────────────────
@export var equipment     : Dictionary = {
	"weapon":     "",
	"head":       "",
	"torso":      "",
	"legs":       "",
	"accessory":  "",
	"accessory2": "",
	"consumable":  "",
	"consumable2": "",
}
## Quantité stackée dans chaque slot consommable (0 = slot vide)
@export var consumable_quantities : Dictionary = {
	"consumable":  0,
	"consumable2": 0,
}

# ─────────────────────────────────────────────
#  APPEARANCE
# ─────────────────────────────────────────────
@export var appearance : Dictionary = {
	"body":   "",
	"eyes":   "",
	"hair":   "",
	"top":    "",
	"bottom": "",
}

# ─────────────────────────────────────────────
#  FLAGS
# ─────────────────────────────────────────────
@export var control_by_player : bool = false
@export var is_advanced_class : bool = false


# ─────────────────────────────────────────────
#  GETTERS CALCULÉS
# ─────────────────────────────────────────────
## Retourne les bonus d'équipement agrégés pour un stat donné (item + enchantements).
## stat_key : "atk" | "matk" | "def" | "mdef" | "spd" | "crit" | "hp" | "mana"
func get_equipment_bonus(stat_key: String) -> float:
	var total : float = 0.0
	for slot in equipment:
		var item_id : String = equipment[slot]
		if item_id == "":
			continue
		var item : Dictionary = EquipmentLibrary.get_item(item_id)
		total += item.get("stats", {}).get(stat_key, 0.0)
		## Bonus enchantement sur ce slot
		var ench_id : String = enchantments.get(slot, "")
		if ench_id != "":
			var ench : Dictionary = EnchantmentLibrary.get_enchantment(ench_id)
			total += ench.get("stats", {}).get(stat_key, 0.0)
	return total


func get_speed() -> float:
	## V = V_base × (1 + Agilité / 100)
	return GameConfig.HERO_BASE_SPEED * (1.0 + agility / 100.0)

func get_hp_max() -> float:
	## PV_max = (100 + Force×2 + Défense×1.5 + bonus équip) × multiplicateur traits
	var base : float = 100.0 + (strength * 2.0) + (defense * 1.5) + get_equipment_bonus("hp")
	return base * TraitLibrary.get_hp_mult(traits)

func get_mana_max() -> float:
	## Mana_max = 50 + (Magie × 3) + bonus équipement
	return 50.0 + (magic * 3.0) + get_equipment_bonus("mana")

func get_crit_chance() -> float:
	## P_crit = Chance × 0.5 + bonus équipement
	return luck * 0.5 + get_equipment_bonus("crit")

## Retourne la somme des bonus de stat issus des traits.
func get_trait_stat_bonus(stat: String) -> float:
	return TraitLibrary.get_stat_bonus(traits, stat)


## Équipe un item. Retourne false si l'item est incompatible avec la classe.
func equip(item_id: String) -> bool:
	var item : Dictionary = EquipmentLibrary.get_item(item_id)
	if item.is_empty():
		push_warning("HeroData.equip: item inconnu '%s'" % item_id)
		return false

	var type    : String = item["type"]
	var subtype : String = item["subtype"]

	## Vérification de compatibilité armes
	if type == "weapon" and not (subtype in weapon_types):
		push_warning("HeroData.equip: classe '%s' ne peut pas porter l'arme de type '%s'." % [hero_class, subtype])
		return false

	## Vérification de compatibilité armures
	if type == "armor" and subtype != armor_type:
		push_warning("HeroData.equip: classe '%s' ne peut pas porter l'armure de type '%s'." % [hero_class, subtype])
		return false

	## Détermine le slot selon le type
	var slot : String
	match type:
		"weapon":      slot = "weapon"
		"armor":       slot = item.get("slot", "torso")   ## head | torso | legs
		"accessory":   slot = "accessory"
		"consumable":  slot = "consumable"
		_:
			push_warning("HeroData.equip: type d'item inconnu '%s'" % type)
			return false

	equipment[slot] = item_id
	return true


## Déséquipe le slot donné.
func unequip(slot: String) -> void:
	if equipment.has(slot):
		equipment[slot] = ""

func get_salary() -> int:
	return salary


## Consomme un plat cuisiné : restaure la faim et applique son buff temporaire.
## L'item doit être présent dans GuildInventoryManager.
func consume_dish(dish_id: String) -> bool:
	var dish : Dictionary = DishLibrary.get_dish(dish_id)
	if dish.is_empty():
		return false
	## Retire l'item de l'inventaire
	var removed : bool = false
	for i in GuildInventoryManager.slots.size():
		var slot = GuildInventoryManager.slots[i]
		if slot != null and slot["item_id"] == dish_id:
			GuildInventoryManager.remove_from_slot(i, 1)
			removed = true
			break
	if not removed:
		return false
	## Restaure la faim
	hunger = minf(100.0, hunger + dish.get("satiety", 0.0))
	## Applique le buff si présent
	var buff : Dictionary = dish.get("buff", {})
	var stat : String = buff.get("stat", "")
	var value : float = buff.get("value", 0.0)
	var dur   : float = buff.get("duration_days", 0.0)
	if stat != "" and value > 0.0 and dur > 0.0:
		var expires : int = TimeManager.current_day + int(ceil(dur))
		active_buffs.append({"stat": stat, "value": value, "expires_day": expires})
	return true


# ─────────────────────────────────────────────
#  PLANNING PAR DÉFAUT
# ─────────────────────────────────────────────
func apply_default_planning() -> void:
	planning.clear()
	for h in range(24):
		if h >= 0  and h < 6:  planning[h] = "sleep"
		elif h >= 6  and h < 8:  planning[h] = "free"
		elif h >= 8  and h < 12: planning[h] = "work"
		elif h >= 12 and h < 13: planning[h] = "free"
		elif h >= 13 and h < 18: planning[h] = "work"
		elif h >= 18 and h < 22: planning[h] = "free"
		else:                    planning[h] = "sleep"


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	return {
		"hero_id":      hero_id,
		"hero_name":    hero_name,
		"hero_class":   hero_class,
		"level":        level,
		"xp":           xp,
		"rank":         rank,
		"missions_last_20": missions_last_20,
		"strength":     strength,
		"defense":      defense,
		"agility":      agility,
		"magic":        magic,
		"luck":         luck,
		"hp_max":       hp_max,
		"hp":           hp,
		"mana_max":     mana_max,
		"mana":         mana,
		"moral":        moral,
		"social":       social,
		"manual_work":  manual_work,
		"occult_work":  occult_work,
		"cooking":      cooking,
		"knowledge":    knowledge,
		"energy":       energy,
		"hunger":       hunger,
		"entertainment": entertainment,
		"toilet":       toilet,
		"hygiene":      hygiene,
		"salary":       salary,
		"days_unpaid":  days_unpaid,
		"planning":     planning,
		"job":          job,
		"strength_priority": strength_priority,
		"defense_priority":  defense_priority,
		"agility_priority":  agility_priority,
		"mana_priority":     mana_priority,
		"on_mission":           on_mission,
		"mission_return_day":   mission_return_day,
		"mission_return_hour":  mission_return_hour,
		"traits":          traits,
		"skills":          skills,
		"equipped_skills": equipped_skills,
		"skill_points":    skill_points,
		"equipment":              equipment,
		"consumable_quantities":  consumable_quantities,
		"enchantments":           enchantments,
		"active_buffs":    active_buffs,
		"appearance":   appearance,
		"control_by_player": control_by_player,
		"is_advanced_class": is_advanced_class,
		"class_type":   class_type,
		"weapon_types": weapon_types,
		"armor_type":   armor_type,
	}

func deserialize(d: Dictionary) -> void:
	hero_id       = d.get("hero_id",     -1)
	hero_name     = d.get("hero_name",   "")
	hero_class    = d.get("hero_class",  "")
	level         = d.get("level",       1)
	xp            = d.get("xp",          0.0)
	rank          = d.get("rank",        "F")
	missions_last_20 = d.get("missions_last_20", [])
	strength      = d.get("strength",    10.0)
	defense       = d.get("defense",     10.0)
	agility       = d.get("agility",     10.0)
	magic         = d.get("magic",       10.0)
	luck          = d.get("luck",        10.0)
	hp_max        = d.get("hp_max",      100.0)
	hp            = d.get("hp",          100.0)
	mana_max      = d.get("mana_max",    50.0)
	mana          = d.get("mana",        50.0)
	moral         = d.get("moral",       100.0)
	social        = d.get("social",      1.0)
	manual_work   = d.get("manual_work", 1.0)
	occult_work   = d.get("occult_work", 1.0)
	cooking       = d.get("cooking",     1.0)
	knowledge     = d.get("knowledge",   1.0)
	energy        = d.get("energy",      100.0)
	hunger        = d.get("hunger",      100.0)
	entertainment = d.get("entertainment", 100.0)
	toilet        = d.get("toilet",      100.0)
	hygiene       = d.get("hygiene",     100.0)
	salary        = d.get("salary",      10)
	days_unpaid   = d.get("days_unpaid", 0)
	planning      = d.get("planning",    {})
	job           = d.get("job",         0)
	strength_priority = d.get("strength_priority", 25)
	defense_priority  = d.get("defense_priority",  25)
	agility_priority  = d.get("agility_priority",  25)
	mana_priority     = d.get("mana_priority",     25)
	on_mission          = d.get("on_mission",          false)
	mission_return_day  = d.get("mission_return_day",  -1)
	mission_return_hour = d.get("mission_return_hour", -1)
	traits.assign(d.get("traits", []))
	skills        = d.get("skills", [])
	equipped_skills.assign(d.get("equipped_skills", []))
	skill_points  = d.get("skill_points", 0)
	enchantments = d.get("enchantments", {"weapon": "", "head": "", "torso": "", "legs": "", "accessory": ""})
	active_buffs = d.get("active_buffs", [])
	## Compatibilité ascendante : l'ancien slot "armor" → "torso"
	var saved_equip : Dictionary = d.get("equipment", {})
	equipment = {
		"weapon":     saved_equip.get("weapon",     ""),
		"head":       saved_equip.get("head",       ""),
		"torso":      saved_equip.get("torso",      saved_equip.get("armor", "")),
		"legs":       saved_equip.get("legs",       ""),
		"accessory":  saved_equip.get("accessory",  ""),
		"accessory2": saved_equip.get("accessory2", ""),
		"consumable": saved_equip.get("consumable", ""),
		"consumable2":saved_equip.get("consumable2",""),
	}
	var saved_cq : Dictionary = d.get("consumable_quantities", {})
	consumable_quantities = {
		"consumable":  saved_cq.get("consumable",  0),
		"consumable2": saved_cq.get("consumable2", 0),
	}
	appearance    = d.get("appearance",  {"body":"","eyes":"","hair":"","top":"","helm":"","pant":""})
	control_by_player = d.get("control_by_player", false)
	is_advanced_class = d.get("is_advanced_class", false)
	class_type   = d.get("class_type",   "physique")
	weapon_types.assign(d.get("weapon_types", []))
	armor_type   = d.get("armor_type",   "legere")
