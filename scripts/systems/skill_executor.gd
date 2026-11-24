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

# Temporary star shield triggered by orbit_shield global effect
var _shield_orbit_timer: float = 0.0
var _shield_orbit_nodes: Array[MeshInstance3D] = []
var _shield_orbit_angle: float = 0.0
var _shield_orbit_hit_cd: Dictionary = {}

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
	_shield_orbit_timer = 0.0
	_shield_orbit_hit_cd.clear()
	for n in _shield_orbit_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_shield_orbit_nodes.clear()

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
	var cd_rate: float = 1.0
	if stats.has_turret_stance and player_ctrl != null:
		cd_rate *= (0.75 if player_ctrl.is_moving else 2.0)
	if player_ctrl != null and player_ctrl.has_zoomies_active():
		cd_rate *= 1.25

	var active_orbit_uids: Dictionary = {}
	for cfg in stats.active_skill_configs:
		var uid: int = int(cfg["uid"])
		var gid: String = String(cfg["gem_id"])
		if gid == "starlight_orb":
			active_orbit_uids[uid] = true
			_step_orbit_skill(cfg, delta, player_pos)
			continue

		var rem: float = float(_cooldowns.get(uid, 0.0)) - delta * cd_rate
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

	_step_temp_orbit_shield(delta, player_pos)

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
	if world_root == null or stats == null:
		return
	var col: Color = Color(1.0, 0.78, 0.22)
	var p_fire: bool = false
	var p_cold: bool = false
	var p_slow: bool = false
	match kind:
		"aegis_freeze":
			col = Color(0.52, 0.92, 1.0)
			p_cold = true
			p_slow = true
		"dash_honey_nova":
			col = Color(1.0, 0.78, 0.22)
			p_slow = true
		"thorns_burst":
			col = Color(0.95, 0.42, 0.26)
		"ember_corpse":
			col = Color(1.0, 0.48, 0.18)
			p_fire = true
		"frost_shatter":
			col = Color(0.45, 0.92, 1.0)
			p_cold = true
			p_slow = true
	var a: AreaEffectEntity = AreaEffectEntity.new()
	a.apply_slow = p_slow
	a.apply_burn = p_fire
	a.setup_player_nova(pos, radius, dmg, stats.crit_chance, stats.crit_mult, col, p_fire, p_cold, 0.0, grid, pos)
	a.enemy_hit.connect(_on_area_enemy_hit)
	world_root.add_child(a)
	_areas.append(a)

func trigger_all_skills_from_dash(player_pos: Vector3) -> void:
	if stats == null or not stats.has_dash_triggers_skills or world_root == null:
		return
	for cfg in stats.active_skill_configs:
		if String(cfg["gem_id"]) == "starlight_orb":
			continue
		_trigger_skill(cfg, player_pos, true)

func trigger_kill_effects(pos: Vector3, was_chilled_flag: bool) -> void:
	if stats == null or world_root == null:
		return
	if stats.has_ember_corpse:
		trigger_reactive_nova("ember_corpse", pos, 24.0, 3.6)
	if stats.has_frost_shatter and was_chilled_flag:
		trigger_reactive_nova("frost_shatter", pos, 26.0, 4.4)

func trigger_static_spark(pos: Vector3) -> void:
	if stats == null or world_root == null or grid == null:
		return
	var first_t: Node3D = grid.find_nearest(pos, 13.0)
	if first_t == null:
		return
	var hit_map: Dictionary = {first_t.get_instance_id(): true}
	_spawn_lightning_visual(pos, first_t.global_position, Color(0.55, 0.92, 1.0))
	first_t.take_damage(20.0, Vector3.ZERO)
	_emit_damage(first_t.global_position, 20.0, false, false, false, 0.0)
	var second_t: Node3D = grid.find_nearest(first_t.global_position, 8.0, hit_map)
	if second_t != null:
		_spawn_lightning_visual(first_t.global_position, second_t.global_position, Color(0.55, 0.92, 1.0))
		second_t.take_damage(20.0, Vector3.ZERO)
		_emit_damage(second_t.global_position, 20.0, false, false, false, 0.0)

func activate_orbit_shield() -> void:
	_shield_orbit_timer = 5.0

func _step_temp_orbit_shield(delta: float, player_pos: Vector3) -> void:
	if _shield_orbit_timer <= 0.0:
		if not _shield_orbit_nodes.is_empty():
			for n in _shield_orbit_nodes:
				if is_instance_valid(n):
					n.queue_free()
			_shield_orbit_nodes.clear()
			_shield_orbit_hit_cd.clear()
		return
	_shield_orbit_timer -= delta
	while _shield_orbit_nodes.size() < 3:
		var star: MeshInstance3D = ChibiMeshFactory._make_part(
			ChibiMeshFactory._get_prism(Vector3(0.42, 0.50, 0.42)),
			ChibiMeshFactory.get_toon_mat(Color(1.0, 0.86, 0.36), 1.35, 0.2),
			Vector3.ZERO,
			Vector3.ZERO,
			Vector3.ONE,
			false
		)
		world_root.add_child(star)
		_shield_orbit_nodes.append(star)
	_shield_orbit_angle += delta * 3.8
	for eid in _shield_orbit_hit_cd.keys():
		var t: float = float(_shield_orbit_hit_cd[eid]) - delta
		if t <= 0.0:
			_shield_orbit_hit_cd.erase(eid)
		else:
			_shield_orbit_hit_cd[eid] = t
	for idx in range(_shield_orbit_nodes.size()):
		var star_node: MeshInstance3D = _shield_orbit_nodes[idx]
		var a: float = _shield_orbit_angle + float(idx) * (TAU / 3.0)
		var spos: Vector3 = player_pos + Vector3(cos(a) * 2.6, 0.72, sin(a) * 2.6)
		star_node.global_position = spos
		star_node.rotation.y += delta * 7.0
		var hits: Array = grid.query_radius(spos, 0.95)
		for e in hits:
			if not is_instance_valid(e) or e.get("is_dead") == true:
				continue
			var eid: int = e.get_instance_id()
			if _shield_orbit_hit_cd.has(eid):
				continue
			_shield_orbit_hit_cd[eid] = 0.4
			var kb: Vector3 = e.global_position - player_pos
			kb.y = 0.0
			e.take_damage(22.0, kb.normalized() * 3.2 if kb.length_squared() > 0.01 else Vector3.ZERO)
			_emit_damage(e.global_position, 22.0, false, false, false, 0.0)

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

	var is_fire: bool = bool(cfg.get("ignite", false))
	var is_cold: bool = bool(cfg.get("chill", false))
	var base_dmg: float = float(cfg["damage"])
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
			var dmg: float = base_dmg * (float(cfg["crit_mult"]) * 0.01 if is_crit else 1.0)
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
			nova.pull_inward = bool(cfg.get("pull_inward", false))
			nova.setup_player_nova(player_pos, float(cfg["area_radius"]), float(cfg["damage"]) * 0.7, float(cfg["crit_chance"]), float(cfg["crit_mult"]), Color(0.45, 0.90, 1.0), bool(cfg.get("ignite", false)), true, float(cfg.get("leech_pct", 0.0)), grid, player_pos)
			nova.enemy_hit.connect(_on_area_enemy_hit)
			world_root.add_child(nova)
			_areas.append(nova)
		"honey_slam":
			var slam_pos: Vector3 = player_pos
			if nearest != null and player_pos.distance_to(nearest.global_position) < 4.5:
				slam_pos = player_pos.lerp(nearest.global_position, 0.35)
			var is_fire_s: bool = bool(cfg.get("ignite", false))
			var is_cold_s: bool = bool(cfg.get("chill", false))
			var slam: AreaEffectEntity = AreaEffectEntity.new()
			slam.apply_slow = true
			slam.pull_inward = bool(cfg.get("pull_inward", false))
			slam.setup_player_nova(slam_pos, float(cfg["area_radius"]), float(cfg["damage"]), float(cfg["crit_chance"]), float(cfg["crit_mult"]), Color(1.0, 0.78, 0.22), is_fire_s, is_cold_s, float(cfg.get("leech_pct", 0.0)), grid, player_pos)
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
			var meteor: AreaEffectEntity = AreaEffectEntity.new()
			meteor.pull_inward = bool(cfg.get("pull_inward", false))
			meteor.setup_meteor(drop_pos, float(cfg["area_radius"]), float(cfg["damage"]), float(cfg["crit_chance"]), float(cfg["crit_mult"]), bool(cfg.get("chill", false)), float(cfg.get("leech_pct", 0.0)))
			meteor.enemy_hit.connect(_on_area_enemy_hit)
			world_root.add_child(meteor)
			_areas.append(meteor)

	if not is_echo:
		skill_casted.emit(gid)
	return true

func _fire_fan(origin: Vector3, target: Vector3, cfg: Dictionary, style: String, spread_step: float) -> void:
	var count: int = int(cfg["projectiles"])
	if bool(cfg.get("nova_360", false)):
		var ring_count: int = maxi(count, 6)
		for i in range(ring_count):
			var a: float = float(i) * (TAU / float(ring_count))
			_spawn_proj(origin, Vector3(cos(a), 0.0, sin(a)), cfg, style)
		return
	var dir: Vector3 = target - origin
	dir.y = 0.0
	if dir.length_squared() < 0.001:
		dir = Vector3(0.0, 0.0, 1.0)
	dir = dir.normalized()
	var base_ang: float = atan2(dir.z, dir.x)
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
	var is_fire: bool = bool(cfg.get("ignite", false))
	var is_cold: bool = bool(cfg.get("chill", false))
	var leech_pct: float = float(cfg.get("leech_pct", 0.0))

	for _hop in range(chains_total):
		if curr == null or not is_instance_valid(curr) or curr.get("is_dead") == true:
			break
		hit_map[curr.get_instance_id()] = true
		_spawn_lightning_visual(prev_pos, curr.global_position, Color(0.55, 0.88, 1.0))
		var is_crit: bool = randf() * 100.0 < float(cfg["crit_chance"])
		var dmg: float = base_dmg * (float(cfg["crit_mult"]) * 0.01 if is_crit else 1.0)
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
	var boom: AreaEffectEntity = AreaEffectEntity.new()
	boom.pull_inward = bool(cfg.get("pull_inward", false))
	boom.setup_player_nova(
		pos,
		radius,
		float(cfg.get("damage", 25.0)),
		float(cfg.get("crit_chance", 8.0)),
		float(cfg.get("crit_mult", 165.0)),
		Color(1.0, 0.45, 0.16),
		true,
		bool(cfg.get("chill", false)),
		float(cfg.get("leech_pct", 0.0)),
		grid,
		pos
	)
	boom.enemy_hit.connect(_on_area_enemy_hit)
	world_root.add_child(boom)
	_areas.append(boom)

func _on_proj_enemy_hit(_enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float) -> void:
	_emit_damage(pos, dmg, is_crit, is_fire, is_cold, leech_pct)

func _on_area_enemy_hit(_enemy: Node3D, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, pos: Vector3, leech_pct: float) -> void:
	_emit_damage(pos, dmg, is_crit, is_fire, is_cold, leech_pct)

func _emit_damage(pos: Vector3, dmg: float, is_crit: bool, is_fire: bool, is_cold: bool, leech_pct: float) -> void:
	var heal_amt: float = minf(dmg * leech_pct * 0.01, stats.max_hp * 0.08)
	damage_dealt.emit(pos, dmg, is_crit, is_fire, is_cold, heal_amt)
