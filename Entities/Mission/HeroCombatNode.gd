## HeroCombatNode.gd
## Clone de combat d'un héros — CharacterBody2D avec IA simple.
## Spawné par mission_scene.gd à partir d'un HeroData existant.
class_name HeroCombatNode
extends CharacterBody2D

signal hp_changed(hero_node, hp, hp_max)
signal mana_changed(hero_node, mana, mana_max)
signal hero_died(hero_node)
signal skill_used(hero_node, skill_id, cooldown)

const ATTACK_RANGE        : float = 28.0
const ATTACK_CD           : float = 1.5
const MANA_REGEN          : float = 0.5   ## par seconde
const CHASE_SPEED         : float = 90.0
const POTION_HP_THRESHOLD : float = 0.30  ## 30% HP → auto-potion

var hero_data           : HeroData = null
var is_player_controlled : bool    = false

var _hp       : float = 100.0
var _hp_max   : float = 100.0
var _mana     : float = 50.0
var _mana_max : float = 50.0
var _dead     : bool  = false

var _atk_timer       : float  = 0.0
var _potion_used     : bool   = false
var _enemies_container : Node2D = null
var _target            : Node2D = null
var _status_effects    : Array  = []

## Cooldowns restants par skill_id
var _skill_cooldowns : Dictionary = {}
## Index du prochain skill à tenter (round-robin)
var _skill_index : int = 0
## Buffs de stat actifs en combat [{ "stat", "value", "timer" }]
var _combat_buffs : Array = []
var _mouse_arrow : Polygon2D = null
## Potion de résurrection : déclenche une fois si equipped
var _res_potion_ready : bool = false

## Bonus issus des compétences passives apprises
var _passive_atk_mult      : float = 1.0
var _passive_dmg_reduction : float = 0.0   ## somme de réductions (0.05 + 0.10 = 0.15 max ~50%)
var _passive_crit_bonus    : float = 0.0
var _passive_on_kill_heal  : float = 0.0   ## % HP max récupéré au kill
var _passive_mana_regen    : float = 1.0   ## multiplicateur regen mana
var _passive_def_bonus_pct : float = 0.0   ## bonus défense %


## Somme les buffs alimentaires actifs pour une stat donnée.
func _get_buff_bonus(stat: String) -> float:
	if hero_data == null:
		return 0.0
	var total : float = 0.0
	for buff in hero_data.active_buffs:
		if buff.get("stat", "") == stat:
			total += buff.get("value", 0.0)
	return total


func setup(p_hero_data: HeroData, enemies_container: Node2D, player_controlled: bool = false) -> void:
	is_player_controlled = player_controlled
	hero_data          = p_hero_data
	_enemies_container = enemies_container

	_hp_max   = p_hero_data.get_hp_max()
	_hp       = _hp_max
	_mana_max = p_hero_data.get_mana_max()
	_mana     = _mana_max

	_apply_passives(p_hero_data)
	## Potion de résurrection : vérifie si équipée
	var cons_id : String = p_hero_data.equipment.get("consumable", "")
	if cons_id != "":
		var cons_item : Dictionary = EquipmentLibrary.get_item(cons_id)
		for eff in cons_item.get("effects", []):
			if eff.get("type", "") == "prevent_death":
				_res_potion_ready = true

	collision_layer = 2  # layer 2
	collision_mask  = 4  # layer 3 (mobs)

	var col_shape := CollisionShape2D.new()
	var circle    := CircleShape2D.new()
	circle.radius = 8.0
	col_shape.shape = circle
	add_child(col_shape)

	## Visuel placeholder : fond bleu + initiale du nom
	var bg := ColorRect.new()
	bg.color    = Color(0.10, 0.28, 0.55, 0.85)
	bg.size     = Vector2(16, 16)
	bg.position = Vector2(-8, -8)
	bg.z_index  = -1
	add_child(bg)

	var vis := Label.new()
	vis.text     = p_hero_data.hero_name.substr(0, 1)
	vis.position = Vector2(-5, -22)
	vis.add_theme_font_size_override("font_size", 11)
	vis.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
	add_child(vis)

	## Flèche directionnelle souris (joueur uniquement)
	if player_controlled:
		_mouse_arrow = Polygon2D.new()
		_mouse_arrow.polygon = PackedVector2Array([
			Vector2(20, 0), Vector2(13, -4), Vector2(13, 4)
		])
		_mouse_arrow.color = Color(1.0, 0.95, 0.1, 0.85)
		_mouse_arrow.z_index = 10
		add_child(_mouse_arrow)


func get_hp()     -> float: return _hp
func get_hp_max() -> float: return _hp_max
func get_mana()   -> float: return _mana
func is_dead()    -> bool:  return _dead


func take_damage(amount: float, effect: Variant = null) -> void:
	if _dead:
		return
	var def_val  : float = ((hero_data.defense if hero_data else 5.0) + _get_buff_bonus("defense") + _get_combat_stat_buff("def")) * (1.0 + _passive_def_bonus_pct)
	var reduced  : float = maxf(1.0, amount - sqrt(def_val))
	reduced *= maxf(0.0, 1.0 - _passive_dmg_reduction)
	_hp -= reduced
	hp_changed.emit(self, _hp, _hp_max)

	if effect != null and effect is Dictionary:
		_try_apply_effect(effect)

	if not _potion_used and _hp / _hp_max < POTION_HP_THRESHOLD:
		_try_use_potion()

	if _hp <= 0.0:
		_die()


func _die() -> void:
	## Potion de résurrection : ressuscite une fois à 30% PV
	if _res_potion_ready:
		_res_potion_ready = false
		_hp    = _hp_max * 0.30
		_dead  = false
		hp_changed.emit(self, _hp, _hp_max)
		## Consomme la potion de l'inventaire
		var cons_id : String = hero_data.equipment.get("consumable", "") if hero_data else ""
		if cons_id != "":
			for i in GuildInventoryManager.MAX_SLOTS:
				var slot = GuildInventoryManager.slots[i]
				if slot != null and slot["item_id"] == cons_id:
					GuildInventoryManager.remove_from_slot(i, 1)
					break
		return
	_dead    = true
	velocity = Vector2.ZERO
	hero_died.emit(self)


func _physics_process(delta: float) -> void:
	if _dead:
		return

	_tick_status_effects(delta)
	_tick_combat_buffs(delta)
	_atk_timer = maxf(0.0, _atk_timer - delta)

	## Régénération de mana (avec bonus passif)
	_mana = minf(_mana_max, _mana + MANA_REGEN * _passive_mana_regen * delta)
	mana_changed.emit(self, _mana, _mana_max)

	## Tick cooldowns compétences
	for sid in _skill_cooldowns.keys():
		_skill_cooldowns[sid] = maxf(0.0, _skill_cooldowns[sid] - delta)

	## Ciblage commun IA et joueur
	if _target == null or not is_instance_valid(_target) or _target.is_dead():
		_target = _find_nearest_enemy()

	if is_player_controlled:
		_process_player()
	else:
		_process_ai()


func _process_player() -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("camera_move_right"): dir.x += 1
	if Input.is_action_pressed("camera_move_left"):  dir.x -= 1
	if Input.is_action_pressed("camera_move_down"):  dir.y += 1
	if Input.is_action_pressed("camera_move_up"):    dir.y -= 1
	velocity = dir.normalized() * CHASE_SPEED
	move_and_slide()

	## Flèche souris
	if _mouse_arrow != null:
		var mouse_dir := get_global_mouse_position() - global_position
		if mouse_dir.length_squared() > 1.0:
			_mouse_arrow.rotation = mouse_dir.angle()

	if _target == null:
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist <= ATTACK_RANGE:
		if not _try_use_skill():
			if _atk_timer <= 0.0:
				_do_attack()
				_atk_timer = ATTACK_CD


func _process_ai() -> void:
	if _target == null:
		velocity = Vector2.ZERO
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist > ATTACK_RANGE:
		velocity = global_position.direction_to(_target.global_position) * CHASE_SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		## Tenter une compétence active avant l'attaque de base
		if not _try_use_skill():
			if _atk_timer <= 0.0:
				_do_attack()
				_atk_timer = ATTACK_CD


func _do_attack() -> void:
	if _target == null or not _target.has_method("take_damage"):
		return
	if hero_data == null:
		return

	var str_val   : float = hero_data.strength + _get_buff_bonus("strength")
	var atk_bonus : float = hero_data.get_equipment_bonus("atk") + _get_combat_stat_buff("atk")
	var d_base    : float = sqrt(str_val) + atk_bonus

	## Multiplicateur moral (GDD §6.3)
	var moral      : float = hero_data.moral + _get_buff_bonus("moral")
	var moral_mult : float
	if   moral > 80.0: moral_mult = 1.00
	elif moral > 60.0: moral_mult = 0.90
	elif moral > 40.0: moral_mult = 0.85
	elif moral > 20.0: moral_mult = 0.80
	else:              moral_mult = 0.75

	## Critique (avec bonus passif)
	var crit_chance : float = (hero_data.luck + _get_buff_bonus("luck")) * 0.005 + (hero_data.get_equipment_bonus("crit") + _get_combat_stat_buff("crit")) * 0.01 + _passive_crit_bonus
	var crit_mult   : float = 2.0 if randf() < crit_chance else 1.0

	var dmg : float = maxf(1.0, d_base * _passive_atk_mult * moral_mult * crit_mult)
	_target.take_damage(dmg)


## Applique les bonus des compétences passives apprises.
func _apply_passives(p_hero_data: HeroData) -> void:
	for entry in p_hero_data.skills:
		var sid : String = entry.get("id", "")
		var sdata : Dictionary = SkillLibrary.get_skill(sid)
		if sdata.get("type", "") != "passive":
			continue
		var fx : Dictionary = SkillLibrary.get_passive_combat_effects(sid)
		_passive_atk_mult      += fx.get("atk_bonus_pct",   0.0)
		_passive_dmg_reduction += fx.get("dmg_reduction",   0.0)
		_passive_crit_bonus    += fx.get("crit_bonus",       0.0)
		_passive_on_kill_heal  += fx.get("on_kill_heal_pct", 0.0)
		_passive_mana_regen    += fx.get("mana_regen_mult",  0.0)
		_passive_def_bonus_pct += fx.get("def_bonus_pct",    0.0)
	## Cap la réduction de dégâts à 50%
	_passive_dmg_reduction = minf(_passive_dmg_reduction, 0.50)


## Appelé par la scène quand un ennemi meurt au corps à corps (passive on_kill_heal).
func on_enemy_killed() -> void:
	if _passive_on_kill_heal > 0.0:
		var heal : float = _hp_max * _passive_on_kill_heal
		_hp = minf(_hp_max, _hp + heal)
		hp_changed.emit(self, _hp, _hp_max)


## Tente d'utiliser une compétence équipée prête. Retourne true si une skill a été lancée.
func _try_use_skill() -> bool:
	if hero_data == null or hero_data.equipped_skills.is_empty():
		return false
	var count : int = hero_data.equipped_skills.size()
	## Parcours round-robin pour trouver une skill prête
	for i in count:
		var idx : int    = (_skill_index + i) % count
		var sid : String = hero_data.equipped_skills[idx]
		var sdata : Dictionary = SkillLibrary.get_skill(sid)
		if sdata.is_empty():
			continue
		var cost : int   = sdata.get("mana_cost", 0)
		var cd   : float = sdata.get("cooldown", 3.0)
		if _mana < cost:
			continue
		if _skill_cooldowns.get(sid, 0.0) > 0.0:
			continue
		## Skill prête → utilisation
		_mana -= cost
		mana_changed.emit(self, _mana, _mana_max)
		_skill_cooldowns[sid] = cd
		_skill_index = (idx + 1) % count
		_execute_skill(sdata)
		skill_used.emit(self, sid, cd)
		return true
	return false


func _execute_skill(sdata: Dictionary) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var str_val   : float = (hero_data.strength if hero_data else 5.0) + _get_buff_bonus("strength")
	var mag_val   : float = (hero_data.magic    if hero_data else 5.0) + _get_buff_bonus("magic")
	var moral     : float = (hero_data.moral    if hero_data else 50.0) + _get_buff_bonus("moral")
	var moral_mult : float
	if   moral > 80.0: moral_mult = 1.00
	elif moral > 60.0: moral_mult = 0.90
	elif moral > 40.0: moral_mult = 0.85
	elif moral > 20.0: moral_mult = 0.80
	else:              moral_mult = 0.75

	var _label : String = sdata.get("label", "Compétence")
	var class_id : String = sdata.get("class_id", "")

	## Logique par classe / nom de skill
	match class_id:
		"mage", "invocateur":
			## Dégâts magiques : magie × 1.5
			var dmg : float = maxf(1.0, mag_val * 1.5 * moral_mult)
			_target.take_damage(dmg)
		"guerisseur":
			## Soin sur soi-même
			var heal : float = mag_val * 1.2
			_hp = minf(_hp_max, _hp + heal)
			hp_changed.emit(self, _hp, _hp_max)
		_:
			## Dégâts physiques majorés : force × 1.8
			var atk : float = hero_data.get_equipment_bonus("atk") if hero_data else 0.0
			var dmg : float = maxf(1.0, (sqrt(str_val) + atk) * 1.8 * moral_mult)
			_target.take_damage(dmg)


func _find_nearest_enemy() -> Node2D:
	if _enemies_container == null:
		return null
	var nearest   : Node2D = null
	var best_dist : float  = INF
	for child in _enemies_container.get_children():
		if not child.has_method("is_dead") or child.is_dead():
			continue
		var d := global_position.distance_to(child.global_position)
		if d < best_dist:
			best_dist = d
			nearest   = child
	return nearest


## Somme les bonus de stat issus des potions de buff en combat.
func _get_combat_stat_buff(stat: String) -> float:
	var total : float = 0.0
	for b in _combat_buffs:
		if b.get("stat", "") == stat:
			total += b.get("value", 0.0)
	return total


## Tick des buffs de combat (décrémente les timers).
func _tick_combat_buffs(delta: float) -> void:
	var expired : Array = []
	for b in _combat_buffs:
		b["timer"] -= delta
		if b["timer"] <= 0.0:
			expired.append(b)
	for b in expired:
		_combat_buffs.erase(b)


## Utilise l'objet consommable équipé. Appelée par l'UI du joueur.
## Retourne true si l'item a été utilisé.
func use_equipped_item() -> bool:
	if _dead or hero_data == null:
		return false
	var item_id : String = hero_data.equipment.get("consumable", "")
	if item_id.is_empty():
		return false
	## Cherche l'item dans l'inventaire de la guilde
	var slot_idx : int = -1
	for i in GuildInventoryManager.MAX_SLOTS:
		var slot = GuildInventoryManager.slots[i]
		if slot != null and slot["item_id"] == item_id:
			slot_idx = i
			break
	if slot_idx < 0:
		return false

	var item : Dictionary = EquipmentLibrary.get_item(item_id)
	for eff in item.get("effects", []):
		match eff.get("type", ""):
			"heal":
				var heal : float = eff.get("value", 0.0)
				_hp = minf(_hp_max, _hp + heal)
				hp_changed.emit(self, _hp, _hp_max)
			"restore_mana":
				_mana = minf(_mana_max, _mana + eff.get("value", 0.0))
				mana_changed.emit(self, _mana, _mana_max)
			"stat_buff":
				_combat_buffs.append({
					"stat":  eff.get("stat", ""),
					"value": eff.get("value", 0.0),
					"timer": eff.get("duration", 60.0),
				})
			"heal_over_time":
				_combat_buffs.append({
					"stat":  "hot",   ## heal_over_time géré dans _tick_combat_buffs
					"value": eff.get("value", 0.0),
					"timer": eff.get("duration", 60.0),
				})
			"cure_status":
				var status_to_cure : String = eff.get("status", "")
				_status_effects = _status_effects.filter(
					func(s): return s.get("type", "") != status_to_cure)
			"prevent_death":
				_res_potion_ready = true   ## déjà géré à la mort

	GuildInventoryManager.remove_from_slot(slot_idx, 1)
	return true


func _try_use_potion() -> void:
	_potion_used = true
	var slots : Array = GuildInventoryManager.slots
	for i in slots.size():
		var slot = slots[i]
		if slot == null:
			continue
		var item : Dictionary = EquipmentLibrary.get_item(slot["item_id"])
		if item.is_empty():
			continue
		var effects : Array = item.get("effects", [])
		for eff in effects:
			if eff.get("type", "") == "heal":
				var heal : float = _hp_max * eff.get("value", 0.3)
				_hp = minf(_hp_max, _hp + heal)
				hp_changed.emit(self, _hp, _hp_max)
				GuildInventoryManager.remove_from_slot(i, 1)
				return


# ─────────────────────────────────────────────
#  EFFETS DE STATUT
# ─────────────────────────────────────────────
func _try_apply_effect(effect: Dictionary) -> void:
	if randf() > effect.get("chance", 1.0):
		return
	_status_effects.append({
		"type":  effect.get("type", ""),
		"value": effect.get("value", 0.0),
		"timer": effect.get("duration", 3.0),
	})


func _tick_status_effects(delta: float) -> void:
	var to_remove : Array = []
	for eff in _status_effects:
		eff["timer"] -= delta
		var t : String = eff.get("type", "")
		if t == "poison" or t == "burn":
			var dot : float = eff.get("value", 1.0) * delta
			_hp = maxf(0.0, _hp - dot)
			hp_changed.emit(self, _hp, _hp_max)
			if _hp <= 0.0:
				_die()
				return
		if eff["timer"] <= 0.0:
			to_remove.append(eff)
	for eff in to_remove:
		_status_effects.erase(eff)


func _unhandled_input(event: InputEvent) -> void:
	if not is_player_controlled or _dead:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		_player_click_attack()


func _player_click_attack() -> void:
	if _enemies_container == null:
		return
	## Cible l'ennemi le plus proche du curseur souris
	var mouse_pos := get_global_mouse_position()
	var nearest   : Node2D = null
	var best_dist : float  = INF
	for enemy in _enemies_container.get_children():
		if not enemy.has_method("is_dead") or enemy.is_dead():
			continue
		var d := mouse_pos.distance_to(enemy.global_position)
		if d < best_dist:
			best_dist = d
			nearest   = enemy
	if nearest == null:
		return
	_target = nearest
	var dist := global_position.distance_to(nearest.global_position)
	if dist <= ATTACK_RANGE and _atk_timer <= 0.0:
		_do_attack()
		_atk_timer = ATTACK_CD
