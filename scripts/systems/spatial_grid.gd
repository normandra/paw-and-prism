class_name SpatialGrid

const CELL_SIZE: float = 4.5

var _cells: Dictionary = {}
var _all_enemies: Array = []

func rebuild(enemies: Array) -> void:
	_cells.clear()
	_all_enemies.clear()
	for e in enemies:
		if not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		if e.get("is_dead") == true:
			continue
		_all_enemies.append(e)
		var pos: Vector3 = e.global_position
		var cx: int = int(floor(pos.x / CELL_SIZE))
		var cz: int = int(floor(pos.z / CELL_SIZE))
		var key: Vector2i = Vector2i(cx, cz)
		if not _cells.has(key):
			_cells[key] = []
		var bucket: Array = _cells[key]
		bucket.append(e)

func query_radius(pos: Vector3, radius: float) -> Array:
	var out: Array = []
	var scan_r: float = radius + 2.5
	var min_cx: int = int(floor((pos.x - scan_r) / CELL_SIZE))
	var max_cx: int = int(floor((pos.x + scan_r) / CELL_SIZE))
	var min_cz: int = int(floor((pos.z - scan_r) / CELL_SIZE))
	var max_cz: int = int(floor((pos.z + scan_r) / CELL_SIZE))

	for cx in range(min_cx, max_cx + 1):
		for cz in range(min_cz, max_cz + 1):
			var key: Vector2i = Vector2i(cx, cz)
			if not _cells.has(key):
				continue
			var bucket: Array = _cells[key]
			for e in bucket:
				if not is_instance_valid(e) or e.get("is_dead") == true:
					continue
				var ep: Vector3 = e.global_position
				var dx: float = ep.x - pos.x
				var dz: float = ep.z - pos.z
				var er: float = float(e.get("hit_radius")) if e.get("hit_radius") != null else 0.7
				var combined: float = radius + er
				if dx * dx + dz * dz <= combined * combined:
					out.append(e)
	return out

func find_nearest(pos: Vector3, max_range: float, exclude_ids: Dictionary = {}) -> Node3D:
	var best: Node3D = null
	var best_d_sq: float = max_range * max_range
	for e in _all_enemies:
		if not is_instance_valid(e) or e.get("is_dead") == true:
			continue
		if exclude_ids.has(e.get_instance_id()):
			continue
		var ep: Vector3 = e.global_position
		var dx: float = ep.x - pos.x
		var dz: float = ep.z - pos.z
		var d_sq: float = dx * dx + dz * dz
		if d_sq < best_d_sq:
			best_d_sq = d_sq
			best = e
	return best

func find_densest_cluster_center(pos: Vector3, max_range: float) -> Vector3:
	var candidates: Array = query_radius(pos, max_range)
	if candidates.is_empty():
		return pos + Vector3(0.0, 0.0, 5.0)
	var best_pos: Vector3 = candidates[0].global_position
	var best_score: int = -1
	var step: int = maxi(1, candidates.size() / 12)
	for i in range(0, candidates.size(), step):
		var c: Node3D = candidates[i]
		var nearby: Array = query_radius(c.global_position, 4.0)
		if nearby.size() > best_score:
			best_score = nearby.size()
			best_pos = c.global_position
	return best_pos
