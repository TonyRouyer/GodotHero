## CombatHUD.gd
## Interface de combat : barres HP/mana sans dépendance au thème (ColorRect),
## compteur ennemis, log de combat, barre de compétences, écran de fin.
class_name CombatHUD
extends CanvasLayer

signal return_pressed

## hero_node → { "hp_fill": ColorRect, "mana_fill": ColorRect }
var _hero_bars         : Dictionary      = {}
## hero_node → { skill_id → { panel, cd_lbl, style, remaining } }
var _hero_skill_panels : Dictionary      = {}
var _full_rect         : Control         = null
var _hero_section      : VBoxContainer   = null
var _skill_bar_root    : HBoxContainer   = null
var _enemy_count_lbl   : Label           = null
var _log_container     : VBoxContainer   = null
var _log_scroll        : ScrollContainer = null
var _end_panel         : PanelContainer  = null


func _ready() -> void:
	layer = 10

	_full_rect = Control.new()
	_full_rect.name = "FullRect"
	_full_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_full_rect)

	## ── Section héros (bas-gauche) ─────────────────────────────
	var hero_bg := _make_panel(Color(0.06, 0.06, 0.08, 0.86))
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
	var log_bg := _make_panel(Color(0.04, 0.04, 0.06, 0.82))
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
	var skill_bg := _make_panel(Color(0.06, 0.06, 0.08, 0.86))
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


# ─────────────────────────────────────────────
#  UTILITAIRES DE CONSTRUCTION
# ─────────────────────────────────────────────

## PanelContainer avec fond sombre stylisé (sans dépendance au thème par défaut).
func _make_panel(bg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(4)
	s.content_margin_left   = 6
	s.content_margin_right  = 6
	s.content_margin_top    = 4
	s.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", s)
	return p


## Barre de progression thème-indépendante : ColorRect fond + ColorRect remplissage.
## Retourne { "outer": Control, "fill": ColorRect }.
func _make_bar(height: float, fill_color: Color, bg_color: Color) -> Dictionary:
	var outer := Control.new()
	outer.custom_minimum_size   = Vector2(0, height)
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.clip_contents         = true

	var bg := ColorRect.new()
	bg.color = bg_color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.add_child(bg)

	## Coin arrondi simulé avec un léger border radius via marges
	var fill := ColorRect.new()
	fill.color         = fill_color
	fill.anchor_left   = 0.0
	fill.anchor_top    = 0.0
	fill.anchor_right  = 1.0   ## mis à jour dynamiquement (0.0–1.0)
	fill.anchor_bottom = 1.0
	fill.offset_left   = 0
	fill.offset_top    = 1
	fill.offset_right  = 0
	fill.offset_bottom = -1
	outer.add_child(fill)

	return {"outer": outer, "fill": fill}


# ─────────────────────────────────────────────
#  AJOUT DE HÉROS
# ─────────────────────────────────────────────

func add_hero_bar(hero_node: Node2D, hero_data: HeroData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_hero_section.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text                = hero_data.hero_name.substr(0, 8)
	name_lbl.custom_minimum_size = Vector2(60, 0)
	name_lbl.vertical_alignment  = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	name_lbl.add_theme_font_size_override("font_size", 10)
	row.add_child(name_lbl)

	var bars_vbox := VBoxContainer.new()
	bars_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars_vbox.add_theme_constant_override("separation", 3)
	row.add_child(bars_vbox)

	var hp_d   := _make_bar(9.0,  Color(0.18, 0.76, 0.24), Color(0.10, 0.10, 0.10, 0.9))
	var mana_d := _make_bar(5.0,  Color(0.12, 0.38, 0.90), Color(0.05, 0.06, 0.20, 0.9))
	bars_vbox.add_child(hp_d["outer"])
	bars_vbox.add_child(mana_d["outer"])

	_hero_bars[hero_node] = { "hp_fill": hp_d["fill"], "mana_fill": mana_d["fill"] }
	_add_hero_skill_slots(hero_node, hero_data)


func _add_hero_skill_slots(hero_node: Node2D, hero_data: HeroData) -> void:
	if hero_data.equipped_skills.is_empty():
		return

	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 2)
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skill_bar_root.add_child(group)

	var hero_name_lbl := Label.new()
	hero_name_lbl.text = hero_data.hero_name.substr(0, 8)
	hero_name_lbl.add_theme_font_size_override("font_size", 9)
	hero_name_lbl.modulate = Color(0.75, 0.80, 0.90)
	group.add_child(hero_name_lbl)

	var slots_row := HBoxContainer.new()
	slots_row.add_theme_constant_override("separation", 4)
	group.add_child(slots_row)

	_hero_skill_panels[hero_node] = {}
	for sid in hero_data.equipped_skills:
		var sdata : Dictionary = SkillLibrary.get_skill(sid)
		var slot_panel := PanelContainer.new()
		slot_panel.custom_minimum_size   = Vector2(64, 0)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = Color(0.10, 0.50, 0.12, 0.90)
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
		name_lbl.text                 = sdata.get("label", sid).substr(0, 12)
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(name_lbl)

		var cd_lbl := Label.new()
		cd_lbl.text = "Prête"
		cd_lbl.add_theme_font_size_override("font_size", 9)
		cd_lbl.add_theme_color_override("font_color", Color(0.40, 1.0, 0.45))
		cd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(cd_lbl)

		_hero_skill_panels[hero_node][sid] = {
			"panel":     slot_panel,
			"cd_lbl":    cd_lbl,
			"style":     slot_style,
			"total_cd":  sdata.get("cooldown", 1.0),
			"remaining": 0.0,
		}


# ─────────────────────────────────────────────
#  MISES À JOUR DYNAMIQUES
# ─────────────────────────────────────────────

func update_skill_cooldown(hero_node: Node2D, skill_id: String, cooldown: float) -> void:
	if not _hero_skill_panels.has(hero_node):
		return
	if not _hero_skill_panels[hero_node].has(skill_id):
		return
	var entry : Dictionary = _hero_skill_panels[hero_node][skill_id]
	entry["remaining"]  = cooldown
	entry["cd_lbl"].text = "%.1fs" % cooldown
	entry["cd_lbl"].add_theme_color_override("font_color", Color(1.0, 0.55, 0.15))
	entry["style"].bg_color = Color(0.38, 0.18, 0.04, 0.90)


func _process(delta: float) -> void:
	for hero_node in _hero_skill_panels:
		for sid in _hero_skill_panels[hero_node]:
			var entry : Dictionary = _hero_skill_panels[hero_node][sid]
			if entry["remaining"] <= 0.0:
				continue
			entry["remaining"] = maxf(0.0, entry["remaining"] - delta)
			if entry["remaining"] <= 0.0:
				entry["cd_lbl"].text = "Prête"
				entry["cd_lbl"].add_theme_color_override("font_color", Color(0.40, 1.0, 0.45))
				entry["style"].bg_color = Color(0.10, 0.50, 0.12, 0.90)
			else:
				entry["cd_lbl"].text = "%.1fs" % entry["remaining"]


func update_hero_hp(hero_node: Node2D, hp: float, hp_max: float) -> void:
	if not _hero_bars.has(hero_node):
		return
	var pct : float = clampf((hp / hp_max) if hp_max > 0.0 else 0.0, 0.0, 1.0)
	_hero_bars[hero_node]["hp_fill"].anchor_right = pct
	## Couleur dynamique : vert → orange → rouge selon les PV
	var fill : ColorRect = _hero_bars[hero_node]["hp_fill"]
	if   pct > 0.60: fill.color = Color(0.18, 0.76, 0.24)
	elif pct > 0.30: fill.color = Color(0.85, 0.60, 0.05)
	else:            fill.color = Color(0.80, 0.18, 0.12)


func update_hero_mana(hero_node: Node2D, mana: float, mana_max: float) -> void:
	if not _hero_bars.has(hero_node):
		return
	_hero_bars[hero_node]["mana_fill"].anchor_right = \
		clampf((mana / mana_max) if mana_max > 0.0 else 0.0, 0.0, 1.0)


func update_enemy_count(count: int) -> void:
	_enemy_count_lbl.text = "Ennemis restants : %d" % count


func log(message: String) -> void:
	if _log_container == null:
		return
	var lbl := Label.new()
	lbl.text          = message
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
	_log_container.add_child(lbl)
	while _log_container.get_child_count() > 40:
		_log_container.get_child(0).queue_free()
	_log_scroll.call_deferred("set_v_scroll", 999999)


# ─────────────────────────────────────────────
#  ÉCRAN DE FIN
# ─────────────────────────────────────────────

func show_end_screen(victory: bool, gold: int, rep: int) -> void:
	_end_panel.show()

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_panel.add_child(vbox)

	var title := Label.new()
	title.text                 = "VICTOIRE !" if victory else "DÉFAITE..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override(
		"font_color", Color(1.0, 0.85, 0.10) if victory else Color(1.0, 0.28, 0.28)
	)
	vbox.add_child(title)

	if victory and (gold > 0 or rep > 0):
		var rewards := Label.new()
		rewards.text                 = "+%d or    +%d réputation" % [gold, rep]
		rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rewards.add_theme_color_override("font_color", Color(0.90, 0.90, 0.90))
		rewards.add_theme_font_size_override("font_size", 14)
		vbox.add_child(rewards)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	var btn := Button.new()
	btn.text                  = "Retour à la guilde"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func() -> void: return_pressed.emit())
	vbox.add_child(btn)
