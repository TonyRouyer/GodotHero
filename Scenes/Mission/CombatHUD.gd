## CombatHUD.gd
## Logique du HUD de combat — les nœuds sont définis dans CombatHUD.tscn.
## Ce script gère uniquement les mises à jour dynamiques.
class_name CombatHUD
extends CanvasLayer

signal return_pressed

const HERO_CARD_SCENE : PackedScene = preload("res://Scenes/Mission/HeroCard.tscn")

## hero_node → HeroCard
var _hero_cards : Dictionary = {}
## hero_node → { sid → { overlay, cd_lbl, remaining } }
var _skill_slots : Dictionary = {}
## Référence au héros joueur pour les actions
var _player_node : Node = null
## Prochain slot à remplir (0-3)
var _next_slot : int = 0

@onready var _top_left      : PanelContainer  = $Root/TopLeft
@onready var _mission_title : Label           = $Root/TopLeft/VBox/MissionTitle
@onready var _mission_sub   : Label           = $Root/TopLeft/VBox/MissionSub
@onready var _hero_cards_hb : HBoxContainer   = $Root/BottomLeft/HeroCards
@onready var _bottom_center : PanelContainer  = $Root/BottomCenter
@onready var _actions_hdr   : Label           = $Root/BottomCenter/VBox/ActionsHeader
@onready var _log_scroll    : ScrollContainer = $Root/BottomRight/VBox/LogScroll
@onready var _log_container : VBoxContainer   = $Root/BottomRight/VBox/LogScroll/LogContainer
@onready var _end_panel     : PanelContainer  = $Root/EndPanel

## Slots d'action indexés
@onready var _comp_slots : Array[Node] = [
	$Root/BottomCenter/VBox/ActionsRow/SlotComp1,
	$Root/BottomCenter/VBox/ActionsRow/SlotComp2,
	$Root/BottomCenter/VBox/ActionsRow/SlotComp3,
	$Root/BottomCenter/VBox/ActionsRow/SlotComp4,
]
@onready var _obj_slots : Array[Node] = [
	$Root/BottomCenter/VBox/ActionsRow/SlotObj1,
	$Root/BottomCenter/VBox/ActionsRow/SlotObj2,
]

@onready var _btn_pause : Button = $Root/TopRight/BtnPause
@onready var _btn_play  : Button = $Root/TopRight/BtnPlay
@onready var _btn_fast  : Button = $Root/TopRight/BtnFast


func _ready() -> void:
	_btn_pause.pressed.connect(_on_pause)
	_btn_play.pressed.connect(_on_play)
	_btn_fast.pressed.connect(_on_fast)
	_top_left.hide()
	_bottom_center.hide()
	_preallocate_hero_slots()


func _preallocate_hero_slots() -> void:
	for i in 4:
		var card := HERO_CARD_SCENE.instantiate() as PanelContainer
		_hero_cards_hb.add_child(card)
		card.set_empty()


# ─────────────────────────────────────────────
#  CONFIGURATION INITIALE
# ─────────────────────────────────────────────

## Appelé par mission_scene pour chaque héros.
func add_hero_card(hero_node: Node2D, hero_data: HeroData, is_player: bool) -> void:
	if _next_slot >= 4:
		push_warning("CombatHUD: plus de 4 héros, slot ignoré.")
		return
	var card := _hero_cards_hb.get_child(_next_slot) as PanelContainer
	_next_slot += 1
	card.setup(hero_data, is_player)
	_hero_cards[hero_node] = card

	if is_player:
		_player_node = hero_node
		_setup_action_bar(hero_node, hero_data)


func _setup_action_bar(hero_node: Node, hero_data: HeroData) -> void:
	_bottom_center.show()
	_actions_hdr.text = "Actions — %s" % hero_data.hero_name

	## Associe les 4 slots de compétences aux skills équipés
	_skill_slots[hero_node] = {}
	for i in mini(4, hero_data.equipped_skills.size()):
		var sid   : String     = hero_data.equipped_skills[i]
		var sdata : Dictionary = SkillLibrary.get_skill(sid)
		var slot  : Node       = _comp_slots[i]
		slot.get_node("SlotLabel").text = sdata.get("label", sid).substr(0, 10)
		_skill_slots[hero_node][sid] = {
			"overlay":   slot.get_node("Box/Inner/Overlay"),
			"cd_lbl":    slot.get_node("Box/Inner/CdLabel"),
			"remaining": 0.0,
		}

	## Objets consommables
	var cons_id : String = hero_data.equipment.get("consumable", "")
	if cons_id != "":
		var qty : int = GuildInventoryManager.get_item_count(cons_id)
		var eq  : Dictionary = EquipmentLibrary.get_item(cons_id)
		_obj_slots[0].get_node("SlotLabel").text     = eq.get("label", cons_id).substr(0, 8)
		_obj_slots[0].get_node("Box/Inner/CountBadge").text = "×%d" % qty


## Mode full-IA : affiche le bloc info mission en haut-gauche.
func show_mission_info(mission_name: String) -> void:
	_top_left.show()
	_mission_title.text = mission_name


# ─────────────────────────────────────────────
#  MISES À JOUR DYNAMIQUES
# ─────────────────────────────────────────────

func update_hero_hp(hero_node: Node2D, hp: float, hp_max: float) -> void:
	if _hero_cards.has(hero_node):
		_hero_cards[hero_node].update_hp(hp, hp_max)


func update_hero_mana(_hero_node: Node2D, _mana: float, _mana_max: float) -> void:
	## La mana n'est pas affichée sur la carte héros dans ce layout.
	pass


func update_hero_buffs(hero_node: Node2D, buffs: Array) -> void:
	if _hero_cards.has(hero_node):
		_hero_cards[hero_node].update_buffs(buffs)


func update_skill_cooldown(hero_node: Node2D, skill_id: String, cooldown: float) -> void:
	if not _skill_slots.has(hero_node):
		return
	if not _skill_slots[hero_node].has(skill_id):
		return
	var entry : Dictionary = _skill_slots[hero_node][skill_id]
	entry["remaining"] = cooldown
	entry["overlay"].show()
	entry["cd_lbl"].show()
	entry["cd_lbl"].text = "%.0fs" % cooldown


func _process(delta: float) -> void:
	for hero_node in _skill_slots:
		for sid in _skill_slots[hero_node]:
			var entry : Dictionary = _skill_slots[hero_node][sid]
			if entry["remaining"] <= 0.0:
				continue
			entry["remaining"] = maxf(0.0, entry["remaining"] - delta)
			if entry["remaining"] <= 0.0:
				entry["overlay"].hide()
				entry["cd_lbl"].hide()
			else:
				entry["cd_lbl"].text = "%.0fs" % entry["remaining"]


func update_enemy_count(count: int) -> void:
	_mission_sub.text = "Ennemis restants : %d" % count


func log(message: String) -> void:
	var lbl := Label.new()
	lbl.text          = message
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
	_log_container.add_child(lbl)
	while _log_container.get_child_count() > 40:
		_log_container.get_child(0).queue_free()
	_log_scroll.call_deferred("set_v_scroll", 999999)


func log_damage(attacker: String, amount: int, is_crit: bool) -> void:
	var lbl := Label.new()
	lbl.text = "%s inflige %d%s" % [attacker, amount, " (Critique !)" if is_crit else ""]
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color",
		Color(1.0, 0.80, 0.20) if is_crit else Color(1.0, 0.42, 0.28)
	)
	_log_container.add_child(lbl)
	while _log_container.get_child_count() > 40:
		_log_container.get_child(0).queue_free()
	_log_scroll.call_deferred("set_v_scroll", 999999)


func log_kill(mob_label: String, xp: int) -> void:
	var lbl := Label.new()
	lbl.text = "%s vaincu · +%d XP" % [mob_label, xp]
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.50))
	_log_container.add_child(lbl)
	while _log_container.get_child_count() > 40:
		_log_container.get_child(0).queue_free()
	_log_scroll.call_deferred("set_v_scroll", 999999)


# ─────────────────────────────────────────────
#  CONTRÔLES TEMPS
# ─────────────────────────────────────────────

func _on_pause() -> void:
	get_tree().paused = not get_tree().paused


func _on_play() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


func _on_fast() -> void:
	get_tree().paused = false
	Engine.time_scale = 2.0


# ─────────────────────────────────────────────
#  ÉCRAN DE FIN
# ─────────────────────────────────────────────

func show_end_screen(victory: bool, gold: int, rep: int) -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
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
		rewards.add_theme_font_size_override("font_size", 14)
		rewards.add_theme_color_override("font_color", Color(0.90, 0.90, 0.90))
		vbox.add_child(rewards)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	var btn := Button.new()
	btn.text                  = "Retour à la guilde"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func() -> void: return_pressed.emit())
	vbox.add_child(btn)
