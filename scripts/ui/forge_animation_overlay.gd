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
	clip_contents = true
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
	var vp0: Vector2 = _safe_vp()
	_banner_lbl = Label.new()
	_banner_lbl.text = "FORGING %s..." % (consumed_addon.get_card_name().to_upper() if consumed_addon != null else "CARD")
	_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_banner_lbl.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_banner_lbl.offset_left = 12
	_banner_lbl.offset_right = -12
	_banner_lbl.offset_top = 14 if vp0.y < 540.0 else 32
	_banner_lbl.offset_bottom = 66 if vp0.y < 540.0 else 86
	_banner_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiHelper.apply_display_font(_banner_lbl, 18 if vp0.x < 520.0 else 28, Color(1.0, 0.90, 0.42), 4)
	add_child(_banner_lbl)

	# Template Card Widget (center)
	_tpl_holder = Control.new()
	_tpl_holder.size = Vector2(276, 330)
	_tpl_holder.pivot_offset = Vector2.ZERO
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
	_addon_holder.size = Vector2(230, 260)
	_addon_holder.pivot_offset = Vector2.ZERO
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

func _safe_vp() -> Vector2:
	if size.x > 10.0 and size.y > 10.0:
		return size
	var r: Vector2 = get_viewport_rect().size
	if r.x > 10.0 and r.y > 10.0:
		return r
	return Vector2(1280.0, 720.0)

func _update_layout(t_sec: float) -> void:
	var vp: Vector2 = _safe_vp()
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 12.0)
	var base_scale: float = clampf(minf((vp.x - 36.0) / 304.0, (vp.y - 140.0) / 360.0), 0.42, 1.0)

	if _banner_lbl != null:
		_banner_lbl.add_theme_font_size_override("font_size", 18 if vp.x < 520.0 else 28)

	if _tpl_holder != null:
		var punch: float = 1.0
		var dx: float = 0.0
		if t_sec < _impact_time:
			var p: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			dx = lerpf(minf(80.0, vp.x * 0.12), 0.0, p)
			punch = 0.94 + p * 0.04
		else:
			var post: float = clampf((t_sec - _impact_time) / 0.35, 0.0, 1.0)
			punch = 1.0 + sin(post * PI) * 0.12
		var scl: float = base_scale * punch
		var tw: float = 276.0 * scl
		var th: float = 330.0 * scl
		var tx: float = clampf(center.x - tw * 0.5 + dx, 8.0, maxf(8.0, vp.x - tw - 8.0))
		var ty: float = clampf(center.y - th * 0.5, 56.0, maxf(56.0, vp.y - th - 48.0))
		_tpl_holder.position = Vector2(tx, ty)
		_tpl_holder.scale = Vector2(scl, scl)

	if _addon_holder != null:
		if t_sec < _impact_time:
			var p2: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			var ease_in: float = p2 * p2
			var s_a: float = base_scale * lerpf(0.92, 0.35, ease_in)
			var aw_start: float = 230.0 * base_scale * 0.92
			var start_x: float = maxf(8.0, center.x - minf(260.0, vp.x * 0.32) - aw_start * 0.5)
			var end_x: float = center.x - (230.0 * s_a) * 0.5
			var ah: float = 260.0 * s_a
			var cur_x: float = clampf(lerpf(start_x, end_x, ease_in), 8.0, maxf(8.0, vp.x - 230.0 * s_a - 8.0))
			var arc_y: float = -sin(p2 * PI) * minf(55.0, vp.y * 0.10)
			var cur_y: float = clampf(center.y - ah * 0.5 + arc_y, 56.0, maxf(56.0, vp.y - ah - 48.0))
			_addon_holder.position = Vector2(cur_x, cur_y)
			_addon_holder.scale = Vector2(s_a, s_a)
			_addon_holder.modulate.a = 1.0 - maxf(0.0, (p2 - 0.75) * 3.5)
		else:
			_addon_holder.visible = false

	if _anvil_badge != null:
		var a_pos: Vector2 = center - Vector2(30.0, 30.0)
		_anvil_badge.position = a_pos
		if t_sec < _impact_time:
			var p3: float = clampf(t_sec / _impact_time, 0.0, 1.0)
			var s_anv: float = base_scale * (0.85 + p3 * 0.35)
			_anvil_badge.scale = Vector2(s_anv, s_anv)
			_anvil_badge.modulate.a = 0.92
		else:
			var fade_p: float = clampf((t_sec - _impact_time) / 0.30, 0.0, 1.0)
			var s_f: float = base_scale * (1.3 - fade_p * 0.35)
			_anvil_badge.scale = Vector2(s_f, s_f)
			_anvil_badge.modulate.a = 1.0 - fade_p
			if fade_p >= 1.0:
				_anvil_badge.visible = false

func _spawn_sparks() -> void:
	var vp: Vector2 = _safe_vp()
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 12.0)
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
	var vp: Vector2 = _safe_vp()
	var center: Vector2 = vp * 0.5 + Vector2(0.0, 12.0)

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
