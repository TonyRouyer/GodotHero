## AudioManager — Autoload
## Gère la musique de fond et les effets sonores.
## Utilise deux AudioStreamPlayer internes pour crossfader la musique.
## Les buses "Music" et "SFX" doivent exister dans Project > Audio Buses.
extends Node


# ─────────────────────────────────────────────
#  NODES AUDIO INTERNES
# ─────────────────────────────────────────────
var _music_player_a      : AudioStreamPlayer
var _music_player_b      : AudioStreamPlayer
var _active_music_player : AudioStreamPlayer
var _sfx_pool            : Array[AudioStreamPlayer] = []

const SFX_POOL_SIZE := 8


# ─────────────────────────────────────────────
#  VOLUMES (0.0 – 1.0)
# ─────────────────────────────────────────────
var volume_master : float = GameConfig.VOLUME_MASTER_DEFAULT:
	set(v):
		volume_master = clamp(v, 0.0, 1.0)
		_apply_volumes()

var volume_music : float = GameConfig.VOLUME_MUSIC_DEFAULT:
	set(v):
		volume_music = clamp(v, 0.0, 1.0)
		_apply_volumes()

var volume_sfx : float = GameConfig.VOLUME_SFX_DEFAULT:
	set(v):
		volume_sfx = clamp(v, 0.0, 1.0)
		_apply_volumes()


# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_b = AudioStreamPlayer.new()
	_music_player_a.bus = "Music"
	_music_player_b.bus = "Music"
	add_child(_music_player_a)
	add_child(_music_player_b)
	_active_music_player = _music_player_a

	for i in SFX_POOL_SIZE:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)

	EventBus.scene_loaded.connect(_on_scene_loaded)


func _exit_tree() -> void:
	if EventBus.scene_loaded.is_connected(_on_scene_loaded):
		EventBus.scene_loaded.disconnect(_on_scene_loaded)


# ─────────────────────────────────────────────
#  MUSIQUE
# ─────────────────────────────────────────────
func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if stream == null:
		stop_music()
		return

	if _active_music_player.stream == stream and _active_music_player.playing:
		return

	## Force le loop selon le type de stream
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	if fade_duration > 0.0 and _active_music_player.playing:
		_crossfade(stream, fade_duration)
	else:
		_active_music_player.volume_db = _db_from_linear(volume_music * volume_master)
		_active_music_player.stream = stream
		_active_music_player.play()


func stop_music(fade_duration: float = 0.5) -> void:
	if fade_duration > 0.0:
		var tween = create_tween()
		tween.tween_property(_active_music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_active_music_player.stop)
	else:
		_active_music_player.stop()


func _crossfade(new_stream: AudioStream, duration: float) -> void:
	var next = _music_player_b if _active_music_player == _music_player_a else _music_player_a
	next.stream = new_stream
	next.volume_db = -80.0
	next.play()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_active_music_player, "volume_db", -80.0, duration)
	tween.tween_property(next, "volume_db", _db_from_linear(volume_music * volume_master), duration)
	tween.tween_callback(_active_music_player.stop).set_delay(duration)

	_active_music_player = next


# ─────────────────────────────────────────────
#  EFFETS SONORES
# ─────────────────────────────────────────────
func play_sfx(stream: AudioStream, pitch: float = 1.0) -> void:
	if stream == null:
		return
	var player = _get_free_sfx_player()
	if player == null:
		return
	player.stream = stream
	player.pitch_scale = pitch
	player.play()


func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return null


# ─────────────────────────────────────────────
#  VOLUMES
# ─────────────────────────────────────────────
func _apply_volumes() -> void:
	var music_db = _db_from_linear(volume_music * volume_master)
	var sfx_db   = _db_from_linear(volume_sfx   * volume_master)

	if _active_music_player:
		_active_music_player.volume_db = music_db

	for player in _sfx_pool:
		player.volume_db = sfx_db


func _db_from_linear(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)


# ─────────────────────────────────────────────
#  ADAPTATION PAR SCÈNE
# ─────────────────────────────────────────────
func _on_scene_loaded(scene_id: String) -> void:
	match scene_id:
		"guild":
			var stream = load("res://Assets/Audio/Music/guild_ambiance.ogg")
			if stream:
				play_music(stream)
		"main_menu", "options":
			stop_music()
		_:
			stop_music()


# ─────────────────────────────────────────────
#  SÉRIALISATION
# ─────────────────────────────────────────────
func serialize() -> Dictionary:
	return {
		"volume_master": volume_master,
		"volume_music":  volume_music,
		"volume_sfx":    volume_sfx,
	}


func deserialize(data: Dictionary) -> void:
	volume_master = data.get("volume_master", GameConfig.VOLUME_MASTER_DEFAULT)
	volume_music  = data.get("volume_music",  GameConfig.VOLUME_MUSIC_DEFAULT)
	volume_sfx    = data.get("volume_sfx",    GameConfig.VOLUME_SFX_DEFAULT)
