class_name GemDatabase

static var _gems: Dictionary = {}
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true
	_gems.clear()

	# === 10 ACTIVE SKILL GEMS ===
	_add({
		"id": "acorn_barrage",
		"gem_name": "Acorn Barrage",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 22.0,
		"damage_per_lvl": 5.5,
		"cooldown": 0.68,
		"proj_speed": 22.0,
		"base_projectiles": 1,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "ACRN",
		"desc": "Fires snappy enchanted acorns at the nearest foe.",
	})
	_add({
		"id": "starlight_orb",
		"gem_name": "Starlight Orbs",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.ORBIT, GameEnums.SkillTag.AOE],
		"base_damage": 19.0,
		"damage_per_lvl": 5.0,
		"cooldown": 0.45,
		"proj_speed": 3.4,
		"base_projectiles": 2,
		"pierce": 99,
		"area_radius": 3.4,
		"short": "STAR",
		"desc": "Summons orbiting luminous stars that swirl around your hero.",
	})
	_add({
		"id": "honey_slam",
		"gem_name": "Honey Slam",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.MELEE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 34.0,
		"damage_per_lvl": 8.5,
		"cooldown": 1.35,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 4.2,
		"short": "SLAM",
		"desc": "Smashes golden honey in an AoE ring, slowing hit critters.",
	})
	_add({
		"id": "whisker_lightning",
		"gem_name": "Whisker Lightning",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.CHAIN, GameEnums.SkillTag.LIGHTNING],
		"base_damage": 26.0,
		"damage_per_lvl": 6.5,
		"cooldown": 0.92,
		"proj_speed": 30.0,
		"base_projectiles": 1,
		"base_chains": 2,
		"pierce": 0,
		"area_radius": 1.0,
		"short": "ZAP",
		"desc": "Instant crackle of whisker-static arcing between enemies.",
	})
	_add({
		"id": "petal_cyclone",
		"gem_name": "Petal Cyclone",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 15.0,
		"damage_per_lvl": 4.2,
		"cooldown": 1.15,
		"proj_speed": 14.5,
		"base_projectiles": 6,
		"pierce": 1,
		"area_radius": 0.55,
		"short": "PETL",
		"desc": "Launches a spiraling ring of razor sakura petals outward.",
	})
	_add({
		"id": "fireball_berry",
		"gem_name": "Fireball Berry",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 30.0,
		"damage_per_lvl": 7.5,
		"cooldown": 1.25,
		"proj_speed": 17.5,
		"base_projectiles": 1,
		"pierce": 0,
		"area_radius": 3.0,
		"short": "FIRE",
		"desc": "Lobs an ember-berry that explodes in fiery splash + burn.",
	})
	_add({
		"id": "frost_nova",
		"gem_name": "Frost Nova",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.COLD],
		"base_damage": 20.0,
		"damage_per_lvl": 5.5,
		"cooldown": 1.55,
		"proj_speed": 15.0,
		"base_projectiles": 8,
		"pierce": 1,
		"area_radius": 4.0,
		"short": "FRST",
		"desc": "Radiates icy shards and a chilling frost ring around you.",
	})
	_add({
		"id": "boomerang_bone",
		"gem_name": "Boomerang Bone",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 25.0,
		"damage_per_lvl": 6.5,
		"cooldown": 1.15,
		"proj_speed": 18.0,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 0.75,
		"short": "BONE",
		"desc": "Hurls a spinning treat bone that pierces out and curves back.",
	})
	_add({
		"id": "meteor_pine",
		"gem_name": "Meteor Pinecone",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 52.0,
		"damage_per_lvl": 13.0,
		"cooldown": 2.25,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 4.1,
		"short": "PINE",
		"desc": "Drops a blazing giant pinecone onto the densest foe cluster.",
	})
	_add({
		"id": "spirit_bees",
		"gem_name": "Spirit Bees",
		"gem_type": GameEnums.GemType.ACTIVE,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.MINION, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 17.0,
		"damage_per_lvl": 4.5,
		"cooldown": 1.05,
		"proj_speed": 16.0,
		"base_projectiles": 2,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "BEES",
		"desc": "Releases buzzing spirit bees that seek and sting nearby foes.",
	})

	# === 12 SUPPORT GEMS ===
	_add({
		"id": "sup_gmp",
		"gem_name": "Greater Multi-Proj",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "GMP",
		"desc": "+2 Projectiles (+1 at Lv4), -14% Damage per projectile.",
		"mods": {"extra_proj": 2, "dmg_mult": 0.86, "proj_per_3lvl": 1},
	})
	_add({
		"id": "sup_chain",
		"gem_name": "Chain Support",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.CHAIN],
		"short": "CHN",
		"desc": "Linked skills chain +2 extra times (+1 per 2 levels).",
		"mods": {"extra_chains": 2, "chains_per_2lvl": 1},
	})
	_add({
		"id": "sup_fork",
		"gem_name": "Fork Support",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "FRK",
		"desc": "Projectiles split into 2 angled projectiles on first hit (+10% Dmg).",
		"mods": {"fork": 1, "dmg_mult": 1.10},
	})
	_add({
		"id": "sup_aoe",
		"gem_name": "Increased Area",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.ORBIT],
		"short": "AOE",
		"desc": "+35% Area Size (+6%/lvl) and +10% Area Damage.",
		"mods": {"area_pct": 35.0, "area_per_lvl": 6.0, "dmg_mult": 1.10},
	})
	_add({
		"id": "sup_faster_cast",
		"gem_name": "Faster Casting",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [],
		"short": "FST",
		"desc": "+28% Cast/Trigger Speed (+5%/lvl) for any linked skill.",
		"mods": {"cast_speed_pct": 28.0, "cast_per_lvl": 5.0},
	})
	_add({
		"id": "sup_pierce",
		"gem_name": "Pierce Support",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "PRC",
		"desc": "Projectiles pierce +3 targets (+1/lvl) and deal +12% Damage.",
		"mods": {"extra_pierce": 3, "pierce_per_lvl": 1, "dmg_mult": 1.12},
	})
	_add({
		"id": "sup_ignite",
		"gem_name": "Added Fire & Burn",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.RED,
		"required_tags": [],
		"short": "IGN",
		"desc": "Adds +30% Fire Damage (+5%/lvl) and ignites enemies.",
		"mods": {"added_fire_pct": 30.0, "fire_per_lvl": 5.0},
	})
	_add({
		"id": "sup_chill",
		"gem_name": "Frostbite Support",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [],
		"short": "CHL",
		"desc": "Adds +22% Cold Damage (+4%/lvl) and chills (35% slow).",
		"mods": {"added_cold_pct": 22.0, "cold_per_lvl": 4.0},
	})
	_add({
		"id": "sup_crit",
		"gem_name": "Precision Strikes",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [],
		"short": "CRT",
		"desc": "+14% Crit Chance (+2%/lvl) and +45% Crit Damage.",
		"mods": {"crit_chance": 14.0, "crit_per_lvl": 2.0, "crit_mult": 45.0},
	})
	_add({
		"id": "sup_leech",
		"gem_name": "Life Leech",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.RED,
		"required_tags": [],
		"short": "LCH",
		"desc": "Heals for 3.0% (+0.4%/lvl) of damage dealt by linked skill.",
		"mods": {"leech_pct": 3.0, "leech_per_lvl": 0.4},
	})
	_add({
		"id": "sup_echo",
		"gem_name": "Spell Echo",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [],
		"short": "ECH",
		"desc": "Linked skill triggers twice! (0.78x dmg per trigger = 1.56x net).",
		"mods": {"echo": 1, "dmg_mult": 0.78, "dmg_per_lvl": 0.03},
	})
	_add({
		"id": "sup_homing",
		"gem_name": "Homing Guidance",
		"gem_type": GameEnums.GemType.SUPPORT,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "HOM",
		"desc": "Projectiles steer smoothly toward enemies (+20% Speed).",
		"mods": {"homing": 1, "proj_speed_pct": 20.0},
	})

	# === 10 PASSIVE SKILL GEMS ===
	_add({
		"id": "pas_swiftness",
		"gem_name": "Aura of Swiftness",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "SWFT",
		"desc": "Passive Aura: +16% Move Speed & +12% Attack/Cast Speed (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.MOVE_SPEED_PCT: 16.0,
			GameEnums.StatType.CAST_SPEED_PCT: 12.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.MOVE_SPEED_PCT: 2.0,
			GameEnums.StatType.CAST_SPEED_PCT: 2.0,
		},
		"aura_color": Color(0.45, 0.95, 0.55, 0.35),
	})
	_add({
		"id": "pas_vitality",
		"gem_name": "Vitality Meadow",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "VIT",
		"desc": "Passive Aura: +45 Max HP & +3.5 HP Regen/s (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.MAX_HP: 45.0,
			GameEnums.StatType.HP_REGEN: 3.5,
		},
		"stats_per_lvl": {
			GameEnums.StatType.MAX_HP: 12.0,
			GameEnums.StatType.HP_REGEN: 0.7,
		},
		"aura_color": Color(0.95, 0.45, 0.55, 0.35),
	})
	_add({
		"id": "pas_determination",
		"gem_name": "Determination Shell",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "DET",
		"desc": "Passive Aura: +28 Armor & +10% Damage Reduction (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.ARMOR: 28.0,
			GameEnums.StatType.DMG_REDUCTION_PCT: 10.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.ARMOR: 7.0,
			GameEnums.StatType.DMG_REDUCTION_PCT: 1.5,
		},
		"aura_color": Color(0.95, 0.72, 0.30, 0.35),
	})
	_add({
		"id": "pas_wrath",
		"gem_name": "Wrath of Storms",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.AURA, GameEnums.SkillTag.LIGHTNING],
		"short": "WRTH",
		"desc": "Passive Aura: +8 Flat Damage & +18% All Damage (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.FLAT_DAMAGE: 8.0,
			GameEnums.StatType.DAMAGE_PCT: 18.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.FLAT_DAMAGE: 2.5,
			GameEnums.StatType.DAMAGE_PCT: 4.0,
		},
		"aura_color": Color(0.45, 0.75, 1.0, 0.35),
	})
	_add({
		"id": "pas_precision",
		"gem_name": "Precision Whiskers",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "PRCS",
		"desc": "Passive Aura: +14% Crit Chance & +30% Pickup Radius (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.CRIT_CHANCE: 14.0,
			GameEnums.StatType.PICKUP_RADIUS_PCT: 30.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.CRIT_CHANCE: 2.5,
			GameEnums.StatType.PICKUP_RADIUS_PCT: 6.0,
		},
		"aura_color": Color(0.75, 0.98, 0.45, 0.35),
	})
	_add({
		"id": "pas_clarity",
		"gem_name": "Clarity Prism",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "CLRY",
		"desc": "Passive Aura: +18% Cast Speed & +22% Area Size (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.CAST_SPEED_PCT: 18.0,
			GameEnums.StatType.AREA_PCT: 22.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.CAST_SPEED_PCT: 3.0,
			GameEnums.StatType.AREA_PCT: 4.0,
		},
		"aura_color": Color(0.40, 0.92, 0.98, 0.35),
	})
	_add({
		"id": "pas_greed",
		"gem_name": "Raccoon's Greed",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.WHITE,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "GRD",
		"desc": "White Passive: Fits any socket! +35% Magic Find & +18% XP Gain.",
		"stats": {
			GameEnums.StatType.MAGIC_FIND_PCT: 35.0,
			GameEnums.StatType.XP_GAIN_PCT: 18.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.MAGIC_FIND_PCT: 8.0,
			GameEnums.StatType.XP_GAIN_PCT: 4.0,
		},
		"aura_color": Color(1.0, 0.92, 0.45, 0.35),
	})
	_add({
		"id": "pas_thorns",
		"gem_name": "Bramble Thorns",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.AURA, GameEnums.SkillTag.PHYSICAL],
		"short": "THRN",
		"desc": "Passive: +20 Armor, +15% Damage, and fires Bramble Nova when hurt.",
		"stats": {
			GameEnums.StatType.ARMOR: 20.0,
			GameEnums.StatType.DAMAGE_PCT: 15.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.ARMOR: 5.0,
			GameEnums.StatType.DAMAGE_PCT: 3.5,
		},
		"special": "thorns",
		"aura_color": Color(0.85, 0.38, 0.28, 0.35),
	})
	_add({
		"id": "pas_vampiric",
		"gem_name": "Vampiric Fang",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "VAMP",
		"desc": "Passive: +2.5 Life on Hit & +25 Max HP (scales w/ Lv).",
		"stats": {
			GameEnums.StatType.LIFE_ON_HIT: 2.5,
			GameEnums.StatType.MAX_HP: 25.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.LIFE_ON_HIT: 0.7,
			GameEnums.StatType.MAX_HP: 8.0,
		},
		"aura_color": Color(0.88, 0.20, 0.45, 0.35),
	})
	_add({
		"id": "pas_prism_mastery",
		"gem_name": "Prismatic Mastery",
		"gem_type": GameEnums.GemType.PASSIVE,
		"color": GameEnums.GemColor.WHITE,
		"tags": [GameEnums.SkillTag.AURA],
		"short": "PRSM",
		"desc": "White Passive: +22% Damage & +1 Level to all other gems in this item!",
		"stats": {
			GameEnums.StatType.DAMAGE_PCT: 22.0,
		},
		"stats_per_lvl": {
			GameEnums.StatType.DAMAGE_PCT: 5.0,
		},
		"special": "item_gem_plus_one",
		"aura_color": Color(0.96, 0.90, 1.0, 0.42),
	})

static func _add(def: Dictionary) -> void:
	_gems[String(def["id"])] = def

static func get_def(gem_id: String) -> Dictionary:
	_ensure_init()
	return _gems.get(gem_id, {})

static func get_all_ids() -> Array[String]:
	_ensure_init()
	var out: Array[String] = []
	for k in _gems.keys():
		out.append(String(k))
	return out

static func get_ids_by_type(gtype: int) -> Array[String]:
	_ensure_init()
	var out: Array[String] = []
	for k in _gems.keys():
		var d: Dictionary = _gems[k]
		if int(d.get("gem_type", -1)) == gtype:
			out.append(String(k))
	return out

static func does_support_apply(support_id: String, active_id: String) -> bool:
	var sup_def: Dictionary = get_def(support_id)
	var act_def: Dictionary = get_def(active_id)
	if sup_def.is_empty() or act_def.is_empty():
		return false
	if int(sup_def.get("gem_type", -1)) != GameEnums.GemType.SUPPORT:
		return false
	if int(act_def.get("gem_type", -1)) != GameEnums.GemType.ACTIVE:
		return false
	var req_tags: Array = sup_def.get("required_tags", [])
	if req_tags.is_empty():
		return true
	var act_tags: Array = act_def.get("tags", [])
	for t in req_tags:
		if act_tags.has(t):
			return true
	return false

static func roll_random_gem_id(rng: RandomNumberGenerator, preferred_type: int = -1) -> String:
	_ensure_init()
	var chosen_type: int = preferred_type
	if chosen_type == -1:
		var roll: float = rng.randf()
		if roll < 0.34:
			chosen_type = GameEnums.GemType.ACTIVE
		elif roll < 0.68:
			chosen_type = GameEnums.GemType.SUPPORT
		else:
			chosen_type = GameEnums.GemType.PASSIVE
	var pool: Array[String] = get_ids_by_type(chosen_type)
	if pool.is_empty():
		return "acorn_barrage"
	# Make Prismatic Mastery slightly rarer among passives
	var picked: String = pool[rng.randi() % pool.size()]
	if picked == "pas_prism_mastery" and rng.randf() < 0.55 and pool.size() > 1:
		picked = pool[rng.randi() % (pool.size() - 1)]
	return picked
