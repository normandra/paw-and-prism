class_name CardWidget
extends PanelContainer

var card_ref: CardInstance = null
var action_row: HBoxContainer = null

func setup_card(card: CardInstance, opts: Dictionary = {}) -> void:
	card_ref = card
	var deck_cd_mult: float = float(opts.get("deck_cd_mult", 1.0))
	var is_selected: bool = bool(opts.get("selected", false))
	var forge_target_mode: bool = bool(opts.get("forge_target_mode", false))
	var can_forge_here: bool = bool(opts.get("can_forge_here", false))
	var forge_reason: String = String(opts.get("forge_reason", ""))
	var compact_mobile: bool = bool(opts.get("compact_mobile", false))

	var rar_col: Color = GameEnums.rarity_color(card.rarity)
	var border_col: Color = rar_col
	var bg_col: Color = Color(0.17, 0.14, 0.12, 0.98) if card.is_template() else Color(0.14, 0.17, 0.22, 0.98)
	var border_w: int = 2

	if is_selected:
		border_col = UiHelper.BORDER_GOLD
		border_w = 3
		bg_col = bg_col.lightened(0.08)
	elif forge_target_mode:
		if can_forge_here:
			border_col = UiHelper.CTA_EMERALD_RIM
			border_w = 3
			bg_col = Color(0.13, 0.24, 0.18, 0.98)
		else:
			border_col = rar_col.darkened(0.55)
			modulate = Color(0.62, 0.60, 0.58, 0.85)

	add_theme_stylebox_override("panel", UiHelper.make_panel_box(bg_col, border_col, 12, border_w, 8))
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP

	var root_v: VBoxContainer = VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 5)
	root_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_v)

	# 1. Header Banner Strip (Kind + Rarity + Forge Pips)
	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 4)
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_v.add_child(top_bar)

	var kind_col: Color = Color(0.28, 0.20, 0.12) if card.is_template() else Color(0.16, 0.27, 0.42)
	var kind_pill: PanelContainer = UiHelper.make_badge_pill(
		GameEnums.card_kind_label(card.card_kind),
		kind_col,
		rar_col,
		rar_col.lightened(0.35),
		10
	)
	top_bar.add_child(kind_pill)

	var rar_lbl: Label = Label.new()
	rar_lbl.text = GameEnums.rarity_label(card.rarity)
	rar_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rar_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rar_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
	rar_lbl.add_theme_font_size_override("font_size", 11)
	rar_lbl.add_theme_color_override("font_color", rar_col)
	top_bar.add_child(rar_lbl)

	if card.is_template():
		top_bar.add_child(UiHelper.make_forge_pips_row(card.get_forge_count(), card.get_max_forges(), rar_col, 10))
		var cnt_lbl: Label = Label.new()
		cnt_lbl.text = "%d/%d" % [card.get_forge_count(), card.get_max_forges()]
		cnt_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cnt_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		cnt_lbl.add_theme_font_size_override("font_size", 11)
		cnt_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
		top_bar.add_child(cnt_lbl)

	# 2. Card Title
	var title_lbl: Label = Label.new()
	title_lbl.text = card.get_display_title()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.clip_text = true
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(title_lbl, 15 if compact_mobile else 16, rar_col.lightened(0.28), 2)
	root_v.add_child(title_lbl)

	# 3. Framed Slay-the-Spire Art Portrait
	var art_frame: PanelContainer = PanelContainer.new()
	art_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, rar_col.darkened(0.25), 8, 2, 4, false))
	root_v.add_child(art_frame)

	var art_rect: TextureRect = TextureRect.new()
	art_rect.texture = UiIcons.get_card_art(card.card_id)
	art_rect.custom_minimum_size = Vector2(0, 62 if compact_mobile else 70)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_frame.add_child(art_rect)

	# 4. Compiled Stats or Compatibility Badge Strip
	if card.is_template():
		var cfg: Dictionary = HeroStats.compile_card_config(card, deck_cd_mult)
		var dmg_val: int = int(round(float(cfg["damage"])))
		var cd_val: float = float(cfg["cooldown"])
		var proj_cnt: int = int(cfg["projectiles"])
		var stat_str: String = "%d DMG%s · %.2fs CD" % [dmg_val, (" x%d" % proj_cnt) if proj_cnt > 1 else "", cd_val]
		var stat_row: HBoxContainer = HBoxContainer.new()
		stat_row.alignment = BoxContainer.ALIGNMENT_CENTER
		stat_row.add_theme_constant_override("separation", 6)
		stat_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root_v.add_child(stat_row)
		stat_row.add_child(UiHelper.make_badge_pill(stat_str, UiHelper.BG_WELL, border_col.darkened(0.2), Color(1.0, 0.94, 0.72), 11))
	else:
		var compat_row: HBoxContainer = HBoxContainer.new()
		compat_row.alignment = BoxContainer.ALIGNMENT_CENTER
		compat_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root_v.add_child(compat_row)
		var compat_txt: String = "Applies to: %s" % CardDatabase.get_compatibility_text(card.card_id)
		compat_row.add_child(UiHelper.make_badge_pill(compat_txt, UiHelper.BG_WELL, UiHelper.CTA_SAPPHIRE_RIM.darkened(0.25), Color(0.76, 0.92, 1.0), 11))

	# 5. Recessed Description Box (+ Forged Add-on Chips)
	var desc_well: PanelContainer = PanelContainer.new()
	desc_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_well.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.08, 0.06, 0.06, 0.92), UiHelper.BORDER_SUBTLE, 8, 1, 7, false))
	root_v.add_child(desc_well)

	var desc_v: VBoxContainer = VBoxContainer.new()
	desc_v.add_theme_constant_override("separation", 4)
	desc_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_well.add_child(desc_v)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = card.get_desc()
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
	desc_v.add_child(desc_lbl)

	if card.is_template():
		var forged: Array[Dictionary] = card.get_forged_summary_counts()
		if not forged.is_empty():
			var flow: HFlowContainer = HFlowContainer.new()
			flow.add_theme_constant_override("h_separation", 4)
			flow.add_theme_constant_override("v_separation", 3)
			flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
			desc_v.add_child(flow)
			for f_entry in forged:
				var f_cnt: int = int(f_entry["count"])
				var f_col: Color = GameEnums.rarity_color(int(f_entry["rarity"]))
				var f_txt: String = "+ %s%s" % [String(f_entry["name"]), (" x%d" % f_cnt) if f_cnt > 1 else ""]
				flow.add_child(UiHelper.make_badge_pill(f_txt, f_col.darkened(0.70), f_col, f_col.lightened(0.40), 10))
		else:
			var empty_f: Label = Label.new()
			empty_f.text = "No Add-ons forged (%d slots open)" % card.get_max_forges()
			empty_f.mouse_filter = Control.MOUSE_FILTER_IGNORE
			empty_f.add_theme_font_size_override("font_size", 11)
			empty_f.add_theme_color_override("font_color", Color(0.68, 0.62, 0.54))
			desc_v.add_child(empty_f)

		if forge_target_mode and not can_forge_here and not forge_reason.is_empty():
			var why_lbl: Label = Label.new()
			why_lbl.text = forge_reason
			why_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			why_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
			why_lbl.add_theme_font_size_override("font_size", 11)
			why_lbl.add_theme_color_override("font_color", Color(1.0, 0.54, 0.48))
			desc_v.add_child(why_lbl)
	else:
		var cons_lbl: Label = Label.new()
		cons_lbl.text = "Consumed permanently when forged into a Template Card."
		cons_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cons_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cons_lbl.add_theme_font_size_override("font_size", 11)
		cons_lbl.add_theme_color_override("font_color", Color(0.96, 0.78, 0.42))
		desc_v.add_child(cons_lbl)

	# 6. Action Button Container (populated by InventoryPanel)
	action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	action_row.mouse_filter = Control.MOUSE_FILTER_PASS
	root_v.add_child(action_row)
