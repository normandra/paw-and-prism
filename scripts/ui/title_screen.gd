class_name TitleScreen
extends Control

signal hero_selected(hero_id: String)
signal start_requested(hero_id: String)
signal tutorial_requested(hero_id: String)

var selected_hero_id: String = "shiba"
var _is_mobile_mode: bool = false
var _detail_label: RichTextLabel = null
var _hero_portrait: TextureRect = null
var _top_center: CenterContainer = null
var _crest_panel: PanelContainer = null
var _crest_title_lbl: Label = null
var _crest_sub_lbl: Label = null
var _crest_sub_pill: PanelContainer = null
var _crest_left_star: TextureRect = null
var _crest_right_star: TextureRect = null
var _crest_emblem: TextureRect = null
var _bot_panel: PanelContainer = null
var _bottom_box: BoxContainer = null
var _cta_box: HBoxContainer = null
var _tutorial_btn: Button = null
var _tut_lbl: Label = null
var _start_btn: Button = null
var _cta_lbl: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_refresh_summary()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _bot_panel != null:
		_apply_responsive_layout()

func set_mobile_mode(is_mobile: bool) -> void:
	_is_mobile_mode = is_mobile
	_refresh_summary()
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if (vp.x <= 10.0 or vp.y <= 10.0) and get_viewport() != null:
		vp = get_viewport().get_visible_rect().size
	if vp.x <= 10.0 or vp.y <= 10.0:
		return
	var is_portrait: bool = vp.x < 750.0
	var is_tiny: bool = vp.x < 430.0
	var is_short: bool = vp.y < 540.0

	if _top_center != null:
		_top_center.offset_top = 8 if (is_portrait or is_short) else 12
		_top_center.offset_left = 8
		_top_center.offset_right = -8
	if _crest_panel != null:
		_crest_panel.custom_minimum_size = Vector2(minf(vp.x - 16.0, 620.0), 66.0 if is_tiny else (74.0 if is_portrait else 90.0))
	if _crest_title_lbl != null:
		_crest_title_lbl.add_theme_font_size_override("font_size", 22 if is_tiny else (28 if is_portrait else 42))
	if _crest_emblem != null:
		var esz: int = 24 if is_tiny else (30 if is_portrait else 42)
		_crest_emblem.custom_minimum_size = Vector2(esz, esz)
	for star_n in [_crest_left_star, _crest_right_star]:
		if star_n != null:
			star_n.visible = vp.x >= 400.0
			var ssz: int = 18 if is_portrait else 26
			star_n.custom_minimum_size = Vector2(ssz, ssz)
	if _crest_sub_lbl != null:
		_crest_sub_lbl.text = "Gold · Shops · Card Forging" if vp.x < 480.0 else "Collect Gold  ·  Visit Caravan Shops  ·  Forge Combos"
		_crest_sub_lbl.add_theme_font_size_override("font_size", 11 if vp.x < 480.0 else 12)

	if _bottom_box != null:
		_bottom_box.vertical = is_portrait
	if _hero_portrait != null:
		var psz: int = 40 if is_tiny else 52
		_hero_portrait.custom_minimum_size = Vector2(psz, psz)

	if _bot_panel != null:
		var side_pad: float = 10.0 if is_portrait else (24.0 if is_short else 36.0)
		var bot_pad: float = 10.0 if (is_portrait or is_short) else 16.0
		var bot_w: float = maxf(240.0, vp.x - side_pad * 2.0)
		_bot_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_bot_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
		_bot_panel.custom_minimum_size = Vector2(bot_w, 0.0)
		_bot_panel.offset_left = side_pad
		_bot_panel.offset_right = -side_pad
		_bot_panel.offset_top = 0.0
		_bot_panel.offset_bottom = -bot_pad
		_bot_panel.size = Vector2(bot_w, 0.0)

	if _cta_box != null and _tutorial_btn != null and _start_btn != null:
		if is_portrait:
			_cta_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_tutorial_btn.custom_minimum_size = Vector2(0, 48 if is_tiny else 54)
			_tutorial_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_start_btn.custom_minimum_size = Vector2(0, 48 if is_tiny else 54)
			_start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if _tut_lbl != null:
				_tut_lbl.add_theme_font_size_override("font_size", 15 if is_tiny else 17)
			if _cta_lbl != null:
				_cta_lbl.add_theme_font_size_override("font_size", 16 if is_tiny else 18)
		else:
			_cta_box.size_flags_horizontal = Control.SIZE_SHRINK_END
			_tutorial_btn.custom_minimum_size = Vector2(154, 54 if is_short else 62)
			_tutorial_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
			_start_btn.custom_minimum_size = Vector2(210, 54 if is_short else 62)
			_start_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
			if _tut_lbl != null:
				_tut_lbl.add_theme_font_size_override("font_size", 18)
			if _cta_lbl != null:
				_cta_lbl.add_theme_font_size_override("font_size", 20)

func _build_ui() -> void:
	# === Top Storybook Title Crest ===
	_top_center = CenterContainer.new()
	_top_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_center.offset_top = 12
	_top_center.offset_left = 8
	_top_center.offset_right = -8
	_top_center.offset_bottom = 114
	_top_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_top_center)

	_crest_panel = PanelContainer.new()
	_crest_panel.custom_minimum_size = Vector2(620, 90)
	_crest_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 18, 3, 10))
	_top_center.add_child(_crest_panel)

	var crest_v: VBoxContainer = VBoxContainer.new()
	crest_v.alignment = BoxContainer.ALIGNMENT_CENTER
	crest_v.add_theme_constant_override("separation", 4)
	_crest_panel.add_child(crest_v)

	var title_h: HBoxContainer = HBoxContainer.new()
	title_h.alignment = BoxContainer.ALIGNMENT_CENTER
	title_h.add_theme_constant_override("separation", 8)
	crest_v.add_child(title_h)

	_crest_left_star = UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 26)
	title_h.add_child(_crest_left_star)
	_crest_emblem = UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 42)
	title_h.add_child(_crest_emblem)

	_crest_title_lbl = Label.new()
	_crest_title_lbl.text = "PAW & PRISM"
	_crest_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_crest_title_lbl, 42, Color(1.0, 0.90, 0.42), 6)
	title_h.add_child(_crest_title_lbl)

	_crest_right_star = UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 26)
	title_h.add_child(_crest_right_star)

	var sub_center: CenterContainer = CenterContainer.new()
	crest_v.add_child(sub_center)
	_crest_sub_pill = UiHelper.make_badge_pill(
		"Collect Gold  ·  Visit Caravan Shops  ·  Forge Combos",
		UiHelper.BG_WALNUT,
		UiHelper.BORDER_BRASS,
		UiHelper.TEXT_PARCHMENT,
		12
	)
	_crest_sub_lbl = _crest_sub_pill.get_child(0) as Label
	sub_center.add_child(_crest_sub_pill)

	# === Bottom Hero Banner & Play / Tutorial Bar ===
	_bot_panel = PanelContainer.new()
	_bot_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 12))
	_bot_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bot_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_bot_panel.offset_left = 36
	_bot_panel.offset_right = -36
	_bot_panel.offset_top = 0
	_bot_panel.offset_bottom = -16
	add_child(_bot_panel)

	_bottom_box = BoxContainer.new()
	_bottom_box.vertical = false
	_bottom_box.add_theme_constant_override("separation", 10)
	_bot_panel.add_child(_bottom_box)

	var info_well: PanelContainer = PanelContainer.new()
	info_well.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 10, 2, 10, false))
	_bottom_box.add_child(info_well)

	var info_h: HBoxContainer = HBoxContainer.new()
	info_h.add_theme_constant_override("separation", 10)
	info_well.add_child(info_h)

	_hero_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 52)
	_hero_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info_h.add_child(_hero_portrait)

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
	_tutorial_btn.custom_minimum_size = Vector2(162, 62)
	_tutorial_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_tutorial_btn, Color(0.40, 0.27, 0.11), UiHelper.BORDER_GOLD, 12, 8)
	_tutorial_btn.pressed.connect(func() -> void: tutorial_requested.emit("shiba"))
	_cta_box.add_child(_tutorial_btn)

	var tut_cc: CenterContainer = CenterContainer.new()
	tut_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tut_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_btn.add_child(tut_cc)
	var tut_h: HBoxContainer = HBoxContainer.new()
	tut_h.add_theme_constant_override("separation", 6)
	tut_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tut_cc.add_child(tut_h)
	tut_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 18))
	_tut_lbl = Label.new()
	_tut_lbl.text = "TUTORIAL"
	_tut_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_tut_lbl, 18, Color(1.0, 0.90, 0.44), 3)
	tut_h.add_child(_tut_lbl)

	_start_btn = Button.new()
	_start_btn.text = ""
	_start_btn.custom_minimum_size = Vector2(220, 62)
	_start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_start_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 12, 10)
	_start_btn.pressed.connect(func() -> void: start_requested.emit("shiba"))
	_cta_box.add_child(_start_btn)

	var btn_center: CenterContainer = CenterContainer.new()
	btn_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_btn.add_child(btn_center)
	var btn_h: HBoxContainer = HBoxContainer.new()
	btn_h.add_theme_constant_override("separation", 6)
	btn_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_center.add_child(btn_h)
	btn_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 22))
	_cta_lbl = Label.new()
	_cta_lbl.text = "PLAY RUN"
	_cta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_cta_lbl, 20, UiHelper.TEXT_CREAM, 3)
	btn_h.add_child(_cta_lbl)

func _refresh_summary() -> void:
	if _detail_label == null:
		return
	var hdef: Dictionary = HeroDatabase.get_hero("shiba")
	var controls_hint: String = (
		"Drag to Move  ·  Caravan Shops every 3m (Gold, Cards, Relics)  ·  Tap Deck to Forge"
		if _is_mobile_mode
		else "[WASD] Move  ·  Caravan Shops every 3m  ·  [Tab] Deck & Forge  ·  Bosses 06:30 / 13:00 / 19:30"
	)
	_detail_label.text = "[b][color=#ffd966]%s[/color]  ·  %s[/b]\n[color=#e8dfd0]%s[/color]\n[color=#a9d6ff]Starter: Uncommon Acorn Barrage (0/2 Forges)[/color]  ·  [color=#cfc3af]%s[/color]" % [
		String(hdef["hero_name"]),
		String(hdef["title"]),
		String(hdef["tagline"]),
		controls_hint,
	]
	hero_selected.emit("shiba")
