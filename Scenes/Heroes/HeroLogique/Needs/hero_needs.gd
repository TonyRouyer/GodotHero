extends Node2D

@onready var hero: Hero = get_parent()
@onready var routineNode = get_parent().get_node("HeroRoutine")

#Moral
enum MoralEffectType { TEMPORARY, CONSTANT, PROGRESSIVE }
var moral_effects: Array = []

#Constantes de gestion des besoins
const HUNGER_LOSS_PER_HOUR = 2  # en %/heure en jeu
const ENERGY_LOSS_PER_HOUR = 2.5
const ENTERTAINMENT_LOSS_PER_HOUR = 2.0
const TOILET_LOSS_PER_HOUR = 3.0
const HYGIENE_LOSS_PER_HOUR = 2.0

var starving: bool = false
var exausted: bool = false
var quit_proba: int = 5
#Besoin des hero : HUNGER = 0, SLEEP = 1, TOILET = 2, HYGIENE = 3, ENTERTAINMENT = 4, TRAIN = 5, WORK = 6, FREE = 7 }



func _ready():
	TimeManager.connect("hour_changed", _on_hour_changed)
	TimeManager.connect("day_changed", _on_day_changed)


func _on_hour_changed(_new_hour : int):
	#Calcule de la diminution de faim en fonction du temps
	if hero.hunger <= 0:
		starving = true
	elif hero.hunger >= 5:
		starving = false
	_update_hunger()
	#Calcule de la diminution et gain de someil en fonction du temps
	if hero.energy <= 0:
		exausted = true
	else:
		exausted = false
	_update_energy()
	#Calcule de la diminution/gain de la stat divertisement en fonction du temps
	_update_entertainment()
	#Calcule de la diminution/gain de la stat toilette en fonction du temps
	_update_toilet()
	#Calcule de la diminution/gain de la stat hygiene en fonction du temps
	_update_hygiene()
	
	#Calcule du moral
	hero.moral = 100
	_update_moral()


func _on_day_changed(_new_day):
	if hero.moral <= 5:
		if randf_range(0,100) <= quit_proba:
			print("Le héros est démotivé et quitte la guilde !")
			#hero.quit_guild()
		else:
			quit_proba =+ 5
	else:
		quit_proba = 5

# ---------------------
# Gestion de la Faim
# ---------------------
func _update_hunger():
	# Entraînement ou travail peuvent augmenter le taux
	var modifier = 1.0
	if  routineNode.current_task["type"] == "work" or routineNode.current_task["type"] == "train":
		modifier = 1.5
	var hunger_per_tick = -HUNGER_LOSS_PER_HOUR * modifier
	
	hero.hunger += hunger_per_tick
	hero.hunger = clamp(hero.hunger, 0, 100)
	
	# blesse le hero si il est affamé
	if starving == true:
		hero.hp -= 1


# ---------------------
# Gestion de la Fatigue
# ---------------------
func _update_energy():
	var energy_change = 0.0

	if routineNode.current_task["type"] == "sleep":
		# Dépend du lit
		if routineNode.get_node("activity").is_ground_sleeping:
			var energy_restore_ground = 8.3
			energy_change = energy_restore_ground
		else:
			var energy_restore_bed = 12.5
			energy_change = energy_restore_bed

	else:
		# Entraînement ou travail peuvent augmenter le taux
		var modifier = 1.0
		if  routineNode.current_task["type"] == "train" or routineNode.current_task["type"] == "work":
			modifier = 1.5
		energy_change = -ENERGY_LOSS_PER_HOUR * modifier

	hero.energy += energy_change
	hero.energy = clamp(hero.energy, 0, 100)
	
	if exausted == true:
		hero.moral -= 1

	# Impact sur le moral
	if hero.energy < 10:
		add_moral_effect("Fatigue", -5, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Fatigue")

# ---------------------
# Gestion du divertisement
# ---------------------
func _update_entertainment():
	var loss = ENTERTAINMENT_LOSS_PER_HOUR
	# Peut être augmenté si jamais tu veux que certaines actions soient plus stressantes

	hero.entertainment -= loss
	hero.entertainment = clamp(hero.entertainment, 0, 100)

	# Impact sur le moral
	if hero.entertainment < 25:
		add_moral_effect("Ennui", -3, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Ennui")


# ---------------------
# Gestion toilette
# ---------------------
func _update_toilet():
	var loss = TOILET_LOSS_PER_HOUR	
	hero.toilet -= loss
	hero.toilet = clamp(hero.toilet, 0, 100)

	if hero.toilet <= 10:
		add_moral_effect("Besoin pressant", -5, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Besoin pressant")


# ---------------------
# Gestion du hygiene
# ---------------------
func _update_hygiene():
	var modifier = 1.0
	if routineNode.current_task["type"] == "train" or routineNode.current_task["type"] == "work":
		modifier = 2
	var hygiene_per_tick = -HYGIENE_LOSS_PER_HOUR * modifier

	hero.hygiene += hygiene_per_tick
	hero.hygiene = clamp(hero.hygiene, 0, 100)

	if hero.hygiene < 20:
		add_moral_effect("Sale", -4, 1, MoralEffectType.CONSTANT)
	else:
		remove_moral_effect("Sale")

# ---------------------
# Gestion du Moral
# ---------------------
func _update_moral():
	var total_moral_change = 0.0
	var to_remove = []

	for effect in moral_effects:
		match effect["type"]:
			MoralEffectType.TEMPORARY:
				effect["duration"] -= 1
				if effect["duration"] <= 0:
					to_remove.append(effect)
				else:
					total_moral_change += effect["value"]

			MoralEffectType.CONSTANT:
				total_moral_change += effect["value"]

			MoralEffectType.PROGRESSIVE:
				effect["elapsed"] += 1
				var t = effect["elapsed"] / effect["duration"]
				if t >= 1.0:
					to_remove.append(effect)
				else:
					var current_value = lerp(effect["start_value"], 0.0, t)
					total_moral_change += current_value

	# Supprime les effets expirés
	for e in to_remove:
		moral_effects.erase(e)

	# Applique le changement de moral
	hero.moral += total_moral_change
	hero.moral = clamp(hero.moral, 0, 100)




#Ajout un effet de moral: nom / valeur sur le moral (positive ou negative) / durée en heure, type (ex: MoralEffectType.CONSTANT)
func add_moral_effect(effect_name: String, value: float, duration: float, effect_type: int):
	match effect_type:
		MoralEffectType.TEMPORARY:		
			moral_effects.append({
				"name": effect_name,
				"type": effect_type,
				"value": value,
				"duration": duration
			})
		MoralEffectType.CONSTANT:
			moral_effects.append({
				"name": effect_name,
				"type": effect_type,
				"value": value
			})
		MoralEffectType.PROGRESSIVE:
			moral_effects.append({
				"name": effect_name,
				"type": effect_type,
				"start_value": value,
				"duration": duration,
				"elapsed": 0.0
			})


#Retire un effet au hero en le selectionnat par son nom
func remove_moral_effect(effect_name: String) -> void:
	for i in range(moral_effects.size() - 1, -1, -1):
		if moral_effects[i]["name"] == effect_name:
			moral_effects.remove_at(i)
