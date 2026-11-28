class_name ShopPanel
extends Control

signal shop_closed()
signal open_deck_requested()
signal purchased(kind: String, item_name: String)
signal sfx_requested(sfx_name: String)

var shop_mgr: ShopManager = null
var stats: HeroStats = null
var _elapsed_sec: float = 0.0
var _honey_heal_amt: float = 0.0
var _tutorial_hint: String = ""

var _panel: PanelContainer = null
var _title_lbl: Label = null
var _gold_lbl: Label = null
var _heal_pill: PanelContainer = null
var _hint_lbl: Label = null
var _reroll_btn: Button = null
var _deck_btn: Button = null
var _continue_btn: Button = null
var _shelves_vbox: VBoxContainer = null

func _ready() -> void:
	name = "ShopPanel"
	process_mode = Control.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.04, 0.03, 0.03, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(1060, 650)
	_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 18, 3, 18))
	center.add_child(_panel)

	var root_v: VBoxContainer = VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	_panel.add_child(root_v)

	# === Header Bar ===
	var hdr: HBoxContainer = HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 10)
	root_v.add_child(hdr)

	var stall_ic: TextureRect = TextureRect.new()
	stall_ic.texture = UiIcons.get_ui_icon("shop_stall")
	stall_ic.custom_minimum_size = Vector2(36, 36)
	stall_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stall_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hdr.add_child(stall_ic)

	_title_lbl = Label.new()
	_title_lbl.text = "Meadow Caravan Shop"
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.apply_display_font(_title_lbl, 24, UiHelper.BORDER_GOLD.lightened(0.25), 3)
	hdr.add_child(_title_lbl)

	var gold_box: PanelContainer = PanelContainer.new()
	gold_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.22, 0.16, 0.07, 0.96), UiHelper.BORDER_GOLD, 12, 2, 8))
	hdr.add_child(gold_box)
	var gold_h: HBoxContainer = HBoxContainer.new()
	gold_h.add_theme_constant_override("separation", 6)
	gold_box.add_child(gold_h)
	var g_ic: TextureRect = TextureRect.new()
	g_ic.texture = UiIcons.get_ui_icon("gold_coin")
	g_ic.custom_minimum_size = Vector2(22, 22)
	g_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gold_h.add_child(g_ic)
	_gold_lbl = Label.new()
	_gold_lbl.text = "0 G"
	UiHelper.apply_display_font(_gold_lbl, 18, Color(1.0, 0.90, 0.36), 2)
	gold_h.add_child(_gold_lbl)

	_reroll_btn = Button.new()
	_reroll_btn.text = "Reroll (20G)"
	_reroll_btn.custom_minimum_size = Vector2(142, 42)
	_reroll_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_reroll_btn, UiHelper.CTA_SAPPHIRE, UiHelper.CTA_SAPPHIRE_RIM, 10, 6)
	_reroll_btn.add_theme_font_size_override("font_size", 14)
	_reroll_btn.pressed.connect(func() -> void: reroll_clicked())
	hdr.add_child(_reroll_btn)

	_deck_btn = Button.new()
	_deck_btn.text = "Deck & Forge"
	_deck_btn.custom_minimum_size = Vector2(142, 42)
	_deck_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_deck_btn, Color(0.42, 0.28, 0.11), UiHelper.BORDER_GOLD, 10, 6)
	_deck_btn.add_theme_font_size_override("font_size", 14)
	_deck_btn.pressed.connect(func() -> void:
		sfx_requested.emit("ui_click")
		open_deck_requested.emit()
	)
	hdr.add_child(_deck_btn)

	_continue_btn = Button.new()
	_continue_btn.text = "Continue Run [Space]"
	_continue_btn.custom_minimum_size = Vector2(180, 42)
	_continue_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_continue_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10, 6)
	_continue_btn.add_theme_font_size_override("font_size", 14)
	_continue_btn.pressed.connect(func() -> void: _close_shop())
	hdr.add_child(_continue_btn)

	# Sub-status / Tutorial hint
	var sub_h: HBoxContainer = HBoxContainer.new()
	sub_h.add_theme_constant_override("separation", 10)
	root_v.add_child(sub_h)

	_hint_lbl = Label.new()
	_hint_lbl.text = "Spend Gold on Template Cards, Add-on Cards, and Slay-the-Spire Relics. Open Deck & Forge to customize your build."
	_hint_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_lbl.add_theme_font_size_override("font_size", 13)
	_hint_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	sub_h.add_child(_hint_lbl)

	_heal_pill = UiHelper.make_badge_pill("+25 HP Honey Jar", Color(0.16, 0.34, 0.18), UiHelper.CTA_EMERALD_RIM, Color(0.75, 1.0, 0.78), 12)
	_heal_pill.visible = false
	sub_h.add_child(_heal_pill)

	var scroll: TouchScrollContainer = TouchScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_child(scroll)

	_shelves_vbox = VBoxContainer.new()
	_shelves_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(_shelves_vbox)

func open_shop(p_mgr: ShopManager, p_stats: HeroStats, p_elapsed_sec: float, heal_amt: float = 0.0, tutorial_hint: String = "") -> void:
	shop_mgr = p_mgr
	stats = p_stats
	_elapsed_sec = p_elapsed_sec
	_honey_heal_amt = heal_amt
	_tutorial_hint = tutorial_hint
	visible = true
	refresh()

func refresh() -> void:
	if shop_mgr == null or stats == null or _panel == null:
		return
	var vp_size: Vector2 = get_viewport_rect().size
	if vp_size.x <= 10.0 or vp_size.y <= 10.0:
		vp_size = Vector2(1280.0, 720.0)
	var is_compact: bool = vp_size.x < 720.0
	_panel.custom_minimum_size = Vector2(clampf(vp_size.x - 24.0, 340.0, 1120.0), clampf(vp_size.y - 28.0, 480.0, 700.0))

	if shop_mgr.shop_index > 0:
		_title_lbl.text = "Meadow Caravan Shop #%d (%02d:00)" % [shop_mgr.shop_index, shop_mgr.shop_index * 3]
	else:
		_title_lbl.text = "Meadow Caravan Shop (Tutorial)"

	_gold_lbl.text = "%d G" % stats.gold

	var r_cost: int = shop_mgr.get_reroll_cost(stats)
	_reroll_btn.text = "Reroll (%dG)" % r_cost
	_reroll_btn.disabled = stats.gold < r_cost

	_heal_pill.visible = _honey_heal_amt > 0.0
	if not _tutorial_hint.is_empty():
		_hint_lbl.text = _tutorial_hint
		_hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.42))
	else:
		var disc_str: String = "  ·  Merchant's Bell active: 20% off!" if stats.shop_price_mult < 0.99 else ""
		_hint_lbl.text = "Spend Gold on Template Cards, Add-on Cards, and Relics.%s" % disc_str
		_hint_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)

	for c in _shelves_vbox.get_children():
		c.queue_free()

	# === Shelf 1: Slay-the-Spire Relics ===
	var rel_hdr: Label = Label.new()
	rel_hdr.text = "Relics (Permanent Passive Artifacts)"
	UiHelper.apply_display_font(rel_hdr, 16, Color(0.95, 0.80, 1.0), 2)
	_shelves_vbox.add_child(rel_hdr)

	var rel_grid: GridContainer = GridContainer.new()
	rel_grid.columns = 1 if is_compact else 2
	rel_grid.add_theme_constant_override("h_separation", 10)
	rel_grid.add_theme_constant_override("v_separation", 10)
	rel_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(rel_grid)

	if shop_mgr.relic_offers.is_empty():
		var all_owned: Label = Label.new()
		all_owned.text = "All Meadow Relics collected!"
		all_owned.add_theme_color_override("font_color", Color(0.75, 0.72, 0.65))
		_shelves_vbox.add_child(all_owned)
	else:
		for i in range(shop_mgr.relic_offers.size()):
			var offer: Dictionary = shop_mgr.relic_offers[i]
			rel_grid.add_child(_build_relic_offer_card(i, offer))

	# === Shelf 2: Template Cards ===
	var tpl_hdr: Label = Label.new()
	tpl_hdr.text = "Template Cards (Equippable Main Abilities)"
	UiHelper.apply_display_font(tpl_hdr, 16, UiHelper.BORDER_GOLD.lightened(0.25), 2)
	_shelves_vbox.add_child(tpl_hdr)

	var tpl_cols: int = 1 if is_compact else mini(3, maxi(1, shop_mgr.template_offers.size()))
	var tpl_grid: GridContainer = GridContainer.new()
	tpl_grid.columns = tpl_cols
	tpl_grid.add_theme_constant_override("h_separation", 10)
	tpl_grid.add_theme_constant_override("v_separation", 10)
	tpl_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(tpl_grid)

	for i in range(shop_mgr.template_offers.size()):
		var offer: Dictionary = shop_mgr.template_offers[i]
		tpl_grid.add_child(_build_card_offer_widget(i, offer, true, is_compact))

	# === Shelf 3: Add-on Cards ===
	var add_hdr: Label = Label.new()
	add_hdr.text = "Add-on Cards (Consumed When Forged Into Compatible Template Cards)"
	UiHelper.apply_display_font(add_hdr, 16, Color(0.62, 0.90, 1.0), 2)
	_shelves_vbox.add_child(add_hdr)

	var add_cols: int = 1 if is_compact else 2
	var add_grid: GridContainer = GridContainer.new()
	add_grid.columns = add_cols
	add_grid.add_theme_constant_override("h_separation", 10)
	add_grid.add_theme_constant_override("v_separation", 10)
	add_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelves_vbox.add_child(add_grid)

	for i in range(shop_mgr.addon_offers.size()):
		var offer: Dictionary = shop_mgr.addon_offers[i]
		add_grid.add_child(_build_card_offer_widget(i, offer, false, is_compact))

func _build_relic_offer_card(idx: int, offer: Dictionary) -> Control:
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

	var h: HBoxContainer = HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	box.add_child(h)

	var art_frame: PanelContainer = PanelContainer.new()
	art_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, r_col.darkened(0.2), 8, 2, 4, false))
	h.add_child(art_frame)
	var ic: TextureRect = TextureRect.new()
	ic.texture = UiIcons.get_relic_art(rid)
	ic.custom_minimum_size = Vector2(72, 54)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_frame.add_child(ic)

	var info_v: VBoxContainer = VBoxContainer.new()
	info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_v.add_theme_constant_override("separation", 4)
	h.add_child(info_v)

	var top_r: HBoxContainer = HBoxContainer.new()
	top_r.add_theme_constant_override("separation", 6)
	info_v.add_child(top_r)
	top_r.add_child(UiHelper.make_badge_pill(GameEnums.rarity_label(rar), Color(0.20, 0.14, 0.28), r_col, r_col.lightened(0.35), 10))
	var n_lbl: Label = Label.new()
	n_lbl.text = String(rdef.get("name", rid))
	n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.apply_display_font(n_lbl, 15, r_col.lightened(0.28), 2)
	top_r.add_child(n_lbl)

	var d_lbl: Label = Label.new()
	d_lbl.text = String(rdef.get("desc", ""))
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_lbl.add_theme_font_size_override("font_size", 12)
	d_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	info_v.add_child(d_lbl)

	var buy_btn: Button = Button.new()
	buy_btn.custom_minimum_size = Vector2(102, 42)
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
	h.add_child(buy_btn)
	return box

func _build_card_offer_widget(idx: int, offer: Dictionary, is_tpl: bool, is_compact: bool) -> CardWidget:
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
			var fit_pill: PanelContainer = UiHelper.make_badge_pill("Fits Equipped Deck", Color(0.14, 0.30, 0.18), UiHelper.CTA_EMERALD_RIM, Color(0.75, 1.0, 0.78), 10)
			cw.action_row.add_child(fit_pill)

	var btn: Button = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 36)
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
