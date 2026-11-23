class_name HudController
extends Control

signal open_inventory_requested()
signal toggle_pause_requested()
signal toggle_mute_requested()

var _hero_portrait: TextureRect = null
var _timer_lbl: Label = null
var _phase_icon: TextureRect = null
var _phase_lbl: Label = null
var _next_boss_lbl: Label = null
var _fps_pill: PanelContainer = null
var _fps_lbl: Label = null
var _kills_lbl: Label = null
var _bosses_lbl: Label = null
var _level_lbl: Label = null
var _xp_bar: ProgressBar = null
var _xp_lbl: Label = null

var _boss_panel: PanelContainer = null
var _boss_name_lbl: Label = null
var _boss_hp_bar: ProgressBar = null

var _hp_bar: ProgressBar = null
var _hp_lbl: Label = null
var _dash_bar: ProgressBar = null
var _dust_lbl: Label = null
var _inv_btn: Button = null
var _inv_lbl: Label = null
var _mute_icon: TextureRect = null

var _skills_hbox: HBoxContainer = null
var _passives_hbox: HBoxContainer = null
var _skill_cards: Dictionary = {}

var _banner_panel: PanelContainer = null
var _banner_lbl: Label = null
var _banner_timer: float = 0.0

var _toast_vbox: VBoxContainer = null
var _toasts: Array[Dictionary] = []

var _popup_pool: Array[Dictionary] = []
var _world_labels: Array[Label] = []
var _compass_arrows: Array[Label] = []
var _unread_loot: int = 0

var _hud_throttle: float = 0.0
var _last_phase_name: String = ""
var _last_inv_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_hud()

func _build_hud() -> void:
	# === Top Shimmering XP Bar with micro-label ===
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_xp_bar.offset_bottom = 16
	UiHelper.style_progress_bar(_xp_bar, Color(0.28, 0.84, 0.98), Color(0.08, 0.06, 0.06, 0.95), 2)
	add_child(_xp_bar)

	_xp_lbl = Label.new()
	_xp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_xp_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_xp_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_xp_lbl.add_theme_font_size_override("font_size", 10)
	_xp_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	_xp_lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04, 0.95))
	_xp_lbl.add_theme_constant_override("outline_size", 3)
	_xp_bar.add_child(_xp_lbl)

	# === Top Status Strip ===
	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_top = 22
	top_bar.offset_left = 18
	top_bar.offset_right = -18
	top_bar.offset_bottom = 74
	top_bar.add_theme_constant_override("separation", 12)
	top_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(top_bar)

	var left_pill: PanelContainer = PanelContainer.new()
	left_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_BRASS, 12, 2, 7))
	top_bar.add_child(left_pill)
	var lp_h: HBoxContainer = HBoxContainer.new()
	lp_h.add_theme_constant_override("separation", 10)
	left_pill.add_child(lp_h)

	_hero_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 34)
	lp_h.add_child(_hero_portrait)

	_level_lbl = Label.new()
	_level_lbl.text = "Lv.1"
	UiHelper.apply_display_font(_level_lbl, 17, Color(1.0, 0.88, 0.36), 2)
	lp_h.add_child(_level_lbl)

	lp_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("skull"), 18))
	_kills_lbl = Label.new()
	_kills_lbl.text = "0"
	_kills_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_kills_lbl.add_theme_font_size_override("font_size", 14)
	lp_h.add_child(_kills_lbl)

	lp_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 18))
	_bosses_lbl = Label.new()
	_bosses_lbl.text = "0/3"
	_bosses_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_bosses_lbl.add_theme_font_size_override("font_size", 14)
	_bosses_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.44))
	lp_h.add_child(_bosses_lbl)

	var spacer1: Control = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer1)

	# Center Clock Plaque
	var clock_pill: PanelContainer = PanelContainer.new()
	clock_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 12, 2, 8))
	top_bar.add_child(clock_pill)
	var cp_h: HBoxContainer = HBoxContainer.new()
	cp_h.add_theme_constant_override("separation", 12)
	clock_pill.add_child(cp_h)

	_phase_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("sun_meadow"), 22)
	cp_h.add_child(_phase_icon)

	_phase_lbl = Label.new()
	_phase_lbl.text = "Sunny Meadow"
	_phase_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_phase_lbl.add_theme_font_size_override("font_size", 13)
	_phase_lbl.add_theme_color_override("font_color", Color(0.70, 0.95, 0.70))
	cp_h.add_child(_phase_lbl)

	_timer_lbl = Label.new()
	_timer_lbl.text = "00:00 / 20:00"
	UiHelper.apply_display_font(_timer_lbl, 21, UiHelper.TEXT_CREAM, 3)
	cp_h.add_child(_timer_lbl)

	_next_boss_lbl = Label.new()
	_next_boss_lbl.text = "Boss 1 in 06:30"
	_next_boss_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_next_boss_lbl.add_theme_font_size_override("font_size", 13)
	_next_boss_lbl.add_theme_color_override("font_color", Color(1.0, 0.68, 0.46))
	cp_h.add_child(_next_boss_lbl)

	var spacer2: Control = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer2)

	# Optional FPS pill (hidden by default unless F3 or ?review=1)
	_fps_pill = PanelContainer.new()
	_fps_pill.visible = false
	_fps_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 8, 1, 6, false))
	top_bar.add_child(_fps_pill)
	_fps_lbl = Label.new()
	_fps_lbl.text = "60 FPS"
	_fps_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_fps_lbl.add_theme_font_size_override("font_size", 12)
	_fps_lbl.add_theme_color_override("font_color", Color(0.72, 0.95, 0.72))
	_fps_pill.add_child(_fps_lbl)

	# Top-Right Mute & Pause icon buttons (clean centered icon+label)
	var mute_btn: Button = Button.new()
	mute_btn.text = ""
	mute_btn.custom_minimum_size = Vector2(74, 42)
	mute_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(mute_btn, UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 10, 6)
	mute_btn.pressed.connect(func() -> void: toggle_mute_requested.emit())
	top_bar.add_child(mute_btn)
	var m_cc: CenterContainer = CenterContainer.new()
	m_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mute_btn.add_child(m_cc)
	var m_h: HBoxContainer = HBoxContainer.new()
	m_h.add_theme_constant_override("separation", 5)
	m_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m_cc.add_child(m_h)
	_mute_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("sound_on"), 18)
	m_h.add_child(_mute_icon)
	var m_lbl: Label = Label.new()
	m_lbl.text = "[M]"
	m_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(m_lbl, 13, UiHelper.TEXT_CREAM, 2)
	m_h.add_child(m_lbl)

	var pause_btn: Button = Button.new()
	pause_btn.text = ""
	pause_btn.custom_minimum_size = Vector2(82, 42)
	pause_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(pause_btn, UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 10, 6)
	pause_btn.pressed.connect(func() -> void: toggle_pause_requested.emit())
	top_bar.add_child(pause_btn)
	var p_cc: CenterContainer = CenterContainer.new()
	p_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_btn.add_child(p_cc)
	var p_h: HBoxContainer = HBoxContainer.new()
	p_h.add_theme_constant_override("separation", 5)
	p_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p_cc.add_child(p_h)
	p_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("pause"), 16))
	var p_lbl: Label = Label.new()
	p_lbl.text = "[Esc]"
	p_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(p_lbl, 13, UiHelper.TEXT_CREAM, 2)
	p_h.add_child(p_lbl)

	# === Ornate Boss Health Bar ===
	_boss_panel = PanelContainer.new()
	_boss_panel.visible = false
	_boss_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.20, 0.08, 0.09, 0.95), Color(1.0, 0.40, 0.34), 12, 2, 8))
	_boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_boss_panel.offset_left = 250
	_boss_panel.offset_right = -250
	_boss_panel.offset_top = 82
	_boss_panel.offset_bottom = 140
	add_child(_boss_panel)

	var bp_v: VBoxContainer = VBoxContainer.new()
	bp_v.add_theme_constant_override("separation", 5)
	_boss_panel.add_child(bp_v)

	var bp_hdr: HBoxContainer = HBoxContainer.new()
	bp_hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	bp_hdr.add_theme_constant_override("separation", 8)
	bp_v.add_child(bp_hdr)
	bp_hdr.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 20))

	_boss_name_lbl = Label.new()
	_boss_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_boss_name_lbl, 16, Color(1.0, 0.88, 0.45), 2)
	bp_hdr.add_child(_boss_name_lbl)

	_boss_hp_bar = ProgressBar.new()
	_boss_hp_bar.show_percentage = false
	_boss_hp_bar.custom_minimum_size = Vector2(0, 16)
	UiHelper.style_progress_bar(_boss_hp_bar, Color(0.92, 0.24, 0.28), Color(0.12, 0.05, 0.06), 6)
	bp_v.add_child(_boss_hp_bar)

	# === Styled Event Banner ===
	var banner_center: CenterContainer = CenterContainer.new()
	banner_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner_center.offset_top = 148
	banner_center.offset_bottom = 200
	banner_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner_center)

	_banner_panel = PanelContainer.new()
	_banner_panel.visible = false
	_banner_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.12, 0.08, 0.07, 0.92), UiHelper.BORDER_GOLD, 12, 2, 10))
	banner_center.add_child(_banner_panel)

	_banner_lbl = Label.new()
	_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_banner_lbl, 22, Color(1.0, 0.90, 0.42), 3)
	_banner_panel.add_child(_banner_lbl)

	# === Right Loot Toast Feed ===
	_toast_vbox = VBoxContainer.new()
	_toast_vbox.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_vbox.offset_left = -360
	_toast_vbox.offset_right = -18
	_toast_vbox.offset_top = 86
	_toast_vbox.offset_bottom = 350
	_toast_vbox.add_theme_constant_override("separation", 6)
	_toast_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_vbox)

	# === Bottom-Left Hero Vitals & Satchel Button ===
	var bl_panel: PanelContainer = PanelContainer.new()
	bl_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_BRASS, 14, 2, 11))
	bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bl_panel.offset_left = 18
	bl_panel.offset_top = -156
	bl_panel.offset_right = 310
	bl_panel.offset_bottom = -16
	add_child(bl_panel)

	var bl_v: VBoxContainer = VBoxContainer.new()
	bl_v.add_theme_constant_override("separation", 7)
	bl_panel.add_child(bl_v)

	var hp_row: HBoxContainer = HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 6)
	bl_v.add_child(hp_row)
	hp_row.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("heart"), 22))

	_hp_bar = ProgressBar.new()
	_hp_bar.show_percentage = false
	_hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hp_bar.custom_minimum_size = Vector2(0, 24)
	UiHelper.style_progress_bar(_hp_bar, Color(0.86, 0.22, 0.30), Color(0.16, 0.07, 0.09), 7)
	hp_row.add_child(_hp_bar)

	_hp_lbl = Label.new()
	_hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_lbl.add_theme_font_size_override("font_size", 13)
	_hp_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_hp_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	_hp_lbl.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.04, 0.95))
	_hp_lbl.add_theme_constant_override("outline_size", 3)
	_hp_bar.add_child(_hp_lbl)
	_hp_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dash_row: HBoxContainer = HBoxContainer.new()
	dash_row.add_theme_constant_override("separation", 6)
	bl_v.add_child(dash_row)
	dash_row.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("dash_paw"), 18))

	var dash_lbl: Label = Label.new()
	dash_lbl.text = "Dash [Space]"
	dash_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	dash_lbl.add_theme_font_size_override("font_size", 12)
	dash_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
	dash_row.add_child(dash_lbl)

	_dash_bar = ProgressBar.new()
	_dash_bar.show_percentage = false
	_dash_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dash_bar.custom_minimum_size = Vector2(0, 14)
	UiHelper.style_progress_bar(_dash_bar, Color(0.98, 0.78, 0.24), Color(0.12, 0.09, 0.08), 5)
	dash_row.add_child(_dash_bar)

	var bot_bl_row: HBoxContainer = HBoxContainer.new()
	bot_bl_row.add_theme_constant_override("separation", 8)
	bl_v.add_child(bot_bl_row)

	var dust_pill: PanelContainer = PanelContainer.new()
	dust_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, Color(0.35, 0.78, 0.92, 0.8), 8, 1, 5, false))
	bot_bl_row.add_child(dust_pill)
	var dp_h: HBoxContainer = HBoxContainer.new()
	dp_h.add_theme_constant_override("separation", 5)
	dust_pill.add_child(dp_h)
	dp_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("prism_dust"), 18))
	_dust_lbl = Label.new()
	_dust_lbl.text = "25"
	_dust_lbl.add_theme_font_size_override("font_size", 13)
	_dust_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_dust_lbl.add_theme_color_override("font_color", Color(0.55, 0.94, 1.0))
	dp_h.add_child(_dust_lbl)

	_inv_btn = Button.new()
	_inv_btn.text = ""
	_inv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inv_btn.custom_minimum_size = Vector2(0, 38)
	_inv_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_inv_btn, UiHelper.CTA_SAPPHIRE, UiHelper.BORDER_GOLD, 10, 6)
	_inv_btn.pressed.connect(func() -> void: open_inventory_requested.emit())
	bot_bl_row.add_child(_inv_btn)

	var inv_cc: CenterContainer = CenterContainer.new()
	inv_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inv_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inv_btn.add_child(inv_cc)
	var inv_h: HBoxContainer = HBoxContainer.new()
	inv_h.add_theme_constant_override("separation", 6)
	inv_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inv_cc.add_child(inv_h)
	inv_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("bag"), 18))
	_inv_lbl = Label.new()
	_inv_lbl.text = "Gear & Gems [Tab]"
	_inv_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_inv_lbl, 13, UiHelper.TEXT_CREAM, 2)
	inv_h.add_child(_inv_lbl)

	# === Bottom-Center PoE Active Skills & Passive Gems Bar (symmetrically centered!) ===
	var bc_vbox: VBoxContainer = VBoxContainer.new()
	bc_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bc_vbox.offset_left = 320
	bc_vbox.offset_right = -320
	bc_vbox.offset_top = -152
	bc_vbox.offset_bottom = -16
	bc_vbox.alignment = BoxContainer.ALIGNMENT_END
	bc_vbox.add_theme_constant_override("separation", 6)
	bc_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bc_vbox)

	_passives_hbox = HBoxContainer.new()
	_passives_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_passives_hbox.add_theme_constant_override("separation", 6)
	bc_vbox.add_child(_passives_hbox)

	_skills_hbox = HBoxContainer.new()
	_skills_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_skills_hbox.add_theme_constant_override("separation", 8)
	bc_vbox.add_child(_skills_hbox)

	# === Pooled Floating Damage Popups ===
	for _i in range(42):
		var lbl: Label = Label.new()
		lbl.visible = false
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_override("font", UiHelper.get_display_font())
		lbl.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.03))
		lbl.add_theme_constant_override("outline_size", 4)
		add_child(lbl)
		_popup_pool.append({"label": lbl, "timer": 0.0, "world_pos": Vector3.ZERO})

	# === Ground Loot Labels Pool ===
	for _j in range(16):
		var gl: Label = Label.new()
		gl.visible = false
		gl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gl.add_theme_font_override("font", UiHelper.get_bold_font())
		gl.add_theme_font_size_override("font_size", 12)
		gl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04))
		gl.add_theme_constant_override("outline_size", 4)
		add_child(gl)
		_world_labels.append(gl)

	# === Compass Arrows Pool ===
	for _k in range(6):
		var cl: Label = Label.new()
		cl.visible = false
		cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cl.add_theme_font_override("font", UiHelper.get_display_font())
		cl.add_theme_font_size_override("font_size", 14)
		cl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04))
		cl.add_theme_constant_override("outline_size", 4)
		add_child(cl)
		_compass_arrows.append(cl)

func set_fps_visible(show_fps: bool) -> void:
	if _fps_pill != null:
		_fps_pill.visible = show_fps

func toggle_fps_visible() -> void:
	if _fps_pill != null:
		_fps_pill.visible = not _fps_pill.visible

func reset_hud(hero_id: String = "shiba") -> void:
	_unread_loot = 0
	_banner_timer = 0.0
	_hud_throttle = 1.0
	_last_phase_name = ""
	_last_inv_text = ""
	_banner_panel.visible = false
	if _hero_portrait != null:
		_hero_portrait.texture = UiIcons.get_hero_portrait(hero_id)
	for t in _toasts:
		if is_instance_valid(t["node"]):
			t["node"].queue_free()
	_toasts.clear()
	for p in _popup_pool:
		p["timer"] = 0.0
		p["label"].visible = false

func mark_loot_read() -> void:
	_unread_loot = 0

func add_unread_loot() -> void:
	_unread_loot += 1

func set_muted_state(is_muted: bool) -> void:
	if _mute_icon != null:
		_mute_icon.texture = UiIcons.get_ui_icon("sound_off" if is_muted else "sound_on")

func show_banner(text: String, col: Color) -> void:
	_banner_lbl.text = text
	_banner_lbl.add_theme_color_override("font_color", col)
	_banner_panel.visible = true
	_banner_timer = 3.6

func push_toast(text: String, col: Color, icon_tex: Texture2D = null) -> void:
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.08, 0.07, 0.94), col, 10, 2, 7))
	var h: HBoxContainer = HBoxContainer.new()
	h.add_theme_constant_override("separation", 7)
	p.add_child(h)
	if icon_tex != null:
		h.add_child(UiHelper.make_icon_rect(icon_tex, 20))
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	lbl.add_theme_color_override("font_color", col)
	h.add_child(lbl)
	_toast_vbox.add_child(p)
	_toasts.append({"node": p, "timer": 4.2})
	while _toasts.size() > 5:
		var old: Dictionary = _toasts.pop_front()
		if is_instance_valid(old["node"]):
			old["node"].queue_free()

func spawn_damage_popup(world_pos: Vector3, amount: float, is_crit: bool, is_fire: bool, is_cold: bool, is_heal: bool = false) -> void:
	for p in _popup_pool:
		if float(p["timer"]) <= 0.0:
			var lbl: Label = p["label"]
			lbl.text = ("+%d" % int(round(amount))) if is_heal else ("%d!" % int(round(amount)) if is_crit else "%d" % int(round(amount)))
			var col: Color = Color(0.45, 1.0, 0.56) if is_heal else (Color(1.0, 0.88, 0.25) if is_crit else (Color(1.0, 0.52, 0.24) if is_fire else (Color(0.45, 0.90, 1.0) if is_cold else Color(0.98, 0.96, 0.90))))
			lbl.add_theme_color_override("font_color", col)
			lbl.add_theme_font_size_override("font_size", 21 if is_crit else 15)
			p["world_pos"] = world_pos + Vector3(randf_range(-0.4, 0.4), 1.35, randf_range(-0.3, 0.3))
			p["timer"] = 0.72
			lbl.visible = true
			return

func rebuild_skill_bar(stats: HeroStats) -> void:
	for ch in _skills_hbox.get_children():
		ch.queue_free()
	for ch in _passives_hbox.get_children():
		ch.queue_free()
	_skill_cards.clear()

	for p_info in stats.active_passives:
		var gem: GemInstance = p_info["gem"]
		var badge: PanelContainer = PanelContainer.new()
		var gcol: Color = GameEnums.gem_color_value(gem.get_gem_color())
		badge.add_theme_stylebox_override("panel", UiHelper.make_panel_box(gcol.darkened(0.62), gcol, 9, 1, 5, false))
		var ph: HBoxContainer = HBoxContainer.new()
		ph.add_theme_constant_override("separation", 5)
		badge.add_child(ph)
		ph.add_child(UiHelper.make_icon_rect(UiIcons.get_gem_icon(GameEnums.GemType.PASSIVE, gem.get_gem_color()), 17))
		var pl: Label = Label.new()
		pl.text = "%s %d" % [gem.get_short_label(), int(p_info["effective_level"])]
		pl.add_theme_font_size_override("font_size", 12)
		pl.add_theme_font_override("font", UiHelper.get_bold_font())
		pl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		pl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04, 0.95))
		pl.add_theme_constant_override("outline_size", 2)
		ph.add_child(pl)
		_passives_hbox.add_child(badge)

	for cfg in stats.active_skill_configs:
		var uid: int = int(cfg["uid"])
		var gid: String = String(cfg["gem_id"])
		var gcol: Color = GameEnums.gem_color_value(int(cfg["color"]))
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(98, 92)
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, gcol, 11, 2, 6))

		var v: VBoxContainer = VBoxContainer.new()
		v.add_theme_constant_override("separation", 3)
		card.add_child(v)

		var top_r: HBoxContainer = HBoxContainer.new()
		top_r.alignment = BoxContainer.ALIGNMENT_CENTER
		top_r.add_theme_constant_override("separation", 5)
		v.add_child(top_r)

		var well: PanelContainer = PanelContainer.new()
		well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, gcol.darkened(0.25), 8, 1, 3, false))
		well.add_child(UiHelper.make_icon_rect(UiIcons.get_skill_icon(gid), 30))
		top_r.add_child(well)

		var lvl_lbl: Label = Label.new()
		lvl_lbl.text = "Lv.%d" % int(cfg["effective_level"])
		UiHelper.apply_display_font(lvl_lbl, 12, Color(1.0, 0.90, 0.45), 2)
		top_r.add_child(lvl_lbl)

		var name_lbl: Label = Label.new()
		name_lbl.text = String(cfg["short"])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		name_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		name_lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.95))
		name_lbl.add_theme_constant_override("outline_size", 2)
		v.add_child(name_lbl)

		var pip_row: HBoxContainer = HBoxContainer.new()
		pip_row.alignment = BoxContainer.ALIGNMENT_CENTER
		pip_row.custom_minimum_size = Vector2(0, 15)
		pip_row.add_theme_constant_override("separation", 3)
		v.add_child(pip_row)
		var sup_cols: Array = cfg.get("linked_support_colors", [])
		if sup_cols.is_empty():
			var unl: Label = Label.new()
			unl.text = "·"
			unl.add_theme_font_size_override("font_size", 10)
			unl.add_theme_color_override("font_color", Color(0.55, 0.50, 0.45))
			pip_row.add_child(unl)
		else:
			for sc in sup_cols:
				pip_row.add_child(UiHelper.make_icon_rect(UiIcons.get_gem_icon(GameEnums.GemType.SUPPORT, int(sc)), 15))

		var cd_bar: ProgressBar = ProgressBar.new()
		cd_bar.show_percentage = false
		cd_bar.custom_minimum_size = Vector2(0, 6)
		cd_bar.max_value = 1.0
		UiHelper.style_progress_bar(cd_bar, gcol, UiHelper.BG_WELL, 3)
		v.add_child(cd_bar)

		_skills_hbox.add_child(card)
		_skill_cards[uid] = cd_bar

func update_hud(delta: float, stats: HeroStats, player: PlayerController, wave_dir: WaveDirector, skill_exec: SkillExecutor, loot_mgr: LootManager, cam: Camera3D) -> void:
	if _banner_timer > 0.0:
		_banner_timer -= delta
		if _banner_timer <= 0.0:
			_banner_panel.visible = false

	for i in range(_toasts.size() - 1, -1, -1):
		_toasts[i]["timer"] = float(_toasts[i]["timer"]) - delta
		if float(_toasts[i]["timer"]) <= 0.0:
			if is_instance_valid(_toasts[i]["node"]):
				_toasts[i]["node"].queue_free()
			_toasts.remove_at(i)

	for p in _popup_pool:
		var pt: float = float(p["timer"])
		if pt > 0.0:
			pt -= delta
			p["timer"] = pt
			var lbl: Label = p["label"]
			if pt <= 0.0 or cam == null:
				lbl.visible = false
			else:
				var wpos: Vector3 = p["world_pos"] + Vector3(0.0, (0.72 - pt) * 1.8, 0.0)
				if not cam.is_position_behind(wpos):
					var spos: Vector2 = cam.unproject_position(wpos)
					lbl.position = spos - Vector2(18.0, 12.0)
					lbl.modulate.a = clampf(pt / 0.35, 0.0, 1.0)
					lbl.visible = true
				else:
					lbl.visible = false

	for uid in _skill_cards.keys():
		var bar: ProgressBar = _skill_cards[uid]
		if is_instance_valid(bar):
			bar.value = skill_exec.get_cooldown_fraction(int(uid))

	_hud_throttle += delta
	if _hud_throttle < 0.10:
		return
	_hud_throttle = 0.0

	var t: float = wave_dir.elapsed_time
	var mins: int = int(t) / 60
	var secs: int = int(t) % 60
	_timer_lbl.text = "%02d:%02d / 20:00" % [mins, secs]
	var prof: Dictionary = EnemyDatabase.get_wave_profile(t)
	var pname: String = String(prof["phase_name"])
	if pname != _last_phase_name:
		_last_phase_name = pname
		_phase_lbl.text = pname
		if pname.contains("Sunset"):
			_phase_icon.texture = UiIcons.get_ui_icon("sunset")
		elif pname.contains("Twilight"):
			_phase_icon.texture = UiIcons.get_ui_icon("moon_twilight")
		else:
			_phase_icon.texture = UiIcons.get_ui_icon("sun_meadow")

	_next_boss_lbl.text = wave_dir.get_next_boss_countdown()
	_kills_lbl.text = "%d" % wave_dir.kills_count
	_bosses_lbl.text = "%d/3" % wave_dir.bosses_defeated_count
	_level_lbl.text = "Lv.%d" % stats.hero_level
	if _fps_pill.visible:
		_fps_lbl.text = "%d FPS" % int(Engine.get_frames_per_second())
	_xp_bar.max_value = stats.hero_xp_to_next
	_xp_bar.value = stats.hero_xp
	_xp_lbl.text = "Lv.%d  ·  %d / %d XP" % [stats.hero_level, int(stats.hero_xp), int(stats.hero_xp_to_next)]

	_hp_bar.max_value = stats.max_hp
	_hp_bar.value = player.current_hp
	_hp_lbl.text = "%d / %d  (+%.1f/s)" % [int(ceil(player.current_hp)), int(round(stats.max_hp)), stats.hp_regen]
	_dash_bar.max_value = 1.0
	_dash_bar.value = player.get_dash_ready_fraction()
	_dust_lbl.text = "%d" % stats.prism_dust
	var inv_txt: String = "Gear (%d NEW!)" % _unread_loot if _unread_loot > 0 else "Gear & Gems [Tab]"
	if inv_txt != _last_inv_text:
		_last_inv_text = inv_txt
		_inv_lbl.text = inv_txt

	if is_instance_valid(wave_dir.active_boss) and not wave_dir.active_boss.is_dead:
		_boss_panel.visible = true
		_boss_name_lbl.text = "%s (%d / %d)" % [wave_dir.active_boss.enemy_name, int(ceil(wave_dir.active_boss.current_hp)), int(round(wave_dir.active_boss.max_hp))]
		_boss_hp_bar.max_value = wave_dir.active_boss.max_hp
		_boss_hp_bar.value = wave_dir.active_boss.current_hp
	else:
		_boss_panel.visible = false

	_update_world_labels_and_arrows(cam, loot_mgr, wave_dir)

func _update_world_labels_and_arrows(cam: Camera3D, loot_mgr: LootManager, wave_dir: WaveDirector) -> void:
	if cam == null:
		return
	var vsize: Vector2 = get_viewport_rect().size
	var glabels: Array[Dictionary] = loot_mgr.get_ground_labels()
	var arrow_targets: Array[Dictionary] = []

	for i in range(_world_labels.size()):
		var lbl: Label = _world_labels[i]
		if i < glabels.size():
			var info: Dictionary = glabels[i]
			var wpos: Vector3 = info["pos"]
			var spos: Vector2 = cam.unproject_position(wpos)
			var on_screen: bool = not cam.is_position_behind(wpos) and spos.x > 20.0 and spos.x < vsize.x - 20.0 and spos.y > 20.0 and spos.y < vsize.y - 20.0
			if on_screen:
				lbl.text = String(info["text"])
				lbl.add_theme_color_override("font_color", info["color"])
				lbl.position = spos - Vector2(60.0, 14.0)
				lbl.visible = true
			else:
				lbl.visible = false
				if bool(info["is_chest"]):
					arrow_targets.append({"pos": wpos, "text": "CHEST", "color": Color(1.0, 0.88, 0.25)})
		else:
			lbl.visible = false

	if is_instance_valid(wave_dir.active_boss) and not wave_dir.active_boss.is_dead:
		var bpos: Vector3 = wave_dir.active_boss.global_position
		var bspos: Vector2 = cam.unproject_position(bpos)
		if cam.is_position_behind(bpos) or bspos.x < 10.0 or bspos.x > vsize.x - 10.0 or bspos.y < 10.0 or bspos.y > vsize.y - 10.0:
			arrow_targets.append({"pos": bpos, "text": "BOSS!", "color": Color(1.0, 0.32, 0.30)})

	var center: Vector2 = vsize * 0.5
	for i in range(_compass_arrows.size()):
		var cl: Label = _compass_arrows[i]
		if i < arrow_targets.size():
			var tinfo: Dictionary = arrow_targets[i]
			var raw: Vector2 = cam.unproject_position(tinfo["pos"])
			if cam.is_position_behind(tinfo["pos"]):
				raw = vsize - raw
			var dir: Vector2 = (raw - center).normalized()
			var edge_pos: Vector2 = center + dir * minf(center.x - 65.0, center.y - 80.0)
			cl.text = ">> %s" % String(tinfo["text"])
			cl.add_theme_color_override("font_color", tinfo["color"])
			cl.position = edge_pos - Vector2(30.0, 10.0)
			cl.visible = true
		else:
			cl.visible = false
