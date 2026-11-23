class_name ChibiMeshFactory

static var _mat_cache: Dictionary = {}
static var _mesh_cache: Dictionary = {}
static var _hit_flash_mat: StandardMaterial3D = null

static func get_hit_flash_material() -> StandardMaterial3D:
	if _hit_flash_mat == null:
		_hit_flash_mat = StandardMaterial3D.new()
		_hit_flash_mat.albedo_color = Color(1.0, 1.0, 1.0)
		_hit_flash_mat.emission_enabled = true
		_hit_flash_mat.emission = Color(1.0, 0.96, 0.92)
		_hit_flash_mat.emission_energy_multiplier = 2.2
		_hit_flash_mat.roughness = 0.3
	return _hit_flash_mat

static func get_toon_mat(color: Color, emission_strength: float = 0.0, roughness: float = 0.58) -> StandardMaterial3D:
	var key: String = "%.2f_%.2f_%.2f_%.2f_%.2f_%.2f" % [color.r, color.g, color.b, color.a, emission_strength, roughness]
	if _mat_cache.has(key):
		return _mat_cache[key]
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
	mat.roughness = roughness
	mat.rim_enabled = true
	mat.rim = 0.28
	mat.rim_tint = 0.35
	if color.a < 0.99:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emission_strength > 0.01:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_strength
	_mat_cache[key] = mat
	return mat

static func _get_sphere(radius: float) -> SphereMesh:
	var key: String = "sph_%.3f" % radius
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: SphereMesh = SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 16
	m.rings = 10
	_mesh_cache[key] = m
	return m

static func _get_capsule(radius: float, height: float) -> CapsuleMesh:
	var key: String = "cap_%.3f_%.3f" % [radius, height]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: CapsuleMesh = CapsuleMesh.new()
	m.radius = radius
	m.height = height
	m.radial_segments = 14
	m.rings = 6
	_mesh_cache[key] = m
	return m

static func _get_cylinder(top_r: float, bot_r: float, height: float, segs: int = 12) -> CylinderMesh:
	var key: String = "cyl_%.3f_%.3f_%.3f_%d" % [top_r, bot_r, height, segs]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: CylinderMesh = CylinderMesh.new()
	m.top_radius = top_r
	m.bottom_radius = bot_r
	m.height = height
	m.radial_segments = segs
	_mesh_cache[key] = m
	return m

static func _get_box(size: Vector3) -> BoxMesh:
	var key: String = "box_%.3f_%.3f_%.3f" % [size.x, size.y, size.z]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: BoxMesh = BoxMesh.new()
	m.size = size
	_mesh_cache[key] = m
	return m

static func _get_torus(inner_r: float, outer_r: float) -> TorusMesh:
	var key: String = "tor_%.3f_%.3f" % [inner_r, outer_r]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: TorusMesh = TorusMesh.new()
	m.inner_radius = inner_r
	m.outer_radius = outer_r
	m.rings = 18
	m.ring_segments = 8
	_mesh_cache[key] = m
	return m

static func _get_prism(size: Vector3) -> PrismMesh:
	var key: String = "prs_%.3f_%.3f_%.3f" % [size.x, size.y, size.z]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var m: PrismMesh = PrismMesh.new()
	m.size = size
	_mesh_cache[key] = m
	return m

static func _make_part(mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE, cast_shadow: bool = true) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

static func _add_shadow_disc(parent: Node3D, radius: float) -> void:
	var disc: MeshInstance3D = _make_part(
		_get_cylinder(radius, radius, 0.02, 14),
		get_toon_mat(Color(0.05, 0.08, 0.06, 0.34), 0.0, 1.0),
		Vector3(0.0, 0.02, 0.0),
		Vector3.ZERO,
		Vector3.ONE,
		false
	)
	disc.name = "ShadowDisc"
	parent.add_child(disc)

static func _add_cute_eyes(head: Node3D, y_pos: float, z_pos: float, spacing: float, eye_r: float, iris_color: Color = Color(0.08, 0.07, 0.10)) -> void:
	var eye_mat: StandardMaterial3D = get_toon_mat(iris_color, 0.0, 0.15)
	var shine_mat: StandardMaterial3D = get_toon_mat(Color(1.0, 1.0, 1.0), 0.65, 0.1)
	var blush_mat: StandardMaterial3D = get_toon_mat(Color(1.0, 0.56, 0.64), 0.0, 0.7)
	for side in [-1.0, 1.0]:
		var eye: MeshInstance3D = _make_part(_get_sphere(eye_r), eye_mat, Vector3(side * spacing, y_pos, z_pos), Vector3.ZERO, Vector3(0.92, 1.12, 0.72), false)
		head.add_child(eye)
		var shine: MeshInstance3D = _make_part(_get_sphere(eye_r * 0.36), shine_mat, Vector3(side * spacing - eye_r * 0.28, y_pos + eye_r * 0.34, z_pos + eye_r * 0.52), Vector3.ZERO, Vector3.ONE, false)
		head.add_child(shine)
		var blush: MeshInstance3D = _make_part(_get_sphere(eye_r * 0.95), blush_mat, Vector3(side * (spacing + eye_r * 1.1), y_pos - eye_r * 1.25, z_pos - eye_r * 0.25), Vector3.ZERO, Vector3(1.1, 0.55, 0.45), false)
		head.add_child(blush)

static func build_hero_rig(hero_id: String) -> Node3D:
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	var c_prim: Color = hdef["primary_color"]
	var c_sec: Color = hdef["secondary_color"]
	var c_acc: Color = hdef["accent_color"]

	var mat_prim: StandardMaterial3D = get_toon_mat(c_prim)
	var mat_sec: StandardMaterial3D = get_toon_mat(c_sec)
	var mat_acc: StandardMaterial3D = get_toon_mat(c_acc)
	var mat_pink: StandardMaterial3D = get_toon_mat(Color(1.0, 0.68, 0.76))
	var mat_nose: StandardMaterial3D = get_toon_mat(Color(0.16, 0.12, 0.14), 0.0, 0.25)

	var root: Node3D = Node3D.new()
	root.name = "ChibiHero_" + hero_id
	_add_shadow_disc(root, 0.55)

	var body_pivot: Node3D = Node3D.new()
	body_pivot.name = "BodyPivot"
	root.add_child(body_pivot)

	# Plump chibi torso
	var torso: MeshInstance3D = _make_part(_get_capsule(0.30, 0.64), mat_prim, Vector3(0.0, 0.44, 0.0), Vector3.ZERO, Vector3(1.06, 0.95, 0.96))
	body_pivot.add_child(torso)

	# Cute cream/white belly patch
	var belly: MeshInstance3D = _make_part(_get_sphere(0.24), mat_sec, Vector3(0.0, 0.42, 0.17), Vector3.ZERO, Vector3(0.92, 1.05, 0.65), false)
	body_pivot.add_child(belly)

	# Cozy scarf/collar
	var collar: MeshInstance3D = _make_part(_get_torus(0.18, 0.30), mat_acc, Vector3(0.0, 0.66, 0.02), Vector3(8.0, 0.0, 0.0), Vector3(1.05, 0.85, 1.05))
	body_pivot.add_child(collar)

	# Stubby feet
	var left_foot: Node3D = Node3D.new()
	left_foot.name = "LeftFoot"
	left_foot.position = Vector3(0.16, 0.13, 0.04)
	left_foot.add_child(_make_part(_get_sphere(0.13), mat_sec, Vector3.ZERO, Vector3.ZERO, Vector3(0.95, 0.72, 1.25)))
	body_pivot.add_child(left_foot)

	var right_foot: Node3D = Node3D.new()
	right_foot.name = "RightFoot"
	right_foot.position = Vector3(-0.16, 0.13, 0.04)
	right_foot.add_child(_make_part(_get_sphere(0.13), mat_sec, Vector3.ZERO, Vector3.ZERO, Vector3(0.95, 0.72, 1.25)))
	body_pivot.add_child(right_foot)

	# Stubby paws
	var left_paw: MeshInstance3D = _make_part(_get_sphere(0.11), mat_sec, Vector3(0.33, 0.44, 0.10), Vector3.ZERO, Vector3(0.85, 0.9, 1.15))
	body_pivot.add_child(left_paw)
	var right_paw: MeshInstance3D = _make_part(_get_sphere(0.11), mat_sec, Vector3(-0.33, 0.44, 0.10), Vector3.ZERO, Vector3(0.85, 0.9, 1.15))
	body_pivot.add_child(right_paw)

	# Weapon mount attached near right paw
	var weapon_mount: Node3D = Node3D.new()
	weapon_mount.name = "WeaponMount"
	weapon_mount.position = Vector3(-0.37, 0.48, 0.22)
	body_pivot.add_child(weapon_mount)

	# Tail pivot on -Z
	var tail_pivot: Node3D = Node3D.new()
	tail_pivot.name = "TailPivot"
	tail_pivot.position = Vector3(0.0, 0.30, -0.26)
	body_pivot.add_child(tail_pivot)
	match hero_id:
		"shiba":
			var t1: MeshInstance3D = _make_part(_get_capsule(0.11, 0.34), mat_prim, Vector3(0.0, 0.16, -0.10), Vector3(-42.0, 0.0, 0.0))
			var t2: MeshInstance3D = _make_part(_get_sphere(0.13), mat_sec, Vector3(0.0, 0.30, -0.06), Vector3.ZERO)
			tail_pivot.add_child(t1)
			tail_pivot.add_child(t2)
		"bunny":
			tail_pivot.add_child(_make_part(_get_sphere(0.15), mat_sec, Vector3(0.0, 0.02, -0.08)))
		"bear":
			tail_pivot.add_child(_make_part(_get_sphere(0.12), mat_prim, Vector3(0.0, 0.02, -0.06)))
		"cat":
			var c_tail: MeshInstance3D = _make_part(_get_capsule(0.06, 0.50), mat_prim, Vector3(0.0, 0.20, -0.14), Vector3(-48.0, 0.0, 0.0))
			var c_tip: MeshInstance3D = _make_part(_get_sphere(0.07), mat_sec, Vector3(0.0, 0.38, -0.30))
			tail_pivot.add_child(c_tail)
			tail_pivot.add_child(c_tip)

	# Big adorable chibi head!
	var head_pivot: Node3D = Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0.0, 1.00, 0.02)
	body_pivot.add_child(head_pivot)

	var head_sphere: MeshInstance3D = _make_part(_get_sphere(0.41), mat_prim, Vector3.ZERO, Vector3.ZERO, Vector3(1.08, 0.94, 0.98))
	head_pivot.add_child(head_sphere)

	# Cheek / muzzle patches
	if hero_id == "shiba" or hero_id == "cat":
		head_pivot.add_child(_make_part(_get_sphere(0.24), mat_sec, Vector3(0.0, -0.10, 0.26), Vector3.ZERO, Vector3(1.18, 0.72, 0.68), false))
	elif hero_id == "bear":
		head_pivot.add_child(_make_part(_get_sphere(0.20), mat_sec, Vector3(0.0, -0.08, 0.30), Vector3.ZERO, Vector3(1.05, 0.80, 0.68), false))
	else:
		head_pivot.add_child(_make_part(_get_sphere(0.16), mat_sec, Vector3(0.0, -0.08, 0.32), Vector3.ZERO, Vector3(1.0, 0.75, 0.55), false))

	# Nose & cute eyes
	var nose_mat: StandardMaterial3D = mat_pink if hero_id == "bunny" else mat_nose
	head_pivot.add_child(_make_part(_get_sphere(0.055), nose_mat, Vector3(0.0, -0.02, 0.42), Vector3.ZERO, Vector3(1.15, 0.85, 0.85), false))
	_add_cute_eyes(head_pivot, 0.06, 0.36, 0.165, 0.065)

	# Species ears!
	match hero_id:
		"shiba":
			for side in [-1.0, 1.0]:
				var ear: MeshInstance3D = _make_part(_get_cylinder(0.02, 0.15, 0.28, 8), mat_prim, Vector3(side * 0.25, 0.36, 0.0), Vector3(8.0, 0.0, -side * 18.0))
				var ear_in: MeshInstance3D = _make_part(_get_cylinder(0.01, 0.09, 0.20, 8), mat_pink, Vector3(side * 0.25, 0.35, 0.04), Vector3(8.0, 0.0, -side * 18.0), Vector3.ONE, false)
				head_pivot.add_child(ear)
				head_pivot.add_child(ear_in)
		"bunny":
			for side in [-1.0, 1.0]:
				var ear_l: MeshInstance3D = _make_part(_get_capsule(0.11, 0.46), mat_prim, Vector3(side * 0.23, 0.46, -0.02), Vector3(-10.0, 0.0, -side * 22.0))
				var ear_in: MeshInstance3D = _make_part(_get_capsule(0.065, 0.34), mat_sec, Vector3(side * 0.23, 0.45, 0.04), Vector3(-10.0, 0.0, -side * 22.0), Vector3.ONE, false)
				head_pivot.add_child(ear_l)
				head_pivot.add_child(ear_in)
		"bear":
			for side in [-1.0, 1.0]:
				var b_ear: MeshInstance3D = _make_part(_get_sphere(0.15), mat_prim, Vector3(side * 0.30, 0.32, 0.0), Vector3.ZERO, Vector3(1.0, 1.0, 0.65))
				var b_in: MeshInstance3D = _make_part(_get_sphere(0.085), mat_sec, Vector3(side * 0.30, 0.32, 0.05), Vector3.ZERO, Vector3(1.0, 1.0, 0.5), false)
				head_pivot.add_child(b_ear)
				head_pivot.add_child(b_in)
		"cat":
			for side in [-1.0, 1.0]:
				var c_ear: MeshInstance3D = _make_part(_get_cylinder(0.015, 0.14, 0.27, 6), mat_prim, Vector3(side * 0.25, 0.35, 0.02), Vector3(6.0, 0.0, -side * 22.0))
				var c_in: MeshInstance3D = _make_part(_get_cylinder(0.01, 0.08, 0.18, 6), mat_pink, Vector3(side * 0.25, 0.34, 0.05), Vector3(6.0, 0.0, -side * 22.0), Vector3.ONE, false)
				head_pivot.add_child(c_ear)
				head_pivot.add_child(c_in)
			# Cute golden collar bell
			body_pivot.add_child(_make_part(_get_sphere(0.085), mat_acc, Vector3(0.0, 0.60, 0.29)))

	var hat_mount: Node3D = Node3D.new()
	hat_mount.name = "HatMount"
	hat_mount.position = Vector3(0.0, 0.37, 0.0)
	head_pivot.add_child(hat_mount)

	return root

static func update_hero_visual_gear(rig: Node3D, weapon_style: String, helmet_style: String) -> void:
	var weapon_mount: Node3D = rig.get_node_or_null("BodyPivot/WeaponMount")
	if weapon_mount != null:
		for ch in weapon_mount.get_children():
			ch.queue_free()
		_build_chibi_weapon(weapon_mount, weapon_style)

	var hat_mount: Node3D = rig.get_node_or_null("BodyPivot/HeadPivot/HatMount")
	if hat_mount != null:
		for ch in hat_mount.get_children():
			ch.queue_free()
		_build_chibi_hat(hat_mount, helmet_style)

static func _build_chibi_weapon(mount: Node3D, style: String) -> void:
	var wood: StandardMaterial3D = get_toon_mat(Color(0.54, 0.34, 0.18))
	var gold: StandardMaterial3D = get_toon_mat(Color(1.0, 0.80, 0.26), 0.35)
	match style:
		"acorn_wand":
			mount.add_child(_make_part(_get_cylinder(0.035, 0.035, 0.55, 8), wood, Vector3(0.0, 0.18, 0.08), Vector3(32.0, 0.0, 0.0)))
			mount.add_child(_make_part(_get_sphere(0.11), get_toon_mat(Color(0.84, 0.62, 0.28)), Vector3(0.0, 0.40, 0.22)))
			mount.add_child(_make_part(_get_cylinder(0.08, 0.13, 0.08, 10), wood, Vector3(0.0, 0.47, 0.26), Vector3(32.0, 0.0, 0.0)))
		"honey_hammer":
			mount.add_child(_make_part(_get_cylinder(0.04, 0.04, 0.62, 8), wood, Vector3(0.0, 0.20, 0.08), Vector3(28.0, 0.0, 0.0)))
			mount.add_child(_make_part(_get_cylinder(0.16, 0.16, 0.36, 10), gold, Vector3(0.0, 0.46, 0.22), Vector3(28.0, 0.0, 90.0)))
		"star_staff":
			mount.add_child(_make_part(_get_cylinder(0.03, 0.035, 0.72, 8), get_toon_mat(Color(0.45, 0.35, 0.75)), Vector3(0.0, 0.22, 0.06), Vector3(24.0, 0.0, 0.0)))
			mount.add_child(_make_part(_get_sphere(0.12), get_toon_mat(Color(0.45, 0.88, 1.0), 0.9), Vector3(0.0, 0.56, 0.20)))
		"paw_claws":
			var steel: StandardMaterial3D = get_toon_mat(Color(0.82, 0.90, 1.0), 0.45)
			for off_x in [-0.05, 0.0, 0.05]:
				mount.add_child(_make_part(_get_prism(Vector3(0.035, 0.26, 0.035)), steel, Vector3(off_x, 0.06, 0.14), Vector3(75.0, 0.0, 0.0)))

static func _build_chibi_hat(mount: Node3D, style: String) -> void:
	match style:
		"wizard_hat":
			var wiz: StandardMaterial3D = get_toon_mat(Color(0.32, 0.34, 0.78))
			var band: StandardMaterial3D = get_toon_mat(Color(1.0, 0.82, 0.28), 0.35)
			mount.add_child(_make_part(_get_cylinder(0.32, 0.36, 0.05, 14), wiz, Vector3(0.0, 0.0, 0.0)))
			mount.add_child(_make_part(_get_cylinder(0.18, 0.21, 0.08, 12), band, Vector3(0.0, 0.05, 0.0)))
			mount.add_child(_make_part(_get_cylinder(0.02, 0.19, 0.36, 12), wiz, Vector3(0.0, 0.23, -0.02), Vector3(-10.0, 0.0, 0.0)))
		"leaf_crown":
			var leaf: StandardMaterial3D = get_toon_mat(Color(0.36, 0.82, 0.38))
			var flower: StandardMaterial3D = get_toon_mat(Color(1.0, 0.86, 0.32), 0.25)
			mount.add_child(_make_part(_get_torus(0.16, 0.24), leaf, Vector3(0.0, 0.01, 0.0)))
			mount.add_child(_make_part(_get_sphere(0.075), flower, Vector3(0.14, 0.06, 0.14)))
			mount.add_child(_make_part(_get_sphere(0.075), flower, Vector3(-0.14, 0.06, 0.14)))
		"knight_helm":
			var steel: StandardMaterial3D = get_toon_mat(Color(0.76, 0.80, 0.88), 0.0, 0.3)
			var plume: StandardMaterial3D = get_toon_mat(Color(0.95, 0.34, 0.38))
			mount.add_child(_make_part(_get_sphere(0.24), steel, Vector3(0.0, -0.02, 0.0), Vector3.ZERO, Vector3(1.05, 0.75, 1.05)))
			mount.add_child(_make_part(_get_capsule(0.06, 0.24), plume, Vector3(0.0, 0.17, -0.05), Vector3(-35.0, 0.0, 0.0)))
		"ribbon_hood":
			var rib: StandardMaterial3D = get_toon_mat(Color(0.96, 0.38, 0.50))
			mount.add_child(_make_part(_get_sphere(0.08), rib, Vector3(0.0, 0.02, 0.14)))
			mount.add_child(_make_part(_get_box(Vector3(0.18, 0.10, 0.08)), rib, Vector3(0.12, 0.03, 0.10), Vector3(0.0, 0.0, 22.0)))
			mount.add_child(_make_part(_get_box(Vector3(0.18, 0.10, 0.08)), rib, Vector3(-0.12, 0.03, 0.10), Vector3(0.0, 0.0, -22.0)))

static func build_enemy_rig(enemy_id: String, is_elite: bool = false) -> Node3D:
	var edef: Dictionary = EnemyDatabase.get_def(enemy_id)
	var col: Color = edef["color"]
	var acc: Color = edef["accent"]
	var is_boss: bool = bool(edef.get("is_boss", false))

	var mat_main: StandardMaterial3D = get_toon_mat(col)
	var mat_acc: StandardMaterial3D = get_toon_mat(acc)
	var mat_gold: StandardMaterial3D = get_toon_mat(Color(1.0, 0.82, 0.24), 0.55)

	var root: Node3D = Node3D.new()
	root.name = "Enemy_" + enemy_id
	var shadow_r: float = float(edef.get("radius", 0.7)) * 0.85
	_add_shadow_disc(root, shadow_r)

	if is_elite and not is_boss:
		var elite_ring: MeshInstance3D = _make_part(
			_get_torus(shadow_r * 0.88, shadow_r * 1.06),
			get_toon_mat(Color(0.86, 0.40, 1.0, 0.75), 1.0, 0.4),
			Vector3(0.0, 0.05, 0.0),
			Vector3.ZERO,
			Vector3(1.0, 0.3, 1.0),
			false
		)
		root.add_child(elite_ring)

	var body_pivot: Node3D = Node3D.new()
	body_pivot.name = "BodyPivot"
	root.add_child(body_pivot)

	match enemy_id:
		"slime_frog":
			body_pivot.add_child(_make_part(_get_sphere(0.45), mat_main, Vector3(0.0, 0.36, 0.0), Vector3.ZERO, Vector3(1.12, 0.85, 1.05)))
			body_pivot.add_child(_make_part(_get_sphere(0.32), mat_acc, Vector3(0.0, 0.28, 0.18), Vector3.ZERO, Vector3(0.95, 0.75, 0.65), false))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_sphere(0.14), mat_main, Vector3(s * 0.20, 0.68, 0.16)))
			_add_cute_eyes(body_pivot, 0.70, 0.26, 0.20, 0.075, Color(0.12, 0.08, 0.12))
		"hedgehog":
			body_pivot.add_child(_make_part(_get_sphere(0.42), mat_main, Vector3(0.0, 0.38, 0.0), Vector3.ZERO, Vector3(1.0, 0.9, 1.1)))
			body_pivot.add_child(_make_part(_get_sphere(0.28), mat_acc, Vector3(0.0, 0.36, 0.24), Vector3.ZERO, Vector3(0.9, 0.85, 0.75), false))
			for sp in [Vector3(0, 0.68, -0.15), Vector3(0.24, 0.56, -0.20), Vector3(-0.24, 0.56, -0.20), Vector3(0.16, 0.66, 0.05), Vector3(-0.16, 0.66, 0.05)]:
				body_pivot.add_child(_make_part(_get_cylinder(0.01, 0.10, 0.30, 6), mat_main, sp, Vector3(-42.0, 0.0, 0.0)))
			_add_cute_eyes(body_pivot, 0.42, 0.36, 0.15, 0.055)
		"bat_owl":
			body_pivot.add_child(_make_part(_get_sphere(0.40), mat_main, Vector3(0.0, 0.58, 0.0), Vector3.ZERO, Vector3(1.0, 1.05, 0.95)))
			body_pivot.add_child(_make_part(_get_sphere(0.25), mat_acc, Vector3(0.0, 0.54, 0.22), Vector3.ZERO, Vector3(0.9, 0.95, 0.6), false))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_box(Vector3(0.42, 0.06, 0.26)), mat_main, Vector3(s * 0.46, 0.62, -0.02), Vector3(0.0, 0.0, s * 18.0)))
				body_pivot.add_child(_make_part(_get_cylinder(0.01, 0.08, 0.20, 6), mat_main, Vector3(s * 0.20, 0.96, 0.0), Vector3(0.0, 0.0, -s * 20.0)))
			_add_cute_eyes(body_pivot, 0.64, 0.34, 0.15, 0.068, Color(1.0, 0.85, 0.20))
		"acorn_boar":
			body_pivot.add_child(_make_part(_get_capsule(0.44, 0.96), mat_main, Vector3(0.0, 0.46, 0.0), Vector3(90.0, 0.0, 0.0)))
			body_pivot.add_child(_make_part(_get_cylinder(0.18, 0.20, 0.12, 10), mat_acc, Vector3(0.0, 0.44, 0.52), Vector3(90.0, 0.0, 0.0)))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_cylinder(0.01, 0.06, 0.22, 6), get_toon_mat(Color(0.98, 0.96, 0.88)), Vector3(s * 0.20, 0.42, 0.52), Vector3(45.0, 0.0, -s * 20.0)))
			_add_cute_eyes(body_pivot, 0.62, 0.40, 0.20, 0.065)
		"gloom_fox":
			body_pivot.add_child(_make_part(_get_capsule(0.32, 0.72), mat_main, Vector3(0.0, 0.44, 0.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.38), mat_main, Vector3(0.0, 0.94, 0.04)))
			body_pivot.add_child(_make_part(_get_sphere(0.18), mat_acc, Vector3(0.0, 0.88, 0.32), Vector3.ZERO, Vector3(0.9, 0.7, 0.7), false))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_cylinder(0.01, 0.13, 0.32, 6), mat_main, Vector3(s * 0.22, 1.28, 0.0), Vector3(0.0, 0.0, -s * 16.0)))
			body_pivot.add_child(_make_part(_get_capsule(0.14, 0.48), mat_acc, Vector3(0.0, 0.46, -0.36), Vector3(-48.0, 0.0, 0.0)))
			_add_cute_eyes(body_pivot, 0.98, 0.34, 0.16, 0.062, Color(0.95, 0.45, 1.0))
		"raccoon_bandit":
			body_pivot.add_child(_make_part(_get_capsule(0.36, 0.76), mat_main, Vector3(0.0, 0.46, 0.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.40), mat_main, Vector3(0.0, 0.98, 0.02)))
			# Bandit eye mask
			body_pivot.add_child(_make_part(_get_box(Vector3(0.56, 0.15, 0.16)), get_toon_mat(Color(0.12, 0.13, 0.16)), Vector3(0.0, 1.02, 0.33)))
			_add_cute_eyes(body_pivot, 1.02, 0.38, 0.16, 0.065, Color(1.0, 0.88, 0.30))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_sphere(0.12), mat_main, Vector3(s * 0.26, 1.30, 0.0)))
			body_pivot.add_child(_make_part(_get_capsule(0.14, 0.50), mat_acc, Vector3(0.0, 0.42, -0.38), Vector3(-52.0, 0.0, 0.0)))
		"shroom_toad":
			body_pivot.add_child(_make_part(_get_sphere(0.42), mat_acc, Vector3(0.0, 0.38, 0.0), Vector3.ZERO, Vector3(1.0, 0.88, 1.0)))
			# Big spotted mushroom cap!
			body_pivot.add_child(_make_part(_get_sphere(0.56), mat_main, Vector3(0.0, 0.76, 0.0), Vector3.ZERO, Vector3(1.15, 0.62, 1.15)))
			for spot in [Vector3(0.28, 0.90, 0.24), Vector3(-0.28, 0.90, 0.22), Vector3(0.0, 0.96, -0.32)]:
				body_pivot.add_child(_make_part(_get_sphere(0.12), mat_acc, spot, Vector3.ZERO, Vector3.ONE, false))
			_add_cute_eyes(body_pivot, 0.44, 0.36, 0.16, 0.062)
		"boss_grizzle":
			# Giant Honey-Armored Bear King
			body_pivot.add_child(_make_part(_get_capsule(0.86, 1.85), mat_main, Vector3(0.0, 1.10, 0.0), Vector3.ZERO, Vector3(1.1, 1.0, 1.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.65), mat_acc, Vector3(0.0, 1.02, 0.48), Vector3.ZERO, Vector3(1.0, 1.05, 0.65), false))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_sphere(0.38), mat_gold, Vector3(s * 0.95, 1.50, 0.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.90), mat_main, Vector3(0.0, 2.38, 0.08)))
			body_pivot.add_child(_make_part(_get_sphere(0.42), mat_acc, Vector3(0.0, 2.22, 0.74), Vector3.ZERO, Vector3(1.05, 0.78, 0.65), false))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_sphere(0.30), mat_main, Vector3(s * 0.66, 3.04, 0.04)))
			body_pivot.add_child(_make_part(_get_cylinder(0.46, 0.38, 0.38, 8), mat_gold, Vector3(0.0, 3.30, 0.08)))
			_add_cute_eyes(body_pivot, 2.48, 0.85, 0.34, 0.12, Color(1.0, 0.55, 0.15))
		"boss_whiskers":
			# Arcane Owl-Empress
			var mat_arcane: StandardMaterial3D = get_toon_mat(Color(0.42, 0.92, 1.0), 0.95)
			body_pivot.add_child(_make_part(_get_capsule(0.76, 1.80), mat_main, Vector3(0.0, 1.25, 0.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.84), mat_main, Vector3(0.0, 2.40, 0.05)))
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_box(Vector3(1.25, 0.16, 0.68)), mat_main, Vector3(s * 1.22, 1.55, -0.05), Vector3(0.0, 0.0, s * 22.0)))
				body_pivot.add_child(_make_part(_get_cylinder(0.02, 0.22, 0.52, 6), mat_arcane, Vector3(s * 0.52, 3.16, 0.04), Vector3(0.0, 0.0, -s * 22.0)))
			body_pivot.add_child(_make_part(_get_torus(1.15, 1.38), mat_arcane, Vector3(0.0, 2.20, -0.58), Vector3(90.0, 0.0, 0.0)))
			_add_cute_eyes(body_pivot, 2.48, 0.78, 0.32, 0.13, Color(0.45, 0.96, 1.0))
		"boss_bramblehorn":
			# King Bramblehorn, Prism Stag-Dragon
			var mat_prism: StandardMaterial3D = get_toon_mat(Color(1.0, 0.42, 0.88), 1.1)
			var mat_cyan: StandardMaterial3D = get_toon_mat(Color(0.40, 0.95, 1.0), 1.0)
			body_pivot.add_child(_make_part(_get_capsule(0.95, 2.15), mat_main, Vector3(0.0, 1.35, 0.0)))
			body_pivot.add_child(_make_part(_get_sphere(0.98), mat_main, Vector3(0.0, 2.75, 0.10)))
			body_pivot.add_child(_make_part(_get_sphere(0.44), mat_acc, Vector3(0.0, 2.55, 0.84), Vector3.ZERO, Vector3(1.05, 0.78, 0.75), false))
			# Towering prismatic crystal antlers
			for s in [-1.0, 1.0]:
				body_pivot.add_child(_make_part(_get_cylinder(0.05, 0.16, 1.25, 6), mat_prism, Vector3(s * 0.65, 3.72, 0.0), Vector3(0.0, 0.0, -s * 28.0)))
				body_pivot.add_child(_make_part(_get_cylinder(0.03, 0.10, 0.72, 6), mat_cyan, Vector3(s * 0.96, 3.88, 0.14), Vector3(15.0, 0.0, -s * 50.0)))
				body_pivot.add_child(_make_part(_get_box(Vector3(1.15, 0.18, 0.65)), mat_prism, Vector3(s * 1.18, 1.75, -0.18), Vector3(0.0, 0.0, s * 25.0)))
			body_pivot.add_child(_make_part(_get_torus(1.30, 1.56), mat_cyan, Vector3(0.0, 2.40, -0.68), Vector3(90.0, 0.0, 0.0)))
			_add_cute_eyes(body_pivot, 2.84, 0.92, 0.38, 0.14, Color(1.0, 0.88, 0.35))

	if is_elite and not is_boss:
		body_pivot.add_child(_make_part(_get_cylinder(0.18, 0.14, 0.16, 6), mat_gold, Vector3(0.0, 1.25, 0.0)))

	return root

static func build_loot_mesh(kind: String, color: Color, rarity: int = 0) -> Node3D:
	var root: Node3D = Node3D.new()
	var spin_pivot: Node3D = Node3D.new()
	spin_pivot.name = "SpinPivot"
	root.add_child(spin_pivot)

	match kind:
		"xp":
			var m: MeshInstance3D = _make_part(_get_prism(Vector3(0.28, 0.40, 0.28)), get_toon_mat(color, 0.9, 0.2), Vector3(0.0, 0.28, 0.0), Vector3.ZERO, Vector3.ONE, false)
			spin_pivot.add_child(m)
		"heart":
			var mat_h: StandardMaterial3D = get_toon_mat(Color(1.0, 0.28, 0.46), 0.7, 0.3)
			spin_pivot.add_child(_make_part(_get_sphere(0.26), mat_h, Vector3(0.0, 0.32, 0.0), Vector3.ZERO, Vector3(1.15, 0.95, 0.8), false))
		"dust":
			var mat_d: StandardMaterial3D = get_toon_mat(Color(0.55, 0.92, 1.0), 1.0, 0.2)
			spin_pivot.add_child(_make_part(_get_prism(Vector3(0.32, 0.42, 0.32)), mat_d, Vector3(0.0, 0.32, 0.0), Vector3(22.0, 0.0, 18.0), Vector3.ONE, false))
		"gem":
			var mat_g: StandardMaterial3D = get_toon_mat(color, 1.15, 0.15)
			spin_pivot.add_child(_make_part(_get_prism(Vector3(0.46, 0.56, 0.46)), mat_g, Vector3(0.0, 0.48, 0.0), Vector3.ZERO, Vector3.ONE, false))
			spin_pivot.add_child(_make_part(_get_prism(Vector3(0.46, 0.56, 0.46)), mat_g, Vector3(0.0, 0.16, 0.0), Vector3(180.0, 0.0, 0.0), Vector3.ONE, false))
			_add_loot_beam(root, color, 4.8)
		"item":
			var r_col: Color = GameEnums.rarity_color(rarity)
			var mat_i: StandardMaterial3D = get_toon_mat(r_col, 0.75 if rarity >= GameEnums.Rarity.RARE else 0.35, 0.3)
			spin_pivot.add_child(_make_part(_get_box(Vector3(0.46, 0.34, 0.34)), mat_i, Vector3(0.0, 0.36, 0.0), Vector3(10.0, 20.0, 0.0), Vector3.ONE, false))
			spin_pivot.add_child(_make_part(_get_box(Vector3(0.50, 0.10, 0.38)), get_toon_mat(Color(1.0, 0.86, 0.35), 0.5), Vector3(0.0, 0.48, 0.0), Vector3(10.0, 20.0, 0.0), Vector3.ONE, false))
			if rarity >= GameEnums.Rarity.MAGIC:
				var beam_h: float = 3.5 + float(rarity) * 2.4
				_add_loot_beam(root, r_col, beam_h)
		"chest":
			var chest_mat: StandardMaterial3D = get_toon_mat(Color(0.68, 0.40, 0.18))
			var gold_mat: StandardMaterial3D = get_toon_mat(Color(1.0, 0.82, 0.24), 0.75)
			spin_pivot.add_child(_make_part(_get_box(Vector3(1.10, 0.72, 0.76)), chest_mat, Vector3(0.0, 0.38, 0.0)))
			spin_pivot.add_child(_make_part(_get_cylinder(0.38, 0.38, 1.12, 10), gold_mat, Vector3(0.0, 0.76, 0.0), Vector3(0.0, 0.0, 90.0)))
			_add_loot_beam(root, Color(1.0, 0.85, 0.25), 7.5)
	return root

static func _add_loot_beam(parent: Node3D, color: Color, height: float) -> void:
	var beam_col: Color = Color(color.r, color.g, color.b, 0.34)
	var mat: StandardMaterial3D = get_toon_mat(beam_col, 1.35, 1.0)
	var beam: MeshInstance3D = _make_part(_get_cylinder(0.08, 0.22, height, 10), mat, Vector3(0.0, height * 0.5, 0.0), Vector3.ZERO, Vector3.ONE, false)
	parent.add_child(beam)
