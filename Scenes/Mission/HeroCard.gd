## HeroCard.gd
## Carte d'un héros dans le HUD de combat.
## Instanciée par CombatHUD pour chaque héros de la mission (1 à 4).
extends PanelContainer

@onready var _name_lbl   : Label         = $VBox/Header/HeroName
@onready var _class_lbl  : Label         = $VBox/ClassLabel
@onready var _ai_badge   : Label         = $VBox/Header/AIBadge
@onready var _hp_fill    : ColorRect     = $VBox/HPBar/HPFill
@onready var _moral_fill : ColorRect     = $VBox/MoralBar/MoralFill
@onready var _buffs_row  : HBoxContainer = $VBox/BuffsRow
@onready var _player_tag : Label         = $VBox/PlayerTag


func set_empty() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.25)
	_name_lbl.text  = "—"
	_class_lbl.text = "Emplacement libre"
	_ai_badge.visible   = false
	_player_tag.visible = false
	_hp_fill.anchor_right = 0.0
	_moral_fill.anchor_right = 0.0


func setup(hero_data: HeroData, is_player: bool) -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_name_lbl.text  = hero_data.hero_name
	var cls : Dictionary = HeroClassRegistry.get_class_by_id(hero_data.hero_class)
	var cls_label : String = cls.get("label", hero_data.hero_class)
	_class_lbl.text      = "%s · Lv %d" % [cls_label, hero_data.level]
	_ai_badge.visible    = not is_player
	_player_tag.visible  = is_player
	if is_player:
		_apply_player_border()


func _apply_player_border() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	s.set_corner_radius_all(6)
	s.border_width_left   = 2
	s.border_width_top    = 2
	s.border_width_right  = 2
	s.border_width_bottom = 2
	s.border_color        = Color(0.28, 0.58, 1.0)
	s.content_margin_left   = 8.0
	s.content_margin_top    = 6.0
	s.content_margin_right  = 8.0
	s.content_margin_bottom = 6.0
	add_theme_stylebox_override("panel", s)


func update_hp(hp: float, hp_max: float) -> void:
	var pct := clampf((hp / hp_max) if hp_max > 0.0 else 0.0, 0.0, 1.0)
	_hp_fill.anchor_right = pct
	if   pct > 0.60: _hp_fill.color = Color(0.18, 0.76, 0.24)
	elif pct > 0.30: _hp_fill.color = Color(0.85, 0.60, 0.05)
	else:            _hp_fill.color = Color(0.80, 0.18, 0.12)


func update_moral(moral: float, moral_max: float) -> void:
	_moral_fill.anchor_right = clampf(
		(moral / moral_max) if moral_max > 0.0 else 0.0, 0.0, 1.0
	)


func update_buffs(active_buffs: Array) -> void:
	for child in _buffs_row.get_children():
		child.queue_free()
	for buff in active_buffs:
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = _buff_color(buff.get("stat", ""))
		_buffs_row.add_child(dot)


func _buff_color(stat: String) -> Color:
	match stat:
		"poison", "burn": return Color(0.80, 0.20, 0.85)
		"strength", "atk": return Color(1.0, 0.55, 0.10)
		"defense", "def":  return Color(0.22, 0.60, 1.0)
		"hot":             return Color(0.12, 0.85, 0.40)
		_:                 return Color(0.55, 0.55, 0.60)
