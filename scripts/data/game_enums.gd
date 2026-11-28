class_name GameEnums

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

enum CardKind {
	TEMPLATE,
	ADDON,
}

enum CardCategory {
	ATTACK,
	SPELL,
	UTILITY,
	KEYSTONE,
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
			return Color(0.84, 0.86, 0.90)
		Rarity.UNCOMMON:
			return Color(0.36, 0.86, 0.56)
		Rarity.RARE:
			return Color(1.0, 0.84, 0.28)
		Rarity.LEGENDARY:
			return Color(1.0, 0.48, 0.20)
	return Color.WHITE

static func rarity_hex(rarity: int) -> String:
	return "#" + rarity_color(rarity).to_html(false)

static func rarity_label(rarity: int) -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"
		Rarity.UNCOMMON:
			return "Uncommon"
		Rarity.RARE:
			return "Rare"
		Rarity.LEGENDARY:
			return "Legendary"
	return "Common"

static func rarity_forge_limit(rarity: int) -> int:
	match rarity:
		Rarity.COMMON:
			return 1
		Rarity.UNCOMMON:
			return 2
		Rarity.RARE:
			return 3
		Rarity.LEGENDARY:
			return 4
	return 1

static func card_kind_label(kind: int) -> String:
	match kind:
		CardKind.TEMPLATE:
			return "TEMPLATE"
		CardKind.ADDON:
			return "ADD-ON"
	return "CARD"

static func category_color(cat: int) -> Color:
	match cat:
		CardCategory.ATTACK:
			return Color(0.40, 0.86, 0.52)
		CardCategory.SPELL:
			return Color(0.42, 0.74, 1.0)
		CardCategory.UTILITY:
			return Color(0.96, 0.78, 0.34)
		CardCategory.KEYSTONE:
			return Color(1.0, 0.50, 0.28)
	return Color(0.84, 0.86, 0.90)

static func category_label(cat: int) -> String:
	match cat:
		CardCategory.ATTACK:
			return "Attack"
		CardCategory.SPELL:
			return "Spell"
		CardCategory.UTILITY:
			return "Utility"
		CardCategory.KEYSTONE:
			return "Keystone"
	return "Card"

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
	return "Skill"
