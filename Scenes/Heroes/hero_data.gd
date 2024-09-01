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
	else:
		hero.name = ORC_MALE_NAMES[randi() % ORC_MALE_NAMES.size()]
		
	#Definir un skin aleatoire en fonction de la classe
	if hero.classe == "Warrior":
		var warrior_skin = ["warrior_animation1", "warrior_animation2", "warrior_animation3"]
		hero.skin = warrior_skin.pick_random()
	elif hero.classe == "Mage":
		var mage_skin = ["mage_animation1", "mage_animation2"]
		hero.skin = mage_skin.pick_random()
		
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

	var hp_max = base_hp + (hero_stats["strength"] * 2) + (hero_stats["defense"] * 1.5) 
	return hp_max
