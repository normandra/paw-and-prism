class_name ShopPanel
extends ResponsiveModal

signal shop_closed()
signal open_deck_requested()
signal purchased(kind: String, item_name: String)
signal sfx_requested(sfx_name: String)

var shop_mgr: ShopManager = null
var stats: HeroStats = null
var _elapsed_sec: float = 0.0
var _honey_heal_amt: float = 0.0
var _tutorial_hint: String = ""

var _hdr_box: BoxContainer = null
var _hdr_title_row: HBoxContainer = null
var _hdr_actions_row: HBoxContainer = null
var _sub_box: BoxContainer = null
var _stall_ic: TextureRect = null
var _title_lbl: Label = null
var _gold_lbl: Label = null
var _heal_pill: PanelContainer = null
var _hint_lbl: Label = null
var _reroll_btn: Button = null
var _deck_btn: Button = null
var _continue_btn: Button = null
var _shelves_vbox: VBoxContainer = null
var _is_refreshing: bool = false

func _init() -> void:
	name = "ShopPanel"
	max_modal_size = Vector2(1100.0, 690.0)
	compact_breakpoint = 780.0
	fill_height_when_compact = true
	compact_margin = 8
	wide_margin = 18
	modal_bg_color = UiHelper.BG_WOOD_DEEP
	modal_border_color = UiHelper.BORDER_GOLD
	modal_radius = 16
	modal_border_w = 3
	modal_pad = 14

func _build_modal_content(root_v: VBoxContainer) -> void:
	root_v.add_theme_constant_override("separation", 8)

	# === Header (Horizontal on Desktop, Stacked 2-Row on Compact/Mobile) ===
	_hdr_box = BoxContainer.new()
	_hdr_box.name = "ShopHeaderBox"
	_hdr_box.vertical = false
	_hdr_box.add_theme_constant_override("separation", 8)
	root_v.add_child(_hdr_box)

	_hdr_title_row = HBoxContainer.new()
	_hdr_title_row.name = "ShopTitleRow"
	_hdr_title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hdr_title_row.add_theme_constant_override("separation", 8)
	_hdr_box.add_child(_hdr_title_row)

	_stall_ic = TextureRect.new()
	_stall_ic.texture = UiIcons.get_ui_icon("shop_stall")
	_stall_ic.custom_minimum_size = Vector2(32, 32)
	_stall_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stall_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hdr_title_row.add_child(_stall_ic)

	_title_lbl = Label.new()
	_title_lbl.text = "Meadow Caravan Shop"
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.clip_text = true
	UiHelper.apply_display_font(_title_lbl, 22, UiHelper.BORDER_GOLD.lightened(0.25), 3)
	_hdr_title_row.add_child(_title_lbl)

	var gold_box: PanelContainer = PanelContainer.new()
	gold_box.name = "ShopGoldBox"
	gold_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	gold_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.22, 0.16, 0.07, 0.96), UiHelper.BORDER_GOLD, 12, 2, 7))
	_hdr_title_row.add_child(gold_box)
	var gold_h: HBoxContainer = HBoxContainer.new()
	gold_h.add_theme_constant_override("separation", 5)
	gold_box.add_child(gold_h)
	var g_ic: TextureRect = TextureRect.new()
	g_ic.texture = UiIcons.get_ui_icon("gold_coin")
	g_ic.custom_minimum_size = Vector2(20, 20)
	g_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gold_h.add_child(g_ic)
	_gold_lbl = Label.new()
	_gold_lbl.text = "0 G"
	UiHelper.apply_display_font(_gold_lbl, 17, Color(1.0, 0.90, 0.36), 2)
	gold_h.add_child(_gold_lbl)

	_hdr_actions_row = HBoxContainer.new()
	_hdr_actions_row.name = "ShopActionsRow"
	_hdr_actions_row.add_theme_constant_override("separation", 6)
	_hdr_box.add_child(_hdr_actions_row)

	_reroll_btn = Button.new()
	_reroll_btn.name = "RerollBtn"
	_reroll_btn.text = "Reroll (20G)"
	_reroll_btn.custom_minimum_size = Vector2(0, 38)
	_reroll_btn.clip_text = true
	_reroll_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_reroll_btn, UiHelper.CTA_SAPPHIRE, UiHelper.CTA_SAPPHIRE_RIM, 10, 6)
	_reroll_btn.add_theme_font_size_override("font_size", 13)
	_reroll_btn.pressed.connect(func() -> void: reroll_clicked())
	_hdr_actions_row.add_child(_reroll_btn)

	_deck_btn = Button.new()
	_deck_btn.name = "DeckForgeBtn"
	_deck_btn.text = "Deck & Forge"
	_deck_btn.custom_minimum_size = Vector2(0, 38)
	_deck_btn.clip_text = true
	_deck_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_deck_btn, Color(0.42, 0.28, 0.11), UiHelper.BORDER_GOLD, 10, 6)
	_deck_btn.add_theme_font_size_override("font_size", 13)
	_deck_btn.pressed.connect(func() -> void:
		sfx_requested.emit("ui_click")
		open_deck_requested.emit()
	)
	_hdr_actions_row.add_child(_deck_btn)

	_continue_btn = Button.new()
	_continue_btn.name = "ContinueRunBtn"
	_continue_btn.text = "Continue Run"
	_continue_btn.custom_minimum_size = Vector2(0, 38)
	_continue_btn.clip_text = true
	_continue_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_continue_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10, 6)
	_continue_btn.add_theme_font_size_override("font_size", 13)
	_continue_btn.pressed.connect(func() -> void: _close_shop())
	_hdr_actions_row.add_child(_continue_btn)

	# Sub-status / Tutorial hint
	_sub_box = BoxContainer.new()
	_sub_box.vertical = false
	_sub_box.add_theme_constant_override("separation", 8)
	root_v.add_child(_sub_box)

	_hint_lbl = Label.new()
	_hint_lbl.text = "Spend Gold on Template Cards, Add-on Cards, and Relics."
	_hint_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_lbl.add_theme_font_size_override("font_size", 12)
	_hint_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	_sub_box.add_child(_hint_lbl)

	_heal_pill = UiHelper.make_badge_pill("+25 HP Honey Jar", Color(0.16, 0.34, 0.18), UiHelper.CTA_EMERALD_RIM, Color(0.75, 1.0, 0.78), 11)
	_heal_pill.visible = false
	_sub_box.add_child(_heal_pill)

	var scroll: TouchScrollContainer = TouchScrollContainer.new()
	scroll.name = "ShopScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_child(scroll)

	_shelves_vbox = VBoxContainer.new()
	_shelves_vbox.name = "ShopShelves"
	_shelves_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(_shelves_vbox)

func _on_responsive_layout(_vp_size: Vector2, _is_compact: bool) -> void:
	if visible and shop_mgr != null and stats != null and not _is_refreshing:
		refresh()

func open_shop(p_mgr: ShopManager, p_stats: HeroStats, p_elapsed_sec: float, heal_amt: float = 0.0, tutorial_hint: String = "") -> void:
	shop_mgr = p_mgr
	stats = p_stats
	_elapsed_sec = p_elapsed_sec
	_honey_heal_amt = heal_amt
	_tutorial_hint = tutorial_hint
	visible = true
	_sync_modal_bounds()
	refresh()

func refresh() -> void:
	if shop_mgr == null or stats == null or _shelves_vbox == null:
		return
	if _is_refreshing:
		return
	_is_refreshing = true

	var vp_size: Vector2 = get_safe_viewport_size()
	var is_compact: bool = vp_size.x < compact_breakpoint
	var is_narrow: bool = vp_size.x < 620.0

	_apply_header_mode(vp_size, is_compact, is_narrow)

	if shop_mgr.shop_index > 0:
		if is_narrow:
			_title_lbl.text = "Shop #%d (%02d:00)" % [shop_mgr.shop_index, shop_mgr.shop_index * 3]
		else:
			_title_lbl.text = "Meadow Caravan Shop #%d (%02d:00)" % [shop_mgr.shop_index, shop_mgr.shop_index * 3]
	else:
		_title_lbl.text = "Tutorial Shop" if is_narrow else "Meadow Caravan Shop (Tutorial)"

	_gold_lbl.text = "%d G" % stats.gold

	var r_cost: int = shop_mgr.get_reroll_cost(stats)
	_reroll_btn.text = ("Reroll %dG" % r_cost) if is_narrow else ("Reroll (%dG)" % r_cost)
	_reroll_btn.disabled = stats.gold < r_cost
	_deck_btn.text = "Deck" if is_narrow else "Deck & Forge"
	_continue_btn.text = "Continue" if is_compact else "Continue Run [Space]"

	_heal_pill.visible = _honey_heal_amt > 0.0
	if not _tutorial_hint.is_empty():
		_hint_lbl.text = _tutorial_hint
		_hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.42))
	else:
		var disc_str: String = "  ·  Bell: 20%% off!" if stats.shop_price_mult < 0.99 else ""
		_hint_lbl.text = "Buy Cards, Add-ons & Relics.%s" % disc_str if is_narrow else "Spend Gold on Template Cards, Add-on Cards, and Relics.%s" % disc_str
		_hint_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)

	for c in _shelves_vbox.get_children():
		_shelves_vbox.remove_child(c)
		c.queue_free()

	# === Shelf 1: Slay-the-Spire Relics ===
	var rel_hdr: Label = Label.new()
	rel_hdr.text = "Relics (Passive Artifacts)" if is_narrow else "Relics (Permanent Passive Artifacts)"
	rel_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rel_hdr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiHelper.apply_display_font(rel_hdr, 14 if is_narrow else 16, Color(0.95, 0.80, 1.0), 2)
	_shelves_vbox.add_child(rel_hdr)

	var rel_grid: GridContainer = GridContainer.new()
	rel_grid.columns = 1 if vp_size.x < 760.0 else 2
	rel_grid.add_theme_constant_override("h_separation", 10)
	rel_grid.add_theme_constant_override("v_separation", 10)
	rel_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(rel_grid)

	if shop_mgr.relic_offers.is_empty():
		var all_owned: Label = Label.new()
		all_owned.text = "All Meadow Relics collected!"
		all_owned.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		all_owned.add_theme_color_override("font_color", Color(0.75, 0.72, 0.65))
		_shelves_vbox.add_child(all_owned)
	else:
		for i in range(shop_mgr.relic_offers.size()):
			var offer: Dictionary = shop_mgr.relic_offers[i]
			rel_grid.add_child(_build_relic_offer_card(i, offer, is_narrow))

	# === Shelf 2: Template Cards ===
	var tpl_hdr: Label = Label.new()
	tpl_hdr.text = "Template Cards (Main Abilities)" if is_narrow else "Template Cards (Equippable Main Abilities)"
	tpl_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tpl_hdr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiHelper.apply_display_font(tpl_hdr, 14 if is_narrow else 16, UiHelper.BORDER_GOLD.lightened(0.25), 2)
	_shelves_vbox.add_child(tpl_hdr)

	var tpl_cols: int = 1 if is_narrow else (2 if vp_size.x < 940.0 else mini(3, maxi(1, shop_mgr.template_offers.size())))
	var tpl_grid: GridContainer = GridContainer.new()
	tpl_grid.columns = tpl_cols
	tpl_grid.add_theme_constant_override("h_separation", 10)
	tpl_grid.add_theme_constant_override("v_separation", 10)
	tpl_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(tpl_grid)

	for i in range(shop_mgr.template_offers.size()):
		var offer: Dictionary = shop_mgr.template_offers[i]
		tpl_grid.add_child(_build_card_offer_widget(i, offer, true, is_compact, is_narrow))

	# === Shelf 3: Add-on Cards ===
	var add_hdr: Label = Label.new()
	add_hdr.text = "Add-on Cards (Forge Upgrades)" if is_narrow else "Add-on Cards (Consumed When Forged Into Compatible Template Cards)"
	add_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_hdr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiHelper.apply_display_font(add_hdr, 14 if is_narrow else 16, Color(0.62, 0.90, 1.0), 2)
	_shelves_vbox.add_child(add_hdr)

	var add_cols: int = 1 if is_narrow else 2
	var add_grid: GridContainer = GridContainer.new()
	add_grid.columns = add_cols
	add_grid.add_theme_constant_override("h_separation", 10)
	add_grid.add_theme_constant_override("v_separation", 10)
	add_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(add_grid)

	for i in range(shop_mgr.addon_offers.size()):
		var offer: Dictionary = shop_mgr.addon_offers[i]
		add_grid.add_child(_build_card_offer_widget(i, offer, false, is_compact, is_narrow))

	_is_refreshing = false

func _apply_header_mode(_vp_size: Vector2, is_compact: bool, is_narrow: bool) -> void:
	if _hdr_box != null:
		_hdr_box.vertical = is_compact
	if _sub_box != null:
		_sub_box.vertical = is_narrow
	if _stall_ic != null:
		var ic_sz: int = 24 if is_narrow else 32
		_stall_ic.custom_minimum_size = Vector2(ic_sz, ic_sz)
	if _title_lbl != null:
		_title_lbl.add_theme_font_size_override("font_size", 16 if is_narrow else (18 if is_compact else 22))
	if _gold_lbl != null:
		_gold_lbl.add_theme_font_size_override("font_size", 15 if is_narrow else 17)
	if _hdr_actions_row != null:
		_hdr_actions_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL if is_compact else Control.SIZE_SHRINK_END
	var h_btn: int = 36 if is_narrow else 40
	var btn_widths: Array = [
		[_reroll_btn, 0 if is_compact else 128],
		[_deck_btn, 0 if is_compact else 128],
		[_continue_btn, 0 if is_compact else 172],
	]
	for entry in btn_widths:
		var b: Button = entry[0]
		if b != null:
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL if is_compact else Control.SIZE_SHRINK_END
			b.custom_minimum_size = Vector2(int(entry[1]), h_btn)
			b.add_theme_font_size_override("font_size", 12 if is_narrow else 13)

func _build_relic_offer_card(idx: int, offer: Dictionary, is_narrow: bool) -> Control:
	var rid: String = String(offer["relic_id"])
	var rdef: Dictionary = offer["def"]
	var rar: int = int(rdef.get("rarity", GameEnums.Rarity.UNCOMMON))
	var r_col: Color = GameEnums.rarity_color(rar)
	var sold: bool = bool(offer.get("sold", false))
	var price: int = shop_mgr.get_effective_price(int(offer["base_price"]), stats)

	var box: PanelContainer = PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.15, 0.12, 0.20, 0.96), r_col, 12, 2, 10))
	if sold:
		box.modulate = Color(0.55, 0.52, 0.50, 0.72)

	var body: BoxContainer = BoxContainer.new()
	body.vertical = is_narrow
	body.add_theme_constant_override("separation", 8 if is_narrow else 10)
	box.add_child(body)

	var main_h: HBoxContainer = HBoxContainer.new()
	main_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_h.add_theme_constant_override("separation", 10)
	body.add_child(main_h)

	var art_frame: PanelContainer = PanelContainer.new()
	art_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	art_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, r_col.darkened(0.2), 8, 2, 4, false))
	main_h.add_child(art_frame)
	var ic: TextureRect = TextureRect.new()
	ic.texture = UiIcons.get_relic_art(rid)
	ic.custom_minimum_size = Vector2(54, 42) if is_narrow else Vector2(72, 54)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_frame.add_child(ic)

	var info_v: VBoxContainer = VBoxContainer.new()
	info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_v.add_theme_constant_override("separation", 4)
	main_h.add_child(info_v)

	var top_r: HBoxContainer = HBoxContainer.new()
	top_r.add_theme_constant_override("separation", 6)
	info_v.add_child(top_r)
	top_r.add_child(UiHelper.make_badge_pill(GameEnums.rarity_label(rar), Color(0.20, 0.14, 0.28), r_col, r_col.lightened(0.35), 10))
	var n_lbl: Label = Label.new()
	n_lbl.text = String(rdef.get("name", rid))
	n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n_lbl.clip_text = true
	UiHelper.apply_display_font(n_lbl, 14 if is_narrow else 15, r_col.lightened(0.28), 2)
	top_r.add_child(n_lbl)

	var d_lbl: Label = Label.new()
	d_lbl.text = String(rdef.get("desc", ""))
	d_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_lbl.add_theme_font_size_override("font_size", 12)
	d_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	if is_narrow:
		body.add_child(d_lbl)
	else:
		info_v.add_child(d_lbl)

	var buy_btn: Button = Button.new()
	buy_btn.custom_minimum_size = Vector2(0, 38) if is_narrow else Vector2(96, 42)
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL if is_narrow else Control.SIZE_SHRINK_END
	buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	buy_btn.clip_text = true
	buy_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if sold:
		buy_btn.text = "OWNED"
		buy_btn.disabled = true
		UiHelper.style_button(buy_btn, UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 8, 5)
		buy_btn.add_theme_font_size_override("font_size", 13)
	elif stats.gold < price:
		buy_btn.text = "%d G" % price
		buy_btn.disabled = true
		UiHelper.style_button(buy_btn, UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 8, 5)
		buy_btn.add_theme_font_size_override("font_size", 13)
	else:
		buy_btn.text = "Buy %dG" % price
		UiHelper.style_button(buy_btn, Color(0.50, 0.35, 0.09), UiHelper.BORDER_GOLD, 8, 5)
		buy_btn.add_theme_font_size_override("font_size", 13)
		buy_btn.pressed.connect(func() -> void: buy_relic_slot(idx))
	body.add_child(buy_btn)
	return box

func _build_card_offer_widget(idx: int, offer: Dictionary, is_tpl: bool, is_compact: bool, is_narrow: bool) -> CardWidget:
	var card: CardInstance = offer["card"]
	var sold: bool = bool(offer.get("sold", false))
	var price: int = shop_mgr.get_effective_price(int(offer["base_price"]), stats)

	var cw: CardWidget = CardWidget.new()
	cw.setup_card(card, {
		"deck_cd_mult": stats.deck_cd_mult,
		"relic_cd_mult": stats.relic_cd_mult,
		"crit_chance": stats.crit_chance,
		"crit_mult": stats.crit_mult,
		"bonus_forges": stats.bonus_forge_slots,
		"compact_mobile": is_compact,
		"sold": sold,
	})

	if not is_tpl and not sold:
		var fits_active: bool = false
		for eq in stats.equipped_cards:
			if eq != null and CardDatabase.does_addon_apply(card.card_id, eq.card_id):
				fits_active = true
				break
		if fits_active:
			var fit_txt: String = "Fits Deck" if is_narrow else "Fits Equipped Deck"
			var fit_pill: PanelContainer = UiHelper.make_badge_pill(fit_txt, Color(0.14, 0.30, 0.18), UiHelper.CTA_EMERALD_RIM, Color(0.75, 1.0, 0.78), 10)
			cw.action_row.add_child(fit_pill)

	var btn: Button = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 36)
	btn.clip_text = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if sold:
		btn.text = "SOLD (In Bag)"
		btn.disabled = true
		UiHelper.style_button(btn, UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 8, 5)
		btn.add_theme_font_size_override("font_size", 12)
	elif (is_tpl and not stats.can_add_template()) or (not is_tpl and not stats.can_add_addon()):
		btn.text = "Bag Full (%dG)" % price
		btn.disabled = true
		UiHelper.style_button(btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 5)
		btn.add_theme_font_size_override("font_size", 12)
	elif stats.gold < price:
		btn.text = "Need %d G" % price
		btn.disabled = true
		UiHelper.style_button(btn, UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 8, 5)
		btn.add_theme_font_size_override("font_size", 12)
	else:
		btn.text = "Buy · %d G" % price
		UiHelper.style_button(btn, Color(0.50, 0.35, 0.09), UiHelper.BORDER_GOLD, 8, 5)
		btn.add_theme_font_size_override("font_size", 13)
		if is_tpl:
			btn.pressed.connect(func() -> void: buy_template_slot(idx))
		else:
			btn.pressed.connect(func() -> void: buy_addon_slot(idx))
	cw.action_row.add_child(btn)
	return cw

func buy_template_slot(idx: int) -> bool:
	if shop_mgr == null or stats == null:
		return false
	var res: Dictionary = shop_mgr.buy_template(idx, stats)
	if bool(res.get("ok", false)):
		var card: CardInstance = res["card"]
		sfx_requested.emit("equip_snap")
		purchased.emit("template", card.get_display_title())
		refresh()
		return true
	return false

func buy_addon_slot(idx: int) -> bool:
	if shop_mgr == null or stats == null:
		return false
	var res: Dictionary = shop_mgr.buy_addon(idx, stats)
	if bool(res.get("ok", false)):
		var card: CardInstance = res["card"]
		sfx_requested.emit("socket_chime")
		purchased.emit("addon", card.get_card_name())
		refresh()
		return true
	return false

func buy_relic_slot(idx: int) -> bool:
	if shop_mgr == null or stats == null:
		return false
	var res: Dictionary = shop_mgr.buy_relic(idx, stats)
	if bool(res.get("ok", false)):
		sfx_requested.emit("loot_rare")
		purchased.emit("relic", String(res.get("name", "Relic")))
		refresh()
		return true
	return false

func reroll_clicked() -> bool:
	if shop_mgr == null or stats == null:
		return false
	if shop_mgr.reroll(stats, _elapsed_sec):
		sfx_requested.emit("ui_click")
		refresh()
		return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_close_shop()

func _close_shop() -> void:
	sfx_requested.emit("ui_click")
	visible = false
	shop_closed.emit()
