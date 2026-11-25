extends SceneTree

var _failures: Array[String] = []

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("FAIL: " + msg)
	else:
		print("PASS: " + msg)

func _initialize() -> void:
	call_deferred("_run_all")

func _run_all() -> void:
	print("=== Paw & Prism v2 Verification Suite ===")

	# 1. Load & instantiate main scene
	var packed: PackedScene = load("res://scenes/main.tscn")
	_assert(packed != null, "Main scene loads cleanly")
	var main_inst: MainGame = packed.instantiate() as MainGame
	_assert(main_inst != null, "MainGame instantiates cleanly")
	root.add_child(main_inst)
	await process_frame

	# 2. All 4 chibi hero rigs & gear swapping + bare reset
	for hdef in HeroDatabase.get_all_heroes():
		var hid: String = String(hdef["id"])
		var rig: Node3D = ChibiMeshFactory.build_hero_rig(hid)
		_assert(rig != null and rig.get_node_or_null("BodyPivot/HeadPivot/HatMount") != null, "Hero rig built for " + hid)
		ChibiMeshFactory.update_hero_visual_gear(rig, "honey_hammer", "wizard_hat")
		var wmount: Node3D = rig.get_node_or_null("BodyPivot/WeaponMount")
		var hmount: Node3D = rig.get_node_or_null("BodyPivot/HeadPivot/HatMount")
		_assert(wmount != null and wmount.get_child_count() > 0, "Weapon visual swapped for " + hid)
		_assert(hmount != null and hmount.get_child_count() > 0, "Helmet visual swapped for " + hid)
		ChibiMeshFactory.update_hero_visual_gear(rig, "", "")
		_assert(wmount.get_child_count() == 0 and hmount.get_child_count() == 0, "Bare hero gear clears mounts cleanly for " + hid)
		rig.free()

	# 3. All 7 regular enemies + 3 bosses + 3 loot mesh types
	for eid in EnemyDatabase.get_all_regular_ids():
		var erig: Node3D = ChibiMeshFactory.build_enemy_rig(eid, true)
		var bmesh: MeshInstance3D = erig.get_node_or_null("BodyPivot/BodyMesh")
		_assert(erig != null and bmesh != null and bmesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Merged enemy rig (shadow OFF) built for " + eid)
		erig.free()
	for bid in EnemyDatabase.get_all_boss_ids():
		var brig: Node3D = ChibiMeshFactory.build_enemy_rig(bid, false)
		_assert(brig != null and brig.get_node_or_null("BodyPivot") != null, "Boss rig built for " + bid)
		brig.free()
	for lkind in ["item", "main_gem", "mod_gem", "chest"]:
		var lm: Node3D = ChibiMeshFactory.build_loot_mesh(lkind, Color.GOLD, GameEnums.Rarity.RARE)
		_assert(lm != null and lm.get_node_or_null("SpinPivot") != null, "Loot 3D mesh built for " + lkind)
		lm.free()

	# 4. Storybook Theme, Fonts, Vector Icons & Global Effect Chips
	var game_theme: Theme = UiHelper.create_game_theme()
	_assert(game_theme != null and UiHelper.get_display_font() != null and UiHelper.get_body_font() != null, "Storybook Theme and Fredoka/Nunito fonts loaded")
	_assert(UiHelper._wght_tag() == 2003265652, "OpenType wght FourCC tag resolves cleanly")
	for hid in ["shiba", "bunny", "bear", "cat"]:
		var pt: Texture2D = UiIcons.get_hero_portrait(hid)
		_assert(pt != null and pt.get_width() > 0, "Hero portrait SVG rendered for " + hid)
	var main_ids: Array[String] = GemDatabase.get_ids_by_type(GameEnums.GemType.MAIN)
	var mod_ids: Array[String] = GemDatabase.get_ids_by_type(GameEnums.GemType.MODIFIER)
	_assert(main_ids.size() == 10 and mod_ids.size() == 10, "GemDatabase exposes 10 Main & 10 Modifier abilities")
	for gid in main_ids:
		var st: Texture2D = UiIcons.get_skill_icon(gid)
		_assert(st != null and st.get_width() > 0, "Main ability SVG rendered for " + gid)
	for eff_id in ItemDatabase.get_all_non_unique_effect_ids():
		var chip: PanelContainer = UiHelper.make_effect_chip(eff_id, true)
		_assert(chip != null and chip.get_child_count() > 0, "Effect chip built for " + eff_id)
		chip.free()

	# 5. Item Generation, Fixed Rolled Sockets & Behavioral Tradeoffs
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 12345
	for r in [GameEnums.Rarity.COMMON, GameEnums.Rarity.MAGIC, GameEnums.Rarity.RARE, GameEnums.Rarity.UNIQUE]:
		var it: ItemInstance = ItemDatabase.generate_item(r, false, -1, rng)
		_assert(it != null and it.rarity == r and it.get_socket_count() >= 1, "Generated item rarity %d: %s (%s)" % [r, it.item_name, it.get_socket_summary_text()])
	var tut_wand: ItemInstance = ItemDatabase.create_tutorial_wand()
	_assert(tut_wand != null and tut_wand.get_socket_count() >= 2 and tut_wand.links[0], "Tutorial wand has 2 linked sockets")

	var mini_sw: PoESocketWidget = PoESocketWidget.new()
	mini_sw.configure_mini(tut_wand)
	_assert(mini_sw.mini_mode and is_equal_approx(mini_sw.custom_minimum_size.y, 20.0), "PoESocketWidget mini mode height stays 20px")
	mini_sw.free()

	# 6. PoE Ability Linking & Global Behavioral Compilation (zero numeric stat-sticks)
	var test_stats: HeroStats = HeroStats.new("shiba")
	test_stats.init_bare_for_tutorial("shiba")
	_assert(test_stats.equipped[GameEnums.EquipSlot.WEAPON] == null and test_stats.active_skill_configs.is_empty(), "Tutorial bare init starts with zero gear and zero abilities")

	var test_wep: ItemInstance = ItemInstance.new()
	test_wep.equip_slot = GameEnums.EquipSlot.WEAPON
	test_wep.effects = ["short_barrage", "fleet_paws", "glass_spark", "kill_siphon"]
	test_wep.setup_sockets([GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE], [true, false])
	var g_acorn: GemInstance = GemInstance.new("acorn_barrage")
	var g_multi: GemInstance = GemInstance.new("mod_multishot")
	var g_echo: GemInstance = GemInstance.new("mod_echo") # NOT linked yet across link[1] = false
	test_wep.insert_gem(0, g_acorn)
	test_wep.insert_gem(1, g_multi)
	test_wep.insert_gem(2, g_echo)
	test_stats.equipped[GameEnums.EquipSlot.WEAPON] = test_wep
	test_stats.recompute()

	var acorn_cfg: Dictionary = {}
	for c in test_stats.active_skill_configs:
		if int(c["uid"]) == g_acorn.uid:
			acorn_cfg = c
	_assert(not acorn_cfg.is_empty(), "Main Acorn Barrage compiled cleanly")
	var base_acorn_cd: float = float(acorn_cfg["cooldown"])
	# Base 1 + mod_multishot (+2) + short_barrage (+2) = 5 projectiles, 0.55x lifetime!
	_assert(int(acorn_cfg["projectiles"]) == 5, "Multi-Shot + Short Barrage tradeoff grants 5 projectiles (got %d)" % int(acorn_cfg["projectiles"]))
	_assert(float(acorn_cfg["lifetime_mult"]) < 0.7, "Short Barrage reduces projectile lifetime range")
	_assert(bool(acorn_cfg["echo"]) == false, "Unlinked Echo does NOT apply across unlinked socket gap")
	_assert(not ("dash_max_charges" in test_stats), "Dash properties completely removed from HeroStats")
	_assert(test_stats.has_fleet_paws and test_stats.has_kill_siphon and is_equal_approx(test_stats.incoming_dmg_mult, 1.45), "Fleet Paws, Kill Siphon & Glass Spark flags compiled")
	_assert(not GemDatabase.does_modifier_apply("mod_multishot", "honey_slam"), "Multi-Shot does NOT apply to melee Honey Slam")

	# Enable link[1] + test Unique prism_echo + sniper_focus + replacement movement/cadence effects
	test_wep.links[1] = true
	test_wep.effects = ["prism_echo", "sniper_focus", "comet_stride", "cadence_burst", "stride_honey_nova"]
	test_stats.recompute()
	for c in test_stats.active_skill_configs:
		if int(c["uid"]) == g_acorn.uid:
			acorn_cfg = c
	_assert(bool(acorn_cfg["echo"]) == true and int(acorn_cfg["projectiles"]) == 1 and int(acorn_cfg["pierce"]) >= 2, "Linked Echo + Sniper Focus forces 1 fast piercing shot")
	_assert(test_stats.has_comet_stride and test_stats.has_cadence_burst and test_stats.has_stride_honey_nova, "Comet Stride, Cadence Burst & Stride Honey Nova compiled cleanly")
	_assert(float(acorn_cfg["cooldown"]) > base_acorn_cd * 1.15, "Cadence Burst applies 1.18x skill cooldown tradeoff")

	# Test Equipment Swap preserves gems safely
	var tiny_wep: ItemInstance = ItemInstance.new()
	tiny_wep.equip_slot = GameEnums.EquipSlot.WEAPON
	tiny_wep.setup_sockets([GameEnums.GemColor.RED], [])
	test_stats.item_bag.append(tiny_wep)
	var pouch_before: int = test_stats.gem_pouch.size()
	test_stats.equip_item_from_bag(0)
	_assert(test_stats.gem_pouch.size() == pouch_before + 3, "Swapping to smaller weapon preserves all 3 gems in gem_pouch")

	# 7. Full Playable PoE Tutorial Lifecycle
	main_inst.start_tutorial("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and main_inst._is_tutorial, "Tutorial mode entered PLAYING bare-pawed")
	_assert(main_inst.stats.equipped[GameEnums.EquipSlot.WEAPON] == null, "Hero starts tutorial with bare weapon slot")
	_assert(main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 1 spawned Meadow Acorn Wand on ground")

	# Walk to wand -> collect -> equip
	var p1_pos: Vector3 = main_inst.loot_manager.pickups[0].global_position
	main_inst.player.global_position = p1_pos
	main_inst._process(0.4)
	_assert(main_inst.stats.item_bag.size() == 1 and main_inst.tutorial_director.current_step == TutorialDirector.Step.EQUIP_ITEM, "Tutorial Beat 1: Looted Wand -> EQUIP_ITEM")
	main_inst.stats.equip_item_from_bag(0)
	main_inst._on_gear_or_gems_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.LOOT_MAIN and main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 2: Equipping Wand drops Acorn Barrage")

	# Loot Acorn Barrage -> socket -> kill 3 critters
	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.SOCKET_MAIN, "Tutorial Beat 2: Looted Acorn Barrage -> SOCKET_MAIN")
	_assert(main_inst.stats.socket_gem_into_equipped(GameEnums.EquipSlot.WEAPON, 0, 0), "Socketed Acorn Barrage into green weapon socket 0")
	main_inst._on_gear_or_gems_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_1 and main_inst.wave_director.enemies.size() == 3, "Tutorial Beat 2: Socketed Main Ability spawned 3 critters")

	for _k in range(3):
		var cr: EnemyEntity = main_inst.wave_director.enemies[0]
		cr.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.LOOT_MOD and main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 3: Killing 3 critters drops Multi-Shot Modifier")

	# Loot Multi-Shot -> link -> kill 5 critters -> Tutorial Complete
	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.SOCKET_MOD, "Tutorial Beat 3: Looted Multi-Shot -> SOCKET_MOD")
	_assert(main_inst.stats.socket_gem_into_equipped(GameEnums.EquipSlot.WEAPON, 1, 0), "Linked Multi-Shot into green weapon socket 1")
	main_inst._on_gear_or_gems_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_2 and main_inst.wave_director.enemies.size() == 5, "Tutorial Beat 3: Linking Modifier spawned 5 critters")

	for _k2 in range(5):
		var cr2: EnemyEntity = main_inst.wave_director.enemies[0]
		cr2.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.DONE and main_inst.state == MainGame.GameState.ENDED and main_inst.end_screen.visible, "Tutorial Beat 3 completed -> EndScreen Tutorial Complete displayed")

	# 8. Normal 20-Minute Run, TouchControls, Satchel Tradeoff View & 3-Boss Victory
	main_inst.start_new_run("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst._is_tutorial, "20-Min Run entered PLAYING state cleanly")
	_assert(main_inst.hud.touch_controls != null and not main_inst.hud.touch_controls.has_signal("dash_triggered"), "TouchControls pure joystick overlay attached without Dash pad")
	_assert(not main_inst.player.has_signal("dashed") and main_inst.player.has_signal("stride_honey_requested") and main_inst.player.has_signal("comet_stride_requested"), "PlayerController removed dash and exposes stride triggers")
	var touch_start_x: float = main_inst.player.global_position.x
	main_inst.player.set_touch_move(Vector2(1.0, 0.0))
	main_inst.player.step(0.1)
	_assert(main_inst.player.global_position.x > touch_start_x + 0.4, "Touch joystick vector moves player hero")
	main_inst.player.set_touch_move(Vector2.ZERO)

	# Verify TouchScrollContainer + tap-stop + Drop Formula + Focus Load Tax + Volley Shotgun Dampener
	var ts_probe: TouchScrollContainer = TouchScrollContainer.new()
	_assert(ts_probe != null and not TouchScrollContainer.was_recent_drag(), "TouchScrollContainer instantiates and reports clean initial drag state")
	ts_probe.free()
	var sw_probe: PoESocketWidget = PoESocketWidget.new()
	_assert(sw_probe.mouse_filter == Control.MOUSE_FILTER_STOP, "PoESocketWidget stops mouse events cleanly inside scroll views")
	sw_probe.free()
	_assert(is_equal_approx(LootManager.compute_spawn_intensity(0.0), 1.0), "Opening SpawnIntensity(0s) == 1.0")
	_assert(LootManager.compute_spawn_intensity(1100.0) > 4.0, "Late-game SpawnIntensity(1100s) scales above 4.0x")
	_assert(LootManager.compute_regular_item_chance(0.0, false, 0) <= 0.02, "Opening regular item drop chance <= 2.0%%")
	_assert(LootManager.compute_regular_item_chance(1100.0, false, 0) < LootManager.compute_regular_item_chance(0.0, false, 0), "Spawn-normalized item drop rate scales down as wave spawns accelerate")
	_assert(LootManager.compute_regular_item_chance(0.0, false, 80) > LootManager.compute_regular_item_chance(0.0, false, 0), "Dry-streak pity increases item drop rate after 65+ kills")

	var focus_stats: HeroStats = HeroStats.new("shiba")
	_assert(focus_stats.equipped_main_count == 1 and is_equal_approx(focus_stats.multi_skill_cd_mult, 1.0), "1 Main Ability gives 1.00x Focus CD")
	var helmet_item: ItemInstance = focus_stats.equipped[GameEnums.EquipSlot.HELMET]
	helmet_item.insert_gem(0, GemInstance.new("petal_cyclone"))
	focus_stats.recompute()
	_assert(focus_stats.equipped_main_count == 2 and is_equal_approx(focus_stats.multi_skill_cd_mult, 1.25), "2 Main Abilities apply 1.25x Focus CD")
	helmet_item.insert_gem(1, GemInstance.new("frost_nova"))
	focus_stats.recompute()
	_assert(focus_stats.equipped_main_count == 3 and is_equal_approx(focus_stats.multi_skill_cd_mult, 1.50), "3 Main Abilities apply 1.50x Focus CD")

	var volley_enemy: EnemyEntity = EnemyEntity.new()
	_assert(is_equal_approx(volley_enemy.consume_volley_dmg_mult(42), 1.0), "First volley projectile deals 1.00x full hit")
	_assert(is_equal_approx(volley_enemy.consume_volley_dmg_mult(42), 0.35), "Same-volley repeat projectile dampened to 0.35x")
	volley_enemy.free()

	main_inst.skill_executor.trigger_reactive_nova("stride_honey_nova", main_inst.player.global_position, 24.0, 4.4)
	main_inst.skill_executor.trigger_reactive_nova("cadence_burst", main_inst.player.global_position, 34.0, 4.6)
	main_inst.skill_executor.trigger_all_skills_bonus(main_inst.player.global_position)

	for _f in range(20):
		main_inst._process(0.05)
		await process_frame

	main_inst._seed_review_loot()
	main_inst._open_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.INVENTORY and main_inst.inventory_panel.visible, "Satchel opens and displays visual tradeoff comparison")
	_assert(main_inst.inventory_panel._selected_bag_idx == 0, "Satchel auto-selects item 0 so Tradeoff Card & Equip CTA appear immediately")

	var tap_card: PanelContainer = PanelContainer.new()
	var tapped: Array[bool] = [false]
	main_inst.inventory_panel._connect_tap(tap_card, func() -> void: tapped[0] = true)
	_assert(tap_card.mouse_filter == Control.MOUSE_FILTER_STOP, "Satchel item card uses MOUSE_FILTER_STOP for reliable tapping")
	var ev_down: InputEventMouseButton = InputEventMouseButton.new()
	ev_down.button_index = MOUSE_BUTTON_LEFT
	ev_down.pressed = true
	ev_down.position = Vector2(20, 20)
	tap_card.gui_input.emit(ev_down)
	var ev_up: InputEventMouseButton = InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = Vector2(24, 22)
	tap_card.gui_input.emit(ev_up)
	_assert(tapped[0], "Satchel _connect_tap fires cleanly on press+release")
	tap_card.free()

	var equip_target: ItemInstance = main_inst.stats.item_bag[0]
	main_inst.inventory_panel._equip_item_at(0)
	_assert(main_inst.stats.equipped[equip_target.equip_slot] == equip_target, "Direct Satchel _equip_item_at moves Relic into equipped slot")
	_assert(main_inst.inventory_panel._feedback_panel.visible, "Satchel shows confirmation strip after equipping")

	for mtab in ["gear", "items", "skills", "build"]:
		main_inst.inventory_panel._mobile_tab = mtab
		main_inst.inventory_panel.refresh()
	main_inst.inventory_panel._active_right_tab = "main"
	main_inst.inventory_panel.refresh()
	main_inst.inventory_panel._active_right_tab = "mods"
	main_inst.inventory_panel.refresh()
	main_inst._close_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst.inventory_panel.visible, "Satchel closes cleanly")

	var boss_times: Array[float] = [390.5, 780.5, 1170.5]
	for idx in range(boss_times.size()):
		main_inst.wave_director.jump_to_time_for_test(boss_times[idx])
		await process_frame
		var b: EnemyEntity = main_inst.wave_director.active_boss
		_assert(b != null and is_instance_valid(b) and b.boss_index == idx + 1, "Boss %d/3 spawned at t=%.1fs" % [idx + 1, boss_times[idx]])
		if idx == 2:
			_assert(is_equal_approx(b.max_hp, 15000.0), "King Bramblehorn rebalanced HP is 15000")
		var pickups_before: int = main_inst.loot_manager.pickups.size()
		b.take_damage(999999.0, Vector3.ZERO, false)
		await process_frame
		_assert(main_inst.wave_director.bosses_defeated_count == idx + 1, "Boss %d/3 defeat recorded" % [idx + 1])
		_assert(main_inst.loot_manager.pickups.size() > pickups_before, "Boss %d/3 dropped strictly Items & Abilities loot" % [idx + 1])

	_assert(main_inst.state == MainGame.GameState.ENDED, "Defeating Boss 3 transitions MainGame to ENDED (Victory)")

	# 9. Procedural SFX check
	var samples: Array[String] = main_inst.sfx.get_loaded_sample_names()
	_assert(samples.size() >= 15, "SfxManager synthesized %d procedural WAV samples" % samples.size())

	main_inst.queue_free()
	await process_frame

	if _failures.is_empty():
		print("=== ALL VERIFICATION CHECKS PASSED ===")
		quit(0)
	else:
		print("=== VERIFICATION FAILED (%d errors) ===" % _failures.size())
		quit(1)
