class_name TouchControls
extends Control

const BASE_RADIUS: float = 56.0
const KNOB_RADIUS: float = 22.0
const DEADZONE: float = 0.10
const FULL_SPEED_RATIO: float = 0.55

var move_vector: Vector2 = Vector2.ZERO
var touch_ui_visible: bool = false
var allow_mouse_emulation: bool = false
var excluded_controls: Array[Control] = []

var _move_touch_idx: int = -1
var _mouse_move_active: bool = false
var _origin: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _has_moved_once: bool = false

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

func reset_input() -> void:
	_move_touch_idx = -1
	_mouse_move_active = false
	move_vector = Vector2.ZERO
	_origin = Vector2.ZERO
	_knob_pos = Vector2.ZERO
	queue_redraw()

func get_move_vector() -> Vector2:
	return move_vector

func _is_stick_active() -> bool:
	return _move_touch_idx != -1 or _mouse_move_active

func _is_over_excluded(pos: Vector2) -> bool:
	for c in excluded_controls:
		if is_instance_valid(c) and c.visible and c.is_visible_in_tree():
			if c.get_global_rect().grow(8.0).has_point(pos):
				return true
	return false

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
			if _move_touch_idx == -1 and not _is_over_excluded(ev_t.position):
				_move_touch_idx = ev_t.index
				_origin = ev_t.position
				_knob_pos = ev_t.position
				move_vector = Vector2.ZERO
				_has_moved_once = true
				queue_redraw()
		elif ev_t.index == _move_touch_idx:
			_move_touch_idx = -1
			move_vector = Vector2.ZERO
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
	if touch_ui_visible and not _is_stick_active() and not _has_moved_once:
		_draw_move_hint()

	if _is_stick_active():
		_draw_active_joystick()

func _draw_move_hint() -> void:
	var is_portrait: bool = size.x < 700.0
	var hint_pos: Vector2 = Vector2(size.x * 0.5, size.y - (210.0 if is_portrait else 185.0))
	draw_circle(hint_pos, 34.0, Color(0.11, 0.08, 0.07, 0.26))
	draw_arc(hint_pos, 34.0, 0.0, TAU, 36, Color(0.96, 0.79, 0.34, 0.45), 2.0, true)
	draw_circle(hint_pos, 11.0, Color(0.96, 0.79, 0.34, 0.42))
	var bf: Font = UiHelper.get_bold_font()
	if bf != null:
		draw_string(
			bf,
			hint_pos + Vector2(-70.0, 52.0),
			"DRAG TO MOVE",
			HORIZONTAL_ALIGNMENT_CENTER,
			140.0,
			12,
			Color(0.99, 0.96, 0.90, 0.78)
		)

func _draw_active_joystick() -> void:
	draw_circle(_origin, BASE_RADIUS, Color(0.11, 0.08, 0.07, 0.48))
	draw_arc(_origin, BASE_RADIUS, 0.0, TAU, 48, Color(0.58, 0.45, 0.26, 0.88), 2.5, true)

	for ang_idx in range(4):
		var a: float = float(ang_idx) * PI * 0.5
		var d: Vector2 = Vector2(cos(a), sin(a))
		draw_line(_origin + d * (BASE_RADIUS - 8.0), _origin + d * (BASE_RADIUS - 2.0), Color(0.96, 0.79, 0.34, 0.65), 2.0, true)

	draw_line(_origin, _knob_pos, Color(0.96, 0.79, 0.34, 0.55), 4.0, true)

	draw_circle(_knob_pos + Vector2(0.0, 2.5), KNOB_RADIUS + 1.0, Color(0.03, 0.02, 0.02, 0.48))
	draw_circle(_knob_pos, KNOB_RADIUS, UiHelper.BORDER_GOLD)
	draw_arc(_knob_pos, KNOB_RADIUS, 0.0, TAU, 32, Color(0.24, 0.16, 0.10, 0.95), 2.0, true)
	draw_circle(_knob_pos + Vector2(-3.0, -4.0), KNOB_RADIUS * 0.42, Color(1.0, 0.96, 0.84, 0.55))
