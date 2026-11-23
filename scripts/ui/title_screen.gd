class_name TitleScreen
extends Control

signal hero_selected(hero_id: String)
signal start_requested(hero_id: String)

var selected_hero_id: String = "shiba"
var _is_mobile_mode: bool = false
var _hero_cards: Dictionary = {}
var _detail_label: RichTextLabel = null
var _detail_portrait: TextureRect = null
var _crest_panel: PanelContainer = null
var _bot_panel: PanelContainer = null
var _cards_grid: GridContainer = null
var _bottom_box: BoxContainer = null
var _start_btn: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_select_hero("shiba")
	_apply_responsive_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _bot_panel != null:
		_apply_responsive_layout()

func set_mobile_mode(is_mobile: bool) -> void:
	_is_mobile_mode = is_mobile
	_select_hero(selected_hero_id)
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 10.0:
		return
	var is_portrait: bool = vp.x < 960.0
	if _crest_panel != null:
		_crest_panel.custom_minimum_size = Vector2(minf(vp.x - 32.0, 650.0) if is_portrait else 650.0, 94.0)
	if _cards_grid != null:
		_cards_grid.columns = 2 if is_portrait else 4
	if _bottom_box != null:
		_bottom_box.vertical = is_portrait
	if _bot_panel != null:
		if is_portrait:
			_bot_panel.offset_left = 16
			_bot_panel.offset_top = -468
			_bot_panel.offset_right = -16
			_bot_panel.offset_bottom = -16
		else:
			_bot_panel.offset_left = 30
			_bot_panel.offset_top = -256
			_bot_panel.offset_right = -30
			_bot_panel.offset_bottom = -14
	if _start_btn != null:
		if is_portrait:
			_start_btn.custom_minimum_size = Vector2(0, 66)
			_start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			_start_btn.custom_minimum_size = Vector2(268, 64)
			_start_btn.size_flags_horizontal = Control.SIZE_SHRINK_END

func _build_ui() -> void:
	# === Top Storybook Title Crest ===
	var top_center: CenterContainer = CenterContainer.new()
	top_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_center.offset_top = 16
	top_center.offset_bottom = 122
	top_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_center)

	_crest_panel = PanelContainer.new()
	_crest_panel.custom_minimum_size = Vector2(650, 94)
	_crest_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 18, 3, 12))
	top_center.add_child(_crest_panel)

	var crest_v: VBoxContainer = VBoxContainer.new()
	crest_v.alignment = BoxContainer.ALIGNMENT_CENTER
	crest_v.add_theme_constant_override("separation", 5)
	_crest_panel.add_child(crest_v)

	var title_h: HBoxContainer = HBoxContainer.new()
	title_h.alignment = BoxContainer.ALIGNMENT_CENTER
	title_h.add_theme_constant_override("separation", 14)
	crest_v.add_child(title_h)

	title_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 26))
	title_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 44))

	var title_lbl: Label = Label.new()
	title_lbl.text = "PAW & PRISM"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(title_lbl, 44, Color(1.0, 0.90, 0.42), 6)
	title_h.add_child(title_lbl)

	title_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 26))

	var sub_center: CenterContainer = CenterContainer.new()
	crest_v.add_child(sub_center)
	sub_center.add_child(UiHelper.make_badge_pill(
		"3D Chibi ARPG  ·  Loot Gear  ·  Link Prism Gems  ·  3 Bosses",
		UiHelper.BG_WALNUT,
		UiHelper.BORDER_BRASS,
		UiHelper.TEXT_PARCHMENT,
		12
	))

	# === Bottom Hero Picker & Start Bar ===
	_bot_panel = PanelContainer.new()
	_bot_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 12))
	_bot_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bot_panel.offset_left = 30
	_bot_panel.offset_right = -30
	_bot_panel.offset_top = -256
	_bot_panel.offset_bottom = -14
	add_child(_bot_panel)

	var bot_vbox: VBoxContainer = VBoxContainer.new()
	bot_vbox.add_theme_constant_override("separation", 10)
	_bot_panel.add_child(bot_vbox)

	_cards_grid = GridContainer.new()
	_cards_grid.columns = 4
	_cards_grid.add_theme_constant_override("h_separation", 12)
	_cards_grid.add_theme_constant_override("v_separation", 10)
	_cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bot_vbox.add_child(_cards_grid)

	for hdef in HeroDatabase.get_all_heroes():
		var hid: String = String(hdef["id"])
		var card: PanelContainer = _build_hero_card(hdef)
		_cards_grid.add_child(card)
		_hero_cards[hid] = card

	_bottom_box = BoxContainer.new()
	_bottom_box.vertical = false
	_bottom_box.add_theme_constant_override("separation", 12)
	bot_vbox.add_child(_bottom_box)

	var info_well: PanelContainer = PanelContainer.new()
	info_well.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 10, 2, 9, false))
	_bottom_box.add_child(info_well)

	var info_h: HBoxContainer = HBoxContainer.new()
	info_h.add_theme_constant_override("separation", 12)
	info_well.add_child(info_h)

	_detail_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 52)
	info_h.add_child(_detail_portrait)

	_detail_label = RichTextLabel.new()
	_detail_label.bbcode_enabled = true
	_detail_label.fit_content = true
	_detail_label.scroll_active = false
	_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_label.add_theme_font_size_override("normal_font_size", 13)
	info_h.add_child(_detail_label)

	_start_btn = Button.new()
	_start_btn.text = ""
	_start_btn.custom_minimum_size = Vector2(268, 64)
	_start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_start_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 12, 10)
	_start_btn.pressed.connect(func() -> void: start_requested.emit(selected_hero_id))
	_bottom_box.add_child(_start_btn)

	var btn_center: CenterContainer = CenterContainer.new()
	btn_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_btn.add_child(btn_center)
	var btn_h: HBoxContainer = HBoxContainer.new()
	btn_h.add_theme_constant_override("separation", 10)
	btn_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_center.add_child(btn_h)
	btn_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 28))
	var cta_lbl: Label = Label.new()
	cta_lbl.text = "PLAY 20-MIN RUN"
	cta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(cta_lbl, 20, UiHelper.TEXT_CREAM, 3)
	btn_h.add_child(cta_lbl)

func _build_hero_card(hdef: Dictionary) -> PanelContainer:
	var hid: String = String(hdef["id"])
	var acc: Color = hdef["accent_color"]
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 124)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_select_hero(hid)
	)

	var cv: VBoxContainer = VBoxContainer.new()
	cv.add_theme_constant_override("separation", 5)
	cv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(cv)

	var top_h: HBoxContainer = HBoxContainer.new()
	top_h.add_theme_constant_override("separation", 10)
	top_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(top_h)

	top_h.add_child(UiHelper.make_icon_rect(UiIcons.get_hero_portrait(hid), 46))

	var name_v: VBoxContainer = VBoxContainer.new()
	name_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_v.add_theme_constant_override("separation", 3)
	name_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_h.add_child(name_v)

	var n_lbl: Label = Label.new()
	n_lbl.text = String(hdef["hero_name"])
	UiHelper.apply_display_font(n_lbl, 16, UiHelper.TEXT_CREAM, 2)
	n_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_v.add_child(n_lbl)

	var role_pill: PanelContainer = UiHelper.make_badge_pill(String(hdef["title"]), acc.darkened(0.60), acc, Color(1.0, 0.95, 0.85), 11)
	role_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_v.add_child(role_pill)

	var stat_h: HBoxContainer = HBoxContainer.new()
	stat_h.add_theme_constant_override("separation", 12)
	stat_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(stat_h)

	var hp_chip: HBoxContainer = HBoxContainer.new()
	hp_chip.add_theme_constant_override("separation", 4)
	hp_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_chip.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("heart"), 15))
	var hp_lbl: Label = Label.new()
	hp_lbl.text = "%d HP" % int(hdef["base_hp"])
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.add_theme_color_override("font_color", Color(1.0, 0.74, 0.78))
	hp_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_chip.add_child(hp_lbl)
	stat_h.add_child(hp_chip)

	var spd_chip: HBoxContainer = HBoxContainer.new()
	spd_chip.add_theme_constant_override("separation", 4)
	spd_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spd_chip.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("dash_paw"), 15))
	var spd_lbl: Label = Label.new()
	spd_lbl.text = "%.1f Spd" % float(hdef["base_speed"])
	spd_lbl.add_theme_font_size_override("font_size", 12)
	spd_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	spd_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spd_chip.add_child(spd_lbl)
	stat_h.add_child(spd_chip)

	var act_id: String = String(hdef["starter_active_gem"])
	var pas_id: String = String(hdef["starter_passive_gem"])
	var act_def: Dictionary = GemDatabase.get_def(act_id)
	var pas_def: Dictionary = GemDatabase.get_def(pas_id)

	var gems_v: VBoxContainer = VBoxContainer.new()
	gems_v.add_theme_constant_override("separation", 2)
	gems_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(gems_v)

	var act_h: HBoxContainer = HBoxContainer.new()
	act_h.add_theme_constant_override("separation", 6)
	act_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	act_h.add_child(UiHelper.make_icon_rect(UiIcons.get_skill_icon(act_id), 17))
	var act_l: Label = Label.new()
	act_l.text = String(act_def["gem_name"])
	act_l.add_theme_font_size_override("font_size", 12)
	act_l.add_theme_color_override("font_color", Color(0.76, 0.92, 1.0))
	act_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	act_h.add_child(act_l)
	gems_v.add_child(act_h)

	var pas_h: HBoxContainer = HBoxContainer.new()
	pas_h.add_theme_constant_override("separation", 6)
	pas_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pas_h.add_child(UiHelper.make_icon_rect(UiIcons.get_gem_icon(GameEnums.GemType.PASSIVE, int(pas_def["color"])), 17))
	var pas_l: Label = Label.new()
	pas_l.text = String(pas_def["gem_name"])
	pas_l.add_theme_font_size_override("font_size", 12)
	pas_l.add_theme_color_override("font_color", Color(0.74, 0.96, 0.78))
	pas_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pas_h.add_child(pas_l)
	gems_v.add_child(pas_h)

	return card

func _select_hero(hero_id: String) -> void:
	selected_hero_id = hero_id
	for hid in _hero_cards.keys():
		var card: PanelContainer = _hero_cards[hid]
		if hid == hero_id:
			card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_OAK_CARD, UiHelper.BORDER_GOLD, 12, 3, 9))
		else:
			card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 12, 2, 9))

	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	if _detail_portrait != null:
		_detail_portrait.texture = UiIcons.get_hero_portrait(hero_id)
	var act_name: String = String(GemDatabase.get_def(String(hdef["starter_active_gem"]))["gem_name"])
	var sup_name: String = String(GemDatabase.get_def(String(hdef["starter_support_gem"]))["gem_name"])
	var pas_name: String = String(GemDatabase.get_def(String(hdef["starter_passive_gem"]))["gem_name"])
	var controls_hint: String = (
		"Drag anywhere to Move   ·   Tap DASH to Hop-Dash   ·   Tap Gear & Gems for PoE Linking"
		if _is_mobile_mode
		else "[WASD / Arrows] Move   ·   [Space] Hop-Dash   ·   [Tab / I] Gear & PoE Gem Linking   ·   Bosses at 06:30, 13:00, 19:30"
	)
	_detail_label.text = "[b][color=#ffd966]%s[/color][/b] — %s\n[color=#a8e6cf]Starter Link:[/color] %s + %s   ·   [color=#b8d8ff]Passive Aura:[/color] %s\n[color=#cfc3af]%s[/color]" % [
		String(hdef["hero_name"]),
		String(hdef["desc"]),
		act_name,
		sup_name,
		pas_name,
		controls_hint,
	]
	hero_selected.emit(hero_id)
