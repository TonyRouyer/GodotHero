class_name ResearchData
extends Resource

@export var research_name: String
@export var serialised_name : String
@export_multiline var research_description: String
@export var research_level: int
@export var research_column: float
@export var research_icon: Texture2D
@export var research_prerequsites: Array[ResearchData]
@export var research_cost: int
@export var research_duration: int
