class_name HeroStats

var hero_id: String = "shiba"

# Equipped slots: EquipSlot -> ItemInstance or null
var equipped: Dictionary = {}
var item_bag: Array[ItemInstance] = []
var gem_pouch: Array[GemInstance] = []
const MAX_BAG_SIZE: int = 24
const MAX_POUCH_SIZE: int = 24

# Baseline Hero Vitals (zero stat-stick scaling)
var max_hp: float = 135.0
var hp_regen: float = 0.6
var move_speed: float = 8.6
var crit_chance: float = 8.0
var crit_mult: float = 165.0

# Behavioral Flags Derived From Equipped Global Item Effects
var active_effects: Dictionary = {}
var active_effect_list: Array[String] = []
var incoming_dmg_mult: float = 1.0
var has_lucky_clover: bool = false
var has_turret_stance: bool = false
var has_stride_honey_nova: bool = false
var has_cadence_burst: bool = false
var has_kill_siphon: bool = false
var has_zoomies_on_kill: bool = false
var has_ember_corpse: bool = false
var has_frost_shatter: bool = false
var has_static_sprint: bool = false
var has_thorns_burst: bool = false
var has_aegis_freeze: bool = false
var has_orbit_shield: bool = false
var has_cheat_death: bool = false
var has_fleet_paws: bool = false
var has_comet_stride: bool = false

# Compiled PoE Active Skill List
var active_skill_configs: Array[Dictionary] = []

func _init(p_hero_id: String = "shiba") -> void:
	init_for_hero(p_hero_id)

func _reset_empty_slots(p_hero_id: String) -> void:
	hero_id = p_hero_id
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

func init_bare_for_tutorial(p_hero_id: String) -> void:
	_reset_empty_slots(p_hero_id)
	recompute()

func init_for_hero(p_hero_id: String) -> void:
	_reset_empty_slots(p_hero_id)
	var hdef: Dictionary = HeroDatabase.get_hero(hero_id)

	# Starter Weapon: 2-Link containing Hero's Main Ability + open linked Modifier socket + signature Effect
	var weapon: ItemInstance = ItemInstance.new()
	weapon.item_name = String(hdef["starter_weapon_name"])
	weapon.equip_slot = GameEnums.EquipSlot.WEAPON
	weapon.rarity = GameEnums.Rarity.MAGIC
	weapon.visual_style = String(hdef["starter_weapon_style"])
	weapon.effects = [String(hdef["starter_effect_id"])]
	var w_cols: Array[int] = []
	for c in hdef["starter_weapon_sockets"]:
		w_cols.append(int(c))
	var w_lnks: Array[bool] = []
	for l in hdef["starter_weapon_links"]:
		w_lnks.append(bool(l))
	weapon.setup_sockets(w_cols, w_lnks)
	weapon.insert_gem(0, GemInstance.new(String(hdef["starter_main_gem"])))
	equipped[GameEnums.EquipSlot.WEAPON] = weapon

	# Starter Cosmetic Hat with 1 open socket (no starter effect so first looted Helmet is always exciting)
	var helmet: ItemInstance = ItemInstance.new()
	helmet.item_name = "Meadow Cap"
	helmet.equip_slot = GameEnums.EquipSlot.HELMET
	helmet.rarity = GameEnums.Rarity.COMMON
	helmet.visual_style = String(hdef["starter_helmet_style"])
	helmet.effects = []
	helmet.setup_sockets([GameEnums.GemColor.GREEN, GameEnums.GemColor.BLUE], [false])
	equipped[GameEnums.EquipSlot.HELMET] = helmet

	recompute()

func has_effect(effect_id: String) -> bool:
	return active_effects.has(effect_id)

func can_add_item_to_bag() -> bool:
	return item_bag.size() < MAX_BAG_SIZE

func can_add_gem_to_pouch() -> bool:
	return gem_pouch.size() < MAX_POUCH_SIZE

func get_pouch_gems(filter_type: int = -1) -> Array[GemInstance]:
	var out: Array[GemInstance] = []
	for g in gem_pouch:
		if filter_type == -1 or g.get_gem_type() == filter_type:
			out.append(g)
	return out

func equip_item_from_bag(bag_idx: int) -> Dictionary:
	if bag_idx < 0 or bag_idx >= item_bag.size():
		return {"ok": false, "overflow_gems": []}
	var new_item: ItemInstance = item_bag[bag_idx]
	item_bag.remove_at(bag_idx)
	var old_item: ItemInstance = equipped.get(new_item.equip_slot, null)

	var overflow_gems: Array[GemInstance] = []
	if old_item != null:
		var old_gems: Array[GemInstance] = old_item.extract_all_gems()
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
					gem_pouch.append(g) # Preserve player abilities safely
		item_bag.insert(mini(bag_idx, item_bag.size()), old_item)

	equipped[new_item.equip_slot] = new_item
	recompute()
	return {"ok": true, "overflow_gems": overflow_gems, "equipped_item": new_item}

func discard_bag_item(bag_idx: int) -> bool:
	if bag_idx < 0 or bag_idx >= item_bag.size():
		return false
	var item: ItemInstance = item_bag[bag_idx]
	item_bag.remove_at(bag_idx)
	for g in item.extract_all_gems():
		gem_pouch.append(g)
	return true

func discard_gem_from_pouch(pouch_idx: int) -> bool:
	if pouch_idx < 0 or pouch_idx >= gem_pouch.size():
		return false
	gem_pouch.remove_at(pouch_idx)
	return true

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
	max_hp = float(hdef["base_hp"])
	hp_regen = 0.8
	move_speed = float(hdef["base_speed"])
	crit_chance = 8.0
	crit_mult = 165.0

	# Collect active Global Item Effects
	active_effects.clear()
	active_effect_list.clear()
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
		for eid in item.effects:
			if not active_effects.has(eid):
				active_effects[eid] = true
				active_effect_list.append(eid)

	has_lucky_clover = has_effect("lucky_clover")
	has_turret_stance = has_effect("turret_stance")
	has_stride_honey_nova = has_effect("stride_honey_nova")
	has_cadence_burst = has_effect("cadence_burst")
	has_kill_siphon = has_effect("kill_siphon")
	has_zoomies_on_kill = has_effect("zoomies_on_kill")
	has_ember_corpse = has_effect("ember_corpse")
	has_frost_shatter = has_effect("frost_shatter")
	has_static_sprint = has_effect("static_sprint")
	has_thorns_burst = has_effect("thorns_burst")
	has_aegis_freeze = has_effect("aegis_freeze")
	has_orbit_shield = has_effect("orbit_shield")
	has_cheat_death = has_effect("cheat_death")
	has_fleet_paws = has_effect("fleet_paws")
	has_comet_stride = has_effect("comet_stride")
	incoming_dmg_mult = 1.45 if has_effect("glass_spark") else 1.0

	# Compile PoE Main Socket Abilities + Linked Modifier Abilities
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
		for grp in item.get_link_groups():
			var group_indices: Array[int] = grp
			var mains_in_group: Array[GemInstance] = []
			var mods_in_group: Array[GemInstance] = []
			for s_idx in group_indices:
				var g: GemInstance = item.socketed_gems[s_idx]
				if g == null:
					continue
				if g.get_gem_type() == GameEnums.GemType.MAIN:
					mains_in_group.append(g)
				elif g.get_gem_type() == GameEnums.GemType.MODIFIER:
					mods_in_group.append(g)

			for main_gem in mains_in_group:
				active_skill_configs.append(_compile_main_skill(main_gem, mods_in_group, slot))

func _compile_main_skill(main_gem: GemInstance, mods_list: Array[GemInstance], equip_slot: int) -> Dictionary:
	var def: Dictionary = main_gem.get_def()
	var final_dmg: float = float(def.get("base_damage", 20.0))
	var final_cd: float = float(def.get("cooldown", 1.0))
	var base_proj: int = int(def.get("base_projectiles", 1))
	var base_chains: int = int(def.get("base_chains", 0))
	var base_pierce: int = int(def.get("pierce", 0))
	var base_area: float = float(def.get("area_radius", 1.0))
	var final_speed: float = float(def.get("proj_speed", 16.0))

	var mod_factor: int = 2 if has_effect("prism_echo") else 1
	var extra_proj: int = 0
	var extra_chains: int = 0
	var extra_pierce: int = 0
	var forks: int = 0
	var homing: bool = false
	var echo: bool = false
	var area_mult: float = 1.0
	var ignite: bool = false
	var chill: bool = false
	var leech_pct: float = 0.0
	var linked_names: Array[String] = []
	var linked_colors: Array[int] = []

	for mod_gem in mods_list:
		if not GemDatabase.does_modifier_apply(mod_gem.gem_id, main_gem.gem_id):
			continue
		var mdef: Dictionary = mod_gem.get_def()
		var mods: Dictionary = mdef.get("mods", {})
		linked_names.append(mod_gem.get_short_label())
		linked_colors.append(mod_gem.get_gem_color())

		if mods.has("dmg_mult"):
			final_dmg *= float(mods["dmg_mult"])
		if mods.has("extra_proj"):
			extra_proj += int(mods["extra_proj"]) * mod_factor
		if mods.has("extra_chains"):
			extra_chains += int(mods["extra_chains"]) * mod_factor
		if mods.has("extra_pierce"):
			extra_pierce += int(mods["extra_pierce"]) * mod_factor
		if mods.has("fork"):
			forks += int(mods["fork"]) * mod_factor
		if mods.has("homing"):
			homing = true
		if mods.has("echo"):
			echo = true
		if mods.has("area_mult"):
			area_mult *= (1.0 + (float(mods["area_mult"]) - 1.0) * float(mod_factor))
		if mods.has("proj_speed_mult"):
			final_speed *= float(mods["proj_speed_mult"])
		if mods.has("ignite"):
			ignite = true
		if mods.has("chill"):
			chill = true
		if mods.has("leech_pct"):
			leech_pct += float(mods["leech_pct"]) * float(mod_factor)

	if has_effect("prism_echo") and not linked_names.is_empty():
		echo = true

	var tags: Array = main_gem.get_tags()
	var uses_proj: bool = tags.has(GameEnums.SkillTag.PROJECTILE) or tags.has(GameEnums.SkillTag.ORBIT)
	var final_proj: int = base_proj + (extra_proj if uses_proj else 0)
	var final_pierce: int = base_pierce + extra_pierce
	var lifetime_mult: float = 1.0

	# Global Behavioral Item Tradeoffs
	if has_effect("short_barrage") and uses_proj:
		final_proj += 2
		lifetime_mult *= 0.55
	if has_effect("sniper_focus") and tags.has(GameEnums.SkillTag.PROJECTILE):
		final_proj = 1
		final_pierce += 2
		final_speed *= 1.55
		final_dmg *= 1.45
	if has_effect("giant_slow_aoe") and (tags.has(GameEnums.SkillTag.AOE) or tags.has(GameEnums.SkillTag.ORBIT)):
		area_mult *= 1.65
		final_cd *= 1.33
	if has_effect("glass_spark"):
		final_dmg *= 1.75
	if has_effect("cadence_burst"):
		final_cd *= 1.18

	final_cd = maxf(0.18, final_cd)

	return {
		"uid": main_gem.uid,
		"gem_id": main_gem.gem_id,
		"gem": main_gem,
		"equip_slot": equip_slot,
		"gem_name": main_gem.get_gem_name(),
		"short": main_gem.get_short_label(),
		"color": main_gem.get_gem_color(),
		"tags": tags,
		"damage": final_dmg,
		"cooldown": final_cd,
		"projectiles": maxi(1, final_proj),
		"chains": base_chains + extra_chains,
		"pierce": final_pierce,
		"forks": forks,
		"homing": homing or main_gem.gem_id == "spirit_bees",
		"echo": echo,
		"area_radius": base_area * area_mult,
		"area_mult": area_mult,
		"proj_speed": final_speed,
		"lifetime_mult": lifetime_mult,
		"ricochet": has_effect("edge_ricochet"),
		"nova_360": has_effect("nova_barrage"),
		"pull_inward": has_effect("gravity_slams"),
		"crit_chance": crit_chance,
		"crit_mult": crit_mult,
		"ignite": ignite or tags.has(GameEnums.SkillTag.FIRE),
		"chill": chill or tags.has(GameEnums.SkillTag.COLD),
		"leech_pct": leech_pct,
		"linked_mod_names": linked_names,
		"linked_mod_colors": linked_colors,
	}
