## guild_hud.gd
## Contrôleur du HUD de la GuildScene.
## Affiche gold, nourriture, réputation, heure, jour.
## Gère les boutons de vitesse et les onglets de panels.
extends Control


# ─────────────────────────────────────────────
#  LABELS
# ─────────────────────────────────────────────
@onready var gold_label       : Label  = %GoldLabel
@onready var food_label       : Label  = %FoodLabel
@onready var reputation_label : Label  = %ReputationLabel
@onready var time_label       : Label  = %TimeLabel
@onready var day_label        : Label  = %DayLabel

# Boutons vitesse
@onready var pause_btn  : Button = %PauseBtn
@onready var speed1_btn : Button = %Speed1Btn
@onready var speed2_btn : Button = %Speed2Btn
@onready var speed4_btn : Button = %Speed4Btn

# Onglets bas
@onready var heroes_tab_btn    : Button = %HeroesTabBtn
@onready var recruit_tab_btn   : Button = %RecruitTabBtn
@onready var build_tab_btn     : Button = %BuildTabBtn
@onready var research_tab_btn  : Button = %ResearchTabBtn
@onready var inventory_tab_btn : Button = %InventoryTabBtn

var _speed_buttons : Array[Button]
var _open_panel    : String = ""


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_speed_buttons = [pause_btn, speed1_btn, speed2_btn, speed4_btn]

	# Affichage initial
	_refresh_resources()
	_refresh_time(TimeManager.current_hour, TimeManager.current_minute)
	_highlight_speed(TimeManager.speed_index)

	# Connexions EventBus
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.food_changed.connect(_on_food_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.time_speed_changed.connect(_highlight_speed)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.ui_panel_open_requested.connect(_on_any_panel_opened)


func _exit_tree() -> void:
	if EventBus.gold_changed.is_connected(_on_gold_changed):
		EventBus.gold_changed.disconnect(_on_gold_changed)
	if EventBus.food_changed.is_connected(_on_food_changed):
		EventBus.food_changed.disconnect(_on_food_changed)
	if EventBus.reputation_changed.is_connected(_on_reputation_changed):
		EventBus.reputation_changed.disconnect(_on_reputation_changed)
	if EventBus.time_tick.is_connected(_on_time_tick):
		EventBus.time_tick.disconnect(_on_time_tick)
	if EventBus.day_changed.is_connected(_on_day_changed):
		EventBus.day_changed.disconnect(_on_day_changed)
	if EventBus.time_speed_changed.is_connected(_highlight_speed):
		EventBus.time_speed_changed.disconnect(_highlight_speed)
	if EventBus.game_paused.is_connected(_on_game_paused):
		EventBus.game_paused.disconnect(_on_game_paused)
	if EventBus.ui_panel_open_requested.is_connected(_on_any_panel_opened):
		EventBus.ui_panel_open_requested.disconnect(_on_any_panel_opened)


# ─────────────────────────────────────────────
#  RESSOURCES
# ─────────────────────────────────────────────
func _refresh_resources() -> void:
	gold_label.text       = "💰 %d" % GameData.gold
	food_label.text       = "🍖 %d" % GameData.food
	reputation_label.text = "⭐ %d" % GameData.reputation


func _on_gold_changed(new_value: int, _delta: int) -> void:
	gold_label.text = "💰 %d" % new_value


func _on_food_changed(new_value: int, _delta: int) -> void:
	food_label.text = "🍖 %d" % new_value


func _on_reputation_changed(new_value: int, _delta: int) -> void:
	reputation_label.text = "⭐ %d" % new_value


# ─────────────────────────────────────────────
#  TEMPS
# ─────────────────────────────────────────────
func _on_time_tick(hour: int, minute: int) -> void:
	_refresh_time(hour, minute)


func _on_day_changed(day: int) -> void:
	day_label.text = "Jour %d" % day


func _refresh_time(hour: int, minute: int) -> void:
	time_label.text = "%02d:%02d" % [hour, minute]


# ─────────────────────────────────────────────
#  BOUTONS VITESSE
# ─────────────────────────────────────────────
var _last_speed : int = 1


func _on_pause_btn_pressed()  -> void:
	if TimeManager.speed_index != 0:
		_last_speed = TimeManager.speed_index
	TimeManager.set_speed(0)
func _on_speed1_btn_pressed() -> void: _set_speed(1)
func _on_speed2_btn_pressed() -> void: _set_speed(2)
func _on_speed4_btn_pressed() -> void: _set_speed(3)


func _set_speed(index: int) -> void:
	_last_speed = index
	TimeManager.set_speed(index)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("one"):
		_set_speed(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("two"):
		_set_speed(2)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("three"):
		_set_speed(3)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("space"):
		if TimeManager.speed_index == 0:
			TimeManager.set_speed(_last_speed)
		else:
			_last_speed = TimeManager.speed_index
			TimeManager.set_speed(0)
		get_viewport().set_input_as_handled()


func _on_game_paused(is_paused: bool) -> void:
	## Quand la pause menu s'ouvre, on met le bouton pause en surbrillance
	if is_paused:
		_highlight_speed(-1)  # aucun bouton vitesse highlighted
	else:
		_highlight_speed(TimeManager.speed_index)


func _highlight_speed(index: int) -> void:
	for i in _speed_buttons.size():
		_speed_buttons[i].modulate = Color.WHITE if i != index else Color(0.4, 0.9, 0.4)


# ─────────────────────────────────────────────
#  ONGLETS PANELS
# ─────────────────────────────────────────────
func _on_any_panel_opened(panel_id: String, _payload: Dictionary) -> void:
	_open_panel = panel_id


func _toggle_panel(panel_id: String) -> void:
	if _open_panel == panel_id and UIState.menu_open:
		EventBus.ui_panel_open_requested.emit("", {})
	else:
		EventBus.ui_panel_open_requested.emit(panel_id, {})


func _on_heroes_tab_pressed()    -> void: _toggle_panel("hero_panel")
func _on_recruit_tab_pressed()   -> void: _toggle_panel("recruit_panel")
func _on_build_tab_pressed()     -> void: _toggle_panel("build_menu")
func _on_research_tab_pressed()  -> void: _toggle_panel("research_panel")
func _on_inventory_tab_pressed() -> void: _toggle_panel("inventory_panel")
func _on_map_tab_pressed()       -> void: _toggle_panel("market_panel")
func _on_quest_tab_pressed()     -> void: _toggle_panel("quest_panel")
func _on_craft_tab_pressed()     -> void: _toggle_panel("craft_panel")
