class_name GemInstance

static var _next_uid: int = 1

var uid: int = 0
var gem_id: String = ""
var level: int = 1
var xp: float = 0.0
var xp_to_next: float = 100.0

func _init(p_gem_id: String = "acorn_barrage", p_level: int = 1) -> void:
	uid = _next_uid
	_next_uid += 1
	gem_id = p_gem_id
	level = clampi(p_level, 1, 10)
	xp = 0.0
	xp_to_next = _calc_xp_req(level)

static func _calc_xp_req(lvl: int) -> float:
	return 85.0 * pow(1.42, float(lvl - 1))

func get_def() -> Dictionary:
	return GemDatabase.get_def(gem_id)

func get_gem_name() -> String:
	return String(get_def().get("gem_name", gem_id))

func get_short_label() -> String:
	return String(get_def().get("short", "GEM"))

func get_gem_type() -> int:
	return int(get_def().get("gem_type", GameEnums.GemType.ACTIVE))

func get_gem_color() -> int:
	return int(get_def().get("color", GameEnums.GemColor.WHITE))

func get_tags() -> Array:
	return get_def().get("tags", [])

func get_required_tags() -> Array:
	return get_def().get("required_tags", [])

func add_xp(amount: float) -> bool:
	if level >= 10:
		xp = 0.0
		return false
	xp += amount
	var leveled_up: bool = false
	while xp >= xp_to_next and level < 10:
		xp -= xp_to_next
		level += 1
		xp_to_next = _calc_xp_req(level)
		leveled_up = true
	if level >= 10:
		xp = 0.0
	return leveled_up

func get_salvage_dust() -> int:
	return 6 + (level - 1) * 5

func get_upgrade_dust_cost() -> int:
	return 14 + level * 10

func get_passive_stats(effective_level: int) -> Dictionary:
	var def: Dictionary = get_def()
	var base_stats: Dictionary = def.get("stats", {})
	var per_lvl: Dictionary = def.get("stats_per_lvl", {})
	var out: Dictionary = {}
	var lvl_bonus: float = float(maxi(0, effective_level - 1))
	for stat_key in base_stats.keys():
		var val: float = float(base_stats[stat_key]) + float(per_lvl.get(stat_key, 0.0)) * lvl_bonus
		out[int(stat_key)] = val
	return out

func get_tooltip_text(effective_level: int = -1) -> String:
	var eff_lvl: int = effective_level if effective_level > 0 else level
	var def: Dictionary = get_def()
	var header: String = "%s (Lv.%d" % [get_gem_name(), level]
	if eff_lvl > level:
		header += " +%d" % (eff_lvl - level)
	header += ") [%s]" % GameEnums.gem_type_label(get_gem_type())
	var lines: Array[String] = [header]
	if get_gem_type() == GameEnums.GemType.ACTIVE:
		var tags_arr: Array = get_tags()
		var tag_strs: Array[String] = []
		for t in tags_arr:
			tag_strs.append(GameEnums.skill_tag_label(int(t)))
		lines.append("Tags: " + ", ".join(tag_strs))
		var base_dmg: float = float(def.get("base_damage", 10.0)) + float(def.get("damage_per_lvl", 2.0)) * float(eff_lvl - 1)
		lines.append("Base Dmg: %.0f | Cooldown: %.2fs" % [base_dmg, float(def.get("cooldown", 1.0))])
	elif get_gem_type() == GameEnums.GemType.SUPPORT:
		var req: Array = get_required_tags()
		if req.is_empty():
			lines.append("Links with: Any Active Skill")
		else:
			var r_strs: Array[String] = []
			for t in req:
				r_strs.append(GameEnums.skill_tag_label(int(t)))
			lines.append("Links with: " + " / ".join(r_strs))
	else:
		var pstats: Dictionary = get_passive_stats(eff_lvl)
		var p_strs: Array[String] = []
		for sk in pstats.keys():
			p_strs.append(GameEnums.format_stat(int(sk), float(pstats[sk])))
		if not p_strs.is_empty():
			lines.append(", ".join(p_strs))
	lines.append(String(def.get("desc", "")))
	if level < 10:
		lines.append("Gem XP: %d / %d" % [int(xp), int(xp_to_next)])
	else:
		lines.append("MAX LEVEL")
	return "\n".join(lines)
