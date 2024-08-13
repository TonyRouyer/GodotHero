# research_data.gd
extends Resource

class_name ResearchData

@export var name: String
@export var description: String
@export var prerequisites: Array[String]
@export var cost: int
@export var duration: int
