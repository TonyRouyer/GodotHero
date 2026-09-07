## HeroNeeds.gd
## Composant de gestion des besoins, du moral, du salaire et de la progression.
##
## Responsabilités :
##   • Décrémenter les 5 besoins à chaque tick (time_tick)
##   • Recalculer le moral depuis les effets actifs
##   • Payer le salaire et gérer days_unpaid à chaque changement de jour
##   • Appliquer les sorties de travail (or) et d'entraînement (stats) chaque heure
##   • Déclencher le départ du héros (fire) si moral ou impayé trop longtemps
extends Node


# ─────────────────────────────────────────────
#  RÉFÉRENCES
# ─────────────────────────────────────────────
@onready var hero    : Hero = get_parent()
@onready var routine : Node = %HeroRoutine


# ─────────────────────────────────────────────
#  ÉTAT INTERNE
# ─────────────────────────────────────────────
enum MoralEffectType { TEMPORARY, CONSTANT, PROGRESSIVE }

var moral_effects : Array = []
var is_starving   : bool  = false
var is_exhausted  : bool  = false
var quit_proba    : int   = 5  ## Probabilité de démission (%) — augmente si moral reste à 0
## Heures consécutives à moral = 0 — formule GDD §4.1 : P_démission = 5% + H_moral_nul × 1%
var _hours_moral_zero : int = 0

## Initialisé au premier tick valide — ajoute les effets moraux constants des traits.
var _trait_constants_applied : bool = false


# ─────────────────────────────────────────────
#  INIT / NETTOYAGE
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.day_changed.connect(_on_day_changed)


func _exit_tree() -> void:
	if EventBus.time_tick.is_connected(_on_time_tick):
		EventBus.time_tick.disconnect(_on_time_tick)
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)
	if EventBus.day_changed.is_connected(_on_day_changed):
		EventBus.day_changed.disconnect(_on_day_changed)


# ─────────────────────────────────────────────
#  TICK PRINCIPAL — toutes les 5 minutes in-game
# ─────────────────────────────────────────────
func _on_time_tick(_hour: int, _minute: int) -> void:
	if not hero.data or hero.data.on_mission:
		return

	## Premier tick valide : enregistre les effets moraux constants des traits.
	if not _trait_constants_applied:
		_apply_trait_constant_moral()
		_trait_constants_applied = true

	_update_hunger()
	_update_energy()
	_update_entertainment()
	_update_toilet()
	_update_hygiene()
	_update_ground_sleep()

	## Recalcule le moral depuis 100 à chaque tick en appliquant tous les effets actifs.
	hero.data.moral = 100.0
	_update_moral()
	EventBus.hero_moral_effects_changed.emit(hero.data.hero_id, moral_effects.duplicate())

	## Notifie l'UI des nouvelles valeurs.
	EventBus.hero_need_changed.emit(hero.data.hero_id, "hunger",        hero.data.hunger)
	EventBus.hero_need_changed.emit(hero.data.hero_id, "energy",        hero.data.energy)
	EventBus.hero_need_changed.emit(hero.data.hero_id, "entertainment", hero.data.entertainment)
	EventBus.hero_need_changed.emit(hero.data.hero_id, "toilet",        hero.data.toilet)
	EventBus.hero_need_changed.emit(hero.data.hero_id, "hygiene",       hero.data.hygiene)
	EventBus.hero_need_changed.emit(hero.data.hero_id, "moral",         hero.data.moral)


# ─────────────────────────────────────────────
#  HEURE — travail et entraînement
# ─────────────────────────────────────────────
## Appelée à chaque heure in-game. Applique les gains de travail et d'entraînement.
## Les valeurs horaires (or, XP, stats) sont définies dans GameConfig.
func _on_hour_changed(_hour: int) -> void:
	if not hero.data:
		return
	var task : String = _get_current_task_type()
	match task:
		"work":
			_apply_work_output()
		"train":
			_apply_train_output()

	## GDD §4.1 : P_démission = 5% + (H_moral_nul × 1%). Accumulation par heure consécutive.
	var quit_threshold : float = TraitLibrary.get_quit_threshold(hero.data.traits)
	if hero.data.moral <= quit_threshold:
		_hours_moral_zero += 1
		quit_proba = mini(5 + _hours_moral_zero, 80)
	else:
		_hours_moral_zero = 0
		quit_proba = 5


## Travail → production selon le métier + XP métier pour le héros.
func _apply_work_output() -> void:
	## Production selon le job : le cuisinier génère des repas, les autres n'ont pas de production directe.
	var skill_key : String
	match hero.data.job:
		1:
			GameData.reputation += GameConfig.RECEPTION_REP_PER_HOUR
			skill_key = "social"
		2:  skill_key = "manual_work"
		3:
			_try_craft_potion()
			skill_key = "occult_work"
		4:
			_try_contribute_research()
			skill_key = "knowledge"
		5:
			GameData.add_food(GameConfig.COOK_FOOD_PER_HOUR)
			_try_cook_dish()
			skill_key = "cooking"
		_:  skill_key = "manual_work"

	## Progression du skill métier correspondant.
	if skill_key != "":
		var current : float = hero.data.get(skill_key)
		hero.data.set(skill_key, min(current + GameConfig.SKILL_GROWTH_PER_HOUR, GameConfig.HERO_MAX_STAT))
		EventBus.hero_stat_changed.emit(hero.data.hero_id, skill_key, hero.data.get(skill_key))

	## XP de combat (même en travaillant, le héros s'améliore).
	var xp_mult : float = TraitLibrary.get_xp_mult(hero.data.traits)
	hero.data.xp += GameConfig.WORK_XP_PER_HOUR * xp_mult
	_check_level_up()


## Entraînement → XP + stats selon les priorités définies dans le planning du héros.
func _apply_train_output() -> void:
	var xp_mult : float = TraitLibrary.get_xp_mult(hero.data.traits)
	hero.data.xp += GameConfig.TRAIN_XP_PER_HOUR * xp_mult
	_check_level_up()
	## Entraînement intense → boost moral progressif +8 sur 3 jours (table 6.4).
	## Le duplicate-guard de add_moral_effect évite de relancer l'effet tant qu'il est actif.
	add_progressive_effect("Entraînement intense", 8.0, 3)

	## Répartit le gain de stat selon les 4 priorités (pourcentages).
	var total : int = (hero.data.strength_priority + hero.data.defense_priority
	                 + hero.data.agility_priority  + hero.data.mana_priority)
	if total <= 0:
		return
	var gain : float = GameConfig.TRAIN_STAT_PER_HOUR
	hero.data.strength = min(hero.data.strength + gain * hero.data.strength_priority / total, GameConfig.HERO_MAX_STAT)
	hero.data.defense  = min(hero.data.defense  + gain * hero.data.defense_priority  / total, GameConfig.HERO_MAX_STAT)
	hero.data.agility  = min(hero.data.agility  + gain * hero.data.agility_priority  / total, GameConfig.HERO_MAX_STAT)
	hero.data.magic    = min(hero.data.magic    + gain * hero.data.mana_priority     / total, GameConfig.HERO_MAX_STAT)

	EventBus.hero_stat_changed.emit(hero.data.hero_id, "strength", hero.data.strength)
	EventBus.hero_stat_changed.emit(hero.data.hero_id, "defense",  hero.data.defense)
	EventBus.hero_stat_changed.emit(hero.data.hero_id, "agility",  hero.data.agility)
	EventBus.hero_stat_changed.emit(hero.data.hero_id, "magic",    hero.data.magic)


## Vérifie si le héros monte de niveau et l'applique.
## Formule GDD : XP_n = 100 × 1.7^(n-1)
func _check_level_up() -> void:
	var xp_required : float = 100.0 * pow(1.7, hero.data.level - 1)
	if hero.data.xp < xp_required:
		return
	hero.data.xp          -= xp_required
	hero.data.level       += 1
	hero.data.skill_points += 1
	## Bonus de stats aléatoire au niveau up (1–5 points par stat principale).
	hero.data.strength += randi_range(1, 5)
	hero.data.defense  += randi_range(1, 5)
	hero.data.agility  += randi_range(1, 5)
	hero.data.magic    += randi_range(1, 5)
	hero.data.luck     += randi_range(1, 5)
	## Recalcule les stats dérivées.
	hero.data.hp_max = hero.data.get_hp_max()
	hero.data.hp     = min(hero.data.hp, hero.data.hp_max)
	EventBus.ui_notification_requested.emit(
		"%s passe au niveau %d !" % [hero.data.hero_name, hero.data.level], "success")
	EventBus.hero_stat_changed.emit(hero.data.hero_id, "level", hero.data.level)


## Tente de cuisiner le plat le moins cher disponible avec les ingrédients de l'inventaire.
## Appelée toutes les heures quand le cuisinier travaille.
## Produit un plat toutes les ~4 heures (basé sur le cook_time).
func _try_cook_dish() -> void:
	## Cherche un plat faisable avec les ingrédients disponibles
	for dish : Dictionary in DishLibrary.get_all_list():
		var can_cook : bool = true
		for ingredient in dish.get("recipe", []):
			var have : int = 0
			for slot in GuildInventoryManager.slots:
				if slot != null and slot["item_id"] == ingredient["item_id"]:
					have += slot["quantity"]
			if have < ingredient["qty"]:
				can_cook = false
				break
		if not can_cook:
			continue
		## Consomme les ingrédients et produit le plat (1 unité)
		for ingredient in dish.get("recipe", []):
			var remaining : int = ingredient["qty"]
			for i in GuildInventoryManager.slots.size():
				var slot = GuildInventoryManager.slots[i]
				if slot == null or slot["item_id"] != ingredient["item_id"]:
					continue
				var take : int = mini(remaining, slot["quantity"])
				GuildInventoryManager.remove_from_slot(i, take)
				remaining -= take
				if remaining <= 0:
					break
		GuildInventoryManager.add_item(dish["id"], 1)
		return   ## Un seul plat par heure


## Tente de crafter la potion la moins chère disponible avec les ingrédients de l'inventaire.
## Job 3 (Mage/Alchimiste) — appelée toutes les heures.
func _try_craft_potion() -> void:
	for item_id : String in EquipmentLibrary.get_all().keys():
		var item : Dictionary = EquipmentLibrary.get_all()[item_id]
		if item.get("type", "") != "consumable":
			continue
		var recipe : Array = item.get("recipe", [])
		if recipe.is_empty():
			continue
		## Vérifier les ingrédients
		var can_craft : bool = true
		for ing in recipe:
			var have : int = 0
			for slot in GuildInventoryManager.slots:
				if slot != null and slot["item_id"] == ing["item_id"]:
					have += slot["quantity"]
			if have < ing["qty"]:
				can_craft = false
				break
		if not can_craft:
			continue
		## Consommer les ingrédients et produire la potion
		for ing in recipe:
			var remaining : int = ing["qty"]
			for i in GuildInventoryManager.slots.size():
				var slot = GuildInventoryManager.slots[i]
				if slot == null or slot["item_id"] != ing["item_id"]:
					continue
				var take : int = mini(remaining, slot["quantity"])
				GuildInventoryManager.remove_from_slot(i, take)
				remaining -= take
				if remaining <= 0:
					break
		GuildInventoryManager.add_item(item_id, 1)
		return   ## Une seule potion par heure


## Contribue à la recherche active. Job 4 (Chercheur).
## Ajoute des points à ResearchManager ; GameData.research_points est le cumul global.
func _try_contribute_research() -> void:
	if not hero.data:
		return
	var points : float = GameConfig.RESEARCH_POINTS_PER_HOUR * (1.0 + hero.data.knowledge * 0.01)
	GameData.research_points += points   ## stat cumulative globale
	ResearchManager.add_progress(points)


# ─────────────────────────────────────────────
#  JOUR — salaire et démission
# ─────────────────────────────────────────────
## Appelée à chaque nouveau jour in-game.
## 1. Paye le salaire depuis l'or de la guilde.
## 2. Applique un malus moral si impayé.
## 3. Vérifie si le héros démissionne (moral ou jours impayés).
func _on_day_changed(_day: int) -> void:
	if not hero.data:
		return

	## ── Paiement du salaire ──────────────────────────────────────────────────
	if GameData.spend_gold(hero.data.salary):
		## Salaire payé : réinitialise le compteur et retire le malus moral.
		hero.data.days_unpaid = 0
		remove_moral_effect("Non payé")
	else:
		## Pas assez d'or : incrémente le compteur et applique le malus constant.
		hero.data.days_unpaid += 1
		## add_moral_effect ignore les doublons — le malus n'est ajouté qu'une fois.
		add_moral_effect("Non payé", -10.0, 1, MoralEffectType.CONSTANT)
		EventBus.ui_notification_requested.emit(
			"%s n'a pas pu être payé ! (%d jour(s))" % [hero.data.hero_name, hero.data.days_unpaid],
			"warning"
		)

	## ── Expiration des buffs culinaires ─────────────────────────────────────
	if hero.data.active_buffs.size() > 0:
		var today : int = TimeManager.current_day
		var remaining_buffs : Array = []
		for buff in hero.data.active_buffs:
			if buff.get("expires_day", 0) > today:
				remaining_buffs.append(buff)
		hero.data.active_buffs = remaining_buffs

	## Bonus moral journalier des traits (ex : Enthousiaste +15 sur 12h)
	var day_bonus : float = TraitLibrary.get_day_moral_bonus(hero.data.traits)
	if day_bonus > 0.0:
		add_timed_effect("Enthousiasme journalier", day_bonus, 12)

	## ── Vérification départ forcé ────────────────────────────────────────────
	var unpaid_limit : int = TraitLibrary.get_unpaid_quit_days(hero.data.traits)

	if hero.data.days_unpaid >= unpaid_limit:
		_quit_guild("impayé depuis %d jours" % hero.data.days_unpaid)
		return

	## quit_proba est mis à jour chaque heure dans _on_hour_changed (GDD §4.1).
	## On vérifie ici une fois par jour si la probabilité déclenche la démission.
	if quit_proba > 5 and randf_range(0.0, 100.0) <= quit_proba:
		_quit_guild("moral trop bas")


## Fait quitter la guilde au héros : notifie le joueur puis appelle fire_hero().
func _quit_guild(reason: String) -> void:
	if not hero.data:
		return
	EventBus.ui_notification_requested.emit(
		"%s quitte la guilde (%s) !" % [hero.data.hero_name, reason], "error"
	)
	## fire_hero() émet hero_fired, queue_free() le node — exécution différée,
	## donc le reste du frame se termine proprement.
	HeroManager.fire_hero(hero.data.hero_id)


# ─────────────────────────────────────────────
#  MISE À JOUR DES BESOINS
# ─────────────────────────────────────────────

func _update_hunger() -> void:
	var task        : String = _get_current_task_type()
	var modifier    : float  = 1.5 if task in ["work", "train"] else 1.0
	var trait_mult  : float  = TraitLibrary.get_need_mult(hero.data.traits, "hunger")
	hero.data.hunger = clamp(hero.data.hunger + GameConfig.NEED_DECAY["hunger"] * modifier * trait_mult, 0.0, 100.0)

	## Famine (hunger = 0) → perd 1% PV max par heure (GDD §3.2).
	is_starving = hero.data.hunger <= 0.0
	if is_starving:
		hero.data.hp = max(hero.data.hp - hero.data.hp_max * 0.01 / GameConfig.TICKS_PER_HOUR, 0.0)

	## Effet moral : sous-alimenté si faim < 20 % (table 6.3).
	if hero.data.hunger < 20.0:
		add_moral_effect("Affamé", -10.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Affamé")

	## Bien nourri (faim ≥ 75 %) → bonus constant (table 6.3).
	if hero.data.hunger >= 75.0:
		add_moral_effect("Bien nourri", 3.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Bien nourri")

	## Repas chaud : déclenché une fois par repas dès que la faim remonte au-delà de 50 %
	## pendant l'activité "eat" (table 6.2 : +5, 6h = 72 ticks).
	if task == "eat" and hero.data.hunger >= 50.0:
		add_moral_effect("Repas chaud", 5.0, 72, MoralEffectType.TEMPORARY)


func _update_energy() -> void:
	var task   : String = _get_current_task_type()
	var change : float

	if task == "sleep":
		## Lit : ~1.0/tick → de critique(8) à 100 en ~92 ticks ≈ 7.5h in-game.
		## Sol : récupération plus lente, n'atteint jamais 100.
		var is_ground : bool = hero.activity.is_ground_sleeping if hero.activity else false
		change = 0.7 if is_ground else 1.0
		## Traits : Insomnie, Somnoleur, Robuste modifient la récupération.
		change *= TraitLibrary.get_sleep_mult(hero.data.traits)
	else:
		var modifier   : float = 1.5 if task in ["work", "train"] else 1.0
		var trait_mult : float = TraitLibrary.get_need_mult(hero.data.traits, "energy")
		change = GameConfig.NEED_DECAY["energy"] * modifier * trait_mult

	hero.data.energy = clamp(hero.data.energy + change, 0.0, 100.0)

	is_exhausted = hero.data.energy <= 0.0
	if is_exhausted:
		add_moral_effect("Épuisé", -5.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Épuisé")


func _update_entertainment() -> void:
	var trait_mult : float = TraitLibrary.get_need_mult(hero.data.traits, "entertainment")
	hero.data.entertainment = clamp(
		hero.data.entertainment + GameConfig.NEED_DECAY["entertainment"] * trait_mult, 0.0, 100.0)

	## GDD §3.3 et §4.4 : < 25% → −5 moral constant ; > 70% → +3 moral constant.
	if hero.data.entertainment < 25.0:
		add_moral_effect("Ennui", -5.0, 1, MoralEffectType.CONSTANT)
		remove_moral_effect("Diverti")
	elif hero.data.entertainment > 70.0:
		remove_moral_effect("Ennui")
		add_moral_effect("Diverti", 3.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Ennui")
		remove_moral_effect("Diverti")

	## Isolement social profond (divertissement < 10 %) — cumulatif avec "Ennui" (table 6.3).
	if hero.data.entertainment < 10.0:
		add_moral_effect("Isolé socialement", -6.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Isolé socialement")


func _update_toilet() -> void:
	var trait_mult : float = TraitLibrary.get_need_mult(hero.data.traits, "toilet")
	hero.data.toilet = clamp(
		hero.data.toilet + GameConfig.NEED_DECAY["toilet"] * trait_mult, 0.0, 100.0)

	if hero.data.toilet <= 10.0:
		add_moral_effect("Besoin pressant", -5.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Besoin pressant")


func _update_hygiene() -> void:
	var modifier   : float = 2.0 if _get_current_task_type() in ["work", "train"] else 1.0
	var trait_mult : float = TraitLibrary.get_need_mult(hero.data.traits, "hygiene")
	hero.data.hygiene = clamp(
		hero.data.hygiene + GameConfig.NEED_DECAY["hygiene"] * modifier * trait_mult, 0.0, 100.0)

	if hero.data.hygiene < 20.0:
		add_moral_effect("Sale", -4.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Sale")


# ─────────────────────────────────────────────
#  MORAL — calcul depuis les effets actifs
# ─────────────────────────────────────────────
## Le moral repart de 100 à chaque tick et se voit appliquer tous les effets actifs.
## Les effets expirés sont retirés automatiquement.
func _update_moral() -> void:
	var total_change : float = 0.0
	var to_remove    : Array = []

	## Multiplicateurs issus des traits
	var amplifier      : float = TraitLibrary.get_moral_amplifier(hero.data.traits)
	var neg_mult       : float = TraitLibrary.get_neg_moral_mult(hero.data.traits)
	var max_pos_effect : float = TraitLibrary.get_max_positive_moral(hero.data.traits)

	for effect in moral_effects:
		var raw_value : float = 0.0
		match effect["type"]:
			MoralEffectType.TEMPORARY:
				effect["duration"] -= 1
				if effect["duration"] <= 0:
					to_remove.append(effect)
				else:
					raw_value = effect["value"]
			MoralEffectType.CONSTANT:
				raw_value = effect["value"]
			MoralEffectType.PROGRESSIVE:
				effect["elapsed"] += 1
				var t : float = effect["elapsed"] / float(effect["duration"])
				if t >= 1.0:
					to_remove.append(effect)
				else:
					raw_value = lerp(effect["start_value"], 0.0, t)

		if raw_value == 0.0:
			continue
		## Applique les modificateurs de traits selon la polarité
		if raw_value > 0.0:
			raw_value = minf(raw_value, max_pos_effect)  ## Apathique : plafond +5
			raw_value *= amplifier                        ## Instable : ×1.5
		else:
			raw_value *= neg_mult                         ## Stoïque : malus −50%
			raw_value *= amplifier                        ## Instable : ×1.5
		total_change += raw_value

	for e in to_remove:
		moral_effects.erase(e)

	var moral_cap   : float = TraitLibrary.get_moral_cap(hero.data.traits)
	var moral_floor : float = TraitLibrary.get_moral_floor(hero.data.traits)
	hero.data.moral = clamp(hero.data.moral + total_change, moral_floor, moral_cap)


# ─────────────────────────────────────────────
#  API EFFETS MORAUX
# ─────────────────────────────────────────────

## Ajoute un effet moral. Ignore les doublons (même nom = même effet déjà actif).
func add_moral_effect(effect_name: String, value: float, duration: float, type: int) -> void:
	for e in moral_effects:
		if e["name"] == effect_name:
			return
	var effect : Dictionary = {"name": effect_name, "type": type, "value": value}
	match type:
		MoralEffectType.TEMPORARY:
			effect["duration"] = duration
		MoralEffectType.PROGRESSIVE:
			effect["start_value"] = value
			effect["duration"]    = duration
			effect["elapsed"]     = 0.0
	moral_effects.append(effect)


## Retire un effet moral par nom.
func remove_moral_effect(effect_name: String) -> void:
	for i in range(moral_effects.size() - 1, -1, -1):
		if moral_effects[i]["name"] == effect_name:
			moral_effects.remove_at(i)


## Enregistre les effets moraux CONSTANTS issus des traits (appelé une seule fois au 1er tick).
## Les effets CONSTANT ne s'expirent pas — ils restent dans moral_effects jusqu'au départ du héros.
func _apply_trait_constant_moral() -> void:
	if not hero.data:
		return
	var total : float = TraitLibrary.get_moral_constants(hero.data.traits)
	if total == 0.0:
		return
	## On regroupe en un seul effet nommé pour lisibilité dans HeroInspectPanel.
	var label : String = "Traits" if total < 0.0 else "Traits positifs"
	add_moral_effect(label, total, 0.0, MoralEffectType.CONSTANT)


## Appelé depuis MissionManager lors d'une résolution de mission.
## Applique le malus supplémentaire du trait Mauvais Perdant en cas d'échec.
func apply_mission_result_traits(success: bool) -> void:
	if not hero.data or success:
		return
	var extra : float = TraitLibrary.get_extra_fail_moral(hero.data.traits)
	if extra < 0.0:
		add_timed_effect("Mauvais perdant", extra, 8)  ## −20 moral pendant 8h


## Dort au sol — effet CONSTANT -7 tant que is_ground_sleeping (table 6.3).
## La modification directe dans HeroActivity a été retirée ; c'est ici qu'elle est gérée.
func _update_ground_sleep() -> void:
	var is_ground : bool = hero.activity.is_ground_sleeping if hero.activity else false
	if is_ground:
		add_moral_effect("Dort au sol", -7.0, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Dort au sol")


# ─────────────────────────────────────────────
#  API ÉVÉNEMENTS MORAUX (appelable depuis l'extérieur)
# ─────────────────────────────────────────────

## Effet temporaire (table 6.2) : durée en heures in-game.
## Exemples : mission réussie (+10, 12h), altercation (-8, 4h).
func add_timed_effect(effect_name: String, value: float, duration_hours: int) -> void:
	var ticks : int = duration_hours * GameConfig.TICKS_PER_HOUR
	add_moral_effect(effect_name, value, ticks, MoralEffectType.TEMPORARY)


## Effet progressif (table 6.4) : valeur décroît de start_value → 0 sur duration_days jours.
## Exemples : promotion (+15, 5j), perte d'un camarade (-20, 10j).
func add_progressive_effect(effect_name: String, value: float, duration_days: int) -> void:
	var ticks : int = duration_days * GameConfig.TICKS_PER_DAY
	add_moral_effect(effect_name, value, ticks, MoralEffectType.PROGRESSIVE)


# ─────────────────────────────────────────────
#  UTILITAIRE
# ─────────────────────────────────────────────
func _get_current_task_type() -> String:
	if routine and routine.current_task:
		return routine.current_task.get("type", "idle")
	return "idle"
