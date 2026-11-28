class_name MinimapWidget
extends Control

var _player_pos: Vector3 = Vector3.ZERO
var _facing_dir: Vector3 = Vector3(0.0, 0.0, 1.0)
var _arena_half: float = ArenaBuilder.ARENA_HALF_SIZE
var _enemy_pts: Array[Dictionary] = []
var _pickup_pts: Array[Dictionary] = []

func _init() -> void:
	name = "MinimapWidget"
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_entities(player_pos: Vector3, facing_dir: Vector3, enemies: Array[EnemyEntity], pickups: Array[WorldPickup], arena_half: float) -> void:
	_player_pos = player_pos
	_facing_dir = facing_dir
	_arena_half = maxf(10.0, arena_half)
	_enemy_pts.clear()
	_pickup_pts.clear()

	for e in enemies:
		if not is_instance_valid(e) or e.is_dead:
			continue
		_enemy_pts.append({
			"x": e.global_position.x,
			"z": e.global_position.z,
			"boss": e.is_boss,
			"elite": e.is_elite,
		})

	for pk in pickups:
		if not is_instance_valid(pk):
			continue
		_pickup_pts.append({
			"x": pk.global_position.x,
			"z": pk.global_position.z,
			"kind": pk.kind,
			"amt": pk.gold_amount,
		})

	queue_redraw()

func _world_to_map(wx: float, wz: float, rect_size: Vector2) -> Vector2:
	var pad: float = 8.0
	var inner_w: float = maxf(20.0, rect_size.x - pad * 2.0)
	var inner_h: float = maxf(20.0, rect_size.y - pad * 2.0)
	var nx: float = clampf((wx / _arena_half) * 0.5 + 0.5, 0.0, 1.0)
	var nz: float = clampf((wz / _arena_half) * 0.5 + 0.5, 0.0, 1.0)
	return Vector2(pad + nx * inner_w, pad + nz * inner_h)

func _draw() -> void:
	var sz: Vector2 = size
	if sz.x < 16.0 or sz.y < 16.0:
		return

	# Backdrop + Border
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0.08, 0.11, 0.09, 0.86), true)
	draw_rect(Rect2(Vector2(1.0, 1.0), sz - Vector2(2.0, 2.0)), Color(0.95, 0.78, 0.34, 0.85), false, 2.0)

	# Arena Fence Perimeter Box & Center Plaza Ring
	var pad: float = 8.0
	var arena_rect: Rect2 = Rect2(Vector2(pad, pad), sz - Vector2(pad * 2.0, pad * 2.0))
	draw_rect(arena_rect, Color(0.16, 0.24, 0.17, 0.90), true)
	draw_rect(arena_rect, Color(0.76, 0.62, 0.38, 0.75), false, 1.5)

	var map_center: Vector2 = sz * 0.5
	var plaza_r: float = (5.0 / _arena_half) * (arena_rect.size.x * 0.5)
	draw_circle(map_center, plaza_r, Color(0.32, 0.30, 0.28, 0.72))

	# Pickups (Gold Coins / Pouches / Chests / Tutorial Cards)
	for pk in _pickup_pts:
		var mp: Vector2 = _world_to_map(float(pk["x"]), float(pk["z"]), sz)
		var pkind: int = int(pk["kind"])
		if pkind == WorldPickup.Kind.CHEST:
			draw_rect(Rect2(mp - Vector2(3.5, 3.0), Vector2(7.0, 6.0)), Color(1.0, 0.86, 0.22), true)
		elif pkind == WorldPickup.Kind.GOLD_COIN:
			var r: float = 2.6 if int(pk["amt"]) >= 10 else 1.7
			draw_circle(mp, r, Color(1.0, 0.86, 0.28, 0.95))
		else:
			draw_circle(mp, 2.8, Color(0.48, 0.94, 1.0, 0.95))

	# Enemies (Critters / Elites / Bosses)
	for ep in _enemy_pts:
		var mp: Vector2 = _world_to_map(float(ep["x"]), float(ep["z"]), sz)
		if bool(ep["boss"]):
			draw_circle(mp, 5.2, Color(1.0, 0.24, 0.22, 0.95))
			draw_arc(mp, 6.8, 0.0, TAU, 16, Color(1.0, 0.84, 0.26, 0.90), 1.5)
		elif bool(ep["elite"]):
			draw_circle(mp, 3.4, Color(0.84, 0.42, 1.0, 0.95))
		else:
			draw_circle(mp, 1.9, Color(0.96, 0.34, 0.30, 0.88))

	# Mochi (Player) Dot + Facing Pointer
	var p_pt: Vector2 = _world_to_map(_player_pos.x, _player_pos.z, sz)
	var dir2: Vector2 = Vector2(_facing_dir.x, _facing_dir.z)
	if dir2.length_squared() > 0.01:
		dir2 = dir2.normalized()
	else:
		dir2 = Vector2(0.0, 1.0)
	var tip: Vector2 = p_pt + dir2 * 6.5
	draw_line(p_pt, tip, Color(1.0, 0.96, 0.65), 2.2)
	draw_circle(p_pt, 3.6, Color(0.32, 0.94, 1.0))
	draw_arc(p_pt, 3.8, 0.0, TAU, 14, Color(1.0, 1.0, 1.0, 0.95), 1.3)
