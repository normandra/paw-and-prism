class_name HeroDatabase

static func get_all_heroes() -> Array[Dictionary]:
	return [
		{
			"id": "shiba",
			"hero_name": "Mochi the Shiba",
			"title": "Acorn Forgemaster",
			"tagline": "Loot Template & Add-on Cards, forge permanent combos, and defeat all 3 Bosses!",
			"primary_color": Color(0.86, 0.49, 0.17),
			"secondary_color": Color(0.98, 0.91, 0.80),
			"accent_color": Color(0.90, 0.22, 0.24),
			"base_hp": 110.0,
			"base_speed": 6.7,
			"starter_template_id": "acorn_barrage",
			"starter_template_rarity": GameEnums.Rarity.UNCOMMON,
		},
	]

static func get_hero(_hero_id: String = "shiba") -> Dictionary:
	return get_all_heroes()[0]
