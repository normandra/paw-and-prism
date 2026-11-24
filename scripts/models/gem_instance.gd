class_name GemInstance

static var _next_uid: int = 1

var uid: int = 0
var gem_id: String = ""

func _init(p_gem_id: String = "acorn_barrage") -> void:
	uid = _next_uid
	_next_uid += 1
	gem_id = p_gem_id

func get_def() -> Dictionary:
	return GemDatabase.get_def(gem_id)

func get_gem_name() -> String:
	return String(get_def().get("gem_name", gem_id))

func get_short_label() -> String:
	return String(get_def().get("short", "GEM"))

func get_gem_type() -> int:
	return int(get_def().get("gem_type", GameEnums.GemType.MAIN))

func get_gem_color() -> int:
	return int(get_def().get("color", GameEnums.GemColor.WHITE))

func get_tags() -> Array:
	return get_def().get("tags", [])

func get_required_tags() -> Array:
	return get_def().get("required_tags", [])

func get_short_desc() -> String:
	return String(get_def().get("desc", ""))

func get_tooltip_text() -> String:
	var def: Dictionary = get_def()
	var lines: Array[String] = ["%s [%s]" % [get_gem_name(), GameEnums.gem_type_label(get_gem_type())]]
	if get_gem_type() == GameEnums.GemType.MAIN:
		var tags_arr: Array = get_tags()
		var tag_strs: Array[String] = []
		for t in tags_arr:
			tag_strs.append(GameEnums.skill_tag_label(int(t)))
		if not tag_strs.is_empty():
			lines.append("Tags: " + ", ".join(tag_strs))
	else:
		var req: Array = get_required_tags()
		if req.is_empty():
			lines.append("Links: Any Main Ability")
		else:
			var r_strs: Array[String] = []
			for t in req:
				r_strs.append(GameEnums.skill_tag_label(int(t)))
			lines.append("Links: " + " / ".join(r_strs))
	var d_txt: String = String(def.get("desc", ""))
	if not d_txt.is_empty():
		lines.append(d_txt)
	return "\n".join(lines)
