## ConstructionInput.gd
## Gère tous les inputs souris en mode construction.
## Séparé de ConstructionLayer pour isoler la logique d'entrée.
##
## Modes de placement :
##   OBJET      → clic simple (pas de drag)
##   MUR        → drag → rectangle CREUX (contour uniquement)
##   SOL        → drag → rectangle PLEIN
##   DESTRUCTION → drag → rectangle plein
##
## Comportement du drag :
##   - Bouton gauche maintenu → preview dynamique
##   - Relâchement → exécute la construction
extends Node2D


# ─────────────────────────────────────────────
#  RÉFÉRENCES
# ─────────────────────────────────────────────
@onready var grid    : Node2D = $"../Grid"
@onready var preview : Node2D = $"../Preview"

var _start_pos   : Vector2i = Vector2i.ZERO
var _is_dragging : bool     = false


# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not _in_construction_mode():
		return

	var cell = grid.get_hovered_cell()
	
	# ── CLIC GAUCHE PRESSÉ ────────────────────────────────────────
	if event.is_action_pressed("click"):
		match GameData.construction_type:
			"object", "door":
				## Placement direct au clic, pas de drag
				_execute_construction(cell, cell)
				return
			"move":
				_handle_move_click(cell)
				return
			_:
				## Murs / sols / destruction : début du drag
				_start_pos   = cell
				_is_dragging = true
				preview.start_selection(_start_pos)

	# ── CLIC GAUCHE RELÂCHÉ ───────────────────────────────────────
	if event.is_action_released("click") and _is_dragging:
		_is_dragging = false
		var end_pos = cell
		preview.end_selection()
		_execute_construction(_start_pos, end_pos)

	# ── CLIC DROIT : annule le mode construction ──────────────────
	if event.is_action_pressed("click_cancel") or event.is_action_pressed("ui_cancel"):
		_cancel()

	# ── R : rotation ───────────────────────────────────────────────
	if event.is_action_pressed("rotate"):
		GameData.construction_rotation = (GameData.construction_rotation + 1) % 4
		preview.refresh_rotation(GameData.construction_rotation)


func _in_construction_mode() -> bool:
	return GameData.construction_type != "" and not UIState.menu_open


# ─────────────────────────────────────────────
#  EXÉCUTION
# ─────────────────────────────────────────────
func _execute_construction(start: Vector2i, end: Vector2i) -> void:
	match GameData.construction_type:
		"wall":
			## Rectangle creux (contour uniquement)
			var positions = _get_wall_positions(start, end)
			ConstructionManager.request_wall(GameData.construction_item, positions)
		"door":
			## Placement unique (une seule case)
			ConstructionManager.request_wall(GameData.construction_item, [start])
		"floor":
			## Rectangle plein
			var positions = _get_rect_positions(start, end)
			ConstructionManager.request_floor(GameData.construction_item, positions)
		"object":
			ConstructionManager.request_object(
				GameData.construction_item, start, GameData.construction_rotation
			)
		"destroy_all":
			ConstructionManager.request_destroy_all(_get_rect_positions(start, end))
		"destroy_wall":
			ConstructionManager.request_destroy_wall(_get_rect_positions(start, end))
		"destroy_floor":
			ConstructionManager.request_destroy_floor(_get_rect_positions(start, end))
		"destroy_object":
			ConstructionManager.request_destroy_object(_get_rect_positions(start, end))


func _handle_move_click(cell: Vector2i) -> void:
	if ConstructionManager.request_move_object(
		GameData.construction_item, cell, GameData.construction_rotation
	):
		_finish_move_mode()


## Termine le mode déplacement après placement réussi (sans restaurer).
func _finish_move_mode() -> void:
	_is_dragging = false
	GameData.construction_type     = ""
	GameData.construction_item     = ""
	GameData.construction_rotation = 0
	grid.visible = false
	preview.reset()
	EventBus.construction_mode_changed.emit("", "")


func _cancel() -> void:
	## ESC en mode déplacement → restaure l'objet à son emplacement d'origine
	if GameData.construction_type == "move":
		ConstructionManager.restore_object(
			GameData.construction_item,
			GameData.move_original_origin,
			GameData.construction_rotation
		)
	_is_dragging = false
	GameData.construction_type     = ""
	GameData.construction_item     = ""
	GameData.construction_rotation = 0
	grid.visible = false
	preview.reset()
	EventBus.construction_mode_changed.emit("", "")


# ─────────────────────────────────────────────
#  CALCUL DES POSITIONS
# ─────────────────────────────────────────────

## Contour du rectangle (utilisé pour les murs)
## → 1 case si start == end, ligne si 1D, contour si 2D
func _get_wall_positions(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
	var min_x = min(start.x, end.x)
	var max_x = max(start.x, end.x)
	var min_y = min(start.y, end.y)
	var max_y = max(start.y, end.y)

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			## Case unique ou ligne → tout inclus
			## Rectangle 2D → contour uniquement
			if x == min_x or x == max_x or y == min_y or y == max_y:
				positions.append(Vector2i(x, y))
	return positions


## Rectangle plein (utilisé pour les sols et destructions)
func _get_rect_positions(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
	var min_x = min(start.x, end.x)
	var max_x = max(start.x, end.x)
	var min_y = min(start.y, end.y)
	var max_y = max(start.y, end.y)

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			positions.append(Vector2i(x, y))
	return positions
