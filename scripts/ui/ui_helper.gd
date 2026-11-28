class_name UiHelper

# Warm Storybook Timber & Enchanted Gold Palette (3-Tier Surface Elevation)
const BG_WOOD_DEEP := Color(0.11, 0.08, 0.07, 0.97)
const BG_WALNUT := Color(0.19, 0.14, 0.11, 0.98)
const BG_OAK_CARD := Color(0.24, 0.18, 0.14, 0.98)
const BG_WELL := Color(0.09, 0.07, 0.06, 0.96)
const BORDER_GOLD := Color(0.96, 0.79, 0.34, 0.96)
const BORDER_BRASS := Color(0.58, 0.45, 0.26, 0.92)
const BORDER_SUBTLE := Color(0.36, 0.28, 0.20, 0.72)
const BORDER_COMMON := Color(0.48, 0.43, 0.38, 0.92)
const TEXT_CREAM := Color(0.99, 0.96, 0.90)
const TEXT_PARCHMENT := Color(0.88, 0.82, 0.70)
const CTA_EMERALD := Color(0.19, 0.58, 0.33)
const CTA_EMERALD_RIM := Color(0.56, 0.94, 0.54)
const CTA_RUBY := Color(0.56, 0.19, 0.23)
const CTA_RUBY_RIM := Color(0.94, 0.50, 0.44)
const CTA_SAPPHIRE := Color(0.20, 0.37, 0.58)
const CTA_SAPPHIRE_RIM := Color(0.54, 0.84, 1.0)

static var _display_font: Font = null
static var _body_font: Font = null
static var _bold_font: Font = null
static var _theme_cache: Theme = null

static func _wght_tag() -> int:
	var ts: TextServer = TextServerManager.get_primary_interface()
	if ts != null:
		return ts.name_to_tag("wght")
	return 2003265652 # ASCII 'wght' FourCC

static func get_display_font() -> Font:
	if _display_font == null:
		var base: Font = load("res://assets/fonts/Fredoka.ttf")
		if base != null:
			var fv: FontVariation = FontVariation.new()
			fv.base_font = base
			fv.variation_opentype = {_wght_tag(): 700}
			_display_font = fv
	return _display_font

static func get_body_font() -> Font:
	if _body_font == null:
		var base: Font = load("res://assets/fonts/Nunito.ttf")
		if base != null:
			var fv: FontVariation = FontVariation.new()
			fv.base_font = base
			fv.variation_opentype = {_wght_tag(): 600}
			_body_font = fv
	return _body_font

static func get_bold_font() -> Font:
	if _bold_font == null:
		var base: Font = load("res://assets/fonts/Nunito.ttf")
		if base != null:
			var fv: FontVariation = FontVariation.new()
			fv.base_font = base
			fv.variation_opentype = {_wght_tag(): 800}
			_bold_font = fv
	return _bold_font

static func rarity_border_color(rarity: int) -> Color:
	if rarity == GameEnums.Rarity.COMMON:
		return BORDER_COMMON
	return GameEnums.rarity_color(rarity)

static func create_game_theme() -> Theme:
	if _theme_cache != null:
		return _theme_cache
	var t: Theme = Theme.new()
	var body_f: Font = get_body_font()
	var disp_f: Font = get_display_font()
	if body_f != null:
		t.default_font = body_f
		t.default_font_size = 14
		t.set_font("font", "Label", body_f)
		t.set_font("normal_font", "RichTextLabel", body_f)
		t.set_font("bold_font", "RichTextLabel", get_bold_font())
	if disp_f != null:
		t.set_font("font", "Button", disp_f)

	t.set_color("font_color", "Label", TEXT_CREAM)
	t.set_color("default_color", "RichTextLabel", TEXT_CREAM)

	var btn_norm: StyleBoxFlat = make_bevel_box(BG_OAK_CARD, BORDER_BRASS, 10, 2, 5, 10)
	var btn_hov: StyleBoxFlat = make_bevel_box(BG_OAK_CARD.lightened(0.14), BORDER_GOLD, 10, 2, 5, 10)
	var btn_prs: StyleBoxFlat = make_bevel_box(BG_WOOD_DEEP, BORDER_GOLD, 10, 4, 2, 10)
	t.set_stylebox("normal", "Button", btn_norm)
	t.set_stylebox("hover", "Button", btn_hov)
	t.set_stylebox("pressed", "Button", btn_prs)
	t.set_stylebox("focus", "Button", btn_hov)

	t.set_stylebox("panel", "PanelContainer", make_panel_box(BG_WOOD_DEEP, BORDER_BRASS, 12, 2, 10))

	# Custom slim warm gold scrollbars
	var sb_track: StyleBoxFlat = StyleBoxFlat.new()
	sb_track.bg_color = Color(0.08, 0.06, 0.05, 0.85)
	sb_track.set_corner_radius_all(5)
	sb_track.content_margin_left = 4
	sb_track.content_margin_right = 4
	var sb_grab: StyleBoxFlat = StyleBoxFlat.new()
	sb_grab.bg_color = Color(0.68, 0.54, 0.28, 0.9)
	sb_grab.set_corner_radius_all(5)
	var sb_grab_hov: StyleBoxFlat = StyleBoxFlat.new()
	sb_grab_hov.bg_color = BORDER_GOLD
	sb_grab_hov.set_corner_radius_all(5)

	for sb_type in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sb_type, sb_track)
		t.set_stylebox("grabber", sb_type, sb_grab)
		t.set_stylebox("grabber_highlight", sb_type, sb_grab_hov)
		t.set_stylebox("grabber_pressed", sb_type, sb_grab_hov)

	t.set_stylebox("panel", "TooltipPanel", make_panel_box(Color(0.10, 0.08, 0.07, 0.98), BORDER_GOLD, 10, 2, 10))
	t.set_color("font_color", "TooltipLabel", TEXT_CREAM)
	if body_f != null:
		t.set_font("font", "TooltipLabel", body_f)
	t.set_font_size("font_size", "TooltipLabel", 13)

	var sep: StyleBoxLine = StyleBoxLine.new()
	sep.color = Color(0.58, 0.45, 0.26, 0.55)
	sep.thickness = 2
	t.set_stylebox("separator", "HSeparator", sep)

	_theme_cache = t
	return t

static func make_panel_box(bg: Color = BG_WOOD_DEEP, border: Color = BORDER_BRASS, radius: int = 12, border_w: int = 2, pad: int = 10, with_shadow: bool = true) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border_w)
	sb.set_content_margin_all(pad)
	if with_shadow:
		sb.shadow_color = Color(0.02, 0.01, 0.01, 0.48)
		sb.shadow_size = 7
		sb.shadow_offset = Vector2(0, 3)
	return sb

static func make_accent_card_box(bg: Color, accent: Color, radius: int = 10, pad: int = 8) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = accent
	sb.set_corner_radius_all(radius)
	sb.border_width_left = 4
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.set_content_margin_all(pad)
	return sb

static func make_bevel_box(bg: Color, border: Color, radius: int, top_w: int, bot_w: int, pad: int) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_corner_radius_all(radius)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = top_w
	sb.border_width_bottom = bot_w
	sb.set_content_margin_all(pad)
	sb.shadow_color = Color(0.02, 0.01, 0.01, 0.42)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 2)
	return sb

static func style_button(btn: Button, bg: Color = BG_OAK_CARD, border: Color = BORDER_BRASS, radius: int = 10, pad: int = 8) -> void:
	var normal: StyleBoxFlat = make_bevel_box(bg, border, radius, 2, 5, pad)
	var hover: StyleBoxFlat = make_bevel_box(bg.lightened(0.14), border.lightened(0.22), radius, 2, 5, pad)
	var pressed: StyleBoxFlat = make_bevel_box(bg.darkened(0.18), border, radius, 4, 2, pad)
	var disabled: StyleBoxFlat = make_bevel_box(bg.darkened(0.38), border.darkened(0.38), radius, 1, 2, pad)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", TEXT_CREAM)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.88))
	btn.add_theme_color_override("font_disabled_color", Color(0.68, 0.63, 0.56))
	btn.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.03, 0.90))
	btn.add_theme_constant_override("outline_size", 2)
	var df: Font = get_display_font()
	if df != null:
		btn.add_theme_font_override("font", df)

static func style_progress_bar(bar: ProgressBar, fill_col: Color, bg_col: Color = BG_WELL, radius: int = 7) -> void:
	var bg: StyleBoxFlat = make_panel_box(bg_col, Color(0.38, 0.30, 0.22, 0.85), radius, 2, 0, false)
	var fill: StyleBoxFlat = make_panel_box(fill_col, fill_col.lightened(0.30), radius, 1, 0, false)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)

static func apply_display_font(lbl: Label, size: int, col: Color = TEXT_CREAM, outline: int = 3) -> void:
	var df: Font = get_display_font()
	if df != null:
		lbl.add_theme_font_override("font", df)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", col)
	if outline > 0:
		lbl.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.03, 0.94))
		lbl.add_theme_constant_override("outline_size", outline)

static func make_icon_rect(tex: Texture2D, sz: int = 24) -> TextureRect:
	var tr: TextureRect = TextureRect.new()
	tr.texture = tex
	tr.custom_minimum_size = Vector2(sz, sz)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

static func make_badge_pill(text: String, bg: Color, border: Color, text_col: Color = TEXT_CREAM, font_size: int = 11) -> PanelContainer:
	var p: PanelContainer = PanelContainer.new()
	var sb: StyleBoxFlat = make_panel_box(bg, border, 7, 1, 3, false)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", text_col)
	var bf: Font = get_bold_font()
	if bf != null:
		lbl.add_theme_font_override("font", bf)
	p.add_child(lbl)
	return p

static func make_forge_pips_row(used: int, max_forges: int, accent: Color, pip_size: int = 10) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(max_forges):
		var pip: Panel = Panel.new()
		pip.custom_minimum_size = Vector2(pip_size, pip_size)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.set_corner_radius_all(3)
		sb.set_border_width_all(1)
		if i < used:
			sb.bg_color = accent
			sb.border_color = Color(1.0, 0.96, 0.80)
		else:
			sb.bg_color = BG_WELL
			sb.border_color = accent.darkened(0.35)
		pip.add_theme_stylebox_override("panel", sb)
		row.add_child(pip)
	return row
