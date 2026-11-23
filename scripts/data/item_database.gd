class_name ItemDatabase

static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var _seeded: bool = false

static func _ensure_rng() -> void:
	if not _seeded:
		_rng.randomize()
		_seeded = true

static func _base_items_for_slot(slot: int) -> Array[Dictionary]:
	match slot:
		GameEnums.EquipSlot.WEAPON:
			return [
				{"name": "Acorn Wand", "style": "acorn_wand", "stat": GameEnums.StatType.FLAT_DAMAGE, "base": 4.0},
				{"name": "Honey Hammer", "style": "honey_hammer", "stat": GameEnums.StatType.DAMAGE_PCT, "base": 12.0},
				{"name": "Starlight Staff", "style": "star_staff", "stat": GameEnums.StatType.CAST_SPEED_PCT, "base": 10.0},
				{"name": "Paw Claws", "style": "paw_claws", "stat": GameEnums.StatType.CRIT_CHANCE, "base": 6.0},
			]
		GameEnums.EquipSlot.HELMET:
			return [
				{"name": "Sprout Hood", "style": "leaf_crown", "stat": GameEnums.StatType.MAX_HP, "base": 18.0},
				{"name": "Wizard Hat", "style": "wizard_hat", "stat": GameEnums.StatType.AREA_PCT, "base": 10.0},
				{"name": "Knight Cap", "style": "knight_helm", "stat": GameEnums.StatType.ARMOR, "base": 10.0},
				{"name": "Ribbon Hood", "style": "ribbon_hood", "stat": GameEnums.StatType.XP_GAIN_PCT, "base": 8.0},
			]
		GameEnums.EquipSlot.ARMOR:
			return [
				{"name": "Cozy Tunic", "style": "tunic", "stat": GameEnums.StatType.MAX_HP, "base": 28.0},
				{"name": "Bark Breastplate", "style": "plate", "stat": GameEnums.StatType.ARMOR, "base": 16.0},
				{"name": "Velvet Cloak", "style": "cloak", "stat": GameEnums.StatType.DMG_REDUCTION_PCT, "base": 4.0},
			]
		GameEnums.EquipSlot.BOOTS:
			return [
				{"name": "Soft Paw Slippers", "style": "boots", "stat": GameEnums.StatType.MOVE_SPEED_PCT, "base": 8.0},
				{"name": "Meadow Greaves", "style": "boots", "stat": GameEnums.StatType.MOVE_SPEED_PCT, "base": 10.0},
				{"name": "Cloud Treads", "style": "boots", "stat": GameEnums.StatType.PICKUP_RADIUS_PCT, "base": 18.0},
			]
		GameEnums.EquipSlot.AMULET:
			return [
				{"name": "Acorn Pendant", "style": "amulet", "stat": GameEnums.StatType.HP_REGEN, "base": 1.6},
				{"name": "Silver Bell Charm", "style": "amulet", "stat": GameEnums.StatType.CRIT_MULT, "base": 20.0},
				{"name": "Prism Locket", "style": "amulet", "stat": GameEnums.StatType.MAGIC_FIND_PCT, "base": 16.0},
			]
		GameEnums.EquipSlot.RING:
			return [
				{"name": "Clover Ring", "style": "ring", "stat": GameEnums.StatType.CAST_SPEED_PCT, "base": 7.0},
				{"name": "Amber Band", "style": "ring", "stat": GameEnums.StatType.DAMAGE_PCT, "base": 10.0},
				{"name": "Dewdrop Signet", "style": "ring", "stat": GameEnums.StatType.LIFE_ON_HIT, "base": 1.2},
			]
	return [{"name": "Charm", "style": "ring", "stat": GameEnums.StatType.DAMAGE_PCT, "base": 8.0}]

static func _affix_pool_for_slot(slot: int) -> Array[Dictionary]:
	var common_pool: Array[Dictionary] = [
		{"prefix": "Sturdy", "suffix": "of the Bear", "stat": GameEnums.StatType.MAX_HP, "min": 14.0, "max": 26.0, "per_ilvl": 4.5},
		{"prefix": "Fierce", "suffix": "of Ferocity", "stat": GameEnums.StatType.DAMAGE_PCT, "min": 8.0, "max": 16.0, "per_ilvl": 2.4},
		{"prefix": "Nimble", "suffix": "of Alacrity", "stat": GameEnums.StatType.CAST_SPEED_PCT, "min": 6.0, "max": 12.0, "per_ilvl": 1.6},
		{"prefix": "Lucky", "suffix": "of Treasure", "stat": GameEnums.StatType.MAGIC_FIND_PCT, "min": 8.0, "max": 18.0, "per_ilvl": 2.0},
		{"prefix": "Clever", "suffix": "of Wisdom", "stat": GameEnums.StatType.XP_GAIN_PCT, "min": 6.0, "max": 14.0, "per_ilvl": 1.5},
		{"prefix": "Keen", "suffix": "of Precision", "stat": GameEnums.StatType.CRIT_CHANCE, "min": 4.0, "max": 8.0, "per_ilvl": 0.9},
	]
	match slot:
		GameEnums.EquipSlot.WEAPON:
			common_pool.append({"prefix": "Sharp", "suffix": "of Power", "stat": GameEnums.StatType.FLAT_DAMAGE, "min": 3.0, "max": 6.0, "per_ilvl": 1.4})
			common_pool.append({"prefix": "Deadly", "suffix": "of Carnage", "stat": GameEnums.StatType.CRIT_MULT, "min": 16.0, "max": 28.0, "per_ilvl": 3.5})
			common_pool.append({"prefix": "Volley", "suffix": "of Splitting", "stat": GameEnums.StatType.PROJ_SPEED_PCT, "min": 10.0, "max": 18.0, "per_ilvl": 1.8})
			common_pool.append({"prefix": "Leeching", "suffix": "of Fangs", "stat": GameEnums.StatType.LIFE_ON_HIT, "min": 1.0, "max": 2.2, "per_ilvl": 0.35})
		GameEnums.EquipSlot.HELMET:
			common_pool.append({"prefix": "Radiant", "suffix": "of Expansion", "stat": GameEnums.StatType.AREA_PCT, "min": 8.0, "max": 15.0, "per_ilvl": 1.8})
			common_pool.append({"prefix": "Armored", "suffix": "of Iron", "stat": GameEnums.StatType.ARMOR, "min": 8.0, "max": 14.0, "per_ilvl": 2.2})
			common_pool.append({"prefix": "Magnet", "suffix": "of Gathering", "stat": GameEnums.StatType.PICKUP_RADIUS_PCT, "min": 14.0, "max": 24.0, "per_ilvl": 2.5})
		GameEnums.EquipSlot.ARMOR:
			common_pool.append({"prefix": "Plated", "suffix": "of the Turtle", "stat": GameEnums.StatType.ARMOR, "min": 10.0, "max": 18.0, "per_ilvl": 2.8})
			common_pool.append({"prefix": "Guardian's", "suffix": "of Warding", "stat": GameEnums.StatType.DMG_REDUCTION_PCT, "min": 3.0, "max": 6.0, "per_ilvl": 0.6})
			common_pool.append({"prefix": "Soothing", "suffix": "of Renewal", "stat": GameEnums.StatType.HP_REGEN, "min": 1.4, "max": 2.6, "per_ilvl": 0.4})
		GameEnums.EquipSlot.BOOTS:
			common_pool.append({"prefix": "Fleet", "suffix": "of the Hare", "stat": GameEnums.StatType.MOVE_SPEED_PCT, "min": 7.0, "max": 13.0, "per_ilvl": 1.2})
			common_pool.append({"prefix": "Gathering", "suffix": "of Fetching", "stat": GameEnums.StatType.PICKUP_RADIUS_PCT, "min": 12.0, "max": 22.0, "per_ilvl": 2.5})
		GameEnums.EquipSlot.AMULET, GameEnums.EquipSlot.RING:
			common_pool.append({"prefix": "Mighty", "suffix": "of Impact", "stat": GameEnums.StatType.FLAT_DAMAGE, "min": 2.0, "max": 5.0, "per_ilvl": 0.9})
			common_pool.append({"prefix": "Wide", "suffix": "of Reach", "stat": GameEnums.StatType.AREA_PCT, "min": 8.0, "max": 16.0, "per_ilvl": 1.8})
			common_pool.append({"prefix": "Vibrant", "suffix": "of Vitality", "stat": GameEnums.StatType.HP_REGEN, "min": 1.2, "max": 2.4, "per_ilvl": 0.35})
	return common_pool

static func get_unique_templates() -> Array[Dictionary]:
	return [
		{
			"unique_id": "unique_acorn_scepter",
			"name": "Grand Acorn Scepter",
			"slot": GameEnums.EquipSlot.WEAPON,
			"style": "acorn_wand",
			"affixes": [
				{"stat": GameEnums.StatType.FLAT_DAMAGE, "value": 18.0},
				{"stat": GameEnums.StatType.DAMAGE_PCT, "value": 36.0},
				{"stat": GameEnums.StatType.EXTRA_PROJ, "value": 2.0},
				{"stat": GameEnums.StatType.CAST_SPEED_PCT, "value": 18.0},
			],
			"sockets": [GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE, GameEnums.GemColor.RED],
			"links": [true, true, true],
			"effect_desc": "+2 Extra Projectiles to all skills & guaranteed 4-Link!",
		},
		{
			"unique_id": "unique_prism_crown",
			"name": "Prismwhisker Crown",
			"slot": GameEnums.EquipSlot.HELMET,
			"style": "wizard_hat",
			"affixes": [
				{"stat": GameEnums.StatType.MAX_HP, "value": 65.0},
				{"stat": GameEnums.StatType.AREA_PCT, "value": 24.0},
				{"stat": GameEnums.StatType.MAGIC_FIND_PCT, "value": 35.0},
			],
			"sockets": [GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE],
			"links": [true, true],
			"effect_desc": "+1 Level to ALL socketed gems globally & 3 Linked White Sockets!",
		},
		{
			"unique_id": "unique_honey_aegis",
			"name": "Honeycomb Aegis",
			"slot": GameEnums.EquipSlot.ARMOR,
			"style": "plate",
			"affixes": [
				{"stat": GameEnums.StatType.MAX_HP, "value": 120.0},
				{"stat": GameEnums.StatType.ARMOR, "value": 45.0},
				{"stat": GameEnums.StatType.DMG_REDUCTION_PCT, "value": 14.0},
				{"stat": GameEnums.StatType.HP_REGEN, "value": 5.5},
			],
			"sockets": [GameEnums.GemColor.RED, GameEnums.GemColor.RED, GameEnums.GemColor.BLUE, GameEnums.GemColor.GREEN],
			"links": [true, true, true],
			"effect_desc": "Triggers a sticky Honey Nova when hit & 4-Link!",
		},
		{
			"unique_id": "unique_comet_paws",
			"name": "Paws of the Comet",
			"slot": GameEnums.EquipSlot.BOOTS,
			"style": "boots",
			"affixes": [
				{"stat": GameEnums.StatType.MOVE_SPEED_PCT, "value": 32.0},
				{"stat": GameEnums.StatType.CAST_SPEED_PCT, "value": 16.0},
				{"stat": GameEnums.StatType.PICKUP_RADIUS_PCT, "value": 40.0},
			],
			"sockets": [GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE],
			"links": [true, true],
			"effect_desc": "-35% Hop-Dash cooldown & blazing paw speed!",
		},
		{
			"unique_id": "unique_nine_lives",
			"name": "Nine-Lives Bell",
			"slot": GameEnums.EquipSlot.AMULET,
			"style": "amulet",
			"affixes": [
				{"stat": GameEnums.StatType.CRIT_CHANCE, "value": 20.0},
				{"stat": GameEnums.StatType.CRIT_MULT, "value": 55.0},
				{"stat": GameEnums.StatType.MAX_HP, "value": 45.0},
			],
			"sockets": [GameEnums.GemColor.WHITE, GameEnums.GemColor.BLUE],
			"links": [true],
			"effect_desc": "Once per 90s, prevents fatal damage and heals 55% HP!",
		},
		{
			"unique_id": "unique_starweaver",
			"name": "Starweaver Band",
			"slot": GameEnums.EquipSlot.RING,
			"style": "ring",
			"affixes": [
				{"stat": GameEnums.StatType.AREA_PCT, "value": 35.0},
				{"stat": GameEnums.StatType.CAST_SPEED_PCT, "value": 25.0},
				{"stat": GameEnums.StatType.DAMAGE_PCT, "value": 24.0},
			],
			"sockets": [GameEnums.GemColor.BLUE, GameEnums.GemColor.GREEN],
			"links": [true],
			"effect_desc": "Expands spell & melee orbits across the meadow!",
		},
		{
			"unique_id": "unique_brambleclaw",
			"name": "Brambleclaw Gauntlets",
			"slot": GameEnums.EquipSlot.WEAPON,
			"style": "paw_claws",
			"affixes": [
				{"stat": GameEnums.StatType.FLAT_DAMAGE, "value": 24.0},
				{"stat": GameEnums.StatType.LIFE_ON_HIT, "value": 5.5},
				{"stat": GameEnums.StatType.CRIT_CHANCE, "value": 15.0},
				{"stat": GameEnums.StatType.DAMAGE_PCT, "value": 28.0},
			],
			"sockets": [GameEnums.GemColor.RED, GameEnums.GemColor.RED, GameEnums.GemColor.GREEN, GameEnums.GemColor.WHITE],
			"links": [true, true, true],
			"effect_desc": "Massive flat claws + vampiric sustain & 4-Link!",
		},
		{
			"unique_id": "unique_clover_loop",
			"name": "Twilight Clover Loop",
			"slot": GameEnums.EquipSlot.RING,
			"style": "ring",
			"affixes": [
				{"stat": GameEnums.StatType.MAGIC_FIND_PCT, "value": 60.0},
				{"stat": GameEnums.StatType.XP_GAIN_PCT, "value": 30.0},
				{"stat": GameEnums.StatType.PICKUP_RADIUS_PCT, "value": 50.0},
			],
			"sockets": [GameEnums.GemColor.WHITE, GameEnums.GemColor.GREEN],
			"links": [true],
			"effect_desc": "Showers the run in loot & rapid XP leveling!",
		},
	]

static func create_unique_item(unique_id: String, item_level: int = 10) -> ItemInstance:
	for tpl in get_unique_templates():
		if String(tpl["unique_id"]) == unique_id:
			return _build_unique_from_template(tpl, item_level)
	return _build_unique_from_template(get_unique_templates()[0], item_level)

static func _build_unique_from_template(tpl: Dictionary, item_level: int) -> ItemInstance:
	var item: ItemInstance = ItemInstance.new()
	item.item_name = String(tpl["name"])
	item.equip_slot = int(tpl["slot"])
	item.rarity = GameEnums.Rarity.UNIQUE
	item.item_level = maxi(1, item_level)
	item.visual_style = String(tpl["style"])
	item.unique_id = String(tpl["unique_id"])
	item.unique_effect_desc = String(tpl["effect_desc"])
	var scale_mult: float = 1.0 + float(maxi(0, item_level - 1)) * 0.035
	var affs: Array[Dictionary] = []
	for a in tpl["affixes"]:
		var st: int = int(a["stat"])
		var base_v: float = float(a["value"])
		var val: float = base_v if st == GameEnums.StatType.EXTRA_PROJ else snappedf(base_v * scale_mult, 0.1)
		affs.append({"stat": st, "value": val})
	item.affixes = affs
	var scols: Array[int] = []
	for c in tpl["sockets"]:
		scols.append(int(c))
	var lnks: Array[bool] = []
	for l in tpl["links"]:
		lnks.append(bool(l))
	item.setup_sockets(scols, lnks)
	return item

static func generate_item(item_level: int, forced_rarity: int = -1, magic_find: float = 0.0, forced_slot: int = -1, rng_override: RandomNumberGenerator = null) -> ItemInstance:
	_ensure_rng()
	var rng: RandomNumberGenerator = rng_override if rng_override != null else _rng
	var ilvl: int = clampi(item_level, 1, 25)

	var rarity: int = forced_rarity
	if rarity < 0:
		var mf_mult: float = 1.0 + maxf(0.0, magic_find) * 0.01
		var u_chance: float = clampf(0.04 * mf_mult, 0.04, 0.22)
		var r_chance: float = clampf(0.22 * mf_mult, 0.22, 0.45)
		var m_chance: float = 0.44
		var roll: float = rng.randf()
		if roll < u_chance:
			rarity = GameEnums.Rarity.UNIQUE
		elif roll < u_chance + r_chance:
			rarity = GameEnums.Rarity.RARE
		elif roll < u_chance + r_chance + m_chance:
			rarity = GameEnums.Rarity.MAGIC
		else:
			rarity = GameEnums.Rarity.COMMON

	if rarity == GameEnums.Rarity.UNIQUE:
		var uniques: Array[Dictionary] = get_unique_templates()
		if forced_slot >= 0:
			var slot_uniques: Array[Dictionary] = []
			for u in uniques:
				if int(u["slot"]) == forced_slot:
					slot_uniques.append(u)
			if not slot_uniques.is_empty():
				return _build_unique_from_template(slot_uniques[rng.randi() % slot_uniques.size()], ilvl)
		return _build_unique_from_template(uniques[rng.randi() % uniques.size()], ilvl)

	var slot: int = forced_slot if forced_slot >= 0 else rng.randi() % 6
	var bases: Array[Dictionary] = _base_items_for_slot(slot)
	var base_tpl: Dictionary = bases[rng.randi() % bases.size()]

	var item: ItemInstance = ItemInstance.new()
	item.equip_slot = slot
	item.rarity = rarity
	item.item_level = ilvl
	item.visual_style = String(base_tpl["style"])

	# Implicit base stat
	var base_stat: int = int(base_tpl["stat"])
	var base_val: float = float(base_tpl["base"]) * (1.0 + float(ilvl - 1) * 0.14)
	item.affixes.append({"stat": base_stat, "value": snappedf(base_val, 0.1)})

	var num_affixes: int = 0
	match rarity:
		GameEnums.Rarity.COMMON:
			num_affixes = 0
		GameEnums.Rarity.MAGIC:
			num_affixes = rng.randi_range(1, 2)
		GameEnums.Rarity.RARE:
			num_affixes = rng.randi_range(3, 4)

	var pool: Array[Dictionary] = _affix_pool_for_slot(slot)
	var chosen_prefixes: Array[String] = []
	var chosen_suffixes: Array[String] = []
	var used_stats: Dictionary = {}

	for _i in range(num_affixes):
		var candidates: Array[Dictionary] = []
		for a in pool:
			if not used_stats.has(int(a["stat"])):
				candidates.append(a)
		if candidates.is_empty():
			candidates = pool
		var pick: Dictionary = candidates[rng.randi() % candidates.size()]
		var st: int = int(pick["stat"])
		used_stats[st] = true
		var raw_val: float = rng.randf_range(float(pick["min"]), float(pick["max"])) + float(pick["per_ilvl"]) * float(ilvl - 1)
		_merge_affix(item.affixes, st, snappedf(raw_val, 0.1))
		chosen_prefixes.append(String(pick["prefix"]))
		chosen_suffixes.append(String(pick["suffix"]))

	var base_name: String = String(base_tpl["name"])
	if rarity == GameEnums.Rarity.COMMON:
		item.item_name = base_name
	elif rarity == GameEnums.Rarity.MAGIC:
		var pref: String = chosen_prefixes[0] if not chosen_prefixes.is_empty() else "Blessed"
		if chosen_suffixes.size() > 1:
			item.item_name = "%s %s %s" % [pref, base_name, chosen_suffixes[1]]
		else:
			item.item_name = "%s %s" % [pref, base_name]
	else:
		var rare_adj: Array[String] = ["Star", "Honey", "Clover", "Moon", "Sun", "Whisker", "Bramble", "Glimmer", "Paw"]
		var rare_noun: Array[String] = ["Heart", "Song", "Ward", "Crest", "Boon", "Spark", "Fang", "Whisper", "Crown"]
		item.item_name = "%s%s %s" % [
			rare_adj[rng.randi() % rare_adj.size()],
			rare_noun[rng.randi() % rare_noun.size()].to_lower(),
			base_name,
		]

	# Roll PoE sockets & links
	var max_s: int = GameEnums.slot_max_sockets(slot)
	var min_s: int = 1
	if rarity == GameEnums.Rarity.MAGIC and max_s >= 2:
		min_s = 2
	elif rarity == GameEnums.Rarity.RARE:
		min_s = mini(max_s, 3 if max_s >= 3 else 2)
	if ilvl >= 10 and max_s >= 3 and rarity >= GameEnums.Rarity.MAGIC:
		min_s = maxi(min_s, 2)
	var socket_count: int = rng.randi_range(min_s, max_s)

	var colors: Array[int] = []
	for _s in range(socket_count):
		var c_roll: float = rng.randf()
		if c_roll < 0.05:
			colors.append(GameEnums.GemColor.WHITE)
		elif c_roll < 0.37:
			colors.append(GameEnums.GemColor.RED)
		elif c_roll < 0.69:
			colors.append(GameEnums.GemColor.GREEN)
		else:
			colors.append(GameEnums.GemColor.BLUE)

	var link_chance: float = 0.42 + float(rarity) * 0.14 + float(ilvl) * 0.015
	var link_flags: Array[bool] = []
	for _l in range(maxi(0, socket_count - 1)):
		link_flags.append(rng.randf() < clampf(link_chance, 0.35, 0.88))

	item.setup_sockets(colors, link_flags)
	return item

static func _merge_affix(affixes: Array[Dictionary], stat: int, val: float) -> void:
	for a in affixes:
		if int(a["stat"]) == stat:
			a["value"] = snappedf(float(a["value"]) + val, 0.1)
			return
	affixes.append({"stat": stat, "value": val})
