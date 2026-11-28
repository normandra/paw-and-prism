class_name EndScreen
extends Control

signal play_again_requested()
signal title_menu_requested()
signal resume_requested()
signal tutorial_start_run_requested()

var _panel: PanelContainer = null
var _hdr_banner: PanelContainer = null
var _crest_icon: TextureRect = null
var _title_lbl: Label = null
var _intro_lbl: Label = null
var _stat_cards_grid: GridContainer = null
var _build_vbox: VBoxContainer = null
var _resume_btn: Button = null
var _again_btn: Button = null
var _start_run_btn: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()
	_apply_responsive_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _panel != null:
		_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 10.0 or _panel == null:
		return
	var is_portrait: bool = vp.x < 750.0
	_panel.custom_minimum_size = Vector2(minf(vp.x - 20.0, 640.0), minf(vp.y - 32.0, 540.0) if is_portrait else 420.0)

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.02, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(640, 420)
	_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 18))
	center.add_child(_panel)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_panel.add_child(v)

	_hdr_banner = PanelContainer.new()
	_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.24, 0.17, 0.10), UiHelper.BORDER_GOLD, 12, 2, 10, false))
	v.add_child(_hdr_banner)

	var hdr_h: HBoxContainer = HBoxContainer.new()
	hdr_h.alignment = BoxContainer.ALIGNMENT_CENTER
	hdr_h.add_theme_constant_override("separation", 12)
	_hdr_banner.add_child(hdr_h)

	_crest_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("boss_crown"), 40)
	hdr_h.add_child(_crest_icon)

	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_title_lbl, 28, UiHelper.BORDER_GOLD, 4)
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

	var build_scroll: TouchScrollContainer = TouchScrollContainer.new()
	build_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_well.add_child(build_scroll)

	_build_vbox = VBoxContainer.new()
	_build_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build_vbox.add_theme_constant_override("separation", 8)
	build_scroll.add_child(_build_vbox)

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

	_start_run_btn = Button.new()
	_start_run_btn.text = "Start 20-Min Run"
	_start_run_btn.visible = false
	_start_run_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_start_run_btn.custom_minimum_size = Vector2(0, 48)
	_start_run_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_start_run_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	_start_run_btn.pressed.connect(func() -> void:
		visible = false
		tutorial_start_run_requested.emit()
	)
	btns.add_child(_start_run_btn)

	_again_btn = Button.new()
	_again_btn.text = "Play Again"
	_again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_again_btn.custom_minimum_size = Vector2(0, 48)
	_again_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_again_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	_again_btn.pressed.connect(func() -> void:
		visible = false
		play_again_requested.emit()
	)
	btns.add_child(_again_btn)

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
	_again_btn.visible = true
	_start_run_btn.visible = false
	_crest_icon.texture = UiIcons.get_ui_icon("pause")
	_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.14, 0.19, 0.28), Color(0.54, 0.84, 1.0), 12, 2, 10, false))
	_title_lbl.text = "RUN PAUSED"
	_title_lbl.add_theme_color_override("font_color", Color(0.70, 0.92, 1.0))
	_fill_summary(stats, wave_dir, "Press [Tab] anytime to view Relics, equip Template Cards, and forge Add-ons.")
	visible = true

func show_end(victory: bool, stats: HeroStats, wave_dir: WaveDirector) -> void:
	_resume_btn.visible = false
	_again_btn.visible = true
	_start_run_btn.visible = false
	if victory:
		_crest_icon.texture = UiIcons.get_ui_icon("boss_crown")
		_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.28, 0.20, 0.09), UiHelper.BORDER_GOLD, 12, 2, 10, false))
		_title_lbl.text = "VICTORY! MEADOW SAVED!"
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.36))
		_fill_summary(stats, wave_dir, "All 3 Bosses defeated across the 20-minute gauntlet!")
	else:
		_crest_icon.texture = UiIcons.get_ui_icon("skull")
		_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.26, 0.10, 0.11), Color(0.94, 0.44, 0.44), 12, 2, 10, false))
		_title_lbl.text = "DEFEATED..."
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.48, 0.48))
		_fill_summary(stats, wave_dir, "Mochi fought bravely against the critter horde!")
	visible = true

func show_tutorial_complete(stats: HeroStats, wave_dir: WaveDirector) -> void:
	_resume_btn.visible = false
	_again_btn.visible = false
	_start_run_btn.visible = true
	_crest_icon.texture = UiIcons.get_ui_icon("star_upgrade")
	_hdr_banner.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.14, 0.28, 0.16), Color(0.48, 0.94, 0.56), 12, 2, 10, false))
	_title_lbl.text = "TUTORIAL COMPLETE!"
	_title_lbl.add_theme_color_override("font_color", Color(0.68, 1.0, 0.72))
	_fill_summary(stats, wave_dir, "Collected Gold -> Shopped -> Forged Permanent Add-on!")
	visible = true

func _fill_summary(stats: HeroStats, wave_dir: WaveDirector, intro: String) -> void:
	_intro_lbl.text = intro
	for ch in _stat_cards_grid.get_children():
		ch.queue_free()
	for ch in _build_vbox.get_children():
		ch.queue_free()

	var mins: int = int(wave_dir.elapsed_time) / 60 if wave_dir != null else 0
	var secs: int = int(wave_dir.elapsed_time) % 60 if wave_dir != null else 0
	var kills: int = wave_dir.kills_count if wave_dir != null else 0
	var bosses: int = wave_dir.bosses_defeated_count if wave_dir != null else 0
	var hdef: Dictionary = HeroDatabase.get_hero("shiba")

	var stat_items: Array[Dictionary] = [
		{"icon": UiIcons.get_hero_portrait("shiba"), "label": "Hero", "val": String(hdef["hero_name"])},
		{"icon": UiIcons.get_ui_icon("sun_meadow"), "label": "Time", "val": "%02d:%02d / 20:00" % [mins, secs]},
		{"icon": UiIcons.get_ui_icon("boss_crown"), "label": "Bosses", "val": "%d / 3" % bosses},
		{"icon": UiIcons.get_ui_icon("skull"), "label": "Critters", "val": "%d" % kills},
		{"icon": UiIcons.get_ui_icon("gold_coin"), "label": "Gold Earned", "val": "%d G (%d G Left)" % [stats.total_gold_earned, stats.gold]},
		{"icon": UiIcons.get_ui_icon("star_upgrade"), "label": "Relics", "val": "%d Owned" % stats.owned_relics.size()},
	]
	for s in stat_items:
		var c: PanelContainer = PanelContainer.new()
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, 10, 1, 8, false))
		var ch: HBoxContainer = HBoxContainer.new()
		ch.add_theme_constant_override("separation", 10)
		c.add_child(ch)
		ch.add_child(UiHelper.make_icon_rect(s["icon"], 28))
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
		UiHelper.apply_display_font(vl, 16, UiHelper.TEXT_CREAM, 2)
		cv.add_child(vl)
		_stat_cards_grid.add_child(c)

	var act_hdr: Label = Label.new()
	act_hdr.text = "Active Forged Deck (%d Equipped)" % stats.equipped_cards.size()
	act_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	act_hdr.add_theme_font_size_override("font_size", 13)
	act_hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.40))
	_build_vbox.add_child(act_hdr)

	if stats.equipped_cards.is_empty():
		var none_lbl: Label = Label.new()
		none_lbl.text = "No cards equipped"
		none_lbl.add_theme_font_size_override("font_size", 12)
		none_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		_build_vbox.add_child(none_lbl)
	else:
		for card in stats.equipped_cards:
			var r_col: Color = GameEnums.rarity_color(card.rarity)
			var row: HBoxContainer = HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			_build_vbox.add_child(row)
			row.add_child(UiHelper.make_icon_rect(UiIcons.get_card_art(card.card_id), 24))
			var slbl: Label = Label.new()
			slbl.text = "%s (%d/%d)" % [card.get_display_title(), card.get_forge_count(), card.get_max_forges(stats.bonus_forge_slots)]
			slbl.add_theme_font_override("font", UiHelper.get_bold_font())
			slbl.add_theme_font_size_override("font_size", 13)
			slbl.add_theme_color_override("font_color", r_col.lightened(0.25))
			row.add_child(slbl)
			for entry in card.get_forged_summary_counts():
				var cnt: int = int(entry["count"])
				var txt: String = "%s%s" % [String(entry["name"]), (" x%d" % cnt) if cnt > 1 else ""]
				var pill: PanelContainer = UiHelper.make_badge_pill(txt, UiHelper.BG_WALNUT, UiHelper.BORDER_GOLD, Color(1.0, 0.90, 0.50), 10)
				pill.tooltip_text = String(entry.get("desc", ""))
				row.add_child(pill)

	if not stats.owned_relics.is_empty():
		var rel_hdr: Label = Label.new()
		rel_hdr.text = "Collected Relics (%d)" % stats.owned_relics.size()
		rel_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
		rel_hdr.add_theme_font_size_override("font_size", 13)
		rel_hdr.add_theme_color_override("font_color", Color(0.88, 0.72, 1.0))
		_build_vbox.add_child(rel_hdr)
		var r_flow: HFlowContainer = HFlowContainer.new()
		r_flow.add_theme_constant_override("h_separation", 6)
		r_flow.add_theme_constant_override("v_separation", 4)
		_build_vbox.add_child(r_flow)
		for rid in stats.owned_relics:
			var rdef: Dictionary = RelicDatabase.get_def(rid)
			var rar_c: Color = GameEnums.rarity_color(int(rdef.get("rarity", GameEnums.Rarity.UNCOMMON)))
			var rpill: PanelContainer = UiHelper.make_badge_pill(String(rdef.get("name", rid)), rar_c.darkened(0.70), rar_c, rar_c.lightened(0.35), 10)
			rpill.tooltip_text = String(rdef.get("desc", ""))
			r_flow.add_child(rpill)
