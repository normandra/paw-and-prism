class_name PlayerController
extends Node3D

signal player_hurt(dmg: float, hp_after: float)
signal player_died()
signal cheat_death_triggered()
signal reactive_nova_requested(kind: String, pos: Vector3, dmg: float, radius: float)
signal orbit_shield_requested()

var stats: HeroStats = null
var current_hp: float = 110.0
var is_dead: bool = false

var _rig: Node3D = null
var _body_pivot: Node3D = null
var _head_pivot: Node3D = null
var _left_foot: Node3D = null
var _right_foot: Node3D = null
var _tail_pivot: Node3D = null
var _aura_ring_holder: Node3D = null

var _facing_dir: Vector3 = Vector3(0.0, 0.0, 1.0)
var external_move_vec: Vector2 = Vector2.ZERO
var is_moving: bool = false
var _walk_phase: float = 0.0
var _invuln_timer: float = 0.0
var _cheat_death_cd: float = 0.0
var _thorns_cd: float = 0.0
var _orbit_shield_cd: float = 0.0
var _zoomies_timer: float = 0.0

func setup(p_stats: HeroStats) -> void:
	stats = p_stats
	current_hp = stats.max_hp
	is_dead = false
	_invuln_timer = 0.0
	_cheat_death_cd = 0.0
	_thorns_cd = 0.0
	_orbit_shield_cd = 0.0
	_zoomies_timer = 0.0
	external_move_vec = Vector2.ZERO

	if _rig != null:
		_rig.queue_free()
	_rig = ChibiMeshFactory.build_hero_rig(stats.hero_id)
	add_child(_rig)
	_body_pivot = _rig.get_node_or_null("BodyPivot")
	_head_pivot = _rig.get_node_or_null("BodyPivot/HeadPivot")
	_left_foot = _rig.get_node_or_null("BodyPivot/LeftFoot")
	_right_foot = _rig.get_node_or_null("BodyPivot/RightFoot")
	_tail_pivot = _rig.get_node_or_null("BodyPivot/TailPivot")

	if _aura_ring_holder == null:
		_aura_ring_holder = Node3D.new()
		_aura_ring_holder.name = "AuraRings"
		add_child(_aura_ring_holder)

	refresh_card_auras()

func refresh_card_auras() -> void:
	if stats == null:
		return
	current_hp = minf(current_hp, stats.max_hp)
	if _aura_ring_holder == null:
		return
	for ch in _aura_ring_holder.get_children():
		ch.queue_free()
	var count: int = mini(4, stats.equipped_cards.size())
	for idx in range(count):
		var c: CardInstance = stats.equipped_cards[idx]
		var col: Color = GameEnums.rarity_color(c.rarity)
		col.a = 0.34
		var ring_r: float = 0.78 + float(idx) * 0.20
		var ring: MeshInstance3D = MeshInstance3D.new()
		ring.mesh = ChibiMeshFactory._get_torus(ring_r, ring_r + 0.05)
		ring.material_override = ChibiMeshFactory.get_toon_mat(col, 0.9, 0.5)
		ring.position = Vector3(0.0, 0.05, 0.0)
		ring.scale = Vector3(1.0, 0.25, 1.0)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_aura_ring_holder.add_child(ring)

func set_touch_move(vec: Vector2) -> void:
	external_move_vec = vec.limit_length(1.0)

func has_zoomies_active() -> bool:
	return _zoomies_timer > 0.0

func notify_kill() -> void:
	if stats == null:
		return
	if stats.has_zoomies_on_kill:
		_zoomies_timer = BalanceConfig.ZOOMIES_DURATION

func step(delta: float) -> void:
	if is_dead or stats == null:
		return

	if _invuln_timer > 0.0:
		_invuln_timer -= delta
	if _cheat_death_cd > 0.0:
		_cheat_death_cd -= delta
	if _thorns_cd > 0.0:
		_thorns_cd -= delta
	if _orbit_shield_cd > 0.0:
		_orbit_shield_cd -= delta
	if _zoomies_timer > 0.0:
		_zoomies_timer -= delta

	if current_hp < stats.max_hp and stats.hp_regen > 0.0:
		current_hp = minf(stats.max_hp, current_hp + stats.hp_regen * delta)

	var move_vec: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_vec.x += 1.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_vec.x -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_vec.y += 1.0
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_vec.y -= 1.0

	var input_dir: Vector3 = Vector3.ZERO
	if move_vec.length_squared() > 0.001:
		move_vec = move_vec.normalized()
		input_dir = Vector3(move_vec.x, 0.0, move_vec.y)
		_facing_dir = input_dir
	elif external_move_vec.length_squared() > 0.001:
		input_dir = Vector3(external_move_vec.x, 0.0, external_move_vec.y)
		_facing_dir = input_dir.normalized()

	var moving_input: bool = input_dir.length_squared() > 0.001
	var zoomies_mult: float = 1.0
	if _zoomies_timer > 0.0 and stats.zoomies_stacks > 0:
		zoomies_mult = BalanceConfig.ZOOMIES_SPEED_MULT + BalanceConfig.ZOOMIES_SPEED_STACK * float(stats.zoomies_stacks - 1)
	var speed: float = stats.move_speed * zoomies_mult
	var move_delta: Vector3 = input_dir * speed * delta if moving_input else Vector3.ZERO

	global_position += move_delta
	var bound: float = ArenaBuilder.ARENA_HALF_SIZE - 1.5
	global_position.x = clampf(global_position.x, -bound, bound)
	global_position.z = clampf(global_position.z, -bound, bound)

	var step_dist: float = Vector2(move_delta.x, move_delta.z).length()
	is_moving = step_dist > 0.002

	_animate_chibi(delta, is_moving)

func _animate_chibi(delta: float, moving_now: bool) -> void:
	if _rig == null or _body_pivot == null:
		return

	var target_yaw: float = atan2(_facing_dir.x, _facing_dir.z)
	_rig.rotation.y = lerp_angle(_rig.rotation.y, target_yaw, minf(1.0, delta * 14.0))

	if _aura_ring_holder != null:
		_aura_ring_holder.rotation.y += delta * 0.9

	if moving_now:
		_walk_phase += delta * 15.0
		var hop: float = absf(sin(_walk_phase)) * 0.14
		_body_pivot.position.y = hop
		_body_pivot.rotation.z = sin(_walk_phase) * 0.10
		_body_pivot.rotation.x = 0.08
		_body_pivot.scale = Vector3(1.0, 1.0 + sin(_walk_phase * 2.0) * 0.04, 1.0)
		if _left_foot != null and _right_foot != null:
			_left_foot.position.z = 0.04 + sin(_walk_phase) * 0.14
			_right_foot.position.z = 0.04 - sin(_walk_phase) * 0.14
	else:
		_walk_phase += delta * 3.8
		_body_pivot.position.y = sin(_walk_phase) * 0.03
		_body_pivot.rotation.z = lerpf(_body_pivot.rotation.z, 0.0, minf(1.0, delta * 10.0))
		_body_pivot.rotation.x = lerpf(_body_pivot.rotation.x, 0.0, minf(1.0, delta * 10.0))
		_body_pivot.scale = Vector3(1.0, 1.0 + sin(_walk_phase) * 0.025, 1.0)

	if _tail_pivot != null:
		_tail_pivot.rotation.y = sin(_walk_phase * 1.4) * 0.35

	if _invuln_timer > 0.0:
		_rig.visible = int(floor(_invuln_timer * 24.0)) % 2 == 0
	else:
		_rig.visible = true

func heal(amount: float) -> void:
	if is_dead or stats == null or amount <= 0.0:
		return
	current_hp = minf(stats.max_hp, current_hp + amount)

func take_damage(raw_dmg: float, bypass_invuln: bool = false) -> float:
	if is_dead or stats == null:
		return 0.0
	if _invuln_timer > 0.0 and not bypass_invuln:
		return 0.0

	var final_dmg: float = maxf(1.0, raw_dmg * stats.incoming_dmg_mult)

	_invuln_timer = BalanceConfig.HIT_INVULN_SEC
	current_hp -= final_dmg

	if stats.has_thorns_burst and _thorns_cd <= 0.0:
		_thorns_cd = BalanceConfig.THORNS_CD
		var tdmg: float = BalanceConfig.THORNS_DMG + BalanceConfig.THORNS_STACK * float(maxi(0, stats.thorns_stacks - 1))
		reactive_nova_requested.emit("thorns_burst", global_position, tdmg, BalanceConfig.THORNS_RADIUS)
	if stats.has_orbit_shield and _orbit_shield_cd <= 0.0:
		_orbit_shield_cd = BalanceConfig.ORBIT_SHIELD_CD
		orbit_shield_requested.emit()

	if current_hp <= 0.0:
		if stats.has_cheat_death and _cheat_death_cd <= 0.0:
			var cd_red: float = BalanceConfig.CHEAT_DEATH_CD_REDUCTION * float(maxi(0, stats.nine_lives_stacks - 1))
			_cheat_death_cd = maxf(30.0, BalanceConfig.CHEAT_DEATH_CD - cd_red)
			current_hp = stats.max_hp * BalanceConfig.CHEAT_DEATH_HEAL_PCT
			_invuln_timer = BalanceConfig.CHEAT_DEATH_INVULN
			cheat_death_triggered.emit()
			return final_dmg
		current_hp = 0.0
		is_dead = true
		player_hurt.emit(final_dmg, 0.0)
		player_died.emit()
		return final_dmg

	player_hurt.emit(final_dmg, current_hp)
	return final_dmg
