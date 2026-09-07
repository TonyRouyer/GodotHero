## RecruitManager — Autoload
## Gère le pool de héros disponibles au recrutement.
extends Node


signal pool_changed 


var _pool : Array[HeroData] = []
var _hours_since_last_spawn : float = 0.0


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	EventBus.hour_changed.connect(_on_hour_changed)

	## Génère un premier héros pour debug
	_try_add_hero()


func _exit_tree() -> void:
	if EventBus.hour_changed.is_connected(_on_hour_changed):
		EventBus.hour_changed.disconnect(_on_hour_changed)


# ─────────────────────────────────────────────
#  TICK HORAIRE
# ─────────────────────────────────────────────
func _on_hour_changed(_hour: int) -> void:
	_hours_since_last_spawn += 1.0
	var interval :float = _get_spawn_interval()
	if _hours_since_last_spawn >= interval:
		_hours_since_last_spawn = 0.0
		_try_add_hero()


func _get_spawn_interval() -> float:
	var rep : float = GameData.reputation
	return 15.0 - min(rep / 5.0, 12.0)


func _get_max_visible() -> int:
	return 1 + int(GameData.reputation / 10.0)


func _try_add_hero() -> void:
	if _pool.size() >= _get_max_visible():
		return
	var data :HeroData = HeroGenerator.generate_for_recruitment()
	if data:
		_pool.append(data)
		pool_changed.emit()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────
func get_pool() -> Array[HeroData]:
	var result : Array[HeroData] = []
	for d in _pool:
		result.append(d)
	return result


func recruit(hero_data: HeroData) -> bool:
	var cost :int = _get_recruit_cost(hero_data)
	if not GameData.spend_gold(cost):
		EventBus.ui_notification_requested.emit(
			"Or insuffisant pour recruter %s (%d or requis)" % [hero_data.hero_name, cost], "error"
		)
		return false

	_pool.erase(hero_data)
	HeroManager.spawn_hero(hero_data)
	pool_changed.emit()
	return true


func refuse(hero_data: HeroData) -> void:
	_pool.erase(hero_data)
	pool_changed.emit()


func _get_recruit_cost(hero_data: HeroData) -> int:
	return hero_data.salary * 5


## Ajoute un héros random au pool (pour les tests)
func add_random_for_test() -> void:
	var data := HeroGenerator.generate_for_recruitment()
	if data:
		_pool.append(data)
		pool_changed.emit()


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	var pool_data :Array = []
	for d in _pool:
		pool_data.append(d.serialize())
	return {
		"pool":                  pool_data,
		"hours_since_last_spawn": _hours_since_last_spawn,
	}


func deserialize(data: Dictionary) -> void:
	_pool.clear()
	_hours_since_last_spawn = data.get("hours_since_last_spawn", 0.0)
	for hero_dict in data.get("pool", []):
		var hd := HeroData.new()
		hd.deserialize(hero_dict)
		_pool.append(hd)
	pool_changed.emit()
