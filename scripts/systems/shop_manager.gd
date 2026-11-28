class_name ShopManager
extends RefCounted

const TEMPLATE_COUNT: int = 3
const ADDON_COUNT: int = 4
const RELIC_COUNT: int = 2

var shop_index: int = 0
var reroll_count: int = 0
var template_offers: Array[Dictionary] = []
var addon_offers: Array[Dictionary] = []
var relic_offers: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	_rng.randomize()

func reset() -> void:
	shop_index = 0
	reroll_count = 0
	template_offers.clear()
	addon_offers.clear()
	relic_offers.clear()

func setup_for_shop(p_shop_idx: int, elapsed_sec: float, stats: HeroStats) -> void:
	shop_index = p_shop_idx
	reroll_count = 0
	_roll_stock(elapsed_sec, stats)

func setup_tutorial_shop() -> void:
	shop_index = 0
	reroll_count = 0
	template_offers.clear()
	addon_offers.clear()
	relic_offers.clear()

	var t1: CardInstance = CardInstance.new("honey_slam", GameEnums.Rarity.COMMON)
	template_offers.append({"card": t1, "base_price": 45, "sold": false})
	var t2: CardInstance = CardInstance.new("starlight_orb", GameEnums.Rarity.UNCOMMON)
	template_offers.append({"card": t2, "base_price": 65, "sold": false})

	var a1: CardInstance = CardInstance.new("addon_multishot", GameEnums.Rarity.COMMON)
	addon_offers.append({"card": a1, "base_price": 30, "sold": false})
	var a2: CardInstance = CardInstance.new("addon_ignite", GameEnums.Rarity.UNCOMMON)
	addon_offers.append({"card": a2, "base_price": 50, "sold": false})

	var r1: Dictionary = RelicDatabase.get_def("relic_golden_acorn")
	relic_offers.append({"relic_id": "relic_golden_acorn", "def": r1, "base_price": 70, "sold": false})

func get_effective_price(base_price: int, stats: HeroStats) -> int:
	var mult: float = stats.shop_price_mult if stats != null else 1.0
	return maxi(5, int(round(float(base_price) * mult)))

func get_reroll_cost(stats: HeroStats) -> int:
	var raw: int = BalanceConfig.SHOP_REROLL_BASE + reroll_count * BalanceConfig.SHOP_REROLL_STEP
	return get_effective_price(raw, stats)

func reroll(stats: HeroStats, elapsed_sec: float) -> bool:
	if stats == null:
		return false
	var cost: int = get_reroll_cost(stats)
	if not stats.spend_gold(cost):
		return false
	reroll_count += 1
	_roll_stock(elapsed_sec, stats)
	return true

func buy_template(idx: int, stats: HeroStats) -> Dictionary:
	if stats == null or idx < 0 or idx >= template_offers.size():
		return {"ok": false, "reason": "Invalid Shop Slot"}
	var offer: Dictionary = template_offers[idx]
	if bool(offer.get("sold", false)):
		return {"ok": false, "reason": "Already Sold"}
	if not stats.can_add_template():
		return {"ok": false, "reason": "Templates Bag Full"}
	var price: int = get_effective_price(int(offer["base_price"]), stats)
	if not stats.spend_gold(price):
		return {"ok": false, "reason": "Need %d Gold" % price}
	offer["sold"] = true
	var card: CardInstance = offer["card"]
	stats.template_inventory.append(card)
	return {"ok": true, "card": card, "cost": price}

func buy_addon(idx: int, stats: HeroStats) -> Dictionary:
	if stats == null or idx < 0 or idx >= addon_offers.size():
		return {"ok": false, "reason": "Invalid Shop Slot"}
	var offer: Dictionary = addon_offers[idx]
	if bool(offer.get("sold", false)):
		return {"ok": false, "reason": "Already Sold"}
	if not stats.can_add_addon():
		return {"ok": false, "reason": "Add-ons Bag Full"}
	var price: int = get_effective_price(int(offer["base_price"]), stats)
	if not stats.spend_gold(price):
		return {"ok": false, "reason": "Need %d Gold" % price}
	offer["sold"] = true
	var card: CardInstance = offer["card"]
	stats.addon_inventory.append(card)
	return {"ok": true, "card": card, "cost": price}

func buy_relic(idx: int, stats: HeroStats) -> Dictionary:
	if stats == null or idx < 0 or idx >= relic_offers.size():
		return {"ok": false, "reason": "Invalid Shop Slot"}
	var offer: Dictionary = relic_offers[idx]
	if bool(offer.get("sold", false)):
		return {"ok": false, "reason": "Already Sold"}
	var rid: String = String(offer["relic_id"])
	if stats.has_relic(rid):
		offer["sold"] = true
		return {"ok": false, "reason": "Already Owned"}
	var price: int = get_effective_price(int(offer["base_price"]), stats)
	if not stats.spend_gold(price):
		return {"ok": false, "reason": "Need %d Gold" % price}
	offer["sold"] = true
	stats.add_relic(rid)
	var rdef: Dictionary = offer["def"]
	return {"ok": true, "relic_id": rid, "name": String(rdef.get("name", rid)), "cost": price}

func _roll_stock(elapsed_sec: float, stats: HeroStats) -> void:
	template_offers.clear()
	addon_offers.clear()
	relic_offers.clear()

	# 1. Template Cards Shelf (distinct IDs when possible)
	var picked_tpls: Array[String] = []
	for i in range(TEMPLATE_COUNT):
		var rar: int = CardDatabase.roll_template_rarity(elapsed_sec, _rng, GameEnums.Rarity.UNCOMMON if (i == 0 and elapsed_sec >= 170.0) else -1)
		var cid: String = CardDatabase.roll_template_id(_rng)
		for _t in range(6):
			if not picked_tpls.has(cid):
				break
			cid = CardDatabase.roll_template_id(_rng)
		picked_tpls.append(cid)
		var card: CardInstance = CardInstance.new(cid, rar)
		var base_p: int = int(BalanceConfig.TEMPLATE_PRICE_BY_RARITY.get(rar, 65))
		template_offers.append({"card": card, "base_price": base_p, "sold": false})

	# 2. Add-on Cards Shelf (smart bias toward Add-ons usable on equipped Template Cards)
	var picked_adds: Array[String] = []
	for i in range(ADDON_COUNT):
		var addon: CardInstance = CardInstance.generate_addon(elapsed_sec, _rng)
		if stats != null and not stats.equipped_cards.is_empty() and i < 2:
			for _t in range(8):
				var compatible: bool = false
				for eq in stats.equipped_cards:
					if eq != null and CardDatabase.does_addon_apply(addon.card_id, eq.card_id):
						compatible = true
						break
				if compatible and not picked_adds.has(addon.card_id):
					break
				addon = CardInstance.generate_addon(elapsed_sec, _rng)
		else:
			for _t2 in range(5):
				if not picked_adds.has(addon.card_id):
					break
				addon = CardInstance.generate_addon(elapsed_sec, _rng)
		picked_adds.append(addon.card_id)
		var base_ap: int = int(BalanceConfig.ADDON_PRICE_BY_RARITY.get(addon.rarity, 45))
		addon_offers.append({"card": addon, "base_price": base_ap, "sold": false})

	# 3. Slay-the-Spire Relics Shelf (only unowned relics)
	var owned: Array[String] = stats.owned_relics if stats != null else []
	var unowned: Array[String] = RelicDatabase.get_unowned_ids(owned)
	# Deterministic partial shuffle using _rng
	for i in range(unowned.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: String = unowned[i]
		unowned[i] = unowned[j]
		unowned[j] = tmp
	var take: int = mini(RELIC_COUNT, unowned.size())
	for k in range(take):
		var rid: String = unowned[k]
		var rdef: Dictionary = RelicDatabase.get_def(rid)
		relic_offers.append({
			"relic_id": rid,
			"def": rdef,
			"base_price": int(rdef.get("cost", 75)),
			"sold": false,
		})
