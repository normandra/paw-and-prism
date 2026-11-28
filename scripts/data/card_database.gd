class_name CardDatabase

static var _cards: Dictionary = {}
static var _template_ids: Array[String] = []
static var _addon_ids: Array[String] = []
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true
	_cards.clear()
	_template_ids.clear()
	_addon_ids.clear()

	# === 10 TEMPLATE CARDS (Equip to Auto-Cast; Forge Capacity 1/2/3/4 by Rarity) ===
	_add({
		"id": "acorn_barrage",
		"card_name": "Acorn Barrage",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.ATTACK,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 21.0,
		"cooldown": 0.70,
		"proj_speed": 22.0,
		"base_projectiles": 1,
		"base_chains": 0,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "ACRN",
		"desc": "Fires an aimed woodland acorn at the nearest critter.",
	})
	_add({
		"id": "starlight_orb",
		"card_name": "Starlight Orbs",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.SPELL,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.ORBIT, GameEnums.SkillTag.AOE],
		"base_damage": 16.0,
		"cooldown": 0.58,
		"proj_speed": 3.4,
		"base_projectiles": 2,
		"base_chains": 0,
		"pierce": 99,
		"area_radius": 3.4,
		"short": "STAR",
		"desc": "Summons orbiting star blades that slice nearby foes.",
	})
	_add({
		"id": "honey_slam",
		"card_name": "Honey Slam",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.ATTACK,
		"tags": [GameEnums.SkillTag.MELEE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 38.0,
		"cooldown": 1.40,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"base_chains": 0,
		"pierce": 99,
		"area_radius": 4.0,
		"short": "SLAM",
		"desc": "Smashes a sticky honey shockwave that slows critters.",
	})
	_add({
		"id": "whisker_lightning",
		"card_name": "Whisker Lightning",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.SPELL,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.CHAIN, GameEnums.SkillTag.LIGHTNING],
		"base_damage": 24.0,
		"cooldown": 0.92,
		"proj_speed": 30.0,
		"base_projectiles": 1,
		"base_chains": 2,
		"pierce": 0,
		"area_radius": 1.0,
		"short": "ZAP",
		"desc": "Strikes with crackling static that arcs across critters.",
	})
	_add({
		"id": "petal_cyclone",
		"card_name": "Petal Cyclone",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.ATTACK,
		"tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 14.0,
		"cooldown": 1.15,
		"proj_speed": 15.0,
		"base_projectiles": 6,
		"base_chains": 0,
		"pierce": 1,
		"area_radius": 0.55,
		"short": "PETL",
		"desc": "Whirls out 6 piercing blossom petals in a spiral.",
	})
	_add({
		"id": "fireball_berry",
		"card_name": "Fireball Berry",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.SPELL,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 30.0,
		"cooldown": 1.28,
		"proj_speed": 18.0,
		"base_projectiles": 1,
		"base_chains": 0,
		"pierce": 0,
		"area_radius": 3.0,
		"short": "FIRE",
		"desc": "Launches an ember berry that detonates & burns.",
	})
	_add({
		"id": "frost_nova",
		"card_name": "Frost Nova",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.SPELL,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.COLD],
		"base_damage": 19.0,
		"cooldown": 1.55,
		"proj_speed": 15.0,
		"base_projectiles": 8,
		"base_chains": 0,
		"pierce": 1,
		"area_radius": 4.0,
		"short": "FRST",
		"desc": "Shatters a chilling frost ring + 8 outward icicles.",
	})
	_add({
		"id": "boomerang_bone",
		"card_name": "Boomerang Bone",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.ATTACK,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 22.0,
		"cooldown": 1.20,
		"proj_speed": 18.5,
		"base_projectiles": 1,
		"base_chains": 0,
		"pierce": 99,
		"area_radius": 0.75,
		"short": "BONE",
		"desc": "Hurls a spinning bone that returns right to Mochi.",
	})
	_add({
		"id": "meteor_pine",
		"card_name": "Meteor Pinecone",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.SPELL,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 56.0,
		"cooldown": 2.25,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"base_chains": 0,
		"pierce": 99,
		"area_radius": 4.0,
		"short": "PINE",
		"desc": "Calls a blazing pinecone crash onto dense packs.",
	})
	_add({
		"id": "spirit_bees",
		"card_name": "Spirit Bees",
		"card_kind": GameEnums.CardKind.TEMPLATE,
		"category": GameEnums.CardCategory.ATTACK,
		"tags": [GameEnums.SkillTag.MINION, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 17.0,
		"cooldown": 1.05,
		"proj_speed": 16.5,
		"base_projectiles": 2,
		"base_chains": 0,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "BEES",
		"desc": "Releases homing spirit bees that chase targets.",
	})

	# === 24 ADD-ON CARDS (Consumed to Permanently Forge onto Template Cards) ===
	# -- 10 Core Skill Modifiers --
	_add({
		"id": "addon_multishot",
		"card_name": "Multi-Shot",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.ATTACK,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.ORBIT],
		"short": "MULT",
		"desc": "+2 Fan Shots (or +2 Orbiters). Deals 22% less hit dmg.",
		"mods": {"extra_proj": 2, "dmg_mult": 0.78},
	})
	_add({
		"id": "addon_chain",
		"card_name": "Chain Bounce",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.CHAIN],
		"short": "CHN",
		"desc": "Shots bounce to +2 nearby foes. Deals 8% less hit dmg.",
		"mods": {"extra_chains": 2, "dmg_mult": 0.92},
	})
	_add({
		"id": "addon_fork",
		"card_name": "Twin Fork",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.ATTACK,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "FORK",
		"desc": "Splits x2 on hit (max 2 gens). Deals 10% less hit dmg.",
		"mods": {"fork": 1, "dmg_mult": 0.90},
	})
	_add({
		"id": "addon_pierce",
		"card_name": "Deep Pierce",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.COMMON,
		"category": GameEnums.CardCategory.ATTACK,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "PRCE",
		"desc": "Projectiles pass through +3 additional critters.",
		"mods": {"extra_pierce": 3},
	})
	_add({
		"id": "addon_homing",
		"card_name": "Homing Seekers",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.COMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "HOME",
		"desc": "Shots steer toward targets (+15% spd, 5% less dmg).",
		"mods": {"homing": 1, "proj_speed_bonus": 0.15, "dmg_mult": 0.95},
	})
	_add({
		"id": "addon_echo",
		"card_name": "Double Echo",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [],
		"short": "ECHO",
		"desc": "+1 delayed repeat cast (or +1 orb). Deals 26% less dmg.",
		"mods": {"echo": 1, "dmg_mult": 0.74},
	})
	_add({
		"id": "addon_giant_blast",
		"card_name": "Giant Blast",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.ORBIT],
		"short": "WIDE",
		"desc": "Increases explosion, slam, or orbit radius by +45%.",
		"mods": {"area_bonus": BalanceConfig.GIANT_AOE_RADIUS_STEP},
	})
	_add({
		"id": "addon_ignite",
		"card_name": "Blazing Burn",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.COMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [],
		"short": "BURN",
		"desc": "Hits ignite critters for 22% DPS fire burn (+15%/stack).",
		"mods": {"ignite": 1},
	})
	_add({
		"id": "addon_chill",
		"card_name": "Frost Chill",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.COMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [],
		"short": "CHIL",
		"desc": "Hits chill critters, slowing their speed by 26%.",
		"mods": {"chill": 1},
	})
	_add({
		"id": "addon_leech",
		"card_name": "Life Siphon",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [],
		"short": "HEAL",
		"desc": "Hits heal 2.2% dmg (+1.2%/stack, cap 2.5 HP / 0.35s).",
		"mods": {"leech": 1},
	})

	# -- 10 Adapted Behavioral & Tradeoff Effects --
	_add({
		"id": "addon_sniper_focus",
		"card_name": "Sniper Focus",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "SNIP",
		"desc": "Forces 1 bolt: +50% spd, +2 pierce, +42% dmg (+25%/stack).",
		"mods": {"sniper_focus": 1},
	})
	_add({
		"id": "addon_short_barrage",
		"card_name": "Short Barrage",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.ORBIT],
		"short": "BARG",
		"desc": "+2 projectiles, but range halved (0.52x lifetime).",
		"mods": {"short_barrage": 1},
	})
	_add({
		"id": "addon_glass_spark",
		"card_name": "Glass Spark",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [],
		"short": "GLSS",
		"desc": "+52% card dmg, but Hero takes +35% dmg (cap 2.4x).",
		"mods": {"glass_spark": 1},
	})
	_add({
		"id": "addon_ember_corpse",
		"card_name": "Ember Corpse",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [],
		"short": "EMBR",
		"desc": "Slain critters erupt for 16 (+6/stack) fire AoE (0.25s ICD).",
		"mods": {"ember_corpse": 1},
	})
	_add({
		"id": "addon_frost_shatter",
		"card_name": "Frost Shatter",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.SPELL,
		"required_tags": [],
		"short": "SHAT",
		"desc": "Chilled kills burst for 16 (+6/stack) ice AoE (0.25s ICD).",
		"mods": {"frost_shatter": 1},
	})
	_add({
		"id": "addon_gravity_pull",
		"card_name": "Gravity Slam",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [GameEnums.SkillTag.AOE],
		"short": "GRAV",
		"desc": "AoE blasts pull critters inward (+15% radius/stack).",
		"mods": {"gravity_pull": 1},
	})
	_add({
		"id": "addon_ricochet",
		"card_name": "Edge Ricochet",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "RICO",
		"desc": "Shots bounce back at walls (+12% proj speed/stack).",
		"mods": {"ricochet": 1},
	})
	_add({
		"id": "addon_nova_ring",
		"card_name": "Nova Barrage",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.LEGENDARY,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "NOVA",
		"desc": "Fires all shots in a 360 ring (min 6, +2/stack).",
		"mods": {"nova_ring": 1},
	})
	_add({
		"id": "addon_cadence_burst",
		"card_name": "Cadence Burst",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [],
		"short": "CADN",
		"desc": "Every 4th cast triggers 24 (+10/stack) nova; +20% cooldown.",
		"mods": {"cadence_burst": 1},
	})
	_add({
		"id": "addon_overclock",
		"card_name": "Turret Overclock",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [],
		"short": "TURT",
		"desc": "Standing still casts 1.65x (+0.25x/stack); moving 0.80x.",
		"mods": {"overclock": 1},
	})

	# -- 4 Utility & Defense Add-ons --
	_add({
		"id": "addon_zoomies",
		"card_name": "Zoomies Frenzy",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.COMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [],
		"short": "ZOOM",
		"desc": "Kills boost speed +18% & cast rate +15% (+6%/+5%/stack).",
		"mods": {"zoomies": 1},
	})
	_add({
		"id": "addon_thorns",
		"card_name": "Bramble Thorns",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.UNCOMMON,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [],
		"short": "THRN",
		"desc": "Being hit blasts 18 (+8/stack) bramble AoE (2s CD).",
		"mods": {"thorns": 1},
	})
	_add({
		"id": "addon_orbit_shield",
		"card_name": "Star Shield",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.RARE,
		"category": GameEnums.CardCategory.UTILITY,
		"required_tags": [],
		"short": "SHLD",
		"desc": "Being hit spawns 3 guard stars for 3.8s (+5 dmg/stack).",
		"mods": {"orbit_shield": 1},
	})
	_add({
		"id": "addon_nine_lives",
		"card_name": "Nine-Lives Bell",
		"card_kind": GameEnums.CardKind.ADDON,
		"rarity": GameEnums.Rarity.LEGENDARY,
		"category": GameEnums.CardCategory.KEYSTONE,
		"required_tags": [],
		"short": "LIFE",
		"desc": "Cheats fatal hit: heal 45% + 1.4s invuln (105s, -20s/stack).",
		"mods": {"nine_lives": 1},
	})

static func _add(def: Dictionary) -> void:
	var cid: String = String(def["id"])
	_cards[cid] = def
	if int(def["card_kind"]) == GameEnums.CardKind.TEMPLATE:
		_template_ids.append(cid)
	else:
		_addon_ids.append(cid)

static func get_def(card_id: String) -> Dictionary:
	_ensure_init()
	return _cards.get(card_id, {})

static func get_all_ids() -> Array[String]:
	_ensure_init()
	var out: Array[String] = []
	for k in _cards.keys():
		out.append(String(k))
	return out

static func get_all_template_ids() -> Array[String]:
	_ensure_init()
	return _template_ids.duplicate()

static func get_all_addon_ids() -> Array[String]:
	_ensure_init()
	return _addon_ids.duplicate()

static func does_addon_apply(addon_id: String, template_id: String) -> bool:
	var adef: Dictionary = get_def(addon_id)
	var tdef: Dictionary = get_def(template_id)
	if adef.is_empty() or tdef.is_empty():
		return false
	if int(adef.get("card_kind", -1)) != GameEnums.CardKind.ADDON:
		return false
	if int(tdef.get("card_kind", -1)) != GameEnums.CardKind.TEMPLATE:
		return false
	var req_tags: Array = adef.get("required_tags", [])
	if req_tags.is_empty():
		return true
	var t_tags: Array = tdef.get("tags", [])
	for req in req_tags:
		if t_tags.has(req):
			return true
	return false

static func get_compatibility_text(addon_id: String) -> String:
	var adef: Dictionary = get_def(addon_id)
	var req_tags: Array = adef.get("required_tags", [])
	if req_tags.is_empty():
		return "Any Template"
	var parts: PackedStringArray = []
	for t in req_tags:
		parts.append(GameEnums.skill_tag_label(int(t)))
	return " / ".join(parts)

static func roll_template_rarity(elapsed_sec: float, rng: RandomNumberGenerator, min_rarity: int = 0) -> int:
	var progress: float = clampf(elapsed_sec / 1200.0, 0.0, 1.0)
	var w_common: float = lerpf(0.50, 0.14, progress)
	var w_uncommon: float = lerpf(0.36, 0.34, progress)
	var w_rare: float = lerpf(0.12, 0.36, progress)
	var w_leg: float = lerpf(0.02, 0.16, progress)
	var tot: float = w_common + w_uncommon + w_rare + w_leg
	var r: float = rng.randf() * tot
	var rolled: int = GameEnums.Rarity.COMMON
	if r < w_common:
		rolled = GameEnums.Rarity.COMMON
	elif r < w_common + w_uncommon:
		rolled = GameEnums.Rarity.UNCOMMON
	elif r < w_common + w_uncommon + w_rare:
		rolled = GameEnums.Rarity.RARE
	else:
		rolled = GameEnums.Rarity.LEGENDARY
	return maxi(rolled, min_rarity)

static func roll_template_id(rng: RandomNumberGenerator, forced_id: String = "") -> String:
	_ensure_init()
	if not forced_id.is_empty():
		return forced_id
	return _template_ids[rng.randi() % _template_ids.size()]

static func roll_addon_id(elapsed_sec: float, rng: RandomNumberGenerator, min_rarity: int = -1, forced_id: String = "") -> String:
	_ensure_init()
	if not forced_id.is_empty():
		return forced_id
	var pool: Array[String] = _addon_ids
	if min_rarity >= 0:
		var filtered: Array[String] = []
		for aid in _addon_ids:
			var r_val: int = int(get_def(aid).get("rarity", GameEnums.Rarity.COMMON))
			if r_val >= min_rarity:
				filtered.append(aid)
		if not filtered.is_empty():
			pool = filtered
	else:
		# Early wave softly weights away from Legendary Add-ons, late wave opens them up
		var progress: float = clampf(elapsed_sec / 1200.0, 0.0, 1.0)
		var weighted: Array[String] = []
		for aid in _addon_ids:
			var r_val: int = int(get_def(aid).get("rarity", GameEnums.Rarity.COMMON))
			var copies: int = 4 - r_val if progress < 0.45 else 2 + (r_val % 2)
			for _c in range(maxi(1, copies)):
				weighted.append(aid)
		pool = weighted
	return pool[rng.randi() % pool.size()]
