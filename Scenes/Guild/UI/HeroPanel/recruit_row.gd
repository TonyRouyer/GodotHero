## recruit_row.gd
## Ligne du panel de recrutement.
## Affiche : rang, nom, classe, niveau, coût de recrutement, bouton Recruter, bouton Refuser.
extends PanelContainer


@onready var rank_label   : Label  = %RankLabel
@onready var name_label   : Label  = %NameLabel
@onready var class_label  : Label  = %ClassLabel
@onready var lvl_label    : Label  = %LvlLabel
@onready var cost_label   : Label  = %CostLabel
@onready var recruit_btn  : Button = %RecruitBtn
@onready var refuse_btn   : Button = %RefuseBtn

var _data : HeroData = null


func setup(hero_data: HeroData) -> void:
	_data = hero_data

	rank_label.text  = _data.rank
	name_label.text  = _data.hero_name
	class_label.text = _data.hero_class.capitalize()
	lvl_label.text   = "L%d" % _data.level

	var cost := RecruitManager._get_recruit_cost(_data)
	cost_label.text  = "%d ⚜" % cost


func _on_recruit_pressed() -> void:
	if RecruitManager.recruit(_data):
		queue_free()


func _on_refuse_pressed() -> void:
	RecruitManager.refuse(_data)
	queue_free()
