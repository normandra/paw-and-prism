extends SceneTree

# Automated Paw & Prism v3.0 Card-Forging Balance Audit System
# Usage: godot --headless --path . --script res://tests/balance_audit.gd

var _failures: Array[String] = []

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("BALANCE FAIL: " + msg)
	else:
		print("OK: " + msg)

func _initialize() -> void:
	call_deferred("_run_audit")

func _card_dps(cfg: Dictionary, cd_rate_mult: float = 1.0, extra_target_hits: int = 1) -> float:
	var dmg: float = float(cfg.get("damage", 20.0)) * BalanceConfig.expected_crit_mult()
	var still_rate: float = float(cfg.get("turret_still_mult", 1.0))
	var eff_rate: float = still_rate if cd_rate_mult > 1.0 else cd_rate_mult
	if cd_rate_mult <= 1.0 and float(cfg.get("turret_move_mult", 1.0)) < 0.99:
		eff_rate = float(cfg.get("turret_move_mult", 1.0))
	var cd: float = maxf(0.18, float(cfg.get("cooldown", 1.0))) / maxf(0.25, eff_rate)
	var echo_n: int = int(cfg.get("echo_count", 0))
	var casts: float = 1.0 + float(echo_n)
	var proj_n: int = maxi(1, int(cfg.get("projectiles", 1)))
	var hit_weight: float = 1.0
	var cid: String = String(cfg.get("card_id", ""))
	if cid == "starlight_orb":
		var orb_n: int = proj_n + echo_n
		hit_weight = 1.0 + float(maxi(0, orb_n - 1)) * BalanceConfig.VOLLEY_REPEAT_MULT
		casts = 1.0
	elif cid in ["spirit_bees", "acorn_barrage", "fireball_berry", "petal_cyclone", "frost_nova"]:
		var hits_on_boss: int = mini(proj_n, maxi(1, extra_target_hits))
		hit_weight = 1.0 + float(maxi(0, hits_on_boss - 1)) * BalanceConfig.VOLLEY_REPEAT_MULT
	var direct_dps: float = (dmg * hit_weight * casts) / cd
	var burn_mult: float = float(cfg.get("burn_mult", 1.0))
	var burn_dps: float = dmg * BalanceConfig.BURN_DPS_RATIO * burn_mult if bool(cfg.get("ignite", false)) else 0.0
	var cadence_bonus: float = 0.0
	var cad_stacks: int = int(cfg.get("cadence_stacks", 0))
	if cad_stacks > 0:
		var cad_dmg: float = BalanceConfig.CADENCE_DMG + BalanceConfig.CADENCE_DMG_STACK * float(cad_stacks - 1)
		cadence_bonus = (cad_dmg * BalanceConfig.expected_crit_mult()) / (cd * float(BalanceConfig.CADENCE_EVERY_N))
	return direct_dps + burn_dps + cadence_bonus

func _deck_total_dps(cards: Array[CardInstance], stand_still: bool = true) -> float:
	var cd_mult: float = BalanceConfig.compute_deck_cd_mult(cards.size())
	var total: float = 0.0
	for c in cards:
		var cfg: Dictionary = HeroStats.compile_card_config(c, cd_mult)
		var hits_est: int = 2 if c.card_id == "spirit_bees" else 1
		total += _card_dps(cfg, 1.5 if stand_still else 0.9, hits_est)
	return total

func _make_forged_card(cid: String, rarity: int, addons: Array[String]) -> CardInstance:
	var c: CardInstance = CardInstance.new(cid, rarity)
	for aid in addons:
		c.apply_forge(aid)
	return c

func _run_audit() -> void:
	print("=== Paw & Prism v3.0 Automated Balance Audit ===")
	print("--- 1. T0 Single Template Card Baseline DPS (crit=x%.3f) ---" % BalanceConfig.expected_crit_mult())

	for cid in CardDatabase.get_all_template_ids():
		var card: CardInstance = CardInstance.new(cid, GameEnums.Rarity.COMMON)
		var cfg: Dictionary = HeroStats.compile_card_config(card, 1.0)
		var st_hits: int = 2 if cid == "spirit_bees" else 1
		var dps: float = _card_dps(cfg, 1.0, st_hits)
		print("  %-18s dmg=%4.1f  cd=%.2fs  ST_DPS=%5.1f" % [card.get_card_name(), float(cfg["damage"]), float(cfg["cooldown"]), dps])
		_check(dps >= 10.0 and dps <= 40.0, "T0 %s ST DPS within [10, 40] (got %.1f)" % [cid, dps])

	print("--- 2. Deck Progression: 1-Card Hyper-Forge vs 3-Card Well-Forged Endgame vs Unforged Bloat ---")
	# Boss 1 (06:30): Early Uncommon Acorn (2/2) + Common Honey Slam (1/1)
	var t1_deck: Array[CardInstance] = [
		_make_forged_card("acorn_barrage", GameEnums.Rarity.UNCOMMON, ["addon_sniper_focus", "addon_pierce"]),
		_make_forged_card("honey_slam", GameEnums.Rarity.COMMON, ["addon_chill"]),
	]
	var t1_dps: float = _deck_total_dps(t1_deck, false)

	# Boss 2 (13:00): Uncommon Acorn (2/2) + Rare Meteor (2/3)
	var t2_deck: Array[CardInstance] = [
		_make_forged_card("acorn_barrage", GameEnums.Rarity.UNCOMMON, ["addon_sniper_focus", "addon_echo"]),
		_make_forged_card("meteor_pine", GameEnums.Rarity.RARE, ["addon_giant_blast", "addon_chill"]),
	]
	var t2_dps: float = _deck_total_dps(t2_deck, false)

	# 1-Card Legendary Hyper-Forge (4/4)
	var hyper_one: CardInstance = _make_forged_card("acorn_barrage", GameEnums.Rarity.LEGENDARY, ["addon_sniper_focus", "addon_echo", "addon_glass_spark", "addon_overclock"])
	var hyper_one_still: float = _card_dps(HeroStats.compile_card_config(hyper_one, 1.0), 1.5, 1)
	var hyper_one_move: float = _card_dps(HeroStats.compile_card_config(hyper_one, 1.0), 0.9, 1)

	# 3-Card Well-Forged Endgame Deck (e.g. 1 Legendary 4/4 + 2 Rare 3/3)
	var forged_three: Array[CardInstance] = [
		_make_forged_card("acorn_barrage", GameEnums.Rarity.LEGENDARY, ["addon_sniper_focus", "addon_echo", "addon_glass_spark", "addon_overclock"]),
		_make_forged_card("meteor_pine", GameEnums.Rarity.RARE, ["addon_echo", "addon_giant_blast", "addon_chill"]),
		_make_forged_card("whisker_lightning", GameEnums.Rarity.RARE, ["addon_chain", "addon_ignite", "addon_leech"]),
	]
	var forged_three_still: float = _deck_total_dps(forged_three, true)
	var forged_three_move: float = _deck_total_dps(forged_three, false)

	# 6-Card Unforged Random Spam (deck bloat)
	var spam_six: Array[CardInstance] = []
	for sid in ["acorn_barrage", "whisker_lightning", "fireball_berry", "honey_slam", "spirit_bees", "boomerang_bone"]:
		spam_six.append(CardInstance.new(sid, GameEnums.Rarity.COMMON))
	var spam_six_dps: float = _deck_total_dps(spam_six, false)

	# 3 Well-Forged + 3 Raw Bloat Cards
	var bloated_six: Array[CardInstance] = forged_three.duplicate()
	for extra_id in ["petal_cyclone", "frost_nova", "boomerang_bone"]:
		bloated_six.append(CardInstance.new(extra_id, GameEnums.Rarity.COMMON))
	var bloated_six_move: float = _deck_total_dps(bloated_six, false)

	print("  T1 Early Deck (06:30):              ST_DPS=%.1f" % t1_dps)
	print("  T2 Mid Deck (13:00):                ST_DPS=%.1f" % t2_dps)
	print("  1-Card Legendary Acorn (4/4):       Still=%.1f  Move=%.1f" % [hyper_one_still, hyper_one_move])
	print("  3-Card Well-Forged Endgame:         Still=%.1f  Move=%.1f (CD x%.2f)" % [forged_three_still, forged_three_move, BalanceConfig.compute_deck_cd_mult(3)])
	print("  3-Forged + 3-Raw Bloat (6 Cards):   Move=%.1f (CD x%.2f)" % [bloated_six_move, BalanceConfig.compute_deck_cd_mult(6)])
	print("  6-Card Unforged Spam:               Total=%.1f (CD x%.2f)" % [spam_six_dps, BalanceConfig.compute_deck_cd_mult(6)])

	_check(forged_three_still > spam_six_dps * 2.0, "3-Card Forged Endgame beats 6-Card unforged spam by >2.0x (%.1f vs %.1f)" % [forged_three_still, spam_six_dps])
	_check(forged_three_move > bloated_six_move, "Trimmed 3-Card Forged Deck beats 3-Forged + 3-Raw Bloat (%.1f vs %.1f)" % [forged_three_move, bloated_six_move])

	print("--- 3. Boss & Elite TTK ---")
	var b1_hp: float = float(EnemyDatabase.get_def("boss_grizzle")["hp"])
	var b2_hp: float = float(EnemyDatabase.get_def("boss_whiskers")["hp"])
	var b3_hp: float = float(EnemyDatabase.get_def("boss_bramblehorn")["hp"])
	var t_b1: float = b1_hp / maxf(1.0, t1_dps)
	var t_b2: float = b2_hp / maxf(1.0, t2_dps)
	var t_b3_still: float = b3_hp / maxf(1.0, forged_three_still)
	var t_b3_move: float = b3_hp / maxf(1.0, forged_three_move)
	var late_prof: Dictionary = EnemyDatabase.get_wave_profile(1170.0)
	var bandit_hp: float = float(EnemyDatabase.get_def("raccoon_bandit")["hp"]) * float(late_prof["hp_scale"])
	var bandit_ttk: float = bandit_hp / maxf(1.0, forged_three_move)

	print("  06:30 Grizzle (%.0f HP) @ T1:         %.1fs" % [b1_hp, t_b1])
	print("  13:00 Whiskers (%.0f HP) @ T2:        %.1fs" % [b2_hp, t_b2])
	print("  19:30 Bramblehorn (%.0f HP) @ 3-Card: Still=%.1fs  Move=%.1fs" % [b3_hp, t_b3_still, t_b3_move])
	print("  19:30 Bandit (%.0f HP) @ 3-Card Move: %.1fs" % [bandit_hp, bandit_ttk])

	_check(t_b1 >= 20.0 and t_b1 <= 55.0, "Boss 1 TTK at T1 within [20s, 55s] (got %.1fs)" % t_b1)
	_check(t_b2 >= 30.0 and t_b2 <= 75.0, "Boss 2 TTK at T2 within [30s, 75s] (got %.1fs)" % t_b2)
	_check(t_b3_still >= 30.0 and t_b3_still <= 65.0, "Boss 3 TTK at 3-Card Still within [30s, 65s] (got %.1fs)" % t_b3_still)
	_check(bandit_ttk <= 9.0, "Late Bandit TTK at 3-Card Move <= 9.0s (got %.1fs)" % bandit_ttk)

	print("--- 4. Lethality (Hits-to-Die) & Sustain Caps ---")
	var m_hp: float = float(HeroDatabase.get_hero("shiba")["base_hp"])
	var late_dmg_scale: float = float(late_prof["dmg_scale"])
	var bandit_dmg: float = float(EnemyDatabase.get_def("raccoon_bandit")["damage"]) * late_dmg_scale
	var boss3_tele: float = float(EnemyDatabase.get_def("boss_bramblehorn")["damage"]) * late_dmg_scale * 1.65
	var hits_bandit: int = int(ceil(m_hp / bandit_dmg))
	var hits_boss3_tele: int = int(ceil(m_hp / boss3_tele))
	var hits_glass_tele: int = int(ceil(m_hp / (boss3_tele * (1.0 + BalanceConfig.GLASS_TAKEN_BONUS))))
	var max_sustain_hps: float = BalanceConfig.BASE_HP_REGEN + (BalanceConfig.LEECH_MAX_PER_PROC / BalanceConfig.LEECH_ICD_SEC)

	print("  Mochi HP=%.0f | 19:30 Bandit=%.1f dmg (%d hits) | Boss3 Cross=%.1f (%d hits, Glass %d hit)" % [m_hp, bandit_dmg, hits_bandit, boss3_tele, hits_boss3_tele, hits_glass_tele])
	print("  Max Capped Sustain HP/s: %.2f HP/s (Regen=%.2f + Leech=%.2f)" % [max_sustain_hps, BalanceConfig.BASE_HP_REGEN, BalanceConfig.LEECH_MAX_PER_PROC / BalanceConfig.LEECH_ICD_SEC])
	_check(hits_bandit >= 2 and hits_bandit <= 5, "Late regular Bandit kills Mochi in 2-5 hits (got %d)" % hits_bandit)
	_check(hits_boss3_tele == 2 and hits_glass_tele == 1, "Boss 3 telegraph 2-shots standard Mochi and 1-shots Glass (got %d, Glass %d)" % [hits_boss3_tele, hits_glass_tele])

	print("--- 5. Speed Pressure & 20-Min Deterministic Shop Gold Economy ---")
	var m_spd: float = float(HeroDatabase.get_hero("shiba")["base_speed"])
	var late_bandit_spd: float = float(EnemyDatabase.get_def("raccoon_bandit")["speed"]) * float(late_prof["speed_scale"])
	print("  Mochi Speed=%.1f | 19:30 Bandit Speed=%.2f (%.0f%% of Mochi)" % [m_spd, late_bandit_spd, (late_bandit_spd / m_spd) * 100.0])
	_check(late_bandit_spd >= m_spd * 0.90, "Late Bandit >= 90%% of Mochi speed (%.2f vs %.1f)" % [late_bandit_spd, m_spd])

	var est_enemy_gold: float = 950.0 * BalanceConfig.GOLD_DROP_CHANCE * float(BalanceConfig.GOLD_VALUE_ENEMY)
	var est_elite_gold: float = 14.0 * float(BalanceConfig.GOLD_VALUE_ELITE)
	var est_boss_gold: float = 3.0 * float(BalanceConfig.GOLD_VALUE_BOSS)
	var est_chest_gold: float = 12.0 * float(BalanceConfig.GOLD_VALUE_CHEST)
	var est_total_gold: float = float(BalanceConfig.STARTING_GOLD) + est_enemy_gold + est_elite_gold + est_boss_gold + est_chest_gold
	print("  6 Caravan Shops (every %.0fs) | Est. 20m Gold Income: ~%.0f G" % [BalanceConfig.SHOP_INTERVAL_SEC, est_total_gold])
	_check(est_total_gold >= 1300.0 and est_total_gold <= 2600.0, "Est. 20m Gold budget within [1300, 2600] (got %.0f G)" % est_total_gold)

	if _failures.is_empty():
		print("=== BALANCE AUDIT PASSED ===")
		quit(0)
	else:
		print("=== BALANCE AUDIT FAILED (%d checks) ===" % _failures.size())
		quit(1)
