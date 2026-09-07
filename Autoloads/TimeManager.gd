## TimeManager — Autoload #4
## Horloge du jeu. Gère le temps, la vitesse et la pause.
## Émet ses signaux via EventBus pour que tout le projet soit synchronisé.
extends Node

# ─────────────────────────────────────────────
#  ÉTAT
# ─────────────────────────────────────────────
var current_minute: int = 0
var current_hour:   int = 7    # on commence à 7h du matin
var current_day:    int = 1

var speed_index: int = 1       # index dans GameConfig.TIME_SPEEDS
var is_paused:   bool = false

var _tick_accumulator: float = 0.0

var _was_daytime: bool = true  



# ─────────────────────────────────────────────
#  GETTERS PRATIQUES
# ─────────────────────────────────────────────
var current_speed: float:
	get: return 0.0 if is_paused else GameConfig.TIME_SPEEDS[speed_index]

var is_daytime: bool:
	get: return current_hour >= 6 and current_hour < 22

var time_string: String:
	get: return "%02d:%02d" % [current_hour, current_minute]

var day_string: String:
	get: return "Jour %d" % current_day


func get_sky_color() -> Color:
	var keys: Array = GameConfig.DAY_CYCLE_COLORS.keys()
	keys.sort()
	var h_from  = keys[0]
	var h_to   = keys[0]
	for i in keys.size():
		if keys[i] <= current_hour:
			h_from = keys[i]
		if keys[i] > current_hour:
			h_to = keys[i]
			break
		else:
			h_to = keys[0]  
	var t :float = (current_minute) / 60.0
	return GameConfig.DAY_CYCLE_COLORS[h_from].lerp(
		GameConfig.DAY_CYCLE_COLORS[h_to], t
	)
	
# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if is_paused or current_speed == 0.0:
		return

	_tick_accumulator += delta * current_speed

	var tick_duration = GameConfig.SECONDS_PER_TICK
	while _tick_accumulator >= tick_duration:
		_tick_accumulator -= tick_duration
		_advance_time()


func _advance_time() -> void:
	current_minute += GameConfig.MINUTES_PER_TICK

	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		EventBus.hour_changed.emit(current_hour)
		
		# ── détection passage jour/nuit ──────────────────
		if is_daytime != _was_daytime:
			_was_daytime = is_daytime
			EventBus.day_night_changed.emit(is_daytime)

		if current_hour >= GameConfig.HOURS_PER_DAY:
			current_hour = 0
			current_day += 1
			GameData.current_day = current_day
			EventBus.day_changed.emit(current_day)

	EventBus.time_tick.emit(current_hour, current_minute)


# ─────────────────────────────────────────────
#  CONTRÔLE
# ─────────────────────────────────────────────
func set_speed(index: int) -> void:
	index = clamp(index, 0, GameConfig.TIME_SPEEDS.size() - 1)
	speed_index = index
	EventBus.time_speed_changed.emit(speed_index)


func pause() -> void:
	is_paused = true
	GameData.is_paused = true
	EventBus.game_paused.emit(true)


func unpause() -> void:
	is_paused = false
	GameData.is_paused = false
	EventBus.game_paused.emit(false)


func toggle_pause() -> void:
	if is_paused:
		unpause()
	else:
		pause()


func speed_up() -> void:
	set_speed(speed_index + 1)


func speed_down() -> void:
	set_speed(speed_index - 1)


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	return {
		"minute": current_minute,
		"hour":   current_hour,
		"day":    current_day,
		"speed":  speed_index,
	}


func deserialize(data: Dictionary) -> void:
	current_minute = data.get("minute", 0)
	current_hour   = data.get("hour",   7)
	current_day    = data.get("day",    1)
	speed_index    = data.get("speed",  1)
	is_paused      = false
	_tick_accumulator = 0.0
