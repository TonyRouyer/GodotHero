## ResearchLibrary.gd
## Registre statique de toutes les recherches disponibles.
## Usage : var def = ResearchLibrary.get(id)
class_name ResearchLibrary

static var _defs        : Dictionary = {}
static var _initialized : bool       = false

const _ICON_BASE : String = "res://Sprites/Interface/research icon/"


static func get_definition(id: String) -> ResearchData:
	if not _initialized:
		_build_all()
	return _defs.get(id, null)


static func get_all() -> Array:
	if not _initialized:
		_build_all()
	return _defs.values()


static func get_for_level(level: int) -> Array:
	if not _initialized:
		_build_all()
	var result : Array = []
	for r in _defs.values():
		if r.level == level:
			result.append(r)
	return result


static func _r(id: String, label: String, desc: String, unlocks: String, cost: int, level: int, prereqs: Array, icon: String) -> ResearchData:
	var d := ResearchData.new()
	d.id            = id
	d.label         = label
	d.description   = desc
	d.unlocks       = unlocks
	d.cost          = cost
	d.level         = level
	d.prerequisites.assign(prereqs)
	d.icon_path     = (_ICON_BASE + icon) if icon != "" else ""
	_defs[id] = d
	return d


static func _build_all() -> void:
	_initialized = true

	## ── NIVEAU 1 ────────────────────────────────────────────────────────────
	_r("forge_basique",
		"Forge basique",
		"Permet la construction de la forge, forge des objets de rang F.",
		"Salle forge + forge, enclume. Plans rang F et E, charbon, verre.",
		200, 1, [],
		"recherche_de_forge.png")

	_r("couture_rudimentaire",
		"Couture rudimentaire",
		"Permet la création d'équipements tissu/cuir rang F.",
		"Salle de couture, métier à tisser, chevalet de tannage. Plans rang F et E, tissus.",
		150, 1, [],
		"couture.png")

	_r("artisanat_general",
		"Artisanat général",
		"Permet la construction d'un atelier de craft pour matériaux simples.",
		"Salle atelier et objets liés (sauf atelier de recyclage). Plans objets craftables via atelier.",
		150, 1, [],
		"")

	_r("recyclage_primaire",
		"Recyclage primaire",
		"Recyclage partiel (25%) des armes et armures.",
		"Atelier de recyclage. Fonction de recyclage disponible (25%).",
		100, 1, [],
		"recyclage.png")

	## ── NIVEAU 2 ────────────────────────────────────────────────────────────
	_r("entrainement_martial",
		"Entraînement Martial",
		"Améliore la salle d'entraînement, permet objets physiques.",
		"Salle d'entraînement + tous les objets d'entraînement physique.",
		600, 2, ["forge_basique"],
		"entrainement martial.png")

	_r("entrainement_magique",
		"Entraînement Magique",
		"Débloque la salle de l'arcanum.",
		"Salle Arcanum + bureau enchanté, lutrin.",
		600, 2, ["couture_rudimentaire"],
		"entainement magique.png")

	_r("alchimie_basique",
		"Alchimie basique",
		"Crée la salle et l'établi de base pour potions simples.",
		"Établi d'alchimie + objets liés. Potions T1 (mineure) + objets craftables via alchimie.",
		300, 2, ["artisanat_general"],
		"alchimie.png")

	_r("menuiserie",
		"Menuiserie",
		"Permet de créer des meubles en bois basiques.",
		"Table en bois avec chaise, placard personnel, étagère.",
		400, 2, ["artisanat_general"],
		"")

	## ── NIVEAU 3 ────────────────────────────────────────────────────────────
	_r("forge_avancee",
		"Forge avancée (D)",
		"Création d'équipements rang D (acier).",
		"Plans de rang D. Soufflet + plan lingot de fer.",
		400, 3, ["entrainement_martial"],
		"acier de forge.png")

	_r("tissage_renforce",
		"Tissage renforcé (D)",
		"Confection d'armures tissu/cuir renforcé.",
		"Plans rang D. Rouet + plan tissus renforcé.",
		350, 3, ["entrainement_magique"],
		"tissage renforcé.png")

	_r("ameublement",
		"Ameublement",
		"Débloque certains meubles, notamment décoratifs.",
		"Cloche de réception, coffre à outil, globe runique, lutrin, plan de travail, évier rustique.",
		400, 3, ["menuiserie"],
		"")

	_r("medecine",
		"Médecine",
		"Débloque l'infirmerie et ses meubles liés.",
		"Salle infirmerie + objets liés.",
		500, 3, ["alchimie_basique"],
		"soin de base.png")

	_r("esthetique",
		"Esthétique",
		"Débloque certains objets de décoration.",
		"Statue de héros, fontaine décorative, tapis royal rouge, tapis décoratif.",
		50, 3, [],
		"")

	## ── NIVEAU 4 ────────────────────────────────────────────────────────────
	_r("forge_maitre",
		"Forge de maître (C)",
		"Permet de forger armes/armures de rang C.",
		"Plans rang C. Ratelier d'outils + plan lingot d'acier, huile de boeuf.",
		800, 4, ["forge_avancee"],
		"forge de maitre d'arme.png")

	_r("armurier_agile",
		"Armurier agile (C)",
		"Création armures cuir/tissu de rang C.",
		"Plans rang C. Chevalet de tannage + plan cuir.",
		800, 4, ["tissage_renforce"],
		"atelier_armurier_agile.png")

	_r("joaillerie",
		"Joaillerie",
		"Permet de forger des bijoux (anneaux, amulettes).",
		"Craft des anneaux et amulettes.",
		1200, 4, ["forge_avancee", "tissage_renforce"],
		"")

	_r("jardin_botanique",
		"Jardin Botanique",
		"Permet la culture de plantes sur plates-bandes.",
		"Plates-bandes, compost, arrosoir magique. Accès aux graines à l'achat.",
		700, 4, ["medecine"],
		"jardin botanique.png")

	_r("divertissement",
		"Divertissement",
		"Débloque des objets de divertissement.",
		"Plateau d'échecs, table de jeu.",
		800, 4, ["ameublement"],
		"")

	## ── NIVEAU 5 ────────────────────────────────────────────────────────────
	_r("enchantement",
		"Enchantement",
		"Permet l'enchantement des armes et équipements.",
		"Fonctionnalité enchantement (recherche + application). Autel d'enchantement + enchantements rang C.",
		1000, 5, ["forge_maitre", "armurier_agile"],
		"enchantement d'equipement.png")

	_r("alchimie_avancee",
		"Alchimie avancée",
		"Permet de créer plus de potions.",
		"Accès aux potions T2 + chaudron magique.",
		1000, 5, ["jardin_botanique"],
		"alchimiste acomplit.png")

	_r("economie_commerciale",
		"Économie commerciale",
		"Débloque l'accès au marché avec possibilité d'acheter/vendre.",
		"Accès au marché.",
		650, 5, ["medecine"],
		"")

	_r("recyclage_avance",
		"Recyclage avancé (50%)",
		"Augmente l'efficacité du recyclage.",
		"Recyclage de 50% des équipements et armes.",
		800, 5, ["economie_commerciale"],
		"recyclage avancé.png")

	_r("brassage",
		"Brassage",
		"Débloque le tonneau de fermentation et la possibilité de faire bière/hydromel.",
		"Objet : atelier de fermentation + recettes liées.",
		950, 5, ["jardin_botanique"],
		"")

	## ── NIVEAU 6 ────────────────────────────────────────────────────────────
	_r("forge_haute_qualite",
		"Forge haute qualité (B)",
		"Fabrication armures/armes B.",
		"Plans rang B. Bibliothèque de schémas, lingot d'acier trempé + rivet d'acier.",
		2000, 6, ["enchantement"],
		"maitrise de forge de haute qualité.png")

	_r("tannage_avance",
		"Tannage avancé (cuir B)",
		"Fabrication armures cuir/tissu B.",
		"Plans rang B. Armoire en tissu + plan cuir tanné + cuir souple.",
		2000, 6, ["enchantement"],
		"technique de tannage avancé.png")

	_r("enchantement_avance",
		"Enchantement avancé",
		"Ajoute des enchantements puissants (rang B).",
		"Débloque les enchantements de rang B.",
		1500, 6, ["enchantement"],
		"arme enchanté avancé.png")

	_r("alchimiste_experimente",
		"Alchimiste expérimenté",
		"Plus de potions diverses, effets complexes.",
		"Accès aux potions offensives/défensives.",
		1500, 6, ["alchimie_avancee"],
		"alchimiste acomplit.png")

	_r("agriculture_avancee",
		"Agriculture avancée",
		"Améliore les cultures et la gestion botanique.",
		"Débloque meuble rasoir magique et bac de compost.",
		1500, 6, ["alchimie_avancee"],
		"jardin botanique.png")

	## ── NIVEAU 7 ────────────────────────────────────────────────────────────
	_r("enchantement_expert",
		"Enchantement expert",
		"Débloque des enchantements plus avancés.",
		"Débloque les enchantements de rang A.",
		2000, 7, ["enchantement_avance"],
		"maitrise de l'enchantement.png")

	_r("salle_ascension",
		"Salle d'Ascension",
		"Permet de faire évoluer les héros.",
		"Fonction d'évolution des héros + autel d'évolution.",
		1800, 7, ["forge_haute_qualite", "tannage_avance"],
		"salle d'ascention.png")

	_r("soins_innovants",
		"Systèmes de Soins Innovants",
		"Améliore les effets de soin en infirmerie (+25% efficacité).",
		"Améliore les soins des lits d'infirmerie.",
		2100, 7, ["alchimiste_experimente"],
		"systele de soin inovant.png")

	## ── NIVEAU 8 ────────────────────────────────────────────────────────────
	_r("forge_legendaire_A",
		"Forge d'Armes Légendaires (A)",
		"Permet la fabrication d'armes et armures en métal de rang A.",
		"Débloque les plans de rang A.",
		2500, 8, ["salle_ascension"],
		"forgeron legendaire.png")

	_r("confection_elite_A",
		"Confection d'Armures Élites (A)",
		"Création d'armures cuir/tissu de rang A.",
		"Débloque les plans de rang A.",
		2500, 8, ["salle_ascension"],
		"confection d'armure d'élite.png")

	_r("alchimiste_expert",
		"Alchimiste expert",
		"Permet de fabriquer des potions plus rares.",
		"Accès aux potions rares.",
		2000, 8, ["soins_innovants"],
		"alchimiste econome.png")

	## ── NIVEAU 9 ────────────────────────────────────────────────────────────
	_r("maitrise_enchantement_bijoux",
		"Maîtrise de l'Enchantement (Bijoux)",
		"Permet d'enchanter les anneaux et amulettes avec effets magiques.",
		"Enchantement bijoux.",
		3000, 9, ["forge_legendaire_A", "confection_elite_A"],
		"maitrise de l'enchantement.png")

	_r("strategie_guerre",
		"Stratégie de Guerre Avancée",
		"Bonus +10% de dégâts pour tous les héros en combat.",
		"Buff global passif.",
		2800, 9, ["forge_legendaire_A", "confection_elite_A"],
		"strategie de guerre avancée.png")

	_r("recyclage_integral",
		"Recyclage Intégral (100%)",
		"Récupérer toutes les ressources d'un équipement recyclé.",
		"Fonction totale de recyclage (100%).",
		3000, 9, ["alchimiste_expert"],
		"recyclage intégrale.png")

	## ── NIVEAU 10 ───────────────────────────────────────────────────────────
	_r("forgeron_legendaire_S",
		"Forgeron Légendaire (S)",
		"Permet de fabriquer les armes/armures de rang S.",
		"Débloque les plans de rang S.",
		3500, 10, ["strategie_guerre"],
		"forgeron legendaire.png")

	_r("couturier_legendaire_S",
		"Couturier Légendaire (S)",
		"Permet de créer les armures cuir/tissu de rang S.",
		"Débloque les plans de rang S.",
		3500, 10, ["strategie_guerre"],
		"couturier legendaire.png")
