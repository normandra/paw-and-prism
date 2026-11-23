class_name HeroStats

var hero_id: String = "shiba"
var hero_level: int = 1
var hero_xp: float = 0.0
var hero_xp_to_next: float = 65.0
var prism_dust: int = 20

# Level-up bonus stat accumulators
var level_bonuses: Dictionary = {}

# Equipped slots: EquipSlot -> ItemInstance or null
var equipped: Dictionary = {}
var item_bag: Array[ItemInstance] = []
var gem_pouch: Array[GemInstance] = []
const MAX_BAG_SIZE: int = 24
const MAX_POUCH_SIZE: int = 24

# Computed combat stats
var max_hp: float = 135.0
var armor: float = 6.0
var hp_regen: float = 0.5
var move_speed: float = 8.4
var pickup_radius: float = 4.2
var damage_mult: float = 1.0
var flat_damage: float = 0.0
var cast_speed_mult: float = 1.0
var crit_chance: float = 8.0
var crit_mult: float = 165.0
var area_mult: float = 1.0
var proj_speed_mult: float = 1.0
var extra_projectiles: int = 0
var life_on_hit: float = 0.0
var xp_gain_mult: float = 1.0
var magic_find: float = 0.0
var dmg_reduction: float = 0.0
var dash_cd_mult: float = 1.0

# Unique & Passive flags
var has_cheat_death: bool = false
var has_honey_aegis: bool = false
var has_thorns: bool = false
var global_gem_level_bonus: int = 0

# Compiled PoE Skill & Passive lists
var active_skill_configs: Array[Dictionary] = []
var active_passives: Array[Dictionary] = []

func _init(p_hero_id: String = "shiba") -> void:
	init_for_hero(p_hero_id)

func init_for_hero(p_hero_id: String) -> void:
	hero_id = p_hero_id
	hero_level = 1
	hero_xp = 0.0
	hero_xp_to_next = 65.0
	prism_dust = 25
	level_bonuses.clear()
	equipped.clear()
	item_bag.clear()
	gem_pouch.clear()

	for slot in [
		GameEnums.EquipSlot.WEAPON,
		GameEnums.EquipSlot.HELMET,
		GameEnums.EquipSlot.ARMOR,
		GameEnums.EquipSlot.BOOTS,
		GameEnums.EquipSlot.AMULET,
		GameEnums.EquipSlot.RING,
	]:
		equipped[slot] = null

	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)

	# Build starter weapon with 3-link (Active + Support + empty)
	var weapon: ItemInstance = ItemInstance.new()
	weapon.item_name = String(hdef["starter_weapon_name"])
	weapon.equip_slot = GameEnums.EquipSlot.WEAPON
	weapon.rarity = GameEnums.Rarity.MAGIC
	weapon.item_level = 1
	weapon.visual_style = String(hdef["starter_weapon_style"])
	weapon.affixes = [
		{"stat": GameEnums.StatType.FLAT_DAMAGE, "value": 4.0},
		{"stat": GameEnums.StatType.DAMAGE_PCT, "value": 10.0},
	]
	var w_cols: Array[int] = []
	for c in hdef["starter_weapon_sockets"]:
		w_cols.append(int(c))
	var w_lnks: Array[bool] = []
	for l in hdef["starter_weapon_links"]:
		w_lnks.append(bool(l))
	weapon.setup_sockets(w_cols, w_lnks)
	weapon.insert_gem(0, GemInstance.new(String(hdef["starter_active_gem"]), 1))
	weapon.insert_gem(1, GemInstance.new(String(hdef["starter_support_gem"]), 1))
	equipped[GameEnums.EquipSlot.WEAPON] = weapon

	# Starter Helmet (so hero wears a cute hat immediately)
	var helmet: ItemInstance = ItemInstance.new()
	helmet.item_name = "Cozy Meadow Cap"
	helmet.equip_slot = GameEnums.EquipSlot.HELMET
	helmet.rarity = GameEnums.Rarity.COMMON
	helmet.item_level = 1
	helmet.visual_style = String(hdef["starter_helmet_style"])
	helmet.affixes = [{"stat": GameEnums.StatType.MAX_HP, "value": 14.0}]
	helmet.setup_sockets([GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE], [false])
	equipped[GameEnums.EquipSlot.HELMET] = helmet

	# Starter Armor holding starter Passive Gem
	var armor_item: ItemInstance = ItemInstance.new()
	armor_item.item_name = "Traveler's Paw Tunic"
	armor_item.equip_slot = GameEnums.EquipSlot.ARMOR
	armor_item.rarity = GameEnums.Rarity.COMMON
	armor_item.item_level = 1
	armor_item.visual_style = "tunic"
	armor_item.affixes = [{"stat": GameEnums.StatType.MAX_HP, "value": 20.0}]
	var a_cols: Array[int] = []
	for c in hdef["starter_armor_sockets"]:
		a_cols.append(int(c))
	var a_lnks: Array[bool] = []
	for l in hdef["starter_armor_links"]:
		a_lnks.append(bool(l))
	armor_item.setup_sockets(a_cols, a_lnks)
	armor_item.insert_gem(0, GemInstance.new(String(hdef["starter_passive_gem"]), 1))
	equipped[GameEnums.EquipSlot.ARMOR] = armor_item

	# Starter Boots
	var boots: ItemInstance = ItemInstance.new()
	boots.item_name = "Soft Paw Slippers"
	boots.equip_slot = GameEnums.EquipSlot.BOOTS
	boots.rarity = GameEnums.Rarity.COMMON
	boots.item_level = 1
	boots.visual_style = "boots"
	boots.affixes = [{"stat": GameEnums.StatType.MOVE_SPEED_PCT, "value": 6.0}]
	boots.setup_sockets([GameEnums.GemColor.GREEN], [])
	equipped[GameEnums.EquipSlot.BOOTS] = boots

	recompute()

func add_hero_xp(amount: float) -> Dictionary:
	var gained_levels: int = 0
	var adjusted: float = amount * xp_gain_mult
	hero_xp += adjusted
	while hero_xp >= hero_xp_to_next:
		hero_xp -= hero_xp_to_next
		hero_level += 1
		gained_levels += 1
		hero_xp_to_next = 65.0 * pow(1.24, float(hero_level - 1))
	# Also share XP with every currently socketed gem!
	var gems_leveled: Array[GemInstance] = grant_xp_to_equipped_gems(adjusted * 0.65)
	return {"levels": gained_levels, "gems_leveled": gems_leveled}

func grant_xp_to_equipped_gems(amount: float) -> Array[GemInstance]:
	var leveled: Array[GemInstance] = []
	for slot in equipped.keys():
		var item: ItemInstance = equipped[slot]
		if item == null:
			continue
		for g in item.socketed_gems:
			if g != null:
				var gem: GemInstance = g
				if gem.add_xp(amount):
					leveled.append(gem)
	if not leveled.is_empty():
		recompute()
	return leveled

func add_level_bonus(stat: int, value: float) -> void:
	level_bonuses[stat] = float(level_bonuses.get(stat, 0.0)) + value
	recompute()

func can_add_item_to_bag() -> bool:
	return item_bag.size() < MAX_BAG_SIZE

func can_add_gem_to_pouch() -> bool:
	return gem_pouch.size() < MAX_POUCH_SIZE

func equip_item_from_bag(bag_idx: int) -> Dictionary:
	if bag_idx < 0 or bag_idx >= item_bag.size():
		return {"ok": false, "overflow_gems": []}
	var new_item: ItemInstance = item_bag[bag_idx]
	item_bag.remove_at(bag_idx)
	var old_item: ItemInstance = equipped.get(new_item.equip_slot, null)

	var overflow_gems: Array[GemInstance] = []
	if old_item != null:
		var old_gems: Array[GemInstance] = old_item.extract_all_gems()
		# Preserve gems by moving into compatible sockets on new_item, else return to gem_pouch
		for g in old_gems:
			var placed: bool = false
			for s_idx in range(new_item.get_socket_count()):
				if new_item.socketed_gems[s_idx] == null and new_item.can_socket(s_idx, g):
					new_item.insert_gem(s_idx, g)
					placed = true
					break
			if not placed:
				if gem_pouch.size() < MAX_POUCH_SIZE:
					gem_pouch.append(g)
				else:
					overflow_gems.append(g)
					gem_pouch.append(g) # Never destroy player's leveled gems
		item_bag.insert(mini(bag_idx, item_bag.size()), old_item)

	equipped[new_item.equip_slot] = new_item
	recompute()
	return {"ok": true, "overflow_gems": overflow_gems, "equipped_item": new_item}

func salvage_bag_item(bag_idx: int) -> int:
	if bag_idx < 0 or bag_idx >= item_bag.size():
		return 0
	var item: ItemInstance = item_bag[bag_idx]
	item_bag.remove_at(bag_idx)
	# Rescue any gems inside before salvaging
	for g in item.extract_all_gems():
		gem_pouch.append(g)
	var dust: int = item.get_salvage_dust()
	prism_dust += dust
	return dust

func salvage_common_and_magic() -> Dictionary:
	var count: int = 0
	var dust: int = 0
	for i in range(item_bag.size() - 1, -1, -1):
		var it: ItemInstance = item_bag[i]
		if it.rarity == GameEnums.Rarity.COMMON or it.rarity == GameEnums.Rarity.MAGIC:
			dust += salvage_bag_item(i)
			count += 1
	return {"count": count, "dust": dust}

func salvage_gem_from_pouch(pouch_idx: int) -> int:
	if pouch_idx < 0 or pouch_idx >= gem_pouch.size():
		return 0
	var g: GemInstance = gem_pouch[pouch_idx]
	gem_pouch.remove_at(pouch_idx)
	var dust: int = g.get_salvage_dust()
	prism_dust += dust
	return dust

func socket_gem_into_equipped(slot: int, socket_idx: int, pouch_idx: int) -> bool:
	var item: ItemInstance = equipped.get(slot, null)
	if item == null or pouch_idx < 0 or pouch_idx >= gem_pouch.size():
		return false
	var gem: GemInstance = gem_pouch[pouch_idx]
	if not item.can_socket(socket_idx, gem):
		return false
	gem_pouch.remove_at(pouch_idx)
	var prev: GemInstance = item.insert_gem(socket_idx, gem)
	if prev != null:
		gem_pouch.append(prev)
	recompute()
	return true

func unsocket_gem_from_equipped(slot: int, socket_idx: int) -> GemInstance:
	var item: ItemInstance = equipped.get(slot, null)
	if item == null:
		return null
	var removed: GemInstance = item.remove_gem(socket_idx)
	if removed != null:
		gem_pouch.append(removed)
		recompute()
	return removed

func recompute() -> void:
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)
	var stat_sum: Dictionary = {}

	# Hero base + per-hero-level tiny scaling
	var base_hp: float = float(hdef["base_hp"]) + float(hero_level - 1) * 5.0
	var base_spd: float = float(hdef["base_speed"])
	var base_armor: float = float(hdef["base_armor"])
	var base_crit: float = float(hdef["base_crit"])

	# Level-up choices
	for st in level_bonuses.keys():
		stat_sum[int(st)] = float(stat_sum.get(int(st), 0.0)) + float(level_bonuses[st])

	has_cheat_death = false
	has_honey_aegis = false
	has_thorns = false
	global_gem_level_bonus = 0

	# Equipped gear affixes + unique effects
	for slot in equipped.keys():
		var item: ItemInstance = equipped[slot]
		if item == null:
			continue
		for aff in item.affixes:
			var st: int = int(aff["stat"])
			stat_sum[st] = float(stat_sum.get(st, 0.0)) + float(aff["value"])
		match item.unique_id:
			"unique_prism_crown":
				global_gem_level_bonus += 1
			"unique_nine_lives":
				has_cheat_death = true
			"unique_honey_aegis":
				has_honey_aegis = true

	# Pass 1: Passive Skill Gems across all equipped items
	active_passives.clear()
	for slot in equipped.keys():
		var item: ItemInstance = equipped[slot]
		if item == null:
			continue
		var item_has_prism_mastery: bool = false
		var prism_uid: int = -1
		for g in item.socketed_gems:
			if g != null and g.gem_id == "pas_prism_mastery":
				item_has_prism_mastery = true
				prism_uid = g.uid
				break
		for g in item.socketed_gems:
			if g == null:
				continue
			var gem: GemInstance = g
			if gem.get_gem_type() != GameEnums.GemType.PASSIVE:
				continue
			var bonus: int = global_gem_level_bonus
			if item_has_prism_mastery and gem.uid != prism_uid:
				bonus += 1
			var eff_lvl: int = gem.level + bonus
			var pstats: Dictionary = gem.get_passive_stats(eff_lvl)
			for st in pstats.keys():
				stat_sum[int(st)] = float(stat_sum.get(int(st), 0.0)) + float(pstats[st])
			var def: Dictionary = gem.get_def()
			if String(def.get("special", "")) == "thorns":
				has_thorns = true
			active_passives.append({
				"gem": gem,
				"effective_level": eff_lvl,
				"aura_color": def.get("aura_color", Color(1.0, 1.0, 1.0, 0.3)),
			})

	# Finalize core scalar stats
	max_hp = base_hp + float(stat_sum.get(GameEnums.StatType.MAX_HP, 0.0))
	armor = base_armor + float(stat_sum.get(GameEnums.StatType.ARMOR, 0.0))
	hp_regen = 0.6 + float(stat_sum.get(GameEnums.StatType.HP_REGEN, 0.0))
	move_speed = base_spd * (1.0 + float(stat_sum.get(GameEnums.StatType.MOVE_SPEED_PCT, 0.0)) * 0.01)
	pickup_radius = 4.2 * (1.0 + float(stat_sum.get(GameEnums.StatType.PICKUP_RADIUS_PCT, 0.0)) * 0.01)
	damage_mult = 1.0 + float(stat_sum.get(GameEnums.StatType.DAMAGE_PCT, 0.0)) * 0.01
	flat_damage = float(stat_sum.get(GameEnums.StatType.FLAT_DAMAGE, 0.0))
	cast_speed_mult = maxf(0.25, 1.0 + float(stat_sum.get(GameEnums.StatType.CAST_SPEED_PCT, 0.0)) * 0.01)
	crit_chance = clampf(base_crit + float(stat_sum.get(GameEnums.StatType.CRIT_CHANCE, 0.0)), 0.0, 95.0)
	crit_mult = 165.0 + float(stat_sum.get(GameEnums.StatType.CRIT_MULT, 0.0))
	area_mult = 1.0 + float(stat_sum.get(GameEnums.StatType.AREA_PCT, 0.0)) * 0.01
	proj_speed_mult = 1.0 + float(stat_sum.get(GameEnums.StatType.PROJ_SPEED_PCT, 0.0)) * 0.01
	extra_projectiles = int(round(float(stat_sum.get(GameEnums.StatType.EXTRA_PROJ, 0.0))))
	life_on_hit = float(stat_sum.get(GameEnums.StatType.LIFE_ON_HIT, 0.0))
	xp_gain_mult = 1.0 + float(stat_sum.get(GameEnums.StatType.XP_GAIN_PCT, 0.0)) * 0.01
	magic_find = float(stat_sum.get(GameEnums.StatType.MAGIC_FIND_PCT, 0.0))
	dmg_reduction = clampf(float(stat_sum.get(GameEnums.StatType.DMG_REDUCTION_PCT, 0.0)), 0.0, 65.0)

	dash_cd_mult = 1.0
	var boots_item: ItemInstance = equipped.get(GameEnums.EquipSlot.BOOTS, null)
	if boots_item != null and boots_item.unique_id == "unique_comet_paws":
		dash_cd_mult = 0.65

	# Pass 2: Compile PoE Active Skill Gems + Linked Support Gems
	active_skill_configs.clear()
	for slot in [
		GameEnums.EquipSlot.WEAPON,
		GameEnums.EquipSlot.HELMET,
		GameEnums.EquipSlot.ARMOR,
		GameEnums.EquipSlot.BOOTS,
		GameEnums.EquipSlot.AMULET,
		GameEnums.EquipSlot.RING,
	]:
		var item: ItemInstance = equipped.get(slot, null)
		if item == null:
			continue
		var item_has_prism_mastery: bool = false
		for g in item.socketed_gems:
			if g != null and g.gem_id == "pas_prism_mastery":
				item_has_prism_mastery = true
				break
		var bonus_lvl: int = global_gem_level_bonus + (1 if item_has_prism_mastery else 0)

		var groups: Array = item.get_link_groups()
		for grp in groups:
			var group_indices: Array[int] = grp
			# Collect active & support gems inside this link group
			var actives_in_group: Array[GemInstance] = []
			var supports_in_group: Array[GemInstance] = []
			for s_idx in group_indices:
				var g: GemInstance = item.socketed_gems[s_idx]
				if g == null:
					continue
				if g.get_gem_type() == GameEnums.GemType.ACTIVE:
					actives_in_group.append(g)
				elif g.get_gem_type() == GameEnums.GemType.SUPPORT:
					supports_in_group.append(g)

			for act_gem in actives_in_group:
				var cfg: Dictionary = _compile_active_skill(act_gem, supports_in_group, bonus_lvl, slot)
				active_skill_configs.append(cfg)

func _compile_active_skill(act_gem: GemInstance, supports: Array[GemInstance], bonus_lvl: int, equip_slot: int) -> Dictionary:
	var def: Dictionary = act_gem.get_def()
	var eff_lvl: int = act_gem.level + bonus_lvl
	var base_dmg: float = float(def.get("base_damage", 15.0)) + float(def.get("damage_per_lvl", 4.0)) * float(eff_lvl - 1)
	var base_cd: float = float(def.get("cooldown", 1.0))
	var base_proj: int = int(def.get("base_projectiles", 1))
	var base_chains: int = int(def.get("base_chains", 0))
	var base_pierce: int = int(def.get("pierce", 0))
	var base_area: float = float(def.get("area_radius", 1.0))
	var base_speed: float = float(def.get("proj_speed", 16.0))

	var sup_dmg_mult: float = 1.0
	var sup_cast_pct: float = 0.0
	var sup_area_pct: float = 0.0
	var sup_proj_speed_pct: float = 0.0
	var sup_extra_proj: int = 0
	var sup_extra_chains: int = 0
	var sup_extra_pierce: int = 0
	var sup_fork: int = 0
	var sup_homing: bool = false
	var sup_echo: bool = false
	var sup_crit_chance: float = 0.0
	var sup_crit_mult: float = 0.0
	var sup_added_fire: float = 0.0
	var sup_added_cold: float = 0.0
	var sup_leech_pct: float = 0.0
	var linked_names: Array[String] = []
	var linked_colors: Array[int] = []

	for sup in supports:
		if not GemDatabase.does_support_apply(sup.gem_id, act_gem.gem_id):
			continue
		var sdef: Dictionary = sup.get_def()
		var mods: Dictionary = sdef.get("mods", {})
		var s_eff_lvl: int = sup.level + bonus_lvl
		var lvl_minus_one: float = float(maxi(0, s_eff_lvl - 1))

		linked_names.append("%s Lv.%d" % [sup.get_short_label(), s_eff_lvl])
		linked_colors.append(sup.get_gem_color())

		if mods.has("dmg_mult"):
			var dm: float = float(mods["dmg_mult"]) + float(mods.get("dmg_per_lvl", 0.0)) * lvl_minus_one
			sup_dmg_mult *= dm
		if mods.has("extra_proj"):
			sup_extra_proj += int(mods["extra_proj"]) + int(floor(lvl_minus_one / 3.0)) * int(mods.get("proj_per_3lvl", 0))
		if mods.has("extra_chains"):
			sup_extra_chains += int(mods["extra_chains"]) + int(floor(lvl_minus_one / 2.0)) * int(mods.get("chains_per_2lvl", 0))
		if mods.has("extra_pierce"):
			sup_extra_pierce += int(mods["extra_pierce"]) + int(lvl_minus_one) * int(mods.get("pierce_per_lvl", 0))
		if mods.has("fork"):
			sup_fork += int(mods["fork"])
		if mods.has("homing"):
			sup_homing = true
		if mods.has("echo"):
			sup_echo = true
		if mods.has("cast_speed_pct"):
			sup_cast_pct += float(mods["cast_speed_pct"]) + float(mods.get("cast_per_lvl", 0.0)) * lvl_minus_one
		if mods.has("area_pct"):
			sup_area_pct += float(mods["area_pct"]) + float(mods.get("area_per_lvl", 0.0)) * lvl_minus_one
		if mods.has("proj_speed_pct"):
			sup_proj_speed_pct += float(mods["proj_speed_pct"])
		if mods.has("crit_chance"):
			sup_crit_chance += float(mods["crit_chance"]) + float(mods.get("crit_per_lvl", 0.0)) * lvl_minus_one
		if mods.has("crit_mult"):
			sup_crit_mult += float(mods["crit_mult"])
		if mods.has("added_fire_pct"):
			sup_added_fire += float(mods["added_fire_pct"]) + float(mods.get("fire_per_lvl", 0.0)) * lvl_minus_one
		if mods.has("added_cold_pct"):
			sup_added_cold += float(mods["added_cold_pct"]) + float(mods.get("cold_per_lvl", 0.0)) * lvl_minus_one
		if mods.has("leech_pct"):
			sup_leech_pct += float(mods["leech_pct"]) + float(mods.get("leech_per_lvl", 0.0)) * lvl_minus_one

	var total_cast_mult: float = cast_speed_mult * (1.0 + sup_cast_pct * 0.01)
	var final_cd: float = maxf(0.14, base_cd / total_cast_mult)
	var total_area_mult: float = area_mult * (1.0 + sup_area_pct * 0.01)
	var final_dmg: float = (base_dmg + flat_damage * 0.85) * damage_mult * sup_dmg_mult

	var tags: Array = act_gem.get_tags()
	var uses_proj: bool = tags.has(GameEnums.SkillTag.PROJECTILE) or tags.has(GameEnums.SkillTag.ORBIT)
	var final_proj: int = base_proj + sup_extra_proj + (extra_projectiles if uses_proj else 0)

	return {
		"uid": act_gem.uid,
		"gem_id": act_gem.gem_id,
		"gem": act_gem,
		"equip_slot": equip_slot,
		"effective_level": eff_lvl,
		"gem_name": act_gem.get_gem_name(),
		"short": act_gem.get_short_label(),
		"color": act_gem.get_gem_color(),
		"tags": tags,
		"damage": final_dmg,
		"cooldown": final_cd,
		"projectiles": maxi(1, final_proj),
		"chains": base_chains + sup_extra_chains,
		"pierce": base_pierce + sup_extra_pierce,
		"forks": sup_fork,
		"homing": sup_homing or act_gem.gem_id == "spirit_bees",
		"echo": sup_echo,
		"area_radius": base_area * total_area_mult,
		"area_mult": total_area_mult,
		"proj_speed": base_speed * proj_speed_mult * (1.0 + sup_proj_speed_pct * 0.01),
		"crit_chance": clampf(crit_chance + sup_crit_chance, 0.0, 95.0),
		"crit_mult": crit_mult + sup_crit_mult,
		"added_fire_pct": sup_added_fire,
		"added_cold_pct": sup_added_cold,
		"leech_pct": sup_leech_pct,
		"linked_support_names": linked_names,
		"linked_support_colors": linked_colors,
	}
