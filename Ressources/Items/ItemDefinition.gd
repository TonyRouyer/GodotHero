## ItemDefinition.gd
## Données statiques d'un type d'item (arme, armure, consommable, matériau).
extends Resource
class_name ItemDefinition

@export var id          : String = ""
@export var label       : String = ""
@export var description : String = ""
@export var type        : String = "material"  ## weapon|armor|accessory|consumable|material
@export var stackable   : bool   = false
@export var max_stack   : int    = 1
@export var rarity      : String = "common"    ## common|uncommon|rare|epic|legendary
@export var icon_color  : Color  = Color(0.5, 0.5, 0.5)
