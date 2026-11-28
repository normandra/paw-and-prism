class_name AreaEffectEntity
extends Node3D

signal enemy_hit(enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float)
signal player_telegraph_hit(dmg: float)

enum Kind {
	PLAYER_NOVA,
	METEOR_STRIKE,
	LIGHTNING_ARC,
	ENEMY_TELEGRAPH,
}

var kind: int = Kind.PLAYER_NOVA
var radius: float = 4.0
var damage: float = 25.0
var crit_chance: float = 10.0
var crit_mult: float = 165.0
var is_fire: bool = false
var is_cold: bool = false
var leech_pct: float = 0.0
var apply_slow: bool = false
var apply_burn: bool = false
var pull_inward: bool = false
var burn_dps_mult: float = 1.0
var burn_dur_bonus: float = 0.0
var chilled_vuln_mult: float = 1.0

var _timer: float = 0.0
var _duration: float = 0.4
var _detonated: bool = false
var _ring_mesh: MeshInstance3D = null
var _fill_mesh: MeshInstance3D = null
var _meteor_mesh: MeshInstance3D = null
var _color: Color = Color.GOLD

func setup_player_nova(p_pos: Vector3, p_radius: float, p_dmg: float, p_crit_c: float, p_crit_m: float, p_col: Color, p_fire: bool, p_cold: bool, p_leech: float, grid: SpatialGrid, player_pos: Vector3) -> void:
	kind = Kind.PLAYER_NOVA
	position = p_pos
	radius = p_radius
	damage = p_dmg
	crit_chance = p_crit_c
	crit_mult = p_crit_m
	is_fire = p_fire
	is_cold = p_cold
	leech_pct = p_leech
	_color = p_col
	_duration = 0.34
	_timer = 0.0

	_ring_mesh = MeshInstance3D.new()
	_ring_mesh.mesh = ChibiMeshFactory._get_torus(0.75, 1.0)
	_ring_mesh.material_override = ChibiMeshFactory.get_unshaded_mat(Color(p_col.r, p_col.g, p_col.b, 0.78), true)
	_ring_mesh.position = Vector3(0.0, 0.14, 0.0)
	_ring_mesh.scale = Vector3(0.3, 0.3, 0.3)
	_ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring_mesh)

	_apply_player_aoe(grid, player_pos)
	_detonated = true

func setup_meteor(p_pos: Vector3, p_radius: float, p_dmg: float, p_crit_c: float, p_crit_m: float, p_cold: bool, p_leech: float) -> void:
	kind = Kind.METEOR_STRIKE
	position = p_pos
	radius = p_radius
	damage = p_dmg
	crit_chance = p_crit_c
	crit_mult = p_crit_m
	is_fire = true
	is_cold = p_cold
	leech_pct = p_leech
	_duration = 0.42
	_timer = 0.0

	# Ground target ring
	_ring_mesh = MeshInstance3D.new()
	_ring_mesh.mesh = ChibiMeshFactory._get_torus(p_radius * 0.88, p_radius)
	_ring_mesh.material_override = ChibiMeshFactory.get_unshaded_mat(Color(1.0, 0.42, 0.16, 0.70), true)
	_ring_mesh.position = Vector3(0.0, 0.06, 0.0)
	_ring_mesh.scale = Vector3(1.0, 0.25, 1.0)
	_ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring_mesh)

	# Falling blazing pinecone
	_meteor_mesh = MeshInstance3D.new()
	_meteor_mesh.mesh = ChibiMeshFactory._get_sphere(0.85, 10, 6)
	_meteor_mesh.material_override = ChibiMeshFactory.get_toon_mat(Color(1.0, 0.48, 0.12), 1.4, 0.3)
	_meteor_mesh.position = Vector3(0.0, 12.0, 0.0)
	_meteor_mesh.scale = Vector3(0.9, 1.35, 0.9)
	_meteor_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_meteor_mesh)

func setup_lightning_arc(from_pos: Vector3, to_pos: Vector3, p_col: Color) -> void:
	kind = Kind.LIGHTNING_ARC
	position = (from_pos + to_pos) * 0.5
	position.y = 0.7
	_duration = 0.16
	_timer = 0.0

	var diff: Vector3 = to_pos - from_pos
	diff.y = 0.0
	var length: float = maxf(0.2, diff.length())
	var bar: MeshInstance3D = MeshInstance3D.new()
	bar.mesh = ChibiMeshFactory._get_box(Vector3(0.18, 0.18, length))
	bar.material_override = ChibiMeshFactory.get_unshaded_mat(p_col)
	bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(bar)
	rotation.y = atan2(diff.x, diff.z)

func setup_enemy_telegraph(p_pos: Vector3, p_radius: float, p_windup: float, p_dmg: float, p_col: Color) -> void:
	kind = Kind.ENEMY_TELEGRAPH
	position = Vector3(p_pos.x, 0.0, p_pos.z)
	radius = p_radius
	damage = p_dmg
	_duration = maxf(0.35, p_windup)
	_timer = 0.0
	_color = p_col

	_ring_mesh = MeshInstance3D.new()
	_ring_mesh.mesh = ChibiMeshFactory._get_torus(p_radius * 0.88, p_radius)
	_ring_mesh.material_override = ChibiMeshFactory.get_unshaded_mat(Color(p_col.r, p_col.g, p_col.b, 0.85), true)
	_ring_mesh.position = Vector3(0.0, 0.06, 0.0)
	_ring_mesh.scale = Vector3(1.0, 0.2, 1.0)
	_ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring_mesh)

	_fill_mesh = MeshInstance3D.new()
	_fill_mesh.mesh = ChibiMeshFactory._get_cylinder(p_radius, p_radius, 0.04, 16)
	_fill_mesh.material_override = ChibiMeshFactory.get_unshaded_mat(Color(p_col.r, p_col.g, p_col.b, 0.34), true)
	_fill_mesh.position = Vector3(0.0, 0.04, 0.0)
	_fill_mesh.scale = Vector3(0.05, 1.0, 0.05)
	_fill_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_fill_mesh)

func step(delta: float, grid: SpatialGrid, player_pos: Vector3) -> bool:
	_timer += delta
	var t: float = clampf(_timer / _duration, 0.0, 1.0)

	match kind:
		Kind.PLAYER_NOVA:
			if _ring_mesh != null:
				var s: float = lerpf(0.35, radius, t)
				_ring_mesh.scale = Vector3(s, 0.35 * (1.0 - t * 0.6), s)
			if _timer >= _duration:
				return false
		Kind.METEOR_STRIKE:
			if not _detonated:
				if _meteor_mesh != null:
					_meteor_mesh.position.y = lerpf(12.0, 0.4, t * t)
				if _timer >= _duration:
					_detonated = true
					_apply_player_aoe(grid, player_pos)
					if _meteor_mesh != null:
						_meteor_mesh.visible = false
					if _ring_mesh != null:
						_ring_mesh.material_override = ChibiMeshFactory.get_toon_mat(Color(1.0, 0.82, 0.25, 0.85), 1.6, 0.2)
					_timer = 0.0
					_duration = 0.24
					kind = Kind.PLAYER_NOVA
			return true
		Kind.LIGHTNING_ARC:
			if _timer >= _duration:
				return false
		Kind.ENEMY_TELEGRAPH:
			if not _detonated:
				if _fill_mesh != null:
					_fill_mesh.scale = Vector3(t, 1.0, t)
				if _timer >= _duration:
					_detonated = true
					var dx: float = player_pos.x - global_position.x
					var dz: float = player_pos.z - global_position.z
					if dx * dx + dz * dz <= radius * radius:
						player_telegraph_hit.emit(damage)
					if _fill_mesh != null:
						_fill_mesh.material_override = ChibiMeshFactory.get_toon_mat(Color(1.0, 0.92, 0.85, 0.65), 1.8, 0.2)
					_timer = 0.0
					_duration = 0.18
					kind = Kind.LIGHTNING_ARC
			return true

	return true

func _apply_player_aoe(grid: SpatialGrid, player_pos: Vector3) -> void:
	var center_pos: Vector3 = global_position if is_inside_tree() else position
	var targets: Array = grid.query_radius(center_pos, radius)
	for e in targets:
		if not is_instance_valid(e) or e.get("is_dead") == true:
			continue
		var is_crit: bool = randf() * 100.0 < crit_chance
		var chill_bonus: float = chilled_vuln_mult if float(e.get("_chill_timer")) > 0.0 else 1.0
		var dmg: float = damage * chill_bonus * (crit_mult * 0.01 if is_crit else 1.0)
		var kb: Vector3 = Vector3.ZERO
		if pull_inward:
			var pull: Vector3 = center_pos - e.global_position
			pull.y = 0.0
			if pull.length_squared() > 0.04:
				kb = pull.normalized() * minf(5.0, pull.length() * 1.4)
		else:
			kb = e.global_position - player_pos
			kb.y = 0.0
			kb = kb.normalized() * 3.8 if kb.length_squared() > 0.01 else Vector3.ZERO
		if (is_fire or apply_burn) and e.has_method("apply_burn"):
			e.apply_burn(dmg * 0.28 * burn_dps_mult, 3.0 + burn_dur_bonus)
		if (is_cold or apply_slow) and e.has_method("apply_chill"):
			e.apply_chill(2.5)
		e.take_damage(dmg, kb)
		enemy_hit.emit(e, dmg, is_crit, is_fire, is_cold, e.global_position, leech_pct)
