class_name InventoryPanel
extends Control

signal closed()
signal gear_changed()
signal sfx_requested(sfx_name: String)

var _stats: HeroStats = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _frame: PanelContainer = null
var _hero_portrait: TextureRect = null
var _left_stats_rtl: RichTextLabel = null
var _center_slots_vbox: VBoxContainer = null
var _craft_target_lbl: Label = null
var _recolor_btn: Button = null
var _link_btn: Button = null
var _add_socket_btn: Button = null
var _dust_header_lbl: Label = null

var _tab_items_btn: Button = null
var _tab_gems_btn: Button = null
var _right_content_vbox: VBoxContainer = null

var _active_right_tab: String = "items"
var _gem_filter: int = -1
var _selected_bag_idx: int = -1
var _selected_pouch_idx: int = -1
var _selected_craft_slot: int = GameEnums.EquipSlot.WEAPON

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_rng.randomize()
	_build_shell()
	_clamp_frame_size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_clamp_frame_size()

func _clamp_frame_size() -> void:
	if _frame == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 10.0 or vp.y <= 10.0:
		vp = Vector2(1280.0, 720.0)
	_frame.custom_minimum_size = Vector2(minf(vp.x - 48.0, 1220.0), minf(vp.y - 40.0, 680.0))

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

	hdr.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("paw_prism_crest"), 34))

	var title: Label = Label.new()
	title.text = "HERO SATCHEL & PRISM SOCKET BOARD"
	UiHelper.apply_display_font(title, 22, UiHelper.BORDER_GOLD, 3)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var dust_pill: PanelContainer = PanelContainer.new()
	dust_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, Color(0.42, 0.88, 1.0), 10, 2, 7, false))
	hdr.add_child(dust_pill)
	var dp_h: HBoxContainer = HBoxContainer.new()
	dp_h.add_theme_constant_override("separation", 6)
	dust_pill.add_child(dp_h)
	dp_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("prism_dust"), 20))
	_dust_header_lbl = Label.new()
	_dust_header_lbl.text = "Prism Dust: 0"
	_dust_header_lbl.add_theme_font_size_override("font_size", 15)
	_dust_header_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_dust_header_lbl.add_theme_color_override("font_color", Color(0.55, 0.94, 1.0))
	dp_h.add_child(_dust_header_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = "Resume [Tab / Esc]"
	close_btn.custom_minimum_size = Vector2(175, 40)
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(close_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	close_btn.pressed.connect(func() -> void: close_panel())
	hdr.add_child(close_btn)

	# 3-Column Body
	var cols: HBoxContainer = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 12)
	root_v.add_child(cols)

	# === LEFT COLUMN: Portrait, Computed Stats & PoE Linked Skills ===
	var left_box: PanelContainer = PanelContainer.new()
	left_box.custom_minimum_size = Vector2(305, 0)
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.size_flags_stretch_ratio = 0.92
	left_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	cols.add_child(left_box)

	var left_v: VBoxContainer = VBoxContainer.new()
	left_v.add_theme_constant_override("separation", 8)
	left_box.add_child(left_v)

	var left_hdr: HBoxContainer = HBoxContainer.new()
	left_hdr.add_theme_constant_override("separation", 10)
	left_v.add_child(left_hdr)
	_hero_portrait = UiHelper.make_icon_rect(UiIcons.get_hero_portrait("shiba"), 44)
	left_hdr.add_child(_hero_portrait)
	var lh_lbl: Label = Label.new()
	lh_lbl.text = "Hero Stats & Active Build"
	UiHelper.apply_display_font(lh_lbl, 16, UiHelper.BORDER_GOLD, 2)
	left_hdr.add_child(lh_lbl)

	var left_well: PanelContainer = PanelContainer.new()
	left_well.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 10, false))
	left_v.add_child(left_well)

	_left_stats_rtl = RichTextLabel.new()
	_left_stats_rtl.bbcode_enabled = true
	_left_stats_rtl.scroll_active = true
	_left_stats_rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_stats_rtl.add_theme_font_size_override("normal_font_size", 14)
	left_well.add_child(_left_stats_rtl)

	# === CENTER COLUMN: 6 Equipment Slots + Drawn Sockets + Prism Forge ===
	var center_box: PanelContainer = PanelContainer.new()
	center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_box.size_flags_stretch_ratio = 1.32
	center_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	cols.add_child(center_box)

	var center_v: VBoxContainer = VBoxContainer.new()
	center_v.add_theme_constant_override("separation", 8)
	center_box.add_child(center_v)

	var center_hint: Label = Label.new()
	center_hint.text = "Select a gem in Skill Gems -> click a glowing socket to insert! Click an occupied socket to remove."
	center_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center_hint.add_theme_font_size_override("font_size", 12)
	center_hint.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
	center_v.add_child(center_hint)

	var slots_scroll: ScrollContainer = ScrollContainer.new()
	slots_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_v.add_child(slots_scroll)

	_center_slots_vbox = VBoxContainer.new()
	_center_slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_center_slots_vbox.add_theme_constant_override("separation", 7)
	slots_scroll.add_child(_center_slots_vbox)

	# Prism Forge Crafting Strip
	var craft_panel: PanelContainer = PanelContainer.new()
	craft_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, Color(0.45, 0.84, 0.98, 0.72), 10, 1, 8, false))
	center_v.add_child(craft_panel)

	var craft_v: VBoxContainer = VBoxContainer.new()
	craft_v.add_theme_constant_override("separation", 6)
	craft_panel.add_child(craft_v)

	_craft_target_lbl = Label.new()
	_craft_target_lbl.text = "Prism Forge Target: Weapon"
	_craft_target_lbl.add_theme_font_size_override("font_size", 13)
	_craft_target_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_craft_target_lbl.add_theme_color_override("font_color", Color(0.58, 0.94, 1.0))
	craft_v.add_child(_craft_target_lbl)

	var craft_btns: HBoxContainer = HBoxContainer.new()
	craft_btns.add_theme_constant_override("separation", 8)
	craft_v.add_child(craft_btns)

	_recolor_btn = _make_icon_button("Recolor (10)", UiIcons.get_ui_icon("craft_recolor"), UiHelper.CTA_SAPPHIRE, UiHelper.CTA_SAPPHIRE_RIM)
	_recolor_btn.pressed.connect(_on_craft_recolor)
	craft_btns.add_child(_recolor_btn)

	_link_btn = _make_icon_button("Add Link (15)", UiIcons.get_ui_icon("craft_link"), Color(0.32, 0.24, 0.11), UiHelper.BORDER_GOLD)
	_link_btn.pressed.connect(_on_craft_link)
	craft_btns.add_child(_link_btn)

	_add_socket_btn = _make_icon_button("+Socket (25)", UiIcons.get_ui_icon("craft_socket"), UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM)
	_add_socket_btn.pressed.connect(_on_craft_socket)
	craft_btns.add_child(_add_socket_btn)

	# === RIGHT COLUMN: Backpack Items & Skill Gems Tabs ===
	var right_box: PanelContainer = PanelContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_stretch_ratio = 1.26
	right_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	cols.add_child(right_box)

	var right_v: VBoxContainer = VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	right_box.add_child(right_v)

	var tab_row: HBoxContainer = HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	right_v.add_child(tab_row)

	_tab_items_btn = Button.new()
	_tab_items_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_items_btn.custom_minimum_size = Vector2(0, 38)
	_tab_items_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tab_items_btn.pressed.connect(func() -> void:
		_active_right_tab = "items"
		_selected_pouch_idx = -1
		refresh()
	)
	tab_row.add_child(_tab_items_btn)

	_tab_gems_btn = Button.new()
	_tab_gems_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_gems_btn.custom_minimum_size = Vector2(0, 38)
	_tab_gems_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tab_gems_btn.pressed.connect(func() -> void:
		_active_right_tab = "gems"
		_selected_bag_idx = -1
		refresh()
	)
	tab_row.add_child(_tab_gems_btn)

	_right_content_vbox = VBoxContainer.new()
	_right_content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_theme_constant_override("separation", 7)
	right_v.add_child(_right_content_vbox)

func _make_icon_button(lbl_txt: String, icon_tex: Texture2D, bg: Color, border: Color) -> Button:
	var btn: Button = Button.new()
	btn.text = lbl_txt
	btn.icon = icon_tex
	btn.add_theme_constant_override("icon_max_width", 20)
	btn.add_theme_constant_override("h_separation", 6)
	btn.custom_minimum_size = Vector2(0, 36)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(btn, bg, border, 8, 6)
	return btn

func open_panel(stats: HeroStats) -> void:
	_stats = stats
	_selected_bag_idx = -1
	_selected_pouch_idx = -1
	visible = true
	_clamp_frame_size()
	refresh()

func close_panel() -> void:
	visible = false
	_selected_pouch_idx = -1
	closed.emit()

func refresh() -> void:
	if _stats == null:
		return
	if _hero_portrait != null:
		_hero_portrait.texture = UiIcons.get_hero_portrait(_stats.hero_id)
	_dust_header_lbl.text = "Prism Dust: %d" % _stats.prism_dust
	_tab_items_btn.text = "Looted Gear (%d/%d)" % [_stats.item_bag.size(), HeroStats.MAX_BAG_SIZE]
	_tab_gems_btn.text = "Skill Gems (%d/%d)" % [_stats.gem_pouch.size(), HeroStats.MAX_POUCH_SIZE]

	UiHelper.style_button(
		_tab_items_btn,
		UiHelper.BG_OAK_CARD if _active_right_tab == "items" else UiHelper.BG_WELL,
		UiHelper.BORDER_GOLD if _active_right_tab == "items" else UiHelper.BORDER_BRASS,
		9,
		7
	)
	UiHelper.style_button(
		_tab_gems_btn,
		UiHelper.BG_OAK_CARD if _active_right_tab == "gems" else UiHelper.BG_WELL,
		UiHelper.BORDER_GOLD if _active_right_tab == "gems" else UiHelper.BORDER_BRASS,
		9,
		7
	)

	_refresh_left_stats()
	_refresh_center_slots()
	_refresh_right_column()

func _refresh_left_stats() -> void:
	var s: HeroStats = _stats
	var hdef: Dictionary = HeroDatabase.get_hero(s.hero_id)
	var txt: String = "[b][color=#ffd966]%s · Lv.%d[/color][/b]\n\n" % [String(hdef["hero_name"]), s.hero_level]

	txt += "[b][color=#ff9eb0]VITALS[/color][/b]\n"
	txt += "Max HP: [color=#fff5e0]%d[/color]   |   Regen: %.1f/s\n" % [int(round(s.max_hp)), s.hp_regen]
	txt += "Armor: %d   |   Dmg Red: %d%%\n\n" % [int(round(s.armor)), int(round(s.dmg_reduction))]

	txt += "[b][color=#ffb86c]OFFENSE[/color][/b]\n"
	txt += "Damage: [color=#fff5e0]%d%%[/color]   |   Flat: +%d\n" % [int(round(s.damage_mult * 100.0)), int(round(s.flat_damage))]
	txt += "Cast Speed: [color=#8ae69a]%d%%[/color]   |   Extra Proj: +%d\n" % [int(round(s.cast_speed_mult * 100.0)), s.extra_projectiles]
	txt += "Crit: %.1f%%   |   Crit Dmg: %d%%\n\n" % [s.crit_chance, int(round(s.crit_mult))]

	txt += "[b][color=#82d4ff]UTILITY[/color][/b]\n"
	txt += "Area: %d%%   |   Move Spd: %.1f\n" % [int(round(s.area_mult * 100.0)), s.move_speed]
	txt += "Life on Hit: %.1f   |   XP: %d%%   |   MF: +%d%%\n\n" % [s.life_on_hit, int(round(s.xp_gain_mult * 100.0)), int(round(s.magic_find))]

	txt += "[b][color=#7de0ff]ACTIVE POE SKILLS (%d)[/color][/b]\n" % s.active_skill_configs.size()
	if s.active_skill_configs.is_empty():
		txt += "[color=#ff7070]No Active Skill gem socketed! Insert one into any matching socket.[/color]\n"
	for cfg in s.active_skill_configs:
		var hex: String = GameEnums.gem_color_hex(int(cfg["color"]))
		txt += "• [b][color=%s]%s Lv.%d[/color][/b] (%.0f dmg / %.2fs)\n" % [hex, String(cfg["gem_name"]), int(cfg["effective_level"]), float(cfg["damage"]), float(cfg["cooldown"])]
		var sups: Array = cfg["linked_support_names"]
		if sups.is_empty():
			txt += "   [color=#9c8e7a]No linked supports[/color]\n"
		else:
			txt += "   [color=#ffd966]Linked:[/color] " + ", ".join(sups) + "\n"

	txt += "\n[b][color=#a8f0b0]PASSIVE GEMS (%d)[/color][/b]\n" % s.active_passives.size()
	if s.active_passives.is_empty():
		txt += "[color=#9c8e7a]None socketed yet.[/color]\n"
	for p_info in s.active_passives:
		var pg: GemInstance = p_info["gem"]
		var hex: String = GameEnums.gem_color_hex(pg.get_gem_color())
		txt += "• [color=%s]%s Lv.%d[/color]\n" % [hex, pg.get_gem_name(), int(p_info["effective_level"])]

	_left_stats_rtl.text = txt

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
		var is_craft_sel: bool = (slot == _selected_craft_slot)
		var border_col: Color = Color(0.50, 0.92, 1.0) if is_craft_sel else (UiHelper.rarity_border_color(item.rarity) if item != null else UiHelper.BORDER_SUBTLE)

		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, border_col, 10, 2 if is_craft_sel else 1, 8, false))
		_center_slots_vbox.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 5)
		card.add_child(cv)

		# Clickable item header card (no blinding white borders on common items)
		var hdr_panel: PanelContainer = PanelContainer.new()
		hdr_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		hdr_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var r_col: Color = GameEnums.rarity_color(item.rarity) if item != null else Color(0.55, 0.50, 0.45)
		var b_col: Color = UiHelper.rarity_border_color(item.rarity) if item != null else UiHelper.BORDER_SUBTLE
		hdr_panel.add_theme_stylebox_override("panel", UiHelper.make_accent_card_box(UiHelper.BG_OAK_CARD if item != null else UiHelper.BG_WELL, b_col, 8, 7))
		var cap_slot: int = slot
		hdr_panel.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_selected_craft_slot = cap_slot
				sfx_requested.emit("ui_click")
				refresh()
		)
		cv.add_child(hdr_panel)

		var hh: HBoxContainer = HBoxContainer.new()
		hh.add_theme_constant_override("separation", 8)
		hh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hdr_panel.add_child(hh)
		hh.add_child(UiHelper.make_icon_rect(UiIcons.get_slot_icon(slot), 24))

		var hv: VBoxContainer = VBoxContainer.new()
		hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hv.add_theme_constant_override("separation", 2)
		hv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hh.add_child(hv)

		var name_lbl: Label = Label.new()
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", r_col)
		if item == null:
			name_lbl.text = "%s: Empty Slot" % GameEnums.slot_label(slot)
			hv.add_child(name_lbl)
		else:
			name_lbl.text = "%s (iLv.%d)" % [item.item_name, item.item_level]
			hv.add_child(name_lbl)
			var aff_strs: Array[String] = []
			for a in item.affixes:
				aff_strs.append(GameEnums.format_stat(int(a["stat"]), float(a["value"])))
			var aff_lbl: Label = Label.new()
			aff_lbl.text = "  |  ".join(aff_strs)
			aff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			aff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			aff_lbl.add_theme_font_size_override("font_size", 11)
			aff_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
			hv.add_child(aff_lbl)
			if not item.unique_effect_desc.is_empty():
				var u_lbl: Label = Label.new()
				u_lbl.text = "Unique: " + item.unique_effect_desc
				u_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				u_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
				u_lbl.add_theme_font_size_override("font_size", 11)
				u_lbl.add_theme_color_override("font_color", Color(1.0, 0.72, 0.34))
				hv.add_child(u_lbl)

		if item != null:
			var sock_widget: PoESocketWidget = PoESocketWidget.new()
			sock_widget.configure(slot, item, sel_gem)
			sock_widget.socket_clicked.connect(_on_socket_clicked)
			cv.add_child(sock_widget)

	var target_item: ItemInstance = _stats.equipped.get(_selected_craft_slot, null)
	if target_item == null:
		_craft_target_lbl.text = "Prism Forge Target: %s (Empty)" % GameEnums.slot_label(_selected_craft_slot)
		_recolor_btn.disabled = true
		_link_btn.text = "Add Link (15)"
		_link_btn.disabled = true
		_add_socket_btn.disabled = true
	else:
		_craft_target_lbl.text = "Prism Forge: %s (%d/%d Sockets)" % [target_item.item_name, target_item.get_socket_count(), target_item.get_max_sockets()]
		_recolor_btn.disabled = (_stats.prism_dust < 10)
		if target_item.are_all_linked():
			_link_btn.text = "All Linked"
			_link_btn.disabled = true
		else:
			_link_btn.text = "Add Link (15)"
			_link_btn.disabled = (_stats.prism_dust < 15)
		_add_socket_btn.disabled = (_stats.prism_dust < 25 or target_item.get_socket_count() >= target_item.get_max_sockets())

func _refresh_right_column() -> void:
	for ch in _right_content_vbox.get_children():
		ch.queue_free()

	if _active_right_tab == "items":
		_build_items_tab()
	else:
		_build_gems_tab()

func _build_items_tab() -> void:
	var bulk_btn: Button = Button.new()
	bulk_btn.text = ""
	bulk_btn.custom_minimum_size = Vector2(0, 38)
	bulk_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(bulk_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 6)
	bulk_btn.pressed.connect(func() -> void:
		var res: Dictionary = _stats.salvage_common_and_magic()
		if int(res["count"]) > 0:
			_selected_bag_idx = -1
			sfx_requested.emit("equip_snap")
			gear_changed.emit()
			refresh()
	)
	_right_content_vbox.add_child(bulk_btn)
	var b_cc: CenterContainer = CenterContainer.new()
	b_cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bulk_btn.add_child(b_cc)
	var b_h: HBoxContainer = HBoxContainer.new()
	b_h.add_theme_constant_override("separation", 8)
	b_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b_cc.add_child(b_h)
	b_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("salvage"), 18))
	var b_lbl: Label = Label.new()
	b_lbl.text = "Salvage Common & Magic"
	b_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(b_lbl, 14, UiHelper.TEXT_CREAM, 2)
	b_h.add_child(b_lbl)

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
		emp.text = "No unequipped gear in satchel yet.\nDefeat critters, elites, chests & bosses to loot Diablo gear!"
		emp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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

			top_h.add_child(UiHelper.make_icon_rect(UiIcons.get_slot_icon(it.equip_slot), 24))

			var name_l: Label = Label.new()
			name_l.text = it.item_name
			name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_l.clip_text = true
			name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			name_l.add_theme_font_override("font", UiHelper.get_bold_font())
			name_l.add_theme_font_size_override("font_size", 13)
			name_l.add_theme_color_override("font_color", r_col)
			top_h.add_child(name_l)

			var ilvl_pill: PanelContainer = UiHelper.make_badge_pill("i%d" % it.item_level, UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, UiHelper.TEXT_PARCHMENT, 10)
			top_h.add_child(ilvl_pill)

			var bot_h: HBoxContainer = HBoxContainer.new()
			bot_h.add_theme_constant_override("separation", 8)
			bot_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rv.add_child(bot_h)

			var meta_l: Label = Label.new()
			meta_l.text = "%s · %s" % [GameEnums.slot_label(it.equip_slot), GameEnums.rarity_label(it.rarity)]
			meta_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			meta_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			meta_l.add_theme_font_size_override("font_size", 11)
			meta_l.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
			bot_h.add_child(meta_l)

			var mini_sock: PoESocketWidget = PoESocketWidget.new()
			mini_sock.configure_mini(it)
			bot_h.add_child(mini_sock)

	if _selected_bag_idx >= 0 and _selected_bag_idx < _stats.item_bag.size():
		var sel_item: ItemInstance = _stats.item_bag[_selected_bag_idx]
		var cur_item: ItemInstance = _stats.equipped.get(sel_item.equip_slot, null)
		var comp_box: PanelContainer = PanelContainer.new()
		comp_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.rarity_border_color(sel_item.rarity), 10, 2, 10, false))
		_right_content_vbox.add_child(comp_box)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 6)
		comp_box.add_child(cv)

		var rtl: RichTextLabel = RichTextLabel.new()
		rtl.bbcode_enabled = true
		rtl.fit_content = true
		rtl.scroll_active = false
		rtl.add_theme_font_size_override("normal_font_size", 12)

		var r_hex: String = "#" + GameEnums.rarity_color(sel_item.rarity).to_html(false)
		var txt: String = "[b][color=%s]%s[/color][/b] (%s · iLv.%d)\n" % [r_hex, sel_item.item_name, GameEnums.slot_label(sel_item.equip_slot), sel_item.item_level]
		if not sel_item.unique_effect_desc.is_empty():
			txt += "[color=#ff9e44]Unique: %s[/color]\n" % sel_item.unique_effect_desc
		txt += "[color=#99c2ff]vs Equipped (%s):[/color]\n" % (cur_item.item_name if cur_item != null else "Empty")
		for diff in UiHelper.compare_items(sel_item, cur_item):
			var st: int = int(diff["stat"])
			var d_val: float = float(diff["delta"])
			var n_val: float = float(diff["new_val"])
			var delta_str: String = "[color=#66ee77](+%.1f)[/color]" % d_val if d_val > 0.01 else ("[color=#ff6666](%.1f)[/color]" % d_val if d_val < -0.01 else "[color=#999999](=)[/color]")
			txt += "• %s: %.1f  %s\n" % [GameEnums.stat_label(st), n_val, delta_str]
		rtl.text = txt
		cv.add_child(rtl)

		var btn_row: HBoxContainer = HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 8)
		cv.add_child(btn_row)

		var eq_btn: Button = Button.new()
		eq_btn.text = "Equip (Keeps Gems)"
		eq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eq_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(eq_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 8, 7)
		eq_btn.pressed.connect(func() -> void:
			_stats.equip_item_from_bag(_selected_bag_idx)
			_selected_bag_idx = -1
			sfx_requested.emit("equip_snap")
			gear_changed.emit()
			refresh()
		)
		btn_row.add_child(eq_btn)

		var sal_btn: Button = Button.new()
		sal_btn.text = "Salvage (+%d)" % sel_item.get_salvage_dust()
		sal_btn.icon = UiIcons.get_ui_icon("salvage")
		sal_btn.add_theme_constant_override("icon_max_width", 18)
		sal_btn.add_theme_constant_override("h_separation", 6)
		sal_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(sal_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 7)
		sal_btn.pressed.connect(func() -> void:
			_stats.salvage_bag_item(_selected_bag_idx)
			_selected_bag_idx = -1
			sfx_requested.emit("ui_click")
			gear_changed.emit()
			refresh()
		)
		btn_row.add_child(sal_btn)

func _build_gems_tab() -> void:
	var filter_row: HBoxContainer = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	_right_content_vbox.add_child(filter_row)

	for pair in [[-1, "All"], [GameEnums.GemType.ACTIVE, "Active"], [GameEnums.GemType.SUPPORT, "Support"], [GameEnums.GemType.PASSIVE, "Passive"]]:
		var f_id: int = int(pair[0])
		var f_lbl: String = String(pair[1])
		var fb: Button = Button.new()
		fb.text = f_lbl
		fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(
			fb,
			UiHelper.BG_OAK_CARD if _gem_filter == f_id else UiHelper.BG_WELL,
			UiHelper.BORDER_GOLD if _gem_filter == f_id else UiHelper.BORDER_BRASS,
			8,
			5
		)
		fb.pressed.connect(func() -> void:
			_gem_filter = f_id
			_selected_pouch_idx = -1
			refresh()
		)
		filter_row.add_child(fb)

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
		if _gem_filter != -1 and g.get_gem_type() != _gem_filter:
			continue
		shown_count += 1
		var gcol: Color = GameEnums.gem_color_value(g.get_gem_color())
		var is_sel: bool = (i == _selected_pouch_idx)
		var gtype: int = g.get_gem_type()

		var gem_card: PanelContainer = PanelContainer.new()
		gem_card.mouse_filter = Control.MOUSE_FILTER_STOP
		gem_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		gem_card.add_theme_stylebox_override(
			"panel",
			UiHelper.make_accent_card_box(gcol.darkened(0.65) if is_sel else UiHelper.BG_OAK_CARD, Color(1.0, 0.90, 0.30) if is_sel else gcol, 8, 7)
		)
		var idx_cap: int = i
		gem_card.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_selected_pouch_idx = -1 if _selected_pouch_idx == idx_cap else idx_cap
				sfx_requested.emit("ui_click")
				refresh()
		)
		list_v.add_child(gem_card)

		var gh: HBoxContainer = HBoxContainer.new()
		gh.add_theme_constant_override("separation", 8)
		gh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gem_card.add_child(gh)

		var gtex: Texture2D = UiIcons.get_skill_icon(g.gem_id) if gtype == GameEnums.GemType.ACTIVE else UiIcons.get_gem_icon(gtype, g.get_gem_color())
		gh.add_child(UiHelper.make_icon_rect(gtex, 24))

		var short_type: String = "ACT" if gtype == GameEnums.GemType.ACTIVE else ("SUP" if gtype == GameEnums.GemType.SUPPORT else "PAS")
		var type_pill: PanelContainer = UiHelper.make_badge_pill(short_type, gcol.darkened(0.60), gcol, UiHelper.TEXT_CREAM, 10)
		type_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gh.add_child(type_pill)

		var gname_lbl: Label = Label.new()
		gname_lbl.text = g.get_gem_name()
		gname_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gname_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gname_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		gname_lbl.add_theme_font_size_override("font_size", 13)
		gname_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		gh.add_child(gname_lbl)

		var lvl_pill: PanelContainer = UiHelper.make_badge_pill("Lv.%d" % g.level, UiHelper.BG_WELL, UiHelper.BORDER_GOLD, Color(1.0, 0.90, 0.45), 10)
		lvl_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gh.add_child(lvl_pill)

	if shown_count == 0:
		var emp_box: PanelContainer = PanelContainer.new()
		emp_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_SUBTLE, 10, 1, 14, false))
		var emp: Label = Label.new()
		emp.text = "No gems matching filter in pouch.\nClick any socketed gem in Center Column to unsocket it here!"
		emp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		emp.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		emp_box.add_child(emp)
		list_v.add_child(emp_box)

	if _selected_pouch_idx >= 0 and _selected_pouch_idx < _stats.gem_pouch.size():
		var sel_gem: GemInstance = _stats.gem_pouch[_selected_pouch_idx]
		var gcol: Color = GameEnums.gem_color_value(sel_gem.get_gem_color())
		var gbox: PanelContainer = PanelContainer.new()
		gbox.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, gcol, 10, 2, 10, false))
		_right_content_vbox.add_child(gbox)

		var gv: VBoxContainer = VBoxContainer.new()
		gv.add_theme_constant_override("separation", 6)
		gbox.add_child(gv)

		var info_lbl: Label = Label.new()
		info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_lbl.add_theme_font_size_override("font_size", 12)
		var extra_hint: String = "\n-> Click a glowing GOLD socket in the Center Column to equip!"
		if sel_gem.get_gem_type() == GameEnums.GemType.SUPPORT:
			var matches: Array[String] = []
			for cfg in _stats.active_skill_configs:
				if GemDatabase.does_support_apply(sel_gem.gem_id, String(cfg["gem_id"])):
					matches.append(String(cfg["gem_name"]))
			if not matches.is_empty():
				extra_hint = "\nLinks with your equipped: " + ", ".join(matches) + extra_hint
			else:
				extra_hint = "\nNote: No currently equipped Active Skill matches its tags yet." + extra_hint
		info_lbl.text = sel_gem.get_tooltip_text() + extra_hint
		gv.add_child(info_lbl)

		var g_btns: HBoxContainer = HBoxContainer.new()
		g_btns.add_theme_constant_override("separation", 6)
		gv.add_child(g_btns)

		if sel_gem.level < 10:
			var up_cost: int = sel_gem.get_upgrade_dust_cost()
			var lvl_btn: Button = Button.new()
			lvl_btn.text = "Level Up (%d Dust)" % up_cost
			lvl_btn.disabled = (_stats.prism_dust < up_cost)
			lvl_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lvl_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			UiHelper.style_button(lvl_btn, UiHelper.CTA_SAPPHIRE, UiHelper.CTA_SAPPHIRE_RIM, 8, 6)
			lvl_btn.pressed.connect(func() -> void:
				if _stats.prism_dust >= up_cost:
					_stats.prism_dust -= up_cost
					sel_gem.add_xp(sel_gem.xp_to_next)
					_stats.recompute()
					sfx_requested.emit("socket_chime")
					gear_changed.emit()
					refresh()
			)
			g_btns.add_child(lvl_btn)

		var sal_g_btn: Button = Button.new()
		sal_g_btn.text = "Salvage (+%d)" % sel_gem.get_salvage_dust()
		sal_g_btn.icon = UiIcons.get_ui_icon("salvage")
		sal_g_btn.add_theme_constant_override("icon_max_width", 18)
		sal_g_btn.add_theme_constant_override("h_separation", 6)
		sal_g_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(sal_g_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 6)
		sal_g_btn.pressed.connect(func() -> void:
			_stats.salvage_gem_from_pouch(_selected_pouch_idx)
			_selected_pouch_idx = -1
			sfx_requested.emit("ui_click")
			gear_changed.emit()
			refresh()
		)
		g_btns.add_child(sal_g_btn)

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

func _on_craft_recolor() -> void:
	if _stats == null or _stats.prism_dust < 10:
		return
	var item: ItemInstance = _stats.equipped.get(_selected_craft_slot, null)
	if item == null:
		return
	var rescued: Array[GemInstance] = item.extract_all_gems()
	_stats.prism_dust -= 10
	item.recolor_sockets(_rng)
	for g in rescued:
		var placed: bool = false
		for i in range(item.get_socket_count()):
			if item.socketed_gems[i] == null and item.can_socket(i, g):
				item.insert_gem(i, g)
				placed = true
				break
		if not placed:
			_stats.gem_pouch.append(g)
	_stats.recompute()
	sfx_requested.emit("socket_chime")
	gear_changed.emit()
	refresh()

func _on_craft_link() -> void:
	if _stats == null or _stats.prism_dust < 15:
		return
	var item: ItemInstance = _stats.equipped.get(_selected_craft_slot, null)
	if item == null or item.are_all_linked():
		return
	if item.add_link(_rng):
		_stats.prism_dust -= 15
		_stats.recompute()
		sfx_requested.emit("socket_chime")
		gear_changed.emit()
		refresh()

func _on_craft_socket() -> void:
	if _stats == null or _stats.prism_dust < 25:
		return
	var item: ItemInstance = _stats.equipped.get(_selected_craft_slot, null)
	if item == null:
		return
	if item.add_socket(_rng):
		_stats.prism_dust -= 25
		_stats.recompute()
		sfx_requested.emit("socket_chime")
		gear_changed.emit()
		refresh()
