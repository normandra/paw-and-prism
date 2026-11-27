class_name UiIcons

static var _cache: Dictionary = {}

static func _from_svg(key: String, svg_str: String, scale_factor: float = 2.0) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var img: Image = Image.new()
	var err: int = img.load_svg_from_string(svg_str, scale_factor)
	if err != OK or img.is_empty():
		img = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.85, 0.35, 1.0))
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

static func get_hero_portrait(hero_id: String) -> Texture2D:
	var key: String = "hero_" + hero_id
	if _cache.has(key):
		return _cache[key]
	var svg: String = ""
	match hero_id:
		"shiba":
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
			<circle cx="32" cy="32" r="30" fill="#3a2820" stroke="#f2c757" stroke-width="3"/>
			<polygon points="14,24 18,6 28,18" fill="#eba042" stroke="#2d1d14" stroke-width="2" stroke-linejoin="round"/>
			<polygon points="50,24 46,6 36,18" fill="#eba042" stroke="#2d1d14" stroke-width="2" stroke-linejoin="round"/>
			<polygon points="17,22 20,11 26,18" fill="#ffa8ba"/>
			<polygon points="47,22 44,11 38,18" fill="#ffa8ba"/>
			<ellipse cx="32" cy="35" rx="20" ry="18" fill="#eba042" stroke="#2d1d14" stroke-width="2"/>
			<ellipse cx="32" cy="40" rx="16" ry="12" fill="#fff2d8"/>
			<circle cx="24" cy="32" r="3.4" fill="#1e1718"/>
			<circle cx="40" cy="32" r="3.4" fill="#1e1718"/>
			<circle cx="23" cy="30.8" r="1.2" fill="#ffffff"/>
			<circle cx="39" cy="30.8" r="1.2" fill="#ffffff"/>
			<ellipse cx="18" cy="37" rx="3.4" ry="2" fill="#ff8fa6"/>
			<ellipse cx="46" cy="37" rx="3.4" ry="2" fill="#ff8fa6"/>
			<ellipse cx="32" cy="37" rx="3.2" ry="2.3" fill="#2d1d14"/>
			<path d="M18,51 Q32,58 46,51 L43,47 Q32,52 21,47 Z" fill="#e64545"/>
			</svg>"""
		"bunny":
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
			<circle cx="32" cy="32" r="30" fill="#2d2642" stroke="#9ac2ff" stroke-width="3"/>
			<ellipse cx="22" cy="18" rx="6" ry="15" transform="rotate(-14 22 18)" fill="#faeae4" stroke="#2d1d24" stroke-width="2"/>
			<ellipse cx="42" cy="18" rx="6" ry="15" transform="rotate(14 42 18)" fill="#faeae4" stroke="#2d1d24" stroke-width="2"/>
			<ellipse cx="22" cy="19" rx="3" ry="10" transform="rotate(-14 22 19)" fill="#ffb8cf"/>
			<ellipse cx="42" cy="19" rx="3" ry="10" transform="rotate(14 42 19)" fill="#ffb8cf"/>
			<ellipse cx="32" cy="39" rx="19" ry="16" fill="#faeae4" stroke="#2d1d24" stroke-width="2"/>
			<polygon points="32,8 42,24 22,24" fill="#5258c4" stroke="#242763" stroke-width="2" stroke-linejoin="round"/>
			<ellipse cx="32" cy="24" rx="14" ry="3.5" fill="#5258c4" stroke="#f7cf57" stroke-width="1.5"/>
			<circle cx="24" cy="37" r="3.4" fill="#201a26"/>
			<circle cx="40" cy="37" r="3.4" fill="#201a26"/>
			<circle cx="23" cy="35.8" r="1.2" fill="#ffffff"/>
			<circle cx="39" cy="35.8" r="1.2" fill="#ffffff"/>
			<ellipse cx="18" cy="42" rx="3.4" ry="2" fill="#ff94b2"/>
			<ellipse cx="46" cy="42" rx="3.4" ry="2" fill="#ff94b2"/>
			<ellipse cx="32" cy="41" rx="2.8" ry="2" fill="#ff84aa"/>
			</svg>"""
		"bear":
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
			<circle cx="32" cy="32" r="30" fill="#263322" stroke="#f2b84b" stroke-width="3"/>
			<circle cx="16" cy="20" r="8" fill="#9e6338" stroke="#2d1d14" stroke-width="2"/>
			<circle cx="48" cy="20" r="8" fill="#9e6338" stroke="#2d1d14" stroke-width="2"/>
			<circle cx="16" cy="20" r="4.2" fill="#e6bf8a"/>
			<circle cx="48" cy="20" r="4.2" fill="#e6bf8a"/>
			<ellipse cx="32" cy="36" rx="21" ry="18" fill="#9e6338" stroke="#2d1d14" stroke-width="2"/>
			<ellipse cx="32" cy="41" rx="10" ry="8" fill="#e6bf8a"/>
			<circle cx="23" cy="33" r="3.2" fill="#1e1718"/>
			<circle cx="41" cy="33" r="3.2" fill="#1e1718"/>
			<circle cx="22" cy="31.8" r="1.1" fill="#ffffff"/>
			<circle cx="40" cy="31.8" r="1.1" fill="#ffffff"/>
			<ellipse cx="17" cy="39" rx="3.4" ry="2" fill="#ff8fa6"/>
			<ellipse cx="47" cy="39" rx="3.4" ry="2" fill="#ff8fa6"/>
			<ellipse cx="32" cy="38.5" rx="3.8" ry="2.6" fill="#2d1d14"/>
			<path d="M22,16 Q32,10 42,16" fill="none" stroke="#5cc466" stroke-width="3.5" stroke-linecap="round"/>
			<circle cx="32" cy="13" r="3" fill="#ffd84f"/>
			</svg>"""
		_:
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
			<circle cx="32" cy="32" r="30" fill="#232533" stroke="#ffd257" stroke-width="3"/>
			<polygon points="14,25 16,7 28,18" fill="#373a47" stroke="#181920" stroke-width="2" stroke-linejoin="round"/>
			<polygon points="50,25 48,7 36,18" fill="#373a47" stroke="#181920" stroke-width="2" stroke-linejoin="round"/>
			<polygon points="17,22 18,12 25,18" fill="#ff9eb8"/>
			<polygon points="47,22 46,12 39,18" fill="#ff9eb8"/>
			<ellipse cx="32" cy="36" rx="20" ry="17" fill="#373a47" stroke="#181920" stroke-width="2"/>
			<ellipse cx="32" cy="42" rx="14" ry="10" fill="#f5f5fa"/>
			<circle cx="24" cy="33" r="3.5" fill="#ffd24a"/>
			<circle cx="40" cy="33" r="3.5" fill="#ffd24a"/>
			<circle cx="24" cy="33" r="1.8" fill="#181920"/>
			<circle cx="40" cy="33" r="1.8" fill="#181920"/>
			<circle cx="22.8" cy="31.8" r="1" fill="#ffffff"/>
			<circle cx="38.8" cy="31.8" r="1" fill="#ffffff"/>
			<ellipse cx="32" cy="38.5" rx="2.8" ry="2" fill="#ff8cb0"/>
			<circle cx="32" cy="51" r="4" fill="#ffd257" stroke="#8c6216" stroke-width="1.5"/>
			</svg>"""
	return _from_svg(key, svg, 1.5)

static func get_slot_icon(slot: int) -> Texture2D:
	var key: String = "slot_%d" % slot
	if _cache.has(key):
		return _cache[key]
	var inner: String = ""
	match slot:
		GameEnums.EquipSlot.WEAPON:
			inner = """<path d="M12,36 L30,18 L34,22 L16,40 Z" fill="#b87b44" stroke="#2d1c12" stroke-width="2"/><circle cx="34" cy="14" r="8" fill="#f7c74a" stroke="#7a5112" stroke-width="2"/><polygon points="34,4 36,11 43,14 36,16 34,23 31,16 24,14 31,11" fill="#fff7c2"/>"""
		GameEnums.EquipSlot.HELMET:
			inner = """<path d="M10,34 Q24,39 38,34 L34,28 L24,10 L14,28 Z" fill="#5b6ee1" stroke="#1e2452" stroke-width="2" stroke-linejoin="round"/><ellipse cx="24" cy="32" rx="16" ry="5" fill="#4657bd" stroke="#f7cf57" stroke-width="2"/><circle cx="24" cy="23" r="3" fill="#ffe175"/>"""
		GameEnums.EquipSlot.ARMOR:
			inner = """<path d="M12,12 L20,10 L24,15 L28,10 L36,12 L40,22 L34,24 L34,38 L14,38 L14,24 L8,22 Z" fill="#639bff" stroke="#1b2b4a" stroke-width="2" stroke-linejoin="round"/><circle cx="24" cy="25" r="4.5" fill="#ffd966"/>"""
		GameEnums.EquipSlot.BOOTS:
			inner = """<path d="M14,12 L25,12 L25,27 L38,29 L38,37 L14,37 Z" fill="#9c6238" stroke="#2b190d" stroke-width="2" stroke-linejoin="round"/><path d="M26,18 L35,14 L32,22" fill="none" stroke="#ffe57f" stroke-width="2.5" stroke-linecap="round"/>"""
		GameEnums.EquipSlot.AMULET:
			inner = """<path d="M14,12 Q24,26 34,12" fill="none" stroke="#e0b248" stroke-width="2.5"/><circle cx="24" cy="28" r="9" fill="#ffd24a" stroke="#6b4b12" stroke-width="2"/><circle cx="24" cy="28" r="4.5" fill="#5ce1e6"/>"""
		_:
			inner = """<ellipse cx="24" cy="28" rx="12" ry="10" fill="none" stroke="#f2c44e" stroke-width="5"/><polygon points="24,10 31,17 24,23 17,17" fill="#57e68b" stroke="#195c34" stroke-width="1.8"/>"""
	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">%s</svg>""" % inner
	return _from_svg(key, svg, 1.5)

static func get_skill_icon(gem_id: String) -> Texture2D:
	var key: String = "skill_" + gem_id
	if _cache.has(key):
		return _cache[key]
	var inner: String = ""
	match gem_id:
		"acorn_barrage":
			inner = """<ellipse cx="26" cy="27" rx="11" ry="12" transform="rotate(-25 26 27)" fill="#d6943c" stroke="#3b2210" stroke-width="2"/><path d="M16,18 Q24,10 34,16 L31,23 Q23,19 15,24 Z" fill="#6b3e1e" stroke="#2d180a" stroke-width="2"/><path d="M8,36 L15,31 M12,41 L19,36" stroke="#fff3a8" stroke-width="2.5" stroke-linecap="round"/>"""
		"starlight_orb":
			inner = """<circle cx="24" cy="24" r="16" fill="none" stroke="#5ec7ff" stroke-width="2.2" stroke-dasharray="6 4"/><polygon points="24,6 28,16 38,18 28,22 24,32 20,22 10,18 20,16" fill="#92f0ff" stroke="#1e5780" stroke-width="1.8"/><circle cx="37" cy="34" r="4.5" fill="#ffe878"/>"""
		"honey_slam":
			inner = """<ellipse cx="24" cy="36" rx="17" ry="6" fill="#ffbe33" fill-opacity="0.6" stroke="#ffdf70" stroke-width="2"/><rect x="14" y="10" width="20" height="13" rx="3" fill="#f2a629" stroke="#4f2c08" stroke-width="2"/><rect x="22" y="23" width="4" height="14" fill="#7a461e"/>"""
		"whisker_lightning":
			inner = """<polygon points="28,4 13,25 23,25 18,44 36,21 25,21" fill="#6be2ff" stroke="#1a4e73" stroke-width="2" stroke-linejoin="round"/><polygon points="26,9 18,23 25,23 21,37 32,22 24,22" fill="#fff7b0"/>"""
		"petal_cyclone":
			inner = """<ellipse cx="24" cy="13" rx="6" ry="9" fill="#ff94c2" stroke="#8c2653" stroke-width="1.5"/><ellipse cx="35" cy="24" rx="9" ry="6" fill="#ffb8d9" stroke="#8c2653" stroke-width="1.5"/><ellipse cx="24" cy="35" rx="6" ry="9" fill="#ff94c2" stroke="#8c2653" stroke-width="1.5"/><ellipse cx="13" cy="24" rx="9" ry="6" fill="#ffb8d9" stroke="#8c2653" stroke-width="1.5"/><circle cx="24" cy="24" r="4.5" fill="#ffe57a"/>"""
		"fireball_berry":
			inner = """<path d="M24,5 C36,15 39,29 29,39 C22,44 13,40 12,30 C11,20 19,14 24,5 Z" fill="#ff6624" stroke="#611808" stroke-width="2"/><circle cx="23" cy="29" r="7.5" fill="#ffd24a"/>"""
		"frost_nova":
			inner = """<path d="M24,6 L24,42 M8,15 L40,33 M40,15 L8,33" stroke="#8af0ff" stroke-width="3.5" stroke-linecap="round"/><polygon points="24,14 32,24 24,34 16,24" fill="#d9fbff" stroke="#2c7a96" stroke-width="1.8"/>"""
		"boomerang_bone":
			inner = """<path d="M12,18 C18,12 30,12 36,18" fill="none" stroke="#ffdf7a" stroke-width="2.5" stroke-dasharray="4 3"/><path d="M12,30 L34,20" stroke="#fff7e8" stroke-width="7" stroke-linecap="round"/><circle cx="11" cy="27" r="4" fill="#fff7e8"/><circle cx="14" cy="33" r="4" fill="#fff7e8"/><circle cx="34" cy="17" r="4" fill="#fff7e8"/><circle cx="37" cy="23" r="4" fill="#fff7e8"/>"""
		"meteor_pine":
			inner = """<path d="M38,8 L22,24" stroke="#ff8229" stroke-width="7" stroke-linecap="round"/><ellipse cx="20" cy="29" rx="10" ry="12" transform="rotate(35 20 29)" fill="#b34419" stroke="#ffd257" stroke-width="2"/><circle cx="17" cy="31" r="4" fill="#ffe370"/>"""
		"spirit_bees":
			inner = """<ellipse cx="20" cy="16" rx="7" ry="4" transform="rotate(-25 20 16)" fill="#d6f7ff"/><ellipse cx="29" cy="16" rx="7" ry="4" transform="rotate(25 29 16)" fill="#d6f7ff"/><ellipse cx="24" cy="28" rx="11" ry="8" fill="#ffd238" stroke="#36240c" stroke-width="2"/><rect x="19" y="21" width="3.5" height="14" fill="#36240c"/><rect x="26" y="21" width="3.5" height="14" fill="#36240c"/>"""
		_:
			inner = """<polygon points="24,6 40,24 24,42 8,24" fill="#ffd56b" stroke="#6b4b12" stroke-width="2"/>"""
	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">%s</svg>""" % inner
	return _from_svg(key, svg, 1.5)

static func get_gem_icon(gem_type: int, gem_color: int) -> Texture2D:
	var key: String = "gem_%d_%d" % [gem_type, gem_color]
	if _cache.has(key):
		return _cache[key]
	var fill_hex: String = GameEnums.gem_color_hex(gem_color)
	var dark_hex: String = "#" + GameEnums.gem_color_value(gem_color).darkened(0.45).to_html(false)
	var light_hex: String = "#" + GameEnums.gem_color_value(gem_color).lightened(0.45).to_html(false)
	var svg: String = ""
	match gem_type:
		GameEnums.GemType.MAIN:
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">
			<polygon points="24,4 42,20 34,42 14,42 6,20" fill="%s" stroke="%s" stroke-width="2.5" stroke-linejoin="round"/>
			<polygon points="24,9 35,21 29,37 19,37 13,21" fill="%s" fill-opacity="0.45"/>
			<circle cx="18" cy="17" r="3" fill="#ffffff" fill-opacity="0.85"/>
			</svg>""" % [fill_hex, dark_hex, light_hex]
		_:
			svg = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">
			<circle cx="24" cy="24" r="18" fill="%s" stroke="%s" stroke-width="2.5"/>
			<circle cx="24" cy="24" r="11" fill="%s" fill-opacity="0.45"/>
			<circle cx="17" cy="17" r="3.2" fill="#ffffff" fill-opacity="0.85"/>
			</svg>""" % [fill_hex, dark_hex, light_hex]
	return _from_svg(key, svg, 1.5)

static func get_icon(icon_name: String) -> Texture2D:
	if icon_name in ["acorn_barrage", "fireball_berry", "frost_nova", "honey_slam", "whisker_lightning", "petal_cyclone", "starlight_orb", "boomerang_bone", "meteor_pine", "spirit_bees"]:
		return get_skill_icon(icon_name)
	return get_ui_icon(icon_name)

static func get_ui_icon(icon_name: String) -> Texture2D:
	var key: String = "ui_" + icon_name
	if _cache.has(key):
		return _cache[key]
	var inner: String = ""
	match icon_name:
		"paw_prism_crest":
			inner = """<ellipse cx="12" cy="19" rx="4" ry="5.5" transform="rotate(-18 12 19)" fill="#fff2d6"/><ellipse cx="20" cy="13" rx="4" ry="5.5" transform="rotate(-5 20 13)" fill="#fff2d6"/><ellipse cx="28" cy="13" rx="4" ry="5.5" transform="rotate(5 28 13)" fill="#fff2d6"/><ellipse cx="36" cy="19" rx="4" ry="5.5" transform="rotate(18 36 19)" fill="#fff2d6"/><polygon points="24,19 34,30 24,42 14,30" fill="#5ce1e6" stroke="#ffd56b" stroke-width="2.5"/>"""
		"heart":
			inner = """<path d="M24,40 C10,30 6,21 9,14 C12,8 20,9 24,15 C28,9 36,8 39,14 C42,21 38,30 24,40 Z" fill="#ff4d6d" stroke="#5c1020" stroke-width="2"/>"""
		"dash_paw":
			inner = """<path d="M8,28 L20,28 M12,21 L22,21 M12,35 L22,35" stroke="#ffe175" stroke-width="3" stroke-linecap="round"/><circle cx="31" cy="28" r="8" fill="#ffd24a" stroke="#61420e" stroke-width="2"/>"""
		"prism_dust":
			inner = """<polygon points="24,6 38,24 24,42 10,24" fill="#63e8ff" stroke="#185a73" stroke-width="2"/><polygon points="24,11 32,24 24,37 16,24" fill="#c7f9ff" fill-opacity="0.7"/>"""
		"bag":
			inner = """<path d="M16,16 L32,16 L38,38 C38,41 35,42 24,42 C13,42 10,41 10,38 Z" fill="#b8783e" stroke="#361e0c" stroke-width="2"/><path d="M19,16 L18,9 L30,9 L29,16" fill="none" stroke="#ffd257" stroke-width="3"/><circle cx="24" cy="29" r="4.5" fill="#ffd257"/>"""
		"boss_crown":
			inner = """<polygon points="8,36 10,14 19,24 24,10 29,24 38,14 40,36" fill="#ffd24a" stroke="#69420a" stroke-width="2" stroke-linejoin="round"/><circle cx="24" cy="28" r="3.5" fill="#ff4757"/>"""
		"skull":
			inner = """<circle cx="24" cy="22" r="14" fill="#f0e8dc" stroke="#332b28" stroke-width="2"/><rect x="17" y="32" width="14" height="8" rx="2" fill="#f0e8dc" stroke="#332b28" stroke-width="2"/><circle cx="19" cy="22" r="3.2" fill="#2b2124"/><circle cx="29" cy="22" r="3.2" fill="#2b2124"/>"""
		"sun_meadow":
			inner = """<circle cx="24" cy="24" r="10" fill="#ffd84f" stroke="#a66f12" stroke-width="2"/><path d="M24,6 L24,11 M24,37 L24,42 M6,24 L11,24 M37,24 L42,24 M11,11 L15,15 M33,33 L37,37 M37,11 L33,15 M15,33 L11,37" stroke="#ffd84f" stroke-width="3" stroke-linecap="round"/>"""
		"sunset":
			inner = """<path d="M10,32 Q24,14 38,32 Z" fill="#ff9442" stroke="#85300c" stroke-width="2"/><line x1="6" y1="34" x2="42" y2="34" stroke="#ffd26b" stroke-width="3" stroke-linecap="round"/>"""
		"moon_twilight":
			inner = """<path d="M30,10 C18,12 12,24 18,34 C23,41 34,41 38,35 C29,36 23,28 24,19 C25,15 27,12 30,10 Z" fill="#b8d0ff" stroke="#344573" stroke-width="2"/><circle cx="34" cy="16" r="2.5" fill="#fff29e"/>"""
		"sound_on":
			inner = """<polygon points="10,19 18,19 28,11 28,37 18,29 10,29" fill="#f5ebd6" stroke="#2d221c" stroke-width="2" stroke-linejoin="round"/><path d="M33,17 Q38,24 33,31 M37,13 Q44,24 37,35" fill="none" stroke="#8ee69c" stroke-width="2.5" stroke-linecap="round"/>"""
		"sound_off":
			inner = """<polygon points="10,19 18,19 28,11 28,37 18,29 10,29" fill="#9c948c" stroke="#2d221c" stroke-width="2" stroke-linejoin="round"/><path d="M32,18 L40,30 M40,18 L32,30" stroke="#ff6b6b" stroke-width="3" stroke-linecap="round"/>"""
		"pause":
			inner = """<rect x="13" y="11" width="8" height="26" rx="3" fill="#f5ebd6" stroke="#2d221c" stroke-width="2"/><rect x="27" y="11" width="8" height="26" rx="3" fill="#f5ebd6" stroke="#2d221c" stroke-width="2"/>"""
		"craft_recolor":
			inner = """<circle cx="18" cy="18" r="8" fill="#ff5e5b"/><circle cx="30" cy="18" r="8" fill="#52e070"/><circle cx="24" cy="30" r="8" fill="#57a3ff"/>"""
		"craft_link":
			inner = """<circle cx="14" cy="24" r="7" fill="none" stroke="#ffd24a" stroke-width="3"/><circle cx="34" cy="24" r="7" fill="none" stroke="#ffd24a" stroke-width="3"/><rect x="18" y="21" width="12" height="6" rx="2" fill="#ffe680"/>"""
		"craft_socket":
			inner = """<circle cx="24" cy="24" r="14" fill="#1e222e" stroke="#66e88a" stroke-width="3"/><path d="M24,15 L24,33 M15,24 L33,24" stroke="#a8ffc0" stroke-width="3.5" stroke-linecap="round"/>"""
		"salvage":
			inner = """<path d="M12,16 L36,16 L33,39 L15,39 Z" fill="#8c3b3b" stroke="#2b1212" stroke-width="2"/><path d="M10,16 L38,16 M20,11 L28,11" stroke="#ffd2b0" stroke-width="3" stroke-linecap="round"/>"""
		"star_upgrade":
			inner = """<polygon points="24,5 29,17 42,18 32,27 35,40 24,33 13,40 16,27 6,18 19,17" fill="#ffd64f" stroke="#7a510c" stroke-width="2" stroke-linejoin="round"/>"""
		_:
			inner = """<circle cx="24" cy="24" r="14" fill="#ffd56b" stroke="#594015" stroke-width="2"/>"""
	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">%s</svg>""" % inner
	return _from_svg(key, svg, 1.5)
