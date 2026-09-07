## HeroSkillsPanel.gd
## Panneau de gestion des compétences d'un héros.
## Ouvert via EventBus.ui_panel_open_requested("skills_panel", {"hero_data": hero_data}).
extends Control


const MAX_EQUIPPED : int = 4

## Coût d'achat en points de compétence selon le rang de la compétence.
const SKILL_COST_BY_RANK := {
	"F": 1, "E": 2, "D": 4, "C": 6, "B": 10, "A": 15, "S": 25,
}

var _panel       : PanelContainer  = null
var _data        : HeroData        = null
var _title_lbl   : Label           = null

## Colonne gauche
var _skills_vbox   : VBoxContainer = null
var _equip_counter : Label         = null

## Colonne droite
var _buy_vbox    : VBoxContainer   = null
var _points_lbl  : Label           = null


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_panel.hide()
	EventBus.ui_panel_open_requested.connect(_on_open_requested)


func _exit_tree() -> void:
	if EventBus.ui_panel_open_requested.is_connected(_on_open_requested):
		EventBus.ui_panel_open_requested.disconnect(_on_open_requested)


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(700, 440)
	add_child(_panel)

	var outer := MarginContainer.new()
	for side : String in ["left", "right", "top", "bottom"]:
		outer.add_theme_constant_override("margin_" + side, 12)
	_panel.add_child(outer)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	outer.add_child(root)

	## ── Titre ─────────────────────────────────────────────────────────────────
	var title_row := HBoxContainer.new()
	root.add_child(title_row)

	_title_lbl = Label.new()
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 15)
	title_row.add_child(_title_lbl)

	var close_btn := Button.new()
	close_btn.text = "← Retour"
	close_btn.add_theme_font_size_override("font_size", 11)
	close_btn.custom_minimum_size = Vector2(70, 0)
	close_btn.pressed.connect(_close)
	title_row.add_child(close_btn)

	root.add_child(HSeparator.new())

	## ── Corps : [gauche] | [sep] | [droite] ──────────────────────────────────
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	_build_left_column(body)
	body.add_child(VSeparator.new())
	_build_right_column(body)


func _build_left_column(parent: HBoxContainer) -> void:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	parent.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	var hdr := Label.new()
	hdr.text = "Compétences apprises"
	hdr.add_theme_font_size_override("font_size", 12)
	vbox.add_child(hdr)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)

	_skills_vbox = VBoxContainer.new()
	_skills_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skills_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_skills_vbox)

	_equip_counter = Label.new()
	_equip_counter.add_theme_font_size_override("font_size", 11)
	_equip_counter.modulate = Color(0.70, 0.70, 0.75)
	vbox.add_child(_equip_counter)


func _build_right_column(parent: HBoxContainer) -> void:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	for side : String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	parent.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	## En-tête : titre + points disponibles
	var hdr_row := HBoxContainer.new()
	vbox.add_child(hdr_row)

	var hdr := Label.new()
	hdr.text = "Acheter des compétences"
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_theme_font_size_override("font_size", 12)
	hdr_row.add_child(hdr)

	_points_lbl = Label.new()
	_points_lbl.add_theme_font_size_override("font_size", 11)
	_points_lbl.modulate = Color(0.95, 0.85, 0.30)
	hdr_row.add_child(_points_lbl)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)

	_buy_vbox = VBoxContainer.new()
	_buy_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buy_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_buy_vbox)


# ─────────────────────────────────────────────
#  OUVERTURE / FERMETURE
# ─────────────────────────────────────────────
func _on_open_requested(panel_id: String, payload: Dictionary) -> void:
	if panel_id != "skills_panel":
		return
	_data = payload.get("hero_data", null) as HeroData
	if not _data:
		return
	_title_lbl.text = _data.hero_name
	_refresh()
	_panel.show()
	await get_tree().process_frame
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	UIState.menu_open = true


func _close() -> void:
	_panel.hide()
	if _data:
		## Rerouvre le panneau de détail du héros
		EventBus.hero_inspect_requested.emit(_data, Vector2(-1.0, -1.0))
	else:
		UIState.menu_open = false


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("click"):
		var r := Rect2(_panel.global_position, _panel.size)
		if not r.has_point(get_viewport().get_mouse_position()):
			_close()


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT
# ─────────────────────────────────────────────
func _refresh() -> void:
	_refresh_owned()
	_refresh_buyable()


func _refresh_owned() -> void:
	for c in _skills_vbox.get_children():
		c.queue_free()

	var equipped_count : int = _data.equipped_skills.size()

	if _data.skills.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucune compétence apprise."
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = Color(0.50, 0.50, 0.50)
		_skills_vbox.add_child(lbl)
	else:
		for entry in _data.skills:
			var skill_id : String = entry if entry is String else entry.get("id", "")
			var sdef : Dictionary = SkillLibrary.get_skill(skill_id)
			if sdef.is_empty():
				continue
			_skills_vbox.add_child(_make_owned_row(sdef, equipped_count))

	_equip_counter.text = "Équipées : %d / %d" % [equipped_count, MAX_EQUIPPED]


func _make_owned_row(sdef: Dictionary, equipped_count: int) -> HBoxContainer:
	var skill_id    : String = sdef["id"]
	var is_equipped : bool   = skill_id in _data.equipped_skills

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	## Fond coloré selon état équipé
	var pc  := PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sty := StyleBoxFlat.new()
	sty.bg_color     = Color(0.10, 0.22, 0.14) if is_equipped else Color(0.14, 0.14, 0.20)
	sty.border_color = Color(0.25, 0.70, 0.35) if is_equipped else Color(0.30, 0.30, 0.50)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(3)
	sty.content_margin_left   = 8
	sty.content_margin_right  = 8
	sty.content_margin_top    = 4
	sty.content_margin_bottom = 4
	pc.add_theme_stylebox_override("panel", sty)
	row.add_child(pc)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 1)
	pc.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = sdef.get("label", skill_id)
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.tooltip_text = sdef.get("description", "")
	if is_equipped:
		name_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.50))
	info_vbox.add_child(name_lbl)

	## Sous-info : cooldown / mana / passif
	var parts : Array[String] = []
	if sdef.get("type", "") == "passive":
		parts.append("Passif")
	else:
		var cd : float = sdef.get("cooldown", 0.0)
		var mc : int   = sdef.get("mana_cost", 0)
		if cd > 0.0: parts.append("Cd: %.0fs" % cd)
		if mc > 0:   parts.append("Mana: %d" % mc)
	if not parts.is_empty():
		var sub := Label.new()
		sub.text = " · ".join(parts)
		sub.add_theme_font_size_override("font_size", 9)
		sub.modulate = Color(0.55, 0.55, 0.60)
		info_vbox.add_child(sub)

	## Bouton
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(90, 0)
	btn.add_theme_font_size_override("font_size", 10)
	if is_equipped:
		btn.text = "Déséquiper"
		btn.pressed.connect(_unequip_skill.bind(skill_id))
	else:
		btn.text = "Équiper"
		btn.disabled = (equipped_count >= MAX_EQUIPPED)
		btn.pressed.connect(_equip_skill.bind(skill_id))
	row.add_child(btn)

	return row


func _refresh_buyable() -> void:
	for c in _buy_vbox.get_children():
		c.queue_free()

	_points_lbl.text = "Points : %d" % _data.skill_points

	## IDs des compétences déjà apprises
	var owned_ids : Array = []
	for entry in _data.skills:
		owned_ids.append(entry if entry is String else entry.get("id", ""))

	## Compétences disponibles pour la classe du héros jusqu'à son rang
	var available : Array = SkillLibrary.get_skills_up_to_rank(
		_data.hero_class, _data.rank
	).filter(func(s : Dictionary) -> bool: return not (s["id"] in owned_ids))

	if available.is_empty():
		var lbl := Label.new()
		lbl.text = "Toutes les compétences\ndisponibles sont déjà apprises."
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = Color(0.50, 0.50, 0.50)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		_buy_vbox.add_child(lbl)
		return

	for sdef : Dictionary in available:
		_buy_vbox.add_child(_make_buy_row(sdef))


func _make_buy_row(sdef: Dictionary) -> HBoxContainer:
	var skill_id : String = sdef["id"]
	var cost     : int    = SKILL_COST_BY_RANK.get(sdef.get("rank", "F"), 1)
	var can_buy  : bool   = _data.skill_points >= cost

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var pc  := PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sty := StyleBoxFlat.new()
	sty.bg_color     = Color(0.12, 0.12, 0.18)
	sty.border_color = Color(0.28, 0.26, 0.42)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(3)
	sty.content_margin_left   = 8
	sty.content_margin_right  = 8
	sty.content_margin_top    = 4
	sty.content_margin_bottom = 4
	pc.add_theme_stylebox_override("panel", sty)
	row.add_child(pc)

	var name_lbl := Label.new()
	name_lbl.text = sdef.get("label", skill_id)
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	name_lbl.tooltip_text = sdef.get("description", "")
	if not can_buy:
		name_lbl.modulate = Color(0.55, 0.55, 0.55)
	pc.add_child(name_lbl)

	var buy_btn := Button.new()
	buy_btn.text = "%d pts" % cost
	buy_btn.custom_minimum_size = Vector2(64, 0)
	buy_btn.add_theme_font_size_override("font_size", 10)
	buy_btn.disabled = not can_buy
	if not can_buy:
		buy_btn.modulate.a = 0.50
	buy_btn.pressed.connect(_buy_skill.bind(skill_id, cost))
	row.add_child(buy_btn)

	return row


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func _equip_skill(skill_id: String) -> void:
	if not _data or _data.equipped_skills.size() >= MAX_EQUIPPED:
		return
	if not (skill_id in _data.equipped_skills):
		_data.equipped_skills.append(skill_id)
	_refresh()


func _unequip_skill(skill_id: String) -> void:
	if not _data:
		return
	_data.equipped_skills.erase(skill_id)
	_refresh()


func _buy_skill(skill_id: String, cost: int) -> void:
	if not _data or _data.skill_points < cost:
		return
	## Vérifier pas déjà acheté
	for entry in _data.skills:
		var eid : String = entry if entry is String else entry.get("id", "")
		if eid == skill_id:
			return
	_data.skill_points -= cost
	var sdef : Dictionary = SkillLibrary.get_skill(skill_id)
	_data.skills.append({
		"id":    skill_id,
		"rank":  sdef.get("rank", "F"),
		"level": 1,
	})
	_refresh()
