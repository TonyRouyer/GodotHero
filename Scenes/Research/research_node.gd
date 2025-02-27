class_name ResearchNode
extends TextureButton

@export var data: ResearchData
@export var checked: bool = false


func _ready() -> void:
	add_to_group("ResearchNode")
	if data:
		stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_normal = data.research_icon
		self.name = get_resource_name(data)

func init(d: ResearchData, cms: Vector2) -> void:
	data = d
	custom_minimum_size = cms
	checked = false

func get_resource_name(resource: Resource):
	return resource.resource_path.get_file().trim_suffix('.tres')
