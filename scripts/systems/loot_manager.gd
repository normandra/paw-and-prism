class_name LootManager
extends Node

signal xp_collected(amount: float)
signal heart_collected(amount: float)
signal dust_collected(amount: int)
signal item_looted(item: ItemInstance)
signal gem_looted(gem: GemInstance)
signal loot_bag_full(label: String)
signal chest_opened()

var world_root: Node3D = null
var stats: HeroStats = null
var pickups: Array[WorldPickup] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

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

func drop_for_enemy(enemy: EnemyEntity, elapsed_sec: float) -> void:
	if world_root == null or stats == null:
		return
	var pos: Vector3 = enemy.global_position
	var ilvl: int = clampi(1 + int(elapsed_sec / 60.0), 1, 20)
	var mf: float = stats.magic_find

	# Always drop XP shard (merge if too many shards on floor)
	_spawn_xp_shard(pos, enemy.xp_reward)

	if enemy.is_boss:
		# Diablo Loot Fountain!
		for i in range(3):
			var r_forced: int = GameEnums.Rarity.UNIQUE if i == 0 else GameEnums.Rarity.RARE
			var b_item: ItemInstance = ItemDatabase.generate_item(ilvl + 2, r_forced, mf, -1, _rng)
			_spawn_item_pickup(pos + Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5)), b_item)
		# Guarantee 1 Active, 1 Support, 1 Passive gem from Boss
		for gtype in [GameEnums.GemType.ACTIVE, GameEnums.GemType.SUPPORT, GameEnums.GemType.PASSIVE]:
			var gid: String = GemDatabase.roll_random_gem_id(_rng, gtype)
			var g_lvl: int = mini(4, 1 + enemy.boss_index)
			_spawn_gem_pickup(pos + Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5)), GemInstance.new(gid, g_lvl))
		_spawn_dust_pickup(pos, 25 + enemy.boss_index * 15)
		_spawn_heart_pickup(pos, 65.0)
		return

	if enemy.is_elite:
		var elite_rarity: int = GameEnums.Rarity.RARE if _rng.randf() < clampf(0.38 + mf * 0.005, 0.38, 0.80) else GameEnums.Rarity.MAGIC
		_spawn_item_pickup(pos, ItemDatabase.generate_item(ilvl, elite_rarity, mf, -1, _rng))
		if _rng.randf() < 0.72:
			_spawn_gem_pickup(pos, GemInstance.new(GemDatabase.roll_random_gem_id(_rng), 1))
		_spawn_dust_pickup(pos, 8)
		if _rng.randf() < 0.45:
			_spawn_heart_pickup(pos, 32.0)
		return

	# Regular enemy drops
	var item_chance: float = clampf(0.032 * (1.0 + mf * 0.007), 0.03, 0.095)
	if _rng.randf() < item_chance:
		_spawn_item_pickup(pos, ItemDatabase.generate_item(ilvl, -1, mf, -1, _rng))

	var gem_chance: float = clampf(0.024 * (1.0 + mf * 0.005), 0.02, 0.075)
	if _rng.randf() < gem_chance:
		_spawn_gem_pickup(pos, GemInstance.new(GemDatabase.roll_random_gem_id(_rng), 1))

	if _rng.randf() < 0.035:
		_spawn_heart_pickup(pos, 26.0)

	if _rng.randf() < 0.04:
		_spawn_dust_pickup(pos, 4)

func spawn_treasure_chest(pos: Vector3) -> void:
	if world_root == null:
		return
	var p: WorldPickup = WorldPickup.new()
	p.setup_chest(pos)
	world_root.add_child(p)
	pickups.append(p)

func _spawn_xp_shard(pos: Vector3, amount: float) -> void:
	var xp_count: int = 0
	var farthest_xp: WorldPickup = null
	for pk in pickups:
		if is_instance_valid(pk) and pk.kind == WorldPickup.Kind.XP:
			xp_count += 1
			farthest_xp = pk
	if xp_count >= 140 and farthest_xp != null:
		farthest_xp.xp_value += amount
		return
	var p: WorldPickup = WorldPickup.new()
	p.setup_xp(pos, amount)
	world_root.add_child(p)
	pickups.append(p)

func _spawn_heart_pickup(pos: Vector3, heal: float) -> void:
	var p: WorldPickup = WorldPickup.new()
	p.setup_heart(pos, heal)
	world_root.add_child(p)
	pickups.append(p)

func _spawn_dust_pickup(pos: Vector3, amount: int) -> void:
	var p: WorldPickup = WorldPickup.new()
	p.setup_dust(pos, amount)
	world_root.add_child(p)
	pickups.append(p)

func _spawn_item_pickup(pos: Vector3, item: ItemInstance) -> void:
	var p: WorldPickup = WorldPickup.new()
	p.setup_item(pos, item)
	world_root.add_child(p)
	pickups.append(p)

func _spawn_gem_pickup(pos: Vector3, gem: GemInstance) -> void:
	var p: WorldPickup = WorldPickup.new()
	p.setup_gem(pos, gem)
	world_root.add_child(p)
	pickups.append(p)

func step(delta: float, player_pos: Vector3, elapsed_sec: float) -> void:
	if stats == null:
		return
	for i in range(pickups.size() - 1, -1, -1):
		var pk: WorldPickup = pickups[i]
		if not is_instance_valid(pk):
			pickups.remove_at(i)
			continue
		if pk.step(delta, player_pos, stats.pickup_radius):
			var consumed: bool = _collect_pickup(pk, elapsed_sec)
			if consumed:
				pickups.remove_at(i)
				pk.queue_free()

func _collect_pickup(pk: WorldPickup, elapsed_sec: float) -> bool:
	match pk.kind:
		WorldPickup.Kind.XP:
			xp_collected.emit(pk.xp_value)
			return true
		WorldPickup.Kind.HEART:
			heart_collected.emit(pk.heal_value)
			return true
		WorldPickup.Kind.DUST:
			stats.prism_dust += pk.dust_value
			dust_collected.emit(pk.dust_value)
			return true
		WorldPickup.Kind.ITEM:
			if stats.can_add_item_to_bag():
				stats.item_bag.append(pk.item_data)
				item_looted.emit(pk.item_data)
				return true
			else:
				loot_bag_full.emit("Bag Full! Open [Tab] & Salvage")
				return false
		WorldPickup.Kind.GEM:
			if stats.can_add_gem_to_pouch():
				stats.gem_pouch.append(pk.gem_data)
				gem_looted.emit(pk.gem_data)
				return true
			else:
				loot_bag_full.emit("Gem Pouch Full! [Tab] to Salvage")
				return false
		WorldPickup.Kind.CHEST:
			var ilvl: int = clampi(1 + int(elapsed_sec / 60.0), 1, 20)
			var rare_or_magic: int = GameEnums.Rarity.RARE if _rng.randf() < 0.55 else GameEnums.Rarity.MAGIC
			var c_item: ItemInstance = ItemDatabase.generate_item(ilvl, rare_or_magic, stats.magic_find, -1, _rng)
			var c_gem: GemInstance = GemInstance.new(GemDatabase.roll_random_gem_id(_rng), 1)
			if stats.can_add_item_to_bag():
				stats.item_bag.append(c_item)
				item_looted.emit(c_item)
			else:
				_spawn_item_pickup(pk.global_position, c_item)
			if stats.can_add_gem_to_pouch():
				stats.gem_pouch.append(c_gem)
				gem_looted.emit(c_gem)
			else:
				_spawn_gem_pickup(pk.global_position, c_gem)
			stats.prism_dust += 12
			dust_collected.emit(12)
			heart_collected.emit(35.0)
			chest_opened.emit()
			return true
	return true

func get_ground_labels() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for pk in pickups:
		if not is_instance_valid(pk):
			continue
		if pk.kind == WorldPickup.Kind.ITEM or pk.kind == WorldPickup.Kind.GEM or pk.kind == WorldPickup.Kind.CHEST:
			out.append({
				"pos": pk.global_position + Vector3(0.0, 1.1, 0.0),
				"text": pk.get_label_text(),
				"color": pk.get_label_color(),
				"is_chest": pk.kind == WorldPickup.Kind.CHEST,
			})
	return out
