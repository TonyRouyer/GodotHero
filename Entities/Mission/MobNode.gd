## MobNode.gd
## Ennemi combat — CharacterBody2D avec machine à états simple.
## États : IDLE → CHASE → ATTACK → DEAD
## Spawné par wood1_scene._place_enemies() selon la difficulté de la mission.
class_name MobNode
extends CharacterBody2D

signal mob_died(mob_node)
signal hp_changed(mob_node, hp, hp_max)

enum State { IDLE, CHASE, ATTACK, DEAD }

const AGGRO_RANGE  : float = 200.0
const ATTACK_RANGE : float = 28.0
const ATTACK_CD    : float = 2.0

var mob_id   : String     = ""
var mob_data : Dictionary = {}

var _hp     : float = 10.0
var _hp_max : float = 10.0
var _speed  : float = 80.0
var _state  : State = State.IDLE

var _atk_timer        : float  = 0.0
var _heroes_container : Node2D = null
var _target           : Node2D = null
var _status_effects   : Array  = []


func setup(p_mob_id: String, heroes_container: Node2D) -> void:
	mob_id            = p_mob_id
	_heroes_container = heroes_container
	mob_data          = MobLibrary.get_mob(p_mob_id)
	if mob_data.is_empty():
		push_error("MobNode: mob inconnu « %s »" % p_mob_id)
		queue_free()
		return

	_hp_max = MobLibrary.get_hp_max(p_mob_id)
	_hp     = _hp_max
	_speed  = mob_data.get("speed", 80.0)

	collision_layer = 4  # layer 3
	collision_mask  = 6  # layer 2 (héros) + layer 3 (autres mobs)

	var col_shape := CollisionShape2D.new()
	var circle    := CircleShape2D.new()
	circle.radius = 8.0
	col_shape.shape = circle
	add_child(col_shape)

	## Visuel : fond rouge + initiale du label
	var bg := ColorRect.new()
	bg.color    = Color(0.55, 0.10, 0.10, 0.85)
	bg.size     = Vector2(16, 16)
	bg.position = Vector2(-8, -8)
	bg.z_index  = -1
	add_child(bg)

	var vis := Label.new()
	vis.text     = mob_data.get("label", "M").substr(0, 1)
	vis.position = Vector2(-5, -22)
	vis.add_theme_font_size_override("font_size", 11)
	vis.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	add_child(vis)


func get_hp()     -> float: return _hp
func get_hp_max() -> float: return _hp_max
func is_dead()    -> bool:  return _state == State.DEAD


func take_damage(amount: float, effect: Variant = null) -> void:
	if _state == State.DEAD:
		return
	var stats   : Dictionary = mob_data.get("stats", {})
	var def_val : float      = stats.get("defense", 0.0)
	var reduced : float      = maxf(1.0, amount - sqrt(def_val))
	_hp -= reduced
	hp_changed.emit(self, _hp, _hp_max)

	if effect != null and effect is Dictionary:
		_try_apply_effect(effect)

	if _hp <= 0.0:
		_die()


func show_hit_flash() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(2.0, 0.30, 0.30), 0.06)
	tw.tween_property(self, "modulate", Color.WHITE, 0.14)


func _spawn_damage_number(amount: float, is_crit: bool) -> void:
	var lbl := Label.new()
	lbl.text = ("★%d" if is_crit else "-%d") % int(amount)
	lbl.add_theme_font_size_override("font_size", 14 if is_crit else 11)
	lbl.add_theme_color_override("font_color",
		Color(1.0, 0.85, 0.05) if is_crit else Color(1.0, 0.40, 0.20)
	)
	lbl.position = Vector2(randf_range(-6.0, 6.0), -24.0)
	lbl.z_index  = 20
	add_child(lbl)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(lbl, "position", lbl.position + Vector2(0, -20), 0.75)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.75)
	tw.chain().tween_callback(lbl.queue_free)


func _die() -> void:
	_state   = State.DEAD
	velocity = Vector2.ZERO
	mob_died.emit(self)
	_drop_loot()
	queue_free()


func _drop_loot() -> void:
	var drops : Array = mob_data.get("drops", [])
	for drop in drops:
		var chance : float = 0.20 if drop.get("rare", false) else 0.55
		if randf() > chance:
			continue
		var qty : int = randi_range(drop.get("min", 1), drop.get("max", 1))
		GuildInventoryManager.add_item(drop.get("item_id", ""), qty)


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return

	_tick_status_effects(delta)
	_atk_timer = maxf(0.0, _atk_timer - delta)

	if _target == null or not is_instance_valid(_target) or _target.is_dead():
		_target = _find_nearest_hero()

	## Séparation douce entre mobs pour éviter la superposition
	_apply_separation(delta)

	match _state:
		State.IDLE:
			velocity = Vector2.ZERO
			if _target != null:
				var dist := global_position.distance_to(_target.global_position)
				if dist <= AGGRO_RANGE:
					_state = State.CHASE

		State.CHASE:
			if _target == null or not is_instance_valid(_target):
				_state   = State.IDLE
				velocity = Vector2.ZERO
			else:
				var dist := global_position.distance_to(_target.global_position)
				if dist <= ATTACK_RANGE:
					_state   = State.ATTACK
					velocity = Vector2.ZERO
				else:
					velocity = global_position.direction_to(_target.global_position) * _speed
					move_and_slide()

		State.ATTACK:
			velocity = Vector2.ZERO
			if _target == null or not is_instance_valid(_target):
				_state = State.IDLE
				return
			var dist := global_position.distance_to(_target.global_position)
			if dist > ATTACK_RANGE * 1.5:
				_state = State.CHASE
				return
			if _atk_timer <= 0.0:
				_do_attack()
				_atk_timer = ATTACK_CD


func _do_attack() -> void:
	if _target == null or not _target.has_method("take_damage"):
		return
	var atk_data : Dictionary = mob_data.get("attacks", {}).get("basic", {})
	var power    : float      = atk_data.get("power", 5.0)
	var stats    : Dictionary = mob_data.get("stats", {})
	var str_val  : float      = stats.get("strength", 5.0)
	var dmg    : float   = sqrt(str_val) + power
	var effect : Variant = atk_data.get("effect", null)
	_target.take_damage(dmg, effect)
	if _target.has_method("show_hit_flash"):
		_target.show_hit_flash()
	if _target.has_method("_spawn_damage_number"):
		_target._spawn_damage_number(dmg, false)


func _apply_separation(delta: float) -> void:
	var parent : Node = get_parent()
	if parent == null:
		return
	var sep := Vector2.ZERO
	for mob in parent.get_children():
		if mob == self or not mob is MobNode or mob.is_dead():
			continue
		var diff : Vector2 = global_position - mob.global_position
		var dist : float   = diff.length()
		if dist < 18.0 and dist > 0.001:
			sep += diff.normalized() * (18.0 - dist) * 4.0
	if sep.length_squared() > 0.0:
		global_position += sep * delta


func _find_nearest_hero() -> Node2D:
	if _heroes_container == null:
		return null
	var nearest   : Node2D = null
	var best_dist : float  = INF
	for child in _heroes_container.get_children():
		if not child.has_method("is_dead") or child.is_dead():
			continue
		var d := global_position.distance_to(child.global_position)
		if d < best_dist:
			best_dist = d
			nearest   = child
	return nearest


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
