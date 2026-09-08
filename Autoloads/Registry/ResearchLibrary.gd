## ResearchLibrary.gd
## Registre statique de toutes les recherches disponibles.
## Usage : var def = ResearchLibrary.get(id)
class_name ResearchLibrary

static var _defs        : Dictionary = {}
static var _initialized : bool       = false

const _ICON_BASE : String = "res://Sprites/Interface/research icon/"


static func get_definition(id: String) -> ResearchData:
	if not _initialized:
		_build_all()
	return _defs.get(id, null)


static func get_all() -> Array:
	if not _initialized:
		_build_all()
	return _defs.values()


static func get_for_level(level: int) -> Array:
	if not _initialized:
		_build_all()
	var result : Array = []
	for r in _defs.values():
		if r.level == level:
			result.append(r)
	return result


static func _r(id: String, label: String, desc: String, unlocks: String, cost: int, level: int, prereqs: Array, icon: String) -> ResearchData:
	var d := ResearchData.new()
	d.id            = id
	d.label         = label
	d.description   = desc
	d.unlocks       = unlocks
	d.cost          = cost
	d.level         = level
	d.prerequisites.assign(prereqs)
	d.icon_path     = (_ICON_BASE + icon) if icon != "" else ""
	_defs[id] = d
	return d


static func _build_all() -> void:
	_initialized = true
	_build_niveau_1()
	_build_niveau_2()
	_build_niveau_3()
	_build_niveau_4()
	_build_niveau_5()
	_build_niveau_6()
	_build_niveau_7()
	_build_niveau_8()
	_build_niveau_9()
	_build_niveau_10()


# ── NIVEAU 1 (4 recherches) ──────────────────────────────────────────────────
static func _build_niveau_1() -> void:
	pass


# ── NIVEAU 2 (4 recherches) ──────────────────────────────────────────────────
static func _build_niveau_2() -> void:
	pass


# ── NIVEAU 3 (5 recherches) ──────────────────────────────────────────────────
static func _build_niveau_3() -> void:
	pass


# ── NIVEAU 4 (5 recherches) ──────────────────────────────────────────────────
static func _build_niveau_4() -> void:
	pass


# ── NIVEAU 5 (5 recherches) ──────────────────────────────────────────────────
static func _build_niveau_5() -> void:
	pass


# ── NIVEAU 6 (5 recherches) ──────────────────────────────────────────────────
static func _build_niveau_6() -> void:
	pass


# ── NIVEAU 7 (3 recherches) ──────────────────────────────────────────────────
static func _build_niveau_7() -> void:
	pass


# ── NIVEAU 8 (3 recherches) ──────────────────────────────────────────────────
static func _build_niveau_8() -> void:
	pass


# ── NIVEAU 9 (3 recherches) ──────────────────────────────────────────────────
static func _build_niveau_9() -> void:
	pass


# ── NIVEAU 10 (2 recherches) ─────────────────────────────────────────────────
static func _build_niveau_10() -> void:
	pass
