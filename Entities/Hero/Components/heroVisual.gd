## HeroVisuals.gd
## Gère les layers visuels du héros.
## Chaque layer est un AnimatedSprite2D avec son propre SpriteFrames.
## Tous les layers sont synchronisés sur le même frame.
extends Node2D

@onready var hero : Hero = get_parent()

## Layers dans l'ordre de rendu (bas → haut)
@onready var layer_body   : AnimatedSprite2D = $Body
@onready var layer_chest  : AnimatedSprite2D = $Chest
@onready var layer_eyes   : AnimatedSprite2D = $Eye
@onready var layer_hair   : AnimatedSprite2D = $Hair
@onready var layer_helm   : AnimatedSprite2D = $Helm
@onready var layer_pant   : AnimatedSprite2D = $Pant
@onready var layer_weapon : AnimatedSprite2D = $Weapon

## Layer maître — les autres se synchronisent sur lui
@onready var _master : AnimatedSprite2D = layer_body

var _all_layers : Array[AnimatedSprite2D] = []
var _current_animation : String = ""


func _ready() -> void:
	_all_layers = [layer_body, layer_chest, layer_eyes, layer_hair, layer_helm, layer_pant, layer_weapon]

	# Seul le master émet le signal frame_changed
	# Les autres le suivent passivement
	_master.frame_changed.connect(_sync_all_layers)
	_master.animation_changed.connect(_on_animation_changed)


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

## Appelé par HeroAnimator à la place de anim_player.play()
func play(anim_name: String) -> void:
	if _current_animation == anim_name:
		return
	_current_animation = anim_name

	var is_left : bool = anim_name.ends_with("_left")
	# Pour les anims _left on joue l'équivalent _right et on flip
	var actual_anim : String = anim_name.replace("_left", "_right") if is_left else anim_name

	for layer in _all_layers:
		if layer.sprite_frames and layer.sprite_frames.has_animation(actual_anim):
			layer.play(actual_anim)
			layer.flip_h = is_left

## Configure les layers depuis HeroData au spawn
func setup(data: HeroData) -> void:
	_apply_body(data)
	_apply_eyes(data)
	_apply_hair(data)
	_apply_outfit(data)
	_apply_weapon(data)
	play("idle_down")


## Met à jour uniquement l'arme (équipement changé en cours de jeu)
func update_weapon(item_id: String) -> void:
	var frames := _load_frames("weapon", item_id)
	layer_weapon.sprite_frames = frames
	layer_weapon.visible = (frames != null)
	if frames:
		layer_weapon.play(_current_animation)
		layer_weapon.frame = _master.frame


# ─────────────────────────────────────────────
#  SYNCHRONISATION
# ─────────────────────────────────────────────

func _sync_all_layers() -> void:
	var target_frame := _master.frame
	for layer in _all_layers:
		if layer == _master:
			continue
		if layer.visible and layer.sprite_frames:
			layer.frame = target_frame


func _on_animation_changed() -> void:
	# Rien à faire ici — play() gère déjà la synchro
	pass


# ─────────────────────────────────────────────
#  APPLICATION DES LAYERS DEPUIS HERODATA
# ─────────────────────────────────────────────

func _apply_body(data: HeroData) -> void:
	# data.appearance["body"] = "male_light" / "female_dark" etc.
	var id : String = data.appearance.get("body", "body_male")
	layer_body.sprite_frames = _load_frames("body", id)


func _apply_eyes(data: HeroData) -> void:
	var id : String = data.appearance.get("eyes", "eye_male")
	layer_eyes.sprite_frames = _load_frames("eye", id)


func _apply_hair(data: HeroData) -> void:
	var id : String = data.appearance.get("hair", "hair1_male")
	var frames := _load_frames("hair", id)
	layer_hair.sprite_frames = frames
	#layer_hair.visible = (frames != null)
	


func _apply_outfit(data: HeroData) -> void:
	var top_id    : String = data.appearance.get("top",    "mineur_chest")
	var bottom_id : String = data.appearance.get("pant", "miner_pant")
	layer_chest.sprite_frames    = _load_frames("chest",    top_id)
	layer_pant.sprite_frames = _load_frames("pant", bottom_id)
	
	if(data.appearance.get("helm") != ""):
		var helm_id   : String = data.appearance.get("helm", "helm_1")
		layer_helm.sprite_frames = _load_frames("helm", helm_id)
		layer_hair.visible   = false



func _apply_weapon(data: HeroData) -> void:
	var item_id : String = data.equipment.get("weapon", "")
	update_weapon(item_id)


# ─────────────────────────────────────────────
#  CHARGEMENT DES SPRITEFRAMES
# ─────────────────────────────────────────────

## Convention de nommage des fichiers :
## res://Assets/Heroes/{category}/{id}.png
## Les SpriteFrames sont créés dynamiquement depuis le spritesheet
func _load_frames(category: String, id: String) -> SpriteFrames:
	if id == "":
		return null
	

	var path := "res://Assets/Sprites/Heroes/%s/%s.png" % [category, id]
	if not ResourceLoader.exists(path):
		push_warning("HeroVisuals: texture introuvable '%s'" % path)
		return null

	var tex := load(path) as Texture2D
	return _build_sprite_frames(tex)


## Construit un SpriteFrames depuis un spritesheet LPC standard
## Layout LPC : 4 directions × N frames, lignes dans l'ordre :
##   0 = walk_up, 1 = walk_left, 2 = walk_down, 3 = walk_right
## (à adapter selon TON layout exact)
func _build_sprite_frames(tex: Texture2D) -> SpriteFrames:
	if tex == null:
		return null

	var sf    := SpriteFrames.new()
	var fw    : int = 16   # largeur d'un frame
	var fh    : int = 32   # hauteur d'un frame

	# { nom_anim → [ligne, nb_frames, fps, loop, flip_h] }
	var anims := {
		"walk_down":  [1, 6, 8, true,  false],
		"walk_up":    [2, 6, 8, true,  false],
		"walk_right": [0, 6, 8, true,  false],
		"walk_left":  [0, 6, 8, true,  true],  
		"idle_down":  [6, 1, 6, true,  false],
		"idle_up":    [8, 1, 6, true,  false],
		"idle_right": [7, 1, 4, false, false],
		"idle_left":  [7, 1, 4, false, true], 
		"sit_down":  [9, 1, 6, true,  false],
		"sit_up":    [11, 1, 6, true,  false],
		"sit_right": [10, 1, 4, false, false],
		"sit_left":  [10, 1, 4, false, true], 
	}

	sf.remove_animation("default")

	for anim_name in anims:
		var cfg     : Array = anims[anim_name]
		var row     : int   = cfg[0]
		var nb      : int   = cfg[1]
		var fps     : int   = cfg[2]
		var loop_a  : bool  = cfg[3]
		var flip    : bool  = cfg[4]

		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, loop_a)

		for i in range(nb):
				var atlas       := AtlasTexture.new()
				atlas.atlas      = tex
				atlas.region     = Rect2(i * fw, row * fh, fw, fh)
				atlas.filter_clip = true

				if flip:
					pass

				sf.add_frame(anim_name, atlas)

	return sf
