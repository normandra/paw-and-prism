class_name ProjectileEntity
extends Node3D

signal enemy_hit(enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float)
signal chain_arc_requested(from_pos: Vector3, to_pos: Vector3, col: Color)
signal fork_requested(pos: Vector3, dir: Vector3, cfg: Dictionary, hit_ids: Dictionary)
signal explosion_requested(pos: Vector3, radius: float, cfg: Dictionary)
signal player_hit_by_enemy_proj(dmg: float)

var is_enemy_proj: bool = false
var direction: Vector3 = Vector3(0.0, 0.0, 1.0)
var speed: float = 18.0
var damage: float = 20.0
var hit_radius: float = 0.55
var lifetime: float = 2.0

var pierce_left: int = 0
var chains_left: int = 0
var forks_left: int = 0
var homing: bool = false
var is_boomerang: bool = false
var explodes_radius: float = 0.0

var crit_chance: float = 8.0
var crit_mult: float = 165.0
var is_fire: bool = false
var is_cold: bool = false
var leech_pct: float = 0.0
var proj_color: Color = Color.GOLD
var source_cfg: Dictionary = {}

var _age: float = 0.0
var _hit_ids: Dictionary = {}
var _boomerang_returning: bool = false
var _mesh_pivot: Node3D = null

func setup_player_proj(p_pos: Vector3, p_dir: Vector3, cfg: Dictionary, style: String, already_hit: Dictionary = {}) -> void:
	is_enemy_proj = false
	position = Vector3(p_pos.x, 0.58, p_pos.z)
	direction = Vector3(p_dir.x, 0.0, p_dir.z).normalized()
	if direction.length_squared() < 0.001:
		direction = Vector3(0.0, 0.0, 1.0)
	source_cfg = cfg
	speed = float(cfg.get("proj_speed", 18.0))
	damage = float(cfg.get("damage", 20.0))
	crit_chance = float(cfg.get("crit_chance", 8.0))
	crit_mult = float(cfg.get("crit_mult", 165.0))
	is_fire = float(cfg.get("added_fire_pct", 0.0)) > 0.0 or (cfg.get("tags", []).has(GameEnums.SkillTag.FIRE))
	is_cold = float(cfg.get("added_cold_pct", 0.0)) > 0.0 or (cfg.get("tags", []).has(GameEnums.SkillTag.COLD))
	leech_pct = float(cfg.get("leech_pct", 0.0))

	pierce_left = int(cfg.get("pierce", 0))
	chains_left = int(cfg.get("chains", 0))
	forks_left = int(cfg.get("forks", 0))
	homing = bool(cfg.get("homing", false))
	is_boomerang = (style == "bone")
	explodes_radius = float(cfg.get("area_radius", 2.8)) if style == "fireball" else 0.0
	hit_radius = 0.72 if is_boomerang else 0.56
	lifetime = 2.6 if is_boomerang else (2.4 if homing else 1.8)
	_hit_ids = already_hit.duplicate()

	_build_visual(style)

func setup_enemy_proj(p_pos: Vector3, p_dir: Vector3, p_speed: float, p_dmg: float, p_radius: float, p_col: Color) -> void:
	is_enemy_proj = true
	position = Vector3(p_pos.x, 0.65, p_pos.z)
	direction = Vector3(p_dir.x, 0.0, p_dir.z).normalized()
	speed = p_speed
	damage = p_dmg
	hit_radius = p_radius
	proj_color = p_col
	lifetime = 3.2
	_build_visual("enemy_orb")

func _build_visual(style: String) -> void:
	_mesh_pivot = Node3D.new()
	add_child(_mesh_pivot)
	match style:
		"acorn":
			proj_color = Color(0.86, 0.62, 0.24)
			var body: MeshInstance3D = ChibiMeshFactory._make_part(ChibiMeshFactory._get_sphere(0.20), ChibiMeshFactory.get_toon_mat(proj_color, 0.35), Vector3.ZERO, Vector3.ZERO, Vector3(0.9, 0.9, 1.3), false)
			var cap: MeshInstance3D = ChibiMeshFactory._make_part(ChibiMeshFactory._get_cylinder(0.18, 0.24, 0.12, 8), ChibiMeshFactory.get_toon_mat(Color(0.45, 0.26, 0.14)), Vector3(0.0, 0.0, -0.15), Vector3(90.0, 0.0, 0.0), Vector3.ONE, false)
			_mesh_pivot.add_child(body)
			_mesh_pivot.add_child(cap)
		"petal":
			proj_color = Color(1.0, 0.66, 0.84)
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_box(Vector3(0.32, 0.08, 0.44)), ChibiMeshFactory.get_toon_mat(proj_color, 0.85), Vector3.ZERO, Vector3.ZERO, Vector3.ONE, false))
		"fireball":
			proj_color = Color(1.0, 0.44, 0.14)
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_sphere(0.30), ChibiMeshFactory.get_toon_mat(proj_color, 1.4), Vector3.ZERO, Vector3.ZERO, Vector3.ONE, false))
		"icicle":
			proj_color = Color(0.45, 0.90, 1.0)
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_cylinder(0.02, 0.16, 0.56, 6), ChibiMeshFactory.get_toon_mat(proj_color, 1.1), Vector3.ZERO, Vector3(90.0, 0.0, 0.0), Vector3.ONE, false))
		"bone":
			proj_color = Color(0.98, 0.95, 0.88)
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_box(Vector3(0.68, 0.14, 0.18)), ChibiMeshFactory.get_toon_mat(proj_color, 0.4), Vector3.ZERO, Vector3.ZERO, Vector3.ONE, false))
			for s in [-0.32, 0.32]:
				_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_sphere(0.14), ChibiMeshFactory.get_toon_mat(proj_color, 0.4), Vector3(s, 0.0, 0.0), Vector3.ZERO, Vector3.ONE, false))
		"bee":
			proj_color = Color(1.0, 0.84, 0.22)
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_sphere(0.20), ChibiMeshFactory.get_toon_mat(proj_color, 0.8), Vector3.ZERO, Vector3.ZERO, Vector3(0.9, 0.9, 1.25), false))
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_box(Vector3(0.48, 0.04, 0.18)), ChibiMeshFactory.get_toon_mat(Color(0.95, 0.98, 1.0, 0.8), 0.7), Vector3(0.0, 0.12, 0.0), Vector3.ZERO, Vector3.ONE, false))
		_:
			_mesh_pivot.add_child(ChibiMeshFactory._make_part(ChibiMeshFactory._get_sphere(hit_radius), ChibiMeshFactory.get_toon_mat(proj_color, 1.35), Vector3.ZERO, Vector3.ZERO, Vector3.ONE, false))

func step(delta: float, grid: SpatialGrid, player_pos: Vector3) -> bool:
	_age += delta
	if _age >= lifetime:
		if not is_enemy_proj and explodes_radius > 0.0:
			explosion_requested.emit(global_position, explodes_radius, source_cfg)
		return false

	if is_enemy_proj:
		global_position += direction * speed * delta
		var dx: float = global_position.x - player_pos.x
		var dz: float = global_position.z - player_pos.z
		var reach: float = hit_radius + 0.45
		if dx * dx + dz * dz <= reach * reach:
			player_hit_by_enemy_proj.emit(damage)
			return false
		if absf(global_position.x) > ArenaBuilder.ARENA_HALF_SIZE + 4.0 or absf(global_position.z) > ArenaBuilder.ARENA_HALF_SIZE + 4.0:
			return false
		return true

	# Boomerang motion
	if is_boomerang:
		if not _boomerang_returning:
			var forward_spd: float = speed * maxf(0.0, 1.0 - _age / 0.65)
			global_position += direction * forward_spd * delta
			if _age >= 0.65:
				_boomerang_returning = true
				_hit_ids.clear()
		else:
			var back: Vector3 = player_pos - global_position
			back.y = 0.0
			if back.length() < 1.1:
				return false
			direction = back.normalized()
			global_position += direction * (speed * 1.25) * delta
		if _mesh_pivot != null:
			_mesh_pivot.rotation.y += delta * 18.0
	else:
		# Homing steering
		if homing:
			var nearest: Node3D = grid.find_nearest(global_position, 13.0, _hit_ids)
			if nearest != null:
				var want: Vector3 = nearest.global_position - global_position
				want.y = 0.0
				if want.length_squared() > 0.01:
					direction = direction.lerp(want.normalized(), minf(1.0, delta * 7.5)).normalized()
		global_position += direction * speed * delta
		if _mesh_pivot != null:
			_mesh_pivot.rotation.y = atan2(direction.x, direction.z)

	# Check enemy collision via SpatialGrid
	var hits: Array = grid.query_radius(global_position, hit_radius)
	for e in hits:
		if not is_instance_valid(e) or e.get("is_dead") == true:
			continue
		var eid: int = e.get_instance_id()
		if _hit_ids.has(eid):
			continue
		_hit_ids[eid] = true

		if explodes_radius > 0.0:
			explosion_requested.emit(global_position, explodes_radius, source_cfg)
			return false

		var is_crit: bool = randf() * 100.0 < crit_chance
		var dmg: float = damage * (crit_mult * 0.01 if is_crit else 1.0)
		var extra_elem: float = 1.0 + float(source_cfg.get("added_fire_pct", 0.0)) * 0.01 + float(source_cfg.get("added_cold_pct", 0.0)) * 0.01
		dmg *= extra_elem

		if is_fire and e.has_method("apply_burn"):
			e.apply_burn(dmg * 0.25, 3.0)
		if is_cold and e.has_method("apply_chill"):
			e.apply_chill(2.5)
		e.take_damage(dmg, direction * 3.0)
		enemy_hit.emit(e, dmg, is_crit, is_fire, is_cold, e.global_position, leech_pct)

		if forks_left > 0:
			forks_left -= 1
			fork_requested.emit(global_position, direction, source_cfg, _hit_ids)
			return false

		if chains_left > 0:
			var next_target: Node3D = grid.find_nearest(global_position, 10.0, _hit_ids)
			if next_target != null:
				chains_left -= 1
				chain_arc_requested.emit(global_position, next_target.global_position, proj_color)
				var ndir: Vector3 = next_target.global_position - global_position
				ndir.y = 0.0
				direction = ndir.normalized()
				continue

		if pierce_left > 0:
			pierce_left -= 1
			continue

		if not is_boomerang:
			return false

	return true
