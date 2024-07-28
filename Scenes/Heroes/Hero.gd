extends Node2D

# Variables de stats et attributs du héros
@export var level: int
@export var strength: int
@export var defense: int
@export var agility: int
@export var mana: int
@export var luck: int
@export var hp_max:int
@export var hp:int
@export var race : String
@export var classe : String
@export var idle_animation: String
@export var moral : int
@export var rang : Array
@export var skill_point : int

# Références aux nœuds
@onready var animatedSprite = $AnimatedSprite2D
@onready var collisionShape = $Area2D/CollisionShape2D
@onready var ui_stats_overlay = $stats_overlay
@onready var atck = $stats_overlay/str
@onready var def = $stats_overlay/def
@onready var agi = $stats_overlay/agi
@onready var man = $stats_overlay/mana
@onready var lck = $stats_overlay/luck
@onready var hp_now = $stats_overlay/hp
@onready var lvl = $stats_overlay/lvl
@onready var ui_stats_panel = $CanvasLayer/statsWindow
@onready var ui_nom = $CanvasLayer/statsWindow/Nom
@onready var ui_race = $CanvasLayer/statsWindow/Race
@onready var ui_classe = $CanvasLayer/statsWindow/Classe
@onready var ui_level = $CanvasLayer/statsWindow/Level
@onready var ui_strength = $CanvasLayer/statsWindow/Strength
@onready var ui_defense = $CanvasLayer/statsWindow/Defense
@onready var ui_agility = $CanvasLayer/statsWindow/Agility
@onready var ui_mana = $CanvasLayer/statsWindow/Mana
@onready var ui_luck = $CanvasLayer/statsWindow/Luck
@onready var ui_hp = $CanvasLayer/statsWindow/Hp
@onready var ui_sprite = $CanvasLayer/statsWindow/Sprite
@onready var train_timer = $TrainTimer
@onready var equipement_container = $CanvasLayer/statsWindow/EquipementContainer
@onready var global_inventory
@onready var global_inventory_node = $CanvasLayer/GlobalInventory


#Var divers
var draggable = false
var in_inside_dropable = false
var body_ref = null
var offset: Vector2
var initialPos: Vector2
var heroInstance = null
var rangList = ["F","E","D","C","B","A","S"]
var hero_win_streak = 0
var trainType: String = ""
var equipment = {}

func _ready():
	# Si il y une animation de hero, lance l'animation
	if idle_animation != "":
		animatedSprite.play(idle_animation)

	for i in range(equipement_container.get_children().size()):
		equipment["EquipementSlot" + str(i)] = {}

	
	var scene_tree = get_tree()
	if scene_tree.has_group("inventory"):
		global_inventory = get_tree().get_nodes_in_group("inventory")[0]


func _process(_delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			ui_stats_overlay.visible = false
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
		if Input.is_action_pressed("click"):
			ui_stats_overlay.visible = false
			global_position = get_global_mouse_position() - offset
		if Input.is_action_just_pressed("r_click"):
			GameData.set_active_hero(self)
			show_stats_overlay()
		elif Input.is_action_just_released("click"):
			global.is_dragging = false
			if in_inside_dropable and !is_position_occupied(body_ref.position):
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			else:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered():
	if not global.is_dragging:
		draggable = true
		scale = Vector2(1.1,1.1)
		update_stats_overlay()

func _on_area_2d_mouse_exited():
	if not global.is_dragging:
		draggable = false
		scale = Vector2(1,1)
		ui_stats_overlay.visible = false

func _on_area_2d_body_entered(body):
	if body.is_in_group('dropable'):
		in_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body
		
		# Definie la global train_zone en fonction de la dropzone dans la quelle a été deposer l'instance de hero
		if body.for_mana == true:
			self.trainType = "mana"
		if body.for_def == true:
			self.trainType = "defense"

func _on_area_2d_body_exited(body):
	in_inside_dropable = false
	body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)

	if body.for_mana == true:
		self.trainType = ""
	if body.for_def == true:
		self.trainType = ""

func is_position_occupied(new_position: Vector2) -> bool:
	# Vérifie si une position est déjà occupée par un héros
	for hero in get_parent().get_children():
		if hero != self and hero.global_position.distance_to(new_position) < 30.0:
			return true
	return false

func show_stats_overlay():
	# Affiche la fenêtre des statistiques
	ui_stats_panel.visible = true
	# Remplit les informations du héros dans l'UI
	ui_nom.text = self.name
	ui_race.text = self.race
	ui_classe.text = self.classe
	ui_level.text = "Level: " + str(self.level)
	ui_strength.text = "Strength: " + str(self.strength)
	ui_defense.text = "Defense: " + str(self.defense)
	ui_agility.text = "Agility: " + str(self.agility)
	ui_mana.text = "Mana: " + str(self.mana)
	ui_luck.text = "Luck: " + str(self.luck)
	
	# Mise à jour de la barre de progression HP
	ui_hp.max_value = float(self.hp_max)
	ui_hp.value = float(self.hp)
	
	# Charge le sprite du héros dans l'UI
	ui_sprite.animation  = self.idle_animation
	global_inventory_node.show()

func _on_button_pressed():
	ui_stats_panel.visible = false
	global_inventory_node.hide()

# Met à jour l'overlay des statistiques
func update_stats_overlay():
	atck.text =  "Str :  " + str(self.strength)
	def.text =  "Def :  " + str(self.defense)
	agi.text =  "Agi :  " + str(self.agility)
	man.text = "Mana :  " + str(self.mana)
	lck.text =  "Luck " + str(self.luck)
	hp_now.text = str(self.hp) + "/" + str(self.hp_max)
	lvl.text = "lvl " + str(self.level)
	ui_stats_overlay.visible = true


func _on_train_timer_timeout():
	if self.trainType == "mana":
		print("++ mana")
		self.mana += 1
	if self.trainType == "defense":
		print("++ defense")
		self.defense += 1
		
		
		
		
		
func load_equipment():
	for child in equipement_container.get_children():
		var data = equipment[child.name]
		child.set_slot(data)	
		
		
#Equip and item removing it from thew inventory slot and add it to the equipment slot
func equip_item(from_slot,equip_slot,item, from_inventory:bool = true):
	if from_inventory:
		if equipment[equip_slot].is_empty():
			#Si on ajoute une nouveau equipement depuis l'inventaire
			equipment[equip_slot] = item
			global_inventory.inventory[from_slot].clear()
		else:

			#si l'on veux swap un equipement deja present depuis l'inventaire
			var equiped_item = equipment[equip_slot].duplicate()
			equipment[equip_slot] = item
			global_inventory.inventory[from_slot] = equiped_item
	else:
		if equipment[equip_slot].is_empty():
			#Si on equipe depuis les equipement dans une case vide
			equipment[equip_slot] = item
			equipment[from_slot].clear()
		else:
			#si on swap 2 equipement du meme type
			var equipped_item = equipment[equip_slot].duplicate()
			equipment[equip_slot] = item
			equipment[from_slot] = equipped_item
	load_equipment()
	global_inventory.load_inventory()
	
#remove item from equipment slot put in inventory
func unequip_item(from_slot,equip_slot, item):
	if global_inventory.inventory[equip_slot].is_empty():
		#Si de equipe un equipement vers une case vide de l'inventaire
		global_inventory.inventory[equip_slot] = item
		equipment[from_slot].clear()
	else:
		#Si de equipe un equipement vers une case deja occuper de l'inventaire
		var inventory_slot = global_inventory.inventory[equip_slot]
		global_inventory.inventory[equip_slot] = equipment[from_slot].duplicate()
		equipment[from_slot] = inventory_slot
	
	load_equipment()
	global_inventory.load_inventory()

