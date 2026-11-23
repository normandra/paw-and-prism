class_name GameEnums

enum Rarity {
	COMMON,
	MAGIC,
	RARE,
	UNIQUE,
}

enum EquipSlot {
	WEAPON,
	HELMET,
	ARMOR,
	BOOTS,
	AMULET,
	RING,
}

enum GemType {
	ACTIVE,
	SUPPORT,
	PASSIVE,
}

enum GemColor {
	RED,
	GREEN,
	BLUE,
	WHITE,
}

enum SkillTag {
	PROJECTILE,
	AOE,
	MELEE,
	SPELL,
	CHAIN,
	ORBIT,
	FIRE,
	COLD,
	LIGHTNING,
	PHYSICAL,
	MINION,
	AURA,
}

enum StatType {
	MAX_HP,
	ARMOR,
	HP_REGEN,
	MOVE_SPEED_PCT,
	PICKUP_RADIUS_PCT,
	DAMAGE_PCT,
	FLAT_DAMAGE,
	CAST_SPEED_PCT,
	CRIT_CHANCE,
	CRIT_MULT,
	AREA_PCT,
	PROJ_SPEED_PCT,
	EXTRA_PROJ,
	LIFE_ON_HIT,
	XP_GAIN_PCT,
	MAGIC_FIND_PCT,
	DMG_REDUCTION_PCT,
}

static func rarity_color(rarity: int) -> Color:
	match rarity:
		Rarity.COMMON:
			return Color(0.86, 0.88, 0.92)
		Rarity.MAGIC:
			return Color(0.42, 0.72, 1.0)
		Rarity.RARE:
			return Color(1.0, 0.85, 0.30)
		Rarity.UNIQUE:
			return Color(1.0, 0.50, 0.16)
	return Color.WHITE

static func rarity_label(rarity: int) -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"
		Rarity.MAGIC:
			return "Magic"
		Rarity.RARE:
			return "Rare"
		Rarity.UNIQUE:
			return "Unique"
	return "Common"

static func gem_color_value(gcolor: int) -> Color:
	match gcolor:
		GemColor.RED:
			return Color(0.95, 0.30, 0.28)
		GemColor.GREEN:
			return Color(0.32, 0.88, 0.44)
		GemColor.BLUE:
			return Color(0.34, 0.64, 1.0)
		GemColor.WHITE:
			return Color(0.95, 0.96, 1.0)
	return Color.WHITE

static func gem_color_hex(gcolor: int) -> String:
	match gcolor:
		GemColor.RED:
			return "#f24d47"
		GemColor.GREEN:
			return "#52e070"
		GemColor.BLUE:
			return "#57a3ff"
		GemColor.WHITE:
			return "#f2f5ff"
	return "#ffffff"

static func gem_color_letter(gcolor: int) -> String:
	match gcolor:
		GemColor.RED:
			return "R"
		GemColor.GREEN:
			return "G"
		GemColor.BLUE:
			return "B"
		GemColor.WHITE:
			return "W"
	return "?"

static func gem_type_label(gtype: int) -> String:
	match gtype:
		GemType.ACTIVE:
			return "ACTIVE"
		GemType.SUPPORT:
			return "SUPPORT"
		GemType.PASSIVE:
			return "PASSIVE"
	return "GEM"

static func slot_label(slot: int) -> String:
	match slot:
		EquipSlot.WEAPON:
			return "Weapon"
		EquipSlot.HELMET:
			return "Helmet"
		EquipSlot.ARMOR:
			return "Armor"
		EquipSlot.BOOTS:
			return "Boots"
		EquipSlot.AMULET:
			return "Amulet"
		EquipSlot.RING:
			return "Ring"
	return "Gear"

static func slot_max_sockets(slot: int) -> int:
	match slot:
		EquipSlot.WEAPON, EquipSlot.ARMOR:
			return 4
		EquipSlot.HELMET, EquipSlot.BOOTS:
			return 3
		EquipSlot.AMULET, EquipSlot.RING:
			return 2
	return 2

static func skill_tag_label(tag: int) -> String:
	match tag:
		SkillTag.PROJECTILE:
			return "Projectile"
		SkillTag.AOE:
			return "AoE"
		SkillTag.MELEE:
			return "Melee"
		SkillTag.SPELL:
			return "Spell"
		SkillTag.CHAIN:
			return "Chain"
		SkillTag.ORBIT:
			return "Orbit"
		SkillTag.FIRE:
			return "Fire"
		SkillTag.COLD:
			return "Cold"
		SkillTag.LIGHTNING:
			return "Lightning"
		SkillTag.PHYSICAL:
			return "Physical"
		SkillTag.MINION:
			return "Minion"
		SkillTag.AURA:
			return "Aura"
	return "Skill"

static func stat_label(stat: int) -> String:
	match stat:
		StatType.MAX_HP:
			return "Max HP"
		StatType.ARMOR:
			return "Armor"
		StatType.HP_REGEN:
			return "HP Regen/s"
		StatType.MOVE_SPEED_PCT:
			return "Move Speed"
		StatType.PICKUP_RADIUS_PCT:
			return "Pickup Radius"
		StatType.DAMAGE_PCT:
			return "Damage"
		StatType.FLAT_DAMAGE:
			return "Flat Damage"
		StatType.CAST_SPEED_PCT:
			return "Attack/Cast Speed"
		StatType.CRIT_CHANCE:
			return "Crit Chance"
		StatType.CRIT_MULT:
			return "Crit Damage"
		StatType.AREA_PCT:
			return "Area Size"
		StatType.PROJ_SPEED_PCT:
			return "Projectile Speed"
		StatType.EXTRA_PROJ:
			return "Extra Projectiles"
		StatType.LIFE_ON_HIT:
			return "Life on Hit"
		StatType.XP_GAIN_PCT:
			return "XP Gain"
		StatType.MAGIC_FIND_PCT:
			return "Magic Find"
		StatType.DMG_REDUCTION_PCT:
			return "Damage Reduction"
	return "Stat"

static func is_percent_stat(stat: int) -> bool:
	match stat:
		StatType.MOVE_SPEED_PCT, StatType.PICKUP_RADIUS_PCT, StatType.DAMAGE_PCT, \
		StatType.CAST_SPEED_PCT, StatType.CRIT_CHANCE, StatType.CRIT_MULT, \
		StatType.AREA_PCT, StatType.PROJ_SPEED_PCT, StatType.XP_GAIN_PCT, \
		StatType.MAGIC_FIND_PCT, StatType.DMG_REDUCTION_PCT:
			return true
	return false

static func format_stat(stat: int, value: float) -> String:
	var sign_prefix: String = "+" if value >= 0.0 else ""
	if is_percent_stat(stat):
		return "%s%d%% %s" % [sign_prefix, int(round(value)), stat_label(stat)]
	if stat == StatType.HP_REGEN or stat == StatType.LIFE_ON_HIT:
		return "%s%.1f %s" % [sign_prefix, value, stat_label(stat)]
	return "%s%d %s" % [sign_prefix, int(round(value)), stat_label(stat)]
