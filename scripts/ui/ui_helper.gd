class_name UiHelper

static func make_panel_box(bg: Color = Color(0.11, 0.12, 0.18, 0.92), border: Color = Color(0.45, 0.48, 0.62, 0.8), radius: int = 10, border_w: int = 2, pad: int = 10) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border_w)
	sb.set_content_margin_all(pad)
	return sb

static func style_button(btn: Button, bg: Color = Color(0.20, 0.23, 0.34), border: Color = Color(0.50, 0.56, 0.74), radius: int = 8) -> void:
	var normal: StyleBoxFlat = make_panel_box(bg, border, radius, 2, 8)
	var hover: StyleBoxFlat = make_panel_box(bg.lightened(0.16), border.lightened(0.25), radius, 2, 8)
	var pressed: StyleBoxFlat = make_panel_box(bg.darkened(0.15), border, radius, 2, 8)
	var disabled: StyleBoxFlat = make_panel_box(bg.darkened(0.45), border.darkened(0.4), radius, 1, 8)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.88))

static func style_progress_bar(bar: ProgressBar, fill_col: Color, bg_col: Color = Color(0.08, 0.09, 0.14, 0.9), radius: int = 6) -> void:
	var bg: StyleBoxFlat = make_panel_box(bg_col, Color(0.32, 0.35, 0.48, 0.7), radius, 1, 0)
	var fill: StyleBoxFlat = make_panel_box(fill_col, fill_col.lightened(0.25), radius, 1, 0)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)

static func compare_items(new_item: ItemInstance, current_item: ItemInstance) -> Array[Dictionary]:
	var new_totals: Dictionary = new_item.get_stat_totals() if new_item != null else {}
	var cur_totals: Dictionary = current_item.get_stat_totals() if current_item != null else {}
	var all_stats: Dictionary = {}
	for k in new_totals.keys():
		all_stats[int(k)] = true
	for k in cur_totals.keys():
		all_stats[int(k)] = true
	var diffs: Array[Dictionary] = []
	for st in all_stats.keys():
		var nv: float = float(new_totals.get(st, 0.0))
		var cv: float = float(cur_totals.get(st, 0.0))
		var delta: float = nv - cv
		diffs.append({
			"stat": int(st),
			"new_val": nv,
			"old_val": cv,
			"delta": delta,
		})
	return diffs
