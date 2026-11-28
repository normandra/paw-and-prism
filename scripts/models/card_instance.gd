class_name CardInstance

static var _next_uid: int = 1

var uid: int = 0
var card_id: String = "acorn_barrage"
var card_kind: int = GameEnums.CardKind.TEMPLATE
var rarity: int = GameEnums.Rarity.COMMON
var forged_addons: Array[String] = []

func _init(p_card_id: String = "acorn_barrage", p_rarity: int = -1) -> void:
	uid = _next_uid
	_next_uid += 1
	card_id = p_card_id
	var def: Dictionary = get_def()
	card_kind = int(def.get("card_kind", GameEnums.CardKind.TEMPLATE))
	if p_rarity >= 0:
		rarity = p_rarity
	elif def.has("rarity"):
		rarity = int(def["rarity"])
	else:
		rarity = GameEnums.Rarity.COMMON
	forged_addons.clear()

static func generate_template(elapsed_sec: float, rng: RandomNumberGenerator, forced_rarity: int = -1, forced_id: String = "") -> CardInstance:
	var cid: String = CardDatabase.roll_template_id(rng, forced_id)
	var rar: int = forced_rarity if forced_rarity >= 0 else CardDatabase.roll_template_rarity(elapsed_sec, rng)
	return CardInstance.new(cid, rar)

static func generate_addon(elapsed_sec: float, rng: RandomNumberGenerator, min_rarity: int = -1, forced_id: String = "") -> CardInstance:
	var cid: String = CardDatabase.roll_addon_id(elapsed_sec, rng, min_rarity, forced_id)
	return CardInstance.new(cid)

func get_def() -> Dictionary:
	return CardDatabase.get_def(card_id)

func is_template() -> bool:
	return card_kind == GameEnums.CardKind.TEMPLATE

func is_addon() -> bool:
	return card_kind == GameEnums.CardKind.ADDON

func get_card_name() -> String:
	return String(get_def().get("card_name", card_id))

func get_display_title() -> String:
	var n: String = get_card_name()
	if is_template() and not forged_addons.is_empty():
		return "%s +%d" % [n, forged_addons.size()]
	return n

func get_short_label() -> String:
	return String(get_def().get("short", card_id.substr(0, 4).to_upper()))

func get_category() -> int:
	return int(get_def().get("category", GameEnums.CardCategory.ATTACK))

func get_tags() -> Array:
	return get_def().get("tags", [])

func get_desc() -> String:
	return String(get_def().get("desc", ""))

func get_max_forges() -> int:
	if not is_template():
		return 0
	return GameEnums.rarity_forge_limit(rarity)

func get_forge_count() -> int:
	return forged_addons.size()

func get_remaining_forges() -> int:
	return maxi(0, get_max_forges() - forged_addons.size())

func is_forge_full() -> bool:
	return forged_addons.size() >= get_max_forges()

func get_addon_stack_count(addon_id: String) -> int:
	var count: int = 0
	for aid in forged_addons:
		if aid == addon_id:
			count += 1
	return count

func can_accept_addon(addon_card: CardInstance) -> Dictionary:
	if not is_template():
		return {"ok": false, "reason": "Only Template Cards can be forged"}
	if addon_card == null or not addon_card.is_addon():
		return {"ok": false, "reason": "Select an Add-on Card first"}
	if is_forge_full():
		return {"ok": false, "reason": "Forge Limit (%d/%d)" % [get_forge_count(), get_max_forges()]}
	if not CardDatabase.does_addon_apply(addon_card.card_id, card_id):
		return {"ok": false, "reason": "Requires %s" % CardDatabase.get_compatibility_text(addon_card.card_id)}
	return {"ok": true, "reason": "Forge (%d/%d -> %d/%d)" % [get_forge_count(), get_max_forges(), get_forge_count() + 1, get_max_forges()]}

func apply_forge(addon_id: String) -> bool:
	if not is_template() or is_forge_full():
		return false
	if not CardDatabase.does_addon_apply(addon_id, card_id):
		return false
	forged_addons.append(addon_id)
	return true

func get_forged_summary_counts() -> Array[Dictionary]:
	var order: Array[String] = []
	var counts: Dictionary = {}
	for aid in forged_addons:
		if not counts.has(aid):
			counts[aid] = 0
			order.append(aid)
		counts[aid] = int(counts[aid]) + 1
	var out: Array[Dictionary] = []
	for aid in order:
		var adef: Dictionary = CardDatabase.get_def(aid)
		out.append({
			"id": aid,
			"name": String(adef.get("card_name", aid)),
			"short": String(adef.get("short", aid.to_upper())),
			"count": int(counts[aid]),
			"rarity": int(adef.get("rarity", GameEnums.Rarity.COMMON)),
		})
	return out

func get_forged_summary_text() -> String:
	var parts: PackedStringArray = []
	for entry in get_forged_summary_counts():
		var cnt: int = int(entry["count"])
		parts.append("%s%s" % [String(entry["name"]), (" x%d" % cnt) if cnt > 1 else ""])
	return ", ".join(parts)
