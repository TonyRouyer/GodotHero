## ItemLibrary.gd
## Registre statique de tous les items. Source unique de vérité.
## Usage : var def = ItemLibrary.get_definition("iron_sword")
class_name ItemLibrary

static var _defs        : Dictionary = {}
static var _initialized : bool       = false


static func get_definition(id: String) -> ItemDefinition:
	if not _initialized:
		_build_all()
	return _defs.get(id, null)


static func get_all() -> Dictionary:
	if not _initialized:
		_build_all()
	return _defs


static func _build_all() -> void:
	_initialized = true

	## ── ARME ────────────────────────────────────────────────────────────────
	var sword := ItemDefinition.new()
	sword.id          = "iron_sword"
	sword.label       = "Épée de fer"
	sword.description = "Forgée dans du fer brut.\n+5 Force en mission."
	sword.type        = "weapon"
	sword.stackable   = false
	sword.max_stack   = 1
	sword.rarity      = "common"
	sword.icon_color  = Color(0.70, 0.70, 0.85)
	_defs["iron_sword"] = sword

	## ── CONSOMMABLE ─────────────────────────────────────────────────────────
	var potion := ItemDefinition.new()
	potion.id          = "health_potion"
	potion.label       = "Potion de soin"
	potion.description = "Restaure 25 PV en mission."
	potion.type        = "consumable"
	potion.stackable   = true
	potion.max_stack   = 10
	potion.rarity      = "common"
	potion.icon_color  = Color(0.85, 0.15, 0.15)
	_defs["health_potion"] = potion

	## ── MATÉRIAU ────────────────────────────────────────────────────────────
	var torch := ItemDefinition.new()
	torch.id          = "torch"
	torch.label       = "Torche"
	torch.description = "Éclaire les passages sombres en mission."
	torch.type        = "material"
	torch.stackable   = true
	torch.max_stack   = 99
	torch.rarity      = "common"
	torch.icon_color  = Color(1.00, 0.55, 0.10)
	_defs["torch"] = torch
