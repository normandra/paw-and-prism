class_name TitleScreen
extends Control

signal hero_selected(hero_id: String)
signal start_requested(hero_id: String)
signal tutorial_requested(hero_id: String)

var selected_hero_id: String = "shiba"
var _is_mobile_mode: bool = false
var _hero_cards: Dictionary = {}
var _detail_label: RichTextLabel = null
var _detail_portrait: TextureRect = null
var _crest_panel: PanelContainer = null
var _bot_panel: PanelContainer = null
var _cards_grid: GridContainer = null
var _bottom_box: BoxContainer = null
var _cta_box: HBoxContainer = null
var _tutorial_btn: Button = null
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
		_crest_panel.custom_minimum_size = Vector2(minf(vp.x - 32.0, 620.0) if is_portrait else 620.0, 90.0)
	if _cards_grid != null:
		_cards_grid.columns = 2 if is_portrait else 4
	if _bottom_box != null:
		_bottom_box.vertical = is_portrait
	if _bot_panel != null:
		if is_portrait:
			_bot_panel.offset_left = 14
			_bot_panel.offset_top = -456
			_bot_panel.offset_right = -14
			_bot_panel.offset_bottom = -14
		else:
			_bot_panel.offset_left = 28
			_bot_panel.offset_top = -254
			_bot_panel.offset_right = -28
			_bot_panel.offset_bottom = -14
	if _cta_box != null and _tutorial_btn != null and _start_btn != null:
		if is_portrait:
			_cta_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_tutorial_btn.custom_minimum_size = Vector2(0, 58)
			_tutorial_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_start_btn.custom_minimum_size = Vector2(0, 58)
			_start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			_cta_box.size_flags_horizontal = Control.SIZE_SHRINK_END
			_tutorial_btn.custom_minimum_size = Vector2(158, 62)
			_tutorial_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
			_start_btn.custom_minimum_size = Vector2(215, 62)
			_start_btn.size_flags_horizontal = Control.SIZE_SHRINK_END

func _build_ui() -> void:
	# === Top Storybook Title Crest ===
	var top_center: CenterContainer = CenterContainer.new()
	top_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_center.offset_top = 16
	top_center.offset_bottom = 118
	top_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_center)

	_crest_panel = PanelContainer.new()
	_crest_panel.custom_minimum_size = Vector2(620, 90)
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
	title_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 42))

	var title_lbl: Label = Label.new()
	title_lbl.text = "PAW & PRISM"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(title_lbl, 42, Color(1.0, 0.90, 0.42), 6)
	title_h.add_child(title_lbl)

	title_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 26))

	var sub_center: CenterContainer = CenterContainer.new()
	crest_v.add_child(sub_center)
	sub_center.add_child(UiHelper.make_badge_pill(
		"Loot Relics  ·  Link Abilities  ·  3 Bosses",
		UiHelper.BG_WALNUT,
		UiHelper.BORDER_BRASS,
		UiHelper.TEXT_PARCHMENT,
		12
	))

	# === Bottom Hero Picker & Play / Tutorial Bar ===
	_bot_panel = PanelContainer.new()
	_bot_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 12))
	_bot_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bot_panel.offset_left = 28
	_bot_panel.offset_right = -28
	_bot_panel.offset_top = -254
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

	_detail_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 48)
	info_h.add_child(_detail_portrait)

	_detail_label = RichTextLabel.new()
	_detail_label.bbcode_enabled = true
	_detail_label.fit_content = true
	_detail_label.scroll_active = false
	_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_label.add_theme_font_size_override("normal_font_size", 13)
	info_h.add_child(_detail_label)

	_cta_box = HBoxContainer.new()
	_cta_box.add_theme_constant_override("separation", 10)
	_bottom_box.add_child(_cta_box)

	_tutorial_btn = Button.new()
	_tutorial_btn.text = ""
	_tutorial_btn.custom_minimum_size = Vector2(158, 62)
	_tutorial_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_tutorial_btn, Color(0.40, 0.27, 0.11), UiHelper.BORDER_GOLD, 12, 8)
	_tutorial_btn.pressed.connect(func() -> void: tutorial_requested.emit(selected_hero_id))
	_cta_box.add_child(_tutorial_btn)

	var tut_cc: CenterContainer = CenterContainer.new()
	tut_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tut_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_btn.add_child(tut_cc)
	var tut_h: HBoxContainer = HBoxContainer.new()
	tut_h.add_theme_constant_override("separation", 8)
	tut_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tut_cc.add_child(tut_h)
	tut_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 22))
	var tut_lbl: Label = Label.new()
	tut_lbl.text = "TUTORIAL"
	tut_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(tut_lbl, 18, Color(1.0, 0.90, 0.44), 3)
	tut_h.add_child(tut_lbl)

	_start_btn = Button.new()
	_start_btn.text = ""
	_start_btn.custom_minimum_size = Vector2(215, 62)
	_start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_start_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 12, 10)
	_start_btn.pressed.connect(func() -> void: start_requested.emit(selected_hero_id))
	_cta_box.add_child(_start_btn)

	var btn_center: CenterContainer = CenterContainer.new()
	btn_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_btn.add_child(btn_center)
	var btn_h: HBoxContainer = HBoxContainer.new()
	btn_h.add_theme_constant_override("separation", 9)
	btn_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_center.add_child(btn_h)
	btn_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 26))
	var cta_lbl: Label = Label.new()
	cta_lbl.text = "PLAY RUN"
	cta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(cta_lbl, 20, UiHelper.TEXT_CREAM, 3)
	btn_h.add_child(cta_lbl)

func _build_hero_card(hdef: Dictionary) -> PanelContainer:
	var hid: String = String(hdef["id"])
	var acc: Color = hdef["accent_color"]
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 122)
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

	top_h.add_child(UiHelper.make_icon_rect(UiIcons.get_hero_portrait(hid), 42))

	var name_v: VBoxContainer = VBoxContainer.new()
	name_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_v.add_theme_constant_override("separation", 3)
	name_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_h.add_child(name_v)

	var n_lbl: Label = Label.new()
	n_lbl.text = String(hdef["hero_name"])
	UiHelper.apply_display_font(n_lbl, 15, UiHelper.TEXT_CREAM, 2)
	n_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_v.add_child(n_lbl)

	var role_pill: PanelContainer = UiHelper.make_badge_pill(String(hdef["title"]), acc.darkened(0.60), acc, Color(1.0, 0.95, 0.85), 11)
	role_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_v.add_child(role_pill)

	# Starter Main Ability + Starter Behavioral Effect Chips (icon-first, zero walls of text)
	var main_id: String = String(hdef["starter_main_gem"])
	var main_def: Dictionary = GemDatabase.get_def(main_id)
	var eff_id: String = String(hdef["starter_effect_id"])

	var main_h: HBoxContainer = HBoxContainer.new()
	main_h.add_theme_constant_override("separation", 6)
	main_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(main_h)
	main_h.add_child(UiHelper.make_icon_rect(UiIcons.get_skill_icon(main_id), 18))
	var main_l: Label = Label.new()
	main_l.text = String(main_def["gem_name"])
	main_l.add_theme_font_override("font", UiHelper.get_bold_font())
	main_l.add_theme_font_size_override("font_size", 12)
	main_l.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0))
	main_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_h.add_child(main_l)

	var eff_chip: PanelContainer = UiHelper.make_effect_chip(eff_id, true)
	eff_chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cv.add_child(eff_chip)

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
	var controls_hint: String = (
		"Drag Move  ·  Tap DASH  ·  Bag to Equip & Link"
		if _is_mobile_mode
		else "[WASD] Move  ·  [Space] Dash  ·  [Tab] Satchel  ·  Bosses 06:30 / 13:00 / 19:30"
	)
	_detail_label.text = "[b][color=#ffd966]%s[/color][/b]  —  %s\n[color=#cfc3af]%s[/color]" % [
		String(hdef["hero_name"]),
		String(hdef["tagline"]),
		controls_hint,
	]
	hero_selected.emit(hero_id)
