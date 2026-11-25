class_name TouchScrollContainer
extends ScrollContainer

const DRAG_THRESHOLD: float = 14.0

static var _last_drag_ms: int = 0

var _tracking: bool = false
var _dragging: bool = false
var _touch_idx: int = -1
var _press_pos: Vector2 = Vector2.ZERO
var _last_y: float = 0.0
var _vel_y: float = 0.0

static func was_recent_drag(window_ms: int = 180) -> bool:
	return (Time.get_ticks_msec() - _last_drag_ms) <= window_ms

func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	follow_focus = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not _tracking and absf(_vel_y) > 4.0 and is_visible_in_tree():
		var next_scroll: float = float(scroll_vertical) + _vel_y * delta
		scroll_vertical = maxi(0, int(round(next_scroll)))
		_vel_y = lerpf(_vel_y, 0.0, minf(1.0, delta * 9.0))
	elif not _tracking:
		_vel_y = 0.0

func _input(event: InputEvent) -> void:
	if not visible or not is_visible_in_tree():
		_reset_drag()
		return

	if event is InputEventScreenTouch:
		var ev_t: InputEventScreenTouch = event
		if ev_t.pressed:
			if not _tracking and get_global_rect().has_point(ev_t.position):
				_tracking = true
				_dragging = false
				_touch_idx = ev_t.index
				_press_pos = ev_t.position
				_last_y = ev_t.position.y
				_vel_y = 0.0
		elif _tracking and ev_t.index == _touch_idx:
			if _dragging:
				_last_drag_ms = Time.get_ticks_msec()
			_tracking = false
			_dragging = false
			_touch_idx = -1
	elif event is InputEventScreenDrag:
		var ev_d: InputEventScreenDrag = event
		if _tracking and ev_d.index == _touch_idx:
			_handle_drag_move(ev_d.position)
	elif event is InputEventMouseButton:
		var ev_b: InputEventMouseButton = event
		if ev_b.button_index == MOUSE_BUTTON_LEFT:
			if ev_b.pressed:
				if not _tracking and get_global_rect().has_point(ev_b.position):
					_tracking = true
					_dragging = false
					_touch_idx = -2
					_press_pos = ev_b.position
					_last_y = ev_b.position.y
					_vel_y = 0.0
			elif _tracking and _touch_idx == -2:
				if _dragging:
					_last_drag_ms = Time.get_ticks_msec()
				_tracking = false
				_dragging = false
				_touch_idx = -1
	elif event is InputEventMouseMotion and _tracking and _touch_idx == -2:
		_handle_drag_move((event as InputEventMouseMotion).position)

func _handle_drag_move(pos: Vector2) -> void:
	if not _dragging and pos.distance_to(_press_pos) > DRAG_THRESHOLD:
		_dragging = true
	var dy: float = pos.y - _last_y
	_last_y = pos.y
	if _dragging and absf(dy) > 0.05:
		scroll_vertical = maxi(0, scroll_vertical - int(round(dy)))
		_vel_y = -dy * 24.0
		_last_drag_ms = Time.get_ticks_msec()

func _reset_drag() -> void:
	_tracking = false
	_dragging = false
	_touch_idx = -1
	_vel_y = 0.0
