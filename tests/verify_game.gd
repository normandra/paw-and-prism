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
	print("=== Paw & Prism v3.1 Card, Shop & Relic Verification Suite ===")

	# 1. Load & instantiate main scene
	var packed: PackedScene = load("res://scenes/main.tscn")
	_assert(packed != null, "Main scene loads cleanly")
	var main_inst: MainGame = packed.instantiate() as MainGame
	_assert(main_inst != null, "MainGame instantiates cleanly")
	root.add_child(main_inst)
	await process_frame

	# 2. Single streamlined playable hero + Brotato-scale 56x56m Arena
	var all_heroes: Array[Dictionary] = HeroDatabase.get_all_heroes()
	_assert(all_heroes.size() == 1 and String(all_heroes[0]["id"]) == "shiba", "HeroDatabase streamlined to 1 playable hero (shiba)")
	_assert(is_equal_approx(ArenaBuilder.ARENA_HALF_SIZE, 28.0), "Arena resized to compact Brotato-style half-size 28.0m (56x56m)")
	var rig: Node3D = ChibiMeshFactory.build_hero_rig("shiba")
	_assert(rig != null and rig.get_node_or_null("BodyPivot/WeaponMount") != null, "Mochi the Shiba 3D rig built with signature Acorn Wand")
	rig.free()

	# 3. All 7 regular enemies + 3 bosses + 5 Loot Mesh Types (including Gold Coin & Pouch)
	for eid in EnemyDatabase.get_all_regular_ids():
		var erig: Node3D = ChibiMeshFactory.build_enemy_rig(eid, true)
		var bmesh: MeshInstance3D = erig.get_node_or_null("BodyPivot/BodyMesh")
		_assert(erig != null and bmesh != null and bmesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Merged enemy rig (shadow OFF) built for " + eid)
		erig.free()
	for bid in EnemyDatabase.get_all_boss_ids():
		var brig: Node3D = ChibiMeshFactory.build_enemy_rig(bid, false)
		_assert(brig != null and brig.get_node_or_null("BodyPivot") != null, "Boss rig built for " + bid)
		brig.free()
	for lkind in ["gold_coin", "gold_pouch", "template_card", "addon_card", "chest"]:
		var lm: Node3D = ChibiMeshFactory.build_loot_mesh(lkind, Color.GOLD, GameEnums.Rarity.RARE)
		_assert(lm != null and lm.get_node_or_null("SpinPivot") != null, "Loot 3D mesh built for " + lkind)
		lm.free()

	# 4. Storybook Theme, Fonts, Bespoke SVG Card Artwork (10 Templates + 24 Add-ons) & 12 Relic SVGs
	var game_theme: Theme = UiHelper.create_game_theme()
	_assert(game_theme != null and UiHelper.get_display_font() != null and UiHelper.get_body_font() != null, "Storybook Theme and Fredoka/Nunito fonts loaded")
	_assert(UiHelper._wght_tag() == 2003265652, "OpenType wght FourCC tag resolves cleanly")
	var pt: Texture2D = UiIcons.get_hero_portrait("shiba")
	_assert(pt != null and pt.get_width() > 0, "Hero portrait SVG rendered for shiba")

	var tpl_ids: Array[String] = CardDatabase.get_all_template_ids()
	var add_ids: Array[String] = CardDatabase.get_all_addon_ids()
	var relic_ids: Array[String] = RelicDatabase.get_all_ids()
	_assert(tpl_ids.size() == 10 and add_ids.size() == 24 and relic_ids.size() == 12, "Databases expose 10 Templates, 24 Add-ons, and 12 Relics")
	for cid in tpl_ids + add_ids:
		var art: Texture2D = UiIcons.get_card_art(cid)
		_assert(art != null and art.get_width() == 160 and art.get_height() == 120, "Custom SVG card artwork rendered (160x120) for " + cid)
	for rid in relic_ids:
		var rart: Texture2D = UiIcons.get_relic_art(rid)
		_assert(rart != null and rart.get_width() == 160 and rart.get_height() == 120, "Custom SVG relic artwork rendered (160x120) for " + rid)

	# 5. CardInstance Rarity Forge Limits, Relic Effects & Readable Forged Descriptions
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42069
	var expected_limits: Array[int] = [1, 2, 3, 4]
	for r in [GameEnums.Rarity.COMMON, GameEnums.Rarity.UNCOMMON, GameEnums.Rarity.RARE, GameEnums.Rarity.LEGENDARY]:
		var c_probe: CardInstance = CardInstance.generate_template(600.0, rng, r, "acorn_barrage")
		_assert(c_probe.get_max_forges() == expected_limits[r], "Rarity %s forge cap == %d" % [GameEnums.rarity_label(r), expected_limits[r]])
		c_probe.apply_forge("addon_leech")
		var cw_probe: CardWidget = CardWidget.new()
		cw_probe.setup_card(c_probe, {"bonus_forges": 1})
		_assert(cw_probe.mouse_filter == Control.MOUSE_FILTER_STOP and cw_probe.tooltip_text.contains("Life Siphon") and cw_probe.tooltip_text.contains("Hits heal 2.2%"), "Forged Life Siphon renders full effect explanation on CardWidget for " + GameEnums.rarity_label(r))
		cw_probe.free()

	# Masterwork Anvil (+1 Forge Slot) + Hourglass (-15% CD) + Lucky Dice + Bell discount
	var test_stats: HeroStats = HeroStats.new("shiba")
	test_stats.init_bare_for_tutorial("shiba")
	var unc_acorn: CardInstance = CardInstance.new("acorn_barrage", GameEnums.Rarity.UNCOMMON)
	test_stats.equipped_cards.append(unc_acorn)
	test_stats.addon_inventory.append(CardInstance.new("addon_multishot"))
	test_stats.addon_inventory.append(CardInstance.new("addon_multishot"))
	test_stats.addon_inventory.append(CardInstance.new("addon_pierce"))
	test_stats.recompute()

	_assert(bool(test_stats.forge_addon_onto_card(0, unc_acorn)["ok"]), "1st Multi-Shot forged & Add-on consumed")
	_assert(bool(test_stats.forge_addon_onto_card(0, unc_acorn)["ok"]), "2nd stacked Multi-Shot forged (2/2 limit)")
	_assert(not bool(test_stats.forge_addon_onto_card(0, unc_acorn)["ok"]) and test_stats.addon_inventory.size() == 1, "3rd forge blocked on Uncommon 2/2 cap")
	test_stats.add_relic("relic_forge_hammer")
	_assert(test_stats.get_max_forges_for(unc_acorn) == 3, "Masterwork Anvil Relic expands Uncommon cap from 2 -> 3")
	_assert(bool(test_stats.forge_addon_onto_card(0, unc_acorn)["ok"]) and unc_acorn.get_forge_count() == 3, "3rd forge (Pierce) succeeds after acquiring Masterwork Anvil Relic")

	test_stats.add_relic("relic_hourglass")
	test_stats.add_relic("relic_merchant_bell")
	_assert(is_equal_approx(test_stats.relic_cd_mult, 0.85) and is_equal_approx(test_stats.shop_price_mult, 0.80), "Hourglass (-15%% CD) & Merchant's Bell (20%% discount) update HeroStats cleanly")

	# Unlimited equip count + Deck Focus scaling
	var deck_stats: HeroStats = HeroStats.new("shiba")
	_assert(deck_stats.equipped_card_count == 1 and is_equal_approx(deck_stats.deck_cd_mult, 1.00), "1 equipped card gives 1.00x Deck Focus CD")
	deck_stats.equipped_cards.append(CardInstance.new("petal_cyclone", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 2 and is_equal_approx(deck_stats.deck_cd_mult, 1.12), "2 equipped cards give 1.12x Deck Focus CD")
	deck_stats.equipped_cards.append(CardInstance.new("frost_nova", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 3 and is_equal_approx(deck_stats.deck_cd_mult, 1.25), "3 equipped cards give 1.25x Deck Focus CD")
	deck_stats.equipped_cards.append(CardInstance.new("honey_slam", GameEnums.Rarity.COMMON))
	deck_stats.equipped_cards.append(CardInstance.new("spirit_bees", GameEnums.Rarity.COMMON))
	deck_stats.recompute()
	_assert(deck_stats.equipped_card_count == 5 and is_equal_approx(deck_stats.deck_cd_mult, 1.95), "5 unlimited equipped cards apply 1.95x Deck Focus CD")

	# 6. Full Playable v3.1 Tutorial (Card -> Gold Pouch -> Shop Purchase -> Forging -> Wave Clear)
	main_inst.start_tutorial("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and main_inst._is_tutorial, "Tutorial entered PLAYING bare-pawed")
	_assert(main_inst.stats.equipped_cards.is_empty() and main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 1 spawned Acorn Barrage Card")

	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.stats.template_inventory.size() == 1 and main_inst.tutorial_director.current_step == TutorialDirector.Step.EQUIP_TEMPLATE, "Tutorial Beat 1: Looted Template Card -> EQUIP_TEMPLATE")
	main_inst.stats.equip_template_from_inventory(0)
	main_inst._on_deck_changed()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_1 and main_inst.wave_director.enemies.size() == 3, "Tutorial Beat 2: Equipping Card spawned 3 critters")

	for _k in range(3):
		var cr: EnemyEntity = main_inst.wave_director.enemies[0]
		cr.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.LOOT_GOLD and main_inst.loot_manager.pickups.size() == 1, "Tutorial Beat 2: Killing 3 critters dropped 40G Gold Pouch")

	main_inst.player.global_position = main_inst.loot_manager.pickups[0].global_position
	main_inst._process(0.4)
	_assert(main_inst.state == MainGame.GameState.SHOP and main_inst.shop_panel.visible and main_inst.tutorial_director.current_step == TutorialDirector.Step.BUY_IN_SHOP, "Tutorial Beat 3: Picking up Gold automatically opened Tutorial Caravan Shop")
	_assert(main_inst.shop_panel.buy_addon_slot(0), "Tutorial Beat 3: Purchased Multi-Shot Add-on (30G) inside ShopPanel")
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.FORGE_ADDON and main_inst.stats.addon_inventory.size() == 1, "Tutorial Beat 3: Shop purchase advanced Tutorial to FORGE_ADDON")

	main_inst._open_inventory_from_shop()
	main_inst.inventory_panel.start_forge_addon_at(0)
	_assert(main_inst.inventory_panel.confirm_forge_onto_equipped(0, false), "Tutorial Beat 3: Forged Multi-Shot onto Acorn Barrage via Deck UI")
	main_inst._close_inventory()
	main_inst._close_shop()
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.KILL_WAVE_2 and main_inst.wave_director.enemies.size() == 5, "Tutorial Beat 4: Forging spawned 5-critter finale wave")

	for _k2 in range(5):
		var cr2: EnemyEntity = main_inst.wave_director.enemies[0]
		cr2.take_damage(9999.0, Vector3.ZERO, false)
	await process_frame
	_assert(main_inst.tutorial_director.current_step == TutorialDirector.Step.DONE and main_inst.state == MainGame.GameState.ENDED and main_inst.end_screen.visible, "Tutorial Complete -> EndScreen displayed cleanly")

	# 7. Normal 20-Min Run, Deterministic 3-Min Shop, Relics, Minimap, Forge Anim Overlay & 3-Boss Victory
	main_inst.start_new_run("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst._is_tutorial, "20-Min Run entered PLAYING state cleanly")
	_assert(main_inst.stats.gold == BalanceConfig.STARTING_GOLD, "Run starts with %d Gold" % BalanceConfig.STARTING_GOLD)

	# Trigger deterministic Shop #1 at t = 180.0s
	main_inst.wave_director.jump_to_time_for_test(179.9)
	main_inst.wave_director.step(0.2, main_inst.player.global_position, main_inst.spatial_grid, main_inst.loot_manager)
	await process_frame
	_assert(main_inst.state == MainGame.GameState.SHOP and main_inst.shop_panel.visible and main_inst.shop_manager.shop_index == 1, "Deterministic Caravan Shop #1 opened at t=03:00 (180s)")
	_assert(main_inst.shop_manager.template_offers.size() == 3 and main_inst.shop_manager.addon_offers.size() == 4 and main_inst.shop_manager.relic_offers.size() == 2, "Shop #1 stocked 3 Templates, 4 Add-ons, and 2 Unowned Relics")
	main_inst.stats.add_gold(300)
	_assert(main_inst.shop_panel.buy_relic_slot(0), "Bought Relic #0 from Caravan Shop")
	_assert(main_inst.shop_panel.buy_template_slot(0), "Bought Template Card #0 from Caravan Shop")
	_assert(main_inst.shop_panel.reroll_clicked(), "Reroll refreshed Caravan Shop stock")
	main_inst._close_shop()
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst.shop_panel.visible, "Shop closes cleanly back to PLAYING")

	# Forge Animation Overlay & Deck UI sanity + mobile tab never uses 'Tpl'
	main_inst._seed_review_loot()
	main_inst._open_inventory()
	await process_frame
	_assert(main_inst.inventory_panel._m_tab_tpl_btn.text.begins_with("Templates"), "Mobile Deck tab spells out 'Templates' instead of 'Tpl'")
	main_inst.inventory_panel.start_forge_addon_at(0)
	_assert(main_inst.inventory_panel.confirm_forge_onto_equipped(0, true), "Animated Forge executed cleanly")
	_assert(main_inst.inventory_panel._forge_anim.visible, "ForgeAnimationOverlay visibly active during animated forge")
	main_inst.inventory_panel._forge_anim._finish()
	_assert(not main_inst.inventory_panel._forge_anim.visible, "ForgeAnimationOverlay finishes cleanly back to Deck UI")
	main_inst._close_inventory()
	await process_frame

	# 3-Boss gauntlet + Gold drops + Minimap sync
	var boss_times: Array[float] = [390.5, 780.5, 1170.5]
	for idx in range(boss_times.size()):
		main_inst.wave_director.jump_to_time_for_test(boss_times[idx])
		await process_frame
		var b: EnemyEntity = main_inst.wave_director.active_boss
		_assert(b != null and is_instance_valid(b) and b.boss_index == idx + 1, "Boss %d/3 spawned at t=%.1fs" % [idx + 1, boss_times[idx]])
		var pickups_before: int = main_inst.loot_manager.pickups.size()
		b.take_damage(999999.0, Vector3.ZERO, false)
		await process_frame
		_assert(main_inst.wave_director.bosses_defeated_count == idx + 1, "Boss %d/3 defeat recorded" % [idx + 1])
		_assert(main_inst.loot_manager.pickups.size() > pickups_before, "Boss %d/3 dropped Gold Pouches" % [idx + 1])

	main_inst.hud._minimap.update_entities(main_inst.player.global_position, main_inst.player.get_facing_dir(), main_inst.wave_director.enemies, main_inst.loot_manager.pickups, ArenaBuilder.ARENA_HALF_SIZE)
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
