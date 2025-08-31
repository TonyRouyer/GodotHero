extends TileMapLayer

@onready var wall = %Wall


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _is_used_by_obstacle(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if _is_used_by_obstacle(coords):
		tile_data.set_navigation_polygon(0, null)

func _is_used_by_obstacle(coords: Vector2i) -> bool:
	if coords in wall.get_used_cells():
		var is_obstacle = wall.get_cell_tile_data(coords).get_collision_polygons_count(0) > 0
		if is_obstacle:
			return true
	return false
