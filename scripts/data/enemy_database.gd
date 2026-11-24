class_name EnemyDatabase

static var _defs: Dictionary = {}
static var _init_done: bool = false

static func _ensure_init() -> void:
	if _init_done:
		return
	_init_done = true
	_defs = {
		"slime_frog": {
			"id": "slime_frog",
			"enemy_name": "Dewdrop Frog",
			"hp": 26.0,
			"speed": 3.4,
			"damage": 7.0,
			"radius": 0.65,
			"xp": 10.0,
			"color": Color(0.45, 0.88, 0.48),
			"accent": Color(0.84, 0.98, 0.72),
			"is_boss": false,
		},
		"hedgehog": {
			"id": "hedgehog",
			"enemy_name": "Spiky Hedgehog",
			"hp": 36.0,
			"speed": 4.6,
			"damage": 9.0,
			"radius": 0.65,
			"xp": 14.0,
			"color": Color(0.60, 0.42, 0.28),
			"accent": Color(0.95, 0.85, 0.70),
			"is_boss": false,
		},
		"bat_owl": {
			"id": "bat_owl",
			"enemy_name": "Flap Owl-Bat",
			"hp": 32.0,
			"speed": 5.2,
			"damage": 10.0,
			"radius": 0.68,
			"xp": 15.0,
			"color": Color(0.44, 0.36, 0.78),
			"accent": Color(0.95, 0.72, 0.90),
			"is_boss": false,
		},
		"acorn_boar": {
			"id": "acorn_boar",
			"enemy_name": "Tusk Piglet",
			"hp": 78.0,
			"speed": 3.3,
			"damage": 15.0,
			"radius": 0.85,
			"xp": 24.0,
			"color": Color(0.76, 0.40, 0.28),
			"accent": Color(0.98, 0.90, 0.76),
			"is_boss": false,
		},
		"gloom_fox": {
			"id": "gloom_fox",
			"enemy_name": "Gloom Fox",
			"hp": 54.0,
			"speed": 4.0,
			"damage": 13.0,
			"radius": 0.72,
			"xp": 26.0,
			"color": Color(0.56, 0.28, 0.68),
			"accent": Color(0.95, 0.68, 0.98),
			"ranged": true,
			"is_boss": false,
		},
		"raccoon_bandit": {
			"id": "raccoon_bandit",
			"enemy_name": "Bandit Raccoon",
			"hp": 96.0,
			"speed": 4.4,
			"damage": 17.0,
			"radius": 0.80,
			"xp": 38.0,
			"color": Color(0.42, 0.44, 0.50),
			"accent": Color(0.92, 0.92, 0.95),
			"is_boss": false,
		},
		"shroom_toad": {
			"id": "shroom_toad",
			"enemy_name": "Puff Shroom-Toad",
			"hp": 68.0,
			"speed": 3.1,
			"damage": 14.0,
			"radius": 0.78,
			"xp": 28.0,
			"color": Color(0.86, 0.26, 0.30),
			"accent": Color(0.98, 0.94, 0.88),
			"explodes_on_death": true,
			"is_boss": false,
		},
		"boss_grizzle": {
			"id": "boss_grizzle",
			"enemy_name": "Sir Grizzle, Honey-Armored King",
			"hp": 1250.0,
			"speed": 4.0,
			"damage": 24.0,
			"radius": 1.85,
			"color": Color(0.58, 0.34, 0.16),
			"accent": Color(1.0, 0.78, 0.18),
			"is_boss": true,
			"boss_index": 1,
			"spawn_time": 390.0, # 06:30
		},
		"boss_whiskers": {
			"id": "boss_whiskers",
			"enemy_name": "Lady Whiskers, Arcane Owl-Empress",
			"hp": 2800.0,
			"speed": 4.3,
			"damage": 30.0,
			"radius": 1.95,
			"color": Color(0.32, 0.26, 0.66),
			"accent": Color(0.45, 0.90, 1.0),
			"is_boss": true,
			"boss_index": 2,
			"spawn_time": 780.0, # 13:00
		},
		"boss_bramblehorn": {
			"id": "boss_bramblehorn",
			"enemy_name": "King Bramblehorn, Prism Stag-Dragon",
			"hp": 5400.0,
			"speed": 4.6,
			"damage": 38.0,
			"radius": 2.25,
			"color": Color(0.24, 0.14, 0.36),
			"accent": Color(1.0, 0.42, 0.84),
			"is_boss": true,
			"boss_index": 3,
			"spawn_time": 1170.0, # 19:30
		},
	}

static func get_def(enemy_id: String) -> Dictionary:
	_ensure_init()
	return _defs.get(enemy_id, _defs["slime_frog"])

static func get_all_regular_ids() -> Array[String]:
	return ["slime_frog", "hedgehog", "bat_owl", "acorn_boar", "gloom_fox", "raccoon_bandit", "shroom_toad"]

static func get_all_boss_ids() -> Array[String]:
	return ["boss_grizzle", "boss_whiskers", "boss_bramblehorn"]

static func get_wave_profile(elapsed_sec: float) -> Dictionary:
	# 20-minute (1200s) difficulty & pool progression (rebalanced for pure loot-driven power)
	if elapsed_sec < 120.0:
		return {
			"phase_name": "Sunny Meadow",
			"pool": ["slime_frog", "hedgehog"],
			"spawn_interval": 0.95,
			"batch_size": 2,
			"hp_scale": 1.0,
			"dmg_scale": 1.0,
			"max_active": 42,
		}
	elif elapsed_sec < 260.0:
		return {
			"phase_name": "Sunny Meadow",
			"pool": ["slime_frog", "hedgehog", "bat_owl"],
			"spawn_interval": 0.78,
			"batch_size": 3,
			"hp_scale": 1.20,
			"dmg_scale": 1.10,
			"max_active": 62,
		}
	elif elapsed_sec < 420.0:
		return {
			"phase_name": "Sunny Meadow",
			"pool": ["hedgehog", "bat_owl", "acorn_boar", "slime_frog"],
			"spawn_interval": 0.65,
			"batch_size": 3,
			"hp_scale": 1.45,
			"dmg_scale": 1.22,
			"max_active": 80,
		}
	elif elapsed_sec < 640.0:
		return {
			"phase_name": "Golden Sunset",
			"pool": ["bat_owl", "acorn_boar", "gloom_fox", "hedgehog"],
			"spawn_interval": 0.56,
			"batch_size": 4,
			"hp_scale": 1.85,
			"dmg_scale": 1.42,
			"max_active": 96,
		}
	elif elapsed_sec < 840.0:
		return {
			"phase_name": "Golden Sunset",
			"pool": ["acorn_boar", "gloom_fox", "raccoon_bandit", "shroom_toad"],
			"spawn_interval": 0.50,
			"batch_size": 4,
			"hp_scale": 2.35,
			"dmg_scale": 1.65,
			"max_active": 112,
		}
	elif elapsed_sec < 1050.0:
		return {
			"phase_name": "Twilight Grove",
			"pool": ["gloom_fox", "raccoon_bandit", "shroom_toad", "acorn_boar", "bat_owl"],
			"spawn_interval": 0.44,
			"batch_size": 5,
			"hp_scale": 2.95,
			"dmg_scale": 1.90,
			"max_active": 124,
		}
	else:
		return {
			"phase_name": "Twilight Finale",
			"pool": ["raccoon_bandit", "shroom_toad", "gloom_fox", "acorn_boar"],
			"spawn_interval": 0.40,
			"batch_size": 5,
			"hp_scale": 3.60,
			"dmg_scale": 2.20,
			"max_active": 135,
		}
