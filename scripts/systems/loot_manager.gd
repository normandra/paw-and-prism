class_name LootManager
extends Node

signal card_looted(card: CardInstance)
signal hero_heal_requested(amount: float)
signal loot_bag_full(label: String)
signal chest_opened()

const BASE_TEMPLATE_DROP: float = BalanceConfig.BASE_TEMPLATE_DROP
const BASE_ADDON_DROP: float = BalanceConfig.BASE_ADDON_DROP
const PITY_GRACE_TEMPLATE: int = BalanceConfig.PITY_GRACE_TEMPLATE
const PITY_STEP_TEMPLATE: float = BalanceConfig.PITY_STEP_TEMPLATE
const PITY_GRACE_ADDON: int = BalanceConfig.PITY_GRACE_ADDON
const PITY_STEP_ADDON: float = BalanceConfig.PITY_STEP_ADDON
const TEMPLATE_MIN_INTERVAL: float = BalanceConfig.TEMPLATE_MIN_INTERVAL
const ADDON_MIN_INTERVAL: float = BalanceConfig.ADDON_MIN_INTERVAL

var world_root: Node3D = null
var stats: HeroStats = null
var pickups: Array[WorldPickup] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _kills_since_template: int = 0
var _kills_since_addon: int = 0
var _last_reg_tpl_sec: float = -99.0
var _last_reg_add_sec: float = -99.0

static func compute_spawn_intensity(elapsed_sec: float) -> float:
	var base_prof: Dictionary = EnemyDatabase.get_wave_profile(0.0)
	var base_rate: float = float(base_prof["batch_size"]) / maxf(0.1, float(base_prof["spawn_interval"]))
	var prof: Dictionary = EnemyDatabase.get_wave_profile(elapsed_sec)
	var rate: float = float(prof["batch_size"]) / maxf(0.1, float(prof["spawn_interval"]))
	return maxf(1.0, rate / base_rate)

static func compute_regular_template_chance(elapsed_sec: float, kills_since: int) -> float:
	var s_t: float = compute_spawn_intensity(elapsed_sec)
	var base_c: float = BASE_TEMPLATE_DROP / pow(s_t, 0.75)
	var pity: float = float(maxi(0, kills_since - PITY_GRACE_TEMPLATE)) * PITY_STEP_TEMPLATE
	return clampf(base_c + pity, 0.002, 0.12)

static func compute_regular_addon_chance(elapsed_sec: float, kills_since: int) -> float:
	var s_t: float = compute_spawn_intensity(elapsed_sec)
	var base_c: float = BASE_ADDON_DROP / pow(s_t, 0.75)
	var pity: float = float(maxi(0, kills_since - PITY_GRACE_ADDON)) * PITY_STEP_ADDON
	return clampf(base_c + pity, 0.002, 0.14)

func setup(p_world: Node3D, p_stats: HeroStats) -> void:
	world_root = p_world
	stats = p_stats
	_rng.randomize()
	clear_all()

func clear_all() -> void:
	for p in pickups:
		if is_instance_valid(p):
			p.queue_free()
	pickups.clear()
	_kills_since_template = 0
	_kills_since_addon = 0
	_last_reg_tpl_sec = -99.0
	_last_reg_add_sec = -99.0

func drop_for_enemy(enemy: EnemyEntity, elapsed_sec: float) -> void:
	if world_root == null or stats == null:
		return
	var pos: Vector3 = enemy.global_position

	if enemy.is_boss:
		var leg_tpl: CardInstance = CardInstance.generate_template(elapsed_sec, _rng, GameEnums.Rarity.LEGENDARY)
		spawn_specific_card(pos + Vector3(0.0, 0.0, -1.2), leg_tpl)
		var rar_add: CardInstance = CardInstance.generate_addon(elapsed_sec, _rng, GameEnums.Rarity.RARE)
		spawn_specific_card(pos + Vector3(-1.4, 0.0, 1.1), rar_add)
		var bonus_add: CardInstance = CardInstance.generate_addon(elapsed_sec, _rng, GameEnums.Rarity.UNCOMMON)
		spawn_specific_card(pos + Vector3(1.4, 0.0, 1.1), bonus_add)
		hero_heal_requested.emit(BalanceConfig.BOSS_HEAL)
		return

	if enemy.is_elite:
		if _rng.randf() < 0.72:
			var elite_tpl: CardInstance = CardInstance.generate_template(elapsed_sec, _rng, CardDatabase.roll_template_rarity(elapsed_sec, _rng, GameEnums.Rarity.UNCOMMON))
			spawn_specific_card(pos + Vector3(-0.6, 0.0, 0.3), elite_tpl)
		if _rng.randf() < 0.85:
			var elite_add: CardInstance = CardInstance.generate_addon(elapsed_sec, _rng)
			spawn_specific_card(pos + Vector3(0.7, 0.0, 0.4), elite_add)
		hero_heal_requested.emit(BalanceConfig.ELITE_HEAL)
		return

	# Regular enemy drops: spawn-rate-normalized probability + dry-streak pity + cooldown gate
	_kills_since_template += 1
	_kills_since_addon += 1
	if elapsed_sec - _last_reg_tpl_sec >= TEMPLATE_MIN_INTERVAL:
		var tpl_chance: float = compute_regular_template_chance(elapsed_sec, _kills_since_template)
		if _rng.randf() < tpl_chance:
			_kills_since_template = 0
			_last_reg_tpl_sec = elapsed_sec
			spawn_specific_card(pos, CardInstance.generate_template(elapsed_sec, _rng))

	if elapsed_sec - _last_reg_add_sec >= ADDON_MIN_INTERVAL:
		var add_chance: float = compute_regular_addon_chance(elapsed_sec, _kills_since_addon)
		if _rng.randf() < add_chance:
			_kills_since_addon = 0
			_last_reg_add_sec = elapsed_sec
			spawn_specific_card(pos + Vector3(0.4, 0.0, 0.0), CardInstance.generate_addon(elapsed_sec, _rng))

func spawn_treasure_chest(pos: Vector3) -> void:
	if world_root == null:
		return
	var p: WorldPickup = WorldPickup.new()
	p.setup_chest(pos)
	world_root.add_child(p)
	pickups.append(p)

func spawn_specific_card(pos: Vector3, card: CardInstance) -> WorldPickup:
	if world_root == null or card == null:
		return null
	var p: WorldPickup = WorldPickup.new()
	p.setup_card(pos, card)
	world_root.add_child(p)
	pickups.append(p)
	return p

func step(delta: float, player_pos: Vector3, elapsed_sec: float) -> void:
	if stats == null:
		return
	for i in range(pickups.size() - 1, -1, -1):
		var pk: WorldPickup = pickups[i]
		if not is_instance_valid(pk):
			pickups.remove_at(i)
			continue
		if pk.step(delta, player_pos):
			var consumed: bool = _collect_pickup(pk, elapsed_sec)
			if consumed:
				pickups.remove_at(i)
				pk.queue_free()

func _collect_pickup(pk: WorldPickup, elapsed_sec: float) -> bool:
	match pk.kind:
		WorldPickup.Kind.TEMPLATE_CARD:
			if stats.can_add_template():
				stats.template_inventory.append(pk.card_data)
				card_looted.emit(pk.card_data)
				return true
			loot_bag_full.emit("Template Bag Full! Open [Tab] to Discard")
			return false
		WorldPickup.Kind.ADDON_CARD:
			if stats.can_add_addon():
				stats.addon_inventory.append(pk.card_data)
				card_looted.emit(pk.card_data)
				return true
			loot_bag_full.emit("Add-on Bag Full! Open [Tab] to Discard")
			return false
		WorldPickup.Kind.CHEST:
			var c_rar: int = GameEnums.Rarity.RARE if _rng.randf() < 0.60 else GameEnums.Rarity.UNCOMMON
			var c_tpl: CardInstance = CardInstance.generate_template(elapsed_sec, _rng, c_rar)
			if stats.can_add_template():
				stats.template_inventory.append(c_tpl)
				card_looted.emit(c_tpl)
			else:
				spawn_specific_card(pk.global_position, c_tpl)
			var c_add: CardInstance = CardInstance.generate_addon(elapsed_sec, _rng, GameEnums.Rarity.UNCOMMON if _rng.randf() < 0.65 else -1)
			if stats.can_add_addon():
				stats.addon_inventory.append(c_add)
				card_looted.emit(c_add)
			else:
				spawn_specific_card(pk.global_position, c_add)
			hero_heal_requested.emit(BalanceConfig.CHEST_HEAL)
			chest_opened.emit()
			return true
	return true

func get_ground_labels() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for pk in pickups:
		if not is_instance_valid(pk):
			continue
		out.append({
			"pos": pk.global_position + Vector3(0.0, 1.1, 0.0),
			"text": pk.get_label_text(),
			"color": pk.get_label_color(),
			"is_chest": pk.kind == WorldPickup.Kind.CHEST,
		})
	return out
