class_name InventoryPanel
extends Control

signal closed()
signal gear_changed()
signal sfx_requested(sfx_name: String)

var _stats: HeroStats = null

var _frame: PanelContainer = null
var _title_lbl: Label = null
var _close_btn: Button = null
var _tut_banner_panel: PanelContainer = null
var _tut_banner_lbl: Label = null
var _cols: BoxContainer = null
var _left_box: PanelContainer = null
var _left_build_vbox: VBoxContainer = null
var _center_box: PanelContainer = null
var _center_slots_vbox: VBoxContainer = null
var _right_box: PanelContainer = null

var _tab_items_btn: Button = null
var _tab_main_btn: Button = null
var _tab_mods_btn: Button = null
var _tab_build_btn: Button = null
var _right_content_vbox: VBoxContainer = null

var _active_right_tab: String = "items"
var _selected_bag_idx: int = -1
var _selected_pouch_idx: int = -1
var _tutorial_hint: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_shell()
	_clamp_frame_size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_clamp_frame_size()

func set_tutorial_hint(hint: String) -> void:
	_tutorial_hint = hint
	if _tut_banner_panel != null and _tut_banner_lbl != null:
		_tut_banner_panel.visible = not hint.is_empty()
		_tut_banner_lbl.text = hint
	if hint.begins_with("Main tab"):
		_active_right_tab = "main"
	elif hint.begins_with("Mods tab"):
		_active_right_tab = "mods"
	elif hint.begins_with("Items tab"):
		_active_right_tab = "items"

func _clamp_frame_size() -> void:
	if _frame == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 10.0 or vp.y <= 10.0:
		vp = Vector2(1280.0, 720.0)
	var is_portrait: bool = vp.x < 960.0
	if is_portrait:
		_frame.custom_minimum_size = Vector2(vp.x - 24.0, vp.y - 36.0)
		if _cols != null:
			_cols.vertical = true
		if _left_box != null:
			_left_box.visible = false
		if _tab_build_btn != null:
			_tab_build_btn.visible = true
		if _title_lbl != null:
			_title_lbl.text = "SATCHEL"
		if _close_btn != null:
			_close_btn.text = "Resume"
			_close_btn.custom_minimum_size = Vector2(106, 40)
	else:
		_frame.custom_minimum_size = Vector2(minf(vp.x - 48.0, 1220.0), minf(vp.y - 40.0, 680.0))
		if _cols != null:
			_cols.vertical = false
		if _left_box != null:
			_left_box.visible = true
		if _tab_build_btn != null:
			_tab_build_btn.visible = false
		if _title_lbl != null:
			_title_lbl.text = "HERO SATCHEL"
		if _close_btn != null:
			_close_btn.text = "Resume [Tab / Esc]"
			_close_btn.custom_minimum_size = Vector2(175, 40)
		if _active_right_tab == "build":
			_active_right_tab = "items"
			if visible and _stats != null:
				refresh()

func _build_shell() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.02, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_frame = PanelContainer.new()
	_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 14))
	center.add_child(_frame)

	var root_v: VBoxContainer = VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	_frame.add_child(root_v)

	# Header Row
	var hdr: HBoxContainer = HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 12)
	root_v.add_child(hdr)

	hdr.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 32))

	_title_lbl = Label.new()
	_title_lbl.text = "HERO SATCHEL"
	UiHelper.apply_display_font(_title_lbl, 22, UiHelper.BORDER_GOLD, 3)
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.clip_text = true
	hdr.add_child(_title_lbl)

	_close_btn = Button.new()
	_close_btn.text = "Resume [Tab / Esc]"
	_close_btn.custom_minimum_size = Vector2(175, 40)
	_close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_close_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	_close_btn.pressed.connect(func() -> void: close_panel())
	hdr.add_child(_close_btn)

	# Optional Tutorial Step Banner
	_tut_banner_panel = PanelContainer.new()
	_tut_banner_panel.visible = false
	_tut_banner_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.28, 0.20, 0.08), UiHelper.BORDER_GOLD, 10, 2, 8, false))
	root_v.add_child(_tut_banner_panel)
	var tb_h: HBoxContainer = HBoxContainer.new()
	tb_h.add_theme_constant_override("separation", 8)
	_tut_banner_panel.add_child(tb_h)
	tb_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 20))
	_tut_banner_lbl = Label.new()
	_tut_banner_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_tut_banner_lbl.add_theme_font_size_override("font_size", 14)
	_tut_banner_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
	tb_h.add_child(_tut_banner_lbl)

	# Responsive 3-Column / Stacked Body
	_cols = BoxContainer.new()
	_cols.vertical = false
	_cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cols.add_theme_constant_override("separation", 12)
	root_v.add_child(_cols)

	# === LEFT COLUMN: Active Skills & Behavioral Global Effects ===
	_left_box = PanelContainer.new()
	_left_box.custom_minimum_size = Vector2(290, 0)
	_left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_box.size_flags_stretch_ratio = 0.88
	_left_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	_cols.add_child(_left_box)

	var left_v: VBoxContainer = VBoxContainer.new()
	left_v.add_theme_constant_override("separation", 8)
	_left_box.add_child(left_v)

	var lh_lbl: Label = Label.new()
	lh_lbl.text = "Active Build"
	UiHelper.apply_display_font(lh_lbl, 16, UiHelper.BORDER_GOLD, 2)
	left_v.add_child(lh_lbl)

	var left_scroll: ScrollContainer = ScrollContainer.new()
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_v.add_child(left_scroll)

	_left_build_vbox = VBoxContainer.new()
	_left_build_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_build_vbox.add_theme_constant_override("separation", 8)
	left_scroll.add_child(_left_build_vbox)

	# === CENTER COLUMN: 6 Equipment Slots + Fixed Linked Sockets ===
	_center_box = PanelContainer.new()
	_center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_center_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_center_box.size_flags_stretch_ratio = 1.25
	_center_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	_cols.add_child(_center_box)

	var center_v: VBoxContainer = VBoxContainer.new()
	center_v.add_theme_constant_override("separation", 7)
	_center_box.add_child(center_v)

	var center_hint: Label = Label.new()
	center_hint.text = "Select Main or Mod -> click pulsing socket  |  Click filled socket to remove"
	center_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center_hint.add_theme_font_size_override("font_size", 11)
	center_hint.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
	center_v.add_child(center_hint)

	var slots_scroll: ScrollContainer = ScrollContainer.new()
	slots_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_v.add_child(slots_scroll)

	_center_slots_vbox = VBoxContainer.new()
	_center_slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_center_slots_vbox.add_theme_constant_override("separation", 7)
	slots_scroll.add_child(_center_slots_vbox)

	# === RIGHT COLUMN: 3 Loot Type Tabs + Build (Portrait) ===
	_right_box = PanelContainer.new()
	_right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_box.size_flags_stretch_ratio = 1.15
	_right_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	_cols.add_child(_right_box)

	var right_v: VBoxContainer = VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	_right_box.add_child(right_v)

	var tab_row: HBoxContainer = HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 6)
	right_v.add_child(tab_row)

	_tab_items_btn = _make_tab_button("items")
	tab_row.add_child(_tab_items_btn)
	_tab_main_btn = _make_tab_button("main")
	tab_row.add_child(_tab_main_btn)
	_tab_mods_btn = _make_tab_button("mods")
	tab_row.add_child(_tab_mods_btn)
	_tab_build_btn = _make_tab_button("build")
	_tab_build_btn.text = "Build"
	_tab_build_btn.visible = false
	tab_row.add_child(_tab_build_btn)

	_right_content_vbox = VBoxContainer.new()
	_right_content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_theme_constant_override("separation", 7)
	right_v.add_child(_right_content_vbox)

func _make_tab_button(tab_key: String) -> Button:
	var btn: Button = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 36)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func() -> void:
		_active_right_tab = tab_key
		_selected_bag_idx = -1
		_selected_pouch_idx = -1
		refresh()
	)
	return btn

func open_panel(stats: HeroStats) -> void:
	_stats = stats
	_selected_bag_idx = -1
	_selected_pouch_idx = -1
	visible = true
	set_tutorial_hint(_tutorial_hint)
	_clamp_frame_size()
	refresh()

func close_panel() -> void:
	visible = false
	_selected_pouch_idx = -1
	closed.emit()

func refresh() -> void:
	if _stats == null:
		return
	var main_count: int = _stats.get_pouch_gems(GameEnums.GemType.MAIN).size()
	var mod_count: int = _stats.get_pouch_gems(GameEnums.GemType.MODIFIER).size()
	_tab_items_btn.text = "Items (%d)" % _stats.item_bag.size()
	_tab_main_btn.text = "Main (%d)" % main_count
	_tab_mods_btn.text = "Mods (%d)" % mod_count

	for pair in [[_tab_items_btn, "items"], [_tab_main_btn, "main"], [_tab_mods_btn, "mods"], [_tab_build_btn, "build"]]:
		var btn: Button = pair[0]
		var key: String = pair[1]
		if btn != null:
			UiHelper.style_button(
				btn,
				UiHelper.BG_OAK_CARD if _active_right_tab == key else UiHelper.BG_WELL,
				UiHelper.BORDER_GOLD if _active_right_tab == key else UiHelper.BORDER_BRASS,
				9,
				6
			)

	_refresh_left_build()
	_refresh_center_slots()
	_refresh_right_column()

func _refresh_left_build() -> void:
	for ch in _left_build_vbox.get_children():
		ch.queue_free()
	_populate_build_vbox(_left_build_vbox)

func _populate_build_vbox(container: VBoxContainer) -> void:
	var s: HeroStats = _stats
	var hdef: Dictionary = HeroDatabase.get_hero(s.hero_id)

	var hero_card: PanelContainer = PanelContainer.new()
	hero_card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 10, 1, 8, false))
	container.add_child(hero_card)
	var hh: HBoxContainer = HBoxContainer.new()
	hh.add_theme_constant_override("separation", 10)
	hero_card.add_child(hh)
	hh.add_child(UiHelper.make_icon_rect(UiIcons.get_hero_portrait(s.hero_id), 40))
	var hv: VBoxContainer = VBoxContainer.new()
	hv.add_theme_constant_override("separation", 4)
	hh.add_child(hv)
	var hn: Label = Label.new()
	hn.text = String(hdef["hero_name"])
	UiHelper.apply_display_font(hn, 15, Color(1.0, 0.88, 0.42), 2)
	hv.add_child(hn)

	var vitals_h: HBoxContainer = HBoxContainer.new()
	vitals_h.add_theme_constant_override("separation", 10)
	hv.add_child(vitals_h)
	for pair in [["heart", "%d" % int(round(s.max_hp))], ["dash_paw", "%.1f | %dx" % [s.move_speed, s.dash_max_charges]]]:
		var vp: HBoxContainer = HBoxContainer.new()
		vp.add_theme_constant_override("separation", 4)
		vp.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon(pair[0]), 14))
		var vl: Label = Label.new()
		vl.text = pair[1]
		vl.add_theme_font_size_override("font_size", 12)
		vl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		vp.add_child(vl)
		vitals_h.add_child(vp)

	# Linked Active Skills
	var sk_hdr: Label = Label.new()
	sk_hdr.text = "ACTIVE ABILITIES (%d)" % s.active_skill_configs.size()
	sk_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	sk_hdr.add_theme_font_size_override("font_size", 12)
	sk_hdr.add_theme_color_override("font_color", Color(0.56, 0.90, 1.0))
	container.add_child(sk_hdr)

	if s.active_skill_configs.is_empty():
		var emp_s: Label = Label.new()
		emp_s.text = "None socketed yet."
		emp_s.add_theme_font_size_override("font_size", 12)
		emp_s.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		container.add_child(emp_s)
	else:
		for cfg in s.active_skill_configs:
			var gcol: Color = GameEnums.gem_color_value(int(cfg["color"]))
			var sc: PanelContainer = PanelContainer.new()
			sc.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, gcol.darkened(0.2), 9, 1, 7, false))
			container.add_child(sc)
			var sv: VBoxContainer = VBoxContainer.new()
			sv.add_theme_constant_override("separation", 4)
			sc.add_child(sv)
			var sh: HBoxContainer = HBoxContainer.new()
			sh.add_theme_constant_override("separation", 8)
			sv.add_child(sh)
			sh.add_child(UiHelper.make_icon_rect(UiIcons.get_skill_icon(String(cfg["gem_id"])), 24))
			var sn: Label = Label.new()
			sn.text = "%s" % String(cfg["gem_name"])
			sn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sn.add_theme_font_override("font", UiHelper.get_bold_font())
			sn.add_theme_font_size_override("font_size", 13)
			sn.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
			sh.add_child(sn)
			var stats_p: Label = Label.new()
			stats_p.text = "%.0f | %.2fs" % [float(cfg["damage"]), float(cfg["cooldown"])]
			stats_p.add_theme_font_size_override("font_size", 11)
			stats_p.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
			sh.add_child(stats_p)

			var mod_names: Array = cfg.get("linked_mod_names", [])
			var mod_cols: Array = cfg.get("linked_mod_colors", [])
			if not mod_names.is_empty():
				var mr: HFlowContainer = HFlowContainer.new()
				mr.add_theme_constant_override("h_separation", 4)
				mr.add_theme_constant_override("v_separation", 4)
				sv.add_child(mr)
				for k in range(mod_names.size()):
					var mcol: Color = GameEnums.gem_color_value(int(mod_cols[k]))
					mr.add_child(UiHelper.make_badge_pill(String(mod_names[k]), mcol.darkened(0.65), mcol, UiHelper.TEXT_CREAM, 10))

	# Global Effects
	var ef_hdr: Label = Label.new()
	ef_hdr.text = "GLOBAL EFFECTS (%d)" % s.active_effect_list.size()
	ef_hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	ef_hdr.add_theme_font_size_override("font_size", 12)
	ef_hdr.add_theme_color_override("font_color", Color(1.0, 0.86, 0.44))
	container.add_child(ef_hdr)

	if s.active_effect_list.is_empty():
		var emp_e: Label = Label.new()
		emp_e.text = "Equip Relics to gain Global Effects."
		emp_e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		emp_e.add_theme_font_size_override("font_size", 12)
		emp_e.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		container.add_child(emp_e)
	else:
		var ef_list: VBoxContainer = VBoxContainer.new()
		ef_list.add_theme_constant_override("separation", 5)
		container.add_child(ef_list)
		for eid in s.active_effect_list:
			var chip: PanelContainer = UiHelper.make_effect_chip(String(eid), false)
			chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			ef_list.add_child(chip)

func _refresh_center_slots() -> void:
	for ch in _center_slots_vbox.get_children():
		ch.queue_free()

	var sel_gem: GemInstance = null
	if _selected_pouch_idx >= 0 and _selected_pouch_idx < _stats.gem_pouch.size():
		sel_gem = _stats.gem_pouch[_selected_pouch_idx]

	for slot in [
		GameEnums.EquipSlot.WEAPON,
		GameEnums.EquipSlot.HELMET,
		GameEnums.EquipSlot.ARMOR,
		GameEnums.EquipSlot.BOOTS,
		GameEnums.EquipSlot.AMULET,
		GameEnums.EquipSlot.RING,
	]:
		var item: ItemInstance = _stats.equipped.get(slot, null)
		var b_col: Color = UiHelper.rarity_border_color(item.rarity) if item != null else UiHelper.BORDER_SUBTLE
		var r_col: Color = GameEnums.rarity_color(item.rarity) if item != null else Color(0.55, 0.50, 0.45)

		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, b_col, 10, 1, 8, false))
		_center_slots_vbox.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 5)
		card.add_child(cv)

		var hdr_panel: PanelContainer = PanelContainer.new()
		hdr_panel.add_theme_stylebox_override("panel", UiHelper.make_accent_card_box(UiHelper.BG_OAK_CARD if item != null else UiHelper.BG_WELL, b_col, 8, 7))
		cv.add_child(hdr_panel)

		var hh: HBoxContainer = HBoxContainer.new()
		hh.add_theme_constant_override("separation", 8)
		hdr_panel.add_child(hh)
		hh.add_child(UiHelper.make_icon_rect(UiIcons.get_slot_icon(slot), 24))

		var hv: VBoxContainer = VBoxContainer.new()
		hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hv.add_theme_constant_override("separation", 4)
		hh.add_child(hv)

		var top_r: HBoxContainer = HBoxContainer.new()
		top_r.add_theme_constant_override("separation", 6)
		hv.add_child(top_r)

		var name_lbl: Label = Label.new()
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", r_col)
		name_lbl.text = ("%s: Empty" % GameEnums.slot_label(slot)) if item == null else item.item_name
		top_r.add_child(name_lbl)

		if item != null:
			top_r.add_child(UiHelper.make_badge_pill(GameEnums.rarity_label(item.rarity), r_col.darkened(0.68), r_col, UiHelper.TEXT_CREAM, 10))
			if not item.effects.is_empty():
				var ef_flow: HFlowContainer = HFlowContainer.new()
				ef_flow.add_theme_constant_override("h_separation", 5)
				ef_flow.add_theme_constant_override("v_separation", 4)
				hv.add_child(ef_flow)
				for eid in item.effects:
					ef_flow.add_child(UiHelper.make_effect_chip(String(eid), true))

		if item != null:
			var sock_widget: PoESocketWidget = PoESocketWidget.new()
			sock_widget.configure(slot, item, sel_gem)
			sock_widget.socket_clicked.connect(_on_socket_clicked)
			cv.add_child(sock_widget)

func _refresh_right_column() -> void:
	for ch in _right_content_vbox.get_children():
		ch.queue_free()

	match _active_right_tab:
		"items":
			_build_items_tab()
		"main":
			_build_gems_tab(GameEnums.GemType.MAIN)
		"mods":
			_build_gems_tab(GameEnums.GemType.MODIFIER)
		"build":
			var b_well: PanelContainer = PanelContainer.new()
			b_well.size_flags_vertical = Control.SIZE_EXPAND_FILL
			b_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 10, false))
			_right_content_vbox.add_child(b_well)
			var b_scroll: ScrollContainer = ScrollContainer.new()
			b_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
			b_well.add_child(b_scroll)
			var bv: VBoxContainer = VBoxContainer.new()
			bv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bv.add_theme_constant_override("separation", 8)
			b_scroll.add_child(bv)
			_populate_build_vbox(bv)

func _build_items_tab() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_child(scroll)

	var list_v: VBoxContainer = VBoxContainer.new()
	list_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_v.add_theme_constant_override("separation", 6)
	scroll.add_child(list_v)

	if _stats.item_bag.is_empty():
		var emp_box: PanelContainer = PanelContainer.new()
		emp_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 14, false))
		var emp: Label = Label.new()
		emp.text = "No Relics in bag yet."
		emp.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		emp_box.add_child(emp)
		list_v.add_child(emp_box)
	else:
		for i in range(_stats.item_bag.size()):
			var it: ItemInstance = _stats.item_bag[i]
			var r_col: Color = GameEnums.rarity_color(it.rarity)
			var b_col: Color = UiHelper.rarity_border_color(it.rarity)
			var is_sel: bool = (i == _selected_bag_idx)

			var row_card: PanelContainer = PanelContainer.new()
			row_card.mouse_filter = Control.MOUSE_FILTER_STOP
			row_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			row_card.add_theme_stylebox_override(
				"panel",
				UiHelper.make_accent_card_box(UiHelper.BG_OAK_CARD if not is_sel else Color(0.30, 0.23, 0.16), Color(1.0, 0.90, 0.36) if is_sel else b_col, 8, 8)
			)
			var idx_cap: int = i
			row_card.gui_input.connect(func(ev: InputEvent) -> void:
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
					_selected_bag_idx = idx_cap
					sfx_requested.emit("ui_click")
					refresh()
			)
			list_v.add_child(row_card)

			var rv: VBoxContainer = VBoxContainer.new()
			rv.add_theme_constant_override("separation", 4)
			rv.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row_card.add_child(rv)

			var top_h: HBoxContainer = HBoxContainer.new()
			top_h.add_theme_constant_override("separation", 8)
			top_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rv.add_child(top_h)
			top_h.add_child(UiHelper.make_icon_rect(UiIcons.get_slot_icon(it.equip_slot), 22))
			var nl: Label = Label.new()
			nl.text = it.item_name
			nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			nl.add_theme_font_override("font", UiHelper.get_bold_font())
			nl.add_theme_font_size_override("font_size", 13)
			nl.add_theme_color_override("font_color", r_col)
			top_h.add_child(nl)

			var mini_sw: PoESocketWidget = PoESocketWidget.new()
			mini_sw.configure_mini(it)
			top_h.add_child(mini_sw)

			if not it.effects.is_empty():
				var ef_row: HFlowContainer = HFlowContainer.new()
				ef_row.add_theme_constant_override("h_separation", 4)
				ef_row.add_theme_constant_override("v_separation", 4)
				ef_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
				rv.add_child(ef_row)
				for eid in it.effects:
					ef_row.add_child(UiHelper.make_effect_chip(String(eid), true))

	# Selected Item Visual Tradeoff Inspector
	if _selected_bag_idx >= 0 and _selected_bag_idx < _stats.item_bag.size():
		var sel_item: ItemInstance = _stats.item_bag[_selected_bag_idx]
		var cur_item: ItemInstance = _stats.equipped.get(sel_item.equip_slot, null)
		var r_col: Color = GameEnums.rarity_color(sel_item.rarity)

		var cmp_box: PanelContainer = PanelContainer.new()
		cmp_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, r_col, 10, 2, 10, false))
		_right_content_vbox.add_child(cmp_box)

		var cmp_v: VBoxContainer = VBoxContainer.new()
		cmp_v.add_theme_constant_override("separation", 6)
		cmp_box.add_child(cmp_v)

		var hdr_row: HBoxContainer = HBoxContainer.new()
		hdr_row.add_theme_constant_override("separation", 8)
		cmp_v.add_child(hdr_row)
		var new_n: Label = Label.new()
		new_n.text = "%s (%s)" % [sel_item.item_name, sel_item.get_socket_summary_text()]
		new_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_n.add_theme_font_override("font", UiHelper.get_bold_font())
		new_n.add_theme_font_size_override("font_size", 13)
		new_n.add_theme_color_override("font_color", r_col)
		hdr_row.add_child(new_n)

		var cur_txt: String = "vs Empty" if cur_item == null else ("vs %s (%s)" % [cur_item.item_name, cur_item.get_socket_summary_text()])
		var vs_lbl: Label = Label.new()
		vs_lbl.text = cur_txt
		vs_lbl.add_theme_font_size_override("font_size", 11)
		vs_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		cmp_v.add_child(vs_lbl)

		# Tradeoff Diff Effect Chips (+ Gained / - Lost / = Shared)
		var diff_flow: HFlowContainer = HFlowContainer.new()
		diff_flow.add_theme_constant_override("h_separation", 5)
		diff_flow.add_theme_constant_override("v_separation", 5)
		cmp_v.add_child(diff_flow)

		var cur_effects: Array[String] = cur_item.effects if cur_item != null else []
		for eid in sel_item.effects:
			if eid in cur_effects:
				diff_flow.add_child(UiHelper.make_effect_chip(eid, true, "= "))
			else:
				diff_flow.add_child(UiHelper.make_effect_chip(eid, true, "+ ", Color(0.40, 0.94, 0.56)))
		for eid in cur_effects:
			if not (eid in sel_item.effects):
				diff_flow.add_child(UiHelper.make_effect_chip(eid, true, "- ", Color(0.96, 0.44, 0.44)))

		var btns_h: HBoxContainer = HBoxContainer.new()
		btns_h.add_theme_constant_override("separation", 8)
		cmp_v.add_child(btns_h)

		var eq_btn: Button = Button.new()
		eq_btn.text = "Equip"
		eq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eq_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(eq_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 8, 6)
		eq_btn.pressed.connect(func() -> void:
			var res: Dictionary = _stats.equip_item_from_bag(_selected_bag_idx)
			if bool(res.get("ok", false)):
				_selected_bag_idx = -1
				sfx_requested.emit("equip_snap")
				gear_changed.emit()
				refresh()
		)
		btns_h.add_child(eq_btn)

		var drop_btn: Button = Button.new()
		drop_btn.text = "Drop"
		drop_btn.custom_minimum_size = Vector2(92, 0)
		drop_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(drop_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 6)
		drop_btn.pressed.connect(func() -> void:
			_stats.discard_bag_item(_selected_bag_idx)
			_selected_bag_idx = -1
			sfx_requested.emit("ui_click")
			gear_changed.emit()
			refresh()
		)
		btns_h.add_child(drop_btn)

func _build_gems_tab(filter_gtype: int) -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_child(scroll)

	var list_v: VBoxContainer = VBoxContainer.new()
	list_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_v.add_theme_constant_override("separation", 6)
	scroll.add_child(list_v)

	var shown_count: int = 0
	for i in range(_stats.gem_pouch.size()):
		var g: GemInstance = _stats.gem_pouch[i]
		var gtype: int = g.get_gem_type()
		if gtype != filter_gtype:
			continue
		shown_count += 1
		var gcol: Color = GameEnums.gem_color_value(g.get_gem_color())
		var is_sel: bool = (i == _selected_pouch_idx)

		var card: PanelContainer = PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.add_theme_stylebox_override(
			"panel",
			UiHelper.make_accent_card_box(UiHelper.BG_OAK_CARD if not is_sel else Color(0.28, 0.22, 0.16), Color(1.0, 0.90, 0.36) if is_sel else gcol, 8, 8)
		)
		var pouch_idx: int = i
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_selected_pouch_idx = -1 if _selected_pouch_idx == pouch_idx else pouch_idx
				sfx_requested.emit("ui_click")
				refresh()
		)
		list_v.add_child(card)

		var gh: HBoxContainer = HBoxContainer.new()
		gh.add_theme_constant_override("separation", 8)
		gh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(gh)

		var gtex: Texture2D = UiIcons.get_skill_icon(g.gem_id) if gtype == GameEnums.GemType.MAIN else UiIcons.get_gem_icon(GameEnums.GemType.MODIFIER, g.get_gem_color())
		gh.add_child(UiHelper.make_icon_rect(gtex, 28))

		var gv: VBoxContainer = VBoxContainer.new()
		gv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gv.add_theme_constant_override("separation", 3)
		gv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gh.add_child(gv)

		var row_top: HBoxContainer = HBoxContainer.new()
		row_top.add_theme_constant_override("separation", 6)
		row_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gv.add_child(row_top)

		var gn: Label = Label.new()
		gn.text = g.get_gem_name()
		gn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gn.add_theme_font_override("font", UiHelper.get_bold_font())
		gn.add_theme_font_size_override("font_size", 13)
		gn.add_theme_color_override("font_color", gcol.lightened(0.25))
		row_top.add_child(gn)

		row_top.add_child(UiHelper.make_badge_pill(GameEnums.gem_color_letter(g.get_gem_color()), gcol.darkened(0.68), gcol, UiHelper.TEXT_CREAM, 10))

		var d_lbl: Label = Label.new()
		d_lbl.text = g.get_short_desc()
		d_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		d_lbl.add_theme_font_size_override("font_size", 11)
		d_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		gv.add_child(d_lbl)

	if shown_count == 0:
		var emp_g: PanelContainer = PanelContainer.new()
		emp_g.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 12, false))
		var el: Label = Label.new()
		el.text = "No %s abilities in pouch." % ("Main" if filter_gtype == GameEnums.GemType.MAIN else "Modifier")
		el.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		emp_g.add_child(el)
		list_v.add_child(emp_g)

	# Selected Ability Inspector
	if _selected_pouch_idx >= 0 and _selected_pouch_idx < _stats.gem_pouch.size():
		var sel_gem: GemInstance = _stats.gem_pouch[_selected_pouch_idx]
		var gcol: Color = GameEnums.gem_color_value(sel_gem.get_gem_color())
		var g_box: PanelContainer = PanelContainer.new()
		g_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, gcol, 10, 2, 10, false))
		_right_content_vbox.add_child(g_box)

		var g_v: VBoxContainer = VBoxContainer.new()
		g_v.add_theme_constant_override("separation", 6)
		g_box.add_child(g_v)

		var gh_sel: HBoxContainer = HBoxContainer.new()
		gh_sel.add_theme_constant_override("separation", 8)
		g_v.add_child(gh_sel)
		var sel_tex: Texture2D = UiIcons.get_skill_icon(sel_gem.gem_id) if sel_gem.get_gem_type() == GameEnums.GemType.MAIN else UiIcons.get_gem_icon(GameEnums.GemType.MODIFIER, sel_gem.get_gem_color())
		gh_sel.add_child(UiHelper.make_icon_rect(sel_tex, 24))
		var sel_title: Label = Label.new()
		sel_title.text = "%s — %s" % [sel_gem.get_gem_name(), sel_gem.get_short_desc()]
		sel_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sel_title.add_theme_font_override("font", UiHelper.get_bold_font())
		sel_title.add_theme_font_size_override("font_size", 12)
		sel_title.add_theme_color_override("font_color", gcol.lightened(0.25))
		gh_sel.add_child(sel_title)

		var hint_l: Label = Label.new()
		hint_l.text = "Click a pulsing %s socket on the left to insert." % GameEnums.gem_color_letter(sel_gem.get_gem_color())
		hint_l.add_theme_font_size_override("font_size", 11)
		hint_l.add_theme_color_override("font_color", Color(1.0, 0.90, 0.44))
		g_v.add_child(hint_l)

		var drop_g_btn: Button = Button.new()
		drop_g_btn.text = "Drop"
		drop_g_btn.custom_minimum_size = Vector2(0, 32)
		drop_g_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(drop_g_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 5)
		drop_g_btn.pressed.connect(func() -> void:
			_stats.discard_gem_from_pouch(_selected_pouch_idx)
			_selected_pouch_idx = -1
			sfx_requested.emit("ui_click")
			gear_changed.emit()
			refresh()
		)
		g_v.add_child(drop_g_btn)

func _on_socket_clicked(slot: int, socket_idx: int) -> void:
	if _stats == null:
		return
	if _selected_pouch_idx >= 0 and _selected_pouch_idx < _stats.gem_pouch.size():
		if _stats.socket_gem_into_equipped(slot, socket_idx, _selected_pouch_idx):
			_selected_pouch_idx = -1
			sfx_requested.emit("socket_chime")
			gear_changed.emit()
			refresh()
		else:
			sfx_requested.emit("player_hurt")
	else:
		var removed: GemInstance = _stats.unsocket_gem_from_equipped(slot, socket_idx)
		if removed != null:
			sfx_requested.emit("ui_click")
			gear_changed.emit()
			refresh()
