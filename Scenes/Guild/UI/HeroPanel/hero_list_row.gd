## hero_list_row.gd
## Une ligne dans la liste des héros.
## Affiche : rang, nom, classe, niveau, HP/100, Moral/100, bouton focus, bouton renvoyer.
extends PanelContainer


# ─────────────────────────────────────────────
#  NŒUDS
# ─────────────────────────────────────────────
@onready var rank_label  : Label  = %RankLabel
@onready var name_label  : Label  = %NameLabel
@onready var class_label : Label  = %ClassLabel
@onready var lvl_label   : Label  = %LvlLabel
@onready var hp_label    : Label  = %HpLabel
@onready var moral_label : Label  = %MoralLabel
@onready var focus_btn   : Button = %FocusBtn
@onready var fire_btn    : Button = %FireBtn


# ─────────────────────────────────────────────
#  DONNÉES
# ─────────────────────────────────────────────
var _data : HeroData = null


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func setup(hero_data: HeroData) -> void:
	_data = hero_data
	refresh()

	## Bouton "Détail" : ouvre HeroInspectPanel centré sur l'écran
	var inspect_btn := Button.new()
	inspect_btn.text = "Détail"
	inspect_btn.add_theme_font_size_override("font_size", 9)
	inspect_btn.pressed.connect(_on_inspect_pressed)
	var hbox : HBoxContainer = fire_btn.get_parent()
	hbox.add_child(inspect_btn)
	hbox.move_child(inspect_btn, fire_btn.get_index())

	## Se met à jour quand les stats changent
	EventBus.hero_stat_changed.connect(_on_stat_changed)
	EventBus.hero_need_changed.connect(_on_need_changed)


func _exit_tree() -> void:
	if EventBus.hero_stat_changed.is_connected(_on_stat_changed):
		EventBus.hero_stat_changed.disconnect(_on_stat_changed)
	if EventBus.hero_need_changed.is_connected(_on_need_changed):
		EventBus.hero_need_changed.disconnect(_on_need_changed)


func refresh() -> void:
	if not _data:
		return

	rank_label.text  = _data.rank
	name_label.text  = _data.hero_name
	class_label.text = _data.hero_class.capitalize()
	lvl_label.text   = "L%d" % _data.level
	hp_label.text    = "Hp : %d/100" % int(_data.hp)
	moral_label.text = "Moral : %d/100" % int(_data.moral)


# ─────────────────────────────────────────────
#  BOUTONS
# ─────────────────────────────────────────────
func _on_inspect_pressed() -> void:
	## Vector2(-1,-1) = sentinel → HeroInspectPanel se centre sur l'écran
	EventBus.hero_inspect_requested.emit(_data, Vector2(-1.0, -1.0))


func _on_focus_pressed() -> void:
	var hero_node = HeroManager.get_hero_node(_data.hero_id)
	if hero_node:
		EventBus.camera_focus_requested.emit(hero_node.global_position)


func _on_fire_pressed() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Renvoyer le héros"
	dialog.dialog_text = "Renvoyer %s de la guilde ?\nCette action est irréversible." % _data.hero_name
	dialog.confirmed.connect(_confirm_fire)
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered()


func _confirm_fire() -> void:
	HeroManager.fire_hero(_data.hero_id)


# ─────────────────────────────────────────────
#  MISE À JOUR TEMPS RÉEL
# ─────────────────────────────────────────────
func _on_stat_changed(hero_id: int, stat_name: String, new_value: float) -> void:
	if hero_id != _data.hero_id:
		return
	match stat_name:
		"hp":
			hp_label.text = "Hp : %d/100" % int(new_value)


func _on_need_changed(hero_id: int, need_name: String, new_value: float) -> void:
	if hero_id != _data.hero_id:
		return
	if need_name == "moral":
		moral_label.text = "Moral : %d/100" % int(new_value)
