class_name MainGame
extends Node

enum GameState {
	TITLE,
	PLAYING,
	INVENTORY,
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
var tutorial_director: TutorialDirector = null
var sfx: SfxManager = null

var ui_layer: CanvasLayer = null
var title_screen: TitleScreen = null
var hud: HudController = null
var inventory_panel: InventoryPanel = null
var end_screen: EndScreen = null

var _showcase_rig: Node3D = null
var _showcase_time: float = 0.0
var _selected_hero_id: String = "shiba"
var _is_tutorial: bool = false
var _shake_trauma: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _review_mode: bool = false
var _is_mobile_touch: bool = false
var _allow_mouse_touch: bool = false
var _last_content_scale: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()

	if DisplayServer.is_touchscreen_available():
		_is_mobile_touch = true

	if OS.has_feature("android") or OS.has_feature("ios"):
		_is_mobile_touch = true
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		get_viewport().scaling_3d_scale = 0.72
	elif OS.has_feature("web"):
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		var has_rev = JavaScriptBridge.eval("window.location.search.includes('review=1')")
		_review_mode = bool(has_rev)
		var has_web_touch = JavaScriptBridge.eval("('ontouchstart' in window) || (navigator.maxTouchPoints > 0) || (window.matchMedia && window.matchMedia('(pointer: coarse)').matches)")
		if bool(has_web_touch):
			_is_mobile_touch = true
		var has_sim_mobile = JavaScriptBridge.eval("window.location.search.includes('mobile=1') || window.location.search.includes('touch=1')")
		if bool(has_sim_mobile):
			_is_mobile_touch = true
			_allow_mouse_touch = true
		if DisplayServer.screen_get_scale() > 1.5:
			get_viewport().scaling_3d_scale = 0.72 if _is_mobile_touch else 0.78
	else:
		if OS.get_cmdline_args().has("--review"):
			_review_mode = true
		if OS.get_cmdline_args().has("--mobile"):
			_is_mobile_touch = true
			_allow_mouse_touch = true

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
	player.static_spark_requested.connect(func(pos: Vector3) -> void:
		if skill_executor != null:
			skill_executor.trigger_static_spark(pos)
	)
	player.stride_honey_requested.connect(func(pos: Vector3) -> void:
		if skill_executor != null:
			skill_executor.trigger_reactive_nova("stride_honey_nova", pos, 24.0, 4.4)
	)
	player.comet_stride_requested.connect(func(pos: Vector3) -> void:
		if skill_executor != null:
			skill_executor.trigger_all_skills_bonus(pos)
	)
	player.orbit_shield_requested.connect(func() -> void:
		if skill_executor != null:
			skill_executor.activate_orbit_shield()
	)
	world_root.add_child(player)

	skill_executor = SkillExecutor.new()
	skill_executor.name = "SkillExecutor"
	skill_executor.damage_dealt.connect(_on_damage_dealt)
	skill_executor.skill_casted.connect(func(_sid: String) -> void: sfx.play("hit_pop", 0.14, 90))
	world_root.add_child(skill_executor)

	loot_manager = LootManager.new()
	loot_manager.name = "LootManager"
	loot_manager.hero_heal_requested.connect(func(amt: float) -> void:
		player.heal(amt)
		hud.spawn_damage_popup(player.global_position, amt, false, false, false, true)
		sfx.play("loot_common")
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
		hud.push_toast("BOSS: %s" % b.enemy_name, Color(1.0, 0.36, 0.32))
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

	tutorial_director = TutorialDirector.new()
	tutorial_director.name = "TutorialDirector"
	tutorial_director.objective_changed.connect(func(_step_i: int, _tot: int, txt: String, hl_bag: bool) -> void:
		if hud != null:
			hud.set_tutorial_objective(true, txt, hl_bag)
	)
	tutorial_director.satchel_hint_changed.connect(func(hint: String) -> void:
		if inventory_panel != null:
			inventory_panel.set_tutorial_hint(hint)
	)
	tutorial_director.banner_requested.connect(func(t: String, c: Color) -> void:
		if hud != null:
			hud.show_banner(t, c)
	)
	tutorial_director.tutorial_completed.connect(_on_tutorial_completed)
	add_child(tutorial_director)

	_build_ui()
	get_viewport().size_changed.connect(_update_responsive_scale)
	_update_responsive_scale()
	_enter_title_state()

func _update_responsive_scale() -> void:
	var win_sz: Vector2i = DisplayServer.window_get_size()
	if win_sz.x <= 10 or win_sz.y <= 10:
		return
	var target_csf: float = 1.0
	var aspect_hw: float = float(win_sz.y) / float(win_sz.x)
	if aspect_hw > 1.50:
		target_csf = 2.75
	elif aspect_hw > 1.05:
		target_csf = 1.95
	elif _is_mobile_touch:
		target_csf = 1.45
	if absf(target_csf - _last_content_scale) > 0.02:
		_last_content_scale = target_csf
		get_tree().root.content_scale_factor = target_csf

func _clear_touch_controls() -> void:
	if hud != null:
		hud.reset_touch_input()
	if player != null:
		player.set_touch_move(Vector2.ZERO)

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	title_screen = TitleScreen.new()
	title_screen.hero_selected.connect(_on_title_hero_selected)
	title_screen.start_requested.connect(start_new_run)
	title_screen.tutorial_requested.connect(start_tutorial)
	ui_layer.add_child(title_screen)
	title_screen.set_mobile_mode(_is_mobile_touch)

	hud = HudController.new()
	hud.visible = false
	hud.open_inventory_requested.connect(_open_inventory)
	hud.toggle_pause_requested.connect(_toggle_pause)
	hud.toggle_mute_requested.connect(_toggle_mute)
	ui_layer.add_child(hud)
	hud.set_mobile_mode(_is_mobile_touch, _allow_mouse_touch)

	inventory_panel = InventoryPanel.new()
	inventory_panel.closed.connect(_close_inventory)
	inventory_panel.gear_changed.connect(_on_gear_or_gems_changed)
	inventory_panel.sfx_requested.connect(func(sname: String) -> void: sfx.play(sname))
	ui_layer.add_child(inventory_panel)

	end_screen = EndScreen.new()
	end_screen.resume_requested.connect(_resume_from_pause)
	end_screen.play_again_requested.connect(func() -> void:
		if _is_tutorial:
			start_tutorial(_selected_hero_id)
		else:
			start_new_run(_selected_hero_id)
	)
	end_screen.tutorial_start_run_requested.connect(func() -> void: start_new_run(_selected_hero_id))
	end_screen.title_menu_requested.connect(_enter_title_state)
	ui_layer.add_child(end_screen)

func _enter_title_state() -> void:
	state = GameState.TITLE
	_is_tutorial = false
	get_tree().paused = false
	_clear_touch_controls()
	if tutorial_director != null:
		tutorial_director.reset()
	if wave_director != null:
		wave_director.reset()
	if skill_executor != null:
		skill_executor.clear_all()
	if loot_manager != null:
		loot_manager.clear_all()
	player.visible = false
	title_screen.visible = true
	hud.visible = false
	hud.set_tutorial_objective(false)
	inventory_panel.visible = false
	inventory_panel.set_tutorial_hint("")
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
	_is_tutorial = false
	if _showcase_rig != null:
		_showcase_rig.queue_free()
		_showcase_rig = null

	get_tree().paused = false
	state = GameState.PLAYING
	_shake_trauma = 0.0

	tutorial_director.reset()
	stats = HeroStats.new(hero_id)
	player.visible = true
	player.global_position = Vector3.ZERO
	player.setup(stats)

	skill_executor.setup(world_root, spatial_grid, stats)
	loot_manager.setup(world_root, stats)
	wave_director.setup(
		world_root,
		func(e: EnemyEntity) -> void:
			if player != null:
				player.notify_kill()
			if skill_executor != null:
				skill_executor.trigger_kill_effects(e.global_position, e.was_chilled())
			loot_manager.drop_for_enemy(e, wave_director.elapsed_time),
		func(pos: Vector3, dir: Vector3, spd: float, dmg: float, r: float, col: Color) -> void:
			skill_executor.spawn_enemy_projectile(pos, dir, spd, dmg, r, col, player),
		func(pos: Vector3, r: float, windup: float, dmg: float, col: Color, _is_ring: bool) -> void:
			skill_executor.spawn_enemy_telegraph(pos, r, windup, dmg, col, player)
	)
	spatial_grid.rebuild([])

	title_screen.visible = false
	inventory_panel.visible = false
	inventory_panel.set_tutorial_hint("")
	end_screen.visible = false
	hud.visible = true
	hud.reset_hud(_selected_hero_id)
	hud.set_tutorial_objective(false)
	hud.set_fps_visible(_review_mode)
	hud.set_mobile_mode(_is_mobile_touch, _allow_mouse_touch)
	hud.reset_touch_input()
	hud.rebuild_skill_bar(stats)
	hud.show_banner("Survive 20 Minutes & Defeat All 3 Bosses!", Color(1.0, 0.90, 0.42))
	sfx.play("socket_chime")

func start_tutorial(hero_id: String) -> void:
	_selected_hero_id = hero_id
	_is_tutorial = true
	if _showcase_rig != null:
		_showcase_rig.queue_free()
		_showcase_rig = null

	get_tree().paused = false
	state = GameState.PLAYING
	_shake_trauma = 0.0

	stats = HeroStats.new(hero_id)
	stats.init_bare_for_tutorial(hero_id)
	player.visible = true
	player.global_position = Vector3.ZERO
	player.setup(stats)

	skill_executor.setup(world_root, spatial_grid, stats)
	loot_manager.setup(world_root, stats)
	wave_director.setup(
		world_root,
		func(e: EnemyEntity) -> void:
			if player != null:
				player.notify_kill()
			if skill_executor != null:
				skill_executor.trigger_kill_effects(e.global_position, e.was_chilled())
			if tutorial_director != null:
				tutorial_director.notify_enemy_killed(e),
		func(pos: Vector3, dir: Vector3, spd: float, dmg: float, r: float, col: Color) -> void:
			skill_executor.spawn_enemy_projectile(pos, dir, spd, dmg, r, col, player),
		func(pos: Vector3, r: float, windup: float, dmg: float, col: Color, _is_ring: bool) -> void:
			skill_executor.spawn_enemy_telegraph(pos, r, windup, dmg, col, player)
	)
	spatial_grid.rebuild([])

	title_screen.visible = false
	inventory_panel.visible = false
	end_screen.visible = false
	hud.visible = true
	hud.reset_hud(_selected_hero_id)
	hud.set_fps_visible(_review_mode)
	hud.set_mobile_mode(_is_mobile_touch, _allow_mouse_touch)
	hud.reset_touch_input()
	hud.rebuild_skill_bar(stats)
	tutorial_director.start(stats, loot_manager, wave_director, player)
	sfx.play("socket_chime")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.keycode
		if kc == KEY_F3:
			if hud != null:
				hud.toggle_fps_visible()
			get_viewport().set_input_as_handled()
			return
		if _review_mode and stats != null:
			if kc == KEY_F8:
				_seed_review_loot()
				get_viewport().set_input_as_handled()
				return
			elif kc == KEY_F9:
				wave_director.bosses_defeated_count = 3
				wave_director.kills_count = maxi(wave_director.kills_count, 312)
				wave_director.elapsed_time = 1178.0
				_on_victory()
				get_viewport().set_input_as_handled()
				return
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
	_clear_touch_controls()
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
		_clear_touch_controls()
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
	if _is_tutorial and tutorial_director != null:
		tutorial_director.notify_gear_changed()

func _process(delta: float) -> void:
	if state == GameState.TITLE:
		_showcase_time += delta
		if _showcase_rig != null:
			_showcase_rig.rotation.y = sin(_showcase_time * 0.9) * 0.48
			_showcase_rig.position.y = absf(sin(_showcase_time * 3.0)) * 0.12
		if camera != null:
			var vp_sz: Vector2 = get_viewport().get_visible_rect().size
			if vp_sz.y > vp_sz.x * 1.05:
				camera.look_at_from_position(Vector3(0.0, 2.65, 7.20), Vector3(0.0, 0.25, 0.0), Vector3.UP)
			else:
				camera.look_at_from_position(Vector3(0.0, 2.38, 5.85), Vector3(0.0, 0.56, 0.0), Vector3.UP)
		return

	if state != GameState.PLAYING or get_tree().paused:
		return

	player.set_touch_move(hud.get_touch_move_vector())
	player.step(delta)
	if _is_tutorial:
		wave_director.step_enemies_only(delta, player.global_position, spatial_grid)
	else:
		wave_director.step(delta, player.global_position, spatial_grid, loot_manager)
	skill_executor.step(delta, player.global_position, player)
	loot_manager.step(delta, player.global_position, wave_director.elapsed_time)

	var touching: Array = spatial_grid.query_radius(player.global_position, 0.55)
	if not touching.is_empty():
		var e: EnemyEntity = touching[0]
		player.take_damage(e.contact_damage)

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
	var vp_sz: Vector2 = get_viewport().get_visible_rect().size
	var cam_off: Vector3 = Vector3(0.0, 22.5, 17.0) if vp_sz.y > vp_sz.x * 1.05 else Vector3(0.0, 17.5, 13.5)
	var target_cam_pos: Vector3 = player.global_position + cam_off + shake_off
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

func _on_item_looted(item: ItemInstance) -> void:
	hud.add_unread_loot()
	var col: Color = GameEnums.rarity_color(item.rarity)
	hud.push_toast("[%s] %s (%s)" % [GameEnums.rarity_label(item.rarity), item.item_name, item.get_socket_summary_text()], col, UiIcons.get_slot_icon(item.equip_slot))
	if item.rarity >= GameEnums.Rarity.UNIQUE:
		sfx.play("loot_unique")
		hud.show_banner("UNIQUE: %s!" % item.item_name, col)
	elif item.rarity >= GameEnums.Rarity.RARE:
		sfx.play("loot_rare")
	else:
		sfx.play("loot_common")
	if _is_tutorial and tutorial_director != null:
		tutorial_director.notify_item_looted(item)

func _on_gem_looted(gem: GemInstance) -> void:
	hud.add_unread_loot()
	var col: Color = GameEnums.gem_color_value(gem.get_gem_color())
	var gtype: int = gem.get_gem_type()
	var gtex: Texture2D = UiIcons.get_skill_icon(gem.gem_id) if gtype == GameEnums.GemType.MAIN else UiIcons.get_gem_icon(GameEnums.GemType.MODIFIER, gem.get_gem_color())
	hud.push_toast("[%s] %s" % [GameEnums.gem_type_label(gtype), gem.get_gem_name()], col, gtex)
	sfx.play("gem_drop")
	if _is_tutorial and tutorial_director != null:
		tutorial_director.notify_gem_looted(gem)

func _seed_review_loot() -> void:
	if stats == null:
		return
	if stats.item_bag.is_empty():
		stats.item_bag.append(ItemDatabase.create_unique_item("unique_acorn_scepter"))
		stats.item_bag.append(ItemDatabase.generate_item(GameEnums.Rarity.RARE, false, GameEnums.EquipSlot.HELMET, _rng))
		stats.item_bag.append(ItemDatabase.generate_item(GameEnums.Rarity.MAGIC, false, GameEnums.EquipSlot.RING, _rng))
	if stats.gem_pouch.is_empty():
		stats.gem_pouch.append(GemInstance.new("petal_cyclone"))
		stats.gem_pouch.append(GemInstance.new("mod_multishot"))
		stats.gem_pouch.append(GemInstance.new("mod_chain"))
	if inventory_panel != null and inventory_panel.visible:
		inventory_panel.refresh()

func _on_tutorial_completed() -> void:
	if state == GameState.ENDED:
		return
	_clear_touch_controls()
	state = GameState.ENDED
	get_tree().paused = true
	sfx.play("victory_fanfare")
	end_screen.show_tutorial_complete(stats, wave_director)

func _on_player_died() -> void:
	if state == GameState.ENDED:
		return
	_clear_touch_controls()
	state = GameState.ENDED
	get_tree().paused = true
	sfx.play("boss_horn")
	end_screen.show_end(false, stats, wave_director)

func _on_victory() -> void:
	if state == GameState.ENDED:
		return
	_clear_touch_controls()
	state = GameState.ENDED
	get_tree().paused = true
	sfx.play("victory_fanfare")
	end_screen.show_end(true, stats, wave_director)
