## planning_row.gd
## Ligne de planning : nom du héros + 24 blocs de couleur cliquables (1 par heure).
extends HBoxContainer


const ACTIVITY_COLORS := {
	"sleep": Color(0.20, 0.30, 0.70),
	"work":  Color(0.80, 0.55, 0.10),
	"train": Color(0.15, 0.60, 0.25),
	"free":  Color(0.40, 0.40, 0.45),
}

@onready var name_label      : Label        = $NameLabel
@onready var hours_container : HBoxContainer = $HoursContainer

var _data      : HeroData = null
var _panel_ref : Node     = null
var _blocks    : Array[ColorRect] = []


func setup(hero_data: HeroData, panel_ref: Node) -> void:
	_data      = hero_data
	_panel_ref = panel_ref
	name_label.text = hero_data.hero_name.left(10)
	name_label.mouse_filter = Control.MOUSE_FILTER_STOP
	name_label.mouse_entered.connect(_on_name_hover_enter)
	name_label.mouse_exited.connect(_on_name_hover_exit)
	name_label.gui_input.connect(_on_name_clicked)

	for h in range(24):
		var block : ColorRect = ColorRect.new()
		block.custom_minimum_size = Vector2(17, 22)
		block.mouse_filter = Control.MOUSE_FILTER_STOP
		var hour : int = h
		block.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_block_clicked(hour)
		)
		hours_container.add_child(block)
		_blocks.append(block)

	refresh()


func _on_name_clicked(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not _panel_ref:
		return
	var preset : String = _panel_ref.get_selected_preset()
	if preset == "":
		return
	_panel_ref._apply_preset_to_hero(_data.hero_id)


func _on_name_hover_enter() -> void:
	if _panel_ref and _panel_ref.get_selected_preset() != "":
		name_label.modulate = Color(1.0, 0.85, 0.3)


func _on_name_hover_exit() -> void:
	name_label.modulate = Color.WHITE


func refresh() -> void:
	if not _data:
		return
	for h in range(24):
		_apply_color(_blocks[h], _data.planning.get(h, "free"), h == TimeManager.current_hour)


func _on_block_clicked(hour: int) -> void:
	if not _panel_ref or not _data:
		return
	var activity : String = _panel_ref.get_selected_activity()
	if activity == "":
		return
	_data.planning[hour] = activity
	_apply_color(_blocks[hour], activity, hour == TimeManager.current_hour)


func _apply_color(block: ColorRect, activity: String, is_current: bool) -> void:
	var base : Color = ACTIVITY_COLORS.get(activity, ACTIVITY_COLORS["free"])
	block.color = base.lightened(0.25) if is_current else base


func highlight_current_hour(hour: int) -> void:
	for h in range(24):
		_apply_color(_blocks[h], _data.planning.get(h, "free"), h == hour)
