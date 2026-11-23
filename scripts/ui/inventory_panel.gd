class_name InventoryPanel
extends Control

signal closed()
signal gear_changed()
signal sfx_requested(sfx_name: String)

var _stats: HeroStats = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

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

var _active_right_tab: String = "items" # "items" | "gems"
var _gem_filter: int = -1 # -1 = all, else GameEnums.GemType
var _selected_bag_idx: int = -1
var _selected_pouch_idx: int = -1
var _selected_craft_slot: int = GameEnums.EquipSlot.WEAPON

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_rng.randomize()
	_build_shell()

func _build_shell() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.04, 0.08, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var frame: PanelContainer = PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.15, 0.97), Color(0.96, 0.80, 0.34, 0.9), 14, 2, 14))
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 28
	frame.offset_top = 24
	frame.offset_right = -28
	frame.offset_bottom = -24
	add_child(frame)

	var root_v: VBoxContainer = VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	frame.add_child(root_v)

	# Header Row
	var hdr: HBoxContainer = HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 12)
	root_v.add_child(hdr)

	var title: Label = Label.new()
	title.text = "HERO GEAR & PATH OF EXILE GEM SOCKET BOARD"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.40))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	_dust_header_lbl = Label.new()
	_dust_header_lbl.text = "Prism Dust: 0"
	_dust_header_lbl.add_theme_font_size_override("font_size", 16)
	_dust_header_lbl.add_theme_color_override("font_color", Color(0.48, 0.92, 1.0))
	hdr.add_child(_dust_header_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = "Resume [Tab / Esc]"
	close_btn.custom_minimum_size = Vector2(165, 36)
	UiHelper.style_button(close_btn, Color(0.24, 0.44, 0.30), Color(0.56, 0.92, 0.62), 8)
	close_btn.pressed.connect(func() -> void: close_panel())
	hdr.add_child(close_btn)

	# 3-Column Body
	var cols: HBoxContainer = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 12)
	root_v.add_child(cols)

	# === LEFT COLUMN: Computed Stats & PoE Linked Skills ===
	var left_box: PanelContainer = PanelContainer.new()
	left_box.custom_minimum_size = Vector2(305, 0)
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.size_flags_stretch_ratio = 0.95
	left_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.12, 0.18), Color(0.35, 0.42, 0.58), 10, 1, 10))
	cols.add_child(left_box)

	_left_stats_rtl = RichTextLabel.new()
	_left_stats_rtl.bbcode_enabled = true
	_left_stats_rtl.scroll_active = true
	_left_stats_rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_stats_rtl.add_theme_font_size_override("normal_font_size", 13)
	left_box.add_child(_left_stats_rtl)

	# === CENTER COLUMN: 6 Equipment Slots + Sockets + Dust Crafting ===
	var center_box: PanelContainer = PanelContainer.new()
	center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_box.size_flags_stretch_ratio = 1.25
	center_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.12, 0.18), Color(0.35, 0.42, 0.58), 10, 1, 10))
	cols.add_child(center_box)

	var center_v: VBoxContainer = VBoxContainer.new()
	center_v.add_theme_constant_override("separation", 8)
	center_box.add_child(center_v)

	var center_hint: Label = Label.new()
	center_hint.text = "Click a gem in Gems tab -> click a glowing socket to insert! Click occupied socket to remove."
	center_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center_hint.add_theme_font_size_override("font_size", 12)
	center_hint.add_theme_color_override("font_color", Color(0.75, 0.84, 0.95))
	center_v.add_child(center_hint)

	var slots_scroll: ScrollContainer = ScrollContainer.new()
	slots_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_v.add_child(slots_scroll)

	_center_slots_vbox = VBoxContainer.new()
	_center_slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_center_slots_vbox.add_theme_constant_override("separation", 7)
	slots_scroll.add_child(_center_slots_vbox)

	# Prism Dust Crafting Strip
	var craft_panel: PanelContainer = PanelContainer.new()
	craft_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.08, 0.10, 0.16), Color(0.45, 0.82, 0.96, 0.8), 8, 1, 8))
	center_v.add_child(craft_panel)

	var craft_v: VBoxContainer = VBoxContainer.new()
	craft_v.add_theme_constant_override("separation", 6)
	craft_panel.add_child(craft_v)

	_craft_target_lbl = Label.new()
	_craft_target_lbl.text = "Crafting Target: Weapon"
	_craft_target_lbl.add_theme_font_size_override("font_size", 13)
	_craft_target_lbl.add_theme_color_override("font_color", Color(0.55, 0.92, 1.0))
	craft_v.add_child(_craft_target_lbl)

	var craft_btns: HBoxContainer = HBoxContainer.new()
	craft_btns.add_theme_constant_override("separation", 6)
	craft_v.add_child(craft_btns)

	_recolor_btn = Button.new()
	_recolor_btn.text = "Recolor (10)"
	_recolor_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.style_button(_recolor_btn, Color(0.20, 0.24, 0.36), Color(0.50, 0.84, 1.0))
	_recolor_btn.pressed.connect(_on_craft_recolor)
	craft_btns.add_child(_recolor_btn)

	_link_btn = Button.new()
	_link_btn.text = "Add Link (15)"
	_link_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.style_button(_link_btn, Color(0.26, 0.24, 0.16), Color(1.0, 0.85, 0.34))
	_link_btn.pressed.connect(_on_craft_link)
	craft_btns.add_child(_link_btn)

	_add_socket_btn = Button.new()
	_add_socket_btn.text = "+Socket (25)"
	_add_socket_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.style_button(_add_socket_btn, Color(0.22, 0.28, 0.24), Color(0.52, 0.92, 0.62))
	_add_socket_btn.pressed.connect(_on_craft_socket)
	craft_btns.add_child(_add_socket_btn)

	# === RIGHT COLUMN: Backpack Items & Gem Pouch Tabs ===
	var right_box: PanelContainer = PanelContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_stretch_ratio = 1.25
	right_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.12, 0.18), Color(0.35, 0.42, 0.58), 10, 1, 10))
	cols.add_child(right_box)

	var right_v: VBoxContainer = VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	right_box.add_child(right_v)

	var tab_row: HBoxContainer = HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	right_v.add_child(tab_row)

	_tab_items_btn = Button.new()
	_tab_items_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_items_btn.pressed.connect(func() -> void:
		_active_right_tab = "items"
		_selected_pouch_idx = -1
		refresh()
	)
	tab_row.add_child(_tab_items_btn)

	_tab_gems_btn = Button.new()
	_tab_gems_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_gems_btn.pressed.connect(func() -> void:
		_active_right_tab = "gems"
		_selected_bag_idx = -1
		refresh()
	)
	tab_row.add_child(_tab_gems_btn)

	_right_content_vbox = VBoxContainer.new()
	_right_content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_theme_constant_override("separation", 6)
	right_v.add_child(_right_content_vbox)

func open_panel(stats: HeroStats) -> void:
	_stats = stats
	_selected_bag_idx = -1
	_selected_pouch_idx = -1
	visible = true
	refresh()

func close_panel() -> void:
	visible = false
	_selected_pouch_idx = -1
	closed.emit()

func refresh() -> void:
	if _stats == null:
		return
	_dust_header_lbl.text = "Prism Dust: %d" % _stats.prism_dust
	_tab_items_btn.text = "Looted Gear (%d/%d)" % [_stats.item_bag.size(), HeroStats.MAX_BAG_SIZE]
	_tab_gems_btn.text = "Skill Gems (%d/%d)" % [_stats.gem_pouch.size(), HeroStats.MAX_POUCH_SIZE]

	UiHelper.style_button(_tab_items_btn, Color(0.24, 0.30, 0.46) if _active_right_tab == "items" else Color(0.14, 0.16, 0.24), Color(1.0, 0.84, 0.34) if _active_right_tab == "items" else Color(0.36, 0.42, 0.56))
	UiHelper.style_button(_tab_gems_btn, Color(0.24, 0.30, 0.46) if _active_right_tab == "gems" else Color(0.14, 0.16, 0.24), Color(1.0, 0.84, 0.34) if _active_right_tab == "gems" else Color(0.36, 0.42, 0.56))

	_refresh_left_stats()
	_refresh_center_slots()
	_refresh_right_column()

func _refresh_left_stats() -> void:
	var s: HeroStats = _stats
	var txt: String = "[b][color=#ffd966]Hero Stats (Lv.%d)[/color][/b]\n" % s.hero_level
	txt += "Max HP: [color=#ff8a9b]%d[/color]  |  Regen: %.1f/s\n" % [int(round(s.max_hp)), s.hp_regen]
	txt += "Armor: %d  |  Dmg Red: %d%%\n" % [int(round(s.armor)), int(round(s.dmg_reduction))]
	txt += "Damage Mult: [color=#ffb36b]%d%%[/color]  |  Flat: +%d\n" % [int(round(s.damage_mult * 100.0)), int(round(s.flat_damage))]
	txt += "Attack/Cast Speed: [color=#8ae69a]%d%%[/color]\n" % int(round(s.cast_speed_mult * 100.0))
	txt += "Crit Chance: %.1f%%  |  Crit Dmg: %d%%\n" % [s.crit_chance, int(round(s.crit_mult))]
	txt += "Area Size: %d%%  |  Move Spd: %.1f\n" % [int(round(s.area_mult * 100.0)), s.move_speed]
	txt += "Life on Hit: %.1f  |  Extra Proj: +%d\n" % [s.life_on_hit, s.extra_projectiles]
	txt += "XP Gain: %d%%  |  Magic Find: +%d%%\n\n" % [int(round(s.xp_gain_mult * 100.0)), int(round(s.magic_find))]

	txt += "[b][color=#7de0ff]Active PoE Skills (%d)[/color][/b]\n" % s.active_skill_configs.size()
	if s.active_skill_configs.is_empty():
		txt += "[color=#ff6666]No Active Skill gem socketed! Socket one in any matching slot.[/color]\n"
	for cfg in s.active_skill_configs:
		var hex: String = GameEnums.gem_color_hex(int(cfg["color"]))
		txt += "• [b][color=%s]%s Lv.%d[/color][/b] (%.0f dmg / %.2fs)\n" % [hex, String(cfg["gem_name"]), int(cfg["effective_level"]), float(cfg["damage"]), float(cfg["cooldown"])]
		var sups: Array = cfg["linked_support_names"]
		if sups.is_empty():
			txt += "   [color=#9999aa]No linked supports[/color]\n"
		else:
			txt += "   [color=#ffd966]Linked:[/color] " + ", ".join(sups) + "\n"

	txt += "\n[b][color=#a8f0b0]Socketed Passive Gems (%d)[/color][/b]\n" % s.active_passives.size()
	if s.active_passives.is_empty():
		txt += "[color=#9999aa]None socketed yet.[/color]\n"
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
		var border_col: Color = GameEnums.rarity_color(item.rarity) if item != null else Color(0.32, 0.34, 0.42)
		if is_craft_sel:
			border_col = Color(0.50, 0.92, 1.0)

		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.14, 0.15, 0.22), border_col, 8, 2 if is_craft_sel else 1, 7))
		_center_slots_vbox.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 5)
		card.add_child(cv)

		var top_btn: Button = Button.new()
		top_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if item == null:
			top_btn.text = "%s: [Empty Slot]" % GameEnums.slot_label(slot)
			UiHelper.style_button(top_btn, Color(0.12, 0.13, 0.18), Color(0.28, 0.30, 0.38), 6)
		else:
			var aff_strs: Array[String] = []
			for a in item.affixes:
				aff_strs.append(GameEnums.format_stat(int(a["stat"]), float(a["value"])))
			top_btn.text = "%s: %s (iLv.%d)\n%s" % [GameEnums.slot_label(slot), item.item_name, item.item_level, "  |  ".join(aff_strs)]
			if not item.unique_effect_desc.is_empty():
				top_btn.text += "\nUnique: " + item.unique_effect_desc
			UiHelper.style_button(top_btn, Color(0.16, 0.18, 0.26), GameEnums.rarity_color(item.rarity), 6)
		top_btn.add_theme_font_size_override("font_size", 12)
		var cap_slot: int = slot
		top_btn.pressed.connect(func() -> void:
			_selected_craft_slot = cap_slot
			sfx_requested.emit("ui_click")
			refresh()
		)
		cv.add_child(top_btn)

		if item != null:
			var sock_row: HBoxContainer = HBoxContainer.new()
			sock_row.add_theme_constant_override("separation", 4)
			cv.add_child(sock_row)

			for s_idx in range(item.get_socket_count()):
				var scol: int = item.socket_colors[s_idx]
				var g_in: GemInstance = item.socketed_gems[s_idx]
				var s_btn: Button = Button.new()
				s_btn.custom_minimum_size = Vector2(72, 34)
				s_btn.add_theme_font_size_override("font_size", 11)
				var base_c: Color = GameEnums.gem_color_value(scol)
				var compatible: bool = (sel_gem != null and item.can_socket(s_idx, sel_gem))
				if g_in != null:
					var gtype_tag: String = "A" if g_in.get_gem_type() == GameEnums.GemType.ACTIVE else ("S" if g_in.get_gem_type() == GameEnums.GemType.SUPPORT else "P")
					s_btn.text = "[%s] %s Lv.%d" % [gtype_tag, g_in.get_short_label(), g_in.level]
					UiHelper.style_button(s_btn, base_c.darkened(0.55), Color(1.0, 0.88, 0.25) if compatible else base_c, 6)
				else:
					s_btn.text = "(%s) Empty" % GameEnums.gem_color_letter(scol)
					UiHelper.style_button(s_btn, base_c.darkened(0.75), Color(1.0, 0.90, 0.25) if compatible else base_c.darkened(0.2), 6)

				var c_slot: int = slot
				var c_idx: int = s_idx
				s_btn.pressed.connect(func() -> void: _on_socket_clicked(c_slot, c_idx))
				sock_row.add_child(s_btn)

				if s_idx < item.links.size():
					var link_lbl: Label = Label.new()
					link_lbl.text = "===" if item.links[s_idx] else " · "
					link_lbl.add_theme_font_size_override("font_size", 14)
					link_lbl.add_theme_color_override("font_color", Color(1.0, 0.86, 0.30) if item.links[s_idx] else Color(0.40, 0.42, 0.50))
					sock_row.add_child(link_lbl)

	# Update Crafting buttons state
	var target_item: ItemInstance = _stats.equipped.get(_selected_craft_slot, null)
	if target_item == null:
		_craft_target_lbl.text = "Crafting Target: %s (Empty)" % GameEnums.slot_label(_selected_craft_slot)
		_recolor_btn.disabled = true
		_link_btn.disabled = true
		_add_socket_btn.disabled = true
	else:
		_craft_target_lbl.text = "Crafting: %s (%d/%d Sockets)" % [target_item.item_name, target_item.get_socket_count(), target_item.get_max_sockets()]
		_recolor_btn.disabled = (_stats.prism_dust < 10)
		_link_btn.disabled = (_stats.prism_dust < 15 or target_item.are_all_linked())
		_add_socket_btn.disabled = (_stats.prism_dust < 25 or target_item.get_socket_count() >= target_item.get_max_sockets())

func _refresh_right_column() -> void:
	for ch in _right_content_vbox.get_children():
		ch.queue_free()

	if _active_right_tab == "items":
		_build_items_tab()
	else:
		_build_gems_tab()

func _build_items_tab() -> void:
	var top_actions: HBoxContainer = HBoxContainer.new()
	_right_content_vbox.add_child(top_actions)

	var bulk_btn: Button = Button.new()
	bulk_btn.text = "Salvage All Common & Magic"
	bulk_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.style_button(bulk_btn, Color(0.32, 0.18, 0.20), Color(0.95, 0.52, 0.46), 6)
	bulk_btn.pressed.connect(func() -> void:
		var res: Dictionary = _stats.salvage_common_and_magic()
		if int(res["count"]) > 0:
			_selected_bag_idx = -1
			sfx_requested.emit("equip_snap")
			gear_changed.emit()
			refresh()
	)
	top_actions.add_child(bulk_btn)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_content_vbox.add_child(scroll)

	var list_v: VBoxContainer = VBoxContainer.new()
	list_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_v.add_theme_constant_override("separation", 5)
	scroll.add_child(list_v)

	if _stats.item_bag.is_empty():
		var emp: Label = Label.new()
		emp.text = "No unequipped items in bag yet.\nDefeat critters, elites & bosses to loot Diablo gear!"
		emp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list_v.add_child(emp)
	else:
		for i in range(_stats.item_bag.size()):
			var it: ItemInstance = _stats.item_bag[i]
			var btn: Button = Button.new()
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.text = "[%s] %s (iLv.%d)  %s" % [GameEnums.slot_label(it.equip_slot), it.item_name, it.item_level, it.get_socket_summary_text()]
			btn.add_theme_font_size_override("font_size", 12)
			var is_sel: bool = (i == _selected_bag_idx)
			UiHelper.style_button(btn, Color(0.22, 0.24, 0.34) if is_sel else Color(0.14, 0.16, 0.22), GameEnums.rarity_color(it.rarity), 6)
			var idx_cap: int = i
			btn.pressed.connect(func() -> void:
				_selected_bag_idx = idx_cap
				sfx_requested.emit("ui_click")
				refresh()
			)
			list_v.add_child(btn)

	# Diablo Side-by-Side Comparison Inspector
	if _selected_bag_idx >= 0 and _selected_bag_idx < _stats.item_bag.size():
		var sel_item: ItemInstance = _stats.item_bag[_selected_bag_idx]
		var cur_item: ItemInstance = _stats.equipped.get(sel_item.equip_slot, null)
		var comp_box: PanelContainer = PanelContainer.new()
		comp_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.08, 0.10, 0.15), GameEnums.rarity_color(sel_item.rarity), 8, 2, 8))
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
		var txt: String = "[b][color=%s]%s[/color][/b] (%s iLv.%d)\n" % [r_hex, sel_item.item_name, GameEnums.slot_label(sel_item.equip_slot), sel_item.item_level]
		txt += "Sockets: %s\n" % sel_item.get_socket_summary_text()
		if not sel_item.unique_effect_desc.is_empty():
			txt += "[color=#ff9e44]Unique: %s[/color]\n" % sel_item.unique_effect_desc
		txt += "[color=#99b8ff]vs Equipped (%s):[/color]\n" % (cur_item.item_name if cur_item != null else "Empty")
		for diff in UiHelper.compare_items(sel_item, cur_item):
			var st: int = int(diff["stat"])
			var d_val: float = float(diff["delta"])
			var n_val: float = float(diff["new_val"])
			var arrow: String = "[color=#66ee77]▲ +%.1f[/color]" % d_val if d_val > 0.01 else ("[color=#ff6666]▼ %.1f[/color]" % d_val if d_val < -0.01 else "[color=#aaaaaa]=[/color]")
			txt += "• %s: %.1f (%s)\n" % [GameEnums.stat_label(st), n_val, arrow]
		rtl.text = txt
		cv.add_child(rtl)

		var btn_row: HBoxContainer = HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 8)
		cv.add_child(btn_row)

		var eq_btn: Button = Button.new()
		eq_btn.text = "Equip (Preserves Gems)"
		eq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiHelper.style_button(eq_btn, Color(0.22, 0.48, 0.30), Color(0.55, 0.96, 0.62), 6)
		eq_btn.pressed.connect(func() -> void:
			_stats.equip_item_from_bag(_selected_bag_idx)
			_selected_bag_idx = -1
			sfx_requested.emit("equip_snap")
			gear_changed.emit()
			refresh()
		)
		btn_row.add_child(eq_btn)

		var sal_btn: Button = Button.new()
		sal_btn.text = "Salvage (+%d Dust)" % sel_item.get_salvage_dust()
		UiHelper.style_button(sal_btn, Color(0.36, 0.20, 0.20), Color(0.95, 0.55, 0.45), 6)
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
	filter_row.add_theme_constant_override("separation", 5)
	_right_content_vbox.add_child(filter_row)

	for pair in [[-1, "All"], [GameEnums.GemType.ACTIVE, "Active"], [GameEnums.GemType.SUPPORT, "Support"], [GameEnums.GemType.PASSIVE, "Passive"]]:
		var f_id: int = int(pair[0])
		var f_lbl: String = String(pair[1])
		var fb: Button = Button.new()
		fb.text = f_lbl
		fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiHelper.style_button(fb, Color(0.24, 0.32, 0.48) if _gem_filter == f_id else Color(0.14, 0.16, 0.24), Color(0.60, 0.85, 1.0) if _gem_filter == f_id else Color(0.35, 0.40, 0.52), 6)
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
	list_v.add_theme_constant_override("separation", 5)
	scroll.add_child(list_v)

	var shown_count: int = 0
	for i in range(_stats.gem_pouch.size()):
		var g: GemInstance = _stats.gem_pouch[i]
		if _gem_filter != -1 and g.get_gem_type() != _gem_filter:
			continue
		shown_count += 1
		var gcol: Color = GameEnums.gem_color_value(g.get_gem_color())
		var is_sel: bool = (i == _selected_pouch_idx)
		var btn: Button = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "[%s] %s Lv.%d (%s)" % [GameEnums.gem_type_label(g.get_gem_type()), g.get_gem_name(), g.level, GameEnums.gem_color_letter(g.get_gem_color())]
		btn.add_theme_font_size_override("font_size", 12)
		UiHelper.style_button(btn, gcol.darkened(0.62) if is_sel else Color(0.14, 0.16, 0.22), Color(1.0, 0.90, 0.30) if is_sel else gcol, 6)
		var idx_cap: int = i
		btn.pressed.connect(func() -> void:
			_selected_pouch_idx = -1 if _selected_pouch_idx == idx_cap else idx_cap
			sfx_requested.emit("ui_click")
			refresh()
		)
		list_v.add_child(btn)

	if shown_count == 0:
		var emp: Label = Label.new()
		emp.text = "No gems matching filter in pouch.\nClick any socketed gem in Center Column to unsocket it here!"
		emp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list_v.add_child(emp)

	if _selected_pouch_idx >= 0 and _selected_pouch_idx < _stats.gem_pouch.size():
		var sel_gem: GemInstance = _stats.gem_pouch[_selected_pouch_idx]
		var gcol: Color = GameEnums.gem_color_value(sel_gem.get_gem_color())
		var gbox: PanelContainer = PanelContainer.new()
		gbox.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.08, 0.10, 0.15), gcol, 8, 2, 8))
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
			UiHelper.style_button(lvl_btn, Color(0.20, 0.34, 0.48), Color(0.55, 0.92, 1.0), 6)
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
		sal_g_btn.text = "Salvage (+%d Dust)" % sel_gem.get_salvage_dust()
		UiHelper.style_button(sal_g_btn, Color(0.36, 0.20, 0.20), Color(0.95, 0.55, 0.45), 6)
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
	# Rescue gems if their color no longer fits after recolor
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
