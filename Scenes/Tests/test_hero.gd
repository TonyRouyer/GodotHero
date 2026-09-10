## test_hero.gd
## Scène de test autonome — Routines IA et besoins des héros.
## Lancer depuis l'éditeur : F6 sur cette scène.
##
## Ce que ça teste :
##   - Décroissance des 5 besoins (faim, énergie, divertissement, vessie, hygiène)
##   - Calcul du moral en temps réel
##   - Système de routine (think tree) → activité affichée
##   - Paiement du salaire + démission si impayé / moral trop bas
##
## Note : sans objets placés (lit, nourriture, sanitaires), le héros reste en idle/wander.
## C'est normal — les besoins décroissent quand même et le moral réagit.
extends Node2D


# ─────────────────────────────────────────────
#  CONSTANTES
# ─────────────────────────────────────────────
const HERO_SCENE          := preload("res://Entities/Hero/Hero.tscn")
const GUILD_CAMERA_SCRIPT := preload("res://Scenes/Guild/guild_camera.gd")
const PLANNING_ROW_SCENE  := preload("res://Scenes/Guild/UI/HeroPanel/PlanningRow.tscn")

const NEED_LABELS : Dictionary = {
	"hunger":        "Faim",
	"energy":        "Énergie",
	"entertainment": "Divertissement",
	"toilet":        "Vessie",
	"hygiene":       "Hygiène",
}

const JOB_LABELS : Dictionary = {
	0: "Libre",
	1: "Accueil",
	2: "Forgeron",
	3: "Alchimiste",
	4: "Chercheur",
	5: "Cuisinier",
}

const ACTIVITY_COLORS := {
	"sleep": Color(0.20, 0.30, 0.70),
	"work":  Color(0.80, 0.55, 0.10),
	"train": Color(0.15, 0.60, 0.25),
	"free":  Color(0.40, 0.40, 0.45),
}

const NEED_COLOR_OK   := Color(0.35, 0.85, 0.45)
const NEED_COLOR_WARN := Color(1.00, 0.60, 0.10)
const NEED_COLOR_CRIT := Color(0.90, 0.20, 0.20)


# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var _hero : Hero     = null
var _data : HeroData = null

var _heroes_container  : Node2D = null
var _objects_container : Node2D = null

## Planning
var _selected_activity : String = "work"
var _selected_preset   : String = ""
var _planning_row      : Node   = null
var _act_btn_map       : Dictionary = {}   ## activity → Button

## Job
var _job_option : OptionButton = null


# ─────────────────────────────────────────────
#  REFS UI
# ─────────────────────────────────────────────
var _need_bars  : Dictionary = {}   ## need_id → ProgressBar
var _need_vals  : Dictionary = {}   ## need_id → Label
var _moral_bar  : ProgressBar = null
var _moral_val  : Label       = null
var _task_lbl   : Label       = null
var _hero_lbl   : Label       = null
var _time_lbl   : Label       = null
var _day_lbl    : Label       = null
var _log_vbox   : VBoxContainer = null
var _log_lines  : Array[String] = []


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_setup_containers()
	_setup_navigation()
	_spawn_objects()
	_setup_camera()
	_setup_ui()
	_spawn_hero()
	_connect_signals()
	TimeManager.unpause()
	TimeManager.set_speed(1)


func _exit_tree() -> void:
	WorldContext.clear()
	HeroManager.clear()


# ─────────────────────────────────────────────
#  SETUP CONTENEURS
## Reproduit Main → SceneContainer → TestHero → World → Heroes
## pour que HeroManager._get_heroes_container() trouve le bon nœud.
# ─────────────────────────────────────────────
func _setup_containers() -> void:
	var scene_ctr := Node2D.new()
	scene_ctr.name = "SceneContainer"
	add_child(scene_ctr)

	var test_node := Node2D.new()
	test_node.name = "TestHero"
	scene_ctr.add_child(test_node)

	var world := Node2D.new()
	world.name = "World"
	test_node.add_child(world)

	_heroes_container = Node2D.new()
	_heroes_container.name = "Heroes"
	world.add_child(_heroes_container)

	_objects_container = Node2D.new()
	_objects_container.name = "Objects"
	world.add_child(_objects_container)

	WorldContext.setup(_objects_container, _heroes_container)


# ─────────────────────────────────────────────
#  SETUP NAVIGATION
## Zone de navigation couvrant toute la fenêtre (1200×800).
## Sans ça, NavigationAgent2D du héros émet des warnings.
# ─────────────────────────────────────────────
func _setup_navigation() -> void:
	var nav  := NavigationRegion2D.new()
	var poly := NavigationPolygon.new()
	poly.agent_radius = 8.0
	poly.add_outline(PackedVector2Array([
		Vector2(300, 100), Vector2(1000, 100), Vector2(1000, 700), Vector2(300, 700)
	]))
	poly.make_polygons_from_outlines()
	nav.navigation_polygon = poly
	add_child(nav)
	nav.bake_navigation_polygon()


# ─────────────────────────────────────────────
#  CAMÉRA
## Réutilise guild_camera.gd (zoom molette, pan clavier, clic-drag bouton milieu).
# ─────────────────────────────────────────────
func _setup_camera() -> void:
	var cam : Camera2D = GUILD_CAMERA_SCRIPT.new()
	cam.name      = "GuildCamera"
	cam.map_min   = Vector2(300, 100)
	cam.map_max   = Vector2(900, 700)
	cam.zoom      = Vector2(2, 2)
	cam.position  = Vector2(600, 420)
	add_child(cam)


# ─────────────────────────────────────────────
#  SPAWN OBJETS
## Instancie les objets minimum pour que les routines fonctionnent.
## ObjectFinder cherche dans WorldContext.objects_container (= _objects_container).
# ─────────────────────────────────────────────
func _spawn_objects() -> void:
	var defs : Array = [
		## ── Besoins de base ──────────────────────────────────────────────────
		["res://Entities/Objects/Bed/bed.tscn",                    Vector2(400, 300)],
		["res://Entities/Objects/ServingTable/serving_table.tscn", Vector2(448, 300)],
		["res://Entities/Objects/Toilet/toilet.tscn",              Vector2(400, 400)],
		["res://Entities/Objects/Sink/sink.tscn",                  Vector2(432, 400)],
		["res://Entities/Objects/Luth/luth.tscn",                  Vector2(400, 500)],
		## ── Objets de travail (job 2 — Forgeron) ─────────────────────────────
		["res://Entities/Objects/Forge/forge.tscn",                Vector2(560, 300)],
		["res://Entities/Objects/WorkbenchCraft/workbench_craft.tscn", Vector2(608, 300)],
		["res://Entities/Objects/TanningRack/tanning_rack.tscn",   Vector2(656, 300)],
		["res://Entities/Objects/Loom/loom.tscn",                  Vector2(688, 300)],
		## ── Objets de travail (job 3 — Alchimiste) ───────────────────────────
		["res://Entities/Objects/AlchemyTable/alchemy_table.tscn", Vector2(560, 400)],
		["res://Entities/Objects/MagicCauldron/magic_cauldron.tscn", Vector2(608, 400)],
		## ── Objets de travail (autres jobs) ──────────────────────────────────
		["res://Entities/Objects/ReceptionDesk/reception_desk.tscn", Vector2(560, 500)],
		["res://Entities/Objects/ResearchDesk/research_desk.tscn",   Vector2(640, 500)],
		["res://Entities/Objects/Furnace/furnace.tscn",              Vector2(688, 500)],
	]
	for def in defs:
		var path : String  = def[0]
		var pos  : Vector2 = def[1]
		if not ResourceLoader.exists(path):
			_spawn_placeholder(pos, path.get_file().get_basename())
			continue
		var instance : Node2D = (load(path) as PackedScene).instantiate()
		instance.position = pos
		_objects_container.add_child(instance)


func _spawn_placeholder(pos: Vector2, label_text: String) -> void:
	var node := Node2D.new()
	node.position = pos
	_objects_container.add_child(node)

	var rect := ColorRect.new()
	rect.color = Color(0.55, 0.20, 0.55, 0.80)
	rect.size  = Vector2(32, 32)
	node.add_child(rect)

	var lbl := Label.new()
	lbl.text = label_text.replace("_", "\n")
	lbl.position = Vector2(0, 34)
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.modulate = Color(1, 1, 1)
	node.add_child(lbl)


# ─────────────────────────────────────────────
#  SPAWN HÉROS
# ─────────────────────────────────────────────
func _spawn_hero() -> void:
	_data = HeroGenerator.generate()
	_data.apply_default_planning()
	_hero = HeroManager.spawn_hero(_data, Vector2(650, 420))

	if _hero == null:
		_log("ERREUR : impossible de spawner le héros")
		return

	_hero_lbl.text = "%s  ·  %s  ·  Niv.%d" % [
		_data.hero_name,
		_data.hero_class.capitalize(),
		_data.level,
	]
	_log("Héros spawné : %s (%s)" % [_data.hero_name, _data.hero_class])
	_refresh_needs()
	_refresh_job_ui()

	## Planning row
	if _planning_row and _planning_row.has_method("setup"):
		_planning_row.setup(_data, self)


# ─────────────────────────────────────────────
#  SIGNAUX
# ─────────────────────────────────────────────
func _connect_signals() -> void:
	EventBus.time_tick.connect(_on_tick)
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.hero_need_changed.connect(_on_need_changed)
	EventBus.hero_task_changed.connect(_on_task_changed)
	EventBus.hero_fired.connect(_on_hero_fired)


func _on_tick(hour: int, minute: int) -> void:
	_time_lbl.text = "%02d:%02d" % [hour, minute]
	if _data:
		_moral_bar.value = _data.moral
		_moral_val.text  = "%d" % int(_data.moral)
		_moral_bar.modulate = _need_color(_data.moral)
	if _planning_row and _planning_row.has_method("highlight_current_hour"):
		_planning_row.highlight_current_hour(hour)


func _on_day_changed(day: int) -> void:
	_day_lbl.text = "Jour %d" % day
	_log("── Jour %d ──  Or guilde : %d" % [day, GameData.gold])


func _on_need_changed(hero_id: int, need_name: String, value: float) -> void:
	if _data == null or hero_id != _data.hero_id:
		return
	if not _need_bars.has(need_name):
		return
	(_need_bars[need_name] as ProgressBar).value    = value
	(_need_bars[need_name] as ProgressBar).modulate = _need_color(value)
	(_need_vals[need_name] as Label).text           = "%d" % int(value)

	## Log si franchissement d'un seuil critique
	if value <= 5.0:
		_log("⚠ %s à %d" % [NEED_LABELS.get(need_name, need_name), int(value)])


func _on_task_changed(hero_id: int, task_text: String) -> void:
	if _data and hero_id == _data.hero_id:
		_task_lbl.text = task_text


func _on_hero_fired(hero_id: int) -> void:
	if _data == null or hero_id != _data.hero_id:
		return
	_task_lbl.text    = "DÉMISSIONNÉ"
	_task_lbl.add_theme_color_override("font_color", Color.RED)
	_hero = null
	_log("⚠ %s a démissionné !" % _data.hero_name)


# ─────────────────────────────────────────────
#  REFRESH INITIAL (avant les signaux du 1er tick)
# ─────────────────────────────────────────────
func _refresh_needs() -> void:
	if _data == null:
		return
	for need_id in NEED_LABELS:
		var val : float = _data.get(need_id)
		(_need_bars[need_id] as ProgressBar).value    = val
		(_need_bars[need_id] as ProgressBar).modulate = _need_color(val)
		(_need_vals[need_id] as Label).text           = "%d" % int(val)
	_moral_bar.value = _data.moral
	_moral_val.text  = "%d" % int(_data.moral)


# ─────────────────────────────────────────────
#  ACTIONS BOUTONS
# ─────────────────────────────────────────────
func _drain_hunger()        -> void: _set_need("hunger",        5.0)
func _drain_energy()        -> void: _set_need("energy",        5.0)
func _drain_entertainment() -> void: _set_need("entertainment", 5.0)
func _drain_toilet()        -> void: _set_need("toilet",        5.0)
func _drain_hygiene()       -> void: _set_need("hygiene",       5.0)

func _set_need(need: String, value: float) -> void:
	if _data == null: return
	_data.set(need, value)
	_log("→ %s forcé à %d" % [NEED_LABELS.get(need, need), int(value)])

func _fill_all() -> void:
	if _data == null: return
	for need in NEED_LABELS:
		_data.set(need, 100.0)
	_refresh_needs()
	_log("Tous les besoins remplis")

func _pay_salary() -> void:
	GameData.add_gold(500)
	_log("Or +500  (total : %d)" % GameData.gold)

func _drain_gold() -> void:
	GameData.gold = 0
	EventBus.gold_changed.emit(0, 0)
	_log("Or mis à 0 — salaire dû au prochain jour")

func _set_speed_0() -> void: TimeManager.set_speed(0)
func _set_speed_1() -> void: TimeManager.set_speed(1)
func _set_speed_2() -> void: TimeManager.set_speed(2)
func _set_speed_4() -> void: TimeManager.set_speed(3)

func _on_job_selected(idx: int) -> void:
	if _data == null:
		return
	_data.job = _job_option.get_item_id(idx)
	_log("Métier → %s" % JOB_LABELS.get(_data.job, "?"))


# ─────────────────────────────────────────────
#  PLANNING — interface requise par planning_row.gd
# ─────────────────────────────────────────────
func get_selected_activity() -> String: return _selected_activity
func get_selected_preset()   -> String: return _selected_preset


func _apply_preset_to_hero(_hero_id: int) -> void:
	if _selected_preset == "" or _data == null:
		return
	_data.planning = _build_preset(_selected_preset)
	if _planning_row and _planning_row.has_method("refresh"):
		_planning_row.refresh()


func _build_preset(preset_id: String) -> Dictionary:
	var p : Dictionary = {}
	match preset_id:
		"morning":
			for h in range(24):
				if h < 6:    p[h] = "sleep"
				elif h < 8:  p[h] = "free"
				elif h < 12: p[h] = "work"
				elif h < 13: p[h] = "free"
				elif h < 18: p[h] = "work"
				elif h < 22: p[h] = "free"
				else:        p[h] = "sleep"
		"night":
			for h in range(24):
				if h < 4:    p[h] = "work"
				elif h < 10: p[h] = "sleep"
				elif h < 22: p[h] = "free"
				else:        p[h] = "work"
		"training":
			for h in range(24):
				if h < 6:    p[h] = "sleep"
				elif h < 20: p[h] = "train"
				else:        p[h] = "free"
		"free_day":
			for h in range(24):
				p[h] = "sleep" if h < 8 else "free"
	return p


func _select_activity_planning(act: String) -> void:
	_selected_activity = act
	_selected_preset   = ""
	_refresh_activity_btns()


func _select_preset_planning(preset_id: String) -> void:
	_selected_preset   = "" if _selected_preset == preset_id else preset_id
	_selected_activity = ""
	_refresh_activity_btns()


func _refresh_activity_btns() -> void:
	for act in _act_btn_map:
		var btn : Button = _act_btn_map[act]
		var color : Color = ACTIVITY_COLORS.get(act, Color.GRAY)
		var active : bool = (act == _selected_activity)
		var style := StyleBoxFlat.new()
		style.bg_color = color if active else color.darkened(0.45)
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", Color.WHITE)


func _refresh_job_ui() -> void:
	if _data == null or _job_option == null:
		return
	for i in _job_option.item_count:
		if _job_option.get_item_id(i) == _data.job:
			_job_option.select(i)
			break

func _respawn_hero() -> void:
	if _hero and is_instance_valid(_hero):
		HeroManager.fire_hero(_data.hero_id)
	_hero = null
	_data = null
	_task_lbl.text = "—"
	_task_lbl.remove_theme_color_override("font_color")
	_hero_lbl.text = "—"
	_spawn_hero()
	## La planning row est re-setup dans _spawn_hero


# ─────────────────────────────────────────────
#  LOG
# ─────────────────────────────────────────────
func _log(msg: String) -> void:
	var entry := "[%02d:%02d] %s" % [TimeManager.current_hour, TimeManager.current_minute, msg]
	_log_lines.push_front(entry)
	if _log_lines.size() > 40:
		_log_lines.resize(40)

	for child in _log_vbox.get_children():
		child.queue_free()

	for line in _log_lines:
		var lbl := Label.new()
		lbl.text = line
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.modulate = Color(0.75, 0.75, 0.75)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_log_vbox.add_child(lbl)


# ─────────────────────────────────────────────
#  HELPER COULEUR
# ─────────────────────────────────────────────
func _need_color(value: float) -> Color:
	if value < 20.0: return NEED_COLOR_CRIT
	if value < 40.0: return NEED_COLOR_WARN
	return NEED_COLOR_OK


# ─────────────────────────────────────────────
#  CONSTRUCTION UI
# ─────────────────────────────────────────────
func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	## ── PANEL GAUCHE : infos + besoins + boutons ──
	var left := PanelContainer.new()
	left.position = Vector2(10, 10)
	left.custom_minimum_size = Vector2(310, 0)
	root.add_child(left)

	var lm := MarginContainer.new()
	for s in ["left","right","top","bottom"]:
		lm.add_theme_constant_override("margin_" + s, 10)
	left.add_child(lm)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 7)
	lm.add_child(col)

	## Titre
	_add_label(col, "Test — Héros & Besoins", 14)

	## Heure / Jour
	var time_row := HBoxContainer.new()
	col.add_child(time_row)
	_time_lbl = _add_label(time_row, "00:00", 12, true)
	_day_lbl  = _add_label(time_row, "Jour 1", 12)

	col.add_child(HSeparator.new())

	## Identité héros
	_add_label(col, "Héros", 10, false, Color(0.6, 0.6, 0.6))
	_hero_lbl = _add_label(col, "—", 11)

	## Métier
	_add_label(col, "Métier", 10, false, Color(0.6, 0.6, 0.6))
	_job_option = OptionButton.new()
	_job_option.add_theme_font_size_override("font_size", 10)
	_job_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for job_id in JOB_LABELS:
		_job_option.add_item(JOB_LABELS[job_id], job_id)
	_job_option.item_selected.connect(_on_job_selected)
	col.add_child(_job_option)

	## Activité
	_add_label(col, "Activité courante", 10, false, Color(0.6, 0.6, 0.6))
	_task_lbl = _add_label(col, "—", 11, false, Color(0.4, 0.9, 0.6))

	col.add_child(HSeparator.new())

	## Besoins
	_add_label(col, "Besoins", 11)
	for need_id in NEED_LABELS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		col.add_child(row)

		var name_lbl := Label.new()
		name_lbl.text = NEED_LABELS[need_id]
		name_lbl.custom_minimum_size = Vector2(115, 0)
		name_lbl.add_theme_font_size_override("font_size", 10)
		row.add_child(name_lbl)

		var bar := ProgressBar.new()
		bar.max_value = 100
		bar.value     = 100
		bar.custom_minimum_size = Vector2(120, 14)
		bar.show_percentage = false
		bar.modulate = NEED_COLOR_OK
		row.add_child(bar)

		var val := Label.new()
		val.text = "100"
		val.custom_minimum_size = Vector2(28, 0)
		val.add_theme_font_size_override("font_size", 10)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val)

		_need_bars[need_id] = bar
		_need_vals[need_id] = val

	## Moral
	col.add_child(HSeparator.new())
	_add_label(col, "Moral", 11)
	var mor_row := HBoxContainer.new()
	mor_row.add_theme_constant_override("separation", 6)
	col.add_child(mor_row)

	var mor_name := Label.new()
	mor_name.text = "Moral"
	mor_name.custom_minimum_size = Vector2(115, 0)
	mor_name.add_theme_font_size_override("font_size", 10)
	mor_row.add_child(mor_name)

	_moral_bar = ProgressBar.new()
	_moral_bar.max_value = 100
	_moral_bar.value     = 100
	_moral_bar.custom_minimum_size = Vector2(120, 14)
	_moral_bar.show_percentage = false
	_moral_bar.modulate = NEED_COLOR_OK
	mor_row.add_child(_moral_bar)

	_moral_val = Label.new()
	_moral_val.text = "100"
	_moral_val.custom_minimum_size = Vector2(28, 0)
	_moral_val.add_theme_font_size_override("font_size", 10)
	_moral_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mor_row.add_child(_moral_val)

	col.add_child(HSeparator.new())

	## Vitesse
	_add_label(col, "Vitesse", 10, false, Color(0.6, 0.6, 0.6))
	var spd := HBoxContainer.new()
	spd.add_theme_constant_override("separation", 4)
	col.add_child(spd)
	_btn(spd, "Pause", _set_speed_0)
	_btn(spd, "×1",   _set_speed_1)
	_btn(spd, "×2",   _set_speed_2)
	_btn(spd, "×4",   _set_speed_4)

	col.add_child(HSeparator.new())

	## Manipulation besoins
	_add_label(col, "Vider un besoin (→ 5)", 10, false, Color(0.6, 0.6, 0.6))
	var d1 := HBoxContainer.new(); d1.add_theme_constant_override("separation", 4); col.add_child(d1)
	_btn(d1, "Faim",   _drain_hunger)
	_btn(d1, "Énergie", _drain_energy)
	_btn(d1, "Diverti.", _drain_entertainment)
	var d2 := HBoxContainer.new(); d2.add_theme_constant_override("separation", 4); col.add_child(d2)
	_btn(d2, "Vessie",  _drain_toilet)
	_btn(d2, "Hygiène", _drain_hygiene)

	col.add_child(HSeparator.new())

	_btn(col, "Remplir tout",              _fill_all)
	_btn(col, "Payer salaire  (+500 or)",  _pay_salary)
	_btn(col, "Vider l'or  (salaire dû)",  _drain_gold)
	_btn(col, "Nouveau héros",             _respawn_hero)

	## ── PANEL DROIT : log événements ──
	var right := PanelContainer.new()
	right.anchor_left  = 1.0
	right.anchor_right = 1.0
	right.offset_left  = -310.0
	right.offset_right = 0.0
	right.position.y   = 10.0
	right.custom_minimum_size = Vector2(300, 0)
	root.add_child(right)

	var rm := MarginContainer.new()
	for s in ["left","right","top","bottom"]:
		rm.add_theme_constant_override("margin_" + s, 10)
	right.add_child(rm)

	var rcol := VBoxContainer.new()
	rcol.add_theme_constant_override("separation", 6)
	rm.add_child(rcol)

	_add_label(rcol, "Événements", 12)
	rcol.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 500)
	rcol.add_child(scroll)

	_log_vbox = VBoxContainer.new()
	_log_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_vbox.add_theme_constant_override("separation", 2)
	scroll.add_child(_log_vbox)

	## ── PANEL PLANNING (bas de l'écran) ──────────────────────────────────────
	var plan_panel := PanelContainer.new()
	plan_panel.anchor_left   = 0.0
	plan_panel.anchor_right  = 1.0
	plan_panel.anchor_top    = 1.0
	plan_panel.anchor_bottom = 1.0
	plan_panel.offset_top    = -110.0
	plan_panel.offset_bottom = -8.0
	plan_panel.offset_left   = 8.0
	plan_panel.offset_right  = -8.0
	root.add_child(plan_panel)

	var pm := MarginContainer.new()
	for s in ["left","right","top","bottom"]:
		pm.add_theme_constant_override("margin_" + s, 6)
	plan_panel.add_child(pm)

	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 4)
	pm.add_child(pv)

	## Ligne 1 : activités + préréglages
	var act_row := HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 6)
	pv.add_child(act_row)

	_add_label(act_row, "Activité :", 10)
	for act in ["sleep", "work", "train", "free"]:
		var lbl_map := {"sleep": "Sommeil", "work": "Travail", "train": "Entraîn.", "free": "Libre"}
		var b := Button.new()
		b.text = lbl_map[act]
		b.add_theme_font_size_override("font_size", 10)
		b.custom_minimum_size = Vector2(70, 0)
		b.pressed.connect(_select_activity_planning.bind(act))
		act_row.add_child(b)
		_act_btn_map[act] = b

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	act_row.add_child(spacer)

	_add_label(act_row, "Préréglage :", 10)
	var preset_defs := [["Matin","morning"],["Nuit","night"],["Entraîn.","training"],["Jour libre","free_day"]]
	for pd in preset_defs:
		var b := Button.new()
		b.text = pd[0]
		b.add_theme_font_size_override("font_size", 10)
		b.pressed.connect(_select_preset_planning.bind(pd[1]))
		act_row.add_child(b)

	## Ligne 2 : planning row du héros
	_planning_row = PLANNING_ROW_SCENE.instantiate()
	pv.add_child(_planning_row)
	## setup() est appelé dans _spawn_hero après que _data est prêt

	_refresh_activity_btns()


# ─────────────────────────────────────────────
#  HELPERS UI
# ─────────────────────────────────────────────
func _add_label(parent: Node, text: String, size: int = 10,
				expand: bool = false, color: Color = Color.WHITE) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	if color != Color.WHITE:
		lbl.add_theme_color_override("font_color", color)
	if expand:
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(lbl)
	return lbl


func _btn(parent: Node, text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 10)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(cb)
	parent.add_child(btn)
	return btn
