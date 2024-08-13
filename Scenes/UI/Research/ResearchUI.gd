extends Control

signal gold_changed

@onready var research_container = $Panel/ScrollContainer/researchItem
@onready var current_project_label = $PanelContainer/MarginContainer/VBoxContainer/CurrentSearchLabel
@onready var progress_bar = $PanelContainer/MarginContainer/VBoxContainer/ProgressBar
@onready var start_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var cancel_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelButton
@onready var tool_tip = $ToolTip
@onready var tool_tip_name = $ToolTip/MarginContainer/Name

var current_research = null
var current_research_id = null
var current_progress = 0
var start_research = false

func _ready():
	display_research_tree()

func _process(delta):
	tool_tip.position = get_global_mouse_position()
	if current_research != null and start_research:
		current_progress += delta
		progress_bar.value = current_progress
		if current_progress >= progress_bar.max_value:
			complete_research()

func display_research_tree():
	var research_lists = ResearchGobal.get_all_research()
	for research_id in research_lists.keys():
		var research = ResearchGobal.get_research(research_id)
		
		if global.research_finished.has(research["research_name"]):
			continue
	
		var research_pos = research["pos"]
		var research_button = TextureButton.new()
		research_button.texture_normal = load("res://Sprites/Interface/research/" + research["icon"])
		research_button.name = research_id
		research_button.position = Vector2(research_pos[0], research_pos[1])
		
		research_button.mouse_entered.connect(_on_research_button_hovered.bind(research["research_name"]))
		research_button.mouse_exited.connect(_on_research_button_out)
		research_button.modulate = Color(1, 1, 1, 0.5)
		
		research_button.pressed.connect(_on_research_button_pressed.bind(research_id, research))
		research_container.add_child(research_button)
		
		research_button.disabled = true
		if all_prereqs_completed(research["prerequisites"]):
			research_button.disabled = false
			research_button.modulate = Color(1, 1, 1)
		if global.research_finished.has(research_id):
			research_button.disabled = true
			research_button.modulate = Color(1, 1, 1, 0.5)

func all_prereqs_completed(prerequisites):
	for prereq in prerequisites:
		if not global.research_finished.has(prereq):
			return false
	return true

func _on_research_button_hovered(research):
	tool_tip.show()
	tool_tip_name.text = research

func _on_research_button_out():
	tool_tip.hide()

func _on_research_button_pressed(research_id, research):
	current_research = research
	current_research_id = research_id
	current_project_label.text = research["research_name"]

func _on_start_button_pressed():
	if current_research:
		if global.gold >= current_research["cost"]:
			#methode qui emmet le signal d'actualisation d'interface des gold
			global.set_gold(-current_research["cost"])
			progress_bar.value = 0
			current_progress = 0
			progress_bar.max_value = current_research["duration"]  / 100
			start_research = true  # Connect timer or other logic to increment progress
		else:
			print("Not enough gold to start the research")

func _on_cancel_button_pressed():
	current_research = null
	current_research_id = null
	current_project_label.text = ""
	progress_bar.value = 0
	start_research = false

func complete_research():
	print("Research complete: ", current_research["research_name"])
	global.research_finished.append(current_research_id)
	current_research = null
	current_research_id = null
	progress_bar.value = 0
	current_project_label.text = ""
	start_research = false
	update_research_buttons()

func update_research_buttons():
	for research_button in research_container.get_children():
		var research_id = research_button.name
		var research = ResearchGobal.get_research(research_id)

		research_button.modulate = Color(1, 1, 1, 0.5)
		research_button.disabled = true
			
		if all_prereqs_completed(research["prerequisites"]):
			research_button.disabled = false
			research_button.modulate = Color(1, 1, 1)
			
		if global.research_finished.has(research_id):
			research_button.disabled = true
			research_button.modulate = Color(1, 1, 1, 0.5)

func _on_search_btn_pressed():
	self.visible = !self.visible
