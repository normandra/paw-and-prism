class_name ForgeAnimationOverlay
extends Control

var _elapsed: float = 0.0
var _duration: float = 1.65
var _impact_time: float = 0.52
var _impact_fired: bool = false
var _on_complete: Callable = Callable()

var _tpl_holder: Control = null
var _addon_holder: Control = null
var _banner_lbl: Label = null
var _anvil_badge: PanelContainer = null
var _sparks: Array[Dictionary] = []

func _init() -> void:
	name = "ForgeAnimationOverlay"
	process_mode = Control.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func _ready() -> void:
	theme = UiHelper.create_game_theme()

func play_forge(
	upgraded_template: CardInstance,
	consumed_addon: CardInstance,
	bonus_forges: int,
	deck_cd_mult: float,
	relic_cd_mult: float,
	on_complete: Callable
) -> void:
	for c in get_children():
		c.queue_free()
	_sparks.clear()
	_elapsed = 0.0
	_impact_fired = false
	_on_complete = on_complete
	visible = true

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.03, 0.80)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Banner at top
	_banner_lbl = Label.new()
	_banner_lbl.text = "FORGING %s..." % (consumed_addon.get_card_name().to_upper() if consumed_addon != null else "CARD")
	_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_lbl.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_banner_lbl.offset_top = 42
	_banner_lbl.offset_bottom = 86
	_banner_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_banner_lbl, 30, Color(1.0, 0.90, 0.42), 4)
	add_child(_banner_lbl)

	# Template Card Widget (center)
	_tpl_holder = Control.new()
	_tpl_holder.custom_minimum_size = Vector2(276, 330)
	_tpl_holder.pivot_offset = Vector2(138, 165)
	_tpl_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tpl_holder)

	var tpl_card: CardWidget = CardWidget.new()
	tpl_card.custom_minimum_size = Vector2(276, 330)
	tpl_card.setup_card(upgraded_template, {
		"deck_cd_mult": deck_cd_mult,
		"relic_cd_mult": relic_cd_mult,
		"bonus_forges": bonus_forges,
		"selected": true,
	})
	_tpl_holder.add_child(tpl_card)

	# Consumed Add-on Card Widget (starts left, arcs into center & vanishes on impact)
	_addon_holder = Control.new()
	_addon_holder.custom_minimum_size = Vector2(230, 260)
	_addon_holder.pivot_offset = Vector2(115, 130)
	_addon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_addon_holder)

	if consumed_addon != null:
		var addon_card: CardWidget = CardWidget.new()
		addon_card.custom_minimum_size = Vector2(230, 260)
		addon_card.setup_card(consumed_addon, {"compact_mobile": true})
		_addon_holder.add_child(addon_card)

	# Anvil Center Crest
	_anvil_badge = PanelContainer.new()
	_anvil_badge.add_theme_stylebox_override("panel", UiHelper.make_panel_box(Color(0.22, 0.16, 0.10, 0.96), UiHelper.BORDER_GOLD, 28, 3, 10))
	_anvil_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var anvil_ic: TextureRect = TextureRect.new()
	anvil_ic.texture = UiIcons.get_ui_icon("anvil_forge")
	anvil_ic.custom_minimum_size = Vector2(40, 40)
	anvil_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	anvil_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_anvil_badge.add_child(anvil_ic)
	add_child(_anvil_badge)

	var hint: Label = Label.new()
	hint.text = "Tap anywhere to continue"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -54
	hint.offset_bottom = -24
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.84, 0.78, 0.66))
	add_child(hint)

	_update_layout(0.0)

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if _elapsed >= 0.30 and ((event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed)):
		_finish()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _elapsed >= 0.30 and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		_finish()

func _process(delta: float) -> void:
	if not visible:
		return
	_elapsed += minf(delta, 0.05)

	if not _impact_fired and _elapsed >= _impact_time:
		_impact_fired = true
		_spawn_sparks()
		if _banner_lbl != null:
			_banner_lbl.text = "FORGED! Effect Added Permanently"
			_banner_lbl.add_theme_color_override("font_color", Color(0.55, 1.0, 0.68))

	for i in range(_sparks.size() - 1, -1, -1):
		var sp: Dictionary = _sparks[i]
		sp["age"] = float(sp["age"]) + delta
		sp["pos"] = Vector2(sp["pos"]) + Vector2(sp["vel"]) * delta
		sp["vel"] = Vector2(sp["vel"]) * (1.0 - minf(0.8, delta * 2.8)) + Vector2(0.0, 120.0 * delta)
		if float(sp["age"]) >= float(sp["life"]):
			_sparks.remove_at(i)

	_update_layout(_elapsed)
	queue_redraw()

	if _elapsed >= _duration:
		_finish()

func _update_layout(t_sec: float) -> void:
	var vp: Vector2 = size if size.x > 10.0 else Vector2(1280.0, 720.0)
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 18.0)

	if _tpl_holder != null:
		var base_pos: Vector2 = center - Vector2(138.0, 165.0)
		var scl: float = 1.0
		if t_sec < _impact_time:
			var p: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			base_pos.x += lerpf(90.0, 0.0, p)
			scl = 0.94 + p * 0.04
		else:
			var post: float = clampf((t_sec - _impact_time) / 0.35, 0.0, 1.0)
			scl = 1.0 + sin(post * PI) * 0.16
		_tpl_holder.position = base_pos
		_tpl_holder.scale = Vector2(scl, scl)

	if _addon_holder != null:
		if t_sec < _impact_time:
			var p2: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			var ease_in: float = p2 * p2
			var start_p: Vector2 = center + Vector2(-minf(340.0, vp.x * 0.28) - 115.0, -130.0)
			var end_p: Vector2 = center - Vector2(115.0, 130.0)
			var arc_y: float = -sin(p2 * PI) * 65.0
			_addon_holder.position = start_p.lerp(end_p, ease_in) + Vector2(0.0, arc_y)
			var s_a: float = lerpf(1.0, 0.35, ease_in)
			_addon_holder.scale = Vector2(s_a, s_a)
			_addon_holder.rotation = lerpf(-0.12, 0.18, ease_in)
			_addon_holder.modulate.a = 1.0 - maxf(0.0, (p2 - 0.75) * 3.5)
		else:
			_addon_holder.visible = false

	if _anvil_badge != null:
		var a_pos: Vector2 = center - Vector2(30.0, 30.0)
		_anvil_badge.position = a_pos
		if t_sec < _impact_time:
			var p3: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			var s_anv: float = 0.85 + p3 * 0.40
			_anvil_badge.scale = Vector2(s_anv, s_anv)
			_anvil_badge.modulate.a = 0.92
		else:
			var fade_p: float = clampf((t_sec - _impact_time) / 0.30, 0.0, 1.0)
			_anvil_badge.scale = Vector2(1.4 - fade_p * 0.4, 1.4 - fade_p * 0.4)
			_anvil_badge.modulate.a = 1.0 - fade_p
			if fade_p >= 1.0:
				_anvil_badge.visible = false

func _spawn_sparks() -> void:
	var vp: Vector2 = size if size.x > 10.0 else Vector2(1280.0, 720.0)
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 18.0)
	var cols: Array[Color] = [
		Color(1.0, 0.92, 0.42),
		Color(1.0, 0.68, 0.24),
		Color(0.62, 0.94, 1.0),
		Color(1.0, 1.0, 1.0),
	]
	for i in range(36):
		var ang: float = (float(i) / 36.0) * TAU + randf_range(-0.12, 0.12)
		var spd: float = randf_range(160.0, 440.0)
		_sparks.append({
			"pos": center,
			"vel": Vector2(cos(ang), sin(ang)) * spd,
			"age": 0.0,
			"life": randf_range(0.45, 0.90),
			"size": randf_range(3.5, 8.5),
			"col": cols[i % cols.size()],
		})

func _draw() -> void:
	if not visible:
		return
	var vp: Vector2 = size if size.x > 10.0 else Vector2(1280.0, 720.0)
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 18.0)

	# Shockwave rings after impact
	if _impact_fired:
		var post: float = _elapsed - _impact_time
		for ring_i in range(2):
			var rp: float = clampf((post - float(ring_i) * 0.08) / 0.55, 0.0, 1.0)
			if rp > 0.0 and rp < 1.0:
				var rad: float = lerpf(24.0, 260.0 + float(ring_i) * 60.0, rp)
				var alpha: float = (1.0 - rp) * 0.85
				var col: Color = Color(1.0, 0.88, 0.36, alpha) if ring_i == 0 else Color(0.55, 0.92, 1.0, alpha)
				draw_arc(center, rad, 0.0, TAU, 48, col, 4.5 * (1.0 - rp * 0.5))

		# Radial Starburst flash right on impact
		if post < 0.25:
			var fa: float = (1.0 - post / 0.25) * 0.55
			draw_circle(center, lerpf(160.0, 45.0, post / 0.25), Color(1.0, 0.94, 0.65, fa))

	# Flying forge sparks
	for sp in _sparks:
		var t: float = clampf(float(sp["age"]) / float(sp["life"]), 0.0, 1.0)
		var col: Color = sp["col"]
		col.a = 1.0 - t
		var p: Vector2 = sp["pos"]
		var r: float = float(sp["size"]) * (1.0 - t * 0.45)
		draw_circle(p, r, col)

func _finish() -> void:
	visible = false
	for c in get_children():
		c.queue_free()
	_sparks.clear()
	var cb: Callable = _on_complete
	_on_complete = Callable()
	if cb.is_valid():
		cb.call()
