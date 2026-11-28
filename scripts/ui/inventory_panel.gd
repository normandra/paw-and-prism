class_name InventoryPanel
extends ResponsiveModal

signal closed()
signal deck_changed()
signal sfx_requested(sfx_name: String)

var _stats: HeroStats = null

var _hdr_row1: HBoxContainer = null
var _title_lbl: Label = null
var _focus_wide_slot: Control = null
var _focus_mobile_slot: Control = null
var _focus_pill_lbl: Label = null
var _focus_pill: PanelContainer = null
var _close_btn: Button = null

var _tut_banner_panel: PanelContainer = null
var _tut_banner_lbl: Label = null
var _feedback_panel: PanelContainer = null
var _feedback_lbl: Label = null
var _forge_mode_panel: PanelContainer = null
var _forge_mode_icon: TextureRect = null
var _forge_mode_lbl: Label = null
var _forge_cancel_btn: Button = null

var _mobile_tabs_row: HBoxContainer = null
var _m_tab_active_btn: Button = null
var _m_tab_tpl_btn: Button = null
var _m_tab_add_btn: Button = null

var _cols: BoxContainer = null
var _left_box: PanelContainer = null
var _active_hdr_lbl: Label = null
var _active_grid: GridContainer = null

var _right_box: PanelContainer = null
var _right_tab_row: HBoxContainer = null
var _tab_tpl_btn: Button = null
var _tab_add_btn: Button = null
var _collection_grid: GridContainer = null

var _relics_bar: PanelContainer = null
var _relics_flow: HFlowContainer = null
var _forge_anim: ForgeAnimationOverlay = null
var _back_to_shop_mode: bool = false

var _is_mobile_layout: bool = false
var _mobile_tab: String = "active" # active | templates | addons
var _active_right_tab: String = "templates" # templates | addons
var _forging_addon_idx: int = -1
var _tutorial_hint: String = ""

func _init() -> void:
	name = "InventoryPanel"
	max_modal_size = Vector2(1220.0, 690.0)
	compact_breakpoint = 900.0
	fill_height_when_compact = true
	compact_margin = 8
	wide_margin = 18
	modal_bg_color = UiHelper.BG_WOOD_DEEP
	modal_border_color = UiHelper.BORDER_GOLD
	modal_radius = 16
	modal_border_w = 3
	modal_pad = 12

func set_tutorial_hint(hint: String) -> void:
	_tutorial_hint = hint
	if _tut_banner_panel != null and _tut_banner_lbl != null:
		_tut_banner_panel.visible = not hint.is_empty()
		_tut_banner_lbl.text = hint
	if hint.begins_with("Templates tab"):
		_active_right_tab = "templates"
		_mobile_tab = "templates"
	elif hint.begins_with("Add-ons tab"):
		_active_right_tab = "addons"
		_mobile_tab = "addons"

func _clamp_frame_size() -> void:
	_sync_modal_bounds()

func _on_responsive_layout(vp: Vector2, is_compact: bool) -> void:
	_is_mobile_layout = is_compact
	var is_narrow: bool = vp.x < 760.0
	var is_tiny: bool = vp.x < 430.0

	if _focus_pill != null and _focus_wide_slot != null and _focus_mobile_slot != null:
		var want_parent: Control = _focus_mobile_slot if is_narrow else _focus_wide_slot
		if _focus_pill.get_parent() != want_parent:
			_focus_pill.reparent(want_parent)
		_focus_mobile_slot.visible = is_narrow
		_focus_wide_slot.visible = not is_narrow
		_focus_pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL if is_narrow else Control.SIZE_SHRINK_CENTER

	if _mobile_tabs_row != null:
		_mobile_tabs_row.visible = _is_mobile_layout
	if _title_lbl != null:
		_title_lbl.text = "CARD DECK" if _is_mobile_layout else "CARD DECK & FORGE"
		_title_lbl.add_theme_font_size_override("font_size", 17 if is_tiny else (19 if _is_mobile_layout else 22))
	if _close_btn != null:
		if _is_mobile_layout:
			_close_btn.text = "Back to Shop" if _back_to_shop_mode else "Resume"
			_close_btn.custom_minimum_size = Vector2(106 if _back_to_shop_mode else 92, 38)
		else:
			_close_btn.text = "Back to Shop [Esc]" if _back_to_shop_mode else "Resume [Tab / Esc]"
			_close_btn.custom_minimum_size = Vector2(175, 42)
		_close_btn.add_theme_font_size_override("font_size", 13 if is_tiny else 15)

	var grid_cols: int = 1 if vp.x < 620.0 else 2
	if _active_grid != null:
		_active_grid.columns = grid_cols
	if _collection_grid != null:
		_collection_grid.columns = grid_cols

	for mb in [_m_tab_active_btn, _m_tab_tpl_btn, _m_tab_add_btn]:
		if mb != null:
			mb.add_theme_font_size_override("font_size", 12 if is_tiny else 13)

	if visible and _stats != null:
		_apply_column_visibility()

func _apply_column_visibility() -> void:
	if _is_mobile_layout:
		if _left_box != null:
			_left_box.visible = (_mobile_tab == "active")
		if _right_box != null:
			_right_box.visible = (_mobile_tab != "active")
		if _right_tab_row != null:
			_right_tab_row.visible = false
		_active_right_tab = "addons" if _mobile_tab == "addons" else "templates"
	else:
		if _left_box != null:
			_left_box.visible = true
		if _right_box != null:
			_right_box.visible = true
		if _right_tab_row != null:
			_right_tab_row.visible = true

func _build_modal_content(root_v: VBoxContainer) -> void:
	root_v.add_theme_constant_override("separation", 8)

	# Header Row 1
	_hdr_row1 = HBoxContainer.new()
	_hdr_row1.add_theme_constant_override("separation", 8)
	root_v.add_child(_hdr_row1)

	_hdr_row1.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("deck_cards"), 26))

	_title_lbl = Label.new()
	_title_lbl.text = "CARD DECK & FORGE"
	UiHelper.apply_display_font(_title_lbl, 22, UiHelper.BORDER_GOLD, 3)
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.clip_text = true
	_hdr_row1.add_child(_title_lbl)

	_focus_wide_slot = HBoxContainer.new()
	_focus_wide_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hdr_row1.add_child(_focus_wide_slot)

	_focus_pill = PanelContainer.new()
	_focus_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, UiHelper.BORDER_BRASS, 8, 1, 6, false))
	_focus_wide_slot.add_child(_focus_pill)
	_focus_pill_lbl = Label.new()
	_focus_pill_lbl.text = "Active: 1 Card · 100% Cast Rate"
	_focus_pill_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_focus_pill_lbl.clip_text = true
	_focus_pill_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_focus_pill_lbl.add_theme_font_size_override("font_size", 12)
	_focus_pill_lbl.add_theme_color_override("font_color", Color(0.64, 0.96, 0.72))
	_focus_pill.add_child(_focus_pill_lbl)

	_close_btn = Button.new()
	_close_btn.text = "Resume [Tab / Esc]"
	_close_btn.custom_minimum_size = Vector2(175, 42)
	_close_btn.clip_text = true
	_close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_close_btn, UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, 10)
	_close_btn.add_theme_font_size_override("font_size", 15)
	_close_btn.pressed.connect(func() -> void: close_panel())
	_hdr_row1.add_child(_close_btn)

	# Mobile Header Row 2 (Focus Rate Pill)
	_focus_mobile_slot = HBoxContainer.new()
	_focus_mobile_slot.visible = false
	_focus_mobile_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_v.add_child(_focus_mobile_slot)

	# Tutorial Hint Banner
	_tut_banner_panel = PanelContainer.new()
	_tut_banner_panel.visible = false
	_tut_banner_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.28, 0.20, 0.08), UiHelper.BORDER_GOLD, 10, 2, 8, false))
	root_v.add_child(_tut_banner_panel)
	var tb_h: HBoxContainer = HBoxContainer.new()
	tb_h.add_theme_constant_override("separation", 8)
	_tut_banner_panel.add_child(tb_h)
	tb_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 20))
	_tut_banner_lbl = Label.new()
	_tut_banner_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tut_banner_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tut_banner_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_tut_banner_lbl.add_theme_font_size_override("font_size", 13)
	_tut_banner_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
	tb_h.add_child(_tut_banner_lbl)

	# Confirmation Strip
	_feedback_panel = PanelContainer.new()
	_feedback_panel.visible = false
	_feedback_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.11, 0.28, 0.17), UiHelper.CTA_EMERALD_RIM, 8, 1, 6, false))
	root_v.add_child(_feedback_panel)
	_feedback_lbl = Label.new()
	_feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_feedback_lbl.add_theme_font_size_override("font_size", 13)
	_feedback_lbl.add_theme_color_override("font_color", Color(0.68, 1.0, 0.78))
	_feedback_panel.add_child(_feedback_lbl)

	# Active Forge Mode Banner
	_forge_mode_panel = PanelContainer.new()
	_forge_mode_panel.visible = false
	_forge_mode_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.16, 0.24, 0.36), UiHelper.BORDER_GOLD, 10, 2, 8, false))
	root_v.add_child(_forge_mode_panel)
	var fm_h: HBoxContainer = HBoxContainer.new()
	fm_h.add_theme_constant_override("separation", 8)
	_forge_mode_panel.add_child(fm_h)
	_forge_mode_icon = UiHelper.make_icon_rect(UiIcons.get_ui_icon("anvil_forge"), 24)
	fm_h.add_child(_forge_mode_icon)
	_forge_mode_lbl = Label.new()
	_forge_mode_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_forge_mode_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_forge_mode_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	_forge_mode_lbl.add_theme_font_size_override("font_size", 12)
	_forge_mode_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.50))
	fm_h.add_child(_forge_mode_lbl)
	_forge_cancel_btn = Button.new()
	_forge_cancel_btn.text = "Cancel"
	_forge_cancel_btn.custom_minimum_size = Vector2(78, 34)
	_forge_cancel_btn.clip_text = true
	_forge_cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(_forge_cancel_btn, UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, 8, 4)
	_forge_cancel_btn.pressed.connect(func() -> void: cancel_forge())
	fm_h.add_child(_forge_cancel_btn)

	# Mobile Single-Column Tabs (Active | Templates | Add-ons)
	_mobile_tabs_row = HBoxContainer.new()
	_mobile_tabs_row.visible = false
	_mobile_tabs_row.add_theme_constant_override("separation", 6)
	root_v.add_child(_mobile_tabs_row)
	_m_tab_active_btn = _make_tab_button("Active", true, func() -> void:
		_mobile_tab = "active"
		refresh()
	)
	_m_tab_tpl_btn = _make_tab_button("Templates", true, func() -> void:
		_mobile_tab = "templates"
		_active_right_tab = "templates"
		refresh()
	)
	_m_tab_add_btn = _make_tab_button("Add-ons", true, func() -> void:
		_mobile_tab = "addons"
		_active_right_tab = "addons"
		refresh()
	)
	_mobile_tabs_row.add_child(_m_tab_active_btn)
	_mobile_tabs_row.add_child(_m_tab_tpl_btn)
	_mobile_tabs_row.add_child(_m_tab_add_btn)

	# Desktop 2-Pane Split (Left: Active Deck | Right: Templates & Add-ons)
	_cols = BoxContainer.new()
	_cols.vertical = false
	_cols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cols.add_theme_constant_override("separation", 12)
	root_v.add_child(_cols)

	# LEFT PANE: Active Equipped Deck
	_left_box = PanelContainer.new()
	_left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	_cols.add_child(_left_box)

	var left_v: VBoxContainer = VBoxContainer.new()
	left_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_v.add_theme_constant_override("separation", 8)
	_left_box.add_child(left_v)

	_active_hdr_lbl = Label.new()
	_active_hdr_lbl.text = "ACTIVE DECK (Any Limit)"
	_active_hdr_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_active_hdr_lbl.clip_text = true
	UiHelper.apply_display_font(_active_hdr_lbl, 15, UiHelper.BORDER_GOLD, 2)
	left_v.add_child(_active_hdr_lbl)

	var active_scroll: TouchScrollContainer = TouchScrollContainer.new()
	active_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_v.add_child(active_scroll)

	_active_grid = GridContainer.new()
	_active_grid.columns = 2
	_active_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_active_grid.add_theme_constant_override("h_separation", 8)
	_active_grid.add_theme_constant_override("v_separation", 8)
	active_scroll.add_child(_active_grid)

	# RIGHT PANE: Card Collection (Templates & Add-ons)
	_right_box = PanelContainer.new()
	_right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_box.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WALNUT, UiHelper.BORDER_SUBTLE, 12, 1, 10, false))
	_cols.add_child(_right_box)

	var right_v: VBoxContainer = VBoxContainer.new()
	right_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_v.add_theme_constant_override("separation", 8)
	_right_box.add_child(right_v)

	_right_tab_row = HBoxContainer.new()
	_right_tab_row.add_theme_constant_override("separation", 6)
	right_v.add_child(_right_tab_row)

	_tab_tpl_btn = _make_tab_button("Templates", false, func() -> void:
		_active_right_tab = "templates"
		refresh()
	)
	_tab_add_btn = _make_tab_button("Add-ons", false, func() -> void:
		_active_right_tab = "addons"
		refresh()
	)
	_right_tab_row.add_child(_tab_tpl_btn)
	_right_tab_row.add_child(_tab_add_btn)

	var col_scroll: TouchScrollContainer = TouchScrollContainer.new()
	col_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_v.add_child(col_scroll)

	_collection_grid = GridContainer.new()
	_collection_grid.columns = 2
	_collection_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_collection_grid.add_theme_constant_override("h_separation", 8)
	_collection_grid.add_theme_constant_override("v_separation", 8)
	col_scroll.add_child(_collection_grid)

	# Owned Relics Ribbon at bottom of Deck frame
	_relics_bar = PanelContainer.new()
	_relics_bar.visible = false
	_relics_bar.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.12, 0.10, 0.18, 0.94), Color(0.68, 0.50, 0.92), 10, 1, 6, false))
	root_v.add_child(_relics_bar)
	_relics_flow = HFlowContainer.new()
	_relics_flow.add_theme_constant_override("h_separation", 6)
	_relics_flow.add_theme_constant_override("v_separation", 4)
	_relics_bar.add_child(_relics_flow)

	# Juicy Forge Animation Overlay (topmost fullscreen child of InventoryPanel)
	_forge_anim = ForgeAnimationOverlay.new()
	add_child(_forge_anim)

func _make_tab_button(label_txt: String, is_mobile_bar: bool, on_press: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = label_txt
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 38 if is_mobile_bar else 36)
	btn.clip_text = true
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 13 if is_mobile_bar else 14)
	btn.pressed.connect(on_press)
	return btn

func _connect_tap(ctrl: Control, callback: Callable) -> void:
	ctrl.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				ctrl.set_meta("_tap_origin", ev.global_position)
			elif ctrl.has_meta("_tap_origin"):
				var origin: Vector2 = ctrl.get_meta("_tap_origin")
				ctrl.remove_meta("_tap_origin")
				if origin.distance_to(ev.global_position) <= 18.0:
					ctrl.accept_event()
					callback.call()
	)

func _show_feedback(msg: String) -> void:
	if _feedback_panel == null or _feedback_lbl == null:
		return
	_feedback_lbl.text = msg
	_feedback_panel.visible = not msg.is_empty()

func open_panel(stats: HeroStats, back_to_shop: bool = false) -> void:
	_stats = stats
	_back_to_shop_mode = back_to_shop
	_forging_addon_idx = -1
	_show_feedback("")
	if not _tutorial_hint.is_empty():
		set_tutorial_hint(_tutorial_hint)
	visible = true
	_sync_modal_bounds()
	refresh()

func close_panel() -> void:
	_forging_addon_idx = -1
	if _forge_anim != null and _forge_anim.visible:
		_forge_anim.visible = false
	visible = false
	closed.emit()

func cancel_forge() -> void:
	_forging_addon_idx = -1
	refresh()

func start_forge_addon_at(addon_idx: int) -> void:
	if _stats == null or addon_idx < 0 or addon_idx >= _stats.addon_inventory.size():
		return
	_forging_addon_idx = addon_idx
	if _is_mobile_layout:
		_mobile_tab = "active"
	sfx_requested.emit("ui_click")
	refresh()

func equip_template_at(inv_idx: int) -> bool:
	if _stats == null:
		return false
	var res: Dictionary = _stats.equip_template_from_inventory(inv_idx)
	if not bool(res.get("ok", false)):
		return false
	var card: CardInstance = res["card"]
	_show_feedback("Equipped %s into Active Deck!" % card.get_display_title())
	sfx_requested.emit("equip_snap")
	deck_changed.emit()
	refresh()
	return true

func unequip_card_at(eq_idx: int) -> bool:
	if _stats == null:
		return false
	var res: Dictionary = _stats.unequip_template_card(eq_idx)
	if not bool(res.get("ok", false)):
		return false
	var card: CardInstance = res["card"]
	_show_feedback("Moved %s to Template Collection." % card.get_display_title())
	sfx_requested.emit("ui_click")
	deck_changed.emit()
	refresh()
	return true

func confirm_forge_onto_card(target_card: CardInstance, animate: bool = true) -> bool:
	if _stats == null or _forging_addon_idx < 0 or target_card == null:
		return false
	var res: Dictionary = _stats.forge_addon_onto_card(_forging_addon_idx, target_card)
	if not bool(res.get("ok", false)):
		_show_feedback(String(res.get("reason", "Cannot forge Add-on here")))
		return false
	var addon_name: String = String(res.get("addon_name", "Add-on"))
	var consumed_addon: CardInstance = res.get("addon_card", null)
	_forging_addon_idx = -1
	_show_feedback("Forged %s onto %s (%d/%d)!" % [
		addon_name,
		target_card.get_card_name(),
		target_card.get_forge_count(),
		target_card.get_max_forges(_stats.bonus_forge_slots),
	])
	sfx_requested.emit("socket_chime")
	deck_changed.emit()
	refresh()
	if animate and _forge_anim != null and visible and consumed_addon != null:
		_forge_anim.play_forge(
			target_card,
			consumed_addon,
			_stats.bonus_forge_slots,
			_stats.deck_cd_mult,
			_stats.relic_cd_mult,
			func() -> void: refresh()
		)
	return true

func confirm_forge_onto_equipped(eq_idx: int, animate: bool = true) -> bool:
	if _stats == null or eq_idx < 0 or eq_idx >= _stats.equipped_cards.size():
		return false
	return confirm_forge_onto_card(_stats.equipped_cards[eq_idx], animate)

func confirm_forge_onto_inventory_template(inv_idx: int, animate: bool = true) -> bool:
	if _stats == null or inv_idx < 0 or inv_idx >= _stats.template_inventory.size():
		return false
	return confirm_forge_onto_card(_stats.template_inventory[inv_idx], animate)

func refresh() -> void:
	if _stats == null or _active_grid == null:
		return
	if _forging_addon_idx >= _stats.addon_inventory.size():
		_forging_addon_idx = -1

	_apply_column_visibility()
	_refresh_focus_header()
	_refresh_forge_banner()
	_refresh_tab_buttons()
	_rebuild_active_grid()
	_rebuild_collection_grid()
	_refresh_relics_bar()

func _refresh_relics_bar() -> void:
	if _relics_bar == null or _relics_flow == null or _stats == null:
		return
	for c in _relics_flow.get_children():
		_relics_flow.remove_child(c)
		c.queue_free()
	var vp: Vector2 = get_safe_viewport_size()
	# Keep bottom bar omitted if vertical space on short mobile landscape is tight (Relics remain in Shop/Pause/HUD)
	if _stats.owned_relics.is_empty() or vp.y < 520.0:
		_relics_bar.visible = false
		return
	_relics_bar.visible = true
	var hdr: Label = Label.new()
	hdr.text = "Relics:"
	hdr.add_theme_font_override("font", UiHelper.get_bold_font())
	hdr.add_theme_font_size_override("font_size", 11)
	hdr.add_theme_color_override("font_color", Color(0.92, 0.80, 1.0))
	_relics_flow.add_child(hdr)
	var is_compact_chip: bool = vp.x < 500.0
	for rid in _stats.owned_relics:
		var rdef: Dictionary = RelicDatabase.get_def(rid)
		var rar_c: Color = GameEnums.rarity_color(int(rdef.get("rarity", GameEnums.Rarity.UNCOMMON)))
		var chip: PanelContainer = PanelContainer.new()
		chip.tooltip_text = "%s: %s" % [String(rdef.get("name", rid)), String(rdef.get("desc", ""))]
		chip.add_theme_stylebox_override("panel", UiHelper.make_panel_box(rar_c.darkened(0.75), rar_c, 8, 1, 4, false))
		var ch_h: HBoxContainer = HBoxContainer.new()
		ch_h.add_theme_constant_override("separation", 4)
		chip.add_child(ch_h)
		var ic: TextureRect = TextureRect.new()
		ic.texture = UiIcons.get_relic_art(rid)
		ic.custom_minimum_size = Vector2(20, 15)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ch_h.add_child(ic)
		var lbl: Label = Label.new()
		lbl.text = String(rdef.get("name", rid)) if is_compact_chip else "%s (%s)" % [String(rdef.get("name", rid)), String(rdef.get("tag", ""))]
		lbl.add_theme_font_size_override("font_size", 10 if is_compact_chip else 11)
		lbl.add_theme_color_override("font_color", rar_c.lightened(0.40))
		ch_h.add_child(lbl)
		_relics_flow.add_child(chip)

func _refresh_focus_header() -> void:
	var n: int = _stats.equipped_card_count
	var eff_cd: float = _stats.deck_cd_mult * _stats.relic_cd_mult
	var rate_pct: int = int(round((1.0 / maxf(0.1, eff_cd)) * 100.0))
	var tag: String = "Focused" if n <= 2 else ("Balanced" if n == 3 else "Deck Tax x%.2f" % _stats.deck_cd_mult)
	_focus_pill_lbl.text = "Active: %d Card%s · %d%% Rate (%s)" % [n, "" if n == 1 else "s", rate_pct, tag]
	var col: Color = Color(0.64, 0.96, 0.72) if n <= 3 else Color(1.0, 0.78, 0.36)
	_focus_pill_lbl.add_theme_color_override("font_color", col)
	_active_hdr_lbl.text = "ACTIVE DECK (%d Equipped)" % n

func _refresh_forge_banner() -> void:
	if _forging_addon_idx >= 0 and _forging_addon_idx < _stats.addon_inventory.size():
		var addon: CardInstance = _stats.addon_inventory[_forging_addon_idx]
		_forge_mode_icon.texture = UiIcons.get_card_art(addon.card_id)
		_forge_mode_lbl.text = "FORGE MODE: %s (%s) — Tap [+ Forge Here] on any compatible Template Card! (Consumes Add-on)" % [
			addon.get_card_name(),
			CardDatabase.get_compatibility_text(addon.card_id),
		]
		_forge_mode_panel.visible = true
	else:
		_forge_mode_panel.visible = false

func _refresh_tab_buttons() -> void:
	var n_act: int = _stats.equipped_cards.size()
	var n_tpl: int = _stats.template_inventory.size()
	var n_add: int = _stats.addon_inventory.size()

	_tab_tpl_btn.text = "Templates (%d)" % n_tpl
	_tab_add_btn.text = "Add-ons (%d)" % n_add
	_m_tab_active_btn.text = "Active (%d)" % n_act
	_m_tab_tpl_btn.text = "Templates (%d)" % n_tpl
	_m_tab_add_btn.text = "Add-ons (%d)" % n_add

	UiHelper.style_button(_tab_tpl_btn, UiHelper.CTA_SAPPHIRE if _active_right_tab == "templates" else UiHelper.BG_OAK_CARD, UiHelper.BORDER_GOLD if _active_right_tab == "templates" else UiHelper.BORDER_BRASS, 8, 5)
	UiHelper.style_button(_tab_add_btn, UiHelper.CTA_SAPPHIRE if _active_right_tab == "addons" else UiHelper.BG_OAK_CARD, UiHelper.BORDER_GOLD if _active_right_tab == "addons" else UiHelper.BORDER_BRASS, 8, 5)

	var m_btns: Dictionary = {"active": _m_tab_active_btn, "templates": _m_tab_tpl_btn, "addons": _m_tab_add_btn}
	for k in m_btns.keys():
		var b: Button = m_btns[k]
		var active_b: bool = (_mobile_tab == k)
		UiHelper.style_button(b, UiHelper.CTA_SAPPHIRE if active_b else UiHelper.BG_OAK_CARD, UiHelper.BORDER_GOLD if active_b else UiHelper.BORDER_BRASS, 8, 5)

func _rebuild_active_grid() -> void:
	for ch in _active_grid.get_children():
		_active_grid.remove_child(ch)
		ch.queue_free()

	if _stats.equipped_cards.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No active cards equipped.\nEquip a Template Card to start casting!"
		empty_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_font_size_override("font_size", 14)
		empty_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		_active_grid.add_child(empty_lbl)
		return

	var pending_addon: CardInstance = _stats.addon_inventory[_forging_addon_idx] if (_forging_addon_idx >= 0 and _forging_addon_idx < _stats.addon_inventory.size()) else null

	for idx in range(_stats.equipped_cards.size()):
		var card: CardInstance = _stats.equipped_cards[idx]
		var forge_check: Dictionary = card.can_accept_addon(pending_addon, _stats.bonus_forge_slots) if pending_addon != null else {"ok": false, "reason": ""}
		var cw: CardWidget = CardWidget.new()
		cw.setup_card(card, {
			"deck_cd_mult": _stats.deck_cd_mult,
			"relic_cd_mult": _stats.relic_cd_mult,
			"crit_chance": _stats.crit_chance,
			"crit_mult": _stats.crit_mult,
			"bonus_forges": _stats.bonus_forge_slots,
			"forge_target_mode": pending_addon != null,
			"can_forge_here": bool(forge_check.get("ok", false)),
			"forge_reason": String(forge_check.get("reason", "")),
			"compact_mobile": _is_mobile_layout,
		})

		var eq_i: int = idx
		if pending_addon != null:
			if bool(forge_check.get("ok", false)):
				var f_btn: Button = _make_card_btn("+ Forge Here", UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, func() -> void: confirm_forge_onto_equipped(eq_i))
				cw.action_row.add_child(f_btn)
				_connect_tap(cw, func() -> void: confirm_forge_onto_equipped(eq_i))
		else:
			var u_btn: Button = _make_card_btn("Unequip", UiHelper.BG_OAK_CARD, UiHelper.BORDER_BRASS, func() -> void: unequip_card_at(eq_i))
			cw.action_row.add_child(u_btn)

		_active_grid.add_child(cw)

func _rebuild_collection_grid() -> void:
	for ch in _collection_grid.get_children():
		_collection_grid.remove_child(ch)
		ch.queue_free()

	if _active_right_tab == "templates":
		if _stats.template_inventory.is_empty():
			var e_tpl: Label = Label.new()
			e_tpl.text = "No spare Template Cards in collection.\nBuy Template Cards at Caravan Shops every 3 minutes!"
			e_tpl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			e_tpl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			e_tpl.add_theme_font_size_override("font_size", 14)
			e_tpl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
			_collection_grid.add_child(e_tpl)
			return

		var pending_addon: CardInstance = _stats.addon_inventory[_forging_addon_idx] if (_forging_addon_idx >= 0 and _forging_addon_idx < _stats.addon_inventory.size()) else null
		for idx in range(_stats.template_inventory.size()):
			var card: CardInstance = _stats.template_inventory[idx]
			var forge_check: Dictionary = card.can_accept_addon(pending_addon, _stats.bonus_forge_slots) if pending_addon != null else {"ok": false, "reason": ""}
			var cw: CardWidget = CardWidget.new()
			cw.setup_card(card, {
				"deck_cd_mult": _stats.deck_cd_mult,
				"relic_cd_mult": _stats.relic_cd_mult,
				"crit_chance": _stats.crit_chance,
				"crit_mult": _stats.crit_mult,
				"bonus_forges": _stats.bonus_forge_slots,
				"forge_target_mode": pending_addon != null,
				"can_forge_here": bool(forge_check.get("ok", false)),
				"forge_reason": String(forge_check.get("reason", "")),
				"compact_mobile": _is_mobile_layout,
			})

			var tpl_i: int = idx
			if pending_addon != null:
				if bool(forge_check.get("ok", false)):
					var f_btn: Button = _make_card_btn("+ Forge Here", UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, func() -> void: confirm_forge_onto_inventory_template(tpl_i))
					cw.action_row.add_child(f_btn)
					_connect_tap(cw, func() -> void: confirm_forge_onto_inventory_template(tpl_i))
			else:
				var eq_btn: Button = _make_card_btn("Equip", UiHelper.CTA_EMERALD, UiHelper.CTA_EMERALD_RIM, func() -> void: equip_template_at(tpl_i))
				cw.action_row.add_child(eq_btn)
				var del_btn: Button = _make_card_btn("Drop", UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, func() -> void:
					_stats.discard_template(tpl_i)
					_show_feedback("Discarded Template Card.")
					refresh()
				, true)
				cw.action_row.add_child(del_btn)
			_collection_grid.add_child(cw)
	else:
		if _stats.addon_inventory.is_empty():
			var e_add: Label = Label.new()
			e_add.text = "No Add-on Cards in pouch.\nVisit Caravan Shops every 3 minutes for Add-ons & Relics!"
			e_add.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			e_add.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			e_add.add_theme_font_size_override("font_size", 14)
			e_add.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
			_collection_grid.add_child(e_add)
			return

		for idx in range(_stats.addon_inventory.size()):
			var addon: CardInstance = _stats.addon_inventory[idx]
			var is_sel: bool = (idx == _forging_addon_idx)
			var cw: CardWidget = CardWidget.new()
			cw.setup_card(addon, {
				"selected": is_sel,
				"compact_mobile": _is_mobile_layout,
			})
			var add_i: int = idx
			if is_sel:
				var c_btn: Button = _make_card_btn("Selecting Target...", UiHelper.BORDER_GOLD.darkened(0.45), UiHelper.BORDER_GOLD, func() -> void: cancel_forge())
				cw.action_row.add_child(c_btn)
			else:
				var f_btn: Button = _make_card_btn("Forge onto Card", UiHelper.CTA_SAPPHIRE, UiHelper.CTA_SAPPHIRE_RIM, func() -> void: start_forge_addon_at(add_i))
				cw.action_row.add_child(f_btn)
				_connect_tap(cw, func() -> void: start_forge_addon_at(add_i))
			var del_btn: Button = _make_card_btn("Drop", UiHelper.CTA_RUBY, UiHelper.CTA_RUBY_RIM, func() -> void:
				if _forging_addon_idx == add_i:
					_forging_addon_idx = -1
				elif _forging_addon_idx > add_i:
					_forging_addon_idx -= 1
				_stats.discard_addon(add_i)
				_show_feedback("Discarded Add-on Card.")
				refresh()
			, true)
			cw.action_row.add_child(del_btn)
			_collection_grid.add_child(cw)

func _make_card_btn(txt: String, bg: Color, border: Color, on_tap: Callable, narrow: bool = false) -> Button:
	var btn: Button = Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(58 if narrow else 0, 38)
	btn.clip_text = true
	if not narrow:
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UiHelper.style_button(btn, bg, border, 8, 5)
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(on_tap)
	return btn
