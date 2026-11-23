class_name LevelUpModal
extends Control

signal option_chosen(payload: Dictionary)

var _cards_hbox: HBoxContainer = null
var _title_lbl: Label = null
var _current_options: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.04, 0.08, 0.70)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 340)
	panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.10, 0.11, 0.18, 0.96), Color(1.0, 0.85, 0.32, 0.95), 14, 3, 18))
	center.add_child(panel)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)

	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 26)
	_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.42))
	v.add_child(_title_lbl)

	var sub: Label = Label.new()
	sub.text = "Pick an upgrade (Click or press [1] / [2] / [3])"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.78, 0.84, 0.94))
	v.add_child(sub)

	_cards_hbox = HBoxContainer.new()
	_cards_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cards_hbox.add_theme_constant_override("separation", 12)
	v.add_child(_cards_hbox)

func open_for_level(new_level: int, stats: HeroStats) -> void:
	_title_lbl.text = "LEVEL %d REACHED!" % new_level
	for ch in _cards_hbox.get_children():
		ch.queue_free()
	_current_options = _roll_options(stats)

	for i in range(_current_options.size()):
		var opt: Dictionary = _current_options[i]
		var btn: Button = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.text = "[%d] %s\n\n%s" % [i + 1, String(opt["title"]), String(opt["desc"])]
		btn.add_theme_font_size_override("font_size", 15)
		UiHelper.style_button(btn, Color(0.16, 0.19, 0.28), opt["color"], 10)
		var captured: Dictionary = opt
		btn.pressed.connect(func() -> void: _pick(captured))
		_cards_hbox.add_child(btn)

	visible = true

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
		{"kind": "stat", "stat": GameEnums.StatType.DAMAGE_PCT, "val": 14.0, "title": "Ferocious Paws", "desc": "+14% All Damage", "color": Color(1.0, 0.55, 0.35)},
		{"kind": "stat", "stat": GameEnums.StatType.CAST_SPEED_PCT, "val": 12.0, "title": "Swift Whiskers", "desc": "+12% Attack & Cast Speed", "color": Color(0.45, 0.90, 0.65)},
		{"kind": "stat", "stat": GameEnums.StatType.MAX_HP, "val": 32.0, "title": "Fluffy Heartiness", "desc": "+32 Max HP (and heals 32 HP)", "color": Color(0.95, 0.42, 0.52)},
		{"kind": "stat", "stat": GameEnums.StatType.AREA_PCT, "val": 16.0, "title": "Blooming Aura", "desc": "+16% Area Size", "color": Color(0.48, 0.76, 1.0)},
		{"kind": "stat", "stat": GameEnums.StatType.CRIT_CHANCE, "val": 7.0, "title": "Sharp Claws", "desc": "+7% Critical Strike Chance", "color": Color(1.0, 0.85, 0.32)},
		{"kind": "stat", "stat": GameEnums.StatType.MOVE_SPEED_PCT, "val": 10.0, "title": "Zoomies Boost", "desc": "+10% Move Speed", "color": Color(0.55, 0.96, 0.60)},
		{"kind": "stat", "stat": GameEnums.StatType.ARMOR, "val": 12.0, "title": "Acorn Plating", "desc": "+12 Armor", "color": Color(0.84, 0.72, 0.48)},
		{"kind": "stat", "stat": GameEnums.StatType.MAGIC_FIND_PCT, "val": 20.0, "title": "Lucky Tail", "desc": "+20% Magic Find (Better Gear!)", "color": Color(1.0, 0.72, 0.28)},
		{"kind": "gem_xp", "val": 140.0, "title": "Prismatic Surge", "desc": "Grant +140 XP to all socketed Active, Support & Passive Gems!", "color": Color(0.65, 0.55, 1.0)},
		{"kind": "dust_pack", "val": 25.0, "title": "Prism Dust Pouch", "desc": "+25 Prism Dust for Recoloring & Linking Sockets!", "color": Color(0.45, 0.94, 1.0)},
	]
	if stats.can_add_gem_to_pouch():
		pool.append({"kind": "free_gem", "val": 1.0, "title": "Mystery Skill Gem", "desc": "Gain a random Active, Support, or Passive Skill Gem!", "color": Color(0.96, 0.68, 1.0)})

	pool.shuffle()
	var out: Array[Dictionary] = []
	for i in range(mini(3, pool.size())):
		out.append(pool[i])
	return out
