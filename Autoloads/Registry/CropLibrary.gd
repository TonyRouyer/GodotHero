## CropLibrary.gd — Autoload
## Registre des 8 cultures disponibles dans les planting_beds.
## Temps de pousse en jours de jeu (GameConfig.DAY_DURATION).
##
## Structure :
##   id            : String  — identifiant unique
##   label         : String  — nom affiché
##   growth_days   : float   — jours de jeu nécessaires à maturité
##   yield_id      : String  — ID matériau produit (dans MaterialLibrary ou DishLibrary ingrédients)
##   yield_qty     : int     — quantité produite à la récolte
##   seed_cost_id  : String  — ID item pour planter (graine, bouture…) — "" si aucun coût
##   seed_cost_qty : int     — quantité de graine nécessaire
##   price         : int     — valeur de la récolte en or
##   description   : String
extends Node


var _crops : Dictionary = {}


func _ready() -> void:
	_register_crops()


# ─────────────────────────────────────────────
#  API PUBLIQUE
# ─────────────────────────────────────────────

func get_crop(id: String) -> Dictionary:
	return _crops.get(id, {})


func get_all() -> Dictionary:
	return _crops


func get_all_list() -> Array:
	return _crops.values()


# ─────────────────────────────────────────────
#  HELPER
# ─────────────────────────────────────────────
func _c(id: String, label: String, growth_days: float, yield_id: String, yield_qty: int,
		seed_cost_id: String, seed_cost_qty: int, price: int, desc: String) -> void:
	_crops[id] = {
		"id":            id,
		"label":         label,
		"growth_days":   growth_days,
		"yield_id":      yield_id,
		"yield_qty":     yield_qty,
		"seed_cost_id":  seed_cost_id,
		"seed_cost_qty": seed_cost_qty,
		"price":         price,
		"description":   desc,
	}


# ─────────────────────────────────────────────
#  CULTURES (8)
# ─────────────────────────────────────────────
func _register_crops() -> void:

	## Lin — 2,5 jours — produit "flax" (fibre textile)
	_c("lin", "Lin", 2.5,
		"flax", 4,
		"", 0, 3,
		"Pousse rapidement. Donne des fibres de lin utilisées pour le tissage.")

	## Carotte — 3 jours — produit "carrot" (ingrédient cuisine)
	_c("carotte", "Carotte", 3.0,
		"carrot", 5,
		"", 0, 2,
		"Un légume robuste facile à cultiver. Ingrédient culinaire de base.")

	## Blé — 4 jours — produit "grain" (céréale)
	_c("ble", "Blé", 4.0,
		"grain", 6,
		"", 0, 4,
		"La culture de base. Le grain sert au pain, à la bouillie et à la bière.")

	## Chou — 3,5 jours — produit "cabbage"
	_c("chou", "Chou", 3.5,
		"cabbage", 4,
		"", 0, 2,
		"Un légume trapu qui pousse bien dans les terres froides.")

	## Herbes médicinales — 2 jours — produit "medicinal_plant"
	_c("herbes", "Herbes Médicinales", 2.0,
		"medicinal_plant", 3,
		"", 0, 5,
		"Petites plantes aux vertus curatives. Utiles pour les potions.")

	## Baies sauvages — 5 jours — produit "wild_berry"
	_c("baies", "Baies Sauvages", 5.0,
		"wild_berry", 6,
		"", 0, 3,
		"Des baies sucrées et acidulées. Utilisées en cuisine et pour les confitures.")

	## Houblon — 6 jours — produit "hops" (brasserie)
	_c("houblon", "Houblon", 6.0,
		"hops", 4,
		"", 0, 6,
		"Plante grimpante indispensable pour brasser la bière. Pousse lentement.")

	## Herbes rares — 7 jours — produit "rare_herbs"
	_c("herbes_rares", "Herbes Rares", 7.0,
		"rare_herbs", 2,
		"", 0, 15,
		"Des herbes aux propriétés magiques exceptionnelles. Long à pousser, très précieux.")
