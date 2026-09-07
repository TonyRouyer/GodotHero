## ResearchTreeCanvas.gd
## Zone scrollable de l'arbre de recherche (panneau droit du ResearchPanel).
## Chaque niveau = une colonne. Les icônes sont reliées par des lignes de prérequis.
## Dessin des lignes et des indicateurs visuels via _draw() (derrière les boutons).
extends Control
class_name ResearchTreeCanvas


signal research_selected(research_id: String)


const ICON_SIZE : int = 50
const COL_W     : int = 130
const ROW_H     : int = 82
const PAD_X     : int = 20
const PAD_Y     : int = 14

const _LEVEL_COLORS : Array = [
	Color(0.55, 0.55, 0.65), Color(0.40, 0.70, 0.40),
	Color(0.30, 0.60, 0.85), Color(0.80, 0.65, 0.20),
	Color(0.85, 0.40, 0.20), Color(0.70, 0.20, 0.80),
	Color(0.90, 0.20, 0.30), Color(0.20, 0.75, 0.75),
	Color(1.00, 0.55, 0.00), Color(1.00, 0.85, 0.20),
]

## {id: Vector2} — centre de chaque icône dans l'espace local du canvas
var _centers  : Dictionary = {}
## {id: Button}
var _buttons  : Dictionary = {}

var _selected : String = ""
var _built    : bool   = false


func _ready() -> void:
	ResearchManager.research_changed.connect(_on_state_changed)


# ─────────────────────────────────────────────
#  CONSTRUCTION
# ─────────────────────────────────────────────

func build() -> void:
	if _built:
		_refresh_all()
		queue_redraw()
		return
	_built = true

	var all : Array = ResearchLibrary.get_all()

	## Regroupe par niveau (1–10)
	var by_level : Dictionary = {}
	for r in all:
		var rd := r as ResearchData
		if rd == null:
			continue
		if not by_level.has(rd.level):
			by_level[rd.level] = []
		by_level[rd.level].append(rd)

	## Calcule la hauteur du canvas (doit tenir dans la fenêtre sans scroll vertical)
	var max_count : int = 1
	for lvl in by_level:
		max_count = maxi(max_count, (by_level[lvl] as Array).size())

	var canvas_w : int = 10 * COL_W + PAD_X * 2
	var canvas_h : int = max_count * ROW_H + PAD_Y * 2
	custom_minimum_size = Vector2(canvas_w, canvas_h)

	## Tri anti-croisements : traitement niveau par niveau
	## Les centres provisoires alimentent le tri du niveau suivant.
	var placed_centers : Dictionary = {}

	for lvl in range(1, 11):
		if not by_level.has(lvl):
			continue
		var items : Array = by_level[lvl]
		if lvl > 1:
			items = _sort_by_prereq_y(items, placed_centers, canvas_h)
			by_level[lvl] = items
		## Stocke les centres provisoires de ce niveau pour les niveaux suivants
		var col_h    : int   = items.size() * ROW_H
		var start_y  : float = (canvas_h - col_h) / 2.0
		for i in items.size():
			var rd    : ResearchData = items[i]
			var icon_x : float = PAD_X + (lvl - 1) * COL_W + (COL_W - ICON_SIZE) / 2.0
			var icon_y : float = start_y + i * ROW_H + (ROW_H - ICON_SIZE) / 2.0
			placed_centers[rd.id] = Vector2(icon_x + ICON_SIZE * 0.5, icon_y + ICON_SIZE * 0.5)

	## Construit les widgets avec l'ordre final
	for lvl in range(1, 11):
		if not by_level.has(lvl):
			continue
		var items   : Array = by_level[lvl]
		var col_h   : int   = items.size() * ROW_H
		var start_y : float = (canvas_h - col_h) / 2.0
		for i in items.size():
			var rd    : ResearchData = items[i]
			var icon_x : float = PAD_X + (lvl - 1) * COL_W + (COL_W - ICON_SIZE) / 2.0
			var icon_y : float = start_y + i * ROW_H + (ROW_H - ICON_SIZE) / 2.0
			_centers[rd.id] = Vector2(icon_x + ICON_SIZE * 0.5, icon_y + ICON_SIZE * 0.5)
			_build_icon_widget(rd, Vector2(icon_x, icon_y))

	_refresh_all()
	queue_redraw()


## Trie les items d'un niveau par la Y moyenne de leurs prérequis déjà placés.
## Les items sans prérequis placés se retrouvent au centre (mid_y).
func _sort_by_prereq_y(items: Array, centers: Dictionary, canvas_h: float) -> Array:
	var mid_y : float = canvas_h * 0.5
	var scored : Array = []
	for r in items:
		var rd := r as ResearchData
		if rd == null:
			continue
		var sum_y : float = 0.0
		var count : int   = 0
		for prereq_id : String in rd.prerequisites:
			if centers.has(prereq_id):
				sum_y += centers[prereq_id].y
				count += 1
		scored.append({"rd": rd, "score": sum_y / count if count > 0 else mid_y})
	scored.sort_custom(func(a, b): return a["score"] < b["score"])
	var result : Array = []
	for s in scored:
		result.append(s["rd"])
	return result


func _build_icon_widget(rd: ResearchData, pos: Vector2) -> void:
	## Bouton icône — le nom s'affiche en tooltip au survol
	var btn := Button.new()
	btn.position           = pos
	btn.size               = Vector2(ICON_SIZE, ICON_SIZE)
	btn.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	btn.flat               = true
	btn.focus_mode         = Control.FOCUS_NONE
	btn.expand_icon        = true
	btn.tooltip_text       = rd.label

	if rd.icon_path != "" and ResourceLoader.exists(rd.icon_path):
		btn.icon = load(rd.icon_path) as Texture2D
	else:
		var img := Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGB8)
		img.fill(_LEVEL_COLORS[clampi(rd.level - 1, 0, _LEVEL_COLORS.size() - 1)])
		btn.icon = ImageTexture.create_from_image(img)

	btn.pressed.connect(func(): _on_icon_pressed(rd.id))
	add_child(btn)
	_buttons[rd.id] = btn


# ─────────────────────────────────────────────
#  INTERACTIONS
# ─────────────────────────────────────────────

func _on_icon_pressed(id: String) -> void:
	_selected = id
	_refresh_all()
	research_selected.emit(id)


## Sélectionne visuellement une recherche sans émettre de signal.
func select_silent(id: String) -> void:
	_selected = id
	_refresh_all()


# ─────────────────────────────────────────────
#  RAFRAÎCHISSEMENT D'ÉTAT
# ─────────────────────────────────────────────

func _on_state_changed() -> void:
	_refresh_all()


func _refresh_all() -> void:
	for id in _buttons:
		_apply_button_state(id)
	queue_redraw()


func _apply_button_state(id: String) -> void:
	var btn      : Button = _buttons[id]
	var is_done  : bool   = ResearchManager.is_unlocked(id)
	var is_act   : bool   = ResearchManager.is_active(id)
	var paused   : bool   = ResearchManager.is_paused
	var can_do   : bool   = ResearchManager.can_start(id)

	if is_done:
		btn.modulate = Color(0.50, 1.00, 0.55)   ## vert : débloqué
	elif is_act and not paused:
		btn.modulate = Color(1.00, 0.95, 0.40)   ## jaune vif : en cours
	elif is_act and paused:
		btn.modulate = Color(0.90, 0.65, 0.25)   ## orange : en pause
	elif can_do:
		btn.modulate = Color(1.00, 1.00, 1.00)   ## blanc : disponible
	else:
		btn.modulate = Color(0.30, 0.30, 0.30)   ## gris foncé : verrouillé


# ─────────────────────────────────────────────
#  DESSIN — lignes + indicateurs
# ─────────────────────────────────────────────

func _draw() -> void:
	## 1. Lignes de prérequis (uniquement vers un niveau inférieur — évite les croisements intra-niveau)
	for r in ResearchLibrary.get_all():
		var rd   : ResearchData = r as ResearchData
		if rd == null:
			continue
		var to_c : Vector2 = _centers.get(rd.id, Vector2.ZERO)
		if to_c == Vector2.ZERO:
			continue
		for prereq_id : String in rd.prerequisites:
			var prereq_def : ResearchData = ResearchLibrary.get_definition(prereq_id)
			if prereq_def == null or prereq_def.level >= rd.level:
				continue   ## ignore les dépendances intra-niveau ou circulaires
			var from_c : Vector2 = _centers.get(prereq_id, Vector2.ZERO)
			if from_c == Vector2.ZERO:
				continue
			var prereq_done : bool = ResearchManager.is_unlocked(prereq_id)
			var line_col := Color(0.30, 0.75, 0.30, 0.85) if prereq_done else Color(0.40, 0.40, 0.40, 0.55)
			draw_line(from_c, to_c, line_col, 1.5)

	## 2. Contour sélection (or)
	if _selected != "" and _centers.has(_selected):
		_draw_outline(_centers[_selected], Color(1.00, 0.85, 0.20, 0.95), 2.5)

	## 3. Contour recherche active (cyan / orange si pause) — seulement si ≠ sélection
	var act_id : String = ResearchManager.active_id
	if act_id != "" and _centers.has(act_id) and act_id != _selected:
		var act_col := Color(0.25, 0.90, 1.00, 0.85) if not ResearchManager.is_paused \
		              else Color(0.90, 0.60, 0.20, 0.80)
		_draw_outline(_centers[act_id], act_col, 1.5)


func _draw_outline(center: Vector2, color: Color, width: float) -> void:
	var half : float = ICON_SIZE * 0.5 + 3.0
	draw_rect(Rect2(center.x - half, center.y - half, half * 2.0, half * 2.0), color, false, width)
