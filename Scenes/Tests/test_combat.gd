## test_combat.gd
## Scène de test : configuration du héros → combat 1 vs 3 slimes.
## Contrôles en combat : ZQSD / flèches = se déplacer, clic gauche = cibler.
extends Node2D

# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const ARENA_CENTER  := Vector2(600.0, 380.0)
const ARENA_W       := 520.0
const ARENA_H       := 360.0
const HERO_SPAWN    := Vector2(600.0, 450.0)
const SLIME_SPAWNS  := [
	Vector2(470.0, 280.0),
	Vector2(600.0, 260.0),
	Vector2(730.0, 280.0),
]
const RANK_ORDER : Array[String] = ["F", "E", "D", "C", "B", "A", "S"]
const STAT_NAMES : Array[String] = ["strength", "defense", "agility", "magic", "luck"]


# ─────────────────────────────────────────────
#  ÉTAT CONFIG
# ─────────────────────────────────────────────
var _cfg_classes  : Array   = []   # Array of class Dictionaries
var _cfg_class_idx: int     = 0
var _cfg_level    : int     = 1
## Valeurs de stats personnalisées (remplies depuis la classe + niveau, modifiables)
var _cfg_stats    : Dictionary = {
	"strength": 10.0, "defense": 10.0, "agility": 10.0, "magic": 10.0, "luck": 10.0
}
## Slots équipement : slot → item_id ("")
var _cfg_equip    : Dictionary = {
	"weapon": "", "head": "", "torso": "", "legs": "", "accessory": "", "consumable": ""
}
## Slots compétences équipées (4 max)
var _cfg_skills   : Array[String] = ["", "", "", ""]


# ─────────────────────────────────────────────
#  NŒUDS DE COMBAT
# ─────────────────────────────────────────────
var _heroes_container  : Node2D         = null
var _enemies_container : Node2D         = null
var _hero_node         : HeroCombatNode = null
var _mob_nodes         : Array[MobNode] = []


# ─────────────────────────────────────────────
#  UI CONFIG
# ─────────────────────────────────────────────
var _config_canvas  : CanvasLayer   = null
var _class_option   : OptionButton  = null
var _level_spin     : SpinBox       = null
var _stat_spins     : Dictionary    = {}   # stat → SpinBox
var _hp_lbl         : Label         = null
var _mana_lbl       : Label         = null
var _equip_options  : Dictionary    = {}   # slot → OptionButton
var _skill_options  : Array[OptionButton] = []


# ─────────────────────────────────────────────
#  UI HUD (en combat)
# ─────────────────────────────────────────────
var _hero_hp_bar   : ProgressBar         = null
var _hero_mana_bar : ProgressBar         = null
var _mob_hp_bars   : Array[ProgressBar]  = []
var _status_label  : Label               = null
var _restart_btn   : Button              = null

var _battle_over : bool = false


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_draw_arena()
	_setup_containers()
	_build_config_panel()


# ─────────────────────────────────────────────
#  ARÈNE
# ─────────────────────────────────────────────
func _draw_arena() -> void:
	var floor_rect := ColorRect.new()
	floor_rect.color    = Color(0.18, 0.28, 0.18)
	floor_rect.size     = Vector2(ARENA_W, ARENA_H)
	floor_rect.position = ARENA_CENTER - Vector2(ARENA_W, ARENA_H) * 0.5
	floor_rect.z_index  = -10
	add_child(floor_rect)

	var wc  := Color(0.35, 0.30, 0.22)
	var wt  := 12.0
	var ax  := ARENA_CENTER.x - ARENA_W * 0.5
	var ay  := ARENA_CENTER.y - ARENA_H * 0.5
	_add_wall(Vector2(ax - wt, ay - wt),          Vector2(ARENA_W + wt * 2.0, wt), wc)
	_add_wall(Vector2(ax - wt, ay + ARENA_H),      Vector2(ARENA_W + wt * 2.0, wt), wc)
	_add_wall(Vector2(ax - wt, ay),                Vector2(wt, ARENA_H), wc)
	_add_wall(Vector2(ax + ARENA_W, ay),           Vector2(wt, ARENA_H), wc)


func _add_wall(pos: Vector2, size: Vector2, color: Color) -> void:
	var r := ColorRect.new()
	r.color    = color
	r.size     = size
	r.position = pos
	r.z_index  = -9
	add_child(r)


func _setup_containers() -> void:
	_heroes_container       = Node2D.new()
	_heroes_container.name  = "Heroes"
	add_child(_heroes_container)

	_enemies_container      = Node2D.new()
	_enemies_container.name = "Enemies"
	add_child(_enemies_container)


# ═════════════════════════════════════════════
#  PANNEAU DE CONFIGURATION
# ═════════════════════════════════════════════
func _build_config_panel() -> void:
	_cfg_classes = HeroClassRegistry.get_all_base_classes()

	_config_canvas       = CanvasLayer.new()
	_config_canvas.layer = 20
	add_child(_config_canvas)

	## Fond semi-transparent
	var overlay := ColorRect.new()
	overlay.color = Color(0.04, 0.04, 0.10, 0.93)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_config_canvas.add_child(overlay)

	## Conteneur principal centré
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_CENTER)
	scroll.offset_left   = -420.0
	scroll.offset_top    = -310.0
	scroll.offset_right  =  420.0
	scroll.offset_bottom =  310.0
	_config_canvas.add_child(scroll)

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(840, 0)
	root.add_theme_constant_override("separation", 10)
	scroll.add_child(root)

	## Titre
	var title := Label.new()
	title.text = "Configuration du Héros"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	root.add_child(_hsep())

	## ── Ligne 1 : Classe / Niveau / Stats / Équipement ────────────────────────
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 20)
	root.add_child(row1)

	row1.add_child(_build_class_level_panel())
	row1.add_child(_vsep())
	row1.add_child(_build_stats_panel())
	row1.add_child(_vsep())
	row1.add_child(_build_equip_panel())

	root.add_child(_hsep())

	## ── Ligne 2 : Compétences ─────────────────────────────────────────────────
	root.add_child(_build_skills_panel())

	root.add_child(_hsep())

	## ── Bouton Lancer ─────────────────────────────────────────────────────────
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var start_btn := Button.new()
	start_btn.text = "Lancer le combat"
	start_btn.custom_minimum_size = Vector2(220, 38)
	start_btn.add_theme_font_size_override("font_size", 14)
	start_btn.pressed.connect(_on_start_combat)
	btn_row.add_child(start_btn)
	root.add_child(btn_row)

	## Initialisation
	_refresh_config_ui()


# ─────────────────────────────────────────────
#  Sous-panneaux de configuration
# ─────────────────────────────────────────────
func _build_class_level_panel() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(160, 0)
	vbox.add_theme_constant_override("separation", 6)

	vbox.add_child(_lbl("Classe", 12, true))
	_class_option = OptionButton.new()
	for c in _cfg_classes:
		_class_option.add_item(c.get("label", c.get("id", "?")))
	_class_option.selected = 0
	_class_option.item_selected.connect(_on_class_changed)
	vbox.add_child(_class_option)

	vbox.add_child(_lbl("Niveau", 12, true))
	_level_spin = SpinBox.new()
	_level_spin.min_value = 1
	_level_spin.max_value = 20
	_level_spin.value     = 1
	_level_spin.value_changed.connect(_on_level_changed)
	vbox.add_child(_level_spin)

	var reset_btn := Button.new()
	reset_btn.text = "Recalculer stats"
	reset_btn.add_theme_font_size_override("font_size", 10)
	reset_btn.pressed.connect(_apply_class_stats)
	vbox.add_child(reset_btn)

	return vbox


func _build_stats_panel() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(200, 0)
	vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_lbl("Stats (modifiables)", 12, true))

	for stat in STAT_NAMES:
		var row := HBoxContainer.new()
		var name_lbl := Label.new()
		name_lbl.text = _stat_display(stat) + ":"
		name_lbl.custom_minimum_size = Vector2(75, 0)
		name_lbl.add_theme_font_size_override("font_size", 11)
		var spin := SpinBox.new()
		spin.min_value = 1
		spin.max_value = 999
		spin.value     = _cfg_stats[stat]
		spin.custom_minimum_size = Vector2(95, 0)
		spin.value_changed.connect(_on_stat_changed.bind(stat))
		_stat_spins[stat] = spin
		row.add_child(name_lbl)
		row.add_child(spin)
		vbox.add_child(row)

	## Aperçu HP / Mana calculés
	vbox.add_child(_lbl("", 4, false))   # spacer
	var hp_row := HBoxContainer.new()
	var hp_name := Label.new()
	hp_name.text = "PV max :"
	hp_name.custom_minimum_size = Vector2(75, 0)
	hp_name.add_theme_font_size_override("font_size", 11)
	_hp_lbl = Label.new()
	_hp_lbl.add_theme_font_size_override("font_size", 11)
	_hp_lbl.add_theme_color_override("font_color", Color(0.85, 0.3, 0.3))
	hp_row.add_child(hp_name)
	hp_row.add_child(_hp_lbl)
	vbox.add_child(hp_row)

	var mana_row := HBoxContainer.new()
	var mana_name := Label.new()
	mana_name.text = "Mana max :"
	mana_name.custom_minimum_size = Vector2(75, 0)
	mana_name.add_theme_font_size_override("font_size", 11)
	_mana_lbl = Label.new()
	_mana_lbl.add_theme_font_size_override("font_size", 11)
	_mana_lbl.add_theme_color_override("font_color", Color(0.3, 0.5, 0.95))
	mana_row.add_child(mana_name)
	mana_row.add_child(_mana_lbl)
	vbox.add_child(mana_row)

	return vbox


func _build_equip_panel() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(240, 0)
	vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_lbl("Équipement", 12, true))

	for slot in ["weapon", "head", "torso", "legs", "accessory", "consumable"]:
		var row := HBoxContainer.new()
		var slot_lbl := Label.new()
		slot_lbl.text = _slot_display(slot) + ":"
		slot_lbl.custom_minimum_size = Vector2(72, 0)
		slot_lbl.add_theme_font_size_override("font_size", 11)
		var opt := OptionButton.new()
		opt.custom_minimum_size = Vector2(160, 0)
		opt.add_theme_font_size_override("font_size", 10)
		_equip_options[slot] = opt
		opt.item_selected.connect(_on_equip_changed.bind(slot))
		row.add_child(slot_lbl)
		row.add_child(opt)
		vbox.add_child(row)

	return vbox


func _build_skills_panel() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.add_child(_lbl("Compétences équipées (max 4)", 12, true))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)

	for i in 4:
		var slot_vbox := VBoxContainer.new()
		slot_vbox.custom_minimum_size = Vector2(180, 0)
		slot_vbox.add_child(_lbl("Slot %d" % (i + 1), 10, false))
		var opt := OptionButton.new()
		opt.add_theme_font_size_override("font_size", 10)
		opt.item_selected.connect(_on_skill_changed.bind(i))
		_skill_options.append(opt)
		slot_vbox.add_child(opt)
		hbox.add_child(slot_vbox)

	return vbox


# ─────────────────────────────────────────────
#  REFRESH CONFIG UI
# ─────────────────────────────────────────────
func _refresh_config_ui() -> void:
	_apply_class_stats()
	_refresh_equip_options()
	_refresh_skill_options()


func _apply_class_stats() -> void:
	if _cfg_classes.is_empty():
		return
	var cls  : Dictionary = _cfg_classes[_cfg_class_idx]
	var base : Dictionary = cls.get("stat_base", {})
	var gain : Dictionary = cls.get("stat_gain", {})
	var lvl  : int        = _cfg_level

	for stat in STAT_NAMES:
		var val : float = base.get(stat, 10.0) + gain.get(stat, 0.0) * (lvl - 1)
		val = clampf(val, 1.0, 999.0)
		_cfg_stats[stat] = val
		if _stat_spins.has(stat):
			_stat_spins[stat].value = val

	_refresh_derived_stats()


func _refresh_derived_stats() -> void:
	var str_v : float = _cfg_stats.get("strength", 10.0)
	var def_v : float = _cfg_stats.get("defense",  10.0)
	var mag_v : float = _cfg_stats.get("magic",    10.0)
	if _hp_lbl:
		_hp_lbl.text   = "%.0f" % (100.0 + str_v * 2.0 + def_v * 1.5)
	if _mana_lbl:
		_mana_lbl.text = "%.0f" % (50.0  + mag_v * 3.0)


func _refresh_equip_options() -> void:
	if _cfg_classes.is_empty():
		return
	var cls         : Dictionary = _cfg_classes[_cfg_class_idx]
	var weapon_types: Array      = cls.get("weapon_types", [])
	var armor_type  : String     = cls.get("armor_type", "legere")

	_populate_option(_equip_options["weapon"],    EquipmentLibrary.get_weapons_for_class(weapon_types), "weapon")
	_populate_option(_equip_options["head"],      EquipmentLibrary.get_armors_for_slot(armor_type, "head"), "head")
	_populate_option(_equip_options["torso"],     EquipmentLibrary.get_armors_for_slot(armor_type, "torso"), "torso")
	_populate_option(_equip_options["legs"],      EquipmentLibrary.get_armors_for_slot(armor_type, "legs"), "legs")
	_populate_option(_equip_options["accessory"], EquipmentLibrary.get_by_type("accessory"), "accessory")
	_populate_option(_equip_options["consumable"],EquipmentLibrary.get_by_type("consumable"), "consumable")


func _populate_option(opt: OptionButton, items: Array, slot: String) -> void:
	opt.clear()
	opt.add_item("— Aucun —")
	opt.set_item_metadata(0, "")
	for item in items:
		var label : String = "[%s] %s" % [item.get("rank", "F"), item.get("label", item.get("id", "?"))]
		opt.add_item(label)
		opt.set_item_metadata(opt.item_count - 1, item.get("id", ""))
	opt.selected = 0
	_cfg_equip[slot] = ""


func _refresh_skill_options() -> void:
	if _cfg_classes.is_empty():
		return
	var class_id : String = _cfg_classes[_cfg_class_idx].get("id", "")
	var rank     : String = _level_to_rank(_cfg_level)
	var skills   : Array  = SkillLibrary.get_skills_up_to_rank(class_id, rank)

	for i in _skill_options.size():
		var opt := _skill_options[i]
		opt.clear()
		opt.add_item("— Aucune —")
		opt.set_item_metadata(0, "")
		for sk in skills:
			var type_icon : String = "A" if sk.get("type", "") == "active" else "P"
			var lbl : String = "[%s][%s] %s" % [type_icon, sk.get("rank", "F"), sk.get("label", sk.get("id", "?"))]
			opt.add_item(lbl)
			opt.set_item_metadata(opt.item_count - 1, sk.get("id", ""))
		opt.selected = 0
		_cfg_skills[i] = ""


# ─────────────────────────────────────────────
#  CALLBACKS CONFIG
# ─────────────────────────────────────────────
func _on_class_changed(idx: int) -> void:
	_cfg_class_idx = idx
	_cfg_equip = { "weapon": "", "head": "", "torso": "", "legs": "", "accessory": "", "consumable": "" }
	_refresh_config_ui()


func _on_level_changed(val: float) -> void:
	_cfg_level = int(val)
	_apply_class_stats()
	_refresh_skill_options()


func _on_stat_changed(val: float, stat: String) -> void:
	_cfg_stats[stat] = val
	_refresh_derived_stats()


func _on_equip_changed(idx: int, slot: String) -> void:
	var opt : OptionButton = _equip_options[slot]
	_cfg_equip[slot] = opt.get_item_metadata(idx)


func _on_skill_changed(idx: int, slot: int) -> void:
	var opt := _skill_options[slot]
	_cfg_skills[slot] = opt.get_item_metadata(idx)


# ─────────────────────────────────────────────
#  LANCEMENT DU COMBAT
# ─────────────────────────────────────────────
func _on_start_combat() -> void:
	_config_canvas.queue_free()
	_config_canvas = null
	_spawn_hero_with_config()
	_spawn_mobs()
	_build_hud()


func _spawn_hero_with_config() -> void:
	var data := HeroData.new()
	data.hero_id   = 99
	data.hero_name = "Test"
	data.level     = _cfg_level
	data.rank      = _level_to_rank(_cfg_level)
	data.moral     = 100.0

	if not _cfg_classes.is_empty():
		var cls : Dictionary = _cfg_classes[_cfg_class_idx]
		data.hero_class  = cls.get("id", "")
		data.class_type  = cls.get("class_type", "physique")
		data.weapon_types.assign(cls.get("weapon_types", []))
		data.armor_type  = cls.get("armor_type", "legere")

	data.strength = _cfg_stats.get("strength", 10.0)
	data.defense  = _cfg_stats.get("defense",  10.0)
	data.agility  = _cfg_stats.get("agility",  10.0)
	data.magic    = _cfg_stats.get("magic",    10.0)
	data.luck     = _cfg_stats.get("luck",     10.0)

	## Équipement
	for slot in _cfg_equip:
		var item_id : String = _cfg_equip[slot]
		if item_id != "":
			data.equipment[slot] = item_id

	## Compétences équipées
	data.equipped_skills.clear()
	for sid in _cfg_skills:
		if sid != "":
			data.equipped_skills.append(sid)

	_hero_node = HeroCombatNode.new()
	_heroes_container.add_child(_hero_node)
	_hero_node.global_position = HERO_SPAWN
	_hero_node.setup(data, _enemies_container, true)

	_hero_node.hp_changed.connect(_on_hero_hp_changed)
	_hero_node.mana_changed.connect(_on_hero_mana_changed)
	_hero_node.hero_died.connect(_on_hero_died)

	## Caméra attachée au héros
	var cam := Camera2D.new()
	cam.zoom         = Vector2(2.0, 2.0)
	cam.limit_left   = int(ARENA_CENTER.x - ARENA_W * 0.5) - 40
	cam.limit_top    = int(ARENA_CENTER.y - ARENA_H * 0.5) - 40
	cam.limit_right  = int(ARENA_CENTER.x + ARENA_W * 0.5) + 40
	cam.limit_bottom = int(ARENA_CENTER.y + ARENA_H * 0.5) + 40
	_hero_node.add_child(cam)


func _spawn_mobs() -> void:
	for i in 3:
		var mob := MobNode.new()
		_enemies_container.add_child(mob)
		mob.global_position = SLIME_SPAWNS[i]
		mob.setup("slime", _heroes_container)
		_mob_nodes.append(mob)
		mob.mob_died.connect(_on_mob_died.bind(i))
		mob.hp_changed.connect(_on_mob_hp_changed.bind(i))


# ═════════════════════════════════════════════
#  HUD COMBAT
# ═════════════════════════════════════════════
func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	## Héros (bas gauche)
	var hero_panel := PanelContainer.new()
	hero_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hero_panel.offset_left   = 8.0
	hero_panel.offset_bottom = -8.0
	hero_panel.offset_right  = 230.0
	hero_panel.offset_top    = -100.0
	canvas.add_child(hero_panel)

	var hvbox := VBoxContainer.new()
	hero_panel.add_child(hvbox)

	var cls_name : String = ""
	if not _cfg_classes.is_empty():
		cls_name = _cfg_classes[_cfg_class_idx].get("label", "")
	var name_lbl := Label.new()
	name_lbl.text = "Test — %s Niv.%d" % [cls_name, _cfg_level]
	name_lbl.add_theme_font_size_override("font_size", 11)
	hvbox.add_child(name_lbl)

	hvbox.add_child(_lbl("PV", 10, false))
	_hero_hp_bar = _make_bar(Color(0.8, 0.15, 0.15), _hero_node.get_hp_max())
	_hero_hp_bar.value = _hero_node.get_hp()
	hvbox.add_child(_hero_hp_bar)

	hvbox.add_child(_lbl("Mana", 10, false))
	_hero_mana_bar = _make_bar(Color(0.15, 0.35, 0.85), _hero_node.get_mana())
	_hero_mana_bar.value = _hero_node.get_mana()
	hvbox.add_child(_hero_mana_bar)

	## Mobs (haut droite)
	var mob_vbox := VBoxContainer.new()
	mob_vbox.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	mob_vbox.offset_left   = -175.0
	mob_vbox.offset_top    = 8.0
	mob_vbox.offset_right  = -8.0
	mob_vbox.offset_bottom = 130.0
	canvas.add_child(mob_vbox)

	for i in _mob_nodes.size():
		mob_vbox.add_child(_lbl("Slime %d" % (i + 1), 10, false))
		var bar := _make_bar(Color(0.50, 0.75, 0.20), _mob_nodes[i].get_hp_max())
		bar.value = _mob_nodes[i].get_hp()
		_mob_hp_bars.append(bar)
		mob_vbox.add_child(bar)

	## Statut (centre haut)
	_status_label = Label.new()
	_status_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_status_label.offset_top   = 14.0
	_status_label.offset_left  = -140.0
	_status_label.offset_right =  140.0
	_status_label.add_theme_font_size_override("font_size", 28)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.visible = false
	canvas.add_child(_status_label)

	## Bouton rejouer (centre)
	_restart_btn = Button.new()
	_restart_btn.text = "Rejouer"
	_restart_btn.set_anchors_preset(Control.PRESET_CENTER)
	_restart_btn.offset_left   = -70.0
	_restart_btn.offset_right  =  70.0
	_restart_btn.offset_top    =  22.0
	_restart_btn.offset_bottom =  52.0
	_restart_btn.visible = false
	_restart_btn.pressed.connect(_restart)
	canvas.add_child(_restart_btn)

	## Hint (bas droite)
	var hint := Label.new()
	hint.text = "ZQSD / flèches : se déplacer\nClic gauche : cibler ennemi"
	hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.offset_left   = -210.0
	hint.offset_bottom = -8.0
	hint.offset_right  = -8.0
	hint.offset_top    = -50.0
	hint.add_theme_font_size_override("font_size", 10)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	canvas.add_child(hint)


# ─────────────────────────────────────────────
#  SIGNAUX COMBAT
# ─────────────────────────────────────────────
func _on_hero_hp_changed(_node: Node, hp: float, hp_max: float) -> void:
	if _hero_hp_bar:
		_hero_hp_bar.max_value = hp_max
		_hero_hp_bar.value     = hp


func _on_hero_mana_changed(_node: Node, mana: float, mana_max: float) -> void:
	if _hero_mana_bar:
		_hero_mana_bar.max_value = mana_max
		_hero_mana_bar.value     = mana


func _on_hero_died(_node: Node) -> void:
	if _battle_over:
		return
	_battle_over = true
	_show_result("DEFAITE", Color(0.9, 0.15, 0.15))


func _on_mob_hp_changed(_node: Node, hp: float, hp_max: float, i: int) -> void:
	if i < _mob_hp_bars.size():
		_mob_hp_bars[i].max_value = hp_max
		_mob_hp_bars[i].value     = hp


func _on_mob_died(_node: Node, i: int) -> void:
	if i < _mob_hp_bars.size():
		_mob_hp_bars[i].value = 0.0
	if _hero_node and is_instance_valid(_hero_node):
		_hero_node.on_enemy_killed()
	if _battle_over:
		return
	for mob in _mob_nodes:
		if is_instance_valid(mob) and not mob.is_dead():
			return
	_battle_over = true
	_show_result("VICTOIRE !", Color(0.15, 0.85, 0.30))


func _show_result(text: String, color: Color) -> void:
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", color)
	_status_label.visible = true
	_restart_btn.visible  = true


func _restart() -> void:
	get_tree().reload_current_scene()


# ═════════════════════════════════════════════
#  UTILITAIRES
# ═════════════════════════════════════════════
func _level_to_rank(lvl: int) -> String:
	if   lvl >= 18: return "A"
	elif lvl >= 14: return "B"
	elif lvl >= 10: return "C"
	elif lvl >= 7:  return "D"
	elif lvl >= 4:  return "E"
	return "F"


func _stat_display(stat: String) -> String:
	match stat:
		"strength": return "Force"
		"defense":  return "Défense"
		"agility":  return "Agilité"
		"magic":    return "Magie"
		"luck":     return "Chance"
	return stat


func _slot_display(slot: String) -> String:
	match slot:
		"weapon":    return "Arme"
		"head":      return "Tête"
		"torso":     return "Torse"
		"legs":      return "Jambes"
		"accessory": return "Accessoire"
		"consumable":return "Consommable"
	return slot


func _make_bar(color: Color, max_val: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value           = max_val
	bar.value               = max_val
	bar.custom_minimum_size = Vector2(160.0, 14.0)
	bar.show_percentage     = false
	var style := StyleBoxFlat.new()
	style.bg_color = color
	bar.add_theme_stylebox_override("fill", style)
	return bar


func _lbl(text: String, font_size: int, bold: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	if bold:
		l.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	return l


func _hsep() -> HSeparator:
	return HSeparator.new()


func _vsep() -> VSeparator:
	return VSeparator.new()
