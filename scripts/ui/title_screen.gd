class_name TitleScreen
extends Control

signal hero_selected(hero_id: String)
signal start_requested(hero_id: String)

var selected_hero_id: String = "shiba"
var _hero_buttons: Dictionary = {}
var _detail_label: RichTextLabel = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_select_hero("shiba")

func _build_ui() -> void:
	# Subtle bottom/side backdrop leaving center 3D chibi showcase visible!
	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.84), Color(1.0, 0.84, 0.36, 0.8), 14, 2, 14))
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 40
	top_panel.offset_right = -40
	top_panel.offset_top = 18
	top_panel.offset_bottom = 112
	add_child(top_panel)

	var top_vbox: VBoxContainer = VBoxContainer.new()
	top_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_panel.add_child(top_vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = "PAW & PRISM"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 34)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.44))
	top_vbox.add_child(title_lbl)

	var sub_lbl: Label = Label.new()
	sub_lbl.text = "3D Chibi Critter Survivors  |  Diablo Gear Loot  |  Path of Exile Skill & Passive Gems  |  20-Min 3-Boss Run"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", Color(0.84, 0.92, 1.0))
	top_vbox.add_child(sub_lbl)

	# Bottom Hero Picker & Start Bar
	var bot_panel: PanelContainer = PanelContainer.new()
	bot_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.88), Color(0.45, 0.56, 0.82, 0.85), 14, 2, 14))
	bot_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bot_panel.offset_left = 36
	bot_panel.offset_right = -36
	bot_panel.offset_top = -275
	bot_panel.offset_bottom = -18
	add_child(bot_panel)

	var bot_vbox: VBoxContainer = VBoxContainer.new()
	bot_vbox.add_theme_constant_override("separation", 10)
	bot_panel.add_child(bot_vbox)

	var cards_row: HBoxContainer = HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 12)
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bot_vbox.add_child(cards_row)

	for hdef in HeroDatabase.get_all_heroes():
		var hid: String = String(hdef["id"])
		var btn: Button = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 118)
		btn.text = "%s\n[%s]\nHP: %d  |  Spd: %.1f\nSkill: %s\nPassive: %s" % [
			String(hdef["hero_name"]),
			String(hdef["title"]),
			int(hdef["base_hp"]),
			float(hdef["base_speed"]),
			String(GemDatabase.get_def(String(hdef["starter_active_gem"]))["gem_name"]),
			String(GemDatabase.get_def(String(hdef["starter_passive_gem"]))["gem_name"]),
		]
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(func() -> void: _select_hero(hid))
		cards_row.add_child(btn)
		_hero_buttons[hid] = btn

	var bottom_row: HBoxContainer = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 16)
	bot_vbox.add_child(bottom_row)

	_detail_label = RichTextLabel.new()
	_detail_label.bbcode_enabled = true
	_detail_label.fit_content = true
	_detail_label.scroll_active = false
	_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_label.add_theme_font_size_override("normal_font_size", 14)
	bottom_row.add_child(_detail_label)

	var start_btn: Button = Button.new()
	start_btn.text = "START 20-MIN RUN"
	start_btn.custom_minimum_size = Vector2(260, 56)
	start_btn.add_theme_font_size_override("font_size", 20)
	UiHelper.style_button(start_btn, Color(0.22, 0.56, 0.34), Color(0.55, 0.96, 0.62), 10)
	start_btn.pressed.connect(func() -> void: start_requested.emit(selected_hero_id))
	bottom_row.add_child(start_btn)

func _select_hero(hero_id: String) -> void:
	selected_hero_id = hero_id
	for hid in _hero_buttons.keys():
		var b: Button = _hero_buttons[hid]
		if hid == hero_id:
			UiHelper.style_button(b, Color(0.25, 0.32, 0.52), Color(1.0, 0.85, 0.34), 10)
		else:
			UiHelper.style_button(b, Color(0.14, 0.16, 0.24), Color(0.36, 0.42, 0.56), 10)

	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	var act_name: String = String(GemDatabase.get_def(String(hdef["starter_active_gem"]))["gem_name"])
	var sup_name: String = String(GemDatabase.get_def(String(hdef["starter_support_gem"]))["gem_name"])
	var pas_name: String = String(GemDatabase.get_def(String(hdef["starter_passive_gem"]))["gem_name"])
	_detail_label.text = "[b][color=#ffd966]%s[/color][/b] — %s\n[color=#a8e6cf]Starter Link:[/color] %s + %s  |  [color=#b8d8ff]Passive Gem:[/color] %s\n[color=#cccccc]Controls: WASD/Arrows Move  •  Space Hop-Dash  •  [Tab / I] Gear & PoE Gem Linking  •  Defeat 3 Bosses (06:30, 13:00, 19:30)![/color]" % [
		String(hdef["hero_name"]),
		String(hdef["desc"]),
		act_name,
		sup_name,
		pas_name,
	]
	hero_selected.emit(hero_id)
