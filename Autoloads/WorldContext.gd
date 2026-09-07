## WorldContext.gd — Autoload
## Détient les références aux conteneurs de nœuds vivants de la scène active.
## Élimine les chemins codés en dur du type "Main/SceneContainer/GuildScene/World/Objects".
##
## Usage :
##   WorldContext.setup(objects_node, heroes_node)   # appelé par guild_scene._ready()
##   WorldContext.clear()                            # appelé par guild_scene._exit_tree()
##   WorldContext.objects_container                  # accès direct
extends Node

var objects_container : Node2D = null
var heroes_container  : Node2D = null


func setup(objects: Node2D, heroes: Node2D) -> void:
	objects_container = objects
	heroes_container  = heroes


func clear() -> void:
	objects_container = null
	heroes_container  = null


func is_ready() -> bool:
	return objects_container != null and heroes_container != null
