class_name HudController
extends Control

signal open_inventory_requested()
signal toggle_pause_requested()
signal toggle_mute_requested()

var touch_controls: TouchControls = null
var _is_mobile_mode: bool = false
var _is_tutorial_mode: bool = false
var _highlight_bag: bool = false

var _top_bar: HBoxContainer = null
var _left_pill: PanelContainer = null
var _lp_h: HBoxContainer = null
var _clock_pill: PanelContainer = null
var _cp_h: HBoxContainer = null
var _sub_top_vbox: VBoxContainer = null
var _tut_pill: PanelContainer = null
var _tut_lbl: Label = null
var _mute_btn: Button = null
var _mute_lbl: Label = null
var _pause_btn: Button = null
var _pause_lbl: Label = null
var _bl_panel: PanelContainer = null
var _bl_box: BoxContainer = null
var _bc_vbox: VBoxContainer = null

var _hero_portrait: TextureRect = null
var _kills_icon: TextureRect = null
var _boss_icon: TextureRect = null
var _gold_icon: TextureRect = null
var _timer_lbl: Label = null
var _phase_icon: TextureRect = null
var _phase_lbl: Label = null
var _next_boss_lbl: Label = null
var _next_shop_lbl: Label = null
var _fps_pill: PanelContainer = null
var _fps_lbl: Label = null
var _kills_lbl: Label = null
var _gold_lbl: Label = null
var _bosses_lbl: Label = null
var _minimap: MinimapWidget = null
var _relics_hud_hbox: HFlowContainer = null
var _last_relic_count: int = -1
var _last_stats: HeroStats = null

var _boss_panel: PanelContainer = null
var _boss_name_lbl: Label = null
var _boss_hp_bar: ProgressBar = null

var _hp_bar: ProgressBar = null
var _hp_lbl: Label = null
var _inv_btn: Button = null
var _inv_lbl: Label = null
var _mute_icon: TextureRect = null

var _skills_hbox: HBoxContainer = null
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
var _pulse_time: float = 0.0
var _last_phase_name: String = ""
var _last_inv_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_hud()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _safe_vp_size() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	if (vp.x <= 10.0 or vp.y <= 10.0) and get_viewport() != null:
		vp = get_viewport().get_visible_rect().size
	if vp.x <= 10.0 or vp.y <= 10.0:
		vp = Vector2(1280.0, 720.0)
	return vp

func get_overlap_audit_nodes() -> Array[Control]:
	var out: Array[Control] = []
	for c in [_top_bar, _sub_top_vbox, _minimap, _toast_vbox, _bc_vbox, _bl_panel]:
		if c != null:
			out.append(c)
	return out

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _bc_vbox != null:
		_apply_responsive_layout()

func _build_hud() -> void:
	# === Top Status Strip ===
	_top_bar = HBoxContainer.new()
	_top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_bar.offset_top = 12
	_top_bar.offset_left = 18
	_top_bar.offset_right = -18
	_top_bar.offset_bottom = 62
	_top_bar.add_theme_constant_override("separation", 10)
	_top_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_top_bar)

	_left_pill = PanelContainer.new()
	_left_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_BRASS, 12, 2, 6))
	_top_bar.add_child(_left_pill)
	_lp_h = HBoxContainer.new()
	_lp_h.add_theme_constant_override("separation", 8)
	_left_pill.add_child(_lp_h)

	_hero_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 28)
	_lp_h.add_child(_hero_portrait)

	_kills_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("skull"), 17)
	_lp_h.add_child(_kills_icon)
	_kills_lbl = Label.new()
	_kills_lbl.text = "0"
	_kills_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_kills_lbl.add_theme_font_size_override("font_size", 14)
	_lp_h.add_child(_kills_lbl)

	_boss_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 17)
	_lp_h.add_child(_boss_icon)
	_bosses_lbl = Label.new()
	_bosses_lbl.text = "0/3"
	_bosses_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_bosses_lbl.add_theme_font_size_override("font_size", 14)
	_bosses_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.44))
	_lp_h.add_child(_bosses_lbl)

	_gold_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("gold_coin"), 17)
	_lp_h.add_child(_gold_icon)
	_gold_lbl = Label.new()
	_gold_lbl.text = "20G"
	_gold_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_gold_lbl.add_theme_font_size_override("font_size", 14)
	_gold_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.34))
	_lp_h.add_child(_gold_lbl)

	var spacer1: Control = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_bar.add_child(spacer1)

	# Center Clock Plaque
	_clock_pill = PanelContainer.new()
	_clock_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 12, 2, 7))
	_top_bar.add_child(_clock_pill)
	_cp_h = HBoxContainer.new()
	_cp_h.add_theme_constant_override("separation", 10)
	_clock_pill.add_child(_cp_h)

	_phase_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("sun_meadow"), 20)
	_cp_h.add_child(_phase_icon)

	_phase_lbl = Label.new()
	_phase_lbl.text = "Sunny Meadow"
	_phase_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_phase_lbl.add_theme_font_size_override("font_size", 13)
	_phase_lbl.add_theme_color_override("font_color", Color(0.70, 0.95, 0.70))
	_cp_h.add_child(_phase_lbl)

	_timer_lbl = Label.new()
	_timer_lbl.text = "00:00 / 20:00"
	UiHelper.apply_display_font(_timer_lbl, 20, UiHelper.TEXT_CREAM, 3)
	_cp_h.add_child(_timer_lbl)

	_next_shop_lbl = Label.new()
	_next_shop_lbl.text = "Shop 1 in 03:00"
	_next_shop_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_next_shop_lbl.add_theme_font_size_override("font_size", 13)
	_next_shop_lbl.add_theme_color_override("font_color", Color(0.54, 0.92, 1.0))
	_cp_h.add_child(_next_shop_lbl)

	_next_boss_lbl = Label.new()
	_next_boss_lbl.text = "Boss 1 in 06:30"
	_next_boss_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_next_boss_lbl.add_theme_font_size_override("font_size", 13)
	_next_boss_lbl.add_theme_color_override("font_color", Color(1.0, 0.68, 0.46))
	_cp_h.add_child(_next_boss_lbl)

	var spacer2: Control = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_bar.add_child(spacer2)

	# Optional FPS pill
	_fps_pill = PanelContainer.new()
	_fps_pill.visible = false
	_fps_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 8, 1, 5, false))
	_top_bar.add_child(_fps_pill)
	_fps_lbl = Label.new()
	_fps_lbl.text = "60 FPS"
	_fps_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_fps_lbl.add_theme_font_size_override("font_size", 12)
	_fps_lbl.add_theme_color_override("font_color", Color(0.72, 0.95, 0.72))
	_fps_pill.add_child(_fps_lbl)

	# Top-Right Mute & Pause icon buttons
	_mute_btn = Button.new()
	_mute_btn.text = ""
	_mute_btn.custom_minimum_size = Vector2(72, 42)
	_mute_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_mute_btn, UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 10, 6)
	_mute_btn.pressed.connect(func() -> void: toggle_mute_requested.emit())
	_top_bar.add_child(_mute_btn)
	var m_cc: CenterContainer = CenterContainer.new()
	m_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mute_btn.add_child(m_cc)
	var m_h: HBoxContainer = HBoxContainer.new()
	m_h.add_theme_constant_override("separation", 5)
	m_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m_cc.add_child(m_h)
	_mute_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("sound_on"), 18)
	m_h.add_child(_mute_icon)
	_mute_lbl = Label.new()
	_mute_lbl.text = "[M]"
	_mute_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_mute_lbl, 13, UiHelper.TEXT_CREAM, 2)
	m_h.add_child(_mute_lbl)

	_pause_btn = Button.new()
	_pause_btn.text = ""
	_pause_btn.custom_minimum_size = Vector2(80, 42)
	_pause_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_pause_btn, UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 10, 6)
	_pause_btn.pressed.connect(func() -> void: toggle_pause_requested.emit())
	_top_bar.add_child(_pause_btn)
	var p_cc: CenterContainer = CenterContainer.new()
	p_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_btn.add_child(p_cc)
	var p_h: HBoxContainer = HBoxContainer.new()
	p_h.add_theme_constant_override("separation", 5)
	p_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p_cc.add_child(p_h)
	p_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("pause"), 16))
	_pause_lbl = Label.new()
	_pause_lbl.text = "[Esc]"
	_pause_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_pause_lbl, 13, UiHelper.TEXT_CREAM, 2)
	p_h.add_child(_pause_lbl)

	# === Conflict-Free Vertical Stack Below Top Bar (Relics -> Tutorial Objective -> Boss Bar -> Event Banner) ===
	_sub_top_vbox = VBoxContainer.new()
	_sub_top_vbox.name = "SubTopStack"
	_sub_top_vbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_sub_top_vbox.grow_vertical = Control.GROW_DIRECTION_END
	_sub_top_vbox.offset_left = 18
	_sub_top_vbox.offset_right = -152
	_sub_top_vbox.offset_top = 70
	_sub_top_vbox.offset_bottom = 70
	_sub_top_vbox.add_theme_constant_override("separation", 6)
	_sub_top_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_sub_top_vbox)

	_relics_hud_hbox = HFlowContainer.new()
	_relics_hud_hbox.name = "HudRelicsFlow"
	_relics_hud_hbox.visible = false
	_relics_hud_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_relics_hud_hbox.add_theme_constant_override("h_separation", 5)
	_relics_hud_hbox.add_theme_constant_override("v_separation", 4)
	_relics_hud_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	_sub_top_vbox.add_child(_relics_hud_hbox)

	_tut_pill = PanelContainer.new()
	_tut_pill.visible = false
	_tut_pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tut_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.24, 0.17, 0.08), UiHelper.BORDER_GOLD, 12, 2, 7))
	_sub_top_vbox.add_child(_tut_pill)
	var tp_h: HBoxContainer = HBoxContainer.new()
	tp_h.add_theme_constant_override("separation", 7)
	_tut_pill.add_child(tp_h)
	tp_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 18))
	_tut_lbl = Label.new()
	_tut_lbl.text = "1/4  Walk to Acorn Barrage"
	_tut_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tut_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiHelper.apply_display_font(_tut_lbl, 15, Color(1.0, 0.90, 0.42), 2)
	tp_h.add_child(_tut_lbl)

	# === Ornate Boss Health Bar ===
	_boss_panel = PanelContainer.new()
	_boss_panel.visible = false
	_boss_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boss_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.20, 0.08, 0.09, 0.95), Color(1.0, 0.40, 0.34), 12, 2, 7))
	_sub_top_vbox.add_child(_boss_panel)

	var bp_v: VBoxContainer = VBoxContainer.new()
	bp_v.add_theme_constant_override("separation", 4)
	_boss_panel.add_child(bp_v)

	var bp_hdr: HBoxContainer = HBoxContainer.new()
	bp_hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	bp_hdr.add_theme_constant_override("separation", 6)
	bp_v.add_child(bp_hdr)
	bp_hdr.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 18))

	_boss_name_lbl = Label.new()
	_boss_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boss_name_lbl.clip_text = true
	UiHelper.apply_display_font(_boss_name_lbl, 15, Color(1.0, 0.88, 0.45), 2)
	bp_hdr.add_child(_boss_name_lbl)

	_boss_hp_bar = ProgressBar.new()
	_boss_hp_bar.show_percentage = false
	_boss_hp_bar.custom_minimum_size = Vector2(0, 14)
	UiHelper.style_progress_bar(_boss_hp_bar, Color(0.92, 0.24, 0.28), Color(0.12, 0.05, 0.06), 6)
	bp_v.add_child(_boss_hp_bar)

	# === Styled Event Banner (Auto-wraps inside SubTopStack) ===
	_banner_panel = PanelContainer.new()
	_banner_panel.visible = false
	_banner_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_banner_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.12, 0.08, 0.07, 0.92), UiHelper.BORDER_GOLD, 12, 2, 8))
	_sub_top_vbox.add_child(_banner_panel)

	_banner_lbl = Label.new()
	_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_banner_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiHelper.apply_display_font(_banner_lbl, 17, Color(1.0, 0.90, 0.42), 3)
	_banner_panel.add_child(_banner_lbl)

	# === Top-Right Live Arena Minimap ===
	_minimap = MinimapWidget.new()
	_minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap.offset_left = -140
	_minimap.offset_right = -18
	_minimap.offset_top = 72
	_minimap.offset_bottom = 194
	add_child(_minimap)

	# === Right Loot Toast Feed (placed cleanly below Minimap & SubTopStack) ===
	_toast_vbox = VBoxContainer.new()
	_toast_vbox.name = "HudToastFeed"
	_toast_vbox.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_vbox.grow_vertical = Control.GROW_DIRECTION_END
	_toast_vbox.offset_left = -310
	_toast_vbox.offset_right = -18
	_toast_vbox.offset_top = 202
	_toast_vbox.offset_bottom = 202
	_toast_vbox.add_theme_constant_override("separation", 6)
	_toast_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_vbox)

	# === Hero Vitals & Satchel Dock (bottom-left on Desktop, clean full-width bottom bar on Portrait) ===
	_bl_panel = PanelContainer.new()
	_bl_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_BRASS, 14, 2, 10))
	_bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_bl_panel.offset_left = 18
	_bl_panel.offset_top = -104
	_bl_panel.offset_right = 296
	_bl_panel.offset_bottom = -14
	add_child(_bl_panel)

	_bl_box = BoxContainer.new()
	_bl_box.vertical = true
	_bl_box.add_theme_constant_override("separation", 8)
	_bl_panel.add_child(_bl_box)

	var hp_row: HBoxContainer = HBoxContainer.new()
	hp_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_row.add_theme_constant_override("separation", 6)
	_bl_box.add_child(hp_row)
	hp_row.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("heart"), 22))

	_hp_bar = ProgressBar.new()
	_hp_bar.show_percentage = false
	_hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_hp_bar.custom_minimum_size = Vector2(0, 28)
	UiHelper.style_progress_bar(_hp_bar, Color(0.86, 0.22, 0.30), Color(0.16, 0.07, 0.09), 7)
	hp_row.add_child(_hp_bar)

	_hp_lbl = Label.new()
	_hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_lbl.add_theme_font_size_override("font_size", 14)
	_hp_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_hp_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	_hp_lbl.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.04, 0.95))
	_hp_lbl.add_theme_constant_override("outline_size", 3)
	_hp_bar.add_child(_hp_lbl)
	_hp_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_inv_btn = Button.new()
	_inv_btn.text = ""
	_inv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inv_btn.custom_minimum_size = Vector2(0, 40)
	_inv_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_inv_btn, UiHelper.CTA_SAPPHIRE, UiHelper.BORDER_GOLD, 10, 6)
	_inv_btn.pressed.connect(func() -> void: open_inventory_requested.emit())
	_bl_box.add_child(_inv_btn)

	var inv_cc: CenterContainer = CenterContainer.new()
	inv_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inv_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inv_btn.add_child(inv_cc)
	var inv_h: HBoxContainer = HBoxContainer.new()
	inv_h.add_theme_constant_override("separation", 6)
	inv_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inv_cc.add_child(inv_h)
	inv_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("deck_cards"), 19))
	_inv_lbl = Label.new()
	_inv_lbl.text = "Deck [Tab]"
	_inv_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_inv_lbl, 14, UiHelper.TEXT_CREAM, 2)
	inv_h.add_child(_inv_lbl)

	# === Bottom-Center Ability Dock ===
	_bc_vbox = VBoxContainer.new()
	_bc_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bc_vbox.offset_left = 310
	_bc_vbox.offset_right = -310
	_bc_vbox.offset_top = -104
	_bc_vbox.offset_bottom = -14
	_bc_vbox.alignment = BoxContainer.ALIGNMENT_END
	_bc_vbox.add_theme_constant_override("separation", 4)
	_bc_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bc_vbox)

	_skills_hbox = HBoxContainer.new()
	_skills_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_skills_hbox.add_theme_constant_override("separation", 8)
	_bc_vbox.add_child(_skills_hbox)

	# === Multi-Touch Virtual Joystick (Dash removed!) ===
	touch_controls = TouchControls.new()
	touch_controls.excluded_controls = [_left_pill, _clock_pill, _tut_pill, _mute_btn, _pause_btn, _bl_panel]
	add_child(touch_controls)

	# === Pooled Floating Damage Popups ===
	for _i in range(42):
		var lbl: Label = Label.new()
		lbl.name = "DamagePopup_%d" % _i
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
		gl.name = "WorldLabel_%d" % _j
		gl.visible = false
		gl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gl.add_theme_font_override("font", UiHelper.get_bold_font())
		gl.add_theme_font_size_override("font_size", 13)
		gl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04))
		gl.add_theme_constant_override("outline_size", 4)
		add_child(gl)
		_world_labels.append(gl)

	# === Compass Arrows Pool ===
	for _k in range(6):
		var cl: Label = Label.new()
		cl.name = "CompassArrow_%d" % _k
		cl.visible = false
		cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cl.add_theme_font_override("font", UiHelper.get_display_font())
		cl.add_theme_font_size_override("font_size", 15)
		cl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.04))
		cl.add_theme_constant_override("outline_size", 4)
		add_child(cl)
		_compass_arrows.append(cl)

func set_tutorial_objective(active: bool, short_text: String = "", highlight_bag: bool = false) -> void:
	_is_tutorial_mode = active
	_highlight_bag = highlight_bag
	if _clock_pill != null:
		_clock_pill.visible = not active
	if _tut_pill != null:
		_tut_pill.visible = active
	_sync_toast_top()
	if _tut_lbl != null and active:
		_tut_lbl.text = short_text
	if _inv_btn != null and not highlight_bag:
		_inv_btn.modulate = Color.WHITE
		UiHelper.style_button(_inv_btn, UiHelper.CTA_SAPPHIRE, UiHelper.BORDER_GOLD, 10, 6)
	elif _inv_btn != null and highlight_bag:
		UiHelper.style_button(_inv_btn, Color(0.38, 0.27, 0.09), Color(1.0, 0.90, 0.36), 10, 6)

func set_fps_visible(show_fps: bool) -> void:
	if _fps_pill != null:
		_fps_pill.visible = show_fps

func set_mobile_mode(is_mobile: bool, allow_mouse: bool = false) -> void:
	_is_mobile_mode = is_mobile
	if touch_controls != null:
		touch_controls.set_touch_enabled(is_mobile, allow_mouse)
	_apply_responsive_layout()

func get_touch_move_vector() -> Vector2:
	if touch_controls == null:
		return Vector2.ZERO
	return touch_controls.get_move_vector()

func reset_touch_input() -> void:
	if touch_controls != null:
		touch_controls.reset_input()

func _sync_toast_top() -> void:
	if _toast_vbox == null:
		return
	var vp: Vector2 = _safe_vp_size()
	var is_portrait: bool = vp.x < 750.0
	var minimap_bot: float = 136.0 if is_portrait else 194.0
	var sub_bot: float = minimap_bot
	if _sub_top_vbox != null and _sub_top_vbox.visible:
		sub_bot = _sub_top_vbox.position.y + _sub_top_vbox.size.y
	var want_top: int = int(maxf(minimap_bot + 6.0, sub_bot + 6.0))
	_toast_vbox.offset_top = want_top
	_toast_vbox.offset_bottom = want_top

func _apply_responsive_layout() -> void:
	var vp: Vector2 = _safe_vp_size()
	if vp.x <= 10.0:
		return
	var is_portrait: bool = vp.x < 750.0
	var is_tiny: bool = vp.x < 430.0
	var is_short: bool = vp.y < 540.0

	if _hero_portrait != null:
		_hero_portrait.visible = vp.x >= 410.0
		var psz: int = 22 if is_portrait else 28
		_hero_portrait.custom_minimum_size = Vector2(psz, psz)
	var icon_sz: int = 14 if is_tiny else 17
	for ic in [_kills_icon, _boss_icon, _gold_icon]:
		if ic != null:
			ic.custom_minimum_size = Vector2(icon_sz, icon_sz)
	if _lp_h != null:
		_lp_h.add_theme_constant_override("separation", 4 if is_tiny else (6 if is_portrait else 8))
	if _left_pill != null:
		_left_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_BRASS, 10 if is_tiny else 12, 2, 4 if is_tiny else 6))
	for stat_lbl in [_kills_lbl, _bosses_lbl, _gold_lbl]:
		if stat_lbl != null:
			stat_lbl.add_theme_font_size_override("font_size", 12 if is_tiny else 14)

	if _phase_lbl != null:
		_phase_lbl.visible = not is_portrait
	if _next_shop_lbl != null:
		_next_shop_lbl.visible = vp.x >= 920.0
	if _next_boss_lbl != null:
		_next_boss_lbl.visible = not is_portrait
	if _clock_pill != null:
		_clock_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 10 if is_tiny else 12, 2, 5 if is_tiny else 7))
	if _cp_h != null:
		_cp_h.add_theme_constant_override("separation", 5 if is_portrait else 10)
	if _phase_icon != null:
		var ph_sz: int = 16 if is_tiny else 20
		_phase_icon.custom_minimum_size = Vector2(ph_sz, ph_sz)

	var hide_kb_hints: bool = is_portrait or _is_mobile_mode
	if _mute_lbl != null:
		_mute_lbl.visible = not hide_kb_hints
	if _pause_lbl != null:
		_pause_lbl.visible = not hide_kb_hints
	var btn_side: int = 36 if is_tiny else 42
	if _mute_btn != null:
		_mute_btn.custom_minimum_size = Vector2(btn_side if hide_kb_hints else 72, btn_side)
	if _pause_btn != null:
		_pause_btn.custom_minimum_size = Vector2(btn_side if hide_kb_hints else 80, btn_side)
	if _top_bar != null:
		_top_bar.offset_top = 8 if (is_portrait or is_short) else 12
		_top_bar.offset_bottom = 48 if (is_portrait or is_short) else 62
		_top_bar.offset_left = 8 if is_portrait else 18
		_top_bar.offset_right = -8 if is_portrait else -18
		_top_bar.add_theme_constant_override("separation", 4 if is_tiny else (6 if is_portrait else 10))
	if _timer_lbl != null:
		_timer_lbl.add_theme_font_size_override("font_size", 14 if is_tiny else (16 if is_portrait else 20))
	if _tut_lbl != null:
		_tut_lbl.add_theme_font_size_override("font_size", 13 if is_portrait else 15)
	if _banner_lbl != null:
		_banner_lbl.add_theme_font_size_override("font_size", 14 if is_portrait else 17)
	if _boss_name_lbl != null:
		_boss_name_lbl.add_theme_font_size_override("font_size", 13 if is_portrait else 15)
	if _boss_hp_bar != null:
		_boss_hp_bar.custom_minimum_size = Vector2(0, 11 if is_portrait else 14)

	if _sub_top_vbox != null:
		_sub_top_vbox.offset_left = 8 if is_portrait else 18
		_sub_top_vbox.offset_right = -96 if is_portrait else -152
		_sub_top_vbox.offset_top = 56 if (is_portrait or is_short) else 70
		_sub_top_vbox.offset_bottom = _sub_top_vbox.offset_top

	if _bl_panel != null and _bl_box != null and _inv_btn != null:
		if is_portrait:
			_bl_box.vertical = false
			_bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
			_bl_panel.offset_left = 8
			_bl_panel.offset_right = -8
			_bl_panel.offset_top = -56
			_bl_panel.offset_bottom = -8
			_hp_bar.custom_minimum_size = Vector2(0, 28)
			_inv_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
			_inv_btn.custom_minimum_size = Vector2(104 if is_tiny else 132, 36)
		else:
			_bl_box.vertical = true
			_bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
			_bl_panel.offset_left = 18
			_bl_panel.offset_right = 296
			_bl_panel.offset_top = -96 if is_short else -104
			_bl_panel.offset_bottom = -10 if is_short else -14
			_hp_bar.custom_minimum_size = Vector2(0, 26 if is_short else 28)
			_inv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_inv_btn.custom_minimum_size = Vector2(0, 36 if is_short else 40)
	if _bc_vbox != null:
		if is_portrait:
			_bc_vbox.offset_left = 8
			_bc_vbox.offset_right = -8
			_bc_vbox.offset_top = -140
			_bc_vbox.offset_bottom = -62
		else:
			_bc_vbox.offset_left = 304
			_bc_vbox.offset_right = -304
			_bc_vbox.offset_top = -96 if is_short else -104
			_bc_vbox.offset_bottom = -10 if is_short else -14
	if _minimap != null:
		if is_portrait:
			_minimap.offset_left = -88
			_minimap.offset_right = -8
			_minimap.offset_top = 56
			_minimap.offset_bottom = 136
		else:
			_minimap.offset_left = -140
			_minimap.offset_right = -18
			_minimap.offset_top = 72
			_minimap.offset_bottom = 194
	if _toast_vbox != null:
		_toast_vbox.offset_left = -196 if is_portrait else -300
		_toast_vbox.offset_right = -8 if is_portrait else -18
		_sync_toast_top()
	if _inv_lbl != null and _unread_loot == 0:
		_inv_lbl.text = "Deck" if (is_portrait or _is_mobile_mode) else "Deck [Tab]"
	if _last_stats != null:
		rebuild_skill_bar(_last_stats)
	if touch_controls != null:
		touch_controls.queue_redraw()

func toggle_fps_visible() -> void:
	if _fps_pill != null:
		_fps_pill.visible = not _fps_pill.visible

func reset_hud(hero_id: String = "shiba") -> void:
	_unread_loot = 0
	_banner_timer = 0.0
	_hud_throttle = 1.0
	_last_phase_name = ""
	_last_inv_text = ""
	_last_relic_count = -1
	_banner_panel.visible = false
	if _relics_hud_hbox != null:
		_relics_hud_hbox.visible = false
		for c in _relics_hud_hbox.get_children():
			_relics_hud_hbox.remove_child(c)
			c.queue_free()
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
	_banner_timer = 3.4
	_sync_toast_top()

func push_toast(text: String, col: Color, icon_tex: Texture2D = null) -> void:
	_sync_toast_top()
	var p: PanelContainer = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.08, 0.07, 0.94), col, 10, 2, 7))
	var h: HBoxContainer = HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	p.add_child(h)
	if icon_tex != null:
		h.add_child(UiHelper.make_icon_rect(icon_tex, 18))
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	lbl.add_theme_color_override("font_color", col)
	h.add_child(lbl)
	_toast_vbox.add_child(p)
	_toasts.append({"node": p, "timer": 3.8})
	while _toasts.size() > 3:
		var old: Dictionary = _toasts.pop_front()
		if is_instance_valid(old["node"]):
			_toast_vbox.remove_child(old["node"])
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
	if stats == null or _skills_hbox == null:
		return
	_last_stats = stats
	for ch in _skills_hbox.get_children():
		_skills_hbox.remove_child(ch)
		ch.queue_free()
	_skill_cards.clear()

	var n_cards: int = stats.active_skill_configs.size()
	var vp_x: float = _safe_vp_size().x
	var avail_w: float = (vp_x - 18.0) if vp_x < 750.0 else maxf(240.0, vp_x - 624.0)
	var sep: int = 6 if n_cards <= 5 else 4
	var card_w: int = clampi(int(floor((avail_w - float(maxi(0, n_cards - 1) * sep)) / float(maxi(1, n_cards)))), 40, 74)
	_skills_hbox.add_theme_constant_override("separation", sep)

	for cfg in stats.active_skill_configs:
		var uid: int = int(cfg["uid"])
		var cid: String = String(cfg["card_id"])
		var card_obj: CardInstance = cfg["card"]
		var r_col: Color = GameEnums.rarity_color(card_obj.rarity)
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(card_w, 72)
		card.clip_contents = true
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, r_col, 10, 2, 4))

		var tip_parts: PackedStringArray = [card_obj.get_display_title(), "%d DMG · %.2fs CD" % [int(round(float(cfg["damage"]))), float(cfg["cooldown"])]]
		for f_item in card_obj.get_forged_summary_counts():
			var cnt_s: String = " x%d" % int(f_item["count"]) if int(f_item["count"]) > 1 else ""
			tip_parts.append("+ %s%s: %s" % [String(f_item["name"]), cnt_s, String(f_item.get("desc", ""))])
		card.tooltip_text = "\n".join(tip_parts)

		var v: VBoxContainer = VBoxContainer.new()
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		v.add_theme_constant_override("separation", 2)
		card.add_child(v)

		var well_center: CenterContainer = CenterContainer.new()
		v.add_child(well_center)
		var well: PanelContainer = PanelContainer.new()
		well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, r_col.darkened(0.25), 6, 1, 2, false))
		well.add_child(UiHelper.make_icon_rect(UiIcons.get_card_art(cid), 22 if card_w < 54 else 28))
		well_center.add_child(well)

		var name_lbl: Label = Label.new()
		var f_cnt: int = card_obj.get_forge_count()
		name_lbl.text = "%s%s" % [String(cfg["short"]), ("+%d" % f_cnt) if f_cnt > 0 else ""]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.clip_text = true
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10 if card_w < 56 else 11)
		name_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		name_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		name_lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.95))
		name_lbl.add_theme_constant_override("outline_size", 2)
		v.add_child(name_lbl)

		if card_w >= 54:
			var pip_center: CenterContainer = CenterContainer.new()
			pip_center.custom_minimum_size = Vector2(0, 10)
			v.add_child(pip_center)
			pip_center.add_child(UiHelper.make_forge_pips_row(f_cnt, card_obj.get_max_forges(stats.bonus_forge_slots), r_col, 5 if card_w < 64 else 7))

		var cd_bar: ProgressBar = ProgressBar.new()
		cd_bar.show_percentage = false
		cd_bar.custom_minimum_size = Vector2(0, 5)
		cd_bar.max_value = 1.0
		UiHelper.style_progress_bar(cd_bar, r_col, UiHelper.BG_WELL, 3)
		v.add_child(cd_bar)

		_skills_hbox.add_child(card)
		_skill_cards[uid] = cd_bar

func update_hud(delta: float, stats: HeroStats, player: PlayerController, wave_dir: WaveDirector, skill_exec: SkillExecutor, loot_mgr: LootManager, cam: Camera3D) -> void:
	if _highlight_bag and _inv_btn != null:
		_pulse_time += delta * 6.0
		var b: float = 0.85 + 0.15 * sin(_pulse_time)
		_inv_btn.modulate = Color(1.0, b, 0.72 * b + 0.28)

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

	var vsize_pop: Vector2 = _safe_vp_size()
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
					var px: float = spos.x - 18.0
					var py: float = spos.y - 12.0
					if px >= 4.0 and py >= 4.0 and px + 44.0 <= vsize_pop.x and py + 28.0 <= vsize_pop.y:
						lbl.position = Vector2(px, py)
						lbl.modulate.a = clampf(pt / 0.35, 0.0, 1.0)
						lbl.visible = true
					else:
						lbl.visible = false
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

	if not _is_tutorial_mode:
		var t: float = wave_dir.elapsed_time
		var mins: int = int(t) / 60
		var secs: int = int(t) % 60
		var is_portrait: bool = get_viewport_rect().size.x < 750.0
		_timer_lbl.text = ("%02d:%02d" % [mins, secs]) if is_portrait else ("%02d:%02d / 20:00" % [mins, secs])
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
		_next_shop_lbl.text = wave_dir.get_next_shop_countdown()
		_next_boss_lbl.text = wave_dir.get_next_boss_countdown()

	_kills_lbl.text = "%d" % wave_dir.kills_count
	_bosses_lbl.text = "%d/3" % wave_dir.bosses_defeated_count
	if _gold_lbl != null:
		_gold_lbl.text = "%dG" % stats.gold
	if _fps_pill.visible:
		_fps_lbl.text = "%d FPS" % int(Engine.get_frames_per_second())
	if _minimap != null:
		_minimap.update_entities(player.global_position, player.get_facing_dir(), wave_dir.enemies, loot_mgr.pickups, ArenaBuilder.ARENA_HALF_SIZE)
	if _relics_hud_hbox != null and stats.owned_relics.size() != _last_relic_count:
		_last_relic_count = stats.owned_relics.size()
		_relics_hud_hbox.visible = not stats.owned_relics.is_empty()
		for c in _relics_hud_hbox.get_children():
			_relics_hud_hbox.remove_child(c)
			c.queue_free()
		for rid in stats.owned_relics:
			var rdef: Dictionary = RelicDatabase.get_def(rid)
			var rar_c: Color = GameEnums.rarity_color(int(rdef.get("rarity", GameEnums.Rarity.UNCOMMON)))
			var badge: PanelContainer = PanelContainer.new()
			badge.tooltip_text = "%s\n%s" % [String(rdef.get("name", rid)), String(rdef.get("desc", ""))]
			badge.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.14, 0.11, 0.20, 0.90), rar_c, 6, 1, 2, false))
			badge.add_child(UiHelper.make_icon_rect(UiIcons.get_relic_art(rid), 22))
			_relics_hud_hbox.add_child(badge)
		_sync_toast_top()

	_hp_bar.max_value = stats.max_hp
	_hp_bar.value = player.current_hp
	_hp_lbl.text = "%d / %d" % [int(ceil(player.current_hp)), int(round(stats.max_hp))]

	var inv_default: String = "Deck" if _is_mobile_mode else "Deck [Tab]"
	var inv_txt: String = "Deck (%d!)" % _unread_loot if _unread_loot > 0 else inv_default
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
	_sync_toast_top()

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
