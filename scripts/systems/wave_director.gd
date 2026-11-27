class_name WaveDirector
extends Node

signal boss_spawned(boss: EnemyEntity)
signal boss_defeated(boss_index: int, boss_name: String)
signal wave_banner(title: String, color: Color)
signal all_bosses_cleared()

const RUN_DURATION: float = 1200.0 # 20 minutes
const BOSS_TIMES: Array[float] = [390.0, 780.0, 1170.0] # 06:30, 13:00, 19:30

var world_root: Node3D = null
var enemies: Array[EnemyEntity] = []
var active_boss: EnemyEntity = null
var bosses_defeated_count: int = 0
var kills_count: int = 0
var elapsed_time: float = 0.0

var _spawn_timer: float = 0.5
var _elite_timer: float = 65.0
var _chest_timer: float = 55.0
var _surge_index: int = 0
var _boss_spawned_flags: Array[bool] = [false, false, false]
var _surge_times: Array[float] = [240.0, 570.0, 930.0, 1080.0]

var _on_enemy_died_cb: Callable
var _on_enemy_proj_cb: Callable
var _on_enemy_telegraph_cb: Callable

func setup(p_world: Node3D, on_died: Callable, on_proj: Callable, on_tele: Callable) -> void:
	world_root = p_world
	_on_enemy_died_cb = on_died
	_on_enemy_proj_cb = on_proj
	_on_enemy_telegraph_cb = on_tele
	reset()

func reset() -> void:
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	active_boss = null
	bosses_defeated_count = 0
	kills_count = 0
	elapsed_time = 0.0
	_spawn_timer = 0.4
	_elite_timer = 65.0
	_chest_timer = 55.0
	_surge_index = 0
	_boss_spawned_flags = [false, false, false]

func jump_to_time_for_test(seconds: float) -> void:
	elapsed_time = seconds
	for i in range(BOSS_TIMES.size()):
		if elapsed_time >= BOSS_TIMES[i] and not _boss_spawned_flags[i]:
			_boss_spawned_flags[i] = true
			_spawn_boss(i + 1, Vector3(0.0, 0.0, 0.0))

func get_next_boss_countdown() -> String:
	for i in range(BOSS_TIMES.size()):
		if not _boss_spawned_flags[i]:
			var rem: float = maxf(0.0, BOSS_TIMES[i] - elapsed_time)
			var m: int = int(rem) / 60
			var s: int = int(rem) % 60
			return "Boss %d in %02d:%02d" % [i + 1, m, s]
	if is_instance_valid(active_boss):
		return "BOSS FIGHT!"
	return "All Bosses Defeated!"

func step(delta: float, player_pos: Vector3, grid: SpatialGrid, loot_mgr: LootManager) -> void:
	if world_root == null:
		return
	elapsed_time += delta
	var prof: Dictionary = EnemyDatabase.get_wave_profile(elapsed_time)

	# Boss spawns at 06:30, 13:00, 19:30
	for i in range(BOSS_TIMES.size()):
		if not _boss_spawned_flags[i] and elapsed_time >= BOSS_TIMES[i]:
			_boss_spawned_flags[i] = true
			_spawn_boss(i + 1, player_pos)

	var is_web: bool = OS.has_feature("web")
	var max_act_cap: int = int(float(prof["max_active"]) * 0.72) if is_web else int(prof["max_active"])

	var spd_scale: float = float(prof.get("speed_scale", 1.0))

	# Swarm Surges
	if _surge_index < _surge_times.size() and elapsed_time >= _surge_times[_surge_index]:
		_surge_index += 1
		wave_banner.emit("Critter Swarm Surge!", Color(1.0, 0.72, 0.30))
		var pool: Array = prof["pool"]
		for _k in range(12 if is_web else 14):
			if enemies.size() >= max_act_cap + 14:
				break
			var eid: String = String(pool[_k % pool.size()])
			_spawn_enemy(eid, player_pos, float(prof["hp_scale"]), float(prof["dmg_scale"]), false, Vector3.INF, spd_scale)

	# Regular Wave Spawning
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = float(prof["spawn_interval"])
		var batch: int = int(prof["batch_size"])
		var pool: Array = prof["pool"]
		for _b in range(batch):
			if enemies.size() >= max_act_cap:
				break
			var eid: String = String(pool[randi() % pool.size()])
			_spawn_enemy(eid, player_pos, float(prof["hp_scale"]), float(prof["dmg_scale"]), false, Vector3.INF, spd_scale)

	# Periodic Elite Critter
	_elite_timer -= delta
	if _elite_timer <= 0.0:
		_elite_timer = 80.0
		var pool: Array = prof["pool"]
		var eid: String = String(pool[randi() % pool.size()])
		_spawn_enemy(eid, player_pos, float(prof["hp_scale"]), float(prof["dmg_scale"]), true, Vector3.INF, spd_scale)
		wave_banner.emit("Elite Critter Spotted!", Color(0.86, 0.50, 1.0))

	# Periodic Acorn Chest
	_chest_timer -= delta
	if _chest_timer <= 0.0:
		_chest_timer = 95.0
		var ang: float = randf() * TAU
		var dist: float = randf_range(16.0, 26.0)
		var b: float = ArenaBuilder.ARENA_HALF_SIZE - 6.0
		var cpos: Vector3 = Vector3(
			clampf(player_pos.x + cos(ang) * dist, -b, b),
			0.0,
			clampf(player_pos.z + sin(ang) * dist, -b, b)
		)
		loot_mgr.spawn_treasure_chest(cpos)
		wave_banner.emit("Acorn Loot Chest Spawned!", Color(1.0, 0.88, 0.30))

	# Step all active enemies & rebuild SpatialGrid
	step_enemies_only(delta, player_pos, grid)

func step_enemies_only(delta: float, player_pos: Vector3, grid: SpatialGrid) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var e: EnemyEntity = enemies[i]
		if not is_instance_valid(e) or e.is_dead:
			enemies.remove_at(i)
			continue
		e.step(delta, player_pos, grid)

	grid.rebuild(enemies)

func spawn_custom_enemy(enemy_id: String, exact_pos: Vector3, hp_scale: float = 0.6, dmg_scale: float = 0.4) -> EnemyEntity:
	return _spawn_enemy(enemy_id, exact_pos, hp_scale, dmg_scale, false, exact_pos)

func _spawn_boss(boss_num: int, player_pos: Vector3) -> void:
	var boss_ids: Array[String] = ["boss_grizzle", "boss_whiskers", "boss_bramblehorn"]
	var bid: String = boss_ids[clampi(boss_num - 1, 0, boss_ids.size() - 1)]
	var prof: Dictionary = EnemyDatabase.get_wave_profile(elapsed_time)
	var boss: EnemyEntity = _spawn_enemy(bid, player_pos, 1.0, float(prof["dmg_scale"]), false)
	active_boss = boss
	boss_spawned.emit(boss)
	wave_banner.emit("BOSS %d/3: %s!" % [boss_num, boss.enemy_name], Color(1.0, 0.36, 0.32))

func _spawn_enemy(enemy_id: String, player_pos: Vector3, hp_scale: float, dmg_scale: float, is_elite: bool, exact_pos: Vector3 = Vector3.INF, speed_scale: float = 1.0) -> EnemyEntity:
	var e: EnemyEntity = EnemyEntity.new()
	e.setup(enemy_id, hp_scale, dmg_scale, is_elite, speed_scale)

	if exact_pos != Vector3.INF:
		e.position = exact_pos
	else:
		var ang: float = randf() * TAU
		var dist: float = randf_range(21.0, 27.5)
		var bound: float = ArenaBuilder.ARENA_HALF_SIZE - 2.0
		e.position = Vector3(
			clampf(player_pos.x + cos(ang) * dist, -bound, bound),
			0.0,
			clampf(player_pos.z + sin(ang) * dist, -bound, bound)
		)

	e.died.connect(_handle_enemy_died)
	if _on_enemy_proj_cb.is_valid():
		e.spawn_projectile_requested.connect(_on_enemy_proj_cb)
	if _on_enemy_telegraph_cb.is_valid():
		e.spawn_telegraph_requested.connect(_on_enemy_telegraph_cb)
	e.spawn_minion_requested.connect(func(mid: String, mpos: Vector3) -> void:
		var prof: Dictionary = EnemyDatabase.get_wave_profile(elapsed_time)
		_spawn_enemy(mid, player_pos, float(prof["hp_scale"]), float(prof["dmg_scale"]), false, mpos, float(prof.get("speed_scale", 1.0)))
	)
	e.boss_phase_announced.connect(func(bname: String, msg: String) -> void:
		wave_banner.emit("%s: %s" % [bname, msg], Color(1.0, 0.52, 0.25))
	)

	world_root.add_child(e)
	enemies.append(e)
	return e

func _handle_enemy_died(enemy: EnemyEntity) -> void:
	kills_count += 1
	enemies.erase(enemy)
	if _on_enemy_died_cb.is_valid():
		_on_enemy_died_cb.call(enemy)
	if enemy.is_boss:
		bosses_defeated_count += 1
		if active_boss == enemy:
			active_boss = null
		boss_defeated.emit(enemy.boss_index, enemy.enemy_name)
		if enemy.boss_index >= 3:
			all_bosses_cleared.emit()
	enemy.queue_free()
