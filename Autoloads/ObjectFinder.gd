## ObjectFinder.gd — Autoload
## Service centralisé de recherche d'objets dans la scène.
## Élimine la duplication de _find_free_object() entre HeroActivity et HeroRoutine.
##
## Usage :
##   ObjectFinder.find_free_object("bed")
##   ObjectFinder.find_free_object_in_list(["anvil", "forge"])
##   ObjectFinder.find_object_with("chest", "food_amount", 1.0)
##   ObjectFinder.object_available("bed")
extends Node


## Cherche le premier objet du type donné qui est disponible (not used).
func find_free_object(type_id: String) -> Node2D:
	var container : Node2D = WorldContext.objects_container
	if container == null:
		return null
	for obj in container.get_children():
		if obj.get("object_id") == type_id and obj.is_available():
			return obj
	return null


## Cherche le premier objet disponible parmi une liste de types (ordre de priorité).
func find_free_object_in_list(type_ids: Array[String]) -> Node2D:
	for t in type_ids:
		var obj : Node2D = find_free_object(t)
		if obj != null:
			return obj
	return null


## Cherche un objet du type donné dont une propriété dépasse une valeur minimale.
func find_object_with(type_id: String, property: String, min_value: float) -> Node2D:
	var container : Node2D = WorldContext.objects_container
	if container == null:
		return null
	for obj in container.get_children():
		if obj.get("object_id") == type_id:
			var val = obj.get(property)
			if val != null and float(val) >= min_value:
				return obj
	return null


## Indique si un objet d'un type est utilisable (cas spécial pour "food" → GameData.food).
func object_available(type_id: String) -> bool:
	if type_id == "food":
		return GameData.food > 0
	return find_free_object(type_id) != null
