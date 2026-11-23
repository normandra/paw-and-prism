class_name PlayerController
extends Node3D

signal player_hurt(dmg: float, hp_after: float)
signal player_died()
signal cheat_death_triggered()
signal reactive_nova_requested(kind: String, pos: Vector3, dmg: float, radius: float)
signal dashed()

var stats: HeroStats = null
var current_hp: float = 135.0
var is_dead: bool = false

var _rig: Node3D = null
var _body_pivot: Node3D = null
var _head_pivot: Node3D = null
var _left_foot: Node3D = null
var _right_foot: Node3D = null
var _tail_pivot: Node3D = null
var _aura_ring_holder: Node3D = null

var _facing_dir: Vector3 = Vector3(0.0, 0.0, 1.0)
var _walk_phase: float = 0.0
var _invuln_timer: float = 0.0
var _dash_timer: float = 0.0
var _dash_cooldown: float = 0.0
var _dash_dir: Vector3 = Vector3.ZERO
var _cheat_death_cd: float = 0.0
var _honey_aegis_cd: float = 0.0
var _thorns_cd: float = 0.0

var _last_weapon_style: String = ""
var _last_helmet_style: String = ""

func setup(p_stats: HeroStats) -> void:
	stats = p_stats
	current_hp = stats.max_hp
	is_dead = false
	_invuln_timer = 0.0
	_dash_timer = 0.0
	_dash_cooldown = 0.0
	_cheat_death_cd = 0.0

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

	refresh_equipment_visuals()

func refresh_equipment_visuals() -> void:
	if stats == null or _rig == null:
		return
	current_hp = minf(current_hp, stats.max_hp)
	var w_item: ItemInstance = stats.equipped.get(GameEnums.EquipSlot.WEAPON, null)
	var h_item: ItemInstance = stats.equipped.get(GameEnums.EquipSlot.HELMET, null)
	var w_style: String = w_item.visual_style if w_item != null else "acorn_wand"
	var h_style: String = h_item.visual_style if h_item != null else "ribbon_hood"
	if w_style != _last_weapon_style or h_style != _last_helmet_style:
		_last_weapon_style = w_style
		_last_helmet_style = h_style
		ChibiMeshFactory.update_hero_visual_gear(_rig, w_style, h_style)

	# Rebuild subtle passive aura rings under hero
	if _aura_ring_holder != null:
		for ch in _aura_ring_holder.get_children():
			ch.queue_free()
		var idx: int = 0
		for p_info in stats.active_passives:
			if idx >= 4:
				break
			var col: Color = p_info.get("aura_color", Color(1.0, 1.0, 1.0, 0.3))
			var ring_r: float = 0.78 + float(idx) * 0.22
			var ring: MeshInstance3D = MeshInstance3D.new()
			ring.mesh = ChibiMeshFactory._get_torus(ring_r, ring_r + 0.05)
			ring.material_override = ChibiMeshFactory.get_toon_mat(col, 0.9, 0.5)
			ring.position = Vector3(0.0, 0.05, 0.0)
			ring.scale = Vector3(1.0, 0.25, 1.0)
			ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_aura_ring_holder.add_child(ring)
			idx += 1

func get_dash_cooldown_max() -> float:
	if stats == null:
		return 2.2
	return maxf(0.65, 2.2 * stats.dash_cd_mult)

func get_dash_ready_fraction() -> float:
	var cd_max: float = get_dash_cooldown_max()
	if _dash_cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - _dash_cooldown / cd_max, 0.0, 1.0)

func step(delta: float) -> void:
	if is_dead or stats == null:
		return

	# Cooldowns & Regen
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
	if _dash_cooldown > 0.0:
		_dash_cooldown -= delta
	if _cheat_death_cd > 0.0:
		_cheat_death_cd -= delta
	if _honey_aegis_cd > 0.0:
		_honey_aegis_cd -= delta
	if _thorns_cd > 0.0:
		_thorns_cd -= delta

	if current_hp < stats.max_hp and stats.hp_regen > 0.0:
		current_hp = minf(stats.max_hp, current_hp + stats.hp_regen * delta)

	# Movement input
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

	# Trigger Hop-Dash
	var want_dash: bool = Input.is_action_just_pressed("dash") or Input.is_key_pressed(KEY_SPACE)
	if want_dash and _dash_cooldown <= 0.0 and _dash_timer <= 0.0:
		_dash_timer = 0.22
		_dash_cooldown = get_dash_cooldown_max()
		_invuln_timer = maxf(_invuln_timer, 0.26)
		_dash_dir = input_dir if input_dir.length_squared() > 0.01 else _facing_dir
		dashed.emit()

	# Apply movement
	var speed: float = stats.move_speed
	var move_delta: Vector3 = Vector3.ZERO
	if _dash_timer > 0.0:
		_dash_timer -= delta
		move_delta = _dash_dir * (speed * 2.55) * delta
	elif input_dir.length_squared() > 0.001:
		move_delta = input_dir * speed * delta

	global_position += move_delta
	var bound: float = ArenaBuilder.ARENA_HALF_SIZE - 1.5
	global_position.x = clampf(global_position.x, -bound, bound)
	global_position.z = clampf(global_position.z, -bound, bound)

	_animate_chibi(delta, move_delta.length_squared() > 0.00001)

func _animate_chibi(delta: float, is_moving: bool) -> void:
	if _rig == null or _body_pivot == null:
		return

	var target_yaw: float = atan2(_facing_dir.x, _facing_dir.z)
	_rig.rotation.y = lerp_angle(_rig.rotation.y, target_yaw, minf(1.0, delta * 14.0))

	if _aura_ring_holder != null:
		_aura_ring_holder.rotation.y += delta * 0.9

	if _dash_timer > 0.0:
		var hop_t: float = clampf(1.0 - (_dash_timer / 0.22), 0.0, 1.0)
		_body_pivot.position.y = sin(hop_t * PI) * 0.95
		_body_pivot.rotation.x = 0.25
		_body_pivot.scale = Vector3(0.92, 1.12, 0.92)
	elif is_moving:
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

	# Invulnerability blink
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

	var armor_mit: float = 100.0 / (100.0 + maxf(0.0, stats.armor) * 1.6)
	var dr_mit: float = 1.0 - (stats.dmg_reduction * 0.01)
	var final_dmg: float = maxf(1.0, raw_dmg * armor_mit * dr_mit)

	_invuln_timer = 0.45
	current_hp -= final_dmg

	# Reactive Unique/Passive triggers
	if stats.has_honey_aegis and _honey_aegis_cd <= 0.0:
		_honey_aegis_cd = 1.8
		reactive_nova_requested.emit("honey_aegis", global_position, 28.0 * stats.damage_mult, 4.8 * stats.area_mult)
	if stats.has_thorns and _thorns_cd <= 0.0:
		_thorns_cd = 1.2
		reactive_nova_requested.emit("thorns", global_position, (22.0 + stats.armor * 0.8) * stats.damage_mult, 4.2 * stats.area_mult)

	if current_hp <= 0.0:
		if stats.has_cheat_death and _cheat_death_cd <= 0.0:
			_cheat_death_cd = 90.0
			current_hp = stats.max_hp * 0.55
			_invuln_timer = 1.6
			cheat_death_triggered.emit()
			return final_dmg
		current_hp = 0.0
		is_dead = true
		player_hurt.emit(final_dmg, 0.0)
		player_died.emit()
		return final_dmg

	player_hurt.emit(final_dmg, current_hp)
	return final_dmg
