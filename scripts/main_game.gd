class_name MainGame
extends Node

enum GameState {
	TITLE,
	PLAYING,
	INVENTORY,
	LEVEL_UP,
	PAUSED,
	ENDED,
}

var state: int = GameState.TITLE

var world_root: Node3D = null
var camera: Camera3D = null
var arena_builder: ArenaBuilder = null
var spatial_grid: SpatialGrid = null
var stats: HeroStats = null
var player: PlayerController = null
var skill_executor: SkillExecutor = null
var wave_director: WaveDirector = null
var loot_manager: LootManager = null
var sfx: SfxManager = null

var ui_layer: CanvasLayer = null
var title_screen: TitleScreen = null
var hud: HudController = null
var inventory_panel: InventoryPanel = null
var level_up_modal: LevelUpModal = null
var end_screen: EndScreen = null

var _showcase_rig: Node3D = null
var _showcase_time: float = 0.0
var _selected_hero_id: String = "shiba"
var _pending_level_ups: int = 0
var _shake_trauma: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()

	world_root = Node3D.new()
	world_root.name = "WorldRoot"
	world_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world_root)

	camera = Camera3D.new()
	camera.name = "MainCamera"
	camera.fov = 48.0
	camera.far = 160.0
	world_root.add_child(camera)

	arena_builder = ArenaBuilder.new()
	arena_builder.build_arena(world_root)

	spatial_grid = SpatialGrid.new()

	sfx = SfxManager.new()
	sfx.name = "SfxManager"
	add_child(sfx)

	player = PlayerController.new()
	player.name = "Player"
	player.player_hurt.connect(_on_player_hurt)
	player.player_died.connect(_on_player_died)
	player.cheat_death_triggered.connect(func() -> void:
		hud.show_banner("Nine-Lives Bell Saved You!", Color(1.0, 0.85, 0.30))
		sfx.play("loot_unique")
	)
	player.reactive_nova_requested.connect(func(kind: String, pos: Vector3, dmg: float, radius: float) -> void:
		if skill_executor != null:
			skill_executor.trigger_reactive_nova(kind, pos, dmg, radius)
	)
	player.dashed.connect(func() -> void: sfx.play("dash_whoosh"))
	world_root.add_child(player)

	skill_executor = SkillExecutor.new()
	skill_executor.name = "SkillExecutor"
	skill_executor.damage_dealt.connect(_on_damage_dealt)
	skill_executor.skill_casted.connect(func(_sid: String) -> void: sfx.play("hit_pop", 0.14, 90))
	world_root.add_child(skill_executor)

	loot_manager = LootManager.new()
	loot_manager.name = "LootManager"
	loot_manager.xp_collected.connect(_on_xp_collected)
	loot_manager.heart_collected.connect(func(amt: float) -> void:
		player.heal(amt)
		hud.spawn_damage_popup(player.global_position, amt, false, false, false, true)
		sfx.play("loot_common")
	)
	loot_manager.dust_collected.connect(func(amt: int) -> void:
		hud.push_toast("+%d Prism Dust" % amt, Color(0.55, 0.92, 1.0))
		sfx.play("xp_plink")
	)
	loot_manager.item_looted.connect(_on_item_looted)
	loot_manager.gem_looted.connect(_on_gem_looted)
	loot_manager.loot_bag_full.connect(func(msg: String) -> void: hud.push_toast(msg, Color(1.0, 0.55, 0.40)))
	loot_manager.chest_opened.connect(func() -> void:
		hud.show_banner("Acorn Treasure Chest Opened!", Color(1.0, 0.88, 0.30))
		sfx.play("loot_rare")
	)
	world_root.add_child(loot_manager)

	wave_director = WaveDirector.new()
	wave_director.name = "WaveDirector"
	wave_director.boss_spawned.connect(func(b: EnemyEntity) -> void:
		sfx.play("boss_horn")
		_shake_trauma = 0.55
		hud.push_toast("BOSS APPROACHES: %s!" % b.enemy_name, Color(1.0, 0.36, 0.32))
	)
	wave_director.boss_defeated.connect(func(b_idx: int, b_name: String) -> void:
		sfx.play("loot_unique")
		_shake_trauma = 0.65
		if b_idx < 3:
			hud.show_banner("BOSS %d/3 DEFEATED: %s!" % [b_idx, b_name], Color(1.0, 0.85, 0.30))
	)
	wave_director.wave_banner.connect(func(t: String, c: Color) -> void: hud.show_banner(t, c))
	wave_director.all_bosses_cleared.connect(_on_victory)
	world_root.add_child(wave_director)

	_build_ui()
	_enter_title_state()

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	title_screen = TitleScreen.new()
	title_screen.hero_selected.connect(_on_title_hero_selected)
	title_screen.start_requested.connect(start_new_run)
	ui_layer.add_child(title_screen)

	hud = HudController.new()
	hud.visible = false
	hud.open_inventory_requested.connect(_open_inventory)
	hud.toggle_pause_requested.connect(_toggle_pause)
	hud.toggle_mute_requested.connect(_toggle_mute)
	ui_layer.add_child(hud)

	inventory_panel = InventoryPanel.new()
	inventory_panel.closed.connect(_close_inventory)
	inventory_panel.gear_changed.connect(_on_gear_or_gems_changed)
	inventory_panel.sfx_requested.connect(func(sname: String) -> void: sfx.play(sname))
	ui_layer.add_child(inventory_panel)

	level_up_modal = LevelUpModal.new()
	level_up_modal.option_chosen.connect(_on_level_up_chosen)
	ui_layer.add_child(level_up_modal)

	end_screen = EndScreen.new()
	end_screen.resume_requested.connect(_resume_from_pause)
	end_screen.play_again_requested.connect(func() -> void: start_new_run(_selected_hero_id))
	end_screen.title_menu_requested.connect(_enter_title_state)
	ui_layer.add_child(end_screen)

func _enter_title_state() -> void:
	state = GameState.TITLE
	get_tree().paused = false
	if wave_director != null:
		wave_director.reset()
	if skill_executor != null:
		skill_executor.clear_all()
	if loot_manager != null:
		loot_manager.clear_all()
	player.visible = false
	title_screen.visible = true
	hud.visible = false
	inventory_panel.visible = false
	level_up_modal.visible = false
	end_screen.visible = false
	arena_builder.update_biome_lighting(0.0, 10.0)
	_on_title_hero_selected(_selected_hero_id)

func _on_title_hero_selected(hero_id: String) -> void:
	_selected_hero_id = hero_id
	if _showcase_rig != null:
		_showcase_rig.queue_free()
	_showcase_rig = ChibiMeshFactory.build_hero_rig(hero_id)
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	ChibiMeshFactory.update_hero_visual_gear(_showcase_rig, String(hdef["starter_weapon_style"]), String(hdef["starter_helmet_style"]))
	_showcase_rig.position = Vector3(0.0, 0.0, 0.0)
	_showcase_rig.scale = Vector3(1.35, 1.35, 1.35)
	world_root.add_child(_showcase_rig)
	sfx.play("ui_click")

func start_new_run(hero_id: String) -> void:
	_selected_hero_id = hero_id
	if _showcase_rig != null:
		_showcase_rig.queue_free()
		_showcase_rig = null

	get_tree().paused = false
	state = GameState.PLAYING
	_pending_level_ups = 0
	_shake_trauma = 0.0

	stats = HeroStats.new(hero_id)
	player.visible = true
	player.global_position = Vector3.ZERO
	player.setup(stats)

	skill_executor.setup(world_root, spatial_grid, stats)
	loot_manager.setup(world_root, stats)
	wave_director.setup(
		world_root,
		func(e: EnemyEntity) -> void: loot_manager.drop_for_enemy(e, wave_director.elapsed_time),
		func(pos: Vector3, dir: Vector3, spd: float, dmg: float, r: float, col: Color) -> void:
			skill_executor.spawn_enemy_projectile(pos, dir, spd, dmg, r, col, player),
		func(pos: Vector3, r: float, windup: float, dmg: float, col: Color, _is_ring: bool) -> void:
			skill_executor.spawn_enemy_telegraph(pos, r, windup, dmg, col, player)
	)
	spatial_grid.rebuild([])

	title_screen.visible = false
	inventory_panel.visible = false
	level_up_modal.visible = false
	end_screen.visible = false
	hud.visible = true
	hud.reset_hud()
	hud.rebuild_skill_bar(stats)
	hud.show_banner("Survive 20 Minutes & Defeat All 3 Bosses!", Color(1.0, 0.90, 0.42))
	sfx.play("level_up")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.keycode
		if kc == KEY_M:
			_toggle_mute()
			get_viewport().set_input_as_handled()
			return
		if kc == KEY_TAB or kc == KEY_I:
			if state == GameState.PLAYING:
				_open_inventory()
				get_viewport().set_input_as_handled()
			elif state == GameState.INVENTORY:
				_close_inventory()
				get_viewport().set_input_as_handled()
		elif kc == KEY_ESCAPE:
			if state == GameState.INVENTORY:
				_close_inventory()
				get_viewport().set_input_as_handled()
			elif state == GameState.PLAYING or state == GameState.PAUSED:
				_toggle_pause()
				get_viewport().set_input_as_handled()

func _toggle_mute() -> void:
	var is_m: bool = sfx.toggle_mute()
	hud.set_muted_state(is_m)

func _open_inventory() -> void:
	if state != GameState.PLAYING:
		return
	state = GameState.INVENTORY
	get_tree().paused = true
	hud.mark_loot_read()
	inventory_panel.open_panel(stats)
	sfx.play("ui_click")

func _close_inventory() -> void:
	if state != GameState.INVENTORY:
		return
	inventory_panel.visible = false
	state = GameState.PLAYING
	get_tree().paused = false
	sfx.play("ui_click")

func _toggle_pause() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		get_tree().paused = true
		end_screen.show_pause(stats, wave_director)
		sfx.play("ui_click")
	elif state == GameState.PAUSED:
		_resume_from_pause()

func _resume_from_pause() -> void:
	if state != GameState.PAUSED:
		return
	end_screen.visible = false
	state = GameState.PLAYING
	get_tree().paused = false
	sfx.play("ui_click")

func _on_gear_or_gems_changed() -> void:
	if player != null:
		player.refresh_equipment_visuals()
	if hud != null and stats != null:
		hud.rebuild_skill_bar(stats)

func _process(delta: float) -> void:
	if state == GameState.TITLE:
		_showcase_time += delta
		if _showcase_rig != null:
			_showcase_rig.rotation.y += delta * 0.7
			_showcase_rig.position.y = absf(sin(_showcase_time * 3.0)) * 0.14
		if camera != null:
			camera.look_at_from_position(Vector3(0.0, 2.35, 4.9), Vector3(0.0, 1.05, 0.0), Vector3.UP)
		return

	if state != GameState.PLAYING or get_tree().paused:
		return

	# Step simulation
	player.step(delta)
	wave_director.step(delta, player.global_position, spatial_grid, loot_manager)
	skill_executor.step(delta, player.global_position, player)
	loot_manager.step(delta, player.global_position, wave_director.elapsed_time)

	# Enemy contact damage check via SpatialGrid
	var touching: Array = spatial_grid.query_radius(player.global_position, 0.55)
	if not touching.is_empty():
		var e: EnemyEntity = touching[0]
		player.take_damage(e.contact_damage)

	# Lighting & Camera follow
	arena_builder.update_biome_lighting(wave_director.elapsed_time, delta)
	_update_camera(delta)
	hud.update_hud(delta, stats, player, wave_director, skill_executor, loot_manager, camera)

func _update_camera(delta: float) -> void:
	if camera == null or player == null:
		return
	var shake_off: Vector3 = Vector3.ZERO
	if _shake_trauma > 0.0:
		_shake_trauma = maxf(0.0, _shake_trauma - delta * 2.2)
		var mag: float = _shake_trauma * _shake_trauma * 0.55
		shake_off = Vector3(randf_range(-mag, mag), randf_range(-mag, mag), 0.0)
	var target_cam_pos: Vector3 = player.global_position + Vector3(0.0, 17.5, 13.5) + shake_off
	camera.global_position = camera.global_position.lerp(target_cam_pos, minf(1.0, delta * 9.0))
	camera.look_at(player.global_position + Vector3(0.0, 0.65, 0.0), Vector3.UP)

func _on_damage_dealt(pos: Vector3, amount: float, is_crit: bool, is_fire: bool, is_cold: bool, heal_amt: float) -> void:
	if heal_amt > 0.01 and player != null:
		player.heal(heal_amt)
	if hud != null:
		hud.spawn_damage_popup(pos, amount, is_crit, is_fire, is_cold, false)
	if is_crit:
		sfx.play("crit_sparkle", 0.10, 80)

func _on_player_hurt(dmg: float, _hp_after: float) -> void:
	_shake_trauma = maxf(_shake_trauma, 0.35)
	sfx.play("player_hurt", 0.08, 120)
	if hud != null:
		hud.spawn_damage_popup(player.global_position, dmg, false, false, false, false)

func _on_xp_collected(amount: float) -> void:
	sfx.play("xp_plink", 0.14, 55)
	var old_skill_count: int = stats.active_skill_configs.size()
	var gained: int = stats.add_hero_xp(amount)
	if gained > 0:
		_pending_level_ups += gained
		hud.rebuild_skill_bar(stats)
		_try_show_next_level_up()
	elif stats.active_skill_configs.size() == old_skill_count:
		hud.rebuild_skill_bar(stats)

func _try_show_next_level_up() -> void:
	if _pending_level_ups <= 0 or state != GameState.PLAYING:
		return
	_pending_level_ups -= 1
	state = GameState.LEVEL_UP
	get_tree().paused = true
	sfx.play("level_up")
	level_up_modal.open_for_level(stats.hero_level, stats)

func _on_level_up_chosen(opt: Dictionary) -> void:
	var kind: String = String(opt.get("kind", "stat"))
	match kind:
		"stat":
			var st: int = int(opt["stat"])
			var val: float = float(opt["val"])
			stats.add_level_bonus(st, val)
			if st == GameEnums.StatType.MAX_HP:
				player.heal(val)
		"gem_xp":
			stats.grant_xp_to_equipped_gems(float(opt["val"]))
			hud.push_toast("All Equipped Gems +140 XP!", Color(0.75, 0.65, 1.0))
		"dust_pack":
			stats.prism_dust += int(opt["val"])
			hud.push_toast("+%d Prism Dust!" % int(opt["val"]), Color(0.45, 0.94, 1.0))
		"free_gem":
			var g: GemInstance = GemInstance.new(GemDatabase.roll_random_gem_id(_rng), 1)
			if stats.can_add_gem_to_pouch():
				stats.gem_pouch.append(g)
				_on_gem_looted(g)

	hud.rebuild_skill_bar(stats)
	sfx.play("socket_chime")

	if _pending_level_ups > 0:
		state = GameState.PLAYING
		_try_show_next_level_up()
	else:
		state = GameState.PLAYING
		get_tree().paused = false

func _on_item_looted(item: ItemInstance) -> void:
	hud.add_unread_loot()
	var col: Color = GameEnums.rarity_color(item.rarity)
	hud.push_toast("[%s] %s (%s)" % [GameEnums.rarity_label(item.rarity), item.item_name, item.get_socket_summary_text()], col)
	if item.rarity >= GameEnums.Rarity.UNIQUE:
		sfx.play("loot_unique")
		hud.show_banner("UNIQUE DROP: %s!" % item.item_name, col)
	elif item.rarity >= GameEnums.Rarity.RARE:
		sfx.play("loot_rare")
	else:
		sfx.play("loot_common")

func _on_gem_looted(gem: GemInstance) -> void:
	hud.add_unread_loot()
	var col: Color = GameEnums.gem_color_value(gem.get_gem_color())
	hud.push_toast("[%s GEM] %s Lv.%d" % [GameEnums.gem_type_label(gem.get_gem_type()), gem.get_gem_name(), gem.level], col)
	sfx.play("gem_drop")

func _on_player_died() -> void:
	if state == GameState.ENDED:
		return
	state = GameState.ENDED
	get_tree().paused = true
	sfx.play("boss_horn")
	end_screen.show_end(false, stats, wave_director)

func _on_victory() -> void:
	if state == GameState.ENDED:
		return
	state = GameState.ENDED
	get_tree().paused = true
	sfx.play("victory_fanfare")
	end_screen.show_end(true, stats, wave_director)
