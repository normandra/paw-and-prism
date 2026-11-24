class_name ItemDatabase

static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var _seeded: bool = false
static var _effects_cache: Dictionary = {}

static func _ensure_rng() -> void:
	if not _seeded:
		_rng.randomize()
		_seeded = true

static func _ensure_effects() -> void:
	if not _effects_cache.is_empty():
		return
	var defs: Array[Dictionary] = [
		# Standard & Tradeoff Global Effects (18)
		{"id": "dash_honey_nova", "tag": "Dash -> Honey Nova", "icon": "dash_paw", "color": Color(1.0, 0.78, 0.28), "is_tradeoff": false},
		{"id": "dash_triggers_skills", "tag": "Dash Fires Skills | Slow Auto", "icon": "dash_paw", "color": Color(0.55, 0.90, 1.0), "is_tradeoff": true},
		{"id": "turret_stance", "tag": "Stand Still -> 2x Cast", "icon": "sun_meadow", "color": Color(1.0, 0.86, 0.42), "is_tradeoff": true},
		{"id": "zoomies_on_kill", "tag": "Kills -> Speed Burst", "icon": "dash_paw", "color": Color(0.52, 0.95, 0.58), "is_tradeoff": false},
		{"id": "edge_ricochet", "tag": "Shots Bounce Back", "icon": "star_upgrade", "color": Color(0.65, 0.92, 1.0), "is_tradeoff": false},
		{"id": "short_barrage", "tag": "+2 Shots | Short Range", "icon": "star_upgrade", "color": Color(0.56, 0.96, 0.60), "is_tradeoff": true},
		{"id": "sniper_focus", "tag": "Pierce +2 | 1 Fast Shot", "icon": "star_upgrade", "color": Color(1.0, 0.78, 0.42), "is_tradeoff": true},
		{"id": "giant_slow_aoe", "tag": "Huge AoE | Slower Cast", "icon": "sun_meadow", "color": Color(0.70, 0.82, 1.0), "is_tradeoff": true},
		{"id": "ember_corpse", "tag": "Kills -> Fire Pop", "icon": "fireball_berry", "color": Color(1.0, 0.50, 0.24), "is_tradeoff": false},
		{"id": "frost_shatter", "tag": "Chill Kills -> Ice Ring", "icon": "frost_nova", "color": Color(0.45, 0.92, 1.0), "is_tradeoff": false},
		{"id": "static_sprint", "tag": "Moving -> Zap Sparks", "icon": "whisker_lightning", "color": Color(0.55, 0.88, 1.0), "is_tradeoff": false},
		{"id": "vamp_dash", "tag": "Dash -> Siphon Heal", "icon": "heart", "color": Color(1.0, 0.45, 0.58), "is_tradeoff": false},
		{"id": "thorns_burst", "tag": "Hit -> Bramble Nova", "icon": "boss_crown", "color": Color(0.95, 0.56, 0.34), "is_tradeoff": false},
		{"id": "gravity_slams", "tag": "AoE Pulls Foes In", "icon": "sun_meadow", "color": Color(0.76, 0.60, 1.0), "is_tradeoff": false},
		{"id": "glass_spark", "tag": "Heavy Impact | Fragile", "icon": "skull", "color": Color(1.0, 0.44, 0.44), "is_tradeoff": true},
		{"id": "double_dash", "tag": "2x Dash Charges", "icon": "dash_paw", "color": Color(1.0, 0.88, 0.36), "is_tradeoff": false},
		{"id": "orbit_shield", "tag": "Hit -> Star Shield", "icon": "starlight_orb", "color": Color(0.48, 0.86, 1.0), "is_tradeoff": false},
		{"id": "lucky_clover", "tag": "Rarer Loot & Links", "icon": "bag", "color": Color(0.54, 0.96, 0.62), "is_tradeoff": false},
		# Unique Keystones (5)
		{"id": "nova_barrage", "tag": "All Shots Fire 360 Ring", "icon": "star_upgrade", "color": Color(1.0, 0.58, 0.22), "is_tradeoff": false, "unique_only": true},
		{"id": "prism_echo", "tag": "Linked Mods Double-Proc", "icon": "paw_prism_crest", "color": Color(0.94, 0.72, 1.0), "is_tradeoff": false, "unique_only": true},
		{"id": "aegis_freeze", "tag": "Hit -> Freezing Honey Nova", "icon": "frost_nova", "color": Color(0.52, 0.92, 1.0), "is_tradeoff": false, "unique_only": true},
		{"id": "comet_dash", "tag": "Dash Fires All Skills", "icon": "dash_paw", "color": Color(1.0, 0.80, 0.28), "is_tradeoff": false, "unique_only": true},
		{"id": "cheat_death", "tag": "Fatal Hit -> Burst Heal", "icon": "heart", "color": Color(1.0, 0.88, 0.36), "is_tradeoff": false, "unique_only": true},
	]
	for d in defs:
		_effects_cache[String(d["id"])] = d

static func get_effect_def(effect_id: String) -> Dictionary:
	_ensure_effects()
	return _effects_cache.get(effect_id, {"id": effect_id, "tag": effect_id, "icon": "star_upgrade", "color": Color(0.95, 0.82, 0.45), "is_tradeoff": false})

static func get_all_non_unique_effect_ids() -> Array[String]:
	_ensure_effects()
	var out: Array[String] = []
	for k in _effects_cache.keys():
		var d: Dictionary = _effects_cache[k]
		if not bool(d.get("unique_only", false)):
			out.append(String(k))
	return out

static func _base_items_for_slot(slot: int) -> Array[Dictionary]:
	match slot:
		GameEnums.EquipSlot.WEAPON:
			return [
				{"name": "Acorn Wand", "style": "acorn_wand"},
				{"name": "Honey Hammer", "style": "honey_hammer"},
				{"name": "Starlight Staff", "style": "star_staff"},
				{"name": "Paw Claws", "style": "paw_claws"},
			]
		GameEnums.EquipSlot.HELMET:
			return [
				{"name": "Sprout Hood", "style": "leaf_crown"},
				{"name": "Wizard Hat", "style": "wizard_hat"},
				{"name": "Knight Cap", "style": "knight_helm"},
				{"name": "Ribbon Hood", "style": "ribbon_hood"},
			]
		GameEnums.EquipSlot.ARMOR:
			return [
				{"name": "Cozy Tunic", "style": "tunic"},
				{"name": "Bark Vest", "style": "plate"},
				{"name": "Velvet Cloak", "style": "cloak"},
			]
		GameEnums.EquipSlot.BOOTS:
			return [
				{"name": "Paw Slippers", "style": "boots"},
				{"name": "Meadow Boots", "style": "boots"},
				{"name": "Cloud Treads", "style": "boots"},
			]
		GameEnums.EquipSlot.AMULET:
			return [
				{"name": "Acorn Charm", "style": "amulet"},
				{"name": "Bell Pendant", "style": "amulet"},
				{"name": "Prism Locket", "style": "amulet"},
			]
		GameEnums.EquipSlot.RING:
			return [
				{"name": "Clover Ring", "style": "ring"},
				{"name": "Amber Band", "style": "ring"},
				{"name": "Dewdrop Signet", "style": "ring"},
			]
	return [{"name": "Charm", "style": "ring"}]

static func get_unique_templates() -> Array[Dictionary]:
	return [
		{
			"unique_id": "unique_acorn_scepter",
			"name": "Grand Acorn Scepter",
			"slot": GameEnums.EquipSlot.WEAPON,
			"style": "acorn_wand",
			"effects": ["nova_barrage", "short_barrage"],
			"sockets": [GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE, GameEnums.GemColor.RED],
			"links": [true, true, true],
		},
		{
			"unique_id": "unique_prism_crown",
			"name": "Prismwhisker Crown",
			"slot": GameEnums.EquipSlot.HELMET,
			"style": "wizard_hat",
			"effects": ["prism_echo", "lucky_clover"],
			"sockets": [GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE],
			"links": [true, true],
		},
		{
			"unique_id": "unique_honey_aegis",
			"name": "Honeycomb Aegis",
			"slot": GameEnums.EquipSlot.ARMOR,
			"style": "plate",
			"effects": ["aegis_freeze", "thorns_burst"],
			"sockets": [GameEnums.GemColor.RED, GameEnums.GemColor.RED, GameEnums.GemColor.BLUE, GameEnums.GemColor.GREEN],
			"links": [true, true, true],
		},
		{
			"unique_id": "unique_comet_paws",
			"name": "Paws of the Comet",
			"slot": GameEnums.EquipSlot.BOOTS,
			"style": "boots",
			"effects": ["comet_dash", "double_dash"],
			"sockets": [GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE],
			"links": [true, true],
		},
		{
			"unique_id": "unique_nine_lives",
			"name": "Nine-Lives Bell",
			"slot": GameEnums.EquipSlot.AMULET,
			"style": "amulet",
			"effects": ["cheat_death", "zoomies_on_kill"],
			"sockets": [GameEnums.GemColor.WHITE, GameEnums.GemColor.BLUE],
			"links": [true],
		},
		{
			"unique_id": "unique_starweaver",
			"name": "Starweaver Band",
			"slot": GameEnums.EquipSlot.RING,
			"style": "ring",
			"effects": ["gravity_slams", "ember_corpse"],
			"sockets": [GameEnums.GemColor.BLUE, GameEnums.GemColor.GREEN],
			"links": [true],
		},
	]

static func create_tutorial_wand() -> ItemInstance:
	var item: ItemInstance = ItemInstance.new()
	item.item_name = "Meadow Acorn Wand"
	item.equip_slot = GameEnums.EquipSlot.WEAPON
	item.rarity = GameEnums.Rarity.MAGIC
	item.visual_style = "acorn_wand"
	item.effects = ["dash_honey_nova"]
	item.setup_sockets([GameEnums.GemColor.GREEN, GameEnums.GemColor.GREEN], [true])
	return item

static func create_unique_item(unique_id: String) -> ItemInstance:
	for tpl in get_unique_templates():
		if String(tpl["unique_id"]) == unique_id:
			return _build_unique_from_template(tpl)
	return _build_unique_from_template(get_unique_templates()[0])

static func _build_unique_from_template(tpl: Dictionary) -> ItemInstance:
	var item: ItemInstance = ItemInstance.new()
	item.item_name = String(tpl["name"])
	item.equip_slot = int(tpl["slot"])
	item.rarity = GameEnums.Rarity.UNIQUE
	item.visual_style = String(tpl["style"])
	item.unique_id = String(tpl["unique_id"])
	var effs: Array[String] = []
	for e_id in tpl["effects"]:
		effs.append(String(e_id))
	item.effects = effs
	var scols: Array[int] = []
	for c in tpl["sockets"]:
		scols.append(int(c))
	var lnks: Array[bool] = []
	for l in tpl["links"]:
		lnks.append(bool(l))
	item.setup_sockets(scols, lnks)
	return item

static func generate_item(forced_rarity: int = -1, lucky_bonus: bool = false, forced_slot: int = -1, rng_override: RandomNumberGenerator = null) -> ItemInstance:
	_ensure_rng()
	_ensure_effects()
	var rng: RandomNumberGenerator = rng_override if rng_override != null else _rng

	var rarity: int = forced_rarity
	if rarity < 0:
		var u_chance: float = 0.14 if lucky_bonus else 0.05
		var r_chance: float = 0.40 if lucky_bonus else 0.22
		var m_chance: float = 0.36 if lucky_bonus else 0.43
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
				return _build_unique_from_template(slot_uniques[rng.randi() % slot_uniques.size()])
		return _build_unique_from_template(uniques[rng.randi() % uniques.size()])

	var slot: int = forced_slot if forced_slot >= 0 else rng.randi() % 6
	var bases: Array[Dictionary] = _base_items_for_slot(slot)
	var base_tpl: Dictionary = bases[rng.randi() % bases.size()]

	var item: ItemInstance = ItemInstance.new()
	item.equip_slot = slot
	item.rarity = rarity
	item.visual_style = String(base_tpl["style"])

	# Pick Global Behavioral Effects (no numerical stat sticks!)
	var all_effs: Array[String] = get_all_non_unique_effect_ids()
	var non_tradeoffs: Array[String] = []
	var tradeoffs: Array[String] = []
	for eid in all_effs:
		if bool(get_effect_def(eid).get("is_tradeoff", false)):
			tradeoffs.append(eid)
		else:
			non_tradeoffs.append(eid)

	var picked_effects: Array[String] = []
	match rarity:
		GameEnums.Rarity.COMMON:
			picked_effects.append(all_effs[rng.randi() % all_effs.size()])
		GameEnums.Rarity.MAGIC:
			var first_id: String = all_effs[rng.randi() % all_effs.size()]
			picked_effects.append(first_id)
			var pool2: Array[String] = tradeoffs if (not bool(get_effect_def(first_id).get("is_tradeoff", false)) and not tradeoffs.is_empty()) else all_effs
			var second_id: String = pool2[rng.randi() % pool2.size()]
			var guard: int = 0
			while second_id == first_id and guard < 8:
				second_id = all_effs[rng.randi() % all_effs.size()]
				guard += 1
			if second_id != first_id:
				picked_effects.append(second_id)
		GameEnums.Rarity.RARE:
			var first_r: String = non_tradeoffs[rng.randi() % non_tradeoffs.size()] if not non_tradeoffs.is_empty() else all_effs[0]
			picked_effects.append(first_r)
			var second_r: String = all_effs[rng.randi() % all_effs.size()]
			var guard_r: int = 0
			while second_r == first_r and guard_r < 8:
				second_r = all_effs[rng.randi() % all_effs.size()]
				guard_r += 1
			if second_r != first_r:
				picked_effects.append(second_r)
	item.effects = picked_effects

	# Thematic Storybook Naming
	var base_name: String = String(base_tpl["name"])
	if rarity == GameEnums.Rarity.COMMON:
		item.item_name = base_name
	elif rarity == GameEnums.Rarity.MAGIC:
		var magic_pref: Array[String] = ["Dasher's", "Swift", "Sunlit", "Bramble", "Starry", "Ember", "Frost", "Clover"]
		item.item_name = "%s %s" % [magic_pref[rng.randi() % magic_pref.size()], base_name]
	else:
		var rare_adj: Array[String] = ["Star", "Honey", "Clover", "Moon", "Sun", "Whisker", "Bramble", "Glimmer", "Paw"]
		var rare_noun: Array[String] = ["Heart", "Song", "Ward", "Crest", "Boon", "Spark", "Fang", "Crown"]
		item.item_name = "%s%s %s" % [
			rare_adj[rng.randi() % rare_adj.size()],
			rare_noun[rng.randi() % rare_noun.size()].to_lower(),
			base_name,
		]

	# Fixed Rolled PoE Sockets & Links (tradeoffs in socket layouts!)
	var max_s: int = GameEnums.slot_max_sockets(slot)
	var min_s: int = 1
	var top_s: int = mini(2, max_s)
	var link_chance: float = 0.38
	var white_chance: float = 0.04
	match rarity:
		GameEnums.Rarity.MAGIC:
			min_s = mini(2, max_s)
			top_s = mini(3, max_s)
			link_chance = 0.58
			white_chance = 0.06
		GameEnums.Rarity.RARE:
			min_s = mini(3, max_s)
			top_s = max_s
			link_chance = 0.76
			white_chance = 0.10
	if lucky_bonus:
		link_chance = clampf(link_chance + 0.14, 0.38, 0.92)
		white_chance += 0.05

	var socket_count: int = rng.randi_range(min_s, top_s)
	var colors: Array[int] = []
	for _s in range(socket_count):
		var c_roll: float = rng.randf()
		if c_roll < white_chance:
			colors.append(GameEnums.GemColor.WHITE)
		elif c_roll < 0.36:
			colors.append(GameEnums.GemColor.RED)
		elif c_roll < 0.68:
			colors.append(GameEnums.GemColor.GREEN)
		else:
			colors.append(GameEnums.GemColor.BLUE)

	var link_flags: Array[bool] = []
	for _l in range(maxi(0, socket_count - 1)):
		link_flags.append(rng.randf() < link_chance)

	item.setup_sockets(colors, link_flags)
	return item
