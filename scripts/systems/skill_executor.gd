class_name SkillExecutor
extends Node

signal damage_dealt(pos: Vector3, amount: float, is_crit: bool, is_fire: bool, is_cold: bool, leech_amount: float)
signal skill_casted(skill_id: String)

var world_root: Node3D = null
var grid: SpatialGrid = null
var stats: HeroStats = null

var _projs: Array[ProjectileEntity] = []
var _areas: Array[AreaEffectEntity] = []
var _cooldowns: Dictionary = {}
var _echo_queue: Array[Dictionary] = []

# Orbiting stars managed per active starlight_orb config uid
var _orbit_groups: Dictionary = {} # uid -> {"nodes": Array[MeshInstance3D], "angle": float, "hit_cd": Dictionary}
var _spiral_phase: float = 0.0

func setup(p_world: Node3D, p_grid: SpatialGrid, p_stats: HeroStats) -> void:
	world_root = p_world
	grid = p_grid
	stats = p_stats
	clear_all()

func clear_all() -> void:
	for p in _projs:
		if is_instance_valid(p):
			p.queue_free()
	_projs.clear()
	for a in _areas:
		if is_instance_valid(a):
			a.queue_free()
	_areas.clear()
	_cooldowns.clear()
	_echo_queue.clear()
	for k in _orbit_groups.keys():
		var grp: Dictionary = _orbit_groups[k]
		for n in grp["nodes"]:
			if is_instance_valid(n):
				n.queue_free()
	_orbit_groups.clear()

func get_cooldown_fraction(skill_uid: int) -> float:
	if stats == null:
		return 1.0
	for cfg in stats.active_skill_configs:
		if int(cfg["uid"]) == skill_uid:
			var cd_max: float = maxf(0.1, float(cfg["cooldown"]))
			var rem: float = float(_cooldowns.get(skill_uid, 0.0))
			return clampf(1.0 - rem / cd_max, 0.0, 1.0)
	return 1.0

func step(delta: float, player_pos: Vector3, player_ctrl: PlayerController) -> void:
	if stats == null or world_root == null:
		return

	# Process delayed Echo casts
	for i in range(_echo_queue.size() - 1, -1, -1):
		_echo_queue[i]["delay"] = float(_echo_queue[i]["delay"]) - delta
		if float(_echo_queue[i]["delay"]) <= 0.0:
			var cfg: Dictionary = _echo_queue[i]["cfg"]
			_echo_queue.remove_at(i)
			_trigger_skill(cfg, player_pos, true)

	# Manage Orbit skills & trigger Active Skills
	var active_orbit_uids: Dictionary = {}
	for cfg in stats.active_skill_configs:
		var uid: int = int(cfg["uid"])
		var gid: String = String(cfg["gem_id"])
		if gid == "starlight_orb":
			active_orbit_uids[uid] = true
			_step_orbit_skill(cfg, delta, player_pos)
			continue

		var rem: float = float(_cooldowns.get(uid, 0.0)) - delta
		if rem <= 0.0:
			var fired: bool = _trigger_skill(cfg, player_pos, false)
			if fired:
				_cooldowns[uid] = float(cfg["cooldown"])
				if bool(cfg.get("echo", false)):
					_echo_queue.append({"delay": 0.16, "cfg": cfg})
			else:
				_cooldowns[uid] = 0.15
		else:
			_cooldowns[uid] = rem

	# Clean up removed orbit skills
	for uid_key in _orbit_groups.keys():
		if not active_orbit_uids.has(uid_key):
			var grp: Dictionary = _orbit_groups[uid_key]
			for n in grp["nodes"]:
				if is_instance_valid(n):
					n.queue_free()
			_orbit_groups.erase(uid_key)

	# Step projectiles
	for i in range(_projs.size() - 1, -1, -1):
		var p: ProjectileEntity = _projs[i]
		if not is_instance_valid(p) or not p.step(delta, grid, player_pos):
			if is_instance_valid(p):
				p.queue_free()
			_projs.remove_at(i)

	# Step area effects
	for i in range(_areas.size() - 1, -1, -1):
		var a: AreaEffectEntity = _areas[i]
		if not is_instance_valid(a) or not a.step(delta, grid, player_pos):
			if is_instance_valid(a):
				a.queue_free()
			_areas.remove_at(i)

func spawn_enemy_projectile(pos: Vector3, dir: Vector3, spd: float, dmg: float, radius: float, col: Color, player_ctrl: PlayerController) -> void:
	if world_root == null:
		return
	var p: ProjectileEntity = ProjectileEntity.new()
	p.setup_enemy_proj(pos, dir, spd, dmg, radius, col)
	p.player_hit_by_enemy_proj.connect(func(d: float) -> void:
		if is_instance_valid(player_ctrl):
			player_ctrl.take_damage(d)
	)
	world_root.add_child(p)
	_projs.append(p)

func spawn_enemy_telegraph(pos: Vector3, radius: float, windup: float, dmg: float, col: Color, player_ctrl: PlayerController) -> void:
	if world_root == null:
		return
	var a: AreaEffectEntity = AreaEffectEntity.new()
	a.setup_enemy_telegraph(pos, radius, windup, dmg, col)
	a.player_telegraph_hit.connect(func(d: float) -> void:
		if is_instance_valid(player_ctrl):
			player_ctrl.take_damage(d)
	)
	world_root.add_child(a)
	_areas.append(a)

func trigger_reactive_nova(kind: String, pos: Vector3, dmg: float, radius: float) -> void:
	var col: Color = Color(1.0, 0.78, 0.22) if kind == "honey_aegis" else Color(0.90, 0.36, 0.26)
	var a: AreaEffectEntity = AreaEffectEntity.new()
	a.apply_slow = (kind == "honey_aegis")
	a.setup_player_nova(pos, radius, dmg, stats.crit_chance, stats.crit_mult, col, false, false, 0.0, grid, pos)
	a.enemy_hit.connect(_on_area_enemy_hit)
	world_root.add_child(a)
	_areas.append(a)

func _step_orbit_skill(cfg: Dictionary, delta: float, player_pos: Vector3) -> void:
	var uid: int = int(cfg["uid"])
	var count: int = int(cfg["projectiles"]) + (1 if bool(cfg.get("echo", false)) else 0)
	var orbit_r: float = maxf(2.2, float(cfg["area_radius"]))
	var angular_spd: float = maxf(1.8, float(cfg.get("proj_speed", 3.4)) * 0.25)

	if not _orbit_groups.has(uid):
		_orbit_groups[uid] = {"nodes": [], "angle": 0.0, "hit_cd": {}}
	var grp: Dictionary = _orbit_groups[uid]
	var nodes: Array = grp["nodes"]

	while nodes.size() < count:
		var star: MeshInstance3D = ChibiMeshFactory._make_part(
			ChibiMeshFactory._get_prism(Vector3(0.48, 0.56, 0.48)),
			ChibiMeshFactory.get_toon_mat(Color(0.45, 0.90, 1.0), 1.35, 0.2),
			Vector3.ZERO,
			Vector3.ZERO,
			Vector3.ONE,
			false
		)
		world_root.add_child(star)
		nodes.append(star)
	while nodes.size() > count:
		var rem_n: Node3D = nodes.pop_back()
		if is_instance_valid(rem_n):
			rem_n.queue_free()

	grp["angle"] = float(grp["angle"]) + delta * angular_spd
	var hit_cd: Dictionary = grp["hit_cd"]
	for eid in hit_cd.keys():
		var t: float = float(hit_cd[eid]) - delta
		if t <= 0.0:
			hit_cd.erase(eid)
		else:
			hit_cd[eid] = t

	var is_fire: bool = float(cfg.get("added_fire_pct", 0.0)) > 0.0
	var is_cold: bool = float(cfg.get("added_cold_pct", 0.0)) > 0.0
	var base_dmg: float = float(cfg["damage"])
	var extra_elem: float = 1.0 + float(cfg.get("added_fire_pct", 0.0)) * 0.01 + float(cfg.get("added_cold_pct", 0.0)) * 0.01
	var leech_pct: float = float(cfg.get("leech_pct", 0.0))
	var hit_cooldown: float = maxf(0.24, float(cfg["cooldown"]))

	for idx in range(nodes.size()):
		var star_node: MeshInstance3D = nodes[idx]
		var a: float = float(grp["angle"]) + float(idx) * TAU / float(nodes.size())
		var spos: Vector3 = player_pos + Vector3(cos(a) * orbit_r, 0.72, sin(a) * orbit_r)
		star_node.global_position = spos
		star_node.rotation.y += delta * 6.0

		var hits: Array = grid.query_radius(spos, 0.85 * float(cfg.get("area_mult", 1.0)))
		for e in hits:
			if not is_instance_valid(e) or e.get("is_dead") == true:
				continue
			var eid: int = e.get_instance_id()
			if hit_cd.has(eid):
				continue
			hit_cd[eid] = hit_cooldown
			var is_crit: bool = randf() * 100.0 < float(cfg["crit_chance"])
			var dmg: float = base_dmg * extra_elem * (float(cfg["crit_mult"]) * 0.01 if is_crit else 1.0)
			if is_fire and e.has_method("apply_burn"):
				e.apply_burn(dmg * 0.25, 3.0)
			if is_cold and e.has_method("apply_chill"):
				e.apply_chill(2.5)
			var kb: Vector3 = (e.global_position - player_pos)
			kb.y = 0.0
			e.take_damage(dmg, kb.normalized() * 2.2 if kb.length_squared() > 0.01 else Vector3.ZERO)
			_emit_damage(e.global_position, dmg, is_crit, is_fire, is_cold, leech_pct)

func _trigger_skill(cfg: Dictionary, player_pos: Vector3, is_echo: bool) -> bool:
	var gid: String = String(cfg["gem_id"])
	var nearest: Node3D = grid.find_nearest(player_pos, 26.0)

	match gid:
		"acorn_barrage":
			if nearest == null:
				return false
			_fire_fan(player_pos, nearest.global_position, cfg, "acorn", 0.14)
		"fireball_berry":
			if nearest == null:
				return false
			_fire_fan(player_pos, nearest.global_position, cfg, "fireball", 0.22)
		"boomerang_bone":
			var target_pos: Vector3 = nearest.global_position if nearest != null else (player_pos + Vector3(0.0, 0.0, 5.0))
			_fire_fan(player_pos, target_pos, cfg, "bone", 0.26)
		"spirit_bees":
			var bee_target: Vector3 = nearest.global_position if nearest != null else (player_pos + Vector3(3.0, 0.0, 0.0))
			_fire_fan(player_pos, bee_target, cfg, "bee", 0.55)
		"petal_cyclone":
			_spiral_phase += 0.55
			var n: int = int(cfg["projectiles"])
			for i in range(n):
				var a: float = _spiral_phase + float(i) * TAU / float(n)
				_spawn_proj(player_pos, Vector3(cos(a), 0.0, sin(a)), cfg, "petal")
		"frost_nova":
			var n_ice: int = int(cfg["projectiles"])
			for i in range(n_ice):
				var a: float = float(i) * TAU / float(n_ice)
				_spawn_proj(player_pos, Vector3(cos(a), 0.0, sin(a)), cfg, "icicle")
			# Also burst cold chill nova right around player
			var nova: AreaEffectEntity = AreaEffectEntity.new()
			nova.apply_slow = true
			nova.setup_player_nova(player_pos, float(cfg["area_radius"]), float(cfg["damage"]) * 0.7, float(cfg["crit_chance"]), float(cfg["crit_mult"]), Color(0.45, 0.90, 1.0), float(cfg.get("added_fire_pct", 0.0)) > 0.0, true, float(cfg.get("leech_pct", 0.0)), grid, player_pos)
			nova.enemy_hit.connect(_on_area_enemy_hit)
			world_root.add_child(nova)
			_areas.append(nova)
		"honey_slam":
			var slam_pos: Vector3 = player_pos
			if nearest != null and player_pos.distance_to(nearest.global_position) < 4.5:
				slam_pos = player_pos.lerp(nearest.global_position, 0.35)
			var is_fire_s: bool = float(cfg.get("added_fire_pct", 0.0)) > 0.0
			var is_cold_s: bool = float(cfg.get("added_cold_pct", 0.0)) > 0.0
			var extra_e: float = 1.0 + float(cfg.get("added_fire_pct", 0.0)) * 0.01 + float(cfg.get("added_cold_pct", 0.0)) * 0.01
			var slam: AreaEffectEntity = AreaEffectEntity.new()
			slam.apply_slow = true
			slam.setup_player_nova(slam_pos, float(cfg["area_radius"]), float(cfg["damage"]) * extra_e, float(cfg["crit_chance"]), float(cfg["crit_mult"]), Color(1.0, 0.78, 0.22), is_fire_s, is_cold_s, float(cfg.get("leech_pct", 0.0)), grid, player_pos)
			slam.enemy_hit.connect(_on_area_enemy_hit)
			world_root.add_child(slam)
			_areas.append(slam)
		"whisker_lightning":
			if nearest == null:
				return false
			_cast_chain_lightning(player_pos, nearest, cfg)
		"meteor_pine":
			if nearest == null:
				return false
			var drop_pos: Vector3 = grid.find_densest_cluster_center(player_pos, 18.0)
			var extra_m: float = 1.0 + float(cfg.get("added_fire_pct", 0.0)) * 0.01 + float(cfg.get("added_cold_pct", 0.0)) * 0.01
			var meteor: AreaEffectEntity = AreaEffectEntity.new()
			meteor.setup_meteor(drop_pos, float(cfg["area_radius"]), float(cfg["damage"]) * extra_m, float(cfg["crit_chance"]), float(cfg["crit_mult"]), float(cfg.get("added_cold_pct", 0.0)) > 0.0, float(cfg.get("leech_pct", 0.0)))
			meteor.enemy_hit.connect(_on_area_enemy_hit)
			world_root.add_child(meteor)
			_areas.append(meteor)

	if not is_echo:
		skill_casted.emit(gid)
	return true

func _fire_fan(origin: Vector3, target: Vector3, cfg: Dictionary, style: String, spread_step: float) -> void:
	var dir: Vector3 = target - origin
	dir.y = 0.0
	if dir.length_squared() < 0.001:
		dir = Vector3(0.0, 0.0, 1.0)
	dir = dir.normalized()
	var base_ang: float = atan2(dir.z, dir.x)
	var count: int = int(cfg["projectiles"])
	for i in range(count):
		var off: float = (float(i) - float(count - 1) * 0.5) * spread_step
		var d: Vector3 = Vector3(cos(base_ang + off), 0.0, sin(base_ang + off))
		_spawn_proj(origin, d, cfg, style)

func _spawn_proj(origin: Vector3, dir: Vector3, cfg: Dictionary, style: String, hit_ids: Dictionary = {}) -> void:
	var p: ProjectileEntity = ProjectileEntity.new()
	p.setup_player_proj(origin, dir, cfg, style, hit_ids)
	p.enemy_hit.connect(_on_proj_enemy_hit)
	p.chain_arc_requested.connect(_on_chain_arc_requested)
	p.fork_requested.connect(_on_fork_requested)
	p.explosion_requested.connect(_on_explosion_requested)
	world_root.add_child(p)
	_projs.append(p)

func _cast_chain_lightning(origin: Vector3, first_target: Node3D, cfg: Dictionary) -> void:
	var chains_total: int = 1 + int(cfg.get("chains", 2))
	var hit_map: Dictionary = {}
	var prev_pos: Vector3 = origin
	var curr: Node3D = first_target
	var base_dmg: float = float(cfg["damage"])
	var extra_elem: float = 1.0 + float(cfg.get("added_fire_pct", 0.0)) * 0.01 + float(cfg.get("added_cold_pct", 0.0)) * 0.01
	var is_fire: bool = float(cfg.get("added_fire_pct", 0.0)) > 0.0
	var is_cold: bool = float(cfg.get("added_cold_pct", 0.0)) > 0.0
	var leech_pct: float = float(cfg.get("leech_pct", 0.0))

	for _hop in range(chains_total):
		if curr == null or not is_instance_valid(curr) or curr.get("is_dead") == true:
			break
		hit_map[curr.get_instance_id()] = true
		_spawn_lightning_visual(prev_pos, curr.global_position, Color(0.55, 0.88, 1.0))
		var is_crit: bool = randf() * 100.0 < float(cfg["crit_chance"])
		var dmg: float = base_dmg * extra_elem * (float(cfg["crit_mult"]) * 0.01 if is_crit else 1.0)
		if is_fire and curr.has_method("apply_burn"):
			curr.apply_burn(dmg * 0.25, 3.0)
		if is_cold and curr.has_method("apply_chill"):
			curr.apply_chill(2.5)
		curr.take_damage(dmg, Vector3.ZERO)
		_emit_damage(curr.global_position, dmg, is_crit, is_fire, is_cold, leech_pct)

		prev_pos = curr.global_position
		curr = grid.find_nearest(prev_pos, 10.5, hit_map)

func _spawn_lightning_visual(from_p: Vector3, to_p: Vector3, col: Color) -> void:
	var arc: AreaEffectEntity = AreaEffectEntity.new()
	arc.setup_lightning_arc(from_p, to_p, col)
	world_root.add_child(arc)
	_areas.append(arc)

func _on_chain_arc_requested(from_p: Vector3, to_p: Vector3, col: Color) -> void:
	_spawn_lightning_visual(from_p, to_p, col)

func _on_fork_requested(pos: Vector3, dir: Vector3, cfg: Dictionary, hit_ids: Dictionary) -> void:
	var fork_cfg: Dictionary = cfg.duplicate()
	fork_cfg["forks"] = 0
	var base_ang: float = atan2(dir.z, dir.x)
	for offset in [-0.48, 0.48]:
		var d: Vector3 = Vector3(cos(base_ang + offset), 0.0, sin(base_ang + offset))
		_spawn_proj(pos, d, fork_cfg, "acorn", hit_ids)

func _on_explosion_requested(pos: Vector3, radius: float, cfg: Dictionary) -> void:
	var extra_e: float = 1.0 + float(cfg.get("added_fire_pct", 0.0)) * 0.01 + float(cfg.get("added_cold_pct", 0.0)) * 0.01
	var boom: AreaEffectEntity = AreaEffectEntity.new()
	boom.setup_player_nova(
		pos,
		radius,
		float(cfg.get("damage", 25.0)) * extra_e,
		float(cfg.get("crit_chance", 8.0)),
		float(cfg.get("crit_mult", 165.0)),
		Color(1.0, 0.45, 0.16),
		true,
		float(cfg.get("added_cold_pct", 0.0)) > 0.0,
		float(cfg.get("leech_pct", 0.0)),
		grid,
		pos
	)
	boom.enemy_hit.connect(_on_area_enemy_hit)
	world_root.add_child(boom)
	_areas.append(boom)

func _on_proj_enemy_hit(enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float) -> void:
	_emit_damage(pos, dmg, is_crit, is_fire, is_cold, leech_pct)

func _on_area_enemy_hit(enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float) -> void:
	_emit_damage(pos, dmg, is_crit, is_fire, is_cold, leech_pct)

func _emit_damage(pos: Vector3, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, leech_pct: float) -> void:
	var heal_amt: float = stats.life_on_hit + (dmg * leech_pct * 0.01)
	heal_amt = minf(heal_amt, stats.max_hp * 0.08)
	damage_dealt.emit(pos, dmg, is_crit, is_fire, is_cold, heal_amt)
