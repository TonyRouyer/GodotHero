extends Control

signal fire_pressed()

var hero: Hero

func _ready():
	%Name.text = str(hero.name)
	%Level.text = "lvl " + str(hero.level)
	%Classe.text = str(hero.classe)
	%Hp.text = "Hp: " + str(hero.classe)
	%Moral.text = "Moral: " + str(hero.classe)
	
	%DetailBtn.connect("pressed", show_hero_info)
	%FireBtn.connect("pressed", _on_fire_btn_pressed)


func show_hero_info() -> void:
	GameData.hide_ui()
	GameData.set_active_hero(hero)
	hero.hero_panel_info.show_stats_overlay()
	hero.hero_panel_info.show()
	

func _on_fire_btn_pressed() -> void:
	fire_pressed.emit()
