class_name LootManager
extends Node

signal item_looted(item: ItemInstance)
signal gem_looted(gem: GemInstance)
signal hero_heal_requested(amount: float)
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

func drop_for_enemy(enemy: EnemyEntity, _elapsed_sec: float) -> void:
	if world_root == null or stats == null:
		return
	var pos: Vector3 = enemy.global_position
	var lucky: bool = stats.has_lucky_clover

	if enemy.is_boss:
		for i in range(3):
			var r_forced: int = GameEnums.Rarity.UNIQUE if i == 0 else GameEnums.Rarity.RARE
			var b_item: ItemInstance = ItemDatabase.generate_item(r_forced, lucky, -1, _rng)
			spawn_specific_item(pos + Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5)), b_item)
		spawn_specific_gem(pos + Vector3(-1.4, 0.0, 1.2), GemInstance.new(GemDatabase.roll_random_gem_id(_rng, GameEnums.GemType.MAIN)))
		for _m in range(2):
			spawn_specific_gem(pos + Vector3(randf_range(-1.4, 1.4), 0.0, randf_range(-1.4, 1.4)), GemInstance.new(GemDatabase.roll_random_gem_id(_rng, GameEnums.GemType.MODIFIER)))
		hero_heal_requested.emit(50.0)
		return

	if enemy.is_elite:
		var elite_rarity: int = GameEnums.Rarity.RARE if _rng.randf() < (0.60 if lucky else 0.42) else GameEnums.Rarity.MAGIC
		spawn_specific_item(pos, ItemDatabase.generate_item(elite_rarity, lucky, -1, _rng))
		if _rng.randf() < 0.80:
			spawn_specific_gem(pos + Vector3(0.7, 0.0, 0.4), GemInstance.new(GemDatabase.roll_random_gem_id(_rng)))
		hero_heal_requested.emit(18.0)
		return

	# Regular enemy drops: strictly 3 loot types (Items, Main Abilities, Modifier Abilities)
	var item_chance: float = 0.11 if lucky else 0.085
	if _rng.randf() < item_chance:
		spawn_specific_item(pos, ItemDatabase.generate_item(-1, lucky, -1, _rng))

	var gem_chance: float = 0.095 if lucky else 0.075
	if _rng.randf() < gem_chance:
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
			var c_gem: GemInstance = GemInstance.new(GemDatabase.roll_random_gem_id(_rng))
			if stats.can_add_item_to_bag():
				stats.item_bag.append(c_item)
				item_looted.emit(c_item)
			else:
				spawn_specific_item(pk.global_position, c_item)
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
