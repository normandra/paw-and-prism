class_name RelicDatabase
extends RefCounted

const RELICS: Dictionary = {
	"relic_golden_acorn": {
		"name": "Golden Acorn",
		"rarity": GameEnums.Rarity.UNCOMMON,
		"cost": 70,
		"tag": "+30% Gold",
		"accent": Color(0.98, 0.80, 0.24),
		"desc": "All Gold pickups from critters, Elites, Bosses, and chests grant +30% more Gold.",
	},
	"relic_merchant_bell": {
		"name": "Merchant's Bell",
		"rarity": GameEnums.Rarity.UNCOMMON,
		"cost": 75,
		"tag": "20% Discount",
		"accent": Color(0.96, 0.66, 0.30),
		"desc": "All Shop purchases and Rerolls cost 20% less Gold for the rest of the run.",
	},
	"relic_lucky_dice": {
		"name": "Prism Dice",
		"rarity": GameEnums.Rarity.RARE,
		"cost": 80,
		"tag": "+10% Crit",
		"accent": Color(0.76, 0.44, 0.96),
		"desc": "Permanently grants +10% Crit Chance and +25% Crit Damage to every equipped Template Card.",
	},
	"relic_forge_hammer": {
		"name": "Masterwork Anvil",
		"rarity": GameEnums.Rarity.LEGENDARY,
		"cost": 95,
		"tag": "+1 Forge Slot",
		"accent": Color(1.0, 0.56, 0.24),
		"desc": "All current and future Template Cards gain +1 maximum Forge Slot.",
	},
	"relic_hourglass": {
		"name": "Meadow Hourglass",
		"rarity": GameEnums.Rarity.RARE,
		"cost": 90,
		"tag": "-15% Cooldown",
		"accent": Color(0.38, 0.84, 0.96),
		"desc": "Reduces all equipped Template Card cooldowns by 15%.",
	},
	"relic_honey_jar": {
		"name": "Endless Honey Jar",
		"rarity": GameEnums.Rarity.UNCOMMON,
		"cost": 75,
		"tag": "+25 HP & Shop Heal",
		"accent": Color(0.98, 0.72, 0.26),
		"desc": "+25 Max HP and restores 25 HP whenever you enter a Shop.",
	},
	"relic_feather_boots": {
		"name": "Swiftwind Feather",
		"rarity": GameEnums.Rarity.UNCOMMON,
		"cost": 70,
		"tag": "+12% Spd & +50% Mag",
		"accent": Color(0.46, 0.92, 0.72),
		"desc": "Grants +12% Move Speed and +50% Gold pickup magnet radius.",
	},
	"relic_mirror_shard": {
		"name": "Prism Mirror",
		"rarity": GameEnums.Rarity.LEGENDARY,
		"cost": 110,
		"tag": "Every 5th Echoes",
		"accent": Color(0.68, 0.78, 1.0),
		"desc": "Every 5th Template Card trigger fires a bonus Echo cast immediately.",
	},
	"relic_spiked_collar": {
		"name": "Bramble Collar",
		"rarity": GameEnums.Rarity.UNCOMMON,
		"cost": 75,
		"tag": "+30 HP & +0.25s iFrame",
		"accent": Color(0.92, 0.36, 0.44),
		"desc": "Grants +30 Max HP and +0.25s post-hit invulnerability.",
	},
	"relic_magnet_clover": {
		"name": "Clover Magnet",
		"rarity": GameEnums.Rarity.COMMON,
		"cost": 65,
		"tag": "2.4x Mag & +15% Gold",
		"accent": Color(0.38, 0.88, 0.42),
		"desc": "Pulls dropped Gold from 2.4x further away and boosts Gold value by +15%.",
	},
	"relic_ember_lantern": {
		"name": "Ember Lantern",
		"rarity": GameEnums.Rarity.RARE,
		"cost": 85,
		"tag": "+40% Burn & +1.5s",
		"accent": Color(1.0, 0.42, 0.18),
		"desc": "All Burn effects deal +40% DPS and last 1.5s longer.",
	},
	"relic_frost_compass": {
		"name": "Glacier Compass",
		"rarity": GameEnums.Rarity.RARE,
		"cost": 85,
		"tag": "+18% vs Chilled",
		"accent": Color(0.42, 0.80, 1.0),
		"desc": "Chilled enemies take +18% increased damage from all hits.",
	},
}


static func get_def(relic_id: String) -> Dictionary:
	return RELICS.get(relic_id, RELICS["relic_golden_acorn"])


static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for k in RELICS.keys():
		ids.append(str(k))
	return ids


static func get_unowned_ids(owned: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for k in RELICS.keys():
		var sid: String = str(k)
		if not owned.has(sid):
			out.append(sid)
	return out
