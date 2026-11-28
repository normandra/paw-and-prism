class_name LootManager
extends Node

signal gold_collected(amount: int)
signal card_looted(card: CardInstance)
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

func drop_for_enemy(enemy: EnemyEntity, elapsed_sec: float) -> void:
	if world_root == null or stats == null:
		return
	var pos: Vector3 = enemy.global_position

	if enemy.is_boss:
		spawn_gold(pos + Vector3(0.0, 0.0, -1.0), 22)
		spawn_gold(pos + Vector3(-1.1, 0.0, 0.9), 22)
		spawn_gold(pos + Vector3(1.1, 0.0, 0.9), 21)
		hero_heal_requested.emit(BalanceConfig.BOSS_HEAL)
		return

	if enemy.is_elite:
		spawn_gold(pos, BalanceConfig.GOLD_VALUE_ELITE)
		hero_heal_requested.emit(BalanceConfig.ELITE_HEAL)
		return

	if _rng.randf() < BalanceConfig.GOLD_DROP_CHANCE:
		var coin_val: int = BalanceConfig.GOLD_VALUE_ENEMY
		if elapsed_sec >= 600.0 and _rng.randf() < 0.38:
			coin_val += 1
		spawn_gold(pos, coin_val)

func spawn_gold(pos: Vector3, amount: int) -> WorldPickup:
	if world_root == null:
		return null
	var p: WorldPickup = WorldPickup.new()
	p.setup_gold(pos, amount)
	world_root.add_child(p)
	pickups.append(p)
	return p

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

func collect_all_ground_gold() -> int:
	if stats == null:
		return 0
	var total_gained: int = 0
	for i in range(pickups.size() - 1, -1, -1):
		var pk: WorldPickup = pickups[i]
		if not is_instance_valid(pk):
			pickups.remove_at(i)
			continue
		if pk.kind == WorldPickup.Kind.GOLD_COIN:
			var gained: int = stats.add_gold(pk.gold_amount)
			total_gained += gained
			pickups.remove_at(i)
			pk.queue_free()
	if total_gained > 0:
		gold_collected.emit(total_gained)
	return total_gained

func step(delta: float, player_pos: Vector3, _elapsed_sec: float) -> void:
	if stats == null:
		return
	var mag_mult: float = stats.magnet_mult
	for i in range(pickups.size() - 1, -1, -1):
		var pk: WorldPickup = pickups[i]
		if not is_instance_valid(pk):
			pickups.remove_at(i)
			continue
		if pk.step(delta, player_pos, mag_mult):
			pickups.remove_at(i)
			var consumed: bool = _collect_pickup(pk)
			if consumed:
				if is_instance_valid(pk):
					pk.queue_free()
			else:
				pickups.insert(i, pk)

func _collect_pickup(pk: WorldPickup) -> bool:
	match pk.kind:
		WorldPickup.Kind.GOLD_COIN:
			var gained: int = stats.add_gold(pk.gold_amount)
			gold_collected.emit(gained)
			return true
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
			var gained: int = stats.add_gold(BalanceConfig.GOLD_VALUE_CHEST)
			gold_collected.emit(gained)
			hero_heal_requested.emit(BalanceConfig.CHEST_HEAL)
			chest_opened.emit()
			return true
	return true

func get_ground_labels() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for pk in pickups:
		if not is_instance_valid(pk):
			continue
		var txt: String = pk.get_label_text()
		if txt.is_empty():
			continue
		out.append({
			"pos": pk.global_position + Vector3(0.0, 1.1, 0.0),
			"text": txt,
			"color": pk.get_label_color(),
			"is_chest": pk.kind == WorldPickup.Kind.CHEST,
		})
	return out
