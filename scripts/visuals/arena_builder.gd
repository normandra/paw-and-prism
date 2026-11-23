class_name ArenaBuilder

const ARENA_HALF_SIZE: float = 68.0

var sun_light: DirectionalLight3D = null
var world_env: WorldEnvironment = null
var sky_mat: ProceduralSkyMaterial = null
var env_res: Environment = null

func build_arena(parent: Node3D) -> void:
	_build_sky_and_lights(parent)
	_build_ground(parent)
	_build_scenic_props(parent)

func _build_sky_and_lights(parent: Node3D) -> void:
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.40, 0.76, 0.98)
	sky_mat.sky_horizon_color = Color(0.84, 0.94, 1.0)
	sky_mat.ground_bottom_color = Color(0.28, 0.52, 0.30)
	sky_mat.ground_horizon_color = Color(0.60, 0.82, 0.56)

	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat

	env_res = Environment.new()
	env_res.background_mode = Environment.BG_SKY
	env_res.sky = sky
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.74, 0.82, 0.78)
	env_res.ambient_light_energy = 0.82
	env_res.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	world_env = WorldEnvironment.new()
	world_env.environment = env_res
	parent.add_child(world_env)

	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-56.0, 28.0, 0.0)
	sun_light.light_color = Color(1.0, 0.96, 0.88)
	sun_light.light_energy = 1.15
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_max_distance = 75.0
	parent.add_child(sun_light)

func _build_ground(parent: Node3D) -> void:
	var tex: ImageTexture = _generate_meadow_texture()
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(24.0, 24.0, 1.0)
	mat.roughness = 0.92
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON

	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(200.0, 200.0)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	ground.material_override = mat
	parent.add_child(ground)

	# Warm stone center circle marking spawn plaza
	var ring_mesh: CylinderMesh = CylinderMesh.new()
	ring_mesh.top_radius = 6.2
	ring_mesh.bottom_radius = 6.6
	ring_mesh.height = 0.04
	ring_mesh.radial_segments = 32
	var ring_mat: StandardMaterial3D = ChibiMeshFactory.get_toon_mat(Color(0.82, 0.76, 0.62, 0.65), 0.0, 0.9)
	var plaza: MeshInstance3D = MeshInstance3D.new()
	plaza.mesh = ring_mesh
	plaza.material_override = ring_mat
	plaza.position = Vector3(0.0, 0.02, 0.0)
	parent.add_child(plaza)

func _generate_meadow_texture() -> ImageTexture:
	var img: Image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42077
	for y in range(128):
		for x in range(128):
			var base: Color = Color(0.38, 0.69, 0.34)
			var n: float = sin(float(x) * 0.14) * cos(float(y) * 0.14) * 0.035 + rng.randf_range(-0.025, 0.025)
			var col: Color = Color(
				clampf(base.r + n, 0.25, 0.55),
				clampf(base.g + n * 1.1, 0.52, 0.84),
				clampf(base.b + n * 0.8, 0.22, 0.48),
				1.0
			)
			if rng.randf() < 0.025:
				col = col.lightened(0.14)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)

func _build_scenic_props(parent: Node3D) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9001

	# 1. Outer Ring of Chibi Pine Trees (visual arena fence)
	var trunk_mm: MultiMesh = MultiMesh.new()
	trunk_mm.transform_format = MultiMesh.TRANSFORM_3D
	trunk_mm.mesh = ChibiMeshFactory._get_cylinder(0.45, 0.58, 2.2, 8)

	var canopy_mm: MultiMesh = MultiMesh.new()
	canopy_mm.transform_format = MultiMesh.TRANSFORM_3D
	canopy_mm.mesh = ChibiMeshFactory._get_cylinder(0.15, 2.2, 3.8, 10)

	var tree_positions: Array[Vector3] = []
	for i in range(110):
		var angle: float = (float(i) / 110.0) * TAU + rng.randf_range(-0.02, 0.02)
		var dist: float = rng.randf_range(70.5, 86.0)
		var tx: float = clampf(cos(angle) * dist, -84.0, 84.0)
		var tz: float = clampf(sin(angle) * dist, -84.0, 84.0)
		# Push outside playable square
		if absf(tx) < 70.0 and absf(tz) < 70.0:
			if absf(tx) > absf(tz):
				tx = signf(tx) * rng.randf_range(71.0, 82.0)
			else:
				tz = signf(tz) * rng.randf_range(71.0, 82.0)
		tree_positions.append(Vector3(tx, 0.0, tz))

	trunk_mm.instance_count = tree_positions.size()
	canopy_mm.instance_count = tree_positions.size()
	for idx in range(tree_positions.size()):
		var p: Vector3 = tree_positions[idx]
		var s: float = rng.randf_range(0.85, 1.35)
		trunk_mm.set_instance_transform(idx, Transform3D(Basis().scaled(Vector3(s, s, s)), p + Vector3(0.0, 1.1 * s, 0.0)))
		canopy_mm.set_instance_transform(idx, Transform3D(Basis().scaled(Vector3(s, s, s)), p + Vector3(0.0, 3.2 * s, 0.0)))

	var trunks_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	trunks_node.multimesh = trunk_mm
	trunks_node.material_override = ChibiMeshFactory.get_toon_mat(Color(0.46, 0.30, 0.18))
	parent.add_child(trunks_node)

	var canopy_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	canopy_node.multimesh = canopy_mm
	canopy_node.material_override = ChibiMeshFactory.get_toon_mat(Color(0.24, 0.56, 0.28))
	parent.add_child(canopy_node)

	# 2. Meadow boundary glowing lantern stones around +-68
	var stone_mm: MultiMesh = MultiMesh.new()
	stone_mm.transform_format = MultiMesh.TRANSFORM_3D
	stone_mm.mesh = ChibiMeshFactory._get_cylinder(0.42, 0.58, 1.1, 8)
	var stone_pts: Array[Vector3] = []
	for step in range(-64, 68, 16):
		stone_pts.append(Vector3(float(step), 0.55, -ARENA_HALF_SIZE))
		stone_pts.append(Vector3(float(step), 0.55, ARENA_HALF_SIZE))
		stone_pts.append(Vector3(-ARENA_HALF_SIZE, 0.55, float(step)))
		stone_pts.append(Vector3(ARENA_HALF_SIZE, 0.55, float(step)))
	stone_mm.instance_count = stone_pts.size()
	for i in range(stone_pts.size()):
		stone_mm.set_instance_transform(i, Transform3D(Basis(), stone_pts[i]))
	var stones_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	stones_node.multimesh = stone_mm
	stones_node.material_override = ChibiMeshFactory.get_toon_mat(Color(0.74, 0.84, 0.92), 0.35)
	parent.add_child(stones_node)

	# 3. Scattered cute wildflowers across meadow (non-colliding)
	var flower_mm: MultiMesh = MultiMesh.new()
	flower_mm.transform_format = MultiMesh.TRANSFORM_3D
	flower_mm.mesh = ChibiMeshFactory._get_sphere(0.22)
	flower_mm.instance_count = 160
	for i in range(160):
		var fp: Vector3 = Vector3(rng.randf_range(-64.0, 64.0), 0.14, rng.randf_range(-64.0, 64.0))
		flower_mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(1.1, 0.5, 1.1)), fp))
	var flowers_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	flowers_node.multimesh = flower_mm
	flowers_node.material_override = ChibiMeshFactory.get_toon_mat(Color(1.0, 0.88, 0.42), 0.15)
	parent.add_child(flowers_node)

func update_biome_lighting(elapsed_sec: float, delta: float) -> void:
	if sun_light == null or sky_mat == null or env_res == null:
		return
	var target_light: Color
	var target_amb: Color
	var target_sky_top: Color
	var target_sky_hor: Color
	var target_energy: float
	var target_pitch: float

	if elapsed_sec < 390.0:
		# Morning Sunny Meadow
		target_light = Color(1.0, 0.96, 0.88)
		target_amb = Color(0.74, 0.82, 0.78)
		target_sky_top = Color(0.40, 0.76, 0.98)
		target_sky_hor = Color(0.84, 0.94, 1.0)
		target_energy = 1.15
		target_pitch = -56.0
	elif elapsed_sec < 780.0:
		# Golden Sunset Glade
		var t: float = clampf((elapsed_sec - 390.0) / 160.0, 0.0, 1.0)
		target_light = Color(1.0, 0.96, 0.88).lerp(Color(1.0, 0.68, 0.42), t)
		target_amb = Color(0.74, 0.82, 0.78).lerp(Color(0.72, 0.58, 0.64), t)
		target_sky_top = Color(0.40, 0.76, 0.98).lerp(Color(0.48, 0.34, 0.62), t)
		target_sky_hor = Color(0.84, 0.94, 1.0).lerp(Color(1.0, 0.66, 0.46), t)
		target_energy = lerpf(1.15, 1.05, t)
		target_pitch = lerpf(-56.0, -40.0, t)
	else:
		# Starlit Twilight Grove
		var t2: float = clampf((elapsed_sec - 780.0) / 180.0, 0.0, 1.0)
		target_light = Color(1.0, 0.68, 0.42).lerp(Color(0.68, 0.78, 1.0), t2)
		target_amb = Color(0.72, 0.58, 0.64).lerp(Color(0.46, 0.50, 0.74), t2)
		target_sky_top = Color(0.48, 0.34, 0.62).lerp(Color(0.14, 0.16, 0.34), t2)
		target_sky_hor = Color(1.0, 0.66, 0.46).lerp(Color(0.42, 0.36, 0.66), t2)
		target_energy = lerpf(1.05, 0.95, t2)
		target_pitch = lerpf(-40.0, -48.0, t2)

	var step: float = minf(1.0, delta * 2.0)
	sun_light.light_color = sun_light.light_color.lerp(target_light, step)
	sun_light.light_energy = lerpf(sun_light.light_energy, target_energy, step)
	sun_light.rotation_degrees.x = lerpf(sun_light.rotation_degrees.x, target_pitch, step)
	env_res.ambient_light_color = env_res.ambient_light_color.lerp(target_amb, step)
	sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(target_sky_top, step)
	sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(target_sky_hor, step)
