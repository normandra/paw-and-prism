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
	MAIN,
	MODIFIER,
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
		GemType.MAIN:
			return "MAIN"
		GemType.MODIFIER:
			return "MOD"
	return "ABILITY"

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
			return "Proj"
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
	return "Skill"
