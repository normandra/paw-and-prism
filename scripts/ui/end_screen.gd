class_name EndScreen
extends Control

signal play_again_requested()
signal title_menu_requested()
signal resume_requested()

var _hdr_banner: PanelContainer = null
var _crest_icon: TextureRect = null
var _title_lbl: Label = null
var _intro_lbl: Label = null
var _stat_cards_grid: GridContainer = null
var _build_vbox: VBoxContainer = null
var _resume_btn: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.02, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(640, 415)
	panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 18))
	center.add_child(panel)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)

	_hdr_banner = PanelContainer.new()
	_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.24, 0.17, 0.10), UiHelper.BORDER_GOLD, 12, 2, 10, false))
	v.add_child(_hdr_banner)

	var hdr_h: HBoxContainer = HBoxContainer.new()
	hdr_h.alignment = BoxContainer.ALIGNMENT_CENTER
	hdr_h.add_theme_constant_override("separation", 12)
	_hdr_banner.add_child(hdr_h)

	_crest_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 42)
	hdr_h.add_child(_crest_icon)

	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_title_lbl, 30, UiHelper.BORDER_GOLD, 4)
	hdr_h.add_child(_title_lbl)

	_intro_lbl = Label.new()
	_intro_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_lbl.add_theme_font_size_override("font_size", 14)
	_intro_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
	v.add_child(_intro_lbl)

	_stat_cards_grid = GridContainer.new()
	_stat_cards_grid.columns = 2
	_stat_cards_grid.add_theme_constant_override("h_separation", 10)
	_stat_cards_grid.add_theme_constant_override("v_separation", 8)
	v.add_child(_stat_cards_grid)

	var build_well: PanelContainer = PanelContainer.new()
	build_well.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 10, false))
	v.add_child(build_well)

	_build_vbox = VBoxContainer.new()
	_build_vbox.add_theme_constant_override("separation", 8)
	build_well.add_child(_build_vbox)

	var btns: HBoxContainer = HBoxContainer.new()
	btns.add_theme_constant_override("separation", 12)
	v.add_child(btns)

	_resume_btn = Button.new()
	_resume_btn.text = "Resume [Esc]"
	_resume_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resume_btn.custom_minimum_size = Vector2(0, 48)
	_resume_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_resume_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	_resume_btn.pressed.connect(func() -> void:
		visible = false
		resume_requested.emit()
	)
	btns.add_child(_resume_btn)

	var again_btn: Button = Button.new()
	again_btn.text = "Play Again"
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	again_btn.custom_minimum_size = Vector2(0, 48)
	again_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(again_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	again_btn.pressed.connect(func() -> void:
		visible = false
		play_again_requested.emit()
	)
	btns.add_child(again_btn)

	var menu_btn: Button = Button.new()
	menu_btn.text = "Title Menu"
	menu_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_btn.custom_minimum_size = Vector2(0, 48)
	menu_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(menu_btn, UiHelper.BG_WALNUT, UiHelper.BORDER_BRASS, 10)
	menu_btn.pressed.connect(func() -> void:
		visible = false
		title_menu_requested.emit()
	)
	btns.add_child(menu_btn)

func show_pause(stats: HeroStats, wave_dir: WaveDirector) -> void:
	_resume_btn.visible = true
	_crest_icon.texture = UiIcons.get_ui_icon("pause")
	_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.14, 0.19, 0.28), Color(0.54, 0.84, 1.0), 12, 2, 10, false))
	_title_lbl.text = "RUN PAUSED"
	_title_lbl.add_theme_color_override("font_color", Color(0.70, 0.92, 1.0))
	_fill_summary(stats, wave_dir, "Take a breather! Tip: Press [Tab] or [I] anytime to equip looted Diablo gear and link PoE Skill & Passive Gems.")
	visible = true

func show_end(victory: bool, stats: HeroStats, wave_dir: WaveDirector) -> void:
	_resume_btn.visible = false
	if victory:
		_crest_icon.texture = UiIcons.get_ui_icon("boss_crown")
		_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.28, 0.20, 0.09), UiHelper.BORDER_GOLD, 12, 2, 10, false))
		_title_lbl.text = "VICTORY! MEADOW SAVED!"
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.36))
		_fill_summary(stats, wave_dir, "You defeated King Bramblehorn and conquered all 3 Bosses of the 20-minute gauntlet!")
	else:
		_crest_icon.texture = UiIcons.get_ui_icon("skull")
		_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.26, 0.10, 0.11), Color(0.94, 0.44, 0.44), 12, 2, 10, false))
		_title_lbl.text = "DEFEATED..."
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.48, 0.48))
		_fill_summary(stats, wave_dir, "Your little hero fought bravely against the endless critter horde!")
	visible = true

func _fill_summary(stats: HeroStats, wave_dir: WaveDirector, intro: String) -> void:
	_intro_lbl.text = intro
	for ch in _stat_cards_grid.get_children():
		ch.queue_free()
	for ch in _build_vbox.get_children():
		ch.queue_free()

	var mins: int = int(wave_dir.elapsed_time) / 60
	var secs: int = int(wave_dir.elapsed_time) % 60
	var hdef: Dictionary = HeroDatabase.get_hero(stats.hero_id)

	var stat_items: Array[Dictionary] = [
		{"icon": UiIcons.get_hero_portrait(stats.hero_id), "label": "Hero", "val": "%s (Lv.%d)" % [String(hdef["hero_name"]), stats.hero_level]},
		{"icon": UiIcons.get_ui_icon("sun_meadow"), "label": "Time Survived", "val": "%02d:%02d / 20:00" % [mins, secs]},
		{"icon": UiIcons.get_ui_icon("boss_crown"), "label": "Bosses Defeated", "val": "%d / 3" % wave_dir.bosses_defeated_count},
		{"icon": UiIcons.get_ui_icon("skull"), "label": "Critters Defeated", "val": "%d" % wave_dir.kills_count},
	]
	for s in stat_items:
		var c: PanelContainer = PanelContainer.new()
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 10, 1, 8, false))
		var ch: HBoxContainer = HBoxContainer.new()
		ch.add_theme_constant_override("separation", 10)
		c.add_child(ch)
		ch.add_child(UiHelper.make_icon_rect(s["icon"], 30))
		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 1)
		ch.add_child(cv)
		var kl: Label = Label.new()
		kl.text = String(s["label"])
		kl.add_theme_font_size_override("font_size", 11)
		kl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		cv.add_child(kl)
		var vl: Label = Label.new()
		vl.text = String(s["val"])
		UiHelper.apply_display_font(vl, 17, UiHelper.TEXT_CREAM, 2)
		cv.add_child(vl)
		_stat_cards_grid.add_child(c)

	var act_hdr: Label = Label.new()
	act_hdr.text = "Linked Active Skills"
	act_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	act_hdr.add_theme_font_size_override("font_size", 13)
	act_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.40))
	_build_vbox.add_child(act_hdr)

	for cfg in stats.active_skill_configs:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_build_vbox.add_child(row)
		row.add_child(UiHelper.make_icon_rect(UiIcons.get_skill_icon(String(cfg["gem_id"])), 22))
		var slbl: Label = Label.new()
		slbl.text = "%s Lv.%d" % [String(cfg["gem_name"]), int(cfg["effective_level"])]
		slbl.add_theme_font_override("font", UiHelper.get_bold_font())
		slbl.add_theme_font_size_override("font_size", 13)
		slbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		row.add_child(slbl)
		var sups: Array = cfg["linked_support_names"]
		for sup_s in sups:
			row.add_child(UiHelper.make_badge_pill(String(sup_s), UiHelper.BG_WALNUT, UiHelper.BORDER_GOLD, Color(1.0, 0.90, 0.50), 10))

	var pas_hdr: Label = Label.new()
	pas_hdr.text = "Socketed Passive Gems"
	pas_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	pas_hdr.add_theme_font_size_override("font_size", 13)
	pas_hdr.add_theme_color_override("font_color", Color(0.66, 0.94, 0.70))
	_build_vbox.add_child(pas_hdr)

	var pas_row: HFlowContainer = HFlowContainer.new()
	pas_row.add_theme_constant_override("h_separation", 8)
	pas_row.add_theme_constant_override("v_separation", 4)
	_build_vbox.add_child(pas_row)
	for p_info in stats.active_passives:
		var pg: GemInstance = p_info["gem"]
		var gcol: Color = GameEnums.gem_color_value(pg.get_gem_color())
		var chip: PanelContainer = PanelContainer.new()
		chip.add_theme_stylebox_override("panel", UiHelper.make_panel_box(gcol.darkened(0.68), gcol, 7, 1, 5, false))
		var ch_h: HBoxContainer = HBoxContainer.new()
		ch_h.add_theme_constant_override("separation", 5)
		chip.add_child(ch_h)
		ch_h.add_child(UiHelper.make_icon_rect(UiIcons.get_gem_icon(GameEnums.GemType.PASSIVE, pg.get_gem_color()), 16))
		var pl: Label = Label.new()
		pl.text = "%s Lv.%d" % [pg.get_gem_name(), int(p_info["effective_level"])]
		pl.add_theme_font_override("font", UiHelper.get_bold_font())
		pl.add_theme_font_size_override("font_size", 12)
		pl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		ch_h.add_child(pl)
		pas_row.add_child(chip)
