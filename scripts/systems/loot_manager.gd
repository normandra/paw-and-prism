class_name LootManager
extends Node

signal item_looted(item: ItemInstance)
signal gem_looted(gem: GemInstance)
signal hero_heal_requested(amount: float)
signal loot_bag_full(label: String)
signal chest_opened()

const BASE_ITEM_DROP: float = 0.018
const BASE_GEM_DROP: float = 0.011
const PITY_GRACE_ITEM: int = 65
const PITY_STEP_ITEM: float = 0.0015
const PITY_GRACE_GEM: int = 95
const PITY_STEP_GEM: float = 0.0012
const ITEM_MIN_INTERVAL: float = 16.0
const ITEM_MIN_INTERVAL_LUCKY: float = 12.5
const GEM_MIN_INTERVAL: float = 24.0
const GEM_MIN_INTERVAL_LUCKY: float = 19.0

var world_root: Node3D = null
var stats: HeroStats = null
var pickups: Array[WorldPickup] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _kills_since_item: int = 0
var _kills_since_gem: int = 0
var _last_reg_item_sec: float = -99.0
var _last_reg_gem_sec: float = -99.0

static func compute_spawn_intensity(elapsed_sec: float) -> float:
	var prof: Dictionary = EnemyDatabase.get_wave_profile(elapsed_sec)
	var rate: float = float(prof["batch_size"]) / maxf(0.1, float(prof["spawn_interval"]))
	var base_rate: float = 2.0 / 0.95
	return maxf(1.0, rate / base_rate)

static func compute_regular_item_chance(elapsed_sec: float, lucky: bool, kills_since_item: int) -> float:
	var s_t: float = compute_spawn_intensity(elapsed_sec)
	var base_c: float = (BASE_ITEM_DROP * (1.30 if lucky else 1.0)) / pow(s_t, 0.75)
	var pity: float = float(maxi(0, kills_since_item - PITY_GRACE_ITEM)) * PITY_STEP_ITEM
	return clampf(base_c + pity, 0.002, 0.12)

static func compute_regular_gem_chance(elapsed_sec: float, lucky: bool, kills_since_gem: int) -> float:
	var s_t: float = compute_spawn_intensity(elapsed_sec)
	var base_c: float = (BASE_GEM_DROP * (1.30 if lucky else 1.0)) / pow(s_t, 0.75)
	var pity: float = float(maxi(0, kills_since_gem - PITY_GRACE_GEM)) * PITY_STEP_GEM
	return clampf(base_c + pity, 0.0015, 0.09)

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
	_kills_since_item = 0
	_kills_since_gem = 0
	_last_reg_item_sec = -99.0
	_last_reg_gem_sec = -99.0

func drop_for_enemy(enemy: EnemyEntity, elapsed_sec: float) -> void:
	if world_root == null or stats == null:
		return
	var pos: Vector3 = enemy.global_position
	var lucky: bool = stats.has_lucky_clover

	if enemy.is_boss:
		for i in range(2):
			var r_forced: int = GameEnums.Rarity.UNIQUE if i == 0 else GameEnums.Rarity.RARE
			var b_item: ItemInstance = ItemDatabase.generate_item(r_forced, lucky, -1, _rng)
			spawn_specific_item(pos + Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5)), b_item)
		spawn_specific_gem(pos + Vector3(-1.4, 0.0, 1.2), GemInstance.new(GemDatabase.roll_random_gem_id(_rng, GameEnums.GemType.MAIN)))
		spawn_specific_gem(pos + Vector3(1.4, 0.0, 1.2), GemInstance.new(GemDatabase.roll_random_gem_id(_rng, GameEnums.GemType.MODIFIER)))
		hero_heal_requested.emit(50.0)
		return

	if enemy.is_elite:
		if _rng.randf() < (0.80 if lucky else 0.65):
			var elite_rarity: int = GameEnums.Rarity.RARE if _rng.randf() < (0.60 if lucky else 0.42) else GameEnums.Rarity.MAGIC
			spawn_specific_item(pos, ItemDatabase.generate_item(elite_rarity, lucky, -1, _rng))
		if _rng.randf() < (0.55 if lucky else 0.40):
			spawn_specific_gem(pos + Vector3(0.7, 0.0, 0.4), GemInstance.new(GemDatabase.roll_random_gem_id(_rng)))
		hero_heal_requested.emit(18.0)
		return

	# Regular enemy drops: spawn-rate-normalized probability + dry-streak pity + cooldown gate
	_kills_since_item += 1
	_kills_since_gem += 1
	var min_item_dt: float = ITEM_MIN_INTERVAL_LUCKY if lucky else ITEM_MIN_INTERVAL
	if elapsed_sec - _last_reg_item_sec >= min_item_dt:
		var item_chance: float = compute_regular_item_chance(elapsed_sec, lucky, _kills_since_item)
		if _rng.randf() < item_chance:
			_kills_since_item = 0
			_last_reg_item_sec = elapsed_sec
			spawn_specific_item(pos, ItemDatabase.generate_item(-1, lucky, -1, _rng))

	var min_gem_dt: float = GEM_MIN_INTERVAL_LUCKY if lucky else GEM_MIN_INTERVAL
	if elapsed_sec - _last_reg_gem_sec >= min_gem_dt:
		var gem_chance: float = compute_regular_gem_chance(elapsed_sec, lucky, _kills_since_gem)
		if _rng.randf() < gem_chance:
			_kills_since_gem = 0
			_last_reg_gem_sec = elapsed_sec
			spawn_specific_gem(pos, GemInstance.new(GemDatabase.roll_random_gem_id(_rng)))

func spawn_treasure_chest(pos: Vector3) -> void:
	if world_root == null:
		return
	var p: WorldPickup = WorldPickup.new()
	p.setup_chest(pos)
	world_root.add_child(p)
	pickups.append(p)

func spawn_specific_item(pos: Vector3, item: ItemInstance) -> WorldPickup:
	if world_root == null or item == null:
		return null
	var p: WorldPickup = WorldPickup.new()
	p.setup_item(pos, item)
	world_root.add_child(p)
	pickups.append(p)
	return p

func spawn_specific_gem(pos: Vector3, gem: GemInstance) -> WorldPickup:
	if world_root == null or gem == null:
		return null
	var p: WorldPickup = WorldPickup.new()
	if gem.get_gem_type() == GameEnums.GemType.MAIN:
		p.setup_main_ability(pos, gem)
	else:
		p.setup_modifier_ability(pos, gem)
	world_root.add_child(p)
	pickups.append(p)
	return p

func step(delta: float, player_pos: Vector3, _elapsed_sec: float) -> void:
	if stats == null:
		return
	for i in range(pickups.size() - 1, -1, -1):
		var pk: WorldPickup = pickups[i]
		if not is_instance_valid(pk):
			pickups.remove_at(i)
			continue
		if pk.step(delta, player_pos):
			var consumed: bool = _collect_pickup(pk)
			if consumed:
				pickups.remove_at(i)
				pk.queue_free()

func _collect_pickup(pk: WorldPickup) -> bool:
	match pk.kind:
		WorldPickup.Kind.ITEM:
			if stats.can_add_item_to_bag():
				stats.item_bag.append(pk.item_data)
				item_looted.emit(pk.item_data)
				return true
			else:
				loot_bag_full.emit("Bag Full! Open [Tab] to Drop")
				return false
		WorldPickup.Kind.MAIN_ABILITY, WorldPickup.Kind.MODIFIER_ABILITY:
			if stats.can_add_gem_to_pouch():
				stats.gem_pouch.append(pk.gem_data)
				gem_looted.emit(pk.gem_data)
				return true
			else:
				loot_bag_full.emit("Pouch Full! Open [Tab] to Drop")
				return false
		WorldPickup.Kind.CHEST:
			var lucky: bool = stats.has_lucky_clover
			var rar: int = GameEnums.Rarity.RARE if _rng.randf() < (0.72 if lucky else 0.52) else GameEnums.Rarity.MAGIC
			var c_item: ItemInstance = ItemDatabase.generate_item(rar, lucky, -1, _rng)
			if stats.can_add_item_to_bag():
				stats.item_bag.append(c_item)
				item_looted.emit(c_item)
			else:
				spawn_specific_item(pk.global_position, c_item)
			if _rng.randf() < (0.68 if lucky else 0.50):
				var c_gem: GemInstance = GemInstance.new(GemDatabase.roll_random_gem_id(_rng))
				if stats.can_add_gem_to_pouch():
					stats.gem_pouch.append(c_gem)
					gem_looted.emit(c_gem)
				else:
					spawn_specific_gem(pk.global_position, c_gem)
			hero_heal_requested.emit(35.0)
			chest_opened.emit()
			return true
	return true

func get_ground_labels() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for pk in pickups:
		if not is_instance_valid(pk):
			continue
		if pk.kind == WorldPickup.Kind.ITEM or pk.kind == WorldPickup.Kind.MAIN_ABILITY or pk.kind == WorldPickup.Kind.MODIFIER_ABILITY or pk.kind == WorldPickup.Kind.CHEST:
			out.append({
				"pos": pk.global_position + Vector3(0.0, 1.1, 0.0),
				"text": pk.get_label_text(),
				"color": pk.get_label_color(),
				"is_chest": pk.kind == WorldPickup.Kind.CHEST,
			})
	return out
