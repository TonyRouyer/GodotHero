extends Control

signal gold_changed

@onready var research_ui = $"."
@onready var research_container = $HBoxContainer/DisplaySearchPanel/ScrollContainer/researchItem
@onready var scroll_container = $HBoxContainer/DisplaySearchPanel/ScrollContainer


@onready var current_project_label = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/CurrentSearchLabel
@onready var progress_bar = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/ProgressBar
@onready var start_button = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/ButtonContainer/StartButton
@onready var cancel_button = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/ButtonContainer/CancelButton
@onready var current_search_panel = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel
@onready var description = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/Description
@onready var button_container = $HBoxContainer/InfoPanel/DescriptionPanel/CurrentSearchPanel/ButtonContainer



@onready var tool_tip = $ToolTip
@onready var tool_tip_name = $ToolTip/MarginContainer/Name



var current_research = null
var current_progress = 0
var start_research = false

func _ready():
	research_container.position = Vector2(-100, 0 )
	
	var research_items = research_container.get_children()
	for research in research_items:
		var button_tech = research.get_node("Button")
		var button_hide = research.get_node("ButtonHide")
		var parents = research.parents
		
		draw_tech_sub_text(research)
		

		for parent in parents:
			var parent_node = research_container.get_node(parent)
			draw_tech_ligne(research, parent_node)
		#Si deja rechercher on desactive
		if Global.research_finished.has(research.tech_name):
			button_tech.disabled = true
			button_hide.color = Color(0, 1, 1, 0.5)
		#si tout les prequit ne sont pas completer , on desactive
		if not all_prereqs_completed(research.parents):
			button_tech.disabled = true
			button_hide.color = Color(0, 0, 0, 0.5)
			

		
		button_tech.mouse_entered.connect(_on_research_button_hovered.bind(research))
		button_tech.mouse_exited.connect(_on_research_button_out)
		button_tech.pressed.connect(_on_research_button_pressed.bind(research))
	scroll_container.scroll_vertical = 999999

	connect_signals_recursive(self)

func _process(delta):
	tool_tip.position = get_local_mouse_position()
		
	if current_research != null and start_research:
		current_progress += delta
		progress_bar.value = current_progress
		if current_progress >= progress_bar.max_value:
			complete_research()

func all_prereqs_completed(prerequisites):
	for prereq in prerequisites:
		if not Global.research_finished.has(prereq):
			return false
	return true

func _on_research_button_hovered(research):
	tool_tip.show()
	tool_tip_name.text = research.btn_content

func _on_research_button_out():
	tool_tip.hide()

func _on_research_button_pressed(research):
	current_research = research
	current_project_label.text = research.btn_content
	description.text = research.description
	
	description.show()
	current_project_label.show()
	progress_bar.show()
	button_container.show()

func _on_start_button_pressed():
	if current_research:
		if Global.gold >= current_research.cost:
			#methode qui emmet le signal d'actualisation d'interface des gold
			Global.set_gold(-current_research.cost)
			progress_bar.value = 0
			current_progress = 0
			progress_bar.max_value = current_research.duration  / 100
			start_research = true  # Connect timer or other logic to increment progress
		else:
			print("Not enough gold to start the research")

func _on_cancel_button_pressed():
	current_research = null
	current_project_label.text = ""
	progress_bar.value = 0
	start_research = false
	
	description.hide()
	current_project_label.hide()
	progress_bar.hide()
	button_container.hide()

func complete_research():
	Global.research_finished.append(current_research.tech_name)
	current_research = null
	progress_bar.value = 0
	current_project_label.text = ""
	start_research = false
	update_research_buttons()
	
	description.hide()
	current_project_label.hide()
	progress_bar.hide()
	button_container.hide()
	


func update_research_buttons():
	for research in research_container.get_children():
		var button_tech = research.get_node("Button")
		var button_hide = research.get_node("ButtonHide")

	
		button_tech.disabled = false
		button_hide.color = Color(0, 0, 0, 0)

	
		#Si deja rechercher on desactive
		if Global.research_finished.has(research.tech_name):
			button_tech.disabled = true
			button_hide.color = Color(0, 1, 1, 0.5)
		
		#si tout les prequit ne sont pas completer , on desactive
		if not all_prereqs_completed(research.parents):
			button_tech.disabled = true
			button_hide.color = Color(0, 0, 0, 0.5)

func draw_tech_ligne(node, parent):	
	var line = Line2D.new()
	line.width = 3
	line.default_color  = Color(0,0,0,0.5)
	line.add_point(node.size  /2  )
	line.add_point((parent.position - node.position) + parent.size / 2 )


	node.add_child(line)

func draw_tech_sub_text(tech):
	var tech_icon = tech.get_node("Button")
	
	var tech_btn = Label.new()
	tech_btn.text = tech.btn_content	
	tech_btn.add_theme_font_size_override("font_size", 14)
	tech_btn.z_index = 1
	tech_btn.position.y = 64
	
	tech.add_child(tech_btn)

	
	tech_btn.text = tech.btn_content
	tech_btn.size.x = 0

	tech_btn.position.x = (tech_icon.size.x /2 ) - (tech_btn.size.x /2) 
	

func _on_search_btn_pressed():
	self.visible = !self.visible

func _open_btn_pressed():
	research_ui.visible = !research_ui.visible

func _on_mouse_entered():
	Global.mouse_in_menu = true


func _on_mouse_exited():
	Global.mouse_in_menu = false
	
func connect_signals_recursive(node):
	# Parcourir tous les nœuds enfants
	for child in node.get_children():
		# Vérifier si le nœud a le signal "mouse_entered"
		if child.has_signal("mouse_entered") or child.has_signal("_on_mouse_exited"):
			# Connecter le signal au callback _on_mouse_entered
			child.mouse_entered.connect(_on_mouse_entered)
			child.mouse_exited.connect(_on_mouse_exited)
		
		# Appel récursif pour parcourir tous les enfants du nœud
		connect_signals_recursive(child)
