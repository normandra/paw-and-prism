class_name PoESocketWidget
extends Control

signal socket_clicked(equip_slot: int, socket_idx: int)

const SOCKET_SIZE: float = 42.0
const SOCKET_GAP: float = 18.0
const MINI_SIZE: float = 14.0
const MINI_GAP: float = 8.0

var equip_slot: int = GameEnums.EquipSlot.WEAPON
var item: ItemInstance = null
var selected_gem: GemInstance = null
var mini_mode: bool = false

var _hover_idx: int = -1
var _pulse_time: float = 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(240, 66)

func configure(p_slot: int, p_item: ItemInstance, p_sel_gem: GemInstance) -> void:
	mini_mode = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	equip_slot = p_slot
	item = p_item
	selected_gem = p_sel_gem
	var count: int = item.get_socket_count() if item != null else 0
	var width: float = maxf(68.0, float(count) * SOCKET_SIZE + float(maxi(0, count - 1)) * SOCKET_GAP + 12.0)
	custom_minimum_size = Vector2(width, 66.0)
	queue_redraw()

func configure_mini(p_item: ItemInstance) -> void:
	mini_mode = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	item = p_item
	selected_gem = null
	var count: int = item.get_socket_count() if item != null else 0
	var width: float = maxf(24.0, float(count) * MINI_SIZE + float(maxi(0, count - 1)) * MINI_GAP + 6.0)
	custom_minimum_size = Vector2(width, 20.0)
	queue_redraw()

func _process(delta: float) -> void:
	if not mini_mode and visible and selected_gem != null:
		_pulse_time += delta * 5.0
		queue_redraw()

func _get_socket_center(idx: int) -> Vector2:
	if mini_mode:
		return Vector2(3.0 + MINI_SIZE * 0.5 + float(idx) * (MINI_SIZE + MINI_GAP), size.y * 0.5)
	return Vector2(6.0 + SOCKET_SIZE * 0.5 + float(idx) * (SOCKET_SIZE + SOCKET_GAP), 23.0)

func _hit_test(pos: Vector2) -> int:
	if mini_mode or item == null:
		return -1
	var r_sq: float = (SOCKET_SIZE * 0.56) * (SOCKET_SIZE * 0.56)
	for i in range(item.get_socket_count()):
		var c: Vector2 = _get_socket_center(i)
		if pos.distance_squared_to(c) <= r_sq:
			return i
	return -1

func _gui_input(event: InputEvent) -> void:
	if mini_mode or item == null:
		return
	if event is InputEventMouseMotion:
		var new_hover: int = _hit_test(event.position)
		if new_hover != _hover_idx:
			_hover_idx = new_hover
			_update_hover_tooltip()
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit: int = _hit_test(event.position)
		if hit >= 0:
			socket_clicked.emit(equip_slot, hit)
			accept_event()

func _update_hover_tooltip() -> void:
	if item == null or _hover_idx < 0 or _hover_idx >= item.get_socket_count():
		tooltip_text = ""
		return
	var g: GemInstance = item.socketed_gems[_hover_idx]
	if g != null:
		tooltip_text = g.get_tooltip_text() + "\n(Click to unsocket)"
	else:
		var scol_name: String = GameEnums.gem_color_letter(item.socket_colors[_hover_idx])
		tooltip_text = "Empty (%s) Socket\nSelect a matching gem from Skill Gems tab and click to insert." % scol_name

func _draw() -> void:
	if item == null:
		return
	var count: int = item.get_socket_count()

	if mini_mode:
		for i in range(count - 1):
			if i < item.links.size() and item.links[i]:
				var c1: Vector2 = _get_socket_center(i)
				var c2: Vector2 = _get_socket_center(i + 1)
				draw_line(c1, c2, Color(0.95, 0.78, 0.30), 3.2, true)
		for i in range(count):
			var c: Vector2 = _get_socket_center(i)
			var col: Color = GameEnums.gem_color_value(item.socket_colors[i])
			draw_circle(c, 6.2, Color(0.10, 0.08, 0.07))
			draw_arc(c, 5.5, 0.0, TAU, 14, col, 2.0, true)
			if i < item.socketed_gems.size() and item.socketed_gems[i] != null:
				draw_circle(c, 3.0, col)
		return

	# Full Mode: Forged golden metallic link bars
	for i in range(count - 1):
		if i < item.links.size() and item.links[i]:
			var c1: Vector2 = _get_socket_center(i)
			var c2: Vector2 = _get_socket_center(i + 1)
			draw_line(c1, c2, Color(0.18, 0.12, 0.06), 12.0, true)
			draw_line(c1, c2, Color(0.95, 0.76, 0.28), 7.5, true)
			draw_line(c1, c2, Color(1.0, 0.94, 0.65), 2.5, true)

	var font: Font = UiHelper.get_bold_font()
	if font == null:
		font = ThemeDB.fallback_font

	for i in range(count):
		var c: Vector2 = _get_socket_center(i)
		var scol: int = item.socket_colors[i]
		var base_c: Color = GameEnums.gem_color_value(scol)
		var g_in: GemInstance = item.socketed_gems[i]
		var compatible: bool = (selected_gem != null and item.can_socket(i, selected_gem))

		if compatible:
			var pulse_alpha: float = 0.62 + 0.38 * sin(_pulse_time)
			draw_circle(c, 22.8, Color(1.0, 0.88, 0.32, pulse_alpha * 0.45))
			draw_arc(c, 21.5, 0.0, TAU, 24, Color(1.0, 0.90, 0.36, pulse_alpha), 2.5, true)

		var bezel_col: Color = base_c.lightened(0.18) if i == _hover_idx else base_c
		draw_circle(c, 19.0, Color(0.14, 0.10, 0.08))
		draw_arc(c, 18.0, 0.0, TAU, 24, bezel_col, 3.2, true)
		draw_circle(c, 15.2, Color(0.06, 0.05, 0.06))

		if g_in != null:
			var g_col: Color = GameEnums.gem_color_value(g_in.get_gem_color())
			var gtype: int = g_in.get_gem_type()
			var r: float = 11.2
			if gtype == GameEnums.GemType.SUPPORT:
				# Round orb gem
				draw_circle(c, r * 0.92, g_col)
				draw_arc(c, r * 0.92, 0.0, TAU, 18, g_col.darkened(0.35), 1.5, true)
			elif gtype == GameEnums.GemType.PASSIVE:
				# Hexagonal prism gem
				var hex_pts: PackedVector2Array = PackedVector2Array()
				for k in range(6):
					var ang: float = -PI * 0.5 + float(k) * TAU / 6.0
					hex_pts.append(c + Vector2(cos(ang) * r, sin(ang) * r))
				draw_colored_polygon(hex_pts, g_col)
			else:
				# Pentagon faceted Active gem
				var pent_pts: PackedVector2Array = PackedVector2Array([
					c + Vector2(0, -r),
					c + Vector2(r * 0.92, -r * 0.25),
					c + Vector2(r * 0.58, r * 0.88),
					c + Vector2(-r * 0.58, r * 0.88),
					c + Vector2(-r * 0.92, -r * 0.25),
				])
				draw_colored_polygon(pent_pts, g_col)
			draw_circle(c + Vector2(-3.2, -3.5), 2.5, Color(1.0, 1.0, 1.0, 0.88))

			# Crisp dark pill backing clearly below the bezel
			var pill_rect: Rect2 = Rect2(c.x - 23.0, 44.0, 46.0, 17.0)
			var pill_sb: StyleBoxFlat = UiHelper.make_panel_box(Color(0.08, 0.06, 0.06, 0.95), g_col, 5, 1, 0, false)
			draw_style_box(pill_sb, pill_rect)
			var badge_txt: String = "%s %d" % [g_in.get_short_label().substr(0, 3), g_in.level]
			draw_string(font, Vector2(c.x - 21.0, 56.5), badge_txt, HORIZONTAL_ALIGNMENT_CENTER, 42.0, 10, UiHelper.TEXT_CREAM)
		else:
			var letter: String = GameEnums.gem_color_letter(scol)
			draw_string(font, c + Vector2(-6.0, 4.5), letter, HORIZONTAL_ALIGNMENT_CENTER, 12.0, 12, Color(base_c.r, base_c.g, base_c.b, 0.78))
