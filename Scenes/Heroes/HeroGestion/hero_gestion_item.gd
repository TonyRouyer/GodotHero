extends Control

signal fire_pressed()

var hero: Hero

func set_nom(value : String) -> void:
	var nom = %Nom
	nom.text = str(value)


func set_level(value : int) -> void:
	var level = %Level
	level.text = "lvl " + str(value)


func set_classe(value : String) -> void:
	var classe = %Classe
	classe.text = str(value)


func show_hero_info() -> void:
	hero.get_node("%HeroPanelInfo").show_stats_overlay()


func _on_fire_btn_pressed() -> void:
	fire_pressed.emit()
