class_name TouchControls
extends Control

signal dash_triggered()

const BASE_RADIUS: float = 68.0
const KNOB_RADIUS: float = 27.0
const DASH_RADIUS: float = 54.0
const DEADZONE: float = 0.10
const FULL_SPEED_RATIO: float = 0.55

var move_vector: Vector2 = Vector2.ZERO
var touch_ui_visible: bool = false
var allow_mouse_emulation: bool = false
var excluded_controls: Array[Control] = []

var _dash_ready_fraction: float = 1.0
var _move_touch_idx: int = -1
var _dash_touch_idx: int = -1
var _mouse_move_active: bool = false
var _origin: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _has_moved_once: bool = false
var _dash_flash: float = 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_touch_enabled(enabled: bool, allow_mouse: bool = false) -> void:
	touch_ui_visible = enabled
	allow_mouse_emulation = allow_mouse
	if not enabled:
		reset_input()
	queue_redraw()

func set_dash_fraction(frac: float) -> void:
	var clamped: float = clampf(frac, 0.0, 1.0)
	if absf(clamped - _dash_ready_fraction) > 0.01:
		_dash_ready_fraction = clamped
		if touch_ui_visible:
			queue_redraw()

func reset_input() -> void:
	_move_touch_idx = -1
	_dash_touch_idx = -1
	_mouse_move_active = false
	move_vector = Vector2.ZERO
	_origin = Vector2.ZERO
	_knob_pos = Vector2.ZERO
	queue_redraw()

func get_move_vector() -> Vector2:
	return move_vector

func _is_stick_active() -> bool:
	return _move_touch_idx != -1 or _mouse_move_active

func _get_dash_center() -> Vector2:
	return Vector2(size.x - 84.0, size.y - 92.0)

func _is_over_excluded(pos: Vector2) -> bool:
	for c in excluded_controls:
		if is_instance_valid(c) and c.visible and c.is_visible_in_tree():
			if c.get_global_rect().grow(8.0).has_point(pos):
				return true
	return false

func _process(delta: float) -> void:
	if _dash_flash > 0.0:
		_dash_flash = maxf(0.0, _dash_flash - delta * 4.0)
		queue_redraw()

func _input(event: InputEvent) -> void:
	if not visible or not is_visible_in_tree() or get_tree().paused:
		if _move_touch_idx != -1 or _mouse_move_active or move_vector != Vector2.ZERO:
			reset_input()
		return

	if event is InputEventScreenTouch:
		var ev_t: InputEventScreenTouch = event
		if ev_t.pressed:
			if not touch_ui_visible:
				touch_ui_visible = true
			if ev_t.position.distance_to(_get_dash_center()) <= DASH_RADIUS * 1.28:
				_dash_touch_idx = ev_t.index
				_dash_flash = 1.0
				dash_triggered.emit()
				get_viewport().set_input_as_handled()
				queue_redraw()
				return
			if _move_touch_idx == -1 and not _is_over_excluded(ev_t.position):
				_move_touch_idx = ev_t.index
				_origin = ev_t.position
				_knob_pos = ev_t.position
				move_vector = Vector2.ZERO
				_has_moved_once = true
				queue_redraw()
		else:
			if ev_t.index == _move_touch_idx:
				_move_touch_idx = -1
				move_vector = Vector2.ZERO
				queue_redraw()
			if ev_t.index == _dash_touch_idx:
				_dash_touch_idx = -1
				queue_redraw()
	elif event is InputEventScreenDrag:
		var ev_d: InputEventScreenDrag = event
		if ev_d.index == _move_touch_idx:
			_update_stick_drag(ev_d.position)
	elif allow_mouse_emulation and event.device != -1:
		if event is InputEventMouseButton:
			var ev_b: InputEventMouseButton = event
			if ev_b.button_index == MOUSE_BUTTON_LEFT:
				if ev_b.pressed:
					if touch_ui_visible and ev_b.position.distance_to(_get_dash_center()) <= DASH_RADIUS * 1.28:
						_dash_flash = 1.0
						dash_triggered.emit()
						get_viewport().set_input_as_handled()
						queue_redraw()
						return
					if not _is_over_excluded(ev_b.position):
						_mouse_move_active = true
						_origin = ev_b.position
						_knob_pos = ev_b.position
						move_vector = Vector2.ZERO
						_has_moved_once = true
						queue_redraw()
				elif _mouse_move_active:
					_mouse_move_active = false
					move_vector = Vector2.ZERO
					queue_redraw()
		elif event is InputEventMouseMotion and _mouse_move_active:
			_update_stick_drag((event as InputEventMouseMotion).position)

func _update_stick_drag(pos: Vector2) -> void:
	var delta_v: Vector2 = pos - _origin
	var dist: float = delta_v.length()
	if dist > BASE_RADIUS * 1.18:
		_origin = pos - delta_v.normalized() * (BASE_RADIUS * 1.18)
		delta_v = pos - _origin
		dist = delta_v.length()

	_knob_pos = _origin + (delta_v.normalized() * minf(dist, BASE_RADIUS) if dist > 0.001 else Vector2.ZERO)
	var norm_r: float = clampf(dist / (BASE_RADIUS * FULL_SPEED_RATIO), 0.0, 1.0)
	if dist / BASE_RADIUS < DEADZONE:
		move_vector = Vector2.ZERO
	else:
		move_vector = delta_v.normalized() * norm_r
	queue_redraw()

func _draw() -> void:
	if touch_ui_visible:
		_draw_dash_pad()
		if not _is_stick_active() and not _has_moved_once:
			_draw_move_hint()

	if _is_stick_active():
		_draw_active_joystick()

func _draw_dash_pad() -> void:
	var center: Vector2 = _get_dash_center()
	var ready: bool = _dash_ready_fraction >= 0.999

	# Soft drop shadow
	draw_circle(center + Vector2(0.0, 3.0), DASH_RADIUS + 2.0, Color(0.03, 0.02, 0.02, 0.55))

	# Espresso base circle
	var fill_col: Color = Color(0.14, 0.10, 0.08, 0.90)
	if _dash_flash > 0.0:
		fill_col = fill_col.lerp(UiHelper.BORDER_GOLD, _dash_flash * 0.35)
	draw_circle(center, DASH_RADIUS, fill_col)

	# Outer brass ring
	draw_arc(center, DASH_RADIUS, 0.0, TAU, 48, UiHelper.BORDER_BRASS if not ready else UiHelper.BORDER_GOLD, 3.0, true)

	# Cooldown progress ring
	if _dash_ready_fraction > 0.01:
		var arc_col: Color = Color(1.0, 0.84, 0.30, 0.98) if ready else Color(0.96, 0.72, 0.24, 0.85)
		draw_arc(center, DASH_RADIUS - 5.0, -PI * 0.5, -PI * 0.5 + TAU * _dash_ready_fraction, 40, arc_col, 5.0, true)

	# Dash paw icon centered slightly above label
	var dash_tex: Texture2D = UiIcons.get_ui_icon("dash_paw")
	if dash_tex != null:
		var icon_rect: Rect2 = Rect2(center + Vector2(-18.0, -25.0), Vector2(36.0, 36.0))
		draw_texture_rect(dash_tex, icon_rect, false, Color.WHITE if ready else Color(0.75, 0.72, 0.68, 0.75))

	var disp_f: Font = UiHelper.get_display_font()
	if disp_f != null:
		var lbl_pos: Vector2 = center + Vector2(-DASH_RADIUS, 24.0)
		draw_string(
			disp_f,
			lbl_pos,
			"DASH",
			HORIZONTAL_ALIGNMENT_CENTER,
			DASH_RADIUS * 2.0,
			13,
			UiHelper.TEXT_CREAM if ready else Color(0.75, 0.70, 0.62, 0.80)
		)

func _draw_move_hint() -> void:
	var is_portrait: bool = size.x < 960.0
	var hint_pos: Vector2 = Vector2(minf(size.x * 0.24, 175.0), size.y - (340.0 if is_portrait else 245.0))
	draw_circle(hint_pos, 46.0, Color(0.11, 0.08, 0.07, 0.24))
	draw_arc(hint_pos, 46.0, 0.0, TAU, 36, Color(0.96, 0.79, 0.34, 0.42), 2.0, true)
	draw_circle(hint_pos, 14.0, Color(0.96, 0.79, 0.34, 0.38))
	var bf: Font = UiHelper.get_bold_font()
	if bf != null:
		draw_string(
			bf,
			hint_pos + Vector2(-65.0, 66.0),
			"DRAG TO MOVE",
			HORIZONTAL_ALIGNMENT_CENTER,
			130.0,
			12,
			Color(0.99, 0.96, 0.90, 0.72)
		)

func _draw_active_joystick() -> void:
	# Base disc
	draw_circle(_origin, BASE_RADIUS, Color(0.11, 0.08, 0.07, 0.48))
	draw_arc(_origin, BASE_RADIUS, 0.0, TAU, 48, Color(0.58, 0.45, 0.26, 0.88), 3.0, true)

	# 4 subtle cardinal gold tick marks
	for ang_idx in range(4):
		var a: float = float(ang_idx) * PI * 0.5
		var d: Vector2 = Vector2(cos(a), sin(a))
		draw_line(_origin + d * (BASE_RADIUS - 10.0), _origin + d * (BASE_RADIUS - 3.0), Color(0.96, 0.79, 0.34, 0.65), 2.5, true)

	# Stem line
	draw_line(_origin, _knob_pos, Color(0.96, 0.79, 0.34, 0.55), 5.0, true)

	# Thumb knob shadow + brass/gold body + highlight
	draw_circle(_knob_pos + Vector2(0.0, 3.0), KNOB_RADIUS + 1.0, Color(0.03, 0.02, 0.02, 0.48))
	draw_circle(_knob_pos, KNOB_RADIUS, UiHelper.BORDER_GOLD)
	draw_arc(_knob_pos, KNOB_RADIUS, 0.0, TAU, 32, Color(0.24, 0.16, 0.10, 0.95), 2.5, true)
	draw_circle(_knob_pos + Vector2(-4.0, -5.0), KNOB_RADIUS * 0.42, Color(1.0, 0.96, 0.84, 0.55))
