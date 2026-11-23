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
	print("=== Paw & Prism Verification Suite ===")

	# 1. Load & instantiate main scene
	var packed: PackedScene = load("res://scenes/main.tscn")
	_assert(packed != null, "Main scene loads cleanly")
	var main_inst: MainGame = packed.instantiate() as MainGame
	_assert(main_inst != null, "MainGame instantiates cleanly")
	root.add_child(main_inst)
	await process_frame

	# 2. All 4 chibi hero rigs & gear swapping
	for hdef in HeroDatabase.get_all_heroes():
		var hid: String = String(hdef["id"])
		var rig: Node3D = ChibiMeshFactory.build_hero_rig(hid)
		_assert(rig != null and rig.get_node_or_null("BodyPivot/HeadPivot/HatMount") != null, "Hero rig built for " + hid)
		ChibiMeshFactory.update_hero_visual_gear(rig, "honey_hammer", "wizard_hat")
		var wmount: Node3D = rig.get_node_or_null("BodyPivot/WeaponMount")
		var hmount: Node3D = rig.get_node_or_null("BodyPivot/HeadPivot/HatMount")
		_assert(wmount != null and wmount.get_child_count() > 0, "Weapon visual swapped for " + hid)
		_assert(hmount != null and hmount.get_child_count() > 0, "Helmet visual swapped for " + hid)
		rig.queue_free()

	# 3. All 7 regular enemies + 3 bosses build 3D rigs cleanly
	for eid in EnemyDatabase.get_all_regular_ids():
		var erig: Node3D = ChibiMeshFactory.build_enemy_rig(eid, true)
		_assert(erig != null and erig.get_node_or_null("BodyPivot") != null, "Enemy rig built for " + eid)
		erig.queue_free()
	for bid in EnemyDatabase.get_all_boss_ids():
		var brig: Node3D = ChibiMeshFactory.build_enemy_rig(bid, false)
		_assert(brig != null and brig.get_node_or_null("BodyPivot") != null, "Boss rig built for " + bid)
		brig.queue_free()

	# 4. Diablo Item Generation, Comparison, Salvage & Prism Dust Crafting
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 12345
	for r in [GameEnums.Rarity.COMMON, GameEnums.Rarity.MAGIC, GameEnums.Rarity.RARE, GameEnums.Rarity.UNIQUE]:
		var it: ItemInstance = ItemDatabase.generate_item(10, r, 0.0, -1, rng)
		_assert(it != null and it.rarity == r and it.get_socket_count() >= 1, "Generated item rarity %d: %s" % [r, it.item_name])
		_assert(it.get_salvage_dust() >= 4, "Salvage dust valid for " + it.item_name)

	var weapon_a: ItemInstance = ItemDatabase.generate_item(5, GameEnums.Rarity.MAGIC, 0.0, GameEnums.EquipSlot.WEAPON, rng)
	var weapon_b: ItemInstance = ItemDatabase.generate_item(15, GameEnums.Rarity.RARE, 0.0, GameEnums.EquipSlot.WEAPON, rng)
	var diffs: Array[Dictionary] = UiHelper.compare_items(weapon_b, weapon_a)
	_assert(diffs.size() > 0, "Diablo item comparison returns stat diffs")

	weapon_a.setup_sockets([GameEnums.GemColor.RED, GameEnums.GemColor.BLUE], [false])
	var linked_ok: bool = weapon_a.add_link(rng)
	_assert(linked_ok and weapon_a.are_all_linked(), "Prism Dust Add Link connects sockets")
	var added_sock: bool = weapon_a.add_socket(rng)
	_assert(added_sock and weapon_a.get_socket_count() == 3, "Prism Dust Add Socket adds 3rd socket to Weapon")
	weapon_a.recolor_sockets(rng)
	_assert(weapon_a.socket_colors.size() == 3, "Recolor sockets preserves socket count")

	# 5. PoE Gem System (Active + Support Linking, Tag Matching, Passives, Prism Mastery, Gem XP, Equipment Swap)
	var test_stats: HeroStats = HeroStats.new("shiba")
	var test_wep: ItemInstance = ItemInstance.new()
	test_wep.equip_slot = GameEnums.EquipSlot.WEAPON
	test_wep.setup_sockets([GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE, GameEnums.GemColor.RED], [true, false, true])
	var g_acorn: GemInstance = GemInstance.new("acorn_barrage", 1)
	var g_gmp: GemInstance = GemInstance.new("sup_gmp", 1)
	var g_echo: GemInstance = GemInstance.new("sup_echo", 1) # NOT linked to socket 0-1 (link[1] is false!)
	test_wep.insert_gem(0, g_acorn)
	test_wep.insert_gem(1, g_gmp)
	test_wep.insert_gem(2, g_echo)
	test_stats.equipped[GameEnums.EquipSlot.WEAPON] = test_wep
	test_stats.recompute()

	var acorn_cfg: Dictionary = {}
	for c in test_stats.active_skill_configs:
		if int(c["uid"]) == g_acorn.uid:
			acorn_cfg = c
	_assert(not acorn_cfg.is_empty(), "Active Acorn Barrage compiled")
	_assert(int(acorn_cfg["projectiles"]) == 3, "Linked GMP adds +2 projectiles (total 3)")
	_assert(bool(acorn_cfg["echo"]) == false, "Unlinked Spell Echo does NOT apply across unlinked socket gap")

	# Now link socket 1-2 and verify Echo applies, AND test tag mismatch (GMP on Honey Slam)
	test_wep.links[1] = true
	test_stats.recompute()
	for c in test_stats.active_skill_configs:
		if int(c["uid"]) == g_acorn.uid:
			acorn_cfg = c
	_assert(bool(acorn_cfg["echo"]) == true, "Linked Spell Echo applies once link[1] is connected")
	_assert(not GemDatabase.does_support_apply("sup_gmp", "honey_slam"), "GMP does NOT apply to melee Honey Slam")

	# Test Passive Gems + Prismatic Mastery +1 Level
	var test_armor: ItemInstance = ItemInstance.new()
	test_armor.equip_slot = GameEnums.EquipSlot.ARMOR
	test_armor.setup_sockets([GameEnums.GemColor.RED, GameEnums.GemColor.WHITE], [false])
	test_stats.equipped[GameEnums.EquipSlot.ARMOR] = test_armor
	test_stats.recompute()
	var base_hp_before: float = test_stats.max_hp

	var g_vit: GemInstance = GemInstance.new("pas_vitality", 1)
	var g_prism: GemInstance = GemInstance.new("pas_prism_mastery", 1)
	test_armor.insert_gem(0, g_vit)
	test_stats.recompute()
	var hp_with_vit: float = test_stats.max_hp
	_assert(hp_with_vit > base_hp_before, "Passive gem pas_vitality increases Max HP (%.0f -> %.0f)" % [base_hp_before, hp_with_vit])

	test_armor.insert_gem(1, g_prism)
	test_stats.recompute()
	_assert(test_stats.max_hp > hp_with_vit, "Prismatic Mastery boosts Vitality passive gem level (+12 HP)")

	# Test Gem XP Leveling
	var dmg_lvl1: float = float(acorn_cfg["damage"])
	var leveled: bool = g_acorn.add_xp(1000.0)
	_assert(leveled and g_acorn.level >= 2, "Gem XP leveling increases gem level")
	test_stats.recompute()
	for c in test_stats.active_skill_configs:
		if int(c["uid"]) == g_acorn.uid:
			acorn_cfg = c
	_assert(float(acorn_cfg["damage"]) > dmg_lvl1, "Leveled active gem increases skill damage")

	# Test Equipment Swap preserves gems safely
	var new_tiny_wep: ItemInstance = ItemInstance.new()
	new_tiny_wep.equip_slot = GameEnums.EquipSlot.WEAPON
	new_tiny_wep.setup_sockets([GameEnums.GemColor.RED], [])
	test_stats.item_bag.append(new_tiny_wep)
	var pouch_before: int = test_stats.gem_pouch.size()
	test_stats.equip_item_from_bag(0)
	_assert(test_stats.gem_pouch.size() == pouch_before + 3, "Equipping smaller weapon safely returns all 3 non-fitting gems to gem_pouch")

	# 6. 20-Minute Run Director & Combat + UI + 3 Boss Encounters + Victory
	main_inst.start_new_run("shiba")
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING, "Game entered PLAYING state")

	# Step live combat for 20 frames + test Inventory & Level-Up UI paths
	for _f in range(20):
		main_inst._process(0.05)
		await process_frame

	main_inst._open_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.INVENTORY and main_inst.inventory_panel.visible, "InventoryPanel opens and pauses game")
	main_inst.inventory_panel._active_right_tab = "gems"
	main_inst.inventory_panel.refresh()
	main_inst._close_inventory()
	await process_frame
	_assert(main_inst.state == MainGame.GameState.PLAYING and not main_inst.inventory_panel.visible, "InventoryPanel closes and resumes game")

	main_inst.level_up_modal.open_for_level(2, main_inst.stats)
	await process_frame
	_assert(main_inst.level_up_modal.visible, "LevelUpModal displays upgrade cards")
	main_inst.level_up_modal._pick({"kind": "stat", "stat": GameEnums.StatType.DAMAGE_PCT, "val": 14.0})
	await process_frame
	_assert(not main_inst.level_up_modal.visible, "LevelUpModal closes cleanly after pick")

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
		_assert(main_inst.loot_manager.pickups.size() > pickups_before, "Boss %d/3 dropped Diablo loot fountain" % [idx + 1])

	_assert(main_inst.state == MainGame.GameState.ENDED, "Defeating Boss 3 transitions MainGame to ENDED (Victory)")

	# 7. Procedural SFX check
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
