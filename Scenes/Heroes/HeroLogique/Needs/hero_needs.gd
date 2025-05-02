extends Node2D

@onready var hero: Hero = get_parent()
@onready var routineNode = get_parent().get_node("HeroRoutine")
@onready var removeDayTimer: Timer = $RemoveDayTimer #timer qui decroit les jour quand le hero a faim

# Constantes de gestion des besoins
const FAIM_LOSS_PER_HOUR = 2  # en %/heure en jeu
const FATIGUE_LOSS_PER_HOUR = 2.5
const TIMER_INTERVAL = 1.0 # Intervalle du timer en secondes
const SECONDS_PER_HOUR = 60.0   # donc 3.3 / 60 ≈ 0.055 / sec
var days_without_food: int = 7

enum MoralEffectType { TEMPORARY, CONSTANT, PROGRESSIVE }
var moral_effects: Array = []

#Besoin des hero : 0 = HUNGER, 1 = SLEEP, 2 = TRAIN, 3 = WORK, 4 = FREE

func _ready():
	TimeManager.connect("hour_changed", _on_hour_changed)
	TimeManager.connect("day_changed", _on_day_changed)
		
func _on_hour_changed(_new_hour : int):
	#Calcule de la diminution de faim en fonction du temps
	_update_faim()
	#Calcule de la diminution et gain de someil en fonction du temps
	_update_fatigue()
	#Calcule du moral
	hero.moral = 100
	_update_moral()


func _on_day_changed(new_day : int):
	print('il est le: ', new_day)
	

func _on_remove_day_timer_timeout():
	days_without_food -= 1


# ---------------------
# Gestion de la Faim
# ---------------------
func _update_faim():
	# Entraînement ou travail peuvent augmenter le taux
	var modifier = 1.0
	if  routineNode.last_need == 2 or routineNode.last_need == 3:
		modifier = 1.5
	var faim_per_tick = -FAIM_LOSS_PER_HOUR * modifier
	
	print("faim=", faim_per_tick)
	
	hero.faim += faim_per_tick
	hero.faim = clamp(hero.faim, 0, 100)
	
	# tu le hero si il passe 7 jour sans manger
	if hero.faim <= 0:
		if removeDayTimer.is_stopped():
			removeDayTimer.start()
			
		if days_without_food == 0:
			print("Le héros est mort de faim !")
			#hero.die()


# ---------------------
# Gestion de la Fatigue
# ---------------------
func _update_fatigue():
	var fatigue_change = 0.0

	if routineNode.last_need == 1:
		# Dépend du lit

		if routineNode.get_node("Sleep").is_ground_sleeping:
			print("hero is ground sleeping")
			fatigue_change = 100 / 12
		else:
			print("hero lit")
			fatigue_change = 100 / 8

	else:
		# Entraînement ou travail peuvent augmenter le taux
		var modifier = 1.0
		if  routineNode.last_need == 2 or routineNode.last_need == 3:
			modifier = 1.5
		fatigue_change = -FATIGUE_LOSS_PER_HOUR * modifier

	hero.fatigue += fatigue_change
	hero.fatigue = clamp(hero.fatigue, 0, 100)

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

	if hero.moral <= 0:
		print("Le héros est démotivé et quitte la guilde !")
		#hero.quit_guild()


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
	print(moral_effects)
	for i in range(moral_effects.size() - 1, -1, -1):
		if moral_effects[i]["name"] == effect_name:
			moral_effects.remove_at(i)
	print(moral_effects)
