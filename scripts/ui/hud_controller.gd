class_name HudController
extends Control

signal open_inventory_requested()
signal toggle_pause_requested()
signal toggle_mute_requested()

var _timer_lbl: Label = null
var _phase_lbl: Label = null
var _next_boss_lbl: Label = null
var _kills_lbl: Label = null
var _level_lbl: Label = null
var _xp_bar: ProgressBar = null

var _boss_panel: PanelContainer = null
var _boss_name_lbl: Label = null
var _boss_hp_bar: ProgressBar = null

var _hp_bar: ProgressBar = null
var _hp_lbl: Label = null
var _dash_bar: ProgressBar = null
var _dust_lbl: Label = null
var _inv_btn: Button = null
var _mute_btn: Button = null

var _skills_hbox: HBoxContainer = null
var _passives_hbox: HBoxContainer = null
var _skill_cards: Dictionary = {}

var _banner_lbl: Label = null
var _banner_timer: float = 0.0

var _toast_vbox: VBoxContainer = null
var _toasts: Array[Dictionary] = []

var _popup_pool: Array[Dictionary] = []
var _world_labels: Array[Label] = []
var _compass_arrows: Array[Label] = []
var _unread_loot: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_hud()

func _build_hud() -> void:
	# === Top XP Bar ===
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_xp_bar.offset_bottom = 12
	UiHelper.style_progress_bar(_xp_bar, Color(0.32, 0.88, 1.0), Color(0.06, 0.08, 0.14, 0.9), 2)
	add_child(_xp_bar)

	# === Top Status Strip ===
	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_top = 18
	top_bar.offset_left = 18
	top_bar.offset_right = -18
	top_bar.offset_bottom = 66
	top_bar.add_theme_constant_override("separation", 12)
	top_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(top_bar)

	# Left Info Pill
	var left_pill: PanelContainer = PanelContainer.new()
	left_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.84), Color(0.42, 0.52, 0.72, 0.75), 10, 2, 8))
	top_bar.add_child(left_pill)
	var lp_h: HBoxContainer = HBoxContainer.new()
	lp_h.add_theme_constant_override("separation", 14)
	left_pill.add_child(lp_h)

	_level_lbl = Label.new()
	_level_lbl.text = "Lv. 1"
	_level_lbl.add_theme_font_size_override("font_size", 16)
	_level_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.36))
	lp_h.add_child(_level_lbl)

	_kills_lbl = Label.new()
	_kills_lbl.text = "Kills: 0"
	_kills_lbl.add_theme_font_size_override("font_size", 15)
	lp_h.add_child(_kills_lbl)

	# Center Clock Pill
	var spacer1: Control = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer1)

	var clock_pill: PanelContainer = PanelContainer.new()
	clock_pill.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.88), Color(1.0, 0.84, 0.36, 0.85), 10, 2, 8))
	top_bar.add_child(clock_pill)
	var cp_h: HBoxContainer = HBoxContainer.new()
	cp_h.add_theme_constant_override("separation", 14)
	clock_pill.add_child(cp_h)

	_phase_lbl = Label.new()
	_phase_lbl.text = "Sunny Meadow"
	_phase_lbl.add_theme_font_size_override("font_size", 13)
	_phase_lbl.add_theme_color_override("font_color", Color(0.64, 0.94, 0.68))
	cp_h.add_child(_phase_lbl)

	_timer_lbl = Label.new()
	_timer_lbl.text = "00:00 / 20:00"
	_timer_lbl.add_theme_font_size_override("font_size", 20)
	_timer_lbl.add_theme_color_override("font_color", Color(1.0, 0.98, 0.92))
	cp_h.add_child(_timer_lbl)

	_next_boss_lbl = Label.new()
	_next_boss_lbl.text = "Boss 1 in 06:30"
	_next_boss_lbl.add_theme_font_size_override("font_size", 13)
	_next_boss_lbl.add_theme_color_override("font_color", Color(1.0, 0.62, 0.44))
	cp_h.add_child(_next_boss_lbl)

	var spacer2: Control = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer2)

	# Top-Right Controls
	_mute_btn = Button.new()
	_mute_btn.text = "Audio: ON [M]"
	_mute_btn.custom_minimum_size = Vector2(115, 38)
	UiHelper.style_button(_mute_btn)
	_mute_btn.pressed.connect(func() -> void: toggle_mute_requested.emit())
	top_bar.add_child(_mute_btn)

	var pause_btn: Button = Button.new()
	pause_btn.text = "Pause [Esc]"
	pause_btn.custom_minimum_size = Vector2(105, 38)
	UiHelper.style_button(pause_btn)
	pause_btn.pressed.connect(func() -> void: toggle_pause_requested.emit())
	top_bar.add_child(pause_btn)

	# === Boss Health Bar ===
	_boss_panel = PanelContainer.new()
	_boss_panel.visible = false
	_boss_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.16, 0.08, 0.10, 0.92), Color(1.0, 0.35, 0.32, 0.95), 10, 2, 8))
	_boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_boss_panel.offset_left = 260
	_boss_panel.offset_right = -260
	_boss_panel.offset_top = 74
	_boss_panel.offset_bottom = 128
	add_child(_boss_panel)

	var bp_v: VBoxContainer = VBoxContainer.new()
	bp_v.add_theme_constant_override("separation", 4)
	_boss_panel.add_child(bp_v)

	_boss_name_lbl = Label.new()
	_boss_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_lbl.add_theme_font_size_override("font_size", 15)
	_boss_name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	bp_v.add_child(_boss_name_lbl)

	_boss_hp_bar = ProgressBar.new()
	_boss_hp_bar.show_percentage = false
	_boss_hp_bar.custom_minimum_size = Vector2(0, 16)
	UiHelper.style_progress_bar(_boss_hp_bar, Color(0.95, 0.24, 0.26), Color(0.12, 0.05, 0.06), 6)
	bp_v.add_child(_boss_hp_bar)

	# === Wave / Boss Event Banner ===
	_banner_lbl = Label.new()
	_banner_lbl.visible = false
	_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_banner_lbl.offset_top = 136
	_banner_lbl.offset_bottom = 176
	_banner_lbl.add_theme_font_size_override("font_size", 24)
	_banner_lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
	_banner_lbl.add_theme_constant_override("outline_size", 5)
	add_child(_banner_lbl)

	# === Right Loot Toast Feed ===
	_toast_vbox = VBoxContainer.new()
	_toast_vbox.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_vbox.offset_left = -360
	_toast_vbox.offset_right = -18
	_toast_vbox.offset_top = 82
	_toast_vbox.offset_bottom = 340
	_toast_vbox.add_theme_constant_override("separation", 6)
	_toast_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_vbox)

	# === Bottom-Left Hero Vitals & Gear Button ===
	var bl_panel: PanelContainer = PanelContainer.new()
	bl_panel.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.09, 0.10, 0.16, 0.88), Color(0.45, 0.56, 0.78, 0.8), 12, 2, 10))
	bl_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bl_panel.offset_left = 18
	bl_panel.offset_top = -152
	bl_panel.offset_right = 296
	bl_panel.offset_bottom = -16
	add_child(bl_panel)

	var bl_v: VBoxContainer = VBoxContainer.new()
	bl_v.add_theme_constant_override("separation", 6)
	bl_panel.add_child(bl_v)

	_hp_bar = ProgressBar.new()
	_hp_bar.show_percentage = false
	_hp_bar.custom_minimum_size = Vector2(0, 22)
	UiHelper.style_progress_bar(_hp_bar, Color(0.92, 0.28, 0.34), Color(0.16, 0.08, 0.10), 6)
	bl_v.add_child(_hp_bar)

	_hp_lbl = Label.new()
	_hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_lbl.add_theme_font_size_override("font_size", 13)
	_hp_bar.add_child(_hp_lbl)
	_hp_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dash_row: HBoxContainer = HBoxContainer.new()
	dash_row.add_theme_constant_override("separation", 8)
	bl_v.add_child(dash_row)

	var dash_lbl: Label = Label.new()
	dash_lbl.text = "Dash [Space]"
	dash_lbl.add_theme_font_size_override("font_size", 12)
	dash_row.add_child(dash_lbl)

	_dash_bar = ProgressBar.new()
	_dash_bar.show_percentage = false
	_dash_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dash_bar.custom_minimum_size = Vector2(0, 14)
	UiHelper.style_progress_bar(_dash_bar, Color(0.98, 0.82, 0.28), Color(0.12, 0.12, 0.16), 5)
	dash_row.add_child(_dash_bar)

	var bot_bl_row: HBoxContainer = HBoxContainer.new()
	bot_bl_row.add_theme_constant_override("separation", 8)
	bl_v.add_child(bot_bl_row)

	_dust_lbl = Label.new()
	_dust_lbl.text = "Dust: 25"
	_dust_lbl.add_theme_font_size_override("font_size", 13)
	_dust_lbl.add_theme_color_override("font_color", Color(0.55, 0.92, 1.0))
	bot_bl_row.add_child(_dust_lbl)

	_inv_btn = Button.new()
	_inv_btn.text = "Gear & Gems [Tab]"
	_inv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHelper.style_button(_inv_btn, Color(0.24, 0.30, 0.48), Color(1.0, 0.82, 0.32), 8)
	_inv_btn.pressed.connect(func() -> void: open_inventory_requested.emit())
	bot_bl_row.add_child(_inv_btn)

	# === Bottom-Center PoE Active Skills & Passive Gems Bar ===
	var bc_vbox: VBoxContainer = VBoxContainer.new()
	bc_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bc_vbox.offset_left = 315
	bc_vbox.offset_right = -240
	bc_vbox.offset_top = -126
	bc_vbox.offset_bottom = -16
	bc_vbox.alignment = BoxContainer.ALIGNMENT_END
	bc_vbox.add_theme_constant_override("separation", 6)
	bc_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bc_vbox)

	_passives_hbox = HBoxContainer.new()
	_passives_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_passives_hbox.add_theme_constant_override("separation", 6)
	bc_vbox.add_child(_passives_hbox)

	_skills_hbox = HBoxContainer.new()
	_skills_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_skills_hbox.add_theme_constant_override("separation", 8)
	bc_vbox.add_child(_skills_hbox)

	# === Pooled Floating Damage Popups ===
	for _i in range(42):
		var lbl: Label = Label.new()
		lbl.visible = false
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
		lbl.add_theme_constant_override("outline_size", 4)
		add_child(lbl)
		_popup_pool.append({"label": lbl, "timer": 0.0, "world_pos": Vector3.ZERO})

	# === Ground Loot Labels Pool ===
	for _j in range(18):
		var gl: Label = Label.new()
		gl.visible = false
		gl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gl.add_theme_font_size_override("font_size", 12)
		gl.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.08))
		gl.add_theme_constant_override("outline_size", 4)
		add_child(gl)
		_world_labels.append(gl)

	# === Compass Arrows Pool (Boss / Chests) ===
	for _k in range(6):
		var cl: Label = Label.new()
		cl.visible = false
		cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cl.add_theme_font_size_override("font_size", 14)
		cl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
		cl.add_theme_constant_override("outline_size", 4)
		add_child(cl)
		_compass_arrows.append(cl)

func reset_hud() -> void:
	_unread_loot = 0
	_banner_timer = 0.0
	_banner_lbl.visible = false
	for t in _toasts:
		if is_instance_valid(t["node"]):
			t["node"].queue_free()
	_toasts.clear()
	for p in _popup_pool:
		p["timer"] = 0.0
		p["label"].visible = false

func mark_loot_read() -> void:
	_unread_loot = 0

func add_unread_loot() -> void:
	_unread_loot += 1

func set_muted_state(is_muted: bool) -> void:
	if _mute_btn != null:
		_mute_btn.text = "Audio: OFF [M]" if is_muted else "Audio: ON [M]"

func show_banner(text: String, col: Color) -> void:
	_banner_lbl.text = text
	_banner_lbl.add_theme_color_override("font_color", col)
	_banner_lbl.visible = true
	_banner_timer = 3.6

func push_toast(text: String, col: Color) -> void:
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.08, 0.09, 0.14, 0.88), col, 8, 2, 6))
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", col)
	p.add_child(lbl)
	_toast_vbox.add_child(p)
	_toasts.append({"node": p, "timer": 4.2})
	while _toasts.size() > 5:
		var old: Dictionary = _toasts.pop_front()
		if is_instance_valid(old["node"]):
			old["node"].queue_free()

func spawn_damage_popup(world_pos: Vector3, amount: float, is_crit: bool, is_fire: bool, is_cold: bool, is_heal: bool = false) -> void:
	for p in _popup_pool:
		if float(p["timer"]) <= 0.0:
			var lbl: Label = p["label"]
			lbl.text = ("+%d" % int(round(amount))) if is_heal else ("%d!" % int(round(amount)) if is_crit else "%d" % int(round(amount)))
			var col: Color = Color(0.45, 1.0, 0.56) if is_heal else (Color(1.0, 0.88, 0.25) if is_crit else (Color(1.0, 0.52, 0.24) if is_fire else (Color(0.45, 0.90, 1.0) if is_cold else Color(0.96, 0.96, 0.98))))
			lbl.add_theme_color_override("font_color", col)
			lbl.add_theme_font_size_override("font_size", 20 if is_crit else 15)
			p["world_pos"] = world_pos + Vector3(randf_range(-0.4, 0.4), 1.35, randf_range(-0.3, 0.3))
			p["timer"] = 0.72
			lbl.visible = true
			return

func rebuild_skill_bar(stats: HeroStats) -> void:
	for ch in _skills_hbox.get_children():
		ch.queue_free()
	for ch in _passives_hbox.get_children():
		ch.queue_free()
	_skill_cards.clear()

	for p_info in stats.active_passives:
		var gem: GemInstance = p_info["gem"]
		var badge: PanelContainer = PanelContainer.new()
		var gcol: Color = GameEnums.gem_color_value(gem.get_gem_color())
		badge.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.10, 0.12, 0.18, 0.85), gcol, 6, 1, 4))
		var pl: Label = Label.new()
		pl.text = "%s Lv.%d" % [gem.get_short_label(), int(p_info["effective_level"])]
		pl.add_theme_font_size_override("font_size", 11)
		pl.add_theme_color_override("font_color", gcol.lightened(0.25))
		badge.add_child(pl)
		_passives_hbox.add_child(badge)

	for cfg in stats.active_skill_configs:
		var uid: int = int(cfg["uid"])
		var gcol: Color = GameEnums.gem_color_value(int(cfg["color"]))
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(98, 62)
		card.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.10, 0.11, 0.17, 0.92), gcol, 8, 2, 5))

		var v: VBoxContainer = VBoxContainer.new()
		v.add_theme_constant_override("separation", 2)
		card.add_child(v)

		var title: Label = Label.new()
		title.text = "%s Lv.%d" % [String(cfg["short"]), int(cfg["effective_level"])]
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 13)
		title.add_theme_color_override("font_color", gcol.lightened(0.2))
		v.add_child(title)

		var sup_names: Array = cfg["linked_support_names"]
		var sup_lbl: Label = Label.new()
		sup_lbl.text = "%d Linked" % sup_names.size() if not sup_names.is_empty() else "Unlinked"
		sup_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sup_lbl.add_theme_font_size_override("font_size", 10)
		sup_lbl.add_theme_color_override("font_color", Color(0.95, 0.84, 0.40) if not sup_names.is_empty() else Color(0.65, 0.68, 0.74))
		v.add_child(sup_lbl)

		var cd_bar: ProgressBar = ProgressBar.new()
		cd_bar.show_percentage = false
		cd_bar.custom_minimum_size = Vector2(0, 7)
		cd_bar.max_value = 1.0
		UiHelper.style_progress_bar(cd_bar, gcol, Color(0.06, 0.06, 0.09), 3)
		v.add_child(cd_bar)

		_skills_hbox.add_child(card)
		_skill_cards[uid] = cd_bar

func update_hud(delta: float, stats: HeroStats, player: PlayerController, wave_dir: WaveDirector, skill_exec: SkillExecutor, loot_mgr: LootManager, cam: Camera3D) -> void:
	# Timer & Phase
	var t: float = wave_dir.elapsed_time
	var mins: int = int(t) / 60
	var secs: int = int(t) % 60
	_timer_lbl.text = "%02d:%02d / 20:00" % [mins, secs]
	var prof: Dictionary = EnemyDatabase.get_wave_profile(t)
	_phase_lbl.text = String(prof["phase_name"])
	_next_boss_lbl.text = wave_dir.get_next_boss_countdown()
	_kills_lbl.text = "Kills: %d  |  Bosses: %d/3" % [wave_dir.kills_count, wave_dir.bosses_defeated_count]
	_level_lbl.text = "Lv. %d" % stats.hero_level
	_xp_bar.max_value = stats.hero_xp_to_next
	_xp_bar.value = stats.hero_xp

	# Player Vitals
	_hp_bar.max_value = stats.max_hp
	_hp_bar.value = player.current_hp
	_hp_lbl.text = "HP %d / %d  (+%.1f/s)" % [int(ceil(player.current_hp)), int(round(stats.max_hp)), stats.hp_regen]
	_dash_bar.max_value = 1.0
	_dash_bar.value = player.get_dash_ready_fraction()
	_dust_lbl.text = "Dust: %d" % stats.prism_dust
	_inv_btn.text = "Gear & Gems (%d NEW!) [Tab]" % _unread_loot if _unread_loot > 0 else "Gear & Gems [Tab]"

	# Boss Bar
	if is_instance_valid(wave_dir.active_boss) and not wave_dir.active_boss.is_dead:
		_boss_panel.visible = true
		_boss_name_lbl.text = "%s (%d / %d)" % [wave_dir.active_boss.enemy_name, int(ceil(wave_dir.active_boss.current_hp)), int(round(wave_dir.active_boss.max_hp))]
		_boss_hp_bar.max_value = wave_dir.active_boss.max_hp
		_boss_hp_bar.value = wave_dir.active_boss.current_hp
	else:
		_boss_panel.visible = false

	# Skill Cooldown Bars
	for uid in _skill_cards.keys():
		var bar: ProgressBar = _skill_cards[uid]
		if is_instance_valid(bar):
			bar.value = skill_exec.get_cooldown_fraction(int(uid))

	# Banner timer
	if _banner_timer > 0.0:
		_banner_timer -= delta
		if _banner_timer <= 0.0:
			_banner_lbl.visible = false

	# Toasts timer
	for i in range(_toasts.size() - 1, -1, -1):
		_toasts[i]["timer"] = float(_toasts[i]["timer"]) - delta
		if float(_toasts[i]["timer"]) <= 0.0:
			if is_instance_valid(_toasts[i]["node"]):
				_toasts[i]["node"].queue_free()
			_toasts.remove_at(i)

	# Screen-space Floating Damage Popups
	for p in _popup_pool:
		var pt: float = float(p["timer"])
		if pt > 0.0:
			pt -= delta
			p["timer"] = pt
			var lbl: Label = p["label"]
			if pt <= 0.0 or cam == null:
				lbl.visible = false
			else:
				var wpos: Vector3 = p["world_pos"] + Vector3(0.0, (0.72 - pt) * 1.8, 0.0)
				if not cam.is_position_behind(wpos):
					var spos: Vector2 = cam.unproject_position(wpos)
					lbl.position = spos - Vector2(18.0, 12.0)
					lbl.modulate.a = clampf(pt / 0.35, 0.0, 1.0)
					lbl.visible = true
				else:
					lbl.visible = false

	# Ground Loot Labels & Offscreen Compass Arrows
	_update_world_labels_and_arrows(cam, loot_mgr, wave_dir)

func _update_world_labels_and_arrows(cam: Camera3D, loot_mgr: LootManager, wave_dir: WaveDirector) -> void:
	if cam == null:
		return
	var vsize: Vector2 = get_viewport_rect().size
	var glabels: Array[Dictionary] = loot_mgr.get_ground_labels()
	var arrow_targets: Array[Dictionary] = []

	for i in range(_world_labels.size()):
		var lbl: Label = _world_labels[i]
		if i < glabels.size():
			var info: Dictionary = glabels[i]
			var wpos: Vector3 = info["pos"]
			var spos: Vector2 = cam.unproject_position(wpos)
			var on_screen: bool = not cam.is_position_behind(wpos) and spos.x > 20.0 and spos.x < vsize.x - 20.0 and spos.y > 20.0 and spos.y < vsize.y - 20.0
			if on_screen:
				lbl.text = String(info["text"])
				lbl.add_theme_color_override("font_color", info["color"])
				lbl.position = spos - Vector2(60.0, 14.0)
				lbl.visible = true
			else:
				lbl.visible = false
				if bool(info["is_chest"]):
					arrow_targets.append({"pos": wpos, "text": "CHEST", "color": Color(1.0, 0.88, 0.25)})
		else:
			lbl.visible = false

	if is_instance_valid(wave_dir.active_boss) and not wave_dir.active_boss.is_dead:
		var bpos: Vector3 = wave_dir.active_boss.global_position
		var bspos: Vector2 = cam.unproject_position(bpos)
		if cam.is_position_behind(bpos) or bspos.x < 10.0 or bspos.x > vsize.x - 10.0 or bspos.y < 10.0 or bspos.y > vsize.y - 10.0:
			arrow_targets.append({"pos": bpos, "text": "BOSS!", "color": Color(1.0, 0.32, 0.30)})

	var center: Vector2 = vsize * 0.5
	for i in range(_compass_arrows.size()):
		var cl: Label = _compass_arrows[i]
		if i < arrow_targets.size():
			var tinfo: Dictionary = arrow_targets[i]
			var raw: Vector2 = cam.unproject_position(tinfo["pos"])
			if cam.is_position_behind(tinfo["pos"]):
				raw = vsize - raw
			var dir: Vector2 = (raw - center).normalized()
			var edge_pos: Vector2 = center + dir * minf(center.x - 65.0, center.y - 80.0)
			cl.text = ">> %s" % String(tinfo["text"])
			cl.add_theme_color_override("font_color", tinfo["color"])
			cl.position = edge_pos - Vector2(30.0, 10.0)
			cl.visible = true
		else:
			cl.visible = false
