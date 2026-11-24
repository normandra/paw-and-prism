class_name ItemInstance

static var _next_uid: int = 1

var uid: int = 0
var item_name: String = "Starter Gear"
var equip_slot: int = GameEnums.EquipSlot.WEAPON
var rarity: int = GameEnums.Rarity.COMMON
var visual_style: String = "acorn_wand"
var effects: Array[String] = [] # Behavioral global effect IDs
var unique_id: String = ""

var socket_colors: Array[int] = []
var links: Array[bool] = [] # size = max(0, socket_colors.size() - 1)
var socketed_gems: Array = [] # Array of GemInstance or null

func _init() -> void:
	uid = _next_uid
	_next_uid += 1

func setup_sockets(colors: Array[int], link_flags: Array[bool]) -> void:
	socket_colors = colors.duplicate()
	links = []
	socketed_gems = []
	var count: int = socket_colors.size()
	for i in range(count):
		socketed_gems.append(null)
		if i < count - 1:
			var is_linked: bool = link_flags[i] if i < link_flags.size() else false
			links.append(is_linked)

func get_socket_count() -> int:
	return socket_colors.size()

func get_max_sockets() -> int:
	return GameEnums.slot_max_sockets(equip_slot)

func can_socket(socket_idx: int, gem: GemInstance) -> bool:
	if gem == null:
		return false
	if socket_idx < 0 or socket_idx >= socket_colors.size():
		return false
	var scolor: int = socket_colors[socket_idx]
	var gcolor: int = gem.get_gem_color()
	if scolor == GameEnums.GemColor.WHITE or gcolor == GameEnums.GemColor.WHITE:
		return true
	return scolor == gcolor

func insert_gem(socket_idx: int, gem: GemInstance) -> GemInstance:
	if not can_socket(socket_idx, gem):
		return null
	var previous: GemInstance = socketed_gems[socket_idx]
	socketed_gems[socket_idx] = gem
	return previous

func remove_gem(socket_idx: int) -> GemInstance:
	if socket_idx < 0 or socket_idx >= socketed_gems.size():
		return null
	var removed: GemInstance = socketed_gems[socket_idx]
	socketed_gems[socket_idx] = null
	return removed

func extract_all_gems() -> Array[GemInstance]:
	var out: Array[GemInstance] = []
	for i in range(socketed_gems.size()):
		if socketed_gems[i] != null:
			out.append(socketed_gems[i])
			socketed_gems[i] = null
	return out

func get_link_group_indices(socket_idx: int) -> Array[int]:
	var count: int = socket_colors.size()
	if socket_idx < 0 or socket_idx >= count:
		return []
	var start_idx: int = socket_idx
	while start_idx > 0 and links[start_idx - 1]:
		start_idx -= 1
	var end_idx: int = socket_idx
	while end_idx < count - 1 and links[end_idx]:
		end_idx += 1
	var group: Array[int] = []
	for i in range(start_idx, end_idx + 1):
		group.append(i)
	return group

func get_link_groups() -> Array:
	var groups: Array = []
	var visited: Dictionary = {}
	for i in range(socket_colors.size()):
		if visited.has(i):
			continue
		var g: Array[int] = get_link_group_indices(i)
		for idx in g:
			visited[idx] = true
		groups.append(g)
	return groups

func get_effect_tags() -> Array[String]:
	var out: Array[String] = []
	for eid in effects:
		var edef: Dictionary = ItemDatabase.get_effect_def(eid)
		out.append(String(edef.get("tag", eid)))
	return out

func get_socket_summary_text() -> String:
	var s: String = ""
	for i in range(socket_colors.size()):
		var letter: String = GameEnums.gem_color_letter(socket_colors[i])
		var filled: String = "*" if (i < socketed_gems.size() and socketed_gems[i] != null) else ""
		s += "(%s%s)" % [letter, filled]
		if i < links.size():
			s += "===" if links[i] else " "
	return s

func get_tooltip_lines() -> Array[String]:
	var lines: Array[String] = []
	lines.append("%s [%s]" % [item_name, GameEnums.slot_label(equip_slot)])
	lines.append("%s | %s" % [GameEnums.rarity_label(rarity), get_socket_summary_text()])
	for tag in get_effect_tags():
		lines.append("• " + tag)
	return lines
