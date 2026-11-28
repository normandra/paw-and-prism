extends SceneTree

var _failures: Array[String] = []

const VIEWPORTS: Array[Dictionary] = [
	{"name": "narrow_phone_360x640", "size": Vector2i(360, 640), "mobile": true},
	{"name": "phone_se_465x828", "size": Vector2i(465, 828), "mobile": true},
	{"name": "phone_tall_465x1007", "size": Vector2i(465, 1007), "mobile": true},
	{"name": "tablet_656x875", "size": Vector2i(656, 875), "mobile": true},
	{"name": "mobile_land_1075x496", "size": Vector2i(1075, 496), "mobile": true},
	{"name": "desktop_1280x720", "size": Vector2i(1280, 720), "mobile": false},
]

func _record(violations: Array[String], tag: String) -> void:
	if violations.is_empty():
		print("OK: " + tag)
	else:
		for v in violations:
			_failures.append(tag + " -> " + v)
			push_error("LAYOUT FAIL [%s]: %s" % [tag, v])

func _initialize() -> void:
	call_deferred("_run_audit")

func _settle() -> void:
	await process_frame
	await process_frame
	await process_frame

func _run_audit() -> void:
	print("=== Paw & Prism Automated Multi-Viewport UI Layout Audit ===")

	var sub_vp: SubViewport = SubViewport.new()
	sub_vp.name = "AuditViewport"
	sub_vp.size = Vector2i(1280, 720)
	sub_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_vp.gui_embed_subwindows = true
	root.add_child(sub_vp)

	var packed: PackedScene = load("res://scenes/main.tscn")
	var main_inst: MainGame = packed.instantiate() as MainGame
	sub_vp.add_child(main_inst)
	await _settle()

	for vp_info in VIEWPORTS:
		var vname: String = String(vp_info["name"])
		var vsz: Vector2i = vp_info["size"]
		var is_mob: bool = bool(vp_info["mobile"])
		var vp_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(vsz))

		sub_vp.size = vsz
		main_inst._is_mobile_touch = is_mob
		main_inst._allow_mouse_touch = is_mob
		main_inst.title_screen.set_mobile_mode(is_mob)
		main_inst.hud.set_mobile_mode(is_mob, is_mob)
		await _settle()

		# 1. TitleScreen
		main_inst._enter_title_state()
		main_inst.title_screen.set_mobile_mode(is_mob)
		await _settle()
		var ts_overlaps: Array[Control] = [main_inst.title_screen._crest_panel, main_inst.title_screen._bot_panel]
		_record(UiLayoutGuard.audit_screen(main_inst.title_screen, vp_rect, vname + "/TitleScreen", ts_overlaps), vname + "/TitleScreen")

		# 2. HUD Normal Run + 5 Active Cards + 4 Relics + Boss Bar + Banner + Toasts
		main_inst.start_new_run("shiba")
		await _settle()
		for cid in ["starlight_orb", "meteor_pine", "whisker_lightning", "frost_nova"]:
			main_inst.stats.equipped_cards.append(CardInstance.new(cid, GameEnums.Rarity.RARE))
		for rid in ["relic_golden_acorn", "relic_merchant_bell", "relic_hourglass", "relic_honey_jar"]:
			main_inst.stats.add_relic(rid)
		main_inst.stats.recompute()
		main_inst.hud.rebuild_skill_bar(main_inst.stats)
		main_inst.wave_director.jump_to_time_for_test(390.5)
		main_inst.hud.show_banner("BOSS 1/3 DEFEATED: Sir Grizzle the Giant!", Color(1.0, 0.85, 0.30))
		main_inst.hud.push_toast("+22 Gold Pouch", Color(1.0, 0.88, 0.30), UiIcons.get_ui_icon("gold_coin"))
		main_inst.hud.push_toast("[Rare] Meteor Pinecone", Color(0.55, 0.85, 1.0), UiIcons.get_card_art("meteor_pine"))
		main_inst.hud._hud_throttle = 1.0
		main_inst.hud.update_hud(0.16, main_inst.stats, main_inst.player, main_inst.wave_director, main_inst.skill_executor, main_inst.loot_manager, main_inst.camera)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.hud, vp_rect, vname + "/HudNormal", main_inst.hud.get_overlap_audit_nodes()), vname + "/HudNormal")

		# 3. HUD Tutorial State
		main_inst.start_tutorial("shiba")
		await _settle()
		main_inst.hud._hud_throttle = 1.0
		main_inst.hud.update_hud(0.16, main_inst.stats, main_inst.player, main_inst.wave_director, main_inst.skill_executor, main_inst.loot_manager, main_inst.camera)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.hud, vp_rect, vname + "/HudTutorial", main_inst.hud.get_overlap_audit_nodes()), vname + "/HudTutorial")

		# 4. Caravan Shop #3 (Honey Jar Heal + Bell Discount + 3 Templates + 4 Add-ons + 2 Relics)
		main_inst.start_new_run("shiba")
		main_inst.stats.add_gold(240)
		main_inst.stats.add_relic("relic_honey_jar")
		main_inst.stats.add_relic("relic_merchant_bell")
		main_inst.wave_director.jump_to_time_for_test(540.0)
		main_inst._open_shop_ui(3, false)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.shop_panel, vp_rect, vname + "/ShopCaravan"), vname + "/ShopCaravan")

		# 5. Tutorial Shop
		main_inst._close_shop()
		main_inst.start_tutorial("shiba")
		main_inst.stats.add_gold(40)
		main_inst._open_shop_ui(0, true)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.shop_panel, vp_rect, vname + "/ShopTutorial"), vname + "/ShopTutorial")
		main_inst._close_shop()

		# 6. InventoryPanel (4/4 Forged Legendary + Forge Mode Banner + Tabs + Relics)
		main_inst.start_new_run("shiba")
		var leg: CardInstance = CardInstance.new("acorn_barrage", GameEnums.Rarity.LEGENDARY)
		leg.apply_forge("addon_multishot")
		leg.apply_forge("addon_chain")
		leg.apply_forge("addon_leech")
		leg.apply_forge("addon_echo")
		main_inst.stats.equipped_cards = [leg, CardInstance.new("starlight_orb", GameEnums.Rarity.RARE)]
		main_inst.stats.template_inventory.append(CardInstance.new("meteor_pine", GameEnums.Rarity.RARE))
		main_inst.stats.addon_inventory.append(CardInstance.new("addon_pierce", GameEnums.Rarity.COMMON))
		main_inst.stats.addon_inventory.append(CardInstance.new("addon_ignite", GameEnums.Rarity.COMMON))
		main_inst.stats.add_relic("relic_golden_acorn")
		main_inst.stats.add_relic("relic_hourglass")
		main_inst.stats.add_relic("relic_forge_hammer")
		main_inst.stats.add_relic("relic_mirror_shard")
		main_inst.stats.recompute()
		main_inst._open_inventory()
		main_inst.inventory_panel.start_forge_addon_at(0)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.inventory_panel, vp_rect, vname + "/InventoryActiveForge"), vname + "/InventoryActiveForge")
		main_inst.inventory_panel.cancel_forge()
		main_inst.inventory_panel._mobile_tab = "templates"
		main_inst.inventory_panel.refresh()
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.inventory_panel, vp_rect, vname + "/InventoryTemplates"), vname + "/InventoryTemplates")

		# 7. ForgeAnimationOverlay (at start t=0.0, mid t=0.25, impact t=0.60)
		main_inst.inventory_panel.start_forge_addon_at(0)
		main_inst.inventory_panel.confirm_forge_onto_equipped(1, true)
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.inventory_panel._forge_anim, vp_rect, vname + "/ForgeAnimStart"), vname + "/ForgeAnimStart")
		main_inst.inventory_panel._forge_anim._process(0.25)
		await process_frame
		_record(UiLayoutGuard.audit_screen(main_inst.inventory_panel._forge_anim, vp_rect, vname + "/ForgeAnimMid"), vname + "/ForgeAnimMid")
		main_inst.inventory_panel._forge_anim._process(0.35)
		await process_frame
		_record(UiLayoutGuard.audit_screen(main_inst.inventory_panel._forge_anim, vp_rect, vname + "/ForgeAnimImpact"), vname + "/ForgeAnimImpact")
		main_inst.inventory_panel._forge_anim._finish()
		main_inst._close_inventory()

		# 8. EndScreen (Victory + Forged Cards + Relics)
		main_inst._on_victory()
		await _settle()
		_record(UiLayoutGuard.audit_screen(main_inst.end_screen, vp_rect, vname + "/EndVictory"), vname + "/EndVictory")
		main_inst.end_screen.visible = false

	main_inst.queue_free()
	sub_vp.queue_free()
	await _settle()

	if _failures.is_empty():
		print("=== ALL MULTI-VIEWPORT UI LAYOUT AUDITS PASSED ===")
		quit(0)
	else:
		print("=== UI LAYOUT AUDIT FAILED (%d violations) ===" % _failures.size())
		quit(1)
