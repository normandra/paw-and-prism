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
	print("=== Paw & Prism v3.0 Card-Forging Verification Suite ===")

	# 1. Load & instantiate main scene
	var packed: PackedScene = load("res://scenes/main.tscn")
	_assert(packed != null, "Main scene loads cleanly")
	var main_inst: MainGame = packed.instantiate() as MainGame
	_assert(main_inst != null, "MainGame instantiates cleanly")
	root.add_child(main_inst)
	await process_frame

	# 2. Single streamlined playable hero: Mochi the Shiba only
	var all_heroes: Array[Dictionary] = HeroDatabase.get_all_heroes()
	_assert(all_heroes.size() == 1 and String(all_heroes[0]["id"]) == "shiba", "HeroDatabase streamlined to 1 playable hero (shiba)")
	var rig: Node3D = ChibiMeshFactory.build_hero_rig("shiba")
	_assert(rig != null and rig.get_node_or_null("BodyPivot/WeaponMount") != null, "Mochi the Shiba 3D rig built with signature Acorn Wand")
	rig.free()

	# 3. All 7 regular enemies + 3 bosses + 3 Card/Chest loot mesh types
	for eid in EnemyDatabase.get_all_regular_ids():
		var erig: Node3D = ChibiMeshFactory.build_enemy_rig(eid, true)
		var bmesh: MeshInstance3D = erig.get_node_or_null("BodyPivot/BodyMesh")
		_assert(erig != null and bmesh != null and bmesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Merged enemy rig (shadow OFF) built for " + eid)
		erig.free()
	for bid in EnemyDatabase.get_all_boss_ids():
		var brig: Node3D = ChibiMeshFactory.build_enemy_rig(bid, false)
		_assert(brig != null and brig.get_node_or_null("BodyPivot") != null, "Boss rig built for " + bid)
		brig.free()
	for lkind in ["template_card", "addon_card", "chest"]:
		var lm: Node3D = ChibiMeshFactory.build_loot_mesh(lkind, Color.GOLD, GameEnums.Rarity.RARE)
		_assert(lm != null and lm.get_node_or_null("SpinPivot") != null, "Loot 3D mesh built for " + lkind)
		lm.free()

	# 4. Storybook Theme, Fonts & Bespoke SVG Card Artwork (10 Templates + 24 Add-ons)
	var game_theme: Theme = UiHelper.create_game_theme()
	_assert(game_theme != null and UiHelper.get_display_font() != null and UiHelper.get_body_font() != null, "Storybook Theme and Fredoka/Nunito fonts loaded")
	_assert(UiHelper._wght_tag() == 2003265652, "OpenType wght FourCC tag resolves cleanly")
	var pt: Texture2D = UiIcons.get_hero_portrait("shiba")
	_assert(pt != null and pt.get_width() > 0, "Hero portrait SVG rendered for shiba")

	var tpl_ids: Array[String] = CardDatabase.get_all_template_ids()
	var add_ids: Array[String] = CardDatabase.get_all_addon_ids()
	_assert(tpl_ids.size() == 10 and add_ids.size() == 24, "CardDatabase exposes 10 Template Cards & 24 Add-on Cards")
	for cid in tpl_ids + add_ids:
		var art: Texture2D = UiIcons.get_card_art(cid)
		_assert(art != null and art.get_width() == 160 and art.get_height() == 120, "Custom SVG card artwork rendered (160x120) for " + cid)

	# 5. CardInstance Rarity Forge Limits (Common 1 / Uncommon 2 / Rare 3 / Legendary 4), Stacking & Tag Validation
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42069
	var expected_limits: Array[int] = [1, 2, 3, 4]
	for r in [GameEnums.Rarity.COMMON, GameEnums.Rarity.UNCOMMON, GameEnums.Rarity.RARE, GameEnums.Rarity.LEGENDARY]:
		var c_probe: CardInstance = CardInstance.generate_template(600.0, rng, r, "acorn_barrage")
		_assert(c_probe.get_max_forges() == expected_limits[r], "Rarity %s forge cap == %d" % [GameEnums.rarity_label(r), expected_limits[r]])
		var cw_probe: CardWidget = CardWidget.new()
		cw_probe.setup_card(c_probe)
		_assert(cw_probe.mouse_filter == Control.MOUSE_FILTER_STOP and cw_probe.action_row != null, "CardWidget builds Slay-the-Spire card frame for " + GameEnums.rarity_label(r))
		cw_probe.free()

	# Incompatible add-on check (Multi-Shot cannot forge onto Melee Honey Slam)
	var slam_card: CardInstance = CardInstance.new("honey_slam", GameEnums.Rarity.RARE)
	var multi_addon: CardInstance = CardInstance.new("addon_multishot")
	_assert(not bool(slam_card.can_accept_addon(multi_addon)["ok"]), "Incompatible Multi-Shot rejected on melee Honey Slam")

	# Duplicate stacking + forge limit cap + Add-on consumption
	var test_stats: HeroStats = HeroStats.new("shiba")
	test_stats.init_bare_for_tutorial("shiba")
	_assert(test_stats.equipped_cards.is_empty() and test_stats.active_skill_configs.is_empty(), "Tutorial bare init starts with 0 equipped cards")

	var unc_acorn: CardInstance = CardInstance.new("acorn_barrage", GameEnums.Rarity.UNCOMMON)
	test_stats.equipped_cards.append(unc_acorn)
	test_stats.addon_inventory.append(CardInstance.new("addon_multishot"))
	test_stats.addon_inventory.append(CardInstance.new("addon_multishot"))
	test_stats.addon_inventory.append(CardInstance.new("addon_pierce"))
	test_stats.recompute()

	var f1: Dictionary = test_stats.forge_addon_onto_card(0, unc_acorn)
	_assert(bool(f1["ok"]) and test_stats.addon_inventory.size() == 2 and unc_acorn.get_forge_count() == 1, "1st Multi-Shot forged & Add-on consumed")
	var f2: Dictionary = test_stats.forge_addon_onto_card(0, unc_acorn)
	_assert(bool(f2["ok"]) and test_stats.addon_inventory.size() == 1 and unc_acorn.get_forge_count() == 2, "2nd stacked Multi-Shot forged (2/2 limit)")
	var f3: Dictionary = test_stats.forge_addon_onto_card(0, unc_acorn)
	_assert(not bool(f3["ok"]) and test_stats.addon_inventory.size() == 1, "3rd forge blocked on Uncommon 2/2 cap without consuming Add-on")
	_assert(int(test_stats.active_skill_configs[0]["projectiles"]) == 5, "Double-stacked Multi-Shot on Acorn grants 1 + 2 + 2 = 5 shots")

	# Unlimited equip count + Deck Focus scaling
	var deck_stats: HeroStats = HeroStats.new("shiba")
	_assert(deck_stats.equipped_card_count == 1 and is_equal_approx(deck_stats.deck_cd_mult, 1.00), "1 equipped card gives 1.00x Deck Focus CD")
	deck_stats.equipped_cards.append(CardInstance.new("petal_cyclone", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 2 and is_equal_approx(deck_stats.deck_cd_mult, 1.12), "2 equipped cards give 1.12x Deck Focus CD")
	deck_stats.equipped_cards.append(CardInstance.new("frost_nova", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 3 and is_equal_approx(deck_stats.deck_cd_mult, 1.25), "3 equipped cards give 1.25x Deck Focus CD (sweet spot)")
	deck_stats.equipped_cards.append(CardInstance.new("honey_slam", GameEnums.Rarity.COMMON))
	deck_stats.equipped_cards.append(CardInstance.new("spirit_bees", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 5 and is_equal_approx(deck_stats.deck_cd_mult, 1.95), "5 unlimited equipped cards apply 1.95x Deck Focus CD")

	# Per-card Sniper Focus vs Short Barrage + Glass Spark taken dmg
	var s_stats: HeroStats = HeroStats.new("shiba")
	var acorn_sniper: CardInstance = CardInstance.new("acorn_barrage", GameEnums.Rarity.LEGENDARY)
	acorn_sniper.apply_forge("addon_multishot")
	acorn_sniper.apply_forge("addon_sniper_focus")
	acorn_sniper.apply_forge("addon_glass_spark")
	acorn_sniper.apply_forge("addon_echo")
	s_stats.equipped_cards = [acorn_sniper]
	s_stats.recompute()
	var scfg: Dictionary = s_stats.active_skill_configs[0]
	_assert(int(scfg["projectiles"]) == 1 and int(scfg["pierce"]) == 2 and int(scfg["echo_count"]) == 1, "Legendary 4/4 forged Acorn Sniper compiles 1 piercing bolt + Echo")
	_assert(is_equal_approx(s_stats.incoming_dmg_mult, 1.0 + BalanceConfig.GLASS_TAKEN_BONUS), "Glass Spark sets Hero incoming_dmg_mult cleanly")

	# 6. Full Playable 3-Beat Card-Forging Tutorial
	main_inst.start_tutorial("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and main_inst._is_tutorial, "Tutorial entered PLAYING bare-pawed")
	_assert(main_inst.stats.equipped_cards.is_empty(), "Hero starts tutorial with 0 equipped cards")
	_assert(main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 1 spawned Uncommon Acorn Barrage Card")

	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.stats.template_inventory.size() == 1 and main_inst.tutorial_director.current_step == TutorialDirector.Step.EQUIP_TEMPLATE, "Tutorial Beat 1: Looted Template Card -> EQUIP_TEMPLATE")
	main_inst.stats.equip_template_from_inventory(0)
	main_inst._on_deck_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_1 and main_inst.wave_director.enemies.size() == 3, "Tutorial Beat 1: Equipping Card spawned 3 critters")

	for _k in range(3):
		var cr: EnemyEntity = main_inst.wave_director.enemies[0]
		cr.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.LOOT_ADDON and main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 2: Killing 3 critters drops Multi-Shot Add-on Card")

	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.FORGE_ADDON, "Tutorial Beat 2: Looted Multi-Shot Add-on -> FORGE_ADDON")
	var tut_forge: Dictionary = main_inst.stats.forge_addon_onto_card(0, main_inst.stats.equipped_cards[0])
	_assert(bool(tut_forge["ok"]) and main_inst.stats.addon_inventory.is_empty(), "Tutorial Beat 2: Multi-Shot forged & consumed onto Acorn Barrage")
	main_inst._on_deck_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_2 and main_inst.wave_director.enemies.size() == 5, "Tutorial Beat 2: Forging triggered 5-critter test wave")

	for _k2 in range(5):
		var cr2: EnemyEntity = main_inst.wave_director.enemies[0]
		cr2.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.DONE and main_inst.state == MainGame.GameState.ENDED and main_inst.end_screen.visible, "Tutorial Complete -> EndScreen displayed cleanly")

	# 7. Normal 20-Minute Run, TouchControls, Drop Formula, Deck/Forge UI & 3-Boss Victory
	main_inst.start_new_run("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst._is_tutorial, "20-Min Run entered PLAYING state cleanly")
	_assert(main_inst.stats.equipped_cards.size() == 1 and main_inst.stats.equipped_cards[0].rarity == GameEnums.Rarity.UNCOMMON, "20-Min Run starts with Uncommon Acorn Barrage (2 forge slots)")
	_assert(main_inst.hud.touch_controls != null and not main_inst.hud.touch_controls.has_signal("dash_triggered"), "TouchControls joystick attached without Dash pad")

	var touch_start_x: float = main_inst.player.global_position.x
	main_inst.player.set_touch_move(Vector2(1.0, 0.0))
	main_inst.player.step(0.1)
	_assert(main_inst.player.global_position.x > touch_start_x + 0.4, "Touch joystick moves Mochi cleanly")
	main_inst.player.set_touch_move(Vector2.ZERO)

	# Drop rate scaling + Volley Shotgun check
	_assert(is_equal_approx(LootManager.compute_spawn_intensity(0.0), 1.0), "Opening SpawnIntensity(0s) == 1.0")
	_assert(LootManager.compute_spawn_intensity(1100.0) > 4.0, "Late-game SpawnIntensity(1100s) scales above 4.0x")
	_assert(LootManager.compute_regular_template_chance(1100.0, 0) < LootManager.compute_regular_template_chance(0.0, 0), "Spawn-normalized Template drop chance scales down as spawns rise")
	_assert(LootManager.compute_regular_addon_chance(0.0, 80) > LootManager.compute_regular_addon_chance(0.0, 0), "Dry-streak pity boosts Add-on drop rate after 60+ kills")

	var volley_enemy: EnemyEntity = EnemyEntity.new()
	_assert(is_equal_approx(volley_enemy.consume_volley_dmg_mult(99), 1.0), "First volley projectile deals 1.00x full hit")
	_assert(is_equal_approx(volley_enemy.consume_volley_dmg_mult(99), BalanceConfig.VOLLEY_REPEAT_MULT), "Same-volley repeat dampened cleanly")
	volley_enemy.free()

	main_inst._seed_review_loot()
	main_inst._open_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.INVENTORY and main_inst.inventory_panel.visible, "Deck & Forge panel opens cleanly")

	# Equip seeded Rare Meteor Pinecone via InventoryPanel + Forge Multi-Shot onto Starter Acorn via UI flow
	_assert(main_inst.inventory_panel.equip_template_at(0), "Deck UI equip_template_at equips Meteor Pinecone into Active Deck")
	_assert(main_inst.stats.equipped_cards.size() == 2, "Active Deck now has 2 unlimited equipped cards")
	main_inst.inventory_panel.start_forge_addon_at(0)
	_assert(main_inst.inventory_panel._forge_mode_panel.visible, "Deck UI displays Forge Mode banner when Add-on selected")
	_assert(main_inst.inventory_panel.confirm_forge_onto_equipped(0), "Deck UI confirm_forge_onto_equipped permanently forges Add-on onto Card 0")
	_assert(main_inst.stats.equipped_cards[0].get_forge_count() == 1 and main_inst.inventory_panel._feedback_panel.visible, "Starter Card now shows 1/2 forged & UI confirmation strip")

	for mtab in ["active", "templates", "addons"]:
		main_inst.inventory_panel._mobile_tab = mtab
		main_inst.inventory_panel.refresh()
	main_inst._close_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst.inventory_panel.visible, "Deck & Forge panel closes cleanly")

	var boss_times: Array[float] = [390.5, 780.5, 1170.5]
	for idx in range(boss_times.size()):
		main_inst.wave_director.jump_to_time_for_test(boss_times[idx])
		await process_frame
		var b: EnemyEntity = main_inst.wave_director.active_boss
		_assert(b != null and is_instance_valid(b) and b.boss_index == idx + 1, "Boss %d/3 spawned at t=%.1fs" % [idx + 1, boss_times[idx]])
		if idx == 2:
			_assert(is_equal_approx(b.max_hp, 9500.0), "King Bramblehorn HP == 9500")
		var pickups_before: int = main_inst.loot_manager.pickups.size()
		b.take_damage(999999.0, Vector3.ZERO, false)
		await process_frame
		_assert(main_inst.wave_director.bosses_defeated_count == idx + 1, "Boss %d/3 defeat recorded" % [idx + 1])
		_assert(main_inst.loot_manager.pickups.size() > pickups_before, "Boss %d/3 dropped Template & Add-on Cards" % [idx + 1])

	_assert(main_inst.state == MainGame.GameState.ENDED, "Defeating Boss 3 transitions MainGame to ENDED (Victory)")

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
