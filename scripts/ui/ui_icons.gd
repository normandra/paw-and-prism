class_name UiIcons

static var _cache: Dictionary = {}

static func _from_svg(key: String, svg_str: String, scale_factor: float = 2.0) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var img: Image = Image.new()
	var err: int = img.load_svg_from_string(svg_str, scale_factor)
	if err != OK or img.is_empty():
		img = Image.create_empty(48, 48, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.85, 0.35, 1.0))
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

static func get_hero_portrait(_hero_id: String = "shiba") -> Texture2D:
	var key: String = "hero_shiba"
	if _cache.has(key):
		return _cache[key]
	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
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
	return _from_svg(key, svg, 1.5)

static func get_card_art(card_id: String) -> Texture2D:
	var key: String = "card_" + card_id
	if _cache.has(key):
		return _cache[key]

	var bg_top: String = "#253028"
	var bg_bot: String = "#161a18"
	var inner: String = ""

	match card_id:
		# === 10 TEMPLATE CARDS ===
		"acorn_barrage":
			bg_top = "#2e4626"; bg_bot = "#1b2816"
			inner = """<circle cx="56" cy="18" r="14" fill="#ffd966" fill-opacity="0.16"/><ellipse cx="44" cy="31" rx="14" ry="16" transform="rotate(-24 44 31)" fill="#d6943c" stroke="#2d180a" stroke-width="2.5"/><path d="M29,18 Q43,6 58,15 L52,25 Q41,19 28,27 Z" fill="#6b3e1e" stroke="#2d180a" stroke-width="2.2"/><path d="M10,44 L22,36 M16,52 L28,44" stroke="#fff3a8" stroke-width="3.2" stroke-linecap="round"/><circle cx="24" cy="24" r="3" fill="#fff7c2"/>"""
		"starlight_orb":
			bg_top = "#182c4d"; bg_bot = "#10182b"
			inner = """<circle cx="40" cy="30" r="22" fill="none" stroke="#5ec7ff" stroke-width="2.5" stroke-dasharray="7 5"/><polygon points="40,7 46,22 61,25 46,31 40,46 34,31 19,25 34,22" fill="#92f0ff" stroke="#1e5780" stroke-width="2"/><circle cx="60" cy="43" r="6" fill="#ffe878" stroke="#8c6212" stroke-width="1.5"/><circle cx="19" cy="17" r="4" fill="#b8e6ff"/>"""
		"honey_slam":
			bg_top = "#4a3014"; bg_bot = "#261708"
			inner = """<ellipse cx="40" cy="48" rx="28" ry="8" fill="#ffbe33" fill-opacity="0.55" stroke="#ffe075" stroke-width="2.2"/><rect x="23" y="10" width="34" height="20" rx="5" fill="#f2a629" stroke="#422406" stroke-width="2.5"/><rect x="37" y="30" width="6" height="19" fill="#7a461e" stroke="#2b1708" stroke-width="1.5"/><circle cx="58" cy="26" r="4" fill="#ffe270"/>"""
		"whisker_lightning":
			bg_top = "#162d47"; bg_bot = "#0e1726"
			inner = """<circle cx="40" cy="30" r="24" fill="#4ad4ff" fill-opacity="0.14"/><polygon points="48,4 24,31 39,31 30,56 58,26 42,26" fill="#6be2ff" stroke="#143c59" stroke-width="2.2" stroke-linejoin="round"/><polygon points="45,10 30,29 41,29 34,47 51,28 40,28" fill="#fff8b8"/><path d="M12,18 L20,22 M60,42 L68,46" stroke="#9ef2ff" stroke-width="2.5" stroke-linecap="round"/>"""
		"petal_cyclone":
			bg_top = "#472138"; bg_bot = "#24111c"
			inner = """<path d="M18,30 A22,22 0 1,1 62,30" fill="none" stroke="#ffd1e8" stroke-width="2" stroke-dasharray="5 4"/><ellipse cx="40" cy="14" rx="7" ry="11" fill="#ff8fc0" stroke="#751c45" stroke-width="1.8"/><ellipse cx="56" cy="30" rx="11" ry="7" fill="#ffb8d9" stroke="#751c45" stroke-width="1.8"/><ellipse cx="40" cy="46" rx="7" ry="11" fill="#ff8fc0" stroke="#751c45" stroke-width="1.8"/><ellipse cx="24" cy="30" rx="11" ry="7" fill="#ffb8d9" stroke="#751c45" stroke-width="1.8"/><circle cx="40" cy="30" r="6" fill="#ffe57a"/>"""
		"fireball_berry":
			bg_top = "#4f1e14"; bg_bot = "#240c08"
			inner = """<circle cx="40" cy="34" r="22" fill="#ff742e" fill-opacity="0.22"/><path d="M40,5 C58,18 61,37 47,51 C37,57 23,52 22,38 C21,25 32,16 40,5 Z" fill="#ff6624" stroke="#5c1707" stroke-width="2.4"/><circle cx="39" cy="37" r="10" fill="#ffd24a"/><circle cx="37" cy="35" r="4.5" fill="#fff7b8"/>"""
		"frost_nova":
			bg_top = "#163b4a"; bg_bot = "#0c1d26"
			inner = """<path d="M40,7 L40,53 M17,18 L63,42 M63,18 L17,42" stroke="#8af0ff" stroke-width="4" stroke-linecap="round"/><polygon points="40,17 51,30 40,43 29,30" fill="#dffbff" stroke="#226680" stroke-width="2.2"/><circle cx="40" cy="30" r="4" fill="#ffffff"/>"""
		"boomerang_bone":
			bg_top = "#3e3324"; bg_bot = "#211b13"
			inner = """<path d="M16,22 C28,9 52,9 64,22" fill="none" stroke="#ffdf7a" stroke-width="3" stroke-dasharray="6 4"/><path d="M21,39 L58,24" stroke="#fff7e8" stroke-width="9" stroke-linecap="round"/><circle cx="19" cy="35" r="5" fill="#fff7e8" stroke="#6e5a44" stroke-width="1.5"/><circle cx="23" cy="43" r="5" fill="#fff7e8" stroke="#6e5a44" stroke-width="1.5"/><circle cx="57" cy="20" r="5" fill="#fff7e8" stroke="#6e5a44" stroke-width="1.5"/><circle cx="61" cy="28" r="5" fill="#fff7e8" stroke="#6e5a44" stroke-width="1.5"/>"""
		"meteor_pine":
			bg_top = "#4a2212"; bg_bot = "#210e08"
			inner = """<path d="M62,7 L39,30" stroke="#ff8229" stroke-width="11" stroke-linecap="round"/><ellipse cx="34" cy="37" rx="13" ry="16" transform="rotate(35 34 37)" fill="#b34419" stroke="#ffd257" stroke-width="2.5"/><ellipse cx="29" cy="49" rx="18" ry="4" fill="#ff9638" fill-opacity="0.45"/><circle cx="30" cy="40" r="6" fill="#ffe370"/>"""
		"spirit_bees":
			bg_top = "#263f26"; bg_bot = "#132114"
			inner = """<ellipse cx="33" cy="19" rx="10" ry="6" transform="rotate(-25 33 19)" fill="#d6f7ff"/><ellipse cx="47" cy="19" rx="10" ry="6" transform="rotate(25 47 19)" fill="#d6f7ff"/><ellipse cx="40" cy="34" rx="15" ry="11" fill="#ffd238" stroke="#36240c" stroke-width="2.4"/><rect x="33" y="24" width="4.5" height="20" fill="#36240c"/><rect x="43" y="24" width="4.5" height="20" fill="#36240c"/><circle cx="18" cy="41" r="4" fill="#ffe98a" fill-opacity="0.8"/>"""

		# === 24 ADD-ON CARDS ===
		"addon_multishot":
			bg_top = "#1f3d28"; bg_bot = "#102116"
			inner = """<path d="M16,30 L60,14 M16,30 L64,30 M16,30 L60,46" stroke="#6bff9c" stroke-width="3.5" stroke-linecap="round"/><polygon points="62,14 54,10 56,19" fill="#ffe878"/><polygon points="66,30 57,25 57,35" fill="#ffe878"/><polygon points="62,46 54,41 56,50" fill="#ffe878"/>"""
		"addon_chain":
			bg_top = "#1b334d"; bg_bot = "#101b29"
			inner = """<circle cx="18" cy="40" r="7" fill="#5ce1ff"/><circle cx="42" cy="16" r="7" fill="#5ce1ff"/><circle cx="62" cy="40" r="7" fill="#ffe46b"/><polyline points="18,40 31,26 42,16 53,27 62,40" fill="none" stroke="#9ef2ff" stroke-width="3.5" stroke-linejoin="round"/>"""
		"addon_fork":
			bg_top = "#213c29"; bg_bot = "#122116"
			inner = """<path d="M14,30 L36,30 L60,14 M36,30 L60,46" fill="none" stroke="#75f59e" stroke-width="4" stroke-linecap="round"/><circle cx="36" cy="30" r="6" fill="#ffd966"/>"""
		"addon_pierce":
			bg_top = "#223b2a"; bg_bot = "#111f16"
			inner = """<rect x="30" y="13" width="6" height="34" rx="2" fill="#9c8a78"/><rect x="46" y="13" width="6" height="34" rx="2" fill="#9c8a78"/><line x1="10" y1="30" x2="66" y2="30" stroke="#ffe166" stroke-width="4.5" stroke-linecap="round"/><polygon points="70,30 58,22 58,38" fill="#fff2a6"/>"""
		"addon_homing":
			bg_top = "#233642"; bg_bot = "#121c24"
			inner = """<circle cx="58" cy="24" r="11" fill="none" stroke="#ff7a7a" stroke-width="2.5"/><circle cx="58" cy="24" r="4" fill="#ff7a7a"/><path d="M14,44 Q32,48 40,30 T55,24" fill="none" stroke="#70f0ff" stroke-width="3.8" stroke-linecap="round"/>"""
		"addon_echo":
			bg_top = "#242c54"; bg_bot = "#141830"
			inner = """<polygon points="30,10 46,30 30,50 14,30" fill="#5ea4ff" fill-opacity="0.55" stroke="#a6ceff" stroke-width="2"/><polygon points="48,10 64,30 48,50 32,30" fill="#92d5ff" stroke="#ffffff" stroke-width="2.2"/>"""
		"addon_giant_blast":
			bg_top = "#283552"; bg_bot = "#141a2b"
			inner = """<circle cx="40" cy="30" r="23" fill="#5ce1ff" fill-opacity="0.22" stroke="#75e8ff" stroke-width="2.8" stroke-dasharray="6 4"/><circle cx="40" cy="30" r="10" fill="#ffd966"/><path d="M40,9 L40,16 M40,44 L40,51 M19,30 L26,30 M54,30 L61,30" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/>"""
		"addon_ignite":
			bg_top = "#4c2012"; bg_bot = "#240d07"
			inner = """<path d="M40,7 C55,20 57,38 45,50 C34,56 24,49 24,37 C24,25 34,18 40,7 Z" fill="#ff6624"/><path d="M40,21 C47,29 48,39 41,46 C35,49 30,44 31,37 C32,30 36,26 40,21 Z" fill="#ffe166"/>"""
		"addon_chill":
			bg_top = "#183e4f"; bg_bot = "#0c2029"
			inner = """<path d="M40,8 L40,52 M20,19 L60,41 M60,19 L20,41" stroke="#9ef5ff" stroke-width="3.5" stroke-linecap="round"/><circle cx="40" cy="30" r="9" fill="#5cd6ff" stroke="#ffffff" stroke-width="2"/>"""
		"addon_leech":
			bg_top = "#451924"; bg_bot = "#210b11"
			inner = """<path d="M40,50 C20,37 14,25 19,16 C23,8 34,10 40,18 C46,10 57,8 61,16 C66,25 60,37 40,50 Z" fill="#ff4d6d" stroke="#ffd2dc" stroke-width="2.2"/><path d="M40,21 L40,37 M32,29 L48,29" stroke="#ffffff" stroke-width="3.2" stroke-linecap="round"/>"""
		"addon_sniper_focus":
			bg_top = "#3f2e16"; bg_bot = "#1f170a"
			inner = """<circle cx="40" cy="30" r="19" fill="none" stroke="#ffd257" stroke-width="2.5"/><path d="M40,6 L40,18 M40,42 L40,54 M16,30 L28,30 M52,30 L64,30" stroke="#ffd257" stroke-width="2.8" stroke-linecap="round"/><circle cx="40" cy="30" r="5" fill="#ff5e5b"/>"""
		"addon_short_barrage":
			bg_top = "#244225"; bg_bot = "#122112"
			inner = """<line x1="16" y1="16" x2="36" y2="21" stroke="#8eff9a" stroke-width="3.5" stroke-linecap="round"/><line x1="14" y1="26" x2="40" y2="26" stroke="#8eff9a" stroke-width="3.5" stroke-linecap="round"/><line x1="14" y1="35" x2="40" y2="35" stroke="#8eff9a" stroke-width="3.5" stroke-linecap="round"/><line x1="16" y1="45" x2="36" y2="40" stroke="#8eff9a" stroke-width="3.5" stroke-linecap="round"/><line x1="50" y1="11" x2="50" y2="49" stroke="#ff7a5c" stroke-width="3.5" stroke-dasharray="5 4"/>"""
		"addon_glass_spark":
			bg_top = "#4a1920"; bg_bot = "#240a0e"
			inner = """<polygon points="40,7 58,30 40,53 22,30" fill="#ff5e78" fill-opacity="0.85" stroke="#ffd6e0" stroke-width="2.4"/><polyline points="35,14 43,27 33,36 41,47" fill="none" stroke="#fff7b8" stroke-width="2.6"/>"""
		"addon_ember_corpse":
			bg_top = "#4a2414"; bg_bot = "#210f08"
			inner = """<circle cx="40" cy="31" r="17" fill="#ff6e2b" fill-opacity="0.35"/><circle cx="40" cy="31" r="9" fill="#ffb84d"/><path d="M40,8 L43,20 M60,18 L50,25 M62,40 L50,36 M40,53 L39,42 M18,40 L29,35 M20,18 L31,24" stroke="#ff823a" stroke-width="3" stroke-linecap="round"/>"""
		"addon_frost_shatter":
			bg_top = "#183e52"; bg_bot = "#0b1e29"
			inner = """<polygon points="40,8 48,22 36,26" fill="#a8f6ff"/><polygon points="62,25 48,33 45,22" fill="#70e4ff"/><polygon points="48,51 39,38 51,36" fill="#a8f6ff"/><polygon points="20,40 31,32 33,43" fill="#70e4ff"/><circle cx="40" cy="30" r="6" fill="#ffffff"/>"""
		"addon_gravity_pull":
			bg_top = "#2b204d"; bg_bot = "#150f29"
			inner = """<circle cx="40" cy="30" r="9" fill="#9c75ff" stroke="#e2d1ff" stroke-width="2"/><path d="M18,16 L30,24 M62,16 L50,24 M18,44 L30,36 M62,44 L50,36" stroke="#d0b8ff" stroke-width="3" stroke-linecap="round"/>"""
		"addon_ricochet":
			bg_top = "#1f3747"; bg_bot = "#101c26"
			inner = """<rect x="60" y="9" width="6" height="42" rx="2" fill="#ffd257"/><polyline points="16,44 60,29 22,14" fill="none" stroke="#75f0ff" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"/><polygon points="18,13 28,11 25,21" fill="#75f0ff"/>"""
		"addon_nova_ring":
			bg_top = "#4f2512"; bg_bot = "#261006"
			inner = """<circle cx="40" cy="30" r="8" fill="#ffe166"/><path d="M40,7 L40,17 M56,14 L49,21 M63,30 L53,30 M56,46 L49,39 M40,53 L40,43 M24,46 L31,39 M17,30 L27,30 M24,14 L31,21" stroke="#ff9640" stroke-width="3.5" stroke-linecap="round"/>"""
		"addon_cadence_burst":
			bg_top = "#203b4a"; bg_bot = "#101e26"
			inner = """<circle cx="19" cy="32" r="5" fill="#7094a8"/><circle cx="32" cy="32" r="5" fill="#7094a8"/><circle cx="45" cy="32" r="5" fill="#7094a8"/><polygon points="60,13 64,25 76,26 66,34 69,46 60,39 51,46 54,34 44,26 56,25" fill="#ffe159" stroke="#ffffff" stroke-width="1.5"/>"""
		"addon_overclock":
			bg_top = "#453719"; bg_bot = "#21190b"
			inner = """<circle cx="40" cy="30" r="19" fill="#2b2112" stroke="#ffd257" stroke-width="3"/><polygon points="44,15 33,31 41,31 37,45 50,27 42,27" fill="#78f2ff"/><circle cx="40" cy="30" r="23" fill="none" stroke="#ffd257" stroke-width="1.5" stroke-dasharray="4 4"/>"""
		"addon_zoomies":
			bg_top = "#1d422d"; bg_bot = "#0e2117"
			inner = """<path d="M12,24 L36,24 M18,32 L44,32 M12,40 L36,40" stroke="#78ff9b" stroke-width="3.5" stroke-linecap="round"/><ellipse cx="52" cy="33" rx="9" ry="7" fill="#ffd966"/><circle cx="45" cy="21" r="3" fill="#ffd966"/><circle cx="52" cy="18" r="3" fill="#ffd966"/><circle cx="59" cy="21" r="3" fill="#ffd966"/>"""
		"addon_thorns":
			bg_top = "#3d281a"; bg_bot = "#1f130c"
			inner = """<circle cx="40" cy="30" r="14" fill="none" stroke="#f28c4b" stroke-width="4"/><polygon points="40,6 44,16 36,16" fill="#ffd27d"/><polygon points="63,28 54,33 54,24" fill="#ffd27d"/><polygon points="40,54 36,44 44,44" fill="#ffd27d"/><polygon points="17,28 26,24 26,33" fill="#ffd27d"/>"""
		"addon_orbit_shield":
			bg_top = "#1f3554"; bg_bot = "#101a2b"
			inner = """<path d="M40,10 L56,17 L56,31 C56,42 40,50 40,50 C40,50 24,42 24,31 L24,17 Z" fill="#4aa8ff" stroke="#d1eeff" stroke-width="2.4"/><polygon points="40,19 43,27 51,28 45,33 46,41 40,37 34,41 35,33 29,28 37,27" fill="#ffe46b"/>"""
		"addon_nine_lives":
			bg_top = "#4d2f14"; bg_bot = "#261608"
			inner = """<path d="M26,40 Q40,10 54,40 Z" fill="#ffd24a" stroke="#75490e" stroke-width="2.4"/><circle cx="40" cy="43" r="5" fill="#fff2a6"/><path d="M40,21 C34,15 28,20 31,26 L40,34 L49,26 C52,20 46,15 40,21 Z" fill="#ff5470"/>"""
		_:
			inner = """<polygon points="40,8 58,30 40,52 22,30" fill="#ffd56b" stroke="#6b4b12" stroke-width="2"/>"""

	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="80" height="60" viewBox="0 0 80 60">
	<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0%%" stop-color="%s"/><stop offset="100%%" stop-color="%s"/></linearGradient></defs>
	<rect x="0" y="0" width="80" height="60" rx="6" fill="url(#g)"/>
	%s
	</svg>""" % [bg_top, bg_bot, inner]
	return _from_svg(key, svg, 2.0)

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
		"deck_cards", "bag":
			inner = """<rect x="10" y="13" width="17" height="24" rx="3" transform="rotate(-10 18 25)" fill="#4d73b8" stroke="#f7cf57" stroke-width="2"/><rect x="20" y="11" width="17" height="24" rx="3" transform="rotate(8 28 23)" fill="#2d4c7a" stroke="#ffd966" stroke-width="2"/><polygon points="28,17 33,23 28,29 23,23" fill="#ffe878"/>"""
		"anvil_forge":
			inner = """<path d="M9,22 L38,22 L34,30 L29,30 L33,39 L15,39 L19,30 L12,30 Z" fill="#8290a6" stroke="#232833" stroke-width="2" stroke-linejoin="round"/><polygon points="25,6 28,13 35,14 29,18 31,24 25,20 19,24 21,18 15,14 22,13" fill="#ffd957"/>"""
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
		"salvage":
			inner = """<path d="M12,16 L36,16 L33,39 L15,39 Z" fill="#8c3b3b" stroke="#2b1212" stroke-width="2"/><path d="M10,16 L38,16 M20,11 L28,11" stroke="#ffd2b0" stroke-width="3" stroke-linecap="round"/>"""
		"star_upgrade":
			inner = """<polygon points="24,5 29,17 42,18 32,27 35,40 24,33 13,40 16,27 6,18 19,17" fill="#ffd64f" stroke="#7a510c" stroke-width="2" stroke-linejoin="round"/>"""
		_:
			inner = """<circle cx="24" cy="24" r="14" fill="#ffd56b" stroke="#594015" stroke-width="2"/>"""
	var svg: String = """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">%s</svg>""" % inner
	return _from_svg(key, svg, 1.5)
