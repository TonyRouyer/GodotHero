extends Resource

# Définition des listes de noms
const HUMAN_MALE_NAMES = [
	"Aldric", "Baldwin", "Cedric", "Darian", "Edmund",
	"Felix", "Gareth", "Harold", "Isaac", "Julian",
	"Kelvin", "Leonard", "Marcus", "Nathaniel", "Oswin",
	"Percival", "Quentin", "Roderick", "Sebastian", "Tristan",
	"Uther", "Victor", "William", "Xander", "Yvain",
	"Zachary", "Alaric", "Benedict", "Conrad", "Dominic",
	"Eldric", "Fabian", "Geoffrey", "Hadrian", "Ivan",
	"Jasper", "Kenneth", "Lysander", "Matthias", "Nolan",
	"Orlando", "Peregrin", "Quinlan", "Reginald", "Silas",
	"Theron", "Ulrich", "Valerian", "Wesley", "Xanthus",
	"Adelaide", "Beatrice", "Cassandra", "Daphne", "Evelyn",
	"Felicity", "Gwendolyn", "Helena", "Isolde", "Juliana",
	"Katherine", "Lillian", "Margaret", "Natalia", "Ophelia",
	"Penelope", "Quinn", "Rosalind", "Seraphina", "Theodora",
	"Ursula", "Violet", "Wilhelmina", "Xanthe", "Yvette",
	"Zara", "Amelia", "Bridget", "Celeste", "Diana",
	"Elinor", "Freya", "Genevieve", "Harriet", "Imogen",
	"Jocelyn", "Kiera", "Lucille", "Miranda", "Nadia",
	"Olivia", "Priscilla", "Quinta", "Rowena", "Sophia",
	"Tabitha", "Una", "Vivian", "Winifred", "Xenia"
]

const ORC_MALE_NAMES = [
	"Gorash", "Thrag", "Dorgul", "Kragnor", "Brok",
	"Grok", "Vrog", "Morgrum", "Harg", "Torok",
	"Zog", "Rugash", "Blorg", "Muglak", "Grukk",
	"Thok", "Brak", "Urgok", "Druk", "Gar",
	"Lugash", "Nok", "Zug", "Horgul", "Karg",
	"Throg", "Bulg", "Grash", "Ruk", "Nog",
	"Urdak", "Borash", "Varg", "Hruk", "Trog",
	"Kulg", "Gorm", "Drak", "Korog", "Murg",
	"Rogruk", "Vok", "Zrag", "Orag", "Drorg",
	"Grag", "Nurg", "Blurg", "Kor", "Mok",
	"Graak", "Shaga", "Broka", "Throk", "Lugra",
	"Droka", "Morgra", "Hurka", "Zorga", "Kragha",
	"Ruka", "Urka", "Zolga", "Fraga", "Dolka",
	"Hroka", "Vurka", "Gorza", "Blurka", "Torga",
	"Groka", "Narka", "Orga", "Gralka", "Korka",
	"Thrakka", "Mugra", "Braka", "Rorga", "Kroka",
	"Thugra", "Grakna", "Zarka", "Vogla", "Draka",
	"Horka", "Nulka", "Mogka", "Falka", "Zulka",
	"Vorka", "Grolka", "Dorgna", "Krulka", "Morka",
	"Turka", "Zurka", "Glorka", "Norja", "Drulka"
]

const RACES = ["Human", "Orc"]
const CLASSES = ["Mage", "Warrior"]



func get_random_hero():
	var hero = {}
	
	# Définir un niveau de base
	hero.level = 1
	
	# Définir une race aléatoire
	hero.race = RACES[randi() % RACES.size()]
	
	# Définir une classe aléatoire
	hero.classe = CLASSES[randi() % CLASSES.size()]
	
	# Définir un nom aléatoire en fonction de la race
	if hero.race == "Human":
		hero.name = HUMAN_MALE_NAMES[randi() % HUMAN_MALE_NAMES.size()]
		hero.animated_skin = "soldier_idle"
	else:
		hero.name = ORC_MALE_NAMES[randi() % ORC_MALE_NAMES.size()]
		hero.animated_skin = "orc_idle"
		
	hero.strength = randi_range(3,15)
	hero.defense = randi_range(3,15)
	hero.agility = randi_range(3,15)
	hero.mana = randi_range(3,15)
	hero.luck = randi_range(3,15)
	hero.hp_max = calculate_max_hp(hero)
	hero.hp = hero.hp_max
	return hero
	
func calculate_max_hp(hero_stats: Dictionary) -> int:
	var base_hp = 100
	var strength_factor = 5
	var defense_factor = 3
	var agility_factor = 2
	
	var hp_max = base_hp + (hero_stats["strength"] * strength_factor) + (hero_stats["defense"] * defense_factor) + (hero_stats["agility"] * agility_factor)
	return hp_max
