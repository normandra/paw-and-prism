class_name HeroStats

var hero_id: String = "shiba"

# Unlimited Active Deck of Template Cards + Collections
var equipped_cards: Array[CardInstance] = []
var template_inventory: Array[CardInstance] = []
var addon_inventory: Array[CardInstance] = []
const MAX_TEMPLATE_INV: int = 36
const MAX_ADDON_INV: int = 36

# Baseline Hero Vitals
var max_hp: float = 110.0
var hp_regen: float = BalanceConfig.BASE_HP_REGEN
var move_speed: float = 6.7
var crit_chance: float = BalanceConfig.BASE_CRIT_CHANCE
var crit_mult: float = BalanceConfig.BASE_CRIT_MULT

# Aggregated Deck-Wide Utility/Defense Stacks (derived from forged Add-ons on active cards)
var active_forged_summary: Array[Dictionary] = []
var glass_stacks: int = 0
var ember_corpse_stacks: int = 0
var frost_shatter_stacks: int = 0
var zoomies_stacks: int = 0
var thorns_stacks: int = 0
var orbit_shield_stacks: int = 0
var nine_lives_stacks: int = 0

var incoming_dmg_mult: float = 1.0
var has_zoomies_on_kill: bool = false
var has_ember_corpse: bool = false
var has_frost_shatter: bool = false
var has_thorns_burst: bool = false
var has_orbit_shield: bool = false
var has_cheat_death: bool = false

# Economy & Relics
var gold: int = BalanceConfig.STARTING_GOLD
var total_gold_earned: int = BalanceConfig.STARTING_GOLD
var owned_relics: Array[String] = []
var bonus_forge_slots: int = 0
var gold_mult: float = 1.0
var shop_price_mult: float = 1.0
var magnet_mult: float = 1.0
var relic_cd_mult: float = 1.0
var extra_invuln_sec: float = 0.0
var burn_dps_mult: float = 1.0
var burn_dur_bonus: float = 0.0
var chilled_vuln_mult: float = 1.0
var has_prism_mirror: bool = false
var shop_enter_heal: float = 0.0

# Compiled Active Card Skill Configs
var active_skill_configs: Array[Dictionary] = []
var equipped_card_count: int = 0
var deck_cd_mult: float = 1.0

func _init(p_hero_id: String = "shiba") -> void:
	init_for_hero(p_hero_id)

func _reset_empty(p_hero_id: String = "shiba") -> void:
	hero_id = p_hero_id
	equipped_cards.clear()
	template_inventory.clear()
	addon_inventory.clear()
	owned_relics.clear()
	gold = BalanceConfig.STARTING_GOLD
	total_gold_earned = BalanceConfig.STARTING_GOLD

func init_bare_for_tutorial(p_hero_id: String = "shiba") -> void:
	_reset_empty(p_hero_id)
	gold = 0
	total_gold_earned = 0
	recompute()

func init_for_hero(p_hero_id: String = "shiba") -> void:
	_reset_empty(p_hero_id)
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	var starter_id: String = String(hdef.get("starter_template_id", "acorn_barrage"))
	var starter_rarity: int = int(hdef.get("starter_template_rarity", GameEnums.Rarity.UNCOMMON))
	var starter: CardInstance = CardInstance.new(starter_id, starter_rarity)
	equipped_cards.append(starter)
	recompute()

func add_gold(base_amount: int) -> int:
	var gained: int = maxi(1, int(round(float(base_amount) * gold_mult)))
	gold += gained
	total_gold_earned += gained
	return gained

func spend_gold(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	return true

func has_relic(relic_id: String) -> bool:
	return owned_relics.has(relic_id)

func add_relic(relic_id: String) -> bool:
	if owned_relics.has(relic_id):
		return false
	owned_relics.append(relic_id)
	recompute()
	return true

func get_max_forges_for(card: CardInstance) -> int:
	if card == null:
		return 0
	return card.get_max_forges(bonus_forge_slots)

func can_add_template() -> bool:
	return template_inventory.size() < MAX_TEMPLATE_INV

func can_add_addon() -> bool:
	return addon_inventory.size() < MAX_ADDON_INV

func add_card_to_inventory(card: CardInstance) -> bool:
	if card == null:
		return false
	if card.is_template():
		if not can_add_template():
			return false
		template_inventory.append(card)
		return true
	if not can_add_addon():
		return false
	addon_inventory.append(card)
	return true

func equip_template_from_inventory(inv_idx: int) -> Dictionary:
	if inv_idx < 0 or inv_idx >= template_inventory.size():
		return {"ok": false}
	var card: CardInstance = template_inventory[inv_idx]
	template_inventory.remove_at(inv_idx)
	equipped_cards.append(card)
	recompute()
	return {"ok": true, "card": card}

func unequip_template_card(eq_idx: int) -> Dictionary:
	if eq_idx < 0 or eq_idx >= equipped_cards.size():
		return {"ok": false}
	var card: CardInstance = equipped_cards[eq_idx]
	equipped_cards.remove_at(eq_idx)
	template_inventory.append(card)
	recompute()
	return {"ok": true, "card": card}

func forge_addon_onto_card(addon_idx: int, target_card: CardInstance) -> Dictionary:
	if addon_idx < 0 or addon_idx >= addon_inventory.size() or target_card == null:
		return {"ok": false, "reason": "Invalid card selection"}
	var addon: CardInstance = addon_inventory[addon_idx]
	var check: Dictionary = target_card.can_accept_addon(addon, bonus_forge_slots)
	if not bool(check.get("ok", false)):
		return check
	var applied: bool = target_card.apply_forge(addon.card_id, bonus_forge_slots)
	if not applied:
		return {"ok": false, "reason": "Forge failed"}
	# Consumes the Add-on Card permanently
	addon_inventory.remove_at(addon_idx)
	recompute()
	return {
		"ok": true,
		"template": target_card,
		"addon_card": addon,
		"addon_id": addon.card_id,
		"addon_name": addon.get_card_name(),
	}

func discard_template(inv_idx: int) -> bool:
	if inv_idx < 0 or inv_idx >= template_inventory.size():
		return false
	template_inventory.remove_at(inv_idx)
	return true

func discard_addon(addon_idx: int) -> bool:
	if addon_idx < 0 or addon_idx >= addon_inventory.size():
		return false
	addon_inventory.remove_at(addon_idx)
	return true

func recompute() -> void:
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	max_hp = float(hdef["base_hp"])
	hp_regen = BalanceConfig.BASE_HP_REGEN
	move_speed = float(hdef["base_speed"])
	crit_chance = BalanceConfig.BASE_CRIT_CHANCE
	crit_mult = BalanceConfig.BASE_CRIT_MULT

	# Apply Slay-the-Spire style Relics
	bonus_forge_slots = 1 if has_relic("relic_forge_hammer") else 0
	gold_mult = 1.0 + (0.30 if has_relic("relic_golden_acorn") else 0.0) + (0.15 if has_relic("relic_magnet_clover") else 0.0)
	shop_price_mult = 0.80 if has_relic("relic_merchant_bell") else 1.0
	magnet_mult = 1.0 * (1.50 if has_relic("relic_feather_boots") else 1.0) * (2.40 if has_relic("relic_magnet_clover") else 1.0)
	relic_cd_mult = 0.85 if has_relic("relic_hourglass") else 1.0
	extra_invuln_sec = 0.25 if has_relic("relic_spiked_collar") else 0.0
	burn_dps_mult = 1.40 if has_relic("relic_ember_lantern") else 1.0
	burn_dur_bonus = 1.5 if has_relic("relic_ember_lantern") else 0.0
	chilled_vuln_mult = 1.18 if has_relic("relic_frost_compass") else 1.0
	has_prism_mirror = has_relic("relic_mirror_shard")
	shop_enter_heal = 25.0 if has_relic("relic_honey_jar") else 0.0

	if has_relic("relic_lucky_dice"):
		crit_chance += 10.0
		crit_mult += 25.0
	if has_relic("relic_honey_jar"):
		max_hp += 25.0
	if has_relic("relic_spiked_collar"):
		max_hp += 30.0
	if has_relic("relic_feather_boots"):
		move_speed *= 1.12

	equipped_card_count = equipped_cards.size()
	deck_cd_mult = BalanceConfig.compute_deck_cd_mult(equipped_card_count)

	# Count deck-wide forged utility/defense/glass stacks across all equipped cards
	var addon_totals: Dictionary = {}
	var addon_order: Array[String] = []
	for card in equipped_cards:
		if card == null:
			continue
		for aid in card.forged_addons:
			if not addon_totals.has(aid):
				addon_totals[aid] = 0
				addon_order.append(aid)
			addon_totals[aid] = int(addon_totals[aid]) + 1

	glass_stacks = int(addon_totals.get("addon_glass_spark", 0))
	ember_corpse_stacks = int(addon_totals.get("addon_ember_corpse", 0))
	frost_shatter_stacks = int(addon_totals.get("addon_frost_shatter", 0))
	zoomies_stacks = int(addon_totals.get("addon_zoomies", 0))
	thorns_stacks = int(addon_totals.get("addon_thorns", 0))
	orbit_shield_stacks = int(addon_totals.get("addon_orbit_shield", 0))
	nine_lives_stacks = int(addon_totals.get("addon_nine_lives", 0))

	incoming_dmg_mult = minf(BalanceConfig.GLASS_TAKEN_CAP, 1.0 + BalanceConfig.GLASS_TAKEN_BONUS * float(glass_stacks))
	has_zoomies_on_kill = zoomies_stacks > 0
	has_ember_corpse = ember_corpse_stacks > 0
	has_frost_shatter = frost_shatter_stacks > 0
	has_thorns_burst = thorns_stacks > 0
	has_orbit_shield = orbit_shield_stacks > 0
	has_cheat_death = nine_lives_stacks > 0

	active_forged_summary.clear()
	for aid in addon_order:
		var adef: Dictionary = CardDatabase.get_def(aid)
		active_forged_summary.append({
			"id": aid,
			"name": String(adef.get("card_name", aid)),
			"count": int(addon_totals[aid]),
			"rarity": int(adef.get("rarity", GameEnums.Rarity.COMMON)),
		})

	active_skill_configs.clear()
	for card in equipped_cards:
		if card == null:
			continue
		active_skill_configs.append(compile_card_config(card, deck_cd_mult, crit_chance, crit_mult, relic_cd_mult))

static func compile_card_config(card: CardInstance, p_deck_cd_mult: float = 1.0, p_crit_chance: float = BalanceConfig.BASE_CRIT_CHANCE, p_crit_mult: float = BalanceConfig.BASE_CRIT_MULT, p_relic_cd_mult: float = 1.0) -> Dictionary:
	var def: Dictionary = card.get_def()
	var final_dmg: float = float(def.get("base_damage", 20.0))
	var final_cd: float = float(def.get("cooldown", 1.0))
	var base_proj: int = int(def.get("base_projectiles", 1))
	var base_chains: int = int(def.get("base_chains", 0))
	var base_pierce: int = int(def.get("pierce", 0))
	var base_area: float = float(def.get("area_radius", 1.0))
	var final_speed: float = float(def.get("proj_speed", 16.0))

	# Group forged Add-ons by ID so stacking scales deterministically regardless of forge order
	var counts: Dictionary = {}
	for aid in card.forged_addons:
		counts[aid] = int(counts.get(aid, 0)) + 1

	var extra_proj: int = 0
	var extra_chains: int = 0
	var extra_pierce: int = 0
	var forks: int = 0
	var homing: bool = false
	var echo_count: int = 0
	var area_mult: float = 1.0
	var ignite: bool = false
	var burn_mult: float = 1.0
	var chill: bool = false
	var leech_pct: float = 0.0
	var lifetime_mult: float = 1.0
	var ricochet: bool = false
	var nova_360: bool = false
	var nova_min_proj: int = 6
	var pull_inward: bool = false
	var cadence_stacks: int = 0
	var turret_still_mult: float = 1.0
	var turret_move_mult: float = 1.0

	if counts.has("addon_multishot"):
		var k: int = int(counts["addon_multishot"])
		extra_proj += 2 * k
		final_dmg *= pow(0.78, k)
	if counts.has("addon_chain"):
		var k: int = int(counts["addon_chain"])
		extra_chains += 2 * k
		final_dmg *= pow(0.92, k)
	if counts.has("addon_fork"):
		var k: int = int(counts["addon_fork"])
		forks += mini(BalanceConfig.MAX_FORK_GENERATIONS, k)
		final_dmg *= pow(0.90, k)
	if counts.has("addon_pierce"):
		extra_pierce += 3 * int(counts["addon_pierce"])
	if counts.has("addon_homing"):
		var k: int = int(counts["addon_homing"])
		homing = true
		final_speed *= (1.0 + 0.15 * float(k))
		final_dmg *= pow(0.95, k)
	if counts.has("addon_echo"):
		var k: int = int(counts["addon_echo"])
		echo_count += k
		final_dmg *= pow(0.74, k)
	if counts.has("addon_giant_blast"):
		var k: int = int(counts["addon_giant_blast"])
		area_mult *= (1.0 + BalanceConfig.GIANT_AOE_RADIUS_STEP * float(k))
	if counts.has("addon_ignite"):
		var k: int = int(counts["addon_ignite"])
		ignite = true
		burn_mult = 1.0 + 0.15 * float(k - 1)
	if counts.has("addon_chill"):
		chill = true
	if counts.has("addon_leech"):
		var k: int = int(counts["addon_leech"])
		leech_pct += BalanceConfig.LEECH_PCT_FIRST + BalanceConfig.LEECH_PCT_STACK * float(k - 1)
	if counts.has("addon_short_barrage"):
		var k: int = int(counts["addon_short_barrage"])
		extra_proj += BalanceConfig.SHORT_BARRAGE_PROJ * k
		lifetime_mult = maxf(0.30, lifetime_mult * pow(BalanceConfig.SHORT_BARRAGE_LIFE_MULT, k))
	if counts.has("addon_gravity_pull"):
		var k: int = int(counts["addon_gravity_pull"])
		pull_inward = true
		area_mult *= (1.0 + 0.15 * float(k - 1))
	if counts.has("addon_ricochet"):
		var k: int = int(counts["addon_ricochet"])
		ricochet = true
		final_speed *= (1.0 + 0.12 * float(k - 1))
	if counts.has("addon_nova_ring"):
		var k: int = int(counts["addon_nova_ring"])
		nova_360 = true
		nova_min_proj = 6 + 2 * (k - 1)
	if counts.has("addon_cadence_burst"):
		var k: int = int(counts["addon_cadence_burst"])
		cadence_stacks = k
		final_cd *= pow(BalanceConfig.CADENCE_CD_MULT, k)
	if counts.has("addon_overclock"):
		var k: int = int(counts["addon_overclock"])
		turret_still_mult = BalanceConfig.TURRET_STILL_FIRST + BalanceConfig.TURRET_STILL_STACK * float(k - 1)
		turret_move_mult = BalanceConfig.TURRET_MOVE_RATE
	if counts.has("addon_glass_spark"):
		var k: int = int(counts["addon_glass_spark"])
		final_dmg *= (1.0 + BalanceConfig.GLASS_CARD_DMG_BONUS * float(k))

	var tags: Array = card.get_tags()
	var uses_proj: bool = tags.has(GameEnums.SkillTag.PROJECTILE) or tags.has(GameEnums.SkillTag.ORBIT)
	var final_proj: int = base_proj + (extra_proj if uses_proj else 0)
	var final_pierce: int = base_pierce + extra_pierce

	if counts.has("addon_sniper_focus") and tags.has(GameEnums.SkillTag.PROJECTILE):
		var ks: int = int(counts["addon_sniper_focus"])
		final_proj = 1
		final_pierce += BalanceConfig.SNIPER_EXTRA_PIERCE * ks
		final_speed *= BalanceConfig.SNIPER_SPEED_MULT
		final_dmg *= BalanceConfig.SNIPER_DMG_FIRST * pow(BalanceConfig.SNIPER_DMG_STACK, ks - 1)

	final_cd *= p_deck_cd_mult * p_relic_cd_mult
	final_cd = maxf(0.18, final_cd)

	return {
		"uid": card.uid,
		"card_id": card.card_id,
		"card": card,
		"card_name": card.get_display_title(),
		"short": card.get_short_label(),
		"rarity": card.rarity,
		"category": card.get_category(),
		"tags": tags,
		"damage": final_dmg,
		"cooldown": final_cd,
		"projectiles": maxi(1, final_proj),
		"chains": base_chains + extra_chains,
		"pierce": final_pierce,
		"forks": forks,
		"homing": homing or card.card_id == "spirit_bees",
		"echo_count": echo_count,
		"area_radius": base_area * area_mult,
		"area_mult": area_mult,
		"proj_speed": final_speed,
		"lifetime_mult": lifetime_mult,
		"ricochet": ricochet,
		"nova_360": nova_360,
		"nova_min_proj": nova_min_proj,
		"pull_inward": pull_inward,
		"cadence_stacks": cadence_stacks,
		"turret_still_mult": turret_still_mult,
		"turret_move_mult": turret_move_mult,
		"crit_chance": p_crit_chance,
		"crit_mult": p_crit_mult,
		"ignite": ignite or tags.has(GameEnums.SkillTag.FIRE),
		"burn_mult": burn_mult,
		"chill": chill or tags.has(GameEnums.SkillTag.COLD),
		"leech_pct": leech_pct,
		"forged_summary": card.get_forged_summary_counts(),
	}
