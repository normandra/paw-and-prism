class_name EndScreen
extends Control

signal play_again_requested()
signal title_menu_requested()
signal resume_requested()

var _title_lbl: Label = null
var _summary_rtl: RichTextLabel = null
var _resume_btn: Button = null
var _is_pause_mode: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()

func _build_ui() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.04, 0.08, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 400)
	panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.96), Color(1.0, 0.84, 0.34, 0.9), 14, 3, 20))
	center.add_child(panel)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)

	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 30)
	v.add_child(_title_lbl)

	_summary_rtl = RichTextLabel.new()
	_summary_rtl.bbcode_enabled = true
	_summary_rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_summary_rtl.add_theme_font_size_override("normal_font_size", 15)
	v.add_child(_summary_rtl)

	var btns: HBoxContainer = HBoxContainer.new()
	btns.add_theme_constant_override("separation", 12)
	v.add_child(btns)

	_resume_btn = Button.new()
	_resume_btn.text = "Resume Run [Esc]"
	_resume_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resume_btn.custom_minimum_size = Vector2(0, 46)
	UiHelper.style_button(_resume_btn, Color(0.22, 0.48, 0.30), Color(0.55, 0.95, 0.62), 8)
	_resume_btn.pressed.connect(func() -> void:
		visible = false
		resume_requested.emit()
	)
	btns.add_child(_resume_btn)

	var again_btn: Button = Button.new()
	again_btn.text = "Play Again"
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	again_btn.custom_minimum_size = Vector2(0, 46)
	UiHelper.style_button(again_btn, Color(0.24, 0.32, 0.50), Color(0.55, 0.85, 1.0), 8)
	again_btn.pressed.connect(func() -> void:
		visible = false
		play_again_requested.emit()
	)
	btns.add_child(again_btn)

	var menu_btn: Button = Button.new()
	menu_btn.text = "Title Menu"
	menu_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_btn.custom_minimum_size = Vector2(0, 46)
	UiHelper.style_button(menu_btn, Color(0.26, 0.20, 0.24), Color(0.88, 0.60, 0.65), 8)
	menu_btn.pressed.connect(func() -> void:
		visible = false
		title_menu_requested.emit()
	)
	btns.add_child(menu_btn)

func show_pause(stats: HeroStats, wave_dir: WaveDirector) -> void:
	_is_pause_mode = true
	_resume_btn.visible = true
	_title_lbl.text = "PAUSED"
	_title_lbl.add_theme_color_override("font_color", Color(0.68, 0.90, 1.0))
	_fill_summary(stats, wave_dir, "Take a breather! Tip: Press [Tab] or [I] anytime to equip looted Diablo gear and link PoE Skill & Passive Gems.")
	visible = true

func show_end(victory: bool, stats: HeroStats, wave_dir: WaveDirector) -> void:
	_is_pause_mode = false
	_resume_btn.visible = false
	if victory:
		_title_lbl.text = "VICTORY! MEADOW SAVED!"
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.32))
		_fill_summary(stats, wave_dir, "You defeated King Bramblehorn and conquered all 3 Bosses of the 20-minute gauntlet!")
	else:
		_title_lbl.text = "DEFEATED..."
		_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.42, 0.44))
		_fill_summary(stats, wave_dir, "Your little hero fought bravely against the endless critter horde!")
	visible = true

func _fill_summary(stats: HeroStats, wave_dir: WaveDirector, intro: String) -> void:
	var mins: int = int(wave_dir.elapsed_time) / 60
	var secs: int = int(wave_dir.elapsed_time) % 60
	var hdef: Dictionary = HeroDatabase.get_hero(stats.hero_id)

	var txt: String = "%s\n\n" % intro
	txt += "[b]Hero:[/b] %s (Level %d)\n" % [String(hdef["hero_name"]), stats.hero_level]
	txt += "[b]Time Survived:[/b] %02d:%02d / 20:00\n" % [mins, secs]
	txt += "[b]Bosses Defeated:[/b] %d / 3\n" % wave_dir.bosses_defeated_count
	txt += "[b]Critters Defeated:[/b] %d\n\n" % wave_dir.kills_count

	txt += "[b][color=#ffd966]Final Linked Active Skills:[/color][/b]\n"
	for cfg in stats.active_skill_configs:
		var sups: Array = cfg["linked_support_names"]
		var sup_txt: String = " <- [" + ", ".join(sups) + "]" if not sups.is_empty() else ""
		txt += "• %s Lv.%d%s\n" % [String(cfg["gem_name"]), int(cfg["effective_level"]), sup_txt]

	txt += "\n[b][color=#a8f0b0]Socketed Passive Gems:[/color][/b]\n"
	for p_info in stats.active_passives:
		var pg: GemInstance = p_info["gem"]
		txt += "• %s Lv.%d\n" % [pg.get_gem_name(), int(p_info["effective_level"])]

	_summary_rtl.text = txt
