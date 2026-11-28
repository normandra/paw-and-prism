class_name ResponsiveModal
extends Control

var max_modal_size: Vector2 = Vector2(1060.0, 650.0)
var compact_breakpoint: float = 760.0
var fill_height_when_compact: bool = true
var compact_margin: int = 8
var wide_margin: int = 18

var modal_bg_color: Color = UiHelper.BG_WOOD_DEEP
var modal_border_color: Color = UiHelper.BORDER_GOLD
var modal_radius: int = 16
var modal_border_w: int = 3
var modal_pad: int = 12

var _dim: ColorRect = null
var _bounds_margin: MarginContainer = null
var _frame: PanelContainer = null
var _content_root: VBoxContainer = null
var _is_compact_layout: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiHelper.create_game_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	_dim = ColorRect.new()
	_dim.name = "ModalDim"
	_dim.color = Color(0.03, 0.02, 0.02, 0.80)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)

	_bounds_margin = MarginContainer.new()
	_bounds_margin.name = "ModalBounds"
	_bounds_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bounds_margin.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_bounds_margin)

	_frame = PanelContainer.new()
	_frame.name = "ModalFrame"
	_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_frame.custom_minimum_size = Vector2.ZERO
	_frame.clip_contents = true
	_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(modal_bg_color, modal_border_color, modal_radius, modal_border_w, modal_pad))
	_bounds_margin.add_child(_frame)

	_content_root = VBoxContainer.new()
	_content_root.name = "ModalContent"
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_root.add_theme_constant_override("separation", 8)
	_frame.add_child(_content_root)

	_build_modal_content(_content_root)
	if get_viewport() != null:
		get_viewport().size_changed.connect(_on_viewport_resized)
	_sync_modal_bounds()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_VISIBILITY_CHANGED:
		if _bounds_margin != null:
			_sync_modal_bounds()

func _on_viewport_resized() -> void:
	if _bounds_margin != null:
		_sync_modal_bounds()

func get_safe_viewport_size() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	if (vp.x <= 10.0 or vp.y <= 10.0) and get_viewport() != null:
		vp = get_viewport().get_visible_rect().size
	if vp.x <= 10.0 or vp.y <= 10.0:
		vp = Vector2(1280.0, 720.0)
	return vp

func _sync_modal_bounds() -> void:
	if _bounds_margin == null:
		return
	var vp: Vector2 = get_safe_viewport_size()
	_is_compact_layout = vp.x < compact_breakpoint
	var m: int = compact_margin if _is_compact_layout else wide_margin
	var avail_w: float = maxf(240.0, vp.x - float(m * 2))
	var avail_h: float = maxf(200.0, vp.y - float(m * 2))
	var target_w: float = avail_w if _is_compact_layout else minf(avail_w, max_modal_size.x)
	var target_h: float = avail_h if (_is_compact_layout and fill_height_when_compact) else minf(avail_h, max_modal_size.y)

	var pad_x: int = int(floor(maxf(float(m), (vp.x - target_w) * 0.5)))
	var pad_y: int = int(floor(maxf(float(m), (vp.y - target_h) * 0.5)))
	_bounds_margin.add_theme_constant_override("margin_left", pad_x)
	_bounds_margin.add_theme_constant_override("margin_right", pad_x)
	_bounds_margin.add_theme_constant_override("margin_top", pad_y)
	_bounds_margin.add_theme_constant_override("margin_bottom", pad_y)

	if _frame != null:
		var inner_pad: int = mini(modal_pad, 8) if _is_compact_layout else modal_pad
		_frame.add_theme_stylebox_override("panel", UiHelper.make_panel_box(modal_bg_color, modal_border_color, modal_radius, modal_border_w, inner_pad))

	_on_responsive_layout(vp, _is_compact_layout)

func _build_modal_content(_root: VBoxContainer) -> void:
	pass

func _on_responsive_layout(_vp_size: Vector2, _is_compact: bool) -> void:
	pass
