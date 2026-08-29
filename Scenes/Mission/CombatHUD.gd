## CombatHUD.gd
## Interface de combat code-only : barres HP/mana, compteur ennemis, log, écran de fin.
class_name CombatHUD
extends CanvasLayer

signal return_pressed

## hero_node → { hp_bar, mana_bar }
var _hero_bars       : Dictionary       = {}
## hero_node → { skill_id → { panel, cd_lbl, total_cd } }
var _hero_skill_panels : Dictionary     = {}
var _full_rect       : Control          = null
var _hero_section    : VBoxContainer    = null
var _skill_bar_root  : HBoxContainer    = null  ## barre de skills (bas-centre)
var _enemy_count_lbl : Label            = null
var _log_container   : VBoxContainer    = null
var _log_scroll      : ScrollContainer  = null
var _end_panel       : PanelContainer   = null


func _ready() -> void:
	layer = 10

	_full_rect = Control.new()
	_full_rect.name = "FullRect"
	_full_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_full_rect)

	## ── Section héros (bas-gauche) ─────────────────────────────
	var hero_bg := PanelContainer.new()
	var hero_bg_style := StyleBoxFlat.new()
	hero_bg_style.bg_color = Color(0.06, 0.06, 0.08, 0.82)
	hero_bg_style.set_corner_radius_all(4)
	hero_bg.add_theme_stylebox_override("panel", hero_bg_style)
	hero_bg.set_anchor_and_offset(SIDE_LEFT,   0.0,  4.0)
	hero_bg.set_anchor_and_offset(SIDE_TOP,    0.65, 0.0)
	hero_bg.set_anchor_and_offset(SIDE_RIGHT,  0.32, 0.0)
	hero_bg.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -4.0)
	_full_rect.add_child(hero_bg)

	_hero_section = VBoxContainer.new()
	_hero_section.add_theme_constant_override("separation", 4)
	hero_bg.add_child(_hero_section)

	## ── Compteur ennemis (coin haut-droit) ─────────────────────
	_enemy_count_lbl = Label.new()
	_enemy_count_lbl.set_anchor_and_offset(SIDE_LEFT,   0.65, 0.0)
	_enemy_count_lbl.set_anchor_and_offset(SIDE_TOP,    0.0,  8.0)
	_enemy_count_lbl.set_anchor_and_offset(SIDE_RIGHT,  1.0, -8.0)
	_enemy_count_lbl.set_anchor_and_offset(SIDE_BOTTOM, 0.08, 0.0)
	_enemy_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_enemy_count_lbl.add_theme_color_override("font_color", Color.WHITE)
	_enemy_count_lbl.add_theme_font_size_override("font_size", 14)
	_enemy_count_lbl.text = "Ennemis : 0"
	_full_rect.add_child(_enemy_count_lbl)

	## ── Log de combat (côté droit) ─────────────────────────────
	var log_bg := PanelContainer.new()
	var log_bg_style := StyleBoxFlat.new()
	log_bg_style.bg_color = Color(0.06, 0.06, 0.08, 0.82)
	log_bg_style.set_corner_radius_all(4)
	log_bg.add_theme_stylebox_override("panel", log_bg_style)
	log_bg.set_anchor_and_offset(SIDE_LEFT,   0.68, 0.0)
	log_bg.set_anchor_and_offset(SIDE_TOP,    0.08, 4.0)
	log_bg.set_anchor_and_offset(SIDE_RIGHT,  1.0, -4.0)
	log_bg.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -4.0)
	_full_rect.add_child(log_bg)

	_log_scroll = ScrollContainer.new()
	_log_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_bg.add_child(_log_scroll)

	_log_container = VBoxContainer.new()
	_log_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_scroll.add_child(_log_container)

	## ── Barre de compétences (bas-centre) ────────────────────
	var skill_bg := PanelContainer.new()
	var skill_bg_style := StyleBoxFlat.new()
	skill_bg_style.bg_color = Color(0.06, 0.06, 0.08, 0.82)
	skill_bg_style.set_corner_radius_all(4)
	skill_bg.add_theme_stylebox_override("panel", skill_bg_style)
	skill_bg.set_anchor_and_offset(SIDE_LEFT,   0.25, 0.0)
	skill_bg.set_anchor_and_offset(SIDE_TOP,    0.88, 0.0)
	skill_bg.set_anchor_and_offset(SIDE_RIGHT,  0.75, 0.0)
	skill_bg.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -4.0)
	_full_rect.add_child(skill_bg)

	_skill_bar_root = HBoxContainer.new()
	_skill_bar_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_skill_bar_root.add_theme_constant_override("separation", 6)
	skill_bg.add_child(_skill_bar_root)

	## ── Panneau de fin (centre, caché) ─────────────────────────
	_end_panel = PanelContainer.new()
	_end_panel.set_anchor_and_offset(SIDE_LEFT,   0.25, 0.0)
	_end_panel.set_anchor_and_offset(SIDE_TOP,    0.25, 0.0)
	_end_panel.set_anchor_and_offset(SIDE_RIGHT,  0.75, 0.0)
	_end_panel.set_anchor_and_offset(SIDE_BOTTOM, 0.75, 0.0)
	_full_rect.add_child(_end_panel)
	_end_panel.hide()


func add_hero_bar(hero_node: Node2D, hero_data: HeroData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_hero_section.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = hero_data.hero_name.substr(0, 8)
	name_lbl.custom_minimum_size = Vector2(56, 0)
	name_lbl.vertical_alignment  = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.add_theme_font_size_override("font_size", 10)
	row.add_child(name_lbl)

	var bars_vbox := VBoxContainer.new()
	bars_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars_vbox.add_theme_constant_override("separation", 2)
	row.add_child(bars_vbox)

	var hp_bar := ProgressBar.new()
	hp_bar.min_value             = 0.0
	hp_bar.max_value             = 1.0
	hp_bar.value                 = 1.0
	hp_bar.custom_minimum_size   = Vector2(0, 8)
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.show_percentage       = false
	var hp_fill := StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.18, 0.75, 0.22)
	hp_fill.set_corner_radius_all(2)
	var hp_bg_style := StyleBoxFlat.new()
	hp_bg_style.bg_color = Color(0.12, 0.12, 0.12, 0.9)
	hp_bg_style.set_corner_radius_all(2)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	hp_bar.add_theme_stylebox_override("background", hp_bg_style)
	bars_vbox.add_child(hp_bar)

	var mana_bar := ProgressBar.new()
	mana_bar.min_value             = 0.0
	mana_bar.max_value             = 1.0
	mana_bar.value                 = 1.0
	mana_bar.custom_minimum_size   = Vector2(0, 5)
	mana_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mana_bar.show_percentage       = false
	var mana_fill := StyleBoxFlat.new()
	mana_fill.bg_color = Color(0.10, 0.35, 0.90)
	mana_fill.set_corner_radius_all(2)
	var mana_bg_style := StyleBoxFlat.new()
	mana_bg_style.bg_color = Color(0.05, 0.08, 0.22, 0.9)
	mana_bg_style.set_corner_radius_all(2)
	mana_bar.add_theme_stylebox_override("fill", mana_fill)
	mana_bar.add_theme_stylebox_override("background", mana_bg_style)
	bars_vbox.add_child(mana_bar)

	_hero_bars[hero_node] = { "hp_bar": hp_bar, "mana_bar": mana_bar }
	_add_hero_skill_slots(hero_node, hero_data)


func _add_hero_skill_slots(hero_node: Node2D, hero_data: HeroData) -> void:
	if hero_data.equipped_skills.is_empty():
		return
	## Groupe par héros : nom + 4 slots
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 2)
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skill_bar_root.add_child(group)

	var hero_name_lbl := Label.new()
	hero_name_lbl.text = hero_data.hero_name.substr(0, 8)
	hero_name_lbl.add_theme_font_size_override("font_size", 9)
	hero_name_lbl.modulate = Color(0.80, 0.80, 0.80)
	group.add_child(hero_name_lbl)

	var slots_row := HBoxContainer.new()
	slots_row.add_theme_constant_override("separation", 4)
	group.add_child(slots_row)

	_hero_skill_panels[hero_node] = {}
	for sid in hero_data.equipped_skills:
		var sdata : Dictionary = SkillLibrary.get_skill(sid)
		var slot_panel := PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(64, 0)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = Color(0.10, 0.55, 0.10, 0.85)
		slot_style.set_corner_radius_all(3)
		slot_style.content_margin_left   = 4
		slot_style.content_margin_right  = 4
		slot_style.content_margin_top    = 3
		slot_style.content_margin_bottom = 3
		slot_panel.add_theme_stylebox_override("panel", slot_style)
		slots_row.add_child(slot_panel)

		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 1)
		slot_panel.add_child(inner)

		var name_lbl := Label.new()
		name_lbl.text = sdata.get("label", sid).substr(0, 12)
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(name_lbl)

		var cd_lbl := Label.new()
		cd_lbl.text = "Prête"
		cd_lbl.add_theme_font_size_override("font_size", 9)
		cd_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		cd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(cd_lbl)

		_hero_skill_panels[hero_node][sid] = {
			"panel":    slot_panel,
			"cd_lbl":   cd_lbl,
			"style":    slot_style,
			"total_cd": sdata.get("cooldown", 1.0),
			"remaining": 0.0,
		}


func update_skill_cooldown(hero_node: Node2D, skill_id: String, cooldown: float) -> void:
	if not _hero_skill_panels.has(hero_node):
		return
	if not _hero_skill_panels[hero_node].has(skill_id):
		return
	var entry : Dictionary = _hero_skill_panels[hero_node][skill_id]
	entry["remaining"] = cooldown
	entry["cd_lbl"].text = "%.1fs" % cooldown
	entry["cd_lbl"].add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	entry["style"].bg_color = Color(0.40, 0.20, 0.05, 0.85)


func _process(delta: float) -> void:
	## Décompte visuel des cooldowns
	for hero_node in _hero_skill_panels:
		for sid in _hero_skill_panels[hero_node]:
			var entry : Dictionary = _hero_skill_panels[hero_node][sid]
			if entry["remaining"] <= 0.0:
				continue
			entry["remaining"] = maxf(0.0, entry["remaining"] - delta)
			if entry["remaining"] <= 0.0:
				entry["cd_lbl"].text = "Prête"
				entry["cd_lbl"].add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
				entry["style"].bg_color = Color(0.10, 0.55, 0.10, 0.85)
			else:
				entry["cd_lbl"].text = "%.1fs" % entry["remaining"]


func update_hero_hp(hero_node: Node2D, hp: float, hp_max: float) -> void:
	if not _hero_bars.has(hero_node):
		return
	_hero_bars[hero_node]["hp_bar"].value = (hp / hp_max) if hp_max > 0.0 else 0.0


func update_hero_mana(hero_node: Node2D, mana: float, mana_max: float) -> void:
	if not _hero_bars.has(hero_node):
		return
	_hero_bars[hero_node]["mana_bar"].value = (mana / mana_max) if mana_max > 0.0 else 0.0


func update_enemy_count(count: int) -> void:
	_enemy_count_lbl.text = "Ennemis restants : %d" % count


func log(message: String) -> void:
	if _log_container == null:
		return
	var lbl := Label.new()
	lbl.text         = message
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	_log_container.add_child(lbl)
	## Limite le log à 40 lignes
	while _log_container.get_child_count() > 40:
		_log_container.get_child(0).queue_free()
	## Scroll vers le bas au prochain frame
	_log_scroll.call_deferred("set_v_scroll", 999999)


func show_end_screen(victory: bool, gold: int, rep: int) -> void:
	_end_panel.show()

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_panel.add_child(vbox)

	var title := Label.new()
	title.text                 = "VICTOIRE !" if victory else "DÉFAITE..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1) if victory else Color(1.0, 0.3, 0.3))
	vbox.add_child(title)

	if victory and (gold > 0 or rep > 0):
		var rewards := Label.new()
		rewards.text                 = "+%d or    +%d réputation" % [gold, rep]
		rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rewards.add_theme_color_override("font_color", Color.WHITE)
		rewards.add_theme_font_size_override("font_size", 14)
		vbox.add_child(rewards)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	var btn := Button.new()
	btn.text               = "Retour à la guilde"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func() -> void: return_pressed.emit())
	vbox.add_child(btn)
