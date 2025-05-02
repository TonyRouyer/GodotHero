extends Control

signal gold_changed

@onready var research_container : Control = %ResearchItems
@onready var current_project_label : Label = %CurrentSearchLabel
@onready var progress_bar : ProgressBar = %CurrentSearchProgressBar
@onready var description : TextEdit = %CurrentSearchDescription
@onready var button_container : HBoxContainer = %ButtonContainer
@onready var tool_tip : PanelContainer = $ToolTip
@onready var research_timer : Timer = %ResearchTimer

var start_research : bool = false
var current_research : String = ""
var selected_research : String = ""
var not_finished_research : Dictionary = {}


func _ready() -> void:
	add_to_group("UI")
	research_container.position = Vector2(-100, 0 )
	var research_items = GameData.get_all_file_paths("res://Scenes/Research/ResearchResources/")
	var margin = Vector2(64,64)
	var save_y_size: int = 0
	
	for research in research_items:
		var research_data = load(research) # recupere la ressource  ResearchData
		var research_node = ResearchNode.new() # crée le node (textureButton)
		research_node.init(research_data, Vector2(64,64)) # puis initie les data du node avec la ressource precedement chargé
		research_node.size = Vector2(64,64)
		research_container.add_child(research_node)
		var level = research_node.data.research_level
		var research_column = research_node.data.research_column
		
		# --- 1) Calcul de la position Y en fonction du level ---
		# exemple y_pos = 64 + (2 - 1) * (64 + 64) = 192
		var y_pos = margin.y + (level - 1) * (research_node.size.y + margin.y)
		# --- 2) Calcul de la position X en fonction de la colonne definie ---
		var x_pos = margin.x + (research_column - 1 ) * (research_node.size.x + margin.y) 
		research_node.position = Vector2(x_pos, y_pos)
		
		#Si deja rechercher on desactive
		#var research_name = research_node.data.serialised_name
		if GameData.research_finished.has(research_node.data.serialised_name):
			research_node.disabled = true
			research_node.self_modulate  = Color(1, 1, 1, 0.5)
			
		#si tout les prequit ne sont pas completer , on desactive
		if not all_prereqs_completed(research_node.data.research_prerequsites):
			research_node.disabled = true
			research_node.self_modulate = Color(1, 1, 1, 0.5)
			
		#Affiche le nom du node sous ce dernier
		#draw_tech_sub_text(research_node)
			
		#Affiche les nodes au dessus des ligne
		research_node.z_index = 1
		
		#connecte les signal pour afficher le tool tip
		research_node.connect("mouse_entered" , _on_research_button_hovered.bind(research_node.data.research_name))
		research_node.connect("mouse_exited" , _on_research_button_out)
		research_node.connect("pressed", _on_research_button_pressed.bind(research_node.data))
		
		#Redimentionne correctement l enfant du scroll node en Y
		if y_pos > save_y_size:
			save_y_size = y_pos
		research_container.custom_minimum_size.y = (save_y_size + 128)
	
	draw_tech_ligne()


func _process(_delta) -> void:
	tool_tip.position = get_local_mouse_position() + Vector2(15,15)


func complete_research() -> void:
	print('just complete: ', current_research)
	GameData.research_finished.append(current_research)
	not_finished_research.erase(current_research)  # Supprime la recherche complétée
	start_research = false
	update_research_buttons()
	button_container.visible = false


func update_research_buttons() -> void:
	var nodes = get_tree().get_nodes_in_group("ResearchNode")
	for research_node in nodes:
		if research_node is TextureButton:
			research_node.disabled = false
			research_node.self_modulate = Color(1, 1, 1, 1)

			#Si deja rechercher on desactive
			if GameData.research_finished.has(research_node.data.serialised_name):
				research_node.disabled = true
				research_node.self_modulate = Color(1, 1, 1, 0.5)
			
			#si tout les prequit ne sont pas completer , on desactive
			if not all_prereqs_completed(research_node.data.research_prerequsites):
				research_node.disabled = true
				research_node.self_modulate = Color(1, 1, 1, 0.5)


func draw_tech_ligne() -> void:
	var nodes = get_tree().get_nodes_in_group("ResearchNode")
	for node in nodes:
		var parents = node.data.research_prerequsites
		for parent_resource in parents:
			var parent = research_container.get_node(parent_resource.serialised_name)
			var line = Line2D.new()
			line.width = 3
			line.default_color  = Color(0,0,0,0.5)
			line.add_point(node.position + (node.size / 2))
			line.add_point( parent.position  + (parent.size / 2))
			node.get_parent().add_child(line)


func all_prereqs_completed(prerequisites : Array[ResearchData]) -> bool:
	for prereq in prerequisites:
		if not GameData.research_finished.has(prereq.serialised_name):
			return false
	return true


func save_current_research() -> void:
	if current_research != "" and selected_research == current_research:
		not_finished_research[current_research] = {
			'time_left' : progress_bar.value,
			'max_value' : progress_bar.max_value
		}


#Affiche ou maque l'interface de recherches
func _open_btn_pressed() -> void:
	if !self.visible:
		GameData.hide_ui()
		GameData.construction_type = ""
	self.visible = !self.visible
	GameData.menu_open = !GameData.menu_open


#Affiche les data d'une recherche quand on la selectione
func _on_research_button_pressed(research) -> void:
	print("toto")
	save_current_research()
	if research.serialised_name != selected_research:
		selected_research = research.serialised_name
		current_project_label.text = research.research_name
		description.text = research.research_description
		progress_bar.max_value = research.research_duration
		
		# Si cette recherche avait déjà été lancée, affiche sa progression sauvegardée,
		if not_finished_research.has(selected_research):
			progress_bar.value = not_finished_research[selected_research].time_left
			progress_bar.max_value = not_finished_research[selected_research].max_value
		# sinon on démarre à 0.
		else:
			progress_bar.value = 0
		
		description.show()
		current_project_label.show()
		progress_bar.show()
		button_container.show()


#function qui lance une recherche
func _on_start_button_pressed() -> void:
	save_current_research()
	if selected_research:
		var research_data = research_container.get_node(selected_research).data
		var research_name = research_data.serialised_name
		var research_cost = research_data.research_cost
		var research_duration = research_data.research_duration
			
		# Si la recherche n'est pas déjà dans le dictionnaire, on l'initialise
		if not not_finished_research.has(research_name):
			if GameData.gold >= research_cost and start_research == false:
				GameData.set_gold(-research_cost)
				progress_bar.max_value = research_duration 
		# La recherche a déjà été lancée (et possiblement sauvegardée lors d'un switch) : on reprend le temps restant
		else:
			progress_bar.value = not_finished_research[research_name].time_left
			
		start_research = true
		current_research = research_name
		not_finished_research[research_name] = {
			'time_left' : 0,
			'max_value' : research_duration
		}
		research_timer.start()


func _on_pause_button_pressed():
	save_current_research()
	research_timer.stop()
	start_research = false


func _on_research_button_hovered(research_name) -> void:
	tool_tip.show()
	tool_tip.get_node("MarginContainer/ToolTipName").text = str(research_name)



func _on_research_button_out() -> void:
	tool_tip.hide()


func _on_timer_timeout():
	#Si on a commencer une recherche et que la recherche selectionné est celle qui est en cours
	if start_research and current_research == selected_research:
		progress_bar.value += 1
		not_finished_research[current_research].time_left += 1
		if progress_bar.value >= progress_bar.max_value:
			complete_research()
		
	#Si une recherche est en cours mais que on ne l'a pas selectionné
	if start_research and current_research != selected_research:
		if not_finished_research.has(current_research):
			not_finished_research[current_research].time_left += 1
			if not_finished_research[current_research].time_left >= not_finished_research[current_research].max_value:
				complete_research()
