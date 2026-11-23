class_name LevelUpModal
extends Control

signal option_chosen(payload: Dictionary)

var _is_mobile_mode: bool = false
var _panel: PanelContainer = null
var _cards_box: BoxContainer = null
var _title_lbl: Label = null
var _sub_lbl: Label = null
var _current_options: Array[Dictionary] = []

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

func set_mobile_mode(is_mobile: bool) -> void:
	_is_mobile_mode = is_mobile
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 10.0:
		return
	var is_portrait: bool = vp.x < 900.0
	if _panel != null:
		if is_portrait:
			_panel.custom_minimum_size = Vector2(minf(vp.x - 32.0, 680.0), minf(vp.y - 96.0, 860.0))
		else:
			_panel.custom_minimum_size = Vector2(830.0, 420.0)
	if _cards_box != null:
		_cards_box.vertical = is_portrait
	if _sub_lbl != null:
		_sub_lbl.text = (
			"Tap an Enchantment Card to Choose"
			if _is_mobile_mode
			else "Select an Enchantment Card (Click anywhere on card or press [1] / [2] / [3])"
		)

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.02, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(830, 420)
	_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WOOD_DEEP, UiHelper.BORDER_GOLD, 16, 3, 20))
	center.add_child(_panel)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_panel.add_child(v)

	var hdr_h: HBoxContainer = HBoxContainer.new()
	hdr_h.alignment = BoxContainer.ALIGNMENT_CENTER
	hdr_h.add_theme_constant_override("separation", 12)
	v.add_child(hdr_h)
	hdr_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 36))

	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHelper.apply_display_font(_title_lbl, 28, Color(1.0, 0.90, 0.40), 4)
	hdr_h.add_child(_title_lbl)
	hdr_h.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon("star_upgrade"), 36))

	_sub_lbl = Label.new()
	_sub_lbl.text = "Select an Enchantment Card (Click anywhere on card or press [1] / [2] / [3])"
	_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_lbl.add_theme_font_size_override("font_size", 13)
	_sub_lbl.add_theme_color_override("font_color", UiHelper.TEXT_PARCHMENT)
	v.add_child(_sub_lbl)

	_cards_box = BoxContainer.new()
	_cards_box.vertical = false
	_cards_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cards_box.add_theme_constant_override("separation", 14)
	v.add_child(_cards_box)

func open_for_level(new_level: int, stats: HeroStats) -> void:
	_title_lbl.text = "LEVEL %d REACHED!" % new_level
	_apply_responsive_layout()
	for ch in _cards_box.get_children():
		ch.queue_free()
	_current_options = _roll_options(stats)

	for i in range(_current_options.size()):
		var opt: Dictionary = _current_options[i]
		var col: Color = opt["color"]
		var base_bg: Color = UiHelper.BG_WALNUT.lerp(col.darkened(0.72), 0.36)
		var hover_bg: Color = base_bg.lightened(0.14)

		var card: PanelContainer = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var normal_sb: StyleBoxFlat = UiHelper.make_panel_box(base_bg, col, 14, 2, 14)
		var hover_sb: StyleBoxFlat = UiHelper.make_panel_box(hover_bg, col.lightened(0.25), 14, 3, 14)
		card.add_theme_stylebox_override("panel", normal_sb)

		var captured: Dictionary = opt
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_pick(captured)
		)
		card.mouse_entered.connect(func() -> void: card.add_theme_stylebox_override("panel", hover_sb))
		card.mouse_exited.connect(func() -> void: card.add_theme_stylebox_override("panel", normal_sb))
		_cards_box.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.alignment = BoxContainer.ALIGNMENT_CENTER
		cv.add_theme_constant_override("separation", 9)
		cv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(cv)

		var cat_center: CenterContainer = CenterContainer.new()
		cat_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(cat_center)
		var ribbon: PanelContainer = UiHelper.make_badge_pill(String(opt["category"]), col.darkened(0.45), col, UiHelper.TEXT_CREAM, 12)
		ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cat_center.add_child(ribbon)

		var icon_center: CenterContainer = CenterContainer.new()
		icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(icon_center)
		var icon_ring: PanelContainer = PanelContainer.new()
		icon_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_ring.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, col, 38, 3, 12, false))
		icon_center.add_child(icon_ring)
		icon_ring.add_child(UiHelper.make_icon_rect(UiIcons.get_ui_icon(String(opt["icon"])), 52))

		var t_lbl: Label = Label.new()
		t_lbl.text = String(opt["title"])
		t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		UiHelper.apply_display_font(t_lbl, 20, UiHelper.TEXT_CREAM, 2)
		cv.add_child(t_lbl)

		var d_lbl: Label = Label.new()
		d_lbl.text = String(opt["desc"])
		d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		d_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		d_lbl.add_theme_font_size_override("font_size", 14)
		d_lbl.add_theme_color_override("font_color", UiHelper.TEXT_CREAM)
		cv.add_child(d_lbl)

		# Concrete Before -> After stat preview box
		var preview_well: PanelContainer = PanelContainer.new()
		preview_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview_well.add_theme_stylebox_override("panel", UiHelper.make_panel_box(UiHelper.BG_WELL, col.darkened(0.35), 8, 1, 7, false))
		cv.add_child(preview_well)
		var pv_lbl: Label = Label.new()
		pv_lbl.text = _build_preview_text(opt, stats)
		pv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pv_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pv_lbl.add_theme_font_override("font", UiHelper.get_bold_font())
		pv_lbl.add_theme_font_size_override("font_size", 12)
		pv_lbl.add_theme_color_override("font_color", col.lightened(0.28))
		preview_well.add_child(pv_lbl)

		var spacer: Control = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(spacer)

		var choose_btn: Button = Button.new()
		choose_btn.text = "[%d] CHOOSE" % (i + 1)
		choose_btn.custom_minimum_size = Vector2(0, 44)
		choose_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UiHelper.style_button(choose_btn, col.darkened(0.34), col, 10, 8)
		choose_btn.pressed.connect(func() -> void: _pick(captured))
		cv.add_child(choose_btn)

	visible = true

func _build_preview_text(opt: Dictionary, stats: HeroStats) -> String:
	var kind: String = String(opt.get("kind", "stat"))
	if kind == "dust_pack":
		return "Prism Dust: %d -> %d" % [stats.prism_dust, stats.prism_dust + int(opt["val"])]
	if kind == "gem_xp":
		return "Equipped Gems: +140 XP"
	if kind == "free_gem":
		return "Gem Pouch: %d -> %d" % [stats.gem_pouch.size(), stats.gem_pouch.size() + 1]
	var st: int = int(opt.get("stat", 0))
	var v: float = float(opt.get("val", 0.0))
	match st:
		GameEnums.StatType.DAMAGE_PCT:
			var cur: int = int(round(stats.damage_mult * 100.0))
			return "Damage: %d%% -> %d%%" % [cur, cur + int(v)]
		GameEnums.StatType.CAST_SPEED_PCT:
			var cur_c: int = int(round(stats.cast_speed_mult * 100.0))
			return "Cast Speed: %d%% -> %d%%" % [cur_c, cur_c + int(v)]
		GameEnums.StatType.MAX_HP:
			var cur_hp: int = int(round(stats.max_hp))
			return "Max HP: %d -> %d" % [cur_hp, cur_hp + int(v)]
		GameEnums.StatType.AREA_PCT:
			var cur_a: int = int(round(stats.area_mult * 100.0))
			return "Area Size: %d%% -> %d%%" % [cur_a, cur_a + int(v)]
		GameEnums.StatType.CRIT_CHANCE:
			return "Crit Chance: %.0f%% -> %.0f%%" % [stats.crit_chance, minf(95.0, stats.crit_chance + v)]
		GameEnums.StatType.MOVE_SPEED_PCT:
			return "Move Speed: %.1f -> %.1f" % [stats.move_speed, stats.move_speed * (1.0 + v * 0.01)]
		GameEnums.StatType.ARMOR:
			return "Armor: %d -> %d" % [int(round(stats.armor)), int(round(stats.armor + v))]
		GameEnums.StatType.MAGIC_FIND_PCT:
			return "Magic Find: +%d%% -> +%d%%" % [int(round(stats.magic_find)), int(round(stats.magic_find + v))]
	return "Instant Hero Bonus"

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var idx: int = -1
		if event.keycode == KEY_1:
			idx = 0
		elif event.keycode == KEY_2:
			idx = 1
		elif event.keycode == KEY_3:
			idx = 2
		if idx >= 0 and idx < _current_options.size():
			get_viewport().set_input_as_handled()
			_pick(_current_options[idx])

func _pick(opt: Dictionary) -> void:
	visible = false
	option_chosen.emit(opt)

func _roll_options(stats: HeroStats) -> Array[Dictionary]:
	var pool: Array[Dictionary] = [
		{"kind": "stat", "stat": GameEnums.StatType.DAMAGE_PCT, "val": 14.0, "category": "OFFENSE", "icon": "star_upgrade", "title": "Ferocious Paws", "desc": "+14% All Damage", "color": Color(1.0, 0.55, 0.32)},
		{"kind": "stat", "stat": GameEnums.StatType.CAST_SPEED_PCT, "val": 12.0, "category": "TEMPO", "icon": "dash_paw", "title": "Swift Whiskers", "desc": "+12% Attack & Cast Speed", "color": Color(0.45, 0.90, 0.60)},
		{"kind": "stat", "stat": GameEnums.StatType.MAX_HP, "val": 32.0, "category": "VITALITY", "icon": "heart", "title": "Fluffy Heartiness", "desc": "+32 Max HP & heals 32 HP", "color": Color(0.95, 0.42, 0.52)},
		{"kind": "stat", "stat": GameEnums.StatType.AREA_PCT, "val": 16.0, "category": "ARCANE", "icon": "sun_meadow", "title": "Blooming Aura", "desc": "+16% Area Size", "color": Color(0.48, 0.78, 1.0)},
		{"kind": "stat", "stat": GameEnums.StatType.CRIT_CHANCE, "val": 7.0, "category": "PRECISION", "icon": "star_upgrade", "title": "Sharp Claws", "desc": "+7% Critical Strike Chance", "color": Color(1.0, 0.85, 0.32)},
		{"kind": "stat", "stat": GameEnums.StatType.MOVE_SPEED_PCT, "val": 10.0, "category": "AGILITY", "icon": "dash_paw", "title": "Zoomies Boost", "desc": "+10% Move Speed", "color": Color(0.55, 0.96, 0.60)},
		{"kind": "stat", "stat": GameEnums.StatType.ARMOR, "val": 12.0, "category": "DEFENSE", "icon": "boss_crown", "title": "Acorn Plating", "desc": "+12 Armor", "color": Color(0.88, 0.74, 0.45)},
		{"kind": "stat", "stat": GameEnums.StatType.MAGIC_FIND_PCT, "val": 20.0, "category": "TREASURE", "icon": "bag", "title": "Lucky Tail", "desc": "+20% Magic Find (Better Gear!)", "color": Color(1.0, 0.72, 0.28)},
		{"kind": "gem_xp", "val": 140.0, "category": "PRISM SURGE", "icon": "prism_dust", "title": "Prismatic Surge", "desc": "+140 XP to all socketed Active, Support & Passive Gems!", "color": Color(0.68, 0.56, 1.0)},
		{"kind": "dust_pack", "val": 25.0, "category": "CRAFTING", "icon": "prism_dust", "title": "Prism Dust Pouch", "desc": "+25 Prism Dust for Recoloring & Linking Sockets!", "color": Color(0.45, 0.94, 1.0)},
	]
	if stats.can_add_gem_to_pouch():
		pool.append({"kind": "free_gem", "val": 1.0, "category": "SKILL GEM", "icon": "paw_prism_crest", "title": "Mystery Skill Gem", "desc": "Gain a random Active, Support, or Passive Skill Gem!", "color": Color(0.96, 0.68, 1.0)})

	pool.shuffle()
	var out: Array[Dictionary] = []
	for i in range(mini(3, pool.size())):
		out.append(pool[i])
	return out
