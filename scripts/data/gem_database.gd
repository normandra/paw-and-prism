class_name GemDatabase

static var _gems: Dictionary = {}
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true
	_gems.clear()

	# === 10 MAIN SOCKET ABILITIES ===
	_add({
		"id": "acorn_barrage",
		"gem_name": "Acorn Barrage",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 24.0,
		"cooldown": 0.65,
		"proj_speed": 22.0,
		"base_projectiles": 1,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "ACRN",
		"desc": "Aimed flying acorns",
	})
	_add({
		"id": "starlight_orb",
		"gem_name": "Starlight Orbs",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.ORBIT, GameEnums.SkillTag.AOE],
		"base_damage": 21.0,
		"cooldown": 0.45,
		"proj_speed": 3.4,
		"base_projectiles": 2,
		"pierce": 99,
		"area_radius": 3.4,
		"short": "STAR",
		"desc": "Orbiting star blades",
	})
	_add({
		"id": "honey_slam",
		"gem_name": "Honey Slam",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.MELEE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 42.0,
		"cooldown": 1.25,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 4.3,
		"short": "SLAM",
		"desc": "Slowing honey shockwave",
	})
	_add({
		"id": "whisker_lightning",
		"gem_name": "Whisker Lightning",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.CHAIN, GameEnums.SkillTag.LIGHTNING],
		"base_damage": 28.0,
		"cooldown": 0.88,
		"proj_speed": 30.0,
		"base_projectiles": 1,
		"base_chains": 2,
		"pierce": 0,
		"area_radius": 1.0,
		"short": "ZAP",
		"desc": "Arcing static bolts",
	})
	_add({
		"id": "petal_cyclone",
		"gem_name": "Petal Cyclone",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 17.0,
		"cooldown": 1.08,
		"proj_speed": 15.0,
		"base_projectiles": 6,
		"pierce": 1,
		"area_radius": 0.55,
		"short": "PETL",
		"desc": "Spiraling petal ring",
	})
	_add({
		"id": "fireball_berry",
		"gem_name": "Fireball Berry",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 34.0,
		"cooldown": 1.18,
		"proj_speed": 18.0,
		"base_projectiles": 1,
		"pierce": 0,
		"area_radius": 3.2,
		"short": "FIRE",
		"desc": "Explosive burning berry",
	})
	_add({
		"id": "frost_nova",
		"gem_name": "Frost Nova",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.BLUE,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.AOE, GameEnums.SkillTag.COLD],
		"base_damage": 22.0,
		"cooldown": 1.45,
		"proj_speed": 15.0,
		"base_projectiles": 8,
		"pierce": 1,
		"area_radius": 4.2,
		"short": "FRST",
		"desc": "Chill ring + ice shards",
	})
	_add({
		"id": "boomerang_bone",
		"gem_name": "Boomerang Bone",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 28.0,
		"cooldown": 1.08,
		"proj_speed": 18.5,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 0.75,
		"short": "BONE",
		"desc": "Returning piercing bone",
	})
	_add({
		"id": "meteor_pine",
		"gem_name": "Meteor Pinecone",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.RED,
		"tags": [GameEnums.SkillTag.SPELL, GameEnums.SkillTag.AOE, GameEnums.SkillTag.FIRE],
		"base_damage": 66.0,
		"cooldown": 2.05,
		"proj_speed": 0.0,
		"base_projectiles": 1,
		"pierce": 99,
		"area_radius": 4.2,
		"short": "PINE",
		"desc": "Heavy pinecone crash",
	})
	_add({
		"id": "spirit_bees",
		"gem_name": "Spirit Bees",
		"gem_type": GameEnums.GemType.MAIN,
		"color": GameEnums.GemColor.GREEN,
		"tags": [GameEnums.SkillTag.MINION, GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.PHYSICAL],
		"base_damage": 20.0,
		"cooldown": 0.98,
		"proj_speed": 16.5,
		"base_projectiles": 2,
		"pierce": 0,
		"area_radius": 0.55,
		"short": "BEES",
		"desc": "Seeking spirit bees",
	})

	# === 10 BEHAVIORAL MODIFIER ABILITIES ===
	_add({
		"id": "mod_multishot",
		"gem_name": "Multi-Shot",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.ORBIT],
		"short": "MULT",
		"desc": "+2 Fan Shots",
		"mods": {"extra_proj": 2, "dmg_mult": 0.80},
	})
	_add({
		"id": "mod_chain",
		"gem_name": "Chain Bounce",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE, GameEnums.SkillTag.CHAIN],
		"short": "CHN",
		"desc": "Bounces +2 Foes",
		"mods": {"extra_chains": 2},
	})
	_add({
		"id": "mod_fork",
		"gem_name": "Twin Fork",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "FORK",
		"desc": "Splits x2 on Hit",
		"mods": {"fork": 1},
	})
	_add({
		"id": "mod_pierce",
		"gem_name": "Deep Pierce",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "PRCE",
		"desc": "Pierces +3 Foes",
		"mods": {"extra_pierce": 3},
	})
	_add({
		"id": "mod_homing",
		"gem_name": "Homing Seekers",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.GREEN,
		"required_tags": [GameEnums.SkillTag.PROJECTILE],
		"short": "HOME",
		"desc": "Curves to Targets",
		"mods": {"homing": 1, "proj_speed_mult": 1.15},
	})
	_add({
		"id": "mod_echo",
		"gem_name": "Double Echo",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [],
		"short": "ECHO",
		"desc": "Casts Twice",
		"mods": {"echo": 1, "dmg_mult": 0.78},
	})
	_add({
		"id": "mod_nova_area",
		"gem_name": "Giant Blast",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [GameEnums.SkillTag.AOE, GameEnums.SkillTag.ORBIT],
		"short": "WIDE",
		"desc": "Massive Area",
		"mods": {"area_mult": 1.55},
	})
	_add({
		"id": "mod_ignite",
		"gem_name": "Blazing Burn",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.RED,
		"required_tags": [],
		"short": "BURN",
		"desc": "Ignites + Burn",
		"mods": {"ignite": 1},
	})
	_add({
		"id": "mod_chill",
		"gem_name": "Frost Chill",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.BLUE,
		"required_tags": [],
		"short": "CHIL",
		"desc": "Chills & Slows",
		"mods": {"chill": 1},
	})
	_add({
		"id": "mod_leech",
		"gem_name": "Life Siphon",
		"gem_type": GameEnums.GemType.MODIFIER,
		"color": GameEnums.GemColor.RED,
		"required_tags": [],
		"short": "HEAL",
		"desc": "Hits Heal You",
		"mods": {"leech_pct": 5.5},
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

static func does_modifier_apply(mod_id: String, main_id: String) -> bool:
	var mod_def: Dictionary = get_def(mod_id)
	var main_def: Dictionary = get_def(main_id)
	if mod_def.is_empty() or main_def.is_empty():
		return false
	if int(mod_def.get("gem_type", -1)) != GameEnums.GemType.MODIFIER:
		return false
	if int(main_def.get("gem_type", -1)) != GameEnums.GemType.MAIN:
		return false
	var req_tags: Array = mod_def.get("required_tags", [])
	if req_tags.is_empty():
		return true
	var main_tags: Array = main_def.get("tags", [])
	for t in req_tags:
		if main_tags.has(t):
			return true
	return false

static func roll_random_gem_id(rng: RandomNumberGenerator, preferred_type: int = -1) -> String:
	_ensure_init()
	var chosen_type: int = preferred_type
	if chosen_type == -1:
		chosen_type = GameEnums.GemType.MAIN if rng.randf() < 0.45 else GameEnums.GemType.MODIFIER
	var pool: Array[String] = get_ids_by_type(chosen_type)
	if pool.is_empty():
		return "acorn_barrage"
	return pool[rng.randi() % pool.size()]
