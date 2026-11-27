class_name EnemyEntity
extends Node3D

signal died(enemy: EnemyEntity)
signal spawn_projectile_requested(pos: Vector3, dir: Vector3, speed: float, dmg: float, radius: float, col: Color)
signal spawn_telegraph_requested(pos: Vector3, radius: float, windup: float, dmg: float, col: Color, is_ring: bool)
signal spawn_minion_requested(enemy_id: String, pos: Vector3)
signal boss_phase_announced(boss_name: String, message: String)

var enemy_id: String = "slime_frog"
var enemy_name: String = "Dewdrop Frog"
var is_boss: bool = false
var is_elite: bool = false
var is_dead: bool = false
var boss_index: int = 0

var max_hp: float = 30.0
var current_hp: float = 30.0
var move_speed: float = 3.5
var contact_damage: float = 8.0
var hit_radius: float = 0.7

var _is_ranged: bool = false
var _explodes_on_death: bool = false
var _ranged_cd: float = 1.8

var _rig: Node3D = null
var _body_pivot: Node3D = null
var _mesh_nodes: Array[MeshInstance3D] = []
var _orig_materials: Array[Material] = []

var _flash_timer: float = 0.0
var _burn_timer: float = 0.0
var _burn_dps: float = 0.0
var _burn_tick: float = 0.0
var _chill_timer: float = 0.0
var _knockback_vel: Vector3 = Vector3.ZERO
var _waddle_phase: float = 0.0
var _sep_parity: int = 0
var _volley_hits: Dictionary = {}

# Boss AI state
var _boss_cd: float = 2.4
var _boss_cycle: int = 0
var _boss_enraged: bool = false
var _boss_charge_timer: float = 0.0
var _boss_charge_windup: float = 0.0
var _boss_charge_dir: Vector3 = Vector3.ZERO

func setup(p_enemy_id: String, hp_scale: float, dmg_scale: float, p_elite: bool = false, p_speed_scale: float = 1.0) -> void:
	enemy_id = p_enemy_id
	is_elite = p_elite
	is_dead = false
	var def: Dictionary = EnemyDatabase.get_def(enemy_id)
	enemy_name = String(def["enemy_name"])
	is_boss = bool(def.get("is_boss", false))
	boss_index = int(def.get("boss_index", 0))
	_is_ranged = bool(def.get("ranged", false))
	_explodes_on_death = bool(def.get("explodes_on_death", false))

	var elite_hp_mult: float = BalanceConfig.ELITE_HP_MULT if (is_elite and not is_boss) else 1.0
	var elite_dmg_mult: float = BalanceConfig.ELITE_DMG_MULT if (is_elite and not is_boss) else 1.0
	max_hp = float(def["hp"]) * hp_scale * elite_hp_mult
	current_hp = max_hp
	move_speed = float(def["speed"]) * (1.0 if is_boss else p_speed_scale) * (BalanceConfig.ELITE_SPEED_MULT if (is_elite and not is_boss) else 1.0)
	contact_damage = float(def["damage"]) * dmg_scale * elite_dmg_mult
	hit_radius = float(def["radius"]) * (1.28 if (is_elite and not is_boss) else 1.0)

	_waddle_phase = randf() * TAU
	_ranged_cd = randf_range(1.1, 2.0)
	_boss_cd = 2.0
	_boss_cycle = 0
	_boss_enraged = false
	_volley_hits.clear()

	_rig = ChibiMeshFactory.build_enemy_rig(enemy_id, is_elite)
	if is_elite and not is_boss:
		_rig.scale = Vector3(1.28, 1.28, 1.28)
	add_child(_rig)
	_body_pivot = _rig.get_node_or_null("BodyPivot")
	_collect_meshes(_rig)

func _collect_meshes(node: Node) -> void:
	for ch in node.get_children():
		if ch is MeshInstance3D and ch.name != "ShadowDisc" and ch.name != "EliteRing":
			var mi: MeshInstance3D = ch
			_mesh_nodes.append(mi)
			_orig_materials.append(mi.material_override)
		_collect_meshes(ch)

func step(delta: float, player_pos: Vector3, grid: SpatialGrid) -> void:
	if is_dead:
		return

	# Status ticks
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_restore_materials()

	if _chill_timer > 0.0:
		_chill_timer -= delta

	if _burn_timer > 0.0:
		_burn_timer -= delta
		_burn_tick += delta
		if _burn_tick >= 0.35:
			_burn_tick -= 0.35
			take_damage(_burn_dps * 0.35, Vector3.ZERO, false)
			if is_dead:
				return

	# Knockback decay
	if _knockback_vel.length_squared() > 0.01:
		global_position += _knockback_vel * delta
		_knockback_vel = _knockback_vel.lerp(Vector3.ZERO, minf(1.0, delta * 9.0))

	var to_player: Vector3 = player_pos - global_position
	to_player.y = 0.0
	var dist: float = to_player.length()
	var dir_to_player: Vector3 = to_player / maxf(0.001, dist)

	var chill_mult: float = BalanceConfig.ENEMY_CHILL_SPEED_MULT if _chill_timer > 0.0 else 1.0

	if is_boss:
		_step_boss_ai(delta, player_pos, dir_to_player, dist, chill_mult)
	else:
		# Regular & Ranged AI
		var move_dir: Vector3 = dir_to_player
		var spd: float = move_speed * chill_mult
		if _is_ranged:
			if dist < 11.5:
				spd = 0.0
			_ranged_cd -= delta
			if _ranged_cd <= 0.0 and dist < 24.0:
				_ranged_cd = randf_range(1.7, 2.3)
				spawn_projectile_requested.emit(
					global_position + Vector3(0.0, 0.6, 0.0),
					dir_to_player,
					12.5,
					contact_damage * 1.0,
					0.36,
					Color(0.88, 0.36, 1.0)
				)

		# Zero-allocation soft separation every 2nd frame
		_sep_parity += 1
		var sep: Vector3 = grid.compute_separation(self, hit_radius * 1.45) if (_sep_parity & 1) == 0 else Vector3.ZERO

		var final_vel: Vector3 = (move_dir * spd) + (sep * 3.4)
		global_position += final_vel * delta

	var bound: float = ArenaBuilder.ARENA_HALF_SIZE - 1.2
	global_position.x = clampf(global_position.x, -bound, bound)
	global_position.z = clampf(global_position.z, -bound, bound)

	# Face player & cute waddle
	if _rig != null:
		var yaw: float = atan2(dir_to_player.x, dir_to_player.z)
		_rig.rotation.y = lerp_angle(_rig.rotation.y, yaw, minf(1.0, delta * 9.0))
	if _body_pivot != null:
		_waddle_phase += delta * (10.0 if not is_boss else 6.0) * chill_mult
		_body_pivot.position.y = absf(sin(_waddle_phase)) * (0.14 if not is_boss else 0.22)
		_body_pivot.rotation.z = sin(_waddle_phase) * 0.09

func _step_boss_ai(delta: float, player_pos: Vector3, dir_to_player: Vector3, dist: float, chill_mult: float) -> void:
	if _boss_charge_windup > 0.0:
		_boss_charge_windup -= delta
		if _boss_charge_windup <= 0.0:
			_boss_charge_timer = 0.62
		return
	if _boss_charge_timer > 0.0:
		_boss_charge_timer -= delta
		global_position += _boss_charge_dir * (move_speed * 3.4) * delta
		return

	# Check 50% HP enrage
	if not _boss_enraged and current_hp <= max_hp * 0.5:
		_boss_enraged = true
		if enemy_id == "boss_grizzle":
			boss_phase_announced.emit(enemy_name, "Enraged! Summoning Honey Guard!")
			for i in range(4):
				var ang: float = float(i) * TAU / 4.0
				spawn_minion_requested.emit("acorn_boar", global_position + Vector3(cos(ang), 0.0, sin(ang)) * 3.5)
		elif enemy_id == "boss_bramblehorn":
			boss_phase_announced.emit(enemy_name, "Prism Overdrive! Gloom Foxes Join!")
			for i in range(3):
				var ang: float = float(i) * TAU / 3.0
				spawn_minion_requested.emit("gloom_fox", global_position + Vector3(cos(ang), 0.0, sin(ang)) * 4.5)
		else:
			boss_phase_announced.emit(enemy_name, "Arcane Tempest Unleashed!")

	# Walk steadily toward player
	if dist > 2.2:
		global_position += dir_to_player * move_speed * chill_mult * delta

	_boss_cd -= delta * (1.32 if _boss_enraged else 1.0)
	if _boss_cd > 0.0:
		return

	_boss_cycle += 1
	match enemy_id:
		"boss_grizzle":
			if _boss_cycle % 2 == 1:
				_boss_cd = 2.3
				spawn_telegraph_requested.emit(global_position, 5.6, 0.90, contact_damage * 1.50, Color(1.0, 0.72, 0.16), false)
			else:
				_boss_cd = 2.6
				_boss_charge_dir = dir_to_player
				_boss_charge_windup = 0.72
				spawn_telegraph_requested.emit(global_position + _boss_charge_dir * 4.5, 2.2, 0.70, contact_damage * 1.35, Color(1.0, 0.45, 0.18), false)
		"boss_whiskers":
			if _boss_cycle % 3 == 1:
				_boss_cd = 2.2
				var count: int = 9 if _boss_enraged else 7
				var base_ang: float = atan2(dir_to_player.z, dir_to_player.x)
				for i in range(count):
					var off: float = (float(i) - float(count - 1) * 0.5) * 0.22
					var d: Vector3 = Vector3(cos(base_ang + off), 0.0, sin(base_ang + off))
					spawn_projectile_requested.emit(global_position + Vector3(0.0, 1.1, 0.0), d, 13.0, contact_damage * 1.0, 0.45, Color(0.45, 0.92, 1.0))
			elif _boss_cycle % 3 == 2:
				_boss_cd = 2.5
				for i in range(5):
					var offset: Vector3 = Vector3(randf_range(-5.5, 5.5), 0.0, randf_range(-5.5, 5.5))
					spawn_telegraph_requested.emit(player_pos + offset, 2.6, 0.92, contact_damage * 1.40, Color(0.55, 0.85, 1.0), false)
			else:
				_boss_cd = 2.4
				var ring_n: int = 12
				for i in range(ring_n):
					var a: float = float(i) * TAU / float(ring_n)
					spawn_projectile_requested.emit(global_position + Vector3(0.0, 1.1, 0.0), Vector3(cos(a), 0.0, sin(a)), 11.0, contact_damage * 0.95, 0.44, Color(0.82, 0.55, 1.0))
		"boss_bramblehorn":
			if _boss_cycle % 3 == 1:
				_boss_cd = 2.0
				var count: int = 16 if _boss_enraged else 12
				var spin: float = float(_boss_cycle) * 0.35
				for i in range(count):
					var a: float = spin + float(i) * TAU / float(count)
					var col: Color = Color(1.0, 0.42, 0.88) if i % 2 == 0 else Color(0.38, 0.96, 1.0)
					spawn_projectile_requested.emit(global_position + Vector3(0.0, 1.3, 0.0), Vector3(cos(a), 0.0, sin(a)), 13.0, contact_damage * 1.05, 0.48, col)
			elif _boss_cycle % 3 == 2:
				_boss_cd = 2.3
				for i in range(4):
					var off: Vector3 = Vector3(randf_range(-4.5, 4.5), 0.0, randf_range(-4.5, 4.5))
					spawn_telegraph_requested.emit(player_pos + off, 2.9, 0.88 + float(i) * 0.12, contact_damage * 1.45, Color(1.0, 0.35, 0.80), false)
			else:
				_boss_cd = 2.5
				# Cross slam + inner nova
				spawn_telegraph_requested.emit(global_position, 6.2, 0.98, contact_damage * 1.65, Color(1.0, 0.48, 0.90), false)
				for i in range(4):
					var a: float = float(i) * PI * 0.5 + float(_boss_cycle) * 0.4
					spawn_telegraph_requested.emit(global_position + Vector3(cos(a), 0.0, sin(a)) * 7.5, 3.0, 0.98, contact_damage * 1.50, Color(0.42, 0.92, 1.0), false)

func apply_burn(dps: float, dur: float) -> void:
	_burn_dps = maxf(_burn_dps, dps)
	_burn_timer = maxf(_burn_timer, dur)

func apply_chill(dur: float) -> void:
	_chill_timer = maxf(_chill_timer, dur)

func was_chilled() -> bool:
	return _chill_timer > 0.0

func consume_volley_dmg_mult(p_cast_uid: int) -> float:
	if p_cast_uid == 0:
		return 1.0
	if _volley_hits.has(p_cast_uid):
		return BalanceConfig.VOLLEY_REPEAT_MULT
	if _volley_hits.size() >= 24:
		_volley_hits.clear()
	_volley_hits[p_cast_uid] = true
	return 1.0

func take_damage(amount: float, knockback_vec: Vector3 = Vector3.ZERO, trigger_flash: bool = true) -> void:
	if is_dead:
		return
	current_hp -= amount
	if not is_boss and knockback_vec.length_squared() > 0.001:
		var kb_scale: float = BalanceConfig.ENEMY_KNOCKBACK_ELITE if is_elite else BalanceConfig.ENEMY_KNOCKBACK_REGULAR
		_knockback_vel += knockback_vec * kb_scale

	if trigger_flash:
		_flash_timer = 0.09
		var flash_mat: StandardMaterial3D = ChibiMeshFactory.get_hit_flash_material()
		for mi in _mesh_nodes:
			if is_instance_valid(mi):
				mi.material_override = flash_mat

	if current_hp <= 0.0:
		current_hp = 0.0
		is_dead = true
		if _explodes_on_death:
			spawn_telegraph_requested.emit(global_position, 3.2, 0.65, contact_damage * 1.15, Color(0.96, 0.30, 0.35), false)
		died.emit(self)

func _restore_materials() -> void:
	for i in range(_mesh_nodes.size()):
		var mi: MeshInstance3D = _mesh_nodes[i]
		if is_instance_valid(mi):
			mi.material_override = _orig_materials[i]
