class_name ArenaBuilder

const ARENA_HALF_SIZE: float = 68.0

var sun_light: DirectionalLight3D = null
var world_env: WorldEnvironment = null
var sky_mat: ProceduralSkyMaterial = null
var env_res: Environment = null

var _biome_timer: float = 0.0
var _last_sky_top: Color = Color(0.36, 0.68, 0.92)
var _last_sky_hor: Color = Color(0.76, 0.89, 0.96)

func build_arena(parent: Node3D) -> void:
	_build_sky_and_lights(parent)
	_build_ground(parent)
	_build_scenic_props(parent)

func _build_sky_and_lights(parent: Node3D) -> void:
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = _last_sky_top
	sky_mat.sky_horizon_color = _last_sky_hor
	sky_mat.ground_bottom_color = Color(0.20, 0.38, 0.20)
	sky_mat.ground_horizon_color = Color(0.46, 0.66, 0.42)

	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat
	sky.radiance_size = Sky.RADIANCE_SIZE_32

	env_res = Environment.new()
	env_res.background_mode = Environment.BG_SKY
	env_res.sky = sky
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.46, 0.56, 0.62)
	env_res.ambient_light_energy = 0.34
	env_res.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env_res.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_res.tonemap_exposure = 0.90
	env_res.fog_enabled = true
	env_res.fog_light_color = Color(0.74, 0.88, 0.94)
	env_res.fog_density = 0.0055

	world_env = WorldEnvironment.new()
	world_env.environment = env_res
	parent.add_child(world_env)

	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-52.0, 26.0, 0.0)
	sun_light.light_color = Color(1.0, 0.93, 0.82)
	sun_light.light_energy = 0.72
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun_light.directional_shadow_max_distance = 32.0
	sun_light.shadow_bias = 0.08
	parent.add_child(sun_light)

func _build_ground(parent: Node3D) -> void:
	var tex: ImageTexture = _generate_meadow_texture()
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(24.0, 24.0, 1.0)
	mat.roughness = 0.96
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED

	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(200.0, 200.0)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	ground.material_override = mat
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(ground)

	# Rich weathered cobblestone center plaza (mid-dark figure-ground contrast!)
	var plaza_tex: ImageTexture = _generate_plaza_texture()
	var plaza_mat: StandardMaterial3D = StandardMaterial3D.new()
	plaza_mat.albedo_texture = plaza_tex
	plaza_mat.roughness = 0.96
	plaza_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	plaza_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	plaza_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var plaza_plane: PlaneMesh = PlaneMesh.new()
	plaza_plane.size = Vector2(14.0, 14.0)
	var plaza: MeshInstance3D = MeshInstance3D.new()
	plaza.mesh = plaza_plane
	plaza.material_override = plaza_mat
	plaza.position = Vector3(0.0, 0.025, 0.0)
	plaza.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(plaza)

func _generate_meadow_texture() -> ImageTexture:
	var img: Image = Image.create_empty(128, 128, false, Image.FORMAT_RGBA8)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42077
	for y in range(128):
		for x in range(128):
			var base: Color = Color(0.24, 0.47, 0.22)
			var n: float = sin(float(x) * 0.14) * cos(float(y) * 0.14) * 0.028 + rng.randf_range(-0.020, 0.020)
			var col: Color = Color(
				clampf(base.r + n, 0.15, 0.36),
				clampf(base.g + n * 1.15, 0.34, 0.58),
				clampf(base.b + n * 0.8, 0.14, 0.32),
				1.0
			)
			if rng.randf() < 0.028:
				col = col.lightened(0.12)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)

func _generate_plaza_texture() -> ImageTexture:
	var sz: int = 192
	var img: Image = Image.create_empty(sz, sz, false, Image.FORMAT_RGBA8)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77112
	var half: float = float(sz) * 0.5
	for y in range(sz):
		for x in range(sz):
			var dx: float = (float(x) - half) / half
			var dy: float = (float(y) - half) / half
			var r: float = sqrt(dx * dx + dy * dy)
			if r > 0.98:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var ang: float = atan2(dy, dx) + PI
			var ring_idx: int = int(floor(r * 6.0))
			var seg_count: float = maxf(6.0, float(ring_idx + 1) * 7.0)
			var ring_f: float = fract_f(r * 6.0)
			var seg_f: float = fract_f((ang / TAU) * seg_count + float(ring_idx) * 0.37)

			var is_mortar: bool = ring_f < 0.08 or ring_f > 0.92 or seg_f < 0.06 or seg_f > 0.94
			var tile_hash: float = sin(float(ring_idx * 31 + int(floor((ang / TAU) * seg_count)) * 17)) * 0.04
			var col: Color
			if is_mortar:
				col = Color(0.24, 0.25, 0.19, 1.0)
			elif r > 0.86:
				col = Color(0.38, 0.33, 0.26, 1.0)
			else:
				col = Color(
					clampf(0.45 + tile_hash + rng.randf_range(-0.015, 0.015), 0.34, 0.54),
					clampf(0.40 + tile_hash + rng.randf_range(-0.015, 0.015), 0.30, 0.48),
					clampf(0.32 + tile_hash + rng.randf_range(-0.015, 0.015), 0.24, 0.40),
					1.0
				)
			col.a = clampf((0.98 - r) / 0.06, 0.0, 1.0)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)

func fract_f(v: float) -> float:
	return v - floor(v)

func _build_scenic_props(parent: Node3D) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9001

	# 1. Outer Ring of Tiered Chibi Pine Trees (2 stacked cones + varied pine colors)
	var trunk_mm: MultiMesh = MultiMesh.new()
	trunk_mm.transform_format = MultiMesh.TRANSFORM_3D
	trunk_mm.mesh = ChibiMeshFactory._get_cylinder(0.42, 0.56, 2.2, 8)

	var canopy_mm: MultiMesh = MultiMesh.new()
	canopy_mm.transform_format = MultiMesh.TRANSFORM_3D
	canopy_mm.use_colors = true
	canopy_mm.mesh = ChibiMeshFactory._get_cylinder(0.12, 2.25, 3.2, 8)

	var tree_shadow_mm: MultiMesh = MultiMesh.new()
	tree_shadow_mm.transform_format = MultiMesh.TRANSFORM_3D
	tree_shadow_mm.mesh = ChibiMeshFactory._get_cylinder(2.1, 2.1, 0.02, 10)

	var tree_positions: Array[Vector3] = []
	for i in range(96):
		var angle: float = (float(i) / 96.0) * TAU + rng.randf_range(-0.02, 0.02)
		var dist: float = rng.randf_range(70.5, 86.0)
		var tx: float = clampf(cos(angle) * dist, -84.0, 84.0)
		var tz: float = clampf(sin(angle) * dist, -84.0, 84.0)
		if absf(tx) < 70.0 and absf(tz) < 70.0:
			if absf(tx) > absf(tz):
				tx = signf(tx) * rng.randf_range(71.0, 82.0)
			else:
				tz = signf(tz) * rng.randf_range(71.0, 82.0)
		tree_positions.append(Vector3(tx, 0.0, tz))

	trunk_mm.instance_count = tree_positions.size()
	canopy_mm.instance_count = tree_positions.size() * 2
	tree_shadow_mm.instance_count = tree_positions.size()
	var pine_greens: Array[Color] = [
		Color(0.18, 0.44, 0.22),
		Color(0.22, 0.50, 0.26),
		Color(0.16, 0.39, 0.24),
		Color(0.25, 0.48, 0.22),
	]
	for idx in range(tree_positions.size()):
		var p: Vector3 = tree_positions[idx]
		var s: float = rng.randf_range(0.85, 1.35)
		var gcol: Color = pine_greens[idx % pine_greens.size()]
		trunk_mm.set_instance_transform(idx, Transform3D(Basis().scaled(Vector3(s, s, s)), p + Vector3(0.0, 1.1 * s, 0.0)))
		canopy_mm.set_instance_transform(idx * 2, Transform3D(Basis().scaled(Vector3(s, s, s)), p + Vector3(0.0, 2.9 * s, 0.0)))
		canopy_mm.set_instance_color(idx * 2, gcol)
		canopy_mm.set_instance_transform(idx * 2 + 1, Transform3D(Basis().scaled(Vector3(s * 0.72, s * 0.76, s * 0.72)), p + Vector3(0.0, 4.7 * s, 0.0)))
		canopy_mm.set_instance_color(idx * 2 + 1, gcol.lightened(0.10))
		tree_shadow_mm.set_instance_transform(idx, Transform3D(Basis().scaled(Vector3(s, 1.0, s)), p + Vector3(0.0, 0.02, 0.0)))

	var trunks_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	trunks_node.multimesh = trunk_mm
	trunks_node.material_override = ChibiMeshFactory.get_toon_mat(Color(0.42, 0.26, 0.15))
	trunks_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(trunks_node)

	var canopy_mat: StandardMaterial3D = ChibiMeshFactory.get_toon_mat(Color(1.0, 1.0, 1.0)).duplicate()
	canopy_mat.vertex_color_use_as_albedo = true
	var canopy_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	canopy_node.multimesh = canopy_mm
	canopy_node.material_override = canopy_mat
	canopy_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(canopy_node)

	var tshad_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	tshad_node.multimesh = tree_shadow_mm
	tshad_node.material_override = ChibiMeshFactory.get_unshaded_mat(Color(0.04, 0.07, 0.05, 0.34), true)
	tshad_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(tshad_node)

	# 2. Midground Woodland Shrubs (soft scenic depth outside center plaza)
	var shrub_mm: MultiMesh = MultiMesh.new()
	shrub_mm.transform_format = MultiMesh.TRANSFORM_3D
	shrub_mm.use_colors = true
	shrub_mm.mesh = ChibiMeshFactory._get_sphere(0.85, 10, 6)
	shrub_mm.instance_count = 36
	for i in range(36):
		var sa: float = rng.randf() * TAU
		var sd: float = rng.randf_range(16.0, 62.0)
		var sx: float = cos(sa) * sd
		var sz: float = sin(sa) * sd
		var sc: float = rng.randf_range(0.7, 1.3)
		shrub_mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(sc * 1.2, sc * 0.65, sc * 1.1)), Vector3(sx, 0.35 * sc, sz)))
		shrub_mm.set_instance_color(i, pine_greens[i % pine_greens.size()].lightened(0.08))
	var shrub_mat: StandardMaterial3D = ChibiMeshFactory.get_toon_mat(Color(1.0, 1.0, 1.0)).duplicate()
	shrub_mat.vertex_color_use_as_albedo = true
	var shrubs_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	shrubs_node.multimesh = shrub_mm
	shrubs_node.material_override = shrub_mat
	shrubs_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shrubs_node)

	# 3. Warm Mossy Stone Boundary Pillars + Tiny Amber Lantern Orbs
	var stone_mm: MultiMesh = MultiMesh.new()
	stone_mm.transform_format = MultiMesh.TRANSFORM_3D
	stone_mm.mesh = ChibiMeshFactory._get_cylinder(0.40, 0.56, 1.15, 8)
	var orb_mm: MultiMesh = MultiMesh.new()
	orb_mm.transform_format = MultiMesh.TRANSFORM_3D
	orb_mm.mesh = ChibiMeshFactory._get_sphere(0.24, 8, 5)
	var stone_pts: Array[Vector3] = []
	for step in range(-64, 68, 16):
		stone_pts.append(Vector3(float(step), 0.55, -ARENA_HALF_SIZE))
		stone_pts.append(Vector3(float(step), 0.55, ARENA_HALF_SIZE))
		stone_pts.append(Vector3(-ARENA_HALF_SIZE, 0.55, float(step)))
		stone_pts.append(Vector3(ARENA_HALF_SIZE, 0.55, float(step)))
	stone_mm.instance_count = stone_pts.size()
	orb_mm.instance_count = stone_pts.size()
	for i in range(stone_pts.size()):
		stone_mm.set_instance_transform(i, Transform3D(Basis(), stone_pts[i]))
		orb_mm.set_instance_transform(i, Transform3D(Basis(), stone_pts[i] + Vector3(0.0, 0.72, 0.0)))
	var stones_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	stones_node.multimesh = stone_mm
	stones_node.material_override = ChibiMeshFactory.get_toon_mat(Color(0.46, 0.44, 0.40))
	stones_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(stones_node)

	var orbs_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	orbs_node.multimesh = orb_mm
	orbs_node.material_override = ChibiMeshFactory.get_toon_mat(Color(1.0, 0.78, 0.34), 0.55)
	orbs_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(orbs_node)

	# 4. Multi-color Wildflowers (excluded from center cobblestone plaza!)
	var flower_mm: MultiMesh = MultiMesh.new()
	flower_mm.transform_format = MultiMesh.TRANSFORM_3D
	flower_mm.use_colors = true
	flower_mm.mesh = ChibiMeshFactory._get_sphere(0.18, 8, 5)
	flower_mm.instance_count = 140
	var flower_cols: Array[Color] = [
		Color(0.98, 0.96, 0.88),
		Color(1.0, 0.76, 0.84),
		Color(0.84, 0.76, 1.0),
		Color(1.0, 0.86, 0.42),
	]
	for i in range(140):
		var fp: Vector3 = Vector3(rng.randf_range(-64.0, 64.0), 0.10, rng.randf_range(-64.0, 64.0))
		while Vector2(fp.x, fp.z).length() < 8.0:
			fp = Vector3(rng.randf_range(-64.0, 64.0), 0.10, rng.randf_range(-64.0, 64.0))
		flower_mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(1.0, 0.5, 1.0)), fp))
		flower_mm.set_instance_color(i, flower_cols[i % flower_cols.size()])
	var f_mat: StandardMaterial3D = ChibiMeshFactory.get_toon_mat(Color(1.0, 1.0, 1.0)).duplicate()
	f_mat.vertex_color_use_as_albedo = true
	var flowers_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	flowers_node.multimesh = flower_mm
	flowers_node.material_override = f_mat
	flowers_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flowers_node)

func update_biome_lighting(elapsed_sec: float, delta: float) -> void:
	if sun_light == null or sky_mat == null or env_res == null:
		return
	_biome_timer += delta
	if _biome_timer < 2.5 and elapsed_sec > 1.0:
		return
	_biome_timer = 0.0

	var target_light: Color
	var target_amb: Color
	var target_sky_top: Color
	var target_sky_hor: Color
	var target_fog: Color
	var target_energy: float
	var target_amb_energy: float
	var target_pitch: float

	if elapsed_sec < 390.0:
		target_light = Color(1.0, 0.93, 0.82)
		target_amb = Color(0.46, 0.56, 0.62)
		target_sky_top = Color(0.36, 0.68, 0.92)
		target_sky_hor = Color(0.76, 0.89, 0.96)
		target_fog = Color(0.74, 0.88, 0.94)
		target_energy = 0.72
		target_amb_energy = 0.34
		target_pitch = -52.0
	elif elapsed_sec < 780.0:
		var t: float = clampf((elapsed_sec - 390.0) / 160.0, 0.0, 1.0)
		target_light = Color(1.0, 0.93, 0.82).lerp(Color(1.0, 0.64, 0.38), t)
		target_amb = Color(0.46, 0.56, 0.62).lerp(Color(0.56, 0.42, 0.50), t)
		target_sky_top = Color(0.36, 0.68, 0.92).lerp(Color(0.44, 0.30, 0.58), t)
		target_sky_hor = Color(0.76, 0.89, 0.96).lerp(Color(0.96, 0.62, 0.42), t)
		target_fog = Color(0.74, 0.88, 0.94).lerp(Color(0.88, 0.62, 0.48), t)
		target_energy = lerpf(0.72, 0.68, t)
		target_amb_energy = lerpf(0.34, 0.32, t)
		target_pitch = lerpf(-52.0, -38.0, t)
	else:
		var t2: float = clampf((elapsed_sec - 780.0) / 180.0, 0.0, 1.0)
		target_light = Color(1.0, 0.64, 0.38).lerp(Color(0.64, 0.74, 0.98), t2)
		target_amb = Color(0.56, 0.42, 0.50).lerp(Color(0.34, 0.38, 0.60), t2)
		target_sky_top = Color(0.44, 0.30, 0.58).lerp(Color(0.12, 0.14, 0.30), t2)
		target_sky_hor = Color(0.96, 0.62, 0.42).lerp(Color(0.36, 0.32, 0.58), t2)
		target_fog = Color(0.88, 0.62, 0.48).lerp(Color(0.24, 0.24, 0.44), t2)
		target_energy = lerpf(0.68, 0.62, t2)
		target_amb_energy = lerpf(0.32, 0.30, t2)
		target_pitch = lerpf(-38.0, -46.0, t2)

	sun_light.light_color = target_light
	sun_light.light_energy = target_energy
	sun_light.rotation_degrees.x = target_pitch
	env_res.ambient_light_color = target_amb
	env_res.ambient_light_energy = target_amb_energy
	env_res.fog_light_color = target_fog

	if _color_diff(sky_mat.sky_top_color, target_sky_top) > 0.015 or _color_diff(sky_mat.sky_horizon_color, target_sky_hor) > 0.015:
		sky_mat.sky_top_color = target_sky_top
		sky_mat.sky_horizon_color = target_sky_hor

func _color_diff(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
